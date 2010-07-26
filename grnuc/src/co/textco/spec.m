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
$(GRLIB)/lib/textcosp.o
#else
ARCHIVE
$(GRLIB)/lib/textcosp.lib
#endif

#else

LIB
$GRMDS/lib/textcosp.o

#endif

SOURCE
COchgtxattr.S
COdpemptytx.S
COedittext.S
COplytext.S
COsvtxasfl.S
COtext.S
COtxfrmfile.S
COtxfrmtxel.S
COtxalel.S

#ifndef IDRAW
COcptxfljf.S
#endif       /* IDRAW */
