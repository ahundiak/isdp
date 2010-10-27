/* $Id: PDUstate_frm.C,v 1.5 2002/05/28 20:10:13 tlstalli Exp $ */
/* -------------------------------------------------------------------
 * I/VDS
 *
 * File: vds/emsfixes/pdu/filemgr/PDUstate_frm.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *       $Log: PDUstate_frm.C,v $
 *       Revision 1.5  2002/05/28 20:10:13  tlstalli
 *       added code to make call to CMCheckFile for CM control
 *
 *       Revision 1.4  2002/05/09 16:13:34  tlstalli
 *       Made AMDC Phase II Changes
 *
 *       Revision 1.3  2002/01/07 18:33:39  jdsauby
 *       JTSMP CR 5924
 *
 *       Revision 1.2  2001/10/16 15:35:41  jdsauby
 *       JTS MP CR 5536, plus misc  JDS 10/16/01
 *
 *       Revision 1.1  2001/09/07 18:31:05  jdsauby
 *       Final Checkin for AIM / PDU integration  - jds
 *
 *       Revision 1.1  2001/08/15 18:58:12  jdsauby
 *       Added to SP for AIM PDM integration - jds, tls
 *
 *
 * Revision 1.3  2000/10/24  21:50:08  pinnacle
 * (No comment)
 *
 *
 * History:
 *       MM/DD/YY        AUTHOR          DESCRIPTION
 *       08/15/01	 js		 AIM integration
 * -------------------------------------------------------------------------*/

#include <stdio.h>
#include <FI.h>
#include <PDUforms.h>
#include <PDUerror.h>
#include <PDUintdef.h>
#include <PDUform_def.h>
#include <PDUfile_def.h>
#include <PDUcommand.h>
#include <PDUstr.h>
#include <MEMerrordef.h>
#include <MEMstruct.h>
#include <PDMmessage.h>
#include "PDUproto.h"
/*#include "PDMproto.h"*/
#include "exmacros.h"
#include "VDaimCM.h"


/* Gadgets */

#define CURRENT		20   /* workflow, ACL, state */
#define NEW 		22
#define PARTS_MCF  	11
#define SELECT  	24
#define DESELECT	25

#define LIST_MCF	11


/* Externs */

//extern char * calloc();
//extern char * realloc();
extern short PDU_state_form_created;
extern short PDU_state_form_displayed;
extern short PDU_state_perm_window;
extern short PDU_second_row;
extern int PDU_command;
extern int PDU_selected_rows;
extern int PDU_local_files_displayed;
extern struct PDUforms      forms;
extern struct PDUrefresh      *refresh;
extern int PDU_mcf_list;
extern int *PDU_parts_index;
extern MEMptr PDU_parts_list_bufr;
extern MEMptr PDU_states_bufr;
extern struct PDUacl_node *PDU_acl_list;
extern struct PDUacl_node *PDU_acl_group_list;



