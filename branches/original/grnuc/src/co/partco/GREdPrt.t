command_string GRC_M_EdPart,CO_edit_part,GREdPr
class          COpart
product_name   "$GRNUC"
super_class    COtools
super_class    COdpb
super_class    CEO_GSLOCATE
spec_path      "$GRNUC/co/spec"
path           "."
form           "GREditPrt",CO_edit_part,0,"-1","-1"
start_state    START
options	       "siT"
 
state_table

#include <grmessage.h>
#include <lcdef.h>
#include <FI.h>
#include <toolco.h>
#include "partco.h"

state *
    on EX_RESTART 
        state START

state START

    execute true (sts, CO_ARE_PARTS)

    on RETURN_CODE = TRUE
        do COtools.assign ( 0, &me->num_attrs,   CO_cin_to_int )
        do COtools.assign ( 0, &me->num_objects, CO_cin_to_int )
        do erase_form_by_label (CO_edit_part, 1, sts)
        state EDIT_PART

    on RETURN_CODE = FALSE
        do status_key  GR_I_NoPtDef
        do COtools.wait(20) 
        state terminate

    on ELSE 
        do status_key GR_E_ErrEncCmdTrm 
        state terminate
    
state EDIT_PART

    msg_key      GRC_M_EdPart
    prompt_key   GR_P_IdPart
    relocate_key GR_E_EleNotFnd
    
    filter gs_locate

    execute COtools.assign (*me->response, sts, CO_cin_to_int)

    on EX_DATA
        do COtools.assign ( &me->located_chansel, &me->part, CO_gschan_to_grid )
        do update_form_attributes_by_label ( CO_edit_part, sts, CO_NUMBER, CO_NAME, CO_STATIC, CO_DYNAMIC ) 
        do display_form_by_label (CO_edit_part, sts)
        state .
    
    on RETURN_CODE = CO_ACCEPT_RESPONSE
        do query_form_by_label (CO_edit_part, sts)
            on SUCCESS
                do status_key  GR_I_UpdPart
                do ms_on_off MS_OFF
                do modify_part         (CO_edit_part, sts)
                do ms_on_off MS_ON
                do status_key  GR_I_PartUpd
                do erase_form_by_label (CO_edit_part, 0, sts) 
                do reset_form_by_label (CO_edit_part, sts)
                state .
        do update_form_attributes_by_label ( CO_edit_part, 
                                             sts, 
                                             CO_NUMBER, 
                                             CO_NAME, 
                                             0, 
                                             0 ) 
        state .

    on RETURN_CODE = CO_CANCEL_RESPONSE
        do erase_form_by_label (CO_edit_part, 0, sts) 
        do reset_form_by_label (CO_edit_part, sts)
        state .

    on RETURN_CODE = CO_MODIFY_RESPONSE
        do query_form_by_label (CO_edit_part, sts)
            on SUCCESS
                do status_key  GR_I_UpdPart
                do ms_on_off MS_OFF
                do modify_part         (CO_edit_part, sts)
                do ms_on_off MS_ON
                do status_key  GR_I_PartUpd
                state .
        do update_form_attributes_by_label ( CO_edit_part, 
                                             sts, 
                                             CO_NUMBER, 
                                             CO_NAME, 
                                             0, 
                                             0 ) 
        state .

at wakeup
    do gslocate_num_inputs 1
    do gslocate_spec_mask1 "GRm_DATA | GRm_TEXT_VALUE"
    do gslocate_spec_prompt1_key     GR_P_AccFnc
    do locate_mask         "GRm_DATA | GRm_TEXT_VALUE"
    do accept_mask         "GRm_DATA | GRm_TEXT_VALUE"
    do locate_eligible     "+GRpart"
    do locate_display      "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | 
                            ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT | 
                            LC_ERASE_ALL | LC_ACCEPT_CURSOR"
    do locate_owner        "LC_NO_RIGID_OWNER | LC_FLEX_COMP | LC_FLEX_OWNER | 
                            LC_REF_HEADER | LC_NO_REF_OBJECTS |
                            LC_NO_ASSOCIATIVE | LC_NO_EXTERN_CONST"
    do locate_properties   "LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY"
    do unhighlight_mode GRhe

