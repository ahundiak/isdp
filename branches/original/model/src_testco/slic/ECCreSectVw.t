/*
    gslocate_num_inputs 1
    unhilight_mode       GRhe
 *  Name
 *      COsectionview
 *
 *  Description
 *      This command creates a sectional view from a principal view.
 *
 *  History
 *      WBC  07/10/91    Creation date
 */

command_string      MDCrScVw,ECsectvw,MDCrScVw
class               ECsectvw
spec_path           "$GRNUC/spec"
spec_path           "$MODEL/spec"
status_display      "MDSectView","-1","-1"
form                "Crosshatch",0,0,"-1","-1"
product_name        "$MODEL"
options	  	    "sicT"
start_state         start

state_table
#include "OMerrordef.h"
#include <grmessage.h>
#include <griodef.h>
#include <lcdef.h>
#include <exdef.h>
#include <var.h>
#include <msdef.h>
#include <grerr.h>
#include <toolco.h>
#include "detailco.h"
#include "DIdef.h"
#include "EMSmsgdef.h"
#include "EMSasectvw.h"
#include "ECcmd.h"
#include "ECmsg.h"
#include "execmsg.h"
#include "dp.h"
#include "igrdef.h"

state *
on EX_RESTART
      do COtools.empty_channel(&me->located_chansel)
      do ECsectvw.terminate_select_handler()          state start
on EX_FORM_FINISHED                                   state .

state start
    execute              clear_default_scale()
    message_key          EM_M_CrScVw
    prompt_key           GR_P_IdDrwVw
    accept_key           EMS_P_IdCtPlLnRj
    relocate_key         GR_E_EleNotFnd
    locate_eligible      "GRdrawview"
    locate_owner         "LC_READ | LC_NO_REF_HEADER | LC_NO_REF_OBJECTS"
    locate_properties    "LC_LC_ONLY | LC_RW | LC_DP_ONLY"
    locate_display       "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
    filter gs_locate
on EX_BACK_UP                                         state start
on EX_DATA or TEXT_VALUE
        do COtools.assign ( &me->event2.event.button,
                            me->window_matrix,
                            CO_btn_to_mtx )
        do COtools.assign ( &me->event2.event.button,
                            &me->window_id,
                            CO_btn_to_grid )
        do set_defaults()
        do send_foreign ( CO_get_drawview_scale )
        do set_default_scale()
        do send_foreign (CO_get_projection_angle)
        do ECsectvw.store_located_object(0)
        do COtools.push_event(&me->event1)            state have_drawing_view

state have_drawing_view
    execute ECsectvw.setup_select_handler()
    prompt_key           EMS_P_IdCtPlLn
    accept_key           GR_P_Acc
    relocate_key         GR_E_EleNotFnd
    locate_eligible      "+GRcurve"
    locate_owner         "LC_READ | LC_NO_REF_HEADER | LC_NO_REF_OBJECTS"
    locate_properties    "LC_LC_ONLY | LC_RW | LC_DP_ONLY"
    locate_display       "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
    filter gs_locate
on EX_BACK_UP
        do ECsectvw.terminate_select_handler()        state start
on EX_DATA
        do COtools.assign ( &me->event1,
                            &me->event3,
                            CO_evt_to_evt )        
        do ECsectvw.terminate_select_handler()
        do ECsectvw.store_located_object(2)           state verify_cutting_line

state verify_cutting_line
        execute verify_cut_plane_line()
            on RETURN_CODE = EMS_S_Success            state get_next_state
            on RETURN_CODE = EMS_E_InvalidArg
                do status_key EMS_S_LnNonPlnr         state have_drawing_view
            on RETURN_CODE = EMS_E_NotSupported
                do status_key EMS_S_NonLnCmpNotAl     state have_drawing_view
            on RETURN_CODE = EMS_E_NoSolution
                do status_key EMS_S_SlLnOvrlpSec      state have_drawing_view
            on RETURN_CODE = EMS_E_InvalidCase
                do status_key EMS_S_SlLnNotPlnDV      state have_drawing_view
            on ELSE
                do status_key  GR_E_ErrEncCmdRst      state start

