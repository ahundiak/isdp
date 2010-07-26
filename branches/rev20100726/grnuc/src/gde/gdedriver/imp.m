INCLUDE
$(INGRHOME)/include
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/ingrsys
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
$(GRNUC)/src/gde/gdedriver

#if defined( NT )
EXEC
$(GRLIB)/bin/gde.exe
#else
EXEC
$(GRLIB)/bin/gde
#endif

#if defined( IRIX )
EXECOPT
-L $(INGRHOME)/lib
#endif

LINKLIB
#ifdef CLIX
#ifdef ENV5
-lUMS -lforms_s -ltools_s -lmalloc -lm -lc_s
#endif
#endif
#if defined( SUNOS ) || defined( SUNOS5 ) || defined( IRIX )
-lUMS -lXFI -lXFS -lX11 -lxcmalloc -lm -lc
#endif
#ifdef NT
$(SHAMROCK)\lib\shamrock.lib
user32.lib
#endif

#ifdef NT
LINKOPT
-subsystem:windows
-entry:WinMainCRTStartup
#endif

SOURCE
main_main.c
chkerror.c
main_init.c
main_noti.c

