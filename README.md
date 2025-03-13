# Unitree Mujoco Integration

This project integrates Unitree robots with MuJoCo 2.1.0 physics simulator in a Docker environment.

## Prerequisites

- Docker
- Docker Compose
- X11 for visualization
- Git
- At least 4GB of free disk space

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/yourusername/unitree_streams.git
cd unitree_streams
```

2. Build the Docker container:
```bash
docker-compose build
```

3. Run the simulation:
```bash
xhost +local:docker  # Allow X11 connections from Docker
docker-compose up
```

## Troubleshooting

### Library Issues

If you encounter library-related issues:

1. Run the diagnostic script:
```bash
# Start container in debug mode
docker-compose run --rm unitree-mujoco /bin/bash

# Inside container, run diagnostics
/patches/check_libs.sh
```

2. Common issues and solutions:

   a. Missing libraries:
   ```bash
   # Check library paths
   ldconfig -p | grep mujoco
   ls -l /usr/local/lib/libmujoco*
   ```

   b. Header file issues:
   ```bash
   # Verify header installation
   ls -l /usr/local/include/mj*.h
   ls -l /usr/local/include/mujoco/
   ```

   c. Library load errors:
   ```bash
   # Check library dependencies
   ldd /usr/local/lib/libmujoco210.so
   ```

### Graphics Issues

1. For NVIDIA GPU support, uncomment the relevant section in docker-compose.yml:
```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: 1
          capabilities: [graphics,compute,utility]
```

2. For Mesa/software rendering issues:
```bash
# Inside container
export LIBGL_ALWAYS_SOFTWARE=1
```

## Development

### Building from Source

1. Debug build:
```bash
docker-compose build --progress=plain

# For verbose output
docker-compose build --progress=plain --no-cache
```

2. Modifying source files:
   - Source files are in `patches/unitree_mujoco/`
   - Build system files in `patches/`
   - Changes require container rebuild

### Directory Structure

```
.
├── docker-compose.yml   # Container configuration
├── Dockerfile          # Build instructions
├── patches/           # Source and build files
│   ├── apply_patches.sh
│   ├── check_libs.sh
│   └── unitree_mujoco/
│       ├── CMakeLists.txt
│       ├── main.cc
│       ├── platform_ui_adapter.cc
│       ├── simulate.cc
│       └── simulate.h
└── README.md
```

## Notes

- MuJoCo 2.1.0 specific changes:
  - Uses direct header includes (no mujoco/ prefix)
  - Links against libmujoco210.so
  - Modified include order for proper compilation
