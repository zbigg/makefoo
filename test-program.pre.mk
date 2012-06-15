#
# feature test_progra_shortcutm
#
# synopsis
# component_TEST_SOURCES 
#  where component is any otherise defined
#  component (PROGRAM, STATIC_LIBRARY, SHARED_LIBRARY)
#
# targets:
#   component-test 
#       will run this test program
#   component-coverage-test 
#       will run this program
#

define test_shortcut_program_template
# 1 - component name
ifdef $(1)_TEST_SOURCES
$(1)_test_program_SOURCES := $$($(1)_TEST_SOURCES)
$(1)_test_program_DIR     := $$($(1)_DIR)
$(1)_test_program_TESTED_COMPONENT := $1

PROGRAMS      += $(1)_test_program
TEST_PROGRAMS += $(1)_test_program

endif
endef

test_shortcut_COMPONENTS=$(sort $(COMPONENTS) $(PROGRAMS) $(STATIC_LIBRARIES) $(SHARED_LIBRARIES))
$(foreach component,$(test_shortcut_COMPONENTS) ,$(eval $(call test_shortcut_program_template,$(component))))

TEST_PROGRAMS_sorted := $(sort $(TEST_PROGRAMS))
PROGRAMS += $(TEST_PROGRAMS_sorted)

#$(foreach test_program,$(TEST_PROGRAMS_sorted),$(eval $(call common_defs,$(test_program))))


# jedit: :tabSize=8:mode=makefile:

