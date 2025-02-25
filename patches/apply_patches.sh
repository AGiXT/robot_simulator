#!/bin/bash
set -ex

PATCH_DIR=/patches/unitree_mujoco
MUJOCO_DIR=/unitree_mujoco

# Ensure patch directory exists
if [ ! -d "$PATCH_DIR" ]; then
    echo "Patch directory not found: $PATCH_DIR"
    exit 1
fi

echo "Checking Mujoco installation..."
if [ ! -d "/usr/local/include/mujoco" ]; then
    echo "Error: Mujoco headers not found in /usr/local/include/mujoco"
    exit 1
fi

echo "Setting up Mujoco libraries..."
# Check for versioned library
if [ ! -f "/usr/local/lib/libmujoco210.so" ]; then
    echo "Looking for Mujoco library in original location..."
    if [ -f "/opt/mujoco/mujoco/bin/libmujoco210.so" ]; then
        echo "Found libmujoco210.so in /opt/mujoco/mujoco/bin"
        cp -v /opt/mujoco/mujoco/bin/libmujoco210.so /usr/local/lib/
        cp -v /opt/mujoco/mujoco/bin/lib*.so* /usr/local/lib/
    else
        echo "Error: Could not find libmujoco210.so"
        echo "Contents of /opt/mujoco/mujoco/bin:"
        ls -la /opt/mujoco/mujoco/bin
        exit 1
    fi
fi

# Create symlink if it doesn't exist
if [ ! -L "/usr/local/lib/libmujoco.so" ]; then
    echo "Creating libmujoco.so symlink..."
    ln -sv /usr/local/lib/libmujoco210.so /usr/local/lib/libmujoco.so
fi

# Update library cache
ldconfig

echo "Creating directory structure..."
mkdir -p "$MUJOCO_DIR/src/mujoco"

echo "Copying source files..."
cp -v "$PATCH_DIR/simulate.h" "$MUJOCO_DIR/src/mujoco/"
cp -v "$PATCH_DIR/simulate.cc" "$MUJOCO_DIR/src/mujoco/"
cp -v "$PATCH_DIR/platform_ui_adapter.cc" "$MUJOCO_DIR/src/mujoco/"
cp -v "$PATCH_DIR/main.cc" "$MUJOCO_DIR/src/mujoco/"
cp -v "$PATCH_DIR/CMakeLists.txt" "$MUJOCO_DIR/"

echo "Verifying setup..."
ls -la "$MUJOCO_DIR/src/mujoco"
ls -la /usr/local/lib/libmujoco*
ldconfig -p | grep mujoco

echo "Patches applied successfully"