CC
acc -ansi -O3

SOURCE

GRctxcheckct.I
GRctxrefchec.I
GRctxdeletec.I
GRrffilnami.I
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
GRctxgraph.I
GRctxdebug.I

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
GRcpupdrtree.I

GRrfaddwrng.I
GRrfdebug.I
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
GRrfisparent.I
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
GRrfgetosnum.I
GRrfupdrtree.I
GRrfload.I
Super_rfmgri.I
GRwrite.I
GRlist.I

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
GRrfchgname.I
GRrfputname.I

GRclpanal.I

invischkover.c

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

SRC
$(GRNUC)/src/go/ref

#ifndef NT
LIB
$(GRLIB)/lib/ref_I.o
#else
ARCHIVE
$(GRLIB)/lib/ref_I.lib
#endif
