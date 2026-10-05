#include <cstdlib>
#include <iostream>
#include <kcenon/monitoring/core/performance_monitor.h>

int main()
{
    kcenon::monitoring::performance_monitor monitor;
    if (monitor.get_name().empty()) return EXIT_FAILURE;
    std::cout << "monitoring_system e2e: OK" << std::endl;
    return EXIT_SUCCESS;
}
