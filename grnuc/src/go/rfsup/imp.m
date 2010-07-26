CC
acc -knr

SOURCE
GRxformprism.I
GRget_Super.I
GRcheckmast.I
GRrfremrtree.I
GRrfaddrtree.I
GRopenfile.I 
GRconnchanne.I
GRctxstack.I
GRcheckref.I
GRdisthruref.I
GRgetctxid.I
GRloadinst.I
GRupdcontext.I
GRcyclic_che.I
GRrefmode.I
GRrefpass.I
GRincinvtab.I
GRdecinvtab.I
GRlocrefobj.I
GRnamereffi.I
GRgetrefrang.I
GRgetrefleve.I
GRrfloccheck.I
GRcheckconte.I
GRgetcontext.I

GRverifyview.C
GRputsavevw.C
GRgetranges.C
GRgetcurves.C
GRgetupdrng.C

GRcomputectx.c
GRrefvwclp.c
GRbuildbuf.c
GRpassrange.c
GRstrokcp.c
GRfixmatrix.c

GRfindcontex.I
GRcontextcon.I
GRformlbsys.c
GRxformboth.I
GRpolyconnec.I
GRsuperconne.I
GRformdvpris.I
GRrfreport.I
GRfctthruref.I
GRchgreftype.I
GRfindrefobj.I
GRreffilerng.I
GRrfshwrclip.I
GRsplitfunc.c
GRrfsupfunc.C
GRattachref.I
GRgetrefinfo.I
GRputrefinfo.I
GRrevreffile.I


#ifndef IDRAW
GRgetclippol.I
#endif

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

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

SRC
$(GRNUC)/src/go/rfsup

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/refsup.o
#else
ARCHIVE
$(GRLIB)/lib/refsup.lib
#endif

#else

ARCHIVE
$GRMDS/lib/refsup.a

#endif	
