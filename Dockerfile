FROM fedora:latest

RUN yum -y update && yum install -y cmake git mingw32-qt5* mingw32-gcc-c++ mingw32-gcc mingw32-gcc-gfortran mingw32-libgomp mingw32-gsl mingw32-zlib mingw32-nsis unzip wget

#yum install -y nano vim mlocate && updatedb

RUN /bin/bash -c ' mkdir fftw3 && cd fftw3;                                                          \
    wget ftp://ftp.fftw.org/pub/fftw/fftw-3.3.5-dll32.zip && unzip fftw-3.3.5-dll32.zip;             \
	for i in *.def; do /usr/bin/i686-w64-mingw32-dlltool -d $i -l `basename ${i} .def`.dll.a; done;  \
	/bin/cp *.dll /usr/i686-w64-mingw32/sys-root/mingw/bin;                                          \
    /bin/cp fftw3* /usr/i686-w64-mingw32/sys-root/mingw/include;                                     \
    /bin/cp *.dll.a /usr/i686-w64-mingw32/sys-root/mingw/lib;                                        '
 

RUN wget http://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio3410.tar.gz && tar -zxvf cfitsio3410.tar.gz; \
    cd cfitsio && mkdir cross && cd cross; \
    cmake -DCMAKE_SYSTEM_NAME=Windows -DCMAKE_C_COMPILER=i686-w64-mingw32-gcc -DCMAKE_CXX_COMPILER=i686-w64-mingw32-c++ -DCMAKE_RC_COMPILER=i686-w64-mingw32-windres -DCMAKE_INSTALL_PREFIX:PATH=/usr/i686-w64-mingw32/sys-root/mingw .. && make -j$(nproc) install; \
    /bin/mv /usr/i686-w64-mingw32/sys-root/mingw/lib/libcfitsio.dll /usr/i686-w64-mingw32/sys-root/mingw/bin


RUN git clone https://github.com/iltommi/neutrino.git ;                                                         \
    cd neutrino && mkdir cross && cd cross ;                                                                    \
    cmake .. -DCMAKE_TOOLCHAIN_FILE=../resources/cmake/Toolchain-i686-mingw32.cmake && make -j$(nproc) package 

