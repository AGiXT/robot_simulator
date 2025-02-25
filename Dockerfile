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
    mv /opt/mujoco/mujoco210 /opt/mujoco/mujoco && \
    echo "Initial Mujoco contents:" && \
    tree /opt/mujoco/mujoco

# Set up Mujoco environment and copy files
RUN set -ex && \
    # Copy include files
    mkdir -p /usr/local/include/mujoco && \
    cp -rv /opt/mujoco/mujoco/include/* /usr/local/include/mujoco/ && \
    # Copy libraries
    mkdir -p /usr/local/lib && \
    cp -v /opt/mujoco/mujoco/bin/libmujoco210.so /usr/local/lib/ && \
    cp -v /opt/mujoco/mujoco/bin/libglew.so /usr/local/lib/ && \
    cp -v /opt/mujoco/mujoco/bin/libglewegl.so /usr/local/lib/ && \
    cp -v /opt/mujoco/mujoco/bin/libglewosmesa.so /usr/local/lib/ && \
    cp -v /opt/mujoco/mujoco/bin/libglfw.so.3 /usr/local/lib/ && \
    # Create symlinks
    ln -sf /usr/local/lib/libmujoco210.so /usr/local/lib/libmujoco.so && \
    ldconfig && \
    echo "Installed libraries:" && \
    ls -la /usr/local/lib/lib*

# Set environment variables
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
ENV MUJOCO_PATH=/opt/mujoco/mujoco

# Create Mujoco CMake config with correct library name
RUN mkdir -p /usr/local/lib/cmake/mujoco && \
    echo 'set(MUJOCO_INCLUDE_DIRS "/usr/local/include")' > /usr/local/lib/cmake/mujoco/mujocoConfig.cmake && \
    echo 'set(MUJOCO_LIBRARIES "/usr/local/lib/libmujoco210.so")' >> /usr/local/lib/cmake/mujoco/mujocoConfig.cmake && \
    echo 'include_directories(${MUJOCO_INCLUDE_DIRS})' >> /usr/local/lib/cmake/mujoco/mujocoConfig.cmake

# Copy patches and scripts
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
    cmake .. -DCMAKE_PREFIX_PATH=/usr/local/lib/cmake/mujoco -DCMAKE_VERBOSE_MAKEFILE=ON && \
    make VERBOSE=1

WORKDIR /unitree_mujoco/build
ENTRYPOINT ["./unitree_mujoco"]