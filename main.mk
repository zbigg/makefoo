#
# omsbuild/main.mk
#
#    common rules applicable for all components
#   
all: $(COMPONENTS)

clean:
	rm -rf $(all_objects) $(all_outputs)

show:
	@echo $($(NAME))
	
# jedit: :tabSize=8:mode=makefile:

