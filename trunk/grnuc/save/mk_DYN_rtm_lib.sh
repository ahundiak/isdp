#
# This script creates dynamic library:	libIGgrnuc_default.so
# from file:				objectlist_DYNAMIC
#
# To build a Model executable with dynamic GRNUC library, use this:
# (remove islmakelib first!!)
#
# ln -s islmakelib_DYN islmakelib
#
ld -z text -G -o /opt/ingr/lib/libIGgrnuc_default.so `cat ~/ems/grnuc/objectlist_DYNAMIC`

ld -r -o /usr2/grnuc34/lib/isl/ci_tiny.o	\
    /usr2/grnuc34/src/pplsrc/src/X86_fcall.o	\
    /usr2/grnuc34/src/pplsrc/src/ciextern.o
