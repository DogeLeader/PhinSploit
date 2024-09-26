# Use the latest Ubuntu base image
FROM ubuntu:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV VNC_PORT=5901
ENV WEBSOCKIFY_PORT=8080

# Update the package list and install necessary dependencies
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    pkg-config \
    build-essential \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libswscale-dev \
    libsdl2-dev \
    libxrandr-dev \
    libxi-dev \
    libudev-dev \
    libusb-1.0-0-dev \
    libasound2-dev \
    libpulse-dev \
    libevdev-dev \
    libmbedtls-dev \
    libenet-dev \
    libcurl4-openssl-dev \
    zlib1g-dev \
    qtbase5-dev \
    qtbase5-private-dev \
    libqt5opengl5-dev \
    libqt5x11extras5-dev \
    libminiupnpc-dev \
    libhidapi-dev \
    libudev-dev \
    libsqlite3-dev \
    python3-dev \
    python3-pip \
    ninja-build \
    libssl-dev \
    x11vnc \
    xvfb \
    novnc \
    websockify \
    && apt-get clean

# Clone the Dolphin Emulator Git repository
RUN git clone https://github.com/dolphin-emu/dolphin.git /dolphin

# Set working directory to Dolphin source
WORKDIR /dolphin

# Create a build directory and switch to it
RUN mkdir build && cd build

# Configure the build with CMake
RUN cd build && cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release

# Build Dolphin using Ninja
RUN cd build && ninja

# Expose ports for VNC and Websockify
EXPOSE 8080
EXPOSE 5901

# Create and embed the start.sh script directly in the Dockerfile
RUN echo '#!/bin/bash\n\
# Start X virtual framebuffer in background\n\
Xvfb :1 -screen 0 1280x720x16 &\n\
\n\
# Start x11vnc on display :1 in background\n\
x11vnc -display :1 -usepw -forever -shared -rfbport 5901 &\n\
\n\
# Start Dolphin Emulator in background\n\
/dolphin/build/Binaries/dolphin-emu &\n\
\n\
# Start websockify to bridge VNC to WebSockets\n\
websockify --web /usr/share/novnc 8080 localhost:5901\n' > /opt/dolphin-start.sh \
    && chmod +x /opt/dolphin-start.sh

# Copy the noVNC web files to the container
RUN cp -r /usr/share/novnc/* /opt/novnc

# Set the entrypoint to run the bash script
CMD ["/opt/dolphin-start.sh"]
