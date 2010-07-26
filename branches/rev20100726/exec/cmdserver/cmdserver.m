SRC
$(EXNUC)/exec/cmdserver

SPEC
$(EXNUC)/spec

#if defined (IRIX5)
OPPFLAGS
-I$(SRC)
-D_MIPS_ISA=_MIPS_ISA_MIPS2
#endif

INCLUDE
$(EXNUC)/include
$(UMS_INC_PATH)
#if defined (ENV5)
$(FORMS_INC_PATH)
#elif defined (X11)
$(HELPDP_INC_PATH)
$(X11_INC_PATH)
#endif
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

SOURCE
attach.C
detach.C
init.C
search.C
strip.C
quiet.C
cmdserveri.I 

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp
