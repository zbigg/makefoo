#!/bin/sh
overall_result=0

MAKEFOO=`pwd`/..
export MAKEFOO

for test_script in *_test.sh ; do
    test_name=`echo $test_script | sed -e 'sX_test.shXX'`
    r=0
    (
        echo "---- test $test_name"
        ./${test_script} 2>&1
        r=$?
        if [ "$r" = "0" ] ; then
            echo "---- > success"
        else
            echo "---- > failure, see $test_name.log"
        fi
    ) | tee $test_name.log
    if grep -qF -- "---- > failure" $test_name.log ; then
        overall_result=1
    fi
done
if [ "$overall_result" != "0" ] ; then
    echo "$0: error, some tests failed"
fi    

exit $overall_result
