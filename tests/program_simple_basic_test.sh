#!/bin/sh

. ./testlib.sh

set -e
cd program_simple
invoke_test make clean

#  first clean make
invoke_test make
    assert_grep "compiling a.cpp" stdout
    assert_grep "compiling b.c" stdout
    assert_grep "linking program program_simple" stdout
    
    assert_exists .obj/a.o .obj/b.o program_simple

# now remote program and check if it is relinked
rm program_simple
invoke_test make
    assert_exists program_simple
    assert_grepv "compiling" stdout
    assert_grep "linking program program_simple" stdout

# now touch one file and check if
# only it is being recompiled
# and program is relinked
touch a.cpp
rm program_simple

invoke_test make 
    assert_grep "compiling a.cpp" stdout
    assert_grepv "compiling a.c" stdout
    assert_grep "linking program program_simple" stdout
    
    assert_exists .obj/a.o .obj/b.o program_simple

make clean


