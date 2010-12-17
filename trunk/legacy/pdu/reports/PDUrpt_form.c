#include <stdio.h>
#include <tools.h>
#include <FI.h>
#include <MEMerrordef.h>
#include <PDUstr.h>
#include <PDUerror.h>
#include <PDUcommand.h>
#include <PDMcommand.h>
#include <PDUforms.h>
#include <PDUform_def.h>
#include <PDUfile_def.h>
#include <part_gadgets.h>
#include <exdef.h>
#include <PDUproto.h>
#include <PDMproto.h>


/* Gadgets */

#define REPORT_GRP    40
#define REPORT_NAME   24
#define MODE_GRP      39
#define BOM           21
#define PART          30
#define SUMMARY_BOM   22
#define USED_IMM      31
#define PARTS_LIST    23
#define USED_HIGH_LVL 32
#define CATALOGS      29
#define COMMAND_GRP   37
#define DISPLAY       18
#define DEFINE        19
#define DELETE        20
#define PARTID_GRP    33
#define REVISION_LIST 36
#define PART_NUM_LIST 35
#define CAT_LIST      34
#define REPORT_LIST   44
#define BOM_MAPPING   45
#define MODIFY        46
#define FILE_GRP      54
#define SAVE_OP_TOG   50
#define OUTPUT_FILE   52
#define CREATE        56
#define SEARCH_BUTTON        63
#define BOM_MCF       49
#define BOM_LIST_GRP  62
#define SUMMARY_EXPL  41
#define IMPORT_RIS    57
#define SELECT_ID_TOG 55
#define PART_FLD_GRP  43


/* Externs */

extern char * calloc();
extern char * realloc();
extern int FIg_get_text_length();
extern int FIg_get_text();
extern struct PDUrefresh *refresh;
extern struct PDUforms forms;
extern int    PDU_command;
extern int    PDU_active_button;
extern int    PDU_refresh_gadgets[7];
extern Form   PDU_form_id;
extern Form   PDU_calling_form;
extern char *PDU_report_name;
extern char *PDU_output_file;
extern char *** PDU_update_struct;
extern int *PDU_gadget_labels;
extern int PDU_selected_rows;
extern int PDU_store_row;
extern int PDM_debug_on;
extern MEMptr PDU_ret_bufr;
extern char *PDU_delete_reports;
extern short PDU_perm_window;
extern short PDU_report_exists;


