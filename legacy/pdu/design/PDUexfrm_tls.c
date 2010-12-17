#include	<PDUstr.h>
#include	<PDUuser.h>
#include	<PDUerror.h>
#include        <PDUint.h>
#include        <PDUintdef.h>
#include        <PDUfile_def.h>
#include        <part_gadgets.h>
#include        <PDUforms.h>
#include        <PDUpart.h>
#include        <exdef.h>
#include        <errno.h>
#include        <MEMstruct.h>
#include        <MEMerrordef.h>
#include        <NFMerrordef.h>
#include        "PDUproto.h"
#include        "PDUcommand.h"
#include        "PDMproto.h"

static int static_gadget_label;
static short seed_file_form = FALSE;

int PDUprocess_ex_file_form(fp, label)

Form fp;
int label;

  {
  int status = PDM_S_SUCCESS;
  int length;
  int select;
  int no_headings;
  int all_flag;
  char **headings = NULL; 
  char *text = NULL;
  char *msg;
  int  responses[1];
  char *strings[1];
  int  pos;
  int state = 0;
  short file_exists = TRUE;
  short review = FALSE;


  extern struct PDUforms forms;
  extern struct PDUuser *user;
  extern struct PDUrefresh *refresh;
  extern Form PDU_form_id;
  extern int PDU_active_button;
  extern int *PDU_gadget_labels;
  extern int PDU_refresh_gadgets[7];
  extern int PDU_command;
  extern char ***PDU_update_struct;
  extern MEMptr PDU_ret_bufr;
  extern MEMptr PDU_part_file_buffer;
  extern int PDU_selected_rows;
  extern short PDU_edit_display;

  _pdm_debug("PDUprocess_ex_file_form", 0);
  forms.ex_file_form_id = fp;
  static_gadget_label = label;
  PDU_form_id = forms.ex_file_form_id;
  PDU_refresh_gadgets[0] = EX_PROJECT_FLD;
  PDU_refresh_gadgets[1] = EX_CATALOG_FLD;
  PDU_refresh_gadgets[2] = EX_PARTNUM_FLD;
  PDU_refresh_gadgets[3] = EX_REVISION_FLD;
  PDU_refresh_gadgets[5] = EX_DESCRIPTION;
  PDU_refresh_gadgets[6] = EX_FILENAME_FLD;

  PDUdismiss_subforms();
  switch (label)
    {
    case FI_CANCEL:
     
         seed_file_form = FALSE;
         break;

    case FI_ACCEPT:

         _pdm_debug("desc = <%s>", refresh->rev_description);
         
         if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0)
          && (refresh->rev_partid) && (strcmp(refresh->rev_partid, "") != 0) &&
            (refresh->rev_revision) && (strcmp(refresh->rev_revision, "") != 0))
           {
           if (PDUnullstr(user->username))
             {
             status = PDUautomatic_login(TRUE);
             _pdm_status("PDUautomatic_login", status);
             if (status != PDM_S_SUCCESS)
               {
               PDUmessage(status, 's');
               break;
               }
             break;
             }
           if (refresh->rev_filename == NULL)
             {
             PDUmessage(PDM_E_FILE_NULL, 's');
             return(0);
             }
           else if (strcmp(refresh->rev_filename, "") == 0)
             {
             PDUmessage(PDM_E_FILE_NULL, 's');
             return(0);
             }
           FIg_get_state(forms.ex_file_form_id, ASSEMBLY_DISPLAY, &state);
           _pdm_debug("state = <%d>", state);
           if (state)
             PDU_edit_display = TRUE;
           else
             PDU_edit_display = FALSE;
           FIg_get_state(forms.ex_file_form_id, 34, &state);
           if (state)
             review = TRUE;
           else
             review = FALSE;
           status = PDUverify_file(refresh->rev_filename);
           _pdm_status("PDUverify_file", status);
           if (status != PDM_S_SUCCESS)
             file_exists = FALSE;
             
           PDU_form_id = forms.ex_file_form_id;
           PDUfill_in_string(&refresh->act_catalog, refresh->rev_catalog);
           PDUfill_in_string(&refresh->act_partid, refresh->rev_partid);
           PDUfill_in_string(&refresh->act_revision, refresh->rev_revision);
           PDUfill_in_string(&refresh->act_filename, refresh->rev_filename);
           PDUfill_in_string(&refresh->act_parttype, refresh->rev_parttype);
           PDUfill_in_string(&refresh->act_description, refresh->rev_description);
           status = PDMrcheck_part_status(refresh->rev_catalog, 
                                          refresh->rev_partid, 
                                          refresh->rev_revision);
           _pdm_status("PDMrcheck_part_status", status);
           if (status == MEM_S_SUCCESS)
             {
             PDUmessage(PDM_E_ERROR_RETRIEVING_STATUS);
             break;
             }
          else if (((status == PDM_I_CHECKED_IN) || 
             (status == PDM_I_COPIED_TO_LOCAL_BY_YOU) ||
             (status == PDM_I_ATTACHED_TO_LOCAL_ASSY)) && !review)
             {
             PDU_command = -1;
             FIg_set_text(forms.ex_file_form_id, 15, "PduDummyFile");
             if (PDU_part_file_buffer)
               MEMclose(&PDU_part_file_buffer);

             /* Put checkout and activate command on queue */
             PDU_selected_rows = 0;
             responses[0] = EX_CMD_KEY;
             strings[0] = "PDChOtAcPr";
             status = PDUprepare_queue ( responses, strings, 1 );
             _pdm_status("PDUprepare_queue (checkout and activate)",status);

             /* Put a "Y" response for creating the dummy file */
             responses[0] = EX_STRING;
             strings[0] = "y";
             status = PDUprepare_queue ( responses, strings, 1 );
             _pdm_status("PDUprepare_queue",status);

             break;
             }

           else if (((status == PDM_I_CHECKED_IN) ||
                   (status == PDM_I_ATTACHED_TO_LOCAL_ASSY) ||
                   (status == PDM_I_CHECKED_OUT_BY_ANOTHER_USER)) && review)
            {
             FIg_set_text(forms.ex_file_form_id, 15, "PduDummyFile");

             /* Put copy local and activate command on queue */
             PDU_command = -1;
             PDU_selected_rows = 0;
             responses[0] = EX_CMD_KEY;
             strings[0] = "PDCpLcAc";
             status = PDUprepare_queue ( responses, strings, 1 );
             _pdm_status("PDUprepare_queue (copy local and activate)", status);

             /* Put a "Y" response for creating the dummy file */
             responses[0] = EX_STRING;
             strings[0] = "y";
             status = PDUprepare_queue ( responses, strings, 1 );
             _pdm_status("PDUprepare_queue",status);

             break;
            }

/* MJG - check to see if another user has checked out the file 6/28/94 */
            else if (status == PDM_I_CHECKED_OUT_BY_ANOTHER_USER)
             {
             _pdm_debug("file is checked out by another user", 0);
             FIg_set_text(forms.ex_file_form_id, 15, NULL_STRING);
             msg = (char *) PDUtranslate_message(status);
             FIg_set_text(forms.ex_file_form_id, FI_MSG_FIELD, msg);
             PDU_command = 0;
             PDUmessage(status, 's');
             FIg_set_state_off(forms.ex_file_form_id, FI_ACCEPT);
             return(0);
             }

           else if ((PDU_edit_display) && (file_exists))
            {
             responses[0] = EX_CMD_KEY;
             strings[0] = "PDMnDp";
             status = PDUprepare_queue ( responses, strings, 1 );
             _pdm_status("PDUprepare_queue (checkout part)",status);
            }
           else if (file_exists)
             {
             PDU_command = 0;
             }
           else if ((!file_exists) && (!seed_file_form))
             {
             FIf_erase(fp);
             status = PDUautomatic_seed_file();
             _pdm_status("PDUautomatic_seed_file", status);
             FIg_set_text(forms.ex_file_form_id, 15, "");
             seed_file_form = TRUE;
             return(0);
             }
           else if (!file_exists)
             {
             PDU_command = 0;
             responses[0] = EX_STRING;
             strings[0] = "y";
             status = PDUprepare_queue ( responses, strings, 1 );
             _pdm_status("PDUprepare_queue",status);
             }
           else if (review)
             {
             status = PDUchange_review_file_permissions(refresh->rev_filename,
                                                        FALSE);
             _pdm_status("PDUchange_review_file_permissions", status);
             }
              
            PDUupdate_active_part_info();
           /* ALR  TR139313379 & TR139311051 This does not need to be
              done here. At times there is not an active object space. */
            /*
            if (forms.design_form_id)
              {
              PDUcheck_file_for_origins();
              PDUcheck_file_for_parts();
              PDUcheck_if_file_an_assembly();
              }
            */
            status = PDM_S_SUCCESS;
            seed_file_form = FALSE;
           }
          break;
    case EX_PROJECT_FLD:

         if (PDUnullstr(user->username))
           {
           status = PDUautomatic_login(TRUE);
           _pdm_status("PDUautomatic_login", status);
           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }
           break;
           }
         PDU_form_id = forms.ex_file_form_id;
         refresh->rev_project = NULL;
         status = PDUep_proj_fld();
         _pdm_status("PDUep_proj_fld", status);

         if (status == 0)
           break;
         PDUmessage(status, 's');
         break;
 
    case EX_PROJECT_BTN:

         if (PDUnullstr(user->username))
           {
           status = PDUautomatic_login(TRUE);
           _pdm_status("PDUautomatic_login", status);
           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }
           break;
           }
         PDU_form_id = forms.ex_file_form_id;
         PDU_active_button = EX_PROJECT_BTN;
         status = PDUep_proj_btn();
         _pdm_status("PDUep_proj_btn", status);
         if (status == PDM_S_SUCCESS)
           FIfld_pos_cursor(fp, EX_CATALOG_FLD, 0,0,0,0,1,1);
         else
           FIg_set_state_off(fp, label);
         PDUmessage(status, 's');
         break;

    case EX_CATALOG_FLD:
         
         if (PDUnullstr(user->username))
           {
           status = PDUautomatic_login(TRUE);
           _pdm_status("PDUautomatic_login", status);
           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }
           break;
           }
         PDU_form_id = forms.ex_file_form_id;
         if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
           PDUfill_in_string(&refresh->rev_catalog, NULL);
         if ((refresh->rev_partid) && (strcmp(refresh->rev_partid, "") != 0))
           PDUfill_in_string(&refresh->rev_partid, NULL);
         if ((refresh->rev_revision) && 
             (strcmp(refresh->rev_revision, "") != 0))
           PDUfill_in_string(&refresh->rev_revision, NULL);
         if ((refresh->rev_description) && 
             (strcmp(refresh->rev_description, "") != 0))
           PDUfill_in_string(&refresh->rev_description, NULL);
         if ((refresh->rev_filename) && 
             (strcmp(refresh->rev_filename, "") != 0))
           PDUfill_in_string(&refresh->rev_filename, NULL);

         FIg_set_text(fp, EX_PARTNUM_FLD, "");
         FIg_set_text(fp, EX_REVISION_FLD, "");
         FIg_set_text(fp, EX_DESCRIPTION, "");
         FIg_set_text(fp, EX_FILENAME_FLD, "");

         status = PDUep_cat_fld();
         _pdm_status("PDUep_cat_fld", status);

         if (status == 0)
           break;
         PDUmessage(status, 's');
         break;

    case EX_CATALOG_BTN:

         PDU_active_button = label;
         if (PDUnullstr(user->username))
           {
           status = PDUautomatic_login(TRUE);
           _pdm_status("PDUautomatic_login", status);
           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }
           break;
           }
         PDU_form_id = forms.ex_file_form_id;

         if ((refresh->rev_partid) && (strcmp(refresh->rev_partid, "") != 0))
           PDUfill_in_string(&refresh->rev_partid, NULL);
         if ((refresh->rev_revision) && 
             (strcmp(refresh->rev_revision, "") != 0))
           PDUfill_in_string(&refresh->rev_revision, NULL);
         if ((refresh->rev_description) && 
             (strcmp(refresh->rev_description, "") != 0))
           PDUfill_in_string(&refresh->rev_description, NULL);
         if ((refresh->rev_filename) && 
             (strcmp(refresh->rev_filename, "") != 0))
           PDUfill_in_string(&refresh->rev_filename, NULL);

         FIg_set_text(fp, EX_PARTNUM_FLD, "");
         FIg_set_text(fp, EX_REVISION_FLD, "");
         FIg_set_text(fp, EX_DESCRIPTION, "");
         FIg_set_text(fp, EX_FILENAME_FLD, "");

         status = PDUep_cat_btn();
         _pdm_status("PDUep_cat_btn", status);
         break;

    case EX_PARTNUM_FLD:

         if (PDUnullstr(user->username))
           {
           status = PDUautomatic_login(TRUE);
           _pdm_status("PDUautomatic_login", status);
           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }
           break;
           }
         PDU_form_id = forms.ex_file_form_id;
         if ((refresh->rev_partid) && (strcmp(refresh->rev_partid, "") != 0))
           PDUfill_in_string(&refresh->rev_partid, NULL);
         if ((refresh->rev_revision) && 
             (strcmp(refresh->rev_revision, "") != 0))
           PDUfill_in_string(&refresh->rev_revision, NULL);
         if ((refresh->rev_description) && 
             (strcmp(refresh->rev_description, "") != 0))
           PDUfill_in_string(&refresh->rev_description, NULL);
         if ((refresh->rev_filename) && 
             (strcmp(refresh->rev_filename, "") != 0))
           PDUfill_in_string(&refresh->rev_filename, NULL);

         FIg_set_text(fp, EX_REVISION_FLD, "");
         FIg_set_text(fp, EX_DESCRIPTION, "");
         FIg_set_text(fp, EX_FILENAME_FLD, "");

         status = PDUep_part_fld();
         _pdm_status("PDUep_part_fld", status);
         
         if (status == 0)
           break;
        if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0) &&
            (refresh->rev_partid) && (strcmp(refresh->rev_partid, "") != 0) &&
            (refresh->rev_revision) && (strcmp(refresh->rev_revision, "") != 0))
          PDUget_filename_for_part(refresh->rev_catalog, refresh->rev_partid, 
                                 refresh->rev_revision, &refresh->rev_filename);
        if ((refresh->rev_filename) && (strcmp(refresh->rev_filename, "") != 0))
          {
          FIg_set_text(forms.ex_file_form_id, EX_FILENAME_FLD, 
                       refresh->rev_filename);
          FIg_set_text(forms.ex_file_form_id, 15, refresh->rev_filename);
          }
        else
          FIg_set_text(forms.ex_file_form_id, EX_FILENAME_FLD, "");
         PDUmessage(status, 's');
         break;

    case EX_PARTNUM_BTN:

         if (PDUnullstr(user->username))
           {
           status = PDUautomatic_login(TRUE);
           _pdm_status("PDUautomatic_login", status);
           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }
           break;
           }
         PDU_form_id = forms.ex_file_form_id;
         PDU_active_button = label;

         if ((refresh->rev_revision) && 
             (strcmp(refresh->rev_revision, "") != 0))
           PDUfill_in_string(&refresh->rev_revision, NULL);
         if ((refresh->rev_description) && 
             (strcmp(refresh->rev_description, "") != 0))
           PDUfill_in_string(&refresh->rev_description, NULL);
         if ((refresh->rev_filename) && 
             (strcmp(refresh->rev_filename, "") != 0))
           PDUfill_in_string(&refresh->rev_filename, NULL);

         FIg_set_text(fp, EX_REVISION_FLD, "");
         FIg_set_text(fp, EX_DESCRIPTION, "");
         FIg_set_text(fp, EX_FILENAME_FLD, "");
         
         status = PDUep_part_btn();
         _pdm_status("PDUep_part_btn", status);

         if (status == 0)
           break;
         PDUmessage(status, 's');
         break;

    case EX_REVISION_FLD:

         if (PDUnullstr(user->username))
           {
           status = PDUautomatic_login(TRUE);
           _pdm_status("PDUautomatic_login", status);
           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }
           break;
           }
         PDU_form_id = forms.ex_file_form_id;
         if ((refresh->rev_revision) && 
             (strcmp(refresh->rev_revision, "") != 0))
           PDUfill_in_string(&refresh->rev_revision, NULL);
         if ((refresh->rev_description) && 
             (strcmp(refresh->rev_description, "") != 0))
           PDUfill_in_string(&refresh->rev_description, NULL);
         if ((refresh->rev_filename) && 
             (strcmp(refresh->rev_filename, "") != 0))
           PDUfill_in_string(&refresh->rev_filename, NULL);

         FIg_set_text(fp, EX_DESCRIPTION, "");
         FIg_set_text(fp, EX_FILENAME_FLD, "");
         
         status = PDUep_rev_fld();
         _pdm_status("PDUep_rev_fld", status);

         if (status == 0)
           break;
        if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0) &&
            (refresh->rev_partid) && (strcmp(refresh->rev_partid, "") != 0) &&
            (refresh->rev_revision) && (strcmp(refresh->rev_revision, "") != 0))
          PDUget_filename_for_part(refresh->rev_catalog, refresh->rev_partid, 
                                 refresh->rev_revision, &refresh->rev_filename);
        if ((refresh->rev_filename) && (strcmp(refresh->rev_filename, "") != 0))
          {
          FIg_set_text(forms.ex_file_form_id, EX_FILENAME_FLD, 
                       refresh->rev_filename);
          FIg_set_text(forms.ex_file_form_id, 15, refresh->rev_filename);
          }
        else
          FIg_set_text(forms.ex_file_form_id, EX_FILENAME_FLD, "");
         PDUmessage(status, 's');
         break;

    case EX_REVISION_BTN:

         if (PDUnullstr(user->username))
           {
           status = PDUautomatic_login(TRUE);
           _pdm_status("PDUautomatic_login", status);
           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }
           break;
           }
         PDU_form_id = forms.ex_file_form_id;
         PDU_active_button = label;

         if ((refresh->rev_description) && 
             (strcmp(refresh->rev_description, "") != 0))
           PDUfill_in_string(&refresh->rev_description, NULL);
         if ((refresh->rev_filename) && 
             (strcmp(refresh->rev_filename, "") != 0))
           PDUfill_in_string(&refresh->rev_filename, NULL);

         FIg_set_text(fp, EX_DESCRIPTION, "");
         FIg_set_text(fp, EX_FILENAME_FLD, "");
         
         status = PDUep_rev_btn();
         _pdm_status("PDUep_rev_btn", status);
         
         if (status == 0)
           break;
         PDUmessage(status, 's');
         break;

    case EX_DESCRIPTION:

         if (PDUnullstr(user->username))
           {
           status = PDUautomatic_login(TRUE);
           _pdm_status("PDUautomatic_login", status);
           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }
           break;
           }
         PDU_form_id = forms.ex_file_form_id;
         if ((refresh->rev_description) && 
             (strcmp(refresh->rev_description, "") != 0))

         status = PDUep_desc_fld();
         _pdm_status("PDUep_desc_fld", status);

         if (status == 0)
           break;
         PDUmessage(status, 's');
         break;

    case EX_FILENAME_FLD:

         if (PDUnullstr(user->username))
           {
           status = PDUautomatic_login(TRUE);
           _pdm_status("PDUautomatic_login", status);
           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }
           break;
           }
         PDU_form_id = forms.ex_file_form_id;
         FIfld_get_text_length(fp, label, 0, 0, &length);
         text = (char *)malloc(sizeof (char) * (length + 1));
         memset(text, NULL, (length + 1));
         FIfld_get_text(fp, label, 0, 0, length, (unsigned char *)text, &select,
                        &pos);
         if (text == NULL)
           {
           refresh->rev_filename = NULL;
           break;
           }
         else if (strcmp(text, "") == 0)
           {
           refresh->rev_filename = NULL;
           break;
           }
  
         if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0) 
          && (refresh->rev_partid) && (strcmp(refresh->rev_partid, "") != 0) 
          && (refresh->rev_revision)
          && (strcmp(refresh->rev_revision, "") != 0))
           {
           status = PDUvalid_filename(refresh->rev_catalog, refresh->rev_partid,
                                      refresh->rev_revision, text);
           _pdm_status("PDUvalid_filename", status);
           if (status != PDM_S_SUCCESS)
             {
             FIg_set_text(fp, label, "");
             if ((refresh->rev_filename) && 
                 (strcmp(refresh->rev_filename, "") != 0))
               PDUfill_in_string(&refresh->rev_filename, NULL);
             FIfld_pos_cursor(fp, label, 0,0,0,0,1,1);
             PDUmessage(status, 's');
             break;
             }
           PDUfill_in_string(&refresh->rev_filename, text);
           FIg_set_text(fp, 15, text);
           }
         else
           {
           msg = (char *)PDUtranslate_message(PDM_I_ENTER_CAT_PRT_REV);
           FIg_set_text(fp, FI_MSG_FIELD,msg);
           break;
           }
         break;

    case EX_FILENAME_BTN:
   
         if (PDUnullstr(user->username))
           {
           status = PDUautomatic_login(TRUE);
           _pdm_status("PDUautomatic_login", status);
           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }
           break;
           }
         PDU_form_id = forms.ex_file_form_id;
         PDU_active_button = label;
         
         if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0) 
          && (refresh->rev_partid) && (strcmp(refresh->rev_partid, "") != 0) 
          && (refresh->rev_revision)
          && (strcmp(refresh->rev_revision, "") != 0))
           {
           if (PDU_ret_bufr)
             MEMclose(&PDU_ret_bufr);
           status = PDMget_filenames(refresh->rev_catalog, refresh->rev_partid,
                                     refresh->rev_revision, &PDU_ret_bufr);
           _pdm_status("PDMget_filenames", status);
           if ((status != PDM_S_SUCCESS) || (PDU_ret_bufr == NULL))
             {
             PDUmessage(status, 's');
             msg = (char *)PDUtranslate_message(PDM_E_NO_PART_FILES);
             FIg_set_text(fp, FI_MSG_FIELD, msg);
             if (PDU_ret_bufr)
               MEMclose(&PDU_ret_bufr);
             FIg_set_state_off(fp, label);
             break;
             }
           PDUsetup_single_buffer(PDU_ret_bufr);
           PDU_gadget_labels[0] = EX_FILENAME_FLD;
           PDU_update_struct[0] = &refresh->rev_filename;
           all_flag = FALSE;
           no_headings = 1;
           headings = (char **)malloc (sizeof (char *) * no_headings);
           memset(headings, NULL, sizeof(char *) * no_headings);
           PDUfill_in_string(&headings[0], "n_cofilename");
           PDUsetup_popup_list(headings, no_headings, all_flag, PDU_ret_bufr);
           PDUsetup_form_fields(headings, no_headings, all_flag, PDU_ret_bufr);
           PDUsetup_struct_fields(headings, no_headings, all_flag, 
                                 PDU_ret_bufr);
           PDUfree_string_array(&headings, no_headings);
           status = PDUsingle_list_form();
           }
         else
           {
           msg = (char *)PDUtranslate_message(PDM_I_ENTER_CAT_PRT_REV);
           FIg_set_text(fp, FI_MSG_FIELD,msg);
           break;
           }
         break;

    case SEARCH:

         if (PDUnullstr(user->username))
           {
           status = PDUautomatic_login(TRUE);
           _pdm_status("PDUautomatic_login", status);
           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }
           break;
           }
         PDU_form_id = forms.ex_file_form_id;
         FIf_erase(fp);
         SelectOrPlacePart(TRUE, FALSE, fp);
         break;

    }
  return(1);
  }

