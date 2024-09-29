FROM ubuntu:latest

# Environment settings
ENV DEBIAN_FRONTEND=noninteractive
ENV QT_INSTALL_DIR=/opt/qt6.5.1

# Install required dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    wget \
    curl \
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
    xauth \
    dbus-x11 \
    xvfb \
    libevdev-dev \
    libcubeb-dev \
    libbluetooth-dev \
    llvm \
    qtbase5-dev \
    qt6-base-dev \
    --no-install-recommends

# Clean up APT when done
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download and install Qt 6.5.1
RUN wget https://download.qt.io/official_releases/qt/6.5/6.5.1/single/qt-everywhere-src-6.5.1.tar.xz && \
    tar -xf qt-everywhere-src-6.5.1.tar.xz && \
    cd qt-everywhere-src-6.5.1 && \
    ./configure -prefix $QT_INSTALL_DIR -opensource -confirm-license -nomake tests -nomake examples && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    rm -rf qt-everywhere-src-6.5.1 qt-everywhere-src-6.5.1.tar.xz

# Clone Dolphin emulator repository
RUN git clone --depth 1 https://github.com/dolphin-emu/dolphin.git /dolphin

# Build Dolphin emulator
WORKDIR /dolphin
RUN mkdir build && cd build && \
    cmake .. && \
    make -j$(nproc) && \
    make install

# Expose the desired port
EXPOSE 10000

# Start command with xpra
CMD ["bash", "-c", "xpra start :100 --bind-tcp=0.0.0.0:10000 --html=on --daemon=no --start-child='/dolphin/build/Binaries/dolphin-emu
