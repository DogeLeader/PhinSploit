# Use the official Alpine base image
FROM alpine:latest

# Set environment variables to avoid prompts during package installation
ENV LANG=C.UTF-8

# Install necessary dependencies: Dolphin Emulator, x11vnc, noVNC, and other utilities
RUN apk update && apk add --no-cache \
    dolphin-emulator \
    x11vnc \
    novnc \
    websockify \
    bash \
    xf86-video-fbdev \
    xorg-server \
    xvfb \
    && rm -rf /var/cache/apk/*

# Disable unnecessary GPU drivers or conflicting video drivers
# We'll create an Xorg configuration that forces it to use fbdev (framebuffer driver)
RUN echo -e "Section \"Device\"\n  Identifier  \"Default Device\"\n  Driver      \"fbdev\"\nEndSection" > /etc/X11/xorg.conf.d/00-device.conf

# Create necessary directories for VNC and Dolphin emulator
RUN mkdir -p /root/.vnc /root/.dolphin-emu

# Set up VNC password (you can change the password here)
RUN echo "root" | vncpasswd -f > /root/.vnc/passwd && chmod 600 /root/.vnc/passwd

# Expose the default VNC port (5900) and the noVNC web port (6080)
EXPOSE 5900 6080

# Set the working directory
WORKDIR /root

# Start the VNC server with a virtual framebuffer and noVNC web server
CMD bash -c "xvfb-run --server-args='-screen 0 1280x720x24' dolphin-emu & \
    x11vnc -display :99 -forever -nopw -listen localhost -xkb -bg && \
    websockify --web=/usr/share/novnc/ 6080 localhost:5900"
