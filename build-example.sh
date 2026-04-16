#!/bin/bash
set -e

PROJECT_ROOT=$(pwd)
ARM_SYSROOT="/home/leung/lvgl/git-clone/t113/arm-sysroot"
EXAMPLE_BUILD_DIR="$PROJECT_ROOT/example/build"
STAGE_DIR="$PROJECT_ROOT/build/install"

rm -rf "$EXAMPLE_BUILD_DIR"

cmake -S "$PROJECT_ROOT/example" -B "$EXAMPLE_BUILD_DIR" \
  -DCMAKE_TOOLCHAIN_FILE="$PROJECT_ROOT/toolchain.cmake" \
  -DCMAKE_SYSTEM_NAME=Linux \
  -DCMAKE_C_COMPILER=arm-linux-gnueabi-gcc \
  -DCMAKE_CXX_COMPILER=arm-linux-gnueabi-g++ \
  -DCMAKE_PREFIX_PATH="$STAGE_DIR" \
  -Dlv_port_linux_DIR="$STAGE_DIR/lib/cmake/lv_port_linux"

cmake --build "$EXAMPLE_BUILD_DIR" -j4
