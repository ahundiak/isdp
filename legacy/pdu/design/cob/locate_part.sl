command_string PDCMLOCATEPART, PDC_M_LOCATE_PART, PDLcPr
class          COpdu
product_name   "$PDU"
super_class    CEO_LOCATE
start_state    LOCATE_PART 
 
state_table

#include "lcdef.h"
#include "PDUerror.h"
#include "PDUcommand.h"
#include "PDUprompt.h"

state *
    on EX_RESTART 
        state LOCATE_PART 

state LOCATE_PART

    highlight_located 0
    execute      disconnect_located
    
    message_key  PDC_M_IDENTIFY_PART
    prompt_key   PDP_P_IDENTIFY_PART
    accept_key   PDP_P_ACCEPT_PART
    relocate_key PDM_I_PART_NOT_FOUND 

    locate_class          "GRpart"

    locate_properties     "LC_LC_ONLY | LC_WRITE_ONLY | LC_DP_ONLY" 

    locate_owner          "LC_NO_RIGID_OWNER | LC_FLEX_COMP | LC_FLEX_OWNER |
                           LC_REF_HEADER | LC_NO_REF_OBJECTS" 

    locate_display        "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                           ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT |
                           LC_ERASE_ALL | LC_ACCEPT_CURSOR" 
    
    filter locate
    prompt " "
    status " "

    on EX_RJT_MOVEON
       do list_parts
       state terminate

    on EX_OBJID
       do highlight_located 0
       do store_GRpart_id
       state terminate

    on EX_DATA
       do highlight_located 0
       do store_GRpart_id
       state terminate

    on ELSE
       do prompt ""
       do message ""
       do display_design_form
       state terminate
