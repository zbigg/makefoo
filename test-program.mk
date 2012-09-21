#
# test
#

ifdef VERBOSE
LCOV_QUIET=
else
LCOV_QUIET=-q
endif

define test_program_template
# 1 - component name
# 2 - target type (PROGRAM, SHARED_LIBRARY, STATIC_LIBRARY)

# TBD, output to $(1)_objdir

$(1)_testdir := $$($(1)_builddir)/testdir
$(1)_LD_LIBRARY_PATH := $$(LD_LIBRARY_PATH)
$(1)_test_executable = $$(realpath $$($(1)_builddir)/$$($(1)_name))
$(1)_tested_component_builddir = $$($($(1)_TESTED_COMPONENT)_builddir)
$(1)_tested_component_sources = $$(realpath $$($($(1)_TESTED_COMPONENT)_sources_rel))

$(1)-test: $$($(1)_outputs)
	mkdir -p $$($(1)_testdir)
	cd $$($(1)_testdir) && LD_LIBRARY_PATH="$$($(1)_LD_LIBRARY_PATH)" $$($(1)_test_executable) $$($(1)_TEST_INVOKE_ARGS)

$(1)_coverage_test_result := $$($(1)_builddir)/coverage-test-result.lcov
$(1)-coverage-test: $$($(1)_outputs)
	mkdir -p $$($(1)_testdir)
	$(EXEC) lcov $(LCOV_QUIET) --directory $$($(1)_tested_component_builddir) --zerocounters
	cd $$($(1)_testdir) && LD_LIBRARY_PATH="$$($(1)_LD_LIBRARY_PATH)" $$($(1)_test_executable) $$($(1)_TEST_INVOKE_ARGS)
	
	$(EXEC) lcov $(LCOV_QUIET) --test-name=$(1) --directory $$($(1)_tested_component_builddir) -b . --capture --output-file $$($(1)_coverage_test_result)
	$(EXEC) lcov $(LCOV_QUIET) --extract $$($(1)_coverage_test_result) $$($(1)_tested_component_sources) -o $$($(1)_coverage_test_result)
	$(EXEC) lcov $(LCOV_QUIET) --list $$($(1)_coverage_test_result)
#	$(EXEC) lcov --remove $$($(1)_coverage_test_result) "/usr/*" -o $$($(1)_coverage_test_result) 
	

coverage_trace_files += $$($(1)_coverage_test_result)
test: $(1)-test
coverage-test: $(1)-coverage-test
endef

coverage-test-report: coverage-test
	genhtml -o coverage-test-report $(coverage_trace_files)

TEST_PROGRAMS_sorted := $(sort $(TEST_PROGRAMS))

$(foreach test_program,$(TEST_PROGRAMS_sorted),$(eval $(call test_program_template,$(test_program))))


# jedit: :tabSize=8:mode=makefile:

