#
# cppcheck module for makefoo
#
# usage Makefile:
#
#   MAKEFOO_USE=cppcheck
#
#   CPPCHECK_FLAGS     - to add custom global cppcheck flags
#   xxx_CPPCHECK_FLAGS - to add custom component specific cppcheck flags
#   
#   default flags (overridable)
#
#   MAKEFOO_CPPCHECK_FLAGS=--quiet --enable=all --template=gcc
#
# usage (invocation)
#
#   make cppcheck 
#     cppcheck on all defined C/C++sources
#
#   make xxx_cppcheck
#     cppcheck on C/C++ sources of component xxx
#
#
# MAKEFOO cppcheck defaults convienient for author
#  - gcc error mode
#  - enable all errors
#  - be quiet, show only results 
#

ifndef MAKEFOO_CPPCHECK_FLAGS 
MAKEFOO_CPPCHECK_FLAGS=--quiet --enable=all --template gcc
endif

ifndef CPPCHECK
CPPCHECK=cppcheck
endif

define cppcheck_template

ifdef $(1)_SOURCES

$(1)_c_sources_rel = $$(filter %.c, $$($(1)_sources_rel))
$(1)_cpp_sources_rel = $$(filter %.cpp, $$($(1)_sources_rel))   

ifneq ($$($(1)_c_sources_rel),)

$(1)_c_source_flags=$$($(1)_CFLAGS) $$(CFLAGS)
$(1)_c_cppcheck_flags=$$(filter -D*, $$($(1)_c_source_flags)) $$(filter -I%, $$($(1)_c_source_flags)) $$($(1)_CPPCHECK_FLAGS) $(CPPCHECK_FLAGS)

$(1)_debug_vars += $(1)_c_cppcheck_flags
$(1)_c_cppcheck:
	$(COMMENT) "[$1] cppcheck C sources" 
	$(EXEC) $(CPPCHECK) $(MAKEFOO_CPPCHECK_FLAGS) $$($(1)_c_cppcheck_flags) $$($(1)_c_sources_rel)

$(1)_cppcheck: $(1)_c_cppcheck 
cppcheck: $(1)_c_cppcheck

endif # c sources

ifneq ($$($(1)_cpp_sources_rel),)

$(1)_cpp_source_flags=$$($(1)_CXXFLAGS) $$(CXXFLAGS)
$(1)_cpp_cppcheck_flags=$$(filter -D*, $$($(1)_cpp_source_flags)) $$(filter -I%, $$($(1)_cpp_source_flags)) $$($(1)_CPPCHECK_FLAGS) $(CPPCHECK_FLAGS)

$(1)_debug_vars += $(1)_cpp_cppcheck_flags

$(1)_cpp_cppcheck:
	$(COMMENT) "[$1] cppcheck C++ sources"
	$(EXEC) $(CPPCHECK) $(MAKEFOO_CPPCHECK_FLAGS) $$($(1)_cpp_cppcheck_flags) $$($(1)_cpp_sources_rel)

$(1)_cppcheck: $(1)_cpp_cppcheck	
cppcheck: $(1)_cpp_cppcheck

endif # cpp sources

endif # $(1)_SOURCES
endef

CPPCHECK_COMPONENTS_sorted = $(sort $(COMPONENTS))

$(foreach component,$(CPPCHECK_COMPONENTS_sorted),$(eval $(call cppcheck_template,$(component))))


# jedit: :tabSize=8:mode=makefile:

