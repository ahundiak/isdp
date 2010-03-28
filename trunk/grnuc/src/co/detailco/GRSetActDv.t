/*\
Description
    The SET ACTIVE DRAWING VIEW COMMAND command is used to define an
    active drawing view.

History
    jay wallingford  06/20/89    creation 
\*/

command_string  GRMSetActDrwVw,CO_activedv,GRSDrVSh
class           COdetail
super_class     COtools
super_class     CEO_GSLOCATE
spec_path       "$grnuc/co/spec"
start_state     start
options		"siTC"
product_name    "$SOURCE"

state_table
#include "grmessage.h"
#include "lcdef.h"
#include <toolco.h>
#include "detailco.h"

state start
    message_key       GRC_M_SetActDrwVw
    prompt_key        GR_P_IdDrwVwMvOnOff
    accept_key        GR_P_AccDrwVw
    relocate_key      GR_E_EleNotFnd
    mask              "GRm_BACK_UP | GRm_RESTART | GRm_RJT_MOVEON | GRm_DATA | GRm_TEXT_VALUE"
    locate_eligible   "GRdrawview GRdrawsheet"
    locate_owner      "LC_GEOM_MOD | LC_NO_REF_HEADER | LC_NO_REF_OBJECTS"
    locate_properties "LC_LC_ONLY | LC_RW | LC_DP_ONLY"
    locate_display    "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
    filter            gs_locate

on EX_BACK_UP                                       state .
on EX_RESTART       do COtools.erase_highlight ()   state start
on EX_RJT_MOVEON    do set_active_owner (0)         state terminate
on EX_DATA or TEXT_VALUE
                    do COtools.erase_highlight ()
                    do set_active_owner (0)
                    do set_active_owner (&me->located_chansel)
                                                    state terminate
