SOURCE

DPdebug.I
DPsvdel.I
DPsvinquire.I
DPgetsavvwid.I
DPtotnumvw.I
DPsavvwcons.I
DPsvrecall.I
DPviewvol.I
DPcenter.I
IGEwinsupi.I
DPerahil.I
DPgetggid.I
DPactivate.I
DPcal.I
DPcons.I
DPclear.I
DPallow.I
DPclpicon.I
DPcolwin.I
DPmovicon.I
DPcovicon.I
DPdelete.I
DPcross.I
DPcvtpnt.I
DPdelicon.I
DPdisbybuf.I
DPdisbyoid.I
DPgriddraw.I
DPgrlock.I
DPgronoff.I
DPsetinq.I
DPinrot.I

DPrngbox.I

DPuor2dit.I
DPupdate.I
DPfit.I
DPlevels.I
DPlvldiri.I

DPgenupdate.I
DPwnarea.I
DPfddefvw.I
dplocbrln.C
dpsetvw.I

DPgetid.C
DPchgname.C
DPaddvwname.C
DPunitvwvec.C
dpcliprng.C
dpmacerahil.I
dpdisplay.I
dpdyncvtpnt.C
dpcvrtpnt.I
dpdynamics.I
dptxdynamics.I
dpdynsup.I
dpunderline.I
dpclosechar.I
dplevel.I
dpmacupdate.I
dpmacgenupd.I
dppresetvvol.C
dp3Ddatapt.C
dpbrlnconst.C
dpgrid.I
dpconstgrid.C
dpaxisalign.C
dpclpstack.C
dpmtxstack.C

dpbcstrk.C

dppsstrk.C
dppystrk.C
dpoutpnt.C

DPzdepfnc.C
DPwldvw.C
dpsetdsp.C
dpinqwsdep.C
dpdiselem.C
dpelem.C
dpaddfnt.I
dpchgfstfnt.C
dpcrefntbl.C
dpdelfnt.C
dpdelfntbl.C
dpgetfntadr.C
dptxstrk.C
dptxunder.C
dpprojchar.C

#ifndef X11 
dpdynevent.C
#endif

#ifdef X11 
xdpdynevent.C
#endif

dperase.C
dpeschdler.C
dpsetrng.C
dpsetrow.C
dprngcheck.C
dpgetrng.C
dpexbell.C
dpviewind.I
DPfitrng.I
DPstartupi.I
DPusrlnstli.I
DPcodpbi.I
DPchoosvis.c
dptoler.C

#ifndef IDRAW
DPwnareaf.C
DPcalpersp.I
DPunpersp.I
DPsetpersp.I
DPexsetpp.I
DPinrgbox.I
DPviewdyn.I
DPcvtpersp.I
GRviewdyni.I
GRvw_dlist.I
DPfitpersp.C
DPordphigs.C
DPphigsord.C
dpalignper.C
dpbsqstrk.C
#endif

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
#ifdef X11
$(XINC)
#endif
$(INGRHOME)/include
$(GRNUC)/ingrsys
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

CC
acc -knr

COPT
-ga

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

SRC
$(GRNUC)/src/display/grdisplay

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/grdisplay.o
#else
ARCHIVE
$(GRLIB)/lib/grdisplay.lib
#endif
#else
ARCHIVE
$GRMDS/lib/grdisplay.a
#endif
