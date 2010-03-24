SRC
$(EXNUC)/exec/wfi

SOURCE
IGEabsdigi.I
IGEdigwini.I
IGEinlisnri.I
IGEingeni.I
exerror.C
filters.C
keyin.C
messages.C
special.C
wfi.C
waitmsg.C
squeue.C
button.C

INCLUDE
$(EXNUC)/include
#if defined (ENV5)
$(FORMS_INC_PATH)
#elif defined (X11)
$(XFORMSDP_INC_PATH)
$(X11_INC_PATH)
#endif
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

SPEC
$(EXNUC)/spec

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp

