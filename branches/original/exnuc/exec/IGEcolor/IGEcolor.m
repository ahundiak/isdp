SRC
$(EXNUC)/exec/IGEcolor

SOURCE
APPcolor2i.I
IGEchgclr.I
IGEcolor2i.I
IGEcolortbl.I
IGEconclrtab.I
igecolmac.I
APPcolori.I
IGEcolori.I
IGEuserrampi.I
DPcolors.C

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

DEFINE
CCDEF

OPP
$(BASE)/bin/opp

OMCPP
$(BASE)/bin/omcpp
