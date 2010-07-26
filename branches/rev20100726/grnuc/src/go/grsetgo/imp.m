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
$(GRNUC)/src/go/grsetgo

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/grsetgo.o
#else
ARCHIVE
$(GRLIB)/lib/grsetgo.lib
#endif


#else

ARCHIVE
$GRMDS/lib/grsetgo.a

#endif

SOURCE
GRfcadd.I
GRfcand.I
GRfccopy.I
GRfcdelete.I
GRfcdisplay.I
GRfcdissolve.I
GRfcend.I
GRfcflat.I
GRfcgetobj.I
GRfcinqcount.I
GRfcmerge.I
#ifndef IDRAW
GRfcor.I
#endif
GRfcpostproc.I
GRfcputrp.I
GRfcremmemb.I
#ifndef IDRAW
GRfcseti.I
#endif
GRfcstart.I
GRfctocpx.I
GRfcupdpath.I
GRgrseti.I
GRgs_fun.I
GRgsaction.I
GRgsadd.I
GRgsaddobj.I
GRgsand.I
GRgscopy.I
GRgscriteria.I
GRgsdelete.I
GRgsdisplay.I
GRgsdissolve.I
GRgsdp.I
GRgsempty.I
GRgsend.I
GRgsenvcomp.I
GRgsflat.I
GRgsflatten.I
GRgsgetobj.I
GRgsgetobjin.I
GRgsgetsimp.I
GRgsinit.I
GRgsinqcount.I
GRgslocate.I
GRgsmerge.I
GRgsobjadd.I
#ifndef IDRAW
GRgsor.I
#endif
GRgspass.I
GRgsremmemb.I
GRgsstart.I
GRgstocpx.I
GRgsupdpath.I
GRprismloc.I
GRsvadd.I
GRsvand.I
GRsvcheckobj.I
GRsvcopy.I
GRsvcriteria.I
GRsvdelete.I
GRsvdisplay.I
GRsvdissolve.I
GRsvdyself.I
GRsvempty.I
GRsvend.I
GRsvenvcomp.I
GRsvflat.I
GRsvgetobj.I
GRsvinit.I
GRsvinqcount.I
GRsvmerge.I
GRsvobjadd.I
#ifndef IDRAW
GRsvor.I
#endif
GRsvpass.I
GRsvpostobj.I
GRsvremmemb.I
GRsvstart.I
GRsvtocpx.I
GRsvunpreset.I
GRsvupdpath.I
