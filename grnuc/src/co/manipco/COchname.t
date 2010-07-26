/*
Name
        COchname

Description
        This file contains the transition table for the Change Element
        Name Command.

History
        mrm     09/06/88    COBbed from existing command
*/

class               COchange
super_class         COdpb
super_class         COtools
super_class         CEO_GSLOCATE
command_object      GRMChEleNm, COch_name, GRCENm
synonym             "mv", COch_name, GRCENm
product_name        "$PLATFORM"
options             "si"
spec_path           "$GRNUC/co/spec"
start_state         locate_object

state_table

#include "cochindex.h"
#include "comndef.h"
#include "grmessage.h"
#include "grerr.h"

state locate_object
    message_key GRC_M_ChEleNm
    prompt_key GR_P_IdEle
    accept_key GR_P_AccNwNm
    relocate_key GR_E_EleNotFnd
    locate_mask "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    accept_mask "GRm_TEXT_VALUE"
    locate_eligible "+GRvg"
    locate_properties "MOVE_LC_PROPS"
    locate_owner "LC_RIGID_COMP | LC_FLEX_COMP | LC_FLEX_OWNER | LC_RIGID_OWNER | LC_HANDLES"
    locate_display "MANIP_LC_DISFLAG"
    filter gs_locate_noauto
/*
        Note:  9/6/88 - the locate filter currently cannot support returning
        GRw_no_value, so the function COch_name, called by the use_events
        action, checks for a NULL response string and returns GRw_no_value
        if appropriate, to be checked here.

        on RETURN_CODE = GRw_no_value
            do status_key GR_E_InvNme
            state get_new_name
*/
        on TEXT_VALUE
            do use_events ()
                on RETURN_CODE = GR_E_INV_REQUEST
                    do status_key GR_E_DupNme
                    state get_new_name
                on RETURN_CODE = GRw_no_value or ERROR
                    do status_key GR_E_InvNme
                    state get_new_name
                on SUCCESS
                    do COtools.erase_highlight ()
                    do disconnect_located 1
                    state .
            state .

state get_new_name
    prompt_key GR_P_EntNwNm
    filter get_event
        on RETURN_CODE = GRw_no_value
            do status_key GR_E_InvNme
            state .
        on TEXT_VALUE
            do use_events ()
                on RETURN_CODE = GR_E_INV_REQUEST
                    do status_key GR_E_DupNme
                    state .
                on ERROR
                    do status_key GR_E_InvNme
                    state .
                on SUCCESS
                    do COtools.erase_highlight ()
                    do disconnect_located 1
                    state locate_object
            state .
        on EX_RESTART or EX_BACK_UP
            do COtools.erase_highlight ()
            do disconnect_located 1
            state locate_object
