# Use the latest Ubuntu base image
FROM ubuntu:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Add Xpra official repository to avoid broken package
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:xpra-org/xpra && \
    apt-get update

# Install dependencies and handle dpkg errors
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    libavcodec-dev \
    libavformat-dev \
    libboost-filesystem-dev \
    libboost-system-dev \
    libcurl4-openssl-dev \
    libglew-dev \
    libgtk-3-dev \
    libjpeg-dev \
    libopenal-dev \
    libpng-dev \
    libsdl2-dev \
    libsqlite3-dev \
    libudev-dev \
    libxi-dev \
    libxrandr-dev \
    libxss-dev \
    libxext-dev \
    libxinerama-dev \
    xpra \
    xauth \
    dbus-x11 \
    xvfb \
    --no-install-recommends || true && \
    apt-get -f install && \
    dpkg --configure -a && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Clone Dolphin emulator repository
RUN git clone --depth 1 https://github.com/dolphin-emu/dolphin.git /dolphin

# Build Dolphin
WORKDIR /dolphin
RUN mkdir build && cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install

# Expose the port that Render expects
EXPOSE 10000

# Start Dolphin and Xpra with the web client
CMD ["bash", "-c", "xpra start :100 --bind-tcp=0.0.0.0:10000 --html=on --daemon=no --start-child='/dolphin/build/Binaries/dolphin-emu'"]
