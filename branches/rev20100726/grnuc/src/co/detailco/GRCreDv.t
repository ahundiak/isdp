/*
Description
    The CREATE DRAWING VIEW command creates a drawing view using a
    save view from another file.

History
    jay wallingford 	06/20/89    	Creation date
    henry bequet	12/10/91	Writable reference files
    mrm			08/12/93	added status_display_button calls
*/

command_string  GRMCrtDrwVw,CO_drawview,GRCrDrV
class           COdetail
super_class     COtools
super_class     CEO_GSLOCATE
spec_path       "$grnuc/co/spec"
product_name    "$SOURCE"
status_display  "GRStatus","-1","-1"
options	        "siTC"
start_state     start

state_table
#include <OMerrordef.h>
#include <execmsg.h>
#include <grmessage.h>
#include <referr.h>
#include <grerr.h>
#include <msdef.h>
#include <toolco.h>
#include "detailco.h"
#include <DIdef.h>
#include <OMtypes.h>
#include <ODE.h>

state *
on EX_RESTART                                   state start

/* 
 * Create Drawing View Section.
 */
state start
    execute            COtools.empty_channel (&me->located_chansel )
    execute            COtools.assign (CO_drawview, &me->cmd_mode, CO_cin_to_int)
    execute            status_display_button(1)
    status_key         GR_M_StsFmAvail
    message_key        GRC_M_CrtDrwVw
    prompt_key         GR_P_CrtDwgView
    execute options_mode (FILENAME_MODE,me->directory)
    filter             get_event

on STATUS_DISP
    do options_mode (FILENAME_MODE,me->directory)
    state .

on EX_BACK_UP
    state prinview_locate_draw_view

on EX_RJT_MOVEON or NULL_STRING
    do set_defaults()
    state no_model_view

on EX_STRING
    do set_defaults()
    do COtools.access_file ( sts,
                             (CO_file_exists | CO_file_reg | CO_file_read),
                             me->event1.event.keyin,
                             0 )
        on MSSUCC
            do COtools.assign ( me->event1.event.keyin,
                                me->model,
                                CO_str_to_str )
            do echo_mode	    		
	    do query_file (sts, me->model)
            state have_model

    do COtools.access_file ( sts,
                             (CO_file_exists | CO_file_dir | CO_file_read),
                             me->event1.event.keyin,
                             0 )
        on MSSUCC
            do assign (me->event1.event.keyin, me->directory, CO_str_to_str)
            do assign (-1, &me->option, CO_cin_to_int)
            do options_mode (FILENAME_MODE, me->directory)
            state .
                    
    do status_key GR_E_FlNotFnd
    state .

state have_model
    prompt_key         GR_P_EntSavVw
    execute options_mode (VIEW_MODE,&me->ref_id)
    execute            status_display_button(1)
    filter             get_event

on STATUS_DISP
    do options_mode (VIEW_MODE,&me->ref_id)
    state .

on NULL_STRING
    state .

on EX_BACK_UP
    state -

on EX_STRING
    do COtools.assign ( me->event1.event.keyin,
                        me->view,
                        CO_str_to_str )
    do COtools.assign ( me->view,
                        me->text_name,
                        CO_str_to_str )
    state have_view

state no_model_view
    status_key        GR_P_MvOnFldView
    prompt_key        GR_P_EntDrwVwOrient
    execute options_mode (ORIENTATION_MODE,0)
    execute           status_display_button(1)
    filter            get_event

on EX_RJT_MOVEON
    state prinview_locate_draw_view

on STATUS_DISP
    do options_mode (ORIENTATION_MODE,0)
    state .

on EX_BACK_UP
    state -

on NULL_STRING
    state .

on EX_STRING
    do define_drawview_orientation
        on MSFAIL
            do status_key  GR_E_EntVldOrient
            state .
    state have_view

state have_view
    prompt_key        GR_P_EntScXX
    execute options_mode (SCALE_MODE,0)
    execute           status_display_button(1)
    filter            get_event

on STATUS_DISP
    do options_mode (SCALE_MODE,0)
    state .

on EX_BACK_UP
    state -

on NULL_STRING or EX_RJT_MOVEON
    do COtools.assign ( GR_I_11, me->text_scale, CO_msg_to_str )
    state have_model_scale

on EX_STRING
    do COtools.assign ( me->event1.event.keyin,
                        me->text_scale,
                        CO_str_to_str )
    state have_model_scale

state have_model_scale
    execute erase_form_by_label (STATUS_FORM, 1, sts)
    execute            status_display_button(0)
    prompt_key        GR_P_IdDrwVwOrg
    dynamics          2
    filter            get_event

on EX_BACK_UP
    state -

on EX_DATA
    do COtools.assign ( &me->event1.event.button,
                        &me->window_id,
                        CO_btn_to_grid )
    do COtools.assign ( &me->event1.event.button,
                        me->window_matrix,
                        CO_btn_to_mtx )
    do COtools.compare ( sts, me->model, "", CO_str_to_str )
        on RETURN_CODE = CO_eq
            state create_drawview

    do status_key GR_I_RefAtt
    state create_drawview

state create_drawview

execute construct_drawview

on RETURN_CODE = GRFILENOTFOUND
    do status_key  GR_E_FlNotFnd
    state start

on RETURN_CODE = GRVIEWNOTFOUND
    do status_key  GR_E_SvVwNotFnd
    state have_model

on RETURN_CODE = GRSDGNEXCEED
    do status_key  GR_E_InvScFac
    state have_view

on RETURN_CODE = GR_E_INV_REQUEST
    do status_key  GR_E_FlCantOpn
    state start

on RETURN_CODE = OM_E_NO_OS_AVAIL
    do status_key GR_E_MaxRfFl
    state start

on RETURN_CODE = MSFAIL
    do status_key  GR_E_ErrEncCmdRst
    state start

on RETURN_CODE = OM_I_DUPLICATE_OS
    do status ""
    do display_mode GRbd
    do display_located 
    do construct_default_cs
    do error_box_key EX_F_DupIntOSName
    state have_model_origin

on RETURN_CODE = MSSUCC
    do status ""
    do display_mode GRbd
    do display_located 
    do construct_default_cs
    state have_model_origin

state have_model_origin
    prompt_key        GR_P_EntCorSysOrgMvOn
    dynamics          2
    filter            get_event
on EX_RJT_MOVEON
    do get_name_from_matrix
    do display_mode GRbd
    do send_foreign (CO_display_cs)  
    state have_cs_origin

on EX_DATA
    do get_name_from_matrix
    do transform_cs
    do display_mode GRbd
    do send_foreign (CO_display_cs)
    state have_cs_origin

state have_cs_origin
    prompt_key        GR_P_EntDrwVwTxtOrgMvOn
    dynamics          0
    filter            get_event

on NULL_STRING or EX_RJT_MOVEON
    state have_text_origin

on EX_DATA
    do construct_text(CO_name) 
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
    do construct_text(CO_scale)   
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
    do COtools.assign ( &me->located_chansel,
                        &me->dv_id1,
                        CO_gschan_to_grid )
    do send_foreign ( CO_get_projection_angle )
    do get_drawview_info
    state have_draw_view

on EX_STRING
    do send_foreign (CO_put_drawview_desc)       
    do COtools.assign ( &me->located_chansel,
                        &me->dv_id1,
                        CO_gschan_to_grid )
    do send_foreign ( CO_get_projection_angle )
    do get_drawview_info
    state have_draw_view

/* 
 * Create Principle View Section.
 */
state prinview_locate_draw_view
    execute              COtools.empty_channel (&me->located_chansel )
    execute              COtools.assign (CO_prinview, &me->cmd_mode, CO_cin_to_int)
    status_key           GR_P_MvAuxBkCrView
    message_key          GRC_M_CrtPrnDrwVw
    prompt_key           GR_P_IdDrwVw
    accept_key           GR_P_AccDrwVw
    relocate_key         GR_E_EleNotFnd
    locate_eligible      "GRdrawview"
    locate_owner         "LC_READ | LC_NO_REF_HEADER | LC_NO_REF_OBJECTS"
    locate_properties    "LC_LC_ONLY | LC_RW | LC_DP_ONLY"
    locate_display       "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
    filter gs_locate

on EX_BACK_UP
    state start

on EX_RJT_MOVEON
    state auxview_locate_draw_view

on EX_DATA or TEXT_VALUE
    do set_defaults ()
    do COtools.assign ( &me->event1.event.button,
                        &me->window_id,
                        CO_btn_to_grid )
    do COtools.assign ( &me->event1.event.button,
                        me->window_matrix,
                        CO_btn_to_mtx )
    do COtools.assign ( &me->located_chansel,
                        &me->dv_id1,
                        CO_gschan_to_grid )
    do send_foreign ( CO_get_projection_angle )
    do get_drawview_info
    state have_draw_view

state have_draw_view
    execute           COtools.assign (CO_prinview, &me->cmd_mode, CO_cin_to_int)
    status_key        GR_P_MvAuxBkRlView
    message_key       GRC_M_CrtPrnDrwVw
    prompt_key        GR_P_EntOrgPrnDrwVw
    dynamics          5
    filter get_event

on EX_BACK_UP
    state prinview_locate_draw_view

on EX_RJT_MOVEON
    state auxview_locate_draw_view

on EX_DATA
    do send_foreign(CO_get_drawview_scale)
    do get_principal_drawview_matrix
        on RETURN_CODE = "MSFAIL"
            do status_key  GR_E_DrwVwNotOrthoAlgn
            state prinview_locate_draw_view
    do COtools.erase_highlight ()
    do xcopy_drawview
        on ERROR
            do status_key GR_E_ErrEncCmdRst
            state start
    do display_mode GRbd
    do display_located 
    do COtools.assign (&me->located_chansel, &me->dv_id2, CO_gschan_to_grid)
    do align_drawing_views
    do construct_default_cs
    state have_prinview_origin

state have_prinview_origin
   prompt_key        GR_P_EntCorSysOrgMvOn
   dynamics          2
   filter            get_event

on EX_RJT_MOVEON
    do get_name_from_matrix
    do display_mode GRbd
    do send_foreign(CO_display_cs)
    state have_prinview_cs_origin

on EX_DATA
    do get_name_from_matrix
    do transform_cs
    do display_mode GRbd
    do send_foreign(CO_display_cs)
    state have_prinview_cs_origin

state have_prinview_cs_origin
    prompt_key        GR_P_EntDrwVwTxtOrgMvOn
    dynamics          0
    filter            get_event

on NULL_STRING or EX_RJT_MOVEON
    state have_prinview_text_origin

on EX_DATA
    do construct_text(CO_name)
    state have_prinview_text_origin

on EX_STRING
    do COtools.assign ( me->event1.event.keyin, me->text_name, CO_str_to_str )
    state .

state have_prinview_text_origin
    prompt_key        GR_P_EntDrwVwScTxtOrgMvOn
    dynamics          1
    filter            get_event

on NULL_STRING or EX_RJT_MOVEON
    state have_scale_origin

on EX_DATA
    do construct_text(CO_scale)
    state have_prinview_scale_origin

state have_prinview_scale_origin
    prompt_key        GR_P_EntDrwVwNme
    filter            get_event

on NULL_STRING or EX_RJT_MOVEON
    state have_prinview_dv_name

on EX_STRING
    do COtools.change_name(sts,&me->located_chansel,me->event1.event.keyin )
        on RETURN_CODE = "DIR_E_NAME_DUP"
            do status_key  GR_E_DupNme
            state .
        on SUCCESS
            state have_prinview_dv_name
        on SEVERE or ERROR or WARNING
            do status_key  GR_E_InvNme
            state .
    state have_prinview_dv_name

state have_prinview_dv_name
    prompt_key        GR_P_EntDrwVwDes
    filter            get_event

on EX_BACK_UP
    state -

on NULL_STRING or EX_RJT_MOVEON
    do COtools.assign ( &me->located_chansel,
                        &me->dv_id1,
                        CO_gschan_to_grid )
    do send_foreign ( CO_get_projection_angle )
    do get_drawview_info
    state have_draw_view

on EX_STRING
    do send_foreign(CO_put_drawview_desc)
    do COtools.assign ( &me->located_chansel,
                        &me->dv_id1,
                        CO_gschan_to_grid )
    do send_foreign ( CO_get_projection_angle )
    do get_drawview_info
    state have_draw_view

/* 
 * Create Auxilliary View Section.
 */
state auxview_locate_draw_view
    execute              COtools.empty_channel (&me->located_chansel )
    execute              COtools.assign (CO_auxview, &me->cmd_mode, CO_cin_to_int)
    status_key           GR_P_MvPplBkCrView
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
    state start

on EX_RJT_MOVEON
    state prinview_locate_draw_view

on EX_DATA or TEXT_VALUE
    do set_defaults ()
    do COtools.assign ( &me->event1.event.button, me->point1, CO_btn_to_pnt )
    do COtools.assign ( &me->event1, &me->line_base, CO_evt_to_evt )
    do get_drawview_info
    state auxview_get_point2

state auxview_get_point1
    execute           COtools.assign (CO_auxview, &me->cmd_mode, CO_cin_to_int)
    status_key        GR_P_MvPplBkRlView
    prompt_key        GR_P_1stPtFldLn
    filter get_event

on EX_BACK_UP
    state auxview_locate_draw_view

on EX_RJT_MOVEON
    do COtools.assign ( &me->located_chansel,
                        &me->dv_id1,
                        CO_gschan_to_grid )
    do send_foreign ( CO_get_projection_angle )
    do get_drawview_info
    state have_draw_view

on EX_DATA or TEXT_VALUE
    do set_defaults ()
    do COtools.assign ( &me->event1.event.button, me->point1, CO_btn_to_pnt )
    do COtools.assign ( &me->event1, &me->line_base, CO_evt_to_evt )
    do get_drawview_info
    state auxview_get_point2

state auxview_get_point2
    status_key        GR_P_MvPplBk1stPt
    prompt_key        GR_P_EntSecPtFldLn
    dynamics          3
    filter get_event

on EX_BACK_UP
    state -

on EX_RJT_MOVEON
    state prinview_locate_draw_view

on EX_DATA
    do COtools.assign ( &me->event1.event.button, me->point2, CO_btn_to_pnt )
    do COtools.assign ( &me->located_chansel, &me->dv_id1, CO_gschan_to_grid )
    do send_foreign ( CO_get_projection_angle )
    do COtools.assign ( &me->event1.event.button, &me->window_id, CO_btn_to_grid )
    do COtools.assign ( &me->event1.event.button, me->window_matrix, CO_btn_to_mtx )
    do get_auxview_normal
    state auxview_get_origin

state auxview_get_origin
    status_key        GR_P_BkRedefFldLn
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
            state auxview_locate_draw_view
    do display_mode GRbd
    do display_located 
    do COtools.assign ( &me->located_chansel, &me->dv_id2, CO_gschan_to_grid )
    do align_drawing_views
    do construct_default_cs
    state auxview_have_origin

state auxview_have_origin
    prompt_key        GR_P_EntCorSysOrgMvOn
    dynamics          2
    filter            get_event

on EX_RJT_MOVEON
    do display_mode GRbd
    do send_foreign ( CO_display_cs )
    do COtools.assign ( GR_I_Auxiliary, me->text_name, CO_msg_to_str )
    state auxview_have_cs_x_axis

on EX_DATA
    do COtools.assign ( &me->event1.event.button, me->point1, CO_btn_to_pnt )
    do COtools.assign ( &me->event1, &me->line_base, CO_evt_to_evt )
    do COtools.assign ( GR_I_Auxiliary, me->text_name, CO_msg_to_str )
    state auxview_have_cs_origin

state auxview_have_cs_origin
    prompt_key        GR_P_EntXAxCorSys
    dynamics          6
    filter            get_event

on EX_BACK_UP
    state -

on EX_DATA
    do construct_x_aligned_cs
    do display_mode GRbd
    do send_foreign ( CO_display_cs ) 
    state auxview_have_cs_x_axis

state auxview_have_cs_x_axis
    prompt_key       GR_P_EntDrwVwTxtOrgMvOn
    dynamics         0
    filter           get_event

on NULL_STRING or EX_RJT_MOVEON
    state auxview_have_text_origin

on EX_DATA
    do construct_text ( CO_name )
    state auxview_have_text_origin

on EX_STRING
    do COtools.assign ( me->event1.event.keyin, me->text_name, CO_str_to_str )
    state .

state auxview_have_text_origin
    prompt_key        GR_P_EntDrwVwScTxtOrgMvOn
    dynamics          1
    filter            get_event

on NULL_STRING or EX_RJT_MOVEON
    state auxview_have_scale_origin

on EX_DATA
    do construct_text ( CO_scale )
    state auxview_have_scale_origin

state auxview_have_scale_origin
    prompt_key        GR_P_EntDrwVwNme
    filter            get_event

on NULL_STRING or EX_RJT_MOVEON
    state auxview_have_dv_name

on EX_STRING
    do COtools.change_name ( sts, &me->located_chansel, me->event1.event.keyin )   
        on RETURN_CODE = "DIR_E_NAME_DUP"
            do status_key  GR_E_DupNme
            state .

        on SUCCESS
            state auxview_have_dv_name

        on SEVERE or ERROR or WARNING
            do status_key  GR_E_InvNme
            state .
    state auxview_have_dv_name

state auxview_have_dv_name
    prompt_key        GR_P_EntDrwVwDes
    filter            get_event

on EX_BACK_UP
    state -

on NULL_STRING or EX_RJT_MOVEON
    state auxview_locate_draw_view

on EX_STRING
    do send_foreign (CO_put_drawview_desc)
    state auxview_locate_draw_view

at init
    do COtools.assign (-1, &me->ref_id.objid, CO_cin_to_int)
    do COtools.assign (0, &me->ref_id.osnum, CO_cin_to_int)
    do COtools.assign (".", me->directory, CO_str_to_str)
    do COtools.assign (-1, &me->option, CO_cin_to_int)
/*
at wakeup
    do status_key GR_I_StFmAvail
*/

at sleep
    do query_file (sts, 0)

/*  doing this during sleep to fix TR 92N0269
at delete
    do query_file (sts, 0)
*/
