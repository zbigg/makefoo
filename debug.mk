#
# makefoo debug module
#
# defines following targets
#
#  show NAME=var
#  show-outputs
#  show-defs
#
#  xxx-show-outputs
#  xxx-show-defs


show:
	@echo $($(NAME))


define debug_template

$(1)-show-outputs:
	@$$(foreach var,$$(sort $$(filter %_outputs, $$($(1)_debug_vars))), echo $$(var) = $$($$(var)) ; )

$(1)-show-defs:
	@$$(foreach var,$$(sort $$($(1)_debug_vars)), echo $$(var) = $$($$(var)) ; )
.PHONY: $(1)-vars $(1)-outputs

show-outputs: $(1)-show-outputs
show-defs: $(1)-show-defs
endef

show-defs:
	@$(foreach var,$(sort $(debug_vars)), echo $(var) = $($(var)) ; )
	
$(foreach component,$(sort $(COMPONENTS)),$(eval $(call debug_template,$(component))))

# jedit: :tabSize=8:mode=makefile:

