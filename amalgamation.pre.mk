#
# amalgamation.pre.mk
#
# (see amalgamation.mk for description

# jedit: :tabSize=8:mode=makefile:



define c_amalgamation_template
# 1 - component name
ifdef $(1)_ENABLE_AMALGAMATION
ifdef $(1)_SOURCES
 
$(1)_amalgamation_c_sources_rel := $$(filter %.c, $$($(1)_sources_rel))
$(1)_amalgamation_c_source_file = $(1)_amalgamation_c.c

 
$$($(1)_amalgamation_c_source_file):
	$(COMMENT) "[$1] creating amalgamation file for C sources ($$@)"
	@mkdir -p $$($(1)_objdir)
	rm -rf $$@
	$(EXEC) for FILE in $$($(1)_amalgamation_c_sources_rel) ; do echo "#include \"$$$$FILE\"" ; done | tee $$@  

$(1)_c_sources_rel := $$($(1)_amalgamation_cpp_source_file)

endif # xxx_SOURCES
endif # xxx_AMALGAMATION
endef

define cpp_amalgamation_template
# 1 - component name
ifdef $(1)_ENABLE_AMALGAMATION
ifdef $(1)_SOURCES
$(1)_amalgamation_cpp_sources     := $$(filter %.cpp, $$($(1)_SOURCES))
$(1)_amalgamation_cpp_sources_rel := $$(filter %.cpp, $$($(1)_sources_rel))
$(1)_amalgamation_cpp_source_file = $(1)_amalgamation_cpp.cpp

 
$$($(1)_amalgamation_cpp_source_file):
	$(COMMENT) "[$1] creating amalgamation file for C++ sources ($$@)"
	@mkdir -p $$($(1)_objdir)
	@rm -rf $$@
	$(EXEC) for FILE in $$($(1)_amalgamation_cpp_sources_rel) ; do echo "#include \"$$$$FILE\"" ; done | tee $$@ 

$(1)_cpp_sources_rel := $$($(1)_amalgamation_cpp_source_file)
endif # xxx_SOURCES
endif # xxx_AMALGAMATION

endef

NATIVE_COMPONENTS2 += $(sort $(PROGRAMS) $(STATIC_LIBRARIES) $(SHARED_LIBRARIES))

$(foreach component,$(NATIVE_COMPONENTS2), $(eval $(call c_amalgamation_template,$(component))))
$(foreach component,$(NATIVE_COMPONENTS2), $(eval $(call cpp_amalgamation_template,$(component))))

# jedit: :tabSize=8:mode=makefile:

