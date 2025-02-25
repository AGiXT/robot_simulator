cmake_minimum_required(VERSION 3.10)
project(unitree_mujoco)

# Set verbosity
set(CMAKE_VERBOSE_MAKEFILE ON)

# Find required libraries
find_package(GLEW REQUIRED)
find_package(glfw3 REQUIRED)

# Set directory variables
set(MUJOCO_DIR "/opt/mujoco/mujoco210")
set(MUJOCO_INCLUDE_DIRS 
    "${MUJOCO_DIR}/include"
    "/usr/local/include"
    "/usr/local/include/mujoco"
)
set(MUJOCO_LIBRARY_DIR "${MUJOCO_DIR}/bin")

# Debug print
message(STATUS "Build configuration:")
message(STATUS "  MUJOCO_DIR: ${MUJOCO_DIR}")
message(STATUS "  Include directories:")
foreach(dir ${MUJOCO_INCLUDE_DIRS})
    message(STATUS "    ${dir}")
endforeach()
message(STATUS "  Library directory: ${MUJOCO_LIBRARY_DIR}")

# Set include directories
include_directories(
    ${CMAKE_SOURCE_DIR}/src
    ${MUJOCO_INCLUDE_DIRS}
)

# Set library directories
link_directories(
    ${MUJOCO_LIBRARY_DIR}
    /usr/local/lib
)

# Set source files
set(SOURCES
    src/mujoco/main.cc
    src/mujoco/simulate.cc
    src/mujoco/platform_ui_adapter.cc
)

# Create executable
add_executable(unitree_mujoco ${SOURCES})

# Find MuJoCo library
find_library(MUJOCO_LIB 
    NAMES mujoco210 libmujoco210
    PATHS ${MUJOCO_LIBRARY_DIR} /usr/local/lib
    NO_DEFAULT_PATH
)

if(NOT MUJOCO_LIB)
    message(FATAL_ERROR "Could not find MuJoCo library in ${MUJOCO_LIBRARY_DIR} or /usr/local/lib")
endif()
message(STATUS "Found MuJoCo library: ${MUJOCO_LIB}")

# Configure RPATH
set_target_properties(unitree_mujoco PROPERTIES
    INSTALL_RPATH "${MUJOCO_LIBRARY_DIR}:/usr/local/lib"
    BUILD_WITH_INSTALL_RPATH TRUE
    SKIP_BUILD_RPATH FALSE
    BUILD_WITH_INSTALL_NAME_DIR TRUE
)

# Set link flags
target_link_libraries(unitree_mujoco
    PRIVATE
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

# Verify header existence
foreach(header mjmodel.h mjdata.h mujoco.h mjrender.h mjui.h mjvisualize.h)
    set(HEADER_FOUND FALSE)
    foreach(dir ${MUJOCO_INCLUDE_DIRS})
        if(EXISTS "${dir}/${header}")
            message(STATUS "Found ${header} in ${dir}")
            set(HEADER_FOUND TRUE)
            break()
        endif()
    endforeach()
    if(NOT HEADER_FOUND)
        message(WARNING "Could not find ${header} in any include directory")
    endif()
endforeach()

# Final status message
message(STATUS "Configuration complete. Use make VERBOSE=1 for detailed build output")