INCLUDE
#ifdef X11
$(XINC)
#endif
$(INGRHOME)/include
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include
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
acc -ansi
COPT
-ga
#ifdef SUNOS
EXECOPT
-L /usr/5lib
#endif
#ifdef IRIX
EXECOPT
-L $(INGRHOME)/lib
#endif
SRC
$(MODEL)/src_assem/revasm
#if defined( NT )
EXEC
$(GRLIB)binrevasm.exe
#else
EXEC
$(MDTARG)/bin/reviseassly
#endif
LINKLIB
#ifdef CLIX
#ifdef X11
-lUMS -lXFI_s -lXFS_s -lXt -lX11_s -lbsd -lm -lc_s
#endif
#ifdef ENV5
-lUMS -lforms_s -ltools_s -lm -lc_s
#endif
#endif
#if defined ( SUNOS ) || defined ( SUNOS5 )
-lUMS -lXFI -lXFS -lXt -lX11 -lm
#endif
#ifdef IRIX
-lUMS -lXFI -lXFS -lXt -lX11 -lm
#endif
#ifdef NT
$(SHAMROCK)libshamrock.lib
#endif
#ifdef NT
LINKOPT
-subsystem:windows
-entry:WinMainCRTStartup
#endif
SOURCE
GRgetprodata.c
GRingrhome.c
revasmmain.c
semphore.c
treeipc.c
