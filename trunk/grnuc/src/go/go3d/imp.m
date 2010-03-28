CC
acc -knr

SOURCE

GR3dcaclipto.I
GR3dcrclipto.I
GR3deaclipto.I
GR3delclipto.I
GR3dilclipto.I
GR3dlsclipto.I
GR3dolclipto.I
GR3dopclipto.I
GR3dpgclipto.I
GR3dpsclipto.I
GR3dptclipto.I
GR3dslclipto.I

GR3dcaputarc.I
GR3dcrputarc.I
GR3deaputarc.I
GR3delputarc.I
GR3dilputpol.I
GR3dlsputpol.I
GR3dolputpol.I
GR3dopputpol.I
GR3dpgputpol.I
GR3dpsputpol.I
GR3dptputpol.I
GR3dslputpol.I

GR3dcagetarc.I
GR3dcrgetarc.I
GR3deagetarc.I
GR3delgetarc.I
GR3dilgetpol.I
GR3dlsgetpol.I
GR3dolgetpol.I
GR3dopgetpol.I
GR3dpggetpol.I
GR3dpsgetpol.I
GR3dptgetpol.I
GR3dslgetpol.I

GR3dcadebug.I
GR3dcrdebug.I
GR3deadebug.I
GR3deldebug.I
GR3dildebug.I
GR3dlsdebug.I
GR3doldebug.I
GR3dopdebug.I
GR3dpgdebug.I
GR3dpsdebug.I
GR3dptdebug.I
GR3dsldebug.I

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

INCLUDE
$(INGRHOME)/include
$(GRNUC)/include
$(EXNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv

SRC
$(GRNUC)/src/go/go3d

#ifndef IDRAW

#ifndef NT
LIB
$(GRLIB)/lib/go3d_I.o
#else
ARCHIVE
$(GRLIB)/lib/go3d_I.lib
#endif


#else

ARCHIVE
$GRMDS/lib/go3d_I.a

#endif	

OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp
