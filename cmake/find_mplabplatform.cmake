#
# IPEとデバッガを探す
#
# 発見できた場合は #MPLAB_PLATFORM_FOUND に1が、$IPE_ROOT にIPEへのルートパスが、$MDB_ROOTにmdbへのルートパスが代入されます。
#
cmake_minimum_required(VERSION 3.10)

set(MPLAB_PLATFORM_FOUND 0)
set(MPLABX_INSTALL_DIR "" CACHE PATH "Path to root of IPE (optional)")

# OSごとにインストール先が異なるので、指定がなければ自動で決定する
if(NOT MPLABX_INSTALL_DIR)
    if(DEFINED ENV{MPLABX_INSTALL_DIR})
        set(MPLABX_INSTALL_DIR "$ENV{MPLABX_INSTALL_DIR}")
    else()
        if(APPLE)
            set(MPLABX_INSTALL_DIR "/Applications/microchip/mplabx")
        elseif(UNIX)
            set(MPLABX_INSTALL_DIR "/opt/microchip/mplabx")
        else()
            set(MPLABX_INSTALL_DIR "C:/Program Files/Microchip/mplab_ide")
        endif()
    endif()
endif()

if(NOT EXISTS ${MPLABX_INSTALL_DIR})
    message(WARNING "MPLAB X IDE not found. Please check whether it was successfully installed.")
    return()
endif()

# 最新版を取得
file(GLOB IPE_VARIANTS ${MPLABX_INSTALL_DIR}/v*)
list(SORT IPE_VARIANTS ORDER DESCENDING)
list(GET IPE_VARIANTS 0 MPLABX_ROOT)
set(IPE_ROOT ${MPLABX_ROOT}/mplab_platform/mplab_ipe)
set(MDB_ROOT ${MPLABX_ROOT}/mplab_platform/bin)

if(NOT EXISTS ${IPE_ROOT})
    message(WARNING "No any available IPE variants found.")
    message(WARNING "The toolchain expects it to be placed at ${IPE_ROOT}")
    return()
endif()

if(NOT EXISTS ${MDB_ROOT})
    message(WARNING "No any available mdb variants found.")
    message(WARNING "The toolchain expects it to be placed at ${MDB_ROOT}")
    return()
endif()

message(NOTICE "MPLAB IPE: ${IPE_ROOT}")
message(NOTICE "MPLAB Plaform binaries: ${MDB_ROOT}")

set(MPLAB_PLATFORM_FOUND 1)
