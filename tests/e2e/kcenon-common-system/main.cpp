#include <cstdlib>
#include <iostream>

// Verify header-only package is discoverable and headers are installed.
#include <kcenon/common/common.h>

int main()
{
    std::cout << "common_system e2e: OK" << std::endl;
    return EXIT_SUCCESS;
}
