FROM fedora:latest

RUN dnf -y update && dnf -y install cmake git mingw32-qt5* mingw32-gcc-c++ mingw32-gcc mingw32-gcc-gfortran mingw32-libgomp mingw32-gsl mingw32-zlib mingw32-nsis unzip wget

#fftw

RUN /bin/bash -c ' mkdir fftw3 && cd fftw3;                                                          \
    wget ftp://ftp.fftw.org/pub/fftw/fftw-3.3.5-dll32.zip && unzip fftw-3.3.5-dll32.zip;             \
	for i in *.def; do i686-w64-mingw32-dlltool -d $i -l `basename ${i} .def`.dll.a; done;           \
	/bin/cp *.dll /usr/i686-w64-mingw32/sys-root/mingw/bin;                                          \
    /bin/cp fftw3* /usr/i686-w64-mingw32/sys-root/mingw/include;                                     \
    /bin/cp *.dll.a /usr/i686-w64-mingw32/sys-root/mingw/lib;                                        '
 

# cfits
RUN wget http://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio3410.tar.gz && tar -zxvf cfitsio3410.tar.gz; \
    cd cfitsio && mkdir cross && cd cross; \
    cmake -DCMAKE_SYSTEM_NAME=Windows -DCMAKE_C_COMPILER=i686-w64-mingw32-gcc -DCMAKE_CXX_COMPILER=i686-w64-mingw32-c++ -DCMAKE_RC_COMPILER=i686-w64-mingw32-windres -DCMAKE_INSTALL_PREFIX:PATH=/usr/i686-w64-mingw32/sys-root/mingw .. && make -j$(nproc) install; \
    /bin/mv /usr/i686-w64-mingw32/sys-root/mingw/lib/libcfitsio.dll /usr/i686-w64-mingw32/sys-root/mingw/bin

RUN dnf install -y autoconf automake bash bison bzip2 flex gcc-c++ gdk-pixbuf2-devel gettext git gperf intltool make sed libffi-devel libtool openssl-devel p7zip patch perl pkgconfig python ruby scons unzip wget xz gtk-doc dh-autoreconf 

# RUN git clone https://github.com/mxe/mxe.git && cd mxe && make hdf4 hdf5 MXE_TARGETS=i686-w64-mingw32.shared
# RUN ln -sf /mxe/usr/i686-w64-mingw32.shared/bin/libdf-0.dll /usr/i686-w64-mingw32/sys-root/mingw/bin
# RUN ln -sf /mxe/usr/i686-w64-mingw32.shared/bin/libmfhdf-0.dll /usr/i686-w64-mingw32/sys-root/mingw/bin
# RUN ln -sf /mxe/usr/i686-w64-mingw32.shared/bin/libjpeg-9.dll /usr/i686-w64-mingw32/sys-root/mingw/bin
# RUN ln -sf /mxe/usr/i686-w64-mingw32.shared/bin/libportablexdr-0.dll /usr/i686-w64-mingw32/sys-root/mingw/bin
# RUN ln -sf /mxe/usr/i686-w64-mingw32.shared/include/df* /usr/i686-w64-mingw32/sys-root/mingw/include/
# RUN ln -sf /mxe/usr/i686-w64-mingw32.shared/include/hdf* /usr/i686-w64-mingw32/sys-root/mingw/include/
# RUN ln -sf /mxe/usr/i686-w64-mingw32.shared/include/mfhdf* /usr/i686-w64-mingw32/sys-root/mingw/include/
# RUN ln -sf /mxe/usr/i686-w64-mingw32.shared/lib/libdf* /usr/i686-w64-mingw32/sys-root/mingw/lib
# RUN ln -sf /mxe/usr/i686-w64-mingw32.shared/lib/libmf* /usr/i686-w64-mingw32/sys-root/mingw/lib

RUN dnf install -y mingw32-portablexdr

RUN wget https://support.hdfgroup.org/ftp/HDF/releases/HDF4.2.10/src/hdf-4.2.10.tar.bz2 && tar -jxvf hdf-4.2.10.tar.bz2; \
    cd hdf-4.2.10; \
    wget https://raw.githubusercontent.com/mxe/mxe/master/src/hdf4-1-portability-fixes.patch; \
    wget https://raw.githubusercontent.com/mxe/mxe/master/src/hdf4-2-dllimport.patch; \
    patch -p1 -u < hdf4-1-portability-fixes.patch ; \
    patch -p1 -u < hdf4-2-dllimport.patch ; \
    libtoolize --force; \
    autoreconf --install; \
    ./configure --host='i686-w64-mingw32' --build='x86_64-unknown-linux-gnu' --prefix='/usr/i686-w64-mingw32/sys-root/mingw'  --disable-static --enable-shared  ac_cv_prog_HAVE_DOXYGEN="false" --disable-doxygen --disable-fortran --disable-netcdf LIBS="-lportablexdr -lws2_32"  CPPFLAGS="-DH4_F77_FUNC\(name,NAME\)=NAME -DH4_BUILT_AS_DYNAMIC_LIB=1 -DBIG_LONGS"; \
    make -C mfhdf/xdr -j $(nproc) LDFLAGS=-no-undefined; \
    make -C hdf/src -j $(nproc) LDFLAGS=-no-undefined; \
    make -C hdf/src -j 1 install; \
    make -C mfhdf/libsrc -j $(nproc) LDFLAGS="-no-undefined -ldf"; \
    make -C mfhdf/libsrc -j 1 install


# pyhton 
RUN dnf -y install 'dnf-command(copr)';    \
    dnf -y copr enable smani/mingw-extras; \
    dnf -y update;                         \
    dnf -y install mingw32-python2

# pyhthonqt
RUN git clone https://github.com/iltommi/PythonQt.git && cd PythonQt && mkdir cross && cd cross; \
    cmake -DCMAKE_SYSTEM_NAME=Windows -DCMAKE_FIND_ROOT_PATH=/usr/i686-w64-mingw32 -DCMAKE_C_COMPILER=i686-w64-mingw32-gcc -DCMAKE_CXX_COMPILER=i686-w64-mingw32-c++ -DCMAKE_RC_COMPILER=i686-w64-mingw32-windres -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY -DPYTHON_LIBRARY=/usr/i686-w64-mingw32/sys-root/mingw/bin/libpython2.7.dll -DPYTHON_INCLUDE_DIRS=/usr/i686-w64-mingw32/sys-root/mingw/include -UQT_QMAKE_EXECUTABLE -DQt5_DIR=/usr/i686-w64-mingw32/sys-root/mingw/lib/cmake/Qt5/ -DCMAKE_INSTALL_PREFIX:PATH=/usr/i686-w64-mingw32/sys-root/mingw .. ; \
    make -j$(nproc) install

#-DPythonQt_Wrap_QtAll=TRUE 

# Neutrino
RUN git clone https://github.com/NeutrinoToolkit/Neutrino.git ;                                                 \
    cd Neutrino && mkdir cross && cd cross ;                                                                    \
    cmake .. -DCMAKE_TOOLCHAIN_FILE=../resources/cmake/Toolchain-i686-mingw32.cmake && make -j$(nproc) package 


