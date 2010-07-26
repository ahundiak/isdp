command_string GRC_M_CreatePart,CO_create_part,GRCrPr
class          COpart
product_name   "$GRNUC"
super_class    COtools
super_class    COdpb
super_class    CEO_GSLOCATE
spec_path      "$GRNUC/co/spec"
path           "."
form           "GRCrePrt",CO_create_part,0,"-1","-1"
start_state    START
options	       "siT"
 
state_table

#include <grmessage.h>
#include <lcdef.h>
#include <FI.h>
#include <toolco.h>
#include "partco.h"
#include <dpbco.h>


at init
    do COdpb.alloc  (sts, 0)
    do COdpb.active (sts, 0)

state *
    on EX_RESTART  
        do erase_form_by_label (CO_create_part, 0, sts) 
        do reset_form_by_label (CO_create_part, sts)
        state START

state START

    execute COdpb.get_dpb (sts, CO_scale | CO_angle | CO_level | CO_disp, 0)
    execute COtools.assign ( 0, &me->num_attrs,   CO_cin_to_int )
    execute COtools.assign ( 0, &me->num_objects, CO_cin_to_int )
    execute reset_form_by_label  (CO_create_part, sts)

    on ELSE 
        state PART_GRAPHICS
    
state PART_GRAPHICS

    msg_key      GRC_M_CreatePart
    prompt_key   GR_P_IdEleMvOn
    accept_key   GR_P_AccNxtMvOn
    relocate_key GR_E_EleNotFnd

    filter gs_locate

    on EX_DATA
        do COtools.erase_highlight()
        do gather_objects ( sts ) 
        do COtools.push_event ( &me->event1 ) 
        state .

    on EX_OBJID
        do COtools.erase_highlight()
        do gather_objects ( sts ) 
        state .

    on EX_RJT_MOVEON
        do COtools.compare ( sts, 0, &me->num_objects, CO_cin_to_int )
            on RETURN_CODE = CO_lt
                state PART_INFO

            on RETURN_CODE = CO_eq
                do status_key  GR_I_NoPtGraphDef
                state .

        do status_key GR_E_ErrEncCmdTrm
        state terminate

state PART_INFO    

    execute update_form_by_label (CO_create_part, sts)
    execute display_form_by_label (CO_create_part, sts)
    
    prompt_key  GR_P_SelFrForm
    
    filter wfi

    execute COtools.assign (*me->response, sts, CO_cin_to_int)

    on RETURN_CODE = CO_ACCEPT_RESPONSE
        do query_form_by_label (CO_create_part, sts)
            on RETURN_CODE = MSFAIL
                state .
            on ELSE
                do erase_form_by_label (CO_create_part, 0, sts)
                do reset_form_by_label (CO_create_part, sts) 
                state PART_CONSTRUCT
            state .

    on RETURN_CODE = CO_CANCEL_RESPONSE
        do erase_form_by_label (CO_create_part, 0, sts)
        do reset_form_by_label (CO_create_part, sts) 
        state START

state PART_CONSTRUCT
    ms_on_off MS_OFF
    execute construct (sts, CO_part, 0)
    
    on RETURN_CODE = MSSUCC   
        do ms_on_off MS_ON
        do status_key  GR_I_PtConst
        state START

    on RETURN_CODE = MSFAIL
        do ms_on_off MS_ON
        do status_key GR_E_ErrEncCmdRst 
        state START

    on ELSE
        do ms_on_off MS_ON
        do status_key GR_E_ErrEncCmdTrm 
        state terminate

at wakeup
    do gslocate_num_inputs 1
    do gslocate_spec_mask1 "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    do gslocate_spec_prompt1_key     GR_P_AccFnc
    do locate_mask         "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    do accept_mask         "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    do locate_eligible     "~+GRpart, +GRgraphics"
    do locate_display      "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                            ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT | 
                            LC_ERASE_ALL | LC_ACCEPT_CURSOR"
    do locate_owner        "LC_GEOM_MOD | LC_REF_HEADER | LC_NO_ASSOCIATIVE |
                            LC_NO_EXTERN_CONST"
    do locate_properties   "LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY"

