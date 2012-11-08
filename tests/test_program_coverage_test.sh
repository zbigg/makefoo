#!/bin/sh

. ./testlib.sh

type lcov || skip_test "lcov needed for this test case"

rm -rf test_program_test_coverage
mkdir test_program_test_coverage
cd test_program_test_coverage

( 
    cd ../autoconf_project ;
    autoreconf -I ../../ -f -i
)

invoke_test ../autoconf_project/configure --with-makefoo-dir=../..

{
    
    invoke_make COVERAGE=1 coverage-test-report
    assert_grep "this is bar_test, hello" stdout
    assert_exists ./libbar/libbar_test_program$EXECUTABLE_SUFFIX
    
    assert_exists ./coverage-test-report/index.html
}
cd ..
sleep 0
rm -rf test_program_test_coverage

