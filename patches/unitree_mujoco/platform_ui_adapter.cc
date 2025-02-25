#include <cstring>

// Include headers in the correct order
#include "mjmodel.h"  // Must come first as it defines mjtNum
#include "mjdata.h"
#include "mjrender.h"
#include "mjui.h"
#include "mjvisualize.h"
#include "mujoco.h"

namespace mujoco {

class PlatformUIAdapter {
public:
    PlatformUIAdapter() {
        // Initialize UI state
        memset(&state_, 0, sizeof(state_));
        
        // Initialize rectangles
        for (int i = 0; i < mjMAXUIRECT; i++) {
            state_.rect[i].width = 0;
            state_.rect[i].height = 0;
        }
    }

    void HandleMouseButton(int button, int action, double x, double y) {
        // Convert to UI coordinates
        int wh = state_.rect[0].height;
        state_.type = action ? mjEVENT_PRESS : mjEVENT_RELEASE;
        state_.button = button;
        state_.mouserect = 0;       // Updated: removed buttontime/buttonstate
        state_.dx = 0;
        state_.dy = 0;
        state_.x = x;
        state_.y = wh - y;
    }

    void HandleMouseMove(double x, double y) {
        // Get window height
        int wh = state_.rect[0].height;

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
        state_.rect[0].width = width;
        state_.rect[0].height = height;
    }

    mjuiState* GetUIState() { return &state_; }

private:
    mjuiState state_;
};

} // namespace mujoco