#!/bin/sh

. ./testlib.sh

TOOLSET=gcc $MAKEFOO_dir/configure.sh > stdout
    assert_grep -F "COMPILER_GCC=1" stdout
    assert_grep -F "TOOLSET=gcc" stdout
    assert_grep -F "TOOLSET_CC=gcc" stdout
    assert_grep -F "TOOLSET_CXX=g++" stdout

TOOLSET=clang $MAKEFOO_dir/configure.sh > stdout
    assert_grep -F "COMPILER_CLANG=1" stdout
    assert_grep -F "TOOLSET=clang" stdout
    assert_grep -F "TOOLSET_CC=clang" stdout
    assert_grep -F "TOOLSET_CXX=clang++" stdout

TOOLSET=msvs $MAKEFOO_dir/configure.sh > stdout
    assert_grep -F "TARGET_W32=1" stdout
    assert_grep -F "COMPILER_MSVC=1" stdout
    assert_grep -F "TOOLSET=msvs" stdout
    assert_grep -F "TOOLSET_CC=cl.exe" stdout
    assert_grep -F "TOOLSET_CXX=cl.exe" stdout
    assert_grep -F "TOOLSET_LINKER=link.exe" stdout
    assert_grep -F "EXECUTABLE_EXT=exe" stdout
    assert_grep -F "SHARED_LIBRARY_EXT=dll" stdout
    assert_grep -F "SHARED_LIBRARY_MODEL=dll" stdout
    assert_grep -F "IMPORT_LIBRARY_EXT=dll.lib" stdout
    assert_grep -F "STATIC_LIBRARY_EXT=lib" stdout

rm -rf stdout
