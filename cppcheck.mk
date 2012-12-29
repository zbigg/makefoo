#
# cppcheck module for makefoo
#
# (COMPONENT list have to be filled, so main functionality in cppckeck.post.mk)
#
#
#
#
# usage Makefile:
#
#   MAKEFOO_USE=cppcheck
#
#   CPPCHECK_FLAGS     - to add custom global cppcheck flags
#   xxx_CPPCHECK_FLAGS - to add custom component specific cppcheck flags
#   
#   default flags (overridable)
#
#   MAKEFOO_CPPCHECK_FLAGS=--quiet --enable=all --template=gcc
#
# usage (invocation)
#
#   make cppcheck 
#     cppcheck on all defined C/C++sources
#
#   make xxx_cppcheck
#     cppcheck on C/C++ sources of component xxx



# jedit: :tabSize=8:mode=makefile:

