SRC
$(MODEL)/src_util/graph
EXEC
$(MDTARG)/bin/graph
LINKLIB
#ifdef X11
#ifdef SUNOS5
-lX11
-lm
#else
#ifdef IRIX5
-lX11
#else
-lX11
#endif
#endif
#else
/lib/crt1.o
/usr/lib/libtools_s.a
/lib/libc_s.a
/lib/libm.a
/lib/crtn.o
#endif
#if defined (SUNOS)
CC
cc
#elif defined (SUNOS5)
CC
cc -O -Xa
#else
CC
acc -knr
#endif
COPT
-ga
INCLUDE
$(INGRHOME)/include
$(XINC)
$(GRNUC)/ingrsys
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include
$(MODEL)/proto_include
$(BS)/include
$(BS)/include/prototypes
SOURCE
graph.c
graphics.c
