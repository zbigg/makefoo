#
# omsbuild/main.mk
#
#    common rules applicable for all components
#   

include $(MAKEFOO)/defs.mk

makefoo_pre_includes = $(patsubst %,$(MAKEFOO)/%.pre.mk,$(MAKEFOO_USE))
#makefoo_main_includes = $(patsubst %,%.main.mk,$(MAKEFOO_USE))
makefoo_main_includes = $(patsubst %,$(MAKEFOO)/%.mk,$(MAKEFOO_USE))
makefoo_post_includes = $(patsubst %,$(MAKEFOO)/%.post.mk,$(MAKEFOO_USE))

default: build
-include $(makefoo_pre_includes)

include $(makefoo_main_includes)
-include $(makefoo_post_includes)

build: $(DEFAULT_COMPONENTS)

clean:
	rm -rf $(all_objects) $(all_outputs)

show:
	@echo $($(NAME))

$(top_builddir)/makefoo_configured_defs.mk: $(MAKEFOO)/configure.sh
	@mkdir -p $(top_builddir)
	MAKEFOO=$(MAKEFOO) $(MAKEFOO)/configure.sh > $@

ifndef MAKEFOO_USE_AUTOCONF

configure:
	@mkdir -p $(top_builddir)
	@rm $(top_build `																                                                                                            dir)/makefoo_configured_defs.mk
	@$(MAKE) $(top_builddir)/makefoo_configured_defs.mk
	@cat $(top_builddir)/makefoo_configured_defs.mk
endif

# jedit: :tabSize=8:mode=makefile:

