
INCLUDE
$(INGRHOME)/include
$(XINC)
/usr/ip32/lgdev/lg_libs
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
$(GRNUC)/src/lg/options

EXEC
$(GRLIB)/bin/.lgsetoptions

LINKLIB
#ifdef CLIX
#ifdef ENV5
-lforms_s -ltools_s -lmalloc -lm -lc_s
#endif
#endif
#ifdef SUNOS
-lXFI -lXFS -lxcmalloc -lm -lc /usr/ip32/mgui/lib/libXt.a /usr/ip32/mgui/lib/libX11.a
#endif
#ifdef IRIX
-lXFI -lXFS -lxcmalloc -lm -lc -lXt -lX11
#endif

SOURCE
lgsetoptions.c
