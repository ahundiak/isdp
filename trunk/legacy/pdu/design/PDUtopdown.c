/****************************************************************************

 Document:        PDUtopdown.c

 Description:     This set of functions creates, initializes and displays a 
                  form for user input.  The data from the form is then 
                  processed in the notification routine.

 Return Status:   
                  PDM_S_SUCCESS    All data received from the form was correct
                  
 Notes:           The user is not allowed to exit the form until all
                  information is acceptable, so this function only returns
                  a successful status.  (Unless there is a problem with
                  I/FORMS)

 History:         April 1991          Mychelle Joiner          Created

****************************************************************************/

#include <stdio.h>
#include <FI.h>
#include <tools.h>
#include <PDUerror.h>
#include <PDMtypes.h>
#include <PDUstr.h>
#include <PDUcommand.h>
#include <PDUintdef.h>
#include <exdef.h>
#include "PDUform_def.h"
#include <PDUforms.h>
#include <PDUfile_def.h>
#include <PDUproto.h>
#include <PDUprompt.h>
#include "MEMerrordef.h"


/* Gadgets */

#define TD_CATALOG       34
#define TD_PARTID        35
#define TD_REVISION      36
#define TD_FILENAME      37
#define TD_DESC          12
#define CATALOG_BTN      67
#define PARTID_BTN       68
#define REVISION_BTN     69
#define FILENAME_BTN     13
#define SEARCH_BTN       15
#define PART_MCF         16
#define TD_FILETEXT      14
#define IDENTIFY_TEXT    17
#define MODEL_TEXT       11
#define TD_DESCTEXT      32


/* Externs */

extern char * calloc();
extern char * realloc();
extern char ***PDU_update_struct;
extern int new_mode;
extern int FIg_get_text_length();
extern int FIg_get_text();
extern int FImcf_get_active_col();
extern int FIg_get_text_length();
extern int FIfld_get_text();
extern int FIg_get_type();
extern int PDU_topdown_created;
extern int PDU_topdown_displayed;
extern int *PDU_gadget_labels;
extern int PDU_refresh_gadgets[7];
extern int PDU_active_button;
extern int PDU_command;
extern struct PDUrefresh  *refresh; 
extern struct PDUforms forms;
extern MEMptr PDU_ret_bufr;
extern MEMptr PDU_display_buffer;
extern MEMptr PDU_parts_list_buffer;
extern Form PDU_form_id;
extern int PDU_form_type;
extern short PDU_topdown_perm_window;
extern int PDMdebug_on;
extern short PDU_parts_list_displayed;
extern short PDU_second_row;
extern char    *PDU_save_project;
extern char    *PDU_save_catalog;
extern char    *PDU_save_partid;
extern char    *PDU_save_revision;
extern char    *PDU_save_description;
extern char    *PDU_save_filename;
extern char    *PDU_save_parttype;


