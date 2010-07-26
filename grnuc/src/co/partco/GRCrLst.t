command_string GRC_M_CrPartsLst,CO_create_parts_list,GRCrPrLs
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
#include <dpbco.h>
#include "partco.h"
#include <msdef.h>
#include <msmacros.h>

state *
    on EX_RESTART 
        state START

state START

    execute true (sts, CO_IS_PARTS_LIST)

    on RETURN_CODE = FALSE
        do COtools.assign (0, &me->num_attrs,   CO_cin_to_int)
        do COtools.assign (0, &me->num_objects, CO_cin_to_int)
        state GET_BLOCK_POINT1

    on RETURN_CODE = TRUE
        do status_key  GR_I_PtLstDef
        state terminate

    on ELSE 
        do status_key GR_E_ErrEncCmdTrm 
        state terminate

state GET_BLOCK_POINT1

    msg_key    GRC_M_CrPartsLst
    prompt_key GR_P_EntFstDiaPt

    filter  get_event
    
    on EX_DATA
        do COtools.store_event (&me->event1, 0)
        state GET_BLOCK_POINT2
        
state GET_BLOCK_POINT2

    execute COdpb.get_dpb (sts, CO_sym, 0)

    prompt_key GR_P_EntSecDiaPt
    dynamics CO_parts_list_block
    
    filter get_event
    
    on EX_DATA
        do COtools.store_event (&me->event1, 1)
        do COtools.store_event (&me->event1, 2)
        do construct (sts, CO_parts_list_block, 0)
        state GET_FORMAT
        
    on EX_BACK_UP
        state GET_BLOCK_POINT1

state GET_FORMAT

    execute     do_Global_attr_message()
    prompt_key  GR_P_EntColAttTitleJst
    
    filter  get_event
    
    on EX_STRING
        do store_format (sts, me->event1.event.keyin)
            on RETURN_CODE = MSSUCC
                state PLACE_TITLE
            
            on RETURN_CODE = MSFAIL
                do status_key  GR_I_InvJust
                state .

        do status_key GR_E_ErrEncCmdTrm
        state terminate
        
    on EX_BACK_UP
        do COtools.compare (sts, 0, &me->num_processed, CO_cin_to_int)
            on RETURN_CODE = CO_eq
                do stack_delete (sts, 1, 1)
                state GET_BLOCK_POINT2

            on RETURN_CODE = CO_lt
                do stack_delete (sts, 1, 1)
                do COtools.add (&me->num_processed, -1)
                state PLACE_LINE

        do status_key GR_E_ErrEncCmdTrm
        state terminate
        
state PLACE_TITLE
    
    execute COdpb.get_dpb (sts, CO_everything, 0)

    prompt_key  GR_P_PosTitle
    dynamics CO_parts_list_title
    
    filter  get_event
    
    on EX_DATA
        do COtools.store_event (&me->event1, 2)
        do construct (sts, CO_parts_list_title, 0)
            on RETURN_CODE = MSSUCC
                state PLACE_LINE
                
            on RETURN_CODE = MSFAIL
                do status_key GR_E_ErrEncCmdRst
                state START
                
        do status_key GR_E_ErrEncCmdTrm
        state terminate
        
    on EX_BACK_UP
        state GET_FORMAT
        
state PLACE_LINE

    execute COdpb.get_dpb (sts, CO_sym, 0)

    prompt_key  GR_P_PosColDiv
    dynamics CO_parts_list_divider
    
    filter  get_event
    
    on EX_DATA
        do COtools.store_event (&me->event1, 2)
        do construct (sts, CO_parts_list_divider, 0)
            on RETURN_CODE = MSSUCC
                do COtools.add(&me->num_processed, 1)
                state GET_FORMAT
               
            on RETURN_CODE = MSFAIL
                do status_key GR_E_ErrEncCmdTrm
                state terminate

        do status_key GR_E_ErrEncCmdTrm
        state terminate
        
    on EX_BACK_UP
        do stack_delete (sts, 1, 1)
        state PLACE_TITLE

    on EX_RJT_MOVEON
        do COtools.add(&me->num_processed, 1)
        do ms_on_off MS_OFF
        do construct (sts, CO_parts_list, 0)
            on RETURN_CODE = MSSUCC
                do ms_on_off MS_ON
                do status_key GR_I_PtLstHdrDef
                do COtools.assign (0, &me->num_objects, CO_cin_to_int)
                state terminate
                
            on RETURN_CODE = MSFAIL
                do ms_on_off MS_ON
                do status_key GR_E_ErrEncCmdRst
                do stack_delete (sts, me->num_objects, 1)
                state START

        do ms_on_off MS_ON
        do status_key GR_E_ErrEncCmdTrm
        state terminate

at init
    do COdpb.alloc  (sts, 0)
    do COdpb.active (sts, 0)

at delete
    do stack_delete (sts, me->num_objects, 1)
