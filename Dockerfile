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
RUN sudo apt-get install -y software-properties-common

RUN sudo add-apt-repository ppa:webupd8team/java
RUN sudo apt-get update
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
RUN sudo apt-get install -y oracle-java8-installer
RUN sudo apt-get install -y oracle-java8-set-default

#
# https://github.com/chuross/docker/blob/master/android-java/8/Dockerfile
#

RUN dpkg --add-architecture i386 \
  && apt-get -yq update \
  && apt-get -yq install libncurses5:i386 libstdc++6:i386 zlib1g:i386 --no-install-recommends \
  && apt-get clean

# Android arguments
ARG ANDROID_SDK_VERSION="24.4.1"

ENV ANDROID_SDK_URL http://dl.google.com/android/android-sdk_r${ANDROID_SDK_VERSION}-linux.tgz
ENV ANDROID_HOME /usr/local/android-sdk-linux
ENV PATH ${ANDROID_HOME}/tools:$ANDROID_HOME/platform-tools:$PATH

# Android components
ENV ANDROID_COMPONENTS platform-tools

# install Android
RUN curl -sL "${ANDROID_SDK_URL}" | tar xz --no-same-owner -C /usr/local
RUN echo y | android update sdk --no-ui --all --filter "${ANDROID_COMPONENTS}"

#
# https://github.com/chuross/docker/blob/master/android-emulator/Dockerfile
#

ARG TARGET_API="android-24"
ARG STORAGE_SIZE="128M"
ARG SKIN="QVGA"

ENV ANDROID_TARGET_API $TARGET_API
ENV ANDROID_EMULATOR_STORAGE_SIZE $STORAGE_SIZE
ENV ANDROID_EMULATOR_SKIN $SKIN
ENV ANDROID_EMULATOR_MEMORY 1024
ENV ANDROID_EMULATOR_NAME "armeabi-v7a-${ANDROID_TARGET_API}"
ENV ANDROID_EMULATOR_COMPONENTS $ANDROID_TARGET_API,sys-img-${ANDROID_EMULATOR_NAME}
ENV ANDROID_EMULATOR_PATH $ANDROID_HOME/../emulators
ENV ANDROID_EMULATOR_PORT 5554
ENV ADB_PORT 5555

EXPOSE $ADB_PORT
EXPOSE $ANDROID_EMULATOR_PORT

RUN apt-get install -y socat net-tools

WORKDIR $ANDROID_HOME
RUN rm -rf platforms/$ANDROID_TARGET_API
RUN echo y | android update sdk --no-ui --all --filter "${ANDROID_EMULATOR_COMPONENTS}"

RUN android list targets \
      && echo no | android create avd --force \
                                  -n $ANDROID_EMULATOR_NAME \
                                  -t $ANDROID_TARGET_API \
                                  -c $ANDROID_EMULATOR_STORAGE_SIZE \
                                  -s $ANDROID_EMULATOR_SKIN \
      && echo hw.ramSize=$ANDROID_EMULATOR_MEMORY >> ~/.android/avd/${ANDROID_EMULATOR_NAME}.ini



################################################################################
# Set up our entrypoint script.
################################################################################
COPY docker-accessibility-capture/docker-accessibility-capture-entrypoint.sh /docker-accessibility-capture-entrypoint.sh
RUN dos2unix /docker-accessibility-capture-entrypoint.sh && \
    chmod +x /docker-accessibility-capture-entrypoint.sh

# Run the wrapper script
CMD ["/docker-accessibility-capture-entrypoint.sh"]
