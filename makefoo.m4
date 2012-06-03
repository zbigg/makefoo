dnl
dnl makefoo
dnl

AC_DEFUN(AC_MAKEFOO,
[
    #echo "ac_top_srcdir = $ac_top_srcdir"
    #echo "top_srcdir = $top_srcdir"
    #echo "srcdir = $srcdir"
    
    AC_ARG_WITH(makefoo-dir,[--with-makefoo-dir=DIR   Where makefoo is installed (mandatory if not standard)],
            makefoo_dir="$withval", makefoo_dir="")
            
    AC_MSG_CHECKING(for makefoo path)
    if test x$makefoo_dir = x ; then
        for DIR in /usr/local/lib/MAKEFOO /usr/lib/MAKEFOO $srcdir $srcdir/.. $srcdir/../.. $srcdir/../../.. ; do
            #echo "...trying $DIR" 
            if test -f $DIR/defs.mk ; then
                makefoo_dir=$DIR
                # note, not sure if it's bash
                # or posix feature
                break
            fi
        done
    fi
    
    if test x$makefoo_dir = x ; then
        AC_MSG_RESULT([not found])
        AC_MSG_ERROR([makefoo not found in default locations, please try --with-makefoo-dir=FOLDER option])
    fi
    
    MAKEFOO=${makefoo_dir}
    
    AC_MSG_RESULT([$MAKEFOO])

    # we require canonical host to configure makefoo
    AC_CANONICAL_HOST
    #
    # now generate makefoo_configured_defs
    #
    #echo "host = $host"
    AC_MSG_NOTICE([generating makefoo configuration: makefoo_configured_defs.mk])
    
    rm -rf makefoo_configured_defs.mk
    MAKEFOO=${MAKEFOO} target_arch=$host ${MAKEFOO}/configure.sh > makefoo_configured_defs.mk
    
    AC_MSG_NOTICE([makefoo config:])
    cat makefoo_configured_defs.mk
    AC_SUBST(MAKEFOO)
])
