#!/bin/sh

. ./testlib.sh

rm -rf simple_autoconf_build
mkdir simple_autoconf_build
cd simple_autoconf_build

[ -f ../autoconf_project/configure ] || ( cd ../autoconf_project ; autoconf ; )

invoke_test ../autoconf_project/configure
{
    assert_exists Makefile
    assert_exists ./config.status
}   
invoke_test make
{    
    assert_exists baz/x
    assert_exists libfoo/libfoo.$SHARED_LIBRARY_EXT
    assert_exists libfoo/libbar2.$STATIC_LIBRARY_EXT
}

cd ..
rm -rf simple_autoconf_build

