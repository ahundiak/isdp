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
$(GRNUC)/src/go/supfungo

#ifdef IDRAW

ARCHIVE
$GRMDS/lib/supfungo.a

#else

#ifndef NT
LIB
$(GRLIB)/lib/supfungo.o
#else
ARCHIVE
$(GRLIB)/lib/supfungo.lib
#endif


#endif

SOURCE
GRaccrange.C
GRbtreesup.I
GRbuildprism.C
GRclipfun.I
GRcopyconn.I
GRgetNODobj.I
GRgetglobmgr.I
GRgetwndmx.C
GRlcpath.C
GRlocsupport.C
GRmakegs.I
GRmodscale.C
GRparsename.C
GRprismhelp.C
GRretcellib.C
GRsendsib.C
