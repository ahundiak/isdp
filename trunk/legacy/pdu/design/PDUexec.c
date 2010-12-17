#include        <igrtypedef.h>
#include        <PDUintdef.h>
#include        <PDUcommand.h>
#include        <PDUstr.h>
#include        <PDUuser.h>
#include        <PDUforms.h>
#include        <PDUfile_def.h>
#include        <PDUproto.h>
#include        <PDMtimestamp.h>


extern struct 	PDUrefresh        *refresh;
extern struct   PDUuser           *user;
extern struct   PDUforms          forms;
extern Form     PDU_form_id;
extern int PDU_command;
extern char  *PDU_save;
extern int    PDU_login;
extern int    PDU_local_files_displayed;
extern int    PDU_checkout_type;
extern short  PDU_active_part;

/*****************************************************************
 **                                                             **
 **     This function invokes other PDU functions to perform    **
 **  actions that require access to objects and structures      **
 **  internal to EMS.                                           **
 **                                                             **
 **  History:   created  08/17/87 - Bill Kirk                   **
 **  	    :   modified 02/08/88 - Bill Kirk                   **
 **                                                             **
 *****************************************************************/

int  PDUinternal ()
  {
  IGRlong       status = PDM_S_SUCCESS;
  IGRint        command;

  command = refresh->command;

  switch ( command )
     {
    case PDC_M_ALIGN_PART:
     	break;
     	
     case PDC_M_CREATE_GRAPHICS:
     	break;
     	
     case PDC_M_DEFAULT_ORIGIN:
        break;

     case PDC_M_ACTIVATE_PART:
        status = PDUactivate ();
        _pdm_status("PDUactivate", status);
        break;

     case PDC_M_DEACTIVATE_PART:
     case PDC_M_EXIT_DESIGN:
        status = PDUdeactivate();
        _pdm_status("PDUdeactivate", status);
        break;

     case  PDC_M_LOGOUT:
          status = PDM_S_SUCCESS;

        break;

      case  PDC_M_CONVERT_OS:
        /* deactivate part if active part defined */
        status = PDUverify_part ( 'a' );
        _pdm_status ("PDUverify_part (active)", status);
        if ( 1&status )
           {
            _pdm_debug("check if conversion is necessary",0);
            status = PDUconvert_dir_to_exp();
            _pdm_status("PDUconvert_dir_to_exp",status);
           }
        break;

     case PDC_M_TOGGLE_POINTERS:
        break;

     case PDC_M_TOGGLE_TREE:
        status = PDUtree_toggle ();
        _pdm_status("PDUtree_toggle", status);
        break;

     case PDC_M_TOGGLE_NFS:
        status = PDUnfs_toggle ();
        _pdm_status("PDUnfs_toggle", status);
        break;

     case PDC_M_DELETE_PART: 
	/* for future use */
/*
        status = PDUmgr_delete ();
        _pdm_status("PDUmgr_delete", status);
*/
        status = PDM_E_NOT_IMPLEMENTED;
        break;

     case PDC_M_PLACE_PART:
     case PDC_M_PLACE_VIEW:
     case PDC_M_REPLACE_PART:
     case PDC_M_COPY_PART:
     case PDC_M_DELETE_ORIGIN:
     case PDC_M_DEFINE_ORIGIN:
     case PDC_M_ATTACH_PART:
     case PDC_M_DETACH_PART:
        break;

     case PDC_M_DEBUG_ON:
	status = PDUset_debug (NULL, ON);
	_pdm_status ("PDUset_debug(ON)", status);
        break;

     case PDC_M_DEBUG_OFF:
	status = PDUset_debug (NULL, OFF);
	_pdm_status ("PDUset_debug(OFF)", status);
        break;

     case PDC_M_READ_REFRESH:
	status = PDUread_refresh ();
	_pdm_status ("PDUread_refresh", status);
        break;

     case PDC_M_WRITE_REFRESH:
	status = PDUwrite_refresh ();
	_pdm_status ("PDUwrite_refresh", status);
        break;

     default:
	/* block status message display */
        status = NULL;
        break;
     }

  return (status);
  }

