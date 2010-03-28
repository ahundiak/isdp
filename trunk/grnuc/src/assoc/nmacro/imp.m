SRC
$(GRNUC)/src/assoc/nmacro

CC
acc -knr

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

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

SOURCE
ACdb_info.S
ACdb_infoi.I

ACncpx.S
ACncpxi.I
ACndir.I
ACrep_sup.I
ACncpx_comp.I
ACncpxanal.I

ACconst.S
ACconstgrmsg.I
ACconsti.I
ACdrop.I
ACndrawing.I
ASelmhdbyelm.I
ASispthdbyel.I

ov_ci_mac.S
ov_ci_maci.I
ci_drop.I

nci_macro.S
nci_macroi.I

Gexp.S
Gtext_exp.S
ACpl_hold.S
ACpl_holdi.I

#ifndef NT
LIB
$(GRLIB)/lib/nmacro.o
#else
ARCHIVE
$(GRLIB)/lib/nmacro.lib
#endif


