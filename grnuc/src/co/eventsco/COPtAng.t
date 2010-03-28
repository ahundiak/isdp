/*
Name
        COPtAng

Description
        This file contains the transition table for the point at angle
        to/from commands

History
        mrm     02/17/88    creation
                05/24/89    added auto accept, retrieve locate criteria
                09/26/89    exclude text, raster, reference files
*/

class               COevgen
super_class         CEO_LOCATE
command_object      GRMPtAngFr, COev_pt_angle_from, GRSlPnAnFr
synonym             GRMPtAngTo, COev_pt_angle_to, GRSlPnAnT
product_name        "$PLATFORM"
options             "si"
start_state         start

/*-----*/

state_table

#include "lcdef.h"
#include "coevindex.h"
#include "grmessage.h"

#define ACCEPT_POINT 1

state *
    on EX_RESTART or EX_BACK_UP
        state start

state start
    on CMD_TYPE = COev_pt_angle_from
        do message_key GRC_M_PtAngFr
        do locate_eligible "!+EMScompsurf, GRsmhdr, GRclhdr, GRgrgrp, GRdrawview, GRdvattach, GRtext, GRrg, GRreffile"
        state locate_object
    on CMD_TYPE = COev_pt_angle_to
        do message_key GRC_M_PtAngTo
        do locate_eligible "!+EMSsurface, GRsmhdr, GRclhdr, GRgrgrp, GRdrawview, GRdvattach, GRtext, GRrg, GRreffile"
        state locate_object

state locate_object
    prompt_key GR_P_IdEle
    accept_key GR_P_AccNrDsrAngPt
    relocate_key GR_E_EleNotFnd
    locate_mask "GRm_DATA | GRm_OBJID"
    accept_mask "GRm_DATA"
    locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_RW
                     | IGN_MOD_BIT | IGN_PLANAR_BIT"
    locate_owner "LC_RIGID_COMP | LC_FLEX_COMP | LC_NO_RIGID_OWNER
                | LC_NO_FLEX_OWNER | LC_REF_HEADER | LC_REF_OBJECTS"
    locate_display "ALL_WINDOWS | SEGMENT_HILIGHT | PROJ_ACCEPT_POINT
                  | ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT
                  | LC_ERASE_LOC_ELEMENT | LC_Retrieve_Criteria
                  | LC_ACC_ONE_ELEMENT"
    unhilight_mode GRhe
    filter locate
        on RETURN_CODE = LC_OBJ_LOCATED or RETURN_CODE = LC_ONE_ELEM_ACCEPT
            do store_event (ACCEPT_POINT,0)
            state get_angle

state get_angle
    prompt_key GR_P_KyAng
    filter get_event
        on EX_RJT_MOVEON or RETURN_CODE = GRw_no_value
            do move_angle_to_event (1)
            do use_events ()
                on SUCCESS or INFORMATION
                    do push_event (0)
                    do disconnect_located 1
                    state terminate
                on ELSE
                    do status_key GR_E_ErrEncCmdTrm
                    state terminate
            state terminate
        on ANGLE
            do store_event (ACCEPT_POINT,1)
            do use_events ()
                on SUCCESS or INFORMATION
                    do push_event (0)
                    do disconnect_located 1
                    state terminate
                on ELSE
                    do status_key GR_E_ErrEncCmdTrm
                    state terminate
            state terminate
