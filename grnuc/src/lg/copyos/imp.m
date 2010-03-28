INCLUDE
$(INGRHOME)/include
$(INGRHOME)/include
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
$(GRNUC)/src/lg/copyos

EXEC
$(GRLIB)/bin/cpOS

LINKLIB
#ifdef CLIX
#ifdef ENV5
/usr/ip32/lgdev/lg_libs/libapl.a /usr/ip32/lgdev/lg_libs/libaci.a /usr/ip32/lgdev/lg_libs/liblgft.a -lforms -lbsd
#endif
#endif
#ifdef SUNOS
/usr/ip32/lgdev/lg_libs/libapl.a /usr/ip32/lgdev/lg_libs/libaci.a /usr/ip32/lgdev/lg_libs/liblgft.a -lXFI -lXFS -lm -lc /usr/ip32/mgui/lib/libXt.a /usr/ip32/mgui/lib/libX11.a
#endif
#ifdef IRIX
/usr/ip32/lgdev/lg_libs/libapl.a /usr/ip32/lgdev/lg_libs/libaci.a /usr/ip32/lgdev/lg_libs/liblgft.a -lXFI -lXFS -lm -lc -lXt -lX11
#endif

SOURCE
cpOS.c
