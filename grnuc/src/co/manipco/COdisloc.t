/*
Name
        COdisloc.t

Description
        This files contains the transition table for the Element Display
        On, Element Display Off, Element Locate On, and Element Locate Off
        commands.

History
        mrm     08/16/88    COBbed from existing command
                01/18/90    Removed unhighlight_mode and display after accept
*/

class               COchange
super_class         COdpb
super_class         COtools
super_class         CEO_GSLOCATE
command_object      GRMEleLocOff, COch_loc_off , GRTrOfELc
synonym             GRMEleLocOn, COch_loc_on, GRTrOnELc
synonym             GRMEleDspOff, COch_dis_off, GRTrOfEDs
synonym             GRMEleDspOn, COch_dis_on, GRTrOnEDs
product_name        "$GRNUC"
options             "si"
spec_path           "$GRNUC/spec"
start_state         start

state_table

#include "cochindex.h"
#include "comndef.h"
#include "grmessage.h"

at wakeup
    do hhlite_ele ()

at sleep
    do COtools.erase_highlight ()

state start
    on CMD_TYPE = COch_loc_off
        do message_key GRC_M_EleLocOff
        do highlight_mode GRhdo
        do locate_display "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                           ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT |
                           LC_ERASE_ALL | LC_ACCEPT_CURSOR"
        do locate_properties "LC_LC_ONLY | LC_DP_INVIS |
                              LC_NEW_MOD | LC_PLANAR_NON_PLANAR | LC_RW"
        state locate_object

    on CMD_TYPE = COch_loc_on
        do message_key GRC_M_EleLocOn
        do highlight_mode GRhdo
        do locate_display "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                           ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT |
                           LC_ERASE_LOC_ELEMENT | LC_ACCEPT_CURSOR"
        do locate_properties "LC_NONLC_ONLY | LC_DP_INVIS |
                              LC_NEW_MOD | LC_PLANAR_NON_PLANAR | LC_RW"
        state locate_object

    on CMD_TYPE = COch_dis_off
        do message_key GRC_M_EleDspOff
        do highlight_mode GRhd
        do locate_display "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                           ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT |
                           LC_ERASE_ALL | LC_ACCEPT_CURSOR"
        do locate_properties "LC_LC_NONLC | LC_DP_ONLY |
                              LC_NEW_MOD | LC_PLANAR_NON_PLANAR | LC_RW"
        state locate_object

    on CMD_TYPE = COch_dis_on
        do message_key GRC_M_EleDspOn
        do highlight_mode GRhdo
        do locate_display "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                           ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT |
                           LC_ERASE_LOC_ELEMENT | LC_ACCEPT_CURSOR"
        do locate_properties "LC_LC_NONLC | LC_INVIS_ONLY |
                              LC_NEW_MOD | LC_PLANAR_NON_PLANAR | LC_RW"
        state locate_object

state locate_object
    prompt_key GR_P_IdEle
    accept_key GR_P_Acc
    relocate_key GR_E_EleNotFnd
    gslocate_spec_prompt1_key GR_P_AccFnc
    gslocate_num_inputs 1
    locate_mask "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    accept_mask "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    gslocate_spec_mask1 "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    locate_eligible "+GRvg"
    locate_owner "LC_NON_GEOM_MOD"
    filter gs_locate_noauto
        on SUCCESS
            on EX_DATA or EX_OBJID or EX_STRING
                do use_events ()
                    on SUCCESS
                        do COtools.push_event (&me->event1)
                        on CMD_TYPE = COch_loc_off or CMD_TYPE = COch_loc_on
                            do display_mode GRheo
                            do display_located
                            do disconnect_located 1
                            state .
                        on CMD_TYPE = COch_dis_off
                            do display_mode GRbeheo
                            do display_located
                            do disconnect_located 1
			    /* TR 90N1761 
			    do update_wins */
                            state .
                        on CMD_TYPE = COch_dis_on
                            do display_mode GRbdheo
                            do display_located
                            do disconnect_located 1
                            state .
                        state .
                    on WARNING or ERROR
                        do status_key GR_E_ErrEncCmdRst
                        do disconnect_located 1
                        state .
                state .
            state .
