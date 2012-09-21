#
# makefoo src-dist module
#
# synopsis
#   Makefile:
#     MAKEFOO_USE += src-dist
#
#   invocation:
#     make src-dist
#
# creates $(PRODUCT)-$(VERSION).tar.gz containing bundled
# source distribution in same layout as components in view
#
# input variables: 
#   PRODUCT - name of product, will name the archive
#   VERSION - the version, preferred form 1.2.3-3
#
#   $(component)_SOURCES
#   $(component)_FILES
#   $(component)_SCRIPTS
#   $(component)_EXTRA_DIST - bundle these files from $(top_srcdir)/$(component)_dir
#   
#   EXTRA_DIST - bundle also these (remap to $(top_srcdir))
#
# note: main implementation in src-dist.post.mk
#

