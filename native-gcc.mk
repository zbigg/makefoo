
# product/system defs

ifeq ($(BUILD_TYPE),debug)
build_type_CXXFLAGS = -g -O0
build_type_CFLAGS   = -g -O0
build_type_LDFLAGS  = -g
else
build_type_CXXFLAGS = -g -O2
build_type_CFLAGS   = -g -O2
build_type_LDFLAGS  = -g
endif

ifeq ($(COVERAGE),1)
features_CXXFLAGS += -fprofile-arcs -ftest-coverage
features_CFLAGS   += -fprofile-arcs -ftest-coverage
features_LDFLAGS  += -fprofile-arcs -ftest-coverage
endif

ifeq ($(PROFILE),1)
features_CXXFLAGS += -pg
features_CFLAGS   += -pg
features_LDFLAGS  += -pg
endif

# GNU defaults
ifndef CC
CC=$(TOOLSET_CC)
endif

ifndef CFLAGS
CFLAGS = $(build_type_CFLAGS)
endif

ifndef CXX
CXX=$(TOOLSET_CXX)
endif


ifndef AR
AR=ar
endif

ifndef CXXFLAGS
CFLAGS = $(build_type_CXXFLAGS)
endif
CFLAGS += $(features_CXXFLAGS)


ifndef CXXFLAGS
CXXFLAGS = $(build_type_CXXFLAGS)
endif
CXXFLAGS += $(features_CXXFLAGS)


ifndef LDFLAGS
LDFLAGS = $(build_type_LDFLAGS)
endif
LDFLAGS += $(features_LDFLAGS)

ifndef RANLIB
RANLIB=ranlib
endif

## C compilation
#
define c_template
# 1 - component name
# 2 - target type (PROGRAM, SHARED_LIBRARY, STATIC_LIBRARY)
# 3 - target obj sufix prog|shobj|stobj
#      (note, on most targets static lib obj == prog obj)
# TBD, output to $(1)_objdir

ifdef $(1)_c_sources_rel
$(1)_$(3)_c_sources_rel = $$($(1)_c_sources_rel)
else
$(1)_$(3)_c_sources_rel = $$(filter %.c, $$($(1)_sources_rel))
endif

ifndef $(1)_$(3)_c_objects 
$(1)_$(3)_c_objects = $$(patsubst $$(top_srcdir)/$$($(1)_DIR)/%.c, $$($(1)_objdir)/%.$(3).o, $$($(1)_$(3)_c_sources_rel))
endif

$(1)_$(3)_objects  += $$($(1)_$(3)_c_objects)
$(1)_$(3)_cflags    = $$($(1)_CFLAGS) $$($(2)_CFLAGS) $$(CFLAGS)

$(1)_objects    += $$($(1)_$(3)_c_objects)

$$($(1)_$(3)_c_objects): $$($(1)_objdir)/%.$(3).o: $(top_srcdir)/$$($(1)_DIR)/%.c
	mkdir -p $$($(1)_objdir)
	$(COMMENT) "[$1] compiling $$< ($(3))"
	$(EXEC) $$(CC) $$($(1)_$(3)_cflags) -c -o $$@ $$< 
endef

#
# xxx_LINK_DEPS = yyy zzz
#  - to build yyy & zzz before linking xxx
#  - to link xxx (library?program?) with outputs of yyy, xxx 
#  - yyy, xxx must be libraries
define link_deps

dupa=1
ifdef $(1)_LINK_DEPS
$(1)_link_deps_targets =   $$(foreach dep, $$($(1)_LINK_DEPS), $$($$(dep)_lib_outputs))
#$(1)_link_deps_link_dirs = $$(foreach dep, $$($(1)_LINK_DEPS), -L$$($$(dep)_builddir))
$(1)_link_deps_link_libs = $$($(1)_link_deps_targets)
endif

endef	
#
# C++ compilation
#

define cpp_template
# 1 - component name
# 2 - target type (PROGRAM, SHARED_LIBRARY, STATIC_LIBRARY)
# 3 - target type object tag
# TBD, output to $(1)_objdir

ifdef $(1)_cpp_sources_rel
$(1)_$(3)_cpp_sources_rel = $$($(1)_cpp_sources_rel)
else
$(1)_$(3)_cpp_sources_rel = $$(filter %.cpp, $$($(1)_sources_rel))
endif

ifndef $(1)_$(3)_cpp_objects 
$(1)_$(3)_cpp_objects = $$(patsubst $(top_srcdir)/$$($(1)_DIR)/%.cpp, $$($(1)_objdir)/%.$(3).o, $$($(1)_$(3)_cpp_sources_rel))
endif

$(1)_$(3)_objects    += $$($(1)_$(3)_cpp_objects)
$(1)_$(3)_cxxflags    = $$($(1)_CXXFLAGS) $$($(2)_CXXFLAGS) $$(CXXFLAGS)

$(1)_objects    += $$($(1)_$(3)_cpp_objects)

$$($(1)_$(3)_cpp_objects): $$($(1)_objdir)/%.$(3).o: $(top_srcdir)/$$($(1)_DIR)/%.cpp
	@mkdir -p $$(dir $$(@))
	$(COMMENT) "[$1] compiling $$< ($(3))"
	$(EXEC) $$(CXX) $$($(1)_$(3)_cxxflags) -c -o $$@ $$<
endef


#
# shared library
#
# builds .so or .dll from set of sources
#

#STATIC_LIBRARY_SUFFIX   := a

ifeq ($(SHARED_LIBRARY_MODEL),dll)
STATIC_LIBRARY_CXXFLAGS  = -D$(1)_STATIC
STATIC_LIBRARY_CFLAGS  = -D$(1)_STATIC
endif

ifeq ($(SHARED_LIBRARY_MODEL),dll)
SHARED_LIBRARY_CXXFLAGS  = -D$(1)_EXPORTS -fPIC
SHARED_LIBRARY_CFLAGS  = -D$(1)_EXPORTS -fPIC
else
SHARED_LIBRARY_CXXFLAGS = -fPIC
SHARED_LIBRARY_CFLAGS = -fPIC
endif

# TBD: dll support 
# TBD: in dll builddefine -D$(1)_EXPORTS
# SHARED_LIBRARY_SUFFIX := dll

define shared_library
# 1 - component name

$(1)_shlib_output = $$($(1)_builddir)/lib$$($(1)_name).$$(SHARED_LIBRARY_EXT)
$(1)_lib_outputs += $$($(1)_shlib_output)
$(1)_outputs += $$($(1)_shlib_output)

$(1)_ldflags := $$($(1)_LDFLAGS) \
	$$(LDFLAGS) \
	$$(sort $$($(1)_link_deps_link_dirs)) $$($(1)_link_deps_link_libs) \
	$$($(1)_LIBS) \
	$$(LIBS)

# link with CXX if there are any C++ sources in

ifneq ($$($(1)_shlib_cpp_objects),)
$(1)_linker=$$(CXX)
else
$(1)_linker=$$(CC)
endif

$$($(1)_shlib_output): $$($(1)_link_deps_targets)
$$($(1)_shlib_output): $$($(1)_shlib_objects)
	@mkdir -p $$($(1)_builddir)
	$(COMMENT) [$1] linking shared library $$@ using $$($(1)_linker) 
	$(EXEC) $$($(1)_linker) -shared  -o $$@ $$($(1)_shlib_objects) $$($(1)_ldflags)

endef

SHARED_LIBRARIES_sorted=$(sort $(SHARED_LIBRARIES))
NATIVE_COMPONENTS += $(SHARED_LIBRARIES_sorted)

$(foreach library,$(SHARED_LIBRARIES_sorted), $(eval $(call c_template,$(library),SHARED_LIBRARY,shlib)))
$(foreach library,$(SHARED_LIBRARIES_sorted), $(eval $(call cpp_template,$(library),SHARED_LIBRARY,shlib)))
$(foreach library,$(SHARED_LIBRARIES_sorted), $(eval $(call link_deps,$(library))))
$(foreach library,$(SHARED_LIBRARIES_sorted), $(eval $(call shared_library,$(library))))

