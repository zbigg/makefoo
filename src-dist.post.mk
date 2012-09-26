#
# src-dist.mk
#

ifndef PRODUCT
endif
ifndef VERSION
endif

src_dist_name=$(PRODUCT)-$(VERSION)

src_dist_tgz_name=$(src_dist_name).tar.gz
src_dist_zip_name=$(src_dist_name).zip

src_dist_folder=$(top_builddir)/$(src_dist_name)

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

define makefoo_component_files
makefoo_dist_files_abs += \
        $$(wildcard $(MAKEFOO_dir)/$(1).pre.mk) \
        $$(wildcard $(MAKEFOO_dir)/$(1).mk) \
        $$(wildcard $(MAKEFOO_dir)/$(1).post.mk) \
        $$(patsubst %, $$(MAKEFOO_dir)/%, $$($(1)_MAKEFOO_DIST)) 
endef

ifndef MAKEFOO_SRC_DIST_DONT_BUNDLE_MAKEFOO

$(foreach makefoo_component, $(MAKEFOO_USE) main defs, $(eval $(call makefoo_component_files,$(makefoo_component))))

makefoo_dist_files_rel = $(patsubst $(MAKEFOO_dir)/%,%, $(makefoo_dist_files_abs))

#$(src_dist_folder):
#	@rm -rf $(src_dist_folder)
#	@mkdir -p $(src_dist_folder) 
	
src-dist-makefoo: $(src_dist_folder) $(makefoo_dist_files_abs)
	$(COMMENT) copying MAKEFOO files to distribution folder $(src_dist_folder)/makefoo
	$(EXEC) for file in $(makefoo_dist_files_rel) ; do \
		dir="$(src_dist_folder)/makefoo/`dirname $$file`" ; \
		if [ ! -d $$dir ] ; then mkdir -p $$dir ; fi ; \
		cp  -p -fvr $(MAKEFOO_dir)/$$file $$dir/ ; \
	done
else
src-dist-makefoo:
endif
#.PHONY: src-dist-makefoo


ifneq ($(src_dist_all_files),)

src_dist_all_files_rel = $(patsubst %, $(top_srcdir)/%, $(sort $(src_dist_all_files)))


src-dist: $(src_dist_folder) $(src_dist_all_files_rel) src-dist-makefoo	
	$(COMMENT) copying $(PRODUCT) files to distribution folder $(src_dist_folder)
	$(EXEC) for file in $(src_dist_all_files) ; do \
		   dir="$(src_dist_folder)/`dirname $$file`" ; \
		   if [ ! -d $$dir ] ; then mkdir -p $$dir ; fi ; \
		   cp  -p -fvr $(top_srcdir)/$$file $$dir/ ; \
	   done
	$(COMMENT) creating archive $(src_dist_tgz_name)
	$(EXEC) tar chzf $(src_dist_tgz_name) $(src_dist_folder)
	$(EXEC) rm -rf $(src_dist_folder)	
endif


# jedit: :tabSize=8:mode=makefile:
