
# 工具链

修改 toolchain.cmake 路径
```
set(tools "/home/leung/lvgl/git-clone/t113/toolchain/gcc-linaro-5.3.1-2016.05-x86_64_arm-linux-gnueabi")
```

# 准备好 libevdev

```bash
tree ../arm-sysroot/
../arm-sysroot/
└── usr
    ├── include
    │   └── libevdev-1.0
    │       └── libevdev
    │           ├── libevdev.h
    │           └── libevdev-uinput.h
    └── lib
        ├── libevdev.la
        ├── libevdev.so -> libevdev.so.2.2.0
        ├── libevdev.so.2 -> libevdev.so.2.2.0
        ├── libevdev.so.2.2.0
        └── pkgconfig
            └── libevdev.pc

7 directories, 7 files
```

# 编译

```bash

# 编译库
./build-lv_port_linux.sh 

ls build/install/lib/
cmake  liblvgl.a  liblvgl_demos.a  liblvgl_examples.a  liblvgl_linux.a  liblvgl_thorvg.a

ls build/bin/
lvglsim

# 编译第三方应用项目
./build-example.sh        

ls example/build/main 
example/build/main
```
---

# 详细说明

本文说明如何在 ARM 交叉编译环境下：

1. 编译并安装 `lv_port_linux`
2. 将 `lv_port_linux` 作为外部 package 提供给下游 LVGL 应用工程使用
3. 编译第三方应用示例 `example`

本文的重点不是“仓库内 demo 怎么临时编过”，而是把 `lv_port_linux` 作为一个**可安装、可复用、可被外部工程消费**的上游包来使用。

---

## 工具链

请先修改 `toolchain.cmake` 中工具链路径：

```cmake
set(tools "/home/leung/lvgl/git-clone/t113/toolchain/gcc-linaro-5.3.1-2016.05-x86_64_arm-linux-gnueabi")
````

---

## sysroot 准备

需要提前准备好 `libevdev`，并放入交叉编译 sysroot。

示例目录结构如下：

```bash
tree ../arm-sysroot/
../arm-sysroot/
└── usr
    ├── include
    │   └── libevdev-1.0
    │       └── libevdev
    │           ├── libevdev.h
    │           └── libevdev-uinput.h
    └── lib
        ├── libevdev.la
        ├── libevdev.so -> libevdev.so.2.2.0
        ├── libevdev.so.2 -> libevdev.so.2.2.0
        ├── libevdev.so.2.2.0
        └── pkgconfig
            └── libevdev.pc

7 directories, 7 files
```

至少需要保证以下内容存在：

* `../arm-sysroot/usr/include/libevdev-1.0/...`
* `../arm-sysroot/usr/lib/libevdev.so` 或对应静态库
* `../arm-sysroot/usr/lib/pkgconfig/libevdev.pc`

---

## 构建目标说明

本仓库现在分成两个层次：

### 1. 上游库：`lv_port_linux`

负责：

* 构建 `lvgl`
* 构建 `lvgl_linux`
* 安装头文件
* 安装 `lv_port_linux` 的 CMake package
* 提供给下游工程 `find_package(lv_port_linux CONFIG REQUIRED)` 使用

### 2. 下游应用示例：`example`

`example` 不再视为“仓库内部随便引用源码路径的 demo”，而是视为：

**安装后的外部应用验证工程**

即它通过：

```cmake
find_package(lv_port_linux CONFIG REQUIRED)
```

来消费安装后的 `lv_port_linux` 包。

---

## 目录和产物说明

### 主工程目录

* `build/`

  * `lv_port_linux` 主工程构建目录

* `build/install/`

  * `lv_port_linux` 安装产物目录
  * 提供给下游 `find_package(lv_port_linux CONFIG REQUIRED)` 使用

### 示例工程目录

* `example/build/`

  * 第三方应用示例构建目录
  * 用于验证安装后的 package 是否能被外部工程正确消费

### 关键产物

编译完成后，常见产物如下：

```bash
ls build/install/lib/
cmake  liblvgl.a  liblvgl_demos.a  liblvgl_examples.a  liblvgl_linux.a  liblvgl_thorvg.a
```

说明：

* `liblvgl.a`

  * LVGL core

* `liblvgl_linux.a`

  * Linux port backend

* `liblvgl_demos.a`

  * demos 组件（是否存在取决于配置）

* `liblvgl_examples.a`

  * examples 组件（是否存在取决于配置）

* `liblvgl_thorvg.a`

  * thorvg 组件（是否存在取决于配置）

* `build/install/lib/cmake/lv_port_linux/`

  * 提供给下游工程使用的 CMake package

主工程内置程序：

```bash
ls build/bin/
lvglsim
```

第三方示例应用：

```bash
ls example/build/main
example/build/main
```

---

## 可选组件说明

安装目录下的以下库是否存在，取决于当前 LVGL / lv_port_linux 配置：

* `liblvgl_demos.a`
* `liblvgl_examples.a`
* `liblvgl_thorvg.a`

因此下游工程不应假设这些组件一定存在，而应：

* 使用 `find_package(lv_port_linux CONFIG REQUIRED COMPONENTS demos)`
* 或使用 `OPTIONAL_COMPONENTS`
* 或判断 target 是否存在，例如：

```cmake
if(TARGET lv_port_linux::demos)
    target_link_libraries(my_app PRIVATE lv_port_linux::demos)
endif()
```

当前 package 设计分为：

### 稳定核心

* `lv_port_linux::lvgl`
* `lv_port_linux::lvgl_linux`
* `lv_port_linux::sdk_core`

其中：

* `sdk_core` 用于普通 Linux LVGL 应用
* 不自动把 demos/examples/thorvg 一股脑全部拉进来

### 可选组件

* `lv_port_linux::demos`
* `lv_port_linux::examples`
* `lv_port_linux::thorvg`

由下游按需显式链接。

---

## 编译 lv_port_linux

执行：

```bash
./build-lv_port_linux.sh
```

编译完成后可检查：

```bash
ls build/install/lib/
cmake  liblvgl.a  liblvgl_demos.a  liblvgl_examples.a  liblvgl_linux.a  liblvgl_thorvg.a

ls build/bin/
lvglsim
```

---

## 编译第三方应用项目

执行：

```bash
./build-example.sh
```

编译完成后可检查：

```bash
ls example/build/main
example/build/main
```

注意：

* `example` 是“安装后外部应用验证工程”
* 它会单独有自己的 `example/build/`
* 这是正常现象，不表示重复编译了主工程

---

## 下游应用 CMake 用法

### 仅使用核心能力

适用于普通应用，不使用 demos/examples/thorvg：

```cmake
cmake_minimum_required(VERSION 3.16)
project(my_lvgl_app C CXX)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(my_lvgl_app main.c)

find_package(lv_port_linux CONFIG REQUIRED)

target_link_libraries(my_lvgl_app PRIVATE lv_port_linux::sdk_core)

set_target_properties(my_lvgl_app PROPERTIES
    LINKER_LANGUAGE CXX
)
```

### 使用 demos

如果应用中调用了：

* `lv_demo_widgets()`
* `lv_demo_widgets_start_slideshow()`
* 其他 demo API

则应这样写：

```cmake
cmake_minimum_required(VERSION 3.16)
project(my_lvgl_demo_app C CXX)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(my_lvgl_demo_app main.c)

find_package(lv_port_linux CONFIG REQUIRED COMPONENTS demos)

target_link_libraries(my_lvgl_demo_app PRIVATE
    lv_port_linux::sdk_core
    lv_port_linux::demos
)

set_target_properties(my_lvgl_demo_app PROPERTIES
    LINKER_LANGUAGE CXX
)
```

### demos / examples / thorvg 可选使用

```cmake
find_package(lv_port_linux CONFIG REQUIRED OPTIONAL_COMPONENTS demos examples thorvg)

target_link_libraries(my_app PRIVATE lv_port_linux::sdk_core)

if(TARGET lv_port_linux::demos)
    target_link_libraries(my_app PRIVATE lv_port_linux::demos)
endif()

if(TARGET lv_port_linux::examples)
    target_link_libraries(my_app PRIVATE lv_port_linux::examples)
endif()

if(TARGET lv_port_linux::thorvg)
    target_link_libraries(my_app PRIVATE lv_port_linux::thorvg)
endif()
```

---

## 头文件包含约定

建议下游统一使用以下风格：

```c
#include <lvgl/lvgl.h>
#include <lvgl/driver_backends.h>
#include <lvgl/simulator_settings.h>
```

如果使用 demos：

```c
#include <lvgl/demos/lv_demos.h>
```

不要混用：

* `<lvgl.h>`
* `<lvgl/...>`

否则容易和安装后的 include 路径规则冲突。

---

## 示例应用说明

当前 `example/main.c` 若使用了 demos，则其 `example/CMakeLists.txt` 应类似如下：

```cmake
cmake_minimum_required(VERSION 3.16)
project(lvgl_example C CXX)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(main main.c)

