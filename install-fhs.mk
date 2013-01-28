#
# installation using filesystem hierarchy standard
#
#

ifndef INSTALL
INSTALL     := install
endif

ifndef INSTALL_DATA
INSTALL_DATA     := $(INSTALL)
endif

INSTALL.file    = $(INSTALL_DATA)
INSTALL.program = $(INSTALL)
INSTALL.script  = $(INSTALL)
INSTALL.library = $(INSTALL_DATA)

ifndef prefix
prefix      := /usr/local
endif

ifndef exec_prefix
exec_prefix := ${prefix}
endif

ifndef bindir
bindir      := ${exec_prefix}/bin
endif

ifndef libdir
libdir      := ${exec_prefix}/lib
endif

ifndef sysconfdir
sysconfdir  := ${prefix}/etc
endif

ifndef datarootdir
datarootdir     := ${prefix}/share
endif

ifndef datadir
datadir  := ${datarootdir}
endif


ifndef localstatedir
localstatedir     := ${prefix}/var
endif

ifndef docdir
docdir            := $(datadir)/doc
endif

# $(call makefoo.install.XXXX,component,type,install_dir,files)
#   1 - component
#   2 - type file|executable|library|script
#   3 - install_dir
#   4 - files
#   5 - src-dir-prefix (if files are really in other dir, then append it)
#   
# makefoo.install.tree - respect original files tree
# makefoo.install.flat - flatten the tree
define makefoo.install.tree
$(EXEC) for FILE in $(4) ; do \
	dir="$(DESTDIR)$(3)/`dirname $$FILE`" ; \
	$(COMMENT_SHELL) [$(1)] install $(2) $(DESTDIR)$(3)/$$FILE ; \
	mkdir -p $$dir ; \
	$(INSTALL.$(2))  $(5)/$$FILE "$$dir" ; done
endef

define makefoo.install.flat
$(EXEC) for FILE in $(4) ; do \
	dir="$(DESTDIR)$(3)" ; \
	file="$$(basename $$FILE)" ; \
	$(COMMENT_SHELL) [$(1)] install $(2) $($(DESTDIR)$(3))/$$file ; \
	mkdir -p $$dir ; \
	$(INSTALL.$(2))  $(5)/$$FILE "$$dir" ; done
endef

#
# install script for all targets that
# define X_lib_outputs
#

$(DESTDIR)$(libdir):
	$(COMMENT) create installation folder $@
	$(EXEC) mkdir -p $@

define install_fhs_libs
ifdef $(1)_lib_outputs

$(1)_install_lib: $$($(1)_lib_outputs) $$(DESTDIR)$(libdir)
	$$(call makefoo.install.flat,$(1),library,$(libdir),$$($(1)_lib_outputs),.) 

$(1)_install_targets += $(1)_install_lib

endif
endef

#
# install script for all targets that
# define X_bin_outputs
#
$(DESTDIR)$(bindir):
	$(COMMENT) create installation folder $@
	$(EXEC) mkdir -p $@

define install_fhs_programs
ifdef $(1)_bin_outputs

$(1)_install_bin: $$($(1)_bin_outputs) $$(DESTDIR)$(bindir)
	$$(call makefoo.install.flat,$(1),program,$(bindir),$$($(1)_bin_outputs),.) 

$(1)_install_targets += $(1)_install_bin

endif
endef



#
# install script for all targets that
# define X_FILES and X_SCRIPTS
# installs them into X_INSTALL_DEST
#
define install_verbatim

ifdef $(1)_FILES
$(1)_install_files_src:  $$(call makefoo.static_files_rel,$(1),$$($(1)_FILES))
	$$(call makefoo.install.tree,$(1),file,$$($(1)_INSTALL_DEST), $$(call makefoo.static_files,$(1),$$($(1)_FILES)),$$($(1)_srcdir)) 

$(1)_install_files_generated: $$(call makefoo.generated_files,$(1),$$($(1)_FILES))
	$$(call makefoo.install.tree,$(1),file,$$($(1)_INSTALL_DEST),$$^,.) 

$(1)_install_targets      += $(1)_install_files_src $(1)_install_files_generated
endif

ifdef $(1)_SCRIPTS
$(1)_install_scripts_src:  $$(call makefoo.static_files_rel,$(1),$$($(1)_SCRIPTS))
	$$(call makefoo.install.tree,$(1),script,$$($(1)_INSTALL_DEST), $$(call makefoo.static_files,$(1),$$($(1)_SCRIPTS)),$$($(1)_srcdir)) 

$(1)_install_scripts_generated: $$(call makefoo.generated_files,$(1),$$($(1)_SCRIPTS))
	$$(call makefoo.install.tree,$(1),script,$$($(1)_INSTALL_DEST),$$^,.) 

$(1)_install_targets      += $(1)_install_scripts_src $(1)_install_scripts_generated
endif
endef

define install_common

ifdef $(1)_install_targets
$(1)_install: $$($(1)_install_targets)
install_targets += $$($(1)_install_targets)
endif

endef

# TBD, there must be other way to register
# installablbe items
INSTALLABLE+=\
	$(PUBLIC_COMPONENTS) \
	$(SHARED_LIBRARIES) \
	$(STATIC_LIBRARIES) \
	$(PROGRAMS)

INSTALLABLE_sorted = $(sort $(INSTALLABLE))

$(foreach component,$(INSTALLABLE_sorted), $(eval $(call install_fhs_programs,$(component))))
$(foreach component,$(INSTALLABLE_sorted), $(eval $(call install_fhs_libs,$(component))))
$(foreach component,$(INSTALLABLE_sorted), $(eval $(call install_verbatim,$(component))))
$(foreach component,$(INSTALLABLE_sorted), $(eval $(call install_common,$(component))))

install-fhs: $(install_targets)

install: install-fhs
.PHONY: install-fhs install

# jedit: :tabSize=8:mode=makefile:

