#
# src-dist.mk
#

ifndef PRODUCT
endif
ifndef VERSION
endif

src_dist_folder=$(top_builddir)/$(PRODUCT)-$(VERSION)

$(src_dist_folder):
	@rm -rf $(src_dist_folder)
	@mkdir -p $(src_dist_folder)
.PHONY: $(src_dist_folder)
define src_dist_component
# $1 - component name

ifdef $(1)_SOURCES
src_dist_all_files += $$(patsubst %, $$($(1)_DIR)/%, $$($(1)_SOURCES))
endif

ifdef $(1)_FILES
src_dist_all_files += $$(patsubst %, $$($(1)_DIR)/%, $$($(1)_FILES))
endif

ifdef $(1)_SCRIPTS
src_dist_all_files += $$(patsubst %, $$($(1)_DIR)/%, $$($(1)_SCRIPTS))
endif

ifdef $(1)_EXTRA_DIST
src_dist_all_files += $$(patsubst %, $$($(1)_DIR)/%, $$($(1)_EXTRA_DIST))
endif

endef

$(foreach component,$(COMPONENTS_sorted),$(eval $(call src_dist_component,$(component))))

ifdef EXTRA_DIST
src_dist_all_files += $(EXTRA_DIST)
endif

ifneq ($(src_dist_all_files),)

src_dist_all_files_rel = $(patsubst %, $(top_srcdir)/%, $(sort $(src_dist_all_files)))

src-dist: $(src_dist_folder) $(src_dist_all_files_rel) 
	for file in $(src_dist_all_files) ; do \
		dir="$(src_dist_folder)/`dirname $$file`" ; \
		if [ ! -d $$dir ] ; then mkdir -p $$dir ; fi ; \
		cp  -p -fvr $(top_srcdir)/$$file $$dir/ ; \
	done
endif


# jedit: :tabSize=8:mode=makefile:

