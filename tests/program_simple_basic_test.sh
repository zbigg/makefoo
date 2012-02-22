#!/bin/sh

set -e -x
cd program_simple
make clean

#  first clean make
make 2>&1 | tee stdout 
grep -q "compiling a.cpp" stdout
grep -q "compiling b.c" stdout
grep -q "linking x" stdout

test -f a.o 
test -f b.o
test -f b.o 
test -f x

touch a.cpp
make 2>&1 | tee stdout
grep -q "compiling a.cpp" stdout
grep -q "linking x" stdout
test -f x

make clean
