#
# Install Python
#
# Uses pyenv.
#

ENV PYTHON_VERSION 3.5.2
ENV PYTHON_PIP_VERSION 8.1.1

# Remove Debian python
RUN apt-get -qq purge -y python.*

# Install pyenv
ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

RUN set -ex \
    && curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash \
    && pyenv update \
    && pyenv install $PYTHON_VERSION \
    && pyenv global $PYTHON_VERSION \
    && pyenv rehash

RUN set -ex \
    && python -m pip install --upgrade pip==$PYTHON_PIP_VERSION
