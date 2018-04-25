FROM ataber/trilinos

RUN apt-get update --fix-missing \
&&  apt-get upgrade -y --force-yes \
&&  apt-get install -y --force-yes \
    git \
    ninja-build \
    numdiff \
&&  apt-get clean \
&&  rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# dealii
ARG VER=master
ARG BUILD_TYPE=Release
RUN git clone https://github.com/dealii/dealii.git dealii-$VER-src && \
    cd dealii-$VER-src && \
    git checkout $VER && \
    mkdir build && cd build && \
    cmake -DCMAKE_INSTALL_PREFIX=~/dealii-$VER \
          -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
          -GNinja \
          ../ && \
    ninja library && \
    cp summary.log ~/dealii-$VER/summary.log

