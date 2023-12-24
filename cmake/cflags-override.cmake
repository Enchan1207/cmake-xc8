#
# CMake内部のCFLAGSをオーバライド
#

# オブジェクトファイルと実行可能ファイルの拡張子を設定
# (XC8は.oや.objの代わりに.p1 (中間コードファイル) を出力する)
set(CMAKE_C_OUTPUT_EXTENSION ".p1")
set(CMAKE_EXECUTABLE_SUFFIX ".elf")

# アーカイバに渡すオプションがxc8-arと通常のarとで異なるため、ここで上書き
set(CMAKE_C_CREATE_STATIC_LIBRARY)
string(APPEND CMAKE_C_CREATE_STATIC_LIBRARY "<CMAKE_AR> -r <TARGET> <OBJECTS> <LINK_LIBRARIES>")
