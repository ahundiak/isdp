/*
Name
        COscaleas.t

Description
        This file contains the transition table for the Scale by Active
        Scale and Copy and Scale by Active Scale commands.

History
        mrm     08/04/88    COBbed from old command
                09/13/89    display active scale in the status field
        DLB     04/19/91    added LC_ASSOC
*/

class               COmanip
super_class         CEO_GSLOCATE
command_object      GRMScActSc, COmn_scale_as, GRScE
synonym             GRMCpScActSc, COmn_cp_scale_as, GRCpScE
product_name        "$PLATFORM"
options             "si"
start_state         start

state_table

#include "comnindex.h"
#include "comndef.h"
#include "grmessage.h"

state start
    on CMD_TYPE = COmn_scale_as
        do message_key GRC_M_ScActSc
        do locate_properties "MOVE_LC_PROPS"
        do locate_owner "LC_GEOM_MOD | LC_REF_HEADER | LC_REF_OBJECTS | LC_ASSOCIATIVE"
        state locate_object
    on CMD_TYPE = COmn_cp_scale_as
        do message_key GRC_M_CpScActSc
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
    execute show_attribute ()
    filter gs_locate_noauto
        on EX_DATA
            do store_event (1, 0)
            state scale_object

state get_scale_origin
    prompt_key GR_P_EntOrgSc
    filter get_event
        on EX_DATA
            do store_event (1, 0)
            state scale_object
        on EX_RJT_MOVEON or EX_BACK_UP or EX_RESTART
            do disconnect_located 1
            state locate_object

state scale_object     /* dummy state; scale the object */
    execute get_matrix ()
        on SUCCESS
            on CMD_TYPE = COmn_scale_as
                do transform ()
                    on SUCCESS or WARNING
                        state get_scale_origin
                    on ERROR
                        do status_key GR_E_ErrEncCmdRst
                        do disconnect_located 1
                        state locate_object
                state terminate
            on CMD_TYPE = COmn_cp_scale_as
                do transform_copy ()
                    on SUCCESS or WARNING
                        state get_scale_origin
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
