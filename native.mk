#ifndef TOOLSET
#$(error TOOLSET not declared)
#endif

ifeq ($(TOOLSET),clang)
TOOLSET_impl=gcc
else
TOOLSET_impl=$(TOOLSET)
endif

ifdef TOOLSET
include $(MAKEFOO_dir)/native-$(TOOLSET_impl).mk
endif

# jedit: :tabSize=8:mode=makefile:

