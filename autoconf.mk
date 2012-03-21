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

OMSBUILD_USE_AUTOCONF:=1
$(top_srcdir)/configure: $(top_srcdir)/configure.ac
	(cd $(srcdir); autoconf ; )

$(top_builddir)/config.status : $(top_srcdir)/configure
	(cd $(top_builddir) ; ./config.status --recheck ; )
	
Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
	(cd $(top_builddir) ; ./config.status ; )

# jedit: :tabSize=8:mode=makefile:

