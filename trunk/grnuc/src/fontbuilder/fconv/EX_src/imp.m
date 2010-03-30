CC
$(COMPILER)

COPT
$(COMPOPT)

SRC
$(GRNUC)/src/fontbuilder/fconv/EX_src

#ifdef SUNOS_2.4
EXECOPT
-L /usr/5lib
#endif

SOURCE
FlibUtil.c
#if defined ( SUNOS ) || defined ( SUNOS5 )
Sunstub.c
#endif
string16.c

INCLUDE
$(INGRHOME)/include
$(GRNUC)/src/fontbuilder/fconv/include
$(BS)/include
$(EXNUC)/include
$(GRNUC)/include
$(BS)/proto_include
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

EXEC
$(GRLIB)/src/fontbuilder/bin/GRflibconv

LINKLIBS
$(GRLIB)/src/fontbuilder/fconv/Flib_src/FlibConv.o
$(GRLIB)/src/fontbuilder/fconv/Flib_src/FlibIo.o
$(GRLIB)/src/fontbuilder/fconv/lib/FS.a
$(GRLIB)/src/fontbuilder/fconv/UT_src/UTstring.o
$(GRLIB)/src/fontbuilder/fconv/UT_src/UTck_file.o
$(GRLIB)/src/fontbuilder/fconv/UT_src/UTvax_conv.o
$(GRLIB)/src/fontbuilder/fconv/FF_src/FFerror.o
#ifdef CLIX
#ifdef __cpu_c400__
/usr/lib/c400/libFS_s.a
-lm -lbsd -lc_s
#else
/usr/lib/c100/libFS_s.a
-lm -lbsd -lc_s
#endif
#endif
#ifdef SUNOS_2.4
$(GRLIB)/src/fontbuilder/fconv/UT_src/UTsun_conv.o
$(GRLIB)/libgpipe.a
-lXFS -lXFI -lm -ldl
/usr/lib/libXt.a /usr/lib/libX11.a
-lxc
-lxcmalloc
-lhlib
#endif
#ifdef SUNOS5
$(GRLIB)/src/fontbuilder/fconv/UT_src/UTsun_conv.o
-lXFS -lXFI -lm
-lXt -lX11 -lXext
-ldl -lw -lnsl -lsocket -lxc -lxcmalloc
#endif
#ifdef IRIX
$(GRLIB)/src/fontbuilder/fconv/UT_src/UTsun_conv.o
$(GRLIB)/libgpipe.a
-lXFS -lXFI -lm
/usr/lib/libXt.a /usr/lib/libX11.a
-lxc -lxcmalloc -lhlib
#endif
