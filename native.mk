
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
build_type_CXXFLAGS += -fprofile-arcs -ftest-coverage
build_type_CFLAGS   += -fprofile-arcs -ftest-coverage
build_type_LDFLAGS  += -fprofile-arcs -ftest-coverage
endif

ifeq ($(PROFILE),1)
build_type_CXXFLAGS += -pg
build_type_CFLAGS   += -pg
build_type_LDFLAGS  += -pg
endif

# GNU defaults
ifndef CC
CC=gcc
endif

ifndef CFLAGS
CFLAGS = $(build_type_CFLAGS)
endif

ifndef CXX
CXX=g++
endif


ifndef CXX
AR=ar
endif

ifndef CXXFLAGS
CXXFLAGS = $(build_type_CXXFLAGS)
endif

ifndef LDFLAGS
LDFLAGS = $(build_type_LDFLAGS)
endif

ifndef RANLIB
RANLIB=ranlib
endif

#
# C compilation
#
define c_template
# 1 - component name
# 2 - target type (PROGRAM, SHARED_LIBRARY, STATIC_LIBRARY)

# TBD, output to $(1)_objdir
$(1)_c_sources = $$(filter %.c, $$($(1)_SOURCES))
$(1)_c_sources_rel = $$(patsubst %.c, $$(top_srcdir)/$$($(1)_DIR)/%.c, $$($(1)_c_sources))
$(1)_c_objects = $$(patsubst $$(top_srcdir)/$$($(1)_DIR)/%.c, $$($(1)_objdir)/%.o, $$($(1)_c_sources_rel))
$(1)_objects  += $$($(1)_c_objects)
$(1)_cflags    = $$($(1)_CFLAGS) $$($(2)_CFLAGS) $$(CFLAGS)
$(1)_d_files  += $$(patsubst %.o, %.d, $$($(1)_c_objects))

$$($(1)_c_objects): $$($(1)_objdir)/%.o: $(top_srcdir)/$$($(1)_DIR)/%.c
	@mkdir -p $$($(1)_objdir)
	$(COMMENT) [$1] compiling $$<
	$(EXEC) $$(CC) $$($(1)_cflags) -c -o $$@ $$< 
endef

#
# C++ compilation
#

define cpp_template
# 1 - component name
# 2 - target type (PROGRAM, SHARED_LIBRARY, STATIC_LIBRARY)

# TBD, output to $(1)_objdir

$(1)_cpp_sources = $$(filter %.cpp, $$($(1)_SOURCES))
$(1)_cpp_sources_rel = $$(patsubst %.cpp, $(top_srcdir)/$$($(1)_DIR)/%.cpp, $$($(1)_cpp_sources))
$(1)_cpp_objects =$$(patsubst $(top_srcdir)/$$($(1)_DIR)/%.cpp, $$($(1)_objdir)/%.o, $$($(1)_cpp_sources_rel))
$(1)_objects    += $$($(1)_cpp_objects)
$(1)_cxxflags    = $$($(1)_CXXFLAGS) $$($(2)_CXXFLAGS) $$(CXXFLAGS)
$(1)_d_files    += $$(patsubst %.o, %.d, $$($(1)_cpp_objects))

$$($(1)_cpp_objects): $$($(1)_objdir)/%.o: $(top_srcdir)/$$($(1)_DIR)/%.cpp
	@mkdir -p $$($(1)_objdir)
	$(COMMENT) [$1] compiling $$<
	$(EXEC) $$(CXX) $$($(1)_cxxflags) -c -o $$@ $$<
endef


#
# shared library
#
# builds .so or .dll from set of sources
#

STATIC_LIBRARY_SUFFIX   := a
SHARED_LIBRARY_CXXFLAGS  = -D$(1)_STATIC

SHARED_LIBRARY_SUFFIX   := so
SHARED_LIBRARY_CXXFLAGS  = -fPIC

# TBD: dll support 
# TBD: in dll builddefine -D$(1)_EXPORTS
# SHARED_LIBRARY_SUFFIX := dll

define shared_library
# 1 - component name

$(1)_output  := $$($(1)_builddir)/lib$$($(1)_NAME).$$(SHARED_LIBRARY_SUFFIX)
$(1)_ldflags := $$($(1)_LDFLAGS) $$(LDFLAGS) $$($(1)_LIBS) $$(LIBS)

# link with CXX if there are any C++ sources in

ifneq ($$($(1)_cpp_objects),)
$(1)_linker=$$(CXX)
else
$(1)_linker=$$(CC)
endif

$$($(1)_output): $$($(1)_objects)
	@mkdir -p $$($(1)_builddir)
	$(COMMENT) [$1] linking shared library $$@ using $$($(1)_linker) 
	$(EXEC) $$($(1)_linker) -shared  -o $$@ $$^ $$($(1)_ldflags)

all_objects   += $$($(1)_objects)
all_outputs   += $$($(1)_output)
all_d_files   += $$($(1)_d_files)

$(1): $$($(1)_output)

$(1)-clean clean-$(1):
	rm -rf $$($(1)_output) $$($(1)_objects) $$($(1)_d_files)

endef

SHARED_LIBRARIES_sorted=$(sort $(SHARED_LIBRARIES))
COMPONENTS += $(SHARED_LIBRARIES_sorted)

$(foreach library,$(SHARED_LIBRARIES_sorted), $(eval $(call common_defs,$(library),SHARED_LIBRARY)))
$(foreach library,$(SHARED_LIBRARIES_sorted), $(eval $(call c_template,$(library),SHARED_LIBRARY)))
$(foreach library,$(SHARED_LIBRARIES_sorted), $(eval $(call cpp_template,$(library),SHARED_LIBRARY)))
$(foreach library,$(SHARED_LIBRARIES_sorted), $(eval $(call shared_library,$(library))))

#
# static library template
#
define static_library
# 1 - component name

$(1)_output  := $$($(1)_builddir)/lib$$($(1)_NAME).$$(STATIC_LIBRARY_SUFFIX)

$(1)_archiver=$(AR)

$$($(1)_output): $$($(1)_objects)
	@mkdir -p $$($(1)_builddir)
	$(COMMENT) [$1] creating static library $$@ using $$($(1)_archiver) 
	$(EXEC) $$($(1)_archiver) rcu $$@ $$^ $$($(1)_ldflags)
	$(EXEC) $$(RANLIB) $$@

all_objects   += $$($(1)_objects)
all_outputs   += $$($(1)_output)
all_d_files   += $$($(1)_d_files)

$(1): $$($(1)_output)

$(1)-clean clean-$(1):
	rm -rf $$($(1)_output) $$($(1)_objects) $$($(1)_d_files)

endef

STATIC_LIBRARIES_sorted=$(sort $(STATIC_LIBRARIES))

$(foreach library,$(STATIC_LIBRARIES_sorted),$(eval $(call common_defs,$(library),STATIC_LIBRARY)))
$(foreach library,$(STATIC_LIBRARIES_sorted), $(eval $(call c_template,$(library),STATIC_LIBRARY)))
$(foreach library,$(STATIC_LIBRARIES_sorted), $(eval $(call cpp_template,$(library),STATIC_LIBRARY)))
$(foreach library,$(STATIC_LIBRARIES_sorted),   $(eval $(call static_library,$(library))))

COMPONENTS += $(STATIC_LIBRARIES_sorted)

#
# native progam, will create an executable
# 
define program_template
# 1 - component name

$(1)_output = $$($(1)_builddir)/$$($(1)_NAME)
$(1)_ldflags = $$($(1)_LDFLAGS) $$(LDFLAGS) $$($(1)_LIBS) $$(LIBS)

# link with CXX if there are any C++ sources in

ifneq ($$($(1)_cpp_objects),)
$(1)_linker=$$(CXX)
else
$(1)_linker=$$(CC)
endif

$$($(1)_output): $$($(1)_objects)
	@mkdir -p $$($(1)_builddir)
	$(COMMENT) [$1] linking program $$@ using $$($(1)_linker) 
	$(EXEC) $$($(1)_linker) -o $$@ $$^ $$($(1)_ldflags)

all_objects   += $$($(1)_objects)
all_outputs   += $$($(1)_output)
all_d_files   += $$($(1)_d_files)

$(1): $$($(1)_output)

$(1)-clean clean-$(1):
	rm -rf $$($(1)_output) $$($(1)_objects) $$($(1)_d_files)

endef

PROGRAMS_sorted=$(sort $(PROGRAMS))
COMPONENTS += $(PROGRAMS_sorted)

$(foreach program,$(PROGRAMS_sorted),$(eval $(call common_defs,$(program),PROGRAM)))
$(foreach program,$(PROGRAMS_sorted),$(eval $(call c_template,$(program),PROGRAM)))
$(foreach program,$(PROGRAMS_sorted),$(eval $(call cpp_template,$(program),PROGRAM)))
$(foreach program,$(PROGRAMS_sorted),$(eval $(call program_template,$(program))))


# jedit: :tabSize=8:mode=makefile:

