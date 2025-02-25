cmake_minimum_required(VERSION 3.10)
project(unitree_mujoco)

# Set verbosity for debugging
set(CMAKE_VERBOSE_MAKEFILE ON)

# Find libraries
find_package(GLEW REQUIRED)
find_package(glfw3 REQUIRED)

# Set include directories
include_directories(${CMAKE_SOURCE_DIR}/src)
include_directories(/usr/local/include)
include_directories(/usr/local/include/mujoco)

# Print debug info
message(STATUS "Include directories:")
message(STATUS "  /usr/local/include")
message(STATUS "  /usr/local/include/mujoco")
message(STATUS "  ${CMAKE_SOURCE_DIR}/src")

# Set source files
set(SOURCES
    src/mujoco/main.cc
    src/mujoco/simulate.cc
    src/mujoco/platform_ui_adapter.cc
)

# Create executable
add_executable(unitree_mujoco ${SOURCES})

# Find Mujoco library with version number
find_library(MUJOCO_LIB 
    NAMES mujoco210 libmujoco210
    PATHS /usr/local/lib
)
if(NOT MUJOCO_LIB)
    message(FATAL_ERROR "Could not find libmujoco210.so")
endif()
message(STATUS "Found Mujoco library: ${MUJOCO_LIB}")

# Set link flags
target_link_libraries(unitree_mujoco PRIVATE
    ${MUJOCO_LIB}
    GLEW::GLEW
    glfw
    GL
    pthread
)

# Set C++ standard
target_compile_features(unitree_mujoco PRIVATE cxx_std_17)

# Add compile definitions
target_compile_definitions(unitree_mujoco PRIVATE
    MJ_STATIC=1
    GLEW_STATIC=1
)

# Set compile options
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    target_compile_options(unitree_mujoco PRIVATE -Wall -Wextra)
endif()

# Print library information
message(STATUS "Library search paths:")
get_property(SEARCH_PATHS DIRECTORY PROPERTY LINK_DIRECTORIES)
foreach(PATH ${SEARCH_PATHS})
    message(STATUS "  ${PATH}")
endforeach()