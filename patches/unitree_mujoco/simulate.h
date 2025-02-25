// Copyright 2021 DeepMind Technologies Limited
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0

#pragma once

// Header order matters - mjr.h must come before mjui.h
#include "mujoco/mjr.h"
#include "mujoco/mjui.h"
#include "mujoco/mujoco.h"

// Forward declarations
struct GLFWwindow;

// Mujoco 2.1.0 replacements for removed functionality
#define mjMAXUISECT 10
#define mjEVENT_NONE 0
#define mjEVENT_RESIZE 1

// Constants renamed in 2.1.0
#define mjPRESERVE 0
#define mjSTATE_INTEGRATION 1

namespace mujoco {

class Simulate {
public:
    // Constructor/destructor
    explicit Simulate(mjModel* m, mjData* d);
    ~Simulate();

    // Visualization state
    mjvScene scn;
    mjvCamera cam;
    mjvOption opt;
    mjvPerturb pert;
    mjvFigure figconstraint;
    mjvFigure figcost;
    mjvFigure figtimer;
    mjvFigure figsize;
    mjvFigure figsensor;

    // Model and data
    mjModel* m_;
    mjData* d_;

    // State control
    bool paused;
    bool running;
    bool showhelp;
    bool showoption;
    bool showfullscreen;
    bool showsensor;

    // Update scene and state
    void UpdateScene();
    void IntegrateState();
};

} // namespace mujoco