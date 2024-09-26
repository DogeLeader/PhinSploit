# Use an official Debian image as a base
FROM debian:bullseye-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    wget \
    git \
    curl \
    python3 \
    python3-pip \
    xvfb \
    libgl1-mesa-glx \
    libasound2 \
    libxi6 \
    libxrender1 \
    libxrandr2 \
    sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install the latest versions of gcc and clang
RUN apt-get update && apt-get install -y \
    build-essential \
    clang \
    lld \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js from NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs \
    && npm install -g npm@latest \
    && npm install -g noVNC websockify

# Clone the Dolphin emulator from the official Git repository
RUN git clone https://github.com/dolphin-emu/dolphin.git /dolphin

# Set up Dolphin required dependencies
RUN cd /dolphin && \
    apt-get update && \
    apt-get install -y \
    cmake \
    qtbase5-dev \
    qt5-qmake \
    qtbase5-dev-tools \
    libglu1-mesa-dev \
    libgtk-3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Build Dolphin in release mode and install it
RUN cd /dolphin && \
    mkdir build && \
    cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc) && \
    make install

# Expose ports for noVNC and the websockify server
EXPOSE 6080 5900

# Script to start the virtual frame buffer, websockify, and noVNC
CMD ["bash", "-c", "\
    Xvfb :0 -screen 0 1280x720x24 & \
    DISPLAY=:0 dolphin-emu --start --headless & \
    noVNC/utils/launch.sh --vnc localhost:5900 --listen 6080"]
