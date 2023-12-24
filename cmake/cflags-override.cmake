#
# CMake内部のCFLAGSをオーバライド
#

# オブジェクトファイルと実行可能ファイルの拡張子を設定
# (XC8は.oや.objの代わりに.p1 (中間コードファイル) を出力する)
set(CMAKE_C_OUTPUT_EXTENSION ".p1")
set(CMAKE_EXECUTABLE_SUFFIX ".elf")
