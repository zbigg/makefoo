dnl
dnl makefoo
dnl

AC_DEFUN([AC_MAKEFOO],
[
    #echo "ac_top_srcdir = $ac_top_srcdir"
    #echo "top_srcdir = $top_srcdir"
    #echo "srcdir = $srcdir"
    
    AC_ARG_WITH(makefoo-dir,[--with-makefoo-dir=DIR   Where makefoo is installed (mandatory if not standard)],
            [
                makefoo_dir="$withval"
                makefoo_main="$withval"/main.mk
            ]
            , makefoo_dir="")
            
    AC_MSG_CHECKING(for makefoo path)
    
    if test x$makefoo_dir = x ; then
        AC_MSG_CHECKING(for makefoo path with pkg_config)
        makefoo_dir=`pkg-config --variable=MAKEFOO_dir makefoo 2>/dev/null`
        if test -f $makefoo_dir/defs.mk ; then
            makefoo_main="$makefoo_dir/main.mk"
            AC_MSG_RESULT([$makefoo_dir])
        else
            AC_MSG_RESULT([not found])
        fi
    fi
    if test x$makefoo_dir = x ; then
        AC_MSG_CHECKING([for makefoo in predefined folders])
        for DIR in $srcdir/makefoo /usr/local/lib/makefoo /usr/lib/makefoo $srcdir $srcdir/.. $srcdir/../.. $srcdir/../../.. $HOME/lib/makefoo; do
            #echo "...trying $DIR" 
            if test -f $DIR/defs.mk ; then
                makefoo_dir="$DIR"
                makefoo_main="$DIR/main.mk"
                # note, not sure if it's bash
                # or posix feature
                AC_MSG_RESULT([$MAKEFOO])
                break
            fi
            if test -f makefoo_amalgamation.mk  ; then
                makefoo_dir="$DIR"
                makefoo_main="$DIR/makefoo_amalgamation.mk"
                break
            fi
        done
    fi
    
    if test x$makefoo_main = x ; then
        AC_MSG_RESULT([not found])
        AC_MSG_ERROR([makefoo not found in default locations, please try --with-makefoo-dir=FOLDER option])
    fi
    
    MAKEFOO=${makefoo_main}
    
    # we require canonical host to configure makefoo
    AC_CANONICAL_HOST
    #
    # now generate makefoo_configured_defs
    #
    #echo "host = $host"
    AC_MSG_NOTICE([generating makefoo configuration: makefoo_configured_defs.mk])
    
    rm -rf makefoo_configured_defs.mk
    MAKEFOO_dir=${makefoo_dir} target_arch=$host ${makefoo_dir}/configure.sh > makefoo_configured_defs.mk
    
    AC_MSG_NOTICE([makefoo config:])
    cat makefoo_configured_defs.mk
    AC_SUBST(MAKEFOO)
])
