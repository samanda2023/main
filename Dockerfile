FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    openjdk-11-jdk \
    wget \
    unzip \
    libqt5widgets5 \
    libqt5gui5 \
    libqt5dbus5 \
    libqt5network5 \
    libqt5script5 \
    libqt5xml5 \
    libqt5core5a

# Download and install Android SDK
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-7302050_latest.zip -O /tmp/sdk.zip && \
    unzip /tmp/sdk.zip -d /opt/android-sdk && \
    rm /tmp/sdk.zip

# Set up environment variables
ENV ANDROID_SDK_ROOT /opt/android-sdk
ENV PATH ${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/emulator

# Install SDK components
RUN yes | ${ANDROID_SDK_ROOT}/cmdline-tools/bin/sdkmanager --licenses && \
    ${ANDROID_SDK_ROOT}/cmdline-tools/bin/sdkmanager "platform-tools" "platforms;android-30" "build-tools;30.0.3" "system-images;android-30;google_apis;arm64-v8a" "emulator"

# Create AVD
RUN echo "no" | ${ANDROID_SDK_ROOT}/cmdline-tools/bin/avdmanager create avd -n test_avd -k "system-images;android-30;google_apis;arm64-v8a" -d "Nexus 5X" --force

# Launch emulator in background
CMD ["emulator", "@test_avd", "-no-audio", "-no-window"]



#FROM ubuntu:20.04
#
## Scripts and configuration
#COPY files/root/* /root/
#COPY files/bin/* /bin/
#
## Make sure line endings are Unix
## This changes nothing if core.autocrlf is set to input
#RUN sed -i 's/\r$//' /root/.bashrc
#
#RUN apt-get update && apt-get install -y \
#    clang \
#    clang-tidy \
#    clang-format \
#    g++ \
#    make \
#    valgrind \
#    gdb \
#    llvm \
#    libgtest-dev \
#    software-properties-common \
#    cmake
#
## GTEST installation for labs
#WORKDIR /usr/src/gtest
#RUN cmake CMakeLists.txt \
#    && make \
#    && cp ./lib/libgtest*.a /usr/lib \
#    && mkdir -p /usr/local/lib/gtest/ \
#    && ln -s /usr/lib/libgtest.a /usr/local/lib/gtest/libgtest.a \
#    && ln -s /usr/lib/libgtest_main.a /usr/local/lib/gtest/libgtest_main.a
#
## Grading, curricula requires python3.9
#RUN add-apt-repository ppa:deadsnakes/ppa \
#    && apt-get install -y \
#        git \
#        acl \
#        python3.9 \
#        python3.9-dev \
#        python3-pip \
#    && python3.9 -m pip install curricula curricula-grade curricula-grade-cpp curricula-compile curricula-format watchdog
#
#VOLUME ["/work"]
#WORKDIR /work








## Use a base image with OpenJDK and Android SDK
#FROM openjdk:11
#
#ARG ANDROID_COMMAND_LINE_TOOLS_SHA256_SUM=124f2d5115eee365df6cf3228ffbca6fc3911d16f8025bebd5b1c6e2fcfa7faf
#ARG ANDROID_COMMAND_LINE_TOOLS_VERSION=7583922_latest
#ARG SUPERCRONIC_SHA1SUM=5ddf8ea26b56d4a7ff6faecdd8966610d5cb9d85
#ARG SUPERCRONIC_VERSION=v0.1.9
#
#ENV ANDROID_SDK_ROOT=/var/android-sdk
#
#USER root
#
## Update package list and install necessary tools
#RUN apt-get update && apt-get install -y unzip wget
#
## Create Android SDK root directory
#RUN mkdir -p ${ANDROID_SDK_ROOT}
#
## Download and install Android Command Line Tools
#RUN wget https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_COMMAND_LINE_TOOLS_VERSION}.zip -O commandlinetools-linux.zip && \
#    echo "${ANDROID_COMMAND_LINE_TOOLS_SHA256_SUM} commandlinetools-linux.zip" | sha256sum -c - && \
#    unzip commandlinetools-linux.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
#    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
#    ln -s ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/avdmanager /usr/local/bin && \
#    ln -s ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager /usr/local/bin && \
#    (yes | sdkmanager --licenses)
#
#RUN sdkmanager --update
#
#RUN sdkmanager --list
#
#RUN sdkmanager --install 'build-tools;34.0.0' platform-tools
#
#RUN sdkmanager --install emulator --channel=0
#
#RUN sdkmanager --install 'system-images;android-33;default;arm64-v8a' --channel=0
##RUN sdkmanager "platforms;android-33" "build-tools;33.0.2" "system-images;android-33;default;arm64-v8a"
#
## Create symbolic links for emulator and adb
#RUN ln -s ${ANDROID_SDK_ROOT}/emulator/emulator /usr/local/bin && \
#  ln -s ${ANDROID_SDK_ROOT}/platform-tools/adb /usr/local/bin
#
## Remove downloaded zip file
#RUN rm commandlinetools-linux.zip
#
## Set up periodic cleanup cron job
## Download and install supercronic
#RUN echo "5 4 * * * /usr/bin/find /tmp/android* -mtime +3 -exec rm -rf {} \;" > ${ANDROID_SDK_ROOT}/cleanup.cron && \
#  wget https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-amd64 -O /usr/local/bin/supercronic && \
#  echo "${SUPERCRONIC_SHA1SUM}  /usr/local/bin/supercronic" | sha1sum -c - && \
#  chmod +x /usr/local/bin/supercronic
#
## Remove unnecessary packages and install runtime dependencies
## Clean up package lists and directories
#RUN apt-get remove -y unzip wget && apt-get auto-remove -y && \
#  apt-get install -y libfontconfig libglu1 libnss3-dev libxcomposite1 libxcursor1 libpulse0 libasound2 socat && \
#  rm -rf /var/lib/apt/lists/* && \
#  addgroup --gid 1000 android && \
#  useradd -u 1000 -g android -ms /bin/sh android && \
#  chown -R android:android ${ANDROID_SDK_ROOT}
#
#  ## Set environment variables
#  #ENV ANDROID_HOME=/android/sdk
#  #ENV PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/tools/bin
#  #
#  ## Create the ANDROID_HOME directory
#  #RUN mkdir -p $ANDROID_HOME
#  #
#  ## Install required dependencies
#  #RUN apt-get update && apt-get install -y \
#  #    unzip \
#  #    && rm -rf /var/lib/apt/lists/*
#  #
#  ## Download and install Android SDK
#  #RUN wget https://dl.google.com/android/repository/commandlinetools-linux-7302050_latest.zip -O android-sdk.zip \
#  #    && unzip -q android-sdk.zip -d $ANDROID_HOME \
#  #    && rm android-sdk.zip
#
#
#  # Accept Android SDK licenses
#  #RUN yes | sdkmanager --licenses
#
#  # Install required Android components
#  #RUN sdkmanager "platforms;android-33" "build-tools;33.0.2" "system-images;android-33;google_apis_playstore;arm64-v8a"
#
## Create AVD (Android Virtual Device)
#RUN echo "no" | avdmanager --verbose create avd --force -n test -k "system-images;android-33;google_apis_playstore;arm64-v8a"
#
## Set up hardware acceleration
#ENV QEMU_AUDIO_DRV=none
#ENV QEMU=$ANDROID_HOME/emulator/qemu/linux-arm64/qemu-system-arm64
#ENV KVM_DIR=$ANDROID_HOME/emulator/qemu/linux-arm64/bin
#ENV TMPDIR=/tmp
#ENV QEMU_KERNEL_DIR=$ANDROID_HOME/emulator/qemu/linux-arm64/bin
#
## Launch the emulator in the background
#CMD $ANDROID_HOME/emulator/emulator -avd test -no-window -no-audio -gpu off