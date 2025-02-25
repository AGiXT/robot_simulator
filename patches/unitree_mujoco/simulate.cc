#include "simulate.h"
#include "mujoco/mujoco.h"
#include "mujoco/mjr.h"
#include "mujoco/mjui.h"
#include <cstdio>
#include <cstring>

namespace mujoco {

Simulate::Simulate(mjModel* m, mjData* d) : m_(m), d_(d) {
    // Initialize visualization structures
    mjv_defaultCamera(&cam);
    mjv_defaultPerturb(&pert);
    mjv_defaultOption(&opt);
    mjv_makeScene(m_, &scn, 2000);  // Simplified scene creation

    // Initialize state variables
    paused = false;
    running = true;
    showhelp = false;
    showoption = false;
    showfullscreen = false;
    showsensor = false;

    // Set camera defaults
    cam.lookat[0] = 0;
    cam.lookat[1] = 0;
    cam.lookat[2] = 0;
    cam.distance = 2;
    cam.azimuth = 90;
    cam.elevation = -20;

    // Initialize visualization options
    opt.flags[mjVIS_JOINT] = true;
    opt.flags[mjVIS_ACTUATOR] = true;
    opt.flags[mjVIS_COM] = true;
    opt.flags[mjVIS_CONTACT] = true;
}

void Simulate::UpdateScene() {
    // Update scene with current state
    mjv_updateScene(m_, d_, &opt, NULL, &cam, mjCAT_ALL, &scn);
}

void Simulate::IntegrateState() {
    // Only step if not paused
    if (!paused) {
        // Use standard integrator
        mj_step(m_, d_);
    }
}

Simulate::~Simulate() {
    // Free visualization storage
    mjv_freeScene(&scn);
}

} // namespace mujoco