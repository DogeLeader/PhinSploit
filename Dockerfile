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

# Adding the Debian Testing repository
RUN echo "deb http://deb.debian.org/debian bookworm main" >> /etc/apt/sources.list.d/bookworm.list && \
    apt-get update && \
    apt-get install -y \
    build-essential \
    gcc-11 \
    g++-11 \
    clang \
    lld \
    && rm -rf /etc/apt/sources.list.d/bookworm.list && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set GCC and G++ to point to version 11
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 60 --slave /usr/bin/g++ g++ /usr/bin/g++-11

# Install Node.js from NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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

# Script to start the virtual frame buffer, websockify, and noVNC
CMD ["bash", "-c", "\
    Xvfb :0 -screen 0 1280x720x24 & \
    DISPLAY=:0 dolphin-emu --start --headless & \
    /websockify/run 5900 localhost:5900 --web /noVNC --cert=/etc/ssl/certs/ssl-cert-snakeoil.pem & \
    /noVNC/utils/launch.sh --vnc localhost:5900 --listen 6080"]
