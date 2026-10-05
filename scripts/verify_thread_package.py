"""Verify installed Thread exports against the archive's actual compilation flags."""
import argparse
import json
import os
from pathlib import Path
import shlex
import subprocess

FEATURES = [
    "USE_STD_JTHREAD", "USE_STD_CONCEPTS", "HAS_STD_ATOMIC_WAIT", "HAS_STD_LATCH",
    "USE_STD_SPAN", "USE_STD_FORMAT", "USE_STD_FILESYSTEM", "USE_STD_RANGES",
    "USE_STD_CHRONO_CURRENT_ZONE", "BUILD_WITH_COMMON_SYSTEM", "KCENON_HAS_COMMON_EXECUTOR",
]


def definitions(arguments):
    result = {}
    iterator = iter(arguments)
    for arg in iterator:
        if arg.startswith(("-D", "/D")):
            definition = arg[2:] or next(iterator)
            name, _, value = definition.partition("=")
            result[name] = value or "1"
        elif arg.startswith(("-U", "/U")):
            result.pop(arg[2:] or next(iterator), None)
    return {name: result.get(name) for name in FEATURES}


def run(command, *, cwd, env=None, negative=False, log_name=None):
    print("+ " + shlex.join(map(str, command)), flush=True)
    result = subprocess.run(list(map(str, command)), cwd=cwd, env=env,
                            text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=300)
    print(result.stdout, flush=True)
    if log_name:
        (cwd / log_name).write_text(result.stdout)
    if negative:
        if result.returncode == 0 or "THREAD_ABI_MISMATCH_USE_STD_JTHREAD" not in result.stdout:
            raise RuntimeError("ABI mutation did not fail for the expected feature mismatch")
    elif result.returncode:
        raise RuntimeError(f"Command failed with exit {result.returncode}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--consumer", type=Path, required=True)
    parser.add_argument("--vcpkg", type=Path, required=True)
    parser.add_argument("--triplet", required=True)
    parser.add_argument("--prepare", action="store_true")
    args = parser.parse_args()
    consumer, vcpkg = args.consumer.resolve(), args.vcpkg.resolve()
    evidence = consumer / "thread-abi.json"
    if args.prepare:
        commands_path = vcpkg / "buildtrees/kcenon-thread-system" / (args.triplet + "-rel") / "compile_commands.json"
        commands = json.loads(commands_path.read_text())
        snapshots = []
        for entry in commands:
            command = entry.get("arguments") or shlex.split(entry["command"])
            if any("CMakeFiles/thread_system.dir/" in arg.replace("\\", "/") for arg in command):
                snapshots.append(definitions(command))
        if not snapshots or any(s != snapshots[0] for s in snapshots):
            raise RuntimeError("Missing or inconsistent archive feature definitions")
        expected = snapshots[0]
        if expected["BUILD_WITH_COMMON_SYSTEM"] != "1":
            raise RuntimeError("Archive compilation provenance did not include required common integration")
        lines = ["#pragma once"]
        for name, value in expected.items():
            marker = "THREAD_ABI_MISMATCH_" + name
            if value is None:
                lines += [f"#ifdef {name}", f'#error "{marker}: unexpected definition"', "#endif"]
            else:
                lines += [f"#ifndef {name}", f'#error "{marker}: missing definition"', "#else",
                          f'static_assert({name} == {value}, "{marker}: different value");', "#endif"]
        (consumer / "thread_abi_expected.h").write_text("\n".join(lines) + "\n")
        evidence.write_text(json.dumps({"archive_definitions": expected,
                                       "archive_translation_units": len(snapshots),
                                       "compile_commands": str(commands_path)}, indent=2) + "\n")
        print(evidence.read_text())
        return

    results = json.loads(evidence.read_text())
    prefix = consumer / "vcpkg_installed" / args.triplet
    env = dict(os.environ, PKG_CONFIG_PATH=str(prefix / "lib/pkgconfig"),
               PKG_CONFIG_LIBDIR=str(prefix / "lib/pkgconfig"),
               PATH=str(prefix / "bin") + os.pathsep + os.environ["PATH"])
    pkg = [os.environ.get("PKG_CONFIG", "pkg-config")]
    if os.name == "nt":
        pkg.append("--msvc-syntax")
    cflags = shlex.split(subprocess.check_output([*pkg, "--cflags", "thread_system"], env=env, text=True))
    libs = shlex.split(subprocess.check_output([*pkg, "--static", "--libs", "thread_system"], env=env, text=True))
    if definitions(cflags) != results["archive_definitions"]:
        raise RuntimeError(f"pkg-config flags differ from the archive: {cflags}")
    mutation = ("/" if os.name == "nt" else "-") + (
        "UUSE_STD_JTHREAD" if results["archive_definitions"]["USE_STD_JTHREAD"] is not None
        else "DUSE_STD_JTHREAD=1")
    compiler = shlex.split(os.environ.get("CXX", "cl" if os.name == "nt" else "c++"))
    for negative in (False, True):
        output = consumer / ("pkg-negative" if negative else "pkg-consumer")
        flags = [*cflags, *([mutation] if negative else [])]
        if os.name == "nt":
            output = output.with_suffix(".exe")
            command = [*compiler, "/nologo", "/std:c++20", "/EHsc", "/MD", "/fsanitize=address", "/Zi",
                       *flags, consumer / "main.cpp", f"/Fe:{output}", "/link", *libs]
        else:
            command = [*compiler, "-std=c++20", "-fsanitize=address", "-fno-omit-frame-pointer",
                       *flags, consumer / "main.cpp", "-o", output, *libs]
        run(command, cwd=consumer, env=env, negative=negative,
            log_name="pkg-negative.log" if negative else "pkg-build.log")
        if not negative:
            run([output], cwd=consumer, env=env, log_name="pkg-run.log")
    negative_build = consumer / "build-negative"
    run(["cmake", "-S", consumer, "-B", negative_build,
         f"-DCMAKE_TOOLCHAIN_FILE={vcpkg}/scripts/buildsystems/vcpkg.cmake",
         f"-DVCPKG_TARGET_TRIPLET={args.triplet}", f"-DVCPKG_INSTALLED_DIR={consumer}/vcpkg_installed",
         f"-DABI_NEGATIVE_FLAG={mutation}"], cwd=consumer)
    run(["cmake", "--build", negative_build, "--config", "Release"], cwd=consumer,
        negative=True, log_name="cmake-negative.log")
    results.update(cmake="passed", pkg_config="passed", cmake_negative="rejected", pkg_negative="rejected")
    evidence.write_text(json.dumps(results, indent=2) + "\n")


if __name__ == "__main__":
    main()
