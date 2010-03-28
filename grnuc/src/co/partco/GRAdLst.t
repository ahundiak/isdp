command_string GRC_M_AddPtToPtLst,CO_add_to_parts_list,GRAdPrTPrL
class          COpart
product_name   "$SOURCE"
super_class    COtools
super_class    COdpb
super_class    CEO_GSLOCATE
spec_path      "$GRNUC/co/spec"
path           "."
start_state    START
options	       "siT"
 
state_table

#include <grmessage.h>
#include <lcdef.h>
#include <toolco.h>
#include "partdef.h"
#include "partco.h"

state *
    on EX_RESTART 
        state START

state START

    execute true (sts, CO_IS_PARTS_LIST)

    on RETURN_CODE = TRUE
        do true (sts, CO_ARE_PARTS)
            on RETURN_CODE = TRUE
                do COtools.assign (0, &me->num_attrs,  CO_cin_to_int)
                do COtools.assign (0, &me->num_objects, CO_cin_to_int)
                state SELECT_PART
                
            on RETURN_CODE = FALSE
                do status_key GR_I_NoPtDef
                do COtools.wait(20) 
                state terminate
                
        do status_key GR_E_ErrEncCmdTrm 
        state terminate

    on RETURN_CODE = FALSE
        do status_key GR_I_NoPtLstDef
        do COtools.wait(20) 
        state terminate

    on ELSE 
        do status_key GR_E_ErrEncCmdTrm 
        state terminate
    
state SELECT_PART

    msg_key      GRC_M_AddPtToPtLst
    prompt_key   GR_P_IdParts
    relocate_key GR_E_EleNotFnd
    
    filter gs_locate

    on EX_DATA
        do gather_objects(sts)
        do COtools.erase_highlight()
        do list_parts (sts, CO_add_to_parts_list)
            on RETURN_CODE = MSSUCC
                do COtools.assign (0, &me->num_objects, CO_cin_to_int)
                do COtools.push_event (&me->event1)
                state .
                
            on RETURN_CODE = CO_E_PARTSLIST_ERROR
                do status_key  GR_I_PtLstErr
                state terminate
                
            on RETURN_CODE = CO_E_PART_ON_LIST
                do status_key  GR_I_PtAlreadyOnLst
                state terminate
            
	    on RETURN_CODE = CO_E_PART_IS_LIST
		do status_key GR_I_NoAddPtToLst
		state terminate    

            on RETURN_CODE = MSFAIL
                do status_key GR_E_ErrEncCmdTrm
                state terminate

        do status_key GR_E_ErrEncCmdTrm
        state terminate

    on EX_OBJID
        do gather_objects(sts)
        do COtools.erase_highlight()
        do list_parts (sts, CO_add_to_parts_list)
            on RETURN_CODE = MSSUCC
                do COtools.assign (0, &me->num_objects, CO_cin_to_int)
                state .
                
            on RETURN_CODE = CO_E_PARTSLIST_ERROR
                do status_key  GR_I_PtLstErr
                state terminate
                
            on RETURN_CODE = CO_E_PART_ON_LIST
                do status_key  GR_I_PtAlreadyOnLst
                state terminate

	    on RETURN_CODE = CO_E_PART_IS_LIST
		do status_key  GR_I_NoAddPtToLst
		state terminate    
                
            on RETURN_CODE = MSFAIL
                do status_key GR_E_ErrEncCmdTrm
                state terminate

        do status_key GR_E_ErrEncCmdTrm
        state terminate

    on EX_RJT_MOVEON
        do get_all_parts (sts)
        do list_parts (sts, CO_add_to_parts_list)
            on RETURN_CODE = MSSUCC
                do status_key  GR_I_AllPtAddToLst
                state terminate
                
            on RETURN_CODE = CO_E_PARTSLIST_ERROR
                do status_key  GR_I_PtLstErr
                state terminate
                
            on RETURN_CODE = MSFAIL
                do status_key GR_E_ErrEncCmdTrm
                state terminate

	    on RETURN_CODE = CO_E_PART_IS_LIST
		do status_key  GR_I_NoAddPtToLst
		state terminate    

            on RETURN_CODE = CO_E_PART_ON_LIST
                do status_key  GR_I_PtAlreadyOnLst
                state terminate
                
        do status_key GR_E_ErrEncCmdTrm
        state terminate

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
                            LC_REF_HEADER | LC_NO_REF_OBJECTS"
    do locate_properties   "LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY"

