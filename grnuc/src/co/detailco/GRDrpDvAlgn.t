/*\
Description
    The DROP DRAWING VIEW ALIGNMENT command is used to drop the alignment
    between drawing views.

History
    jay wallingford 06/20/89    Creation date
\*/

command_string  GRMDrpDrwVwAlgn,CO_dropalgn,GRDrDrVAl
class           COdetail
super_class     COtools
super_class     CEO_GSLOCATE
spec_path       "$grnuc/co/spec"
start_state     start
options		"siTC"
product_name    "$SOURCE"

state_table
#include <grmessage.h>
#include <lcdef.h>
#include "detailco.h"
#include <toolco.h>

state start
    message_key       GRC_M_DrpDrwVwAlgn
    prompt_key        GR_P_IdDrwVw
    accept_key        GR_P_AccDrwVw
    relocate_key      GR_E_EleNotFnd
    locate_eligible   "GRdrawview"
    locate_owner      "LC_GEOM_MOD | LC_NO_REF_HEADER | LC_NO_REF_OBJECTS"
    locate_properties "LC_LC_ONLY | LC_RW | LC_DP_ONLY"
    locate_display    "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
    filter            gs_locate
on EX_BACK_UP                                   state -
on EX_RESTART  do COtools.erase_highlight()     state start
on EX_DATA or TEXT_VALUE
               do COtools.erase_highlight()
               do send_foreign(CO_drop_alignment)
               do COtools.empty_channel(&me->located_chansel)
                                                state start
