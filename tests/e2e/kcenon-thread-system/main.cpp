#include <cstdlib>
#include <iostream>
#include <kcenon/thread/thread_pool.h>

int main()
{
    kcenon::thread::thread_pool pool;
    if (pool.start().is_err()) return EXIT_FAILURE;
    if (pool.stop().is_err()) return EXIT_FAILURE;
    std::cout << "thread_system e2e: OK" << std::endl;
    return EXIT_SUCCESS;
}
