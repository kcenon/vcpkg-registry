#include <cstdlib>
#include <iostream>

// Verify installation and linking against pacs_system::core.
// v0.1.0 installs headers under pacs/ (no kcenon/ prefix) with .hpp extension.
#include <pacs/core/dicom_tag.hpp>

int main()
{
    std::cout << "pacs_system e2e: OK" << std::endl;
    return EXIT_SUCCESS;
}
