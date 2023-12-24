#
# CMake XC8 toolchain with MPLAB X IDE
#
# 2023 @Enchan1207
#
cmake_minimum_required(VERSION 3.10)
set(BUILD_FOR_PIC TRUE)

#
# アプリケーションの検索
#

# XC8を探す
if(NOT DEFINED XC8_FOUND OR $XC8_FOUND EQUAL 0)
    message(NOTICE "Looking for XC8 compiler...")
    include(${CMAKE_CURRENT_LIST_DIR}/find_xc8.cmake)
endif()

if($XC8_FOUND EQUAL 0)
    message(FATAL_ERROR "Failed to identify XC8 compiler!")
endif()

# IPEを探す
if(NOT DEFINED IPE_FOUND OR $IPE_FOUND EQUAL 0)
    message(NOTICE "Looking for MPLAB IPE...")
    include(${CMAKE_CURRENT_LIST_DIR}/find_ipe.cmake)
endif()

if($IPE_FOUND EQUAL 0)
    message(FATAL_ERROR "Failed to identify MPLAB IPE!")
endif()

#
# コンパイラの設定
#

# PIC向けのクロスコンパイルであることを明示
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR pic)
set(CMAKE_CROSSCOMPILING 1)

# コマンドのパスを設定
set(CMAKE_C_COMPILER "${XC8_ROOT}/bin/xc8-cc" CACHE PATH "c compiler" FORCE)
set(CMAKE_AR "${XC8_ROOT}/bin/xc8-ar" CACHE PATH "ar" FORCE)

# CMake内部のテストを回避するため、"コンパイラは問題なく動いている"ということにする
# (CMakeはXC8をサポートしていない)
set(CMAKE_C_COMPILER_ID_RUN TRUE)
set(CMAKE_C_COMPILER_FORCED TRUE)
set(CMAKE_C_COMPILER_WORKS TRUE)

# Makefileルールを上書き
set(CMAKE_USER_MAKE_RULES_OVERRIDE ${CMAKE_CURRENT_LIST_DIR}/cflags-override.cmake)

#
# コンパイル設定
#

# include, libディレクトリにXC8のそれを追加 (xc.h等にアクセスするため)
include_directories(
    ${XC8_ROOT}/pic/include
    ${XC8_ROOT}/pic/include/c99
    ${XC8_ROOT}/pic/include/proc
)
link_directories(${XC8_ROOT}/pic/lib)

# defineを追加 (コンパイル時に自動で追加されるが、VSCodeの補完を効かせるために必要)
add_compile_definitions(
    "__XC8"
    "__PICC__"
    "_${PIC_MCU}"
)

# 最適化フラグの構成 リリースビルドでは -Os を使いたかったが、XC8では使えない(ライセンス?)
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(OPTIMIZATION_FLAGS "-O2")
else()
    set(OPTIMIZATION_FLAGS "-Og")
endif()

# コンパイルフラグを構成
set(PIC_MCU "" CACHE STRING "Target microcontroller identifier (required)")
set(PIC_FCPU 0 CACHE STRING "Target microcontroller clock frequency (required)")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D_XTAL_FREQ=${PIC_FCPU} -std=c99 -mcpu=${PIC_MCU} ${OPTIMIZATION_FLAGS}")

#
# プログラマの設定
#
set(IPE_TOOL "" CACHE STRING "The name of tool used for flashing (optional)")

#
# カスタムターゲットの追加
#
macro(target_configure_for_pic target_name)
    # ターゲットが実行可能かを調べる
    get_target_property(target_type ${target_name} TYPE)

    if(target_type STREQUAL "EXECUTABLE")
        set(${target_name}_IS_EXECUTABLE TRUE)
    else()
        set(${target_name}_IS_EXECUTABLE FALSE)
    endif()

    if(${target_name}_IS_EXECUTABLE)
        if(IPE_TOOL)
            # フラッシュターゲットを追加
            add_custom_target(flash-${target_name}
                COMMAND java -jar ${IPE_ROOT} -P${PIC_MCU} -T${IPE_TOOL} -I -M -F"${target_name}.hex"
                DEPENDS ${target_name}
            )
        else()
            message(WARNING "IPE_TOOL not specified. IF you want to add flash target, please specify it.")
        endif()
    endif()
endmacro()
