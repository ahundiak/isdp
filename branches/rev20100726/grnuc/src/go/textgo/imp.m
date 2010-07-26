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

COPT
-ga

CC
acc -knr

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

DEPENDENCIES
/*
om      4.0.5
opp     4.0.41
ige.o   0.8.6
*/

SRC
$(GRNUC)/src/go/textgo

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/textgo.o
#else
ARCHIVE
$(GRLIB)/lib/textgo.lib
#endif


#else

ARCHIVE
$GRMDS/lib/textgo.a

#endif

SOURCE
GR3dtxgenabs.I
GR3dtxpostab.I
GRangplacetx.I
GRchgtxstr.I
GRcreatetext.I
GRdisptext.I
GRdpemptytx.I
GReschndlr.I
GRfieldinq.I
GRfwdcurpos.I
GRgettxattr.I
GRlnusrpos.I
GRplacetext.I
GRrfemptytx.I
GRrpltext.I
GRtx_constr.I
GRtxchgattr.I
GRtxchgflag.I
GRtxchgname.I
GRtxclip.I
GRtxcopy.I
GRconvstr.I
GRtxcursor.I
GRtxdisyours.I
GRtxgetobjin.I
GRtxlocproc.I

GRbbegescseq.C
GRbwddelchr.C
GRbwddispchr.C
GRchrposinfo.C
GRchrwhtsp.C
GRcreatelbs.C
GRdispchr.C
GRedittext.I
GRerasechr.C
GRfbegescseq.C
GRfieldlen.C
GRfieldnum.C
GRfind_pos.C
GRfldendchr.C
GRfldrefpt.C
GRfndescchar.C
GRfwdescseq.C
GRgenfrac.C
GRhorjustmv.C
GRjustexts.C
GRjustfield.C
GRjusthor.C
GRjuststr.C
GRjustvert.C
GRkernprval.C
GRlbsplappro.C
GRlnjustmv.C
GRnumdispchr.C
GRoddescchr.C
GRparescseq.C
GRstrpescseq.C
GRswapbytes.C
GRtexteol.C
GRtxalongcrv.C
GRtxextents.C
GRtxfldbox.C
GRvalidstr.C
GRvertjustmv.C
GRvertssmv.C
GRvldcurpos.C

GRtxtanalyze.I

#ifndef IDRAW
GRtxfillbuf.I
GRblocktext.C
#endif        /* IDRAW */
GRtxt_dlist.I