state get_next_state
    execute selection_states()
        on RETURN_CODE = EMS_S_Success
            do ECsectvw.get_dv_solids(0)
               on RETURN_CODE = MSSUCC
                   do ECsectvw.highlight_solids(2)
                   do ECsectvw.request_unsectioned_models()
                       on RETURN_CODE = TRUE                  state get_unsectioned_solids
                       on RETURN_CODE = FALSE                 state have_parents
                       state start
               on RETURN_CODE = MSINARG
                   do status_key EMS_I_IdDrVwCntNoSl          state start
               state start
        on RETURN_CODE = EMS_I_Success                state get_parents
        on RETURN_CODE = EMS_W_Success                state push_line_accept

state push_line_accept
    execute COtools.push_event(&me->event3)
        on ELSE                                       state get_parents

state get_parents
    execute              COtools.erase_highlight()
    prompt_key           EMS_P_IdSlProc
    accept_key           EMS_P_AccIdNxtSlRj
    relocate_key         GR_E_EleNotFnd
    unhilight_mode       GRhhd
    locate_eligible      "+EMSsolid"
    locate_owner         "LC_READ | LC_REF_HEADER | LC_REF_OBJECTS"
    locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
    locate_display       "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
    filter gs_locate
on EX_BACK_UP                                         state have_drawing_view
on EX_DATA or TEXT_VALUE
        do ECsectvw.get_dv_solids(1)
            on RETURN_CODE = MSSUCC
                do COtools.push_event(&me->event1)
                do ECsectvw.add_verified_solids(TRUE)
                    on RETURN_CODE = MSSUCC
                       do disconnect_located  1            state get_solid_elems
                           on RETURN_CODE = EMS_S_ElNotSlDrVw
                               do status_key EMS_S_ElNotSlDrVw
                               do COtools.wait(120)
                               do highlight_located   0
                               do disconnect_located  1            state get_parents
                    on RETURN_CODE = EMS_I_ElAlrdySel
                        do status_key EMS_I_ElAlrdySel
                        do COtools.wait(120)
                        do disconnect_located  1            state get_parents
                    state start
            on RETURN_CODE = MSINARG
                do status_key EMS_I_IdDrVwCntNoSl          state start
            state start

state get_solid_elems
    prompt_key           EMS_P_IdNxtSlMvOnDn
    accept_key           EMS_P_AccIdNxtSlRj
    relocate_key         GR_E_EleNotFnd
    unhilight_mode       GRhhd
    locate_eligible      "+EMSsolid"
    locate_owner         "LC_READ | LC_REF_HEADER | LC_REF_OBJECTS"
    locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
    locate_display       "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
    filter gs_locate_noauto
on EX_BACK_UP                                         state get_parents
on EX_DATA or TEXT_VALUE 
        do COtools.push_event(&me->event1)
        do ECsectvw.add_verified_solids(TRUE)
               on RETURN_CODE = MSSUCC
                  do disconnect_located  1            state get_solid_elems
               on RETURN_CODE = EMS_S_ElNotSlDrVw
                  do status_key EMS_S_ElNotSlDrVw
                  do COtools.wait(120)
                  do highlight_located   0
                  do disconnect_located  1            state get_solid_elems
               on RETURN_CODE = EMS_I_ElAlrdySel
                  do status_key EMS_I_ElAlrdySel
                  do COtools.wait(120)
                  do disconnect_located  1            state get_solid_elems
        state start
on EX_RJT_MOVEON
        do ECsectvw.request_unsectioned_models()
               on RETURN_CODE = TRUE                  state get_unsectioned_solids
               on RETURN_CODE = FALSE                 state have_parents
        state start

state get_unsectioned_solids
    prompt_key           EMS_P_IdSlNotSect
    accept_key           EMS_P_AccIdNxtSlRj
    gslocate_spec_prompt1_key EMS_P_AccIdNxtSlRj
    relocate_key         GR_E_EleNotFnd
    locate_eligible      "+EMSsolid,GRclhdr,ACconst"
    locate_mask "GRm_BACK_UP| GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    accept_mask "GRm_DATA | GRm_RESTART"
    gslocate_spec_mask1 "GRm_DATA | GRm_RESTART | GRm_RJT_MOVEON"
    locate_owner         "LC_READ | LC_REF_HEADER | LC_REF_OBJECTS"
    locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
    locate_display       "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
    filter gs_locate
