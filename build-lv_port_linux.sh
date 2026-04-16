#!/bin/bash
set -e

PROJECT_ROOT=$(pwd)
ARM_SYSROOT="/home/leung/lvgl/git-clone/t113/arm-sysroot"
BUILD_DIR="$PROJECT_ROOT/build"
STAGE_DIR="$PROJECT_ROOT/build/install"

# 关键：给 pkg-config 的交叉编译环境
export PKG_CONFIG_SYSROOT_DIR="$ARM_SYSROOT"
export PKG_CONFIG_PATH="$ARM_SYSROOT/usr/lib/pkgconfig:$ARM_SYSROOT/usr/share/pkgconfig"
# 更稳：限制 pkg-config 优先只看 sysroot
export PKG_CONFIG_LIBDIR="$ARM_SYSROOT/usr/lib/pkgconfig:$ARM_SYSROOT/usr/share/pkgconfig"

rm -rf "$BUILD_DIR"

cmake -S "$PROJECT_ROOT" -B "$BUILD_DIR" \
  -DCMAKE_TOOLCHAIN_FILE="$PROJECT_ROOT/toolchain.cmake" \
  -DCMAKE_SYSTEM_NAME=Linux \
  -DCMAKE_C_COMPILER=arm-linux-gnueabi-gcc \
  -DCMAKE_CXX_COMPILER=arm-linux-gnueabi-g++ \
  -DCMAKE_C_COMPILER_WORKS=TRUE \
  -DCMAKE_CXX_COMPILER_WORKS=TRUE \
  -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
  -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
  -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
  -DCMAKE_PREFIX_PATH="$ARM_SYSROOT" \
  -DCMAKE_EXE_LINKER_FLAGS="-L$ARM_SYSROOT/usr/lib" \
  -DCMAKE_INSTALL_PREFIX="$STAGE_DIR"

cmake --build "$BUILD_DIR" -j8
cmake --install "$BUILD_DIR"
