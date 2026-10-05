#include "thread_abi_expected.h"
#include <iostream>
#include <memory>
#include <kcenon/thread/core/thread_pool.h>
#include <kcenon/thread/core/thread_worker.h>
#include "worker_contract.h"

int main()
{
    std::cout << "Installed Thread worker size="
              << sizeof(kcenon::thread::thread_worker) << std::endl;
    return run_common_worker_contract();
}
