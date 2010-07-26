
SRC
$(GRNUC)/src/grio/forms

#ifdef IDRAW
ARCHIVE
$GRMDS/lib/forms.a

SOURCE
COprfxcsty.C   COupdatept.I   

#else

#ifndef NT
LIB
$(GRLIB)/lib/forms.o
#else
ARCHIVE
$(GRLIB)/lib/forms.lib
#endif

SOURCE
COprfxcsty.C   COupdatept.I 

#endif 

SPEC
$(EXNUC)/spec
$(GRNUC)/spec
 
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
 
OPP
$(EXTARG)/bin/opp
 
OMCPP
$(EXTARG)/bin/omcpp
 
CC
acc -knr -O3
