command_string GRPrjEl,0,GRPrEl
class          COproj
product_name   "$SOURCE"
super_class    COtools
super_class    COdpb
super_class    CEO_GSLOCATE
spec_path      "$grnuc/co/spec"
path           "."
start_state    START
options	       "siTC"
 
state_table

#include <grmessage.h>
#include <msdef.h>
#include <lcdef.h>
#include <toolco.h>

state *
    on EX_RESTART  
        state START

state START

    on ELSE 
        state FROM_VIEW
    
state FROM_VIEW

    message_key  GRC_M_PrjEl
    prompt_key   GR_P_IdDrwVwPrjFrm
    accept_key   GR_P_AccIdDrwVwPrj
    relocate_key GR_E_EleNotFnd

    locate_eligible "+GRdrawview"

    filter gs_locate

    on EX_DATA
        do COtools.erase_highlight()
        do store_view_info (sts, 0, &me->event3)
        do COtools.push_event ( &me->event1 ) 
        state TO_VIEW

state TO_VIEW

    prompt_key   GR_P_IdDrwVwPrjTo
    accept_key   GR_P_AccElPrj
    relocate_key GR_E_EleNotFnd

    locate_eligible "+GRdrawview"

    filter gs_locate

    on EX_DATA
        do COtools.erase_highlight()
        do store_view_info (sts, 1, &me->event3)
        do COtools.push_event ( &me->event1 )
        state PROJECT_ELEMENTS

    on EX_BACK_UP
        state FROM_VIEW

state PROJECT_ELEMENTS

    prompt_key   GR_P_IdElPrj
    accept_key   GR_P_AccNxtMvOn
    relocate_key GR_E_EleNotFnd

    locate_eligible "+GRcurve"

    filter gs_locate

    on EX_DATA or EX_OBJID
        do COtools.erase_highlight()
        do gather_leaf_objects (sts)
        do COtools.compare (sts, 0, &me->project_state, CO_cin_to_int)
            on RETURN_CODE = CO_eq
                do extract_points (sts)
                    on RETURN_CODE = MSINARG
                        do status_key GR_P_CntPrjElType
                        state .
                do project_points (sts)
                do COtools.push_event ( &me->event1 )
                state .
            on ELSE 
                do transform_elements (sts)
                    on RETURN_CODE = MSINARG
                        do status_key GR_P_CntPrjElType
                        state .
                do COtools.push_event ( &me->event1 )
                state .
            state .

    on EX_BACK_UP
        state TO_VIEW

at init
    do COtools.assign (0, &me->objects, CO_cin_to_int)

at wakeup
    do gslocate_num_inputs 1
    do gslocate_spec_mask1 "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    do gslocate_spec_prompt1_key     GR_P_AccFnc
    do locate_mask         "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    do accept_mask         "GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE"
    do locate_owner        "LC_RIGID_OWNER | LC_FLEX_COMP | LC_NO_FLEX_OWNER | 
                            LC_NO_REF_HEADER | LC_REF_OBJECTS"
    do locate_display      "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | 
                            ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT | 
                            LC_ERASE_ALL | LC_ACCEPT_CURSOR"
    do locate_properties   "LC_LC_ONLY | LC_RW | LC_DP_ONLY"

at delete 
    do free_buffer (me->objects)
