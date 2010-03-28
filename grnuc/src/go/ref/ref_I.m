
SOURCE

GRctxrefchec.I
GRctxdeletec.I
GRctxgetinst.I
GRctxupdatec.I
GRctxcopyctx.I
GRctxconsemp.I
GRctxputosnu.I
GRctxloadctx.I
GRctxgetflag.I
GRctxchgflag.I
GRctxpassche.I
GRctxnotifym.I
GRctxregener.I
GRctxgetosnu.I

GRcpaddwrng.I
GRcpremwrng.I
GRcpapprojpt.I
GRcpclip.I
GRcpclipto.I
GRcpconstruc.I
GRcpcopy.I
GRcpcptform.I
GRcpdelete.I
GRcpdelverte.I
GRcpdetplane.I
GRcpdisyours.I
GRcpgenabsg.I
GRcpgenprism.I
GRcpgeomprop.I
GRcpgetgeom.I
GRcpgetobjin.I
GRcpgetprism.I
GRcpgetrang.I
GRcpgetsize.I
GRcpkeypoint.I
GRcpinsverte.I
GRcplocate.I
GRcplnprojec.I
GRcpmodify.I
GRcppostab.I
GRcppostpris.I
GRcpprismrel.I
GRcpplotyour.I
GRcpptprojec.I
GRcpxform.I

GRrfaddwrng.I
GRrflvdispla.I
GRrfremwrng.I
GRrfchgfilen.I
GRrfchglevel.I
GRrfclose.I
GRrfconstruc.I
GRrfcopy.I
GRrfcptform.I
GRrfdelete.I
GRrfdisyours.I
GRrffunction.I
GRrfgeomprop.I
GRrfgenabs.I
GRrfgetdescr.I
GRrfgetenvir.I
GRrfgetlbsys.I
GRrfgetlevel.I
GRrfgetobjin.I
GRrfgetrang.I
GRrfgetrfpro.I
GRrfgetscale.I
GRrfgetsize.I
GRrfgetgeom.I
GRrfinit.I
GRrflnprojec.I
GRrflocate.I
GRrflocatepr.I
GRrfplotpass.I
GRrfpostab.I
GRrfpostlbsy.I
GRrfprismrel.I
GRrfptprojec.I
GRrfputdescr.I
GRrfputscale.I
GRrfinquirer.I
GRrfselpass.I
GRrfupdrefrn.I
GRrfxform.I
GRrfxformref.I
GRrfpostinit.I
Super_rfmgri.I

#ifndef IDRAW
GRctxcheckct.I
GRctxchkconn.I
GRctxcheckcr.I
GRctxgetmodu.I
GRrfchgrfpro.I
GRrfpre_upda.I
GRrfpost_upd.I
GRcpmodifyhe.I
GRrfchgcolor.I
GRrfchgdp.I
GRrfchgweigh.I
GRrfchgstyle.I

#endif

SPEC
$GRNUC/go/spec
$EXNUC/om/spec
$EXNUC/exec/spec
$GRNUC/display/spec
$GRNUC/grmodule/spec
$GRNUC/font/spec
$GRNUC/igecolor/spec

INCLUDE
$(INGRHOME)/include
$GRNUC/include
$BS/include
$EXNUC/include

OPP
$EXTARG/bin/opp

OMCPP
$EXTARG/bin/omcpp

#ifndef IDRAW

LIB
../lib/ref_I.o

VERSION
../lib/ref_I.o 	0.0.8

#else

ARCHIVE
../lib/ref_I.a

VERSION
../lib/ref_I.a 	0.0.8

#endif	
