#include <stdio.h>
#include "FI.h"
#include "tools.h"
#include "exdef.h"
#include "PDUstr.h"
#include "PDUuser.h"
#include <PDUforms.h>
#include "PDUform_def.h"
#include "PDUfile_def.h"
#include "PDUerror.h"
#include "PDUintdef.h"
#include "PDUextdef.h"
#include "PDUprompt.h"
#include "PDUassy.h"
#include "PDUcommand.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "part_gadgets.h"
#include "SQLerrordef.h"
#include "PDMmessage.h"
#include "PDUproto.h"
#include "PDMproto.h"

/* Gadgets */

#define ROLL_THROUGH             47
#define CHECKIN_BTN              33
#define LOGOUT_BTN               82
#define MCF_LIST_GRP             65
#define LIST_MCF                 11
#define DELETE_LOCAL_BTN         36
#define DESIGN                   46
#define REV_STRUCT_BTN           49
#define CATALOG_BTN              50
#define PARTS_BTN                51
#define REPORTS_BTN              54
#define SEARCH_PARTS_BTN         19
#define LIST_FILES_BTN           66
#define LIST_PARTS_IN_CAT_BTN    56
#define USERNAME_FLD             86
#define SERVER_FLD               87
#define ENV_FLD                  88
#define PART_MCF_HEADING         30
#define PROJECT_LIST_BTN        108
#define CATALOG_LIST_BTN        109
#define PARTNUM_LIST_BTN        110
#define REVISION_LIST_BTN       111
#define FILENAME_LIST_BTN       112
#define WHERE_USED               52
#define STRUCTURE_LIST_GRP       71
#define STRUCTURE_MCF            57
#define REVIEW_DESIGN            72
#define PARM_PARTS_BTN           14
#define UPDATE_DATABASE          75
#define COPY_LOCAL_BTN           32
#define CHECKOUT_BTN             25
#define DELETE_PART              76
#define FLAG                     78
#define MOVE_STATE               77
#define SELECT_ALL               80
#define DESELECT_ALL             81
#define EDIT_ASSEMBLY_TGL        87
#define REVISE_ASSEMBLY_BTN      89

/* Gadgets from other forms */
#define ASSY_SELECT_GRP          64
#define PART_SEARCH_MCF          59

/* Gadgets from TOPDOWN form */
#define TD_CATALOG       34
#define TD_PARTID        35
#define TD_REVISION      36
#define TD_FILENAME      37
#define TD_DESC          12


/* Externs */

extern char *   calloc();
extern char *   realloc();
extern char   * PDU_cat_sort_string;
extern char   * PDU_part_sort_string;
extern char    *PDU_dyn_cat_search;
extern char    *PDU_dyn_part_search;
extern char *** PDU_update_struct;
extern char    *PDU_save_project;
extern char    *PDU_save_catalog;
extern char    *PDU_save_partid;
extern char    *PDU_save_revision;
extern char    *PDU_save_description;
extern char    *PDU_save_filename;
extern char    *PDU_save_parttype;
extern char    *ep_project;
extern char    *ep_catalog;
extern char    *en_itemname;
extern char    *ep_rev;
extern char    *ep_desc;
extern char    *PDU_search_format;
extern int  *   PDU_gadget_labels;
extern int      PDU_refresh_gadgets[7];
extern int  *   PDU_parts_index;
extern int      PDU_command;
extern int      PDU_selected_rows;
extern int      PDU_checkout_type;
extern int      PDU_gadget_label;
extern int      PDU_mcf_list;
extern int      PDU_list_files;
extern int      PDU_form_type;
extern int      PDU_search_type;
extern int      FIg_get_text_length();
extern int      FIg_get_text();
extern int      FImcf_get_active_col();
extern int      FIfld_get_text();
extern int      FIg_get_type();
extern int      PDU_local_files_created;
extern int      PDU_local_files_displayed;
extern int      PDU_single_list_displayed;
extern int      PDU_single_list_created;
extern int      PDU_mcf_list_displayed;
extern int      PDU_mcf_list_created;
extern int      PDU_file_list_created;
extern int      PDU_file_list_displayed;
extern int      PDU_cat_list_displayed;
extern int      PDU_cat_list_created;
extern int      PDU_check_filename;
extern int      project_flag;
extern int      catalog_flag;
extern int      PDU_act_row;
extern int      PDU_login;
extern int      PDU_active_button;
extern int      bufr_flag;
extern int      PDMdebug_on;
extern int      PDU_list_cat;
extern int      end_np_cat_btn_flag;
extern int      end_np_part_btn_flag;
extern int      end_np_parttype_btn_flag;
extern int      end_ep_proj_btn_flag;
extern int      end_ep_cat_btn_flag;
extern int      end_ep_part_fld_flag;
extern int      end_ep_part_btn_flag;
extern int      end_ep_rev_btn_flag;
extern int      end_ep_desc_fld_flag;
extern int      end_ep_desc_btn_flag;
extern int      end_move_to_state_btn_flag;
extern int      pdu_hold_stg_bufr_flag;
extern int      pdu_ep_stg_bufr_flag;
extern int      pdu_hold_acl_bufr_flag;
extern int      pdu_ep_acl_bufr_flag;
extern int      PDU_active_list;
extern short    PDU_files_deleted;
extern short    PDU_list_filenames;
extern short    PDU_check_file_refresh;
extern short    PDU_select_area;
extern short    PDU_second_row;
extern short    PDU_structure_list;
extern short    PDU_load_file_buffer;
extern short    PDU_local_perm_window;
extern short    PDU_perm_window;
extern short    PDU_assy_perm_window;
extern short    PDU_where_used_perm_window;
extern short    PDU_activate_copy;
extern short    PDU_param_cat;
extern short    PDU_main_form_cat;
extern short    PDU_chkout_single;
extern short    PDU_edit_display;
extern short    PDU_extadmin;
extern short    PDU_flag_form_created;
extern short    PDU_flag_form_displayed;
extern short    PDU_flag_perm_window;
extern Form     PDU_form_id;
extern Form     PDU_calling_form;
extern Form     place_part_f;
extern Form     ModifyPartForm;
extern MEMptr   PDU_ret_bufr;
extern MEMptr   PDU_storage_area;
extern MEMptr   PDU_parts_list_bufr;
extern MEMptr   PDU_login_data;
extern MEMptr   PDU_login_attrs;
extern MEMptr   PDU_wf_buffer;
extern MEMptr   PDU_assy_parts_bufr;
extern MEMptr   PDU_part_file_buffer;
extern MEMptr   PDU_delete_buffer;
extern MEMptr   PDUsearch_part_list;
extern struct   PDUrefresh   *refresh;
extern struct   PDUuser      *user;
extern struct   PDUforms     forms;


int PDUsetup_env()
{
   /* set up server, username and environment in read-only fields */
   _pdm_debug("setting up read-only fields", 0);
   FIfld_set_text(forms.local_files_form_id, USERNAME_FLD, 0, 0,
                           user->username, FALSE);
   FIfld_set_text(forms.local_files_form_id, ENV_FLD, 0, 0,
                           user->environment, FALSE);

   return(PDM_S_SUCCESS);
}

