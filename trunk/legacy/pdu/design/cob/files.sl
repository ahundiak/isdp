/*\
DESCRIPTION
     This file processes file manager commands.

HISTORY
     Mychelle Joiner    10/30/91        Created
\*/

product_name	"$PDU"
command_string	"pdm non-graphic commands", 0, NonGra
synonym		PDCMDISPLAYFILES, PDC_M_DISPLAY_FILES, PDShLsLcFl
synonym         PDCMDELETEFILE, PDC_M_DELETE_FILE, PDDlLcFl
synonym         PDCMCOPY, PDC_M_COPY, PDCpFlTLc
class		COpdu		
super_class	CEO_LOCATE
start_state	start

state_table
#include "PDUcommand.h"
#include "PDUerror.h"


state  start
   execute      display_command
                on  RETURN_CODE = PDM_S_SUCCESS
                    state external 
                on  ELSE
                    do  display_status
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
