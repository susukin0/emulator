#!/bin/bash

set -e

# Check for required commands
command -v javac > /dev/null 2>&1 || { echo >&2 "I require openjdk-11 but it's not installed. Install it. Aborting."; exit 1; }
command -v unzip > /dev/null 2>&1 || { echo >&2 "I require unzip but it's not installed. Install it. Aborting."; exit 1; }
command -v wget > /dev/null 2>&1 || { echo >&2 "I require wget but it's not installed. Install it. Aborting."; exit 1; }

# Paths to tools
AVDMANAGER="$HOME/commandline-tools/cmdline-tools/bin/avdmanager"
EMULATOR="$HOME/emulator/emulator"
SDKMANAGER="$HOME/commandline-tools/cmdline-tools/bin/sdkmanager"

# AVD configuration
AVD_NAME="my_avd"

# Download and install necessary SDK components
[[ -e $HOME/commandline-tools.zip ]] || wget -O $HOME/commandline-tools.zip 'https://dl.google.com/android/repository/commandlinetools-linux-9123335_latest.zip' && [[ -d $HOME/commandline-tools ]] || unzip $HOME/commandline-tools.zip -d $HOME/commandline-tools/

yes | $SDKMANAGER --install "emulator" "platforms;android-30" "platform-tools" "extras;google;google_play_services" --sdk_root=$HOME/
yes | $SDKMANAGER "system-images;android-30;google_apis_playstore;x86_64" --sdk_root=$HOME/
yes | $SDKMANAGER --update --sdk_root=$HOME/

# Delete existing AVD if present and create a new one
[[ -d $HOME/.android/avd/$AVD_NAME.avd ]] && $AVDMANAGER delete avd -n $AVD_NAME
echo 'no' | $AVDMANAGER create avd -n $AVD_NAME -k "system-images;android-30;google_apis_playstore;x86_64" -p "$HOME/.android/avd/$AVD_NAME.avd/" --force

# Modify AVD configuration for gaming
[[ -d $HOME/.android/avd/$AVD_NAME.avd ]] && sed -i -e 's/PlayStore.enabled.*/PlayStore.enabled = yes/' $HOME/.android/avd/$AVD_NAME.avd/config.ini
[[ -d $HOME/.android/avd/$AVD_NAME.avd ]] && sed -i -e 's/hw.keyboard.*/hw.keyboard = yes/' $HOME/.android/avd/$AVD_NAME.avd/config.ini
[[ -d $HOME/.android/avd/$AVD_NAME.avd ]] && echo "hw.ramSize=4096" >> $HOME/.android/avd/$AVD_NAME.avd/config.ini
[[ -d $HOME/.android/avd/$AVD_NAME.avd ]] && echo "hw.gpu.enabled=yes" >> $HOME/.android/avd/$AVD_NAME.avd/config.ini
[[ -d $HOME/.android/avd/$AVD_NAME.avd ]] && echo "hw.gpu.mode=auto" >> $HOME/.android/avd/$AVD_NAME.avd/config.ini
[[ -d $HOME/.android/avd/$AVD_NAME.avd ]] && echo "hw.lcd.density=420" >> $HOME/.android/avd/$AVD_NAME.avd/config.ini

echo "All done! Running the device..."

# Launch the emulator
$EMULATOR -avd $AVD_NAME

exit

