#!/usr/bin/env bash

#
# let the order be ...
#
# CC/CXX - if known will define target_arch
# CC/CXX - if defined will define TOOLSET
# TOOLSET - if specifc will define
#   target_arch - if can be determined from TOOLSET
#   CC/CXX - based on target_arch
#   
# target_arch
# 
#
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

found()
{
    eval "$1='$2'"
    if [ -n "$3" ] ; then
        echo "$PNAME: found $1 ($3)" >&2
    else
        echo "$PNAME: found $1" >&2
    fi
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
# detect the TOOLSET if CC/CXX is defined
#

target_arch_from_compiler() {
    # NOTE, this is BASH!
    local comp="$1"
    local compa="${comp##*-}"
    local archa="${comp%-*}"
    if echo "$archa" | grep -qE "(/|^)(i.86|x86|x86_64|arm|amd64|powerpc|alpha|m6[6|8]k|mips|rs6000|sparc)" ; then
        echo $(basename $archa)
        return 0
    fi
    #return 1
}

if [ -z "$target_arch" ] ; then
    if [ -n "${CC}" ] ; then
        r=`target_arch_from_compiler "$CC"`
        if [ -n "$r" ] ; then
            found target_arch "$r" "because CC=$CC looks like cross compiler to $r"
        fi
    elif [ -n "${CXX}" ] ; then
        r=`target_arch_from_compiler "$CXX"`
        if [ -n "$r" ] ; then
            found target_arch "$r" "because CXX=$CXX looks like cross compiler to $r"
        fi
    fi
fi

#
# detect TOOLSET if CC/CXX by name were given by user
#
if [ -z "$TOOLSET" -a -n "${CC}" ] ; then
    case "${CC}" in
        *cl|*cl.exe)
            found TOOLSET msvs "because CC=$CC looks like Microsoft Visual Studio C++ compiler"
            ;;
        *gcc)
            found TOOLSET gcc "because CC=$CC looks like GNU GCC"
            ;;
        *clang*)
            found TOOLSET clang "because CC=$CC looks like LLVM CLang"
            ;;
    esac
fi

if [ -z "$TOOLSET" -a -n "${CXX}" ] ; then
    case "${CC}" in
        *cl|*cl.exe)
            found TOOLSET msvs "because CXX=$CXX looks like Microsoft Visual Studio C++ compiler"
            ;;
        *gcc|*g++)
            found TOOLSET gcc "because CXX=$CXX looks like GNU GCC"
            ;;
        *clang*)
            found TOOLSET clang "because CX=$CXX looks like LLVM CLang"
            ;;
    esac
fi

#
# detect TOOLSET if it can be found determined from target arch
#
if [ -z "$TOOLSET" ] ; then
    case "${target_arch}" in
	*msvc*|*msvs*|w32|w64)
            found TOOLSET msvs "because target_arch looks like W32/W64 and is not MinGW"
            ;;
    esac
fi

#
# detect TOOLSET based on tools that exist in PATH
#
if [ -z "$TOOLSET" ] ; then
    if exists_in_path cl ; then
        found TOOLSET msvs "because cl (MSVS C++ compiler) is found in PATH"
    elif exists_in_path gcc ; then
        found TOOLSET gcc "because gcc was found in PATH"
    elif exists_in_path clang ; then
        found TOOLSET clang "because clang was found in PATH"
    elif exists_in_path cc ; then
        TOOLSET=unix "because generic 'cc' was found in PAth"
    else
        echo "configure.sh: unable to find TOOLSET (tried, gcc/G++, clang(++), cc/CC, cl.exe" >&2 
        exit 1
    fi
fi

#
# now TOOLSET related settings
#
case "${TOOLSET}" in
    *mingw64*)
        target_arch="${target_arch-i686-w64-mingw32}"
        COMPILER_GCC=1
        ;;
    *mingw32|*mingw*)
        target_arch="${target_arch-i586-mingw32msvc}"
        COMPILER_GCC=1
        ;;
    gcc|g++)
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
# GCC specific
#
if [ "$COMPILER_GCC" ] ; then
    if   [ -n "$CC" -a -z "$CXX" ] ; then
        found CXX "${CC/-gcc/-g++}" "because user defined CC=$CC"
    elif [ -n "$CC" -a -z "$CXX" ] ; then
        found CXX "${CC/-g++/-gcc}" "because user defined CXX=$CXX"
    fi

    if [ "$target_arch" != "$build_arch" ] ; then
        found cross_compiler_prefix "${target_arch}-" "because we're cross compiling using gcc to $target_arch"
    fi
    if [ -z "$CC" ] ; then
        CC="${cross_compiler_prefix}gcc"
    fi
    if [ -z "$CXX" ] ; then
        CXX="${cross_compiler_prefix}g++"
    fi

    STATIC_LIBRARY_EXT=a
    OBJECT_EXT=o

    found TOOLSET_CC "${CC-gcc}"
    found TOOLSET_CXX "${CXX-g++}"
fi

#
# CLANG specific
# 
if [ "$COMPILER_CLANG" ] ; then
    if   [ -n "$CC" -a -z "$CXX" ] ; then
        found CXX "${CC/clang/clang++}" "because user defined CC=$CC"
    elif [ -n "$CC" -a -z "$CXX" ] ; then
        found CXX "${CC/clang++/clang}" "because user defined CXX=$CXX"
    fi

    found TOOLSET_CC "${CC-clang}"
    found TOOLSET_CXX "${CXX-clang++}"
fi

#
# target_arch -> IAS specifics
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
# target_arch -> os type specifics
#
case "${target_arch}" in
    *linux*|*Linux*)
        TARGET_LINUX=1
        TARGET_POSIX=1

        SHARED_LIBRARY_EXT=so
        SHARED_LIBRARY_MODEL=so
        
        if [ -n "$TARGET_X86_64" ] ; then
            RPM_ARCH=x86_64
        else
            RPM_ARCH=i386
        fi
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
    *mingw*)
        TARGET_W32=1
        IMPORT_LIBRARY_EXT=dll.a
        TARGET_SHARED_LIBRARY_LDFLAGS="-Wl,--enable-auto-import"

        SHARED_LIBRARY_EXT=dll
        SHARED_LIBRARY_MODEL=dll
        EXECUTABLE_EXT=exe
        ;;
    *msvc*|*msvs)
        IMPORT_LIBRARY_EXT=lib

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


