
SRC
$(GRNUC)/src/co/cr

#ifdef IDRAW
ARCHIVE
$GRMDS/lib/cr.a

SOURCE
COelnptrtr.I   COniel2pts.C   DYcr3pt.C      DYelaxis.C
COnicircle.C   COniel3pts.C   DYcrcnt.C      DYelcnt.C
COnicr2pt.C    COnielaxis.C   DYcrdiam.C     DYelnpts.I
COnicr3pt.C    COnielcnt.C    DYcrrad.C
COnicrcnt.C    DYcircle.C     DYel2pts.C
COnicrdiam.C   DYcr2ptrad.C   DYel3pts.C

#else

#ifndef NT
LIB
$(GRLIB)/lib/cr.o
#else
ARCHIVE
$(GRLIB)/lib/cr.lib
#endif

SOURCE
COelnptrtr.I   COniel2pts.C   DYcr3pt.C      DYelaxis.C
COnicircle.C   COniel3pts.C   DYcrcnt.C      DYelcnt.C
COnicr2pt.C    COnielaxis.C   DYcrdiam.C     DYelnpts.I
COnicr3pt.C    COnielcnt.C    DYcrrad.C      COcrecrchd.C
COnicrcnt.C    DYcircle.C     DYel2pts.C     COnicrchd.I
COnicrdiam.C   DYcr2ptrad.C   DYel3pts.C     DYcrchd.I

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
acc -knr -O3

