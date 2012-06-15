#!/bin/sh

. ./testlib.sh

rm -rf simple_autoconf_project_rpm_build
mkdir simple_autoconf_project_rpm_build
cd simple_autoconf_project_rpm_build

[ -f ../autoconf_project/configure ] || ( cd ../autoconf_project ; autoconf ; )

invoke_test ../autoconf_project/configure --with-makefoo-dir=../..
invoke_make rpm
{    
    assert_exists baz/baz$EXECUTABLE_SUFFIX
    assert_exists libfoo/libfoo.$SHARED_LIBRARY_EXT
    assert_exists libfoo/libfoo.$STATIC_LIBRARY_EXT
    assert_exists libbar/libbar2.$STATIC_LIBRARY_EXT
    
    # check that we have some rpms    
    assert_exists ddd-dev-1*.rpm
    assert_exists libfoo/libfoo-dev-1*.rpm
    
    # and check their contents
    rpm2cpio ddd-dev-1*.rpm | cpio -i -t > ddd.list
    # ddd should contain $p/bin/x and $p/lib/libbar2
    assert_grep "/usr/bin/baz" ddd.list
    assert_grep "/usr/lib/libbar2.a" ddd.list
    
    rpm2cpio libfoo/libfoo-dev-1*.rpm | cpio -i -t > libfoo.list
    # LIBFOO should contain $p/lib/libfoo
    assert_grep "/usr/lib/libfoo.a" libfoo.list
    assert_grep "/usr/lib/libfoo.so" libfoo.list
}

cd ..
#rm -rf simple_autoconf_project_rpm_build

