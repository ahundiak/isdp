OPP
$(EXTARG)/bin/opp

OMCPP
$(EXTARG)/bin/omcpp

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

SPEC
$(EXNUC)/spec
$(GRNUC)/spec

SOURCE
action_gl.I
arg_name_gl.I
delete_gl.I
discon_c_gl.I
display_c_gl.I
display_l_gl.I
filter_gl.I
init_gl.I

SRC
$(GRNUC)/src/dcob/ceo_gslocate

#ifdef IDRAW

LIB
$GRMDS/lib/ceo_gslocate.o

#else

#ifndef NT
LIB
$(GRLIB)/lib/ceo_gslocate.o
#else
ARCHIVE
$(GRLIB)/lib/ceo_gslocate.lib
#endif

#endif
