/*\
DESCRIPTION
   This COB file processes the cancel checkout command.

HISTORY
   Mychelle Joiner   10/30/91        Created
\*/

product_name	"$PDU"
command_string	"pdm non-graphic commands", 0, NonGra
synonym		PDCMCANCELCHECKOUT, PDC_M_CANCEL_CHECKOUT, PDCnPrChOt
class		COpdu		
super_class	CEO_LOCATE
start_state	start

state_table
#include "PDUcommand.h"
#include "PDUerror.h"
#include "PDUprompt.h"


state  start
   execute      display_command
                on  RETURN_CODE = PDM_S_SUCCESS
                    state confirm_cancel
                on  ELSE
                    do  display_status
                    state terminate

state confirm_cancel

   status       " "

   prompt_key   PDP_P_CONFIRM_CANCEL
   filter       get_event

   on EX_STRING = "Y" or EX_STRING = "y"
                do prompt " "
                state external

   on EX_STRING = ""
                do prompt " "
                state external

   on ELSE
                do prompt " "
                do disp_cmd_cancelled
                do display_status
                state terminate

state  external
   prompt	" "

   execute	pdu_external	/* non-graphic processing */
                on  RETURN_CODE = PDM_S_SUCCESS
                    do  display_status
                    state terminate
   		on  ELSE
		   do	display_status
		   state terminate

