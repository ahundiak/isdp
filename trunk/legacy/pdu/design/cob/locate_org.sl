command_string PDCMLOCATEORIGIN, PDC_M_LOCATE_ORIGIN, PDLcOr
class          COpdu
product_name   "$PDU"
super_class    CEO_LOCATE
start_state    LOCATE_ORIGIN 
 
state_table

#include "lcdef.h"
#include "comndef.h"
#include "PDUerror.h"
#include "PDUcommand.h"
#include "PDUprompt.h"

state *
    on EX_RESTART 
        state LOCATE_ORIGIN 

state LOCATE_ORIGIN

    highlight_located 0
    execute      disconnect_located
    
    message_key  PDC_M_LOCATE_ORIGIN
    prompt_key 	 PDP_P_IDENTIFY_ORIGIN
    accept_key   PDP_P_ACCEPT_ORIGIN 
    relocate_key PDM_I_ORIGIN_NOT_FOUND 

    locate_class          "+GRgencs"

    locate_properties     COPY_LC_PROPS 

    locate_owner          COPY_LC_OWNER

    locate_display        "ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
                           ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT |
                           LC_ERASE_ALL | LC_ACCEPT_CURSOR" 
    
    filter locate
    prompt " "
    status " "

    on EX_RJT_MOVEON
       do list_origins
       state terminate

    on EX_DATA
       do highlight_located 0
       do store_origin_id
       state terminate

    on EX_STRING
       do highlight_located 0
       do store_origin_id
       state terminate

    on ELSE
       do prompt ""
       do message ""
       do display_design_form
       state terminate
