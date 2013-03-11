#
# TBD, reinvent new name for subst module
# TBD, hook for default build & clean target
# TBD, feature variable set in .reg.mk
# TBD, register key makefoo/common variables
#      to be automagically included in dist
#
# -----------------
#
# NOTE, this module is 100% makefoo-independent for now
# it would need some glue though
#
# subst
#   generate autoconf-like files with variable substitutions
# synopsis
#
#   subst_FILES += foo
#     creates following target:
#        foo: $(srcdir)/foo.in
#                SOME_SED_COMMAND $(srcdir)/foo.in > foo
#
#   subst_VARIABLES += VERSION_PATCH
#     register variables to be substituted in `subst`-ed files
#
# example:
#   subst_FILES += foo
#   subst_FILES += bar.h:bar.in
#
#   FOO=snafoo
#   BAR=barabum
#   srcdir=.
#
#   subst_VARIABLES += FOO BAR
#   subst_VARIABLES += srcdir
#
#

subst_get_target = $(firstword $(subst :, ,$(1)))
subst_get_source = $(if $(word 2,$(subst :, ,$(1))), \
                        $(srcdir)/$(word 2,$(subst :, ,$(1))), \
			$(srcdir)/$(word 1,$(subst :, ,$(1)).in))
define subst_template

$(call subst_get_target,$(1)): $(call subst_get_source,$(1))
	echo "generating $$<"
	sed  $$(subst_variable_sed_exprs) $$< > $$@

subst_generated_files += $(call subst_get_target,$(1))

endef

subst_variable_sed_exprs = \
$(foreach subst_var,$(sort $(subst_VARIABLES)),\
	-e s/@$(subst_var)@/$($(subst_var))/)

$(foreach subst_def,$(sort $(subst_FILES)),$(eval $(call subst_template,$(subst_def))))

makefoo.subst_files: $(subst_generated_files)

makefoo.subst_files_clean:
	rm -rf $(subst_generated_files)

clean: makefoo.subst_files_clean

