#
# Install Ruby
#

RUN wget -O ruby-install-0.6.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.6.0.tar.gz && \
    mkdir /usr/src/ruby-install && \
    tar -xzC /usr/src/ruby-install --strip-components=1 -f ruby-install-0.6.0.tar.gz && \
    rm ruby-install-0.6.0.tar.gz && \
    cd /usr/src/ruby-install && \
    make install && \
    rm -rf /usr/src/ruby-install

RUN wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz && \
    mkdir /usr/src/chruby && \
    tar -xzC /usr/src/chruby --strip-components=1 -f chruby-0.3.9.tar.gz && \
    rm chruby-0.3.9.tar.gz && \
    cd /usr/src/chruby && \
    make install && \
    rm -rf /usr/src/chruby

# System install of Ruby 2.3.3 with Bundler 1.13.6
RUN ruby-install --system --no-reinstall ruby 2.3.3 && \
    gem install bundler --version "1.13.6"

# Legacy pre-install of Ruby 2.3.1 with Bundler 1.13.1
RUN ruby-install --no-reinstall ruby 2.3.1 && \
    source /usr/local/share/chruby/chruby.sh && \
    chruby ruby-2.3.1 && \
    gem install bundler --version "1.13.1"
