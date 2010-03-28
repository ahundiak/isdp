SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
#ifdef X11 
$(XINC)
#endif
$(EXNUC)/include
$(GRNUC)/include
$(GRNUC)/ingrsys
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
#if defined (XGL)
$(XGLHOME)/include
$(XGLHOME)/include/xgl
#endif

SRC
$(GRNUC)/src/co/displayco

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/co3414_I.o
#else
ARCHIVE
$(GRLIB)/lib/co3414_I.lib
#endif

#else
LIB
$GRMDS/lib/co3414_I.a
#endif

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

SOURCE

numstr.C

COwindowi.I
COgridi.I
COwndmnpli.I
COmiscli.I
COviewmnpli.I
COcolorsi.I
COceocmdsi.I
COdflsi.I
COdlsfunc.C
COedtsvi.I
COlayeri.I
COedtlyi.I
COloclyi.I
COlynumnm.I
COlydispfd.I
COlyfminit.I
COlyfmnot.I
COlysrch.I
COlyocc.I
COactlyi.I
DPgroupof.C
DPindlyof.C
DPpattern.C
marang2vc.C
COSetWinShpi.I
COpersptogi.I
DPvwi.I
COpani.I
COrotcoii.I
COroteyei.I
COtilti.I
COvwanglei.I
COwnareai.I
COzoomi.I
DPinvmxRT.c
DPvw_cal.I
DPmpflyfunc.I
DPvw_dyn.I
DPvw_var.I
DPvw_pyrmd.I
COswapcopyi.I
COvwchari.I
COrclvwi.I

#ifndef IDRAW
DPdyplane.C
DPdypyrm.I
COaxlocks1i.I
COaxlocksi.I
COcnstrpli.I
COdynsetvwi.I
COdynamicsi.I
COfillobji.I
COvwfmnot.I
COvwprogchng.I
COgathggdata.I
#endif

CC 
acc -knr -o3

