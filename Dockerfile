FROM centos:7 AS gcc-centos

ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"
ENV GMP_VERSION=6.1.2
ENV MPFR_VERSION=4.0.2
ENV MPC_VERSION=1.1.0
ENV GCC_VERSION=8.3.0
ENV GDB_VERSION=8.2

RUN 	yum -y install gcc-c++ make lzma m4 
RUN 	pushd /home 
RUN	mkdir build 
RUN	cd build
RUN	curl -o gmp.tar.xz https://gmplib.org/download/gmp/gmp-$GMP_VERSION.tar.xz 
RUN	tar xf gmp.tar.xz 
RUN	mkdir gmp-build 
RUN	pushd gmp-build 
RUN	../gmp-$GMP_VERSION/configure 
RUN	make -j$(nproc) 
RUN	make -j$(nproc) check 
RUN	make install 
RUN	popd
RUN	rm -rf * 
RUN	curl -o mpfr.tar.xz https://www.mpfr.org/mpfr-current/mpfr-$MPFR_VERSION.tar.xz 
RUN	tar xf mpfr.tar.xz 
RUN	mkdir mpfr-build 
RUN	pushd mpfr-build
RUN	../mpfr-$MPFR_VERSION/configure --with-gmp=/usr/local 
RUN	make -j$(nproc) 
RUN	make install 
RUN	popd 
RUN	rm -rf * 
RUN	curl -o mpc.tar.gz https://ftp.gnu.org/gnu/mpc/mpc-$MPC_VERSION.tar.gz 
RUN	tar xf mpc.tar.gz 
RUN	mkdir mpc-build 
RUN	pushd mpc-build 
RUN	../mpc-$MPC_VERSION/configure --with-gmp=/usr/local --with-mpfr=/usr/local 
RUN	make -j$(nproc) 
RUN	make install 
RUN	popd
RUN	rm -rf * 
RUN	curl -o gcc.tar.xz http://robotlab.itk.ppke.hu/gcc/releases/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.xz 
RUN	tar xf gcc.tar.xz 
RUN	mkdir gcc-build 
RUN	pushd gcc-build
RUN	../gcc-$GCC_VERSION/configure --with-gmp=/usr/local --with-mpfr=/usr/local --with-mpc=/usr/local --enable-lto --enable-languages=c,c++ --disable-multilib 
RUN	make -j$(nproc) 
RUN	make install 
RUN	popd 
RUN	rm -rf *
RUN	curl -o gdb.tar.xz https://ftp.gnu.org/gnu/gdb/gdb-$GDB_VERSION.tar.xz
RUN	tar xf gdb.tar.xz
RUN	mkdir gdb-build
RUN	pushd gdb-build
RUN	../gdb-$GDB_VERSION/configure
RUN	make -j$(nproc)
RUN	make install
RUN	popd
RUN	popd
RUN	rm -rf build
RUN	yum -y remove gcc m4
RUN 	yum -y remove `package-cleanup --leaves`

ENV AR="/usr/local/bin/gcc-ar"
ENV RANLIB="/usr/local/bin/gcc-ranlib"
ENV NM="/usr/local/bin/gcc-nm"
ENV CC="/usr/local/bin/gcc"
ENV CXX="/usr/local/bin/g++"
