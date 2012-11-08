#!/bin/sh
overall_result=0

MAKEFOO=`pwd`/../main.mk
export MAKEFOO

for test_script in *_test.sh ; do
    test_name=`echo $test_script | sed -e 'sX_test.shXX'`
    r=0
    (
        echo "---- $test_name -- start"
        ./${test_script} 2>&1
        r=$?
        if [ "$r" = "0" ] ; then
            if egrep -q -- "^$test_name.*: skipped" $test_name.log ; then
                echo "---- $test_name --> skipped"
            else
                echo "---- $test_name --> success"
            fi
        else
            echo "---- $test_name --> failure, see $test_name.log"
        fi
    ) | tee $test_name.log
    if grep -qF -- "---- $test_name --> failure" $test_name.log ; then
        overall_result=1
    fi
done

for test_script in *_test.sh ; do
    test_name=`echo $test_script | sed -e 'sX_test.shXX'`
    if grep -qF -- "---- $test_name --> failure" $test_name.log ; then
        echo "test '$test_name' failed"
    fi
    if grep -qF -- "---- $test_name --> skipped" $test_name.log ; then
        echo "test '$test_name' skipped"
    fi
done

if [ "$overall_result" != "0" ] ; then
    echo "$0: error, some tests failed"
else
    echo "$0: all tests passed"
fi

exit $overall_result

