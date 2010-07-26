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

COPT
-ga

CC
acc -knr

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

SRC
$(GRNUC)/src/co/textco

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/textco.o
#else
ARCHIVE
$(GRLIB)/lib/textco.lib
#endif

#else

ARCHIVE
$GRMDS/lib/textco.a

#endif

SOURCE
COchgtxattri.I
COdpemptytxi.I
COedittexti.I
COplytexti.I
COsvtxasfli.I
COtexti.I
COtxfrmfilei.I
COtxfrmtxeli.I
COtxinsesc.I
DYfittextdyn.I
DYtextdyn.I
COtxaleli.I
COcptxfljfi.I
GRtxparam.I