int local_files_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  static char   * text;
  int             status = PDM_S_SUCCESS;
  int             status1 = PDM_S_SUCCESS;
  int             column = 0;
  int             row = 0;
  int             act_row = 0;
  int             act_pos = 0;
  int             no_headings = 0;
  int             all_flag = 0;
  int             ptype_col = 0;
  int             select, pos = 0;
  int             length = 0;
  int             responses[1];
  int             level = 0;
  int             num_rows = 0;
  int             file_col = 0;
  int             desc_col = 0;
  int             type_col = 0;
  int             mcf_select = FALSE;
  int             part_count = 0;
  int             field = 0;
  int             state = 0;
  char          * strings[1];
  char         ** headings = NULL;
  char         ** list_row;
  char         ** data_row;
  char            type[5];
  char            answer[5];
  char            *prompt_str = NULL;
  char            *msg = NULL;
  char            *save_string = NULL;
  extern void     PDUclear_mcf();
  extern void     PDUreset_local_files_form();
  extern void     PDUset_edit_assy_toggle_after_select();
  MEMptr          ret_bufr = NULL;
  int           display = 0;

  FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
  FIg_set_text(fp, FI_PROMPT_FIELD, NULL_STRING);
  fp = forms.local_files_form_id;
  PDU_form_id = forms.local_files_form_id;
  PDU_check_filename = FALSE;
  PDU_list_filenames = FALSE;
  PDU_check_file_refresh = FALSE;
  PDU_command = 0;
  refresh->command = 0;
  PDU_local_files_displayed = TRUE;
  PDU_main_form_cat = FALSE;
  PDU_load_file_buffer = FALSE;
  PDUmessage(PDM_E_CLEAR_FIELD, 's');
  PDU_part_sort_string = NULL;
  PDU_activate_copy = FALSE;
  PDU_list_cat = FALSE;

  PDUdismiss_subforms();

  switch ( g_label )
  {
    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

         _pdm_debug ("User selected the HELP button", 0);
         if (PDU_local_perm_window == FALSE)
           {
           FIf_cvrt_to_perm_win(forms.local_files_form_id);
           PDU_local_perm_window = TRUE;
           }
         status = PDUinitialize_help();
         _pdm_status("PDUinitialize_help", status);
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }
         Help_topic("local_files");
         break;

    case FI_CVT_TO_PERM_WIN:     /* Member of group FI_CTRL_GROUP */

        value = 0.0;
        f_label = 0;

        PDU_local_perm_window = TRUE;
        break;

    case FI_CANCEL:

         _pdm_debug ("User selected the CANCEL button", 0);

         if (forms.flag_form_id)
           {
           FIf_is_displayed(forms.flag_form_id, &display);
           if (display)
             {
             FIf_erase( forms.flag_form_id );
             FIf_delete( forms.flag_form_id );
             PDU_flag_form_displayed = FALSE;
             PDU_flag_form_created = FALSE;
             PDU_flag_perm_window = FALSE;
             }
           }

         FIf_erase(forms.local_files_form_id);
         PDU_local_files_displayed = FALSE;
         break;

    case FI_RESET:     /* Member of group FI_CTRL_GROUP */

         _pdm_debug ("User selected the RESET button", 0);
         PDUreset_local_files_form();

         PDU_command = 0;
         FIfld_pos_cursor(forms.local_files_form_id, CATALOG_FLD, 0,0,0,0,1,1);

         /* reset the refresh fields */
         PDUfill_in_string(&refresh->rev_project, "");
         PDUfill_in_string(&refresh->rev_catalog, "");
         PDUfill_in_string(&refresh->rev_partid, "");
         PDUfill_in_string(&refresh->rev_revision, "");
         PDUfill_in_string(&refresh->rev_description, "");
         PDUfill_in_string(&refresh->rev_filename, "");
         PDUfill_in_string(&refresh->rev_parttype, "");
          
         break;

    case LOGOUT_BTN:     

         FIg_disable(fp, LOGOUT_BTN);
         PDU_form_id = forms.local_files_form_id;
         break;

    /* Fields in the part selection area */

    case PROJECT_FLD:         /* Field Type:    ASCII    */

         refresh->rev_project = NULL;

         refresh->rev_filename = NULL;
         FIg_set_text(fp, PART_FILE_FLD, "");

         _pdm_debug("Entering PROJECT",0);

         status = PDUep_proj_fld();
         _pdm_status("PDUep_proj_fld",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');
         status = PDUcheck_file_commands();
         _pdm_status("PDUcheck_file_commands", status);
         break;

    case CATALOG_FLD:         /* Field Type:    ASCII    */

         refresh->rev_catalog = NULL;
         refresh->rev_partid = NULL;
         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;

         FIg_set_text(fp, PARTNUM_FLD, "");
         FIg_set_text(fp, PART_REV_FLD, "");
         FIg_set_text(fp, PART_DESC_FLD, "");
         FIg_set_text(fp, PART_FILE_FLD, "");

         _pdm_debug("Entering CATALOG",0);

         PDU_main_form_cat = TRUE;

         status = PDUep_cat_fld();
         _pdm_status("PDUep_cat_fld",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');
         status = PDUcheck_file_commands();
         _pdm_status("PDUcheck_file_commands", status);
         break;

    case PARTNUM_FLD:     /* Sequenced to     */

         refresh->rev_partid = NULL;
         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;

         FIg_set_text(fp, PART_REV_FLD, "");
         FIg_set_text(fp, PART_DESC_FLD, "");
         FIg_set_text(fp, PART_FILE_FLD, "");

         _pdm_debug("Entering PARTNUM",0);

         status = PDUep_part_fld();
         _pdm_status("PDUep_part_fld",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');
         status = PDUcheck_file_commands();
         _pdm_status("PDUcheck_file_commands", status);
         break;

    case PART_REV_FLD:         /* Field Type:    ASCII    */

         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;

         FIg_set_text(fp, PART_DESC_FLD, "");
         FIg_set_text(fp, PART_FILE_FLD, "");

         _pdm_debug("Entering EP_REV_FLD",0);

         status = PDUep_rev_fld();
         _pdm_status("PDUep_rev_fld",status);

         if (status == 0)
            break;

         PDUmessage(status,'s');
         status = PDUcheck_file_commands();
         _pdm_status("PDUcheck_file_commands", status);
         break;

    case PART_FILE_FLD:         /* Field Type:    ASCII    */

         FIfld_get_text_length(fp, PART_FILE_FLD, 0, 0, &length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp, PART_FILE_FLD, 0, 0, length, 
                       (unsigned char *)text, &select, &pos);
         if ((text == NULL) || (strcmp(text, "") == 0))
           {
           refresh->rev_filename = NULL;
           break;
           }

         /* verify part is in part selection area */
         status = PDUverify_part_data(forms.local_files_form_id);
         _pdm_status("PDUverify_part_data", status);
         if (status != PDM_S_SUCCESS)
           break;

         status = PDUvalid_filename(refresh->rev_catalog,
       				    refresh->rev_partid,
				    refresh->rev_revision,
				    text);
         _pdm_status("PDUvalid_filename", status);

        if (status != PDM_S_SUCCESS)
           {
           FIg_set_text(fp, PART_FILE_FLD, "");
           refresh->rev_filename = NULL;
           FIfld_pos_cursor(fp, PART_FILE_FLD, 0,0,0,0,1,1);
           PDUmessage(status, 's');
           break;
           }

         PDUfill_in_string(&refresh->rev_filename, text);

         break;

    case PART_DESC_FLD:         /* Field Type:    ASCII    */

/* 11/21/95 - TR 139528296 - MJG - check for NULL */

         if (refresh->rev_description)
           PDUfill_in_string(&save_string, refresh->rev_description);
         refresh->rev_description = NULL;

         _pdm_debug("Entering EP_DESC_BTN",0);

         status = PDUep_desc_fld();
         _pdm_status("PDUep_desc_fld",status);

         if (status == 0)
           {
           if (save_string)
             {
             _pdm_debug("resetting desc", 0);
             PDUfill_in_string(&refresh->rev_description, save_string);
             FIg_set_text(fp, PART_DESC_FLD, refresh->rev_description);
             }
           break;
           }

         PDUmessage(status,'s');
         status = PDUcheck_file_commands();
         _pdm_status("PDUcheck_file_commands", status);
         break;

    /* Part Selection area list buttons */  

    case PROJECT_LIST_BTN: 
         PDU_active_button = PROJECT_LIST_BTN;

         PDU_check_file_refresh = TRUE;

         refresh->rev_filename = NULL;
         FIg_set_text(fp, PART_FILE_FLD, "");

         _pdm_debug("Entering LIST_PROJECTS",0);

         status = PDUep_proj_btn();
         _pdm_status("PDUep_proj_btn",status);

/*
         if ((status == PDM_S_SUCCESS) && ((!refresh->rev_catalog) ||
             (refresh->rev_catalog && (strcmp(refresh->rev_catalog, "") == 0))))
            FIfld_pos_cursor(PDU_form_id,PDU_refresh_gadgets[1],0,0,0,0,1,1);
         else  if (status != PDM_S_SUCCESS)
            FIg_set_state_off(fp, PROJECT_LIST_BTN);
*/

         PDUmessage(status,'s');
         break; 

    case CATALOG_LIST_BTN:
         PDU_active_button = CATALOG_LIST_BTN;

         PDU_check_file_refresh = TRUE;
         PDU_main_form_cat = TRUE;

         refresh->rev_partid = NULL;
         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;

         FIg_set_text(fp, PARTNUM_FLD, "");
         FIg_set_text(fp, PART_REV_FLD, "");
         FIg_set_text(fp, PART_DESC_FLD, "");
         FIg_set_text(fp, PART_FILE_FLD, "");

         _pdm_debug("Entering EP_CAT_BTN", 0);

         status = PDUep_cat_btn();
         _pdm_status("PDUep_cat_btn",status);

         break;
  
    case PARTNUM_LIST_BTN:
         PDU_active_button = PARTNUM_LIST_BTN;

         PDU_check_file_refresh = TRUE;

         refresh->rev_revision = NULL;
         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;

         FIg_set_text(fp, PART_REV_FLD, "");
         FIg_set_text(fp, PART_DESC_FLD, "");
         FIg_set_text(fp, PART_FILE_FLD, "");

         _pdm_debug("Entering LIST_PARTS",0);

         status = PDUep_part_btn();
         _pdm_status("PDUep_part_btn",status);

         if (status == 0)
            break;

         PDUmessage(status,'s');
         break;

    case REVISION_LIST_BTN:
         PDU_active_button = REVISION_LIST_BTN;

         PDU_check_file_refresh = TRUE;

         refresh->rev_description = NULL;
         refresh->rev_filename = NULL;

         FIg_set_text(fp, PART_DESC_FLD, "");
         FIg_set_text(fp, PART_FILE_FLD, "");

         _pdm_debug("Entering EP_REV_BTN",0);

         status = PDUep_rev_btn();
         _pdm_status("PDUep_rev_btn",status);

         if (status == 0)
            break;

         PDUmessage(status,'s');
         break;
  
    case FILENAME_LIST_BTN:
         PDU_active_button = FILENAME_LIST_BTN;

         PDUdismiss_subforms();

         status = PDUverify_part_data(forms.local_files_form_id);
         _pdm_status("PDUverify_part_data", status);
         if (status != PDM_S_SUCCESS)
           {
           FIg_set_state_off(fp, PDU_active_button);
           PDU_active_button = -1;
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
           PDUmessage(status, 's');
           msg = (char *) PDUtranslate_message(PDM_E_NO_PART_FILES);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           MEMclose(&PDU_ret_bufr);
           FIg_set_state_off(fp, FILENAME_LIST_BTN);
           break;
           }

         if (PDU_ret_bufr == NULL)
           {
           msg = (char *) PDUtranslate_message(PDM_E_NO_PART_FILES);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           PDUmessage(PDM_E_NO_PART_FILES, 's');
           FIg_set_state_off(fp, FILENAME_LIST_BTN);
           break;
           }

         PDUsetup_single_buffer(PDU_ret_bufr);
         PDU_form_id = forms.local_files_form_id;
         PDU_gadget_labels[0] = PART_FILE_FLD;
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

         PDU_list_filenames = TRUE;
         status = PDUsingle_list_form();
         break;

    /* Multicolumn field for listing parts/files */

    case LIST_MCF:     /* Member of group MCF_LIST_GRP  */

         FIfld_get_active_row(fp, LIST_MCF, &act_row, &act_pos);
         _pdm_debug("active row = %d", (char *)act_row);

         if (PDU_parts_list_bufr == NULL)
           break; 

         FImcf_set_active_col(fp, LIST_MCF, 0, 0);
         FIfld_get_select(fp, LIST_MCF, act_row, 0, &mcf_select);

         /* check the value of the first column */
         FIfld_get_text_length(fp, LIST_MCF, act_row, 0, &length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp, LIST_MCF, act_row, 0, length, 
                       (unsigned char *)text, &select, &pos);
         _pdm_debug("text = <%s>", text);

         if (mcf_select == TRUE)
           {
           /* Mark the global array for the row selected */
           PDU_parts_index[act_row] = act_row;
           _pdm_debug("PDU_selected_rows (before incr)= %d", 
                       (char *)PDU_selected_rows);
           PDU_selected_rows = PDU_selected_rows + 1;
           _pdm_debug("PDU_selected_rows (after incr) = %d", 
                       (char *)PDU_selected_rows);

           if (text && (strcmp(text, "") != 0))
             {
             /* loop through columns in mcf to get data selected */
             for (column = 0; column < 7; ++column)
                {
                FIfld_get_text_length(fp, LIST_MCF, act_row, column, &length);
                text = (char *) malloc (sizeof (char) * length + 1);
                memset(text, NULL, sizeof (char) * length + 1);
                FIfld_get_text(fp, LIST_MCF, act_row, column, length, 
                              (unsigned char *)text, &select, &pos);
  
                /* update the structure and the part selection area */
                switch (column)
                  {
                  case 0:
                      if (refresh->rev_catalog && 
                         (strcmp(text, refresh->rev_catalog) != 0))
                        {
                        status = PDMquery_catalog_type(text, type);
                        _pdm_status("PDMquery_catalog_type", status);
                        _pdm_debug("catalog type = <%s>", type);
                     
                        if ((strcmp(type, "P") == 0) ||
                            (strcmp(type, "CID") == 0) ||
                            (strcmp(type, "PXT") == 0) ||
                            (strcmp(type, "EID") == 0))
                          PDU_param_cat = TRUE;
                        else
                          PDU_param_cat = FALSE;
                        }
                      PDUfill_in_string(&refresh->rev_catalog, text);
                      _pdm_debug("catalog = <%s>", refresh->rev_catalog);
                      FIfld_set_text( fp, CATALOG_FLD, 0, column, text, FALSE);
                      break;
                  case 1:
                      PDUfill_in_string(&refresh->rev_partid, text);
                      _pdm_debug("part num = <%s>", refresh->rev_partid);
                      FIfld_set_text( fp, PARTNUM_FLD, 0, column, text, FALSE);
                      break;
                  case 2:
                      PDUfill_in_string(&refresh->rev_revision, text);
                      _pdm_debug("revision = <%s>", refresh->rev_revision);
                      FIfld_set_text( fp, PART_REV_FLD, 0, column, text, FALSE);
                      break;
                  case 3:
                      PDUfill_in_string(&refresh->rev_description,text);
                      _pdm_debug("description = <%s>",refresh->rev_description);
                      FIfld_set_text(fp, PART_DESC_FLD, 0, column, text, FALSE);
                      break;
                  case 5:
                      PDUfill_in_string(&refresh->rev_filename,text);
                      _pdm_debug("filename = <%s>", refresh->rev_filename);
                      FIfld_set_text(fp, PART_FILE_FLD, 0, column, text, FALSE);
                      break;
                  }
                PDUfree_string(&text);
                }  /* end for column */

             /* check for blank rows - multiple files */
             for (row = act_row + 1; row < PDU_parts_list_bufr->rows; ++row)
                {
                _pdm_debug("row = <%d>", (char *)row);
                FIfld_get_text_length(fp, LIST_MCF, row, 0, &length);
                text = (char *) malloc (sizeof (char) * length + 1);
                memset(text, NULL, sizeof (char) * length + 1);
                FIfld_get_text(fp, LIST_MCF, row, 0, length, 
                              (unsigned char *)text, &select, &pos);
                if (strcmp(text, "") == 0)
                  {
                  if (PDU_parts_index[row] == -1)
                    PDU_selected_rows = PDU_selected_rows + 1;
                  PDU_parts_index[row] = row;
                  _pdm_debug("PDU_selected_rows = <%d>", 
                              (char *)PDU_selected_rows);
                  FImcf_set_select(fp, LIST_MCF, row, TRUE);
                  }
                else
                  {
                  _pdm_debug("multiple files not found", 0);
                  break;
                  }
                }
             }
           else  /* text = NULL_STRING, a multiple file was selected */
             {
             _pdm_debug("searching backwards for the associated part", 0);
             for (row = act_row - 1; row >= 0; --row)
                {
                _pdm_debug("row = <%d>", (char *)row);
                FIfld_get_text_length(fp, LIST_MCF, row, 0, &length);
                text = (char *) malloc (sizeof (char) * length + 1);
                memset(text, NULL, sizeof (char) * length + 1);
                FIfld_get_text(fp, LIST_MCF, row, 0, length, 
                              (unsigned char *)text, &select, &pos);

                if (PDU_parts_index[row] == -1)
                  PDU_selected_rows = PDU_selected_rows + 1;
                PDU_parts_index[row] = row;
                _pdm_debug("PDU_selected_rows = <%d>", 
                           (char *)PDU_selected_rows);
                FImcf_set_select(fp, LIST_MCF, row, TRUE);

                if (strcmp(text, "") != 0)
                  {
                  /* loop through columns in mcf to get part info */
                  for (column = 0; column < 7; ++column)
                     {
                     FIfld_get_text_length(fp, LIST_MCF, row, column, &length);
                     text = (char *) malloc (sizeof (char) * length + 1);
                     memset(text, NULL, sizeof (char) * length + 1);
                     FIfld_get_text(fp, LIST_MCF, row, column, length, 
                                   (unsigned char *)text, &select, &pos);
       
                     /* update the structure and the part selection area */
                     switch (column)
                       {
                       case 0:
                          PDUfill_in_string(&refresh->rev_catalog, text);
                          _pdm_debug("catalog = <%s>", refresh->rev_catalog);
                          FIfld_set_text(fp,CATALOG_FLD,0,column,text, FALSE);
                          break;
                      case 1:
                          PDUfill_in_string(&refresh->rev_partid, text);
                          _pdm_debug("part num = <%s>", refresh->rev_partid);
                          FIfld_set_text(fp,PARTNUM_FLD,0,column, text, FALSE);
                          break;
                      case 2:
                          PDUfill_in_string(&refresh->rev_revision, text);
                          _pdm_debug("revision = <%s>", refresh->rev_revision);
                          FIfld_set_text(fp,PART_REV_FLD,0,column,text, FALSE);
                          break;
                      case 3:
                          PDUfill_in_string(&refresh->rev_description,text);
                          _pdm_debug("description = <%s>",refresh->rev_description);
                          FIfld_set_text(fp,PART_DESC_FLD,0,column,text,FALSE);
                          break;
                      case 5:
                          PDUfill_in_string(&refresh->rev_filename,text);
                          _pdm_debug("filename = <%s>", refresh->rev_filename);
                          FIfld_set_text(fp,PART_FILE_FLD,0,column,text,FALSE);
                          break;
                      }
                    PDUfree_string(&text);
                    }  /* end for column */
                  break;
                  }
                }
             /* check for multiple files below the active row */
             for (row = act_row + 1; row < PDU_parts_list_bufr->rows; ++row)
                {
                _pdm_debug("row = <%d>", (char *)row);
                FIfld_get_text_length(fp, LIST_MCF, row, 0, &length);
                text = (char *) malloc (sizeof (char) * length + 1);
                memset(text, NULL, sizeof (char) * length + 1);
                FIfld_get_text(fp, LIST_MCF, row, 0, length, 
                              (unsigned char *)text, &select, &pos);
                if (strcmp(text, "") == 0)
                  {
                  if (PDU_parts_index[row] == -1)
                    PDU_selected_rows = PDU_selected_rows + 1;
                  PDU_parts_index[row] = row;
                  _pdm_debug("PDU_selected_rows = <%d>", 
                             (char *)PDU_selected_rows);
                  FImcf_set_select(fp, LIST_MCF, row, TRUE);
                  }
                else
                  {
                  _pdm_debug("multiple files not found", 0);
                  break;
                  }
                }
             }

           /* update parttype in structure */
           MEMbuild_array(PDU_parts_list_bufr);
           PDUsetup_buffer(PDU_parts_list_bufr,ROW, &list_row);
           status = PDUget_buffer_col(PDU_parts_list_bufr, "p_parttype", 
                                      &ptype_col);
           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }

           PDUfill_in_string(&refresh->rev_parttype, 
               list_row[(PDU_parts_list_bufr->columns * act_row) + ptype_col]);

           }  /* end if select */
         else
           {
           PDU_parts_index[act_row] = -1;
           PDU_selected_rows = PDU_selected_rows - 1;
           _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);

           if (strcmp(text, "") == 0)
             {
             /* find the associated part */
             for (row = act_row - 1; row < PDU_parts_list_bufr->rows; --row)
                {
                _pdm_debug("row = <%d>", (char *)row);
                FIfld_get_text_length(fp, LIST_MCF, row, 0, &length);
                text = (char *) malloc (sizeof (char) * length + 1);
                memset(text, NULL, sizeof (char) * length + 1);
                FIfld_get_text(fp, LIST_MCF, row, 0, length, 
                              (unsigned char *)text, &select, &pos);

                if (PDU_parts_index[row] != -1)
                  PDU_selected_rows = PDU_selected_rows - 1;
                PDU_parts_index[row] = -1;
                _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
                FImcf_set_select(fp, LIST_MCF, row, FALSE);

                if (strcmp(text, "") != 0)
                  {
                  _pdm_debug("associated part found", 0);
                  break;
                  }
               }
             }

           /* check for multiple files */
           for (row = act_row + 1; row < PDU_parts_list_bufr->rows; ++row)
              {
              _pdm_debug("row = <%d>", (char *)row);
              FIfld_get_text_length(fp, LIST_MCF, row, 0, &length);
              text = (char *) malloc (sizeof (char) * length + 1);
              memset(text, NULL, sizeof (char) * length + 1);
              FIfld_get_text(fp, LIST_MCF, row, 0, length, 
                            (unsigned char *)text, &select, &pos);
              if (strcmp(text, "") == 0)
                {
                if (PDU_parts_index[row] != -1)
                  PDU_selected_rows = PDU_selected_rows - 1;
                PDU_parts_index[row] = -1;
                _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
                FImcf_set_select(fp, LIST_MCF, row, FALSE);
                }
              else if (strcmp(text, "") != 0)
                {
                _pdm_debug("no more multiple files found", 0);
                break;
                }
              }

           /* check for parametric catalog */
           if (strcmp(refresh->rev_catalog, "") != 0)
             {
             status = PDMquery_catalog_type(refresh->rev_catalog, type);
             _pdm_status("PDMquery_catalog_type", status);
             _pdm_debug("catalog type = <%s>", type);
         
             if ((strcmp(type, "P") == 0) ||
                 (strcmp(type, "CID") == 0) ||
                 (strcmp(type, "PXT") == 0) ||
                 (strcmp(type, "EID") == 0))
               PDU_param_cat = TRUE;
             else
               PDU_param_cat = FALSE;
             }
           }

         if (PDU_selected_rows > 0)
           {
           if (PDU_param_cat == FALSE)
             {
             PDUenable_local_files_gadgets();
             FIg_enable(forms.local_files_form_id, REVISE_ASSEMBLY_BTN);
             FIg_enable(forms.local_files_form_id, PARTS_BTN);
             }
           else
             {
             PDUdisable_local_files_gadgets();
             FIg_disable(forms.local_files_form_id, REVISE_ASSEMBLY_BTN);
             FIg_disable(forms.local_files_form_id, PARTS_BTN);
             FIg_enable(forms.local_files_form_id, REV_STRUCT_BTN);
             }
           FIg_enable(forms.local_files_form_id, MOVE_STATE);
           }

         /* check to see if delete button should be enabled */
         FIg_disable(fp, DELETE_LOCAL_BTN);
         if (PDU_selected_rows > 0)
           {
           _pdm_debug("resetting delete button", 0);
           for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
              {
              FIfld_get_select(fp, LIST_MCF, row, 0, &mcf_select);
              if (mcf_select == TRUE)
                {
                FIfld_get_text_length(fp, LIST_MCF, row, 6, &length);
                text = (char *) malloc (sizeof (char) * length + 1);
                memset(text, NULL, sizeof (char) * length + 1);
                FIfld_get_text(fp, LIST_MCF, row, 6, length, 
                              (unsigned char *)text, &select, &pos);
                _pdm_debug("test = <%s>", text);
                if ((strcmp(text, "CHECKED OUT") == 0) ||
                    (strcmp(text, "COPIED TO LOCAL") == 0) ||
                    (strcmp(text, "CHECKED OUT & COPIED") == 0) ||
		    (strcmp(text, "CHECKED OUT & ATTACHED") == 0) ||
		    (strcmp(text, "COPIED & ATTACHED") == 0) ||
		    (strcmp(text, "CHECKED OUT, COPIED & ATTACHED") == 0) ||
                    (strcmp(text, "CHECKED OUT & ATTACH") == 0))
                  {
                  FIg_enable(fp, DELETE_LOCAL_BTN);
                  PDUfree_string(&text);
                  break;
                  }
                }
              PDUfree_string(&text);
              }
           }
         else
           FIg_disable(fp, DELETE_LOCAL_BTN);

	 PDUset_edit_assy_toggle_after_select();

         break;

    case STRUCTURE_MCF: 

         FIfld_get_active_row(fp, STRUCTURE_MCF, &act_row, &act_pos);
         FImcf_set_active_col(fp, STRUCTURE_MCF, 0, 0);
         FIfld_get_select(fp, STRUCTURE_MCF, act_row, 0, &mcf_select);
         _pdm_debug("active row = %d", (char *)act_row);

         if (mcf_select == TRUE)
           {
           /* clear out the refresh */
           refresh->rev_project = NULL_STRING;
           refresh->rev_catalog = NULL_STRING;
           refresh->rev_partid = NULL_STRING;
           refresh->rev_revision = NULL_STRING;
           refresh->rev_description = NULL_STRING;
           refresh->rev_filename = NULL_STRING;

           FIg_set_text(fp, PROJECT_FLD, "");
           FIg_set_text(fp, CATALOG_FLD, "");
           FIg_set_text(fp, PARTNUM_FLD, "");
           FIg_set_text(fp, PART_REV_FLD, "");
           FIg_set_text(fp, PART_DESC_FLD, "");
           FIg_set_text(fp, PART_FILE_FLD, "");

           /* Mark the global array for the row selected */
           PDU_parts_index[act_row] = act_row;
           PDU_selected_rows = PDU_selected_rows + 1;
           _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
           
           /* loop through columns in mcf to get data selected */
           for (column = 1; column < 4; ++column)
              {
              FIfld_get_text_length(fp,STRUCTURE_MCF,act_row, column, &length);
              text = (char *) malloc (sizeof (char) * length + 1);
              memset(text, NULL, sizeof (char) * length + 1);
              FIfld_get_text(fp, STRUCTURE_MCF, act_row, column, length, 
                            (unsigned char *)text, &select, &pos);

              /* update the structure and the part selection area */
              switch (column)
                {
                case 1:
                     PDUfill_in_string(&refresh->rev_catalog, text);
                     _pdm_debug("catalog = <%s>", refresh->rev_catalog);
                     FIfld_set_text( fp, CATALOG_FLD, 0, column, text, FALSE);
                     break;
                case 2:
                     PDUfill_in_string(&refresh->rev_partid, text);
                     _pdm_debug("part num = <%s>", refresh->rev_partid);
                     FIfld_set_text( fp, PARTNUM_FLD, 0, column, text, FALSE);
                     break;
                case 3:
                     PDUfill_in_string(&refresh->rev_revision, text);
                     _pdm_debug("revision = <%s>", refresh->rev_revision);
                     FIfld_set_text( fp, PART_REV_FLD, 0, column, text, FALSE);
                     break;
                }
              PDUfree_string(&text);
              }  /* end for column */

           MEMbuild_array(PDU_parts_list_bufr);
           PDUsetup_buffer(PDU_parts_list_bufr,ROW, &list_row);

           _pdm_debug("getting the filename", 0);
           status = PDMget_filenames(refresh->rev_catalog,refresh->rev_partid,
                           refresh->rev_revision, &ret_bufr);
           _pdm_status("PDMget_filenames", status);
       
           if ( status != PDM_S_SUCCESS )
             {
             msg = (char *) PDUtranslate_message(PDM_E_NO_PART_FILES);
             FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
             MEMclose(&ret_bufr);
             PDUmessage(PDM_E_NO_PART_FILES, 's');
             break;
             }
       
           if ((ret_bufr == NULL) || (ret_bufr->rows == 0))
             {
             msg = (char *) PDUtranslate_message(PDM_E_FILE_NOT_FOUND);
             FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
             PDUmessage(PDM_E_FILE_NOT_FOUND, 's');
             break;
             }
  
           MEMbuild_array(ret_bufr);
           PDUsetup_buffer(ret_bufr, ROW, &data_row);
           status = PDUget_buffer_col(ret_bufr, "n_cofilename", &file_col);
           if (status != PDM_S_SUCCESS)
             break;
       
           PDUfill_in_string(&refresh->rev_filename, 
                             data_row[(ret_bufr->columns * 0) + file_col]);
           if (refresh->rev_filename && (strcmp(refresh->rev_filename,"") != 0))
             {
             _pdm_debug("refresh->rev_filename = <%s>", refresh->rev_filename);
             FIg_set_text(fp, PDU_refresh_gadgets[6], refresh->rev_filename);
             }
/*
           status = PDUget_buffer_col(PDU_parts_list_bufr, "n_cofilename", 
                                      &file_col);
           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }

           PDUfill_in_string(&refresh->rev_filename, 
               list_row[(PDU_parts_list_bufr->columns * act_row) + file_col]);
           FIg_set_text(forms.local_files_form_id, PART_FILE_FLD, 
                          refresh->rev_filename);
*/

           _pdm_debug("getting the description", 0);
           status = PDUget_buffer_col(PDU_parts_list_bufr, "n_itemdesc", 
                                      &desc_col);
           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }

           PDUfill_in_string(&refresh->rev_description, 
               list_row[(PDU_parts_list_bufr->columns * act_row) + desc_col]);
           FIg_set_text(forms.local_files_form_id, PART_DESC_FLD, 
                          refresh->rev_description);

           _pdm_debug("getting the parttype", 0);
           status = PDUget_buffer_col(PDU_parts_list_bufr, "p_parttype", 
                                      &type_col);
           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }

           PDUfill_in_string(&refresh->rev_parttype, 
               list_row[(PDU_parts_list_bufr->columns * act_row) + type_col]);

           _pdm_debug("checking part status for delete local button", 0);
           status = PDMrcheck_part_status(refresh->rev_catalog,
                                          refresh->rev_partid,
                                          refresh->rev_revision);
           _pdm_status("PDMrcheck_part_status", status);
           if ((status == PDM_I_COPIED_TO_LOCAL_BY_YOU) ||
               (status == PDM_I_CHECKED_OUT_BY_YOU))
             {
             _pdm_debug("enabling delete local button", 0);
             FIg_enable(fp, DELETE_LOCAL_BTN);
             }
           PDUmessage(PDM_S_SUCCESS, 's');
           }  /* end if select */
         else
           {
           PDU_parts_index[act_row] = -1;
           PDU_selected_rows = PDU_selected_rows - 1;
           _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
           }

         if (PDU_selected_rows > 0)
           {
           if (PDU_param_cat == FALSE)
             {
             PDUenable_local_files_gadgets();
             FIg_enable(forms.local_files_form_id, REVISE_ASSEMBLY_BTN);
             FIg_enable(forms.local_files_form_id, PARTS_BTN);
             }
           else
             {
             PDUdisable_local_files_gadgets();
             FIg_disable(forms.local_files_form_id, REVISE_ASSEMBLY_BTN);
             FIg_disable(forms.local_files_form_id, PARTS_BTN);
             FIg_enable(forms.local_files_form_id, REV_STRUCT_BTN);
             }
           FIg_enable(forms.local_files_form_id, MOVE_STATE);
           }

         _pdm_debug("checking edit assembly toggle", 0);
         if (PDU_selected_rows > 1)
           {
           FIg_disable(fp, EDIT_ASSEMBLY_TGL);
           PDU_chkout_single = FALSE;
           PDU_edit_display = FALSE;
           }
         else
           {
           FIg_enable(fp, EDIT_ASSEMBLY_TGL);
           PDU_chkout_single = TRUE;
	   FIg_get_state(fp, EDIT_ASSEMBLY_TGL, &state);
	   if (state == 1)
             PDU_edit_display = TRUE;
           else
             PDU_edit_display = FALSE;
           }

         break;

    case SEARCH_PARTS_BTN:     
         FIg_disable(forms.local_files_form_id, DELETE_LOCAL_BTN);
         PDU_form_id = forms.local_files_form_id;
         PDU_form_type = LOCAL_FILES_FORM;
         PDU_search_type = FILES;

         PDUclear_mcf();

         _pdm_debug("saving refresh information", 0);
         PDU_save_project = NULL_STRING;
         PDU_save_catalog = NULL_STRING;
         PDU_save_partid = NULL_STRING;
         PDU_save_revision = NULL_STRING;
         PDU_save_description = NULL_STRING;
         PDU_save_filename = NULL_STRING;
         PDU_save_parttype = NULL_STRING;

         if ((refresh->rev_project) && (strcmp(refresh->rev_project, "") != 0))
           PDUfill_in_string(&PDU_save_project, refresh->rev_project);
         if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
           PDUfill_in_string(&PDU_save_catalog, refresh->rev_catalog);
         if ((refresh->rev_partid) && (strcmp(refresh->rev_partid, "") != 0))
           PDUfill_in_string(&PDU_save_partid, refresh->rev_partid);
         if ((refresh->rev_revision) && 
             (strcmp(refresh->rev_revision, "") != 0))
           PDUfill_in_string(&PDU_save_revision, refresh->rev_revision);
         if ((refresh->rev_description) && 
             (strcmp(refresh->rev_description, "") != 0))
           PDUfill_in_string(&PDU_save_description, refresh->rev_description);
         if ((refresh->rev_filename) && 
             (strcmp(refresh->rev_filename, "") != 0))
           PDUfill_in_string(&PDU_save_filename, refresh->rev_filename);
         if ((refresh->rev_parttype) && 
             (strcmp(refresh->rev_parttype, "") != 0))
           PDUfill_in_string(&PDU_save_parttype, refresh->rev_parttype);

         PDU_selected_rows = 0;
	 FIf_erase(fp);
         _pdm_debug("calling part selection form", 0);
         SelectOrPlacePart(TRUE, TRUE, fp);

         break;

    case LIST_PARTS_IN_CAT_BTN:

         FIg_disable(forms.local_files_form_id, DELETE_LOCAL_BTN);

         if ((refresh->rev_catalog == NULL) || 
             (strcmp(refresh->rev_catalog, "") == 0))
           {
           msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           PDUmessage(PDM_I_ENTER_CATALOG, 's');
           break;
           }

         PDUclear_mcf();
         PDU_selected_rows = 0;

         PDU_dyn_cat_search = NULL_STRING;
         PDU_dyn_part_search = NULL_STRING;
         status = PDMsearch_parts_in_catalog(refresh->rev_catalog,
                                             &PDU_parts_list_bufr);
         _pdm_status("PDMsearch_parts_in_catalog", status);

         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }

         catalog_flag = TRUE;
         status = PDUload_local_files_form();
         _pdm_status("PDUload_local_files_form", status);

         break;

    case LIST_FILES_BTN:     
         FIg_disable(forms.local_files_form_id, DELETE_LOCAL_BTN);
         break;

    case WHERE_USED:

         if (PDU_selected_rows > 0)
           part_count = PDUcount_selected_parts();
         else
           part_count = 0;
 
         if (part_count > 1)
           {
           PDUmessage(PDM_I_MULTIPLE_PARTS_SELECTED, 's');
           msg = (char *) PDUtranslate_message(PDM_I_MULTIPLE_PARTS_SELECTED);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }
 
         if ((part_count == 1) && (PDU_mcf_list || PDU_structure_list))
             PDUload_refresh_from_parts_list();
 
         PDUmessage(PDM_E_CLEAR_FIELD, 's');

         status = PDUverify_part_data(forms.local_files_form_id);
         _pdm_status("PDUverify_part_data", status);
         if (status != PDM_S_SUCCESS)
           break;

         PDUclear_mcf();
 
         status = PDMrget_imm_parents(refresh->rev_catalog,
              refresh->rev_partid, refresh->rev_revision, &PDU_parts_list_bufr);
         _pdm_status("PDMrget_imm_parents", status);

         if (status != PDM_S_SUCCESS)
           {
           if (status == SQL_I_NO_ROWS_FOUND)
             status = PDM_E_NO_PARENTS;
           PDUmessage(status, 's');
           MEMclose(&PDU_parts_list_bufr);
           PDU_parts_list_bufr = NULL;
           break;
           }

         if (!PDU_parts_list_bufr)
           {
           _pdm_debug("buffer is NULL", 0);
           PDUmessage(PDM_E_NO_PARENTS, 's');
           break;
           }

         if (PDU_parts_list_bufr->rows == 0)
           {
           _pdm_debug("no rows in buffer", 0);
           PDUmessage(PDM_E_NO_PARENTS, 's');
           MEMclose(&PDU_parts_list_bufr);
           PDU_parts_list_bufr = NULL;
           break;
           }

         if (PDM_debug_on)
           MEMprint_buffer("where_used", PDU_parts_list_bufr, PDU_DEBUG_FILE);

         catalog_flag = TRUE;
         if (PDU_parts_list_bufr)
           {
           status = PDUload_local_files_form();
           _pdm_status("PDUload_local_files_form", status);
           }

         break;

    case ROLL_THROUGH:  
         break;

    /* Buttons from file operations button palette */

    case CHECKIN_BTN:        

          status = PDUcheck_part_data_for_utilities();
          _pdm_status("PDUcheck_part_data_for_utilities", status);
          if (status != PDM_S_SUCCESS)
            break;

         /* put the checkin command on the queue */
         PDU_command = PDC_M_CHECKIN;
         responses[0] = EX_CMD_KEY;
         strings[0] = "PDChInPr";
  
         status = PDUprepare_queue ( responses, strings, 1 );
         _pdm_status("PDUprepare_queue (checkin part)",status);

         break;
         
    case CHECKOUT_BTN:       

         _pdm_debug("entering case for CHECKOUT", 0);
         PDU_command = PDC_M_CHECKOUT;

         /* reset file buffer */
         if (PDU_part_file_buffer)
           {
           MEMclose(&PDU_part_file_buffer);
           PDU_part_file_buffer = NULL;
           }

         PDU_checkout_type = NONACT;

         if (PDU_selected_rows > 1)
           {
           _pdm_debug("checking out multiple parts", 0);
           status = PDUcheckout();
           _pdm_debug("PDUcheckout", status);

	   if (status != PDM_S_SUCCESS)
             PDUmessage(status, 's');

           break;
           }

         if ((PDU_selected_rows == 1) && (PDU_mcf_list || PDU_structure_list))
             PDUload_refresh_from_parts_list();

          status = PDUcheck_part_data_for_utilities();
          _pdm_status("PDUcheck_part_data_for_utilities", status);
          if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            break;
            }

          /* check to see if the part is checked in */
         status = PDMrcheck_part_status(refresh->rev_catalog,
                                        refresh->rev_partid,
                                        refresh->rev_revision);
         _pdm_status("PDMrcheck_part_status", status);
 
         if (status == MEM_S_SUCCESS)
           {
           PDUmessage(PDM_E_ERROR_RETRIEVING_STATUS, 's');
           break;
           }

         if ((status == PDM_I_CHECKED_IN) ||
             (status == PDM_I_COPIED_TO_LOCAL_BY_YOU) ||
             (status == PDM_I_ATTACHED_TO_LOCAL_ASSY))
           {
           /* put the checkout command on the queue */
           PDU_command = PDC_M_CHECKOUT;
           responses[0] = EX_CMD_KEY;
           strings[0] = "PDChOtPr";
    
           status = PDUprepare_queue ( responses, strings, 1 );
           _pdm_status("PDUprepare_queue (checkout part)",status);
           }
         else
           {
           PDUmessage(status, 's');
           break;
           }
  
         break;

    case COPY_LOCAL_BTN:
         
	 _pdm_debug("entering case for COPY_LOCAL", 0);

         /* reset file buffer */
         if (PDU_part_file_buffer)
           {
           MEMclose(&PDU_part_file_buffer);
           PDU_part_file_buffer = NULL;
           }

         if ((PDU_mcf_list) && (PDU_selected_rows > 1))
           {
           /* put the copy command on the queue */
           PDU_command = PDC_M_COPY;
           responses[0] = EX_CMD_KEY;
           strings[0] = "PDCpFlTLc";
   
           status = PDUprepare_queue ( responses, strings, 1 );
           _pdm_status("PDUprepare_queue (checkout part)",status);
           break;
           }

         if ((PDU_selected_rows == 1) && (PDU_mcf_list || PDU_structure_list))
             PDUload_refresh_from_parts_list();

          status = PDUcheck_part_data_for_utilities();
          _pdm_status("PDUcheck_part_data_for_utilities", status);
          if (status != PDM_S_SUCCESS)
            break;

          /* check to see if the part is checked in */
         status = PDMrcheck_part_status(refresh->rev_catalog,
                                        refresh->rev_partid,
                                        refresh->rev_revision);
         _pdm_status("PDMrcheck_part_status", status);
 
         if (status == MEM_S_SUCCESS)
           {
           PDUmessage(PDM_E_ERROR_RETRIEVING_STATUS, 's');
           break;
           }

         if ((status == PDM_I_CHECKED_IN) ||
             (status == PDM_I_ATTACHED_TO_LOCAL_ASSY) ||
             (status == PDM_I_CHECKED_OUT_BY_ANOTHER_USER))
           {
           /* put the copy command on the queue */
           PDU_command = PDC_M_COPY;
           responses[0] = EX_CMD_KEY;
           strings[0] = "PDCpFlTLc";
   
           status = PDUprepare_queue ( responses, strings, 1 );
           _pdm_status("PDUprepare_queue (checkout part)",status);
           break;
           } 
         else
           {
           PDUmessage(status, 's');
           break;
           }

    case DELETE_LOCAL_BTN:   

         if (PDU_selected_rows > 1)
           {
           _pdm_debug("entering delete local for multiple part selection", 0);

           /* call function to pull out the files for deletion */
           status = PDUcreate_delete_buffer();
           _pdm_status("PDUcreate_delete_buffer", status);

           if (status != PDM_S_SUCCESS)
             {
	     PDUmessage(status, 's');
             break;
             }

           if ((PDU_delete_buffer) && (PDU_delete_buffer->rows > 0))
             {
             PDUmessage(PDC_M_DELETE_FILE, 'c');

	     status = PDUdelete_file();
             _pdm_status("PDUdelete_file", status);

             if (status != PDM_S_SUCCESS)
	       PDUmessage(status, 's');

             if (PDU_delete_buffer)
               {
               MEMclose(&PDU_delete_buffer);
               PDU_delete_buffer = NULL;
               }
             }
           else
             if (PDU_delete_buffer)
               {
               MEMclose(&PDU_delete_buffer);
               PDU_delete_buffer = NULL;
               }

           _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);

           if ((PDU_selected_rows > 0) || ((PDU_part_file_buffer) &&
               (PDU_part_file_buffer->rows > 0)))
             {
	     /* reset the parts index for cancel part check out */
             _pdm_debug("resetting PDU_parts_index", 0);
	     for (row = 0; row < PDU_parts_list_bufr->rows; ++ row)
                {
                if (PDU_parts_index[row] > 10000)
                  {
                  PDU_parts_index[row] = PDU_parts_index[row] - 10000;
                  _pdm_debug("resetting row %d", (char *)PDU_parts_index[row]);
                  }
                }

             /* call function to display parts for confirmation */
             if ((PDU_part_file_buffer) && (PDU_part_file_buffer->rows > 0))
               {
               PDU_command = PDC_M_CANCEL_CHECKOUT;
	       status = PDUcancel_list_form();
               _pdm_status("PDUcancel_list_form", status);
               }
             else
               if (PDU_part_file_buffer)
                 {
                 MEMclose(&PDU_part_file_buffer);
                 PDU_part_file_buffer = NULL;
                 }
             }

           break;
           }

         _pdm_debug("entering delete local files for single part selection", 0);
         if ((PDU_selected_rows == 1) && (PDU_mcf_list || PDU_structure_list))
             PDUload_refresh_from_parts_list();

          status = PDUcheck_part_data_for_utilities();
          _pdm_status("PDUcheck_part_data_for_utilities", status);
          if (status != PDM_S_SUCCESS)
            break;

	 /* check the status of the part */
         status = PDMrcheck_part_status(refresh->rev_catalog, 
                                        refresh->rev_partid,
                                        refresh->rev_revision);
         _pdm_status("PDMrcheck_part_status", status);

         if (status == MEM_S_SUCCESS)
           {
           PDUmessage(PDM_E_ERROR_RETRIEVING_STATUS, 's');
           break;
           }

	 /* if the part if checked out to this WS, cancel part checkout */
	 if (status == PDM_I_CHECKED_OUT_BY_YOU)
           {
           /* make sure the file is local */
           status = PDUverify_file(refresh->rev_filename);
           _pdm_status("PDUverify_file", status);

           if (status == PDM_S_SUCCESS)  /* file is checked out */
             {
             _pdm_debug("inside case where file is local for checked out", 0);
             if (PDU_part_file_buffer)
               {
               MEMclose(&PDU_part_file_buffer);
               PDU_part_file_buffer = NULL;
               }
 
             status = PDUload_file_buffer(refresh->rev_catalog,
                                          refresh->rev_partid,
                                          refresh->rev_revision,
                                          refresh->rev_description, "");
             _pdm_status("PDUload_file_buffer", status);
 
             if ((PDU_part_file_buffer) && (PDU_part_file_buffer->rows > 0))
               {
               PDU_command = PDC_M_CANCEL_CHECKOUT;
               status = PDUcancel_list_form();
               _pdm_status("PDUcancel_list_form", status);
               }
             else
               if (PDU_part_file_buffer)
                 {
                 MEMclose(&PDU_part_file_buffer);
                 PDU_part_file_buffer = NULL;
                 }

             /* put the cancel checkout command on the queue */
/*
             PDU_command = PDC_M_CANCEL_CHECKOUT;
             responses[0] = EX_CMD_KEY;
             strings[0] = "PDCnPrChOt";
  
             status = PDUprepare_queue ( responses, strings, 1 );
             _pdm_status("PDUprepare_queue (cancel checkout)", status);
*/

             if (PDU_delete_buffer)
               {
               MEMclose(&PDU_delete_buffer);
               PDU_delete_buffer = NULL;
               }
             break;
             }
           else
             {
             _pdm_debug("inside case where file is not local for checked out", 0);
             PDUfill_in_string(&PDU_save_filename, refresh->rev_filename);
	     PDUmessage(PDM_E_FILE_NOT_LOCAL, 's');
             _pdm_debug("breaking", 0);
             break;
             }
           }

	 /* if the part is copied by you, delete the local file */
         else if (status == PDM_I_COPIED_TO_LOCAL_BY_YOU)
           {
           /* make sure the file is local */
           status = PDUverify_file(refresh->rev_filename);
           _pdm_status("PDUverify_file", status);

           if (status == PDM_S_SUCCESS)  /* file has been copied */
             {
             _pdm_debug("inside case where file is local for copied", 0);
             /* call function to create delete buffer */
             status = PDUcreate_delete_buffer();
             _pdm_status("PDUcreate_delete_buffer", status);
  
             if (status != PDM_S_SUCCESS)
               {
	       PDUmessage(status, 's');
               break;
               }
  
             /* put the delete local files command on the queue */
             PDU_command = PDC_M_DELETE_FILE;
             responses[0] = EX_CMD_KEY;
             strings[0] = "PDDlLcFl";
      
             status = PDUprepare_queue ( responses, strings, 1 );
             _pdm_status("PDUprepare_queue (checkout part)",status);

             if (PDU_part_file_buffer)
               {
               MEMclose(&PDU_part_file_buffer);
               PDU_part_file_buffer = NULL;
               }
             }
           else
             {
             _pdm_debug("inside case where file is not local for copied", 0);
             PDUfill_in_string(&PDU_save_filename, refresh->rev_filename);
	     PDUmessage(PDM_E_FILE_NOT_LOCAL, 's');
             _pdm_debug("breaking", 0);
             break;
             }
           }
         else
           PDUmessage(status, 's');

         break;
         
    case DESIGN:        

         _pdm_debug("entering case for design", 0);
         PDU_command = PDC_M_CHECKOUT_ACTIVATE;

         /* format the buffer */
         if (PDU_part_file_buffer)
           {
           MEMclose(&PDU_part_file_buffer);
           PDU_part_file_buffer = NULL;
           }

	 /* call function to loop through the rows */
         if (PDU_selected_rows > 1)
           {
           _pdm_debug("entering design for multiple part selection", 0);
           PDU_checkout_type = NONACT;

           status = PDUformat_buffer (PDU_PART_FILE_BUFFER, 
                                      &PDU_part_file_buffer);
           _pdm_status("PDUformat_buffer", status);
         
           if (status != PDM_S_SUCCESS)
             {
	     _pdm_debug("error formatting PDU_part_file_buffer", 0);
	     PDU_load_file_buffer = FALSE;;
             }
           else
             {
	     _pdm_debug("PDU_part_file_buffer successfully formatted", 0);
	     PDU_load_file_buffer = TRUE;
             }

           PDUmessage(PDC_M_CHECKOUT, 'c');
           PDU_checkout_type = NONACT;

           status = PDUcheckout();
           _pdm_status("PDUcheckout", status);

	   if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
	     MEMclose(&PDU_part_file_buffer);
             PDU_part_file_buffer = NULL;
             break;
             }

           /* call function to display list of parts that may be activated */
           if ((PDU_part_file_buffer) && (PDU_part_file_buffer->rows > 0))
             {
             PDUpart_file_list_form();

             status = WaitForEvent();
             _pdm_status("WaitForEvent", status);

             if (!status)
               {
                _pdm_debug("part listing form was cancelled", 0);
                PDUmessage(PDM_E_CMD_CANCELLED, 's');
                break;
               }
             }
           else
             {
             MEMclose(&PDU_part_file_buffer);
             PDU_part_file_buffer = NULL;
             }

           break;
           }

         _pdm_debug("entering design for single part selection", 0);
         if ((PDU_selected_rows == 1) && (PDU_mcf_list || PDU_structure_list))
           {
         _pdm_debug("before calling PDUload_refresh_from_parts_lis:", 0);
         _pdm_debug("refresh->rev_filename = <%s>", refresh->rev_filename);
             status = PDUload_refresh_from_parts_list();
             if (status == PDM_E_GENERATE_PARTS_LIST)
               {
               msg = (char *) PDUtranslate_message(PDM_E_GENERATE_PARTS_LIST);
               FIg_set_text(fp, FI_MSG_FIELD, msg);
               break;
               }
           }

          if ((refresh->rev_parttype) &&
             (strcmp(refresh->rev_parttype, "D") != 0) &&
             (strcmp(refresh->rev_parttype, "d") != 0) &&
             (strcmp(refresh->rev_parttype, "G") != 0) &&
             (strcmp(refresh->rev_parttype, "g") != 0))
            {
            msg = (char *)PDUtranslate_message(PDM_E_RETRIEVE_NONGRAPHIC);
            FIg_set_text(fp, FI_MSG_FIELD,msg);
            PDUmessage(PDM_E_RETRIEVE_NONGRAPHIC, 's');
            break;
            }

         _pdm_debug("before calling PDUcheck_part_data_for_utilities:", 0);
         _pdm_debug("refresh->rev_filename = <%s>", refresh->rev_filename);
          status = PDUcheck_part_data_for_utilities();
          _pdm_status("PDUcheck_part_data_for_utilities", status);
          if (status != PDM_S_SUCCESS)
            break;

         _pdm_debug("before calling PDUcheckout:", 0);
         _pdm_debug("refresh->rev_filename = <%s>", refresh->rev_filename);

         /* check to see if the part is checked in */
         status = PDMrcheck_part_status(refresh->rev_catalog, 
                                        refresh->rev_partid,
                                        refresh->rev_revision);
         _pdm_status("PDMrcheck_part_status", status);

         if (status == MEM_S_SUCCESS)
           {
           PDUmessage(PDM_E_ERROR_RETRIEVING_STATUS, 's');
           break;
           }

         if (status == PDM_I_NEVER_CHECKED_IN)
           {
           /* go ahead and activate the part */
           FIf_erase(forms.local_files_form_id);
           PDU_command = PDC_M_ACTIVATE_PART;
           status = PDUactivate();
           _pdm_status("PDUactivate", status);
           break;
           }

         else if (status == PDM_I_CHECKED_OUT_BY_YOU)
           {
           /* go ahead and activate the part */
           FIf_erase(forms.local_files_form_id);
           PDU_command = PDC_M_ACTIVATE_PART;
           status = PDUactivate();
           _pdm_status("PDUactivate", status);
           break;
           }

         else if (status == PDM_I_CHECKED_OUT_BY_ANOTHER_USER)
           {
           PDUmessage(status, 's');
           break;
           }

         else if ((status != PDM_I_CHECKED_IN) &&
                  (status != PDM_I_CHECKED_OUT_BY_YOU) &&
                  (status != PDM_I_NEVER_CHECKED_IN) &&
                  (status != PDM_I_COPIED_TO_LOCAL_BY_YOU) &&
                  (status != PDM_I_ATTACHED_TO_LOCAL_ASSY) &&
                  (status != PDM_I_CHECKED_OUT_BY_ANOTHER_USER))
           {
           PDUmessage(status, 's');
           break;
           }

         PDU_checkout_type = ACT;
         PDU_load_file_buffer = TRUE;

         status = PDUcheckout();
         _pdm_status("PDUcheckout", status);

         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           if (PDU_part_file_buffer)
             {
             PDU_part_file_buffer = NULL;
             MEMclose(&PDU_part_file_buffer);
             }
           break;
           }

         /* call function to display list of parts that may be activated */
         if ((PDU_part_file_buffer) && (PDU_part_file_buffer->rows > 0))
           {
           PDUpart_file_list_form();

           status = WaitForEvent();
           _pdm_status("WaitForEvent", status);

           if (!status)
             {
              _pdm_debug("part listing form was cancelled", 0);
              PDUmessage(PDM_E_CMD_CANCELLED, 's');
              break;
             }
           }
         else
           {
           /* put activate command on the queue */
           FIf_erase(forms.local_files_form_id);
           status = PDUactivate();
           _pdm_status("PDUactivate", status);
           }

         break;

    case REVIEW_DESIGN:  

	 _pdm_debug("entering case for REVIEW_DESIGN", 0);
	 PDU_activate_copy = TRUE;

         /* format the buffer */
         if (PDU_part_file_buffer)
           {
           MEMclose(&PDU_part_file_buffer);
           PDU_part_file_buffer = NULL;
           }

         if (PDU_selected_rows > 1)
           {
	   _pdm_debug("entering review design for multiple part selection", 0);

           status = PDUformat_buffer (PDU_PART_FILE_BUFFER,
                                      &PDU_part_file_buffer);
           _pdm_status("PDUformat_buffer", status);

           if (status != PDM_S_SUCCESS)
             {
             _pdm_debug("error formatting PDU_part_file_buffer", 0);
             PDU_load_file_buffer = FALSE;
             }
           else
             {
             _pdm_debug("PDU_part_file_buffer successfully formatted", 0);
             PDU_load_file_buffer = TRUE;
             }

	   PDUmessage(PDC_M_COPY, 'c');

           status = PDUcopy_file();
           _pdm_status("PDUcopy_file", status);

           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             if (status != PDM_E_COPY_FILES)
               {
	       MEMclose(&PDU_part_file_buffer);
               PDU_part_file_buffer = NULL;
               break;
               }
             }

           /* call function to display list of parts that may be activated */
	   if ((PDU_part_file_buffer) && (PDU_part_file_buffer->rows > 0))
             {
             PDUpart_file_list_form();

             status = WaitForEvent();
             _pdm_status("WaitForEvent", status);

             if (!status)
               {
                _pdm_debug("part listing form was cancelled", 0);
                PDUmessage(PDM_E_CMD_CANCELLED, 's');
                break;
               }
             }
           else
             {
             MEMclose(&PDU_part_file_buffer);
             PDU_part_file_buffer = NULL;
             }

           break;
           }

	 _pdm_debug("entering review design for single part selection", 0);
         if ((PDU_selected_rows == 1) && (PDU_mcf_list || PDU_structure_list))
           {
             status = PDUload_refresh_from_parts_list();
             if (status == PDM_E_GENERATE_PARTS_LIST)
               {
               msg = (char *) PDUtranslate_message(PDM_E_GENERATE_PARTS_LIST);
               FIg_set_text(fp, FI_MSG_FIELD, msg);
               break;
               }
           }

          if ((refresh->rev_parttype) &&
             (strcmp(refresh->rev_parttype, "D") != 0) &&
             (strcmp(refresh->rev_parttype, "d") != 0) &&
             (strcmp(refresh->rev_parttype, "G") != 0) &&
             (strcmp(refresh->rev_parttype, "g") != 0))
            {
            msg = (char *)PDUtranslate_message(PDM_E_RETRIEVE_NONGRAPHIC);
            FIg_set_text(fp, FI_MSG_FIELD,msg);
            PDUmessage(PDM_E_RETRIEVE_NONGRAPHIC, 's');
            break;
            }

          status = PDUcheck_part_data_for_utilities();
          _pdm_status("PDUcheck_part_data_for_utilities", status);
          if (status != PDM_S_SUCCESS)
            break;

         /* check to see if the part is checked in */
         status = PDMrcheck_part_status(refresh->rev_catalog, 
                                        refresh->rev_partid,
                                        refresh->rev_revision);
         _pdm_status("PDMrcheck_part_status", status);

         if (status == MEM_S_SUCCESS)
           {
           PDUmessage(PDM_E_ERROR_RETRIEVING_STATUS, 's');
           break;
           }

         if ((status == PDM_I_CHECKED_OUT_BY_YOU) ||
             (status == PDM_I_COPIED_TO_LOCAL_BY_YOU))
           {
           /* check to see if file is already local */
           status = PDUverify_file(refresh->rev_filename);
           _pdm_status("PDUverify_file", status);

           if (status == PDM_S_SUCCESS)  /* file is checked out */
             {
	     /* go ahead and activate the part */
             FIf_erase(forms.local_files_form_id);
             PDU_command = PDC_M_ACTIVATE_PART;

             status = PDUconvert_file_before_review();
             _pdm_status("PDUconvert_file_before_review", status);

             PDUchange_review_file_permissions(refresh->rev_filename, FALSE);
             status = PDUactivate();
             _pdm_status("PDUactivate", status);
             }
           }

         else if ((status == PDM_I_CHECKED_IN) ||
                  (status == PDM_I_ATTACHED_TO_LOCAL_ASSY) ||
                  (status == PDM_I_CHECKED_OUT_BY_ANOTHER_USER))
           {
           _pdm_debug("copying file for review design", 0);
           PDUmessage(PDC_M_COPY, 'c');
           status = PDUcopy_file();
           _pdm_status("PDUcopy_file", status);
           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }

           /* activate the part */
           FIf_erase(forms.local_files_form_id);
           PDU_command = PDC_M_ACTIVATE_PART;

           status = PDUconvert_file_before_review();
           _pdm_status("PDUconvert_file_before_review", status);

           PDUchange_review_file_permissions(refresh->rev_filename, FALSE);
           status = PDUactivate();
           _pdm_status("PDUactivate", status);
           break;
           }
	  
         else if (status == PDM_I_NEVER_CHECKED_IN)
           {
           status = PDUverify_file(refresh->rev_filename);
           _pdm_status("PDUverify_file", status);

           if (status == PDM_S_SUCCESS)  /* file is checked out */
             {
             _pdm_debug("activating new file", 0);
             /* go ahead and activate the part */
             FIf_erase(forms.local_files_form_id);
             PDU_command = PDC_M_ACTIVATE_PART;

             status = PDUconvert_file_before_review();
             _pdm_status("PDUconvert_file_before_review", status);

             PDUchange_review_file_permissions(refresh->rev_filename, FALSE);
             status = PDUactivate();
             _pdm_status("PDUactivate", status);
             break;
             }
           else if (status == PDM_E_FILE_NULL)
             {
             PDUmessage(PDM_E_NO_PART_FILES, 's');
             break;
             }
           else
             {
             PDUfill_in_string(&PDU_save_filename, refresh->rev_filename);
             PDUmessage(PDM_E_FILE_NOT_LOCAL, 's');
             break;
             }
           }

        else
          {
          PDUmessage(status, 's');
          break;
          }

         break;

    case REV_STRUCT_BTN:      /* same as LIST PART STRUCTURE */

         if (PDU_selected_rows > 0)
           part_count = PDUcount_selected_parts();
         else
           part_count = 0;

         if (part_count > 1)
           {
           PDUmessage(PDM_I_MULTIPLE_PARTS_SELECTED, 's');
           msg = (char *) PDUtranslate_message(PDM_I_MULTIPLE_PARTS_SELECTED);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }

         /*if (PDU_selected_rows == 1)*/
         if ((part_count == 1) && (PDU_mcf_list || PDU_structure_list))
             PDUload_refresh_from_parts_list();

         PDUmessage(PDM_E_CLEAR_FIELD, 's');
	 
         status = PDUverify_part_data(forms.local_files_form_id);
         _pdm_status("PDUverify_part_data", status);
         if (status != PDM_S_SUCCESS)
           break;

         if (refresh->rev_parttype &&
             (strcmp(refresh->rev_parttype, "G") != 0) &&
             (strcmp(refresh->rev_parttype, "g") != 0) &&
             (strcmp(refresh->rev_parttype, "M") != 0) &&
             (strcmp(refresh->rev_parttype, "m") != 0) &&
             (strcmp(refresh->rev_parttype, "P") != 0) &&
             (strcmp(refresh->rev_parttype, "p") != 0) &&
             (strcmp(refresh->rev_parttype, "A") != 0) &&
             (strcmp(refresh->rev_parttype, "a") != 0) &&
             (strcmp(refresh->rev_parttype, "N") != 0) &&
             (strcmp(refresh->rev_parttype, "n") != 0) &&
             (strcmp(refresh->rev_parttype, "D") != 0) &&
             (strcmp(refresh->rev_parttype, "d") != 0))
           {
           msg = (char *) PDUtranslate_message(PDM_E_INVALID_PARTTYPE);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           PDUmessage(PDM_E_INVALID_PARTTYPE, 's');
           break;
           }
         else if (!refresh->rev_parttype)
           {
           _pdm_debug("ERROR: refresh->rev_parttype is NULL", 0);
           msg = (char *) PDUtranslate_message(PDM_E_INVALID_PARTTYPE);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           PDUmessage(PDM_E_INVALID_PARTTYPE, 's');
           break;
           }
          
         PDUclear_mcf();

         status = PDMvalidate_user_access("PDMReview Assembly Structure",
                    NULLSTR, refresh->rev_catalog, NULLSTR, refresh->rev_partid,
                    refresh->rev_revision );
         _pdm_status ("PDMvalidate_user_access", status);

         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           return(status);
           }

         /* get the max level of display from the database */
         status = PDUget_max_level(&level);
         _pdm_status("PDUget_max_level", status);

         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status);
           break;
           }

         /* retrieve the structure of the part in the refresh */

         _pdm_debug("retrieving structure of part <%s>", refresh->rev_partid);
         status = PDMget_assembly_structure(refresh->rev_catalog, 
                                    refresh->rev_partid, refresh->rev_revision, 
                                    level, &PDU_parts_list_bufr, 0);
         _pdm_status("PDMget_assembly_structure", status);

         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }

         if (!(PDU_parts_list_bufr))
           {
	   PDUmessage(PDM_E_RETRIEVE_ASSEMBLY, 's');
           break;
           }

         if ((PDU_parts_list_bufr) && (PDU_parts_list_bufr->rows == 1))
           {
           PDUmessage(PDM_E_PART_NOT_ASSEMBLY, 's');
           msg = (char *) PDUtranslate_message(PDM_E_PART_NOT_ASSEMBLY);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }

         status = PDUdisplay_review_structure(PDU_parts_list_bufr);
         _pdm_status("PDUdisplay_review_structure", status);

         FIg_disable(forms.local_files_form_id, DELETE_LOCAL_BTN);

         break;

    /* Buttons from Entities button palette */

    case CATALOG_BTN:        
         FIf_erase(forms.local_files_form_id);
         PDU_local_files_displayed = FALSE;

         status = PDUcatalog_name_form();
         _pdm_status("PDUcatalog_name_form", status);
         break;

    case PARTS_BTN:         
         refresh->rev_filename = NULL;

         FIf_erase(forms.local_files_form_id);
         PDU_local_files_displayed = FALSE;

         status = PDUpart_form();
         _pdm_status("PDUpart_form", status);
         break;

    case REPORTS_BTN:        
         PDU_active_button = -1;
         FIf_erase(forms.local_files_form_id);
         PDU_local_files_displayed = FALSE;
         PDU_calling_form = fp;
         PDUreports_form();

         break;

    case PARM_PARTS_BTN:
         refresh->rev_filename = NULL;

         FIf_erase(forms.local_files_form_id);
         PDU_local_files_displayed = FALSE;

         status = PDUparametric_part_form(NULL_STRING);
         _pdm_status("PDUparametric_part_form", status);
         break;


    case UPDATE_DATABASE:        

         status = PDUverify_part_data(forms.local_files_form_id);
         _pdm_status("PDUverify_part_data", status);
         if (status != PDM_S_SUCCESS)
           break;

         status = PDUcheck_part("update database", POST_DATABASE);
         _pdm_status("PDUcheck_part", status);

         PDUmessage(status, 's');
         break;


    case DELETE_PART:        

         _pdm_debug("entering case for delete part", 0);

         if ((PDU_selected_rows == 1) && (PDU_mcf_list || PDU_structure_list))
             PDUload_refresh_from_parts_list();

         if (((refresh->rev_partid == NULL)            ||
             (strcmp(refresh->rev_partid, "") == 0)) &&
             (PDU_selected_rows == 0))
           {
           PDUmessage(PDM_I_ENTER_PART, 's');
           msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }

         _pdm_debug("calling UI_prompt", 0);
         prompt_str = (char *) PDUtranslate_message(PDP_P_DELETE_PART);
         UI_prompt(prompt_str);
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
         UI_prompt(NULL_STRING);
      
         _pdm_debug("answer = <%s>", answer);
       
         if ((strcmp(answer, "n")== 0) || (strcmp(answer, "N")==0))
           return(PDM_E_CMD_CANCELLED);
       
         PDU_command = PDC_M_DELETE_ELEMENT;

         status = PDUcheck_part("delete_part", PDC_M_DELETE_ELEMENT);
         _pdm_status("PDUcheck_part", 0);

         PDUmessage(status, 's');

         if (PDU_mcf_list && PDU_parts_list_bufr)
           {
           status1 = PDUupdate_buffer_after_delete_part();
           _pdm_status("PDUupdate_buffer_after_delete_part", status1);
           }

         if (status == PDM_S_SUCCESS)
           PDUmessage(status1, 's');

         break;

    case FLAG:        
         _pdm_debug("entering case for flag part", 0);

         if ((PDU_selected_rows == 1) && (PDU_mcf_list || PDU_structure_list))
             PDUload_refresh_from_parts_list();

         if (((refresh->rev_partid == NULL)            ||
             (strcmp(refresh->rev_partid, "") == 0))   &&
             (PDU_selected_rows == 0))
           {
           PDUmessage(PDM_I_ENTER_PART, 's');
           msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }

         FIg_set_state_off(fp, FLAG);
         PDUflag_form();

         break;

    case MOVE_STATE:        

         _pdm_debug("entering case for move to next state", 0);
 
         if ((PDU_selected_rows == 1) && (PDU_mcf_list || PDU_structure_list))
             PDUload_refresh_from_parts_list();
 
         if (((refresh->rev_partid == NULL)            ||
             (strcmp(refresh->rev_partid, "") == 0))   &&
             (PDU_selected_rows == 0))
           {
           PDUmessage(PDM_I_ENTER_PART, 's');
           msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }

         status = PDUstate_form();
         _pdm_status("PDUstate_form", status);

         PDUmessage(status, 's');

         break;

    case SELECT_ALL:        

         _pdm_debug("entering SELECT_ALL", 0);

         if (PDU_mcf_list)
           field = LIST_MCF;
         else if (PDU_structure_list)
           field = STRUCTURE_MCF;

         FIfld_get_num_rows(fp, field, &num_rows);
         _pdm_debug("num_rows = %d", (char *)num_rows);
         PDU_selected_rows = num_rows;
 
         for (row = 0; row < num_rows; ++row)
            {
            FImcf_set_select(fp, field, row, TRUE);
            PDU_parts_index[row] = row;
            }

         /* check to see if delete button should be enabled */
         FIg_disable(fp, DELETE_LOCAL_BTN);
         if (PDU_selected_rows > 0)
           {
           _pdm_debug("resetting delete button", 0);
           for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
              {
              FIfld_get_select(fp, LIST_MCF, row, 0, &mcf_select);
              if (mcf_select == TRUE)
                {
                FIfld_get_text_length(fp, LIST_MCF, row, 6, &length);
                text = (char *) malloc (sizeof (char) * length + 1);
                memset(text, NULL, sizeof (char) * length + 1);
                FIfld_get_text(fp, LIST_MCF, row, 6, length, 
                              (unsigned char *)text, &select, &pos);
                _pdm_debug("test = <%s>", text);
                if ((strcmp(text, "CHECKED OUT") == 0) ||
                    (strcmp(text, "COPIED TO LOCAL") == 0) ||
                    (strcmp(text, "CHECKED OUT & COPIED") == 0) ||
		    (strcmp(text, "CHECKED OUT & ATTACHED") == 0) ||
		    (strcmp(text, "COPIED & ATTACHED") == 0) ||
		    (strcmp(text, "CHECKED OUT, COPIED & ATTACHED") == 0) ||
                    (strcmp(text, "CHECKED OUT & ATTACH") == 0))
                  {
                  FIg_enable(fp, DELETE_LOCAL_BTN);
                  PDUfree_string(&text);
                  break;
                  }
                }
              PDUfree_string(&text);
              }
           }
         else
           FIg_disable(fp, DELETE_LOCAL_BTN);

         FIg_disable(fp, EDIT_ASSEMBLY_TGL);
         PDU_edit_display = FALSE;
         PDU_chkout_single = FALSE;

         if (PDU_param_cat == FALSE)
           {
           PDUenable_local_files_gadgets();
           FIg_enable(forms.local_files_form_id, REVISE_ASSEMBLY_BTN);
           FIg_enable(forms.local_files_form_id, PARTS_BTN);
           }
         else
           {
           PDUdisable_local_files_gadgets();
           FIg_disable(forms.local_files_form_id, REVISE_ASSEMBLY_BTN);
           FIg_disable(forms.local_files_form_id, PARTS_BTN);
           FIg_enable(forms.local_files_form_id, REV_STRUCT_BTN);
           }
         FIg_enable(forms.local_files_form_id, MOVE_STATE);

         break;

    case DESELECT_ALL:

         _pdm_debug("entering DESELECT_ALL", 0);

         if (PDU_mcf_list)
           field = LIST_MCF;
         else if (PDU_structure_list)
           field = STRUCTURE_MCF;

         FIfld_get_num_rows(fp, field, &num_rows);
         _pdm_debug("num_rows = %d", (char *)num_rows);
         PDU_selected_rows = 0;
 
         for (row = 0; row < num_rows; ++row)
            {
            FImcf_set_select(fp, field, row, FALSE);
            PDU_parts_index[row] = -1;
            }

         FIg_disable(fp, DELETE_LOCAL_BTN);
         PDU_chkout_single = TRUE;
         FIg_enable(fp, EDIT_ASSEMBLY_TGL);
	 FIg_get_state(fp, EDIT_ASSEMBLY_TGL, &state);
	 if (state == 1)
           PDU_edit_display = TRUE;
         else
           PDU_edit_display = FALSE;
         PDUcheck_file_commands();

         break;

    case EDIT_ASSEMBLY_TGL:

         FIg_get_state(fp, EDIT_ASSEMBLY_TGL, &state);
         _pdm_debug("assembly toggle = %d", (char *)state);

         if (state)
           PDU_edit_display = 1;
         else
           PDU_edit_display = 0;

         break;

    case REVISE_ASSEMBLY_BTN:

          if (PDU_selected_rows > 0)
            part_count = PDUcount_selected_parts();
          else
            part_count = 0;

          if (part_count > 1)
            {
            PDUmessage(PDM_I_MULTIPLE_PARTS_SELECTED, 's');
            msg = (char *) PDUtranslate_message(PDM_I_MULTIPLE_PARTS_SELECTED);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }

          if ((part_count == 1) && (PDU_mcf_list || PDU_structure_list))
              PDUload_refresh_from_parts_list();

          PDUmessage(PDM_E_CLEAR_FIELD, 's');

          status = PDUverify_part_data(forms.local_files_form_id);
          _pdm_status("PDUverify_part_data", status);
          if (status != PDM_S_SUCCESS)
            break;

          /* get the file status of the part */
          status = PDMrcheck_part_status(refresh->rev_catalog,
                          refresh->rev_partid, refresh->rev_revision);
          _pdm_status("PDMrcheck_part_status", status);

          if ((status != PDM_I_NEVER_CHECKED_IN) &&
              (status != PDM_I_CHECKED_IN))
            {
            PDUmessage(PDM_I_PART_CHECKIN, 's');
            msg = (char *)PDUtranslate_message(PDM_I_PART_CHECKIN);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }

          status = PDMvalidate_user_access("PDMCheck Out Part", NULLSTR,
                refresh->rev_catalog, NULLSTR, refresh->rev_partid,
                refresh->rev_revision );
          _pdm_status ("PDMvalidate_user_access", status);

          if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            msg = (char *)PDUtranslate_message(status);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }

          FIf_erase(fp);
          PDU_local_files_displayed = FALSE;

          PDU_command = PDC_M_REVISE_ASSEMBLY;
          PDUrevise_assembly_form();
          break;

  } /* END switch ( g_label ) */

  return(status);

} /* END notification_routine() */

/* This function loads/creates, initializes, and displays the local files
   form. */

int PDUlocal_files_form()
{
  int  sts = FI_SUCCESS;
  int  xpos;
  int  ypos;
  char type[5];

  PDU_local_files_created = FALSE;
  PDU_local_files_displayed = FALSE;
  PDU_selected_rows = 0;
  PDU_checkout_type = NONACT;
  PDU_mcf_list = FALSE;
  PDU_structure_list = FALSE;
  PDU_list_files = FALSE;
  PDU_perm_window = FALSE;
  PDU_local_perm_window = FALSE;
  PDU_assy_perm_window = FALSE;
  PDU_where_used_perm_window = FALSE;
  PDU_load_file_buffer = FALSE;
  place_part_f = NULL;
  ModifyPartForm = NULL;
  PDU_list_cat = FALSE;

  sts = FIf_new(LOCAL_FILES_FORM, "local_files", 
                local_files_notification_routine, &forms.local_files_form_id);

  _pdm_debug("Creating local files form", 0);
  PDU_local_files_created = TRUE;

  PDU_form_id = forms.local_files_form_id;

  sts = PDUconvert_form_to_win(forms.local_files_form_id);
  _pdm_status("PDUconvert_form_to_win", sts);

  /* Call function to initialize certain fields and gadgets */
  sts = PDUsetup_env();
  PDUdisable_local_files_gadgets();

  /* initialize PDU_refresh_gadgets */
  PDU_refresh_gadgets[0] = PROJECT_FLD;
  PDU_refresh_gadgets[1] = CATALOG_FLD;
  PDU_refresh_gadgets[2] = PARTNUM_FLD;
  PDU_refresh_gadgets[3] = PART_REV_FLD;
  PDU_refresh_gadgets[5] = PART_DESC_FLD;
  PDU_refresh_gadgets[6] = PART_FILE_FLD;

  /* restore refresh information */
  sts = PDUget_refresh();
  _pdm_status("PDUget_refresh()", sts);

  if (sts == PDM_S_SUCCESS)
    {
    /* validate refresh information */
    sts = PDUvalidate_refresh_data();
    _pdm_status("PDUvalidate_refresh_data", sts);

    /* load refresh information into the form */
    PDUload_refresh_at_login();
    }
  else
    {
    refresh->rev_project = NULL;
    refresh->rev_catalog = NULL;
    refresh->rev_partid = NULL;
    refresh->rev_revision = NULL;
    refresh->rev_description = NULL;
    refresh->rev_filename = NULL;
    refresh->rev_parttype = NULL;
    }
  refresh->command = 0;

  /* if external executable is running, erase file operation gadgets */
  if (PDU_extadmin)
    {
    FIg_erase(forms.local_files_form_id, CHECKIN_BTN);
    FIg_erase(forms.local_files_form_id, CHECKOUT_BTN);
    FIg_erase(forms.local_files_form_id, COPY_LOCAL_BTN);
    FIg_erase(forms.local_files_form_id, UPDATE_DATABASE);
    FIg_erase(forms.local_files_form_id, DELETE_LOCAL_BTN);
    FIg_erase(forms.local_files_form_id, DESIGN);
    FIg_erase(forms.local_files_form_id, REVIEW_DESIGN);
    FIg_erase(forms.local_files_form_id, EDIT_ASSEMBLY_TGL);
    FIg_erase(forms.local_files_form_id, 22); /* file operations text */
    FIg_erase(forms.local_files_form_id, 84); /* edit assy text */
    }

  /* set position of local files form */
  xpos = 0;
  ypos = 115;
  FIf_set_location(forms.local_files_form_id, xpos, ypos);

#if defined (sparc) || defined (__Sol2__)
  FIf_set_scaling_on(forms.local_files_form_id);
  FIf_set_size(forms.local_files_form_id, 950, 767);
#endif

  /* Display the local files form and set the displayed flag to TRUE. */
  _pdm_debug("Displaying the local files form", 0);

  sts = FIf_display(forms.local_files_form_id);
  PDU_local_files_displayed = TRUE;
  PDU_command = 0;

  /* position cursor */
  if ((refresh->rev_catalog == NULL) ||
      (strcmp(refresh->rev_catalog, "") == 0))
    {
    FIfld_pos_cursor(forms.local_files_form_id, CATALOG_FLD, 0,0,0,0,1,1);
    }
  else
    {
    /* check the type of the catalog */
    sts = PDMquery_catalog_type(refresh->rev_catalog, type);
    _pdm_status("PDMquery_catalog_type", sts);
    _pdm_debug("catalog type = <%s>", type);

    if ((strcmp(type, "P") == 0) || 
        (strcmp(type, "CID") == 0) || 
        (strcmp(type, "PXT") == 0) ||
        (strcmp(type, "EID") == 0))
      PDU_param_cat = TRUE;
    else
      {
      PDU_param_cat = FALSE;
      if ((refresh->rev_partid == NULL) ||
          (strcmp(refresh->rev_partid, "") == 0))
        FIfld_pos_cursor(forms.local_files_form_id, PARTNUM_FLD, 0,0,0,0,1,1);
      }
    }

  PDUcheck_file_commands();

  return(sts);
}

int PDUload_local_files_form()
{
extern int    PDU_mcf_list;
extern int    PDMdebug_on;
int           all_flag = FALSE;
int           no_headings;
int           status = PDM_S_SUCCESS;
int           display;
int           offset = 0;
char          **headings;
char          type[5];

  if ((PDU_parts_list_bufr == NULL) || (PDU_parts_list_bufr->rows == 0))
    {
    PDUmessage(PDM_I_NO_FILES_FOUND, 's');
    FIf_is_displayed(forms.local_files_form_id, &display);
    if (display == FALSE)
      {
      FIf_display(forms.local_files_form_id);
      }
    return(status);
    }

  if (PDMdebug_on)
    MEMprint_buffer("list buffer", PDU_parts_list_bufr, PDU_DEBUG_FILE);

  PDUsetup_single_buffer(PDU_parts_list_bufr);

  all_flag = FALSE;
  no_headings = 9;
  headings = (char **) malloc (sizeof (char *) * no_headings);
  memset(headings, NULL, sizeof (char *) * no_headings);

  PDUfill_in_string(&headings[0], "n_catalogname");
  PDUfill_in_string(&headings[1], "n_itemname");
  PDUfill_in_string(&headings[2], "n_itemrev");
  PDUfill_in_string(&headings[3], "n_itemdesc");
  PDUfill_in_string(&headings[4], "n_filetype");
  PDUfill_in_string(&headings[5], "n_cofilename");
  PDUfill_in_string(&headings[6], "p_local");
  PDUfill_in_string(&headings[7], "n_statename");
  PDUfill_in_string(&headings[8], "p_update");

  PDUsetup_popup_list(headings, no_headings, all_flag, PDU_parts_list_bufr);

  PDUfree_string_array(&headings, no_headings);

  if (PDU_mcf_list == FALSE)
     {
     FIg_display(forms.local_files_form_id, MCF_LIST_GRP);
     FIg_display(forms.local_files_form_id, SELECT_ALL);
     FIg_display(forms.local_files_form_id, DESELECT_ALL);
     }
  PDU_mcf_list = TRUE;
  PDU_selected_rows = 0;
  
  PDU_second_row = FALSE;
  PDUbufr_to_mcf(PDU_parts_list_bufr, forms.local_files_form_id, LIST_MCF);

  FIfld_set_num_rows(forms.local_files_form_id, LIST_MCF, 
                     PDU_parts_list_bufr->rows);

  FIfld_set_active_row(forms.local_files_form_id, LIST_MCF, 0, 0);

  /* delete text on rows with multiple files */
  PDUblank_out_multiple_files();

  /* initialize a global array for selected part rows */
  PDU_parts_index = (int *) malloc (sizeof (int)*PDU_parts_list_bufr->rows);
  memset(PDU_parts_index, -1, sizeof (int) * PDU_parts_list_bufr->rows);

  /* reset the part selection fields */
  if ((refresh->rev_project != NULL) && (strcmp(refresh->rev_project, "") != 0))
    FIg_set_text(forms.local_files_form_id, PROJECT_FLD, refresh->rev_project);
  else
    FIg_set_text(forms.local_files_form_id, PROJECT_FLD, "");

  if ((refresh->rev_catalog != NULL) && (strcmp(refresh->rev_catalog, "") != 0))
    {
    FIg_set_text(forms.local_files_form_id, CATALOG_FLD, refresh->rev_catalog);
    /* check the catalog type */
    status = PDMquery_catalog_type(refresh->rev_catalog, type);
    _pdm_status("PDMquery_catalog_type", status);

    _pdm_debug("catalog type = <%s>", type);

    if ((strcmp(type, "P") == 0) ||
        (strcmp(type, "CID") == 0) || 
        (strcmp(type, "PXT") == 0) ||
        (strcmp(type, "EID") == 0))
      PDU_param_cat = TRUE;
    else
      PDU_param_cat = FALSE;
    }
  else
    {
    FIg_set_text(forms.local_files_form_id, CATALOG_FLD, "");
    PDU_param_cat = FALSE;
    }

  if ((refresh->rev_partid != NULL) && (strcmp(refresh->rev_partid, "") != 0))
    FIg_set_text(forms.local_files_form_id, PARTNUM_FLD, refresh->rev_partid);
  else
    FIg_set_text(forms.local_files_form_id, PARTNUM_FLD, "");

  if ((refresh->rev_revision != NULL) && (strcmp(refresh->rev_revision,"")!= 0))
    FIg_set_text(forms.local_files_form_id,PART_REV_FLD,refresh->rev_revision);
  else
    FIg_set_text(forms.local_files_form_id, PART_REV_FLD, "");

  if ((refresh->rev_description != NULL) && 
      (strcmp(refresh->rev_description, "") != 0))
    FIg_set_text(forms.local_files_form_id, PART_DESC_FLD, 
                 refresh->rev_description);
  else
    FIg_set_text(forms.local_files_form_id, PART_DESC_FLD, "");

  if ((refresh->rev_filename != NULL) && (strcmp(refresh->rev_filename,"")!= 0))
    FIg_set_text(forms.local_files_form_id,PART_FILE_FLD,refresh->rev_filename);
  else
    FIg_set_text(forms.local_files_form_id, PART_FILE_FLD, "");

  if (PDU_param_cat == FALSE)
    {
    PDUenable_local_files_gadgets();
    FIg_enable(forms.local_files_form_id, REVISE_ASSEMBLY_BTN);
    FIg_enable(forms.local_files_form_id, PARTS_BTN);
    }
  else
    {
    PDUdisable_local_files_gadgets();
    FIg_disable(forms.local_files_form_id, REVISE_ASSEMBLY_BTN);
    FIg_disable(forms.local_files_form_id, PARTS_BTN);
    FIg_enable(forms.local_files_form_id, REV_STRUCT_BTN);
    FIg_enable(forms.local_files_form_id, MOVE_STATE);
    }

  FIfld_get_row_offset(forms.local_files_form_id, ROLL_THROUGH, &offset);
  if ((PDU_list_files == TRUE) && (offset == 1))
    {
    FIg_disable(forms.local_files_form_id, CHECKIN_BTN);
    PDU_list_files = FALSE;
    }

  if ((PDU_list_files == TRUE) && (offset == 2))
    {
    FIg_disable(forms.local_files_form_id, CHECKOUT_BTN);
    PDU_list_files = FALSE;
    }

  if ((PDU_list_files == TRUE) && (offset == 0))
    PDU_list_files = FALSE;

  FIf_is_displayed(forms.local_files_form_id, &display);
  if (display == FALSE)
    {
    FIf_display(forms.local_files_form_id);
    }

  if (PDU_selected_rows == 0)
    _pdm_debug("PDU_selected_rows = %d (leaving load_local_files_form)", 0);
  return(status);

}  /* end PDUload_local_files_form */

int PDUdisable_local_files_gadgets()
{
  _pdm_debug("in the function PDUdisable_local_files_gadgets", 0);

  FIg_disable(forms.local_files_form_id, CHECKIN_BTN);
  FIg_disable(forms.local_files_form_id, CHECKOUT_BTN);
  FIg_disable(forms.local_files_form_id, COPY_LOCAL_BTN);
  FIg_disable(forms.local_files_form_id, UPDATE_DATABASE);
  FIg_disable(forms.local_files_form_id, DELETE_LOCAL_BTN);
  FIg_disable(forms.local_files_form_id, REV_STRUCT_BTN);
  FIg_disable(forms.local_files_form_id, DESIGN);
  FIg_disable(forms.local_files_form_id, REVIEW_DESIGN);
  FIg_disable(forms.local_files_form_id, FLAG);
  FIg_disable(forms.local_files_form_id, MOVE_STATE);
  FIg_disable(forms.local_files_form_id, DELETE_PART);
  return(PDM_S_SUCCESS);
}

int PDUenable_local_files_gadgets()
{
  _pdm_debug("in the function PDUenable_local_files_gadgets", 0);

  FIg_enable(forms.local_files_form_id, CHECKIN_BTN);
  FIg_enable(forms.local_files_form_id, CHECKOUT_BTN);
  FIg_enable(forms.local_files_form_id, COPY_LOCAL_BTN);
  FIg_enable(forms.local_files_form_id, UPDATE_DATABASE);
  FIg_enable(forms.local_files_form_id, REV_STRUCT_BTN);
  FIg_enable(forms.local_files_form_id, DESIGN);
  FIg_enable(forms.local_files_form_id, REVIEW_DESIGN);
  FIg_enable(forms.local_files_form_id, FLAG);
  FIg_enable(forms.local_files_form_id, MOVE_STATE);
  FIg_enable(forms.local_files_form_id, DELETE_PART);
  return(PDM_S_SUCCESS);
}

int PDUcheck_file_commands()
{
  int   status = PDM_S_SUCCESS;
  int   file_col = 0;
  int   type_col = 0;
  int   num_rows = 0;
  int   row = 0;
  int   state = 0;
  char  *file = NULL;
  char  **data_row;
  char  type[2];
  char  *msg = NULL;
  MEMptr ret_bufr = NULL;
  extern void PDUclear_mcf();
  extern void PDUset_edit_assy_toggle_after_select();

  _pdm_debug("in the function PDUcheck_file_commands", 0);

  /* unselect the rows in the part listing area */
  if (PDU_form_id == forms.local_files_form_id)
    {
    if ((PDU_mcf_list == TRUE) && (PDU_selected_rows > 0))
      {
      _pdm_debug("deselecting rows in part listing area", 0);
      FIfld_get_num_rows(forms.local_files_form_id, LIST_MCF, &num_rows);

      /* do not deselect if the SELECT_ALL button was just selected */
      if (PDU_selected_rows != num_rows)
        {
        for (row = 0; row < num_rows; ++row)
           FImcf_set_select(forms.local_files_form_id, LIST_MCF, row, FALSE);
    
        /* reset the integer array that points to the rows */
        PDU_parts_index = (int *) malloc (sizeof (int) * num_rows);
        memset(PDU_parts_index, -1, sizeof (int) * num_rows);
        PDU_selected_rows = 0;
        }
      }
    else if ((PDU_structure_list == TRUE) && (PDU_selected_rows > 0))
      {
      _pdm_debug("deselecting rows in part listing area", 0);
      FIfld_get_num_rows(forms.local_files_form_id, STRUCTURE_MCF, &num_rows);

      /* do not deselect if the SELECT_ALL button was just selected */
      if (PDU_selected_rows != num_rows)
        {
        for (row = 0; row < num_rows; ++row)
         FImcf_set_select(forms.local_files_form_id, STRUCTURE_MCF, row, FALSE);
  
        /* reset the integer array that points to the rows */
        PDU_parts_index = (int *) malloc (sizeof (int) * num_rows);
        memset(PDU_parts_index, -1, sizeof (int) * num_rows);
        PDU_selected_rows = 0;
        }
      }
    }

  _pdm_debug("checking to see if files have been deleted", 0);
  _pdm_debug("PDU_files_deleted = %d", (char *)PDU_files_deleted);
  /*if ((PDU_form_id == forms.part_operations_form_id) && (PDU_files_deleted))*/
  if (PDU_files_deleted)
    {
    _pdm_debug("files were deleted while in the part session", 0);
    PDU_files_deleted = FALSE;
    PDUclear_mcf();
    }

  if (!(refresh->rev_catalog))
    {
    PDUfill_in_string(&refresh->rev_catalog, NULL_STRING);
    PDU_param_cat = FALSE;
    }
  else if (strcmp(refresh->rev_catalog, "") == 0)
    PDU_param_cat = FALSE;
  else if (strcmp(refresh->rev_catalog, "") != 0)
    {
    if (PDU_form_id == forms.local_files_form_id)
      {
      /* check the type of the catalog */
      status = PDMquery_catalog_type(refresh->rev_catalog, type);
      _pdm_status("PDMquery_catalog_type", status);

      _pdm_debug("catalog type = <%s>", type);
  
      if ((strcmp(type, "P") == 0) ||
          (strcmp(type, "CID") == 0) || 
          (strcmp(type, "PXT") == 0) ||
          (strcmp(type, "EID") == 0))
        {
        PDU_param_cat = TRUE;
        PDUdisable_local_files_gadgets();
        FIg_disable(forms.local_files_form_id, REVISE_ASSEMBLY_BTN);
        FIg_disable(forms.local_files_form_id, PARTS_BTN);
        }
      else
        {
        PDU_param_cat = FALSE;
        FIg_enable(forms.local_files_form_id, REVISE_ASSEMBLY_BTN);
        FIg_enable(forms.local_files_form_id, PARTS_BTN);
        FIg_enable(forms.local_files_form_id, DELETE_PART);
        } 
        FIg_enable(forms.local_files_form_id, MOVE_STATE);
      }
    }

  if (!(refresh->rev_partid))
    PDUfill_in_string(&refresh->rev_partid, NULL_STRING);
  if (!(refresh->rev_revision))
    PDUfill_in_string(&refresh->rev_revision, NULL_STRING);
  if (!(refresh->rev_filename))
    PDUfill_in_string(&refresh->rev_filename, NULL_STRING);

  _pdm_debug("refresh->rev_catalog = <%s>", refresh->rev_catalog);
  _pdm_debug("refresh->rev_partid = <%s>", refresh->rev_partid);
  _pdm_debug("refresh->rev_revision = <%s>", refresh->rev_revision);
  _pdm_debug("refresh->rev_filename = <%s>", refresh->rev_filename);
  _pdm_debug("refresh->rev_parttype = <%s>", refresh->rev_parttype);

  if ((refresh->rev_catalog != NULL)           &&
      (strcmp(refresh->rev_catalog, "") != 0)  &&
      (refresh->rev_partid != NULL)            &&
      (strcmp(refresh->rev_partid, "") != 0)   &&
      (refresh->rev_revision != NULL)          &&
      (strcmp(refresh->rev_revision, "") != 0))
    {
    if ((!refresh->rev_parttype) || ((refresh->rev_parttype) &&
        (strcmp(refresh->rev_parttype, "") == 0))) 
      {
      _pdm_debug("entering case to retrieve parttype", 0);
      if (ret_bufr)
        {
        MEMclose(&ret_bufr);
        ret_bufr = NULL;
        }
      status = PDMquery_part_type(refresh->rev_catalog,
                        refresh->rev_partid, refresh->rev_revision, &ret_bufr);
      _pdm_status("PDMquery_part_type", status);
   
      if ((ret_bufr) && (status == PDM_S_SUCCESS))
        {
        MEMbuild_array(ret_bufr);
        status = PDUget_buffer_col(ret_bufr, "p_parttype", &type_col);
        if (status != PDM_S_SUCCESS)
          return(status);
  
        PDUsetup_buffer(ret_bufr, ROW, &data_row);
  
        PDUfill_in_string(&refresh->rev_parttype,
                    data_row[(ret_bufr->columns * 0) + type_col]);
        _pdm_debug("parttype = <%s>", refresh->rev_parttype);
        MEMclose(&ret_bufr);
        }
      else
        {
        PDUmessage(status, 's');
        MEMclose(&ret_bufr);
        }
      }

    if ((refresh->rev_filename == NULL) || ((refresh->rev_filename) &&
        (strcmp(refresh->rev_filename, "") == 0))) 
      {
      _pdm_debug("entering case to retrieve filenames", 0);
      if ((refresh->command != PDC_M_LOGIN_USER) &&
          (refresh->rev_parttype != NULL) && (PDU_param_cat != TRUE))
        {
        status = PDMget_filenames(refresh->rev_catalog,refresh->rev_partid,
                        refresh->rev_revision, &ret_bufr);
        _pdm_status("PDMget_filenames", status);
    
        if ( status != PDM_S_SUCCESS )
          {
          /* automatically turn on part operation buttons */
          if (!PDU_param_cat)
            {
            FIg_enable(forms.local_files_form_id, FLAG);
            FIg_enable(forms.local_files_form_id, DELETE_PART);
            FIg_enable(forms.local_files_form_id, REV_STRUCT_BTN);
            }
          else
            {
            FIg_disable(forms.local_files_form_id, FLAG);
            FIg_disable(forms.local_files_form_id, DELETE_PART);
            FIg_disable(forms.local_files_form_id, REV_STRUCT_BTN);
            }
          FIg_enable(forms.local_files_form_id, MOVE_STATE);
     
          msg = (char *) PDUtranslate_message(PDM_E_NO_PART_FILES);
          FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
          MEMclose(&ret_bufr);
          PDUmessage(PDM_E_NO_PART_FILES, 's');
          return(status);
          }
    
        if ((ret_bufr == NULL) || (ret_bufr->rows == 0))
          {
          msg = (char *) PDUtranslate_message(PDM_E_FILE_NOT_FOUND);
          FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
          PDUmessage(PDM_E_FILE_NOT_FOUND, 's');
          return(PDM_E_FILE_NOT_FOUND);
          }
  
        MEMbuild_array(ret_bufr);
        PDUsetup_buffer(ret_bufr, ROW, &data_row);
        status = PDUget_buffer_col(ret_bufr, "n_cofilename", &file_col);
        if (status != PDM_S_SUCCESS)
          return(status);
    
        PDUfill_in_string(&file, data_row[(ret_bufr->columns * 0) + file_col]);
        if ((file != NULL) && (strcmp(file, "") != 0))
          {
          _pdm_debug("refresh->rev_filename = <%s>", refresh->rev_filename);
          PDUfill_in_string(&refresh->rev_filename, file);
          FIg_set_text(PDU_form_id, PDU_refresh_gadgets[6], 
                       refresh->rev_filename);
          }
        }
      }
    else
      {
      FIg_set_text(PDU_form_id, PDU_refresh_gadgets[6],refresh->rev_filename);
      }

    _pdm_debug("checking for local files form", 0);
    if (PDU_form_id == forms.local_files_form_id)
      {
      if (PDU_param_cat == FALSE)
        {
        PDUenable_local_files_gadgets();
        FIg_enable(forms.local_files_form_id, REVISE_ASSEMBLY_BTN);
        FIg_enable(forms.local_files_form_id, PARTS_BTN);
        }
      else
        {
        PDUdisable_local_files_gadgets();
        FIg_disable(forms.local_files_form_id, REVISE_ASSEMBLY_BTN);
        FIg_disable(forms.local_files_form_id, PARTS_BTN);
        FIg_enable(forms.local_files_form_id, REV_STRUCT_BTN);
        }
        FIg_enable(forms.local_files_form_id, MOVE_STATE);
     
      /* check to turn on delete local files button */
      if (PDU_command == PDC_M_DEACTIVATE_PART)
        {
        status = PDMrcheck_part_status(refresh->rev_catalog,
                        refresh->rev_partid, refresh->rev_revision);
        _pdm_status("PDMrcheck_part_status", status);

        if ((status == PDM_I_CHECKED_OUT_BY_YOU)  ||
            (status == PDM_I_COPIED_TO_LOCAL_BY_YOU))
          {
          _pdm_debug("turning delete local files button on", 0);
          FIg_enable(PDU_form_id, DELETE_LOCAL_BTN);
          }
        }

      /* check if toggle should be on or off */
      if (PDU_mcf_list)
        PDUset_edit_assy_toggle_after_select();
      else if (PDU_structure_list)
        {
        if (PDU_selected_rows > 1)
          {
          FIg_disable(forms.local_files_form_id, EDIT_ASSEMBLY_TGL);
          PDU_chkout_single = FALSE;
          PDU_edit_display = FALSE;
          }
        else
          {
          FIg_enable(forms.local_files_form_id, EDIT_ASSEMBLY_TGL);
          PDU_chkout_single = TRUE;
          FIg_get_state(forms.local_files_form_id, EDIT_ASSEMBLY_TGL, &state);
          if (state == 1)
            PDU_edit_display = TRUE;
          else
            PDU_edit_display = FALSE;
          }
        }
      }
    }
  else
    {
    PDUfill_in_string(&refresh->rev_filename, "");
    if (forms.local_files_form_id)
      FIg_set_text(forms.local_files_form_id, PDU_refresh_gadgets[6], "");
    if ((PDU_selected_rows == 0) && (PDU_form_id == forms.local_files_form_id))
      PDUdisable_local_files_gadgets();
    }

  return(status);
}

void PDUrefresh_local_files_form()
{
  int   status = PDM_S_SUCCESS;
  int   save_status = PDM_S_SUCCESS;
  static char *text = NULL;
  int   select, pos, length;
  extern void PDUclear_mcf();
  char  *msg = NULL;

  _pdm_debug("in the function PDUrefresh_local_files_form", 0);
  
  PDU_form_id = forms.local_files_form_id;
  PDU_active_button = -1;
  PDU_local_files_displayed = TRUE;

  /* initialize PDU_refresh_gadgets */
  PDU_refresh_gadgets[0] = PROJECT_FLD;
  PDU_refresh_gadgets[1] = CATALOG_FLD;
  PDU_refresh_gadgets[2] = PARTNUM_FLD;
  PDU_refresh_gadgets[3] = PART_REV_FLD;
  PDU_refresh_gadgets[5] = PART_DESC_FLD;
  PDU_refresh_gadgets[6] = PART_FILE_FLD;

  if (!(refresh->rev_catalog))
    {
    PDUfill_in_string(&refresh->rev_catalog, NULL_STRING);
    PDU_param_cat = FALSE;
    }
  else if (strcmp(refresh->rev_catalog, "") == 0)
    PDU_param_cat = FALSE;

  if (!(refresh->rev_partid))
    PDUfill_in_string(&refresh->rev_partid, NULL_STRING);
  if (!(refresh->rev_revision))
    PDUfill_in_string(&refresh->rev_revision, NULL_STRING);
  if (!(refresh->rev_description))
    PDUfill_in_string(&refresh->rev_description, NULL_STRING);
  if (!(refresh->rev_parttype))
    PDUfill_in_string(&refresh->rev_parttype, NULL_STRING);

  _pdm_debug("refresh->rev_catalog = <%s>", refresh->rev_catalog);
  _pdm_debug("refresh->rev_partid = <%s>", refresh->rev_partid);
  _pdm_debug("refresh->rev_revision = <%s>", refresh->rev_revision);
  _pdm_debug("refresh->rev_description = <%s>", refresh->rev_description);
  _pdm_debug("refresh->rev_parttype = <%s>", refresh->rev_parttype);

  _pdm_debug("checking for new catalog", 0);
  FIfld_get_text_length(forms.local_files_form_id, CATALOG_FLD, 0, 0, &length);
  text = (char *) malloc (sizeof (char) * length + 1);
  memset(text, NULL, sizeof (char) * length + 1);
  FIfld_get_text(forms.local_files_form_id, CATALOG_FLD, 0, 0, length,
                (unsigned char *)text, &select, &pos);
  _pdm_debug("text = <%s>", text);

  if (refresh->rev_catalog && (strcmp(refresh->rev_catalog, text) != 0))
    {
    _pdm_debug("catalog has been changed", 0);
    PDUclear_mcf();
    }
  else if (!refresh->rev_catalog)
    {
    _pdm_debug("catalog field has been cleared", 0);
    PDUclear_mcf();
    }
  else if (strcmp(refresh->rev_catalog, "") == 0)
    {
    _pdm_debug("catalog field has been cleared", 0);
    PDUclear_mcf();
    }

  if ((refresh->rev_project != NULL) && 
      (strcmp(refresh->rev_project, "") != 0) &&
      (refresh->rev_catalog != NULL) &&
      (strcmp(refresh->rev_catalog, "") != 0))
    {
    _pdm_debug("verifying catalog and project", 0);
    status = PDUvalid_project(refresh->rev_project,refresh->rev_catalog);
    _pdm_status("PDUvalid_project",status);

    if (status != PDM_S_SUCCESS)
      {
      status = PDM_E_WARN_CAT_PROJ_MAP;
      save_status = PDM_E_WARN_CAT_PROJ_MAP;
      msg = (char *) PDUtranslate_message(status);
      FIg_set_text(PDU_form_id, FI_MSG_FIELD, msg);
      PDUmessage(status, 's');
      }
    }

  if ((refresh->rev_project != NULL) && (strcmp(refresh->rev_project, "") != 0))
    FIg_set_text(forms.local_files_form_id, PROJECT_FLD, refresh->rev_project);
  else
    FIg_set_text(forms.local_files_form_id, PROJECT_FLD, "");

  if ((refresh->rev_catalog != NULL) && (strcmp(refresh->rev_catalog, "") != 0))
    {
    FIg_set_text(forms.local_files_form_id, CATALOG_FLD, refresh->rev_catalog);
    }
  else
    {
    FIg_set_text(forms.local_files_form_id, CATALOG_FLD, "");
    FIg_set_text(forms.local_files_form_id,PARTNUM_FLD,"");
    FIg_set_text(forms.local_files_form_id,PART_REV_FLD,"");
    FIg_set_text(forms.local_files_form_id, PART_DESC_FLD, "");
    refresh->rev_partid = NULL;
    refresh->rev_revision = NULL;
    refresh->rev_description = NULL;
    PDUcheck_file_commands();
    return;
    }

  if ((refresh->rev_partid != NULL) && (strcmp(refresh->rev_partid, "") != 0))
    FIg_set_text(forms.local_files_form_id,PARTNUM_FLD,refresh->rev_partid);
  else
    {
    FIg_set_text(forms.local_files_form_id,PARTNUM_FLD,"");
    FIg_set_text(forms.local_files_form_id,PART_REV_FLD,"");
    FIg_set_text(forms.local_files_form_id, PART_DESC_FLD, "");
    refresh->rev_revision = NULL;
    refresh->rev_description = NULL;
    PDUcheck_file_commands();
    return;
    }

  if ((refresh->rev_revision != NULL) &&
      (strcmp(refresh->rev_revision, "") != 0))
    FIg_set_text(forms.local_files_form_id,PART_REV_FLD,refresh->rev_revision);
  else
    {
    FIg_set_text(forms.local_files_form_id,PART_REV_FLD,"");
    FIg_set_text(forms.local_files_form_id, PART_DESC_FLD, "");
    refresh->rev_description = NULL;
    PDUcheck_file_commands();
    return;
    }

  if ((refresh->rev_description != NULL) &&
      (strcmp(refresh->rev_description, "") != 0))
    FIg_set_text(forms.local_files_form_id, PART_DESC_FLD, 
                 refresh->rev_description);
  else
    FIg_set_text(forms.local_files_form_id,PART_DESC_FLD,"");

  if ((refresh->rev_filename != NULL) &&
      (strcmp(refresh->rev_filename, "") != 0))
    FIg_set_text(forms.local_files_form_id, PART_FILE_FLD, 
                 refresh->rev_filename);
  else
    FIg_set_text(forms.local_files_form_id,PART_FILE_FLD,"");

  PDUcheck_file_commands();

  if (save_status == PDM_E_WARN_CAT_PROJ_MAP)
    PDUmessage(save_status, 's');
}

int PDUdismiss_subforms()
{
         if (PDU_single_list_displayed == TRUE)
           {
           _pdm_debug("deleting single list form", 0);
           FIf_erase(forms.single_list_form_id);
           FIf_delete(forms.single_list_form_id);
           PDU_single_list_displayed = FALSE;
           PDU_single_list_created = FALSE;
           }

         if (PDU_mcf_list_displayed == TRUE)
           {
           _pdm_debug("deleting mcf list form", 0);
           FIf_erase(forms.mcf_list_form_id);
           FIf_delete(forms.mcf_list_form_id);
           PDU_mcf_list_displayed = FALSE;
           PDU_mcf_list_created = FALSE;
           }

         if (PDU_file_list_displayed == TRUE)
           {
           _pdm_debug("deleting file list form", 0);
           FIf_erase(forms.file_list_form_id);
           FIf_delete(forms.file_list_form_id);
           PDU_file_list_displayed = FALSE;
           PDU_file_list_created = FALSE;
           }

         if (PDU_cat_list_displayed == TRUE)
           {
           _pdm_debug("deleting cat list form", 0);
           FIf_erase(forms.class_cat_form_id);
           FIf_delete(forms.class_cat_form_id);
           PDU_cat_list_displayed = FALSE;
           PDU_cat_list_created = FALSE;
           }

         if ((PDU_active_button != -1) && (PDU_form_id == forms.design_form_id))
           {
           _pdm_debug("setting active button OFF on design form", 0);
           FIg_set_state_off(PDU_form_id, PDU_active_list);
           FIg_display(PDU_form_id, PDU_active_list);
           /* restore active button */
           PDU_active_button = -1;
           }
         else if (PDU_active_button != -1)
           {
           _pdm_debug("setting active button OFF on PDU_form_id", 0);
           FIg_set_state_off(PDU_form_id, PDU_active_button);
           FIg_display(PDU_form_id, PDU_active_button);
           /* restore active button */
           PDU_active_button = -1;
           }

          end_np_cat_btn_flag = FALSE;
          end_np_part_btn_flag = FALSE;
          end_np_parttype_btn_flag = FALSE;
          end_ep_proj_btn_flag = FALSE;
          end_ep_cat_btn_flag = FALSE;
          end_ep_part_fld_flag = FALSE;
          end_ep_part_btn_flag = FALSE;
          end_ep_rev_btn_flag = FALSE;
          end_ep_desc_fld_flag = FALSE;
          end_ep_desc_btn_flag = FALSE;
          end_move_to_state_btn_flag = FALSE;
          pdu_hold_stg_bufr_flag = FALSE;
          pdu_hold_acl_bufr_flag = FALSE;
          pdu_ep_stg_bufr_flag = FALSE;
          pdu_ep_acl_bufr_flag = FALSE;
          PDU_list_cat = FALSE;

  return(PDM_S_SUCCESS);
}

int PDUload_refresh_at_login()
{
  if ((refresh->rev_project != NULL) && 
      (strcmp(refresh->rev_project, "") != 0))
    {
    FIg_set_text(forms.local_files_form_id, PROJECT_FLD, refresh->rev_project);
    PDUfill_in_string(&ep_project, refresh->rev_project);
    }

  if ((refresh->rev_catalog != NULL) && 
      (strcmp(refresh->rev_catalog, "") != 0))
    {
    FIg_set_text(forms.local_files_form_id, CATALOG_FLD, refresh->rev_catalog);
    PDUfill_in_string(&ep_catalog, refresh->rev_catalog);
    }

  if ((refresh->rev_partid != NULL) && 
      (strcmp(refresh->rev_partid, "") != 0))
    {
    FIg_set_text(forms.local_files_form_id, PARTNUM_FLD, refresh->rev_partid);
    PDUfill_in_string(&en_itemname, refresh->rev_partid);
    }

  if ((refresh->rev_revision != NULL) && 
      (strcmp(refresh->rev_revision, "") != 0))
    {
    FIg_set_text(forms.local_files_form_id,PART_REV_FLD,refresh->rev_revision);
    PDUfill_in_string(&ep_rev, refresh->rev_revision);
    }

  if ((refresh->rev_description != NULL) && 
      (strcmp(refresh->rev_description,"") != 0))
    {
    FIg_set_text(forms.local_files_form_id, PART_DESC_FLD, 
                 refresh->rev_description);
    PDUfill_in_string(&ep_desc, refresh->rev_description);
    }

  if ((refresh->rev_filename != NULL) && 
      (strcmp(refresh->rev_filename, "") != 0))
    FIg_set_text(forms.local_files_form_id,PART_FILE_FLD,refresh->rev_filename);

  return(PDM_S_SUCCESS);
}

