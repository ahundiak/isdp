/*
Name
        COareapat

Description
        This file contains the state transition table for the Pattern
        Element Area command.

History
        mrm     08/26/88    COBbed from existing command
*/

class               COpattern
super_class         CEO_LOCATE
command_object      GRMPatEleAr, 0, GRPArPt
product_name        "$PLATFORM"
options             "si"
start_state         locate_object

state_table

#include "execmsg.h"
#include "grmessage.h"

at wakeup
    do message_key GRC_M_PatEleAr
    do get_symbol (1)

state locate_object
    prompt_key GR_P_IdEle
    accept_key GR_P_AccPatOrg
    relocate_key GR_E_EleNotFnd
    locate_mask "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    accept_mask "GRm_DATA"
    unhighlight_mode GRbehe
    locate_eligible "+GRbspline, GRcompcurve"
    locate_owner "LC_NON_GEOM_MOD"
    locate_properties "LC_WRITE_ONLY | LC_LC_ONLY | LC_DP_ONLY | LC_PHY_CLOSED"
    locate_display "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                    ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT |
                    LC_ERASE_ALL"
    filter locate
        on EX_DATA
            do store_event (1, 0)
            do status_key GR_I_GenPat
            do generate_pattern (0)
                on SUCCESS
                    do display_mode GRbd
                    do display_constructed (sts)
                    do disconnect_constructed 0
                    do status_key EX_S_Clear
                    state .
                on ELSE
                    do status_key GR_E_ErrEncCmdRst
                    do display_mode GRbd
                    do display_located (sts)
                    do delete_pattern ()
                    state .
            state terminate
