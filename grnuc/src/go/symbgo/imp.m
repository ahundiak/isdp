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
$(GRNUC)/src/go/symbgo

#ifdef IDRAW

ARCHIVE
$GRMDS/lib/symbgo.a

#else

#ifndef NT
LIB
$(GRLIB)/lib/symbgo.o
#else
ARCHIVE
$(GRLIB)/lib/symbgo.lib
#endif


#endif

SOURCE
GR3dlbgen.C
GR3dlbpost.C
GRcladd.I
GRclconstr.I
GRclcopyown.I
GRclgenabsg.I
GRclgetobjin.I
GRclhdri.I
GRcllocpr.I
GRclpostabsg.I
GRclpostclip.I
GRclprismrel.I
GRclremove.I
GRclreplace.I
GRclxformown.I
GRgetcdinfo.I
GRisreplace.C
GRlslmgr_fun.I
GRlslmgri.I
GRrbldbtree.I
GRsdhadd.I
GRsdhconstr.I
GRsdhcopy.I
GRsdhcopyown.I
GRsdhcpsdams.I
GRsdhdelete.I
GRsdhdelown.I
GRsdhdispall.I
GRsdhgenabsg.I
GRsdhgetrang.I
GRsdhgetsize.I
GRsdhpostabs.I
GRsdhrename.I
GRsdhreplace.I
GRsdhplotyrs.I
GRsdlocate.C
GRsmchgcolor.I
GRsmchgdp.I
GRsmchgstyle.I
GRsmchgweigh.I
GRsmclip.I
GRsmconstr.I
GRsmcopy.I
GRsmcpcl.I
GRsmdelown.I
GRsmdfhdri.I
GRsmdrop.I
GRsmdyself.I
GRsmfmtele.I
GRsmgenabsg.I
GRsmgetobjin.I
GRsmgetsymb.I
GRsmhdri.I
GRsmlocate.I
GRsmmvsd.I
GRsmplotyrs.I
GRsmpostabsg.I
GRsmputsymb.I
GRsmreplace.I
GRsmxformown.I
GRsymboli.I
GRtime.C
GRvalbtree.c
