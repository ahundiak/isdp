#
# This script creates dynamic library:	libIGmodel_debug.so
# from file:				objectlist_DYNAMIC
#
# To build a Model executable with dynamic MODEL library, use this:
# (remove Makefile && modelmakelib first!!)
#
# ln -s modelmakelib_DYN modelmakelib
#
# ln -s Makefile_DYN Makefile
#
ld -z text -G -o /opt/ingr/lib/libIGmodel_debug.so `cat ~/ems/model/objectlist_DYNAMIC`
