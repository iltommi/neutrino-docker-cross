FROM fedora:latest

RUN dnf -y update && dnf -y install cmake git mingw32-qt5* mingw32-gcc-c++ mingw32-gcc mingw32-gcc-gfortran mingw32-libgomp mingw32-gsl mingw32-zlib mingw32-nsis unzip wget autoconf automake bash bison bzip2 flex gcc-c++ gdk-pixbuf2-devel gettext git gperf intltool make sed libffi-devel libtool openssl-devel p7zip patch perl pkgconfig python ruby scons unzip wget xz gtk-doc dh-autoreconf mingw32-portablexdr pandoc

# pyhton 
RUN dnf -y install 'dnf-command(copr)';    \
    dnf -y copr enable smani/mingw-extras; \
    dnf -y update;                         \
    dnf -y install mingw32-python2 mingw32-cfitsio

#fftw
RUN /bin/bash -c ' mkdir fftw3 && cd fftw3;\
    wget http://www.fftw.org/fftw-3.3.6-pl2.tar.gz;\
    tar -zxvf fftw-3.3.6-pl2.tar.gz; \
    cd fftw-3.3.6-pl2; \
    ./configure --host='i686-w64-mingw32' --build='x86_64-unknown-linux-gnu' --prefix='/usr/i686-w64-mingw32/sys-root/mingw' --disable-static --enable-shared  ac_cv_prog_HAVE_DOXYGEN="false" --enable-threads --with-combined-threads ; \
    make -j $(nproc) bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=    ;\
    make install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=   '
    
#hdf4
RUN wget https://support.hdfgroup.org/ftp/HDF/releases/HDF4.2.10/src/hdf-4.2.10.tar.bz2 && tar -jxvf hdf-4.2.10.tar.bz2; \
    cd hdf-4.2.10; \
    wget https://raw.githubusercontent.com/iltommi/mxe/master/src/hdf4-1-portability-fixes.patch; \
    wget https://raw.githubusercontent.com/iltommi/mxe/master/src/hdf4-2-dllimport.patch; \
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

# hdf5
# RUN wget https://support.hdfgroup.org/ftp/HDF5/prev-releases/hdf5-1.8/hdf5-1.8.12/src/hdf5-1.8.12.tar.gz; \
#     tar -zxvf hdf5-1.8.12.tar.gz; \
#     cd hdf5-1.8.12; \
#     wget https://raw.githubusercontent.com/iltommi/mxe/master/src/hdf5-1-disable-configure-try-run.patch; \
#     wget https://raw.githubusercontent.com/iltommi/mxe/master/src/hdf5-2-platform-detection.patch; \
#     wget https://raw.githubusercontent.com/iltommi/mxe/master/src/hdf5-3-fix-autoconf-version.patch; \
#     patch -p1 -u < hdf5-1-disable-configure-try-run.patch; \
#     patch -p1 -u < hdf5-2-platform-detection.patch; \
#     patch -p1 -u < hdf5-3-fix-autoconf-version.patch; \
#     autoreconf --force --install; \
#     ./configure --host='i686-w64-mingw32' --build='x86_64-unknown-linux-gnu' --prefix='/usr/i686-w64-mingw32/sys-root/mingw' --disable-static --enable-shared  ac_cv_prog_HAVE_DOXYGEN="false" --disable-doxygen --enable-cxx --disable-direct-vfd  CPPFLAGS='-DH5_HAVE_WIN32_API -DH5_HAVE_MINGW -DHAVE_WINDOWS_PATH -DH5_BUILT_AS_DYNAMIC_LIB'; \
#     sed -i 's,allow_undefined_flag="unsupported",allow_undefined_flag="",g' 'libtool'; \
#     for f in H5detect.exe H5make_libsettings.exe libhdf5.settings; do make -C src $f && install -m755 src/$f /usr/i686-w64-mingw32/sys-root/mingw/bin/; done; \
#     
    
        

# pyhthonqt
RUN git clone https://github.com/iltommi/PythonQt.git && cd PythonQt && mkdir cross && cd cross; \
    cmake -DCMAKE_SYSTEM_NAME=Windows -DCMAKE_FIND_ROOT_PATH=/usr/i686-w64-mingw32 -DCMAKE_C_COMPILER=i686-w64-mingw32-gcc -DCMAKE_CXX_COMPILER=i686-w64-mingw32-c++ -DCMAKE_RC_COMPILER=i686-w64-mingw32-windres -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY -DPYTHON_LIBRARY=/usr/i686-w64-mingw32/sys-root/mingw/bin/libpython2.7.dll -DPYTHON_INCLUDE_DIRS=/usr/i686-w64-mingw32/sys-root/mingw/include -UQT_QMAKE_EXECUTABLE -DQt5_DIR=/usr/i686-w64-mingw32/sys-root/mingw/lib/cmake/Qt5/ -DCMAKE_INSTALL_PREFIX:PATH=/usr/i686-w64-mingw32/sys-root/mingw .. ; \
    make -j$(nproc) install

#-DPythonQt_Wrap_QtAll=TRUE 

# Neutrino
RUN git clone https://github.com/NeutrinoToolkit/Neutrino.git ;                                                 \
    cd Neutrino && mkdir cross && cd cross ;                                                                    \
    cmake .. -DCMAKE_TOOLCHAIN_FILE=../resources/cmake/Toolchain-i686-mingw32.cmake && make -j$(nproc) package 


