CC
acc -knr

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
action_l.I
arg_event.I
arg_lc_info.I
arg_name_l.I
delete_l.I
display_l.I
display_c.I
disconnect.I
execute_l.I
filter_l.I
init_l.I
predicate_l.I
sleep_l.I
wakeup_l.I
smartsketch.I
stdisbtn.I

SRC
$(GRNUC)/src/dcob/ceo_locate

#ifdef IDRAW

LIB
$GRMDS/lib/ceo_locate.o

#else

#ifndef NT
LIB
$(GRLIB)/lib/ceo_locate.o
#else
ARCHIVE
$(GRLIB)/lib/ceo_locate.lib
#endif

#endif