/*********************************************************
* Function: state_notification_routine
* Move state form by PDU, override state btn for CM AIM 
*
*
*
*
***********************************************************/
int state_notification_routine ( f_label, g_label, value, fp )
  int     f_label;        /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;          /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
    int     status = PDM_S_SUCCESS;
    int     select, pos, length;
    int     row = 0;
    int     mcf_select = FALSE;
    int     num_rows = 0;
    int     num_rows2 = 0;
    int     column = 0, response;
    short   found = FALSE;
    short   state_found = FALSE;
    short   row_deleted = FALSE;
    static char *text = NULL;
    static char *state = NULL;
    char    *msg = NULL;
    char    *catalog = NULL;
    char    *partid = NULL;
    char    *revision = NULL;
    extern void PDUselect_row_in_list_mcf();
    char response_data[50], w_flow[20];
    char *CMstate = NULL;

    PDUmessage(PDM_E_CLEAR_FIELD, 's');
    FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
    fp = forms.move_state_form_id;

    switch ( g_label )
    {
      case FI_HELP:     /* Member of group FI_CTRL_GROUP */

	  f_label = 0;
	  value = 0.0;

	  _pdm_debug ("User selected the HELP button", 0);
	  if (PDU_state_perm_window == FALSE)
	  {
	      FIf_cvrt_to_perm_win(forms.move_state_form_id);
	      PDU_state_perm_window = TRUE;
	  }
	  status = PDUinitialize_help();
	  if (status != PDM_S_SUCCESS)
	  {
	      PDUmessage(status, 's');
	      break;
	  }

	  Help_topic("movestate");

	  break;

      case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */
	  PDUmessage(PDM_E_CMD_CANCELLED, 's');

	  _pdm_debug("User selected the cancel button", 0);

	  if (PDU_state_form_displayed == TRUE)
	      FIf_erase( fp );
	  if (PDU_state_form_created == TRUE)
	      FIf_delete( fp );

	  PDU_state_form_displayed = FALSE;
	  PDU_state_form_created = FALSE;
	  PDU_state_perm_window = FALSE;

	  if (PDU_acl_list)
	  {
	      _pdm_debug("freeing PDU_acl_list", 0);
	      status = PDUfree_acl_structure(&PDU_acl_list);
	      _pdm_status("PDUfree_acl_structure", status);
	      PDU_acl_group_list = NULL;
	  }
	  if (PDU_acl_group_list)
	  {
	      _pdm_debug("freeing PDU_acl_group_list", 0);
	      status = PDUfree_acl_structure(&PDU_acl_group_list);
	      _pdm_status("PDUfree_acl_structure", status);
	      PDU_acl_group_list = NULL;
	  }

	  FIf_display(forms.local_files_form_id);
	  PDU_local_files_displayed = TRUE;

	  break;

      case FI_CVT_TO_PERM_WIN:     /* Member of group FI_CTRL_GROUP */

	  value = 0.0;
	  f_label = 0;

	  PDU_state_perm_window = TRUE;
	  break;

      case FI_EXECUTE:

	  _pdm_debug("entering EXECUTE button", 0);

	  FIfld_get_num_rows(fp, PARTS_MCF, &num_rows);
	  found = FALSE;
	  for (row = 0; row < num_rows; ++row)
	  {
	      FIfld_get_select(fp, PARTS_MCF, row, 0, &mcf_select);
	      if (mcf_select)
	      {
		  found = TRUE;
		  break;
	      }
	  }
	  /*
	     if (found == FALSE)
	     {
	     PDUmessage(PDM_E_NO_PARTS_SELECTED, 's');
	     msg = (char *) PDUtranslate_message(PDM_E_NO_PARTS_SELECTED);
	     FIg_set_text(fp, FI_MSG_FIELD, msg);
	     }
	   */

	  if (found)
	  {
	      _pdm_debug("checking for to-state", 0);
	      FIfld_get_num_rows(fp, NEW, &num_rows2);
	      _pdm_debug("num_rows2 = %d", (char *)num_rows2);
	      FImcf_set_active_col(fp, NEW, 0, 0);

	      state_found = FALSE;
	      for (row = 0; row < num_rows2; ++row)
	      {
		  FIfld_get_select(fp, NEW, row, 0, &mcf_select);
		  if (mcf_select)
		  {
		      state_found = TRUE;
		      FIfld_get_text_length(fp, NEW, row, 0, &length);
		      state = (char *) malloc (sizeof (char) * length + 1);
		      memset(state, NULL, sizeof (char) * length + 1);
		      FIfld_get_text(fp, NEW, row, 0, length,
			      (unsigned char *)state, &select, &pos);
		      _pdm_debug("state = <%s>", state);

		      if (strcmp(state, "") == 0)
		      {
			  _pdm_debug("no state selected", 0);
			  PDUmessage(PDM_E_SELECT_STATE, 's');
			  msg = (char *) PDUtranslate_message(PDM_E_SELECT_STATE);
			  FIg_set_text(fp, FI_MSG_FIELD, msg);
			  break;
		      }

		      /* TLS set the CMstate value*/
		      CMstate = (char *)malloc (sizeof (char) * length + 1 );
		      strcpy(CMstate, state );

		  }
	      }
	      if (!state_found)
	      {
		  PDUmessage(PDM_E_SELECT_STATE, 's');
		  msg = (char *) PDUtranslate_message(PDM_E_SELECT_STATE);
		  FIg_set_text(fp, FI_MSG_FIELD, msg);
		  break;
	      }
	  }

	  _pdm_debug("deleting non-selected rows", 0);
	  FIfld_get_num_rows(fp, PARTS_MCF, &num_rows);
	  _pdm_debug("num_rows = %d", (char *)num_rows);
	  row_deleted = 0;

	  for (row = 0; row <= num_rows; ++row)
	  {
	      if (row_deleted)
		  --row;
	      row_deleted = 0;
	      FIfld_get_select(fp, PARTS_MCF, row, 0, &mcf_select);
	      if (!mcf_select)
	      {
		  row_deleted = 1;
		  for (column = 0; column < 3; ++column)
		  {
		      FIfld_get_text_length(fp, PARTS_MCF, row, column, &length);
		      text = (char *) malloc (sizeof (char) * length + 1);
		      memset(text, NULL, sizeof (char) * length + 1);
		      FIfld_get_text(fp, PARTS_MCF, row, column, 
			      length, (unsigned char *)text, &select, &pos);

		      if (column == 0)
		      {
			  PDUfill_in_string(&catalog, text);
			  _pdm_debug("catalog = <%s>", catalog);
		      }
		      else if (column == 1)
		      {
			  PDUfill_in_string(&partid, text);
			  _pdm_debug("part num = <%s>", partid);
		      }
		      else if (column == 2)
		      {
			  PDUfill_in_string(&revision, text);
			  _pdm_debug("revision = <%s>", revision);
		      }
		  }
		  _pdm_debug("deleting row %d", (char *)row);
		  FIfld_delete_rows(fp, PARTS_MCF, row, 1);
		  FIfld_get_num_rows(fp, PARTS_MCF, &num_rows);
		  FIfld_set_num_rows(fp, PARTS_MCF, num_rows);
		  _pdm_debug("num_rows = %d", (char *)num_rows);
		  _pdm_debug("active row = %d", (char *)row);

		  _pdm_debug("moving row to end of acl_list",0);
		  status = PDUremove_node_from_group_list(catalog, partid,
			  revision);
		  _pdm_status("PDUremove_node_from_group_list", status);

	      }
	  }

	  _pdm_debug("processing selected rows", 0);
	  FIfld_get_num_rows(fp, PARTS_MCF, &num_rows);
	  _pdm_debug("num_rows = %d", (char *)num_rows);
	  FImcf_set_active_col(fp, PARTS_MCF, 0, 0);

	  for (row = 0; row < num_rows; ++row)
	  {
	      FIfld_get_select(fp, PARTS_MCF, row, 0, &mcf_select);
	      if (mcf_select)
	      {
		  for (column = 0; column < 4; ++column)
		  {
		      FIfld_get_text_length(fp, PARTS_MCF, row, column, &length);
		      text = (char *) malloc (sizeof (char) * length + 1);
		      memset(text, NULL, sizeof (char) * length + 1);
		      FIfld_get_text(fp, PARTS_MCF, row, column, length,
			      (unsigned char *)text, &select, &pos);

		      if (column == 0)
		      {
			  PDUfill_in_string(&refresh->rev_catalog, text);
			  _pdm_debug("catalog = <%s>", refresh->rev_catalog);
		      }
		      else if (column == 1)
		      {
			  PDUfill_in_string(&refresh->rev_partid, text);
			  _pdm_debug("part num = <%s>", refresh->rev_partid);
		      }
		      else if (column == 2)
		      {
			  PDUfill_in_string(&refresh->rev_revision, text);
			  _pdm_debug("revision = <%s>", refresh->rev_revision);
		      }
		      else if (column == 3)
		      {
			  PDUfill_in_string(&refresh->rev_description,text);
			  _pdm_debug("description = <%s>",refresh->rev_description);
		      }
		  }

		  _pdm_debug("calling move to next state", 0);

		  /* -------------------------------------------------
		   * If AIM/SIr is loaded, then the following needs to happen
		   * **/
		  if ( VDaimIsAimLoaded() ) {

		      /* slj - Here is one potential place for AII code */
		      /* add the CM stuff as a seperate function and check */
		      /* the return status before calling PDUmulti_move_state(state)*/

		      /* SSR */
		      /* Depending on State call CM functions */
		      /*printf("\n to call CMmake_transition");
			status = CMmake_transition();*/
		      //__DBGpr_str("state", CMstate);
		      status = CMget_wflow_name( refresh->rev_catalog, refresh->rev_partid,
			      refresh->rev_revision, w_flow);
		      //__DBGpr_str( " w_flow ", w_flow);
		      // TR1364 follow CM changes only for AVD_CM_W_FLOW
		      // SSR 7 SEP
		      //if(!strcmp(w_flow, AVD_CM_WFLOW))
		      if(!strcasecmp(w_flow, "Y"))
		      {
			  _pdm_debug("move state = <%s>", CMstate);

			  if(!strcmp(CMstate, DEVELOPMENT))
			  {
			      status = CMReject();
			      do
			      {
				  ex$wait_for_input( response = &response,
					  buffer = response_data,
					  mode = EX_ALL_ASCII_MODE,
					  byte = &status );
			      } while( response != EX_FORM_FINISHED );
			      //if(ChkOK == 0)
			      if ( !CheckAllowed() )
			      {
				  //UI_status("Couldnot move to Checking.");
				  UI_status("Couldnot move to Cad Validation.");
				  break;
			      }
		  	      /*
			      if(status)
			      {
				  UI_status("Couldnot Change AR States in AIM.");
				  break;
			      }
			      */
			  }
			  if(!strcmp(CMstate, BASELINE))
			  {
			      status = CMBaseline();
			      if(status)
			      {
				  UI_status("Couldnot Baseline M D C.");
				  break;
			      }
			  }
			  if(!strcmp(CMstate, RELEASE))
			  {
			      status = CMRelease();
			      if(status)
			      {
				  UI_status("Could not Revise M D C.");
				  break;
			      }
			  }
			  //TLS 04-30-02 Changed for AMDC Phase II
			  //if(!strcmp(CMstate, CHECKING))
			  if(!strcmp(CMstate, CADVALIDATION))
			  {
		  	      _pdm_debug("calling CMstate_form", 0);
			      status = CMstate_form();
			      do
			      {
				  ex$wait_for_input( response = &response,
					  buffer = response_data,
					  mode = EX_ALL_ASCII_MODE,
					  byte = &status );
			      } while( response != EX_FORM_FINISHED );
			      //if(ChkOK == 0)
			      if ( !CheckAllowed() )
			      {
				  //UI_status("Couldnot move to Checking.");
				  UI_status("Couldnot move to Cad Validation.");
				  break;
			      }
			  }

			  if(!strcmp(CMstate, CHECKING))
			  {
			      _pdm_debug("calling CMCheckFile", 0);
			      status = CMCheckFile(); 
			      if(status)
			      {
				  UI_status("Could not move state to Checking.");
				  break;
			      }
			  }

			  if(!strcmp(CMstate, REVIEW))
			  {
			      _pdm_debug("calling CMCheckFile", 0);
			      status = CMCheckFile(); 
			      if(status)
			      {
				  UI_status("Could not move state to Review.");
				  break;
			      }
			  }
		
		      }// END TR 1364 SSR 7 SEP
		  }  /* end of if VDaimIsAimLoaded */

		  status = PDUmulti_move_state(state);
		  _pdm_status("PDUmulti_move_state", status);

		  PDUmessage(status, 's');
	      } 
	  }

	  _pdm_debug("checking for failure", 0);
	  for (row = 0; row < num_rows; ++row)
	  {
	      FIfld_get_select(fp, PARTS_MCF, row, 0, &mcf_select);
	      if (mcf_select)
	      {
		  PDUmessage(PDM_E_NOT_TRANSITIONED, 's');
		  break;
	      }
	  }

	  if (PDU_acl_list)
	  {
	      status = PDUfree_acl_structure(&PDU_acl_group_list);
	      _pdm_status("PDUfree_acl_structure", status);
	      PDU_acl_group_list = NULL;

	      /* allow user time to read any error messages */
	      sleep(2);
	      for (row = 0; row < num_rows; ++row)
		  for (column = 0; column < 4; ++column)
		      FIfld_set_text(forms.move_state_form_id, PARTS_MCF, row,
			      column, "", FALSE);

	      status = PDUgroup_parts_for_transition();
	      _pdm_status("PDUgroup_parts_for_transition", status);

	      if (status != PDM_S_SUCCESS)
	      {
		  PDUmessage(status, 's');
		  break;
	      }

	      status = PDUload_move_state_form();
	      _pdm_status("PDUload_move_state_form", status);
	  }
	  else
	  {
	      _pdm_debug("all parts have been moved; exiting", 0);

	      if (PDU_acl_group_list)
	      {
		  status = PDUfree_acl_structure(&PDU_acl_group_list);
		  _pdm_status("PDUfree_acl_structure", status);
		  PDU_acl_group_list = NULL;
	      }

	      if (PDU_state_form_displayed == TRUE)
		  FIf_erase( fp );
	      if (PDU_state_form_created == TRUE)
		  FIf_delete( fp );

	      PDU_state_form_displayed = FALSE;
	      PDU_state_form_created = FALSE;
	      PDU_state_perm_window = FALSE;

	      /*           
			   FIf_display(forms.local_files_form_id);
			   PDU_local_files_displayed = TRUE;
	       */
	  }

	  // SAUBY, added for JTSMP CR 5924
	  FIf_display(forms.local_files_form_id);
	  PDU_local_files_displayed = TRUE;


	  break;

      case CURRENT:   /* READ ONLY FIELD */
	  break;

      case NEW:

	  _pdm_debug("entering NEW listing field", 0);

	  FIfld_get_num_rows(fp, NEW, &num_rows);
	  _pdm_debug("num_rows = %d", (char *)num_rows);
	  FImcf_set_active_col(fp, NEW, 0, 0);

	  for (row = 0; row < num_rows; ++row)
	  {
	      FIfld_get_select(fp, NEW, row, 0, &mcf_select);
	      if (mcf_select)
	      {
		  FIfld_get_text_length(fp, NEW, row, 0, &length);
		  text = (char *) malloc (sizeof (char) * length + 1);
		  memset(text, NULL, sizeof (char) * length + 1);
		  FIfld_get_text(fp, NEW, row, 0, length,
			  (unsigned char *)text, &select, &pos);
		  _pdm_debug("text = <%s>", text);

		  if (strcmp(text, "") == 0)
		  {
		      _pdm_debug("text field is empty", 0);
		      break;
		  }
	      }
	  }
	  break;

      case SELECT:

	  _pdm_debug("entering SELECT button", 0);

	  FIfld_get_num_rows(fp, PARTS_MCF, &num_rows);
	  _pdm_debug("num_rows = %d", (char *)num_rows);

	  for (row = 0; row < num_rows; ++row)
	      FImcf_set_select(fp, PARTS_MCF, row, TRUE);

	  break;

      case DESELECT:

	  _pdm_debug("entering DESELECT button", 0);

	  FIfld_get_num_rows(fp, PARTS_MCF, &num_rows);
	  _pdm_debug("num_rows = %d", (char *)num_rows);

	  for (row = 0; row < num_rows; ++row)
	      FImcf_set_select(fp, PARTS_MCF, row, FALSE);

	  break;

      case PARTS_MCF:

	  _pdm_debug("entering PARTS_MCF", 0);

	  FIfld_get_active_row(fp, PARTS_MCF, &row, &pos);
	  FImcf_set_active_col(fp, PARTS_MCF, 0, 0);
	  FIfld_get_select(fp, PARTS_MCF, row, 0, &mcf_select);
	  _pdm_debug("active row = %d", (char *)row);

	  _pdm_debug("getting part information", 0);
	  for (column = 0; column < 3; ++column)
	  {
	      FIfld_get_text_length(fp, PARTS_MCF, row, column, &length);
	      text = (char *) malloc (sizeof (char) * length + 1);
	      memset(text, NULL, sizeof (char) * length + 1);
	      FIfld_get_text(fp, PARTS_MCF, row, column, length,
		      (unsigned char *)text, &select, &pos);

	      if (column == 0)
	      {
		  PDUfill_in_string(&catalog, text);
		  _pdm_debug("catalog = <%s>", catalog);
	      }
	      else if (column == 1)
	      {
		  PDUfill_in_string(&partid, text);
		  _pdm_debug("part num = <%s>", partid);
	      }
	      else if (column == 2)
	      {
		  PDUfill_in_string(&revision, text);
		  _pdm_debug("revision = <%s>", revision);
	      }
	  }

	  _pdm_debug("finding matching row on main form", 0);
	  if (PDU_mcf_list)
	      PDUselect_row_in_list_mcf(catalog, partid, revision, mcf_select);

	  break;

    } /* END switch ( g_label ) */

    return(status);

} /* END notification_routine() */


#if 0
/* function replaced by AIM  **/
int state_notification_routine ( f_label, g_label, value, fp )
  int     f_label;        /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;          /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  int     status = PDM_S_SUCCESS;
  int     select, pos, length;
  int     row = 0;
  int     mcf_select = FALSE;
  int     num_rows = 0;
  int     num_rows2 = 0;
  int     column = 0;
  short   found = FALSE;
  short   state_found = FALSE;
  short   row_deleted = FALSE;
  static char *text = NULL;
  static char *state = NULL;
  char    *msg = NULL;
  char    *catalog = NULL;
  char    *partid = NULL;
  char    *revision = NULL;
  extern void PDUselect_row_in_list_mcf();

  PDUmessage(PDM_E_CLEAR_FIELD, 's');
  FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
  fp = forms.move_state_form_id;

  switch ( g_label )
  {
    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

	 f_label = 0;
         value = 0.0;

         _pdm_debug ("User selected the HELP button", 0);
         if (PDU_state_perm_window == FALSE)
           {
           FIf_cvrt_to_perm_win(forms.move_state_form_id);
           PDU_state_perm_window = TRUE;
           }
         status = PDUinitialize_help();
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }

         Help_topic("movestate");

         break;

    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */
         PDUmessage(PDM_E_CMD_CANCELLED, 's');

         _pdm_debug("User selected the cancel button", 0);

         if (PDU_state_form_displayed == TRUE)
           FIf_erase( fp );
         if (PDU_state_form_created == TRUE)
           FIf_delete( fp );

         PDU_state_form_displayed = FALSE;
         PDU_state_form_created = FALSE;
         PDU_state_perm_window = FALSE;

         if (PDU_acl_list)
           {
           _pdm_debug("freeing PDU_acl_list", 0);
           status = PDUfree_acl_structure(&PDU_acl_list);
           _pdm_status("PDUfree_acl_structure", status);
           PDU_acl_group_list = NULL;
           }
         if (PDU_acl_group_list)
           {
           _pdm_debug("freeing PDU_acl_group_list", 0);
           status = PDUfree_acl_structure(&PDU_acl_group_list);
           _pdm_status("PDUfree_acl_structure", status);
           PDU_acl_group_list = NULL;
           }

         FIf_display(forms.local_files_form_id);
         PDU_local_files_displayed = TRUE;

         break;

    case FI_CVT_TO_PERM_WIN:     /* Member of group FI_CTRL_GROUP */
 
         value = 0.0;
         f_label = 0;
  
         PDU_state_perm_window = TRUE;
         break;

    case FI_EXECUTE:

         _pdm_debug("entering EXECUTE button", 0);

         FIfld_get_num_rows(fp, PARTS_MCF, &num_rows);
         found = FALSE;
         for (row = 0; row < num_rows; ++row)
            {
            FIfld_get_select(fp, PARTS_MCF, row, 0, &mcf_select);
            if (mcf_select)
              {
              found = TRUE;
              break;
              }
            }
/*
         if (found == FALSE)
           {
           PDUmessage(PDM_E_NO_PARTS_SELECTED, 's');
           msg = (char *) PDUtranslate_message(PDM_E_NO_PARTS_SELECTED);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           }
*/

         if (found)
           {
           _pdm_debug("checking for to-state", 0);
           FIfld_get_num_rows(fp, NEW, &num_rows2);
           _pdm_debug("num_rows2 = %d", (char *)num_rows2);
           FImcf_set_active_col(fp, NEW, 0, 0);
  
           state_found = FALSE;
           for (row = 0; row < num_rows2; ++row)
              {
              FIfld_get_select(fp, NEW, row, 0, &mcf_select);
              if (mcf_select)
                {
                state_found = TRUE;
                FIfld_get_text_length(fp, NEW, row, 0, &length);
                state = (char *) malloc (sizeof (char) * length + 1);
                memset(state, NULL, sizeof (char) * length + 1);
                FIfld_get_text(fp, NEW, row, 0, length,
                              (unsigned char *)state, &select, &pos);
                _pdm_debug("state = <%s>", state);
  
                if (strcmp(state, "") == 0)
                  {
                  _pdm_debug("no state selected", 0);
                  PDUmessage(PDM_E_SELECT_STATE, 's');
                  msg = (char *) PDUtranslate_message(PDM_E_SELECT_STATE);
                  FIg_set_text(fp, FI_MSG_FIELD, msg);
                  break;
                  }
                }
              }
           if (!state_found)
             {
             PDUmessage(PDM_E_SELECT_STATE, 's');
             msg = (char *) PDUtranslate_message(PDM_E_SELECT_STATE);
             FIg_set_text(fp, FI_MSG_FIELD, msg);
             break;
             }
           }

         _pdm_debug("deleting non-selected rows", 0);
         FIfld_get_num_rows(fp, PARTS_MCF, &num_rows);
         _pdm_debug("num_rows = %d", (char *)num_rows);
         row_deleted = 0;

         for (row = 0; row <= num_rows; ++row)
            {
            if (row_deleted)
              --row;
            row_deleted = 0;
            FIfld_get_select(fp, PARTS_MCF, row, 0, &mcf_select);
            if (!mcf_select)
              {
              row_deleted = 1;
              for (column = 0; column < 3; ++column)
                {
                FIfld_get_text_length(fp, PARTS_MCF, row, column, &length);
                text = (char *) malloc (sizeof (char) * length + 1);
                memset(text, NULL, sizeof (char) * length + 1);
                FIfld_get_text(fp, PARTS_MCF, row, column, 
                               length, (unsigned char *)text, &select, &pos);
 
                if (column == 0)
                  {
                  PDUfill_in_string(&catalog, text);
                  _pdm_debug("catalog = <%s>", catalog);
                  }
                else if (column == 1)
                  {
                  PDUfill_in_string(&partid, text);
                  _pdm_debug("part num = <%s>", partid);
                  }
                else if (column == 2)
                  {
                  PDUfill_in_string(&revision, text);
                  _pdm_debug("revision = <%s>", revision);
                  }
                }
              _pdm_debug("deleting row %d", (char *)row);
              FIfld_delete_rows(fp, PARTS_MCF, row, 1);
              FIfld_get_num_rows(fp, PARTS_MCF, &num_rows);
              FIfld_set_num_rows(fp, PARTS_MCF, num_rows);
              _pdm_debug("num_rows = %d", (char *)num_rows);
              _pdm_debug("active row = %d", (char *)row);

              _pdm_debug("moving row to end of acl_list",0);
              status = PDUremove_node_from_group_list(catalog, partid,
                                                      revision);
              _pdm_status("PDUremove_node_from_group_list", status);
                 
              }
            }

         _pdm_debug("processing selected rows", 0);
         FIfld_get_num_rows(fp, PARTS_MCF, &num_rows);
         _pdm_debug("num_rows = %d", (char *)num_rows);
         FImcf_set_active_col(fp, PARTS_MCF, 0, 0);

         for (row = 0; row < num_rows; ++row)
            {
            FIfld_get_select(fp, PARTS_MCF, row, 0, &mcf_select);
            if (mcf_select)
              {
              for (column = 0; column < 4; ++column)
                {
                FIfld_get_text_length(fp, PARTS_MCF, row, column, &length);
                text = (char *) malloc (sizeof (char) * length + 1);
                memset(text, NULL, sizeof (char) * length + 1);
                FIfld_get_text(fp, PARTS_MCF, row, column, length,
                              (unsigned char *)text, &select, &pos);

                if (column == 0)
                  {
                  PDUfill_in_string(&refresh->rev_catalog, text);
                  _pdm_debug("catalog = <%s>", refresh->rev_catalog);
                  }
                else if (column == 1)
                  {
                  PDUfill_in_string(&refresh->rev_partid, text);
                  _pdm_debug("part num = <%s>", refresh->rev_partid);
                  }
                else if (column == 2)
                  {
                  PDUfill_in_string(&refresh->rev_revision, text);
                  _pdm_debug("revision = <%s>", refresh->rev_revision);
                  }
                else if (column == 3)
                  {
                  PDUfill_in_string(&refresh->rev_description,text);
                  _pdm_debug("description = <%s>",refresh->rev_description);
                  }
                }

              _pdm_debug("calling move to next state", 0);
              status = PDUmulti_move_state(state);
              _pdm_status("PDUmulti_move_state", status);

              PDUmessage(status, 's');
              } 
            }

         _pdm_debug("checking for failure", 0);
         for (row = 0; row < num_rows; ++row)
            {
            FIfld_get_select(fp, PARTS_MCF, row, 0, &mcf_select);
            if (mcf_select)
              {
              PDUmessage(PDM_E_NOT_TRANSITIONED, 's');
              break;
              }
            }

         if (PDU_acl_list)
           {
           status = PDUfree_acl_structure(&PDU_acl_group_list);
           _pdm_status("PDUfree_acl_structure", status);
           PDU_acl_group_list = NULL;

           /* allow user time to read any error messages */
           sleep(2);
           for (row = 0; row < num_rows; ++row)
              for (column = 0; column < 4; ++column)
                 FIfld_set_text(forms.move_state_form_id, PARTS_MCF, row,
                                column, "", FALSE);

           status = PDUgroup_parts_for_transition();
           _pdm_status("PDUgroup_parts_for_transition", status);

           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }

           status = PDUload_move_state_form();
           _pdm_status("PDUload_move_state_form", status);
           }
         else
           {
           _pdm_debug("all parts have been moved; exiting", 0);

           if (PDU_acl_group_list)
             {
             status = PDUfree_acl_structure(&PDU_acl_group_list);
             _pdm_status("PDUfree_acl_structure", status);
             PDU_acl_group_list = NULL;
             }

           if (PDU_state_form_displayed == TRUE)
             FIf_erase( fp );
           if (PDU_state_form_created == TRUE)
             FIf_delete( fp );
  
           PDU_state_form_displayed = FALSE;
           PDU_state_form_created = FALSE;
           PDU_state_perm_window = FALSE;

           FIf_display(forms.local_files_form_id);
           PDU_local_files_displayed = TRUE;
           }

         break;

    case CURRENT:   /* READ ONLY FIELD */
         break;

    case NEW:

         _pdm_debug("entering NEW listing field", 0);

         FIfld_get_num_rows(fp, NEW, &num_rows);
         _pdm_debug("num_rows = %d", (char *)num_rows);
         FImcf_set_active_col(fp, NEW, 0, 0);

         for (row = 0; row < num_rows; ++row)
            {
            FIfld_get_select(fp, NEW, row, 0, &mcf_select);
            if (mcf_select)
              {
              FIfld_get_text_length(fp, NEW, row, 0, &length);
              text = (char *) malloc (sizeof (char) * length + 1);
              memset(text, NULL, sizeof (char) * length + 1);
              FIfld_get_text(fp, NEW, row, 0, length,
                            (unsigned char *)text, &select, &pos);
              _pdm_debug("text = <%s>", text);

              if (strcmp(text, "") == 0)
                {
                _pdm_debug("text field is empty", 0);
                break;
                }
              }
            }

         break;

    case SELECT:

         _pdm_debug("entering SELECT button", 0);

         FIfld_get_num_rows(fp, PARTS_MCF, &num_rows);
         _pdm_debug("num_rows = %d", (char *)num_rows);

         for (row = 0; row < num_rows; ++row)
            FImcf_set_select(fp, PARTS_MCF, row, TRUE);

         break;

    case DESELECT:

         _pdm_debug("entering DESELECT button", 0);

         FIfld_get_num_rows(fp, PARTS_MCF, &num_rows);
         _pdm_debug("num_rows = %d", (char *)num_rows);

         for (row = 0; row < num_rows; ++row)
            FImcf_set_select(fp, PARTS_MCF, row, FALSE);

         break;

    case PARTS_MCF:

         _pdm_debug("entering PARTS_MCF", 0);

         FIfld_get_active_row(fp, PARTS_MCF, &row, &pos);
         FImcf_set_active_col(fp, PARTS_MCF, 0, 0);
         FIfld_get_select(fp, PARTS_MCF, row, 0, &mcf_select);
         _pdm_debug("active row = %d", (char *)row);

         _pdm_debug("getting part information", 0);
         for (column = 0; column < 3; ++column)
           {
           FIfld_get_text_length(fp, PARTS_MCF, row, column, &length);
           text = (char *) malloc (sizeof (char) * length + 1);
           memset(text, NULL, sizeof (char) * length + 1);
           FIfld_get_text(fp, PARTS_MCF, row, column, length,
                         (unsigned char *)text, &select, &pos);

           if (column == 0)
             {
             PDUfill_in_string(&catalog, text);
             _pdm_debug("catalog = <%s>", catalog);
             }
           else if (column == 1)
             {
             PDUfill_in_string(&partid, text);
             _pdm_debug("part num = <%s>", partid);
             }
           else if (column == 2)
             {
             PDUfill_in_string(&revision, text);
             _pdm_debug("revision = <%s>", revision);
             }
           }

         _pdm_debug("finding matching row on main form", 0);
         if (PDU_mcf_list)
           PDUselect_row_in_list_mcf(catalog, partid, revision, mcf_select);

         break;

  } /* END switch ( g_label ) */

  return(status);

} /* END notification_routine() */
#endif


/* This function loads/creates, initializes, and displays the login form. */

int PDUstate_form()
{
  int  sts = PDM_S_SUCCESS;

  PDU_acl_list = NULL;
  PDU_acl_group_list = NULL;

  if ((PDU_parts_list_bufr) && (PDU_selected_rows > 0))
    {
    sts = PDUprocess_state_form_parts();
    _pdm_status("PDUprocess_state_form_parts", sts);
    }
  else
    {
    sts = PDUprocess_individual_state_form_part(refresh->rev_catalog,
						refresh->rev_partid,
						refresh->rev_revision,
						refresh->rev_description,
						refresh->rev_filename,
						refresh->rev_parttype);
    _pdm_status("PDUprocess_individual_state_form_part", sts);
    }

  if (sts != PDM_S_SUCCESS)
    return(sts);

  if (!PDU_acl_group_list)
    {
    _pdm_debug("acl_list is empty", 0);
    return(PDM_S_SUCCESS);
    }

  if (PDU_state_form_created == TRUE)
    {
    _pdm_debug("form has already been created", 0);
    return(PDM_S_SUCCESS);
    }

  PDU_state_form_created = FALSE;
  PDU_state_form_displayed = FALSE;
  PDU_state_perm_window = FALSE;

  sts = FIf_new(MOVE_STATE_FORM, "movestate", state_notification_routine,
                &forms.move_state_form_id);

  _pdm_debug("Creating state form", 0);
  PDU_state_form_created = TRUE;

  if (PDU_acl_group_list)
    {
    _pdm_debug("loading parts into form", 0);
    sts = PDUload_move_state_form();
    _pdm_status("PDUload_move_state_form", sts);
    if (sts != PDM_S_SUCCESS)
      {
      FIf_delete(forms.move_state_form_id);
      PDU_state_form_created = FALSE;
      PDU_state_form_displayed = FALSE;
      PDU_state_perm_window = FALSE;
      return(sts);
      }
    }

  FIf_erase(forms.local_files_form_id);
  PDU_local_files_displayed = FALSE;

  /* Display the state form and set the displayed state to TRUE. */
  _pdm_debug("Displaying the state form", 0);

  sts = FIf_display(forms.move_state_form_id);
  PDU_state_form_displayed = TRUE;

  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  return(PDM_S_SUCCESS);
}

