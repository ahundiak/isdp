command_string PDCMLOCATECS, PDC_M_LOCATE_CS, PDLcCs
class          COpdu
product_name   "$PDU"
super_class    CEO_LOCATE
start_state    LOCATE_CS 
 
state_table

#include "lcdef.h"
#include "comndef.h"
#include "PDUerror.h"
#include "PDUcommand.h"
#include "PDUprompt.h"

state *
    on EX_RESTART 
        state LOCATE_CS 

state LOCATE_CS

    highlight_located 0
    execute      disconnect_located
    execute      display_status_message 
    
    message_key PDC_M_LOCATE_CS
    prompt_key	PDP_P_IDENTIFY_COORD_SYS
    status       0 

    accept_key      PDP_P_ACCEPT_CS
    relocate_key    PDP_P_REJECT_CS

    locate_class          "+GRgencs"

    locate_properties     COPY_LC_PROPS 

    locate_owner          COPY_LC_OWNER 

    locate_display        "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                           ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT |
                           LC_ERASE_ALL | LC_ACCEPT_CURSOR" 
    
    filter locate
    prompt ""
    status "" 

    on EX_DATA
       do highlight_located 0
       do store_origin_id
       do status " "
       state terminate

    on EX_STRING
       do highlight_located 0
       do store_origin_id
       do status " "
       state terminate

    on ELSE
       do prompt " "
       do message " "
       do status " "
       do display_design_form
       state terminate
