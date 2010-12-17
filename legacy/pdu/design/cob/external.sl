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
synonym		PDCMDEFINEBOMSUM, PDC_M_DEFINE_BOMSUM, PDDfBOSmPr
synonym		PDCMBOMWHEREHIGHLEV, PDC_M_BOM_WHERE_HIGH_LEV, PDCrWhUsHL
synonym		PDCMBOMPRINT, PDC_M_BOM_PRINT, PDCrBOPrFr
synonym		PDCMBOMWHEREUSEDASSEM, PDC_M_BOM_WHERE_USED_ASSEM, PDCrWhUsAs
synonym		PDCMADDPARTPROJ, PDC_M_ADD_PART_PROJ, PDAdPrPj
synonym		PDCMBOMPARTSLIST, PDC_M_BOM_PARTS_LIST, PDCrBOPrLs
synonym		PDCMUNFLAGARCHIVE, PDC_M_UNFLAG_ARCHIVE, PDCnFlAr
synonym		PDCMUNFLAGBACKUP, PDC_M_UNFLAG_BACKUP, PDCnFlBc
synonym		PDCMUNFLAGRESTORE, PDC_M_UNFLAG_RESTORE, PDCnFlRs
synonym		PDCMUNFLAGDELETE, PDC_M_UNFLAG_DELETE, PDCnFlDl
synonym		PDCMDEFINEBOMPARTSFORM,PDC_M_DEFINE_BOM_PARTS_FORM, PDDfBOPrLs
synonym		PDCMDELBOMPARTSLISTPRFORM, PDC_M_DEL_BOM_PARTS_LIST_PR_FORM, PDDlBOPrLs
synonym		PDCMDELBOMSUMPRFORM, PDC_M_DEL_BOM_SUM_PR_FORM, PDDlBOSmPr
synonym		PDCMDELBOMWHEREBOMPRFORM, PDC_M_DEL_BOM_WHERE_BOM_PR_FORM, PDDlWhUsHL
synonym		PDCMDELBOMWHEREUSEDPRFORM, PDC_M_DEL_BOM_WHERE_USED_PR_FORM, PDDlWhUsAs
synonym		PDCMBOMSUMMARYBOM, PDC_M_BOM_SUMMARY_BOM, PDCrBOSmPr
synonym		PDCMDEFBOMWHEREUSEDPFORM, PDC_M_DEF_BOM_WHERE_USED_PFORM, PDDfWhUsAs
synonym		PDCMDEFBOMWHEREBOMPFORM, PDC_M_DEF_BOM_WHERE_BOM_PFORM, PDDfWhUsHL
synonym		PDCMUSERAPPROVED, PDC_M_USER_APPROVED, PDApPr
synonym		PDCMARCHIVEPENDING, PDC_M_ARCHIVE_PENDING, PDFlPrAr
synonym		PDCMBACKUPPENDING, PDC_M_BACKUP_PENDING, PDFlPrBc
synonym		PDCMBOMDISPLAYREVIEW, PDC_M_BOM_DISPLAY_REVIEW, PDShBORvPr
synonym		PDCMCANCELFLAGS, PDC_M_CANCEL_FLAGS, PDDlPnFl
synonym		PDCMCREATEELEMENT, PDC_M_CREATE_ELEMENT, PDAdPr
synonym		PDCMCREATELIKEPART, PDC_M_CREATE_LIKE_PART, PDCpCPr
synonym		PDCMCREATELIKECATALOG, PDC_M_CREATE_LIKE_CATALOG, PDCpCt
synonym		PDCMCREATECATALOG, PDC_M_CREATE_CATALOG, PDCrCt
synonym		PDCMDEFINEBOMCONT, PDC_M_DEFINE_BOMCONT, PDDfBOCn
synonym		PDCMDEFINEBOMLIST, PDC_M_DEFINE_BOMLIST, PDDfBOLsFr
synonym		PDCMDEFINEBOMMAP, PDC_M_DEFINE_BOMMAP, PDChBOMp
synonym		PDCMDEFINEBOMPRINT, PDC_M_DEFINE_BOMPRINT, PDDfBOPrFr
synonym		PDCMDEFINECATLIST, PDC_M_DEFINE_CATLIST, PDDfCtLsFr
synonym		PDCMDEFINESEARCH, PDC_M_DEFINE_SEARCH, PDDfCtScCr
synonym		PDCMDEFLOCSEARCHCRIT, PDC_M_DEF_LOC_SEARCH_CRIT, PDDfLsCtSc
synonym		PDCMDELETECATALOG, PDC_M_DELETE_CATALOG, PDDlCt
synonym		PDCMDELETEELEMENT, PDC_M_DELETE_ELEMENT, PDDlPr
synonym		PDCMDELETEPENDING, PDC_M_DELETE_PENDING, PDFlPrDl
synonym		PDCMDISPLAYLOC, PDC_M_DISPLAY_LOC, PDShLsCt
synonym		PDCMDISPLAYCATALOG, PDC_M_DISPLAY_CATALOG, PDShLsPrIn
synonym  	PDCMRECONNECT, PDC_M_RECONNECT, PDReCoPD
synonym		PDCMMODIFYCATALOG, PDC_M_MODIFY_CATALOG, PDCCt
synonym		PDCMMODIFYELEMENT, PDC_M_MODIFY_ELEMENT, PDCPr
synonym		PDCMREDRAWDESIGN, PDC_M_REDRAW_DESIGN, PDUrdref
synonym		PDCMRETRIEVEPENDING, PDC_M_RETRIEVE_PENDING, PDFlPrRs
synonym  	PDCMREVIEWPART, PDC_M_REVIEW_PART, PDRvPrAt
synonym		PDCMSEARCHONOFF, PDC_M_SEARCH_ONOFF, PDTgScCr
synonym		PDCMSEARCHACROSSCATS, PDC_M_SEARCH_ACROSS_CATS, PDSrAlCt
synonym		PDCMDEFINELOCDISPLAY, PDC_M_DEFINE_LOC_DISPLAY, PDDfLsCtLs
synonym		PDCMDEFCATSORTCRIT, PDC_M_DEF_CAT_SORT_CRIT, PDDfCtStCr
synonym		PDCMDEFLOCSORTCRIT, PDC_M_DEF_LOC_SORT_CRIT, PDDfLsCtSt
synonym		PDCMCREATENONGRAPHICASS,PDC_M_CREATE_NONGRAPHIC_ASS, PDCrNnAs
synonym		PDCMDELETEBOM, PDC_M_DELETE_BOM, PDDlBO
synonym		PDCMDELETEBOMFORMAT, PDC_M_DELETE_BOM_FORMAT, PDDlBOLsFr
synonym		PDCMDELETECATLISTFORMAT, PDC_M_DELETE_CATLIST_FORMAT, PDDlCtLsFr
synonym		PDCMDELETEBOMPRINTFORMAT, PDC_M_DELETE_BOMPRINT_FORMAT, PDDlBOPrFr
synonym		PDCMDELETELOCDISPFORMAT, PDC_M_DELETE_LOC_DISP_FORMAT, PDDlLsCtLs
synonym		PDCMDISPLAYBOMS, PDC_M_DISPLAY_BOMS, PDShLsBO
synonym		PDCMMODIFYUSERPASSWORD, PDC_M_MODIFY_USER_PASSWORD, PDCUsPs
synonym		PDCMDELETEFILES, PDC_M_DELETE_FILES, PDDlFl
class		COpdu		
super_class	CEO_LOCATE
start_state	start

state_table
#include "PDUcommand.h"
#include "PDUerror.h"
#include "PDUprompt.h"


state  start
   execute    display_command
   execute    verify_command
              on  RETURN_CODE = PDM_S_SUCCESS
                  on CMD_TYPE = PDC_M_DELETE_CATALOG state confirm_delete
                  on CMD_TYPE = PDC_M_DELETE_ELEMENT state confirm_delete_part
                  on CMD_TYPE = PDC_M_DELETE_BOM state confirm_bom_delete
                  on CMD_TYPE = PDC_M_DELETE_FILES state confirm_delete_files
                  on CMD_TYPE = PDC_M_MOVE_TO_STATE state confirm_move_to_state
                  on CMD_TYPE = PDC_M_DELETE_PENDING state delete_pending
                  on CMD_TYPE = PDC_M_BACKUP_PENDING state backup_pending
                  on CMD_TYPE = PDC_M_ARCHIVE_PENDING state archive_pending
                  on CMD_TYPE = PDC_M_RETRIEVE_PENDING state retrieve_pending
                  on CMD_TYPE = PDC_M_UNFLAG_ARCHIVE state unflag_archive
                  on CMD_TYPE = PDC_M_UNFLAG_DELETE state unflag_delete
                  on CMD_TYPE = PDC_M_UNFLAG_RESTORE state unflag_restore
                  on CMD_TYPE = PDC_M_UNFLAG_BACKUP state unflag_backup
                  on CMD_TYPE = PDC_M_DELETE_BOM_FORMAT state delete_report
                  on CMD_TYPE = PDC_M_DELETE_LOC_DISP_FORMAT state delete_report
                  on CMD_TYPE = PDC_M_DELETE_CATLIST_FORMAT state delete_report
                  on CMD_TYPE = PDC_M_DEL_BOM_SUM_PR_FORM state delete_report
                  on CMD_TYPE = PDC_M_DEL_BOM_WHERE_USED_PR_FORM state delete_report
                  on CMD_TYPE = PDC_M_DEL_BOM_WHERE_BOM_PR_FORM state delete_report
                  on CMD_TYPE = PDC_M_DEL_BOM_PARTS_LIST_PR_FORM state delete_report
                  state wk_validate
     	      on  RETURN_CODE = NULL
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

state confirm_delete

   status       " "

   prompt_key   PDP_P_DELETE_CATALOG
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

state delete_report

   status       " "

   prompt_key   PDP_P_DELETE_REPORT
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

state confirm_delete_part

   status       " "

   prompt_key   PDP_P_DELETE_ELEMENT
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

state confirm_bom_delete

   status       " "

   prompt_key   PDP_P_DELETE_BOM
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

state confirm_delete_files

   status       " "

   prompt_key   PDP_P_DELETE_FILES
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

state confirm_move_to_state

   status       " "

   prompt_key   PDP_P_MOVE_TO_STATE
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

state delete_pending

   status       " "

   prompt_key   PDP_P_DELETE_PENDING
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

state backup_pending

   status       " "

   prompt_key   PDP_P_BACKUP_PENDING
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

state archive_pending

   status       " "

   prompt_key   PDP_P_ARCHIVE_PENDING
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

state retrieve_pending

   status       " "

   prompt_key   PDP_P_RETRIEVE_PENDING
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

state unflag_archive

   status       " "

   prompt_key   PDP_P_UNFLAG_ARCHIVE
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

state unflag_delete

   status       " "

   prompt_key   PDP_P_UNFLAG_DELETE
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

state unflag_restore

   status       " "

   prompt_key   PDP_P_UNFLAG_RESTORE
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

state unflag_backup

   status       " "

   prompt_key   PDP_P_UNFLAG_BACKUP
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

state  external
   prompt	" "

   status_key	PDM_I_WORKING
   execute	pdu_external	/* non-graphic processing */
   		on  ELSE
		   do   pdu_chg_wf_state
		   state terminate
