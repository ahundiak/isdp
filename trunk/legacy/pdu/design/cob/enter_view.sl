/*\
DESCRIPTION
     This command prompts the user for a view name. 

HISTORY
     Jamal Shakra    11/22/91    Creation date.
\*/

/*\ ALR 12/28/93   Modified to check return and display message TR 139309988 \*/ 
product_name    "$PDU"
command_string	PDCMENTERVIEW, PDC_M_ENTER_VIEW, PDEnVw
class           COpdu
super_class     CEO_LOCATE
start_state     start

state_table
#include	"PDUerror.h"
#include	"PDUcommand.h"
#include	"PDUprompt.h"
#include	"PDUinform.h"


state  start 

   message      "Define Origin"
   execute      check_default_view
                on RETURN_CODE = PDM_S_SUCCESS
                   do  prompt_key PDP_P_ENTER_VIEW_NAME
                   state  input_view

                on ELSE 
                   do  prompt_key PDP_P_ENTER_VIEW_NAME_DEF
                   state  input_view


state  input_view

   filter       get_event 	
   status	" "


   on STRING = ""
                   do default_view 
                   state  terminate

   on STRING       do  store_view
                   on RETURN_CODE = PDM_S_SUCCESS
                     do display_status
                     state  terminate

                   on ELSE
                     do display_status
                     state start 
                   state terminate 

   on RESET 	   do  default_view
		   state  terminate 

   on DATA         state input_view 

   on ELSE         do  prompt " " 
                   on  CMD_TYPE = PDC_M_CREATE_TOP_DOWN
                       state  terminate
                   do  display_design_form
                   state  terminate
