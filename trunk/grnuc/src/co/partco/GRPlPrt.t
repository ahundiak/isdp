command_string GRC_M_PlPart,CO_place_part,GRPlPr
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
#include <dpbco.h>
#include "partco.h"
#include "partdef.h"

state *
    on EX_RESTART 
        state START

state START
    execute true (sts, CO_ACTIVE_CELL)

    on RETURN_CODE = TRUE
        do COtools.assign (0, &me->num_processed, CO_cin_to_int)
        do COtools.assign (0, &me->num_attrs, CO_cin_to_int)
        do COtools.assign (0, &me->parts_processed, CO_cin_to_int)
        state PLACE_PART

    on RETURN_CODE = FALSE
        do status_key GR_F_NoActCelDfn
        do COtools.wait(20) 
        state terminate

    on ELSE 
        do status_key GR_E_ErrEncCmdTrm 
        state terminate
    
state PLACE_PART

    msg_key     GRC_M_PlPart
    prompt_key  GR_P_EntOrgForPt

    execute COdpb.get_dpb (sts, CO_scale | CO_angle | CO_level | CO_disp, 0)
    dynamics    CO_part_cell
    
    filter get_event

    on EX_DATA
        do ms_on_off MS_OFF
        do place_part (sts, &me->event1)

            on RETURN_CODE = CO_E_NO_CELL
                do ms_on_off MS_ON
                do status_key GR_F_NoActCelDfn
                state terminate

            on RETURN_CODE = CO_E_NOTPARTCELL
                do ms_on_off MS_ON
                do status_key  GR_I_ActCellNotPtCell
                state terminate

            on RETURN_CODE = MSFAIL
                do ms_on_off MS_ON
                do status_key GR_E_ErrEncCmdTrm
                state terminate

            on RETURN_CODE = MSSUCC
                do ms_on_off MS_ON
                do COtools.assign (0, &me->parts_processed, CO_cin_to_int)
                state PROCESS_PARTS

        do ms_on_off MS_ON
        do status_key GR_E_ErrEncCmdTrm
        state terminate

state PROCESS_PARTS

    execute COtools.erase_highlight()
    execute COtools.compare ( sts, 
                              &me->parts_processed, 
                              &me->num_parts, 
                              CO_int_to_int )
    
    on RETURN_CODE = CO_eq
        do status_key  GR_I_PartPlaced
        state START

    on ELSE
        do COtools.assign (0, &me->num_processed, CO_cin_to_int)
        do get_attributes (sts, 0, 1)
        state PROCESS_ATTRIBUTES

state PROCESS_ATTRIBUTES

    execute COtools.compare ( sts, 
                              &me->num_processed, 
                              &me->num_attrs, 
                              CO_int_to_int )
    
    on RETURN_CODE = CO_eq
        do COtools.add (&me->parts_processed, 1)
        state PROCESS_PARTS

    on ELSE
        state GET_ATTRIBUTE_PROMPT

state GET_ATTRIBUTE_PROMPT

    execute get_attribute_prompt (sts)

    on RETURN_CODE = MSSUCC
        do highlight_part (sts)
        state GET_ATTRIBUTE
    
    on ELSE
        do COtools.add (&me->parts_processed, 1)
        state PROCESS_PARTS

state GET_ATTRIBUTE

    execute CEO.prompt (me->prompt)

    filter get_event
    
    on EX_STRING
        do set_attribute (me->event1.event.keyin)
        do COtools.add (&me->num_processed, 1)
        state PROCESS_ATTRIBUTES

    on EX_BACK_UP
        do COtools.compare (sts, 0, &me->num_processed, CO_cin_to_int)
            on RETURN_CODE = CO_eq
                state PROCESS_PARTS
            on ELSE
                do COtools.add (&me->num_processed, -1)
                state PROCESS_ATTRIBUTES
            state terminate

    on EX_RJT_MOVEON
        do COtools.add (&me->num_processed, 1)
        state PROCESS_ATTRIBUTES

at init
    do COdpb.alloc  (sts, 0)
    do COdpb.active (sts, 0)

at delete
    do COtools.erase_highlight()