int reports_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  static char   * text;
  int             status;
  int             state;
  int             responses[1];
  int             no_headings;
  int             length;
  int             select = FALSE;
  int             pos;
  int             act_row;
  int             act_pos;
  int             i;
  int             all_flag;
  int             rows;
  char           ** headings;
  char           *strings[1];
  char           templatetype[3];
  char           *msg = NULL;

  fp = forms.report_form_id;
  PDU_form_id = forms.report_form_id;
  PDUdismiss_subforms();
  switch ( g_label )
  {

    case REPORT_NAME:     /* Member of group REPORT_GRP  */
                             /* Sequenced to    */
                             /* Field Type:    ASCII    */

          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
          /* Get the text string */

          FIfld_get_text_length(fp,REPORT_NAME,0,0,&length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          status = FIfld_get_text(fp,REPORT_NAME,0,0,length,
                                  (unsigned char*)text,&select,&pos);

          if ( status != FI_SUCCESS )
            {
              /* Code to handle error */
              msg = (char *)PDUtranslate_message(PDM_E_GET_REPORT_NAME);
              FIg_set_text(fp, FI_MSG_FIELD, msg);
              PDUmessage(PDM_E_GET_REPORT_NAME, 's');
              FIg_set_text(fp, REPORT_NAME, NULL_STRING);
              if (PDU_report_name)
                PDUfill_in_string(&PDU_report_name, NULL);
              /* Disable command buttons */
              FIg_disable(forms.report_form_id, DEFINE);
              FIg_disable(forms.report_form_id, IMPORT_RIS);
              FIg_disable(forms.report_form_id, MODIFY);
              FIg_disable(forms.report_form_id, CREATE);
              FIg_disable(forms.report_form_id, DELETE);
              break;
            }

          if (strcmp(text, "") == 0)
            {
              if (PDU_report_name)
                PDUfill_in_string(&PDU_report_name, NULL);
              /* Disable command buttons */
              FIg_disable(forms.report_form_id, DEFINE);
              FIg_disable(forms.report_form_id, IMPORT_RIS);
              FIg_disable(forms.report_form_id, MODIFY);
              FIg_disable(forms.report_form_id, CREATE);
              FIg_disable(forms.report_form_id, DELETE);
              PDU_report_exists = FALSE;
              break;
           }
         else if ((PDU_report_name) && (strcmp(PDU_report_name, text) == 0))
            break;

          PDUget_templatetype(templatetype);

          PDUfill_in_string(&PDU_report_name, text);
          _pdm_debug("report name = <%s>", PDU_report_name);
          status = PDMvalidate_report_name(PDU_report_name,templatetype);
          _pdm_status("PDMvalidate_report_name", status);

          if (status != PDM_E_REPORT_EXISTS)
            {
              /* Disable command buttons */
              if (strcmp(templatetype, "C") != 0)
                {
                FIg_enable(forms.report_form_id, DEFINE);
                msg = (char *)PDUtranslate_message(PDM_E_REPORT_TYPE_NOT_EXIST);
                FIg_set_text(fp, FI_MSG_FIELD, msg);
                PDUmessage(PDM_E_REPORT_TYPE_NOT_EXIST, 's');
                }
              else 
                {
                if ((refresh->rev_catalog != NULL) &&
                       (strcmp(refresh->rev_catalog, "") != 0))
                {
                FIg_enable(forms.report_form_id, DEFINE);
                msg = (char *)PDUtranslate_message(PDM_E_REPORT_TYPE_NOT_EXIST);
                FIg_set_text(fp, FI_MSG_FIELD, msg);
                PDUmessage(PDM_E_REPORT_TYPE_NOT_EXIST, 's');
                }
                else
                {
                msg = (char *)PDUtranslate_message(PDM_I_ENTER_CATALOG);
                FIg_set_text(fp, FI_MSG_FIELD, msg);
                PDUmessage(PDM_I_ENTER_CATALOG, 's');
                FIg_disable(forms.report_form_id, DEFINE);
                }
                }

              FIg_enable(forms.report_form_id, IMPORT_RIS);
              FIg_disable(forms.report_form_id, MODIFY);
              FIg_disable(forms.report_form_id, CREATE);
              FIg_disable(forms.report_form_id, DELETE);
              PDU_report_exists = FALSE;
              FIfld_pos_cursor(forms.report_form_id,CATALOG_NAME,0,0,0,0,0,0);
              break;
           }

          PDU_report_exists = TRUE;
          FIfld_pos_cursor(fp,CATALOG_NAME,0,0,0,0,0,0);
          /* Enable command buttons */
          PDUcheck_reportname(templatetype);

         break;

    case OUTPUT_FILE:

          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
          /* Get the text string */

          FIfld_get_text_length(fp,OUTPUT_FILE,0,0,&length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          status = FIfld_get_text(fp,OUTPUT_FILE,0,0,length,
                                  (unsigned char*)text,&select,&pos);

          if ( status != FI_SUCCESS )
            {
              /* Code to handle error */
              msg = (char *)PDUtranslate_message(PDM_E_OUTPUT_FILE);
              FIg_set_text(fp, FI_MSG_FIELD, msg);
              PDUmessage(PDM_E_OUTPUT_FILE, 's');
              FIg_set_text(fp, OUTPUT_FILE, NULL_STRING);
              if (PDU_output_file)
                PDUfill_in_string(&PDU_output_file, NULL);
              break;
            }

         if ((text == NULL) || (strcmp(text, "") == 0))
           {
              if (PDU_output_file)
                PDUfill_in_string(&PDU_output_file, NULL);
           break;
           }

         /*status = PDUfile_id(text);
         _pdm_status("PDUfile_id", status);

         if (status != PDM_S_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_E_FILENAME_TOO_LONG );
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           PDUmessage(PDM_E_FILENAME_TOO_LONG , 's');
           FIfld_pos_cursor(fp, OUTPUT_FILE, 0,0,0,0,0,0);
           if (PDU_output_file)
             PDUfill_in_string(&PDU_output_file, NULL);
           break;
           }*/

          /* Code to process text string "text" */
          PDUfill_in_string(&PDU_output_file, text);
          PDUcheck_output_filename();

         break;

    case BOM:     /* Member of group MODE_GRP  */
                             /* Sequenced to    */
          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
          FIg_set_text(fp, REPORT_NAME, NULL_STRING);
          if (PDU_report_name)
            PDUfill_in_string(&PDU_report_name, NULL);

          FIg_disable(fp, DEFINE);
          FIg_disable(fp, IMPORT_RIS);
          FIg_disable(fp, MODIFY);
          FIg_disable(fp, CREATE);
          FIg_disable(fp, DELETE);

          FIg_enable(fp, PART_FLD_GRP);
          FIg_enable(fp, BOM_LIST_GRP);
          FIg_enable(fp, SELECT_ID_TOG);
          FIg_enable(fp, SEARCH_BUTTON);

         break;

    case PART:     /* Member of group MODE_GRP  */
                             /* Sequenced to    */

          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
          FIg_set_text(fp, REPORT_NAME, NULL_STRING);
          if (PDU_report_name)
            PDUfill_in_string(&PDU_report_name, NULL);

          FIg_disable(fp, DEFINE);
          FIg_disable(fp, IMPORT_RIS);
          FIg_disable(fp, MODIFY);
          FIg_disable(fp, CREATE);
          FIg_disable(fp, DELETE);

          FIg_enable(fp, PART_FLD_GRP);
          FIg_enable(fp, BOM_LIST_GRP);
          FIg_enable(fp, SELECT_ID_TOG);
          FIg_enable(fp, SEARCH_BUTTON);

         break;

    case SUMMARY_BOM:     /* Member of group MODE_GRP  */
                             /* Sequenced to    */
          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
          FIg_set_text(fp, REPORT_NAME, NULL_STRING);
          if (PDU_report_name)
            PDUfill_in_string(&PDU_report_name, NULL);

          FIg_disable(fp, DEFINE);
          FIg_disable(fp, IMPORT_RIS);
          FIg_disable(fp, MODIFY);
          FIg_disable(fp, CREATE);
          FIg_disable(fp, DELETE);

          FIg_enable(fp, PART_FLD_GRP);
          FIg_enable(fp, BOM_LIST_GRP);
          FIg_enable(fp, SELECT_ID_TOG);
          FIg_enable(fp, SEARCH_BUTTON);

         break;

    case SUMMARY_EXPL:     /* Member of group MODE_GRP  */
                             /* Sequenced to    */
          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
          FIg_set_text(fp, REPORT_NAME, NULL_STRING);
          if (PDU_report_name)
            PDUfill_in_string(&PDU_report_name, NULL);

          FIg_disable(fp, DEFINE);
          FIg_disable(fp, IMPORT_RIS);
          FIg_disable(fp, MODIFY);
          FIg_disable(fp, CREATE);
          FIg_disable(fp, DELETE);

          FIg_enable(fp, PART_FLD_GRP);
          FIg_enable(fp, BOM_LIST_GRP);
          FIg_enable(fp, SELECT_ID_TOG);
          FIg_enable(fp, SEARCH_BUTTON);

         break;

    case USED_IMM:     /* Member of group MODE_GRP  */
                             /* Sequenced to    */
          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
          FIg_set_text(fp, REPORT_NAME, NULL_STRING);
          if (PDU_report_name)
            PDUfill_in_string(&PDU_report_name, NULL);

          FIg_disable(fp, DEFINE);
          FIg_disable(fp, IMPORT_RIS);
          FIg_disable(fp, MODIFY);
          FIg_disable(fp, CREATE);
          FIg_disable(fp, DELETE);

          FIg_enable(fp, PART_FLD_GRP);
          FIg_enable(fp, BOM_LIST_GRP);
          FIg_enable(fp, SELECT_ID_TOG);
          FIg_enable(fp, SEARCH_BUTTON);


         break;

    case PARTS_LIST:     /* Member of group MODE_GRP  */
                             /* Sequenced to    */
          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
          FIg_set_text(fp, REPORT_NAME, NULL_STRING);
          if (PDU_report_name)
            PDUfill_in_string(&PDU_report_name, NULL);

          FIg_disable(fp, DEFINE);
          FIg_disable(fp, IMPORT_RIS);
          FIg_disable(fp, MODIFY);
          FIg_disable(fp, CREATE);
          FIg_disable(fp, DELETE);

          FIg_enable(fp, PART_FLD_GRP);
          FIg_enable(fp, BOM_LIST_GRP);
          FIg_enable(fp, SELECT_ID_TOG);
          FIg_enable(fp, SEARCH_BUTTON);


         break;

    case USED_HIGH_LVL:     /* Member of group MODE_GRP  */
                             /* Sequenced to    */
          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
          FIg_set_text(fp, REPORT_NAME, NULL_STRING);
          if (PDU_report_name)
            PDUfill_in_string(&PDU_report_name, NULL);

          FIg_disable(fp, DEFINE);
          FIg_disable(fp, IMPORT_RIS);
          FIg_disable(fp, MODIFY);
          FIg_disable(fp, CREATE);
          FIg_disable(fp, DELETE);

          FIg_enable(fp, PART_FLD_GRP);
          FIg_enable(fp, BOM_LIST_GRP);
          FIg_enable(fp, SELECT_ID_TOG);
          FIg_enable(fp, SEARCH_BUTTON);


         break;

    case CATALOGS:     /* Member of group MODE_GRP  */
                             /* Sequenced to    */
          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
          FIg_set_text(fp, REPORT_NAME, NULL_STRING);
          if (PDU_report_name)
            PDUfill_in_string(&PDU_report_name, NULL);

          FIg_disable(fp, DEFINE);
          FIg_disable(fp, IMPORT_RIS);
          FIg_disable(fp, MODIFY);
          FIg_disable(fp, CREATE);
          FIg_disable(fp, DELETE);

          FIg_disable(fp, PART_FLD_GRP);
          FIg_disable(fp, BOM_LIST_GRP);
          FIg_disable(fp, SELECT_ID_TOG);
          FIg_disable(fp, SEARCH_BUTTON);

         break;

    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

          _pdm_debug("f_label = <%d>", (char *)f_label);
          value = 0.0;
          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
          FIf_cvrt_to_perm_win(fp);
          status = PDUinitialize_help();
          if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }
          PDU_perm_window = TRUE;
          Help_topic("report_form");
         break;

    case FI_CVT_TO_PERM_WIN:

         PDU_perm_window = TRUE;

         break;

    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

          /* Erase the displayed form */

         FIf_erase ( fp );

         /* delete reports left locally */
         if (PDU_delete_reports)
           {
           status = PDUdelete_report_locally();
           _pdm_status("PDUdelete_report_locally", status);
           }

         PDU_form_id = PDU_calling_form;
         if (PDU_calling_form == forms.design_form_id)
           PDUsetup_design_struct();
         else if (PDU_calling_form == forms.local_files_form_id)
           PDUrefresh_local_files_form();
         else
           {
           _pdm_debug("Setting global variables", 0);
           PDU_refresh_gadgets[0] = EP_PROJECT_FLD;
           PDU_refresh_gadgets[1] = EP_CATALOG_FLD;
           PDU_refresh_gadgets[2] = EP_PARTNUM_FLD;
           PDU_refresh_gadgets[3] = EP_REV_FLD;
           PDU_refresh_gadgets[4] = EP_PARTTYPE_FLD;
           PDU_refresh_gadgets[5] = EP_DESC_FLD;
           PDU_form_id =forms.part_operations_form_id;
           }


         UI_prompt("");
         PDUmessage(PDM_E_CLEAR_FIELD, 'c');
         PDUmessage(PDM_E_CLEAR_FIELD, 's');
         FIf_display(PDU_calling_form);
         FIf_delete(fp);
         forms.report_form_id = 0;

         break;

    case FI_RESET:

          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
         FIg_set_text(fp, CATALOG_NAME, "");
         FIg_set_text(fp, PART_NUM, "");
         FIg_set_text(fp, DESCRIPTION_NAME, "");
         FIg_set_text(fp, REVISION_NAME, "");
         FIg_set_text(fp, REPORT_NAME, "");
         FIg_set_text(fp, OUTPUT_FILE, "");
         FIg_erase(fp, FILE_GRP);

         if (PDU_report_name)
           PDUfill_in_string(&PDU_report_name, NULL);
         if (PDU_output_file)
           PDUfill_in_string(&PDU_output_file, NULL);
         if (refresh->rev_catalog)
           PDUfill_in_string(&refresh->rev_catalog, NULL);
         if (refresh->rev_partid)
           PDUfill_in_string(&refresh->rev_partid, NULL);
         if (refresh->rev_revision)
           PDUfill_in_string(&refresh->rev_revision, NULL);
         if (refresh->rev_description)
           PDUfill_in_string(&refresh->rev_description, NULL);

         PDU_report_exists = FALSE;

         FIg_disable(fp, DEFINE);
         FIg_disable(fp, IMPORT_RIS);
         FIg_disable(fp, MODIFY);
         FIg_disable(fp, CREATE);
         FIg_disable(fp, DISPLAY);
         FIg_disable(fp, DELETE);

         FIg_enable(fp,BOM_MAPPING);
         FIg_enable(fp, SELECT_ID_TOG);
         FIg_enable(fp, SEARCH_BUTTON);
         FIfld_pos_cursor(fp,REPORT_NAME,0,0,0,0,0,0);
         FIg_erase(fp, OUTPUT_FILE);

         FIg_set_text(fp, SEARCH_BUTTON, "Search");
         FIg_display(fp, SEARCH_BUTTON);
         FIg_enable(fp, SEARCH_BUTTON);
         FIg_display(fp, PART_FLD_GRP);

         UI_prompt("");
         PDUmessage(PDM_E_CLEAR_FIELD, 'c');
         PDUmessage(PDM_E_CLEAR_FIELD, 's');
         break;

    case DISPLAY:     /* Member of group COMMAND_GRP  */
                             /* Sequenced to    */
 
         /* make sure file is local */
         if (PDU_output_file == NULL)
           {
           msg = (char *)PDUtranslate_message(PDM_E_FILENAME_BLANK );
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           PDUmessage(PDM_E_FILENAME_BLANK , 's');
           break;
           }
         else if (strcmp(PDU_output_file, "") == 0)
           {
           msg = (char *)PDUtranslate_message(PDM_E_FILENAME_BLANK );
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           PDUmessage(PDM_E_FILENAME_BLANK , 's');
           break;
           }

         status = PDUverify_file(PDU_output_file);
         _pdm_status("PDUverify_file", status);

         if (status != PDM_S_SUCCESS)
           {
           PDUfill_in_string(&refresh->rev_filename, PDU_output_file);
           PDUmessage(status, 's');
           PDUfill_in_string(&refresh->rev_filename, NULL);
           break; 
           }

         FIf_cvrt_to_perm_win(fp);
         PDU_perm_window = TRUE;
         /* call function to display local report */
         status = PDUdisplay_local_report_file(PDU_output_file);
         _pdm_status("PDUdisplay_local_report_file", status);

         PDUmessage(status, 's');

         break;

    case DEFINE:     /* Member of group COMMAND_GRP  */
                             /* Sequenced to    */

          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
         FIg_get_state(fp, BOM, &state);
         if (state == 1)
           PDU_command = PDC_M_DEFINE_BOMPRINT;
         else
           {
           FIg_get_state(fp, SUMMARY_BOM, &state);
           if (state == 1)
             PDU_command = PDC_M_DEFINE_BOMSUM;
           else
             {
             FIg_get_state(fp, PARTS_LIST, &state);
             if (state == 1)
               PDU_command = PDC_M_DEFINE_BOM_PARTS_FORM;
             else
               {
               FIg_get_state(fp, USED_HIGH_LVL, &state);
               if (state == 1)
                 PDU_command = PDC_M_DEF_BOM_WHERE_BOM_PFORM;
               else
                 {
                 FIg_get_state(fp, USED_IMM, &state);
                 if (state == 1)
                   PDU_command = PDC_M_DEF_BOM_WHERE_USED_PFORM;
                 else
                   {
                   FIg_get_state(fp, CATALOGS, &state);
                   if (state == 1)
                     PDU_command = PDC_M_DEFINE_LOC_DISPLAY;
                   else
                     {
                     FIg_get_state(fp, SUMMARY_EXPL, &state);
                     if (state == 1)
                       PDU_command = PDC_M_DEFINE_EXPSUM;
                     else
                       PDU_command = PDC_M_DEFINE_CATLIST;
                     }
                   }
                 }
               }
             }
           }
                    
         if (PDU_command == PDC_M_DEFINE_EXPSUM)
           refresh->command = PDC_M_DEFINE_BOMSUM;
         else
           refresh->command = PDU_command;

         status = PDUmessage_trans(refresh->command, 'v');
    
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }

         /* erase form */
         FIf_erase(forms.report_form_id);

         status = PDUdefine_report_format();
         _pdm_status("PDUdefine_report_format", status);

         break;

    case MODIFY:
          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
         FIg_get_state(fp, BOM, &state);
         if (state == 1)
           PDU_command = PDC_M_DEFINE_BOMPRINT;
         else
           {
           FIg_get_state(fp, SUMMARY_BOM, &state);
           if (state == 1)
             PDU_command = PDC_M_DEFINE_BOMSUM;
           else
             {
             FIg_get_state(fp, PARTS_LIST, &state);
             if (state == 1)
               PDU_command = PDC_M_DEFINE_BOM_PARTS_FORM;
             else
               {
               FIg_get_state(fp, USED_HIGH_LVL, &state);
               if (state == 1)
                 PDU_command = PDC_M_DEF_BOM_WHERE_BOM_PFORM;
               else
                 {
                 FIg_get_state(fp, USED_IMM, &state);
                 if (state == 1)
                   PDU_command = PDC_M_DEF_BOM_WHERE_USED_PFORM;
                 else
                   {
                   FIg_get_state(fp, CATALOGS, &state);
                   if (state == 1)
                     PDU_command = PDC_M_DEFINE_LOC_DISPLAY;
                   else
                     {
                     FIg_get_state(fp, SUMMARY_EXPL, &state);
                     if (state == 1)
                       PDU_command = PDC_M_DEFINE_EXPSUM;
                     else 
                       PDU_command = PDC_M_DEFINE_CATLIST;
                     }
                   }
                 }
               }
             }
           }

         if (PDU_command == PDC_M_DEFINE_EXPSUM)
           refresh->command = PDC_M_DEFINE_BOMSUM;
         else
           refresh->command = PDU_command;
         status = PDUmessage_trans(refresh->command, 'v');

         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }

         /* erase form */
         FIf_erase(forms.report_form_id);

         status = PDUdefine_report_format();
         _pdm_status("PDUdefine_report_format", status);

         break;

    case DELETE:     /* Member of group COMMAND_GRP  */
                             /* Sequenced to    */

         FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
         FIg_get_state(fp, BOM, &state);
         if (state == 1)
           PDU_command = PDC_M_DELETE_BOM_FORMAT;
         else
           {
           FIg_get_state(fp, SUMMARY_BOM, &state);
           if (state == 1)
             PDU_command = PDC_M_DEL_BOM_SUM_PR_FORM;
           else
             {
             FIg_get_state(fp, PARTS_LIST, &state);
             if (state == 1)
               PDU_command = PDC_M_DEL_BOM_PARTS_LIST_PR_FORM;
             else
               {
               FIg_get_state(fp, USED_HIGH_LVL, &state);
               if (state == 1)
                 PDU_command = PDC_M_DEL_BOM_WHERE_BOM_PR_FORM;
               else
                 {
                 FIg_get_state(fp, USED_IMM, &state);
                 if (state == 1)
                   PDU_command = PDC_M_DEL_BOM_WHERE_USED_PR_FORM;
                 else
                   {
                   FIg_get_state(fp, CATALOGS, &state);
                   if (state == 1)
                     PDU_command = PDC_M_DELETE_LOC_DISP_FORMAT;
                   else
                     {
                     FIg_get_state(fp, SUMMARY_EXPL, &state);
                     if (state == 1)
                       PDU_command = PDC_M_DEL_BOM_EXP_PR_FORM;
                     else
                       PDU_command = PDC_M_DELETE_CATLIST_FORMAT;
                     }
                   }
                 }
               }
             }
           }

         switch (PDU_command)
           {
           case PDC_M_DELETE_BOM_FORMAT:

              responses[0] = EX_CMD_KEY;
              strings[0] = "PDDlBOLsFr";
              status = PDUprepare_queue(responses, strings, 1);
              _pdm_status("PDUprepare_queu", status);

              break;

           case PDC_M_DEL_BOM_SUM_PR_FORM:

              responses[0] = EX_CMD_KEY;
              strings[0] = "PDDlBOSmPr";
              status = PDUprepare_queue(responses, strings, 1);
              _pdm_status("PDUprepare_queu", status);

              break;

           case PDC_M_DEL_BOM_EXP_PR_FORM:

              responses[0] = EX_CMD_KEY;
              strings[0] = "PDDlBOSmPr";
              status = PDUprepare_queue(responses, strings, 1);
              _pdm_status("PDUprepare_queu", status);

              break;

           case PDC_M_DEL_BOM_PARTS_LIST_PR_FORM:

              responses[0] = EX_CMD_KEY;
              strings[0] = "PDDlBOPrLs";
              status = PDUprepare_queue(responses, strings, 1);
              _pdm_status("PDUprepare_queu", status);

              break;

           case PDC_M_DEL_BOM_WHERE_BOM_PR_FORM:

              responses[0] = EX_CMD_KEY;
              strings[0] = "PDDlWhUsHL";
              status = PDUprepare_queue(responses, strings, 1);
              _pdm_status("PDUprepare_queu", status);

              break;

            case PDC_M_DEL_BOM_WHERE_USED_PR_FORM:

              responses[0] = EX_CMD_KEY;
              strings[0] = "PDDlWhUsAs";
              status = PDUprepare_queue(responses, strings, 1);
              _pdm_status("PDUprepare_queu", status);

              break;

            case PDC_M_DELETE_LOC_DISP_FORMAT:

              responses[0] = EX_CMD_KEY;
              strings[0] = "PDDlLsCtLs";
              status = PDUprepare_queue(responses, strings, 1);
              _pdm_status("PDUprepare_queu", status);

              break;
        
            case PDC_M_DELETE_CATLIST_FORMAT:

              responses[0] = EX_CMD_KEY;
              strings[0] = "PDDlCtLsFr";
              status = PDUprepare_queue(responses, strings, 1);
              _pdm_status("PDUprepare_queu", status);

              break;
        
            default:
              break;
            }

         break;

    case CATALOG_NAME:     /* Member of group PARTID_GRP  */
                             /* Sequenced to    */
         
         FIfld_get_text_length(fp,CATALOG_NAME,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp,CATALOG_NAME,0,0,length,
                        (unsigned char*)text,&select,&pos);

         if ((refresh->rev_catalog) && 
             (strcmp(refresh->rev_catalog, text) == 0))
            break;

         if (strcmp(text, "") == 0)
           {
          if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
            PDUfill_in_string(&refresh->rev_catalog, NULL);
           PDUget_templatetype(templatetype);
           PDUcheck_reportname(templatetype);
           break;
           }

         _pdm_debug("Entering CATALOG",0);
          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
          FIg_set_text(fp, PART_NUM, "");
          FIg_set_text(fp, REVISION_NAME, "");
          FIg_set_text(fp, DESCRIPTION_NAME, "");
         if (refresh->rev_partid)
           PDUfill_in_string(&refresh->rev_partid, NULL);
         if (refresh->rev_revision)
           PDUfill_in_string(&refresh->rev_revision, NULL);
         if (refresh->rev_description)
           PDUfill_in_string(&refresh->rev_description, NULL);
         if (refresh->rev_filename)
           PDUfill_in_string(&refresh->rev_filename, NULL);

         status = PDUep_cat_fld();
         _pdm_status("PDUep_cat_fld",status);

         if (status == 0)
           break;
         else
           {
           PDUget_templatetype(templatetype);
           PDUcheck_reportname(templatetype);
           }

         PDUmessage(status,'s');

         break;

    case PART_NUM:     /* Member of group PARTID_GRP  */
                             /* Sequenced to    */
                             /* Field Type:    ASCII    */

          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
          FIg_set_text(fp, REVISION_NAME, "");
          FIg_set_text(fp, DESCRIPTION_NAME, "");
         _pdm_debug("Entering PARTNUM",0);
         if (refresh->rev_revision)
           PDUfill_in_string(&refresh->rev_revision, NULL);
         if (refresh->rev_description)
           PDUfill_in_string(&refresh->rev_description, NULL);
         if (refresh->rev_filename)
           PDUfill_in_string(&refresh->rev_filename, NULL);

         status = PDUep_part_fld();
         _pdm_status("PDUep_part_fld",status);

         if (status == 0)
           break;
         else
           {
           PDUget_templatetype(templatetype);
           PDUcheck_reportname(templatetype);
           }

         PDUmessage(status,'s');

         break;

    case REVISION_NAME:     /* Member of group PARTID_GRP  */
                             /* Sequenced to    */
                             /* Field Type:    ASCII    */

          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
          FIg_set_text(fp, DESCRIPTION_NAME, "");
         _pdm_debug("Entering REVISION",0);

         if (refresh->rev_description)
           PDUfill_in_string(&refresh->rev_description, NULL);
         if (refresh->rev_filename)
           PDUfill_in_string(&refresh->rev_filename, NULL);

         status = PDUep_rev_fld();
         _pdm_status("PDUep_rev_fld",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');

         break;

    case DESCRIPTION_NAME:     /* Member of group PARTID_GRP  */
                             /* Sequenced to    */
                             /* Field Type:    ASCII    */

          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
         _pdm_debug("Entering DESCRIPTION",0);

         if (refresh->rev_filename)
           PDUfill_in_string(&refresh->rev_filename, NULL);
         status = PDUep_desc_fld();
         _pdm_status("PDUep_desc_fld",status);

         if (status == 0)
           break;

         PDUmessage(status,'s');

         break;

    case REVISION_LIST:     /* Member of group PARTID_GRP  */

          PDU_active_button = REVISION_LIST;
          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
          FIg_set_text(fp, DESCRIPTION_NAME, "");

          if (refresh->rev_description)
            PDUfill_in_string(&refresh->rev_description, NULL);
         _pdm_debug("Entering REVISION",0);

         status = PDUep_rev_btn();
         _pdm_status("PDUep_rev_btn",status);

         if (status == 0)
            break;

         PDUmessage(status,'s');

         break;

    case PART_NUM_LIST:     /* Member of group PARTID_GRP  */

          PDU_active_button = PART_NUM_LIST;
          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
         _pdm_debug("Entering LIST_PARTS",0);

         status = PDUep_part_btn();
         _pdm_status("PDUep_part_btn",status);

         if (status == 0)
            break;

         PDUmessage(status,'s');

         break;

    case CAT_LIST:     /* Member of group PARTID_GRP  */

          PDU_active_button = CAT_LIST;
          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
         status = PDUep_cat_btn();
         _pdm_status("PDUep_cat_btn",status);

         break;

    case REPORT_LIST:     

          PDU_active_button = REPORT_LIST;
          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
         /* query and get the report names */

         if (PDU_ret_bufr)
           MEMclose(&PDU_ret_bufr);

         PDUget_templatetype(templatetype);
         status = PDMlist_reports(templatetype,&PDU_ret_bufr);
         _pdm_status("PDMlist_reports", status);

         if ((status != PDM_S_SUCCESS) || (PDU_ret_bufr->rows == 0))
           {
           FIg_set_state_off(fp, REPORT_LIST);
           break;
           }

          PDUmessage(PDM_E_CLEAR_FIELD, 's');
          PDUsetup_single_buffer(PDU_ret_bufr);
          PDU_gadget_labels[0] = REPORT_NAME;

          PDU_update_struct[0] = &PDU_report_name;

          all_flag = FALSE;
          no_headings = 1;

          headings = (char **)malloc(sizeof (char *) * no_headings);
          memset(headings, NULL, sizeof (char *) * no_headings);

          PDUfill_in_string(&headings[0], "p_templatename");

          PDUsetup_popup_list(headings, no_headings, all_flag,
                                       PDU_ret_bufr);

          PDUsetup_form_fields(headings, no_headings, all_flag,
                                        PDU_ret_bufr);

          PDUsetup_struct_fields(headings, no_headings, all_flag,
                                          PDU_ret_bufr);

          PDUfree_string_array(&headings, no_headings);

          PDU_report_exists = TRUE;

          status = PDUsingle_list_form();

         break;

    case BOM_MAPPING:
          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
    
          status = PDUmessage_trans(PDC_M_DEFINE_BOMMAP, 'v');
          if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            break;
            }

         /* Display Bom Mapping Form */
         FIf_erase(fp);
      
        status = PDUbom_contents_form();

        break;
 
   case CREATE:
 
          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);

         FIg_get_state(fp, BOM, &state);
         if (state == 1)
           PDU_command = PDC_M_BOM_DISPLAY_REVIEW;
         else
           {
           FIg_get_state(fp, SUMMARY_BOM, &state);
           if (state == 1)
             PDU_command = PDC_M_BOM_SUMMARY_BOM;
           else
             {
             FIg_get_state(fp, PARTS_LIST, &state);
             if (state == 1)
               PDU_command = PDC_M_BOM_PARTS_LIST;
             else
               {
               FIg_get_state(fp, USED_HIGH_LVL, &state);
               if (state == 1)
                 PDU_command = PDC_M_BOM_WHERE_HIGH_LEV;
               else
                 {
                 FIg_get_state(fp, USED_IMM, &state);
                 if (state == 1)
                   PDU_command = PDC_M_BOM_WHERE_USED_ASSEM;
                 else
                   {
                   FIg_get_state(fp, CATALOGS, &state);
                   if (state == 1)
                     PDU_command = PDC_M_DISPLAY_LOC;
                   else
                     {
                     FIg_get_state(fp, SUMMARY_EXPL, &state);
                     if (state == 1)
                       PDU_command = PDC_M_EXPLODE_SUMMARY_BOM;
                     else
                       PDU_command = PDC_M_DISPLAY_CATALOG;
                     }
                   }
                 }
               }
             }
           }

        FIg_get_state(fp, SELECT_ID_TOG, &state);

        if (state == 0)
          {
           if ((PDU_command == PDC_M_BOM_DISPLAY_REVIEW) ||
              (PDU_command == PDC_M_BOM_SUMMARY_BOM) || 
              (PDU_command == PDC_M_EXPLODE_SUMMARY_BOM) || 
              (PDU_command == PDC_M_BOM_PARTS_LIST))
            {
            status = PDMrupdate_bom(refresh->rev_catalog, refresh->rev_partid, 
                                   refresh->rev_revision);
            _pdm_status("PDMrupdate_bom", status);
            if (status != PDM_S_SUCCESS)
              {
              PDUmessage(status, 's');
              break;
              }
            }
         }

         switch (PDU_command)
           {
           case PDC_M_BOM_DISPLAY_REVIEW:

              responses[0] = EX_CMD_KEY;
              strings[0] = "PDShBORvPr";
              status = PDUprepare_queue(responses, strings, 1);
              _pdm_status("PDUprepare_queu", status);

              break;

           case PDC_M_BOM_SUMMARY_BOM:

              responses[0] = EX_CMD_KEY;
              strings[0] = "PDCrBOSmPr";
              status = PDUprepare_queue(responses, strings, 1);
              _pdm_status("PDUprepare_queu", status);

              break;

           case PDC_M_EXPLODE_SUMMARY_BOM:

              responses[0] = EX_CMD_KEY;
              strings[0] = "PDCrBOSmPr";
              status = PDUprepare_queue(responses, strings, 1);
              _pdm_status("PDUprepare_queu", status);

              break;

           case PDC_M_BOM_PARTS_LIST:

              responses[0] = EX_CMD_KEY;
              strings[0] = "PDCrBOPrLs";
              status = PDUprepare_queue(responses, strings, 1);
              _pdm_status("PDUprepare_queu", status);

              break;

           case PDC_M_BOM_WHERE_HIGH_LEV:

              responses[0] = EX_CMD_KEY;
              strings[0] = "PDCrWhUsHL";
              status = PDUprepare_queue(responses, strings, 1);
              _pdm_status("PDUprepare_queu", status);

              break;

            case PDC_M_BOM_WHERE_USED_ASSEM:

              responses[0] = EX_CMD_KEY;
              strings[0] = "PDCrWhUsAs";
              status = PDUprepare_queue(responses, strings, 1);
              _pdm_status("PDUprepare_queu", status);

              break;

            case PDC_M_DISPLAY_LOC:

              responses[0] = EX_CMD_KEY;
              strings[0] = "PDShLsCt";
              status = PDUprepare_queue(responses, strings, 1);
              _pdm_status("PDUprepare_queu", status);

              break;
        
            case PDC_M_DISPLAY_CATALOG:

              responses[0] = EX_CMD_KEY;
              strings[0] = "PDShLsPrIn";
              status = PDUprepare_queue(responses, strings, 1);
              _pdm_status("PDUprepare_queu", status);

              break;
        
            default:
              break;
            }

         break;

   case BOM_MCF:

          FIfld_get_active_row(fp, BOM_MCF, &act_row, &act_pos);
          FImcf_set_active_col(fp, BOM_MCF, 0, 0);
          FIfld_get_select(fp, BOM_MCF, act_row, 0, &select);
         
          if (select == TRUE)
          { 
          for (i = 0; i < 3; i ++)
            {
            FImcf_set_active_col(fp, BOM_MCF, i, i);

            /* Get the text string */
            FIfld_get_text_length(fp,BOM_MCF,act_row,i,&length);
            text = (char *) malloc (sizeof (char) * length + 1);
            memset(text, NULL, sizeof (char) * length + 1);
            FIfld_get_text(fp,BOM_MCF,act_row,i,length,
                           (unsigned char*)text,&select,&pos);

            if ( i == 0)
              PDUfill_in_string(&refresh->rev_catalog, text);
            else if (i == 1)
              PDUfill_in_string(&refresh->rev_partid, text);
            else
              PDUfill_in_string(&refresh->rev_revision, text);
            }
            if ((refresh->rev_description) && (strcmp(refresh->rev_description,
                 "") != 0))
              PDUfill_in_string(&refresh->rev_description, NULL);
            FIg_enable(fp, SEARCH_BUTTON);
            }
          else
            {
            FIfld_get_num_rows(forms.report_form_id, BOM_MCF, &rows);
            for (i = 0; i < rows; i ++)
              {
              FIfld_get_select(fp, BOM_MCF, i, 0, &select);
              if (select)
                break;
               }
             if (select)
               FIg_enable(fp, SEARCH_BUTTON);
             else
               {
               FIg_disable(fp, SEARCH_BUTTON);
               FIg_disable(fp, CREATE);
               }
            }
           if ((PDU_report_name) && (strcmp(PDU_report_name, "") != 0))
             {
             PDUget_templatetype(templatetype);
             PDUcheck_reportname(templatetype);
             }

          break;

   case SEARCH_BUTTON:

        FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);

        FIg_get_state(fp, SELECT_ID_TOG, &state);

        if (state == 1)
          {
          FIfld_get_active_row(fp, BOM_MCF, &act_row, &act_pos);
          PDU_store_row = act_row;
          /* user wants to delete a BOM */
         responses[0] = EX_CMD_KEY;
         strings[0] = "PDDlBO";
         status = PDUprepare_queue(responses, strings, 1);
         _pdm_status("PDUprepare_queu", status);
          }
        else
           {
           _pdm_debug("User wants to search for part", 0);
          FIf_erase(fp);
          SelectOrPlacePart(TRUE, FALSE, fp);
          }
       
        break;

   case SELECT_ID_TOG:

          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
        /* according to toggle display output file group */

        FIg_get_state(fp, SELECT_ID_TOG, &state);

        if (state == 1)
          {
          FIg_erase(fp, PART_FLD_GRP);
          status = PDUload_bom_list();
          _pdm_status("PDUload_bom_list", 0);
          FIg_display(fp, BOM_LIST_GRP);
          FIg_set_text(fp, SEARCH_BUTTON, "Delete");
          FIg_display(fp, SEARCH_BUTTON);
          FIg_disable(fp, SEARCH_BUTTON);
          FIg_display(fp, BOM_LIST_GRP);
          }
        else
          {
          PDUupdate_report_form();
          FIg_display(fp, PART_FLD_GRP);
          FIg_erase(fp, BOM_LIST_GRP);
          FIg_set_text(fp, SEARCH_BUTTON, "Search");
          FIg_display(fp, SEARCH_BUTTON);
          FIg_enable(fp, SEARCH_BUTTON);
          FIg_display(fp, PART_FLD_GRP);
          if ((PDU_report_name) && (strcmp(PDU_report_name, "") != 0))
            {
            PDUget_templatetype(templatetype);
            PDUcheck_reportname(templatetype);
            }
          }

        break;

   case SAVE_OP_TOG:

          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
        /* according to toggle display output file group */

        FIg_get_state(fp, SAVE_OP_TOG, &state);

        if (state == 1)
          {
          FIg_display(fp, FILE_GRP);
          FIg_enable(fp, DISPLAY);
          }
        else
          {
          FIg_erase(fp, FILE_GRP);
          FIg_disable(fp, DISPLAY);
          }

        break;

   case IMPORT_RIS:

        FIg_set_text(fp, FI_MSG_FIELD, "");
        responses[0] = EX_CMD_KEY;
        strings[0] = "PDImRis";
        status = PDUprepare_queue(responses, strings, 1);
        _pdm_status("PDUprepare_queu", status);

        break;
        
  } /* END switch ( g_label ) */
  return(1);
} /* END notification_routine() */

