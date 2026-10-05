#include <kcenon/container/container.h>

#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <variant>

int main()
{
    kcenon::container::value_container container;
    container.set("answer", std::int32_t{42});
    const auto value = container.get("answer");
    const auto* answer = value ? std::get_if<std::int32_t>(&value->data) : nullptr;
    if (!answer || *answer != 42 || container.contains("missing")) {
        std::cerr << "container_system installed API check failed\n";
        return EXIT_FAILURE;
    }
    std::cout << "container_system installed API: answer=42\n";
    return EXIT_SUCCESS;
}
