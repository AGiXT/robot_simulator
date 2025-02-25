// Copyright 2021 DeepMind Technologies Limited
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0

#pragma once

// Include only the top-level MuJoCo header
extern "C" {
#include "mujoco.h"
}

// Forward declarations
struct GLFWwindow;

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