#!/bin/bash


rm -fr source
rm -fr build
mkdir source
mkdir build
cd source
git clone git://github.com/xbmc/xbmc.git .
cp ../patches/*.patch ./
git checkout 16.0b1-Jarvis
git apply *.patch
cd tools/depends

# prepare dependencies for compilinig
./bootstrap; ./configure --prefix=$KODI_BUILD_PATH --build=x86_64-linux-gnu --host=aarch64-linux-gnu LDFLAGS="-L$KODI_BUILD_PATH/x86_64-linux-gnu-native/lib -L$CHROOT_PATH/usr/lib/aarch64-linux-gnu -L$CHROOT_PATH/usr/lib -L$CHROOT_PATH/lib -L$CHROOT_PATH/lib/aarch64-linux-gnu" PKG_CONFIG_PATH="$CHROOT_PATH/usr/share/pkgconfig:$CHROOT_PATH/usr/lib/aarch64-linux-gnu/pkgconfig/:$CHROOT_PATH/usr/lib/pkgconfig/:$KODI_BUILD_PATH/x86_64-linux-gnu-native/lib/pkgconfig:$KODI_BUILD_PATH/aarch64-linux-gnu/lib/pkgconfig"

# compile dependencies
cd ../../
make -C tools/depends/native
make -C tools/depends/target/libuuid
make -C tools/depends/target/crossguid
make -C tools/depends/target/libdcadec
make -C tools/depends/target/gmp
make -C tools/depends/target/nettle
make -C tools/depends/target/gnutls
make -C tools/depends/target/libogg
make -C tools/depends/target/libvorbis
make -C tools/depends/target/libsquish
make -C tools/depends/target/ffmpeg

# prepare kodi for compilinig
./bootstrap; ./configure --with-sysroot=$CHROOT_PATH --prefix=$KODI_BUILD_PATH/aarch64-linux-gnu -build=x86_64-linux-gnu --host=aarch64-linux-gnu --disable-vaapi --disable-vdpau CFLAGS="-Os -fPIC -DPIC -D_DEBUG -D_REENTRANT -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -I$CHROOT_PATH/usr/include -I$CHROOT_PATH/usr/include/aarch64-linux-gnu -I$CHROOT_PATH/usr/lib -I$CHROOT_PATH/usr/lib/aarch64-linux-gnu -I$CHROOT_PATH/lib -I$CHROOT_PATH/lib/aarch64-linux-gnu -I$KODI_BUILD_PATH/aarch64-linux-gnu/include -I$CHROOT_PATH/usr/lib/aarch64-linux-gnu/dbus-1.0/include -I$CHROOT_PATH/usr/include/freetype2" CXXFLAGS="-Os -fPIC -DPIC -D_DEBUG -D_REENTRANT -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -I$CHROOT_PATH/usr/include -I$CHROOT_PATH/usr/include/aarch64-linux-gnu -I$CHROOT_PATH/usr/lib -I$CHROOT_PATH/usr/lib/aarch64-linux-gnu -I$CHROOT_PATH/lib -I$CHROOT_PATH/lib/aarch64-linux-gnu -I$KODI_BUILD_PATH/aarch64-linux-gnu/include -I$CHROOT_PATH/usr/lib/aarch64-linux-gnu/dbus-1.0/include -I$CHROOT_PATH/usr/include/freetype2" LDFLAGS="-L$CHROOT_PATH/usr/lib/aarch64-linux-gnu -L$CHROOT_PATH/usr/lib -L$CHROOT_PATH/lib -L$CHROOT_PATH/lib/aarch64-linux-gnu" PKG_CONFIG_PATH="$CHROOT_PATH/usr/share/pkgconfig:$CHROOT_PATH/usr/lib/aarch64-linux-gnu/pkgconfig/:$CHROOT_PATH/usr/lib/pkgconfig/" FFMPEG_CFLAGS="-I$KODI_BUILD_PATH/aarch64-linux-gnu/include" FFMPEG_LIBS="-L$KODI_BUILD_PATH/aarch64-linux-gnu/lib" FFMPEG_LIBDIR="$KODI_BUILD_PATH/aarch64-linux-gnu/lib"

# compile and install kodi
make
make install DESTDIR=$KODI_INSTALL_DIR/ libdir=lib bindir=bin datarootdir=share includedir=include

