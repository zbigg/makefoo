#!/bin/sh

. ./testlib.sh

type rpmbuild || skip_test "rpmbuild required for this test case"

rm -rf simple_autoconf_project_rpm_build
mkdir simple_autoconf_project_rpm_build
cd simple_autoconf_project_rpm_build

( 
    cd ../autoconf_project ;
    autoreconf -I ../../ -f -i
)

invoke_test ../autoconf_project/configure --with-makefoo-dir=../..
    
invoke_make rpm
{    
    assert_exists baz/baz$EXECUTABLE_SUFFIX
    assert_exists libfoo/libfoo.$SHARED_LIBRARY_EXT
    assert_exists libfoo/libfoo.$STATIC_LIBRARY_EXT
    assert_exists libbar/libbar2.$STATIC_LIBRARY_EXT
    
    # check that we have some rpms    
    assert_exists ddd-1.1-1*.rpm
    assert_exists libfoo/libfoo-1.2-1*.rpm
    
    # and check their contents
    rpm2cpio ddd-1.1-1*.rpm | cpio -i -t > ddd.list
    # ddd should contain $p/bin/x and $p/lib/libbar2
    assert_grep "/usr/bin/baz" ddd.list
    assert_grep "/usr/lib(64)?/libbar2.a" ddd.list
    
    rpm2cpio libfoo/libfoo-1.2-1*.rpm | cpio -i -t > libfoo.list
    # LIBFOO should contain $p/lib/libfoo
    assert_grep "/usr/lib(64)?/libfoo.a" libfoo.list
    assert_grep "/usr/lib(64)?/libfoo.so" libfoo.list
    
    # LIBFOO defines rpm attributes
    rpm -qpi libfoo/libfoo-1.2-1*.rpm  > libfoo.info
    
    # summary
    assert_grep 'Summary.*foo library for fooization' libfoo.info
    
    # description 
    assert_grep "^POSIX compatible C library for:" libfoo.info
    assert_grep "^website http://spam_and_foo.org" libfoo.info
    
    assert_grep "License.*SomeCustomLicence" libfoo.info
}

cd ..
#rm -rf simple_autoconf_project_rpm_build

