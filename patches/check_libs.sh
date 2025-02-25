#!/bin/bash
set -x

echo "=== MuJoCo Installation Verification Script ==="

echo -e "\n=== System Information ==="
uname -a
lsb_release -a || true

echo -e "\n=== Directory Structure ==="
echo "MuJoCo root directory:"
ls -la /opt/mujoco/mujoco210
echo -e "\nMuJoCo bin directory:"
ls -la /opt/mujoco/mujoco210/bin
echo -e "\nMuJoCo include directory:"
ls -la /opt/mujoco/mujoco210/include

echo -e "\n=== Header Files ==="
echo "Direct headers in /usr/local/include:"
ls -la /usr/local/include/mj*.h || true
echo -e "\nHeaders in mujoco subdirectory:"
ls -la /usr/local/include/mujoco/ || true

# Check specific required headers
REQUIRED_HEADERS="mjmodel.h mjdata.h mujoco.h mjrender.h mjui.h mjvisualize.h"
echo -e "\nChecking required headers:"
for header in $REQUIRED_HEADERS; do
    echo -n "$header: "
    if [ -f "/usr/local/include/$header" ]; then
        echo "Found in /usr/local/include"
    elif [ -f "/usr/local/include/mujoco/$header" ]; then
        echo "Found in /usr/local/include/mujoco"
    else
        echo "NOT FOUND"
    fi
done

echo -e "\n=== Library Files ==="
echo "Libraries in /usr/local/lib:"
ls -la /usr/local/lib/libmujoco* /usr/local/lib/libglew* 2>/dev/null || true

echo -e "\nChecking symlinks:"
if [ -L "/usr/local/lib/libmujoco.so" ]; then
    readlink -f /usr/local/lib/libmujoco.so
else
    echo "libmujoco.so symlink missing"
fi

echo -e "\n=== Library Dependencies ==="
echo "libmujoco210.so dependencies:"
if [ -f "/usr/local/lib/libmujoco210.so" ]; then
    ldd /usr/local/lib/libmujoco210.so
else
    echo "libmujoco210.so not found in /usr/local/lib"
    if [ -f "/opt/mujoco/mujoco210/bin/libmujoco210.so" ]; then
        echo "Found in original location. Dependencies:"
        ldd /opt/mujoco/mujoco210/bin/libmujoco210.so
    fi
fi

echo -e "\n=== Library Cache ==="
ldconfig -p | grep -E "mujoco|glew"

echo -e "\n=== Environment Variables ==="
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
echo "MUJOCO_PATH=$MUJOCO_PATH"

echo -e "\n=== Testing Header Compilation ==="
TEMP_FILE=$(mktemp).c
cat > $TEMP_FILE << 'EOF'
#include <stdio.h>
#include "mjmodel.h"
#include "mujoco.h"

int main() {
    printf("Testing MuJoCo headers...\n");
    printf("MuJoCo version: %s\n", mj_versionString());
    return 0;
}
EOF

echo "Compiling test program..."
gcc -o /tmp/test_mujoco $TEMP_FILE -I/usr/local/include -L/usr/local/lib -lmujoco210 -lGL -lm || echo "Compilation failed"

if [ -f "/tmp/test_mujoco" ]; then
    echo "Running test program..."
    LD_LIBRARY_PATH=/usr/local/lib:/opt/mujoco/mujoco210/bin /tmp/test_mujoco || echo "Execution failed"
else
    echo "Test program compilation failed"
fi

rm -f $TEMP_FILE /tmp/test_mujoco

echo -e "\n=== Version Information ==="
if [ -f "/usr/local/lib/libmujoco210.so" ]; then
    echo "Library version string:"
    strings /usr/local/lib/libmujoco210.so | grep -i "version=" || true
fi

echo "=== Check Complete ==="