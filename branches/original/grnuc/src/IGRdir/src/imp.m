SRC
$(GRNUC)/src/IGRdir/src

#ifdef IDRAW
ARCHIVE
$GRMDS/lib/srcI.a

SOURCE
COdirmode.C    COremove.C     DIstring.c
COdirxlate.C   FIdirformi.I   COmkdir.C
COshownm.C     COrmdir.C      COcd.C
DIlocate.I     super_diri.I

VERSION
$GRMDS/lib/srcI.a	1.3.0

#else

#ifndef NT
LIB
$(GRLIB)/lib/srcI.o
#else
ARCHIVE
$(GRLIB)/lib/srcI.lib
#endif

SOURCE
COdirmode.C    COremove.C     DIstring.c
COdirxlate.C   COrmdir.C      FIdirformi.I
COcd.C         COmkdir.C      COshownm.C     FIlstformi.I
COcdpath.C     COpwd.C        DIlocate.I     super_diri.I

#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
 
INCLUDE
$(INGRHOME)/include
$(XINC)
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/ingrsys
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