void PDUselect_row_in_list_mcf(cat, part, rev, row_select)
  char    *cat;
  char    *part;
  char    *rev;
  int     row_select;
{
  int                           column;
  int                           row;
  int                           length;
  int                           field;
  int                           select, pos;
  int                           index;
  static char                   *text;
  char                          *catalog = NULL;
  char                          *partid = NULL;
  char                          *revision = NULL;
  Form                          form;

  _pdm_debug("in the function PDUselect_row_in_list_mcf", 0);

  form = forms.local_files_form_id;
  field = LIST_MCF;

  for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
     {
     _pdm_debug("row = %d", (char *)row);
     for (column = 0; column < 3; ++column)
        {
        FIfld_get_text_length(form, field, row, column, &length);
        text = (char *) malloc (sizeof (char) * length + 1);
        memset(text, NULL, sizeof (char) * length + 1);
        FIfld_get_text(form, field, row, column, length,
                      (unsigned char *)text, &select, &pos);

        if (column == 0) PDUfill_in_string(&catalog, text);
        else if (column == 1) PDUfill_in_string(&partid, text);
        else if (column == 2) PDUfill_in_string(&revision, text);
        PDUfree_string(&text);
        }

        _pdm_debug("checking cat/part/rev for NULL", 0);
        if ( catalog && partid && revision &&
             (strcmp(cat, catalog) == 0) &&
             (strcmp(part, partid) == 0) &&
             (strcmp(rev, revision) == 0) )
          {
          if (row_select)
            {
            _pdm_debug("selecting row", 0);
            if (PDU_parts_index[row] == -1)
              {
              FImcf_set_select(form,field,row,row_select);
              PDU_parts_index[row] = row;
              PDU_selected_rows = PDU_selected_rows + 1;
              _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
              }
            }
          else
            {
            _pdm_debug("deselecting row", 0);
            if (PDU_parts_index[row] != -1)
              {
              FImcf_set_select(form,field,row,row_select);
              PDU_parts_index[row] = -1;
              PDU_selected_rows = PDU_selected_rows - 1;
              _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
              }
            }
         
          break;
          }
     /* clear out fields */
     catalog = NULL_STRING;
     partid = NULL_STRING;
     revision = NULL_STRING;
     }

  index = row;

  /* check for multiple files */
  for (row = index + 1; row < PDU_parts_list_bufr->rows; ++row)
     {
     _pdm_debug("row = <%d>", (char *)row);
     FIfld_get_text_length(form, LIST_MCF, row, 0, &length);
     text = (char *) malloc (sizeof (char) * length + 1);
     memset(text, NULL, sizeof (char) * length + 1);
     FIfld_get_text(form, LIST_MCF, row, 0, length, (unsigned char *)text,
                    &select, &pos);
     if (strcmp(text, "") == 0)
       {
       if (row_select)
         {
         _pdm_debug("selecting row", 0);
         if (PDU_parts_index[row] == -1)
           {
           FImcf_set_select(form,field,row,row_select);
           PDU_parts_index[row] = row;
           PDU_selected_rows = PDU_selected_rows + 1;
           _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
           }
         }
       else
         {
         _pdm_debug("deselecting row", 0);
         if (PDU_parts_index[row] != -1)
           {
           FImcf_set_select(form,field,row,row_select);
           PDU_parts_index[row] = -1;
           PDU_selected_rows = PDU_selected_rows - 1;
           _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
           }
         }
       }
     else
       {
       _pdm_debug("multiple files not found", 0);
       break;
       }
     PDUfree_string(&text);
     }

  return;
}

int PDUmulti_move_state(to_state)
  char  *to_state;
{
  int   status = PDM_S_SUCCESS;
  int   sts = PDM_S_SUCCESS;
  char   *status_msg = NULL;
  char   *msg = NULL;
  int    num_rows = 0;
  char   new_msg[50];
 
  _pdm_debug("PDUmulti_move_state", 0);

  PDU_command = PDC_M_USER_APPROVED;

  _pdm_debug("validating access", 0);
  msg = (char *) PDUtranslate_message(PDU_command);

  new_msg[0] = '\0';
  strcpy(new_msg, "PDM");
  strcat(new_msg, msg);

  status = PDMvalidate_user_access ( new_msg, NULLSTR, refresh->rev_catalog, 
                        NULLSTR, refresh->rev_partid, refresh->rev_revision);
  _pdm_status("PDMvalidate_user_access", status);
  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  PDUmessage(PDS_M_GET_TRANS, 's');

  status = PDMget_trans(refresh->rev_catalog, 
                        refresh->rev_partid, 
                        refresh->rev_revision);
  _pdm_status("PDMget_trans",status);
  if (status != PDM_S_SUCCESS)
    return(status);
 
  PDUunlock_item(refresh->rev_catalog, 
                 refresh->rev_partid, 
                 refresh->rev_revision);
 
  status = PDUmake_transition(to_state);
  _pdm_status("PDUmake_transition", status);

  PDUmessage(status, 's');
 
  PDUunlock_item(refresh->rev_catalog, 
                 refresh->rev_partid, 
                 refresh->rev_revision);

  _pdm_debug("setting the state", 0);
  status_msg = (char *) PDUtranslate_message(status);
  _pdm_debug("Error string = <%s>", status_msg);

  sts = PDMset_to_state ( status, "PDM", status_msg );
  _pdm_status ("PDMset_to_state", sts);

  if (PDU_mcf_list && PDU_parts_list_bufr)
    {
    status = PDUupdate_form_after_checkin_out(0);
    _pdm_status("PDUupdate_form_after_checkin_out", status);
    }
  if (PDU_state_form_displayed)
    {
    FIfld_get_num_rows(forms.move_state_form_id, PARTS_MCF, &num_rows);
    if (num_rows > 0)
      {
      status = PDUupdate_state_form_after_move_state();
      _pdm_status("PDUupdate_state_form_after_move_state", status);
      }
    }

  if (PDU_states_bufr)
    {
    MEMclose(&PDU_states_bufr);
    PDU_states_bufr = NULL;
    }
 
  return(status);
}

