SRC
$(EXNUC)/exec/igewindow

SOURCE
IGEaddgad.I
IGEclpicon.I
IGEcovicon.I
IGEdelicon.I
IGEmovicon.I
IGEgadgetsi.I
IGEwinconst.I
IGEdrwbrdr.I
IGEmanipwin.I
IGEldtrminfo.C
DPhdlevent.I
DPwnchgsiz.I
DPwncvtpnt.I
DPwnsetinq.I
DPwnaddgad.I

DPwnpasson.I
IGEwncons.I
DPwnclear.I
DPwnactivate.I
DPwndelete.I
DPwnmovicon.I
DPwncovicon.I
DPwnclpicon.I
igeinqmospos.C
IGEsractive.C

SPEC
$(EXNUC)/spec

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

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp

