INCLUDE
$(INGRHOME)/include
$(INGRHOME)/include
$(EXNUC)/include
$(GRNUC)/include
$(BS)/include
 
OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

COPT
-ga

CC
acc -knr -Achar=unsigned

SPEC
$(EXNUC)/spec
$(EXNUC)/fi/spec
$(EXNUC)/message/spec
$(EXNUC)/icob/spec
$(GRNUC)/spec

#ifndef IDRAW

#else

SRC
$(GRNUC)/test/co/textco/coplacetext


#endif

SOURCE
TSplacetext.I
