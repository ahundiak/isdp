SRC
$(GRNUC)/src/assoc/copara

CC 
acc -knr

SOURCE

COpara.S
COparai.I

COparaloc.S
COparaloci.I

COgraph_pt.S
COgraph_pti.I

COgbl_para.S
COgbl_parai.I

CO_hilite.S
CO_hilitei.I

COiterator.S
COiteratori.I
DYiterator.I

COeqpts.S
COeqptsi.I

COcspoint.S
COcspointi.I
DYcspoint.I

COparaparm.S
COparaparmi.I
DYpara.I
DYonlnpt.I
DYangl.I
DYcircnt_p.I
DYarc_p.I

COparadel.S
COparadeli.I

COparaext.S
COparaexti.I

COparapm.S
COparapmi.I

COchangroot.S
COchangrooti.I

COadd_opt.S
COadd_opti.I

COupdate.S
COupdatei.I

ASget_par.I
create_pm.I
ASfence.I

COchronos.S
COchronosi.I

#ifndef NT
LIB
$(GRLIB)/lib/copara.o
#else
ARCHIVE
$(GRLIB)/lib/copara.lib
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
