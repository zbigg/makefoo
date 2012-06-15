#
# test
#

define test_program_template
# 1 - component name
# 2 - target type (PROGRAM, SHARED_LIBRARY, STATIC_LIBRARY)

# TBD, output to $(1)_objdir

$(1)_testdir := $$($(1)_builddir)/testdir
$(1)_LD_LIBRARY_PATH := $$LD_LIBRARY_PATH
$(1)_test_executable = $$(realpath $$($(1)_builddir)/$$($(1)_name))

$(1)-test: $$($(1)_outputs)
	mkdir -p $$($(1)_testdir)
	cd $$($(1)_testdir) && LD_LIBRARY_PATH="$(1)_LD_LIBRARY_PATH" $$($(1)_test_executable)

endef


TEST_PROGRAMS_sorted := $(sort $(TEST_PROGRAMS))
$(foreach test_program,$(TEST_PROGRAMS_sorted),$(eval $(call common_defs,$(test_program))))
$(foreach test_program,$(TEST_PROGRAMS_sorted),$(eval $(call test_program_template,$(test_program))))

PROGRAMS += $(TEST_PROGRAMS_sorted)

# jedit: :tabSize=8:mode=makefile:

