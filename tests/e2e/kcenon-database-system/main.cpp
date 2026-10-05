#include <cstdlib>
#include <iostream>
#include <kcenon/database/database_manager.h>
#include <memory>

int main()
{
    database::database_manager manager(std::make_shared<database::database_context>());
    std::cout << "database_system e2e: OK" << std::endl;
    return EXIT_SUCCESS;
}
