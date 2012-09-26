#
# rpm is created from package definitions
#
# example:
# 
#   foobar is application that consists of 4 components 
#     - fooctl, 
#     - food (daemon ;) )
#     - libfoo, libfoospam
#
# rpm definition should look like this:
# for everything in one rpm:
#
#  foo_COMPONENTS = fooctl food libfoo libfoospam
#  PACKAGES += foo
#
# and one, foocli rpm will be created that contain installment of all
# 4 components
#
# if one needs to create 4 packages, then define
#
# PACKAGES += fooctl food libfoo libfoospam
#
# and 4 rpms will be created :)
#
# the xxx_COMPONENTS = xxx is an implicit assumption
#
# RPM always need release
#
# Implementation status. "first level works ;)"
#
# $ rpm -qpi simple_autoconf_project_rpm_build/ddd-dev-1.i386.rpm
# Name        : ddd                          Relocations: (not relocatable)
# Version     : dev                               Vendor: (none)
# Release     : 1                             Build Date: Fri Apr  6 01:13:00 2012
# Install Date: (not installed)               Build Host: ubuntu-laptop
# Group       : System Environment/Daemons    Source RPM: ddd-dev-1.src.rpm
# Size        : 8068                             License: proprietary
# Signature   : (none)
# Summary     : - ddd
# Description :
# @@DESCRIPTION@@
# 
#  MUST define way to carry:
#   description
#   summary
#   version
#   release
#   licence
#   vendor (?)
#   rpm-group
#
# (before freezing, consult also deb list of major important fields in package)
ifeq ($(RELEASE),)
RPM_RELEASE=1
else
RPM_RELEASE=$(RELEASE)
endif

ifeq ($(VERBOSE),1)
RPMBUILD_FLAGS=
else
RPMBUILD_FLAGS=--quiet
endif

ifndef RPM_ARCH
RPM_ARCH = $(shell uname -m)
endif

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
$(1)_rpm_name    =  $(1)-$$($(1)_version)-$$(RPM_RELEASE).$$(RPM_ARCH)
$(1)_rpm         := $$($(1)_builddir)/$$($(1)_rpm_name).rpm
$(1)_rpmbuilddir := $$($(1)_builddir)/.rpmbuild
$(1)_spec        := $$($(1)_rpmbuilddir)/SPECS/$(1).spec

#
# if we have xxxx_COMPONENTS then use them, else just build
# rpm from xxxx
ifdef $(1)_COMPONENTS
$(1)_deps = $$($(1)_COMPONENTS)
$(1)_install_targets = $$(patsubst %,%_install, $$($(1)_COMPONENTS))
else
$(1)_deps = $$($(1)_outputs)
$(1)_install_targets = $(1)_install
endif

$$($(1)_rpm): $(MAKEFOO_dir)/rpm-spec-template.in
	@mkdir -p $$($(1)_rpmbuilddir)/SOURCES $$($(1)_rpmbuilddir)/SPECS $$($(1)_rpmbuilddir)/BUILD $$($(1)_rpmbuilddir)/RPMS
	
	$(COMMENT) "[$1]/rpm creating spec file"
	sed -e s/@VERSION@/$$($(1)_version)/ \
	    -e s/@RELEASE@/$(RPM_RELEASE)/   \
	    -e s/@COMPONENT@/$(1)/           \
	    -e s/@PRODUCT@/$(PRODUCT)/       \
	    $$(MAKEFOO_dir)/rpm-spec-template.in > $$($(1)_spec)
	    
	$(COMMENT) "[$1]/rpm installing in staging area [$$($(1)_rpmbuilddir)/BUILDROOT/$$($(1)_rpm_name)]"
	@rm -rf $$($(1)_rpmbuilddir)/BUILDROOT/
	$(EXEC) $(MAKE) $$($(1)_install_targets) DESTDIR=$$($(1)_rpmbuilddir)/BUILDROOT/$$($(1)_rpm_name) \
		prefix=$(rpm_prefix)           \
		exec_prefix=$(rpm_exec_prefix) \
		bindir=$(rpm_bindir)           \
		libdir=$(rpm_libdir)           \
		sysconfdir=$(rpm_sysconfdir)   \
		datadir=$(rpm_datadir)         \
		localstatedir=$(rpm_localstatedir) 
	
	$(COMMENT) "[$1]/rpm" creating $$($(1)_rpm)
	$(EXEC) rpmbuild $(RPMBUILD_FLAGS) --define "_topdir $$(abspath $$($(1)_rpmbuilddir))" -bb $$($(1)_spec)
	
	$(EXEC) mv $$($(1)_rpmbuilddir)/RPMS/$(RPM_ARCH)/$$($(1)_rpm_name).rpm $$($(1)_rpm)
	
	@rm -rf $$($(1)_rpmbuilddir)

$(1)_rpm: $$($(1)_rpm)
.PHONY: $(1)_rpm $$($(1)_rpm)

rpm_targets += $$($(1)_rpm)
endef

RPM_COMPONENTS_sorted := $(sort $(PACKAGES))

$(foreach component,$(RPM_COMPONENTS_sorted),$(eval $(call common_defs,$(component))))
$(foreach component,$(RPM_COMPONENTS_sorted),$(eval $(call rpm_template,$(component))))

rpm: $(rpm_targets)

# makefoo_amalgamation support:
rpm_MAKEFOO_DIST=rpm-spec-template.in

# jedit: :tabSize=8:mode=makefile:

