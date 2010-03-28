
SRC
$(GRNUC)/src/co/meas

#ifdef IDRAW
ARCHIVE
$GRMDS/lib/meas.a

SOURCE
 
COnimlnang.I   COnimsdiam.I   COnimmptel.I
COnimmindi.I   COnimslen.I    DYmsang3pt.C
COnims2pt.C    COnimsptpj.I   DYrastext.I
COnimsalng.I   COnimsrad.I    COcvtptwld.I
COniman3pt.I   COnimsarea.I   COcvtptlcl.I
COasctolc.I    COmang2pt.C    COmang3pt.C
COmangline.I   COmangswp.I    COcenconic.I
COmlenalng.I   COmradele.I    COmang4pts.C
COmang2line.I  DYdynmeas.I

#else

#ifndef NT
LIB
$(GRLIB)/lib/meas.o
#else
ARCHIVE
$(GRLIB)/lib/meas.lib
#endif

SOURCE
 
COnima2pax.I   COnimlnang.I   COnimsdiam.I   DYfixedbuf.C   COasctolc.I
COnimalnax.I   COnimmindi.I   COnimslen.I    DYmsang3pt.C   COcvtptlcl.I
COniman2ln.I   COnims2pt.C    COnimsptpj.I   DYrastext.I    COcvtptwld.I
COniman2pt.I   COnimsalng.I   COnimsrad.I    DYrbfixed.C    COmang2pt.C
COniman3pt.I   COnimsarea.I   COnimsswp.I    COnimmptel.I   COmang3pt.C
COmangline.I   COmangswp.I    COcenconic.I   COmlenalng.I   COmradele.I
COmang4pts.C   COmang2line.I  DYdynmeas.I

#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
#ifdef X11
$(XINC)
#endif
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
