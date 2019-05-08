FROM centos:7 AS builder

ARG GMP_VERSION=6.1.2
ARG MPFR_VERSION=4.0.2
ARG MPC_VERSION=1.1.0
ARG GCC_VERSION=8.3.0
ARG GDB_VERSION=8.2
ARG VALGRIND_VERSION=3.14.0

# install build dependencies
RUN yum -y install gcc-c++ make lzma m4 texi2html texinfo bzip2 && \
    mkdir /home/build

# Compile GMP
RUN cd /home/build && \
    curl -o gmp.tar.xz https://gmplib.org/download/gmp/gmp-$GMP_VERSION.tar.xz && \
    tar xf gmp.tar.xz && \
    mkdir gmp-build && \
    pushd gmp-build && \
    ../gmp-$GMP_VERSION/configure && \
    make -j$(nproc) && \
    make -j$(nproc) check && \
    make install && \
    popd && \
    rm -rf *

# Compile MPFR
RUN cd /home/build && \
    curl -o mpfr.tar.xz https://www.mpfr.org/mpfr-current/mpfr-$MPFR_VERSION.tar.xz && \
    tar xf mpfr.tar.xz && \
    mkdir mpfr-build && \
    pushd mpfr-build && \
    ../mpfr-$MPFR_VERSION/configure --with-gmp=/usr/local && \
    make -j$(nproc) && \
    make install && \
    popd && \
    rm -rf *

# Compile MPC
RUN cd /home/build && \
    curl -o mpc.tar.gz https://ftp.gnu.org/gnu/mpc/mpc-$MPC_VERSION.tar.gz && \
    tar xf mpc.tar.gz && \
    mkdir mpc-build && \
    pushd mpc-build && \
    ../mpc-$MPC_VERSION/configure --with-gmp=/usr/local --with-mpfr=/usr/local && \
    make -j$(nproc) && \
    make install && \
    popd && \
    rm -rf *

# Compile Valgrind
RUN cd /home/build && \
    curl -o valgrind.tar.bz2 https://sourceware.org/pub/valgrind/valgrind-${VALGRIND_VERSION}.tar.bz2 && \
    tar xf valgrind.tar.bz2 && \
    mkdir valgrind-build && \
    pushd valgrind-build && \
    ../valgrind-${VALGRIND_VERSION}/configure --enable-lto --enable-only64bit --prefix=/usr/local  && \
    make -j $(nproc)   && \
    make install && \
    popd && \
    rm -rf *

# Compile GDB
RUN cd /home/build && \
    curl -o gdb.tar.xz https://ftp.gnu.org/gnu/gdb/gdb-$GDB_VERSION.tar.xz && \
    tar xf gdb.tar.xz && \
    mkdir gdb-build && \
    pushd gdb-build && \
    ../gdb-$GDB_VERSION/configure --enable-lto && \
    make -j$(nproc) && \
    make install && \
    popd && \
    rm -rf *

# Compile GCC
ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"

RUN cd /home/build && \
    curl -o gcc.tar.xz http://robotlab.itk.ppke.hu/gcc/releases/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.xz && \
    tar xf gcc.tar.xz && \
    mkdir gcc-build && \
    pushd gcc-build && \
    ../gcc-$GCC_VERSION/configure --with-gmp=/usr/local --with-mpfr=/usr/local --with-mpc=/usr/local --enable-lto --enable-languages=c,c++ --disable-multilib && \
    make -j$(nproc) && \
    make install && \
    popd && \
    rm -rf *

# Stage 2, copy artifacts to new image and prepare environment

FROM centos:7
COPY --from=builder /usr/local /usr/local/

ENV AR="/usr/local/bin/gcc-ar"                          \
    RANLIB="/usr/local/bin/gcc-ranlib"                  \
    NM="/usr/local/bin/gcc-nm"                          \
    CC="/usr/local/bin/gcc"                             \
    CXX="/usr/local/bin/g++"                            \
    LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"
