command_string GRC_M_SavePtData,CO_list_parts,GRSvPrDt
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
#include <FI.h>
#include <toolco.h>
#include "partco.h"

state *
    on EX_RESTART 
        state START

state START

    execute true (sts, CO_ARE_PARTS)

    on RETURN_CODE = TRUE
        do COtools.assign (0, &me->num_attrs,  CO_cin_to_int)
        do COtools.assign (0, &me->num_objects, CO_cin_to_int)
        state GET_FILE

    on RETURN_CODE = FALSE
        do status_key  GR_I_NoPtDef
        do COtools.wait(20) 
        state terminate

    on ELSE 
        do status_key GR_E_ErrEncCmdTrm 
        state terminate
    
state GET_FILE

     msg_key    GRC_M_SavePtData
     prompt_key GR_P_EntFilename
     
     filter    get_event

     on EX_STRING   
        do COtools.access_file (sts, 
                                (CO_file_exists | CO_file_reg | CO_file_write ),
                                me->event1.event.keyin,
                                0 )
            on RETURN_CODE = MSFAIL
                do COtools.open_file (sts, me->event1.event.keyin, "w")
                    on RETURN_CODE = MSSUCC   
                        state SELECT_PART

                    on RETURN_CODE = MSFAIL   
                        do status_key GR_E_FlCantOpn
                        state .
                    state terminate

            on RETURN_CODE = MSSUCC
                do COtools.store_event (&me->event1, 0)
                state OVERWRITE_FILE

            state terminate
    on EX_RJT_MOVEON
        do COtools.open_file (sts, 0, "w")
            on RETURN_CODE = MSSUCC
                state SELECT_PART

            on RETURN_CODE = MSFAIL
                do status_key GR_E_FlCantOpn
                state .
        state terminate
        
state OVERWRITE_FILE
     prompt_key GR_P_FlExOv

     filter    get_event

     on EX_STRING="y" or EX_STRING="Y" or EX_STRING="yes" or EX_STRING="YES"
         do COtools.fetch_event (0, &me->event1)
         do COtools.open_file (sts, me->event1.event.keyin, "w" )
            on RETURN_CODE = MSSUCC 
                state SELECT_PART

            on RETURN_CODE = MSFAIL
                do status_key GR_E_FlCantOpn
                state -
            state terminate

     on EX_STRING="n" or EX_STRING="N" or EX_STRING="no" or EX_STRING="NO"
        state APPEND_FILE

     on EX_BACK_UP
        state -

state APPEND_FILE
     prompt_key     GR_P_FlExApp
     
     filter    get_event

     on EX_STRING="y" or EX_STRING="Y" or EX_STRING="yes" or EX_STRING="YES"
         do COtools.fetch_event (0, &me->event1)
         do COtools.open_file (sts, me->event1.event.keyin, "a")
            on RETURN_CODE = MSSUCC
                state SELECT_PART

            on RETURN_CODE = MSFAIL
                do status_key GR_E_FlCantOpn
                state -
            state terminate

     on EX_STRING="n" or EX_STRING="N" or EX_STRING="no" or EX_STRING="NO"
         state GET_FILE

     on EX_BACK_UP
        state -

state SELECT_PART

    prompt_key   GR_P_IdParts
    relocate_key GR_E_EleNotFnd
    
    filter gs_locate

    on EX_DATA 
        do gather_objects(sts)
        do list_parts (sts, CO_list_parts)
        do COtools.assign (0, &me->num_objects, CO_cin_to_int)
        do COtools.push_event (&me->event1)
        state .

    on EX_OBJID
        do gather_objects(sts)
        do list_parts (sts, CO_list_parts)
        do COtools.assign (0, &me->num_objects, CO_cin_to_int)
        state .

    on EX_RJT_MOVEON
        do get_all_parts (sts)
        do list_parts (sts, CO_list_parts)
        do COtools.assign (0, &me->num_objects, CO_cin_to_int)
        state .

    on EX_BACK_UP
        do COtools.close_file ()
        state START
        
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

