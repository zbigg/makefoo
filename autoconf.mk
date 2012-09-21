#
# omsbuild/autoconf.mk
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
	(cd $(srcdir); autoconf ; )

config.status : $(top_srcdir)/configure
	./config.status --recheck 
	
Makefile: $(srcdir)/Makefile.in config.status
	./config.status

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

