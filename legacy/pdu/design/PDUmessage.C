#include	<OMlimits.h>
#include	<OMerrordef.h>
#include	<PDUint.h>   
#include	<igrtypedef.h>  
#include	<msmacros.h>
#include	<msdef.h>
#include	<grmessage.h>
#include	<PDUintdef.h>
#include	<PDUint.h>   
#include        <PDUprompt.h>
#include        <PDUuser.h>
#include        <PDMmessage.h>
#include        <FI.h>
#include        <PDUproto.h>

extern struct PDUrefresh	*refresh; 
extern struct PDUuser           *user;
extern short  PDU_design_form_display;
extern int    PDU_command;
extern char   *PDU_save_filename;
extern char   *PDU_save_partid;
extern int    PDU_apiflag;
extern short  PDU_extadmin;
extern char   *PDU_attr_name;
extern char   *PDU_srch_catalog;
extern Form   PDU_form_id;

/****************************************************************************

Document:	PDUmessage_trans

Description:
        This command translates the given message key into the appropriate
	command string and then calls PDUwork_controller if a "v" was
	the second argument or PDMset_to_state if anything else was sent.
	PDMwork_controller which mainly provides external support to the
	PDU commands for work flow.  It sends information from the review
	refresh partspec and command string to initialize the work
	flow, to the server.  PDMset_to_state sets the state according to
	the current status.

Algoritm:
        1. Translate the given message key.
	2. If second argument "v" call PDUwork_controller which
	   a. Prefix PDM to the command string to make the work flow string.
	   b. Call PDMvalidate_user_access function to validate the users access
	      with the current command and workflow.
	3. Else: call PDMset_to_state.


Return Status:
	PDM_S_SUCCESS	-	Success
	Other Status	-	Error status returned from PDMvalidate_user_
				access or PDMset_to_state.

Notes:

History:
	11/02/89	Lynn Mettlen	Created
	01/02/90	Lynn Mettlen	Modified
        01/10/91        Jamal Shakra    Modified

*****************************************************************************/

IGRint	PDUmessage_trans (msg_key, wf)
  IGRint	msg_key;	/* command key if for validate, else status */
  IGRchar	wf;		/* v for validate, else for set to state */
  {
  IGRint	status = PDM_S_SUCCESS;
  IGRchar	status_msg[80];
  IGRchar	*output_msg = NULL;


  status_msg[0] = '\0';
  strcpy(status_msg, NULLSTR);

  if ((msg_key == 0) && (wf == 's'))
    return(PDM_S_SUCCESS);

  _pdm_debug("msg_key = %d", (char *)msg_key);

  /* translate command key to command string or message key to string */
  if (!PDU_extadmin)
    {
    ex$message ( buff = status_msg, msgnumb = msg_key );
    _pdm_status2 ("ex$message (translate)", status, msg_key);
    }
  else
    {
    _pdm_debug("translating message for external PDU", 0);
    output_msg = (char *)PDUtranslate_message(msg_key);
    strcpy(status_msg, output_msg);
    }
  _pdm_debug("status message = %s", status_msg);
  
  if (wf == 'v')
     {
     /* call PDMfunction work controller */
     status = PDUwf_check (msg_key);
     if (1&status)
        {
     	status = PDUwork_controller ( status_msg );
     	_pdm_status ("PDMwork_controller", status);
	}
     else status = PDM_S_SUCCESS;
     }
  else
     {
     	_pdm_debug ("before PDUwf_check refresh->command = %d", (char *)refresh->command);
     status = PDUwf_check (refresh->command);
     	_pdm_debug ("after PDUwf_check refresh->command = %d", (char *)refresh->command);
     if (1&status)
        {
     	status = PDMset_to_state ( msg_key, "PDM", status_msg );
     	_pdm_status ("PDMset_to_state", status);
	}
     else  status = PDM_S_SUCCESS;
     }
  return(status);
  }

IGRint	PDUwf_check ( msg_key )
  IGRint	msg_key;
  {
  IGRint	status = PDM_S_SUCCESS;
  switch ( msg_key )
     {
        case PDC_M_LOGIN_USER:
	case PDC_M_LOGOUT:
	case PDC_M_DEBUG_ON:
	case PDC_M_DEBUG_OFF:
	case PDC_M_UPDATE_REF_AREA_PT:	/* UPDATE REF AREA BY PT */
	case PDC_M_DEACTIVATE_PART:
	case PDC_M_EXIT_DESIGN:
	case PDC_M_REDRAW_DESIGN:
	case PDC_M_LOCATE_REV_PRTS:	/* HI REV PRTS */
	case PDC_M_TOGGLE_POINTERS:
	case PDC_M_TOGGLE_TREE:
	case PDC_M_PLACE_PART:
        case PDC_M_DEFINE_ORIGIN:
        case PDC_M_DELETE_ORIGIN:
	case PDC_M_DETACH_PART:
	case PDC_M_REVISE_ASSEMBLY:
  	     status = NULL;
        break;

        case PDC_M_CHECKIN:
	     if (strcmp(refresh->rev_catalog,"pdmseedfiles") == 0)
	       {
		status = NULL;
		break;
	       }
	
        default:
        break;  
     }
  return(status);
  }

/**********************************************
 *					      *
 *  subsystem: MESSAGE PROCESSOR for PDU/PDM  *
 *					      *
 *  author:    Bill Kirk		      *
 *					      *
 **********************************************/

IGRint	PDUmessage (msg_key, msg_field)
  IGRint	msg_key;
  IGRchar	msg_field;
  {
  IGRint	status = PDM_S_SUCCESS;
  IGRchar	output_string[256], status_msg[256];
  IGRchar       *output_msg = NULL;
  IGRchar       *output_msg1 = NULL;
  int           FOUND = FALSE;

  _pdm_debug("In the function PDUmessage", 0);

  if (PDU_apiflag)
    return(PDM_S_SUCCESS);

  _pdm_debug("In the function PDUmessage refresh->status = <0x%.8x>", (char *)refresh->status);
  _pdm_debug("In the function PDUmessage msg_key = <0x%.8x>", (char *)msg_key);
  if ( msg_key == 0 )  return ( PDM_S_SUCCESS );
  if ( msg_key == 1 )  return ( PDM_S_SUCCESS );
  if ( msg_key == OM_S_SUCCESS )  msg_key = PDM_S_SUCCESS;

  if (msg_key == 0)
    return(PDM_S_SUCCESS);

  if (msg_key == 1)
    return(PDM_S_SUCCESS);

  strcpy(status_msg, NULLSTR);
  strcpy(output_string, NULLSTR);

  if ((msg_key == PDC_M_LOGIN_USER) && ((PDU_design_form_display == FALSE) ||
      (PDU_command == PDC_M_REDRAW_DESIGN)))
    msg_key = PDC_M_REDRAW_DESIGN;

  if ((msg_key == PDC_M_BOM_SUMMARY_BOM) && 
     (PDU_command == PDC_M_EXPLODE_SUMMARY_BOM))
    msg_key = PDC_M_EXPLODE_SUMMARY_BOM;

  switch ( msg_field )
     {
     /* command name display */
     case 'c':
     case 'C':
	switch ( msg_key )
	   {
           case PDM_E_CLEAR_FIELD:
		/* get output variable */
		PDUget_var( msg_key, output_string );
		_pdm_debug("output variable = %s", output_string);

                if (!PDU_extadmin)
                  {
                  FOUND = TRUE;
		  ex$message ( field = MESSAGE_FIELD, msgnumb = msg_key,
			     justification = CENTER_JUS,
			     type = "%s", var = ` output_string ` );
		  _pdm_status2 ("ex$message", status, msg_key);
                  }
                else
                  {
                  _pdm_debug("translating message for external PDU", 0);
		  _pdm_debug ("msg_key = %d", (char *)msg_key);
                  output_msg = (char *)PDUtranslate_message_and_vars(msg_key,
                                                                 output_string);
                  _pdm_debug("message string = <%s>", output_msg);
                  if (PDU_form_id)
                    FIg_set_text(PDU_form_id, FI_MSG_FIELD, output_msg);
                  FOUND =  TRUE;
                  }
		break;
        
           default:

                if (!PDU_extadmin)
                  {
	          ex$message ( field = MESSAGE_FIELD, msgnumb = msg_key,
		               justification = CENTER_JUS);
	          _pdm_status2 ("ex$message (command)", status, msg_key);
                  }
               else
                 {
                 _pdm_debug("translating command message for external PDU", 0);
	         _pdm_debug ("msg_key = %d", (char *)msg_key);
                 output_msg = (char *)PDUtranslate_message(msg_key);
                _pdm_debug("message string = <%s>", output_msg);
                if (PDU_form_id)
                  FIg_set_text(PDU_form_id, FI_PROMPT_FIELD, output_msg);
                 }
	      break;
              }
         break;

     /* prompt field display */
     case 'p':
     case 'P':
        if (!PDU_extadmin)
          {
        ex$message ( field = PROMPT_FIELD, msgnumb = msg_key,
		     justification = RIGHT_JUS);
        _pdm_status2 ("ex$message (prompt)", status, msg_key);
          }
        else
          {
          _pdm_debug("translating command message for external PDU", 0);
	  _pdm_debug ("msg_key = %d", (char *)msg_key);
          output_msg = (char *)PDUtranslate_message(msg_key);
          _pdm_debug("message string = <%s>", output_msg);
          if (PDU_form_id)
            FIg_set_text(PDU_form_id, FI_PROMPT_FIELD, output_msg);
          }
	break;

     /* display message in error box */
     case 'e':
     case 'E':
	ex$message ( buff = status_msg, msgnumb = msg_key );
	_pdm_status2 ("ex$message (errorbox)", status, msg_key);

	_pdm_debug("status message = %s", status_msg);
	_pdm_debug("before the UI_error message",0);
/*
	UI_error (status_msg);
*/
	_pdm_debug("after the UI_error message",0);
	break;

     /* translate command key to command string */
     case 't':
     case 'T':
	ex$message ( buff = status_msg, msgnumb = msg_key );
	_pdm_status2 ("ex$message (translate)", status, msg_key);
	_pdm_debug("status message = %s", status_msg);
	break;

     /* status field display */
     case 's':
     case 'S':
	switch ( msg_key )
	   {
	   /*******************************************/
	   /*     message to ignore 		      */
	   /*******************************************/
	   case NULL:
                FOUND = TRUE;
		break;

	   /*******************************************/
	   /* operator INFORMATION messages, SLEEP  5 */
	   /*******************************************/
	   case PDM_I_ALREADY_INIT:
	   case PDM_I_ATTR_NOT_FOUND:
	   case PDM_I_SEARCH_NAME_NOT_FOUND:
	   case PDM_I_NONGRA_CHECKIN:
	   case PDM_I_PART_NOT_FOUND:
           case PDM_I_CREATING_NEW_FILE:
           case PDM_I_NO_FILES_FOUND:
           case PDM_I_ENTER_CATALOG:
           case PDM_I_ENTER_PART:
           case PDM_I_ENTER_LIBRARY:
           case PDM_I_ENTER_REVISION:
           case PDM_I_MULTIPLE_PARTS_SELECTED:
           case PDM_I_DEFAULT_USAGE_LENGTH:
           case PDM_I_INVALID_CATALOG:
                if (!PDU_extadmin)
                  {
		_pdm_debug ("before ex$message msg_key = %d", (char *)msg_key);
		_pdm_status2 ("ex$message", status, msg_key);
		ex$message ( field = ERROR_FIELD, msgnumb = msg_key,
			     justification = CENTER_JUS );
                FOUND = TRUE;
		_pdm_status2 ("ex$message", status, msg_key);
                  }
                else
                  {
                  _pdm_debug("translating message for external PDU", 0);
		  _pdm_debug ("msg_key = %d", (char *)msg_key);
                  output_msg = (char *)PDUtranslate_message(msg_key);
                  _pdm_debug("message string = <%s>", output_msg);
                  if (PDU_form_id)
                    FIg_set_text(PDU_form_id, FI_MSG_FIELD, output_msg);
                  FOUND =  TRUE;
                  }
		break;
           default:
                break;
           }

	switch ( msg_key )
           {

	   /*******************************************/
	   /* operator ERROR messages, 	SLEEP 5       */
	   /**********************************************************/
           /* Please add new error messages to next switch statment. */
           /* This one has gotten too large again.  Mychelle         */
           /**********************************************************/
	   case	PDM_E_VALIDATE_ACCESS:
	   case	PDM_E_INVALID_BOM_CONT:
	   case	PDM_E_REPLACE_SAME:
	   case PDM_E_NOT_IMPLEMENTED:
	   case PDM_E_INVALID_INPUT:
           case PDM_E_NO_EXISTING_FORMAT:
	   case PDM_E_PART_NOT_FOUND:

	   case PDM_E_MRP_NOT_FOUND:
	   case PDM_E_BOM_NOT_FOUND:
	   case PDM_E_BOMMAP_NOT_FOUND:
	   case PDM_E_BOM_EMPTY:
	   case PDM_E_BOM_CONT_NOT_EMPTY:
	   case PDM_E_SYNONYMS_NOT_ADDED:
	   case PDM_E_BOM_SYNONYMS_NOT_ADDED:
	   case PDM_E_BOM_CONT_EXISTS:
	   case PDM_E_BOM_ATTACH:
	   case PDM_E_CIT_ATTACH:
	   case PDM_E_NO_PARTS_FOUND:

	   case PDM_E_BOM_CONT_UNDEFINED:
	   case PDM_E_NO_FILE_NAME:
	   case PDM_E_NO_SPACE:

	   case PDM_E_LOC_DISPLAY_NOT_FOUND:
	   case PDM_E_SORT_CRIT_NOT_FOUND:
	   case PDM_E_SEARCH_ALLCAT_NOT_FOUND:
	   case PDM_E_INVALID_PASSWD:

	   case PDM_E_SELECT_ATTR:
	   case PDM_E_FORMAT_NOT_FOUND:

	   case PDM_E_NO_PARTS_PLACED:
	   case PDM_E_SAVED_VIEW:
	   case PDM_E_DUPLICATE_ORIGIN:
	   case PDM_E_BOM_SELECT:
	   case PDM_E_CYCLIC_1STLEVEL:
	   case PDM_E_CYCLIC_NTHLEVEL:
	

	   case PDM_E_INVALID_FORMAT:
	   case PDM_E_LOCATE_FAILED:
	   case PDM_E_INVALID_ORIGIN_OBJECT:
           case PDM_E_SUB_TOBE_CHECK:
           case PDM_E_ITEM_TOBE_CHECK:
           case PDM_E_NOTCHECK_OUT:
           case PDM_E_NOTCHECK_IN:
           case PDM_E_FILE_LOCAL:
           case PDM_E_ANOTHER_USER:
           case PDM_E_INVALID_PART_TYPE:
           case PDM_E_CAN_NOT_CHECKIN_PARAMETRIC_PART:
           case PDM_E_CAN_NOT_CHECKOUT_PARAMETRIC_PART:
           case PDM_E_CAN_NOT_LOCALLY_COPY_PART:
           case PDM_E_NO_VALID_VIEWS:
           case PDM_E_CMD_CANCELLED:
           case PDM_E_CAN_NOT_ATTACH_PARAMETRIC_PART:
           case PDM_E_ENTER_Y_N:
           case PDM_E_INVALID_PART_POINTER:
           case PDM_E_ILL_CHAR:
           case PDM_E_FILE_NOT_ARCHIVED:
           case PDM_E_SET_FLAG_ARCHIVE:
           case PDM_E_SET_FLAG_BACKUP:
           case PDM_E_ITEM_FLAG_ARCHIVE:
           case PDM_E_ITEM_FLAG_BACKUP:
           case PDM_E_ITEM_FLAG_DELETE:
           case PDM_E_SET_FLAGGED:
           case PDM_E_ITEM_FLAGGED:
           case PDM_E_SET_NOT_FLAGGED:
           case PDM_E_ITEM_NOT_FLAGGED:
           case PDM_E_NOT_FLAGGED_AS_ITEM_RESTORE:
           case PDM_E_NOT_FLAGGED_AS_ITEM_DELETE:
           case PDM_E_NOT_FLAGGED_AS_ITEM_ARCHIVE:
           case PDM_E_NO_FILES_FLAGGED:

           case PDM_E_CATALOG_NOT_FOUND:
           /*case PDM_E_NOTCHECK_OUT:         APOGEE  */
           /*case PDM_E_NOTCHECK_IN:          APOGEE  */
           case PDM_E_ASSEMBLY_CHECKED_OUT:
           case PDM_E_MEMBER_CHECKED_OUT:
           case PDM_E_NO_PART_FILE:

           case PDM_E_FILE_IN_DATABASE:
           case PDM_E_ID_PART:
           case PDM_E_BAD_ATTRIBUTE:

	   case PDM_E_PROJECT_FLD_BLANK:
	   case PDM_E_NO_PROJECT:
	   case PDM_E_NO_CATALOG:


	   case PDM_E_NO_CATALOG_MAP:

	   case PDM_E_PROJECT_FLD_TOO_LONG:

	   case PDM_E_BOM_SYNONYMS_NOT_MODIFIED:
	   case PDM_E_BOMREQATTR_NOT_FOUND:
           case PDM_S_LOGIN:
           case PDM_E_LOGIN:
           case PDM_E_LOGIN_FAILURE:
           case PDM_E_EXP_ERROR:
           case PDM_E_PART_OCCURS_IN_ASSEMBLY: 
           case PDM_E_NO_PROJECTS: 
           case PDM_E_QUERY_SET_MEMBERS:
           case PDM_E_PART_NOT_ASSEMBLY:
           case PDM_E_NO_CATALOGS:
           case PDM_E_NO_CATALOGS_FOUND:

           case PDM_E_BAD_NODE:
           case PDM_E_BAD_PROTOCOL:
           case PDM_E_BAD_USER:
           case PDM_E_USER_PASSWD:
           case PDM_E_BAD_ENV:
           case PDM_E_BAD_STRG:
           case PDM_E_CLH:

           case PDM_E_SEARCH_CATALOG:
           case PDM_E_NO_CRITERIA_DEFINED:
           case PDM_E_CRT_DOESNT_EXIST:
                if (!PDU_extadmin)
                  {
		_pdm_debug ("before ex$message msg_key = %d", (char *)msg_key);
		_pdm_status2 ("ex$message", status, msg_key);
		ex$message ( field = ERROR_FIELD, msgnumb = msg_key,
			     justification = CENTER_JUS );
                FOUND =  TRUE;
		_pdm_status2 ("ex$message", status, msg_key);
                  }
                else
                  {
                  _pdm_debug("translating message for external PDU", 0);
		  _pdm_debug ("msg_key = %d", (char *)msg_key);
                  output_msg = (char *)PDUtranslate_message(msg_key);
                  _pdm_debug("message string = <%s>", output_msg);
                  if (PDU_form_id)
                    FIg_set_text(PDU_form_id, FI_MSG_FIELD, output_msg);
                  FOUND =  TRUE;
                  }
		break;
            default:
                break;
            }

	switch ( msg_key )
           {

	   /*******************************************/
	   /* operator ERROR messages, 	SLEEP 5       */
	   /*******************************************/
           case PDM_E_ATTR_LIST_EMPTY:
           case PDM_E_ERROR_RETRIEVING_SORT:
           case PDM_E_UNIQUE_USAGE:
           case PDM_E_BUFR_LINKLIST:
           case PDM_E_ATTACH_CHECKIN:
           case PDM_E_ATTACH_NONGRAPHIC:
           case PDM_E_FILE_ALREADY_EXISTS:
           case PDM_E_TOO_MANY_PARTS:
           case PDM_E_CI_FILENAME_EXISTS:
           case PDM_E_SYNTAX_ERROR:
           case PDM_E_DISMISS_HELP:
           case PDM_E_NO_USAGE_ID:
           case PDM_E_USAGE_LENGTH:
           case PDM_E_ENTER_FILENAME:
           case PDM_E_COPY_FILES:
           case PDM_E_USER_LOGGED_IN:
           case PDM_E_LOCATE_SCHEMA_FILE:
           case PDM_E_NO_PARENTS:
           case PDM_E_RETRIEVE_ASSEMBLY:
           case PDM_E_READ_PARTS:
           case PDM_E_NOT_CO_USER:
           case PDM_E_PARAMETRIC_STRUCTURE:
           case PDM_E_DELETE_FILES:
           case PDM_E_OPEN_DB:
           case PDM_E_DELETE_LIST_EMPTY:
           case PDM_E_ASSY_NOT_CHECKEDIN:
           case PDM_E_CO_SAME_USER_DIFF_SA:
           case PDM_E_TEMP_OUT:
           case PDM_E_TEMP_IN:
           case PDM_E_NOT_IN_ACL:
           case PDM_E_COPY_LIST_EMPTY:
           case PDM_E_ERROR_RETRIEVING_STATUS:
           case PDM_E_NO_PROJECTS_MAPPED:
           case PDM_E_CHECKOUT_USER:
           case PDM_E_CAT_TYPE_EMPTY:
           case PDM_E_FORM_DATA:
           case PDM_E_USER_NOT_LOGGED_IN:
           case PDM_E_REQUIRED_DATA:
           case PDM_E_INVALID_MODE:
           case PDM_E_PARAM_PART_API:
           case PDM_E_NULL_FILE_LIST:
           case PDM_E_COPY_DUP_FILENAME:
           case PDM_E_WARN_CAT_PROJ_MAP:
           case PDM_E_LOCKED_PART_IN_PROJ:
           case PDM_E_GET_ATTACH_INFO:
           case PDM_E_ENTER_LOCAL_FILENAME:
           case PDM_E_NEW_PART_INFO_INCOMPLETE:
           case PDM_E_EX_PART_INFO_INCOMPLETE:
           case PDM_E_FILES_CANNOT_BE_LOCAL:
           case PDM_E_FILE_NOT_DELETED:
           case PDM_E_COPY_OPEN_FILE:
           case PDM_E_INVALID_FORMAT_NAME:
           case PDM_E_NO_FORMAT_SELECTED:
           case PDM_E_ERROR_SEARCHING_4_PARTS:
           case PDM_E_ERROR_VERIFYING_FILENAME:
           case PDM_E_ALREADY_FLAGGED_FOR_ARCHIVE:
           case PDM_E_ALREADY_FLAGGED_FOR_RESTORE:
           case PDM_E_ALREADY_FLAGGED_FOR_BACKUP:
           case PDM_E_ALREADY_FLAGGED_FOR_DELETE:
           case PDM_E_CON_ACCESS:
           case PDM_E_CON_ACCESS1:
           case PDM_E_CON_TRY_LATER:
           case PDM_E_PART_USED_IN_AN_ASSY:
           case PDM_E_ERROR_INIT_HELP:
           case PDM_E_NO_COMMON_ATTRIB:
           case PDM_E_DIGIT_IN_NODENAME:
           case PDM_E_SEED_CANNOT_BE_ASSY:
           case PDM_E_ITEMNAME_REQUIRED:
           case PDM_E_NO_ACLS_AVAIL:
           case PDM_E_NO_ATTR_VALUES:
           case PDM_E_ITEMREV_REQUIRED:
           case PDM_E_GENERATE_PARTS_LIST:
           case PDM_E_EMPTY_SEARCH_FORMAT:
           case PDM_E_CATALOG_TYPE_P:
           case PDM_E_NFM_DAT_FILE:
           case PDM_E_RETRIEVE_NONGRAPHIC:
           case PDM_E_ENTER_NEW_PART_DATA:
           case PDM_E_CANNOT_DELETE_PARENT:
           case PDM_E_PLACE_ROW:
           case PDM_E_DISP_EXIST_ATTRS:
           case PDM_E_CHANGE_EXIST_DESC:
           case PDM_E_ASSY_NOT_MODIFIED:
           case PDM_E_PART_DATA_FOR_REVISE:
           case PDM_E_CATALOG_FOR_REVISE:
           case PDM_E_PART_FOR_REVISE:
           case PDM_E_REVISION_FOR_REVISE:
           case PDM_E_ROW_NOT_FOUND:
           case PDM_E_CHANGE_FILE_ON_PART_FORM:
           case PDM_E_FILE_FOR_CHGD_PARTS:
           case PDM_E_NEW_FILE_FOR_CHGD_PARTS:
           case PDM_E_DESIGN_FILE_NOT_FOUND:
           case PDM_E_MARKED_FOR_DELETE:
           case PDM_E_NOT_MARKED_FOR_DELETE:
           case PDM_E_ERROR_COPYING_FILES:
           case PDM_E_MLIB_READ_ONLY:
           case PDM_E_RPT_DEFN_EMPTY:
           case PDM_E_FILE_NOT_PDU:
           case PDM_I_KEY_IN_OR_SEARCH:
           case PDM_I_SELECT_FOR_REPLACE:
           case PDM_E_INVALID_STG_FILENAME:
           case PDM_E_ADD_PARAM_REV_ASSY:
           case PDM_E_CANNOT_REPLACE_PARENT:
           case PDM_E_PLACE_ROW_BEFORE_SEARCH:
           case PDM_E_NUM_FILES_EXCEEDS_LIST:
           case PDM_E_DISP_PARAM_ATTRS:
           case PDM_E_MODIFY_DUPLICATE_PART:
           case PDM_E_LIST_EXCEEDS_2000_PARTS:
           case PDM_E_INGRHOME_NOT_SET:
           case PDM_E_NFMADMIN_ACCOUNT:
           case PDM_E_RIS_PATH:
           case PDM_E_RIS_PARMS:
           case PDM_E_RISCONFIG_NOT_FOUND:
           case PDM_E_PART_IN_LIST:
                if (!PDU_extadmin)
                  {
		_pdm_debug ("before ex$message msg_key = %d", (char *)msg_key);
		_pdm_status2 ("ex$message", status, msg_key);
		ex$message ( field = ERROR_FIELD, msgnumb = msg_key,
			     justification = CENTER_JUS );
                FOUND =  TRUE;
		_pdm_status2 ("ex$message", status, msg_key);
                  }
                else
                  {
                  _pdm_debug("translating message for external PDU", 0);
		  _pdm_debug ("msg_key = %d", (char *)msg_key);
                  output_msg = (char *)PDUtranslate_message(msg_key);
                  _pdm_debug("message string = <%s>", output_msg);
                  if (PDU_form_id)
                    FIg_set_text(PDU_form_id, FI_MSG_FIELD, output_msg);
                  FOUND =  TRUE;
                  }
		break;
            default:
                break;
           }

	switch ( msg_key )
           {

	   /*******************************************/
	   /* operator ERROR messages, 	SLEEP 5       */
	   /*******************************************/
           case PDM_E_CANNOT_ADD_FILES:
           case PDM_E_CANNOT_DELETE_FILES:
           case PDM_E_CANNOT_CHANGE_FILES:
           case PDM_E_NO_DATA_IN_FILE_LIST: 
           case PDM_E_DESC_FIELD_BLANK:
           case PDM_E_ENTER_PARTTYPE:
           case PDM_E_FILEDESC_BLANK:
           case PDM_E_INVALID_CHAR_IN_FILENAME:
           case PDM_E_FILETYPE_TOO_LONG:
           case PDM_E_INVALID_FILETYPE:
           case PDM_E_ACL_NAME_BLANK:
           case PDM_E_STG_NAME_BLANK:
           case PDM_E_FILE_NOT_FOUND_IN_BUFFER:
           case PDM_E_DUPLICATE_FILENAME:
           case PDM_E_INVALID_PARTTYPE:
           case PDM_E_ADD_FILES_NG_PART:
           case PDM_E_NOT_UPDATABLE:
           case PDM_E_NO_PART_FILES:
           case PDM_E_NOT_FLAGGED:
           case PDM_E_NOT_DELETED:
           case PDM_E_MIN_1_CHAR:
           case PDM_E_MAX_240_CHARS:
           case PDM_E_DECIMAL_CHAR:
           case PDM_E_TIMESTAMP_CHAR:
           case PDM_E_INTEGER_CHAR:
           case PDM_E_REAL_CHAR:
           case PDM_E_SMALLINT_CHAR:
           case PDM_E_NOT_TRANSITIONED:
           case PDM_E_LOAD_FILE_INFO:
           case PDM_I_FILE_DEFASSEM_STRUCT:
           case PDM_I_ENTER_CAT_PRT_REV:
           case PDM_E_ASSEM_NOT_SAVED:
           case PDM_E_DEL_FIRST:
           case PDM_E_MOD_NONGRAPH:
           case PDM_E_SYNONYM_EXISTS:
           case PDM_E_DEFAULT_40_CHAR:
           case PDM_I_PARAM_PARTTYPE:
           case PDM_I_STAND_PARTTYPE:
           case PDM_I_ATTR_REQ:
           case PDM_E_FUNCTION_NAME:
           case PDM_E_FUNCTION_EXISTS:
           case PDM_E_MIN_MAX:
           case PDM_E_INVALID_DEFAULT:
           case PDM_E_INVALID_MIN_VALUE:
           case PDM_E_SELECT_STATE:
           case PDM_E_MAX_MIN:
           case PDM_E_INVALID_MAX_VALUE:
           case PDM_I_ORDER_EXCEEDS_ATTR:
           case PDM_I_MAX_600_VALUES:
           case PDM_E_ATTR_MODE:
           case PDM_E_ADD_ATTR:
           case PDM_E_ADD_ATTR_LIST:
           case PDM_E_DEFAULT_VALUE:
           case PDM_I_SELECT_ATTR_LIST:
           case PDM_E_ERASE_LIST:
           case PDM_E_DISPLAY_LIST:
           case PDM_E_DISPLAY_RANGE:
           case PDM_E_ERASE_RANGE:
           case PDM_E_DEFAULT_LESS_MIN:
           case PDM_E_DEFAULT_GREAT_MAX:
           case PDM_E_CAT_NAME_FORM:
           case PDM_I_BLANK_CAT_NAME:
           case PDM_E_CAT_RESERVED:
           case PDM_E_CAT_NAME_DIGITS:
           case PDM_E_DESCRIPTION_FORM:
           case PDM_E_NO_CLASSIFICATION_LEVEL:
           case PDM_E_TEMPLATE_CAT_VIEW:
           case PDM_E_SEEDFILES_NOT_DELETED:
           case PDM_E_CAT_WITH_PART_NOT_DEL:
           case PDM_E_CLASS_MODIFIED:
           case PDM_E_TEMPLATE_NOT_PARAM:
           case PDM_E_LIBRARY_FORM:
           case PDM_I_SEL_LIBRARY:
           case PDM_I_SEL_LIBRARY_DEL:
           case PDM_E_CAT_NO_PARTS:
           case PDM_I_ENTER_MACRO_NAME:
           case PDM_E_MACRO_LIB_LOCAL:
           case PDM_E_CHANGE_STATIC_ATTR:
           case PDM_E_CHANGE_DYN_REP_ATTR:
           case PDM_E_FILENAME_FORM:
           case PDM_E_PARAMETERS_DB:
           case PDM_E_PARTTYPE_M:
           case PDM_E_ATTR_VALUE_GEN_FUNC:
           case PDM_I_SEL_LEVEL1_CLASS:
           case PDM_E_RETRIEVE_CLASS:
           case PDM_E_PROCCESS_CLASS_LEVELS:
           case PDM_E_PROJECT_FORM:
           case PDM_E_PROCCESS_DATA:
           case PDM_E_LOADING_DATA:
           case PDM_E_CHANGE_UNSUCCESSFUL:
           case PDM_E_RETRIEVE_DEFAULT_DATA:
           case PDM_I_SEL_ROW_TO_COPY:
           case PDM_I_SEL_ROW_TO_CLEAR:
           case PDM_E_CAT_NOT_PARAMETRIC:
           case PDM_E_SEL_MULT_CATALOGS:
           case PDM_I_PARTS_USED_IN_ASSEM:
           case PDM_E_MOVE_STATE_FAILED:
           case PDM_I_SEL_ORIGIN:
           case PDM_I_SEL_CAT_PLACE_PART:
           case PDM_I_SEL_PART_PLACE_PART:
           case PDM_I_SEL_REVISION_PLACE_PART:
           case PDM_E_PLACE_NON_GRAPHIC:
           case PDM_E_READ_ONLY:
           case PDM_E_VIEW_NAME_FORM:
           case PDM_E_VIEW_NAME_BUFFER:
           case PDM_E_INVALID_VIEW_NAME:
           case PDM_E_INVALID_QUANTITY:
           case PDM_E_ALT_TAG_NOT_UNIQUE:
           case PDM_E_NO_QUANTITY:
           case PDM_E_LIST_FUNC_NOT_EXISTS:
           case PDM_E_NO_WRITE_LOCAL_FILE:
           case PDM_E_SPEC_CHAR_IN_FIELD:
           case PDM_E_ATTR_IN_SORT_LIST:
           case PDM_E_ENTER_SORT_NAME:
           case PDM_E_PARTNUM_LENGTH:
           case PDM_E_REV_LENGTH:
           case PDM_E_DESC_LENGTH:
           case PDM_E_FILE_NOT_GRAPHIC:
           case PDM_E_EXNUC_PATH:
           case PDM_E_COPY_OBJECT_SPACE:
           case PDM_E_FILE_NOT_CREATED:
           case PDM_E_RET_PARTTYPE_DESC:
           case PDM_E_DSP_PARTTYPE_DESC:
           case PDM_I_NEW_FILE_NOT_CREATED:
           case PDM_I_ADD_FILE_NO_COPY:
           case PDM_E_ATTRS_ALREADY_LISTED:
           case PDM_E_EXT_PARTTYPE:
           case PDM_E_DELETE_FILES_FOR_NG:
           case PDM_E_MACRO_PARTTYPE:
           case PDM_E_CANCEL_FLAG_BEFORE_MOD:
           case PDM_E_PART_ASSOC_WITH_PROJECT:
           case PDM_E_CATALOG_TYPE_EID:
           case PDM_E_SELECT_FILE:
           case PDM_I_SELECT_ROWS_TO_DELETE:
           case PDM_E_LOCAL_FILE_NOT_UNIQUE:
           case PDM_E_ENTER_VALUE_LIST:
           case PDM_E_RET_LIST_FILENAMES:
           case PDM_E_ENTER_VALUE_IN_RANGE:
           case PDM_E_END_OF_DATA:
           case PDM_E_NO_MACRO_VIEW:
           case PDM_I_PRT_SEL_NOT_COMPLETE:
           case PDM_E_SEL_PROJECT:
           case PDM_E_CANNOT_BLANK_OUT_FN:
           case PDM_E_TOO_MANY_CATALOGS:
           case PDM_E_ONE_CATALOG_IN_LEVEL:
           case PDM_E_MACRO_TEMP_NO_BLANKS:
           case PDM_E_ERROR_BOM_ATTR:
           case PDM_E_ERROR_RET_CAT_ATTR:
           case PDM_E_PROCESS_CAT_ATTRS:
           case PDM_E_NO_CAT_ATTRS:
           case PDM_E_INVALID_CAT_ATTR:
           case PDM_E_SELECT_BOM_ATTR:
           case PDM_E_SELECT_CAT_ATTR:
           case PDM_E_SAME_ATTR_DATATYPE:
           case PDM_E_ERROR_MAP_ATTR:
           case PDM_E_BOM_ATTR_MAPPED:
           case PDM_E_ENTER_ATTR_NAME:
           case PDM_E_ENTER_ATTR_DATATYPE:
           case PDM_E_INVALID_SYNONYM:
           case PDM_E_GET_REPORT_NAME:
           case PDM_E_REPORT_TYPE_NOT_EXIST:
           case PDM_E_OUTPUT_FILE:
           case PDM_E_ATTR_PLACE_TOO_LONG:
           case PDM_E_REPLACE_LEVEL_ATTR:
           case PDM_E_REPORT_WIDTH_500:
                if (!PDU_extadmin)
                  {
		_pdm_debug ("before ex$message msg_key = %d", (char *)msg_key);
		_pdm_status2 ("ex$message", status, msg_key);
		ex$message ( field = ERROR_FIELD, msgnumb = msg_key,
			     justification = CENTER_JUS );
                FOUND =  TRUE;
		_pdm_status2 ("ex$message", status, msg_key);
                  }
                else
                  {
                  _pdm_debug("translating message for external PDU", 0);
		  _pdm_debug ("msg_key = %d", (char *)msg_key);
                  output_msg = (char *)PDUtranslate_message(msg_key);
                  _pdm_debug("message string = <%s>", output_msg);
                  if (PDU_form_id)
                    FIg_set_text(PDU_form_id, FI_MSG_FIELD, output_msg);
                  FOUND =  TRUE;
                  }
		break;
            default:
                break;
           }

	switch ( msg_key )
           {

	   /*******************************************/
	   /* operator INFORMATION messages, NO SLEEP */
	   /*******************************************/
	   case PDM_S_SUCCESS:
	   case PDM_I_TREE_ATTACH_OFF: 
	   case PDM_I_TREE_ATTACH_ON:
	   case PDM_I_ATOMIC_PART:
	   case PDM_I_FORMAT_NOT_FOUND:
	   case PDM_I_BOMATTR_NOT_FOUND:
	   case PDM_I_SYNONYMS_NOT_ADDED:
	   case PDM_I_ORIGIN_NOT_FOUND:
	   case PDM_I_GRAPHICS_NOT_FOUND:
	   case PDM_I_ATTACHING_PART:
	   case PDM_I_WORKING:
	   case PDM_I_SENDING:
	   case PDM_I_COMPLETE:
	   case PDM_I_FORM_CANCEL:
	   case PDM_I_TRANSFER_PARAM_FORM:
	   case PDM_I_SEL_SORT_BEFORE_SEARCH:
	   case PDM_I_ATTACHED_TO_LOCAL_ASSY:
	   case PDM_I_SELECT_LIST_DEFN:
	   case PDM_I_SELECT_ROW_FOR_PART:
	   case PDS_M_GET_ASSEMBLY:
           case PDS_M_DEFINE_ASSEMBLY:
           case PDS_M_GET_TABLE_ATTR:
           case PDS_M_GET_TABLE_DATA:
           case PDS_M_QUERY_TABLE_DEFINITION:
           case PDS_M_FAST_TABLE_DEFINITION:
           case PDS_M_GEN_SUMMARY_BOM:
           case PDS_M_CANCEL_CHECKOUT_PART:
           case PDS_M_CREATE_CATALOG:
           case PDS_M_MODIFY_CATALOG:
           case PDS_M_DELETE_CATALOG:
           case PDS_M_VALID_ACLS:
           case PDS_M_CHECKIN_PART:
           case PDS_M_CHECKOUT_PART:
           case PDS_M_COPY_ATTACH:
           case PDS_M_DEBUG_ON_OFF:
           case PDS_M_DETACH_PART:
           case PDS_M_FLAG_ARCHIVE:
           case PDS_M_FLAG_BACKUP:
           case PDS_M_FLAG_DELETE:
           case PDS_M_FLAG_RESTORE:
           case PDS_M_UNFLAG_ARCHIVE:
           case PDS_M_UNFLAG_BACKUP:
           case PDS_M_UNFLAG_DELETE:
           case PDS_M_UNFLAG_RESTORE:
           case PDS_M_LIST_LOCAL_FILES:
           case PDS_M_LIST_CHKOUT_FILES:
           case PDS_M_CHKIN_FILES_OF_USER:
           case PDS_M_DELETE_LOCAL_FILES:
           case PDS_M_GET_STATE:
           case PDS_M_GET_FILENAMES:
           case PDS_M_COPY_FILE:
           case PDS_M_VERIFY_INIT:
           case PDS_M_ADD_PART:
           case PDS_M_DELETE_PART:
           case PDS_M_CHECK_DELETE_PART:
           case PDS_M_MODIFY_PART:
           case PDS_M_CANCEL_MODIFY_PART:
           case PDS_M_ADD_PART_TO_PROJECT:
           case PDS_M_QUERY_PART_STATUS:
           case PDS_M_GET_CHILDREN:
           case PDS_M_SHOW_SAVED_VIEWS:
           case PDS_M_READ_CRITERIA:
           case PDS_M_ADD_CRITERIA:
           case PDS_M_SHOW_BOMS:
           case PDS_M_SEARCH_ACROSS_CATS:
           case PDS_M_SEARCH_PARTS_IN_CATALOG:
           case PDS_M_SEARCH_PARTS_IN_PROJECT:
           case PDS_M_SEARCH_PARTS_IN_PROJECT2:
           case PDS_M_LIST_OF_PARTS:
           case PDS_M_VERIFY_PROJECT:
           case PDS_M_VERIFY_CATALOG:
           case PDS_M_CHECK_PARTNUM:
           case PDS_M_VERIFY_PARTNUM:
           case PDS_M_PART_IN_PROJ:
           case PDS_M_PART_FROM_DESC:
           case PDS_M_CATALOG_LIST:
           case PDS_M_PROJ_OF_CAT_LIST:
           case PDS_M_SHOW_PARTS:
           case PDS_M_GET_REVS:
           case PDS_M_GET_DESC:
           case PDS_M_PARTS_IN_CATALOG:
           case PDS_M_SHOW_CATALOGS:
           case PDS_M_VERIFY_PART:
           case PDS_M_GET_DYNAMIC_ATTR:
           case PDS_M_QUERY_TABLE:
           case PDS_M_SHOW_PROJECTS:
           case PDS_M_FIND_BOMNAME:
           case PDS_M_CHECK_ITEM:
           case PDS_M_GENERATE_FILENAME:
           case PDS_M_QUERY_DISTINCT_TABLE:
           case PDS_M_USER_LOGIN:
           case PDS_M_RECONNECT:
           case PDS_M_VALID_CRITERIA:
           case PDS_M_UPDATE_BOM:
           case PDS_M_ADDING_ATTRIBUTE:
           case PDS_M_CHANGING_ATTRIBUTE:
           case PDS_M_CIT_CHILDREN:
           case PDS_M_CIT_PARENTS:
           case PDS_M_EXPAND_PARTS:
           case PDS_M_CHECK_PART_STATUS:
           case PDS_M_PROCESS_FILE:
           case PDS_M_DELETE_FILES:
           case PDS_M_GET_TRANS:
           case PDS_M_MAKE_TRANSITION:
           case PDS_M_FUNCTION_FILES:
           case PDS_M_GET_UNION_ATTR:
           case PDS_M_GET_LIST_ATTR:
           case PDS_M_LIST_REPORTS:
           case PDS_M_GET_STG_FILENAME:
           case PDS_M_LOADING_PARTS:
           case PDS_M_GET_PART_DESC:
                if (!PDU_extadmin)
                  {
                FOUND = TRUE;
		ex$message ( field = ERROR_FIELD, msgnumb = msg_key,
			     justification = CENTER_JUS );
		_pdm_status2 ("ex$message", status, msg_key);
                  }
                else
                  {
                  _pdm_debug("translating message for external PDU", 0);
		  _pdm_debug ("msg_key = %d", (char *)msg_key);
                  output_msg = (char *)PDUtranslate_message(msg_key);
                  _pdm_debug("message string = <%s>", output_msg);
                  if (PDU_form_id)
                    FIg_set_text(PDU_form_id, FI_MSG_FIELD, output_msg);
                  FOUND =  TRUE;
                  }
                break;
           default:
                break;
           }

	switch ( msg_key )
           {

	   /*******************************************/
	   /* operator ERROR messages, NO SLEEP       */
	   /*******************************************/
	   case PDM_E_FAILURE:
	   case PDM_E_INITIALIZED:

	   case PDM_E_CAT_NULL:
	   case PDM_E_PART_NULL:
	   case PDM_E_REV_NULL:
	   case PDM_E_VIEW_NULL:
	   case PDM_E_FILE_NULL:

	   case PDM_E_PARTID_NOT_FOUND:
	   case PDM_E_PARTREV_NOT_FOUND:
	   case PDM_E_USERNAME_NOT_FOUND:
	   case PDM_E_CATNAME_NOT_FOUND:
	   case PDM_E_ATTR_NOT_FOUND:
	   case PDM_E_DATATYPE:
	   case PDM_E_MISSING_VALUES:
	   case PDM_E_NOT_ACTIVE:
	   case PDM_E_LOCSORT_NULL:
	   case PDM_E_LOCSEARCH_NULL:
	   case GR_E_NoRefFl:
                if (!PDU_extadmin)
                  {
                FOUND = TRUE;
		ex$message ( field = ERROR_FIELD, msgnumb = msg_key,
			     justification = CENTER_JUS );
		_pdm_status2 ("ex$message", status, msg_key);
                  }
                else
                  {
                  _pdm_debug("translating message for external PDU", 0);
		  _pdm_debug ("msg_key = %d", (char *)msg_key);
                  output_msg = (char *)PDUtranslate_message(msg_key);
                  _pdm_debug("message string = <%s>", output_msg);
                  if (PDU_form_id)
                    FIg_set_text(PDU_form_id, FI_MSG_FIELD, output_msg);
                  FOUND =  TRUE;
                  }
		break;

           default:
             break;
           }


	switch ( msg_key )
           {

	   /***************************************************/
	   /* operator INFORMATION messages with VARIABLES, SLEEP 5 */
	   /***************************************************/
	   case PDM_I_PART_CHECKIN:

	   /***************************************************/
	   /* operator ERROR messages with VARIABLES, SLEEP 5 */
	   /***************************************************/
	   case PDM_E_FILE_ARCHIVED:
	   case PDM_E_FILE_NOT_FOUND:
	   case PDM_E_CAT_NOT_FOUND:
	   case PDM_E_VIEW_NOT_FOUND:
	   case PDM_E_PART_CHECKEDIN:
	   case PDM_E_PART_NOT_CHECKEDIN:
	   case PDM_E_PART_NONGRAPHIC:
	   case PDM_E_PART_EXISTS:
           case PDM_E_PART_CHECKED_OUT:
	   case PDM_E_ASSEMBLY_NOT_FOUND:
           case PDM_E_REQ_ATTR_VALUE:
           case PDM_I_SEARCHING_CATALOG:
           case PDM_I_NO_PARTS_IN_CATALOG:
           case PDM_I_NUM_ROWS_IN_CATALOG:
           case PDM_E_FILE_NOT_EXIST:
           case PDM_E_PART_NOT_EXIST_ADDING:
		/* get output variable */
		PDUget_var( msg_key, output_string );
		_pdm_debug("output variable = %s", output_string);

                if (!PDU_extadmin)
                  {
                FOUND = TRUE;
		ex$message ( field = ERROR_FIELD, msgnumb = msg_key,
			     justification = CENTER_JUS,
			     type = "%s", var = ` output_string ` );
		_pdm_status2 ("ex$message", status, msg_key);
                  }
                else
                  {
                  _pdm_debug("translating message for external PDU", 0);
		  _pdm_debug ("msg_key = %d", (char *)msg_key);
                  output_msg = (char *)PDUtranslate_message_and_vars(msg_key,
                                                                 output_string);
                  _pdm_debug("message string = <%s>", output_msg);
                  if (PDU_form_id)
                    FIg_set_text(PDU_form_id, FI_MSG_FIELD, output_msg);
                  FOUND =  TRUE;
                  }
		break;
           default:

                break;
           }

	switch ( msg_key )
           {

	   /**********************************************************/
	   /* operator INFORMATION messages with VARIABLES, NO SLEEP */
	   /**********************************************************/
	   case PDM_S_LOGIN:
	   case PDM_I_PART_LOCATED:
	   /****************************************************/
	   /* operator ERROR messages with VARIABLES, NO SLEEP */
	   /****************************************************/
	   case PDM_E_CLEAR_FIELD:
	   case PDM_E_FILE_NOT_LOCAL:
           case PDM_E_FILE_COPIED_LOCAL:
		/* get output variable */
		PDUget_var( msg_key, output_string );
		_pdm_debug("output variable = %s", output_string);

                if (!PDU_extadmin)
                  {
                FOUND = TRUE;
		ex$message ( field = ERROR_FIELD, msgnumb = msg_key,
			     justification = CENTER_JUS,
			     type = "%s", var = ` output_string ` );
		_pdm_status2 ("ex$message", status, msg_key);
                  }
                else
                  {
                  _pdm_debug("translating message for external PDU", 0);
		  _pdm_debug ("msg_key = %d", (char *)msg_key);
                  output_msg = (char *)PDUtranslate_message_and_vars(msg_key,
                                                                 output_string);
                  _pdm_debug("message string = <%s>", output_msg);
                  if (PDU_form_id)
                    FIg_set_text(PDU_form_id, FI_MSG_FIELD, output_msg);
                  FOUND =  TRUE;
                  }
		break;
/*
	   case PDM_E_LOGIN:
                FOUND = TRUE;
		ex$message ( buff = status_msg, msgnumb = msg_key );
		_pdm_status2 ("ex$message", status, msg_key);

		_pdm_debug("status message = %s", status_msg);
		_pdm_debug("before the UI_error message",0);
		UI_error (status_msg);
		_pdm_debug("before the UI_error message",0);
		break;
*/
           default:
                break;
           }

	   /*******************************************/
	   /* internal error messages */
	   /*******************************************/
	   if (!FOUND) 
             {
                if (!PDU_extadmin)
                  {
		ex$message ( buff = output_string, msgnumb = msg_key );
		_pdm_status2 ("ex$message", status, msg_key);

		ex$message ( field = ERROR_FIELD,
			     msgnumb = PDM_E_INTERNAL_ERROR,
			     justification = CENTER_JUS,
			     type = "%s", var = ` output_string ` );
		_pdm_status2 ("ex$message", status, PDM_E_INTERNAL_ERROR);
		sprintf(status_msg,"%s %s","PDM error:",output_string);
                  }
                else
                  {
                  _pdm_debug("translating message for external PDU", 0);
                  output_msg1 = (char *)PDUtranslate_message(msg_key);
		  _pdm_debug ("msg_key = %d", (char *)msg_key);

                  msg_key = PDM_E_INTERNAL_ERROR;
                  output_msg = (char *)PDUtranslate_message_and_vars(msg_key,
                                                                 output_string);
                  _pdm_debug("message string = <%s>", output_msg);
                  if (PDU_form_id)
                    FIg_set_text(PDU_form_id, FI_MSG_FIELD, output_msg);
                  FOUND =  TRUE;
		  sprintf(status_msg,"%s %s","PDM error:",output_msg);
                  }

		_pdm_debug("status message = %s", status_msg);
		break;
	   }

	break;
     }

  return ( PDM_S_SUCCESS );
  }

