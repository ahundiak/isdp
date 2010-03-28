/*
Name
        COrot3pt.t

Description
        This file contains the transition table for the Rotate by 3 Points
        and Copy and Rotate by 3 Points commands.

History
        mrm     08/11/88    creation
        DLB     04/19/91    added LC_ASSOC
*/

class               COmanip
super_class         CEO_GSLOCATE
command_object      GRMRot3Pts, COmn_rotate_3pts, GRRtE3Pn
synonym             GRMCpRot3Pts, COmn_cp_rotate_3pts, GRCpRtE3Pn
product_name        "$PLATFORM"
options             "si"
start_state         start


state_table

#include "comnindex.h"
#include "comndef.h"
#include "grmessage.h"

state start
    on CMD_TYPE = COmn_rotate_3pts
        do message_key GRC_M_Rot3Pts
        do locate_properties "MOVE_LC_PROPS"
        do locate_owner "LC_GEOM_MOD | LC_REF_HEADER | LC_REF_OBJECTS | LC_ASSOCIATIVE"
        state locate_object
    on CMD_TYPE = COmn_cp_rotate_3pts
        do message_key GRC_M_CpRot3Pts
        do locate_properties "COPY_LC_PROPS"
        do locate_owner "COPY_LC_OWNER"
        state locate_object

state locate_object
    prompt_key GR_P_IdEle
    accept_key GR_P_AccPivPt
    gslocate_spec_prompt1_key GR_P_EntPivPt
    relocate_key GR_E_EleNotFnd
    gslocate_num_inputs 1
    locate_mask "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    accept_mask "GRm_DATA"
    gslocate_spec_mask1 "GRm_DATA"
    locate_eligible "+GRgraphics"
    locate_display "MANIP_LC_DISFLAG"
    execute erase_hilite_plane ()
    filter gs_locate_noauto
        on EX_DATA
            do store_event (1, 0)
            state get_reference_pt

state get_pivot_point
    prompt_key GR_P_EntPivPt
    filter get_event
        on EX_DATA
            do store_event (1, 0)
            state get_reference_pt
        on EX_BACK_UP or EX_RJT_MOVEON
            do disconnect_located 1
            state locate_object

state get_reference_pt
    prompt_key GR_P_EntHndlPt
    filter get_event
        on EX_BACK_UP
            state get_pivot_point
        on EX_RJT_MOVEON
            do disconnect_located 1
            state locate_object
        on EX_DATA
            do store_event (1, 1)
            do store_value (3, 0.0) /* dynamics flag - recalculate radius */
                                    /* of lines defining rotation angle   */
            state define_angle

state define_angle
    prompt_key GR_P_DfnRotAng
    dynamics COmn_rotate_3pts
    filter get_event
        on EX_DATA
            do store_event (1, 2)
            do get_matrix ()
                on SUCCESS
                    on CMD_TYPE = COmn_rotate_3pts
                        do transform ()
                            on SUCCESS or WARNING
                                do copy_events (2, 1)
                                state .
                            on ERROR
                                do status_key GR_E_ErrEncCmdRst
                                do disconnect_located 1
                                state start
                        state terminate
                    on CMD_TYPE = COmn_cp_rotate_3pts
                        do transform_copy ()
                            on SUCCESS or WARNING
                                do copy_events (2, 1)
                                state .
                            on ERROR
                                do status_key GR_E_ErrEncCmdRst
                                do disconnect_located 1
                                state start
                        state terminate
                    state terminate
                on ELSE
                    do status_key GR_E_ErrEncCmdRst
                    do disconnect_located 1
                    state start
            state terminate
        on EX_RJT_MOVEON or EX_RESTART
            do disconnect_located 1
            state locate_object
        on EX_BACK_UP
            state -