int PDUprocess_ex_file_form_after_select()

  {
  extern struct PDUrefresh *refresh;
  extern struct PDUforms forms;
  extern int PDU_command;
  int select, pos, len;

  _pdm_debug("PDUprocess_ex_file_form_after_select", 0);
  if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
    FIg_set_text(forms.ex_file_form_id, EX_CATALOG_FLD, refresh->rev_catalog);
  else
    FIg_set_text(forms.ex_file_form_id, EX_CATALOG_FLD, "");
  if ((refresh->rev_partid) && (strcmp(refresh->rev_partid, "") != 0))
    FIg_set_text(forms.ex_file_form_id, EX_PARTNUM_FLD, refresh->rev_partid);
  else
    FIg_set_text(forms.ex_file_form_id, EX_PARTNUM_FLD, "");
  if ((refresh->rev_revision) && (strcmp(refresh->rev_revision, "") != 0))
    FIg_set_text(forms.ex_file_form_id, EX_REVISION_FLD, refresh->rev_revision);
  else
    FIg_set_text(forms.ex_file_form_id, EX_REVISION_FLD, "");

  /* ALR  TR139416033  The get filename was overlaying the selected file */

  FIfld_get_text_length(forms.ex_file_form_id, EX_FILENAME_FLD, 0, 0, &len);
  refresh->rev_filename = (char *)malloc((sizeof(char) * len) + 1);
  FIfld_get_text(forms.ex_file_form_id, EX_FILENAME_FLD, 0, 0, len, (unsigned char *)refresh->rev_filename, &select, &pos);
  if ((strcmp(refresh->rev_filename,"") == 0) || (refresh->rev_filename == NULL))
  {
    if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0) &&
      (refresh->rev_partid) && (strcmp(refresh->rev_partid, "") != 0) &&
      (refresh->rev_revision) && (strcmp(refresh->rev_revision, "") != 0))
    PDUget_filename_for_part(refresh->rev_catalog, refresh->rev_partid, 
                              refresh->rev_revision, &refresh->rev_filename);
    if ((refresh->rev_filename) && (strcmp(refresh->rev_filename, "") != 0))
    {
    FIg_set_text(forms.ex_file_form_id, EX_FILENAME_FLD, refresh->rev_filename);
    FIg_set_text(forms.ex_file_form_id, 15, refresh->rev_filename);
    }
    else
     FIg_set_text(forms.ex_file_form_id, EX_FILENAME_FLD, "");
   }
   else
    FIg_set_text(forms.ex_file_form_id, 15, refresh->rev_filename);
    

  FIf_display(forms.ex_file_form_id);
  return(PDM_S_SUCCESS);
  }

void PDUprocess_ex_file_form_after_login()

  {
  extern struct PDUforms forms;

  _pdm_debug("PDUprocess_ex_file_form_after_login", 0);
  PDUprocess_ex_file_form(forms.ex_file_form_id, static_gadget_label);
  }

void PDUprocess_ex_file_form_after_seed_file()

  {
  extern struct PDUforms forms;
  extern struct PDUrefresh *refresh;

  _pdm_debug("PDUprocess_ex_file_form_after_seed_file", 0);
  FIg_set_text(forms.ex_file_form_id, 15, refresh->rev_filename);
  FIg_call_notification_routine(forms.ex_file_form_id, FI_ACCEPT);
  }