IGRint	PDUget_var (msg_key, output_variable)
  IGRint	msg_key;
  IGRchar	*output_variable;
  {
  switch ( msg_key )
     {
     case PDM_S_LOGIN:
		strcpy(output_variable, user->username);
		break;
     case PDM_E_FILE_NOT_LOCAL:
                if (PDU_save_filename == NULL)
                  PDUfill_in_string(&PDU_save_filename, "");
		strcpy(output_variable, PDU_save_filename);
		break;
     case PDM_E_FILE_COPIED_LOCAL:
                if (PDU_save_filename == NULL)
                  PDUfill_in_string(&PDU_save_filename, "");
		strcpy(output_variable, PDU_save_filename);
		break;
     case PDM_E_FILE_ARCHIVED:
                if ((refresh->rev_filename) && (strcmp(refresh->rev_filename, 
                     "") != 0))
		  strcpy(output_variable, refresh->rev_filename);
		break;
     case PDM_E_ASSEMBLY_NOT_FOUND:
                if ((refresh->rev_filename) && (strcmp(refresh->rev_filename, 
                     "") != 0))
		strcpy(output_variable, refresh->rev_filename);
		break;
     case PDM_E_FILE_NOT_FOUND:
                if ((refresh->rev_filename) && (strcmp(refresh->rev_filename, 
                     "") != 0))
	  	strcpy(output_variable, refresh->rev_filename);
		break;
     case PDM_E_CAT_NOT_FOUND:
		strcpy(output_variable, refresh->rev_catalog);
		break;
     case PDM_E_PART_NOT_FOUND:
		strcpy(output_variable, refresh->rev_partid);
		break;
     case PDM_E_VIEW_NOT_FOUND:
		strcpy(output_variable, refresh->view);
		break;
     case PDM_E_PART_CHECKEDIN:
		strcpy(output_variable, refresh->rev_partid);
		break;
     case PDM_E_PART_NOT_CHECKEDIN:
		strcpy(output_variable, refresh->rev_partid);
		break;
     case PDM_E_PART_NONGRAPHIC:
		strcpy(output_variable, refresh->rev_partid);
		break;
     case PDM_E_PART_EXISTS:
		strcpy(output_variable, NULLSTR);
		break;
     case PDM_I_PART_LOCATED:
		sprintf(output_variable, "%s, %s",
			refresh->rev_partid, refresh->rev_revision);
		break;
     case PDM_E_CLEAR_FIELD:
		strcpy(output_variable, NULLSTR);
		break;
     case PDM_E_REQ_ATTR_VALUE:
                strcpy(output_variable, PDU_attr_name);
                break;
     case PDM_I_NUM_ROWS_IN_CATALOG:
                if (!PDU_srch_catalog)
                  PDUfill_in_string(&PDU_srch_catalog, "");
                strcpy(output_variable, PDU_srch_catalog);
                break;
     case PDM_I_NO_PARTS_IN_CATALOG:
                if (!PDU_srch_catalog)
                  PDUfill_in_string(&PDU_srch_catalog, "");
                strcpy(output_variable, PDU_srch_catalog);
                break;
     case PDM_I_SEARCHING_CATALOG:
                if (!PDU_srch_catalog)
                  PDUfill_in_string(&PDU_srch_catalog, "");
                strcpy(output_variable, PDU_srch_catalog);
                break;
     case PDM_E_FILE_NOT_EXIST:
                if ((PDU_save_filename) && (strcmp(PDU_save_filename, "") != 0))
	  	  strcpy(output_variable, PDU_save_filename);
		break;
     case PDM_E_PART_NOT_EXIST_ADDING:
                if ((PDU_save_partid) && (strcmp(PDU_save_partid, "") != 0))
	  	  strcpy(output_variable, PDU_save_partid);
		break;
     default:
		strcpy(output_variable, NULLSTR);
		break;
     }

  return ( PDM_S_SUCCESS );
  }
