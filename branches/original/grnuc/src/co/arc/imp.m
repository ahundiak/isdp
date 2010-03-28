
SRC
$(GRNUC)/src/co/arc

#ifdef IDRAW
ARCHIVE
$GRMDS/lib/arc.a

SOURCE
COniar3pt.C    COnifillet.I   DYarccnt.I     DYquartell.C
COniarcnt.C    COnihelarc.C   DYarcnrad.C    DYarcendpt.C
COniarcrad.C   COniqelarc.C   DYarcrad.I
COniarrat.C    DYarc3pt.C     DYhalfell.C

#else

#ifndef NT
LIB
$(GRLIB)/lib/arc.o
#else
ARCHIVE
$(GRLIB)/lib/arc.lib
#endif

SOURCE
COniar3pt.C    COnifillet.I   DYarccnt.I     DYquartell.C   COniarcchd.I
COniarcnt.C    COnihelarc.C   DYarcnrad.C    COcomparc.I    DYarcchd.I
COniarcrad.C   COniqelarc.C   DYarcrad.I     COarcxang.I    DYarcendpt.C
COniarrat.C    DYarc3pt.C     DYhalfell.C    COarctocr.I


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
