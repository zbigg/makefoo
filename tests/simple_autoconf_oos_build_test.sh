. ./testlib.sh

rm -rf simple_autoconf_build
mkdir simple_autoconf_build
pushd simple_autoconf_build

invoke_test ../autoconf_project/configure
{
    assert_exists Makefile
    assert_exists ./config.status
}   
invoke_test make
find .
{    
    assert_exists baz/x
    assert_exists libfoo/libfoo.so
    assert_exists libfoo/libbar2.a
}

popd
rm -rf simple_autoconf_build

