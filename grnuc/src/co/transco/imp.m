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

SRC
$(GRNUC)/src/co/transco

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/transco.o
#else
ARCHIVE
$(GRLIB)/lib/transco.lib
#endif

#else

ARCHIVE
$GRMDS/lib/transco.a

#endif

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

CC
acc -knr

SOURCE

COcvigeigdsi.I
COcvigdsigei.I
COcvtype2.I
COcvtype3.I
COcvtype4.I
COcvtype5.I
COcvtype5lv1.C
COcvtype5lv3.I
COcvtype5lv9.I
COcvtype6.I
COcvtype9.I
COcvtype1113.I
COcvtype1214.I

#ifndef IDRAW
COcvtype1819.I
COcvtype23.I
#endif

COcvtype22.I
COcvtype2427.I
COcvtype15.I
COcvtype16.I
COcvtype17.I
COcvunknown.I
COcvtclsli.I
COcvtcellib.I
COcvtclele.I
COcvtcltype5.I
COcvtcltype1.I
COcvtclt1.C
COcvtcltype2.I
GUgetname.C
GUputname.C
GUconstruct.I
GUattrlink.C
