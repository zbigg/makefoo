#
# makefoo "make" function helpers
#


# makefoo.echo_many_lines
#  echo multiline variable
#   $$(call makefoo.echo_many_lines,$(some_multiline_variable)) >> some_file
#
# NOTE, this real high on hacks
#  (credits: http://stackoverflow.com/questions/14760124/how-to-split-in-gnu-makefile-list-of-files-into-separate-lines)
 
makefoo.echo_many_lines = { $(subst ${makefoo.newline},' && echo ',echo '$(1)'); }

# makefoo.choose
#  choose first not empty value
#   $(call makefoo.choose2,X,Y)
#   $(call makefoo.choose3,X,Y,Z)
#   $(call makefoo.choose4,W,X,Y,Z)
makefoo.choose2=$(if $(1),$(1),$(2))
makefoo.choose3=$(if $(1),$(1),$(call makefoo.choose2,$(2),$(3)))
makefoo.choose4=$(if $(1),$(1),$(call makefoo.choose3,$(2),$(3),$(4)))

#
# some internal stuff
#

define makefoo.newline


endef

# jedit: :tabSize=8:mode=makefile:

