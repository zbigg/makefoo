
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

#
# implementation
#
# # $(call static_libs, lib_names)
# #  coverts to absolute paths of lib files

makefoo.autolib.lib-names=$(if $($(1)_LIBNAMES),$($(1)_LIBNAMES),$(1))

makefoo.autolib.system-libflags=$(patsubst %,-l%,$(call makefo.autolib.lib-names,$(1)))

makefoo.autolib.pkg-config-libdir=$(shell pkg-config --variable=libdir $(1))
makefoo.autolib.pkg-config-libflags-static=$(patsubst %, $(call pkg-config-libdir,$(1))/lib%.a,$(call lib-names,$(1)))


# for each dep 
#   print edge lib->dep
#   recursiveal print all deps of dep
#    warning, cycles are not detected, make goes infinite loop here!!!
makefoo.autolib.tsort-echos-for-deps = $(foreach lib,$(1), \
    $(if $($(lib)_DEP_LIBS),\
        $(foreach dep,$($(lib)_DEP_LIBS),echo $(lib) $(dep); \
        $(call makefoo.autolib.tsort-echos-for-deps,$(dep))), \
        echo autolib-dummy-value $(lib); \
    ))
makefoo.autolib.resolve-tsorted-dep-libs = \
    $(filter-out autolib-dummy-value,\
	$(strip \
	    $(shell ( $(call makefoo.autolib.tsort-echos-for-deps,$(1)) ) | tsort )))

# $(call makefoo.autolib.custom_flags,FLAGTYPE,$libs 
makefoo.autolib.custom_flags = \
	$(forach lib,$(1),$(if $($(lib)_$(2)), $($(lib)_$(2))))
	
#
makefoo.pkg-config = $(if $(2),$(shell pkg-config $(1) $(2)),)
makefoo.autolib.filter-pkg-config = $(filter $(makefoo.autolib.pkg-config-libs),$(1))
makefoo.autolib.filter-no-pkg-config = $(filter-out $(makefoo.autolib.pkg-config-libs),$(1))


# TBD, for each non-pkg-config library
#  find library folder, add explicit linking path: DIR/libFOO.a
makefoo.autolib.make_lib_flags-static = 
# same as above more or less, but with -L and -lfoo
makefoo.autolib.make_lib_flags-dynamic = 

makefoo.autolib.all-libs = \
	$(pkg-config_EXT_LIBS) \
	$(system_EXT_LIBS) \
	$(other_EXT_LIBS)

makefoo.autolib.pkg-config-libs = $(pkg-config_EXT_LIBS)

define makefoo.autolib.gather
makefoo.autolib.all-libs += $$($(1)_DEP_LIBS)
endef

define makefoo.autolib.template
ifeq (pkg-config,$$($(1)_TYPE))
makefoo.autolib.pkg-config-libs += $(1)
endif
endef


define makefoo.autolib.update_flags
#  $(1) - native component
#  $(1)_LINK_TYPE
ifdef $(1)_DEP_LIBS

$(1)_makefoo_autolibs_tsorted := $$(call makefoo.autolib.resolve-tsorted-dep-libs, $$($(1)_DEP_LIBS))
$(1)_makefoo_autolibs_pkg-config := $$(call makefoo.autolib.filter-pkg-config,$$($(1)_makefoo_autolibs_tsorted))
$(1)_makefoo_autolibs_other := $$(call makefoo.autolib.filter-other,$$($(1)_makefoo_autolibs_tsorted))

$(1)_makefoo_autolib_link_type := $$(if $$($(1)_LINK_TYPE),$$($(1)_LINK_TYPE),dynamic)

$(1)_CXXFLAGS += \
	$$(call makefoo.pkg-config,--cflags,$$($(1)_makefoo_autolibs_pkg-config)) \
	$$(call makefoo.autolib.custom_flags,CXXFLAGS,$$($(1)_makefoo_autolibs_other))
	
$(1)_CFLAGS += \
	$$(call makefoo.pkg-config,--cflags,$$($(1)_makefoo_autolibs_pkg-config)) \
	$$(call makefoo.autolib.custom_flags,CFLAGS,$$($(1)_makefoo_autolibs_other))

$(1)_LDFLAGS += \
	$$(call makefoo.autolib.custom_flags,LDFLAGS,$$($(1)_makefoo_autolibs_other))
	
$(1)_LIBS    += \
	$$(call makefoo.pkg-config,--libs,$$($(1)_makefoo_autolibs_pkg-config)) \
	$$(call makefoo.autolib.make_lib_flags-$$($(1)_makefoo_autolib_link_type),$$($(1)_makefoo_autolibs_other))

endif
endef

# gather all pkg-config libs from native components
# 

autolib_COMPONENTS_SORTED := $(sort $(COMPONENTS))

$(foreach component,$(autolib_COMPONENTS_SORTED),$(eval $(call makefoo.autolib.gather,$(component))))

$(foreach autolib,$(makefoo.autolib.all-libs),$(eval $(call makefoo.autolib.template,$(autolib))))

$(foreach component,$(autolib_COMPONENTS_SORTED),$(eval $(call makefoo.autolib.update_flags,$(component))))

# jedit: :tabSize=8:mode=makefile:

