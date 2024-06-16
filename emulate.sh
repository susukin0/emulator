#!/bin/bash

set -e

# Check for required tools
command -v javac > /dev/null 2>&1 || { echo >&2 "Error: Java (openjdk-11) is required but not installed. Aborting."; exit 1; }
command -v unzip > /dev/null 2>&1 || { echo >&2 "Error: unzip is required but not installed. Aborting."; exit 1; }
command -v wget > /dev/null 2>&1 || { echo >&2 "Error: wget is required but not installed. Aborting."; exit 1; }

OPT_DIR="/opt/android-sdk"
AVDMANAGER="$OPT_DIR/cmdline-tools/cmdline-tools/bin/avdmanager"
EMULATOR="$OPT_DIR/emulator/emulator"
SDKMANAGER="$OPT_DIR/cmdline-tools/cmdline-tools/bin/sdkmanager"

AVD_NAME="my_avd"

# Download and extract Android SDK tools if not already present
[[ -e $OPT_DIR/commandline-tools.zip ]] || wget -O $OPT_DIR/commandline-tools.zip 'https://dl.google.com/android/repository/commandlinetools-linux-9123335_latest.zip' && [[ -d $OPT_DIR/cmdline-tools ]] || unzip $OPT_DIR/commandline-tools.zip -d $OPT_DIR/cmdline-tools/

# Install SDK components and update
yes | $SDKMANAGER --install "emulator" "platforms;android-30" "platform-tools" --sdk_root=$OPT_DIR
yes | $SDKMANAGER "system-images;android-30;google_apis_playstore;x86_64" --sdk_root=$OPT_DIR
yes | $SDKMANAGER --update --sdk_root=$OPT_DIR

# Check if AVD directory is moved and create symbolic link
if [[ ! -d $OPT_DIR/.android/avd ]]; then
    sudo mv ~/.android/avd $OPT_DIR/.android/
    ln -s $OPT_DIR/.android/avd ~/.android/avd
fi

# Create AVD if it doesn't exist
if [[ ! -d $OPT_DIR/.android/avd/$AVD_NAME.avd ]]; then
    echo 'no' | $AVDMANAGER create avd -n $AVD_NAME -k "system-images;android-30;google_apis_playstore;x86_64" -p "$OPT_DIR/.android/avd/$AVD_NAME.avd/" --force
fi

# Enable Play Store and hardware keyboard
sed -i -e 's/PlayStore.enabled.*/PlayStore.enabled = yes/' $OPT_DIR/.android/avd/$AVD_NAME.avd/config.ini
sed -i -e 's/hw.keyboard.*/hw.keyboard = yes/' $OPT_DIR/.android/avd/$AVD_NAME.avd/config.ini

# Enable GPU acceleration
echo "hw.gpu.enabled = yes" >> $OPT_DIR/.android/avd/$AVD_NAME.avd/config.ini
echo "hw.gpu.mode = host" >> $OPT_DIR/.android/avd/$AVD_NAME.avd/config.ini

# Allocate 2GB of RAM
echo "hw.ramSize=2048" >> $OPT_DIR/.android/avd/$AVD_NAME.avd/config.ini

# Set NVIDIA GPU option
echo "hw.dPad=no" >> $OPT_DIR/.android/avd/$AVD_NAME.avd/config.ini

echo "All processes completed successfully! Starting the Android Emulator..."

$EMULATOR -avd $AVD_NAME

exit 0
