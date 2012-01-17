  makefoo - gnu make more declarative
  ===================================

  makefoo is set of makefile templates that does similar
  job to automake, cmake, bakefile and other makefile generation
  tools. 

  You just declare high level description of C/C++ program
  and makefoo will build it for you.

  Features on target:
   - automatic dependency generation using gcc -MMD
   - C and C++ compilation
   - programs, static and shared libraries
   - support one makefile for several components
   - strict inter component dependencies
   - pkg_config support (as client and as provider)

  Wish features:
   - automatic rpm and deb generation

  Automatic source scan for needed objects:
   - i.e each source is tagged with // uses: component name or something
     and build system create object list from that
