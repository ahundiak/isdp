CC
acc -knr

COPT
-ga

EXECUTABLE
$(GRTARG)/bin/checkcmds

SRC
$(GRNUC)/src/util/checkcmds

SOURCE
checkcmds.c

INCLUDE
#if defined (SUNOS54)
/usr/ucbinclude
#endif
