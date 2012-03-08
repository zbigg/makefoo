ifeq ($(QUIET),1)
VERBOSE=0
endif

ifeq ($(VERBOSE),1)
COMMENT=@true 
EXEC=
else
COMMENT=@echo 
EXEC=@
endif

#
# the not-autoconf build dir and build options
#

ifndef BUILD_TYPE
BUILD_TYPE=debug
endif

ifndef ARCH
ARCH=$(shell uname -m)
endif

build_name := $(BUILD_TYPE)-$(ARCH)
ifeq ($(COVERAGE),1)
build_name := $(build_name)-coverage
endif

ifeq ($(PROFILE),1)
build_name := $(build_name)-profile
endif

ifndef top_builddir
top_builddir = $(top_srcdir)/$(build_name)
endif

all: build

define common_defs
# 1 - component name
# 2 - component type (PROGRAM, SHARED_LIBRARY, STATIC_LIBRARY)

$(1)_builddir := $(top_builddir)/$$($(1)_DIR)
$(1)_srcdir   := $(top_srcdir)/$$($(1)_DIR)

# object files are keps in builddir/.target_type
# as one component can be built in 
# few ways
ifeq ($(2),SHARED_LIBRARY)
$(1)_objdir := $$($(1)_builddir)/.shobj
else
$(1)_objdir := $$($(1)_builddir)/.obj
endif

endef

COMPONENTS_sorted = $(sort $(COMPONENTS))

$(foreach component,$(COMPONENTS_sorted),$(eval $(call common_defs,$(program))))

# jedit: :tabSize=8:mode=makefile:

