/*********************************************************************
Document:	COpdu

Description:
	This COB file processes all PDM commands that have "mixed"
	components.  They have an internal component that manipulates
	EMS graphic objects, and an external component that processes
	forms, and submits database requests to the server.

Notes:
	These commands require no direct user interaction.

History:
	09/21/87	Bill Kirk	Created.
	02/08/88	Bill Kirk	Modified.
	06/21/88	Bill Kirk	Modified to delete PDMMCHECKIN
					and documented

**********************************************************************/

product_name    "$PDU"
command_string  "pdm graphic commands", 0, Graphics
synonym   	PDCMLOGOUT, PDC_M_LOGOUT, PDLgOtPD
synonym		PDCMACTIVATEPART, PDC_M_ACTIVATE_PART, PDAcPr
synonym		PDCMDEACTIVATEPART, PDC_M_DEACTIVATE_PART, PDDcPr
synonym		PDCMTOGGLETREE, PDC_M_TOGGLE_TREE, PDTgSbAt
synonym		PDCMREADREFRESH, PDC_M_READ_REFRESH, PDRdRf
synonym		PDCMWRITEREFRESH, PDC_M_WRITE_REFRESH, PDWrRf
synonym		PDCMDEBUGON, PDC_M_DEBUG_ON, PDDbOn
synonym		PDCMDEBUGOFF, PDC_M_DEBUG_OFF, PDDbOf
synonym         PDCMDEFAULTORIGIN, PDC_M_DEFAULT_ORIGIN, PDDftOr
synonym         PDCMCONVERTOS, PDC_M_CONVERT_OS, PDCvOs
synonym         PDCMEXITDESIGN, PDC_M_EXIT_DESIGN, PDExDs
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
                on  RETURN_CODE = PDM_I_PART_CHECKIN state wk_validate 
                on  RETURN_CODE = PDM_S_SUCCESS or RETURN_CODE = NULL
                    on CMD_TYPE = PDC_M_LOGOUT state confirm_logout
                    on CMD_TYPE = PDC_M_DEFAULT_ORIGIN state internal
                    on CMD_TYPE = PDC_M_CONVERT_OS state internal
                    on CMD_TYPE = PDC_M_DEACTIVATE_PART state exit_save
                    on CMD_TYPE = PDC_M_EXIT_DESIGN state exit_nosave
                    state wk_validate
                on  ELSE
                    do  display_status
                    state terminate

state  wk_validate
   execute      display_command
   execute      pdu_validate_wf
                on  RETURN_CODE = PDM_S_SUCCESS
		    state internal
                on  ELSE
		    do  pdu_chg_wf_state
                    do  display_status
                    state terminate

state confirm_logout

   status       " "

   prompt_key   PDP_P_CONFIRM_LOGOUT
   filter       get_event

   on EX_STRING = "Y" or EX_STRING = "y"
                do prompt " "
                state wk_validate 

   on EX_STRING = ""
                do prompt " "
                state wk_validate 

   on ELSE     
                do prompt " "
                do disp_cmd_cancelled 
                do display_status 
                state terminate


state exit_save

   status       " "

   prompt_key   PDP_P_EXIT_DESIGN_SAVE
   filter       get_event

   on EX_STRING = "Y" or EX_STRING = "y"
                do prompt " "
                state check_for_origins 

   on EX_STRING = ""
                do prompt " "
                state check_for_origins 

   on ELSE
                do prompt " "
                do disp_cmd_cancelled
                do display_status
                state terminate


state check_for_origins

   status       " "

   execute      check_origins

   on  RETURN_CODE = PDM_I_ORIGIN_NOT_FOUND

                   do prompt " "
                   state  prompt_for_origin
 
   on ELSE
                   do prompt " "
                   state wk_validate


state prompt_for_origin 

   prompt_key	PDP_P_CHECKIN_NO_ORIGIN
   filter       get_event

   on EX_STRING = "Y" or EX_STRING = "y"
                do prompt " "
                state wk_validate

   on EX_STRING = "N" or EX_STRING = "n" or EX_STRING = ""
                do prompt " "
                do disp_cmd_cancelled
                state terminate

   on ELSE
                state prompt_for_origin 


state exit_nosave

   status       " "

   prompt_key   PDP_P_EXIT_DESIGN
   filter       get_event

   on EX_STRING = "Y" or EX_STRING = "y"
                do prompt " "
                state wk_validate

   on EX_STRING = ""
                do prompt " "
                state wk_validate

   on ELSE     
                do prompt " "
                do disp_cmd_cancelled
                do display_status
                state terminate

state  internal
   prompt	" "
   status	" "

   status_key	PDM_I_WORKING
   execute	pdu_internal			/* graphic processing */
		on  PDM_S_SUCCESS
                    on CMD_TYPE = PDC_M_CONVERT_OS
                        do  display_status
                        state terminate
		    do  status_key  PDM_E_CLEAR_FIELD
		    do  pdu_external		/* non-graphic processing */
                        on  CMD_TYPE = PDC_M_DEFAULT_ORIGIN
                            do  save_default_view
                            do  close_invis_file 
                            do  pdu_cleanup
                            do  display_status
                        state  terminate

		    on  PDM_E_NOT_IMPLEMENTED
		        do  pdu_chg_wf_state
			state terminate

		    on  ELSE
		        do  pdu_chg_wf_state
			do  display_status
			state terminate
		    state terminate

		on  ELSE
		    do  pdu_chg_wf_state
		    do  display_status
		    state terminate
