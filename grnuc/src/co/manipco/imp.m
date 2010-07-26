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
acc -knr -O3

COPT
-ga


SRC
$(GRNUC)/src/co/manipco

#ifdef IDRAW
ARCHIVE
$GRMDS/lib/manipco.a

#else

#ifndef NT
LIB
$(GRLIB)/lib/manipco.o
#else
ARCHIVE
$(GRLIB)/lib/manipco.lib
#endif

#endif

SOURCE
COchangei.I
COcharray.C
COchfunc.I
COcppar.I
COcpparali.I
COcptform.I
COdislocfun.I
COgsmanipi.I
COmanipi.I
COmnarray.C
COmnfunc.I
COtform.I
DYmirror.I
DYmirrorl.I
DYmove.I
DYrotate.I
#ifndef IDRAW
DYscale.I
#endif
