SRC
$(GRNUC)/src/assoc/nmacro_co

CC
acc -knr

SOURCE

COm_place.S
COm_place1.I
COm_place2.I
COm_place3.I
COm_place4.I
ASputobj.C
COm_disp_def.I

COm_crdef.S
COm_crdef1.I
COm_crdef2.I
COm_crdef3.I
COm_crdef4.I
COm_crdef5.I

COm_move.S
COm_move1.I
COm_move2.I
COm_move3.I
COm_move4.I

COm_modif.S
COm_modif1i.I
COm_modif2i.I
COm_modif3i.I
COm_modif4i.I

COm_lib.S
COm_libi.I
COm_option.I

COm_navig.S
COm_navigi.I

ASgradMac.S
ASfitGrad.I


#ifndef NT
LIB
$(GRLIB)/lib/nmacro_co.o
#else
ARCHIVE
$(GRLIB)/lib/nmacro_co.lib
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(XINC)
$(GRNUC)/src/assoc/include_priv
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
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
