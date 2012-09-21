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

ifndef localstatedir
localstatedir     := ${prefix}/var
endif

ifndef docdir
docdir            := $(datarootdir)/doc
endif

#
# install script for all targets that
# define X_lib_outputs
#

$(DESTDIR)$(libdir):
	mkdir -p $@

define install_fhs_libs
ifdef $(1)_lib_outputs

$(1)_install_lib: $$($(1)_lib_outputs) $$(DESTDIR)$(libdir)
	$$(INSTALL) $$($(1)_lib_outputs) $$(DESTDIR)$(libdir)

$(1)_install_targets += $(1)_install_lib

endif
endef

#
# install script for all targets that
# define X_bin_outputs
#
$(DESTDIR)$(bindir):
	mkdir -p $@

define install_fhs_programs
ifdef $(1)_bin_outputs

$(1)_install_bin: $$($(1)_bin_outputs) $$(DESTDIR)$(bindir)
	$$(INSTALL) $$($(1)_bin_outputs) $$(DESTDIR)$(bindir)

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
$(1)_install_files:
	for FILE in $$($(1)_FILES) ; do \
		dir="$$(DESTDIR)$$($(1)_INSTALL_DEST)/`dirname $$$$FILE`" ; \
		mkdir -pv $$$$dir ; \
		$(INSTALL_DATA)  "$(srcdir)/$$($(1)_DIR)/$$$$FILE" "$$$$dir" ; done

$(1)_install_targets      += $(1)_install_files

endif
ifdef $(1)_SCRIPTS
$(1)_install_scripts:
	for FILE in $$($(1)_SCRIPTS) ; do \
		dir="$$(DESTDIR)$$($(1)_INSTALL_DEST)/`dirname $$$$FILE`" ; \
		mkdir -pv $$$$dir ; \
		$(INSTALL)  "$(srcdir)/$$($(1)_DIR)/$$$$FILE" "$$$$dir" ; done

$(1)_install_targets      += $(1)_install_scripts
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