PDUload_refresh_from_parts_list()
{

  int	       status = PDM_S_SUCCESS;
  int          cat_col;
  int          part_col;
  int          rev_col;
  int          desc_col;
  int          file_col;
  int          type_col;
  int          filename_col = 0;
  int          row;
  Form	       fp;
  char	       **list_row;
  char	       **data_row;
  MEMptr       ret_bufr = NULL;

  _pdm_debug("In the function PDUload_refresh_from_parts_list", 0);

  fp = forms.local_files_form_id;

  if (PDU_parts_list_bufr != NULL)
    {
    MEMbuild_array(PDU_parts_list_bufr);
    status = PDUget_buffer_col(PDU_parts_list_bufr, "n_catalogname", &cat_col);
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

    status = PDUget_buffer_col(PDU_parts_list_bufr, "n_cofilename", &file_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    status = PDUget_buffer_col(PDU_parts_list_bufr, "p_parttype", &type_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    PDUsetup_buffer(PDU_parts_list_bufr, ROW, &list_row);
    }
  else
    {
    PDUmessage(PDM_E_READ_PARTS, 's');
    return(PDM_E_READ_PARTS);
    }

  for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
     {
     if (PDU_parts_index[row] != -1)
       {
       PDUfill_in_string1(&refresh->rev_catalog,
                   list_row[(PDU_parts_list_bufr->columns * row) + cat_col]);
       PDUfill_in_string1(&refresh->rev_partid,
                   list_row[(PDU_parts_list_bufr->columns * row) + part_col]);
       PDUfill_in_string1(&refresh->rev_revision,
                   list_row[(PDU_parts_list_bufr->columns * row) + rev_col]);
       PDUfill_in_string1(&refresh->rev_description,
                   list_row[(PDU_parts_list_bufr->columns * row) + desc_col]);
       PDUfill_in_string1(&refresh->rev_parttype,
                   list_row[(PDU_parts_list_bufr->columns * row) + type_col]);

       _pdm_debug("refresh->rev_catalog = <%s>", refresh->rev_catalog);
       _pdm_debug("refresh->rev_partid = <%s>", refresh->rev_partid);
       _pdm_debug("refresh->rev_revision = <%s>", refresh->rev_revision);
       _pdm_debug("refresh->rev_description = <%s>", refresh->rev_description);
       _pdm_debug("refresh->rev_parttype = <%s>", refresh->rev_parttype);
       _pdm_debug("refresh->rev_filename = <%s>", refresh->rev_filename);

       if (((PDU_command == PDC_M_CHECKOUT_ACTIVATE) || (PDU_activate_copy) ||
           ((PDU_structure_list) && 
         (!strlen(list_row[(PDU_parts_list_bufr->columns * row) + file_col])))))
         {
         status = PDMget_filenames(refresh->rev_catalog,refresh->rev_partid,
                           refresh->rev_revision, &ret_bufr);
         _pdm_status("PDMget_filenames", status);
  
         if ((ret_bufr) && (ret_bufr->rows > 1))
           {
           _pdm_debug("files have been added to part, returning error msg", 0);
           return(PDM_E_GENERATE_PARTS_LIST);
           }

         if (!ret_bufr)
           return(PDM_E_NO_PART_FILES);

         status = MEMbuild_array(ret_bufr);
         _pdm_status("MEMbuild_buffer_array", status);
         if (status != MEM_S_SUCCESS)
           return(PDM_E_BUILD_BUFFER_ARRAY);

         PDUsetup_buffer(ret_bufr, ROW, &data_row);
         PDUget_buffer_col(ret_bufr, "n_cofilename", &filename_col);

         PDUfill_in_string1(&refresh->rev_filename,
                   data_row[(ret_bufr->columns * 0) + filename_col]);
         _pdm_debug("refresh->rev_filename = <%s>", refresh->rev_filename);
         }
       else
         {
         PDUfill_in_string1(&refresh->rev_filename,
                   list_row[(PDU_parts_list_bufr->columns * row) + file_col]);
         _pdm_debug("refresh->rev_filename = <%s>", refresh->rev_filename);
         }

       _pdm_debug("setting text on form", 0);
       if (refresh->rev_catalog)
         FIfld_set_text(fp, CATALOG, 0, 0, refresh->rev_catalog, FALSE);
       else
         FIfld_set_text(fp, CATALOG, 0, 0, NULL_STRING, FALSE);

       if (refresh->rev_partid)
         FIfld_set_text(fp, PARTNUM_FLD, 0, 0, refresh->rev_partid, FALSE);
       else
         FIfld_set_text(fp, PARTNUM_FLD, 0, 0, NULL_STRING, FALSE);

       if (refresh->rev_revision)
         FIfld_set_text(fp, PART_REV_FLD, 0, 0, refresh->rev_revision, FALSE);
       else
         FIfld_set_text(fp, PART_REV_FLD, 0, 0, NULL_STRING, FALSE);

       if (refresh->rev_description)
       FIfld_set_text(fp, PART_DESC_FLD, 0, 0, refresh->rev_description, FALSE);
       else
         FIfld_set_text(fp, PART_DESC_FLD, 0, 0, NULL_STRING, FALSE);

       if (refresh->rev_filename)
         FIfld_set_text(fp, PART_FILE_FLD, 0, 0, refresh->rev_filename, FALSE);
       else
         FIfld_set_text(fp, PART_FILE_FLD, 0, 0, NULL_STRING, FALSE);
       }
     }

  return(status);
}

int PDUcopy_structure_buffer_to_parts_buffer(buffer)
  MEMptr      buffer;
{
  int         status = PDM_S_SUCCESS;
  int	      level_col;
  int	      cat_col;
  int	      part_col;
  int	      rev_col;
  int	      file_col;
  int	      usage_col;
  int	      qty_col;
  int	      attach_col;
  int         row;
  int         char_index;
  char        *level = NULL;
  char        *catalog = NULL;
  char        *partid = NULL;
  char        *revision = NULL;
  char        *filename = NULL;
  char        *attached = NULL;
  char        *usageid = NULL;
  char        *quantity = NULL;
  char        **list_row;
  char        **data_row;
  char        *line = NULL;
  MEMptr      ret_bufr = NULL;

    _pdm_debug("in the function PDUcopy_structure_buffer_to_parts_buffer", 0);

    if (PDU_parts_list_bufr)
      {
      MEMclose(&PDU_parts_list_bufr);
      PDU_parts_list_bufr = NULL;
      }

    status = PDUformat_buffer (PDU_PARTS_LIST_BUFFER, &PDU_parts_list_bufr);
    _pdm_status("PDUformat_buffer", status);

    if (status != PDM_S_SUCCESS)
      {
      PDUmessage(status, 's');
      return(status);
      }

    line = (char*) malloc (PDU_parts_list_bufr->row_size);
    memset (line, NULL, PDU_parts_list_bufr->row_size);

    MEMbuild_array(buffer);
    status = PDUget_buffer_col(buffer, "p_level", &level_col);
    if (status != PDM_S_SUCCESS)
          return(status);

    status = PDUget_buffer_col(buffer, "n_catalogname", &cat_col);
    if (status != PDM_S_SUCCESS)
          return(status);

    status = PDUget_buffer_col(buffer, "n_itemname", &part_col);
    if (status != PDM_S_SUCCESS)
          return(status);

    status = PDUget_buffer_col(buffer, "n_itemrev", &rev_col);
    if (status != PDM_S_SUCCESS)
          return(status);

    status = PDUget_buffer_col(buffer, "p_attached", &attach_col);
    if (status != PDM_S_SUCCESS)
          return(status);

    status = PDUget_buffer_col(buffer, "p_quantity", &qty_col);
    if (status != PDM_S_SUCCESS)
          return(status);

    status = PDUget_buffer_col(buffer, "p_usageid", &usage_col);
    if (status != PDM_S_SUCCESS)
          return(status);

    PDUsetup_buffer(buffer, ROW, &list_row);

    _pdm_debug("buffer->rows = %d", (char *)buffer->rows);

    for (row = 1; row < buffer->rows; ++row)
       {
       _pdm_debug("reading buffer info for row %d", (char *)row);
       PDUfill_in_string(&level,
                         list_row[(buffer->columns * row) + level_col]);
       PDUfill_in_string(&catalog,
                         list_row[(buffer->columns * row) + cat_col]);
       PDUfill_in_string(&partid,
                         list_row[(buffer->columns * row) + part_col]);
       PDUfill_in_string(&revision,
                         list_row[(buffer->columns * row) + rev_col]);
       PDUfill_in_string(&attached,
                         list_row[(buffer->columns * row) + attach_col]);
       PDUfill_in_string(&quantity,
                         list_row[(buffer->columns * row) + qty_col]);
       PDUfill_in_string(&usageid,
                         list_row[(buffer->columns * row) + usage_col]);

       /* call PDM function to retrieve a list of filenames */
       status = PDMget_filenames(catalog,partid,revision, &ret_bufr);
       _pdm_status("PDMget_filenames", status);
       
       if ((ret_bufr) && (ret_bufr->rows > 0))
         {
         MEMbuild_array(ret_bufr);
         status = PDUget_buffer_col(ret_bufr, "n_cofilename", &file_col);
         if (status != PDM_S_SUCCESS)
           return(status);
  
         PDUsetup_buffer(ret_bufr, ROW, &data_row);
     
         PDUfill_in_string(&filename, data_row[(ret_bufr->columns*0)+file_col]);
         }
       else
         PDUfill_in_string(&filename, "");

       /* add the data to the buffer */
       char_index = 0;

       if ((strlen (level )) && level)
         PDUadd_buffer_string(line, &char_index, level);
       else
         line[char_index++] = '\1';

       if ((strlen (catalog )) && catalog)
         PDUadd_buffer_string(line, &char_index, catalog);
       else
         line[char_index++] = '\1';

       if ((strlen (partid )) && partid)
         PDUadd_buffer_string(line, &char_index, partid);
       else
         line[char_index++] = '\1';

       if ((strlen (revision )) && revision)
         PDUadd_buffer_string(line, &char_index, revision);
       else
         line[char_index++] = '\1';

       if ((strlen (filename )) && filename)
         PDUadd_buffer_string(line, &char_index, filename);
       else
         line[char_index++] = '\1';

       if ((strlen (attached )) && attached)
         PDUadd_buffer_string(line, &char_index, attached);
       else
         line[char_index++] = '\1';

       if ((strlen (quantity )) && quantity)
         PDUadd_buffer_string(line, &char_index, quantity);
       else
         line[char_index++] = '\1';

       if ((strlen (usageid )) && usageid)
         PDUadd_buffer_string(line, &char_index, usageid);
       else
         line[char_index++] = '\1';

       _pdm_debug("line = <%s>", line);
       status = MEMwrite (PDU_parts_list_bufr, line);

       if (status != MEM_S_SUCCESS)
         {
         _pdm_debug("Error writing to PDU_parts_list_bufr buffer", 0);
         _pdm_status("MEMwrite()", status);
         return(status);
         }

       memset (line, NULL, PDU_parts_list_bufr->row_size);

       /* reset variables */
       level = NULL_STRING;
       catalog = NULL_STRING;
       partid = NULL_STRING;
       revision = NULL_STRING;
       attached = NULL_STRING;
       quantity = NULL_STRING;
       usageid = NULL_STRING;
       }

   if (PDMdebug_on)
    MEMprint_buffer("parts list", PDU_parts_list_bufr, PDU_DEBUG_FILE);

   if (status == MEM_S_SUCCESS)
     status = PDM_S_SUCCESS;

   return(status);
}

int PDURetFromSelect(form)
Form      form;
{
int       status = PDM_S_SUCCESS;

  _pdm_debug("in the function PDURetFromSelect", 0);

  if (form == forms.part_operations_form_id)
    {
    _pdm_debug("calling function to update part operations form", 0);
    status = PDUupdate_part_form_after_select();
    _pdm_status("PDUupdate_part_form_after_select", status);
    }

  if (form == forms.seed_form_form_id)
    {
    _pdm_debug("calling function to update seed form", 0);
    status = PDUupdate_seed_form_after_select();
    _pdm_status("PDUupdate_seed_form_after_select", status);
    }

  if (form == forms.local_files_form_id)
    {
    _pdm_debug("calling function to update local_files form", 0);
    status = PDUupdate_local_files_form_after_select();
    _pdm_status("PDUupdate_local_files_form_after_select", status);
    }

  if (form == forms.topdown_form_id)
    {
    _pdm_debug("calling function to update topdown form", 0);
    status = PDUupdate_topdown_form_after_select();
    _pdm_status("PDUupdate_topdown_form_after_select", status);
    }

  if (form == forms.parametric_catalog_form_id)
    {
    status = PDUupdate_parametric_catalog_form();
    _pdm_status("PDUupdate_parametric_catalog_form", status);
    }

  if (form == forms.report_form_id)
    {
    status = PDUupdate_report_form();
    _pdm_status("PDUupdate_report_form", status);
    FIf_display(forms.report_form_id);
    }

  if (form == forms.parametric_parts_form_id)
    {
    status = PDUload_parametric_parts_after_select();
    _pdm_status("PDUload_parametric_parts_after_select", status);
    FIf_display(forms.parametric_parts_form_id);
    }

  if (form == forms.ex_file_form_id)
    {
    status = PDUprocess_ex_file_form_after_select();
    _pdm_status("PDUprocess_ex_file_form_after_select", status);
    }

  if (form == forms.rev_assy_form_id)
    {
    status = PDUupdate_revise_assy_form_after_select();
    _pdm_status("PDUupdate_revise_assy_form_after_select", status);
    return(status);
    }

  PDUmessage(status, 's');
  return(status);
}

int PDUupdate_topdown_form_after_select()
{
  int status = PDM_S_SUCCESS;

  _pdm_debug("in the function PDUupdate_topdown_form_after_select", 0);

  _pdm_debug("resetting refresh gadgets", 0);
  PDU_refresh_gadgets[0] = 0;
  PDU_refresh_gadgets[1] = TD_CATALOG;
  PDU_command = PDC_M_CREATE_TOP_DOWN;

  if ((PDUsearch_part_list != NULL) && (PDUsearch_part_list->rows > 0))
    {
    MEMsplit_copy_buffer(PDUsearch_part_list, &PDU_assy_parts_bufr, 0);
/*
    MEMclose(&PDUsearch_part_list);
    PDUsearch_part_list = NULL;
*/
    }
  else
    {
    FIf_display(forms.topdown_form_id);
    if (refresh->status == PDM_E_CMD_CANCELLED)
      status = PDM_E_CMD_CANCELLED;
    else
      status = PDM_I_NO_FILES_FOUND;
    PDUmessage(status, 's');
/*
    MEMclose(&PDUsearch_part_list);
    PDUsearch_part_list = NULL;
*/
    return(status);
    }

  /* write refresh information to the form fields */

  if (refresh->rev_catalog)
    FIg_set_text(forms.topdown_form_id, TD_CATALOG, refresh->rev_catalog);
  if (refresh->rev_partid)
    FIg_set_text(forms.topdown_form_id, TD_PARTID, refresh->rev_partid);
  if (refresh->rev_revision)
    FIg_set_text(forms.topdown_form_id, TD_REVISION, refresh->rev_revision);
  if (refresh->rev_description)
    FIg_set_text(forms.topdown_form_id, TD_DESC, refresh->rev_description);
  if (refresh->rev_filename)
    FIg_set_text(forms.topdown_form_id, TD_FILENAME, refresh->rev_filename);

  /* restore original refresh information */

  /* commented out JBP because of TR#139420762 */
  /*if (PDU_save_project)
    PDUfill_in_string(&refresh->rev_project, PDU_save_project);
  if (PDU_save_catalog)
    PDUfill_in_string(&refresh->rev_catalog, PDU_save_catalog);
  if (PDU_save_partid)
    PDUfill_in_string(&refresh->rev_partid, PDU_save_partid);
  if (PDU_save_revision)
    PDUfill_in_string(&refresh->rev_revision, PDU_save_revision);
  if (PDU_save_description)
    PDUfill_in_string(&refresh->rev_description, PDU_save_description);
  if (PDU_save_filename)
    PDUfill_in_string(&refresh->rev_filename, PDU_save_filename);
  if (PDU_save_parttype)
    PDUfill_in_string(&refresh->rev_parttype, PDU_save_parttype);*/

  PDU_form_id = forms.topdown_form_id;
  FIf_display(forms.topdown_form_id);
  return(PDM_S_SUCCESS);
  
}

int PDUupdate_local_files_form_after_select()
{
int           status = PDM_S_SUCCESS;
int           char_index = 0;
int           row;
int           cat_col;
int           part_col;
int           rev_col;
int           type_col;
char          *catalog = NULL;
char          *partid = NULL;
char          *revision = NULL;
char          *line = NULL;
char          **data_row;
MEMptr        temp_buffer = NULL;
MEMptr        buffer = NULL;

  _pdm_debug("in the function PDUupdate_local_files_form_after_select", 0);

  _pdm_debug("resetting refresh gadgets", 0);
  PDU_refresh_gadgets[0] = PROJECT_FLD;
  PDU_refresh_gadgets[1] = CATALOG_FLD;

  if (refresh->status == PDM_E_CMD_CANCELLED)
     {
     _pdm_debug("search form was cancelled", 0);
     FIf_display(forms.local_files_form_id);

     _pdm_debug("resetting refresh information", 0);
     if (PDU_save_project)
       PDUfill_in_string(&refresh->rev_project, PDU_save_project);
     if (PDU_save_catalog)
       PDUfill_in_string(&refresh->rev_catalog, PDU_save_catalog);
     if (PDU_save_partid)
       PDUfill_in_string(&refresh->rev_partid, PDU_save_partid);
     if (PDU_save_revision)
       PDUfill_in_string(&refresh->rev_revision, PDU_save_revision);
     if (PDU_save_description)
       PDUfill_in_string(&refresh->rev_description, PDU_save_description);
     if (PDU_save_filename)
       PDUfill_in_string(&refresh->rev_filename, PDU_save_filename);
     if (PDU_save_parttype)
       PDUfill_in_string(&refresh->rev_parttype, PDU_save_parttype);
     status = PDM_E_CMD_CANCELLED;
     PDUmessage(status, 's');
     return(status);
     }

  if (!refresh->rev_project)
    FIg_set_text(forms.local_files_form_id, PROJECT_FLD, NULL_STRING);
  else if (strcmp(refresh->rev_project, "") == 0)
    FIg_set_text(forms.local_files_form_id, PROJECT_FLD, NULL_STRING);

  if (PDU_parts_list_bufr)
    {
    MEMclose(&PDU_parts_list_bufr);
    PDU_parts_list_bufr = NULL;
    }

  if ((PDUsearch_part_list == NULL) || (PDUsearch_part_list->rows == 0))
    {
    FIf_display(forms.local_files_form_id);
    if (refresh->status == PDM_E_CMD_CANCELLED)
      status = PDM_E_CMD_CANCELLED;
    else
      status = PDM_I_NO_FILES_FOUND;
    return(status);
    }

  /* format a temporary buffer */
  MEMopen(&temp_buffer, 512);
  MEMwrite_format(temp_buffer, "n_catalogname", "char(20)");
  MEMwrite_format(temp_buffer, "n_itemname", "char(40)");
  MEMwrite_format(temp_buffer, "n_itemrev", "char(40)");

  MEMbuild_array(PDUsearch_part_list);
  status = PDUget_buffer_col(PDUsearch_part_list, "n_catalogname", &cat_col); 
  if (status != PDM_S_SUCCESS)
          return(status);

  status = PDUget_buffer_col(PDUsearch_part_list, "n_itemname", &part_col); 
  if (status != PDM_S_SUCCESS)
          return(status);

  status = PDUget_buffer_col(PDUsearch_part_list, "n_itemrev", &rev_col); 
  if (status != PDM_S_SUCCESS)
          return(status);

  PDUsetup_buffer(PDUsearch_part_list, ROW, &data_row);

  line = (char*) malloc (PDUsearch_part_list->row_size);

  /* copy the first 3 columns of the buffer to temp buffer */
  for (row = 0; row < PDUsearch_part_list->rows; ++row)
     {
     memset (line, NULL, PDUsearch_part_list->row_size);
     char_index = 0;

     PDUfill_in_string(&catalog, 
             data_row[(PDUsearch_part_list->columns * row) + cat_col]);
     PDUfill_in_string(&partid, 
             data_row[(PDUsearch_part_list->columns * row) + part_col]);
     PDUfill_in_string(&revision, 
             data_row[(PDUsearch_part_list->columns * row) + rev_col]);

     if (catalog && (strlen (catalog )))
       PDUadd_buffer_string(line, &char_index, catalog);
     else
       line[char_index++] = '\1';

     if (partid && (strlen (partid )))
       PDUadd_buffer_string(line, &char_index, partid);
     else
       line[char_index++] = '\1';

     if (revision && (strlen (revision )))
       PDUadd_buffer_string(line, &char_index, revision);
     else
       line[char_index++] = '\1';

     _pdm_debug("line = <%s>", line);

     status = MEMwrite (temp_buffer, line);
     if (status != MEM_S_SUCCESS)
       {
       _pdm_debug("Error writing to temp_buffer", 0);
       _pdm_status("MEMwrite ()", status);
       FIf_display(forms.local_files_form_id);
       return(status);
       }
     }
  PDUfree_string(&line);

/*
  MEMclose(&PDUsearch_part_list);
  PDUsearch_part_list = NULL;
*/

  if (PDM_debug_on)
    MEMprint_buffer("shortened parts list", temp_buffer, PDU_DEBUG_FILE);

  PDUmessage(PDS_M_EXPAND_PARTS, 's');

  status = PDMexpand_parts_list(temp_buffer, NULL, &PDU_parts_list_bufr);
  _pdm_status("PDMexpand_parts_list", status);

  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  MEMclose(&temp_buffer);
  temp_buffer = NULL;

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    MEMclose(&PDU_parts_list_bufr);
    PDU_parts_list_bufr = NULL;
    FIf_display(forms.local_files_form_id);
    return(status);
    }

  if (PDM_debug_on)
    MEMprint_buffer("expanded parts list", PDU_parts_list_bufr, PDU_DEBUG_FILE);

  PDU_form_id = forms.local_files_form_id;
  status = PDUload_local_files_form();
  _pdm_status("PDUload_local_files_form", status);

  /* get the parttype for the part in the refresh */
  if (refresh->rev_catalog && refresh->rev_partid && refresh->rev_revision &&
     (strlen(refresh->rev_catalog)) && 
     (strlen(refresh->rev_partid)) &&
     (strlen(refresh->rev_revision)))
    {
    if (!refresh->rev_parttype)
      {
      _pdm_debug("querying for parttype", 0);
      status = PDMquery_part_type(refresh->rev_catalog,
                                  refresh->rev_partid,
                                  refresh->rev_revision, &buffer);
    
      if ((buffer) && (status == PDM_S_SUCCESS))
        {
        MEMbuild_array(buffer);
        status = PDUget_buffer_col(buffer, "p_parttype", &type_col);
        if (status != PDM_S_SUCCESS)
          return(status);
    
        PDUsetup_buffer(buffer, ROW, &data_row);
    
        PDUfill_in_string(&refresh->rev_parttype,
                    data_row[(buffer->columns * 0) + type_col]);
        _pdm_debug("parttype = <%s>", refresh->rev_parttype);
        MEMclose(&buffer);
        }
      else
        {
        PDUmessage(status, 's');
        MEMclose(&buffer);
        return(status);
        }
      }
    else if (!strlen(refresh->rev_parttype))
      {
      _pdm_debug("querying for parttype", 0);
      status = PDMquery_part_type(refresh->rev_catalog,
                                  refresh->rev_partid,
                                  refresh->rev_revision, &buffer);
    
      if ((buffer) && (status == PDM_S_SUCCESS))
        {
        MEMbuild_array(buffer);
        status = PDUget_buffer_col(buffer, "p_parttype", &type_col);
        if (status != PDM_S_SUCCESS)
          return(status);
    
        PDUsetup_buffer(buffer, ROW, &data_row);
    
        PDUfill_in_string(&refresh->rev_parttype,
                    data_row[(buffer->columns * 0) + type_col]);
        _pdm_debug("parttype = <%s>", refresh->rev_parttype);
        MEMclose(&buffer);
        }
      else
        {
        PDUmessage(status, 's');
        MEMclose(&buffer);
        return(status);
        }
      }
    }

  PDUcheck_file_commands();

  return(status);
}

int PDUvalidate_refresh_data()
{
int   status = PDM_S_SUCCESS;

  bufr_flag = FALSE;

  if (refresh->rev_project == NULL)
    refresh->rev_project = NULL_STRING;
  if (refresh->rev_catalog == NULL)
    refresh->rev_catalog = NULL_STRING;
  if (refresh->rev_partid == NULL)
    refresh->rev_partid = NULL_STRING;
  if (refresh->rev_revision == NULL)
    refresh->rev_revision = NULL_STRING;
  if (refresh->rev_description == NULL)
    refresh->rev_description = NULL_STRING;
  if (refresh->rev_filename == NULL)
    refresh->rev_filename = NULL_STRING;
  if (refresh->rev_parttype == NULL)
    refresh->rev_parttype = NULL_STRING;
  
  _pdm_debug("refresh data before validation", 0);
  _pdm_debug("refresh->rev_project = <%s>", refresh->rev_project);
  _pdm_debug("refresh->rev_catalog = <%s>", refresh->rev_catalog);
  _pdm_debug("refresh->rev_partid = <%s>", refresh->rev_partid);
  _pdm_debug("refresh->rev_revision = <%s>", refresh->rev_revision);
  _pdm_debug("refresh->rev_description = <%s>", refresh->rev_description);
  _pdm_debug("refresh->rev_parttype = <%s>", refresh->rev_parttype);
  _pdm_debug("refresh->rev_filename = <%s>", refresh->rev_filename);

  if ((refresh->rev_project != NULL) &&
      (strcmp(refresh->rev_project, "") != 0) &&
      (refresh->rev_catalog != NULL) &&
      (strcmp(refresh->rev_catalog, "") != 0))
    {
    _pdm_debug("verifying catalog and project", 0);
    status = PDUvalid_project(refresh->rev_project,refresh->rev_catalog);
    _pdm_status("PDUvalid_project",status);
 
    if (status != PDM_S_SUCCESS)
      {
      refresh->rev_project = NULL_STRING;
      FIg_set_text(forms.local_files_form_id, PROJECT_FLD, "");
      }
    }

  if (status != PDM_S_SUCCESS)
    refresh->rev_project = NULL_STRING;

  if (strcmp(refresh->rev_catalog, "") != 0)
    {
    status = PDUvalid_catalog(refresh->rev_project, refresh->rev_catalog);
    _pdm_status("PDUvalid_catalog", status);

    if (status != PDM_S_SUCCESS)
      {
      PDUfill_in_string1(&refresh->rev_project, "");
      PDUfill_in_string1(&refresh->rev_catalog, "");
      PDUfill_in_string1(&refresh->rev_partid, "");
      PDUfill_in_string1(&refresh->rev_revision, "");
      PDUfill_in_string1(&refresh->rev_description, "");
      PDUfill_in_string1(&refresh->rev_parttype, "");
      PDUfill_in_string1(&refresh->rev_filename, "");
      return(status);
      }
    }
  else if (strcmp(refresh->rev_project, "") != 0)
    {
    status = PDUvalid_project(refresh->rev_project, "");
    _pdm_status("PDUvalid_project", status);

    if (status != PDM_S_SUCCESS)
      {
      PDUfill_in_string1(&refresh->rev_project, "");
      PDUfill_in_string1(&refresh->rev_catalog, "");
      PDUfill_in_string1(&refresh->rev_partid, "");
      PDUfill_in_string1(&refresh->rev_revision, "");
      PDUfill_in_string1(&refresh->rev_description, "");
      PDUfill_in_string1(&refresh->rev_parttype, "");
      PDUfill_in_string1(&refresh->rev_filename, "");
      return(status);
      }
    }
  else if ((strcmp(refresh->rev_project, "") == 0) &&
           (strcmp(refresh->rev_catalog, "") == 0))
    {
    PDUfill_in_string1(&refresh->rev_partid, "");
    PDUfill_in_string1(&refresh->rev_revision, "");
    PDUfill_in_string1(&refresh->rev_description, "");
    PDUfill_in_string1(&refresh->rev_parttype, "");
    PDUfill_in_string1(&refresh->rev_filename, "");
    return(0);
    }

  if ((strcmp(refresh->rev_partid, "") != 0) &&
      (strcmp(refresh->rev_revision, "") != 0))
    {
    status = PDMcheck_partnum(refresh->rev_catalog, refresh->rev_partid,
                     refresh->rev_revision);
    _pdm_status("PDMcheck_partnum", status);
    MEMclose(&PDU_ret_bufr); PDU_ret_bufr = NULL;

    if (status != PDM_S_SUCCESS)
      {
      PDUfill_in_string1(&refresh->rev_partid, "");
      PDUfill_in_string1(&refresh->rev_revision, "");
      PDUfill_in_string1(&refresh->rev_description, "");
      PDUfill_in_string1(&refresh->rev_parttype, "");
      PDUfill_in_string1(&refresh->rev_filename, "");
      return(status);
      }
    else if ((status == PDM_S_SUCCESS) && 
             (strcmp(refresh->rev_project, "") != 0))
      {
      status = PDMpart_in_project(refresh->rev_project,refresh->rev_catalog,
                                  refresh->rev_partid,refresh->rev_revision);
      _pdm_status("PDMpart_in_project",status);

      if (status != PDM_S_SUCCESS)
        {
        PDUfill_in_string1(&refresh->rev_partid, "");
        PDUfill_in_string1(&refresh->rev_revision, "");
        PDUfill_in_string1(&refresh->rev_description, "");
        PDUfill_in_string1(&refresh->rev_parttype, "");
        PDUfill_in_string1(&refresh->rev_filename, "");
        return(status);
        }
      }
    }
  else if ((strcmp(refresh->rev_partid, "") != 0) &&
           (strcmp(refresh->rev_revision, "") == 0))
    {
    status = PDUvalid_partnum(refresh->rev_catalog, refresh->rev_partid);
    _pdm_status("PDUvalid_partnum", status);

    if (status != PDM_S_SUCCESS)
      {
      PDUfill_in_string1(&refresh->rev_partid, "");
      PDUfill_in_string1(&refresh->rev_revision, "");
      PDUfill_in_string1(&refresh->rev_description, "");
      PDUfill_in_string1(&refresh->rev_parttype, "");
      PDUfill_in_string1(&refresh->rev_filename, "");
      return(status);
      }
    else
      {
      PDUfill_in_string1(&refresh->rev_description, "");
      PDUfill_in_string1(&refresh->rev_parttype, "");
      PDUfill_in_string1(&refresh->rev_filename, "");
      return(status);
      }
    }
  else if ((strcmp(refresh->rev_partid, "") == 0) &&
           (strcmp(refresh->rev_revision, "") == 0))
    {
    PDUfill_in_string1(&refresh->rev_description, "");
    PDUfill_in_string1(&refresh->rev_parttype, "");
    PDUfill_in_string1(&refresh->rev_filename, "");
    return(0);
    }

  if (strcmp(refresh->rev_filename, "") != 0)
    {
    status = PDUvalid_filename(refresh->rev_catalog,
                               refresh->rev_partid,
			       refresh->rev_revision,
			       refresh->rev_filename);
    _pdm_status("PDUvalid_filename", status);

    if (status != PDM_S_SUCCESS)
      {
      PDUfill_in_string1(&refresh->rev_filename, "");
      return(status);
      }
    }

  _pdm_debug("refresh data after validation", 0);
  _pdm_debug("refresh->rev_project = <%s>", refresh->rev_project);
  _pdm_debug("refresh->rev_catalog = <%s>", refresh->rev_catalog);
  _pdm_debug("refresh->rev_partid = <%s>", refresh->rev_partid);
  _pdm_debug("refresh->rev_revision = <%s>", refresh->rev_revision);
  _pdm_debug("refresh->rev_description = <%s>", refresh->rev_description);
  _pdm_debug("refresh->rev_parttype = <%s>", refresh->rev_parttype);
  _pdm_debug("refresh->rev_filename = <%s>", refresh->rev_filename);

  return(status);
}

int PDUblank_out_multiple_files()
{
  int    row;
  int    column;
  int    pos, select;
  int    length;
  static char *text = NULL;
  char   *catalog = NULL_STRING;
  char   *partid = NULL_STRING;
  char   *revision = NULL_STRING;
  char   *next_catalog = NULL_STRING;
  char   *next_partid = NULL_STRING;
  char   *next_revision = NULL_STRING;

  _pdm_debug("in the function PDUblank_out_multiple_files", 0);

  /* get the first part's information */
  for (column = 0; column < 3; ++column)
     {
     FIfld_get_text_length(forms.local_files_form_id, LIST_MCF, 0, column, &length);
     text = (char *) malloc (sizeof (char) * length + 1);
     memset(text, NULL, sizeof (char) * length + 1);
     FIfld_get_text(forms.local_files_form_id, LIST_MCF, 0, column, length, 
                   (unsigned char *)text, &select, &pos);
  
     /* update the structure and the part selection area */
     switch (column)
       {
       case 0:
           PDUfill_in_string(&catalog, text);
           _pdm_debug("catalog = <%s>", catalog);
           break;
       case 1:
           PDUfill_in_string(&partid, text);
           _pdm_debug("part num = <%s>", partid);
           break;
       case 2:
           PDUfill_in_string(&revision, text);
           _pdm_debug("revision = <%s>", revision);
           break;
       }
     PDUfree_string(&text);
     }  /* end for column */

  /* get the next part's information */
  for (row = 1; row < PDU_parts_list_bufr->rows; ++row)
     {
     for (column = 0; column < 3; ++column)
        {
        FIfld_get_text_length(forms.local_files_form_id, LIST_MCF, row, column, &length);
        text = (char *) malloc (sizeof (char) * length + 1);
        memset(text, NULL, sizeof (char) * length + 1);
        FIfld_get_text(forms.local_files_form_id, LIST_MCF, row, column, 
                       length, (unsigned char *)text, &select, &pos);
  
        /* update the structure and the part selection area */
        switch (column)
          {
          case 0:
              PDUfill_in_string(&next_catalog, text);
              _pdm_debug("next_catalog = <%s>", next_catalog);
              break;
          case 1:
              PDUfill_in_string(&next_partid, text);
              _pdm_debug("next_part num = <%s>", next_partid);
              break;
          case 2:
              PDUfill_in_string(&next_revision, text);
              _pdm_debug("next_revision = <%s>", next_revision);
              break;
          }
        PDUfree_string(&text);
        }  /* end for column */

     if ((strcmp(catalog, next_catalog) == 0) &&
         (strcmp(partid, next_partid) == 0) &&
         (strcmp(revision, next_revision) == 0))
       {
       FIfld_set_text(forms.local_files_form_id, LIST_MCF, row,0,"",FALSE);
       FIfld_set_text(forms.local_files_form_id, LIST_MCF, row,1,"",FALSE);
       FIfld_set_text(forms.local_files_form_id, LIST_MCF, row,2,"",FALSE);
       FIfld_set_text(forms.local_files_form_id, LIST_MCF, row,3,"",FALSE);
       FIfld_set_text(forms.local_files_form_id, LIST_MCF, row,7,"",FALSE);
       }
     else
       {
       PDUfill_in_string(&catalog, next_catalog);
       PDUfill_in_string(&partid, next_partid);
       PDUfill_in_string(&revision, next_revision);
       }
     next_catalog = NULL_STRING;
     next_partid = NULL_STRING;
     next_revision = NULL_STRING;
     }
  return(PDM_S_SUCCESS);
}

int PDUcount_selected_parts()
{

Form	form;
int	row, pos, select, length;
int     field;
static char *text = NULL_STRING;
int     parts_found = 0;

  _pdm_debug("in the function PDUcount_selected_parts", 0);

  form = forms.local_files_form_id;
  field = LIST_MCF;

  for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
     {
     if (PDU_parts_index[row] != -1)
       {
       _pdm_debug("checking the catalog column for row %d", (char *)row);
       FIfld_get_text_length(form, field, row, 0, &length);
       text = (char *) malloc (sizeof (char) * length + 1);
       memset(text, NULL, sizeof (char) * length + 1);
       FIfld_get_text(form, field, row, 0, length, (unsigned char *)text,
                      &select, &pos);
       _pdm_debug("text = <%s>", text);
       if (strlen(text) > 0)
         ++parts_found;
       }
     if (parts_found > 1)
       {
       _pdm_debug("%d parts were selected", (char *)parts_found);
       return(parts_found);
       }
     }
  return(parts_found);
}

int PDUpaint_form(form)
Form     form;
{
  int    status = PDM_S_SUCCESS;
  int    xpos = 0;
  int    ypos = 0;
  int    xsize = 0;
  int    ysize = 0;
  int    xhi = 0;
  int    ylo = 0;

  _pdm_debug("in the function PDUpaint_form", 0);

  status = FIf_get_location(form, &xpos, &ypos);
  _pdm_status("FIf_get_location", status);
  _pdm_debug("xpos = %d", (char *)xpos);
  _pdm_debug("ypos = %d", (char *)ypos);

  status = FIf_get_size(form, &xsize, &ysize);
  _pdm_status("FIf_get_size", status);
  _pdm_debug("xsize = %d", (char *)xsize);
  _pdm_debug("ysize = %d", (char *)ysize);

  /* calculate xhi and yhi */
  xhi = xpos + xsize;
  ylo = ypos - ysize;
  _pdm_debug("xhi = %d", (char *)xhi);
  _pdm_debug("ylo = %d", (char *)ylo);

  status = FIf_paint_area(form, xpos, ylo, xhi, ypos);
  _pdm_status("FIf_paint_area", status);

  return(PDM_S_SUCCESS);
  
}

void PDUclear_mcf()
{
  int   num_rows = 0;
  int   row = 0;
  int   column = 0;
  int   state = 0;

    _pdm_debug("in the function PDUclear_mcf", 0);

    if (PDU_mcf_list == TRUE)
      {
      FIfld_get_num_rows(forms.local_files_form_id, LIST_MCF, &num_rows);
      _pdm_debug("field has <%d> rows", (char *)num_rows);
      for (row = 0; row < num_rows; ++row)
         for (column = 0; column < 10; ++column)
            FIfld_set_text(forms.local_files_form_id, LIST_MCF, row, 
                           column, "", FALSE);
      PDU_mcf_list = FALSE;
      FIg_erase(forms.local_files_form_id, MCF_LIST_GRP);
      }

    else if (PDU_structure_list == TRUE)
      {
      FIfld_get_num_rows(forms.local_files_form_id, STRUCTURE_MCF, &num_rows);
      for (row = 0; row < num_rows; ++row)
         for (column = 0; column < 7; ++column)
            FIfld_set_text(forms.local_files_form_id, STRUCTURE_MCF, row, 
                           column, "", FALSE);
      PDU_structure_list = FALSE;
      FIg_erase(forms.local_files_form_id, STRUCTURE_LIST_GRP);
      }
    PDU_selected_rows = 0;

    FIg_erase(forms.local_files_form_id, SELECT_ALL);
    FIg_erase(forms.local_files_form_id, DESELECT_ALL);
    FIg_enable(forms.local_files_form_id, EDIT_ASSEMBLY_TGL);
    FIg_get_state(forms.local_files_form_id, EDIT_ASSEMBLY_TGL, &state);
    if (state == 1)
      PDU_edit_display = TRUE;
    else
      PDU_edit_display = FALSE;
    PDU_chkout_single = TRUE;

    if (PDU_parts_list_bufr)
      {
      MEMclose(&PDU_parts_list_bufr);
      PDU_parts_list_bufr = NULL;
      }
}

int PDUcheck_part_data_for_utilities()
{
char   *msg = NULL;
Form   fp;
int    status = PDM_S_SUCCESS;

  fp = forms.local_files_form_id;

   _pdm_debug("in the function PDUcheck_part_data_for_utilities", 0);

   if (PDU_selected_rows > 0)
     return(PDM_S_SUCCESS);

   if ((refresh->rev_partid == NULL) && (PDU_selected_rows == 0))
     {
     status = PDM_I_ENTER_PART;
     PDUmessage(PDM_I_ENTER_PART, 's');
     msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
     FIg_set_text(fp, FI_MSG_FIELD, msg);
     return(status);
     }
   else if ((strcmp(refresh->rev_partid, "") == 0) && 
          (PDU_selected_rows == 0))
     {
     status = PDM_I_ENTER_PART;
     PDUmessage(PDM_I_ENTER_PART, 's');
     msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
     FIg_set_text(fp, FI_MSG_FIELD, msg);
     return(status);
     }

   if ((refresh->rev_filename == NULL) && (PDU_selected_rows == 0))
     {
     status = PDM_E_ENTER_FILENAME;
     PDUmessage(PDM_E_ENTER_FILENAME, 's');
     msg = (char *) PDUtranslate_message(PDM_E_ENTER_FILENAME);
     FIg_set_text(fp, FI_MSG_FIELD, msg);
     return(status);
     }
   else if ((strcmp(refresh->rev_filename, "") == 0) &&
            (PDU_selected_rows == 0))
     {
     status = PDM_E_ENTER_FILENAME;
     PDUmessage(PDM_E_ENTER_FILENAME, 's');
     msg = (char *) PDUtranslate_message(PDM_E_ENTER_FILENAME);
     FIg_set_text(fp, FI_MSG_FIELD, msg);
     return(status);
     }

  return(status);
}

void PDUreset_local_files_form()
{
   _pdm_debug("in the function PDUreset_local_files_form", 0);

   PDUclear_mcf();
   PDUsetup_env();
   PDU_checkout_type = NONACT;
   PDU_mcf_list = FALSE;
   PDU_structure_list = FALSE;
   PDU_list_files = FALSE;
   PDUdisable_local_files_gadgets();
   PDU_load_file_buffer = FALSE;
   PDU_param_cat = FALSE;
   PDU_list_cat = FALSE;
   PDU_activate_copy = FALSE;
   PDU_main_form_cat = FALSE;
   PDU_check_filename = FALSE;
   PDU_list_filenames = FALSE;

   if (PDU_command == PDC_M_LOGOUT)
     PDU_search_format = NULL_STRING;

   return;
}

void PDUset_edit_assy_toggle_after_select()
{
  int   row;
  int   mcf_select = 0;
  int   count = 0;
  int   length, select, pos;
  int   num_rows = 0;
  int   state;
  static char *text = NULL;

  _pdm_debug("in the function PDUset_edit_assy_toggle_after_select", 0);

  FIfld_get_num_rows(PDU_form_id, LIST_MCF, &num_rows);

  for (row = 0; row < num_rows; ++row)
     {
     FIfld_get_select(PDU_form_id, LIST_MCF, row, 0, &mcf_select);
     if (!mcf_select)
       continue;

     /* check the value of the first column */
     FIfld_get_text_length(PDU_form_id, LIST_MCF, row, 0, &length);
     text = (char *) malloc (sizeof (char) * length + 1);
     memset(text, NULL, sizeof (char) * length + 1);
     FIfld_get_text(PDU_form_id, LIST_MCF, row, 0, length,
                   (unsigned char *)text, &select, &pos);
     _pdm_debug("text = <%s>", text);

     if (text && (strcmp(text, "") != 0))
       ++count;

     if (count > 1)
       {
       FIg_disable(PDU_form_id, EDIT_ASSEMBLY_TGL);
       PDU_edit_display = FALSE;
       PDU_chkout_single = FALSE;
       return;
       }

     }

  if (count == 1)
    {
    FIg_enable(forms.local_files_form_id, EDIT_ASSEMBLY_TGL);
    FIg_get_state(forms.local_files_form_id, EDIT_ASSEMBLY_TGL, &state);
    if (state == 1)
      PDU_edit_display = TRUE;
    else
      PDU_edit_display = FALSE;
    PDU_chkout_single = TRUE;
    }

  return;
}
