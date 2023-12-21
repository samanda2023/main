# Use a base image with OpenJDK and Android SDK
FROM openjdk:11

ARG ANDROID_COMMAND_LINE_TOOLS_SHA256_SUM=124f2d5115eee365df6cf3228ffbca6fc3911d16f8025bebd5b1c6e2fcfa7faf
ARG ANDROID_COMMAND_LINE_TOOLS_VERSION=7583922_latest
ARG SUPERCRONIC_SHA1SUM=5ddf8ea26b56d4a7ff6faecdd8966610d5cb9d85
ARG SUPERCRONIC_VERSION=v0.1.9

ENV ANDROID_SDK_ROOT=/var/android-sdk

USER root

# Update package list and install necessary tools
RUN apt-get update && apt-get install -y unzip wget

# Create Android SDK root directory
RUN mkdir -p ${ANDROID_SDK_ROOT}

# Download and install Android Command Line Tools
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_COMMAND_LINE_TOOLS_VERSION}.zip -O commandlinetools-linux.zip && \
    echo "${ANDROID_COMMAND_LINE_TOOLS_SHA256_SUM} commandlinetools-linux.zip" | sha256sum -c - && \
    unzip commandlinetools-linux.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    ln -s ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/avdmanager /usr/local/bin && \
    ln -s ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager /usr/local/bin && \
    (yes | sdkmanager --licenses)

RUN sdkmanager --update

RUN sdkmanager --list

RUN sdkmanager --install 'build-tools;34.0.0' platform-tools

RUN sdkmanager --install emulator --channel=0

RUN sdkmanager --install 'system-images;android-33;default;arm64-v8a' --channel=0
#RUN sdkmanager "platforms;android-33" "build-tools;33.0.2" "system-images;android-33;default;arm64-v8a"

# Create symbolic links for emulator and adb
RUN ln -s ${ANDROID_SDK_ROOT}/emulator/emulator /usr/local/bin && \
  ln -s ${ANDROID_SDK_ROOT}/platform-tools/adb /usr/local/bin

# Remove downloaded zip file
RUN rm commandlinetools-linux.zip

# Set up periodic cleanup cron job
# Download and install supercronic
RUN echo "5 4 * * * /usr/bin/find /tmp/android* -mtime +3 -exec rm -rf {} \;" > ${ANDROID_SDK_ROOT}/cleanup.cron && \
  wget https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-amd64 -O /usr/local/bin/supercronic && \
  echo "${SUPERCRONIC_SHA1SUM}  /usr/local/bin/supercronic" | sha1sum -c - && \
  chmod +x /usr/local/bin/supercronic

# Remove unnecessary packages and install runtime dependencies
# Clean up package lists and directories
RUN apt-get remove -y unzip wget && apt-get auto-remove -y && \
  apt-get install -y libfontconfig libglu1 libnss3-dev libxcomposite1 libxcursor1 libpulse0 libasound2 socat && \
  rm -rf /var/lib/apt/lists/* && \
  addgroup --gid 1000 android && \
  useradd -u 1000 -g android -ms /bin/sh android && \
  chown -R android:android ${ANDROID_SDK_ROOT}

  ## Set environment variables
  #ENV ANDROID_HOME=/android/sdk
  #ENV PATH=$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/tools/bin
  #
  ## Create the ANDROID_HOME directory
  #RUN mkdir -p $ANDROID_HOME
  #
  ## Install required dependencies
  #RUN apt-get update && apt-get install -y \
  #    unzip \
  #    && rm -rf /var/lib/apt/lists/*
  #
  ## Download and install Android SDK
  #RUN wget https://dl.google.com/android/repository/commandlinetools-linux-7302050_latest.zip -O android-sdk.zip \
  #    && unzip -q android-sdk.zip -d $ANDROID_HOME \
  #    && rm android-sdk.zip


  # Accept Android SDK licenses
  #RUN yes | sdkmanager --licenses

  # Install required Android components
  #RUN sdkmanager "platforms;android-33" "build-tools;33.0.2" "system-images;android-33;google_apis_playstore;arm64-v8a"

# Create AVD (Android Virtual Device)
RUN echo "no" | avdmanager --verbose create avd --force -n test -k "system-images;android-33;google_apis_playstore;arm64-v8a"

# Set up hardware acceleration
ENV QEMU_AUDIO_DRV=none
ENV QEMU=$ANDROID_HOME/emulator/qemu/linux-arm64/qemu-system-arm64
ENV KVM_DIR=$ANDROID_HOME/emulator/qemu/linux-arm64/bin
ENV TMPDIR=/tmp
ENV QEMU_KERNEL_DIR=$ANDROID_HOME/emulator/qemu/linux-arm64/bin

# Launch the emulator in the background
CMD $ANDROID_HOME/emulator/emulator -avd test -no-window -no-audio -gpu off