#
# makefoo src-dist module
#
# synopsis
#   Makefile:
#     MAKEFOO_USE += src-dist
#
#   invocation:
#     make src-dist
#     make distcheck
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
#   MAKEFOO_DISTCHECK_TARGETS 
#     these targets are executed when running distcheck targers
#     NOTE: test and install are default distcheck targets if used
#
# NOTE:
#   By default 'makefoo' used files are bundled in makefoo subdir of source
#   distribution.
#   ./configure script will detect and use this bundled version by default
#   use MAKEFOO_SRC_DIST_DONT_BUNDLE_MAKEFOO=1 to prevent bundling makefoo in src-dist)
#
# impl note: main implementation in src-dist.post.mk
#
#  


