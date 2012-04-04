#
# omsbuild/main.mk
#
#    common rules applicable for all components
#   
build: $(COMPONENTS)

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
	@rm $(top_builddir)/makefoo_configured_defs.mk
	@$(MAKE) $(top_builddir)/makefoo_configured_defs.mk
	@cat $(top_builddir)/makefoo_configured_defs.mk
endif

# jedit: :tabSize=8:mode=makefile:

