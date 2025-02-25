#include "mujoco/mujoco.h"
#include "mujoco/mjr.h"
#include "mujoco/mjui.h"
#include "simulate.h"
#include <GLFW/glfw3.h>
#include <cstdio>
#include <string>

// Error callback
static void error_callback(int error, const char* desc) {
    printf("GLFW Error %d: %s\n", error, desc);
}

int main(int argc, char** argv) {
    // Initialize GLFW
    if (!glfwInit()) {
        printf("Could not initialize GLFW\n");
        return 1;
    }
    glfwSetErrorCallback(error_callback);

    // Check command-line arguments
    if (argc != 2) {
        printf("Usage: %s <model.xml>\n", argv[0]);
        return 1;
    }

    // Load and compile model
    char error[1000] = {'\0'};
    mjModel* model = mj_loadXML(argv[1], 0, error, 1000);
    if (!model) {
        printf("Load model error: %s\n", error);
        return 1;
    }

    // Make data
    mjData* data = mj_makeData(model);
    if (!data) {
        printf("Could not allocate mjData\n");
        mj_deleteModel(model);
        return 1;
    }

    // Create window
    GLFWwindow* window = glfwCreateWindow(1200, 900, "Unitree Mujoco", NULL, NULL);
    if (!window) {
        printf("Could not create window\n");
        mj_deleteData(data);
        mj_deleteModel(model);
        return 1;
    }

    // Initialize simulation
    mujoco::Simulate sim(model, data);

    // Make context current
    glfwMakeContextCurrent(window);

    // Initialize simulation visualization
    mjv_defaultCamera(&sim.cam);
    mjv_defaultOption(&sim.opt);
    mjv_defaultPerturb(&sim.pert);
    mjv_makeScene(model, &sim.scn, 2000);

    // Main loop
    while (!glfwWindowShouldClose(window) && sim.running) {
        // Update simulation
        if (!sim.paused) {
            mj_step(model, data);
        }

        // Update visualization
        mjv_updateScene(model, data, &sim.opt, NULL, &sim.cam, mjCAT_ALL, &sim.scn);

        // Process events
        glfwPollEvents();

        // Swap buffers
        glfwSwapBuffers(window);
    }

    // Free visualization storage
    mjv_freeScene(&sim.scn);

    // Close GLFW
    glfwDestroyWindow(window);
    glfwTerminate();

    // Free Mujoco data
    mj_deleteData(data);
    mj_deleteModel(model);

    return 0;
}