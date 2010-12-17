/*\
DESCRIPTION
   This COB file processes all PDM commands that require no direct
   interaction with EMS objects.  Non-EMS commands are launched by
   invoking a subprocess.

HISTORY
     Bill Kirk    09/21/87    Creation date.
     Bill Kirk    01/08/88    Modify date.
     Bill Kirk    02/08/88    Modify date.
\*/

product_name	"$PDU"
command_string	"pdm non-graphic commands", 0, NonGra
synonym  	PDCMLOGINUSER, PDC_M_LOGIN_USER, PDLgIn
class		COpdu		
super_class	CEO_LOCATE
start_state	start

state_table
#include "PDUcommand.h"
#include "PDUerror.h"
#include "PDUprompt.h"


state  start
   execute      display_command
   execute      verify_command
                on  RETURN_CODE = PDM_S_SUCCESS
		    state external
		on  RETURN_CODE = NULL
		    state terminate
                on  ELSE
                    do  display_status
                    state terminate


state  external
   prompt	" "

   execute	pdu_external	/* non-graphic processing */
                on ELSE
                   do  display_status
                   state terminate
