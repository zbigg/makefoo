
# RPM always need release
ifeq ($(RELEASE),)
RPM_RELEASE=1
else
RPM_RELEASE=$(RELEASE)
endif

RPM_ARCH = $(shell uname -i)
#
# RPM build
#

#TBD:
#rpm_arg doesn't work because it needs a spec file
rpm_arg = $(shell rpmbuild -E %{$(1)} 2>/dev/null)

rpm_prefix=$(call rpm_arg,_prefix)
rpm_exec_prefix=$(call rpm_arg,_exec_prefix)
rpm_bindir=$(call rpm_arg,_bindir)
rpm_libdir=$(call rpm_arg,_libdir)
rpm_sysconfdir=$(call rpm_arg,_sysconfdir)
rpm_datadir=$(call rpm_arg,_datadir)
rpm_localstatedir=$(call rpm_arg,_localstatedir)

define rpm_template
# 1 - component name
# 2 - target type (PROGRAM, SHARED_LIBRARY, STATIC_LIBRARY)

# TBD, output to $(1)_objdir

$(1)_version     = dev
$(1)_rpm_name    =  $(1)-$$($(1)_version)-$(RPM_RELEASE).$(RPM_ARCH)
$(1)_rpm         := $$($(1)_builddir)/$$($(1)_rpm_name).rpm
$(1)_rpmbuilddir := $$($(1)_builddir)/.rpmbuild
$(1)_spec        := $$($(1)_rpmbuilddir)/SPECS/$(1).spec

$$($(1)_rpm): $$($(1)_outputs)
	@mkdir -p $$($(1)_rpmbuilddir)/SOURCES $$($(1)_rpmbuilddir)/SPECS $$($(1)_rpmbuilddir)/BUILD $$($(1)_rpmbuilddir)/RPMS
	
	$(COMMENT) [$1] creating spec file
	sed -e s/@VERSION@/$$($(1)_version)/ \
	    -e s/@RELEASE@/$(RPM_RELEASE)/   \
	    -e s/@COMPONENT@/$(1)/           \
	    -e s/@PRODUCT@/$(PRODUCT)/       \
	    $$(MAKEFOO)/rpm-spec-template.in > $$($(1)_spec)
	    
	$(COMMENT) "[$1] installing in staging area ($$($(1)_rpmbuilddir)/BUILDROOT/)"
	@rm -rf $$($(1)_rpmbuilddir)/BUILDROOT/
	$(MAKE) $(1)_install DESTDIR=$$($(1)_rpmbuilddir)/BUILDROOT/$$($(1)_rpm_name) \
		prefix=$(rpm_prefix)           \
		exec_prefix=$(rpm_exec_prefix) \
		conf_dir=$(rpm_conf_dir) \
		var_dir=$(rpm_var_dir)   \
		bindir=$(rpm_bindir)
		libdir=$(rpm_libdir) 
	
	$(COMMENT) [$1] creating $$($(1)_rpm)
	$(EXEC) rpmbuild --define "_topdir $$(abspath $$($(1)_rpmbuilddir))" -bb $$($(1)_spec)
	
	$(EXEC) mv $$($(1)_rpmbuilddir)/RPMS/$(RPM_ARCH)/$$($(1)_rpm_name).rpm $$($(1)_rpm)
	
	@rm -rf $$($(1)_rpmbuilddir)

$(1)_rpm: $$($(1)_rpm)
.PHONY: $(1)_rpm $$($(1)_rpm)

rpm_targets += $$($(1)_rpm)
endef

RPM_COMPONENTS_sorted := $(sort $(INSTALLABLE))

$(foreach component,$(RPM_COMPONENTS_sorted),$(eval $(call rpm_template,$(component))))

rpm: $(rpm_targets)

# jedit: :tabSize=8:mode=makefile:

