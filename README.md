# Unitree Streams

Docker container for running Unitree Mujoco simulator with compatibility fixes for Mujoco 2.1.0.

## Overview

This repository contains a Docker setup for running the Unitree Mujoco simulator. It includes patches to fix compatibility issues between the original Unitree Mujoco code (designed for Mujoco 2.0) and Mujoco 2.1.0.

## Prerequisites

- Docker
- Docker Compose
- X11 server (for GUI support)

## Usage

1. Clone the repository:
```bash
git clone https://github.com/yourusername/unitree_streams.git
cd unitree_streams
```

2. Build and run the container:
```bash
docker compose up --build
```

If you have an NVIDIA GPU and want to use it, uncomment the GPU-related lines in `docker-compose.yml`.

## Compatibility Fixes

The patches in the `patches` directory address the following Mujoco 2.1.0 compatibility issues:

- Fixed missing type definitions by ensuring proper header inclusion
- Updated deprecated type names (e.g., mjvSceneState → mjvScene)
- Added missing constants that were removed in 2.1.0
- Updated UI state member access to match the new API

The patches are automatically applied during the Docker build process.

## Development

To modify the patches:

1. Edit files in the `patches/unitree_mujoco/` directory
2. Rebuild the container:
```bash
docker compose up --build
```

## Troubleshooting

If you encounter X11 connection issues:
```bash
xhost +local:docker
```

## License

This project is licensed under the same terms as the original Unitree Mujoco repository.