/*\
Name
    COauxview

Description
    This command creates an auxiliary drawing view from another drawing 
    view.  This command will prompt for a line and then the origin of
    auxiliary drawing view.

History
    jay wallingford     06/20/89    Creation

\*/

command_string    GRMCrtAuxDrwVw,CO_auxview,GRCrAxDrV
class             COdetail
super_class       COtools
super_class       CEO_GSLOCATE
spec_path       "$grnuc/co/spec"
product_name      "$SOURCE"
options		"siTC"
start_state       start

state_table
#include <grmessage.h>
#include <griodef.h>
#include <lcdef.h>
#include <exdef.h>
#include <var.h>
#include <grerr.h>
#include <toolco.h>
#include "detailco.h"
#include <DIdef.h>

state *
on EX_RESTART                                       state start

state start
    message_key          GRC_M_CrtAuxDrwVw
    prompt_key           GR_P_IdDrwVw
    accept_key           GR_P_AccFstPtFldLn
    relocate_key         GR_E_EleNotFnd
    locate_eligible      "GRdrawview"
    locate_owner         "LC_READ | LC_NO_REF_HEADER | LC_NO_REF_OBJECTS"
    locate_properties    "LC_LC_ONLY | LC_RW | LC_DP_ONLY"
    locate_display       "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
    filter gs_locate
on EX_BACK_UP
    state .

on EX_DATA or TEXT_VALUE
    do set_defaults ()
    do COtools.assign ( &me->event1.event.button, me->point1, CO_btn_to_pnt )
    do COtools.assign ( &me->event1, &me->line_base, CO_evt_to_evt )
    do get_drawview_info
    state get_point2

state get_point2
    prompt_key        GR_P_EntSecPtFldLn
    dynamics          3
    filter get_event

on EX_BACK_UP
    state -

on EX_DATA
    do COtools.assign ( &me->event1.event.button, me->point2, CO_btn_to_pnt )
    do COtools.assign ( &me->located_chansel, &me->dv_id1, CO_gschan_to_grid )
    do send_foreign ( CO_get_projection_angle )
    do COtools.assign ( &me->event1.event.button, &me->window_id, CO_btn_to_grid )
    do COtools.assign ( &me->event1.event.button, me->window_matrix, CO_btn_to_mtx )
    do get_auxview_normal
    state get_origin

state get_origin
    prompt_key        GR_P_EntOrgAuxDrwVw
    dynamics          4
    filter get_event

on EX_BACK_UP
    state -

on EX_DATA
    do send_foreign ( CO_get_drawview_scale )
    do get_auxview_matrix 
    do COtools.erase_highlight ()
    do xcopy_drawview
        on ERROR
            do status_key GR_E_ErrEncCmdRst
            state start
    do display_mode GRbd
    do display_located 
    do COtools.assign ( &me->located_chansel, &me->dv_id2, CO_gschan_to_grid )
    do align_drawing_views
    do construct_default_cs
    state have_origin

state have_origin
    prompt_key        GR_P_EntCorSysOrgMvOn
    dynamics          2
    filter            get_event

on EX_RJT_MOVEON
    do display_mode GRbd
    do send_foreign ( CO_display_cs )
    do COtools.assign ( GR_I_Auxiliary, me->text_name, CO_msg_to_str )
    state have_cs_x_axis

on EX_DATA
    do COtools.assign ( &me->event1.event.button, me->point1, CO_btn_to_pnt )
    do COtools.assign ( &me->event1, &me->line_base, CO_evt_to_evt )
    do COtools.assign ( GR_I_Auxiliary, me->text_name, CO_msg_to_str )
    state have_cs_origin

state have_cs_origin
    prompt_key        GR_P_EntXAxCorSys
    dynamics          6
    filter            get_event

on EX_BACK_UP
    state -

on EX_DATA
    do construct_x_aligned_cs
    do display_mode GRbd
    do send_foreign ( CO_display_cs ) 
    state have_cs_x_axis

state have_cs_x_axis
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
    prompt_key        GR_P_EntDrwVwScTxtOrgMvOn
    dynamics          1
    filter            get_event

on NULL_STRING or EX_RJT_MOVEON
    state have_scale_origin

on EX_DATA
    do construct_text ( CO_scale )
    state have_scale_origin

state have_scale_origin
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
    prompt_key        GR_P_EntDrwVwDes
    filter            get_event

on EX_BACK_UP
    state -

on NULL_STRING or EX_RJT_MOVEON
    do COtools.empty_channel (&me->located_chansel )
    state start

on EX_STRING
    do send_foreign (CO_put_drawview_desc)
    do COtools.empty_channel (&me->located_chansel )
    state start
