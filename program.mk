###
### usage
###

# product/system defs
CC=gcc
CXX=g++
VERBOSE=@true
EXEC=@

define c_template
$(1)_c_sources = $$(filter %.c, $$($(1)_SOURCES))
$(1)_c_objects = $$(patsubst %.c, %.o, $$($(1)_c_sources))
$(1)_objects += $$($(1)_c_objects)
$(1)_cflags = $$($(1)_CFLAGS) $$(CFLAGS)
$$($(1)_c_objects): %.o: %.c
	$(VERBOSE) [$1] compiling $$<
	$(EXEC) $$(CC) $$($(1)_cflags) -c -o $$@ $$< 
endef

define cpp_template
$(1)_cpp_sources = $$(filter %.cpp, $$($(1)_SOURCES))
$(1)_cpp_objects = $$(patsubst %.cpp, %.o, $$($(1)_cpp_sources))
$(1)_objects += $$($(1)_cpp_objects)
$(1)_cxxflags = $$($(1)_CXXFLAGS) $$(CXXFLAGS)

$$($(1)_cpp_objects): %.o: %.cpp
	$(VERBOSE) [$1] compiling $$<
	$(EXEC) $$(CXX) $$($(1)_cxxflags) -c -o $$@ $$<
endef

define program_template
$(1)_output = $$($(1)_NAME)
$(1)_ldflags = $$($(1)_LDFLAGS) $$(LDFLAGS) $$($(1)_LIBS) $$(LIBS)

# link with CXX if there are any C++ sources in

ifneq ($$($(1)_cpp_objects),)
$(1)_linker=$$(CXX)
else
$(1)_linker=$$(CC)
endif

$$($(1)_output): $$($(1)_objects)
	$(VERBOSE) [$1] linking $$@ using $$($(1)_linker) 
	$(EXEC) $$($(1)_linker) -o $$@ $$< $$($(1)_ldflags)

all_objects   += $$($(1)_objects)
endef

PROGRAMS_sorted=$(sort $(PROGRAMS))

$(foreach program,$(PROGRAMS),$(eval $(call c_template,$(program))))
$(foreach program,$(PROGRAMS),$(eval $(call cpp_template,$(program))))
$(foreach program,$(PROGRAMS),$(eval $(call program_template,$(program))))

clean:
	rm -rf $(all_objects)
# jedit: :tabSize=8:mode=makefile:

help:
	echo $($(name))

