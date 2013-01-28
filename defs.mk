
ifndef srcdir
srcdir=.
endif

ifndef top_builddir
top_builddir=$(srcdir)
endif

include $(top_builddir)/makefoo_configured_defs.mk

#USE_MAKEFOO_LOG=0

ifdef USE_MAKEFOO_LOG
LOG=$(MAKEFOO_dir)/log.sh $(1)
endif

ifeq ($(QUIET),1)
VERBOSE=0
endif

ifeq ($(VERBOSE),1)
COMMENT=@true
COMMENT_SHELL=true
EXEC=$(LOG)
else
COMMENT=@$(LOG) echo 
COMMENT_SHELL=$(LOG) echo
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

ifndef $(1)_DIR
$$(warning $(1)_DIR not defined, assuming . relative to srcdir)
$(1)_DIR=.
endif

$(1)_builddir := $(top_builddir)/$$($(1)_DIR)
$(1)_srcdir   := $(top_srcdir)/$$($(1)_DIR)
$(1)_objdir   := $$($(1)_builddir)/.obj
$(1)_name     := $$(if $$($(1)_NAME),$$($(1)_NAME),$(1))
$(1)_generated_files := $$(sort $$($(1)_GENERATED_SOURCES) $$($(1)_GENERATED_FILES) $(GENERATED_FILES))
$(1)_sources_rel := $$(call makefoo.relativize,$(1),$$($(1)_SOURCES) $$($(1)_FILES) $$($(1)_SCRIPTS))
endef

# $(call makefoo.static_files,component,file-list)
# $(call makefoo.generated_files,component,file-list)
#   get file list that is either "source" or "generated"
makefoo.static_files  = $(filter-out $($(1)_generated_files),$(2))
makefoo.generated_files = $(filter     $($(1)_generated_files),$(2))

# $(call makefoo.relativize,component,files)
#   convert paths of files in component dir
#   to build-dir relative
makefoo.relativize = \
	$(patsubst %, $($(1)_srcdir)/%, $(call makefoo.static_files,$(1), $(2))) \
	$(call makefoo.generated_files,$(1),$(2))

makefoo.static_files_rel = $(patsubst %, $($(1)_srcdir)/%, $(call makefoo.static_files_f,$(1), $(2)))

COMPONENTS_sorted = $(sort $(COMPONENTS) $(PUBLIC_COMPONENTS))

$(foreach component,$(COMPONENTS_sorted),$(eval $(call common_defs,$(component))))

# Disable implicit rules to speedup build
.SUFFIXES:
SUFFIXES :=
%.out:
%.a:
%.ln:
%.o:
%: %.o
%.c:
%: %.c
%.ln: %.c
%.o: %.c
%.cc:
%: %.cc
%.o: %.cc
%.C:
%: %.C
%.o: %.C
%.cpp:
%: %.cpp
%.o: %.cpp
%.p:
%: %.p
%.o: %.p
%.f:
%: %.f
%.o: %.f
%.F:
%: %.F
%.o: %.F
%.f: %.F
%.r:
%: %.r
%.o: %.r
%.f: %.r
%.y:
%.ln: %.y
%.c: %.y
%.l:
%.ln: %.l
%.c: %.l
%.r: %.l
%.s:
%: %.s
%.o: %.s
%.S:
%: %.S
%.o: %.S
%.s: %.S
%.mod:
%: %.mod
%.o: %.mod
%.sym:
%.def:
%.sym: %.def
%.h:
%.info:
%.dvi:
%.tex:
%.dvi: %.tex
%.texinfo:
%.info: %.texinfo
%.dvi: %.texinfo
%.texi:
%.info: %.texi
%.dvi: %.texi
%.txinfo:
%.info: %.txinfo
%.dvi: %.txinfo
%.w:
%.c: %.w
%.tex: %.w
%.ch:
%.web:
%.p: %.web
%.tex: %.web
%.sh:
%: %.sh
%.elc:
%.el:
(%): %
%.out: %
%.c: %.w %.ch
%.tex: %.w %.ch
%: %,v
%: RCS/%,v
%: RCS/%
%: s.%
%: SCCS/s.%
.web.p:
.l.r:
.dvi:
.F.o:
.l:
.y.ln:
.o:
.y:
.def.sym:
.p.o:
.p:
.txinfo.dvi:
.a:
.l.ln:
.w.c:
.texi.dvi:
.sh:
.cc:
.cc.o:
.def:
.c.o:
.r.o:
.r:
.info:
.elc:
.l.c:
.out:
.C:
.r.f:
.S:
.texinfo.info:
.c:
.w.tex:
.c.ln:
.s.o:
.s:
.texinfo.dvi:
.el:
.texinfo:
.y.c:
.web.tex:
.texi.info:
.DEFAULT:
.h:
.tex.dvi:
.cpp.o:
.cpp:
.C.o:
.ln:
.texi:
.txinfo:
.tex:
.txinfo.info:
.ch:
.S.s:
.mod:
.mod.o:
.F.f:
.w:
.S.o:
.F:
.web:
.sym:
.f:
.f.o:

# jedit: :tabSize=8:mode=makefile:

