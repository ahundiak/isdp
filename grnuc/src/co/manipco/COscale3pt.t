/*
Name
        COscale3pt.t

Description
        This file contains the transition table for the Scale by 3 Points
        and Copy and Scale by 3 Points commands.

History
        mrm     08/11/88    creation
        DLB     04/19/91    added LC_ASSOC
*/

class               COmanip
super_class         CEO_GSLOCATE
command_object      GRMSc3Pts, COmn_scale_3pts, GRScE3Pn
synonym             GRMCpSc3Pts, COmn_cp_scale_3pts, GRCpScE3Pn
product_name        "$PLATFORM"
options             "si"
start_state         start


state_table

#include "comnindex.h"
#include "comndef.h"
#include "grmessage.h"

state start
    on CMD_TYPE = COmn_scale_3pts
        do message_key GRC_M_Sc3Pts
        do locate_properties "MOVE_LC_PROPS"
        do locate_owner "LC_GEOM_MOD | LC_REF_HEADER | LC_REF_OBJECTS | LC_ASSOCIATIVE"
        state locate_object
    on CMD_TYPE = COmn_cp_scale_3pts
        do message_key GRC_M_CpSc3Pts
        do locate_properties "COPY_LC_PROPS"
        do locate_owner "COPY_LC_OWNER"
        state locate_object

state locate_object
    prompt_key GR_P_IdEle
    accept_key GR_P_AccOrgSc
    gslocate_spec_prompt1_key GR_P_EntOrgSc
    relocate_key GR_E_EleNotFnd
    gslocate_num_inputs 1
    locate_mask "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    accept_mask "GRm_DATA | GRm_RESTART"
    gslocate_spec_mask1 "GRm_DATA | GRm_RESTART"
    locate_eligible "!+GRdrawview, GRdvattach"
    locate_display "MANIP_LC_DISFLAG"
    execute erase_hilite_plane ()
    filter gs_locate_noauto
        on EX_DATA
            do store_event (1, 0)
            state get_reference_pt

state get_scale_origin
    prompt_key GR_P_EntOrgSc
    filter get_event
        on EX_DATA
            do store_event (1, 0)
            state get_reference_pt
        on EX_BACK_UP or EX_RESTART
            do disconnect_located 1
            state locate_object

state get_reference_pt
    prompt_key GR_P_EntRefPt
    filter get_event
        on EX_DATA
            do store_event (1, 1)
            state define_scale
        on EX_BACK_UP
            state get_scale_origin
        on EX_RESTART
            do disconnect_located 1
            state locate_object

state define_scale
    prompt_key GR_P_DfnScFac
    dynamics COmn_scale_3pts
    filter get_event
        on EX_DATA
            do store_event (1, 2)
            do get_matrix ()
                on SUCCESS
                    on CMD_TYPE = COmn_scale_3pts
                        do transform ()
                            on SUCCESS or WARNING
                                do copy_events (2, 1)
                                state .
                            on ERROR
                                do status_key GR_E_ErrEncCmdRst
                                do disconnect_located 1
                                state start
                        state terminate
                    on CMD_TYPE = COmn_cp_scale_3pts
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
        on EX_BACK_UP
            state -
        on EX_RJT_MOVEON or EX_RESTART
            do disconnect_located 1
            state locate_object
