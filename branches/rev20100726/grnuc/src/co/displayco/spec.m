SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(XINC)
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
$(GRLIB)/lib/co3414_sp.o
#else
ARCHIVE
$(GRLIB)/lib/co3414_sp.lib
#endif


#else

LIB
$GRMDS/lib/co3414_sp.o
#endif

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

SOURCE

COwindow.S
COwndmnpl.S
COgrid.S
COmiscl.S
COviewmnpl.S
COcolors.S
COceocmds.S
COedtsv.S
COlayer.S
COedtly.S
COlocly.S
COSetWinShp.S
COdfls.S
COactly.S
COTogPerBh.S
DPvw.S
COpan.S
COrotcoi.S
COroteye.S
COtilt.S
COvwangle.S
COwnarea.S
COzoom.S
COswapcopy.S
COrclvw.S

#ifndef IDRAW
COdynamics.S
COfillobj.S
COvwchar.S
COaxlocks.S
COcnstrpl.S
COdynsetvw.S
#endif

CC
acc -knr -O3

