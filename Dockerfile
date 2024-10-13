# Use Ubuntu as base image
FROM ubuntu:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies for Dolphin and noVNC/websockify
RUN apt-get update && \
    apt-get install -y \
    git \
    build-essential \
    cmake \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libsdl2-dev \
    libsfml-dev \
    libx11-dev \
    libxext-dev \
    libxtst-dev \
    libxrandr-dev \
    libxrender-dev \
    libxi-dev \
    libxxf86vm-dev \
    libxinerama-dev \
    libglu1-mesa-dev \
    libsdl2-image-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libudev-dev \
    libasound2-dev \
    libpulse-dev \
    libao-dev \
    libopenal-dev \
    libxrandr-dev \
    libegl1-mesa-dev \
    libgles2-mesa-dev \
    libglib2.0-dev \
    libfontconfig1-dev \
    libavfilter-dev \
    libswscale-dev \
    libmbedtls-dev \
    libbz2-dev \
    libpng-dev \
    zlib1g-dev \
    libminiupnpc-dev \
    libhidapi-dev \
    libusb-1.0-0-dev \
    libudev-dev \
    libcairo2-dev \
    libvulkan-dev \
    vulkan-utils \
    libgtk-3-dev \
    libjpeg-dev \
    libpulse-dev \
    libsamplerate0-dev \
    python3 \
    python3-pip \
    wget \
    novnc \
    websockify \
    xfce4 \
    xfce4-terminal \
    && rm -rf /var/lib/apt/lists/*

# Install noVNC and websockify
RUN pip3 install --no-cache-dir websockify

# Clone the Dolphin repository and build it
RUN git clone https://github.com/dolphin-emu/dolphin.git && \
    cd dolphin && \
    mkdir Build && \
    cd Build && \
    cmake .. && \
    make -j$(nproc) && \
    cd ../..

# Set up noVNC
RUN mkdir -p /opt/novnc && \
    cp -r /usr/share/novnc/* /opt/novnc/ && \
    wget -O /opt/novnc/vnc.html https://github.com/novnc/noVNC/releases/download/v1.3.0/vnc.html

# Create a startup script
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'websockify --web=/opt/novnc --cert=/cert.pem --key=/key.pem 6080 localhost:5900 &' >> /start.sh && \
    echo 'xfce4-session &' >> /start.sh && \
    echo 'dolphin-emu-nogui &' >> /start.sh && \
    chmod +x /start.sh

# Expose port for noVNC
EXPOSE 6080

# Run the startup script
CMD ["/start.sh"]
