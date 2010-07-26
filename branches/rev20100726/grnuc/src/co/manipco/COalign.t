/*
Name
        COalign.t

Description
        This command moves and rotates an element through space from a
        reference position and orientation to a new postion and orientation.

History
        mrm     08/10/88    COBbed from old command
*/

class               COmanip
super_class         CEO_GSLOCATE
command_object      GRMAlign, COmn_align, GRAlE
synonym             GRMCpAlign, COmn_cp_align, GRCpAlE
product_name        "$PLATFORM"
options             "si"
start_state         start


state_table

#include "comnindex.h"
#include "comndef.h"
#include "grmessage.h"

state *
    on EX_RESTART
        do disconnect_located 1
        state start
    on EX_BACK_UP
        state -

state start
    on CMD_TYPE = COmn_align
        do message_key GRC_M_Align
        do locate_properties "MOVE_LC_PROPS"
        do locate_owner "MOVE_LC_OWNER"
        state locate_object
    on CMD_TYPE = COmn_cp_align
        do message_key GRC_M_CpAlign
        do locate_properties "COPY_LC_PROPS"
        do locate_owner "COPY_LC_OWNER"
        state locate_object

state locate_object
    prompt_key GR_P_IdEle
    accept_key GR_P_AccOrgCurOr
    gslocate_spec_prompt1_key GR_P_EntOrgCurOr
    relocate_key GR_E_EleNotFnd
    gslocate_num_inputs 1
    locate_mask "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    accept_mask "GRm_DATA | GRm_RESTART"
    gslocate_spec_mask1 "GRm_DATA | GRm_RESTART"
    locate_eligible "+GRgraphics"
    locate_display "MANIP_LC_DISFLAG"
    execute erase_hilite_plane ()
    filter gs_locate_noauto
        on EX_DATA
            do store_event (1, 0)
            state get_pt2_curr_orientation

state get_pt1_curr_orientation
    prompt_key GR_P_EntOrgCurOr
    filter get_event
        on EX_DATA
            do store_event (1, 0)
            state get_pt2_curr_orientation
        on EX_BACK_UP
            do disconnect_located 1
            state locate_object

state get_pt2_curr_orientation
    prompt_key GR_P_Ent2PtCurOr
    filter get_event
        on EX_DATA
            do store_event (1, 1)
            state get_pt3_curr_orientation
        on EX_BACK_UP
            state get_pt1_curr_orientation

state get_pt3_curr_orientation
    prompt_key GR_P_Ent3PtCurOr
    filter get_event
        on EX_DATA
            do store_event (1, 2)
            do check_planarity (0, 1, 2)
                on ERROR
                    do status_key GR_E_PtsNotPlanar
                    state .
                on ELSE
                    state get_new_origin
            state terminate

state get_new_origin
    prompt_key GR_P_EntNewOrg
    filter get_event
        on EX_DATA
            do store_event (1, 3)
            state get_pt2_new_orientation

state get_pt2_new_orientation
    prompt_key GR_P_Ent2PtNewOr
    filter get_event
        on EX_DATA
            do store_event (1, 4)
            state get_pt3_new_orientation

state get_pt3_new_orientation
    prompt_key GR_P_Ent3PtNewOr
    filter get_event
        on EX_DATA
            do store_event (1, 5)
            do check_planarity (3, 4, 5)
                on ERROR
                    do status_key GR_E_PtsNotPlanar
                    state .
                on ELSE
                    do get_matrix ()
                        on SUCCESS
                            on CMD_TYPE = COmn_align
                                do transform ()
                                    on SUCCESS or WARNING
                                        do disconnect_located 1
                                        state start
                                    on ERROR
                                        do status_key GR_E_ErrEncCmdRst
                                        do disconnect_located 1
                                        state start
                                state terminate
                            on CMD_TYPE = COmn_cp_align
                                do transform_copy ()
                                    on SUCCESS or WARNING
                                        do disconnect_located 1
                                        state start
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
            state terminate