/**************************************************************************
 **                                                                      **
 **     This function invokes various PDU functions to perform actions   **
 **  that are non-graphic in nature, and require no access to objects    **
 **  internal to EMS. Initially, the functions will be linked as part    **
 **  of the EMS image and invoked directly. Eventually, the functions    **
 **  will be linked into a seperate image which is invoked as a seperate **
 **  process.                                                            **
 **                                                                      **
 **  History:   created 08/17/87 - Bill Kirk                             **
 **  	    :   modified 02/08/88 - Bill Kirk                   	 **
 **                                                                      **
 **************************************************************************/

int  PDUexternal()
  {
  IGRlong       status = PDM_S_SUCCESS;
  IGRint        command;
/*
  IGRlong       checkin_enter;
  IGRlong       checkin_exit;
  IGRdouble     checkin_enter2;
  IGRdouble     checkin_exit2;
  IGRchar       s[300];
*/
  IGRlong       call_time();
  IGRdouble     system_time();
  extern short PDU_design_form_display;
  IGRchar *msg;
  extern int PDMtime_value;
  extern int PDMtime_enabled;


  command = refresh->command;

  _pdm_debug("In PDUexternal", 0);
  _pdm_debug("PDMtime_enabled  = %d", PDMtime_enabled);
  PDMtime_command_start();
  msg = (char *)PDUtranslate_message(command);
  PDMtime_data(("Command   - %s\n", msg));
  PDMtime_data(("User Start Time - %d\n", PDMtime_value));
  switch ( command )
     {
     case PDC_M_ADD_PART_PROJ:
        status = PDUadd_part_to_project ();
	_pdm_status("PDUadd_part_to_project", status);
        break;

     case PDC_M_UNFLAG_ARCHIVE:
     case PDC_M_UNFLAG_DELETE:
     case PDC_M_UNFLAG_RESTORE:
     case PDC_M_UNFLAG_BACKUP:
        status = PDUflag_part ( command );
	_pdm_status("PDUflag_part", status);
        break;

     case PDC_M_BOM_PARTS_LIST:
     case PDC_M_BOM_SUMMARY_BOM:
     case PDC_M_BOM_WHERE_HIGH_LEV:
     case PDC_M_BOM_WHERE_USED_ASSEM:
        status = PDUdisplay_report ();
	_pdm_status("PDUdisplay_report", status);
        break;

     case PDC_M_DELETE_BOMPRINT_FORMAT:
     case PDC_M_DEL_BOM_PARTS_LIST_PR_FORM:
     case PDC_M_DEL_BOM_SUM_PR_FORM:
     case PDC_M_DEL_BOM_WHERE_BOM_PR_FORM:
     case PDC_M_DEL_BOM_WHERE_USED_PR_FORM:
        status = PDUdelete_report();
	_pdm_status("PDUdelete_report", status);
        break;

     case PDC_M_DISPLAY_FILES:
        status = PDUlist_files( command );
        _pdm_status("PDUlist_files", status);
        break;

     case PDC_M_DISPLAY_BOMS:
          break;

     case PDC_M_DELETE_BOM:
        status = PDUdelete_boms();
        _pdm_status("PDUdelete_bom", status);
        break;

     case PDC_M_DELETE_BOM_FORMAT:
     case PDC_M_DELETE_LOC_DISP_FORMAT:
     case PDC_M_DELETE_CATLIST_FORMAT:
        status = PDUdelete_report();
        _pdm_status("PDUdelete_report", status);
        break;

     case PDC_M_MODIFY_USER_PASSWORD:
        break;

/*
     case PDC_M_CREATE_NONGRAPHIC_ASS:
        status = PDUcreate_non_graphic_assembly();
        _pdm_status("PDUcreate_non_graphic_assembly", status);
        break;
*/

     case PDC_M_SORT_CRIT_ON_OFF:
        status = PDUsort_criteria_on_off();
        _pdm_status("PDUsort_criteria_on_off", status);
        break;
        
     case PDC_M_SEARCH_ACROSS_CATS:
        break;
            
     case PDC_M_DEFINE_SEARCH:
     case PDC_M_DEF_LOC_SEARCH_CRIT:
        break;
        
     case PDC_M_DEFINE_BOMPRINT:
     case PDC_M_DEFINE_BOM_PARTS_FORM:
     case PDC_M_DEF_BOM_WHERE_USED_PFORM:
     case PDC_M_DEF_BOM_WHERE_BOM_PFORM:
     case PDC_M_DEFINE_BOMSUM:
     case PDC_M_DEFINE_LOC_DISPLAY:
        status = PDUdefine_report_format();
        _pdm_status("PDUdefine_report_format", status);
        break;
        
     case PDC_M_CREATE_GRAPHICS:
     	status = PDUext_get_children();
     	_pdm_status("PDUext_get_children", status);
     	break;
     	
     case PDC_M_USER_APPROVED:
        break;

     case PDC_M_LOGIN_USER:
        status = PDUlogin_form();
	_pdm_status("PDUlogin_form", status);

        break;

     case PDC_M_LOGOUT:
	status = PDUlogout ();
        _pdm_status("PDUext_logout", status);

        /* reset global structure */
        user->username = NULL;
        PDUuser_init();
        refresh_init();
        PDUpart_init();

        PDU_login = FALSE;

       break;

     case PDC_M_DEBUG_ON:
	/* turn debug ON at server */
	status = PDUdebug_on ();
	_pdm_status ("PDUdebug_on", status);
        break;

     case PDC_M_DEBUG_OFF:
	/* turn debug OFF at server */
	status = PDUdebug_off ();
	_pdm_status ("PDUdebug_off", status);
        break;


     case PDC_M_CREATE_CATALOG:
        status = PDUcreate_catalog ();
        _pdm_status("PDUcreate_catalog", status);
        break;

     case PDC_M_CREATE_ELEMENT:
        status = PDUadd_part ();
        _pdm_status("PDUadd_part", status);
        break;

     case PDC_M_DISPLAY_LOC:
        status = PDUdisplay_report ();
        _pdm_status("PDUdisplay_report", status);
        break;

     case PDC_M_DISPLAY_CATALOG:
        status = PDUdisplay_report ();
        _pdm_status("PDUdisplay_report", status);
        break;

     case PDC_M_DEFINE_CATLIST:
        status = PDUdefine_report_format ();
        _pdm_status("PDUdefine_report_format (CATLIST)", status);
        break;

     case PDC_M_DEFINE_BOMMAP:
	/*status = PDUdefine_bom_mapping ();
	_pdm_status("PDUdefine_bom_mapping", status);*/
	break;

     case PDC_M_DEF_CAT_SORT_CRIT:
     case PDC_M_DEF_LOC_SORT_CRIT:
        break;
        
     case PDC_M_REVIEW_PART:
        break;

     case PDC_M_MODIFY_ELEMENT:
        status = PDUchange_part ();
        _pdm_status("PDUchange_part", status);
        break;

     case PDC_M_DELETE_FILES:
        status = PDUdelete_files ();
        _pdm_status("PDUdelete_files", status);
        break;

     case PDC_M_MODIFY_CATALOG:
        status = PDUmodify_catalog ();
        _pdm_status("PDUmodify_catalog", status);
        break;

     case PDC_M_DELETE_ELEMENT:
        status = PDUdelete_part ();
        _pdm_status("PDUchange_part", status);
        break;

     case PDC_M_DELETE_CATALOG:
        status = PDUdelete_catalog ();
        _pdm_status("PDUdelete_catalog", status);
        break;

     case PDC_M_CREATE_LIKE_PART:
        break;

     case PDC_M_CREATE_LIKE_CATALOG:
        status = PDUcreate_like_catalog ();
        _pdm_status("PDUcreate_like_catalog", status);
        break;

     case PDC_M_SEARCH_ONOFF:
        status = PDUsearch_on_off ();
        _pdm_status("PDUsearch_on_off", status);
        break;

     case PDC_M_BOM_DISPLAY_REVIEW:
     case PDC_M_BOM_PRINT:
        status = PDUdisplay_report ();
        _pdm_status("PDUdisplay_report (bom print)", status);
        break;

     case PDC_M_BACKUP_PENDING:
     case PDC_M_DELETE_PENDING:
     case PDC_M_CANCEL_FLAGS:
     case PDC_M_ARCHIVE_PENDING:
     case PDC_M_RETRIEVE_PENDING:
        status = PDUflag_part ( command );
        _pdm_status("PDUflag_part ( command )", status);
        break;

     case PDC_M_COPY:
        status = PDUcopy_file();
        _pdm_status("PDUcopy_file", status);
        break;

     case PDC_M_DELETE_FILE:
        status = PDUdelete_file();
        _pdm_status("PDUdelete_file", status);
        break;

     case PDC_M_REDRAW_DESIGN:
     case PDC_M_READ_REFRESH:
  
     if ( !PDUnullstr(user->username) && ((PDU_form_id == forms.design_form_id) 
         || ((PDU_form_id == forms.local_files_form_id) &&
         (!PDU_local_files_displayed))))
     {
       PDUupdate_design_form();
       PDU_design_form_display = TRUE;
       PDUmessage(PDM_E_CLEAR_FIELD, 's');
       status = PDM_S_SUCCESS;
     }

        break;


     case PDC_M_CANCEL_CHECKOUT:
        status = PDUcancel_checkout();
        _pdm_status("PDUext_cancel_checkout", status);
        break;
        
/* commands with internal and external components */
     case PDC_M_UPDATE_REF_AREA_PT:
     case PDC_M_ACTIVATE_PART:
     case PDC_M_DEACTIVATE_PART:
        break;


     case PDC_M_CHECKOUT_UPDATE:
     	status = PDUext_get_children();
     	_pdm_status("PDUext_get_children", status);
        if ((status == PDM_S_SUCCESS) || (status == PDM_E_PART_NOT_ASSEMBLY))
	  {
           status = PDUext_checkout ();
           _pdm_status("PDUext_checkout", status);
          }
        break;

     case PDC_M_CHECKOUT:
	/*
	   1. get review refresh info
	   2. call PDMcheckout to bring file to workstation
	*/

        PDU_command = PDC_M_CHECKOUT;
        PDU_checkout_type = NONACT;
        status = PDUcheckout();
        _pdm_status("PDUcheckout", status);
        break;

     case PDC_M_CHECKIN:
	/*
	   1. get review refresh filename
	   2. child list is already in buffer: refresh->part_list
	   3. call PDMcheckin to send file to host
	*/

        if (PDU_form_id == forms.design_form_id)
          {
          PDU_command = PDC_M_DEACTIVATE_CHECKIN;
          status = PDUcheckin();
          _pdm_status("PDUcheckin", status);
          }
        else
          {
/*
          checkin_enter = call_time(); 
          checkin_enter2 = system_time();
*/

          status = PDUcheckin();
          _pdm_status("PDUcheckin", status);

/*
          checkin_exit = call_time(); 
          checkin_exit2 = system_time(); 
         sprintf(s,"TOTAL TIME OF CHECKIN %f\n",(checkin_exit - checkin_enter));
          TIMEdebug(s);
          _TIMEdebug(checkin_enter2,checkin_exit2,"Total time in CHECKIN");
*/
          }

        break;

     case PDC_M_REPLACE_PART:
     case PDC_M_PLACE_VIEW:
     case PDC_M_ALIGN_PART:
     case PDC_M_ATTACH_PART:
        break;

     case PDC_M_DEFAULT_ORIGIN:
        status = PDM_S_SUCCESS;
        break;

     default: 
	/* block status message display */
        status = NULL;
        break;
     }

  PDMtime_data(("Command Finished - %d\n", time((long *)0)));
  PDMtime_commit();
  return (status);
  }


