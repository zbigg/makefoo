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
#set -x

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

#
# target_arch specific settings
#
case "${target_arch}" in
    *msvc*|*msvs|*mingw*)
        w32_executable_model=1
        target_is_x86_32=1
        ;;
    *x86_64*|*amd64*)
        target_is_x86_64=1
        ;;
    *i*86*)
        target_is_x86_32=1
        ;;
esac

#
# detect the toolset
#
if [ -z "$TOOLSET" ] ; then
    case "${target_arch}" in
        *msvc*|*msvs*)
            default_TOOLSET=msvs
            ;;
        *mingw*)
            default_TOOLSET=gcc
            ;;
        *)
            if [ -z "$TOOLSET" ] ; then
                if exists_in_path cl ; then
                    default_TOOLSET=msvs
                elif exists_in_path gcc ; then
                    default_TOOLSET=gcc
                elif exists_in_path clang ; then
                    default_TOOLSET=clang
                elif exists_in_path cc ; then
                    default_TOOLSET=unix
                else
                    echo "configure.sh: unable to find TOOLSET (tried, gcc/G++, clang(++), cc/CC" >&2 
                    exit 1
                fi
            fi
            ;;
    esac
    TOOLSET="${default_TOOLSET}"
fi

case "${TOOLSET}" in
    gcc)
        TOOLSET_CXX=${CXX-g++}
        TOOLSET_CC=${CC-gcc}
        
        if [ -n "$w32_executable_model" ] ; then
            EXECUTABLE_EXT=exe
            
            STATIC_LIBRARY_EXT=a
            SHARED_LIBRARY_EXT=dll
            IMPORT_LIBRARY_EXT=dll.a
            SHARED_LIBRARY_MODEL=dll

            TARGET_SHARED_LIBRARY_LDFLAGS="-Wl,--enable-auto-import"
        else
            STATIC_LIBRARY_EXT=a
            SHARED_LIBRARY_EXT=so
            SHARED_LIBRARY_MODEL=so
        fi
        ;;
    unix)
        TOOLSET_CXX=${CXX-CC}
        TOOLSET_CC=${CC-cc}
        
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
        
        EXECUTABLE_EXT=exe
        STATIC_LIBRARY_EXT=lib
        SHARED_LIBRARY_EXT=dll
        IMPORT_LIBRARY_EXT=dll.lib
        SHARED_LIBRARY_MODEL=dll
        
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