int reports_form()
{
  int  status;
  Form dummy;

  status = FIf_new(REPORT_FORM, "reports",
                reports_notification_routine,
                &forms.report_form_id);

  _pdm_debug("Creating Reports Form", 0);

  /* set other entered info to NULL */
  if ((refresh->rev_catalog != NULL) && (strcmp(refresh->rev_catalog, "") != 0))
    FIg_set_text(forms.report_form_id, CATALOG_NAME, refresh->rev_catalog);
  if ((refresh->rev_partid != NULL) && (strcmp(refresh->rev_partid, "") != 0))
    FIg_set_text(forms.report_form_id, PART_NUM, refresh->rev_partid);
  if ((refresh->rev_revision != NULL) && 
      (strcmp(refresh->rev_revision, "") != 0))
      FIg_set_text(forms.report_form_id, REVISION_NAME, refresh->rev_revision);
  if ((refresh->rev_description != NULL) &&
     (strcmp(refresh->rev_description, "") != 0))
    FIg_set_text(forms.report_form_id, DESCRIPTION_NAME, refresh->rev_description);

  /* setup global variables for report form */
  PDU_form_id = forms.report_form_id;

  PDU_refresh_gadgets[1] = CATALOG_NAME;
  PDU_refresh_gadgets[2] = PART_NUM;
  PDU_refresh_gadgets[3] = REVISION_NAME;
  PDU_refresh_gadgets[5] = DESCRIPTION_NAME;

  /* if part operations button disable certain report types */
  if (PDU_calling_form == forms.part_operations_form_id)
    {
    _pdm_debug("Disabling certain report types", 0);
    FIg_set_state_off(forms.report_form_id, BOM);
    FIg_disable(forms.report_form_id, BOM);
    FIg_disable(forms.report_form_id, SUMMARY_BOM);
    FIg_disable(forms.report_form_id, SUMMARY_EXPL);
    FIg_disable(forms.report_form_id, PARTS_LIST);
    FIg_disable(forms.report_form_id, CATALOGS);
    FIg_disable(forms.report_form_id, PART);
    FIg_set_state_on(forms.report_form_id, USED_IMM);
    }
    
  /* erase FILE_GRP */
  FIg_erase(forms.report_form_id, FILE_GRP);

  /* Disable command buttons */
  FIg_disable(forms.report_form_id, DEFINE);
  FIg_disable(forms.report_form_id, IMPORT_RIS);
  FIg_disable(forms.report_form_id, CREATE);
  FIg_disable(forms.report_form_id, MODIFY);
  FIg_disable(forms.report_form_id, DISPLAY);
  FIg_disable(forms.report_form_id, DELETE);
  FIg_disable(forms.report_form_id, IMPORT_RIS);
  FIg_enable(forms.report_form_id, BOM_MAPPING);

  if ((PDU_report_name) && (strcmp(PDU_report_name, "") != 0))
    PDUfill_in_string(&PDU_report_name, NULL);

  PDU_report_exists = FALSE;

  /* Display the catalog operations form and set the displayed flag to TRUE. */

  _pdm_debug("Displaying the Reparts Form", 0);

  if (PDM_debug_on)
    {
    dummy = forms.report_form_id;
    FIf_cvrt_to_perm_win(dummy);
    PDU_perm_window = TRUE;
    }
  else
    PDU_perm_window = FALSE;

  FIf_set_orig_coord(forms.report_form_id, 607, 783);
  status = FIf_display(forms.report_form_id);

  FIfld_pos_cursor(forms.report_form_id,REPORT_NAME,0,0,0,0,0,0);
  return(status);
}

