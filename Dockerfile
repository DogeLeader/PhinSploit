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
    pkg-config \
    python3 \
    python3-pip \
    python3-setuptools \
    libgtkmm-3.0-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone the Dolphin repository and build it
WORKDIR /dolphin
RUN git clone --depth=1 https://github.com/dolphin-emu/dolphin.git . \
    && mkdir build \
    && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release \
    && make -j$(nproc)

# Create the final lightweight image
FROM debian:bookworm-slim

# Install required packages for running noVNC and websockify
RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb \
    python3 \
    python3-pip \
    && pip3 install websockify \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy the built Dolphin emulator from the builder stage
COPY --from=builder /dolphin/build/bin/Dolphin /usr/local/bin/Dolphin

# Clone the noVNC repository
RUN git clone --depth=1 https://github.com/novnc/noVNC.git /opt/noVNC

# Set up the working directory and entry point
WORKDIR /opt/noVNC
CMD ["sh", "-c", "xvfb-run --server-args='-screen 0 1024x768x24' /usr/local/bin/Dolphin --no-splash-screen --config-path=/dev/null & websockify --web /opt/noVNC 8080 localhost:5900"]
