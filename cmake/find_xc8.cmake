#
# XC8を探す
#
# 発見できた場合は #XC8_FOUND に1が、$XC8_ROOT にXC8へのルートパスが代入されます。
#
cmake_minimum_required(VERSION 3.10)

set(XC8_FOUND 0)
set(XC8_INSTALL_DIR "" CACHE PATH "Path to root of XC8 compiler (optional)")

# OSごとにインストール先が異なるので、指定がなければ自動で決定する
if(NOT XC8_INSTALL_DIR)
    if(DEFINED ENV{XC8_INSTALL_DIR})
        set(XC8_INSTALL_DIR "$ENV{XC8_INSTALL_DIR}")
    else()
        if(APPLE)
            set(XC8_INSTALL_DIR "/Applications/microchip/xc8")
        elseif(UNIX)
            set(XC8_INSTALL_DIR "/opt/microchip/xc8")
        else()
            set(XC8_INSTALL_DIR "C:/Program Files/Microchip/xc8")
        endif()
    endif()
endif()

if(NOT EXISTS ${XC8_INSTALL_DIR})
    message(WARNING "XC8 not found. Please check whether it was successfully installed.")
    return()
endif()

# 最新版を取得
file(GLOB XC8_VARIANTS ${XC8_INSTALL_DIR}/v*)
list(SORT XC8_VARIANTS ORDER DESCENDING)
list(GET XC8_VARIANTS 0 XC8_ROOT)

if(NOT XC8_ROOT)
    message(WARNING "No any available XC8 variants found.")
    return()
endif()

# ccコマンドを取得
set(xc8_cc "${XC8_ROOT}/bin/xc8-cc")

if(NOT EXISTS ${xc8_cc})
    message(WARNING "Command xc8-cc not found. Install may be broken.")
    return()
endif()

# バージョン表示
execute_process(
    COMMAND ${xc8_cc} --version
    RESULT_VARIABLE xc8_version_result
)

if(NOT xc8_version_result EQUAL 0)
    message(FATAL_ERROR "Failed to get XC8 compiler version.")
endif()

unset(xc8_version_result)

message(NOTICE "${xc8_cc}")

unset(xc8_cc)

set(XC8_FOUND 1)