int PDUreports_form()

{
  int status;

  status = reports_form();
  _pdm_status("reports_form", status);
  if (status == FI_SUCCESS)
    status = PDM_S_SUCCESS;
  return(status);
}

int PDUsetup_report_struct()

  {
  
  _pdm_debug("In the function PDUsetup_report_struct", 0);

  PDU_form_id = forms.report_form_id;

  PDU_refresh_gadgets[1] = CATALOG_NAME;
  PDU_refresh_gadgets[2] = PART_NUM;
  PDU_refresh_gadgets[3] = REVISION_NAME;
  PDU_refresh_gadgets[5] = DESCRIPTION_NAME;

  return(PDM_S_SUCCESS);
  }

int PDUcheck_output_filename()
  {
  int status;

  _pdm_debug("PDUcheck_output_filename", 0);

  if ((PDU_output_file) && (strcmp(PDU_output_file, "") != 0))
    {
    status = PDUverify_file(PDU_output_file);
    _pdm_status("PDUverify_file", status);
    
    if (status != PDM_S_SUCCESS)
     FIg_disable(forms.report_form_id, DISPLAY);
   else
     FIg_enable(forms.report_form_id, DISPLAY);
  }
  else
    FIg_disable(forms.report_form_id, DISPLAY);
 
  return(PDM_S_SUCCESS);
  }

