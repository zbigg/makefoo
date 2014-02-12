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

exists_in_path()
{
    type $1 2>/dev/null >/dev/null 
}


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
# detect the toolset if not defined yet
#
if [ -z "$TOOLSET" ] ; then
    if   [ -n "${CC}" ] ; then
        case "${CC}" in
            *cl|*cl.exe)
                TOOLSET=msvs
                ;;
            *gcc)
                TOOLSET=gcc
                ;;
            *clang*)
                TOOLSET=clang
                ;;
        esac
    elif [ -n "${CXX}" ] ; then
        case "${CC}" in
            *cl|*cl.exe)
                TOOLSET=msvs
                ;;
            *gcc|*g++)
                TOOLSET=gcc
                ;;
            *clang*)
                TOOLSET=clang
                ;;
        esac
    fi
fi

if [ -z "$TOOLSET" ] ; then
    case "${target_arch}" in
        *mingw*)
            default_TOOLSET=gcc
            ;;
	*msvc*|*msvs*)
            default_TOOLSET=msvs
            ;;

        *)
            if exists_in_path cl ; then
                default_TOOLSET=msvs
            elif exists_in_path gcc ; then
                default_TOOLSET=gcc
            elif exists_in_path clang ; then
                default_TOOLSET=clang
            elif exists_in_path cc ; then
                default_TOOLSET=unix
            else
                echo "configure.sh: unable to find TOOLSET (tried, gcc/G++, clang(++), cc/CC, cl.exe" >&2 
                exit 1
            fi
            ;;
    esac
    TOOLSET="${default_TOOLSET}"
fi

case "${TOOLSET}" in
    *mingw64*)
        target_arch="${target_arch-i686-w64-mingw32}"

        TOOLSET_CXX="${CXX-i686-w64-mingw32-g++}"
        TOOLSET_CC="${CC-i686-w64-mingw32-gcc}"

        STATIC_LIBRARY_EXT=a
        OBJECT_EXT=o
        COMPILER_GCC=1
        ;;
    *mingw32|*mingw*)
        target_arch="${target_arch-i586-mingw32msvc}"

        TOOLSET_CXX="${CXX-i586-mingw32msvc-g++}"
        TOOLSET_CC="${CC-i586-mingw32msvc-gcc}"

        STATIC_LIBRARY_EXT=a
        OBJECT_EXT=o
        COMPILER_GCC=1
        ;;
    gcc|g++)
        TOOLSET_CXX="${CXX-g++}"
        TOOLSET_CC="${CC-gcc}"

        STATIC_LIBRARY_EXT=a
        OBJECT_EXT=o
        COMPILER_GCC=1
        ;;
    unix)
        TOOLSET_CXX="${CXX-CC}"
        TOOLSET_CC="${CC-cc}"

        STATIC_LIBRARY_EXT=a
        OBJECT_EXT=o
        ;;
    clang)
        TOOLSET_CXX="${CXX-clang++}"
        TOOLSET_CC="${CC-clang}"
        OBJECT_EXT=o

        STATIC_LIBRARY_EXT=a
        COMPILER_CLANG=1
        ;;
    msvs)
        target_arch="${target_arch-i686-win32-msvs}"

        TOOLSET_CXX="${CXX-cl.exe}"
        TOOLSET_CC="${CC-cl.exe}"
        TOOLSET_LINKER="${LINKER-link.exe}"
        COMPILER_MSVC=1

        STATIC_LIBRARY_EXT=lib
        IMPORT_LIBRARY_EXT=dll.lib

        OBJECT_EXT=obj
        ;;
    *)
        # unknown toolset, guessing
        echo "$0: TOOLSET is unknown (please specify TOOLSET,CC,CXX in env). exiting" >&2
        exit 1
        ;;
esac

target_arch=${target_arch-$build_arch}

#
# choose architecture tag for various builds
#

if [ -n "$TARGET_LINUX" ] ; then
    case "${target_arch}" in
        i386*|i486*|i586*|i686*)
            RPM_ARCH=i386
            ;;
        x86_64|amd64)
            RPM_ARCH=x86_64
            ;;
    esac
fi

#
# target variables 
#
# 
# machine/architecture 
#
case "${target_arch}" in
    *w64-mingw32*)
        target_is_x86_64=1
        TARGET_X86_64=1
        TARGET_W64=1
        ;;
    *msvc*|*msvs|*mingw*|*i*86*)
        target_is_x86_32=1
        TARGET_X86_32=1
        ;;
    *x86_64*|*amd64*)
        target_is_x86_64=1
        TARGET_X86_64=1
        ;;
esac

#
# os type
#
case "${target_arch}" in
    *linux*|*Linux*)
        TARGET_LINUX=1
        TARGET_POSIX=1

        SHARED_LIBRARY_EXT=so
        SHARED_LIBRARY_MODEL=so
        ;;
    *darwin*|*Darwin*)
        TARGET_MACOSX=1
        TARGET_POSIX=1

        SHARED_LIBRARY_EXT=dylib
        ;;
    *freebsd*)
        TARGET_FREEBSD=1
        TARGET_POSIX=1

        SHARED_LIBRARY_EXT=so
        SHARED_LIBRARY_MODEL=so
        ;;
    *msvc*|*msvs|*mingw*)
        TARGET_W32=1

        if [ -n "$COMPILER_GCC" ] ; then
            # mingw
            IMPORT_LIBRARY_EXT=dll.a
            TARGET_SHARED_LIBRARY_LDFLAGS="-Wl,--enable-auto-import"
        fi

        SHARED_LIBRARY_EXT=dll
        SHARED_LIBRARY_MODEL=dll
        EXECUTABLE_EXT=exe
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

emit TARGET_X86_32 TARGET_X86_64

emit TARGET_POSIX
emit TARGET_MACOSX
emit TARGET_LINUX
emit TARGET_FREEBSD
emit TARGET_W32
emit TARGET_W64

emit COMPILER_GCC
emit COMPILER_CLANG
emit COMPILER_MINGW32
emit COMPILER_MSVC

emit TOOLSET TOOLSET_CC TOOLSET_CXX TOOLSET_LINKER
emit EXECUTABLE_EXT
emit SHARED_LIBRARY_EXT SHARED_LIBRARY_MODEL
emit IMPORT_LIBRARY_EXT
emit STATIC_LIBRARY_EXT
emit RPM_ARCH


