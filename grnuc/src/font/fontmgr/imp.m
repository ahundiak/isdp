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
$(GRNUC)/src/font/fontmgr

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/fontmgr.o
#else
ARCHIVE
$(GRLIB)/lib/fontmgr.lib
#endif

#else

ARCHIVE
$GRMDS/lib/fontmgr.a

#endif

SOURCE
GRcleanup.I
GRclrentry.I
GRdupfont.I
GRfmconstr.I
GRfmgetentr.I
GRfmretdata.I
GRfmsuper.I
GRfmwakeup.I
GRgetfntinfo.I
GRisitfnt.C
GRisitfstfnt.I
GRmakeentry.I
GRphysrch.I
GRretfnt.I
GRsetfstfnt.I
GRupdvfntnam.I
GRvirtsrch.I