int PDUcheck_reportname(templatetype)

char *templatetype;
  {
  short enable = FALSE;
  int   status;
  char  *msg = NULL;
  char  lib[256];
  char  out_file[256];

  _pdm_debug("In PDUcheck_reportname", 0);

  if (strcmp(templatetype, "C") == 0)
    {
    _pdm_debug("Template_type = C", 0);
    if ((refresh->rev_catalog != NULL) && 
        (strcmp(refresh->rev_catalog, "") != 0))
     enable = TRUE;
   else
     {
     enable = FALSE;
     msg = (char *)PDUtranslate_message(PDM_I_ENTER_CATALOG);
     FIg_set_text(forms.report_form_id, FI_MSG_FIELD, msg);
     PDUmessage(PDM_I_ENTER_CATALOG, 's');
     }
    }
  else if (strcmp(templatetype, "L") != 0)
    if ((refresh->rev_catalog != NULL) && (refresh->rev_partid != NULL) &&
        (refresh->rev_revision != NULL) &&
        (strcmp(refresh->rev_catalog, "") != 0) && 
        (strcmp(refresh->rev_partid, "") != 0) &&
        (strcmp(refresh->rev_revision, "") != 0))
      enable = TRUE;
    else
      enable = FALSE;
  else
    enable = TRUE;

  if ((PDU_report_name) && (strcmp(PDU_report_name, "") != 0))
    {
    if ((!enable) && (strcmp(templatetype, "C") == 0))
      {
      _pdm_debug("Enable is FALSE",0);
      FIg_disable(forms.report_form_id, DEFINE);
      FIg_disable(forms.report_form_id, MODIFY);
      FIg_disable(forms.report_form_id, DISPLAY);
      FIg_disable(forms.report_form_id, CREATE);
      }
    else if ((!enable) && (strcmp(templatetype, "L") != 0))
      {
      if (PDU_report_exists)
        {
        FIg_disable(forms.report_form_id, DEFINE);
        FIg_disable(forms.report_form_id, IMPORT_RIS);
        FIg_enable(forms.report_form_id, MODIFY);
        }
      else
        {
        FIg_enable(forms.report_form_id, DEFINE);
        FIg_enable(forms.report_form_id, IMPORT_RIS);
        FIg_disable(forms.report_form_id, MODIFY);
        }
      FIg_disable(forms.report_form_id, DISPLAY);
      FIg_disable(forms.report_form_id, CREATE);
      }
     else 
       {
      if (PDU_report_exists)
        {
        FIg_disable(forms.report_form_id, DEFINE);
        FIg_disable(forms.report_form_id, IMPORT_RIS);
        FIg_enable(forms.report_form_id, MODIFY);
        FIg_enable(forms.report_form_id, DISPLAY);
        FIg_enable(forms.report_form_id, CREATE);
        }
      else
        {
        FIg_enable(forms.report_form_id, DEFINE);
        FIg_enable(forms.report_form_id, IMPORT_RIS);
        FIg_disable(forms.report_form_id, MODIFY);
        FIg_disable(forms.report_form_id, DISPLAY);
        FIg_disable(forms.report_form_id, CREATE);
        }
      }
    if (PDU_report_exists)
      FIg_enable(forms.report_form_id, DELETE);
    else
      FIg_disable(forms.report_form_id, DELETE);
    }
   else
    {
    FIg_disable(forms.report_form_id, DEFINE);
    FIg_disable(forms.report_form_id, IMPORT_RIS);
    FIg_disable(forms.report_form_id, MODIFY);
    FIg_disable(forms.report_form_id, CREATE);
    FIg_disable(forms.report_form_id, DELETE);
    FIg_disable(forms.report_form_id, DISPLAY);
    }

  if (PDU_report_exists)
    {
    status = PDMquery_report_type(PDU_report_name, templatetype, lib, out_file);
    _pdm_status("PDMquery_report_type", status);
    _pdm_debug("templatetype = <%s>", templatetype);
    if ((status == PDM_S_SUCCESS) && (templatetype) && (templatetype[1] == 'F'))
      FIg_disable(forms.report_form_id, MODIFY);
    else
      FIg_enable(forms.report_form_id, MODIFY);
    }

  PDUcheck_output_filename();
  return(PDM_S_SUCCESS);
  } 

