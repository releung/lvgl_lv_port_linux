cmake_minimum_required(VERSION 3.16)
project(lvgl_example C CXX)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(main main.c)

find_package(lv_port_linux CONFIG REQUIRED COMPONENTS demos)

target_link_libraries(main PRIVATE
    lv_port_linux::sdk_core
    lv_port_linux::demos
)

set_target_properties(main PROPERTIES
    LINKER_LANGUAGE CXX
)

add_custom_target(run
    COMMAND $<TARGET_FILE:main>
    DEPENDS main
)
