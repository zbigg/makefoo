

VERBOSE=@echo 
EXEC=@

#VERBOSE=@true 
#EXEC=

define common_defs
# 1 - component name
# 2 - component type (PROGRAM, SHARED_LIBRARY, STATIC_LIBRARY)

$(1)_builddir=$(top_builddir)/$$($(1)_DIR)
$(1)_srcdir=$(top_srcdir)/$$($(1)_DIR)

# object files are keps in builddir/.target_type
# as one component can be built in 
# few ways
ifneq ($(2),SHARED_LIBRARY)
$(1)_objdir=$$($(1)_builddir)/.shobj
else
$(1)_objdir=$$($(1)_builddir)/.obj
endif

endef

COMPONENTS_sorted = $(sort $(COMPONENTS))

$(foreach component,$(COMPONENTS_sorted),$(eval $(call common_defs,$(program))))

# jedit: :tabSize=8:mode=makefile:

