SOURCE
VSimgFeature.S
VSifdbintrfc.I
VSifdrwcpgeo.I
VSifdescfoot.I
VSiffindcoll.I
VSiffrzcpy.I
VSiffwdtoorg.I
VSiffwdtosrc.I
VSifgetattr.I
VSifgetedatt.I
VSifgetmodel.I
VSifgetspprt.I
VSifgiveoutp.I
VSifgivestrc.I
VSifmassprop.I
VSifnrmofcmp.I
VSifobjinfo.I
VSifophist.I
VSiforient.I
VSifrestype.I
VSifretnfoot.I
VSifsppdelms.I
VSifusrattr.I

LIB
$(STRUCT)/lib/vsimage.o

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
$(MODEL)/spec
$(VDS)/spec
$(STRUCT)/spec

INCLUDE
$(BS)/include
$(BS)/include/prototypes
$(EXNUC)/include
$(GRNUC)/include
$(MODEL)/include
$(VDS)/include
$(STRUCT)/include
$(STRUCT)/include/prototypes

OPP
$(EXNUC)/bin/opp

OMCPP
$(EXNUC)/bin/omcpp

/*
 * "CLIX" : -D switch for BS
 */
DOPT
CLIX SYSV BSD ENV5 LITTLE_ENDIAN

CC
acc -ansi -O3