#
# static library template
#
define static_library
# 1 - component name

$(1)_stlib_output  := $$($(1)_builddir)/lib$$($(1)_name).$$(STATIC_LIBRARY_EXT)
$(1)_lib_outputs += $$($(1)_stlib_output)
$(1)_outputs += $$($(1)_stlib_output)
$(1)_archiver=$(AR)

$$($(1)_stlib_output): $$($(1)_stlib_objects)
	@mkdir -p $$($(1)_builddir)
	$(COMMENT) [$1] creating static library $$@ using $$($(1)_archiver) 
	$(EXEC) $$($(1)_archiver) rcu $$@ $$^
	$(EXEC) $$(RANLIB) $$@

endef

STATIC_LIBRARIES_sorted=$(sort $(STATIC_LIBRARIES))
$(foreach library,$(STATIC_LIBRARIES_sorted), $(eval $(call c_template,$(library),STATIC_LIBRARY,stlib)))
$(foreach library,$(STATIC_LIBRARIES_sorted), $(eval $(call cpp_template,$(library),STATIC_LIBRARY,stlib)))
$(foreach library,$(STATIC_LIBRARIES_sorted), $(eval $(call static_library,$(library))))

NATIVE_COMPONENTS += $(STATIC_LIBRARIES_sorted)

ifneq ($(EXECUTABLE_EXT),)
PROGRAM_SUFFIX   := .$(EXECUTABLE_EXT)
endif

#
# native progam, will create an executable
# 
define program_template
# 1 - component name

$(1)_bin_outputs = $$($(1)_builddir)/$$($(1)_name)$(PROGRAM_SUFFIX)
$(1)_ldflags = $$($(1)_LDFLAGS) \
	$$(LDFLAGS) \
	$$(sort $$($(1)_link_deps_link_dirs)) $$($(1)_link_deps_link_libs) \
	$$($(1)_LIBS) \
	$$(LIBS)

# link with CXX if there are any C++ sources in

ifneq ($$($(1)_prog_cpp_objects),)
$(1)_linker=$$(CXX)
else
$(1)_linker=$$(CC)
endif

$$($(1)_bin_outputs): $$($(1)_link_deps_targets)
$$($(1)_bin_outputs): $$($(1)_objects)
	@mkdir -p $$($(1)_builddir)
	$(COMMENT) [$1] linking program $$@ using $$($(1)_linker) 
	$(EXEC) $$($(1)_linker) -o $$@ $$($(1)_objects) $$($(1)_ldflags)

$(1)_outputs += $$($(1)_bin_outputs)

endef

PROGRAMS_sorted=$(sort $(PROGRAMS))
NATIVE_COMPONENTS += $(PROGRAMS_sorted)

$(foreach program,$(PROGRAMS_sorted),$(eval $(call c_template,$(program),PROGRAM,prog)))
$(foreach program,$(PROGRAMS_sorted),$(eval $(call cpp_template,$(program),PROGRAM,prog)))
$(foreach program,$(PROGRAMS_sorted),$(eval $(call link_deps,$(program),PROGRAM,prog)))
$(foreach program,$(PROGRAMS_sorted),$(eval $(call program_template,$(program))))

define native_common
$(1): $$($(1)_outputs)

$(1)-clean clean-$(1):
	rm -rf $$($(1)_outputs) $$($(1)_objects) $$($(1)_d_files)

$(1)_d_files  = $$(patsubst %.o, %.d, $$($(1)_objects))

all_objects   += $$($(1)_objects)
all_outputs   += $$($(1)_outputs)
all_d_files   += $$($(1)_d_files)

endef

NATIVE_COMPONENTS_sorted = $(sort $(NATIVE_COMPONENTS))
$(foreach component,$(NATIVE_COMPONENTS_sorted),$(eval $(call native_common,$(component))))

DEFAULT_COMPONENTS += $(NATIVE_COMPONENTS_sorted)
COMPONENTS += $(NATIVE_COMPONENTS_sorted)

# jedit: :tabSize=8:mode=makefile:

