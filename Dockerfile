# Use the latest Ubuntu base image
FROM ubuntu:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Ensure the system is up-to-date and install prerequisite tools
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    wget \
    curl

# Add Xpra official repository to avoid broken packages and outdated versions
RUN add-apt-repository ppa:xpra-org/xpra -y

# Update and install all dependencies
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
    --no-install-recommends && \
    apt-get -f install && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Fix any dpkg errors if present
RUN dpkg --configure -a || true

# Clone the Dolphin emulator repository
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
