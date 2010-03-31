EXEC
$(MDTARG)/bin/dump_mf.x

CC
acc -knr

COPT 
-ga

SRC
$(MODEL)/hplot/src/dump

SOURCE
dump_bytes.c
dump_curve.c
dump_elem.c
dump_header.c
dump_soo.c
dump_surf.c
main.c
scanner.c
stub.c

LINKLIB
$(MDTARG)/hplot/src/hplot/HPdload.o
$(MDTARG)/hplot/src/hplot/HPglobal.o
$(MDTARG)/hplot/src/hplot/HPreader.o
$(MDTARG)/hplot/src/hplot/HPread_surf.o
$(MDTARG)/hplot/src/hplot/HPinit.o
$(MDTARG)/hplot/src/hplot/HPread_ctbl.o
$(MDTARG)/hplot/src/hplot/HPread_curv.o
$(MDTARG)/hplot/src/hplot/HPread_soo.o
$(MDTARG)/hplot/src/hplot/HPmessage.o
$(MDTARG)/hplot/src/hplot/HPversion.o
/usr/lib/c100/libxc.a
/usr/lib/libix.a
/usr/lib/libUMS.a

INCLUDE
$(BS)/include
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include
