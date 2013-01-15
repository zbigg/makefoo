#
# amalgamation.mk
#
# amalgamation build and/or unity build is useful
# when it is good to merge all source files of some components
# and compile them as one step
# (this requires well organized and idempotent headers)
# 
# unity-build described here:
#  - http://cheind.wordpress.com/2009/12/10/reducing-compilation-time-unity-builds/
# amalgamation concept name follows sqlite-amalgamation concept
#
# the actual implementation in amalgamation.pre.mk as
# it modifies definitions used
# by native module
#

# jedit: :tabSize=8:mode=makefile:

