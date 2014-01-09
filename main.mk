#
# omsbuild/main.mk
#
#    common rules applicable for all components
#

MAKEFOO_dir := $(shell dirname $(MAKEFOO))


# each module has up to 4 parts
# 
# module.reg.mk -- registration
#     it shall register components on global components lists
#     registrations may be public
#     most important is to register on
#     COMPONENTS
#      as example:
#       - native PROGRAMS, STATIC_LIBRARIES and SHARED_LIBRARIES will
#            register itself as COMPONENTS
#       - test-program will register auto-test-programs in 
#            PROGRAMS and in 
#            COMPONENTS 
#      it can or shall generate all pseudo targets
#
# then defs.mk is loaded and following definitions are available
#   $(xxx_builddir) - a folder with output files for component xxx (relative to top_builddir)
#   $(xxx_srcdir)   - a folder with source files for component xxx (relative to top_builddir)
#   $(xxx_objdir)   - intermediate files folder (relative to top_builddir)
#   $(xxx_DIR)      - component folder (relative to srcdir)
#   $(xxx_name)     - component name xxx or $(xxx_NAME)
#   
#  
# module.pre.mk
#     preprocessing and updating definitions
#     
# module.mk
#     main functionality of module. it shall emit rules
#     
# module.post.mk
#     
#
makefoo_reg_includes = $(patsubst %,$(MAKEFOO_dir)/%.reg.mk,$(MAKEFOO_USE))
makefoo_pre_includes = $(patsubst %,$(MAKEFOO_dir)/%.pre.mk,$(MAKEFOO_USE))
makefoo_main_includes = $(patsubst %,$(MAKEFOO_dir)/%.mk,$(MAKEFOO_USE))
makefoo_post_includes = $(patsubst %,$(MAKEFOO_dir)/%.post.mk,$(MAKEFOO_USE))

default: build

include $(MAKEFOO_dir)/int_helpers.mk
-include $(makefoo_reg_includes)

include $(MAKEFOO_dir)/defs.mk

-include $(makefoo_pre_includes)

include $(makefoo_main_includes)
-include $(makefoo_post_includes)

makefoo.build: $(all_outputs)
build: makefoo.build

makefoo.clean:
	rm -rf $(all_objects) $(all_outputs)
clean: makefoo.clean

$(top_builddir)/makefoo_configured_defs.mk: $(MAKEFOO_dir)/configure.sh
	@mkdir -p $(top_builddir)
	MAKEFOO_dir=$(MAKEFOO_dir) $(MAKEFOO_dir)/configure.sh > $@

include $(MAKEFOO_dir)/debug.mk

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

