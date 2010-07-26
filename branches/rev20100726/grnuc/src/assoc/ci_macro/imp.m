
SRC
$(GRNUC)/src/assoc/ci_macro

CC
acc -knr

INCLUDE
$(INGRHOME)/include
$(GRNUC)/src/assoc/include_priv
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

SOURCE
ci_mac_def.S
ci_mac_defi.I
cimd_proot.I

ci_macro.S
ci_macroi.I
ci_mac_prt.I

#ifndef NT
LIB
$(GRLIB)/lib/ci_macro.o
#else
ARCHIVE
$(GRLIB)/lib/ci_macro.lib
#endif

