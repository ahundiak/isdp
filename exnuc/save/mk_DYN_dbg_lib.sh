#
# This script creates dynamic library:	libIGexnuc_debug.so
# from file:				objectlist_DYNAMIC
#
# To build a Model executable with dynamic EXNUC library, use this:
# (remove exnucmakelib first!!)
#
# ln -s exnucmakelib_DYN exnucmakelib
#
ld -z text -G -o /opt/ingr/lib/libIGexnuc_debug.so `cat ~/ems/exnuc/objectlist_DYNAMIC`
