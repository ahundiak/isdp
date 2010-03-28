CC
acc -knr

SOURCE

GRgrchgname.I
GRgrgetname.I
GRgrputname.I

GRgrcopy.I
GRgrfunction.I
GRgrcptform.I
GRgrdelete.I
GRgrdisplay.I
GRgrgetobjin.I
GRgrlocaldp.I
GRgridchange.I
GRgrlnproces.I
GRgrptproces.I

#ifndef IDRAW
GRgrgentform.I
GRgrcpforund.I
GRgrundocp.I
GRgrplotprep.I
GRgrrcopy.I
#endif

GRgrdebug.I
GRgrchanpass.I
GRgradddlist.I

GRgrprtread.I

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
$(GRNUC)/src/go/graphics

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/graphics_I.o
#else
ARCHIVE
$(GRLIB)/lib/graphics_I.lib
#endif


#else

ARCHIVE
$GRMDS/lib/graphics_I.a

#endif	


OPP
$(EXTARG)/bin/opp

