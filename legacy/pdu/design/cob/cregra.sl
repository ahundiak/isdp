/*********************************************************************
Document:	PDM_M_CREATE_GRAPHICS

Description:
	This COB file inplements the PDM_M_CREATE_GRAPHICS command.
	It has an external component that retrieves a buffer from the
	server with information from the Contained-In table (CIT),
	and an internal component that creates an empty object space
	with a default window, and places a part pointer for each row
	in the CIT buffer.

Notes:

History:
	06/28/88	Bill Kirk	Created.

**********************************************************************/

product_name	"$PDU"
command_string	PDCMCREATEGRAPHICS, PDC_M_CREATE_GRAPHICS, PDCrGr
class		COpdu		
super_class	CEO_LOCATE
start_state	start

state_table
#include "PDUcommand.h"
#include "PDUerror.h"


state  start
   execute      display_command
   execute      verify_command
                on  RETURN_CODE = PDM_S_SUCCESS
                    state wk_validate
                on  ELSE
                    do  display_status
                    state terminate

state  wk_validate
   execute      display_command
   execute      pdu_validate_wf
                on  RETURN_CODE = PDM_S_SUCCESS
		    state external
                on  ELSE
		    do  pdu_chg_wf_state
                    do  display_status
                    state terminate

state  external
   prompt	" "
   status	" "

   status_key	PDM_I_WORKING
   execute	pdu_external		/* non-graphic processing */
		on  PDM_S_SUCCESS
		    do  status_key  PDM_I_WORKING
		    do  pdu_internal	/* graphic processing */
		    do  pdu_chg_wf_state
		    do  display_status
		    state terminate

		on  ELSE
		    do  pdu_chg_wf_state
		    do  display_status
		    state terminate

