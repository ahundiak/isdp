/*\
Description
    The CHANGE DRAWING VIEW SCALE command is used to change the scale 
    of a drawing view.  The drawing view is scaled by an absolute value
    instead of by a factor.

History
    Gray Winn       04/23/87    Creation date.
    Gray Winn       05/31/88    Change for drawing view.
    jay wallingford 06/20/89    rewritten
\*/

command_string  GRMChgDrwVwSc,CO_scaledv,GRCDrVSc
class           COdetail
super_class     COtools
super_class     CEO_GSLOCATE
spec_path       "$grnuc/co/spec"
start_state     start
options		"siTC"
product_name    "$SOURCE"

state_table
#include <grmessage.h>
#include <lcdef.h>
#include <msdef.h>
#include <toolco.h>
#include "detailco.h"

state *

on EX_RESTART
    do COtools.erase_highlight ()
    do COtools.empty_channel (&me->located_chansel)
    state start

state start
    message_key  GRC_M_ChgDrwVwSc
    prompt_key   GR_P_EntNwScXX
    filter       get_event

on EX_BACK_UP
    state .

on EX_STRING
    do COtools.assign ( me->event1.event.keyin, me->text_scale, CO_str_to_str )
    state have_scale_factor

state have_scale_factor
    prompt_key        GR_P_IdDrwVw
    accept_key        GR_P_AccDrwVw
    relocate_key      GR_E_EleNotFnd
    locate_eligible   "+GRdrawview"
    locate_owner      "LC_GEOM_MOD | LC_NO_REF_HEADER | LC_NO_REF_OBJECTS"
    locate_properties "LC_LC_ONLY | LC_RW | LC_DP_ONLY"
    locate_display    "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
    filter            gs_locate

on EX_BACK_UP
    state start

on EX_DATA or TEXT_VALUE
    do COtools.assign ( &me->event1.event.button,
                        &me->window_id,
                        CO_btn_to_grid )
    do COtools.assign ( &me->event1.event.button,
                        me->window_matrix,
                        CO_btn_to_mtx )
    state have_drawing_view

state have_drawing_view
    prompt_key   GR_P_EntScPt
    filter       get_event

on EX_BACK_UP
    state -

on EX_DATA
    do COtools.erase_highlight ()
    do send_foreign(CO_get_drawview_label)
    do display_mode GRbe
    do display_located 
    do scale_drawview (sts, 1)
        on RETURN_CODE = "MSFAIL"
            do status_key  GR_E_InvScFac
            do display_mode GRbd
            do display_located
            do COtools.empty_channel(&me->located_chansel)
            state start
    do display_mode GRbd
    do display_located 
    state have_scale_point

on EX_RJT_MOVEON
    do COtools.erase_highlight()
    do display_mode GRbe
    do send_foreign (CO_display_drawing_views)
    do scale_drawview (sts, 0)
        on RETURN_CODE = "MSFAIL"
            do status_key  GR_E_InvScFac
            do display_mode GRbd
            do send_foreign(CO_display_drawing_views)
            do COtools.empty_channel(&me->located_chansel)
            state start
    do display_mode GRbd
    do send_foreign(CO_display_drawing_views)
    do COtools.empty_channel(&me->located_chansel)
    state have_scale_factor

state have_scale_point
    prompt_key        GR_P_EntCorSysOrgMvOn
    dynamics          2
    filter            get_event

on EX_RJT_MOVEON
    state have_cs_origin

on EX_DATA           
    do send_foreign(CO_get_cs_id)
    do display_mode GRbe
    do send_foreign(CO_display_cs)
    do transform_cs
    do display_mode GRbd
    do send_foreign(CO_display_cs)
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
    state have_scale_factor

on EX_DATA
    do send_foreign (CO_get_drawview_scale)
    do construct_text(CO_scale)
    state have_scale_factor
