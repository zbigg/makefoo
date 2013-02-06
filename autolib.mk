
#
# makefoo AUTOLIBDEP engine
#

# program_LIB_DEPS = foo bar ...
# library_LIB_DEPS = foo bar
#    dependent may also add some compilation/linking flags
#    link <program> or <shared library> with foo bar (and all of their dependecies)
#
#
# libname_DIR=<where_libname_is_located>
# libname_TYPE=pkg-config, the LDFLAGS & CFLAGS will be retrieved using pkg-config
#
# pkg-config_DEPS += libname
# 	# pkg-config --libs libname will be added to LDLIBS
# 	# pkg-config --libs libname will be added to C(XX)FLAGS
# libname_TYPE=system 
# 	# the library will be linked just as -lFOO foo.lib (msvs) at the end of list
#
# libname_LIBNAMES = foo bar
#       if file id/library name is different from "makefoo" internal lib id
#       then one can change it by LIBNAMES
#       many library names will be added
#
# libname_LDLIBS=<flags>
# libname_LDFLAGS=<flags>
# libname_CFLAGS=<flags>
# libname_CXXFLAGS=<flags>
# 	# custom, hardcoded library
# 	# the library will just append specific flags to particular build/compilation 
# 
# libname_AUTOLIB_DEPS = dep_libname ...
# 	# ensures that all dependent libraries (and/or flags of them) will be linked
# 	# before actual 'libname'


