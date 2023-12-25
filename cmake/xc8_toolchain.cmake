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

# MPLAB Platformを探す
if(NOT DEFINED MPLAB_PLATFORM_FOUND OR $MPLAB_PLATFORM_FOUND EQUAL 0)
    message(NOTICE "Looking for MPLAB Platform...")
    include(${CMAKE_CURRENT_LIST_DIR}/find_mplabplatform.cmake)
endif()

if($MPLAB_PLATFORM_FOUND EQUAL 0)
    message(FATAL_ERROR "Failed to identify MPLAB Platform!")
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
set(PIC_MCU "${PIC_MCU}" CACHE STRING "Target microcontroller identifier (required)")
set(PIC_FCPU "${PIC_FCPU}" CACHE STRING "Target microcontroller clock frequency (required)")
set(CMAKE_C_FLAGS "-D_XTAL_FREQ=${PIC_FCPU} -std=c99 -mcpu=${PIC_MCU} ${OPTIMIZATION_FLAGS}")

#
# プログラマの設定
#
set(IPE_TOOL "${IPE_TOOL}" CACHE STRING "The name of tool used for flashing (optional)")
set(MDB_TOOL "${MDB_TOOL}" CACHE STRING "The name of tool used for debugging (optional)")

#
# 書込み+デバッグターゲットの追加
#

# 書き込みターゲットを追加するマクロを定義
include(${CMAKE_CURRENT_LIST_DIR}/configure_flash_macro.cmake)

# MDB_TOOLが指定されていれば、単純にデバッグセッションを開くターゲットを追加する
if(NOT WIN32 AND MDB_TOOL)
    # デバッガのブートストラップファイルを作成
    set(DEBUG_BOOTSTRAP_PATH "${CMAKE_CURRENT_BINARY_DIR}/debugger_bootstrap.txt")
    if(NOT EXISTS ${DEBUG_BOOTSTRAP_PATH})
        file(
            WRITE ${DEBUG_BOOTSTRAP_PATH} 
            "device PIC${PIC_MCU}\n"
            "hwtool ${MDB_TOOL}\n"
            "reset MCLR\n"
        )
    endif()

    # デバッグターゲットを追加
    if(NOT TARGET debug)
        add_custom_target(debug
            COMMAND ${MDB_ROOT}/mdb.sh ${DEBUG_BOOTSTRAP_PATH}
            USES_TERMINAL
        )
    endif()
endif()
