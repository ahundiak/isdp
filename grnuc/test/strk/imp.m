INCLUDE
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
$(BS)/include/prototypes
$(GRNUC)/proto_pub
$(GRNUC)/proto_priv
 
OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

COPT
-ga

CC
acc -knr

SRC
/

LIB
$(GRNUC)/test/lib/GRstrktst.o

SOURCE
$(GRNUC)/src/display/grdisplay/dpbcstrk.C 
$(GRNUC)/src/display/grdisplay/dpbsqstrk.C
$(GRNUC)/src/display/grdisplay/dppsstrk.C
$(GRNUC)/src/display/grdisplay/dppystrk.C
$(GRNUC)/src/display/grdisplay/dptxstrk.C
