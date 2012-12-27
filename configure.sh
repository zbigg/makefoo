#!/bin/sh

PNAME=`basename $0`
if test "x$MAKEFOO_dir" = "x" ; then
    #DEFAULT_MAKEFOO=/usr/lib/MAKEFOO
    DEFAULT_MAKEFOO_dir=`pwd`
    if test -d $DEFAULT_MAKEFOO_dir ; then
        MAKEFOO_dir="$DEFAULT_MAKEFOO_dir"
    else    
        echo "$PNAME: MAKEFOO variable not set and MAKEFOO not found in default location ($DEFAULT_MAKEFOO)"
        exit 1
    fi
fi

export MAKEFOO
export MAKEFOO_dir

set -e

build_arch=${build_arch-$(sh ${MAKEFOO_dir}/autoconf_helpers/config.guess)}
target_arch=${target_arch-$build_arch}

exists_in_path()
{
    type $1 2>/dev/null >/dev/null 
}
#
# choose architecture tag for various builds
#
case "${target_arch}" in
    i386*|i486*|i586*|i686*)
        RPM_ARCH=i386
        ;;
    x86_64|amd64)
        RPM_ARCH=x86_64
        ;;
esac

#
# choose default compiler and flags
# 
case "${build_arch}" in
    *freebsd*)
	MAKEFOO_MAKE=gmake
	;;
    *)
	MAKEFOO_MAKE=make
	;;
esac

case "${target_arch}" in
    *msvc*|*msvs*)
        TOOLSET=${TOOLSET-msvs}

        EXECUTABLE_EXT=exe
        STATIC_LIBRARY_EXT=lib
        SHARED_LIBRARY_EXT=dll
        IMPORT_LIBRARY_EXT=dll.lib
        SHARED_LIBRARY_MODEL=dll
        ;;
    *mingw*)
        TOOLSET=${TOOLSET-gcc}

        EXECUTABLE_EXT=exe
        
        STATIC_LIBRARY_EXT=a
        SHARED_LIBRARY_EXT=dll
        IMPORT_LIBRARY_EXT=dll.a
        SHARED_LIBRARY_MODEL=dll

        TARGET_SHARED_LIBRARY_LDFLAGS="-Wl,--enable-auto-import"
        ;;
    *)
        if [ -z "$TOOLSET" ] ; then
            if exists_in_path gcc ; then
                TOOLSET=gcc
            elif exists_in_path clang ; then
                TOOLSET=clang
            elif exists_in_path cc ; then
                TOOLSET=unix
            else
                echo "configure.sh: unable to find TOOLSET (tried, gcc/G++, clang(++), cc/CC" >&2 
                exit 1
            fi
        fi
        
        STATIC_LIBRARY_EXT=a
        SHARED_LIBRARY_EXT=so
        SHARED_LIBRARY_MODEL=so
        ;;
esac

case "${TOOLSET}" in
    unix)
        TOOLSET_CXX=${CXX-CC}
        TOOLSET_CC=${CC-cc}
        
        OBJECT_EXT=o
        ;;
    gcc)
        TOOLSET_CXX=${CXX-g++}
        TOOLSET_CC=${CC-gcc}
        
        OBJECT_EXT=o
        ;;
    clang)
        TOOLSET_CXX=${CXX-clang++}
        TOOLSET_CC=${CC-clang}
        
        OBJECT_EXT=o
        ;;
    msvs)
        
        TOOLSET_CXX=${CXX-cl.exe}
        TOOLSET_CC=${CC-cl.exe}
        TOOLSET_LINKER=${LINKER-link.exe}
        
        OBJECT_EXT=obj
        ;;
    *)
        # unknown toolset, guessing
        echo TOOLSET is unknown, exiting
        exit 1
        ;;
esac

emit()
{
    for NAME in $* ; do
        VALUE=`eval echo \\$${NAME}`
        if [ -z "$VALUE" ] ; then
            #echo "# $NAME is not defined for this configuration"
            true
        else
            echo "$NAME=$VALUE"
        fi
    done
}
TARGET_ARCH="${target_arch}"

emit MAKEFOO_MAKE
emit TARGET_ARCH
emit TOOLSET TOOLSET_CC TOOLSET_CXX TOOLSET_LINKER
emit EXECUTABLE_EXT
emit SHARED_LIBRARY_EXT SHARED_LIBRARY_MODEL
emit IMPORT_LIBRARY_EXT
emit STATIC_LIBRARY_EXT
emit RPM_ARCH


