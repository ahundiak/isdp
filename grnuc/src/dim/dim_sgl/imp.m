SOURCE

DMsglpara.S
sglpara_l.I
DMcirdia.S
cirdia_l.I
DMlindia.S
lindia_l.I

CC
acc -knr

SRC
$(GRNUC)/src/dim/dim_sgl

#ifndef NT
LIB
$(GRLIB)/lib/dim_sgl.o
#else
ARCHIVE
$(GRLIB)/lib/dim_sgl.lib
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(XINC)
$(BS)/include
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp
