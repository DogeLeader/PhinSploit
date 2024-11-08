# Use Debian Bookworm Slim as the base image
FROM debian:bookworm-slim AS builder

# Install necessary dependencies for building Dolphin
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    cmake \
    libgtk-3-dev \
    libglew-dev \
    libglib2.0-dev \
    libao-dev \
    libboost-dev \
    libsdl2-dev \
    libvulkan-dev \
    libxi-dev \
    libxrandr-dev \
    libxinerama-dev \
    libx11-dev \
    libasound2-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libudev-dev \
    libevdev-dev \
    liblzo2-dev \
    libcubeb-dev \
    libbluetooth-dev \
    llvm \
    qt6-base-dev \
    qt6-svg-dev \                 
    pkg-config \
    python3 \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Clone the Dolphin repository and build it
WORKDIR /dolphin
RUN git clone --depth=1 --recurse-submodules https://github.com/dolphin-emu/dolphin.git . \
    && mkdir build \
    && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release \
    && make -j$(nproc)

# Create the final lightweight image
FROM debian:bookworm-slim

# Install packages necessary for running noVNC and websockify
RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb \
    python3 \
    python3-venv \
    git \
    libevdev-dev \
    liblzo2-dev \  
    libcubeb-dev \ 
    libminizip-dev \  
    && rm -rf /var/lib/apt/lists/*

# Create a virtual environment for Python
RUN python3 -m venv /opt/venv

# Install websockify in the virtual environment
RUN /opt/venv/bin/pip install websockify

# Copy built Dolphin emulator from the builder stage
COPY --from=builder /dolphin/build/bin/Dolphin /usr/local/bin/Dolphin

# Clone noVNC and install dependencies for better performance
RUN git clone --depth=1 https://github.com/novnc/noVNC.git /opt/noVNC

# Set environment variables for noVNC
ENV NOVNC_PNG_COMPRESSION=1

# Set up the working directory and entry point
WORKDIR /opt/noVNC
CMD ["sh", "-c", "xvfb-run --server-args='-screen 0 1024x768x24' /usr/local/bin/Dolphin --no-splash-screen --config-path=/dev/null & /opt/venv/bin/websockify --web /opt/noVNC --cert=/path/to/cert.pem --key=/path/to/key.pem -D 8080 localhost:5900"]
