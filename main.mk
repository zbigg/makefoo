#
# omsbuild/main.mk
#
#    common rules applicable for all components
#

MAKEFOO_dir := $(shell dirname $(MAKEFOO))

include $(MAKEFOO_dir)/defs.mk

makefoo_pre_includes = $(patsubst %,$(MAKEFOO_dir)/%.pre.mk,$(MAKEFOO_USE))
#makefoo_main_includes = $(patsubst %,%.main.mk,$(MAKEFOO_USE))
makefoo_main_includes = $(patsubst %,$(MAKEFOO_dir)/%.mk,$(MAKEFOO_USE))
makefoo_post_includes = $(patsubst %,$(MAKEFOO_dir)/%.post.mk,$(MAKEFOO_USE))

default: build
-include $(makefoo_pre_includes)

include $(makefoo_main_includes)
-include $(makefoo_post_includes)

build: $(DEFAULT_COMPONENTS)

clean:
	rm -rf $(all_objects) $(all_outputs)

show:
	@echo $($(NAME))

$(top_builddir)/makefoo_configured_defs.mk: $(MAKEFOO_dir)/configure.sh
	@mkdir -p $(top_builddir)
	MAKEFOO_dir=$(MAKEFOO_dir) $(MAKEFOO_dir)/configure.sh > $@

ifndef MAKEFOO_USE_AUTOCONF

configure:
	@mkdir -p $(top_builddir)
	@rm $(top_builddir)/makefoo_configured_defs.mk
	@$(MAKE) $(top_builddir)/makefoo_configured_defs.mk
	@cat $(top_builddir)/makefoo_configured_defs.mk
endif

# makefoo_amalgamation support:
main_MAKEFOO_DIST=\
        autoconf_helpers/config.guess \
        configure.sh

# jedit: :tabSize=8:mode=makefile:

