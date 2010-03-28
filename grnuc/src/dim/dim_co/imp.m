SOURCE

COdim.S
dim.I
COdmplace.S
dmplace.I
update.I
COanplace.S
anplace.I
gtforms.I
COdmcopy.S
dmcopy.I
COgtedit.S
gtedit.I
COchgter.S
chgter.I
COdimonoff.S
dimonoff.I
COweld.S
weldco.I
weldform.I
COsurf.S
surfco.I
surfform.I

CC
acc -knr

SRC
$(GRNUC)/src/dim/dim_co

#ifndef NT
LIB
$(GRLIB)/lib/dim_co.o
#else
ARCHIVE
$(GRLIB)/lib/dim_co.lib
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(XINC)
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

CC
cc 