on EX_BACK_UP
    do selection_states()
        on RETURN_CODE = EMS_S_Success                state have_drawing_view
        on RETURN_CODE = EMS_I_Success or
           RETURN_CODE = EMS_W_Success                state get_parents
    state start
on EX_DATA or TEXT_VALUE 
        do COtools.push_event(&me->event1)
        do ECsectvw.add_verified_solids(FALSE)
               on RETURN_CODE = MSSUCC
                  do disconnect_located  1            state get_next_unsectioned_solid
               on RETURN_CODE = EMS_S_ElNotSlDrVw
                  do status_key EMS_I_ElNotSelProc
                  do COtools.wait(120)
                  do highlight_located   0
                  do disconnect_located  1            state get_unsectioned_solids
               on RETURN_CODE = EMS_I_ElAlrdySel
                  do status_key EMS_I_ElAlrdySel
                  do COtools.wait(120)
                  do disconnect_located  1            state get_unsectioned_solids
               on ELSE
                  do COtools.wait(120)
                  do COtools.erase_highlight()
                  do status_key GR_E_EleNotFnd     state get_unsectioned_solids
        state start

state get_next_unsectioned_solid
    prompt_key           EMS_P_IdNxtSlNotSectMvOn
    accept_key           EMS_P_AccIdNxtSlRj
    relocate_key         GR_E_EleNotFnd
    locate_eligible      "+EMSsolid"
    locate_owner         "LC_READ | LC_REF_HEADER | LC_REF_OBJECTS"
    locate_properties    "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
    locate_display       "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
    filter gs_locate_noauto
on EX_BACK_UP
        do ECsectvw.move_unsectioned_to_sectioned()
        do ECsectvw.highlight_solids(2)               state get_unsectioned_solids
on EX_DATA or TEXT_VALUE
        do COtools.push_event(&me->event1)
        do ECsectvw.add_verified_solids(FALSE)
               on RETURN_CODE = MSSUCC
                  do disconnect_located  1            state get_next_unsectioned_solid
               on RETURN_CODE = EMS_S_ElNotSlDrVw
                  do status_key EMS_I_ElNotSelProc
                  do COtools.wait(120)
                  do highlight_located   0
                  do disconnect_located  1            state get_next_unsectioned_solid
               on RETURN_CODE = EMS_I_ElAlrdySel
                  do status_key EMS_I_ElAlrdySel
                  do COtools.wait(120)
                  do disconnect_located  1            state get_next_unsectioned_solid
        state start
on EX_RJT_MOVEON                                      state have_parents

state have_parents
    prompt_key        GR_P_EntPlcPnt
    dynamics          15
    filter get_event
on EX_BACK_UP        do selection_states()
                         on RETURN_CODE = EMS_S_Success  state have_drawing_view
                         on ELSE                         state get_parents
                     state -
on EX_DATA           do COtools.assign ( &me->event1,
                                         &me->line_base,
                                         CO_evt_to_evt )
                     do COtools.erase_highlight()
                     do status_key EMS_I_Processing
                     do COtools.empty_channel(&me->located_chansel)
                     do construct_sv_drawview()
                     do get_auxview_normal
                     do get_auxview_matrix
                     do construct_default_cs
                     do ECsectvw.create_section_view()
                            on RETURN_CODE = OM_S_SUCCESS
                               do get_auxview_normal
                               do get_auxview_matrix
                               do status_key GR_P_GenCrosHat   state crosshatch_sections
                            on RETURN_CODE = OM_I_STOP_SENDING
                               do get_auxview_normal
                               do get_auxview_matrix
                               do status_key EX_S_Clear        state position_coordsys
                            on RETURN_CODE = EMS_E_NoIntersection
                               do status_key EMS_I_CtPlnDsNotIntSl state start
                            on ELSE
                               do status_key GR_E_ErrEncCmdRst state start
                     state start

state crosshatch_sections
   locate_class    "GRpolygon,GRcompcurve,GRorthpoly,GRcircle,GRellipse,GRbspline"
   locate_properties "LC_LC_ONLY | LC_DP_ONLY | LC_PHY_CLOSED | IGN_RW_BIT"
   locate_owner "LC_FLEX_COMP | LC_NO_REF_HEADER | LC_NO_REF_OBJECTS | LC_RIGID_COMP"
        execute crosshatch_sections()
            on RETURN_CODE = OM_S_SUCCESS
                do status_key EX_S_Clear          state position_coordsys
            on ELSE
                do status_key GR_E_ErrEncCmdRst   state start

state position_coordsys
    execute coord_sys_manual()
        on RETURN_CODE = FALSE
            do display_mode GRbd
            do send_foreign ( CO_display_cs )
            state have_cs_x_axis
        on ELSE                      state get_coordsys_origin

state get_coordsys_origin
    prompt_key        GR_P_EntCorSysOrgMvOn
    dynamics          2
    filter            get_event

on EX_RJT_MOVEON
    do display_mode GRbd
    do send_foreign ( CO_display_cs )
    state have_cs_x_axis

on EX_DATA
    do COtools.assign ( &me->event1.event.button, me->point1, CO_btn_to_pnt )
    do COtools.assign ( &me->event1, &me->line_base, CO_evt_to_evt )
    state have_cs_origin

state have_cs_origin
    prompt_key        GR_P_EntXAxCorSys
    dynamics          6
    filter            get_event

on EX_BACK_UP
    state get_coordsys_origin

on EX_DATA
    do construct_x_aligned_cs
    do display_mode GRbd
    do send_foreign ( CO_display_cs ) 
    state have_cs_x_axis

state have_cs_x_axis
    execute          place_label()
        on RETURN_CODE = "TRUE"                     state place_view_label
        on ELSE                                     state have_text_origin

state place_view_label
    prompt_key       GR_P_EntDrwVwTxtOrgMvOn
    dynamics         0
    filter           get_event

on NULL_STRING or EX_RJT_MOVEON
    state have_text_origin

on EX_DATA
    do construct_text ( CO_name )
    state have_text_origin

on EX_STRING
    do COtools.assign ( me->event1.event.keyin, me->text_name, CO_str_to_str )
    state .

state have_text_origin
    execute display_scale()
        on RETURN_CODE = "TRUE"                     state display_view_scale
        on ELSE                                     state have_scale_origin

state display_view_scale
    prompt_key        GR_P_EntDrwVwScTxtOrgMvOn
    dynamics          1
    filter            get_event

on NULL_STRING or EX_RJT_MOVEON
    state have_scale_origin

on EX_DATA
    do construct_text ( CO_scale )
    state have_scale_origin

state have_scale_origin
    execute get_view_name()
        on RETURN_CODE = "TRUE"
            do COtools.change_name (sts, &me->located_chansel, me->event1.event.keyin)
                on RETURN_CODE = "DIR_E_NAME_DUP"
                    do status_key  GR_E_DupNme
                    state get_new_name
                on SUCCESS
                    state have_dv_name

                on SEVERE or ERROR or WARNING
                    do status_key  GR_E_InvNme
                    state get_new_name
            state have_dv_name
        on RETURN_CODE = "FALSE"                 state have_dv_name

state get_new_name
    prompt_key        GR_P_EntDrwVwNme
    filter            get_event

on NULL_STRING or EX_RJT_MOVEON
    state have_dv_name

on EX_STRING
    do COtools.change_name ( sts, &me->located_chansel, me->event1.event.keyin )   
        on RETURN_CODE = "DIR_E_NAME_DUP"
            do status_key  GR_E_DupNme
            state .

        on SUCCESS
            state have_dv_name

        on SEVERE or ERROR or WARNING
            do status_key  GR_E_InvNme
            state .
    state have_dv_name

state have_dv_name
    execute get_description()
        on RETURN_CODE = "TRUE"
            do send_foreign (CO_put_drawview_desc)        
            do COtools.empty_channel (&me->located_chansel )   state start
        on ELSE
            do COtools.empty_channel (&me->located_chansel )   state start

at wakeup
    do display_status_message()

at sleep
    do COtools.erase_highlight()
