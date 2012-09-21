#
# the shell test library
#
# (most probably bash-only compatible)
#
#
# example of use
#
# -- header
# . ./testlib.sh
#
# -- prepare env
# mkdir foo
# 
# -- invoke the tested command
# invoke_test make
#
# -- and now all assertions
# assert_grep "compiling foo.exe" stdout
# assert_exists foo.exe
# assert_grep   some_symbol foo.map
#


PNAME=`basename $0`
secho() {
    echo "$PNAME: $*" 1>&2
}
show_file()
{
    echo "$PNAME: contents of '$1' after last command ($last_command)"
    egrep -H "^" $1
}
assert_grep() {
    egrep -q "$@" || {
        secho "expected '$1' in '$2' not found"
        show_file $2
        exit 1
    }
}

assert_grepv() {
    egrep -qv "$@" || {
        secho "not expected '$1' found in $2"
        show_file $2
        exit 1
    }
}

assert_exists() {
    local r=0
    for f in "$@" ; do 
        if ! test -f $f ; then
            secho "expected file '$f' doesn't exist"
            r=1
        fi
    done
    if [ "$r" = 1 ] ; then
        exit 1
    fi
}

invoke_make()
{
    invoke_test ${MAKEFOO_MAKE} "$@"
}

invoke_test()
{
    last_command="$@"
    ( "$@" 2>&1 ) | tee stdout
}

if [ -z $MAKEFOO ] ; then
    MAKEFOO_dir=`pwd`/../
    MAKEFOO=${MAKEFOO_dir}/main.mk
    
    
fi
MAKEFOO_dir=`dirname $MAKEFOO`

export MAKEFOO
export MAKEFOO_dir

eval `${MAKEFOO_dir}/configure.sh`

if test "x" = "x$EXECUTABLE_EXT" ; then
    EXECUTABLE_SUFFIX=
else
    EXECUTABLE_SUFFIX=.$EXECUTABLE_EXT
fi