int topdown_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  static char   * text;
  int             status = PDM_S_SUCCESS; 
  int             responses[1];
  int             all_flag;
  int             no_headings;
  int             select, pos, length;
  char            answer[5];
  char          * strings[1];
  char          * state = NULL;
  char          **headings = NULL;
  char 		* msg;

  PDU_form_id = fp;
  new_mode = FALSE;
  FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);

  switch ( g_label )
  {
    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

         _pdm_debug("f_label = <%d>", (char *)f_label);
         value = 0.0;
         _pdm_debug("converting form to permanent window", 0);
         FIf_cvrt_to_perm_win(forms.topdown_form_id);
         PDU_topdown_perm_window = TRUE;
	 status = PDUinitialize_help();
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }
         Help_topic("topdown");

         break;

    case FI_CVT_TO_PERM_WIN:     /* Member of group FI_CTRL_GROUP */

         PDU_topdown_perm_window = TRUE;
         break;

    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

         _pdm_debug("User selected the cancel button", 0);

         if (PDU_topdown_displayed == TRUE)
           {
           FIf_erase ( fp );
           PDU_topdown_displayed = FALSE;
           }
         if (PDU_topdown_created == TRUE)
           {
           FIf_delete ( fp );
           PDU_topdown_created = FALSE;
           }

         if (PDU_command == PDC_M_CREATE_TOP_DOWN)
           {
           refresh->status = PDM_I_FORM_CANCEL;
           responses[0] = RESET;
           strings[0] = "";
           PDUprepare_queue(responses, strings, 1);
           }

         break;

    case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */

         _pdm_debug("User selected the exit and save button", 0);

         if ((refresh->rev_catalog == NULL) ||
             (strcmp(refresh->rev_catalog, "") == 0))
           {
           msg = (char *)PDUtranslate_message(PDM_E_CAT_FIELD_BLANK);
           FIg_set_text(fp, FI_MSG_FIELD,msg);
           FIg_set_state_off(fp, FI_ACCEPT);
           break;
           }

         if ((refresh->rev_partid == NULL) ||
             (strcmp(refresh->rev_partid, "") == 0))
           {
           msg = (char  *)PDUtranslate_message(PDM_E_PART_FIELD_BLANK);
           FIg_set_text(fp, FI_MSG_FIELD,msg);
           FIg_set_state_off(fp, FI_ACCEPT);
           break;
           }

         if ((refresh->rev_revision == NULL) ||
             (strcmp(refresh->rev_revision, "") == 0))
           {
           msg = (char *)PDUtranslate_message(PDM_E_REV_FIELD_BLANK);
           FIg_set_text(fp, FI_MSG_FIELD,msg);
           FIg_set_state_off(fp, FI_ACCEPT);
           break;
           }

         if (PDU_command == PDC_M_CREATE_TOP_DOWN)
           {
           if ((refresh->rev_filename == NULL) ||
               (strcmp(refresh->rev_filename, "") == 0))
             {
             msg = (char *)PDUtranslate_message(PDM_E_FILENAME_BLANK);
             FIg_set_text(fp, FI_MSG_FIELD,msg);
             FIg_set_state_off(fp, FI_ACCEPT);
             break;
             }

           _pdm_debug("check to see if file already exists for TOPDOWN", 0);
           status = PDUverify_file(refresh->rev_filename);
           _pdm_status("PDUverify_file", status);
           if (status == PDM_S_SUCCESS)
             {
             _pdm_debug("file exists: display prompt", 0);
             msg = (char *) PDUtranslate_message_and_vars(
                          PDP_P_FILE_EXISTS, refresh->rev_filename);

             UI_prompt(msg);
             do
               {
               status = PDUget_keyin(answer);
     
               if ((answer) && (strlen(answer) > 0) &&
                   (strcmp(answer,"y")) && (strcmp(answer,"Y")) &&
                   (strcmp(answer,"n")) && (strcmp(answer,"N")))
                 {
                 status = PDM_E_INVALID_INPUT;
                 }
               }
             while (status == PDM_E_INVALID_INPUT);
             if (msg)
               {
               free(msg);
               msg = NULL;
               }
             msg = (char *) PDUtranslate_message(PDM_E_CLEAR_FIELD);
             UI_prompt(msg);
    
             _pdm_debug("answer = <%s>", answer);
             if ((strcmp(answer, "n")== 0) || (strcmp(answer, "N")==0))
               {
               msg = (char *) PDUtranslate_message(PDM_E_CLEAR_FIELD);
               FIg_set_text(fp, FI_MSG_FIELD,msg);
               FIg_set_text(fp, TD_FILENAME, NULL_STRING);
               PDUmessage(PDM_E_CLEAR_FIELD,'s');
               refresh->rev_filename = NULL;
               break;
               }
             }
  
           _pdm_debug("checking for cyclic placement", 0);
           if ((strcmp(refresh->rev_catalog, refresh->act_catalog) == 0) &&
               (strcmp(refresh->rev_partid, refresh->act_partid) == 0) &&
               (strcmp(refresh->rev_revision, refresh->act_revision) == 0))
             {
             msg = (char *)PDUtranslate_message(PDM_E_CYCLIC_1STLEVEL);
             FIg_set_text(fp, FI_MSG_FIELD, msg);
             FIg_set_state_off(fp, FI_ACCEPT);
             break;
             }
  
           status = PDUget_file_status(refresh->rev_catalog,refresh->rev_partid,
                                       refresh->rev_revision, &state);
           _pdm_status("PDUget_file_status", status);
  
           if (strcmp(state, "") != 0)
             {
             status = PDM_E_FILE_IN_DATABASE;
             PDUmessage(status, 's');
             FIg_set_state_off(fp, FI_ACCEPT);
             break;
             }

            refresh->status = PDM_S_SUCCESS;
            responses[0] = MOVE_ON;
            strings[0] = "";
            PDUprepare_queue(responses, strings, 1);
           }

         if (PDU_topdown_displayed == TRUE)
           {
           FIf_erase ( fp );
           PDU_topdown_displayed = FALSE;
           }
         if (PDU_topdown_created == TRUE)
           {
           FIf_delete ( fp );
           PDU_topdown_created = FALSE;
           }


         break;

    case TD_CATALOG: 

         refresh->rev_catalog = NULL_STRING;
         refresh->rev_partid = NULL_STRING;
         refresh->rev_revision = NULL_STRING;
         refresh->rev_description = NULL_STRING;
         if (PDU_command == PDC_M_CREATE_TOP_DOWN)
           refresh->rev_filename = NULL_STRING;

         FIg_set_text(fp, TD_PARTID, "");
         FIg_set_text(fp, TD_REVISION, "");
         FIg_set_text(fp, TD_DESC, "");
         if (PDU_command == PDC_M_CREATE_TOP_DOWN)
           FIg_set_text(fp, TD_FILENAME, "");

         _pdm_debug("Entering CATALOG",0);

         status = PDUep_cat_fld();
         _pdm_status("PDUep_cat_fld",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');

         break;

    case CATALOG_BTN:
         PDU_active_button = CATALOG_BTN;

         refresh->rev_partid = NULL_STRING;
         refresh->rev_revision = NULL_STRING;
         refresh->rev_description = NULL_STRING;
         if (PDU_command == PDC_M_CREATE_TOP_DOWN)
           refresh->rev_filename = NULL_STRING;

         FIg_set_text(fp, TD_PARTID, "");
         FIg_set_text(fp, TD_REVISION, "");
         FIg_set_text(fp, TD_DESC, "");
         if (PDU_command == PDC_M_CREATE_TOP_DOWN)
           FIg_set_text(fp, TD_FILENAME, "");

         status = PDUep_cat_btn();
         _pdm_status("PDUep_cat_btn",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');

         break;

    case TD_PARTID:     /* Sequenced to FIELD3    */

         refresh->rev_partid = NULL_STRING;
         refresh->rev_revision = NULL_STRING;
         refresh->rev_description = NULL_STRING;
         if (PDU_command == PDC_M_CREATE_TOP_DOWN)
           refresh->rev_filename = NULL_STRING;

         FIg_set_text(fp, TD_REVISION, "");
         FIg_set_text(fp, TD_DESC, "");
         if (PDU_command == PDC_M_CREATE_TOP_DOWN)
           FIg_set_text(fp, TD_FILENAME, "");

         _pdm_debug("Entering PARTNUM",0);

         status = PDUep_part_fld();
         _pdm_status("PDUep_part_fld",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');

         if (PDU_command == PDC_M_CREATE_TOP_DOWN)
           {
           status = PDUcheck_topdown_files();
           _pdm_status("PDUcheck_topdown_files", status);
           if (status != PDM_S_SUCCESS)
             PDUmessage(status, 's');
           }

         break;

    case PARTID_BTN:
         PDU_active_button = PARTID_BTN;

         refresh->rev_revision = NULL_STRING;
         refresh->rev_description = NULL_STRING;
         if (PDU_command == PDC_M_CREATE_TOP_DOWN)
           refresh->rev_filename = NULL_STRING;

         FIg_set_text(fp, TD_REVISION, "");
         FIg_set_text(fp, TD_DESC, "");
         if (PDU_command == PDC_M_CREATE_TOP_DOWN)
           FIg_set_text(fp, TD_FILENAME, "");

         _pdm_debug("Entering LIST_PARTS",0);

         status = PDUep_part_btn();
         _pdm_status("PDUep_part_btn",status);

         if (status == 0)
            break;

         PDUmessage(status,'s');

         break;

    case TD_REVISION:     /* Sequenced to FIELD4    */

         refresh->rev_revision = NULL_STRING;
         refresh->rev_description = NULL_STRING;
         if (PDU_command == PDC_M_CREATE_TOP_DOWN)
           refresh->rev_filename = NULL_STRING;

         FIg_set_text(fp, TD_DESC, "");
         if (PDU_command == PDC_M_CREATE_TOP_DOWN)
           FIg_set_text(fp, TD_FILENAME, "");

         _pdm_debug("Entering EP_REV_FLD",0);

         status = PDUep_rev_fld();
         _pdm_status("PDUep_rev_fld",status);

         if (status == 0)
            break;

         PDUmessage(status, 's');

         if (PDU_command == PDC_M_CREATE_TOP_DOWN)
           {
           status = PDUcheck_topdown_files();
           _pdm_status("PDUcheck_topdown_files", status);
           if (status != PDM_S_SUCCESS)
             PDUmessage(status, 's');
           }

         break;

    case REVISION_BTN:
         PDU_active_button = REVISION_BTN;

         refresh->rev_description = NULL_STRING;
         if (PDU_command == PDC_M_CREATE_TOP_DOWN)
           refresh->rev_filename = NULL_STRING;

         FIg_set_text(fp, TD_DESC, "");
         if (PDU_command == PDC_M_CREATE_TOP_DOWN)
           FIg_set_text(fp, TD_FILENAME, "");

         _pdm_debug("Entering EP_REV_BTN",0);

         status = PDUep_rev_btn();
         _pdm_status("PDUep_rev_btn",status);

         if (status == 0)
            break;

         PDUmessage(status,'s');
         break;

    case TD_DESC:

         refresh->rev_description = NULL_STRING;

         _pdm_debug("Entering EP_DESC_BTN",0);

         status = PDUep_desc_fld();
         _pdm_status("PDUep_desc_fld",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');

         break;

    case TD_FILENAME:         /* Field Type:    ASCII    */

         /* verify part is in part selection area */
          if ((refresh->rev_catalog == NULL) ||
              (strcmp(refresh->rev_catalog, "") == 0))
            {
            msg = (char *)PDUtranslate_message(PDM_I_ENTER_CAT_PRT_REV);
            FIg_set_text(fp, FI_MSG_FIELD,msg);
            break;
            }

          if ((refresh->rev_partid == NULL) ||
              (strcmp(refresh->rev_partid, "") == 0))
            {
            msg = (char *)PDUtranslate_message(PDM_I_ENTER_CAT_PRT_REV);
            FIg_set_text(fp, FI_MSG_FIELD,msg);
            break;
            }

          if ((refresh->rev_revision == NULL) ||
              (strcmp(refresh->rev_revision, "") == 0))
            {
            msg = (char *)PDUtranslate_message(PDM_I_ENTER_CAT_PRT_REV);
            FIg_set_text(fp, FI_MSG_FIELD,msg);
            break;
          }

         _pdm_debug("Getting the filename", 0);
	 FIfld_get_text_length(fp, TD_FILENAME, 0, 0, &length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp, TD_FILENAME, 0, 0, length, (unsigned char*)text, 
                        &select, &pos);

         if ((strcmp(text, "") == 0) || (text == NULL))
           {
           refresh->rev_filename = NULL_STRING;
           break;
           }

         status = PDUvalid_filename(refresh->rev_catalog,
                                    refresh->rev_partid,
                                    refresh->rev_revision,
                                    text);
         _pdm_status("PDUvalid_filename", status);

        if (status != PDM_S_SUCCESS)
           {
           FIg_set_text(fp, TD_FILENAME, "");
           refresh->rev_filename = NULL_STRING;
           FIfld_pos_cursor(fp, TD_FILENAME, 0,0,0,0,1,1);
           PDUmessage(status, 's');
           break;
           }

         PDUfill_in_string(&refresh->rev_filename, text);

         break;

    case FILENAME_BTN:
         PDU_active_button = FILENAME_BTN;

         if (refresh->rev_catalog == NULL)
           {
           msg = (char *)PDUtranslate_message(PDM_I_ENTER_CAT_PRT_REV);
           FIg_set_text(fp, FI_MSG_FIELD,msg);
           break;
           }

         if (refresh->rev_partid == NULL)
           {
           msg = (char *)PDUtranslate_message(PDM_I_ENTER_CAT_PRT_REV);
           FIg_set_text(fp, FI_MSG_FIELD,msg);
           break;
           }

         if (refresh->rev_revision == NULL)
           {
           msg = (char *)PDUtranslate_message(PDM_I_ENTER_CAT_PRT_REV);
           FIg_set_text(fp, FI_MSG_FIELD,msg);
           break;
           }

         /* call PDM function to retrieve a list of filenames */
         if (PDU_ret_bufr != NULL)
           {
           MEMclose(&PDU_ret_bufr);
           PDU_ret_bufr = NULL;
           }

         status = PDMget_filenames(refresh->rev_catalog,refresh->rev_partid,
                         refresh->rev_revision, &PDU_ret_bufr);
         _pdm_status("PDMget_filenames", status);

         if ( status != PDM_S_SUCCESS )
           {
           msg = (char *)PDUtranslate_message(PDM_E_RET_LIST_FILENAMES);
           FIg_set_text(fp,FI_MSG_FIELD,msg);
           MEMclose(&PDU_ret_bufr);
           break;
           }

         if ((PDU_ret_bufr == NULL) && (PDU_ret_bufr->rows))
           {
           msg = (char *)PDUtranslate_message(PDM_E_NO_PART_FILES);
           FIg_set_text(fp, FI_MSG_FIELD,msg);
           break;
           }

         PDUsetup_single_buffer(PDU_ret_bufr);
         PDU_form_id = fp;
         PDU_gadget_labels[0] = TD_FILENAME;
         PDU_update_struct[0] = &refresh->rev_filename;

         all_flag = FALSE;
         no_headings = 1;
         headings = (char **) malloc (sizeof (char *) * no_headings);
         memset(headings, NULL, sizeof (char *) * no_headings);

         PDUfill_in_string(&headings[0], "n_cofilename");

         PDUsetup_popup_list(headings, no_headings, all_flag, PDU_ret_bufr);
         PDUsetup_form_fields(headings, no_headings, all_flag, PDU_ret_bufr);
         PDUsetup_struct_fields(headings, no_headings, all_flag, PDU_ret_bufr);

         PDUfree_string_array(&headings, no_headings);

         status = PDUsingle_list_form();
         break;

    case SEARCH_BTN:

	 /* save the part that is in the refresh */
         if (refresh->rev_project)
           PDUfill_in_string(&PDU_save_project, refresh->rev_project);
         else
           PDU_save_project = NULL_STRING;

         if (refresh->rev_catalog)
           PDUfill_in_string(&PDU_save_catalog, refresh->rev_catalog);
         else
           PDU_save_catalog = NULL_STRING;

         if (refresh->rev_partid)
           PDUfill_in_string(&PDU_save_partid, refresh->rev_partid);
         else
           PDU_save_partid = NULL_STRING;

         if (refresh->rev_revision)
           PDUfill_in_string(&PDU_save_revision, refresh->rev_revision);
         else
           PDU_save_revision = NULL_STRING;

         if (refresh->rev_description)
           PDUfill_in_string(&PDU_save_description, refresh->rev_description);
         else
           PDU_save_description = NULL_STRING;

         if (refresh->rev_filename)
           PDUfill_in_string(&PDU_save_filename, refresh->rev_filename);
         else
           PDU_save_filename = NULL_STRING;

         if (refresh->rev_parttype)
           PDUfill_in_string(&PDU_save_parttype, refresh->rev_parttype);
         else
           PDU_save_parttype = NULL_STRING;

         refresh->rev_project = NULL_STRING;
         refresh->rev_catalog = NULL_STRING;
         refresh->rev_partid = NULL_STRING;
         refresh->rev_revision = NULL_STRING;
         refresh->rev_description = NULL_STRING;
         refresh->rev_filename = NULL_STRING;
         refresh->rev_parttype = NULL_STRING;

	 FIf_erase(fp);
	 _pdm_debug("calling part selection form", 0);
         SelectOrPlacePart(TRUE, FALSE, fp);

         break;

  } /* END switch ( g_label ) */


  return(status);

} /* END notification_routine() */

/* This function loads/creates, initializes, and displays the topdown form. */

int PDUtopdown_form()
{
  int  sts = PDM_S_SUCCESS;

  if (PDU_topdown_displayed == TRUE)
    return(sts);

  PDU_topdown_created = FALSE;
  PDU_topdown_displayed = FALSE;
  PDU_topdown_perm_window = FALSE;

  _pdm_debug("Creating topdown form", 0);
  sts = FIf_new(TOPDOWN_FORM, "topdown", topdown_notification_routine,
                &forms.topdown_form_id);
  PDU_topdown_created = TRUE;

  /* initialize refresh gadgets */
  PDU_refresh_gadgets[1] = TD_CATALOG;
  PDU_refresh_gadgets[2] = TD_PARTID;
  PDU_refresh_gadgets[3] = TD_REVISION;
  PDU_refresh_gadgets[5] = TD_DESC;

  if (PDMdebug_on)
    {
    _pdm_debug("converting form to permanent window", 0);
    FIf_cvrt_to_perm_win(forms.topdown_form_id);
    PDU_topdown_perm_window = TRUE;
    }

  if (PDU_command != PDC_M_CREATE_TOP_DOWN)
    {
    _pdm_debug("deleting topdown gadgets", 0);
    FIg_delete(forms.topdown_form_id, TD_FILETEXT);
    FIg_delete(forms.topdown_form_id, TD_FILENAME);
    FIg_delete(forms.topdown_form_id, FILENAME_BTN);
    FIg_delete(forms.topdown_form_id, IDENTIFY_TEXT);
    FIg_delete(forms.topdown_form_id, SEARCH_BTN);

    FIg_display(forms.topdown_form_id, MODEL_TEXT);

    _pdm_debug("moving description gadgets", 0);
    FIg_set_location(forms.topdown_form_id, TD_DESCTEXT, 35, 135);
    FIg_set_location(forms.topdown_form_id, TD_DESC, 145, 135);
    }

  FIf_set_orig_coord(forms.topdown_form_id, 409, 285);
  
  _pdm_debug("Displaying the topdown form", 0);
  sts = FIf_display(forms.topdown_form_id);
  PDU_topdown_displayed = TRUE;

  return(sts); 
}

int PDUcheck_topdown_files()
{
  int       status = PDM_S_SUCCESS;
  int       file_col;
  char      **data_row;
  char      *file = NULL;
  MEMptr    ret_bufr = NULL;

    _pdm_debug("in the function PDUcheck_topdown_files", 0);

    _pdm_debug("checking refresh for retrieving filenames", 0);

    _pdm_debug("refresh->rev_catalog = <%s>", refresh->rev_catalog);
    _pdm_debug("refresh->rev_partid = <%s>", refresh->rev_partid);
    _pdm_debug("refresh->rev_revision = <%s>", refresh->rev_revision);

    if (!refresh->rev_filename)
      refresh->rev_filename = NULL_STRING;

    if (((strcmp(refresh->rev_catalog, "") != 0)  &&
        (refresh->rev_catalog != NULL)           &&
        (strcmp(refresh->rev_partid, "") != 0)   &&
        (refresh->rev_partid != NULL)            &&
        (strcmp(refresh->rev_revision, "") != 0) &&
        (refresh->rev_revision != NULL))         &&
        ((strcmp(refresh->rev_filename, "") == 0)))
      {
      /* call PDM function to retrieve a list of filenames */
      status = PDMget_filenames(refresh->rev_catalog,refresh->rev_partid,
                      refresh->rev_revision, &ret_bufr);
      _pdm_status("PDMget_filenames", status);

      if ( status != PDM_S_SUCCESS )
        {
        PDUmessage(status, 's');
        MEMclose(&ret_bufr);
        return(status);
        }

      if ((ret_bufr == NULL) || (ret_bufr->rows == 0))
        {
        status = PDM_I_NO_FILES_FOUND;
        PDUmessage(status, 's');
        MEMclose(&ret_bufr);
        return(status);
        }

      MEMbuild_array(ret_bufr);
      PDUsetup_buffer(ret_bufr, ROW, &data_row);
      PDUget_buffer_col(ret_bufr, "n_cofilename", &file_col);
  
      PDUfill_in_string(&file, data_row[(ret_bufr->columns) * 0 + file_col]);
      if ((strcmp(file, "") != 0) && (file != NULL))
        {
        PDUfill_in_string(&refresh->rev_filename, file);
        FIg_set_text(forms.topdown_form_id, TD_FILENAME,refresh->rev_filename);
        }
      }

  _pdm_debug("exiting PDUcheck_topdown_files", 0);
  return(status);
}

int PDUload_parts_list()
{
int           all_flag = FALSE;
int           no_headings;
int           status = PDM_S_SUCCESS;
char          **headings;
char	      *msg;

  _pdm_debug("In the function PDUload_parts_list", 0);

  if ((PDU_parts_list_buffer == NULL) || (PDU_parts_list_buffer->rows == 0))
    {
    msg = (char *)PDUtranslate_message(PDM_E_NO_PARTS_FOUND);
    FIg_set_text(forms.topdown_form_id, FI_MSG_FIELD,msg);
    PDUmessage(PDM_E_SEARCH_CATALOG, 's');
    FIf_display(forms.topdown_form_id);
    return(status);
    }

  _pdm_debug("initializing parts list form", 0);
  PDUparts_list_form();

  PDUsetup_single_buffer(PDU_parts_list_buffer);

  all_flag = FALSE;
  no_headings = 4;
  headings = (char **) malloc (sizeof (char *) * no_headings);
  memset(headings, NULL, sizeof (char *) * no_headings);

  PDUfill_in_string(&headings[0], "n_catalogname");
  PDUfill_in_string(&headings[1], "n_itemname");
  PDUfill_in_string(&headings[2], "n_itemrev");
  PDUfill_in_string(&headings[3], "n_itemdesc");

  PDUsetup_popup_list(headings, no_headings, all_flag, PDU_parts_list_buffer);

  PDUfree_string_array(&headings, no_headings);

  PDU_second_row = FALSE;
  PDUbufr_to_mcf(PDU_parts_list_buffer,forms.parts_list_form_id,PART_MCF);

  FIfld_set_num_rows(forms.parts_list_form_id, PART_MCF,
                     PDU_parts_list_buffer->rows);

  MEMclose(&PDU_parts_list_buffer);
  PDU_parts_list_buffer = NULL;

  /* Display the parts_list form and set the displayed flag to TRUE. */
  _pdm_debug("Displaying the parts_list form", 0);

  FIf_display(forms.parts_list_form_id);
  PDU_parts_list_displayed = TRUE;

  return(status);

}  /* end PDUload_parts_list */
