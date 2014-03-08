#
# log.mk
#

help::
	@echo "make VERBOSE=1            -- verbose mode - show all commands"
	@echo "make QUIET=1              -- quiet mode   - show only descriptive summary (default)"

ifdef USE_MAKEFOO_LOG
LOG=$(MAKEFOO_dir)/log.sh $(1)
endif

ifeq ($(QUIET),1)
VERBOSE=0
endif

ifeq ($(VERBOSE),1)
COMMENT=@true
COMMENT_SHELL=true
EXEC=$(LOG)
else
COMMENT=@$(LOG) echo 
COMMENT_SHELL=$(LOG) echo
EXEC=@$(LOG)
endif

# jedit: :tabSize=8:mode=makefile:

