FROM centos:7

ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}" \
    GMP_VERSION=6.1.2                                   \
    MPFR_VERSION=4.0.2                                  \
    MPC_VERSION=1.1.0                                   \
    GCC_VERSION=8.3.0                                   \
    GDB_VERSION=8.2

RUN yum -y install gcc-c++ make lzma m4; \
    pushd /home; \
    mkdir build; \
    pushd build; \
    curl -o gmp.tar.xz https://gmplib.org/download/gmp/gmp-$GMP_VERSION.tar.xz; \
    tar xf gmp.tar.xz; \
    mkdir gmp-build; \
    pushd gmp-build; \
    ../gmp-$GMP_VERSION/configure; \
    make -j$(nproc); \
    make -j$(nproc) check; \
    make install; \
    popd; \
    rm -rf *; \
    curl -o mpfr.tar.xz https://www.mpfr.org/mpfr-current/mpfr-$MPFR_VERSION.tar.xz; \
    tar xf mpfr.tar.xz; \
    mkdir mpfr-build; \
    pushd mpfr-build; \
    ../mpfr-$MPFR_VERSION/configure --with-gmp=/usr/local; \
    make -j$(nproc); \
    make install; \
    popd; \
    rm -rf *; \
    curl -o mpc.tar.gz https://ftp.gnu.org/gnu/mpc/mpc-$MPC_VERSION.tar.gz; \
    tar xf mpc.tar.gz; \
    mkdir mpc-build; \
    pushd mpc-build; \
    ../mpc-$MPC_VERSION/configure --with-gmp=/usr/local --with-mpfr=/usr/local; \
    make -j$(nproc); \
    make install; \
    popd; \
    rm -rf *; \
    curl -o gcc.tar.xz http://robotlab.itk.ppke.hu/gcc/releases/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.xz; \
    tar xf gcc.tar.xz; \
    mkdir gcc-build; \
    pushd gcc-build; \
    ../gcc-$GCC_VERSION/configure --with-gmp=/usr/local --with-mpfr=/usr/local --with-mpc=/usr/local --enable-lto --enable-languages=c,c++ --disable-multilib; \
    make -j$(nproc); \
    make install; \
    popd; \
    rm -rf *; \
    curl -o gdb.tar.xz https://ftp.gnu.org/gnu/gdb/gdb-$GDB_VERSION.tar.xz; \
    tar xf gdb.tar.xz; \
    mkdir gdb-build; \
    pushd gdb-build; \
    ../gdb-$GDB_VERSION/configure; \
    make -j$(nproc); \
    make install; \
    popd; \
    popd; \
    rm -rf build; \
    yum -y remove gcc m4; \
    yum -y remove `package-cleanup --leaves`

ENV AR="/usr/local/bin/gcc-ar"          \
    RANLIB="/usr/local/bin/gcc-ranlib"  \
    NM="/usr/local/bin/gcc-nm"          \
    CC="/usr/local/bin/gcc"             \
    CXX="/usr/local/bin/g++"
