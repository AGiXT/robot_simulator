#include "mujoco/mujoco.h"
#include "mujoco/mjr.h"
#include "mujoco/mjui.h"
#include <cstring>

namespace mujoco {

class PlatformUIAdapter {
public:
    PlatformUIAdapter() {
        // Initialize UI state
        memset(&state_, 0, sizeof(state_));
        for (int i = 0; i < mjMAXUIRECT; i++) {
            state_.mrect[i].width = 0;
            state_.mrect[i].height = 0;
        }
    }

    void HandleMouseButton(int button, int action, double x, double y) {
        // Convert to UI coordinates
        int wh = state_.mrect[0].height;
        state_.type = action ? mjEVENT_PRESS : mjEVENT_RELEASE;
        state_.button = button;
        state_.buttonstate[button] = action;
        state_.dx = 0;
        state_.dy = 0;
        state_.x = x;
        state_.y = wh - y;
    }

    void HandleMouseMove(double x, double y) {
        // Get window height
        int wh = state_.mrect[0].height;

        // Set mouse move event
        state_.type = mjEVENT_MOVE;

        // Compute mouse displacement
        state_.dx = x - state_.x;
        state_.dy = (wh - y) - state_.y;

        // Save mouse position
        state_.x = x;
        state_.y = wh - y;
    }

    void HandleScroll(double xoffset, double yoffset) {
        // Set scroll event
        state_.type = mjEVENT_SCROLL;
        state_.sx = xoffset;
        state_.sy = yoffset;
    }

    void HandleResize(int width, int height) {
        // Set resize event
        state_.type = mjEVENT_RESIZE;
        state_.mrect[0].width = width;
        state_.mrect[0].height = height;
    }

    mjuiState* GetUIState() { return &state_; }

private:
    mjuiState state_;
};

} // namespace mujoco