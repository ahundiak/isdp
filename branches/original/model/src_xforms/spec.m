
SRC
$(MODEL)/src_xforms

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

INCLUDE
$(MODEL)/src_xforms/include
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
#if defined (IRIX)
gad_sym.c
#endif
#if defined (SUNOS5)
gad_sym.c
#endif
#if defined (INTEL)
gad_sym.c
drwtxt.c
fdelete.c
#endif