int PDUprocess_state_form_parts()
{
  int    status = PDM_S_SUCCESS;
  int    err_status = PDM_S_SUCCESS;
  int    row = 0;
  int    cat_col = 0;
  int    part_col = 0;
  int    rev_col = 0;
  int    desc_col = 0;
  int    type_col = 0;
  int    file_col = 0;
  char   catalog[21];
  char   partid[41];
  char   revision[41];
  char   filename[15];
  char   parttype[5];
  char   description[256];
  char   prev_cat[21];
  char   prev_part[41];
  char   prev_rev[41];
  char   aclname[21];
  char   state[40];
  char   workflow[21];
  char   **data_row = NULL;
  char   *file_status = NULL;

  _pdm_debug("PDUprocess_state_form_parts", 0);

  catalog[0] = '\0';
  partid[0] = '\0';
  revision[0] = '\0';
  filename[0] = '\0';
  parttype[0] = '\0';
  description[0] = '\0';
  prev_cat[0] = '\0';
  prev_part[0] = '\0';
  prev_rev[0] = '\0';

  PDU_acl_list = NULL;
  PDU_acl_group_list = NULL;

  if (!PDU_parts_list_bufr)
    return(PDM_E_NULL_BUFFER);

  MEMbuild_array(PDU_parts_list_bufr);
  status = PDUget_buffer_col(PDU_parts_list_bufr,"n_catalogname",&cat_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(PDU_parts_list_bufr, "n_itemname", &part_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(PDU_parts_list_bufr, "n_itemrev", &rev_col);
  if (status != PDM_S_SUCCESS)
    return(status);
  
  status = PDUget_buffer_col(PDU_parts_list_bufr, "n_itemdesc", &desc_col);
  if (status != PDM_S_SUCCESS)
    return(status);
  
  status = PDUget_buffer_col(PDU_parts_list_bufr, "p_parttype", &type_col);
  if (status != PDM_S_SUCCESS)
    return(status);
  
  status = PDUget_buffer_col(PDU_parts_list_bufr, "n_cofilename", &file_col);
  if (status != PDM_S_SUCCESS)
    return(status);
  
  PDUsetup_buffer(PDU_parts_list_bufr, ROW, &data_row);
  _pdm_debug("rows = %d", (char *)PDU_parts_list_bufr->rows);

  for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
     {
     if (PDU_parts_index[row] != -1)
       {
       _pdm_debug("row = %d", (char *)row);
  
       _pdm_debug("getting part information", 0);
       strcpy(catalog, 
              data_row[(PDU_parts_list_bufr->columns * row) + cat_col]);
       strcpy(partid, 
              data_row[(PDU_parts_list_bufr->columns * row) + part_col]);
       strcpy(revision, 
              data_row[(PDU_parts_list_bufr->columns * row) + rev_col]);
       strcpy(filename, 
              data_row[(PDU_parts_list_bufr->columns * row) + file_col]);
       strcpy(description, 
              data_row[(PDU_parts_list_bufr->columns * row) + desc_col]);
       strcpy(parttype, 
              data_row[(PDU_parts_list_bufr->columns * row) + type_col]);

       _pdm_debug("catalog = <%s>", catalog);
       _pdm_debug("partid = <%s>", partid);
       _pdm_debug("revision = <%s>", revision);

       if ((strcmp(prev_cat, catalog) == 0) &&
           (strcmp(prev_part, partid) == 0) &&
           (strcmp(prev_rev, revision) == 0))
         {
         _pdm_debug("previous part equal current part", 0);
         continue;
         }

       strcpy(prev_cat, 
              data_row[(PDU_parts_list_bufr->columns * row) + cat_col]);
       strcpy(prev_part,
              data_row[(PDU_parts_list_bufr->columns * row) + part_col]);
       strcpy(prev_rev, 
              data_row[(PDU_parts_list_bufr->columns * row) + rev_col]);

       _pdm_debug("prev_cat = <%s>", prev_cat);
       _pdm_debug("prev_part = <%s>", prev_part);
       _pdm_debug("prev_rev = <%s>", prev_rev);

       _pdm_debug("checking to see if part is checked in", 0);
       status = PDUget_file_status(catalog, partid, revision, &file_status);
       _pdm_status("PDUget_file_status", status);
       if ((file_status) && (strcmp(file_status, "") != 0) && 
           (strcmp(file_status, "I") != 0))
         {
         PDUmessage(PDM_I_PART_CHECKIN, 's');
         err_status = PDM_I_PART_CHECKIN;
         continue;
         }
      
       _pdm_debug("getting acl information for part", 0);
       status = PDMgetacl_info(catalog, partid, revision, aclname, state,
                               workflow);
       _pdm_status("PDMgetacl_info", status);
  
       if (status != PDM_S_SUCCESS)
         {
         PDUmessage(status, 's');
         return(status);
         }
  
       _pdm_debug("aclname = <%s>", aclname);
       _pdm_debug("state = <%s>", state);
       _pdm_debug("workflow = <%s>", workflow);
       
       _pdm_debug("loading acl information into linklist", 0);
       status = PDUadd_node_to_acl_list(catalog, partid, revision,
                                    description, filename, parttype,
                                    aclname, state, workflow, &PDU_acl_list);
       _pdm_status("PDUadd_node_to_acl_list", status);
       }
     }

  if (PDU_acl_list == NULL)
    {
    PDUmessage(err_status, 's');
    return(err_status);
    }
  
  _pdm_debug("grouping parts", 0);
  status = PDUgroup_parts_for_transition();
  _pdm_status("PDUgroup_parts_for_transition", status);

  return(status);
}

int PDUadd_node_to_acl_list(catalog, partid, revision, description, filename,
                            parttype, aclname, state, workflow, node)
char   catalog[21];
char   partid[41];
char   revision[41];
char   description[256];
char   filename[15];
char   parttype[5];
char   aclname[21];
char   state[41];
char   workflow[21];
struct PDUacl_node **node;
{
  int   status = PDM_S_SUCCESS;
  struct PDUacl_node *tail, *temp, *head;

  _pdm_debug("in the function PDUadd_node_to_acl_list", 0);

  temp = NULL;
  tail = NULL;
  head = NULL;
 
  temp = (struct PDUacl_node *)malloc(sizeof(struct PDUacl_node));
  temp->next = NULL;
  temp->catalog[0] = '\0';
  temp->partid[0] = '\0';
  temp->revision[0] = '\0';
  temp->description[0] = '\0';
  temp->filename[0] = '\0';
  temp->parttype[0] = '\0';
  temp->aclname[0] = '\0';
  temp->state[0] = '\0';
  temp->workflow[0] = '\0';
 
  strcpy((temp->catalog), catalog);
  strcpy((temp->partid), partid);
  strcpy((temp->revision), revision);
  strcpy((temp->description), description);
  strcpy((temp->filename), filename);
  strcpy((temp->parttype), parttype);
  strcpy((temp->aclname), aclname);
  strcpy((temp->state), state);
  strcpy((temp->workflow), workflow);
 
  if (*node)
    {
    _pdm_debug("adding node", 0);
    tail = *node;
    while (tail)
      {
      head = tail;
      tail = tail->next;
      }
    head->next = temp;
    }
  else
    {
    _pdm_debug("creating beginning node", 0);
    *node = temp;
    }
 
  if ((*node) && PDM_debug_on)
    PDUprint_acl_list(*node);

  return(status);
}

int PDUprint_acl_list(node)
struct PDUacl_node *node;
{
int    status = PDM_S_SUCCESS;
FILE  *pdu_debug_file, *fopen();
struct PDUacl_node *list = NULL;
 
  _pdm_debug("in the function PDUprint_acl_list", 0);
 
  if (!node)
    {
    _pdm_debug("ACL Linklist is NULL", 0);
    return(PDM_S_SUCCESS);
    }

  list = node;
 
  if ((pdu_debug_file = fopen (PDU_DEBUG_FILE, "a")) == NULL)
    {
    printf("Could not open debug file\n");
    return(PDM_E_OPEN_FILE);
    }

  while (list)
    {
    fprintf(pdu_debug_file, "catalog     = %s\n", list->catalog);
    fprintf(pdu_debug_file, "partid      = %s\n", list->partid);
    fprintf(pdu_debug_file, "revision    = %s\n", list->revision);
    fprintf(pdu_debug_file, "description = %s\n", list->description);
    fprintf(pdu_debug_file, "filename    = %s\n", list->filename);
    fprintf(pdu_debug_file, "parttype    = %s\n", list->parttype);
    fprintf(pdu_debug_file, "aclname     = %s\n", list->aclname);
    fprintf(pdu_debug_file, "state       = %s\n", list->state);
    fprintf(pdu_debug_file, "workflow    = %s\n", list->workflow);
    fprintf(pdu_debug_file, "\n");
    list = list->next;
    }
 
  fclose (pdu_debug_file);
  return(status);
}

int PDUgroup_parts_for_transition()
{
  int   status = PDM_S_SUCCESS;
  int   row = 0;
  struct  PDUacl_node *current_node = NULL, *next_node = NULL;
  char  aclname[21];
  char  state[41];
  char  workflow[21];

  _pdm_debug("in the function PDUgroup_parts_for_transition", 0);

  if (!PDU_acl_list)
    return(PDM_E_NULL_BUFFER);

  aclname[0] = '\0';
  state[0] = '\0';
  workflow[0] = '\0';

  current_node = PDU_acl_list;

  row = 0;

  while (current_node)
    {
    /*
     * TR 139525986. 29/may/95 - raj.
     * Node 'current_node' is freed in PDUdelete_node_from_acl_list()
     * Contents are unpredictable after this. Store next node.
     */
    next_node = current_node->next;

    if (row == 0)
      {
      strcpy(aclname, current_node->aclname);
      strcpy(state, current_node->state);
      strcpy(workflow, current_node->workflow);

      _pdm_debug("adding first row to group_list", 0);
      status = PDUadd_node_to_acl_list( current_node->catalog,
					current_node->partid,
					current_node->revision,
					current_node->description,
					current_node->filename,
					current_node->parttype,
					current_node->aclname,
					current_node->state,
					current_node->workflow,
					&PDU_acl_group_list);
      _pdm_status("PDUadd_node_to_acl_list", status);

      _pdm_debug("deleting first row from acl_list", 0);
      status = PDUdelete_node_from_acl_list(current_node->catalog,
                                            current_node->partid,
                                            current_node->revision,
                                            &PDU_acl_list);
      _pdm_status("PDUdelete_node_from_acl_list", status);
      ++row;
      }
    else
      {
      if ((strcmp(aclname, current_node->aclname) == 0) &&
          (strcmp(state, current_node->state) == 0) &&
          (strcmp(workflow, current_node->workflow) == 0))
        {
        _pdm_debug("adding matching row to group_list", 0);
        status = PDUadd_node_to_acl_list( current_node->catalog,
					  current_node->partid,
					  current_node->revision,
					  current_node->description,
					  current_node->filename,
					  current_node->parttype,
					  current_node->aclname,
					  current_node->state,
					  current_node->workflow,
					  &PDU_acl_group_list);
        _pdm_status("PDUadd_node_to_acl_list", status);

        _pdm_debug("deleting matching row from acl_list", 0);
        status = PDUdelete_node_from_acl_list(current_node->catalog,
                                              current_node->partid,
                                              current_node->revision,
					      &PDU_acl_list);
        _pdm_status("PDUdelete_node_from_acl_list", status);
        }
      }

/* TR 139525986. See above.		*/
/*  current_node = current_node->next;	*/

    current_node = next_node;
    }

  if ((PDU_acl_list) && PDM_debug_on)
    {
    _pdm_debug("printing original acl list", 0);
    PDUprint_acl_list(PDU_acl_list);
    }

  if ((PDU_acl_group_list) && PDM_debug_on)
    {
    _pdm_debug("printing grouped acl list", 0);
    PDUprint_acl_list(PDU_acl_group_list);
    }

  return(status);
}

int PDUdelete_node_from_acl_list(catalog, partid, revision, acl_list)
char   *catalog;
char   *partid;
char   *revision;
struct PDUacl_node  **acl_list;
{
  int   status = PDM_S_SUCCESS;
  struct PDUacl_node  *current_node = NULL;
  struct PDUacl_node  *prev_node = NULL;

  _pdm_debug("in the function PDUdelete_node_from_acl_list", 0);

  if (!(*acl_list))
    {
    _pdm_debug("acl_list is empty", 0);
    return(PDM_E_NULL_BUFFER);
    }

  _pdm_debug("part to delete is:", 0);
  _pdm_debug("catalog = <%s>", catalog);
  _pdm_debug("partid = <%s>", partid);
  _pdm_debug("revision = <%s>", revision);
 
  current_node = *acl_list;
  prev_node = *acl_list;
 
  while (current_node)
    {
    if ((strcmp(current_node->catalog, catalog) != 0) ||
        (strcmp(current_node->partid, partid) != 0) ||
        (strcmp(current_node->revision, revision) != 0))
      {
      _pdm_debug("moving to next node", 0);
      prev_node = current_node;
      current_node = current_node->next;
      }
    else
      {
      /* drop node from linklist */
      _pdm_debug("current_node->catalog = <%s>", current_node->catalog);
      _pdm_debug("current_node->partid = <%s>", current_node->partid);
      _pdm_debug("current_node->revision = <%s>", current_node->revision);

      if ((*acl_list)->next == NULL)
        {
        _pdm_debug("deleting last node in list: list is NULL", 0);
        free(*acl_list);
        *acl_list = NULL;
        }
      else if ((strcmp((*acl_list)->catalog, catalog) == 0) &&
               (strcmp((*acl_list)->partid, partid) == 0) &&
               (strcmp((*acl_list)->revision, revision) == 0))
        {
        _pdm_debug("deleting first node in list", 0);
        *acl_list = current_node->next;
        free(current_node);
        }
      else
        {
        _pdm_debug("deleting middle node in list", 0);
        prev_node->next = current_node->next;
        free(current_node);
        }
      break;
      }
    }
  
  if ((*acl_list) && PDM_debug_on)
    PDUprint_acl_list(*acl_list);

  return(status);
}

int PDUprocess_individual_state_form_part(catalog, partid, revision,
                                          description, filename, parttype)
char   *catalog;
char   *partid;
char   *revision;
char   *description;
char   *filename;
char   *parttype;
{
  int    status = PDM_S_SUCCESS;
  char   aclname[20];
  char   state[40];
  char   workflow[20];
  char   *file_status = NULL;

  _pdm_debug("in the function PDUprocess_individual_state_form_part", 0);

  PDU_acl_list = NULL;
  PDU_acl_group_list = NULL;

  _pdm_debug("checking to see if part is checked in", 0);
  status = PDUget_file_status(catalog, partid, revision, &file_status);
  _pdm_status("PDUget_file_status", status);
  if ((file_status) && (strcmp(file_status, "") != 0) && 
      (strcmp(file_status, "I") != 0))
    return(PDM_I_PART_CHECKIN);
 
  _pdm_debug("getting acl information for part", 0);
  status = PDMgetacl_info(catalog, partid, revision, aclname, state, workflow);
  _pdm_status("PDMgetacl_info", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  _pdm_debug("aclname = <%s>", aclname);
  _pdm_debug("state = <%s>", state);
  _pdm_debug("workflow = <%s>", workflow);
  
  _pdm_debug("loading acl information into linklist", 0);
  status = PDUadd_node_to_acl_list(catalog, partid, revision,
                                   description, filename, parttype,
                                   aclname, state, workflow, &PDU_acl_list);
  _pdm_status("PDUadd_node_to_acl_list", status);

  _pdm_debug("grouping part", 0);
  status = PDUgroup_parts_for_transition();
  _pdm_status("PDUgroup_parts_for_transition", status);

  return(status);
}

int PDUload_move_state_form()
{
  int    status = PDM_S_SUCCESS;
  int    status1 = PDM_S_SUCCESS;
  struct PDUacl_node *acl_list = NULL;
  char   catalog[21];
  char   partid[41];
  char   revision[41];
  char   **dummy_col;
  char   **dummy_format;
  char   **dummy_row;
  char   **data_row;
  MEMptr attr_bufr = NULL;
  MEMptr states_bufr = NULL;
  MEMptr new_states = NULL;
  int    no_headings = 0;
  int    all_flag = 0;
  int    row = 0;
  int    num_rows = 0;
  int    column = 0;
  char   **headings = NULL;
  extern int PDUload_move_state_form();

  _pdm_debug("in the function PDUload_move_state_form", 0);

  catalog[0] = '\0';
  partid[0] = '\0';
  revision[0] = '\0';

  if (!PDU_acl_group_list)
    return(PDM_E_NULL_BUFFER);

  acl_list = PDU_acl_group_list;

  while (acl_list)
    {
    _pdm_debug("acl_list->workflow = <%s>", acl_list->workflow);
    _pdm_debug("acl_list->aclname = <%s>", acl_list->aclname);
    _pdm_debug("acl_list->state = <%s>", acl_list->state);

    _pdm_debug("writing to current state fields", 0);
    FIfld_set_text(forms.move_state_form_id, CURRENT, 0, 0, 
                            acl_list->workflow, FALSE);
    FIfld_set_text(forms.move_state_form_id, CURRENT, 0, 1, 
                            acl_list->aclname, FALSE);
    FIfld_set_text(forms.move_state_form_id, CURRENT, 0, 2, 
                            acl_list->state, FALSE);
    _pdm_debug("moving pointer to next node", 0);
    acl_list = acl_list->next;
    }

  acl_list = PDU_acl_group_list;

  while (acl_list)
    {
    /* save current catalog and part info */
    strcpy(catalog, acl_list->catalog);
    strcpy(partid, acl_list->partid);
    strcpy(revision, acl_list->revision);

    _pdm_debug("retrieving transitions", 0);
    status = PDMget_trans(acl_list->catalog,
			  acl_list->partid,
			  acl_list->revision);
    _pdm_status("PDMget_trans",status);
    acl_list = acl_list->next;
    if (status != PDM_S_SUCCESS)
      {
      if (acl_list)
        {
        _pdm_debug("calling PDMget_trans for next node", 0);
        continue;
        }
      else
        {
        if (PDU_acl_list)
          {
          status = PDUfree_acl_structure(&PDU_acl_group_list);
          _pdm_status("PDUfree_acl_structure", status);
          PDU_acl_group_list = NULL;
    
          /* allow user time to read any error messages */
          sleep(2);
          for (row = 0; row < num_rows; ++row)
             for (column = 0; column < 4; ++column)
                FIfld_set_text(forms.move_state_form_id, PARTS_MCF, row,
                               column, "", FALSE);
    
          status = PDUgroup_parts_for_transition();
          _pdm_status("PDUgroup_parts_for_transition", status);
    
          if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            return(status);
            }
    
          status = PDUload_move_state_form();
          _pdm_status("PDUload_move_state_form", status);
          }
        else
          {
          _pdm_debug("no more parts to move; exiting", 0);
    
          if (PDU_acl_group_list)
            {
            status1 = PDUfree_acl_structure(&PDU_acl_group_list);
            _pdm_status("PDUfree_acl_structure", status1);
            PDU_acl_group_list = NULL;
            }
          return(status);
          }
        }
      }
    else if (status == PDM_S_SUCCESS)
      {
      _pdm_debug("transitions were successfully retrieved", 0);
      break;
      }
    }
 
  PDUunlock_item(catalog, partid, revision);
 
  status = PDUsetup_buffer_list(PDU_states_bufr,1,0,&dummy_row, &dummy_col,
                                &dummy_format, &attr_bufr);
  _pdm_status("PDUsetup_buffer_list",status);
  if (status != PDM_S_SUCCESS)
    return(status);
 
  status = PDUsetup_buffer_list(PDU_states_bufr,2,0,&data_row, &dummy_col,
                                &dummy_format, &states_bufr);
  _pdm_status("PDUsetup_buffer_list",status);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUdelete_current_state_from_states_buffer(states_bufr, &new_states);
  _pdm_status("PDUdelete_current_state_from_states_buffer", status);
  if (status != PDM_S_SUCCESS)
    return(status);

  MEMclose(&states_bufr);
  states_bufr = NULL;

  PDUsetup_single_buffer(new_states);
 
  all_flag = FALSE;
  no_headings = 1;
  headings = (char **) malloc (sizeof (char *) * no_headings);
  memset(headings, NULL, sizeof (char *) * no_headings);
 
  PDUfill_in_string(&headings[0], "n_statename");

  PDUsetup_popup_list(headings, no_headings, all_flag, new_states);
 
  PDUfree_string_array(&headings, no_headings);
 
  PDU_second_row = FALSE;

  PDUbufr_to_mcf(new_states, forms.move_state_form_id, NEW);
  FIfld_set_active_row(forms.move_state_form_id, NEW, 0, 0);
  FIfld_set_num_rows(forms.move_state_form_id, NEW, (new_states->rows));

  if (new_states->rows == 1)
    {
    _pdm_debug("selecting row", 0);
    FImcf_set_select(forms.move_state_form_id, NEW, 0, TRUE);
    }

  if (status == MEM_S_SUCCESS)
    status = PDM_S_SUCCESS;

  acl_list = PDU_acl_group_list;
  status = PDUload_acl_parts_mcf(acl_list);
  _pdm_status("PDUload_acl_parts_mcf", status);

  return(status);
}

int PDUupdate_state_form_after_move_state()
{
  int  status = PDM_S_SUCCESS;
  int  row = 0;
  int  column = 0;
  int  num_rows = 0;
  int  select, pos, length;
  int  field;
  char  *catalog = NULL;
  char  *partid = NULL;
  char  *revision = NULL;
  static char *text = NULL;
  Form form;
 

  _pdm_debug("in the function PDUupdate_state_form_after_move_state", 0);

  form = forms.move_state_form_id;
  field = PARTS_MCF;

  FIfld_get_num_rows(form, field, &num_rows);
  for (row = 0; row < num_rows; ++row)
     {
     _pdm_debug("searching for matching row in MCF", 0);
     _pdm_debug("row = %d", (char *)row);
     for (column = 0; column < 3; ++column)
        {
        FIfld_get_text_length(form, field, row, column, &length);
        text = (char *) malloc (sizeof (char) * length + 1);
        memset(text, NULL, sizeof (char) * length + 1);
        FIfld_get_text(form, field, row, column, length,
                      (unsigned char *)text, &select, &pos);

        if (column == 0) PDUfill_in_string(&catalog, text);
        else if (column == 1) PDUfill_in_string(&partid, text);
        else if (column == 2) PDUfill_in_string(&revision, text);
        PDUfree_string(&text);
        }

     _pdm_debug("checking cat/part/rev for NULL", 0);
     if ( catalog && partid && revision &&
          (strcmp(refresh->rev_catalog, catalog) == 0) &&
          (strcmp(refresh->rev_partid, partid) == 0) &&
          (strcmp(refresh->rev_revision, revision) == 0) )
       {
       _pdm_debug("deselecting row", 0);
       FImcf_set_select(form,field,row,FALSE);
       }
     }

  return(status);
}

int PDUremove_node_from_group_list(catalog, partid, revision)
  char   *catalog;
  char   *partid;
  char   *revision;
{

  int   status = PDM_S_SUCCESS;
  struct PDUacl_node *acl_list = NULL;

  _pdm_debug("PDUremove_node_from_group_list", 0);

  acl_list = PDU_acl_group_list;

  while (acl_list)
    {
    if ((strcmp(catalog, acl_list->catalog) == 0) &&
        (strcmp(partid, acl_list->partid) == 0) &&
        (strcmp(revision, acl_list->revision) == 0))
      {
      _pdm_debug("adding part back to PDU_acl_list", 0);
      status = PDUadd_node_to_acl_list( acl_list->catalog,
                                        acl_list->partid,
                                        acl_list->revision,
                                        acl_list->description,
                                        acl_list->filename,
                                        acl_list->parttype,
                                        acl_list->aclname,
                                        acl_list->state,
                                        acl_list->workflow,
                                        &PDU_acl_list);
      _pdm_status("PDUadd_node_to_acl_list", status);

      _pdm_debug("removing part from PDU_acl_group_list", 0);
      status = PDUdelete_node_from_acl_list(acl_list->catalog,
                                            acl_list->partid,
                                            acl_list->revision,
                                            &PDU_acl_group_list);
      _pdm_status("PDUdelete_node_from_acl_list", status);
      break;
      }
    acl_list = acl_list->next;
    }

  return(status);
}

int PDUdelete_current_state_from_states_buffer(states_bufr, temp_buffer)
MEMptr states_bufr;
MEMptr *temp_buffer;
{
  int   status = PDM_S_SUCCESS;
  int   row = 0;
  int   statename_col = 0;
  int   trans_col = 0;
  int   stateno_col = 0;
  int   status_col = 0;
  int   char_index = 0;
  char  cur_status[20];
  char  statename[41];
  char  transname[41];
  char  part_status[20];
  char  stateno[5];
  char  **data_row;
  char  *line = NULL;
  
  _pdm_debug("in the function PDUdelete_current_state_from_states_buffer", 0);

  if (!states_bufr)
    return(PDM_E_NULL_BUFFER);

  status = PDUformat_buffer (PDU_STATES_BUFFER, temp_buffer);
  _pdm_status("PDUformat_buffer", status);
 
  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }
 
  line = (char*) malloc ((*temp_buffer)->row_size);

  status = MEMbuild_array(states_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);
 
  status = PDUget_buffer_col(states_bufr, "n_statename", &statename_col);
  if (status != PDM_S_SUCCESS)
    return(status);
 
  status = PDUget_buffer_col(states_bufr, "n_stateno", &stateno_col);
  if (status != PDM_S_SUCCESS)
    return(status);
 
  status = PDUget_buffer_col(states_bufr, "n_transitionname", &trans_col);
  if (status != PDM_S_SUCCESS)
    return(status);
 
  status = PDUget_buffer_col(states_bufr, "n_status", &status_col);
  if (status != PDM_S_SUCCESS)
    return(status);
 
  PDUsetup_buffer(states_bufr, ROW, &data_row);

  cur_status[0] = '\0';
  for (row = 0; row < states_bufr->rows; ++row)
     {
     strcpy(cur_status, data_row[(states_bufr->columns * row) + status_col]);
     _pdm_debug("current status = <%s>", cur_status);
    
     if (strcmp(cur_status, "CURRENT STATE") != 0)
       {
       _pdm_debug("getting data from buffer", 0);
       strcpy(statename, data_row[(states_bufr->columns * row)+statename_col]);
       strcpy(transname, data_row[(states_bufr->columns * row) + trans_col]);
       strcpy(stateno, data_row[(states_bufr->columns * row) + stateno_col]);
       strcpy(part_status, data_row[(states_bufr->columns * row) + status_col]);

       memset (line, NULL, (*temp_buffer)->row_size);
       char_index = 0;

       if (strlen (statename ))
         PDUadd_buffer_string(line, &char_index, statename);
       else
         line[char_index++] = '\1';

       if (strlen (stateno ))
         PDUadd_buffer_string(line, &char_index, stateno);
       else
         line[char_index++] = '\1';

       if (strlen (transname ))
         PDUadd_buffer_string(line, &char_index, transname);
       else
         line[char_index++] = '\1';

       if (strlen (part_status ))
         PDUadd_buffer_string(line, &char_index, part_status);
       else
         line[char_index++] = '\1';

       _pdm_debug("line = <%s>", line);
       status = MEMwrite (*temp_buffer, line);
       _pdm_status("MEMwrite", status);
 
       if (status != MEM_S_SUCCESS)
         return(PDM_E_WRITE_BUFFER);
       }
     }

  if (PDM_debug_on)
    MEMprint_buffer("new states buffer", *temp_buffer, PDU_DEBUG_FILE);

  if (status == MEM_S_SUCCESS)
    status = PDM_S_SUCCESS;

  return(status);
}

int PDUload_acl_parts_mcf(parts_list)
struct  PDUacl_node  *parts_list;
{

  int  status = PDM_S_SUCCESS;
  int  row = 0;
  int  num_rows = 0;
  Form form;

  _pdm_debug("in the function PDUload_acl_parts_mcf", 0);

  if (!parts_list)
    {
    _pdm_debug("parts list is NULL", 0);
    return(PDM_E_NULL_BUFFER);
    }

  form = forms.move_state_form_id;

  while (parts_list)
    {
    FIfld_set_text(form, PARTS_MCF, row, 0, parts_list->catalog, FALSE);
    FIfld_set_text(form, PARTS_MCF, row, 1, parts_list->partid, FALSE);
    FIfld_set_text(form, PARTS_MCF, row, 2, parts_list->revision, FALSE);
    FIfld_set_text(form, PARTS_MCF, row, 3, parts_list->description, FALSE);
    ++row;
    parts_list = parts_list->next;
    }

  FIfld_set_num_rows(form, PARTS_MCF, row);
  _pdm_debug("num rows = %d", (char *)row);
  num_rows = row;

  for (row = 0; row < num_rows; ++row)
     FImcf_set_select(form, PARTS_MCF, row, TRUE);

  return(status);
}

int PDUfree_acl_structure(acl_list)
struct PDUacl_node **acl_list;
{
  struct PDUacl_node * head = NULL;
  long   status = PDM_S_SUCCESS;

  _pdm_debug("in the function PDUfree_acl_structure", 0);
 
  if (*acl_list)
    {
    head = *acl_list;
    while (*acl_list)
      {
      *acl_list = (*acl_list)->next;
      free(head);
      head = *acl_list;
      }
    *acl_list = NULL;
    }
  else
    status = PDM_E_NULL_BUFFER;
  return(status);
}
