/*
Name
        COchattr.t

Description
        This file contains the transition table for the change symbology,
        color, style, weight, layer, and copy and change layer commands.

History
        mrm     08/16/88    COBbed from existing command
                09/22/89    add color, layer, and copy and change layer,
		            prompt user for new attribute to change,
                            union with COdpb and COtools
*/

class               COchange
super_class         COdpb
super_class         COtools
super_class         CEO_GSLOCATE
command_object      GRMChEleSym, COch_symbology, GRCSy
synonym             GRMChEleSt, COch_style, GRCSt
synonym             GRMChEleWt, COch_weight, GRCWg
synonym             GRMChEleCo, COch_color, GRCCl
synonym             GRMChEleLy, COch_layer, GRCLy
synonym             GRMCpChLy, COch_cp_layer, GRCpChLy
product_name        "$PLATFORM"
options             "si"
spec_path           "$GRNUC/co/spec"
start_state         start

state_table

#include "cochindex.h"
#include "comndef.h"
#include "grmessage.h"
#include "dpbco.h"

at init
    do COdpb.alloc (sts, 0)
    do COdpb.active (sts, 0)
    do COdpb.get_dpb (sts, CO_sym, 0)

at delete
    do COdpb.dealloc (sts, 0)

state *
    on EX_BACK_UP state -
    on EX_RESTART state start

state start
    on CMD_TYPE = COch_symbology
        do message_key GRC_M_ChEleSym
        do locate_properties "MOVE_LC_PROPS | LC_RW"
        do locate_owner "LC_NON_GEOM_MOD"
        state get_new_color
    on CMD_TYPE = COch_color
        do message_key GRC_M_ChEleCo
        do locate_properties "MOVE_LC_PROPS | LC_RW"
        do locate_owner "LC_NON_GEOM_MOD"
        state get_new_color
    on CMD_TYPE = COch_weight
        do message_key GRC_M_ChEleWt
        do locate_properties "MOVE_LC_PROPS | LC_RW"
        do locate_owner "LC_NON_GEOM_MOD"
        state get_new_weight
    on CMD_TYPE = COch_style
        do message_key GRC_M_ChEleSt
        do locate_properties "MOVE_LC_PROPS | LC_RW"
        do locate_owner "LC_NON_GEOM_MOD"
        state get_new_style
    on CMD_TYPE = COch_layer
        do message_key GRC_M_ChEleLy
        do locate_properties "MOVE_LC_PROPS | LC_RW"
        do locate_owner "LC_NON_GEOM_MOD|LC_HANDLES"
        state get_new_layer
    on CMD_TYPE = COch_cp_layer
        do message_key GRC_M_CpChLy
        do locate_properties "COPY_LC_PROPS"
        do locate_owner "COPY_LC_OWNER"
        state get_new_layer
    on ELSE
        do status_key GR_E_ErrEncCmdTrm
        state terminate

state get_new_color
    execute COdpb.get (sts, CO_color, me->status, CO_message)
    status 0
    prompt_key GR_P_EntNwCoMvOn
    filter get_event
        on EX_RJT_MOVEON or EX_STRING.GRst_DEFAULT or EX_VALUE.GRst_DEFAULT
            on CMD_TYPE = COch_symbology
                state get_new_weight
            on ELSE
                state locate_object
            state terminate
        on SCALAR
	    do COdpb.put (sts, CO_color, &me->event1.event.value, CO_double)
                on SUCCESS
                    on CMD_TYPE = COch_symbology
                        state get_new_weight
                    on ELSE
                        state locate_object
                    state terminate
                on ELSE /* CO_E_INVINP */
                    do status_key GR_E_InvCo
                    state .
            state terminate
        on EX_STRING
            do COdpb.put (sts, CO_color, me->event1.event.keyin, CO_string)
                on SUCCESS
                    on CMD_TYPE = COch_symbology
                        state get_new_weight
                    on ELSE
                        state locate_object
                    state terminate
                on ELSE /* CO_E_INVINP */
                    do status_key GR_E_InvCo
                    state .
            state terminate

state get_new_weight
    execute COdpb.get (sts, CO_weight, me->status, CO_message)
    status 0
    prompt_key GR_P_EntNwWtMvOn
    filter get_event
        on EX_RJT_MOVEON or EX_STRING.GRst_DEFAULT or EX_VALUE.GRst_DEFAULT
            on CMD_TYPE = COch_symbology
                state get_new_style
            on ELSE
                state locate_object
            state terminate
        on SCALAR
	    do COdpb.put (sts, CO_weight, &me->event1.event.value, CO_double)
                on SUCCESS
                    on CMD_TYPE = COch_symbology
                        state get_new_style
                    on ELSE
                        state locate_object
                    state terminate
                on ELSE /* CO_E_INVINP */
                    do status_key GR_E_InvWt
                    state .
            state terminate
        on EX_STRING
            do COdpb.put (sts, CO_weight, me->event1.event.keyin, CO_string)
                on SUCCESS
                    on CMD_TYPE = COch_symbology
                        state get_new_style
                    on ELSE
                        state locate_object
                    state terminate
                on ELSE /* CO_E_INVINP */
                    do status_key GR_E_InvWt
                    state .
            state terminate

state get_new_style
    execute COdpb.get (sts, CO_style, me->status, CO_message)
    status 0
    prompt_key GR_P_EntNwStMvOn
    filter get_event
        on EX_RJT_MOVEON or EX_STRING.GRst_DEFAULT or EX_VALUE.GRst_DEFAULT
            state locate_object
        on SCALAR
            do COdpb.put (sts, CO_style, &me->event1.event.value, CO_double)
                on SUCCESS
                    state locate_object
                on ELSE /* CO_E_INVINP */
                    do status_key GR_E_InvWt
                    state .
            state terminate
        on EX_STRING
            do COdpb.put (sts, CO_style, me->event1.event.keyin, CO_string)
                on SUCCESS
                    state locate_object
                on ELSE /* CO_E_INVINP */
                    do status_key GR_E_InvSt
                    state .
            state terminate

state get_new_layer
    execute COdpb.get (sts, CO_level, me->status, CO_message)
    status 0
    prompt_key GR_P_EntNwLyMvOn
    filter get_event
        on EX_RJT_MOVEON or EX_STRING.GRst_DEFAULT or EX_VALUE.GRst_DEFAULT
            state locate_object
        on SCALAR
	    do COdpb.put (sts, CO_level, &me->event1.event.value, CO_double)
                on SUCCESS
                    state locate_object
                on ELSE /* CO_E_INVINP */
                    do status_key GR_E_InvLy
                    state .
            state terminate
        on EX_STRING
            do COdpb.put (sts, CO_level, me->event1.event.keyin, CO_string)
                on SUCCESS
                    state locate_object
                on ELSE /* CO_E_INVINP */
                    do status_key GR_E_InvLy
                    state .
            state terminate

state locate_object
    status_key GR_I_Clear
    prompt_key GR_P_IdEle
    accept_key GR_P_AccNxtEle
    gslocate_spec_prompt1_key GR_P_AccNxtEle
    relocate_key GR_E_EleNotFnd
    gslocate_num_inputs 1
    locate_mask "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE | GRm_BACK_UP | GRm_RESTART"
    accept_mask "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    gslocate_spec_mask1 "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    locate_eligible "+GRvg"
    locate_display "MANIP_LC_DISFLAG | LC_ACCEPT_CURSOR"
    filter gs_locate_noauto
        on SUCCESS
            on EX_DATA or EX_OBJID or EX_STRING
                do COtools.erase_highlight ()
                on CMD_TYPE = COch_symbology
                    do COdpb.change (sts, (CO_color | CO_weight | CO_style), &me->located_chansel)
                    do disconnect_located 1
                    do COtools.push_event (&me->event1)
                    state .
                on CMD_TYPE = COch_color
                    do COdpb.change (sts, CO_color, &me->located_chansel)
                    do disconnect_located 1
                    do COtools.push_event (&me->event1)
                    state .
                on CMD_TYPE = COch_weight
                    do COdpb.change (sts, CO_weight, &me->located_chansel)
                    do disconnect_located 1
                    do COtools.push_event (&me->event1)
                    state .
                on CMD_TYPE = COch_style
                    do COdpb.change (sts, CO_style, &me->located_chansel)
                    do disconnect_located 1
                    do COtools.push_event (&me->event1)
                    state .
                on CMD_TYPE = COch_layer
                    do COdpb.change (sts, CO_level, &me->located_chansel)
                    do disconnect_located 1
		    /* TR 90N1731 */
		    do display_located 
                    do COtools.push_event (&me->event1)
                    state .
                on CMD_TYPE = COch_cp_layer
                    do COchange.copy (&me->located_chansel)
                    do COdpb.change (sts, CO_level, &me->located_chansel)
                    do disconnect_located 1
                    do COtools.push_event (&me->event1)
                    state .
                state terminate
            state terminate
