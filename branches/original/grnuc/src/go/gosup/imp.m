CC 
acc -knr

SOURCE
GRchansel.I
grmacrosi.I
grwireframei.I
GRcvtancrv.I
GRptalongcv.I
GO2bcclisect.c
GOarcptrdcv.c
GOarctnbcp.c
GObcsclisect.c
GOcdtto2bc.c
GOcttobc.c
GOfillet.c
GRhvls2pt.C
GRaals2pt.C
GR2bcisectut.c
GRgetbuffer.c
GRload3dconi.c
GRgentransu.c
GRls2pt.c
GRls2ptrt.c
GRorthoseg.c
GRpostrtrans.c
GRposttransu.c
GRprerout.c
GRpytransuti.c
GRsetarc.c
GRsortevents.c
GRtransrange.c
GRvtsegrtang.c
GRar2ptrad.c
GRar2ptradrt.c
GRar3pt.c
GRar3ptrt.c
GRarc2ptr.c
GRarcaxpt.c
GRarcnptang.c
GRarcnptangr.c
GRarcnradpts.C
GRargenabsg.c
GRbclnextend.c
GRbrlncon.c
GRcbclnexten.c
GRcheckrel.c
GRclorthpg.c
GRcr2ptrad.c
GRcr2ptradrt.c
GRcr3pt.c
GRcr3ptrt.c
GRcrc2ptr.c
GRcrcnrad.c
GRcrcnradrt.c
GRcrdiam.c
GRcrdiamrt.c
GReaaxaxpt.c
GReaaxaxptrt.c
GReaaxptax.c
GReaaxptaxrt.c
GRelaxaxpt.c
GRelaxaxptrt.c
GRelcnaxpt.c
GRelcnaxptrt.c
GRxformarc.c
GRcheckortho.c
GRcheckplana.c
GRloadcs.c
GR2ptlsext.c

GR2objisect.C
GR2objminlin.C
GRabsgutil.C
GRpybcueq.C
HSgetprops.C
GRlnoffset.C
GRacthand.C
GRcheckcrit.C
GRcondpath.C
GRlbgeomchk.C

GRnotifylist.I
GR2objaisect.I
GRaltchgclas.I
GRtchgclass.I
GRccschoice.I
GRchgclass.I
GRconsfunc.I
GRfillet.I
GRinit_path.C
GRloccheck.I
GRget2objgeo.I
GRowneradd.I
GRownerrem.I
GRupdaterng.I
GRpladdpts.I
GRcnupdrang.I
GRdetpoint.I
GRaddptsutil.I
GRorthaddpts.I
GUprocessplo.I
GRprocessfit.I

GRprtread.I

#ifndef IDRAW

GOlpfrbs.c
GOlptobs.c
GR2objangbis.C

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

SRC
$(GRNUC)/src/go/gosup

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/gosup.o
#else
ARCHIVE
$(GRLIB)/lib/gosup.lib
#endif


#else

ARCHIVE
$GRMDS/lib/gosup.a

#endif	

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp
