/*\
Name
        COstrfnc.t

Description
   This file contains the transition table for the stretch 
   fence contents command.  

History
   MAS                08/12/88    Creation date.

\*/

command_string  GRMStFnE,FC_INSIDE_OVERLAP,GRStFnE
class           COstrfnc
super_class     COgrpevent
start_state     start
product_name    "$GRNUC"
options         "si"
spec_path       "$GRNUC/co/spec"
state_table

#include "grmessage.h"
#include "execmsg.h"
#include "grgsdef.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "dp.h"

state *
   on EX_RESTART 
        state start
   on EX_BACK_UP
        state -

state start
    on CMD_TYPE = 1
           do message_key GRC_M_StFnE
           state fence_processing

state fence_processing
    status_key GR_I_FncCntPrc
    execute construct_fence_set
    execute start_transition_for_graphics_set        
    execute build_locate_criteria
    execute generate_right_prism_from_fence
        on RETURN_CODE = "MSFAIL"
            do status_key  GR_F_NoActFncDfn
            state terminate
    execute store_right_prism_in_fence_set
    execute generate_select_set_from_right_prism
    execute end_transition_for_graphics_set
    execute define_active_select_set_from_graphics_set_with_fence
        on RETURN_CODE = "MSFAIL"
            do status_key GR_E_EleNotFnd
            state terminate
        on SUCCESS or WARNING
            do fix_up_fence(GRIS_BACKGROUND_DISPLAY)
            do status_key  EX_S_Clear
                state get_from_point

state get_from_point        
    prompt_key  GR_P_EntFromPt
    filter get_event
        on EX_DATA
            do store_event(1,0)
            state get_to_point
        on EX_RJT_MOVEON
            state .
        on EX_BACK_UP
            state .

state get_to_point
    prompt_key  GR_P_EntDesPt
    filter get_event
        on EX_DATA
            do store_event ( 1, 1)
            do draw_objects(GRbehe)
                on ERROR
                    state error_occurred
            do get_matrix()
                on SUCCESS
                    do transform ()
                        on SUCCESS or WARNING
                            do stretch ()
                                on SUCCESS or WARNING
                                    do copy_event (1, 0)
                                    do draw_objects(GRbd)
                                    state regenerate_prism
                                    on ERROR
                                        state error_occurred
                            state terminate
                        on ERROR
                            state error_occurred
                    state terminate
                on ELSE
                    state error_occurred
            state terminate
        on EX_RJT_MOVEON
            state .
        on EX_BACK_UP
            state get_from_point

state regenerate_prism
    execute generate_new_prism()
    execute store_right_prism_in_fence_set
/*    execute connect_fence_to_inside_channel() */
        on ELSE
                state get_to_point
                
state error_occurred
    status_key GR_E_ErrEncCmdRst
    execute draw_objects(GRbd)
        on ELSE
                state start

