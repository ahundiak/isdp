
SRC
$(MODEL)/src_iforms

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

INCLUDE
$(MODEL)/src_iforms/include
$(INGRHOME)/include
$(XINC)
$(GRNUC)/ingrsys
$(MODEL)/include
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(BS)/include/prototypes
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec

SOURCE
#if defined (CLIX)
slider.c
fldpi.c
#endif
