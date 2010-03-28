CC
acc

COPT
-knr

SOURCE

GRntfyconn.I
GRvgrptout.I
GRntfydiscon.I
GRcoflexconn.I
GRcorigidcon.I
GRcodisconn.I
GRvgaddwrng.I
GRvgremwrng.I
GRvgapprojpt.I
GRvgchgcolor.I
GRvgchgdp.I
GRvgchglevel.I
GRvgchghprop.I
GRvgchgprops.I
GRvgchgstyle.I
GRvgchgweigh.I
GRvgfmtele.I
GRvggetexgeo.I
GRvggetexsiz.I
GRvggetprops.I
GRvggethprop.I
GRvggetrang.I
GRvggetsymb.I
GRvglevelcou.I
GRvglocate.I
GRvglocatepr.I
GRvgplotyrs.I
GRvgprojpt.I
GRvgptdis.I
GRvgputsymb.I
GRvgstretch.I
GRvgdebug.I
GRvgcoplanar.I
GRvgputrang.I
GRvganalyze.I
GRrptanalyze.I
GRvgprtread.I
GRntprtread.I
GRcoprtread.I

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(XINC)
$(GRNUC)/include
$(EXNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

SRC
$(GRNUC)/src/go/vg

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/vg_I.o
#else
ARCHIVE
$(GRLIB)/lib/vg_I.lib
#endif


#else

SRC
$(GRNUC)/src/go/vg

ARCHIVE
$GRMDS/lib/vg_I.a

#endif	

OPP
$(EXTARG)/bin/opp
