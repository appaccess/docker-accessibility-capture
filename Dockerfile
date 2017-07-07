#
# This file compiled from Dockerfile.in.
#

FROM ubuntu:14.04

#
# Environment configurations to get everything to play well
#

# Unicode command line
ENV LANG="C.UTF-8" \
    LC_ALL="C.UTF-8"

# Use bash instead of sh, fix stdin tty messages
RUN rm /bin/sh && ln -s /bin/bash /bin/sh && \
    sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile
#
# Install the packages we need for getting things done
#
# Based on: https://hub.docker.com/_/buildpack-deps/
#

RUN apt-get -qq clean && \
    apt-get -qq update && \
    apt-get -qq install -y --no-install-recommends \
        # From jessie-curl
        # https://github.com/docker-library/buildpack-deps/blob/a0a59c61102e8b079d568db69368fb89421f75f2/jessie/curl/Dockerfile
		ca-certificates \
		curl \
		wget \

        # From jessie-scm
        # https://github.com/docker-library/buildpack-deps/blob/1845b3f918f69b4c97912b0d4d68a5658458e84f/jessie/scm/Dockerfile
		bzr \
		git \
		mercurial \
		openssh-client \
		subversion \
		procps \

        # From jessie
        # https://github.com/docker-library/buildpack-deps/blob/e7534be05255522954f50542ebf9c5f06485838d/jessie/Dockerfile
		autoconf \
		automake \
		bzip2 \
		file \
		g++ \
		gcc \
		imagemagick \
		libbz2-dev \
		libc6-dev \
		libcurl4-openssl-dev \
		libdb-dev \
		libevent-dev \
		libffi-dev \
		libgeoip-dev \
		libglib2.0-dev \
		libjpeg-dev \
		liblzma-dev \
		libmagickcore-dev \
		libmagickwand-dev \
		libmysqlclient-dev \
		libncurses-dev \
		libpng-dev \
		libpq-dev \
		libreadline-dev \
		libsqlite3-dev \
		libssl-dev \
		libtool \
		libwebp-dev \
		libxml2-dev \
		libxslt-dev \
		libyaml-dev \
		make \
		patch \
		xz-utils \
		zlib1g-dev \

        # Our common dependencies
        dos2unix \
    && \
    apt-get -qq clean
RUN sudo apt-get update
RUN sudo apt-get install -y software-properties-common

RUN sudo add-apt-repository ppa:webupd8team/java
RUN sudo apt-get update
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
RUN sudo apt-get install -y oracle-java8-installer
RUN sudo apt-get install -y oracle-java8-set-default

########
########
######## https://github.com/bitrise-docker/android/blob/master/Dockerfile
########
########

# Dependencies to execute Android builds
RUN dpkg --add-architecture i386
RUN apt-get update -qq
# RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openjdk-8-jdk libc6:i386 libstdc++6:i386 libgcc1:i386 libncurses5:i386 libz1:i386
RUN apt-get install -y libc6:i386 libstdc++6:i386 libgcc1:i386 libncurses5:i386 libz1:i386 unzip


# ------------------------------------------------------
# --- Download Android SDK tools into $ANDROID_HOME

ENV ANDROID_HOME /opt/android-sdk-linux

RUN cd /opt \
    && wget -q https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip -O android-sdk-tools.zip \
    && unzip -q android-sdk-tools.zip -d ${ANDROID_HOME} \
    && rm -f android-sdk-tools.zip

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools




RUN apt-get install -y socat net-tools




# ------------------------------------------------------
# --- Install Android SDKs and other build packages

# To get a full list of available options you can use:
# RUN sdkmanager --list --verbose --channel=3
RUN sdkmanager --list --verbose

# Accept "android-sdk-license" before installing components, no need to echo y for each component
# License is valid for all the standard components in versions installed from this file
# Non-standard components: MIPS system images, preview versions, GDK (Google Glass) and Android Google TV require separate licenses, not accepted there
RUN mkdir -p ${ANDROID_HOME}/licenses
RUN echo 8933bad161af4178b1185d1a37fbf41ea5269c55 > ${ANDROID_HOME}/licenses/android-sdk-license

# Platform tools
RUN sdkmanager "platform-tools"

# SDKs
RUN sdkmanager "platforms;android-24"

# build tools
# Please keep these in descending order!
RUN sdkmanager "build-tools;24.0.3"

# Android System Image for emulator
RUN sdkmanager "system-images;android-24;default;armeabi-v7a"

# Need the canary build for the swiftshader support
RUN echo yes | sdkmanager --channel=3 "emulator"

RUN sdkmanager --list --verbose




RUN echo no | avdmanager create avd -f -n "docker-accessibility-capture" -k "system-images;android-24;default;armeabi-v7a" -c 128M

RUN echo hw.ramSize=1024 >> ~/.android/avd/docker-accessibility-capture.ini
RUN echo hw.gpu.enabled=yes >> ~/.android/avd/docker-accessibility-capture.ini
RUN echo hw.gpu.mode=swiftshader >> ~/.android/avd/docker-accessibility-capture.ini

RUN cat ~/.android/avd/docker-accessibility-capture.ini




ENV ANDROID_EMULATOR_PORT 5554
ENV ADB_PORT 5555





RUN apt-get install -y libgl1-mesa-dev

ENV QT_QPA_PLATFORM offscreen
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:/opt/android-sdk-linux/emulator/lib64/:/opt/android-sdk-linux/emulator/lib64/qt/lib:/opt/android-sdk-linux/emulator/lib64/gles_swiftshader



################################################################################
# Set up our entrypoint script.
################################################################################
COPY docker-accessibility-capture/docker-accessibility-capture-entrypoint.sh /docker-accessibility-capture-entrypoint.sh
RUN dos2unix /docker-accessibility-capture-entrypoint.sh && \
    chmod +x /docker-accessibility-capture-entrypoint.sh

# Run the wrapper script
CMD ["/docker-accessibility-capture-entrypoint.sh"]
