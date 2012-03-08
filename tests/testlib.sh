#
# the shell test library
#
# (most probably bash-only compatible)
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

invoke_test()
{
    last_command="$@"
    ( "$@" 2>&1 ) | tee stdout
}

