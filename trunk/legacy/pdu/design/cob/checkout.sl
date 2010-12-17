/******************************************************************
Document:	COpdu

Description:
	This COB file implements the PDM CHECKOUT command.

History:
        Mychelle Joiner       10/30/91       Created

*******************************************************************/

product_name    "$PDU"
command_string  PDCMCHECKOUT, PDC_M_CHECKOUT, PDChOtPr
class		COpdu
super_class	CEO_LOCATE
start_state	start

state_table
#include "PDUcommand.h"
#include "PDUerror.h"


state start 
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

