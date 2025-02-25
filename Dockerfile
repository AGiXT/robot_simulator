FROM ubuntu:22.04

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    g++ \
    wget \
    libglew-dev \
    libpthread-stubs0-dev \
    libx11-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libosmesa6-dev \
    libeigen3-dev \
    libglfw3-dev \
    libxrandr-dev \
    libxinerama-dev \
    libxcursor-dev \
    libxi-dev \
    libyaml-cpp-dev \
    tree \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Install Cyclonedds
RUN git clone https://github.com/eclipse-cyclonedds/cyclonedds /cyclonedds
WORKDIR /cyclonedds
RUN mkdir build && cd build && \
    cmake .. && \
    cmake --build . && \
    cmake --install .

# Download and install Mujoco
WORKDIR /
RUN set -ex && \
    wget -O mujoco.tar.gz https://mujoco.org/download/mujoco210-linux-x86_64.tar.gz && \
    mkdir -p /opt/mujoco && \
    tar -xvf mujoco.tar.gz -C /opt/mujoco && \
    rm mujoco.tar.gz && \
    echo "MuJoCo installation:" && \
    ls -la /opt/mujoco/mujoco210

# Set up MuJoCo environment
ENV LD_LIBRARY_PATH=/usr/local/lib:/opt/mujoco/mujoco210/bin:$LD_LIBRARY_PATH
ENV MUJOCO_PATH=/opt/mujoco/mujoco210

# Install MuJoCo headers and libraries
RUN set -ex && \
    # Create include directories
    mkdir -p /usr/local/include/mujoco && \
    # Install headers in both locations
    cp -v /opt/mujoco/mujoco210/include/* /usr/local/include/ && \
    cd /usr/local/include && \
    for f in mj*.h mujoco.h; do \
        if [ -f "$f" ]; then \
            ln -sfv "../$f" "mujoco/$f"; \
        fi \
    done && \
    # Install libraries
    mkdir -p /usr/local/lib && \
    cp -v /opt/mujoco/mujoco210/bin/libmujoco210.so /usr/local/lib/ && \
    cp -v /opt/mujoco/mujoco210/bin/libglew.so /usr/local/lib/ && \
    cp -v /opt/mujoco/mujoco210/bin/libglewegl.so /usr/local/lib/ && \
    # Create symlinks
    ln -sfv /usr/local/lib/libmujoco210.so /usr/local/lib/libmujoco.so && \
    # Update library cache
    ldconfig && \
    # Show what we installed
    echo "Installed headers:" && \
    ls -la /usr/local/include/mj*.h && \
    ls -la /usr/local/include/mujoco/ && \
    echo "Installed libraries:" && \
    ls -la /usr/local/lib/lib*

# Copy patches
COPY patches /patches
RUN chmod +x /patches/apply_patches.sh /patches/check_libs.sh

# Clone and prepare Unitree Mujoco
WORKDIR /
RUN git clone https://github.com/unitreerobotics/unitree_mujoco && \
    cd /unitree_mujoco && \
    mkdir -p src/mujoco && \
    /patches/apply_patches.sh && \
    echo "=== Verifying final setup ===" && \
    /patches/check_libs.sh

# Build with verbose output
WORKDIR /unitree_mujoco
RUN mkdir -p build && cd build && \
    cmake .. -DCMAKE_VERBOSE_MAKEFILE=ON && \
    make VERBOSE=1

# Set working directory and entry point
WORKDIR /unitree_mujoco/build
ENTRYPOINT ["./unitree_mujoco"]