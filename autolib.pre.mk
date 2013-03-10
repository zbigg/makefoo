
#
# makefoo AUTOLIBDEP engine
#

#
# Usage:
#   MAKEFOO_USE += autolib
# 
#   pkg-config_EXT_LIBS += pcre
#   system_EXT_LIBS     += pthread
#
#   some-program_EXT_LIBS += pcre thread
#
# Declare that program/library used EXT_LIBS:
#
#   program_EXT_LIBS = foo bar ...
#   library_EXT_LIBS = foo bar
#      dependent may also add some compilation/linking flags
#      link <program> or <shared library> with foo bar (and all of their dependecies)
#
# Register libraries to specific types:
#
#   pkg-config_EXT_LIBS += pcre
#     tell AUTOLIB engine, to obtain pcre C/C++/Linking flags from pkg-config
#
# libname_EXT_LIBS = dep_libname ...
#     ensures that all dependent libraries (and/or flags of them) will be linked
#     before actual 'libname'
#
# libname_LIBNAMES = foo bar
#     if file id/library name is different from "makefoo" internal lib-id
#     then one can change it by LIBNAMES
#     example: 
#       xyz_LIBNAMES = xyz-main xyz-sdl-plugin 
#       yields following option when linking (dynamically):
#          -lxyz-main -lxyz-sdl-plugin
#          (instead of default -lxyz)
#     note, many library names may be added
#
# libname_DIR=<where_libname_is_located>
#      required for static linking on some platforms
#      libraries from this folder will be passed to linker as arguments
#      example:
#         xyz_DIR=/build/sdk-1.2/lib
#         yields following option when linking statically:
#             /build/config-XYZ/lib/libxyz.a
#
# libname_LIBS=<flags> (defaults to just -llibname or libname.lib)
# libname_LDFLAGS=<flags>
# libname_CFLAGS=<flags>
# libname_CXXFLAGS=<flags>
#      custom, hardcoded library settings
#      the library will just append specific flags to particular build/compilation
#
# FUTURE/ideas:
# pkg-config_DEPS += libname -- not working
# 	# pkg-config --libs libname will be added to LDLIBS
# 	# pkg-config --libs libname will be added to C(XX)FLAGS
# 	# the library will be linked just as -lFOO foo.lib (msvs) at the end of list


makefoo.link-type ?= dynamic

#
# implementation
#

# get library names, use xxx_LIBNAMES
#  $(1) - library NAME
makefoo.autolib.lib-names=$(if $($(1)_LIBNAMES),$($(1)_LIBNAMES),$(1))

# call pkg-config $(1) $(2)
makefoo.pkg-config = $(if $(2),$(shell pkg-config $(1) $(2)),)

# calculate dependencies
#  $(1) - component
#  $(call makefoo.autolib.resolve-tsorted-dep-libs,COMPONENT_NAME)
#
# for each dep 
#   print edge lib->dep
#   recursiveal print all deps of dep
#    warning, cycles are not detected, make goes infinite loop here!!!
makefoo.autolib.tsort-echos-for-deps = $(foreach lib,$(1), \
    $(if $($(lib)_EXT_LIBS),\
        $(foreach dep,$($(lib)_EXT_LIBS),echo $(lib) $(dep); \
        $(call makefoo.autolib.tsort-echos-for-deps,$(dep))), \
        echo autolib-dummy-value $(lib); \
    ))
makefoo.autolib.resolve-tsorted-dep-libs = \
    $(filter-out autolib-dummy-value,\
	$(strip \
	    $(shell ( $(call makefoo.autolib.tsort-echos-for-deps,$(1)) ) | tsort )))
	
makefoo.autolib.filter-pkg-config = $(filter $(makefoo.autolib.pkg-config-libs),$(1))
makefoo.autolib.filter-no-pkg-config = $(filter-out $(makefoo.autolib.pkg-config-libs),$(1))

makefoo.autolib.all-libs = \
	$(pkg-config_EXT_LIBS) \
	$(system_EXT_LIBS) \
	$(other_EXT_LIBS)

makefoo.autolib.pkg-config-libs = $(pkg-config_EXT_LIBS)

define makefoo.autolib.gather
makefoo.autolib.all-libs += $$($(1)_EXT_LIBS)
endef

