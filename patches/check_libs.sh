#!/bin/bash
set -x

echo "=== Checking Mujoco installation ==="
echo "Directory structure:"
tree /opt/mujoco/mujoco

echo -e "\n=== Library files ==="
echo "Original Mujoco libraries:"
find /opt/mujoco/mujoco -name "*.so*" -type f -exec ls -l {} \;

echo -e "\n=== System libraries ==="
echo "Installed libraries in /usr/local/lib:"
ls -l /usr/local/lib/lib*

echo -e "\n=== Library dependencies ==="
echo "Checking libmujoco210.so:"
if [ -f "/usr/local/lib/libmujoco210.so" ]; then
    ldd /usr/local/lib/libmujoco210.so
else
    echo "libmujoco210.so not found in /usr/local/lib"
fi

echo -e "\n=== Checking symlinks ==="
if [ -L "/usr/local/lib/libmujoco.so" ]; then
    ls -l /usr/local/lib/libmujoco.so
    readlink -f /usr/local/lib/libmujoco.so
else
    echo "libmujoco.so symlink not found"
fi

echo -e "\n=== Library cache ==="
echo "Mujoco libraries in ldconfig cache:"
ldconfig -p | grep mujoco

echo -e "\n=== Environment variables ==="
echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
echo "MUJOCO_PATH=$MUJOCO_PATH"

echo -e "\n=== Include files ==="
echo "Mujoco headers:"
ls -R /usr/local/include/mujoco/

echo -e "\n=== CMake files ==="
echo "Mujoco CMake config:"
if [ -f "/usr/local/lib/cmake/mujoco/mujocoConfig.cmake" ]; then
    cat /usr/local/lib/cmake/mujoco/mujocoConfig.cmake
else
    echo "mujocoConfig.cmake not found"
fi

echo -e "\n=== Verifying library load ==="
echo "Testing if library can be loaded:"
python3 -c "
import ctypes
try:
    lib = ctypes.CDLL('/usr/local/lib/libmujoco210.so')
    print('Successfully loaded libmujoco210.so')
except Exception as e:
    print('Failed to load library:', e)
" 2>&1 || true