/*
Name
        COedgepat

Description
        This file contains the state transition table for the Pattern
        Element Edge command.

History
        mrm     08/26/88    COBbed from existing command
*/

class               COpattern
super_class         CEO_LOCATE
command_object      GRMPatEleEdg, 1, GRPEdPt
product_name        "$PLATFORM"
options             "si"
start_state         locate_object

state_table

#include "execmsg.h"
#include "grmessage.h"
#include "lcdef.h"

at wakeup
    do get_symbol (1)

state *
    on EX_RESTART
        state locate_object

state locate_object
    message_key GRC_M_PatEleEdg
    prompt_key GR_P_IdEle
    accept_key GR_P_AccStaPt
    relocate_key GR_E_EleNotFnd
    locate_mask "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    accept_mask "GRm_DATA | GRm_RESTART"
    locate_eligible "+GRbspline, GRcompcurve"
    locate_owner "LC_NON_GEOM_MOD"
    locate_properties "LC_WRITE_ONLY | LC_LC_ONLY | LC_DP_ONLY"
    locate_display "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                    ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT |
                    LC_ERASE_ALL"
    filter locate
        on EX_DATA
            do store_event (1, 0)
            state get_stop_point

state get_start_point
    prompt_key GR_P_EntStartPt
    filter get_event
        on EX_DATA
            do store_event (1, 0)
            state get_stop_point
        on EX_BACK_UP
            state locate_object

state get_stop_point
    prompt_key GR_P_EntStpPt
    filter get_event
        on EX_DATA
            do store_event (1, 1)
            do check_closure (1)
                on MSFAIL
                    state .
                on RETURN_CODE > 0
                    state get_direction_point
                on RETURN_CODE = 0
                    do status_key GR_I_GenPat
                    do generate_pattern (1)
                        on SUCCESS
                            do display_mode GRbd
                            do display_constructed (sts)
                            do disconnect_constructed 0
                            do status_key EX_S_Clear
                            state locate_object
                        on ELSE
                            do delete_pattern ()
                            do status_key GR_E_ErrEncCmdRst
                            state locate_object
                    state terminate
                on ELSE
                    state .
            state terminate
        on EX_BACK_UP
            state get_start_point

state get_direction_point
    status_key GR_I_EleCls
    prompt_key GR_P_EntPtDir
    filter get_event
        on EX_DATA
            do store_event (1, 2)
            do status_key GR_I_GenPat
            do generate_pattern (2)
                on SUCCESS
                    do display_mode GRbd
                    do display_constructed (sts)
                    do disconnect_constructed 0
                    do status_key EX_S_Clear
                    state locate_object
                on ELSE
                    do delete_pattern ()
                    do status_key GR_E_ErrEncCmdRst
                    state locate_object
            state terminate
        on EX_BACK_UP
            state get_stop_point