define makefoo.autolib.template
ifeq (pkg-config,$$($(1)_TYPE))
makefoo.autolib.pkg-config-libs += $(1)
endif
endef

define makefoo.autolib.pkg-config.template
$(1)_makefoo_cflags = $$(shell pkg-config --cflags $(1))
$(1)_makefoo_cxxflags = $$(shell pkg-config --cflags $(1))
$(1)_makefoo_libs-dynamic = $$(shell pkg-config --libs $(1))
$(1)_makefoo_libdir = $$(shell pkg-config --variable=libdir $(1))
$(1)_makefoo_libs-static = $$(patsubst %,$$($(1)_makefoo_libdir)/lib%.a,$$(call makefoo.autolib.lib-names,$(1)))
endef

define makefoo.autolib.normal.template
$(1)_makefoo_cflags =
$(1)_makefoo_cxxflags =
$(1)_makefoo_libs-dynamic = $$(if $$($(1)_LIBS),$$($(1)_LIBS),$$(patsubst %,-l%,$$(call makefoo.autolib.lib-names,$(1))))

ifeq (system,$$($(1)_TYPE))
    #
    # system libs are always linked "in default way"
    #
$(1)_makefoo_libs-static = $$(if $$($(1)_LIBS),$$($(1)_LIBS),$$(patsubst %,-l%,$$(call makefoo.autolib.lib-names,$(1))))
else
    #
    # for others, static link needs specified lib_DIR
    #
$(1)_makefoo_libdir = $$(if $$($(1)_DIR),$$($(1)_DIR),\
                            ./$$(error error $(1)_DIR not defined, it is required for non-system libs in STATIC build))
$(1)_makefoo_libs-static = $$(if $$($(1)_LIBS),$$($(1)_LIBS),$$(patsubst %,$$($(1)_makefoo_libdir)/lib%.a,$$(call makefoo.autolib.lib-names,$(1))))
endif

endef

# get variable of all EXT_LIBS of component
#  $(1) - component name
#  $(2) - dynamic|static

makefoo.each-ext-library-var = $(foreach lib,$($(1)_makefoo_autolibs_tsorted),$($(lib)_$(2)))

define makefoo.autolib.update_flags
#  $(1) - native component
#  $(1)_LINK_TYPE
ifdef $(1)_EXT_LIBS
#
# the big problem here is that pkg-config libs are mixed with rest
# normal libs are correctly sorted, but

$(1)_makefoo_autolibs_tsorted := $$(call makefoo.autolib.resolve-tsorted-dep-libs, $$($(1)_EXT_LIBS))
$(1)_makefoo_autolib_link_type := $$(if $$($(1)_LINK_TYPE),$$($(1)_LINK_TYPE),$(makefoo.link-type))

$(1)_CFLAGS   += $$(call makefoo.each-ext-library-var,$(1),makefoo_cflags)
$(1)_CXXFLAGS += $$(call makefoo.each-ext-library-var,$(1),makefoo_cxxflags)

$(1)_LIBS   += $$(call makefoo.each-ext-library-var,$(1),makefoo_libs-$$($(1)_makefoo_autolib_link_type))

endif # _EXT_LIBS

endef # makefoo.autolib.update_flags

# gather all pkg-config libs from native components
# 

autolib_COMPONENTS_SORTED := $(sort $(COMPONENTS))

# gather all libraries in
#   makefoo.autolib.pkg-config-libs
#   makefoo.autolib.all-libs

makefoo.autolib.normal-libs = $(sort $(call makefoo.autolib.filter-no-pkg-config, $(makefoo.autolib.all-libs))) 

$(foreach component,$(autolib_COMPONENTS_SORTED),$(eval $(call makefoo.autolib.gather,$(component))))
$(foreach autolib,$(makefoo.autolib.all-libs),$(eval $(call makefoo.autolib.template,$(autolib))))

# now create defs for
#  - pkg-config libs
$(foreach lib,$(makefoo.autolib.pkg-config-libs),$(eval $(call makefoo.autolib.pkg-config.template,$(lib))))
#  - normal libs
$(foreach lib,$(makefoo.autolib.normal-libs),$(eval $(call makefoo.autolib.normal.template,$(lib))))

# update target flags
$(foreach component,$(autolib_COMPONENTS_SORTED),$(eval $(call makefoo.autolib.update_flags,$(component))))

# jedit: :tabSize=8:mode=makefile:

