SRC
$(EXNUC)/exec/shexec

SOURCE
exnucglobal.C

INCLUDE
$(EXNUC)/include
#if defined (X11)
$(X11_INC_PATH)
#endif
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

#ifdef IRIX5
OPPFLAGS
-I$(SRC)
-D_MIPS_ISA=_MIPS_ISA_MIPS2
#endif

OMCPP
$(BASE)/bin/omcpp
