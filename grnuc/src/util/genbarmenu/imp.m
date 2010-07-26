INCLUDE
#ifdef X11
$(XINC)
#endif
$(INGRHOME)/include
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

#ifdef SUNOS_2.4
EXECOPT
-L /usr/5lib
#endif

#ifdef IRIX
EXECOPT
-L $(INGRHOME)/lib
#endif

SRC
$(GRNUC)/src/util/genbarmenu

EXECUTABLE
$(GRLIB)/bin/genbarmenu

DEPLIB
$(GRLIB)/lib/utilmisc.a

LINKLIB
#ifdef CLIX
#ifdef X11
-lXFI_s -lXFS_s -lXt -lX11_s -lbsd -lm -lc_s
#endif
#ifdef ENV5
-lforms_s -ltools_s -lm -lc_s
#endif
#endif
#if defined ( SUNOS ) || defined ( SUNOS5 )
-lXFI -lXFS -lXt -lX11 -lm
#endif
#ifdef IRIX
-lXFI -lXFS -lXt -lX11 -lm
#endif
#ifdef NT
$(SHAMROCK)\lib\shamrock.lib
#endif

#ifdef NT
LINKOPT
-subsystem:windows
-entry:WinMainCRTStartup
#endif

SOURCE
genbarmenu.c