int PDUget_templatetype(templatetype)

char *templatetype;

  {
  int state;

  FIg_get_state(forms.report_form_id, BOM, &state);
  if (state == 1)
    strcpy(templatetype,"X");
  else
    {
    FIg_get_state(forms.report_form_id, SUMMARY_BOM, &state);
    if (state == 1)
      strcpy(templatetype,"S");
    else
      {
      FIg_get_state(forms.report_form_id, PARTS_LIST, &state);
      if (state == 1)
        strcpy(templatetype,"O");
      else
        {
        FIg_get_state(forms.report_form_id, USED_HIGH_LVL, &state);
        if (state == 1)
        strcpy(templatetype,"W");
        else
          {
          FIg_get_state(forms.report_form_id, USED_IMM, &state);
          if (state == 1)
             strcpy(templatetype,"U");
          else
            {
            FIg_get_state(forms.report_form_id, CATALOGS, &state);
            if (state == 1)
               strcpy(templatetype,"L");
            else
              {
              FIg_get_state(forms.report_form_id, SUMMARY_EXPL, &state);
              if (state == 1)
                strcpy(templatetype, "P");
              else 
                strcpy(templatetype,"C");
              }
            }
          }
       }
    }
  }
  return(PDM_S_SUCCESS);
  }

int PDUdelete_report_from_field()

  {

  _pdm_debug("In PDUdelete_report_from_field", 0);

  FIg_set_text(forms.report_form_id, REPORT_NAME, "");

  if (PDU_report_name)
    PDUfill_in_string(&PDU_report_name, NULL);

  FIg_disable(forms.report_form_id, DEFINE);
  FIg_disable(forms.report_form_id, MODIFY);
  FIg_disable(forms.report_form_id, CREATE);
  FIg_disable(forms.report_form_id, DELETE);
  FIg_disable(forms.report_form_id, DISPLAY);
  return(PDM_S_SUCCESS);
  }

