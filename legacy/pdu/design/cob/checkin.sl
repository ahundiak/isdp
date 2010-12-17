/******************************************************************
Document:	COpdu

Description:
	This COB file implements the PDM CHECKIN command. The file
	specified in the refresh area is processed to extract
	information from any part pointers placed. The user is
	prompted if the file is already active.

History:
	05/15/88	Bill Kirk	Creation date.

*******************************************************************/

product_name    "$PDU"
command_string  PDCMCHECKIN, PDC_M_CHECKIN, PDChInPr
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

state external 
   execute      pdu_external                   /* non-graphic processing */
		on  RETURN_CODE = PDM_S_SUCCESS or RETURN_CODE = OM_S_SUCCESS
		    do  display_status
		    state terminate
		on  ELSE
		    do  display_status
		    state terminate

