#!/bin/sh

. ./testlib.sh

type cppcheck || skip_test "cppcheck required for this test case"

cd program_simple

#  first clean make
invoke_make cppcheck 
    assert_grep "cppcheck C++ sources" stdout
    assert_grep 'a.cpp(.*)for_cppcheck_only(.*)never used' stdout
    
    assert_grep "cppcheck C sources" stdout
    assert_grep "b.c(.*)style: (.*)foo(.*)is never used" stdout