int PDUupdate_report_form()

  {
  int status;
  char templatetype[3];
  char **ret_data = NULL;

  _pdm_debug("In the function PDUupdate_report_form", 0);
  PDU_form_id = forms.report_form_id;
  if ((refresh->rev_catalog != NULL) && (strcmp(refresh->rev_catalog, "") != 0))
    FIg_set_text(forms.report_form_id, CATALOG_NAME, refresh->rev_catalog);
  else
    FIg_set_text(forms.report_form_id, CATALOG_NAME, "");

  if ((refresh->rev_partid != NULL) && (strcmp(refresh->rev_partid, "") != 0))
    FIg_set_text(forms.report_form_id, PART_NUM, refresh->rev_partid);
  else
    FIg_set_text(forms.report_form_id, PART_NUM, "");

if ((refresh->rev_revision != NULL) && (strcmp(refresh->rev_revision, "") != 0))
    FIg_set_text(forms.report_form_id, REVISION_NAME, refresh->rev_revision);
  else
    FIg_set_text(forms.report_form_id, REVISION_NAME, "");

if ((refresh->rev_description != NULL) && 
    (strcmp(refresh->rev_description, "") != 0))
    FIg_set_text(forms.report_form_id, DESCRIPTION_NAME, 
                 refresh->rev_description);
  else
    FIg_set_text(forms.report_form_id, DESCRIPTION_NAME, "");

  if (PDU_ret_bufr)
    MEMclose(&PDU_ret_bufr);

  if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0) && 
      (refresh->rev_partid) && (strcmp(refresh->rev_partid, "") != 0) &&
      (refresh->rev_revision) && (strcmp(refresh->rev_revision) != 0))
  {
  status = PDMget_pt_desc(refresh->rev_catalog, refresh->rev_partid, 
                          refresh->rev_revision);
  _pdm_status("PDMget_pt_desc", status);
  }
  else
  {
  PDUget_templatetype(templatetype);
  PDUcheck_reportname(templatetype);
  return(PDM_S_SUCCESS);
  }

  if ((status != PDM_S_SUCCESS) || (PDU_ret_bufr == NULL))
    return(PDM_S_SUCCESS);

  if (PDM_debug_on)
    MEMprint_buffer("description", PDU_ret_bufr, PDU_DEBUG_FILE);

  status = MEMbuild_array(PDU_ret_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_S_SUCCESS);

  ret_data = (char **)PDU_ret_bufr->data_ptr;
  
  PDUfill_in_string(&refresh->rev_description, ret_data[1]);
  PDUfill_in_string(&refresh->rev_parttype, ret_data[0]);
  if ((refresh->rev_description != NULL) && 
      (strcmp(refresh->rev_description, "") != 0))
 FIg_set_text(forms.report_form_id, DESCRIPTION_NAME, refresh->rev_description);
  else
    FIg_set_text(forms.report_form_id, DESCRIPTION_NAME, "");

  PDUget_templatetype(templatetype);
  PDUcheck_reportname(templatetype);
  return(PDM_S_SUCCESS);
  }

int PDUload_bom_list()

{
  int status;
  int all_flag;
  int no_headings;
  int rows;
  int i;
  MEMptr bom_list = NULL;
  char  **headings = NULL;
  char  *msg = NULL;

  _pdm_debug("In PDUload_bom_list", 0);
  
  status = PDMshow_boms(&bom_list);
  _pdm_status("PDMshow_boms", status);

  if ((status != PDM_S_SUCCESS) || (bom_list->rows == 0))
    {
    msg = (char *)PDUtranslate_message(PDM_E_NO_BOMS);
    FIg_set_text(forms.report_form_id, FI_MSG_FIELD, msg);
    PDUmessage(PDM_E_NO_BOMS, 's');
    return(status);
    }

  if (PDM_debug_on)
    MEMprint_buffer("bom_list", bom_list, PDU_DEBUG_FILE);

  /* clear out listing area */
  FIfld_get_num_rows(forms.report_form_id, BOM_MCF, &rows);
  if (rows != 0)
    {
    _pdm_debug("Blank out value list", 0);
    for (i = 0; i < rows; i++)
       {
       FIfld_set_text(forms.report_form_id, BOM_MCF, i, 0, "", FALSE);
       FIfld_set_text(forms.report_form_id, BOM_MCF, i, 1, "", FALSE);
       FIfld_set_text(forms.report_form_id, BOM_MCF, i, 2, "", FALSE);
       FIfld_set_text(forms.report_form_id, BOM_MCF, i, 3, "", FALSE);
      }
   }

  PDUsetup_single_buffer(bom_list);

  all_flag = FALSE;
  no_headings = 4;
  headings = (char **) malloc (sizeof (char *) * no_headings);
  memset(headings, NULL, sizeof (char *) * no_headings);

  PDUfill_in_string(&headings[0],"n_catalogname");
  PDUfill_in_string(&headings[1],"n_itemname");
  PDUfill_in_string(&headings[2],"n_itemrev");
  PDUfill_in_string(&headings[3],"p_createdate");

  PDUsetup_popup_list(headings, no_headings, all_flag, bom_list);

  PDUfree_string_array(&headings, no_headings);
  PDU_selected_rows = 0;

  PDUbufr_to_mcf(bom_list, forms.report_form_id, BOM_MCF);

  if (bom_list)
    MEMclose(&bom_list);
  return(PDM_S_SUCCESS);
}

int PDUdelete_boms()

  {
  int status;
  int num_rows;
  int length;
  int select;
  int pos;
  int i;
  short DONE = FALSE;
  char *text = NULL;

  _pdm_debug("In the PDUdelete_boms", 0);

  FIfld_get_num_rows(forms.report_form_id, BOM_MCF, &num_rows);
  _pdm_debug("num_rows = <%d>", (char *)num_rows);
  for (i = 0; i < num_rows; i++)
  {
  FIfld_get_select(forms.report_form_id, BOM_MCF, i, 0, &select);
  if (select)
    {
    _pdm_debug("row selected", 0);
     FIfld_set_active_row(forms.report_form_id, BOM_MCF, i, 0);
     FImcf_set_active_col(forms.report_form_id, BOM_MCF, 0, 0);
     FIfld_get_text_length(forms.report_form_id,BOM_MCF,i,0,&length);
     text = (char *) malloc (sizeof (char) * length + 1);
     memset(text, NULL, sizeof (char) * length + 1);
     FIfld_get_text(forms.report_form_id,BOM_MCF,i,0,length,
                    (unsigned char*)text,&select,&pos);
     PDUfill_in_string(&refresh->rev_catalog, text);

     FImcf_set_active_col(forms.report_form_id, BOM_MCF, 1, 1);
     FIfld_get_text_length(forms.report_form_id,BOM_MCF,i,1,&length);
     text = (char *) malloc (sizeof (char) * length + 1);
     memset(text, NULL, sizeof (char) * length + 1);
     FIfld_get_text(forms.report_form_id,BOM_MCF,i,1,length,
                    (unsigned char*)text,&select,&pos);
     PDUfill_in_string(&refresh->rev_partid, text);

     FImcf_set_active_col(forms.report_form_id, BOM_MCF, 2, 2);
     FIfld_get_text_length(forms.report_form_id,BOM_MCF,i,2,&length);
     text = (char *) malloc (sizeof (char) * length + 1);
     memset(text, NULL, sizeof (char) * length + 1);
     FIfld_get_text(forms.report_form_id,BOM_MCF,i,2,length,
                    (unsigned char*)text,&select,&pos);
     PDUfill_in_string(&refresh->rev_revision, text);

     if ((refresh->rev_description) && (strcmp(refresh->rev_description, "") 
         != 0))
       PDUfill_in_string(&refresh->rev_description, NULL);
    status = PDMrdelete_bom(refresh->rev_catalog, refresh->rev_partid, 
                           refresh->rev_revision);
    _pdm_status("PDMrdelete_bom", status);

    refresh->status = status;
    PDUmessage(status, 's');
    }
  }
  while (!DONE)
  {
  FIfld_get_num_rows(forms.report_form_id, BOM_MCF, &num_rows);
  _pdm_debug("num_rows = <%d>", (char *)num_rows);
  if (num_rows == 0)
    DONE = TRUE;
  for (i = 0; i < num_rows; i++)
  {
  FIfld_get_select(forms.report_form_id, BOM_MCF, i, 0, &select);
  if (select)
    {
    FIfld_delete_rows(forms.report_form_id, BOM_MCF, i, 1);
    break;
    }
  else if (i == (num_rows - 1))
    DONE = TRUE;
  }
  }

  FIg_disable(forms.report_form_id, SEARCH_BUTTON);
  return(PDM_S_SUCCESS);
  }

int PDUdisplay_local_report_file(filename)

char *filename;

  {

  _pdm_debug("In PDUdisplay_local_report_file", 0);

  PSUalloc_rpt();

  PSUdisplay_rpt(filename);

  return(PDM_S_SUCCESS);
  }
