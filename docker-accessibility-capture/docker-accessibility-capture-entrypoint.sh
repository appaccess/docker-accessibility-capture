#!/bin/bash

ip=$(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
socat tcp-listen:$ANDROID_EMULATOR_PORT,bind=$ip,fork tcp:127.0.0.1:$ANDROID_EMULATOR_PORT &
socat tcp-listen:$ADB_PORT,bind=$ip,fork tcp:127.0.0.1:$ADB_PORT &

/opt/android-sdk-linux/emulator/emulator64-arm -avd "docker-accessibility-capture" \
                  -port $ANDROID_EMULATOR_PORT \
                  -no-boot-anim \
                  -no-window \
                  -no-audio \
                  -gpu swiftshader \
				  -verbose \

                  #-no-snapshot-save \
				  #-qemu -usbdevice tablet -vnc :0

adb wait-for-device
adb devices
adb logcat
