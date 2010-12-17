/*\
DESCRIPTION
     This command prompts the user for a point. The point could be entered 
     thru key board or mouse.

HISTORY
     Jamal Shakra    11/14/91    Creation date.
\*/

product_name    "$PDU"
command_string	PDCMENTERPOINT, PDC_M_ENTER_POINT, PDEnPt
class           COpdu
super_class     CEO_LOCATE
start_state     start

state_table
#include	"PDUerror.h"
#include	"PDUcommand.h"
#include	"PDUprompt.h"
#include	"PDUinform.h"


state  start 

   execute      get_message_type

                on RETURN_CODE = PDM_I_DEFINE_ORIGIN_MSG
                   do message_key  PDC_M_DEFINE_ORIGIN state prompt_user

                on RETURN_CODE = PDM_I_PLACE_POINTER_MSG
                   do message_key  PDC_M_PLACE_PART state prompt_user

                on ELSE
                   do message " " state terminate 

state  prompt_user

   execute      get_prompt_type

                on RETURN_CODE = PDM_I_DATA_POINT
                   do prompt_key  PDP_P_ENTER_POINT state display_status 

                on RETURN_CODE = PDM_I_POINT_ONE
                   do prompt_key  PDP_P_ENTER_POINT_ONE state display_status 

                on RETURN_CODE = PDM_I_POINT_TWO
                   do prompt_key  PDP_P_ENTER_POINT_TWO state display_status 

                on RETURN_CODE = PDM_I_POINT_THREE
                   do prompt_key  PDP_P_ENTER_POINT_THREE state display_status 

                on ELSE
                   do prompt " " state terminate

state  display_status
  
   execute     display_status_message
               on RETURN_CODE = PDM_S_SUCCESS 
                  do status  0 state input_point

state  input_point

   filter       get_event 	
   status       "" 

   on DATA	   do save_point
                   do status " "
		   state  terminate 

   on ELSE         do status " "
                   do  display_design_form
                   state terminate 
