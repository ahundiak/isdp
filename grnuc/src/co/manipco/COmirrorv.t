/*
Name
        COmirrorv.t

Description
        This file contains the transition table for the Mirror Vertical and
        Copy and Mirror Vertical commands.

History
        mrm     08/11/88    COBbed from existing command
        DLB     04/19/91    added LC_ASSOC
*/

class               COmanip
super_class         CEO_GSLOCATE
command_object      GRMMirVer, COmn_mirrorv, GRMrEAbVrA
synonym             GRMCpMirVer, COmn_cp_mirrorv, GRCpMrEAbV
product_name        "$PLATFORM"
options             "si"
start_state         start

state_table

#include "comnindex.h"
#include "comndef.h"
#include "grmessage.h"

state start
    on CMD_TYPE = COmn_mirrorv
        do message_key GRC_M_MirVer
        do locate_properties "MOVE_LC_PROPS"
        do locate_owner "LC_GEOM_MOD | LC_REF_HEADER | LC_REF_OBJECTS | LC_ASSOCIATIVE"
        state locate_object
    on CMD_TYPE = COmn_cp_mirrorv
        do message_key GRC_M_CpMirVer
        do locate_properties "COPY_LC_PROPS"
        do locate_owner "COPY_LC_OWNER"
        state locate_object

state locate_object
    prompt_key GR_P_IdEle
    accept_key GR_P_AccMirLn
    gslocate_spec_prompt1_key GR_P_DfnMirLn
    relocate_key GR_E_EleNotFnd
    gslocate_num_inputs 1
    locate_mask "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    accept_mask "GRm_DATA | GRm_RESTART"
    gslocate_spec_mask1 "GRm_DATA | GRm_RESTART"
    locate_eligible "+GRgraphics"
    locate_display "MANIP_LC_DISFLAG"
    execute setup_lcdyn (COmn_mirrorv)
    execute erase_hilite_plane ()
    filter gs_locate_noauto
        on EX_DATA
            do store_event (1, 0)
            state mirror_object

state get_mirror_line
    prompt_key GR_P_EntPtMirLn
    dynamics COmn_mirrorv
    filter get_event
        on EX_DATA
            do store_event (1, 0)
            state mirror_object
        on EX_RJT_MOVEON or EX_RESTART or EX_RJT_MOVEON
            do disconnect_located 1
            state locate_object

state mirror_object     /* dummy state; mirror the object */
    execute get_matrix ()
        on SUCCESS
            on CMD_TYPE = COmn_mirrorv
                do transform ()
                    on SUCCESS or WARNING
                        state get_mirror_line
                    on ERROR
                        do status_key GR_E_ErrEncCmdRst
                        do disconnect_located 1
                        state locate_object
                state terminate
            on CMD_TYPE = COmn_cp_mirrorv
                do transform_copy ()
                    on SUCCESS or WARNING
                        state get_mirror_line
                    on ERROR
                        do status_key GR_E_ErrEncCmdRst
                        do disconnect_located 1
                        state locate_object
                state terminate
        on ELSE
            do status_key GR_E_ErrEncCmdRst
            do disconnect_located 1
            state locate_object
        state terminate
 
