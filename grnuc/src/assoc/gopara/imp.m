
SRC
$(GRNUC)/src/assoc/gopara

CC
acc -knr

SOURCE


ASby2ptsg.S
ASby2ptsgi.I

ASkeyseg.S
ASkeysegi.I


ASlinepara.S
ASlineparai.I

ASlineangl.S
ASlineangli.I

ASlinedbt.S
ASlinedbti.I

ASlineorth.S
ASlineorthi.I

ASintpt.S
ASintpti.I
ASindexpt.S
ASindexpti.I
ASindptwlim.S
ASindptwlimi.I
ASkeypt.S
ASkeypti.I
AScenpt.S
AScenpti.I
ASpointon.S
ASpointoni.I
AStangpt.S
AStangpti.I
AScspoint.S
AScspointi.I

ASref.S
ASwindref.S
ASwindrefi.I
ASby3ptref.S
ASby3ptrefi.I
ASbyzref.S
ASbyzrefi.I

AScontents.S
AScontentsi.I

AScircle.S
AScirclei.I

AScircnt.S
AScircnti.I
AScirpar.S
AScirpari.I

ASarc.S
ASarci.I

ASarccntrd.S
ASarccntrdi.I

angl_pm.S
angl_pmi.I
dist_pm.S
dist_pmi.I
radius_pm.S
radius_pmi.I

ASmodifier.S
ASmodifieri.I

ASmodbsp.S
ASmodbspi.I

ASextbsp.S
ASextbspi.I

ASrevbsp.S
ASrevbspi.I

ASmodlin.S
ASmodlini.I

ASdelseg.S
ASdelsegi.I

ASextseg.S
ASextsegi.I


ASsupport.I
ASpr_support.I
ASbs_support.I
inter_lib.I
ASmatrix.I
ciplace.I
any_create.I

#ifndef NT
LIB
$(GRLIB)/lib/gopara.o
#else
ARCHIVE
$(GRLIB)/lib/gopara.lib
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
