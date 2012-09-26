#!/bin/sh

. ./testlib.sh

rm -rf simple_autoconf_build
mkdir simple_autoconf_build
cd simple_autoconf_build

( 
    cd ../autoconf_project ;
    autoreconf -I ../../ -f -i
)

invoke_test ../autoconf_project/configure --with-makefoo-dir=../..
{
    assert_exists Makefile
    assert_exists ./config.status
}   
invoke_make
{    
    assert_exists baz/baz$EXECUTABLE_SUFFIX
    assert_exists libfoo/libfoo.$SHARED_LIBRARY_EXT
    assert_exists libfoo/libfoo.$STATIC_LIBRARY_EXT
    assert_exists libbar/libbar2.$STATIC_LIBRARY_EXT
}

cd ..
rm -rf simple_autoconf_build

