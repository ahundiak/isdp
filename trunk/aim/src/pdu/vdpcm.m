SOURCE
PDUpart_form.C
PDUmcf_list.C 
PDUdsgn_frm.C

LIB
$AIM_PATH/src/lib/AVDsimilar.o

SPEC
$EXNUC/spec
$GRNUC/spec
$MODEL/spec
$EMS/spec
$VDS/spec

INCLUDE
#if ISDP_MAKE_SP
$SPXV/include
$SPXV/vdinclude
#endif
$BS/include
$BS/include/prototypes
$EXNUC/include
$GRNUC/include
$GRNUC/ingrsys
$MODEL/include
/export/home/source/ems/pdu/include
/export/home/source/ems/pdudp/include
$NFM/include
$NFMDP/include
$FORMS/include
$UMS/include
$AIM/include
$VDS/include
$VDS/vdinclude

OPP
$EXNUC/bin/opp

OMCPP
$EXNUC/bin/omcpp
