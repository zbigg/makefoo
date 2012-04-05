
include $(top_builddir)/makefoo_configured_defs.mk

#USE_MAKEFOO_LOG=0

ifdef USE_MAKEFOO_LOG
LOG=$(MAKEFOO)/log.sh $(1)
endif

ifeq ($(QUIET),1)
VERBOSE=0
endif

ifeq ($(VERBOSE),1)
COMMENT=@true 
EXEC=$(LOG)
else
COMMENT=@$(LOG) echo 
EXEC=@$(LOG)
endif

#
# the not-autoconf build dir and build options
#

ifndef BUILD_TYPE
BUILD_TYPE=debug
endif

ifndef ARCH
ARCH=$(TARGET_ARCH)
endif

build_name := $(BUILD_TYPE)-$(ARCH)
ifeq ($(COVERAGE),1)
build_name := $(build_name)-coverage
endif

ifeq ($(PROFILE),1)
build_name := $(build_name)-profile
endif

ifndef srcdir
srcdir=.
endif

ifndef top_srcdir
top_srcdir = $(srcdir)
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
$(1)_objdir := $$($(1)_builddir)/.obj


endef

COMPONENTS_sorted = $(sort $(COMPONENTS))

$(foreach component,$(COMPONENTS_sorted),$(eval $(call common_defs,$(program))))

# jedit: :tabSize=8:mode=makefile:

