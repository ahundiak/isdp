SRC
$(EXNUC)/exec/fontexec

INCLUDE
$(EXNUC)/include
$(FONTSERVE_INC_PATH)
#if defined (X11)
$(X11_INC_PATH)
#endif
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

SPEC
$(EXNUC)/om/spec
$(EXNUC)/exec/exec

SOURCE
FEchkrngspec.C
FEfontexec.C
FEmapaddfont.C
FEreadfont.C

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp


