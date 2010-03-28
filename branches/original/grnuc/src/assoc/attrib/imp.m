
CC
acc -knr

SRC
$(GRNUC)/src/assoc/attrib

SOURCE

ACdiowner.S
ACdiowneri.I

ACrg_collect.S
ACrg_coli.I
ACrg_coni.I

ACdyn_col.S
ACdyn_coli.I

COtable.S
COtablei.I
COpl_table.I

#ifndef NT
LIB
$(GRLIB)/lib/attrib.o
#else
ARCHIVE
$(GRLIB)/lib/attrib.lib
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
