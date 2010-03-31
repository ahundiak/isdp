EXEC
$(MODEL)/bin/dump_mf.x

CC
acc -knr

COPT 
-ga

SRC
$(PWD)

SOURCE
dump_bytes.c
dump_curve.c
dump_elem.c
dump_header.c
dump_soo.c
dump_surf.c
dump_util.c
main.c
scanner.c
stub.c

DEPLIB
$(MODEL)/hplot/src/hplot/HPdload.o
$(MODEL)/hplot/src/hplot/HPglobal.o
$(MODEL)/hplot/src/hplot/HPreader.o
$(MODEL)/hplot/src/hplot/HPread_surf.o
$(MODEL)/hplot/src/hplot/HPinit.o
$(MODEL)/hplot/src/hplot/HPread_ctbl.o
$(MODEL)/hplot/src/hplot/HPread_curv.o
$(MODEL)/hplot/src/hplot/HPread_soo.o
$(MODEL)/hplot/src/hplot/HPmessage.o
$(MODEL)/hplot/src/hplot/HPversion.o
$(MDTARG)/hsurf/src/co_func/HSrle_util.o

LINKLIB
#if defined (CLIX)
/usr/lib/c100/libxc.a
/usr/lib/libix.a
/usr/lib/libUMS.a
#else
-lUMS
#endif

INCLUDE
../include
$(BS)/include
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include
#if defined (X11)
$(XINC)
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif
#endif
