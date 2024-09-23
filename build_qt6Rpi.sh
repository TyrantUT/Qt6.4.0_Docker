#!/bin/bash

# vim: tabstop=4 shiftwidth=4 softtabstop=4
# -*- sh-basic-offset: 4 -*-

set -exuo pipefail

BUILD_TARGET=/build/qt6_host
SRC=/src
QT_BRANCH="6.7.2"
DEBIAN_VERSION=$(lsb_release -cs)
MAKE_CORES="$(expr $(nproc))"
BUILD_TARGET_PI=/build/qt6_rpi
INSTALL_PREFIX=/opt/qt6pi
QT_HOST_PATH=/opt/qt6

mkdir -p "$BUILD_TARGET_PI"

/usr/games/cowsay -f tux "Building QT version $QT_BRANCH."

function build_qtpi () {

    local SRC_DIR="/src/qt6pi"
    mkdir -p "$SRC_DIR"
    pushd "$BUILD_TARGET_PI"

    "$SRC"/qt6/configure \
        -confirm-license \
        -release \
        -qpa eglfs \
        -opengl es2 \
        -eglfs \
        -no-cups \
        -nomake tests \
        -qt-host-path $QT_HOST_PATH \
        -extprefix $SRC_DIR \
        -prefix $INSTALL_PREFIX \
        -nomake examples \
        -pkg-config \
        -qt-pcre \
        -no-pch \
        -evdev \
        -fontconfig \
        -glib \
        -shared \
        -no-dbus \
        -no-cups \
        -no-gtk \
        -no-use-gold-linker \
        -opensource \
        -skip qttranslations \
        -skip qtdoc \
        -skip qttools \
        -skip qtwebengine \
        -skip qtwebview \
        -skip qtsensors \
        -skip qtvirtualkeyboard \
        -skip qtwebchannel \
        -skip qtspeech \
        -skip qtsql \
        -skip qtdbus \
        -skip qtxml \
        -skip qtjpeg \
        -skip qtlanguageserver \
        -skip qtwebsockets \
        -skip qthttpserver \
        -skip qtserialport \
        -skip qtpositioning \
        -skip qtlocation \
        -skip qtlottie \
        -skip qtmqtt \
        -skip qtremoteobjects \
        -skip qtserialbus \
        -skip qtsvg \
        -skip qtwayland \
        -skip qtcoap \
        -skip qt5compat \
        -skip qtconnectivity \
        -skip qtrpc \
        -skip qtimageformats \
        -skip qtopcua \
        -skip qtnetworkauth \
        -skip qtactiveqt \
        -skip qtgrpc \
        -skip qtscxml \
        -device linux-rasp-pi4-v3d-g++ \
        -device-option CROSS_COMPILE=aarch64-linux-gnu- \
        -- -DCMAKE_TOOLCHAIN_FILE=/build/toolchain.cmake \
        -DQT_FEATURE_xcb=ON \
        -DFEATURE_xcb_xlib=ON \
        -DQT_FEATURE_xlib=ON \
        -DQT_BUILD_EXAMPLES=FALSE \
        -DQT_BUILD_TESTS=FALSE \
        -DQT_DEBUG_FIND_PACKAGE=ON \
        -DQT_FEATURE_egl=ON \
        -DQT_FEATURE_opengl=ON \
        -DQT_FEATURE_opengles2=ON \
        -DQT_FEATURE_opengl_desktop=OFF \
        -DQT_FEATURE_opengl_dynamic=OFF \
        -DQT_HOST_PATH=$QT_HOST_PATH


    /usr/games/cowsay -f tux "Making QT Pi version $QT_BRANCH."
    cmake --build . --parallel "$MAKE_CORES"

    /usr/games/cowsay -f tux "Installing QT Pi version $QT_BRANCH."
    cmake --install .
    popd

    pushd "$SRC_DIR"
    tar cfz "$BUILD_TARGET_PI/qt5-$QT_BRANCH-$DEBIAN_VERSION-$1.tar.gz" qt6pi
    popd

    pushd "$BUILD_TARGET_PI"
    sha256sum "qt5-$QT_BRANCH-$DEBIAN_VERSION-$1.tar.gz" > "qt5-$QT_BRANCH-$DEBIAN_VERSION-$1.tar.gz.sha256"
    popd
}

build_qtpi
