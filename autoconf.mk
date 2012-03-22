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

# jedit: :tabSize=8:mode=makefile:

