# Use an official Ubuntu image as a base
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update package repository and install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends software-properties-common && \
    add-apt-repository ppa:beineri/opt-qt-6.5.0 && \
    apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    qt6base-dev \
    qt6tools-dev-tools \
    libgtk-3-dev \
    libglu1-mesa-dev \
    gcc \
    g++ \
    libudev-dev \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libswresample-dev \
    libswscale-dev \
    libevdev-dev \
    libsdl2-dev \
    bluez \
    llvm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone the Dolphin emulator from the official Git repository and initialize submodules
RUN git clone --recurse-submodules https://github.com/dolphin-emu/dolphin.git /dolphin

# Build Dolphin in release mode and install it
RUN cd /dolphin && \
    mkdir build && \
    cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc) && \
    make install

# Install noVNC and websockify
RUN git clone https://github.com/novnc/noVNC.git /noVNC && \
    git clone https://github.com/novnc/websockify.git /websockify && \
    cd /noVNC && \
    npm install && \
    cd /websockify && \
    apt-get install -y python3-websockify && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Expose ports for noVNC and the websockify server
EXPOSE 6080 5900

# Command to start the virtual frame buffer, websockify, and noVNC
CMD ["bash", "-c", "\
    Xvfb :0 -screen 0 1280x720x24 & \
    DISPLAY=:0 dolphin-emu --start --headless & \
    /websockify/run 5900 localhost:5900 --web /noVNC --cert=/etc/ssl/certs/ssl-cert-snakeoil.pem & \
    /noVNC/utils/launch.sh --vnc localhost:5900 --listen 6080"]
