FROM ataber/cmake

RUN apt-get update --fix-missing \
&&  apt-get upgrade -y --force-yes \
&&  apt-get install -y --force-yes \
    bzip2 \
    gfortran \
    git \
    gsl-bin \
    libblas-dev \
    libgsl0-dev \
    liblapack-dev \
    libsuitesparse-dev \
    libtbb-dev \
    libtbb2 \
    ninja-build \
    numdiff \
    python \
    unzip \
    wget \
&&  apt-get clean \
&&  rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# Export compilers
ENV CC clang-5.0
ENV CXX clang++-5.0
ENV FC gfortran
ENV FF gfortran

ENV HOME /app

#Build Trilinos
ENV TRILINOS_VERSION 12-8-1
RUN wget https://github.com/trilinos/Trilinos/archive/trilinos-release-$TRILINOS_VERSION.tar.gz && \
    tar xfz trilinos-release-$TRILINOS_VERSION.tar.gz && \
    mkdir Trilinos-trilinos-release-$TRILINOS_VERSION/build && \
    cd Trilinos-trilinos-release-$TRILINOS_VERSION/build && \
    cmake \
     -D BUILD_SHARED_LIBS=ON \
     -D CMAKE_BUILD_TYPE=RELEASE \
     -D CMAKE_CXX_FLAGS="-O3" \
     -D CMAKE_C_FLAGS="-O3" \
     -D CMAKE_FORTRAN_FLAGS="-O5" \
     -D CMAKE_INSTALL_PREFIX:PATH=$HOME/libs/trilinos-$TRILINOS_VERSION \
     -D CMAKE_VERBOSE_MAKEFILE=FALSE \
     -D TPL_ENABLE_Boost=OFF \
     -D TPL_ENABLE_MPI=ON \
     -D TPL_ENABLE_Netcdf:BOOL=OFF \
     -D TrilinosFramework_ENABLE_MPI:BOOL=ON \
     -D Trilinos_ASSERT_MISSING_PACKAGES:BOOL=OFF \
     -D Trilinos_ENABLE_ALL_OPTIONAL_PACKAGES:BOOL=ON \
     -D Trilinos_ENABLE_ALL_PACKAGES:BOOL=OFF \
     -D Trilinos_ENABLE_Amesos:BOOL=ON \
     -D Trilinos_ENABLE_AztecOO:BOOL=ON \
     -D Trilinos_ENABLE_Epetra:BOOL=ON \
     -D Trilinos_ENABLE_EpetraExt:BOOL=ON \
     -D Trilinos_ENABLE_Ifpack:BOOL=ON \
     -D Trilinos_ENABLE_Jpetra:BOOL=ON \
     -D Trilinos_ENABLE_Kokkos:BOOL=ON \
     -D Trilinos_ENABLE_Komplex:BOOL=ON \
     -D Trilinos_ENABLE_ML:BOOL=ON \
     -D Trilinos_ENABLE_MOOCHO:BOOL=ON \
     -D Trilinos_ENABLE_MueLu:BOOL=ON \
     -D Trilinos_ENABLE_OpenMP:BOOL=OFF \
     -D Trilinos_ENABLE_Piro:BOOL=ON \
     -D Trilinos_ENABLE_Rythmos:BOOL=ON \
     -D Trilinos_ENABLE_STK:BOOL=OFF \
     -D Trilinos_ENABLE_Sacado=ON \
     -D Trilinos_ENABLE_TESTS:BOOL=OFF \
     -D Trilinos_ENABLE_Stratimikos=ON \
     -D Trilinos_ENABLE_Teuchos:BOOL=ON \
     -D Trilinos_ENABLE_Thyra:BOOL=ON \
     -D Trilinos_ENABLE_Tpetra:BOOL=ON \
     -D Trilinos_ENABLE_TrilinosCouplings:BOOL=ON \
     -D Trilinos_EXTRA_LINK_FLAGS="-lgfortran" \
     -D Trilinos_VERBOSE_CONFIGURE=FALSE \
     .. && \
   make -j4 && make install && \
   cd $HOME && \
   rm -rf Trilinos-trilinos-release-* &&\
   rm -rf trilinos-release-*
ENV TRILINOS_DIR $HOME/libs/trilinos-$TRILINOS_VERSION

#petsc
ENV PETSC_VERSION 3.7.4
RUN wget http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-lite-$PETSC_VERSION.tar.gz && \
    tar xf petsc-lite-$PETSC_VERSION.tar.gz && rm -f petsc-lite-$PETSC_VERSION.tar.gz && \
    cd petsc-$PETSC_VERSION && \
    ./configure \
	--download-fblaslapack \
	--download-hypre=1  \
	--download-scalapack \
	--download-mumps \
	--download-metis \
	--download-parmetis \
	--download-superlu \
	--download-superlu_dist \
	--prefix=$HOME/libs/petsc-$PETSC_VERSION \
	--with-clanguage=C++ \
	--with-debugging=1 \
    	--with-shared-libraries=1 \
	--with-x=0 \
    	COPTFLAGS='-O3' FOPTFLAGS='-O3' && \
    make PETSC_DIR=`pwd` PETSC_ARC=docker all &&\
    make PETSC_DIR=`pwd` PETSC_ARC=docker install && \
    make PETSC_DIR=$HOME/libs/petsc-$PETSC_VERSION PETSC_ARCH= test && \
    cd && rm -rf petsc-$PETSC_VERSION

ENV PETSC_DIR $HOME/libs/petsc-$PETSC_VERSION
ENV METIS_DIR $PETSC_DIR
ENV SCALAPACK_DIR $PETSC_DIR
ENV PARMETIS_DIR $PETSC_DIR
ENV SUPERLU_DIR $PETSC_DIR
ENV SUPERLU_DIST_DIR $PETSC_DIR
ENV MUMPS_DIR $PETSC_DIR

#slepc
ENV SLEPC_VERSION 3.7.3
RUN wget http://slepc.upv.es/download/download.php?filename=slepc-$SLEPC_VERSION.tar.gz \
    -O slepc-$SLEPC_VERSION.tar.gz && \
    tar xfz slepc-$SLEPC_VERSION.tar.gz && rm -f slepc-$SLEPC_VERSION.rag.gz && \
    cd slepc-$SLEPC_VERSION && \
    ./configure --prefix=$HOME/libs/slepc-$SLEPC_VERSION && \
    make SLEPC_DIR=`pwd` && make SLEPC_DIR=`pwd` install && \
    cd && rm -rf slepc-$SLEPC_VERSION*

ENV SLEPC_DIR $HOME/libs/slepc-$SLEPC_VERSION
