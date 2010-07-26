INCLUDE
$(INGRHOME)/include
$(XINC)
$(BS)/include
$(EXNUC)/include
$(GRNUC)/include
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
$(GRNUC)/src/go/ownergo

#ifdef IDRAW

ARCHIVE
$GRMDS/lib/ownergo.a

#else

#ifndef NT
LIB
$(GRLIB)/lib/ownergo.o
#else
ARCHIVE
$(GRLIB)/lib/ownergo.lib
#endif


#endif

SOURCE
GRcmpowneri.I
GRcmpownfunc.I
GRflxowni.I
GRfocompdis.I
GRfoprismrel.I
GRownfunc.I
GRownactown.I
GRownadd.I
GRownchgprop.I
GRownclip.I
GRowncopy.I
GRowncopyown.I
GRowndelete.I
GRowndelown.I
GRowndrop.I
GRowneri.I
GRownfirstco.I
GRowngetcomp.I
GRowndisp.I
GRowngetinfo.I
GRowngetnum.I
GRowngetprop.I
GRowngetrang.I
GRownidchang.I
GRownlocate.I
GRownlocown.I
GRownpostclp.I
GRownprismre.I
GRownproject.I
GRownremcomp.I
GRownremove.I
GRownunknown.I
GRownwrng.I
GRownxform.I
GRownxformow.I
GRptlnproc.I
GRflxchownpr.I
GRflxlocprop.I
GRowngetmat.I
GRownlocprop.I
