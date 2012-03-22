#!/bin/sh

PNAME=`basename $0`
if test "x$MAKEFOO" = "x" ; then
    #DEFAULT_MAKEFOO=/usr/lib/MAKEFOO
    DEFAULT_MAKEFOO=`pwd`
    if test -d $DEFAULT_MAKEFOO ; then
        MAKEFOO="$DEFAULT_MAKEFOO"
    else    
        echo "$PNAME: MAKEFOO variable not set and MAKEFOO not found in default location ($DEFAULT_MAKEFOO)"
        exit 1
    fi
fi
export MAKEFOO

set -e

build_arch=${build_arch-`sh ${MAKEFOO}/autoconf_helpers/config.guess`}
target_arch=${target_arch-$build_arch}

#
# choose default compiler and flags
# 
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
        TOOLSET=gcc
        
        STATIC_LIBRARY_EXT=a
        SHARED_LIBRARY_EXT=so
        SHARED_LIBRARY_MODEL=so
        ;;
esac

case "${TOOLSET}" in
    gcc)
        TOOLSET_CXX=${CXX-g++}
        TOOLSET_CC=${CC-gcc}
        
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

emit TARGET_ARCH
emit TOOLSET TOOLSET_CC TOOLSET_CXX TOOLSET_LINKER
emit EXECUTABLE_EXT
emit SHARED_LIBRARY_EXT SHARED_LIBRARY_MODEL
emit IMPORT_LIBRARY_EXT
emit STATIC_LIBRARY_EXT
