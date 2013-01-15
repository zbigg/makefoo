#ifndef TOOLSET
#$(error TOOLSET not declared)
#endif
ifdef TOOLSET
include $(MAKEFOO_dir)/native-$(TOOLSET).mk
endif

# jedit: :tabSize=8:mode=makefile:

