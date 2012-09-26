. ./testlib.sh

rm -rf test_program_test
mkdir test_program_test
cd test_program_test

( 
    cd ../autoconf_project ;
    autoreconf -I ../../ -f -i
)

invoke_test ../autoconf_project/configure --with-makefoo-dir=../..

{
    invoke_make test
    assert_grep "this is bar_test, hello" stdout
    assert_exists ./libbar/libbar_test_program
    
    invoke_make clean
    
    invoke_make COVERAGE=1 coverage-test-report
    assert_grep "this is bar_test, hello" stdout
    assert_exists ./libbar/libbar_test_program
    
    assert_exists ./coverage-test-report/index.html
}
cd ..

rm -rf test_program_test

