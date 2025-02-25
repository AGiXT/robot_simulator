#!/bin/bash
set -ex

PATCH_DIR=/patches/unitree_mujoco
MUJOCO_DIR=/unitree_mujoco
MUJOCO_ROOT=/opt/mujoco/mujoco210

# Function to display error and exit
error_exit() {
    echo "ERROR: $1" >&2
    exit 1
}

# Ensure directories exist
[ -d "$PATCH_DIR" ] || error_exit "Patch directory not found: $PATCH_DIR"
[ -d "$MUJOCO_ROOT" ] || error_exit "MuJoCo directory not found: $MUJOCO_ROOT"

# Create necessary directories
mkdir -p "$MUJOCO_DIR/src/mujoco"
mkdir -p /usr/local/include/mujoco

echo "=== Setting up MuJoCo headers ==="
# Install headers in both locations
if [ ! -f "/usr/local/include/mjmodel.h" ]; then
    echo "Installing MuJoCo headers..."
    # Copy headers to /usr/local/include
    cp -v $MUJOCO_ROOT/include/mj*.h /usr/local/include/
    cp -v $MUJOCO_ROOT/include/mujoco.h /usr/local/include/
    
    # Create symlinks in mujoco subdirectory
    cd /usr/local/include
    for header in mj*.h mujoco.h; do
        if [ -f "$header" ]; then
            ln -sfv "../$header" "mujoco/$header"
        fi
    done
fi

echo "=== Setting up MuJoCo libraries ==="
if [ ! -f "/usr/local/lib/libmujoco210.so" ]; then
    echo "Installing MuJoCo libraries..."
    # Install libraries
    mkdir -p /usr/local/lib
    cp -v $MUJOCO_ROOT/bin/libmujoco210.so /usr/local/lib/
    cp -v $MUJOCO_ROOT/bin/libglew.so /usr/local/lib/
    cp -v $MUJOCO_ROOT/bin/libglewegl.so /usr/local/lib/
    
    # Create symlink for libmujoco.so
    ln -sfv libmujoco210.so /usr/local/lib/libmujoco.so
    
    # Update library cache
    ldconfig
fi

echo "=== Copying source files ==="
# Copy our source files
cp -v "$PATCH_DIR/main.cc" "$MUJOCO_DIR/src/mujoco/"
cp -v "$PATCH_DIR/simulate.h" "$MUJOCO_DIR/src/mujoco/"
cp -v "$PATCH_DIR/simulate.cc" "$MUJOCO_DIR/src/mujoco/"
cp -v "$PATCH_DIR/platform_ui_adapter.cc" "$MUJOCO_DIR/src/mujoco/"
cp -v "$PATCH_DIR/CMakeLists.txt" "$MUJOCO_DIR/"

echo "=== Verifying installation ==="
echo "Headers:"
ls -l /usr/local/include/mj*.h
ls -l /usr/local/include/mujoco/

echo "Libraries:"
ls -l /usr/local/lib/libmujoco*
ls -l /usr/local/lib/libglew*

echo "=== Checking library dependencies ==="
ldd /usr/local/lib/libmujoco210.so || true

echo "=== Verifying source files ==="
ls -l "$MUJOCO_DIR/src/mujoco/"

echo "=== Checking library cache ==="
ldconfig -p | grep -E "mujoco|glew"

echo "=== Checking environment variables ==="
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
echo "MUJOCO_PATH=$MUJOCO_PATH"

echo "Patches applied successfully"