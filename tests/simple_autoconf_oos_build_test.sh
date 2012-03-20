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
    assert_exists libfoo/libfoo.so
    assert_exists libfoo/libbar2.a
}

cd ..
rm -rf simple_autoconf_build

