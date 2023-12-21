# Use AdoptOpenJDK 11 as the base image
FROM openjdk:11

# Set up Android SDK and NDK
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=${PATH}:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

USER root

RUN mkdir -p ${ANDROID_HOME}

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    wget \
    zip

RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip -O /tmp/android-tools.zip && \
    unzip -q /tmp/android-tools.zip -d ${ANDROID_HOME} && \
    rm /tmp/android-tools.zip

RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses

RUN ${ANDROID_HOME}/tools/bin/sdkmanager --list

# Install necessary SDK components
RUN ${ANDROID_HOME}/tools/bin/sdkmanager "platforms;android-30" \
    "build-tools;30.0.3" \
    "extras;google;m2repository" \
    "extras;android;m2repository" \
    "cmake;3.10.2.4988404"

RUN ls -l ${ANDROID_HOME}/emulator

RUN ls -l ${ANDROID_HOME}/emulator/qemu

RUN ls -l ${ANDROID_HOME}/emulator/qemu/aarch64

# Set up ARM64 emulator
COPY ${ANDROID_HOME}/emulator/qemu/aarch64/qemu-system-aarch64 /usr/bin/qemu-system-aarch64

# Set working directory
WORKDIR /workspace
