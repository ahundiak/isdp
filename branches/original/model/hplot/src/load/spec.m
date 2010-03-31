SRC
$(MODEL)/hplot/src/load

EXEC
$(MDTARG)/bin/load_mf.x

CC
acc -knr

COPT 
-ga

LINKLIB
$(MDTARG)/hplot/hplot/HPdload.o
/usr/lib/c100/libxc.a
/usr/lib/libix.a
/usr/lib/libUMS.a

INCLUDE
$(INGRHOME)/include
$(GRNUC)/ingrsys
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include

SOURCE
