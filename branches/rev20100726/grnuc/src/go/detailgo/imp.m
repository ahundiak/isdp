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

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

CC
acc -knr

COPT
-ga

SRC
$(GRNUC)/src/go/detailgo

#ifndef IDRAW
#ifndef NT
LIB
$(GRLIB)/lib/detailgo.o
#else
ARCHIVE
$(GRLIB)/lib/detailgo.lib
#endif


#else

ARCHIVE
$GRMDS/lib/detailgo.a

#endif

SOURCE
GRdvtansync.I
GRdvsyncfun.I
GRdvcsdisp.I
GRdvtanflag.c
GRdagetornt.I
GRactownmgri.I
GRdaattach.I
GRdacompadd.I
GRdacompdel.I
GRdacomppass.I
GRdaconstr.I
GRdacopydv.I
GRdacopyown.I
GRdadetach.I
GRdadisplay.I
GRdadropalgn.I
GRdadyself.I
GRdagenabsg.I
GRdagetalign.I
GRdagetdesc.I
GRdagetgeom.I
GRdagetid.I
GRdagetlabel.I
GRdagetmdmx.I
GRdagetscale.I
GRdalocate.I
GRdapostabsg.I
GRdaputdesc.I
GRdarealign.I
GRdascale.I
GRdaxformown.I
GRdbclearact.I
GRdbconstr.I
GRdbcopy.I
GRdbdyself.I
GRdbgetdesc.I
GRdblocate.I
GRdbputdesc.I
GRdbsetact.I
GRdrawsheeti.I
GRdrawviewi.I
GRdsborderi.I
GRdsclearact.I
GRdscmprem.I
GRdsconstr.I
GRdsdyself.I
GRdslocate.I
GRdssetact.I
GRdvaligni.I
GRdvattachi.I
GRdvclearact.I
GRdvcmprem.I
GRdvcompdis.I
GRdvconstr.I
GRdvcopydv.I
GRdvcsi.I
GRdvdrop.I
GRdvdyself.I
GRdvgetang.I
GRdvgrgrpi.I
GRdvlocate.I
GRdvsetact.I
GRdvcopy.I
GRdvadd.I
GRdscopy.I
GRdsadd.I
GRdvuphesym.I
