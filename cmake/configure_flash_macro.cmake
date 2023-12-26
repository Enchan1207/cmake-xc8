#
# カスタムのフラッシュターゲットを作成するマクロ
#

macro(target_configure_for_pic target_name)
    # ターゲットが実行可能かを調べる
    get_target_property(target_type ${target_name} TYPE)

    if(target_type STREQUAL "EXECUTABLE")
        set(${target_name}_IS_EXECUTABLE TRUE)
    else()
        set(${target_name}_IS_EXECUTABLE FALSE)
    endif()

    # executableでなければ戻る
    if(NOT ${target_name}_IS_EXECUTABLE)
        return()
    endif()
    
    # ターゲットが出力または生成するファイルのパスを取得
    set(${target_name}_OUTPUT_ROOT "${CMAKE_CURRENT_BINARY_DIR}/${target_name}")
    set(${target_name}_HEX_PATH "${${target_name}_OUTPUT_ROOT}.hex")
    set(${target_name}_MAP_PATH "${${target_name}_OUTPUT_ROOT}.map")
    set(${target_name}_ELF_PATH "${${target_name}_OUTPUT_ROOT}.elf")
    set(${target_name}_MEMSUMMARY_PATH "${${target_name}_OUTPUT_ROOT}-memoryfile.xml")

    # リンクオプションを追加する
    target_link_options(${target_name} PRIVATE
        -mram=default,-320-32f
        -Wl,--defsym=__MPLAB_BUILD=1
        -Wl,--memorysummary,${${target_name}_MEMSUMMARY_PATH}
        -Wl,-Map=${${target_name}_MAP_PATH}
    )

    # 書き込みツール名が指定されていなければ戻る
    if(NOT IPE_TOOL)
        message(WARNING "IPE_TOOL not specified. Creating flash target will be skipped.")
        return()
    endif()    

    # フラッシュターゲットを追加
    add_custom_target(flash-${target_name}
        COMMAND java -jar ${IPE_ROOT}/ipecmd.jar -P${PIC_MCU} -T${IPE_TOOL} -I -M -OL -F"${${target_name}_HEX_PATH}"
        USES_TERMINAL
        DEPENDS ${target_name}
    )

    # これ以降の処理は(現時点では)Windows非対応 (/bin/shが動かないのと、mdb.shに対応するWindowsのファイル名がわからないため)
    if(WIN32)
        message(WARNING "Creating debug targets is not supported on Windows platforms.")
        return()
    endif()

    # デバッグツール名が指定されていなければ戻る
    if(NOT MDB_TOOL)
        message(WARNING "MDB_TOOL not specified. Creating debug target will be skipped.")
        return()
    endif()

    # デバッガのブートストラップファイルを作成する
    set(${target_name}_DEBUG_BOOTSTRAP_PATH "${CMAKE_CURRENT_BINARY_DIR}/${target_name}_debugger_bootstrap.txt")
    if(NOT EXISTS ${${target_name}_DEBUG_BOOTSTRAP_PATH})
        file(
            WRITE ${${target_name}_DEBUG_BOOTSTRAP_PATH} 
            "device PIC${PIC_MCU}\n"
            "hwtool ${MDB_TOOL}\n"
            "program ${${target_name}_ELF_PATH}\n"
            "reset MCLR\n"
        )
    endif()

    # デバッグターゲットを追加
    add_custom_target(debug-${target_name}
        COMMAND ${MDB_ROOT}/mdb.sh ${${target_name}_DEBUG_BOOTSTRAP_PATH}
        USES_TERMINAL
        DEPENDS ${target_name}
    )
endmacro()
