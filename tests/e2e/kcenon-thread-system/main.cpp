#include <cstdlib>
#include <iostream>
#include <kcenon/thread/thread_pool.h>

int main()
{
    kcenon::thread::thread_pool pool;
    // A newly constructed pool has a queue and no workers. Starting it before
    // adding a worker is invalid; exercise the installed archive via queries.
    if (!pool.get_job_queue()) return EXIT_FAILURE;
    if (pool.get_active_worker_count() != 0) return EXIT_FAILURE;
    std::cout << "thread_system e2e: OK" << std::endl;
    return EXIT_SUCCESS;
}
