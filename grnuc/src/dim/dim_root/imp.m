SOURCE

DMroot.S
root.I
compute.I
groverride.I
update.I
root_pret.I
feet.I

DMproot.S
proot.I

DMdim.S
dim.I

DManalyze.I
CC
acc -knr

SRC
$(GRNUC)/src/dim/dim_root

#ifndef NT
LIB
$(GRLIB)/lib/dim_root.o
#else
ARCHIVE
$(GRLIB)/lib/dim_root.lib
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
