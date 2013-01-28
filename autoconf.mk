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

MAKEFOO_USE_AUTOCONF:=1


$(top_srcdir)/configure: $(top_srcdir)/configure.ac
	$(COMMENT) recreating configure
	$(EXEC) (cd $(srcdir); autoconf ; )

config.status : $(top_srcdir)/configure
	$(COMMENT) reconfiguring
	$(EXEC) ./config.status --recheck 

$(AUTOCONF_GENERATED_FILES): %: $(srcdir)/%.in | config.status
	$(COMMENT) recreating $@
	$(EXEC) ./config.status --quiet --file=$@

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
	$(AUTOCONF_AUX_DIR)/config.sub
        

#mkdirs ??

# jedit: :tabSize=8:mode=makefile:

