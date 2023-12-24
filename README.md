# cmake-xc8

## Overview

CMake toolchain for PIC microcontroller (with XC8 C Compiler)

## Usage

You can use this toolchain by some ways:

 1. Configure project only for PIC (always use toolchain when build project)
 2. Configure project for cross-platform software (use toolchain only if build for PIC)

### Before you use...

This repository depends on [MPLAB X IDE](https://www.microchip.com/en-us/tools-resources/develop/mplab-x-ide) and [MPLAB XC8 Compiler](https://www.microchip.com/en-us/tools-resources/develop/mplab-xc-compilers).

### 1. Always use toolchain when build project

If you always want to use XC8 toolchain, please insert following lines into `CMakeLists.txt`.

**NOTE:** Please insert them before `project()` statement!

```cmake
# fetch and enable PIC XC8 toolchain
include(FetchContent)
FetchContent_Declare(
    xc8_toolchain
    GIT_REPOSITORY https://github.com/Enchan1207/cmake-xc8
    GIT_TAG v0.1.0
)
FetchContent_Populate(xc8_toolchain)
set(CMAKE_TOOLCHAIN_FILE "${xc8_toolchain_SOURCE_DIR}/cmake/xc8_toolchain.cmake")
```

### 2. Use toolchain only if build for PIC

If your project is developed as cross-platform software, add `--toolchain=` options to cmake when configure.

```
cmake .. --toolchain=/path/to/xc8_toolchain.cmake
```

It can be able to build your project for PIC without making any changes to `CMakeLists.txt`.

### Custom macros

This toolchain provides custom macros named `target_configure_for_pic()`. It can use like this:

```cmake
add_executable(main)
target_sources(main PRIVATE
    main.cpp
)

# If your project is not only for PIC,
# please check if BUILD_FOR_PIC is defined and its value is `true`
if(${BUILD_FOR_PIC})
    target_configure_for_pic(main)
endif()
```

This macro adds the following custom targets and commands to your target:

 - Flash target:  
   Custom target named `flash-{target_name}` for flashing.
   If you execute this target, built programms will be flashed to microcontroller by `ipecmd.jar` (command-line tool included in MPLAB IPE).

## Variables

You can specify some options to cmake-xc8. These can be checked and edited using ccmake, cmake-gui or command-line options.

 - Environment options:
    - `XC8_INSTALL_DIR`: **Optional**  
      Root path of XC8 compiler. If you installed XC8 to custom directory, you need to set this.
    - `MPLABX_INSTALL_DIR`: **Optional**  
      Root path of MPLAB X IDE. If you installed IPE to custom directory, you need to set this.
 - Compiler options:
    - `PIC_MCU`: **Required**  
      The identifier of target microcontroller.
    - `PIC_FCPU`: **Required**  
      The clock frequency of target microcontroller.
 - Programmer options:
    - `IPE_TOOL`: **Optional**  
      Flash tool identifier. If you want to use PICKit 3, specify `PPK3`.

## License

This repository is published under [MIT License](LICENSE).