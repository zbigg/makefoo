#
# installation using filesystem hierarchy standard
#
#

ifndef INSTALL
INSTALL     := install
endif

ifndef
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


define install_fhs_lib
$(1)_install_lib: $$($(1)_output) $$(DESTDIR)$(libdir)
	$$(INSTALL) $$($(1)_output) $$(DESTDIR)$(libdir)

install_targets += $(1)_install_lib
$(1)_install_targets += $(1)_install_lib
endef

$(DESTDIR)$(libdir):
	mkdir -p $@

define install_fhs_bin
$(1)_install_bin: $$($(1)_output) $$(DESTDIR)$(bindir)
	$$(INSTALL) $$($(1)_output) $$(DESTDIR)$(bindir)

install_targets += $(1)_install_bin
$(1)_install_targets += $(1)_install_bin
endef

define install_common
$(1)_install: $$($(1)_install_targets)
endef

define install_verbatim
$(1)_install_verbatim:

	set -x ; for FILE in $$($(1)_FILES) ; do \
		dir="$$(DESTDIR)$$($(1)_INSTALL_DEST)/`dirname $$$$FILE`" ; \
		mkdir -pv $$$$dir ; \
		$(INSTALL_DATA)  "$(srcdir)/$$($(1)_DIR)/$$$$FILE" "$$$$dir" ; done

	set -x ; for FILE in $$($(1)_SCRIPTS) ; do \
		dir="$$(DESTDIR)$$($(1)_INSTALL_DEST)/`dirname $$$$FILE`" ; \
		mkdir -pv $$$$dir ; \
		$(INSTALL)  "$(srcdir)/$$($(1)_DIR)/$$$$FILE" "$$$$dir" ; done

install_targets      += $(1)_install_verbatim
$(1)_install_targets += $(1)_install_verbatim

endef

$(DESTDIR)$(bindir):
	mkdir -p $@

# TBD, there must be other way to register
# installablbe items
INSTALLABLE=\
	$(SHARED_LIBRARIES) \
	$(STATIC_LIBRARIES) \
	$(PROGRAMS)

INSTALLABLE_sorted = $(sort $(INSTALLABLE))

$(foreach library,$(SHARED_LIBRARIES_sorted), $(eval $(call install_fhs_lib,$(library))))
$(foreach library,$(STATIC_LIBRARIES_sorted), $(eval $(call install_fhs_lib,$(library))))
$(foreach program,$(PROGRAMS_sorted), $(eval $(call install_fhs_bin,$(program))))
$(foreach component,$(INSTALLABLE_sorted), $(eval $(call install_common,$(component))))
$(foreach verbatim,$(INSTALL_VERBATIM), $(eval $(call install_verbatim,$(verbatim))))

install-fhs: $(install_targets)

install: install-fhs
.PHONY: install-fhs install

# jedit: :tabSize=8:mode=makefile:

