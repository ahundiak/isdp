/*
Name
        Elements by Individual Selection

Description
        This is the command class for generating a select set by
        selecting the individual elements that should be in the set. 
        The select set is placed on the input queue.

History
        Gray Winn   10/01/87    Creation date.
        mrm         04/10/91    Allow location by name
*/

command_string  GRMEleIndSel,0,GRSlEInSl
class           COgrpevent
start_state     start
product_name    "$SOURCE"
command_table   "4853.dpt"

state_table
#include "grmessage.h"
#include "griodef.h"
#include "msdef.h"
#include "lcdef.h"

at wakeup
    do display_mode GRhhd
    do display_located (sts)

at sleep
    do clear_highlight
   
state start
    on ELSE
        do construct_graphics_set     
        do build_locate_criteria
        state locate

state locate
    message_key GRC_M_EleIndSel
    prompt_key GR_P_IdEleMvOn
    accept_key GR_P_AccNxtEle
    relocate_key GR_E_EleNotFnd
    locate_mask "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE | GRm_RJT_MOVEON"
    accept_mask "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE | GRm_RJT_MOVEON |
                 GRm_RESTART"
    gslocate_num_inputs 0
    unhilight_mode GRhhd
    locate_display "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                    LC_ERASE_LOC_ELEMENT | LC_ACCEPT_CURSOR"
    filter gs_locate_noauto
        on EX_DATA or EX_STRING
            do put_accept_event_on_queue
            state locate
        on EX_OBJID
            state locate
        on EX_RJT_MOVEON
            do clear_highlight
            do perform_post_processing_on_graphics_set
            do define_active_select_set_from_graphics_set
                on RETURN_CODE = "MSFAIL"
                do status_key GR_E_EleNotFnd
                state terminate
            do put_select_set_on_queue
                state terminate
        on EX_RESTART
            do clear_highlight
            do empty_graphics_set
            state start   
