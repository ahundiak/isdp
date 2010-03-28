INCLUDE
$(INGRHOME)/include
$(GRNUC)/src/fontbuilder/fconv/include
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

CC
acc -knr

COPT
-ga

SRC
$(GRNUC)/src/fontbuilder/fconv/CF_src

#ifdef SUNOS_2.4
EXECOPT
-L /usr/5lib
#endif

EXEC
$(GRLIB)/src/fontbuilder/bin/GRChFn

LINKLIB
$(GRLIB)/src/fontbuilder/fconv/Flib_src/FlibConv.o
$(GRLIB)/src/fontbuilder/fconv/Flib_src/FlibIo.o
$(GRLIB)/src/fontbuilder/fconv/lib/FS.a
$(GRLIB)/src/fontbuilder/fconv/UT_src/UTstring.o
$(GRLIB)/src/fontbuilder/fconv/UT_src/UTck_file.o
$(GRLIB)/src/fontbuilder/fconv/UT_src/UTvax_conv.o
$(GRLIB)/src/fontbuilder/fconv/FF_src/FFerror.o
$(GRLIB)/src/fontbuilder/fconv/EX_src/string16.o
#ifdef CLIX
#ifdef ENV5
#ifdef __cpu_c400__
/usr/lib/c400/libFS_s.a
-lm -lbsd -lc_s
#else
/usr/lib/c100/libFS_s.a
-lm -lbsd -lc_s
#endif
#else
$(GRNUC)/libgpipe.a
/usr/lib/c100/libFS_s.a
-ltools_s -lm -lPW -lg -lbsd -lc_s -ll -lc
/usr/lib/c100/crtn.o
#endif
#endif
#ifdef SUNOS_2.4
$(GRLIB)/src/fontbuilder/fconv/EX_src/Sunstub.o
$(GRLIB)/src/fontbuilder/fconv/UT_src/UTsun_conv.o
$(GRLIB)/libgpipe.a
-lXFS -lXFI -lm -dl
/usr/ip32/mgui/lib/libXt.a /usr/ip32/mgui/lib/libX11.a
-lxc -lxcmalloc -lhlib
#endif
#ifdef SUNOS5
$(GRLIB)/src/fontbuilder/fconv/EX_src/Sunstub.o
$(GRLIB)/src/fontbuilder/fconv/UT_src/UTsun_conv.o
-lXFS -lXFI -lm
/usr/openwin/lib/libXt.a /usr/openwin/lib/libX11.a /usr/openwin/lib/libXext.a
/usr/lib/libdl.so.1
/usr/lib/libw.so.1
/usr/lib/libnsl.so.1
/usr/lib/libsocket.so.1
-lxc -lxcmalloc
#endif
#ifdef IRIX
$(GRLIB)/src/fontbuilder/fconv/UT_src/UTsun_conv.o
$(GRLIB)/libgpipe.a
-lXFS -lXFI -lm
-lX11_s -lXt_s
-lxc
-lxcmalloc
-lhlib
#endif

SOURCE
FlibChFn.c
