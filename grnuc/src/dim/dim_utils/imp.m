SOURCE

glob.I
math.I
dynamics.I
par.I
utils.I
angutils.I
forms.I
form_glob.I
init.I
asroot.I
dmgraph.I
dmexec.I
complex.I
locate.I
cache.I
txdynamics.I
andyn.I
dbgutils.I
place.I
passdim.I
mktext.I
anutils.I
dmsrc.I

CC
acc -knr

SRC
$(GRNUC)/src/dim/dim_utils

#ifndef NT
LIB
$(GRLIB)/lib/dim_utils.o
#else
ARCHIVE
$(GRLIB)/lib/dim_utils.lib
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
cc 
