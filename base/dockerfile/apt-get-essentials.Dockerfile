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
