#
# makefoo/autoconf.mk
#
#     rules to handle autoconf related artifacts up-to-date
#
# will keep up to date following:
#  configure
#  confif.status
#  Makefile
# (all in top_builddir)
#
#


$(srcdir)/configure: $(srcdir)/configure.ac
	$(COMMENT) recreating configure
	$(EXEC) (cd $(srcdir); autoconf ; )

config.status : $(srcdir)/configure
	$(COMMENT) reconfiguring
	$(EXEC) ./config.status --recheck 

$(AUTOCONF_GENERATED_FILES): %: $(srcdir)/%.in config.status $(srcdir)/configure
	$(COMMENT) recreating autoconf output $@
	$(EXEC) ./config.status --quiet $@
	@touch $@

ifndef AUTOCONF_AUX_DIR
AUTOCONF_AUX_DIR=.
endif

EXTRA_DIST += \
	configure.ac \
	configure \
	Makefile.in \
	$(patsubst $(srcdir)/%,%,$(wildcard $(srcdir)/$(AUTOCONF_AUX_DIR)/install-sh)) \
	$(patsubst $(srcdir)/%,%,$(wildcard $(srcdir)/$(AUTOCONF_AUX_DIR)/install.sh)) \
	$(AUTOCONF_AUX_DIR)/config.guess \
	$(AUTOCONF_AUX_DIR)/config.sub \
        $(patsubst %,%.in,$(AUTOCONF_GENERATED_FILES))

#mkdirs ??

# jedit: :tabSize=8:mode=makefile:

