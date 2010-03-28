/*
Description
    The ATTACH MODEL command is used to associate a view of a model 
    with a previously created drawing view.

History
    jay wallingford 06/20/89    Creation date
    Jack            05/22/92    do query_file at sleep rather than delete.
    mrm		    08/12/93	added status_display_button calls
*/
command_string  GRMAtcMdlDrwVw,CO_attachmd,GRAtMdTDrV
class           COdetail
super_class	COtools
super_class     CEO_GSLOCATE
spec_path       "$grnuc/co/spec"
start_state     start
options		"siTC"
status_display  "GRStatus","-1","-1"
product_name    "$SOURCE"

state_table
#include <OMerrordef.h>
#include <execmsg.h>
#include <grmessage.h>
#include <referr.h>
#include <lcdef.h>
#include <grerr.h>
#include <msdef.h>
#include <toolco.h>
#include "detailco.h"
#include <OMtypes.h>
#include <ODE.h>

state *
on EX_RESTART   do COtools.erase_highlight ()
                do COtools.empty_channel(&me->located_chansel) 
                                                state start

state start
    message_key  GRC_M_AtcMdlDrwVw
    prompt_key   GR_P_EntMdlFl
    execute options_mode (FILENAME_MODE,me->directory)
    execute      status_display_button(1)
    filter       get_event

on STATUS_DISP
    do options_mode (FILENAME_MODE,me->directory)
    state .

on EX_BACK_UP or NULL_STRING
    state .

on EX_STRING
    do COtools.access_file ( sts,
                             (CO_file_exists | CO_file_reg | CO_file_read),
                             me->event1.event.keyin,
                             0 )
        on MSSUCC
            do COtools.assign ( me->event1.event.keyin,
                                me->model,
                                CO_str_to_str ) 
            do echo_mode
            do query_file ( sts, me->model )
               on MSFAIL
                  do status_key  GR_E_IllegalAtt
                  state .
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
                    
    do status_key  GR_E_FlNotFnd
    state .

state have_model
    prompt_key   GR_P_EntSavVw
    execute options_mode (VIEW_MODE,&me->ref_id)
    execute      status_display_button(1)
    filter       get_event

on STATUS_DISP
    do options_mode (VIEW_MODE,&me->ref_id)
    state .

on NULL_STRING 
    state .

on EX_BACK_UP
    state -

on EX_STRING
    do COtools.assign ( me->event1.event.keyin, me->view, CO_str_to_str )
    do COtools.compare ( sts, me->view, "", CO_str_to_str )
        on RETURN_CODE = CO_eq    
            do COtools.assign ( me->view,
                                me->text_name,
                                CO_str_to_str )
            state have_view        
    state have_view

state have_view
    execute erase_form_by_label (STATUS_FORM, 1, sts)
    execute           status_display_button(0)
    prompt_key        GR_P_IdDrwVw
    accept_key        GR_P_AccDrwVw
    relocate_key      GR_E_EleNotFnd
    locate_eligible   "GRdrawview"
    locate_owner      "LC_GEOM_MOD | LC_NO_REF_HEADER | LC_NO_REF_OBJECTS"
    locate_properties "LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY"
    locate_display    "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT"
    filter            gs_locate

on EX_BACK_UP
    state -

on EX_DATA or TEXT_VALUE
    do COtools.erase_highlight ()
    do COtools.assign ( &me->event1.event.button,
                        &me->window_id,
                        CO_btn_to_grid )
    do COtools.assign ( &me->event1.event.button,
                        me->window_matrix,
                        CO_btn_to_mtx )
    do status_key GR_I_RefAtt
    do attach_model
        on RETURN_CODE = GRFILENOTFOUND
            do status_key  GR_E_FlNotFnd                
            state start
        on RETURN_CODE = GRVIEWNOTFOUND
            do COtools.empty_channel(&me->located_chansel)
            do status_key  GR_E_SvVwNotFnd
            state have_model
        on RETURN_CODE = GRSDGNEXCEED
            do COtools.empty_channel(&me->located_chansel)
            do status_key  GR_E_InvScFac
            state start
        on RETURN_CODE = GR_E_INV_REQUEST
            do COtools.empty_channel(&me->located_chansel)
            do status_key  GR_E_FlCantOpn
            state start
        on RETURN_CODE = OM_E_NO_OS_AVAIL
            do status_key GR_E_MaxRfFl  
            state start
        on RETURN_CODE = MSFAIL
            do COtools.empty_channel(&me->located_chansel)
            do status_key  GR_E_ErrEncCmdRst
            state start
        on RETURN_CODE = OM_I_DUPLICATE_OS
           do status ""
           do display_mode GRbd
           do send_foreign ( CO_display_drawing_attachments )
           do COtools.empty_channel(&me->located_chansel)
           do error_box_key EX_F_DupIntOSName
           state have_view
        on RETURN_CODE = MSSUCC
           do status ""
           do display_mode GRbd
           do send_foreign ( CO_display_drawing_attachments )
           do COtools.empty_channel(&me->located_chansel)
           state have_view
    state .

at init
    do COtools.assign (-1, &me->ref_id.objid, CO_cin_to_int)
    do COtools.assign (0, &me->ref_id.osnum, CO_cin_to_int)
    do COtools.assign (".", me->directory, CO_str_to_str)
    do COtools.assign (-1, &me->option, CO_cin_to_int)

at wakeup
    do status_key GR_I_StFmAvail

at sleep
    do query_file (sts, 0)

/*  doing this during sleep to fix TR 92N4786
at delete
    do query_file (sts, 0)
*/

