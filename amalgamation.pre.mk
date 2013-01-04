#
# unity.pre.mk
#
# (see unity.mk for description

# jedit: :tabSize=8:mode=makefile:



define c_unity_template
# 1 - component name
ifdef $(1)_SOURCES
$(1)_unity_c_sources     := $$(filter %.c, $$($(1)_SOURCES))
$(1)_unity_c_sources_rel := $$(patsubst %.c, $$(top_srcdir)/$$($(1)_DIR)/%.c, $$($(1)_unity_c_sources))
$(1)_unity_c_source_file = $$($(1)_objdir)/$(1)_amalgamation_c.c

 
$$($(1)_unity_c_source_file):
	$(COMMENT) "[$1] creating unity file for C sources ($$@)"
	@mkdir -p $$($(1)_objdir)
	rm -rf $$@
	$(EXEC) for FILE in $$($(1)_unity_c_sources_rel) ; do echo "#include \"$$$$FILE\"" ; done | tee $$@  

$(1)_c_sources_rel := $$($(1)_unity_cpp_source_file)

endif # xxx_SOURCES
endef

define cpp_unity_template
# 1 - component name
ifdef $(1)_SOURCES
$(1)_unity_cpp_sources     := $$(filter %.cpp, $$($(1)_SOURCES))
$(1)_unity_cpp_sources_rel := $$(patsubst %.cpp, $$(top_srcdir)/$$($(1)_DIR)/%.cpp, $$($(1)_unity_cpp_sources))
$(1)_unity_cpp_source_file = $$($(1)_objdir)/$(1)_amalgamation_cpp.cpp

 
$$($(1)_unity_cpp_source_file):
	$(COMMENT) "[$1] creating unity file for C++ sources ($$@)"
	@mkdir -p $$($(1)_objdir)
	@rm -rf $$@
	$(EXEC) for FILE in $$($(1)_unity_cpp_sources_rel) ; do echo "#include \"$$$$FILE\"" ; done | tee $$@ 

$(1)_cpp_sources_rel := $$($(1)_unity_cpp_source_file)
endif # x xxx_SOURCES

endef

NATIVE_COMPONENTS2 += $(sort $(PROGRAMS) $(STATIC_LIBRARIES) $(SHARED_LIBRARIES))

$(foreach component,$(NATIVE_COMPONENTS2), $(eval $(call c_unity_template,$(component))))
$(foreach component,$(NATIVE_COMPONENTS2), $(eval $(call cpp_unity_template,$(component))))

# jedit: :tabSize=8:mode=makefile:

