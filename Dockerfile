FROM ataber/trilinos

RUN apt-get update --fix-missing \
&&  apt-get upgrade -y --force-yes \
&&  apt-get install -y --force-yes \
    git \
    ninja-build \
    numdiff \
    python \
&&  apt-get clean \
&&  rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# dealii
ARG VER=master
ARG BUILD_TYPE=Debug
RUN git clone https://github.com/dealii/dealii.git dealii-$VER-src && \
    cd dealii-$VER-src && \
    git checkout $VER && \
    mkdir build && cd build && \
    cmake -DDEAL_II_COMPONENT_EXAMPLES=OFF \
          -DCMAKE_INSTALL_PREFIX=~/dealii-$VER \
          -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
          -GNinja \
          ../ && \
    ninja install && \
    ninja test && \
    cp summary.log ~/dealii-$VER/summary.log && \
    cd .. && rm -rf build .git

