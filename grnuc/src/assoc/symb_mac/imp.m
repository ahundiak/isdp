
SRC
$(GRNUC)/src/assoc/symb_mac

CC
acc -knr

SOURCE
ACmodel.S
ACmodeli.I
ACmodel_mgr.S
ACmodel_mgri.I
ACheader.S
ACheaderi.I
ACheadloc.I
ACheadfoot.I
ACheadgrmsg.I
ACheadndmsg.I
ACheadacmsg.I
ACSgen_funi.I
ACci_model.S
ACci_modeli.I

ACci_header.S
ACci_headeri.I

#ifndef NT
LIB
$(GRLIB)/lib/symb_mac.o
#else
ARCHIVE
$(GRLIB)/lib/symb_mac.lib
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(XINC)
$(GRNUC)/src/assoc/include_priv
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