find_package(lv_port_linux CONFIG REQUIRED COMPONENTS demos)

target_link_libraries(main PRIVATE
    lv_port_linux::sdk_core
    lv_port_linux::demos
)

set_target_properties(main PROPERTIES
    LINKER_LANGUAGE CXX
)

add_custom_target(run
    COMMAND $<TARGET_FILE:main>
    DEPENDS main
)
```

---

## 常见问题

### 1）配置时报 `Package 'libevdev' not found`

请确认：

* `../arm-sysroot/usr/lib/pkgconfig/libevdev.pc` 存在
* `../arm-sysroot/usr/include/libevdev-1.0/...` 存在

并确保构建脚本设置了：

```bash
export PKG_CONFIG_SYSROOT_DIR=...
export PKG_CONFIG_PATH=...
export PKG_CONFIG_LIBDIR=...
```

---

### 2）链接时报 `cannot find -levdev`

通常是下游 example 构建时没有正确继承 sysroot 的 `pkg-config` / linker 环境。

请检查：

* `build-example.sh` 是否设置了 `PKG_CONFIG_*`
* 是否传入了正确的 `CMAKE_PREFIX_PATH`
* sysroot 中是否确实存在 `libevdev.so` / `libevdev.a`

---

### 3）报 `lv_conf.h` 或 `#include expects "FILENAME"` 相关错误

请确认：

* 使用的是安装后的 `lv_port_linuxConfig.cmake`
* package config 中传递的是 `LV_CONF_INCLUDE_SIMPLE=1`
* 已删除旧的 `build/` 和 `example/build/` 后重新构建

---

### 4）出现 `__gxx_personality_v0`、`__cxa_end_cleanup`、`operator delete` 等错误

这说明当前 `liblvgl.a` 中包含了 ThorVG 的 C++ 对象文件。

下游工程需要：

* 启用 `CXX`
* 使用 C++ linker
* 或通过 `lv_port_linux::sdk_core` / 组件 target 自动继承 `stdc++`

---

### 5）`find_package(lv_port_linux CONFIG REQUIRED COMPONENTS demos)` 报 NOT FOUND

请确认：

* 安装目录中确实存在 `liblvgl_demos.a`
* `build/install/lib/cmake/lv_port_linux/lv_port_linuxConfig.cmake` 为最新重新生成版本
* 修改过 package config 后，已删除旧的 `build/` 和 `example/build/` 重新编译

---

## 什么时候需要全量重编

以下情况建议删除 `build/` 和 `example/build/` 后重新构建：

* 修改了 `lv_conf.defaults`
* 修改了顶层 `CMakeLists.txt`
* 修改了 `cmake/lv_port_linuxConfig.cmake.in`
* 修改了 `toolchain.cmake`
* 修改了 sysroot 中的依赖库
* 组件导出逻辑发生变化（如 demos/examples/thorvg）
* 改变了安装前缀或 package 查找路径

建议执行：

```bash
rm -rf build example/build
./build-lv_port_linux.sh
./build-example.sh
```

---

## 运行说明

* `build/bin/lvglsim`

  * 为 `lv_port_linux` 主工程内置程序
  * 适合在目标 Linux 图形/输入环境中验证 backend

* `example/build/main`

  * 为第三方应用示例
  * 用于验证安装后的 `lv_port_linux` package 是否可被外部工程消费

注意：

* 交叉编译出来的 ARM 程序不能直接在 x86 主机运行
* 需要拷贝到目标板运行
* 若目标板缺少对应动态库，请检查 rootfs / sysroot 一致性

---

## 设计说明

本项目不再将 `example/` 视为仓库内部直接引用源码路径的 demo，而是将其视为：

**安装后外部应用工程的验证样例**

目标是让 `lv_port_linux` 作为上游 package 被独立应用工程通过：

```cmake
find_package(lv_port_linux CONFIG REQUIRED)
```

的方式使用，而不是依赖仓库内部的源码路径、构建目录或硬编码链接参数。

因此 package 设计采用：

* `sdk_core`：稳定核心能力
* `demos/examples/thorvg`：可选组件 target

这样可同时满足：

* 上游构建产物会因配置变化而变化
* 下游应用需求也不固定

---

## 当前推荐使用顺序

```bash
# 1. 编译并安装 lv_port_linux
./build-lv_port_linux.sh

# 2. 编译外部应用验证工程
./build-example.sh

# 3. 查看产物
ls build/install/lib/
ls build/bin/
ls example/build/main
```

