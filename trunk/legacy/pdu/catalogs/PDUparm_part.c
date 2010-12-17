#include <stdio.h>
#include <tools.h>
#include <FI.h>
#include <PDUerror.h>
#include <PDUprompt.h>
#include <PDUstr.h>
#include <PDUstorage.h>
#include <PDUcommand.h>
#include <PDUforms.h>
#include "PDUform_def.h"
#include <MEMerrordef.h>
#include "PDUfile_def.h"
#include "PDUproto.h"
#include "PDMproto.h"
#include "PDMtypes.h"
#include "PDMmessage.h"


/* Gadgets */

#define CATALOG_DESC  28
#define ATTR_DATA_MCF 12
#define ATTR_NAME_MCF 22
#define LEVEL6_BTN    21
#define LEVEL_GRP     11
#define LEVEL1_BTN    13
#define LEVEL2_BTN    20
#define LEVEL3_BTN    24
#define LEVEL4_BTN    25
#define LEVEL5_BTN    32
#define NEW_CHG_GRP   16
#define NEW_BTN       30
#define CHANGE_BTN    31
#define CATALOG_NAME  29
#define LEVEL7_BTN    23
#define PROJECT_NAME  38
#define PART_NUM      50
#define REVISION      52
#define MOVE_NEXT_STATE 55
#define PROJECT_LIST  63
#define PART_OPER_GRP 64
#define ADD_PART      65
#define CHANGE_PART   66
#define DELETE_PART   69
#define SPREAD_OPER_GRP 40
#define ADD_ROW_DEF   47
#define COPY_ROW      48
#define ADD_ROWS_FR_SEARCH 49
#define CLEAR_ROW     67
#define VALUE_ASSOC_GADGET 36
#define CLASS_ASSOC_GADGET 15


/* Externs */

extern char * calloc();
extern char * realloc();
extern int FIg_get_text_length();
extern int FIg_get_text();
extern int FImcf_get_active_col();
extern int FIg_get_text_length();
extern int FIfld_get_text();

extern struct PDUrefresh *refresh;
extern struct PDUforms forms;
extern struct PDUstorage *storage;
extern Form PDU_form_id;
extern int PDU_new_param_mode;
extern int PDU_change_param_mode;
extern int PDM_debug_on;
extern int bufr_flag;
extern int PDU_active_button;
extern int PDU_active_list;
extern int PDU_value_pulldown;
extern int PDU_catalog_pulldown;
extern int PDU_class_level;
extern int PDU_validate_access;
extern int PDMdebug_on;
extern short PDU_perm_window;
extern MEMptr PDU_ret_bufr;
extern MEMptr PDU_func_buffer;
extern MEMptr PDU_parm_data_bufr;
extern MEMptr PDU_parm_attr_bufr;
extern MEMptr PDU_parm_list_bufr;
extern MEMptr PDU_cat_class_bufr;
extern MEMptr PDU_query_class_bufr;
extern MEMptr PDU_states_bufr;
extern char *PDU_cat_description;
extern char *PDU_store_catalog;
extern char *PDU_value_list[605];
extern char ***PDU_update_struct;
extern MEMptr states_bufr;
extern int PDU_refresh_gadgets[7];

int parm_part_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  static char   * text;
  int             length;
  int             select;
  int             status;
  int             i,sel_flag, selected_rows;
  int             num_rows, num_cols;
  static int      act_row = -1;
  int             row = -1;
  static int      act_col, act_pos;
  static int      delete_flag = FALSE;
  int             pos;
  int             list_row;
  int             attr_row;
  int             buffer_number;
  int             list_size;
  char            *default_value = NULL;
  char            *temp = NULL;
  char            *string = NULL;
  char            *sano = NULL;
  char            *catalog_type = NULL;
  char            cat_type[5];
  char            answer[10];
  char            *msg= NULL;
  char            *attr_name = NULL;
  char            **data_data = NULL;
  char            **attr_data = NULL;
  char            **list_data = NULL;
  MEMptr          temp_bufr = NULL;
  MEMptr          status_bufr = NULL;
  MEMptr          delete_bufr = NULL;
  MEMptr          input_buffer = NULL;

  FIg_set_text(fp, FI_MSG_FIELD, "");

  _pdm_debug("in parm_part_notification_routine", 0);
  _pdm_debug("g_label = <%d>", (char *)g_label);
  PDU_form_id = forms.parametric_parts_form_id;
  PDU_refresh_gadgets[0] = PROJECT_NAME;
  PDU_refresh_gadgets[1] = CATALOG_NAME;
  if (g_label == ATTR_DATA_MCF)
    {
    FImcf_get_active_col(fp,ATTR_DATA_MCF, &act_col, &pos);
    FImcf_set_active_col(fp,ATTR_NAME_MCF, act_col, pos);
    }
  else if (g_label == ATTR_NAME_MCF)
    {
    FImcf_get_active_col(fp,ATTR_NAME_MCF, &act_col, &pos);
    FImcf_set_active_col(fp,ATTR_DATA_MCF, act_col, pos);
    }


  switch ( g_label )
  {
    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

         _pdm_debug("f_label = <%d>", (char *)f_label);
         FIf_cvrt_to_perm_win(fp);
         status = PDUinitialize_help();
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }
         PDU_perm_window = TRUE;
         Help_topic("parmoper");

         break;

    case FI_CVT_TO_PERM_WIN:
        
         PDU_perm_window = TRUE;
         break;

    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

          /* Erase the displayed form */

         GRdelete_pull_down_list(PDU_value_pulldown);
         FIf_delete ( fp );
        if ((refresh->rev_project) && (strcmp(refresh->rev_project, "") != 0))
          PDUfill_in_string(&refresh->rev_project, NULL);
        if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
          PDUfill_in_string(&refresh->rev_catalog, NULL);
        if ((refresh->rev_partid) && (strcmp(refresh->rev_partid, "") != 0))
          PDUfill_in_string(&refresh->rev_partid, NULL);
        if ((refresh->rev_revision) && (strcmp(refresh->rev_revision, "") != 0))
          PDUfill_in_string(&refresh->rev_revision, NULL);
        if ((refresh->rev_description) && 
            (strcmp(refresh->rev_description, "") != 0))
          PDUfill_in_string(&refresh->rev_description, NULL);
        if ((refresh->rev_parttype) && (strcmp(refresh->rev_parttype, "") != 0))
          PDUfill_in_string(&refresh->rev_parttype, NULL);
        if ((refresh->rev_filename) && (strcmp(refresh->rev_filename, "") != 0))
          PDUfill_in_string(&refresh->rev_filename, NULL);
         PDU_form_id = forms.local_files_form_id;
         PDUrefresh_local_files_form();
         FIf_display(PDU_form_id);

         break;

    case FI_RESET:     /* Member of group FI_CTRL_GROUP */

         FIg_reset(fp, ATTR_NAME_MCF);
         FIg_reset(fp, ATTR_DATA_MCF);
         FIg_disable(fp, ATTR_NAME_MCF);
         FIg_disable(fp, ATTR_DATA_MCF);

         FIg_disable(fp, ADD_ROW_DEF);
         FIg_disable(fp, COPY_ROW);
         FIg_disable(fp, CLEAR_ROW);

         FIg_erase(fp, LEVEL2_BTN);
         FIg_erase(fp, LEVEL3_BTN);
         FIg_erase(fp, LEVEL4_BTN);
         FIg_erase(fp, LEVEL5_BTN);
         FIg_erase(fp, LEVEL6_BTN);
         FIg_erase(fp, LEVEL7_BTN);

         FIg_disable(fp, ADD_ROWS_FR_SEARCH);
         FIg_disable(fp, CHANGE_PART);
         FIg_disable(fp, DELETE_PART);
         FIg_disable(fp, MOVE_NEXT_STATE);
         FIg_disable(fp, ADD_PART);

         PDU_new_param_mode = TRUE;
         PDU_change_param_mode = FALSE;

         if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
           PDUfill_in_string(&refresh->rev_catalog, NULL);
         FIg_set_text(fp, CATALOG_NAME, "");

         if (PDU_parm_attr_bufr)
           {
           MEMclose(&PDU_parm_attr_bufr);
           PDU_parm_attr_bufr = NULL;
           }
         if (PDU_parm_data_bufr)
           {
           MEMclose(&PDU_parm_data_bufr);
           PDU_parm_data_bufr = NULL;
           }

         FIfld_set_mode(fp, CATALOG_DESC, 0, FI_REVIEW);
         break;

    case CATALOG_DESC:     /* Sequenced to     */
                             /* Field Type:    ASCII    */

          /* Get the text string */

         FIfld_get_text_length(fp,CATALOG_DESC,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, (length + 1));
         FIfld_get_text(fp,CATALOG_DESC,0,0,length,
                       (unsigned char*)text,&select,&pos);

         break;

    case ATTR_DATA_MCF:     /* Sequenced to     */

         _pdm_debug("Notified", 0);
          /* Get the text string */

         FIfld_get_active_row(fp, ATTR_DATA_MCF, &act_row, &pos);
         FImcf_get_active_col(fp, ATTR_DATA_MCF, &act_col, &act_pos);
         FIfld_get_text_length(fp,ATTR_DATA_MCF,act_row,act_col,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, (length + 1));
         status = FIfld_get_text(fp,ATTR_DATA_MCF,act_row,act_col,length,
                                 (unsigned char*)text,
                                 &select, &pos);

          if (text == NULL)
            break;
          else if (strcmp(text, "") == 0)
            break;

          /* Code to process text string "text" */
          PDUfill_in_string(&default_value, text);

          _pdm_debug("act_col = %d", (char *)act_col);

          FIfld_get_text_length(fp,ATTR_NAME_MCF,0,act_col,&length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, (length + 1));
          FIfld_get_text(fp,ATTR_NAME_MCF,0,act_col,length,
                         (unsigned char*)text,&select,&pos);

          /*if (text == NULL)
            break;
          else if (strcmp(text, "") == 0)
            break;*/

          row = -1;
          for ( i = 0; i < length; i++)
            if (text[i] == '(')
              {
              row = i; 
              break;
              }
         /* for " " */
         if (row != -1)
         {
         row = row -1;
         attr_name = (char *) malloc(length);
         memset(attr_name, NULL, length);
         for (i = 0; i < row; i ++)
           attr_name[i] = text[i];
         }
         else
           PDUfill_in_string(&attr_name, text);
         _pdm_debug("attr_name = <%s>", attr_name);
       status = PDUvalidate_data_value(attr_name, default_value, 
                                       PDU_parm_attr_bufr, 
                                       PDU_parm_list_bufr);
         _pdm_status("PDUvalidate_data_value", status);

         if (status == PDM_E_FAILURE)
           {
           msg = (char *)PDUtranslate_message(PDM_E_ATTR_VALUE_GEN_FUNC);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           FIfld_get_active_row(fp, ATTR_DATA_MCF, &act_row, &pos);
           FIfld_set_text(fp, ATTR_DATA_MCF, act_row, act_col, "", FALSE);
           break;
           }
         else if (status != PDM_S_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_E_BAD_DATA);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           FIfld_get_active_row(fp, ATTR_DATA_MCF, &act_row, &pos);
           FIfld_set_text(fp, ATTR_DATA_MCF, act_row, act_col, "", FALSE);
           break;
           }
         else
           {
           if (attr_name[0] == '*')
             {
             free(attr_name);
             attr_name = (char *)malloc(strlen(text));
             memset(attr_name, NULL, strlen(text));
             for ( i = 1; i < strlen(text); i++)
               attr_name[(i - 1)] = text[i];
             }
           MEMbuild_array(PDU_parm_attr_bufr);
           attr_row = PDUfind_attr_by_synonym(attr_name, PDU_parm_attr_bufr);
           if (attr_row != -1 )
             {
             _pdm_debug("attr_row = %d", (char *)attr_row);
             attr_data = (char **)PDU_parm_attr_bufr->data_ptr;
             PDUfill_in_string(&attr_name, 
                              attr_data[(PDU_parm_attr_bufr->columns * attr_row)
                              + PDU_NFM_ATTR_COL]);
             }
             _pdm_debug("attr_name = <%s>", attr_name);
           if (strcmp(attr_name, PDU_PARTID_ATTR) == 0)
             PDUfill_in_string(&refresh->rev_partid, default_value);
           else if (strcmp(attr_name, PDU_REVISION_ATTR) == 0)
              PDUfill_in_string(&refresh->rev_revision, default_value);
           else if (((strcmp(attr_name, PDU_NFM_VERSIONLIMIT) == 0) ||
                    (strcmp(attr_name, PDU_MAXLEVEL_ATTR) == 0)) &&
                    (default_value[0] == '-'))
           {
           msg = (char *)PDUtranslate_message(PDM_E_BAD_DATA);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           FIfld_get_active_row(fp, ATTR_DATA_MCF, &act_row, &pos);
           FIfld_set_text(fp, ATTR_DATA_MCF, act_row, act_col, "", FALSE);
           break;
           }

           if ((refresh->rev_partid) && (strcmp(refresh->rev_partid, "") != 0) 
               && (refresh->rev_revision) &&
               (strcmp(refresh->rev_revision, "") != 0) && (PDU_new_param_mode))
             {
             PDUload_exec_structure("", refresh->rev_catalog, 
                                             refresh->rev_partid, 
                                             refresh->rev_revision, "", "", "",
                                             0, 0);
             status = PDMvalidate_parametric_part();
             _pdm_status("PDMvalidate_parametric_part", status);

             PDUfill_in_string(&refresh->rev_partid, NULL);
             PDUfill_in_string(&refresh->rev_revision, NULL);
             if (status != PDM_S_SUCCESS)
               {
               msg = (char *)PDUtranslate_message(PDM_E_PART_EXISTS);
               FIg_set_text(fp, FI_MSG_FIELD, msg);
               FIfld_get_active_row(fp, ATTR_DATA_MCF, &act_row, &pos);
               FIfld_set_text(fp, ATTR_DATA_MCF, act_row, act_col, "", FALSE);
               }
             }
           }

           break;

    case ATTR_NAME_MCF:     /* Sequenced to     */

         FImcf_get_active_col(fp,ATTR_NAME_MCF, &act_col, &pos);
         FIfld_get_text_length(fp,ATTR_NAME_MCF,0,act_col,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, (length + 1));
         FIfld_get_text(fp,ATTR_NAME_MCF,0,act_col,length,
                        (unsigned char*)text,&select,&pos);

          _pdm_debug("text = <%s>", text);

          if (text == NULL)
            break;
          else if (strcmp(text, "") == 0)
            break;

          if (text[0] == '*')
            {
            /* attribute has a value list assosciated with it */
            PDUfill_in_string(&temp, text);
            /* strip off '*' from front */
            temp = temp + 1;
            status = PDUprocess_pulldown_list(temp, PDU_parm_attr_bufr, 
                                              PDU_parm_list_bufr);
            }
         break;

    case LEVEL6_BTN:     /* Sequenced to     */

         PDU_class_level = 5;

         if (PDU_query_class_bufr == NULL)
           {
           msg = (char *)PDUtranslate_message(PDM_I_SEL_LEVEL1_CLASS);
           FIg_set_text(fp, FI_MSG_FIELD,msg);
           break;
           }
         else if (PDU_class_level < PDU_query_class_bufr->rows)
           {
           /* call function to update buffer */
           status = PDUupdate_class_buffer(PDU_query_class_bufr, &temp_bufr,
                                           PDU_class_level);
           _pdm_status("PDUupdate_class_buffer", status);

          if (status != PDM_S_SUCCESS)
            {
            msg = (char *)PDUtranslate_message(PDM_E_RETRIEVE_CLASS);
            FIg_set_text(fp, FI_MSG_FIELD,msg );
            break;
            }

          if (PDU_query_class_bufr)
            {
            MEMclose(&PDU_query_class_bufr);
            PDU_query_class_bufr = NULL;
            }
          MEMsplit_copy_buffer(temp_bufr, &PDU_query_class_bufr, 0);
          MEMclose(&temp_bufr); 
          }
         PDUload_exec_structure("", "", "", "", "", "", "", 0, 0);
        _pdm_debug("calling PDMquery_classification", 0);
        if (PDU_cat_class_bufr)
          {
          MEMclose(&PDU_cat_class_bufr);
          PDU_cat_class_bufr = NULL;
          }
        status = PDMquery_classification(PDU_query_class_bufr, 
                                         &PDU_cat_class_bufr);
        _pdm_status("PDMquery_classification", status);

        if ((status != PDM_S_SUCCESS) || (PDU_cat_class_bufr == NULL))
          {
          msg = (char *)PDUtranslate_message(PDM_E_NO_CATALOGS);
          FIg_set_text(fp, FI_MSG_FIELD, msg);
          if (PDU_cat_class_bufr)
            {
            MEMclose(&PDU_cat_class_bufr);
            PDU_cat_class_bufr = NULL;
            }
          break;
          }
       if (PDMdebug_on)
          MEMprint_buffer("classification buffer",PDU_cat_class_bufr,
                           PDU_DEBUG_FILE);
      /* call function to load classes and catalogs into one buffer */
      status = PDUcreate_class_and_catalog_bufr(PDU_cat_class_bufr,
                                               &PDU_ret_bufr);
      _pdm_status("PDUcreate_class_and_catalog_bufr", status);

      if (status!= PDM_S_SUCCESS)
          {
          msg = (char *)PDUtranslate_message(PDM_E_PROCCESS_CLASS_LEVELS);
          FIg_set_text(fp, FI_MSG_FIELD, msg);
          if (PDU_cat_class_bufr)
            {
            MEMclose(&PDU_cat_class_bufr);
            PDU_cat_class_bufr = NULL;
            }
          break;
          }
       if (PDMdebug_on)
          MEMprint_buffer("listing buffer",PDU_ret_bufr,PDU_DEBUG_FILE);

       MEMbuild_array(PDU_ret_bufr);
       data_data = (char **)PDU_ret_bufr->data_ptr;
       /* load classes in to GRpulldown */
       list_size = PDU_ret_bufr->rows;
       for (i = 0; i < list_size; i++)
         PDUfill_in_string(&PDU_value_list[i],
                           data_data[(PDU_ret_bufr->columns * i) + 0]);
        
        
       GRdelete_pull_down_list(PDU_catalog_pulldown);
       GRcreate_pull_down_list(PARAMETRIC_PARTS_FORM, 
                               forms.parametric_parts_form_id,
                               CLASS_ASSOC_GADGET, list_size, VIS_ROWS, 
                          PDU_value_list, list_size, 1, &PDU_catalog_pulldown);
       GRchange_pull_down_text(PDU_catalog_pulldown,PDU_value_list,list_size);
       GRproc_pull_down_list(PDU_catalog_pulldown);

         break;

    case LEVEL1_BTN:     /* Member of group GROUP2  */
                             /* Sequenced to    */

         if (PDU_ret_bufr)
          {
          MEMclose(&PDU_ret_bufr);
          PDU_ret_bufr = NULL;
          }

         PDU_class_level = 0;
         status = PDUformat_classification_buffer(&input_buffer);
         _pdm_status("PDUformat_classification_buffer", status);

         if (status != PDM_S_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_E_RETRIEVE_CLASS);
           FIg_set_text(fp,FI_MSG_FIELD, msg);
           break;
           }

         string = (char *)malloc(input_buffer->row_size);
         memset(string, NULL, input_buffer->row_size);
         sprintf(string, "\1\1");
         status = MEMwrite(input_buffer, string);
         _pdm_status("MEMwrite", status);

         if (status != MEM_S_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_E_RETRIEVE_CLASS);
           FIg_set_text(fp,FI_MSG_FIELD, msg);
           break;
           }
         PDUload_exec_structure("", "", "", "", "", "", "", 0, 0);
        _pdm_debug("calling PDMquery_classification", 0);
        if (PDU_cat_class_bufr)
          {
          MEMclose(&PDU_cat_class_bufr);
          PDU_cat_class_bufr = NULL;
          }
        status = PDMquery_classification(input_buffer, &PDU_cat_class_bufr);
        _pdm_status("PDMquery_classification", status);

        if ((status != PDM_S_SUCCESS) || (PDU_cat_class_bufr == NULL))
          {
          msg = (char *)PDUtranslate_message(PDM_E_NO_CATALOGS);
          FIg_set_text(fp, FI_MSG_FIELD, msg);
          if (PDU_cat_class_bufr)
            {
            MEMclose(&PDU_cat_class_bufr);
            PDU_cat_class_bufr = NULL;
            }
          break;
          }
       if (PDMdebug_on)
          MEMprint_buffer("classification buffer",PDU_cat_class_bufr,
                           PDU_DEBUG_FILE);
      /* call function to load classes and catalogs into one buffer */
      status = PDUcreate_class_and_catalog_bufr(PDU_cat_class_bufr,
                                               &PDU_ret_bufr);
      _pdm_status("PDUcreate_class_and_catalog_bufr", status);

      if (status!= PDM_S_SUCCESS)
          {
          msg = (char *)PDUtranslate_message(PDM_E_PROCCESS_CLASS_LEVELS);
          FIg_set_text(fp, FI_MSG_FIELD, msg);
          if (PDU_cat_class_bufr)
            {
            MEMclose(&PDU_cat_class_bufr);
            PDU_cat_class_bufr = NULL;
            }
          break;
          }
       if (PDMdebug_on)
          MEMprint_buffer("listing buffer",PDU_ret_bufr,PDU_DEBUG_FILE);

       MEMbuild_array(PDU_ret_bufr);
       data_data = (char **)PDU_ret_bufr->data_ptr;
       /* load classes in to GRpulldown */
       list_size = PDU_ret_bufr->rows;
       for (i = 0; i < list_size; i++)
         PDUfill_in_string(&PDU_value_list[i],
                           data_data[(PDU_ret_bufr->columns * i) + 0]);
        
       FIfld_set_max_num_rows(fp, CLASS_ASSOC_GADGET,list_size);
       GRdelete_pull_down_list(PDU_catalog_pulldown);
       GRcreate_pull_down_list(PARAMETRIC_PARTS_FORM, 
                               forms.parametric_parts_form_id,
                               CLASS_ASSOC_GADGET, list_size, VIS_ROWS, 
                          PDU_value_list, list_size, 1, &PDU_catalog_pulldown);
       GRchange_pull_down_text(PDU_catalog_pulldown,PDU_value_list,list_size);
       FIfld_set_max_num_rows(fp, CLASS_ASSOC_GADGET,list_size);
       GRproc_pull_down_list(PDU_catalog_pulldown);
 
         break;

    case LEVEL2_BTN:     /* Member of group GROUP2  */
                             /* Sequenced to    */

         PDU_class_level = 1;

         if (PDU_query_class_bufr == NULL)
           {
           msg = (char *)PDUtranslate_message(PDM_I_SEL_LEVEL1_CLASS);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }
         else if (PDU_class_level < PDU_query_class_bufr->rows)
           {
           /* call function to update buffer */
           status = PDUupdate_class_buffer(PDU_query_class_bufr, &temp_bufr,
                                           PDU_class_level);
           _pdm_status("PDUupdate_class_buffer", status);

          if (status != PDM_S_SUCCESS)
            {
            msg = (char *)PDUtranslate_message(PDM_E_RETRIEVE_CLASS);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }

          if (PDU_query_class_bufr)
            {
            MEMclose(&PDU_query_class_bufr);
            PDU_query_class_bufr = NULL;
            }
          MEMsplit_copy_buffer(temp_bufr, &PDU_query_class_bufr, 0);
          MEMclose(&temp_bufr); 
          }
          
         PDUload_exec_structure("", "", "", "", "", "", "", 0, 0);
        _pdm_debug("calling PDMquery_classification", 0);
        if (PDU_cat_class_bufr)
          {
          MEMclose(&PDU_cat_class_bufr);
          PDU_cat_class_bufr = NULL;
          }
        status = PDMquery_classification(PDU_query_class_bufr, 
                                         &PDU_cat_class_bufr);
        _pdm_status("PDMquery_classification", status);

        if ((status != PDM_S_SUCCESS) || (PDU_cat_class_bufr == NULL))
          {
          msg = (char *)PDUtranslate_message(PDM_E_NO_CATALOGS);
          FIg_set_text(fp, FI_MSG_FIELD, msg);
          if (PDU_cat_class_bufr)
            {
            MEMclose(&PDU_cat_class_bufr);
            PDU_cat_class_bufr = NULL;
            }
          break;
          }
       if (PDMdebug_on)
          MEMprint_buffer("classification buffer",PDU_cat_class_bufr,
                           PDU_DEBUG_FILE);
      /* call function to load classes and catalogs into one buffer */
      status = PDUcreate_class_and_catalog_bufr(PDU_cat_class_bufr,
                                               &PDU_ret_bufr);
      _pdm_status("PDUcreate_class_and_catalog_bufr", status);

      if (status!= PDM_S_SUCCESS)
          {
          msg = (char *)PDUtranslate_message(PDM_I_SEL_LEVEL1_CLASS);
          FIg_set_text(fp, FI_MSG_FIELD, msg);
          if (PDU_cat_class_bufr)
            {
            MEMclose(&PDU_cat_class_bufr);
            PDU_cat_class_bufr = NULL;
            }
          break;
          }
       if (PDMdebug_on)
          MEMprint_buffer("listing buffer",PDU_ret_bufr,PDU_DEBUG_FILE);

       MEMbuild_array(PDU_ret_bufr);
       data_data = (char **)PDU_ret_bufr->data_ptr;
       /* load classes in to GRpulldown */
       list_size = PDU_ret_bufr->rows;
       for (i = 0; i < list_size; i++)
         PDUfill_in_string(&PDU_value_list[i],
                           data_data[(PDU_ret_bufr->columns * i) + 0]);
        
       GRdelete_pull_down_list(PDU_catalog_pulldown);
       GRcreate_pull_down_list(PARAMETRIC_PARTS_FORM, 
                               forms.parametric_parts_form_id,
                               CLASS_ASSOC_GADGET, list_size, VIS_ROWS, 
                          PDU_value_list, list_size, 1, &PDU_catalog_pulldown);
       GRchange_pull_down_text(PDU_catalog_pulldown,PDU_value_list,list_size);
       GRproc_pull_down_list(PDU_catalog_pulldown);


         break;

    case LEVEL3_BTN:     /* Member of group GROUP2  */
                             /* Sequenced to    */
         PDU_class_level = 2;

         if (PDU_query_class_bufr == NULL)
           {
           msg = (char *)PDUtranslate_message(PDM_I_SEL_LEVEL1_CLASS);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }
         else if (PDU_class_level < PDU_query_class_bufr->rows)
           {
           /* call function to update buffer */
           status = PDUupdate_class_buffer(PDU_query_class_bufr, &temp_bufr,
                                           PDU_class_level);
           _pdm_status("PDUupdate_class_buffer", status);

          if (status != PDM_S_SUCCESS)
            {
            msg = (char *)PDUtranslate_message(PDM_E_RETRIEVE_CLASS);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }

          if (PDU_query_class_bufr)
            {
            MEMclose(&PDU_query_class_bufr);
            PDU_query_class_bufr = NULL;
            }
          MEMsplit_copy_buffer(temp_bufr, &PDU_query_class_bufr, 0);
          MEMclose(&temp_bufr); 
          }
          
         PDUload_exec_structure("", "", "", "", "", "", "", 0, 0);
        _pdm_debug("calling PDMquery_classification", 0);
        if (PDU_cat_class_bufr)
          {
          MEMclose(&PDU_cat_class_bufr);
          PDU_cat_class_bufr = NULL;
          }
        status = PDMquery_classification(PDU_query_class_bufr, 
                                         &PDU_cat_class_bufr);
        _pdm_status("PDMquery_classification", status);

        if ((status != PDM_S_SUCCESS) || (PDU_cat_class_bufr == NULL))
          {
          msg = (char *)PDUtranslate_message(PDM_E_NO_CATALOGS);
          FIg_set_text(fp, FI_MSG_FIELD, msg);
          if (PDU_cat_class_bufr)
            {
            MEMclose(&PDU_cat_class_bufr);
            PDU_cat_class_bufr = NULL;
            }
          break;
          }
       if (PDMdebug_on)
          MEMprint_buffer("classification buffer",PDU_cat_class_bufr,
                           PDU_DEBUG_FILE);
      /* call function to load classes and catalogs into one buffer */
      status = PDUcreate_class_and_catalog_bufr(PDU_cat_class_bufr,
                                               &PDU_ret_bufr);
      _pdm_status("PDUcreate_class_and_catalog_bufr", status);

      if (status!= PDM_S_SUCCESS)
          {
          msg = (char *)PDUtranslate_message(PDM_I_SEL_LEVEL1_CLASS);
          FIg_set_text(fp, FI_MSG_FIELD, msg);
          if (PDU_cat_class_bufr)
            {
            MEMclose(&PDU_cat_class_bufr);
            PDU_cat_class_bufr = NULL;
            }
          break;
          }
       if (PDMdebug_on)
          MEMprint_buffer("listing buffer",PDU_ret_bufr,PDU_DEBUG_FILE);

       MEMbuild_array(PDU_ret_bufr);
       data_data = (char **)PDU_ret_bufr->data_ptr;
       /* load classes in to GRpulldown */
       list_size = PDU_ret_bufr->rows;
       for (i = 0; i < list_size; i++)
         PDUfill_in_string(&PDU_value_list[i],
                           data_data[(PDU_ret_bufr->columns * i) + 0]);
        
       GRdelete_pull_down_list(PDU_catalog_pulldown);
       GRcreate_pull_down_list(PARAMETRIC_PARTS_FORM, 
                               forms.parametric_parts_form_id,
                               CLASS_ASSOC_GADGET, list_size, VIS_ROWS, 
                          PDU_value_list, list_size, 1, &PDU_catalog_pulldown);
       GRchange_pull_down_text(PDU_catalog_pulldown,PDU_value_list,list_size);
       GRproc_pull_down_list(PDU_catalog_pulldown);


         break;

    case LEVEL4_BTN:     /* Member of group GROUP2  */
                             /* Sequenced to    */

         PDU_class_level = 3;

         if (PDU_query_class_bufr == NULL)
           {
           msg = (char *)PDUtranslate_message(PDM_I_SEL_LEVEL1_CLASS);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }
         else if (PDU_class_level < PDU_query_class_bufr->rows)
           {
           /* call function to update buffer */
           status = PDUupdate_class_buffer(PDU_query_class_bufr, &temp_bufr,
                                           PDU_class_level);
           _pdm_status("PDUupdate_class_buffer", status);

          if (status != PDM_S_SUCCESS)
            {
            msg = (char *)PDUtranslate_message(PDM_E_RETRIEVE_CLASS);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }

          if (PDU_query_class_bufr)
            {
            MEMclose(&PDU_query_class_bufr);
            PDU_query_class_bufr = NULL;
            }
          MEMsplit_copy_buffer(temp_bufr, &PDU_query_class_bufr, 0);
          MEMclose(&temp_bufr); 
          }
          
         PDUload_exec_structure("", "", "", "", "", "", "", 0, 0);
        _pdm_debug("calling PDMquery_classification", 0);
        if (PDU_cat_class_bufr)
          {
          MEMclose(&PDU_cat_class_bufr);
          PDU_cat_class_bufr = NULL;
          }
        status = PDMquery_classification(PDU_query_class_bufr, 
                                         &PDU_cat_class_bufr);
        _pdm_status("PDMquery_classification", status);

        if ((status != PDM_S_SUCCESS) || (PDU_cat_class_bufr == NULL))
          {
          msg = (char *)PDUtranslate_message(PDM_E_NO_CATALOGS);
          FIg_set_text(fp, FI_MSG_FIELD, msg);
          if (PDU_cat_class_bufr)
            {
            MEMclose(&PDU_cat_class_bufr);
            PDU_cat_class_bufr = NULL;
            }
          break;
          }
       if (PDMdebug_on)
          MEMprint_buffer("classification buffer",PDU_cat_class_bufr,
                           PDU_DEBUG_FILE);
      /* call function to load classes and catalogs into one buffer */
      status = PDUcreate_class_and_catalog_bufr(PDU_cat_class_bufr,
                                               &PDU_ret_bufr);
      _pdm_status("PDUcreate_class_and_catalog_bufr", status);

      if (status!= PDM_S_SUCCESS)
          {
          msg = (char *)PDUtranslate_message(PDM_E_PROCCESS_CLASS_LEVELS);
          FIg_set_text(fp, FI_MSG_FIELD, msg);
          if (PDU_cat_class_bufr)
            {
            MEMclose(&PDU_cat_class_bufr);
            PDU_cat_class_bufr = NULL;
            }
          break;
          }
       if (PDMdebug_on)
          MEMprint_buffer("listing buffer",PDU_ret_bufr,PDU_DEBUG_FILE);

       MEMbuild_array(PDU_ret_bufr);
       data_data = (char **)PDU_ret_bufr->data_ptr;
       /* load classes in to GRpulldown */
       list_size = PDU_ret_bufr->rows;
       for (i = 0; i < list_size; i++)
         PDUfill_in_string(&PDU_value_list[i],
                           data_data[(PDU_ret_bufr->columns * i) + 0]);
        
       GRdelete_pull_down_list(PDU_catalog_pulldown);
       GRcreate_pull_down_list(PARAMETRIC_PARTS_FORM, 
                               forms.parametric_parts_form_id,
                               CLASS_ASSOC_GADGET, list_size, VIS_ROWS, 
                          PDU_value_list, list_size, 1, &PDU_catalog_pulldown);
       GRchange_pull_down_text(PDU_catalog_pulldown,PDU_value_list,list_size);
       GRproc_pull_down_list(PDU_catalog_pulldown);

         break;

    case LEVEL5_BTN:     /* Member of group GROUP2  */
                             /* Sequenced to    */

         PDU_class_level = 4;

         if (PDU_query_class_bufr == NULL)
           {
           msg = (char *)PDUtranslate_message(PDM_I_SEL_LEVEL1_CLASS);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }
         else if (PDU_class_level < PDU_query_class_bufr->rows)
           {
           /* call function to update buffer */
           status = PDUupdate_class_buffer(PDU_query_class_bufr, &temp_bufr,
                                           PDU_class_level);
           _pdm_status("PDUupdate_class_buffer", status);

          if (status != PDM_S_SUCCESS)
            {
            msg = (char *)PDUtranslate_message(PDM_E_RETRIEVE_CLASS);
            FIg_set_text(fp, FI_MSG_FIELD,msg);
            break;
            }

          if (PDU_query_class_bufr)
            {
            MEMclose(&PDU_query_class_bufr);
            PDU_query_class_bufr = NULL;
            }
          MEMsplit_copy_buffer(temp_bufr, &PDU_query_class_bufr, 0);
          MEMclose(&temp_bufr); 
          }
          
         PDUload_exec_structure("", "", "", "", "", "", "", 0, 0);
        _pdm_debug("calling PDMquery_classification", 0);
        if (PDU_cat_class_bufr)
          {
          MEMclose(&PDU_cat_class_bufr);
          PDU_cat_class_bufr = NULL;
          }
        status = PDMquery_classification(PDU_query_class_bufr, 
                                         &PDU_cat_class_bufr);
        _pdm_status("PDMquery_classification", status);

        if ((status != PDM_S_SUCCESS) || (PDU_cat_class_bufr == NULL))
          {
          msg = (char *)PDUtranslate_message(PDM_E_NO_CATALOGS);
          FIg_set_text(fp, FI_MSG_FIELD, msg);
          if (PDU_cat_class_bufr)
            {
            MEMclose(&PDU_cat_class_bufr);
            PDU_cat_class_bufr = NULL;
            }
          break;
          }
       if (PDMdebug_on)
          MEMprint_buffer("classification buffer",PDU_cat_class_bufr,
                           PDU_DEBUG_FILE);
      /* call function to load classes and catalogs into one buffer */
      status = PDUcreate_class_and_catalog_bufr(PDU_cat_class_bufr,
                                               &PDU_ret_bufr);
      _pdm_status("PDUcreate_class_and_catalog_bufr", status);

      if (status!= PDM_S_SUCCESS)
          {
          msg = (char *)PDUtranslate_message(PDM_E_PROCCESS_CLASS_LEVELS);
          FIg_set_text(fp, FI_MSG_FIELD, msg);
          if (PDU_cat_class_bufr)
            {
            MEMclose(&PDU_cat_class_bufr);
            PDU_cat_class_bufr = NULL;
            }
          break;
          }
       if (PDMdebug_on)
          MEMprint_buffer("listing buffer",PDU_ret_bufr,PDU_DEBUG_FILE);

       MEMbuild_array(PDU_ret_bufr);
       data_data = (char **)PDU_ret_bufr->data_ptr;
       /* load classes in to GRpulldown */
       list_size = PDU_ret_bufr->rows;
       for (i = 0; i < list_size; i++)
         PDUfill_in_string(&PDU_value_list[i],
                           data_data[(PDU_ret_bufr->columns * i) + 0]);
        
       GRdelete_pull_down_list(PDU_catalog_pulldown);
       GRcreate_pull_down_list(PARAMETRIC_PARTS_FORM, 
                               forms.parametric_parts_form_id,
                               CLASS_ASSOC_GADGET, list_size, VIS_ROWS, 
                          PDU_value_list, list_size, 1, &PDU_catalog_pulldown);
       GRchange_pull_down_text(PDU_catalog_pulldown,PDU_value_list,list_size);
       GRproc_pull_down_list(PDU_catalog_pulldown);

         break;

    case NEW_BTN:     /* Member of group GROUP3  */
                             /* Sequenced to    */

         if (PDU_new_param_mode)
           break;

         FIg_reset(fp, ATTR_NAME_MCF);
         FIg_reset(fp, ATTR_DATA_MCF);

         FIg_disable(fp, ADD_ROW_DEF);
         FIg_disable(fp, COPY_ROW);
         FIg_disable(fp, CLEAR_ROW);

         FIg_disable(fp, CHANGE_PART);
         FIg_disable(fp, ADD_ROWS_FR_SEARCH);
         FIg_disable(fp, DELETE_PART);
         FIg_disable(fp, MOVE_NEXT_STATE);
         FIg_disable(fp, ADD_PART);

         PDU_new_param_mode = TRUE;
         PDU_change_param_mode = FALSE;

         FIg_disable(fp, ATTR_NAME_MCF);
         FIg_disable(fp, ATTR_DATA_MCF);
         FIfld_set_mode(fp, ATTR_DATA_MCF, 0, FI_MULTI_SELECT);
         FIg_display(fp, ATTR_DATA_MCF);
         
         if (PDU_parm_attr_bufr)
           {
           MEMclose(&PDU_parm_attr_bufr);
           PDU_parm_attr_bufr = NULL;
           }
         if (PDU_parm_data_bufr)
           {
           MEMclose(&PDU_parm_data_bufr);
           PDU_parm_data_bufr = NULL;
           }
         if (PDU_parm_list_bufr)
           {
           MEMclose(&PDU_parm_list_bufr);
           PDU_parm_list_bufr = NULL;
           }

         if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
           {
          status = PDMquery_catalog_type(refresh->rev_catalog, cat_type);
          _pdm_status("PDMquery_catalog", status);

           /* Display Message */
           PDUmessage(PDS_M_GET_TABLE_ATTR, 's');

           catalog_type = (char *) malloc(5);
           memset(catalog_type, NULL, 5);
           strcpy(catalog_type, cat_type);
           PDUload_exec_structure("",refresh->rev_catalog,"",catalog_type,
                                           "", "", "", ADD_DATA,
                                           PDM_PARAMETRIC_PART);
           _pdm_debug("Calling PDMsget_table_attributes", 0);
           status = PDMsget_table_attributes(&PDU_parm_attr_bufr,
                                             &PDU_parm_data_bufr,
                                             &PDU_parm_list_bufr);
           _pdm_status("PDMsget_table_attributes", status);
           PDUmessage(status, 's');

           if ((status != PDM_S_SUCCESS) || (PDU_parm_attr_bufr == NULL))
             {
             msg = (char *)PDUtranslate_message(status);
             FIg_set_text(fp, FI_MSG_FIELD, msg);
              break;
              }

           FIg_erase(fp, ATTR_NAME_MCF);
           FIg_erase(fp, ATTR_DATA_MCF);
           PDUload_data_into_mcf(PDU_parm_attr_bufr, NULL, PDU_parm_list_bufr);
           FIg_enable(fp, ADD_ROW_DEF);
           FIg_enable(fp, COPY_ROW);
           FIg_enable(fp, CLEAR_ROW);
           FIg_display(fp, ATTR_DATA_MCF);
           FIg_display(fp, ATTR_NAME_MCF);
           }

         break;

    case CHANGE_BTN:     /* Member of group GROUP3  */
                             /* Sequenced to    */

         if (PDU_change_param_mode)
           break;

         FIg_reset(fp, ATTR_NAME_MCF);
         FIg_reset(fp, ATTR_DATA_MCF);

         FIg_disable(fp, ADD_ROW_DEF);
         FIg_enable(fp, ADD_ROWS_FR_SEARCH);
         FIg_disable(fp, COPY_ROW);
         FIg_disable(fp, CLEAR_ROW);

         FIg_disable(fp, CHANGE_PART);
         FIg_disable(fp, DELETE_PART);
         FIg_disable(fp, MOVE_NEXT_STATE);
         FIg_disable(fp, ADD_PART);

         PDU_new_param_mode = FALSE;
         PDU_change_param_mode = TRUE;

         FIg_disable(fp, ATTR_NAME_MCF);
         FIg_disable(fp, ATTR_DATA_MCF);
         FIfld_set_mode(fp, ATTR_DATA_MCF, 0, FI_MULTI_SELECT);
         FIg_display(fp, ATTR_DATA_MCF);
         
         if (PDU_parm_attr_bufr)
           {
           MEMclose(&PDU_parm_attr_bufr);
           PDU_parm_attr_bufr = NULL;
           }
         if (PDU_parm_data_bufr)
           {
           MEMclose(&PDU_parm_data_bufr);
           PDU_parm_data_bufr = NULL;
           }
         if (PDU_parm_list_bufr)
           {
           MEMclose(&PDU_parm_list_bufr);
           PDU_parm_list_bufr = NULL;
           }

         break;

    case LEVEL7_BTN:     /* Sequenced to     */

         PDU_class_level = 6;

         if (PDU_query_class_bufr == NULL)
           {
           msg = (char *)PDUtranslate_message(PDM_I_SEL_LEVEL1_CLASS);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }
         else if (PDU_class_level < PDU_query_class_bufr->rows)
           {
           /* call function to update buffer */
           status = PDUupdate_class_buffer(PDU_query_class_bufr, &temp_bufr,
                                           PDU_class_level);
           _pdm_status("PDUupdate_class_buffer", status);

          if (status != PDM_S_SUCCESS)
            {
            msg = (char *)PDUtranslate_message(PDM_I_SEL_LEVEL1_CLASS);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }

          if (PDU_query_class_bufr)
            {
            MEMclose(&PDU_query_class_bufr);
            PDU_query_class_bufr = NULL;
            }
          MEMsplit_copy_buffer(temp_bufr, &PDU_query_class_bufr, 0);
          MEMclose(&temp_bufr); 
          }
          
         PDUload_exec_structure("", "", "", "", "", "", "", 0, 0);
        _pdm_debug("calling PDMquery_classification", 0);
        if (PDU_cat_class_bufr)
          {
          MEMclose(&PDU_cat_class_bufr);
          PDU_cat_class_bufr = NULL;
          }
        status = PDMquery_classification(PDU_query_class_bufr, 
                                         &PDU_cat_class_bufr);
        _pdm_status("PDMquery_classification", status);

        if ((status != PDM_S_SUCCESS) || (PDU_cat_class_bufr == NULL))
          {
          msg = (char *)PDUtranslate_message(PDM_E_NO_CATALOGS);
          FIg_set_text(fp, FI_MSG_FIELD, msg);
          if (PDU_cat_class_bufr)
            {
            MEMclose(&PDU_cat_class_bufr);
            PDU_cat_class_bufr = NULL;
            }
          break;
          }
       if (PDMdebug_on)
          MEMprint_buffer("classification buffer",PDU_cat_class_bufr,
                           PDU_DEBUG_FILE);
      /* call function to load classes and catalogs into one buffer */
      status = PDUcreate_class_and_catalog_bufr(PDU_cat_class_bufr,
                                               &PDU_ret_bufr);
      _pdm_status("PDUcreate_class_and_catalog_bufr", status);

      if (status!= PDM_S_SUCCESS)
          {
          msg = (char *)PDUtranslate_message(PDM_E_PROCCESS_CLASS_LEVELS);
          FIg_set_text(fp, FI_MSG_FIELD, msg);
          if (PDU_cat_class_bufr)
            {
            MEMclose(&PDU_cat_class_bufr);
            PDU_cat_class_bufr = NULL;
            }
          break;
          }
       if (PDMdebug_on)
          MEMprint_buffer("listing buffer",PDU_ret_bufr,PDU_DEBUG_FILE);

       MEMbuild_array(PDU_ret_bufr);
       data_data = (char **)PDU_ret_bufr->data_ptr;
       /* load classes in to GRpulldown */
       list_size = PDU_ret_bufr->rows;
       for (i = 0; i < list_size; i++)
         PDUfill_in_string(&PDU_value_list[i],
                           data_data[(PDU_ret_bufr->columns * i) + 0]);
        
       GRdelete_pull_down_list(PDU_catalog_pulldown);
       GRcreate_pull_down_list(PARAMETRIC_PARTS_FORM, 
                               forms.parametric_parts_form_id,
                               CLASS_ASSOC_GADGET, list_size, VIS_ROWS, 
                          PDU_value_list, list_size, 1, &PDU_catalog_pulldown);
       GRchange_pull_down_text(PDU_catalog_pulldown,PDU_value_list,list_size);
       GRproc_pull_down_list(PDU_catalog_pulldown);

         break;

    case CATALOG_NAME:     /* Sequenced to     */
                             /* Field Type:    ASCII    */

          /* Get the text string */

         FIfld_get_text_length(fp,CATALOG_NAME,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, (length + 1));
         status = FIfld_get_text(fp,CATALOG_NAME,0,0,length,
                                 (unsigned char*)text,&select,&pos);

          if ( status != FI_SUCCESS )
            {
              /* Code to handle error */
              _pdm_debug("Error getting catalog name from form", 0);
              FIg_set_text(fp, CATALOG_NAME, "");
              if ((refresh->rev_catalog) && 
                  (strcmp(refresh->rev_catalog, "") != 0))
                PDUfill_in_string(&refresh->rev_catalog, NULL);
              break;
            }

           if (strcmp(text, "") == 0)
             {
             if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") 
                 != 0))
               PDUfill_in_string(&refresh->rev_catalog, NULL);
             FIg_set_text(fp, CATALOG_DESC, "");
             break;
             }

           if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0)
               && (strcmp(refresh->rev_catalog, text) == 0))
             break;

           status = PDMcheck_for_view(text);
           _pdm_status("PDMcheck_for_view", status);
 
           if (status == PDM_I_VIEW_FOUND)
             {
             strcpy(cat_type, "CID");
             PDUfill_in_string(&refresh->rev_catalog, text);
             }
           else
             {
           bufr_flag = FALSE;
          /* validate catalog on the specific arg */
          if ((refresh->rev_project) && (strcmp(refresh->rev_project, "") != 0))
            status = PDUvalid_catalog(refresh->rev_project, text);
          else
            status = PDUvalid_catalog("", text);
          _pdm_status("PDUvalid_catalog",status);
          if (status != PDM_S_SUCCESS) 
            {
            _pdm_debug("catalog <%s> is not valid", text);
            msg = (char *)PDUtranslate_message(PDM_E_CATALOG_NOT_FOUND);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            FIg_set_text(fp, CATALOG_NAME, "");
            if ((refresh->rev_catalog) && 
                (strcmp(refresh->rev_catalog, "") != 0))
              PDUfill_in_string(&refresh->rev_catalog, NULL);
            FIg_disable(fp, ATTR_DATA_MCF);
            FIg_erase(fp, ATTR_NAME_MCF);
            break;
            }
          else
            PDUfill_in_string(&refresh->rev_catalog, text);
          }

          PDUget_parametric_part_attributes();
          FImcf_get_num_cols(fp, ATTR_NAME_MCF, &num_cols);
          for (i = 0; i < num_cols; i ++)
          FIfld_set_mode(forms.parametric_parts_form_id, ATTR_NAME_MCF, i, 
                         FI_SINGLE_SELECT);


         break;

    case PROJECT_NAME:         /* Field Type:    ASCII    */

          /* Get the text string */

         FIfld_get_text_length(fp,PROJECT_NAME,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, (length + 1));
         status = FIfld_get_text(fp,PROJECT_NAME,0,0,length,
                                 (unsigned char*)text,&select,&pos);

          if ( status != FI_SUCCESS )
            {
              /* Code to handle error */
              if ((refresh->rev_project) && (strcmp(refresh->rev_project, "") 
                 != 0))
                PDUfill_in_string(&refresh->rev_project, NULL);
              break;
            }

          if (text == NULL)
            {
            if ((refresh->rev_project) && (strcmp(refresh->rev_project, "") 
                != 0))
              PDUfill_in_string(&refresh->rev_project, NULL);
            break;
            }
          else if (strcmp(text, "") == 0)
            {
            if ((refresh->rev_project) && (strcmp(refresh->rev_project, "") 
                != 0))
              PDUfill_in_string(&refresh->rev_project,NULL);
            break;
            }

          /* Code to process text string "text" */
          status = PDUep_proj_fld();
          _pdm_status("PDUep_proj_fld", status);

          if (status == 0)
            break;

          PDUmessage(status, 's');

         break;

    case PART_NUM:     /* Sequenced to     */
                             /* Field Type:    ASCII    */

         /* Review Mode Only */

         break;

    case REVISION:         /* Field Type:    ASCII    */

         /* Review Mode Only */

         break;

    case MOVE_NEXT_STATE:     

         status = PDUprocess_move_to_next_state();
         _pdm_status("PDUprocess_move_to_next_state", status);

          if (status == PDM_E_FAILURE)
            PDUmessage(PDM_I_NO_ROWS_SELECTED, 's');
         break;

    case PROJECT_LIST:     

         PDU_active_button = PROJECT_LIST;
         PDU_active_list = TRUE;

         status = PDUep_proj_btn();
         _pdm_status("PDUep_proj_btn", status);

         PDUmessage(status, 's');

         break;

    case ADD_PART:     /* Member of group GROUP10  */
                             /* Sequenced to    */

         /* clear out data bufr first */
         if (PDU_parm_data_bufr)
           {
           MEMsplit_copy_buffer(PDU_parm_data_bufr, &temp_bufr, 0);
           MEMclose(&PDU_parm_data_bufr);
           PDU_parm_data_bufr = NULL;
           }
      
        status = PDUupdate_parm_data_buffer(&PDU_parm_data_bufr, PDU_parm_attr_bufr);
        _pdm_status("PDUupdate_parm_data_buffer", status);

         if (status != PDM_S_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_E_PROCCESS_DATA);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }

         /* call function to load data into buffers */
         status = PDUload_parametric_part_bufr(temp_bufr);
         _pdm_status("PDUload_parametric_part_bufr", status);

         if (status != PDM_S_SUCCESS)
           {
           MEMsplit_copy_buffer(temp_bufr, &PDU_parm_data_bufr, 0);
           MEMclose(&temp_bufr);
           break;
           }

         /* call function to verify all parts do not exist */
         msg = (char *) malloc(240);
         strcpy(msg, "");
         status = PDUcheck_all_parametric_parts_exist(PDU_parm_attr_bufr,
                                                      PDU_parm_data_bufr,
                                                      msg);
         _pdm_status("PDUcheck_all_parametric_parts_exists", status);

         if (status != PDM_S_SUCCESS)
           {
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }

         status = PDUcheck_all_parametric_parts_dup(PDU_parm_attr_bufr,
                                                    PDU_parm_data_bufr,
                                                    msg);
         _pdm_status("PDUcheck_all_parametric_parts_dup", status);

         if (status != PDM_S_SUCCESS)
           {
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }
         /* extract creator and creation date */
         status = MEMbuild_array(PDU_parm_attr_bufr);
         _pdm_status("MEMbuild_array", status);
         if (status != MEM_S_SUCCESS)
             break;
         buffer_number = 0;
         attr_row = PDUfind_attr_in_buffer(PDU_parm_attr_bufr, PDU_NFM_CISANO);
         if (attr_row != -1)
         {
         attr_data = (char **)PDU_parm_attr_bufr->data_ptr;
         sscanf(attr_data[(PDU_parm_attr_bufr->columns * attr_row) + 
                PDU_NFM_LISTNO_COL],
                "%d", &buffer_number);
         }
         if ((buffer_number >= 1) && (attr_row != -1))
           {
           _pdm_debug("buffer_number = <%d>", (char *)buffer_number);
           if (PDM_debug_on)
              MEMprint_buffer("parametric attributes", PDU_parm_list_bufr, 
                               PDU_DEBUG_FILE); 
           status = MEMreset_buffer_no(PDU_parm_list_bufr, buffer_number);
           _pdm_status("MEMreset_buffer_no", status);
           list_data = (char **)PDU_parm_list_bufr->data_ptr;
           PDUfill_in_string(&sano,list_data[0]);
           _pdm_debug("sano = <%s>", sano);
           }
           status = MEMbuild_array(temp_bufr);
           _pdm_status("MEMbuild_array", status);
           status = MEMbuild_array(PDU_parm_data_bufr);
           _pdm_status("MEMbuild_array", status);
          for (i = 0; i < PDU_parm_data_bufr->rows; i++)
            {
        attr_row = PDUfind_attr_in_buffer(PDU_parm_attr_bufr, PDU_NFM_CREATOR);
            _pdm_debug("attr_row = <%d>", (char *)attr_row);
            data_data = (char **)temp_bufr->data_ptr;
            if (attr_row != -1)
              {
              _pdm_debug("before MEMwrite", 0);
              _pdm_debug("data_data[attr_row] = <%s>", data_data[attr_row]);
              status = MEMwrite_data(PDU_parm_data_bufr, data_data[attr_row], 
                                     (i + 1), (attr_row + 1));
              _pdm_status("MEMwrite_data", status);
              }
            attr_row = PDUfind_attr_in_buffer(PDU_parm_attr_bufr, 
                                              "n_creationdate");
            if (attr_row != -1)
              {
              status = MEMwrite_data(PDU_parm_data_bufr, data_data[attr_row], 
                                     (i + 1), (attr_row + 1));
              _pdm_status("MEMwrite_data", status);
              }
            attr_row = PDUfind_attr_in_buffer(PDU_parm_attr_bufr, 
                                              PDU_NFM_CISANO);
            if ((attr_row != -1) && (sano) && (strcmp(sano, "") != 0))
              {
              status = MEMwrite_data(PDU_parm_data_bufr, sano, 
                                     (i + 1), (attr_row + 1));
              _pdm_status("MEMwrite_data", status);
              }
           }
        PDU_validate_access = TRUE;
        refresh->command = PDC_M_CREATE_ELEMENT;
        status = PDUvalidate_access(refresh->command);
        _pdm_status("PDUvalidate_access", status);

        if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
          break;
          }
      if (PDM_debug_on)
        {
         MEMprint_buffer("parametric attributes", PDU_parm_attr_bufr, 
                          PDU_DEBUG_FILE); 
         MEMprint_buffer("parametric attributes", PDU_parm_data_bufr, 
                          PDU_DEBUG_FILE); 
         }
        /* load PDMexec structure */
        PDUload_exec_structure("", refresh->rev_catalog, "", "", "","","",0, 0);

         /* call function to add parts to database */
        PDUmessage(PDS_M_ADD_PART, 's');
         status = PDMadd_parametric_part(PDU_parm_attr_bufr, PDU_parm_data_bufr,
                                         "P", &status_bufr);
         _pdm_status("PDMadd_parametric_part", status);

         if (status != PDM_S_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_E_ADD_ITEM);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           }

         PDUmessage_trans(status, 's');
         PDUmessage(status, 's');
         PDUmessage(PDM_E_CLEAR_FIELD, 'c');
         if (PDU_parm_data_bufr)
           {
           MEMclose(&PDU_parm_data_bufr);
           PDU_parm_data_bufr = NULL;
           }
         status = MEMsplit_copy_buffer(temp_bufr, &PDU_parm_data_bufr, 0);
         if (temp_bufr)
           MEMclose(&temp_bufr);
         FIg_reset(fp, ATTR_DATA_MCF);
         FIg_reset(fp, ATTR_NAME_MCF);
         PDUload_data_into_mcf(PDU_parm_attr_bufr, NULL, PDU_parm_list_bufr);
         if ((refresh->rev_partid) && (strcmp(refresh->rev_partid, "") != 0))
           PDUfill_in_string(&refresh->rev_partid, NULL);
        if ((refresh->rev_revision) && (strcmp(refresh->rev_revision, "") != 0))
           PDUfill_in_string(&refresh->rev_revision, NULL);
         /*if ((status_bufr != NULL) && (status_bufr->rows > 0))
           PDUdisplay_where_used(status_bufr);*/
         break;

    case CHANGE_PART:     /* Member of group GROUP10  */
                             /* Sequenced to    */

         /* call function to load data into buffers */
         status = PDUload_mod_parametric_part_bufr();
         _pdm_status("PDUload_mod_parametric_part_bufr", status);

         if (status == PDM_E_FAILURE)
           break;
         if (status != PDM_S_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_E_LOADING_DATA);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }

        status = PDUextract_refresh_from_mcf(0);
        _pdm_status("PDUextract_refresh_from_mcf", status);

        PDU_validate_access = TRUE;
        refresh->command = PDC_M_MODIFY_ELEMENT;
        status = PDUvalidate_access(refresh->command);
        _pdm_status("PDUvalidate_access", status);

        if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
          break;
          }
      if (PDM_debug_on)
        {
         MEMprint_buffer("parametric attributes", PDU_parm_attr_bufr,
                          PDU_DEBUG_FILE);
         MEMprint_buffer("parametric attributes", PDU_parm_data_bufr,
                          PDU_DEBUG_FILE);
         }
        /* load PDMexec structure */
        PDUload_exec_structure("", refresh->rev_catalog, "", "", "","","",0, 0);


         /* call function to change parts in database */
         PDUmessage(PDS_M_MODIFY_PART, 's');
         status = PDMupdate_parametric_parts(PDU_parm_attr_bufr, 
                                            PDU_parm_data_bufr,
                                            "P", &status_bufr);
         _pdm_status("PDMupdate_parametric_parts", status);

         if (status != PDM_S_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_E_CHANGE_UNSUCCESSFUL);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           }

         PDUmessage_trans(status, 's');
         PDUmessage(status, 's');
         PDUmessage(PDM_E_CLEAR_FIELD, 'c');
         if (PDU_parm_data_bufr)
           {
           MEMclose(&PDU_parm_data_bufr);
           PDU_parm_data_bufr = NULL;
           }
         if ((status_bufr != NULL) && (status_bufr->rows > 0))
           PDUdisplay_where_used(status_bufr);

         FIg_reset(fp, ATTR_NAME_MCF);
         FIg_reset(fp, ATTR_DATA_MCF);
         FIg_disable(fp, ATTR_NAME_MCF);
         FIg_disable(fp, ATTR_DATA_MCF);
         FIg_disable(fp, MOVE_NEXT_STATE);
         FIg_disable(fp, CHANGE_PART);
         FIg_disable(fp, DELETE_PART);

         break;

    case DELETE_PART:     /* Member of group GROUP10  */
                             /* Sequenced to    */

         /* delete selected row */
         FIfld_get_num_rows(fp, ATTR_DATA_MCF, &num_rows);
         selected_rows = -1;
         _pdm_debug("num_rows = %d", (char *)num_rows);
         for ( i = 0; i < num_rows; i++)
           {
           FIfld_get_select(fp, ATTR_DATA_MCF, i, 0, &sel_flag);
           if (sel_flag == TRUE)
             {
             selected_rows = i;
             break;
             }
          }
          _pdm_debug("selected row = %d", (char *)selected_rows);

          if (selected_rows == -1)
            {
            PDUmessage(PDM_I_NO_ROWS_SELECTED, 's');
            break;
            }

          msg = (char *)PDUtranslate_message(PDP_P_DELETE_PARM_PART);
          UI_prompt(msg);
          do
            {
             status = PDUget_keyin(answer);
             if ( (strcmp(answer, "Y") != 0) &&
                  (strcmp(answer, "y") != 0) && (strcmp(answer, "n") != 0) &&
                  (strcmp(answer, "N") != 0) && (strcmp(answer, "") != 0) )
                {
                 status = PDM_E_INVALID_INPUT;
                }

             else
                 status = PDM_S_SUCCESS;
             }

          while (status == PDM_E_INVALID_INPUT);

          UI_prompt("");

          if ((strcmp(answer, "n") == 0) || (strcmp(answer, "N") == 0))
            {
            PDUmessage(PDM_E_CMD_CANCELLED, 's');
            break;
            }
          /* confirm to delete selected parametric parts */
          status = PDUextract_refresh_from_mcf(selected_rows);
          _pdm_status("PDUextract_refresh_from_mcf", status);

         /* call function to load selected parts   in buffer */
         status = PDUload_deleted_parts(&delete_bufr);
         _pdm_status("PDUload_deleted_parts", status);
         if (status != PDM_S_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_E_LOADING_DATA);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }

        PDU_validate_access = TRUE;
        refresh->command = PDC_M_DELETE_ELEMENT;
        status = PDUvalidate_access(refresh->command);
        _pdm_status("PDUvalidate_access", status);

        if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
          break;
          }
      if (PDM_debug_on)
        {
         MEMprint_buffer("parametric attributes", PDU_parm_attr_bufr,
                          PDU_DEBUG_FILE);
         MEMprint_buffer("parametric data", delete_bufr,
                          PDU_DEBUG_FILE);
         }
        /* load PDMexec structure */
        PDUload_exec_structure("", refresh->rev_catalog, "", "", "","","",0, 0);
        PDUmessage(PDS_M_DELETE_PART, 's');
        status = PDMdelete_parametric_parts(PDU_parm_attr_bufr, 
                                            delete_bufr, "P", 
                                            &status_bufr);
        _pdm_status("PDMdelete_parametric_parts", status);
        delete_flag = TRUE;
         if (status != PDM_S_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_E_CHANGE_UNSUCCESSFUL);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           }
         else
           {
           FIfld_get_num_rows(fp, ATTR_DATA_MCF, &num_rows);
           _pdm_debug("num_rows = %d", (char *)num_rows);
           for ( i = 0; i < num_rows; i++)
             {
             FIfld_get_select(fp, ATTR_DATA_MCF, i, 0, &sel_flag);
             if (sel_flag == TRUE)
               FIfld_delete_rows(fp, ATTR_DATA_MCF,i,1);
             }
          }

         PDUmessage_trans(status, 's');
         PDUmessage(status, 's');
         PDUmessage(PDM_E_CLEAR_FIELD, 'c');
         if (PDU_parm_attr_bufr)
           {
           MEMclose(&PDU_parm_attr_bufr);
           PDU_parm_attr_bufr = NULL;
           }
         if (PDU_parm_data_bufr)
           {
           MEMclose(&PDU_parm_data_bufr);
           PDU_parm_data_bufr = NULL;
           }
         FIg_reset(fp, ATTR_NAME_MCF);
         FIg_reset(fp, ATTR_DATA_MCF);
         FIg_disable(fp, ATTR_NAME_MCF);
         FIg_disable(fp, ATTR_DATA_MCF);

         /*if ((status_bufr != NULL) && (status_bufr->rows > 0))
           PDUdisplay_where_used(status_bufr);*/

         FIg_disable(fp, MOVE_NEXT_STATE);
         FIg_disable(fp, CHANGE_PART);
         FIg_disable(fp, DELETE_PART);

         break;

    case ADD_ROW_DEF:     /* Member of group GROUP11  */
                             /* Sequenced to    */
         status = PDUadd_row_with_defaults();
         if (status != PDM_S_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_E_RETRIEVE_DEFAULT_DATA);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           }
         FIg_enable(forms.parametric_parts_form_id, ATTR_NAME_MCF);
         FIg_enable(forms.parametric_parts_form_id, ATTR_DATA_MCF);
         FIg_enable(fp, ADD_PART);
         break;

    case COPY_ROW:     /* Member of group GROUP11  */
                             /* Sequenced to    */

         /* copy selected row */
         FIfld_get_num_rows(fp, ATTR_DATA_MCF, &num_rows);
         selected_rows = -1;
         _pdm_debug("num_rows = %d", (char *)num_rows);
         for ( i = 0; i < num_rows; i++)
           {
           FIfld_get_select(fp, ATTR_DATA_MCF, i, 0, &sel_flag);
           if (sel_flag == TRUE)
             {
             selected_rows = i;
             break;
             }
          }
          _pdm_debug("selected row = %d", (char *)selected_rows);

          if (selected_rows == -1)
            {
            msg = (char *)PDUtranslate_message(PDM_I_SEL_ROW_TO_COPY);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }

         /*if (num_rows != 0)
          num_rows = num_rows - 1;*/

         FIfld_set_max_num_rows(fp, ATTR_DATA_MCF, (num_rows + 1));
         FIfld_set_num_rows(fp, ATTR_DATA_MCF, (num_rows + 1));
         FImcf_get_num_cols(fp, ATTR_DATA_MCF, &num_cols);
         FIfld_set_active_row(fp, ATTR_DATA_MCF, selected_rows, selected_rows);
         for (i = 1; i < num_cols; i++)
          {
          FImcf_set_active_col(fp, ATTR_DATA_MCF, i, 0);
          FIfld_get_text_length(fp,ATTR_DATA_MCF,selected_rows,i,&length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, (length + 1));
          FIfld_get_text(fp,ATTR_DATA_MCF,selected_rows,i,length,
                         (unsigned char*)text,&select,&pos);

          FIfld_set_text(fp, ATTR_DATA_MCF, num_rows, i, text, FALSE);
          }
        
         FImcf_set_active_col(fp, ATTR_DATA_MCF, 0, 0);
         FIfld_set_select(fp, ATTR_DATA_MCF, selected_rows, 0, FALSE);

         break;

    case ADD_ROWS_FR_SEARCH:     /* Member of group GROUP11  */
                             /* Sequenced to    */

         if ((delete_flag) && (refresh->rev_catalog) && 
             (strcmp(refresh->rev_catalog, "") != 0))
           {
           PDUfill_in_string(&refresh->rev_catalog, NULL);
           delete_flag = FALSE;
           }

         FIf_erase(fp);
         refresh->status = PDM_S_SUCCESS;
         SelectOrPlacePart(TRUE, TRUE, fp);
         break;

    case CLEAR_ROW:     /* Member of group GROUP11  */
                             /* Sequenced to    */

         /* clear row */
         FIfld_get_num_rows(fp, ATTR_DATA_MCF, &num_rows);
         selected_rows = -1;
         _pdm_debug("num_rows = %d", (char *)num_rows);
         for ( i = 0; i < num_rows; i++)
           {
           FIfld_get_select(fp, ATTR_DATA_MCF, i, 0, &sel_flag);
           if (sel_flag == TRUE)
             {
             selected_rows = i;
             break;
             }
          }
          _pdm_debug("selected row = %d", (char *)selected_rows);

          if (selected_rows == -1)
            {
            msg = (char *)PDUtranslate_message(PDM_I_SEL_ROW_TO_CLEAR);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }

         num_rows = num_rows - 1;
         FIfld_delete_rows(fp, ATTR_DATA_MCF, selected_rows, 1);
         FIfld_get_max_num_rows(fp, ATTR_DATA_MCF, &num_rows);
         FIfld_set_max_num_rows(fp, ATTR_DATA_MCF, (num_rows - 1));
         FIfld_set_num_rows(fp, ATTR_DATA_MCF, (num_rows - 1));

         break;

    case VALUE_ASSOC_GADGET:

         list_row = value - 1;
         FIfld_get_num_rows(fp, ATTR_DATA_MCF, &num_rows);
         _pdm_debug("num_rows = %d", (char *)num_rows);
         if (num_rows != 0)
           num_rows = num_rows - 1;
         selected_rows = -1;
         for ( i = 0; i < num_rows; i++)
           {
           FIfld_get_select(fp, ATTR_DATA_MCF, i, 0, &sel_flag);
           if (sel_flag == TRUE)
             {
             selected_rows = i;
             break;
             }
          }
         FIfld_get_active_row(fp, ATTR_DATA_MCF, &act_row, &pos);
          _pdm_debug("selected row = %d", (char *)selected_rows);
          if (selected_rows == num_rows)
            selected_rows = -1;
          else if ((selected_rows == -1) && (act_row != -1))
            selected_rows = act_row;

          /* get selected attribute name */
          FIfld_get_text_length(fp,ATTR_NAME_MCF,0,act_col,&length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, (length + 1));
          FIfld_get_text(fp,ATTR_NAME_MCF,0,act_col,length,
                         (unsigned char*)text,&select,&pos);

          PDUfill_in_string(&temp,text);
          /* strip off '*' */
          temp = temp + 1;
          _pdm_debug("temp = <%s>", temp);
          status = MEMbuild_array(PDU_parm_attr_bufr);
          _pdm_status("MEMbuild_array", status);
 
          if (status != MEM_S_SUCCESS)
            break;
          
          attr_row = PDUfind_attr_by_synonym(temp, PDU_parm_attr_bufr);
          _pdm_debug("attr_row = <%d>", (char *)attr_row);
          if (attr_row != -1)
            {
            attr_data = (char **)PDU_parm_attr_bufr->data_ptr;
            PDUfill_in_string(&attr_name, 
                              attr_data[(PDU_parm_attr_bufr->columns * attr_row)
                              + PDU_NFM_ATTR_COL]);
            }
          else
            {
            PDUfill_in_string(&attr_name,temp);
            attr_row = PDUfind_attr_in_buffer(PDU_parm_attr_bufr, attr_name);
            }

          if (strcmp(attr_name, "n_aclno") != 0)
            {
            if (selected_rows == -1)
              FIfld_set_text(fp, ATTR_DATA_MCF, num_rows, act_col, 
                             PDU_value_list[list_row], FALSE);
            else
              FIfld_set_text(fp, ATTR_DATA_MCF, selected_rows, act_col, 
                           PDU_value_list[list_row], FALSE);
            }
          else
            {
          _pdm_debug("attr_name = <%s>", attr_name);
            attr_data = (char **)PDU_parm_attr_bufr->data_ptr;
            sscanf(attr_data[(PDU_parm_attr_bufr->columns * attr_row) + 
                   PDU_NFM_LISTNO_COL], "%d", &buffer_number);
            _pdm_debug("buffer_number = <%d>", (char *)buffer_number);
            status = MEMreset_buffer_no(PDU_parm_list_bufr,1);
            _pdm_status("MEMreset_buffer", status);
            MEMreset_buffer_no(PDU_parm_list_bufr, buffer_number);
            _pdm_status("MEMreset_buffer_no", status);
            list_data = (char **)PDU_parm_list_bufr->data_ptr;
            for (i = 0; i < PDU_parm_list_bufr->rows; i++)
              {
              if (strcmp(PDU_value_list[list_row], 
                 list_data[(PDU_parm_list_bufr->columns * i) + 2]) == 0) 
                {
                _pdm_debug("Setting text", 0);
                if (selected_rows == -1)
                  FIfld_set_text(fp, ATTR_DATA_MCF, num_rows, act_col, 
                               list_data[(PDU_parm_list_bufr->columns * i) + 0],
                               FALSE);
                else
                  FIfld_set_text(fp, ATTR_DATA_MCF, selected_rows, act_col, 
                               list_data[(PDU_parm_list_bufr->columns * i) + 0],
                               FALSE);
                break;
                }
              }
            }

          break;

    case CLASS_ASSOC_GADGET:

         list_row = value - 1;
         /* find level in global classification */
         status = PDUcheck_if_catalog(PDU_value_list[list_row]);
         _pdm_status("PDUcheck_if_catalog", status);

         if (status == PDM_S_SUCCESS)
           {
           _pdm_debug("text_selected = catalog", 0);
           FIfld_set_text(fp, CATALOG_NAME,0,0,PDU_value_list[list_row],
                          FALSE);
           PDUfill_in_string(&refresh->rev_catalog,PDU_value_list[list_row]);
           if (PDU_class_level == 0)
             {
             FIg_set_state_off(fp, LEVEL1_BTN);
             FIg_display(fp, LEVEL1_BTN);
             FIg_erase(fp, LEVEL2_BTN);
             FIg_erase(fp, LEVEL3_BTN);
             FIg_erase(fp, LEVEL4_BTN);
             FIg_erase(fp, LEVEL5_BTN);
             FIg_erase(fp, LEVEL6_BTN);
             FIg_erase(fp, LEVEL7_BTN);
             }
           else if (PDU_class_level == 1)
             {
             FIg_set_state_off(fp, LEVEL2_BTN);
             FIg_display(fp, LEVEL2_BTN);
             FIg_erase(fp, LEVEL3_BTN);
             FIg_erase(fp, LEVEL4_BTN);
             FIg_erase(fp, LEVEL5_BTN);
             FIg_erase(fp, LEVEL6_BTN);
             FIg_erase(fp, LEVEL7_BTN);
             }
           else if (PDU_class_level == 2)
             {
             FIg_set_state_off(fp, LEVEL3_BTN);
             FIg_display(fp, LEVEL3_BTN);
             FIg_erase(fp, LEVEL4_BTN);
             FIg_erase(fp, LEVEL5_BTN);
             FIg_erase(fp, LEVEL6_BTN);
             FIg_erase(fp, LEVEL7_BTN);
             }
           else if (PDU_class_level == 3)
             {
             FIg_set_state_off(fp, LEVEL4_BTN);
             FIg_display(fp, LEVEL4_BTN);
             FIg_erase(fp, LEVEL5_BTN);
             FIg_erase(fp, LEVEL6_BTN);
             FIg_erase(fp, LEVEL7_BTN);
             }
           else if (PDU_class_level == 4)
             {
             FIg_set_state_off(fp, LEVEL5_BTN);
             FIg_display(fp, LEVEL5_BTN);
             FIg_erase(fp, LEVEL6_BTN);
             FIg_erase(fp, LEVEL7_BTN);
             }
           else if (PDU_class_level == 5)
             {
             FIg_set_state_off(fp, LEVEL6_BTN);
             FIg_display(fp, LEVEL6_BTN);
             FIg_erase(fp, LEVEL7_BTN);
             }
           else if (PDU_class_level == 6)
             {
             FIg_set_state_off(fp, LEVEL7_BTN);
             FIg_display(fp, LEVEL7_BTN);
             }
           status = PDUget_parametric_part_attributes();
           _pdm_status("PDUget_parametric_part_attributes", status);
          FImcf_get_num_cols(fp, ATTR_NAME_MCF, &num_cols);
          for (i = 0; i < num_cols; i ++)
          FIfld_set_mode(forms.parametric_parts_form_id, ATTR_NAME_MCF, i, 
                         FI_SINGLE_SELECT);
           }
         else
           {
           _pdm_debug("text_selected = classification", 0);
           if (PDU_class_level == 0)
             {
             FIg_set_state_off(fp, LEVEL1_BTN);
             FIg_display(fp, LEVEL1_BTN);
             FIg_display(fp, LEVEL2_BTN);
             FIg_erase(fp, LEVEL3_BTN);
             FIg_erase(fp, LEVEL4_BTN);
             FIg_erase(fp, LEVEL5_BTN);
             FIg_erase(fp, LEVEL6_BTN);
             FIg_erase(fp, LEVEL7_BTN);
             }
           else if (PDU_class_level == 1)
             {
             FIg_set_state_off(fp, LEVEL2_BTN);
             FIg_display(fp, LEVEL2_BTN);
             FIg_display(fp, LEVEL3_BTN);
             FIg_erase(fp, LEVEL4_BTN);
             FIg_erase(fp, LEVEL5_BTN);
             FIg_erase(fp, LEVEL6_BTN);
             FIg_erase(fp, LEVEL7_BTN);
             }
           else if (PDU_class_level == 2)
             {
             FIg_set_state_off(fp, LEVEL3_BTN);
             FIg_display(fp, LEVEL3_BTN);
             FIg_display(fp, LEVEL4_BTN);
             FIg_erase(fp, LEVEL5_BTN);
             FIg_erase(fp, LEVEL6_BTN);
             FIg_erase(fp, LEVEL7_BTN);
             }
           else if (PDU_class_level == 3)
             {
             FIg_set_state_off(fp, LEVEL4_BTN);
             FIg_display(fp, LEVEL4_BTN);
             FIg_display(fp, LEVEL5_BTN);
             FIg_erase(fp, LEVEL6_BTN);
             FIg_erase(fp, LEVEL7_BTN);
             }
           else if (PDU_class_level == 4)
             {
             FIg_set_state_off(fp, LEVEL5_BTN);
             FIg_display(fp, LEVEL5_BTN);
             FIg_display(fp, LEVEL6_BTN);
             FIg_erase(fp, LEVEL7_BTN);
             }
           else if (PDU_class_level == 5)
             {
             FIg_set_state_off(fp, LEVEL6_BTN);
             FIg_display(fp, LEVEL6_BTN);
             FIg_display(fp, LEVEL7_BTN);
             }
           /* add row to buffer */
           if (PDU_class_level == 0)
             {
             if (PDU_query_class_bufr);
               {
               MEMclose(&PDU_query_class_bufr);
               PDU_query_class_bufr = NULL;
               }
             status = PDUformat_classification_buffer(&PDU_query_class_bufr);
             _pdm_status("PDUformat_classification_buffer", status);

            if (status != PDM_S_SUCCESS)
              {
              msg = (char *)PDUtranslate_message(PDM_E_PROCCESS_CLASS_LEVELS);
              FIg_set_text(fp, FI_MSG_FIELD, msg);
              break;
              }
            PDU_class_level = PDU_class_level + 1;
            }
            if (PDU_class_level > PDU_query_class_bufr->rows)
            {
            string = (char *)malloc(PDU_query_class_bufr->row_size);
            memset(string, NULL, PDU_query_class_bufr->row_size);
            sprintf(string, "%d\1%s\1", PDU_class_level, 
                    PDU_value_list[list_row]);
            _pdm_debug("string = <%s>", string);
            status = MEMwrite(PDU_query_class_bufr, string);
            _pdm_status("MEMwrite_status", status);

            if (status != MEM_S_SUCCESS)
              {
              msg = (char *)PDUtranslate_message(PDM_E_PROCCESS_CLASS_LEVELS);
              FIg_set_text(fp, FI_MSG_FIELD, msg);
              break;
              } 
           }
           FIg_display(fp, ATTR_DATA_MCF);
           PDUprocess_class_pulldown();
           }
           
         break;
  } /* END switch ( g_label ) */
  return(1);
} /* END notification_routine() */

int parametric_part_form(prev_cat_name)
char *prev_cat_name;
{
  int  status;
  int  list_size;
  int  num_cols;
  int  i;

  status = FIf_new(PARAMETRIC_PARTS_FORM, "MOAddRec",
                parm_part_notification_routine,
                &forms.parametric_parts_form_id);

  _pdm_debug("Creating Catalog Name Form", 0);

  PDU_new_param_mode = TRUE;
  PDU_change_param_mode = FALSE;
  PDU_perm_window = FALSE;

  FIg_disable(forms.parametric_parts_form_id, CHANGE_PART);
  FIg_disable(forms.parametric_parts_form_id, DELETE_PART);
  FIg_disable(forms.parametric_parts_form_id, MOVE_NEXT_STATE);

  if (PDU_parm_attr_bufr)
    {
    MEMclose(&PDU_parm_attr_bufr);
    PDU_parm_attr_bufr = NULL;
    }
  if (PDU_parm_data_bufr)
    {
    MEMclose(&PDU_parm_data_bufr);
    PDU_parm_data_bufr = NULL;
    }

  /* ALR 1/4/94  TR 139308899  Transfered here */
  if (strcmp(prev_cat_name,NULL_STRING) != 0)
   {
        _pdm_debug("Transfered here with a catalog |%s| \n",prev_cat_name);
        FIg_set_text(forms.parametric_parts_form_id, CATALOG_NAME, prev_cat_name);
        PDUfill_in_string(&refresh->rev_catalog, prev_cat_name);
        PDUget_parametric_part_attributes();
        FIg_erase(forms.parametric_parts_form_id, CLASS_ASSOC_GADGET);
        FIg_erase(forms.parametric_parts_form_id, VALUE_ASSOC_GADGET);
   }
  else
   {
    refresh->rev_partid = NULL;
    refresh->rev_revision = NULL;
    refresh->rev_catalog = NULL;
    FIg_disable(forms.parametric_parts_form_id, ADD_PART);
    FIg_disable(forms.parametric_parts_form_id, ADD_ROW_DEF);
    FIg_disable(forms.parametric_parts_form_id, COPY_ROW);
    FIg_disable(forms.parametric_parts_form_id, CLEAR_ROW);
   }
  FIg_disable(forms.parametric_parts_form_id, ATTR_DATA_MCF);
  FIg_disable(forms.parametric_parts_form_id, ATTR_NAME_MCF);
  FIg_erase(forms.parametric_parts_form_id, ATTR_DATA_MCF);

  if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
    {
    PDUfill_in_string(&PDU_store_catalog, refresh->rev_catalog);
    PDUfill_in_string(&refresh->rev_catalog, NULL);
    }
  FImcf_get_num_cols(forms.parametric_parts_form_id, ATTR_NAME_MCF, &num_cols);
  for (i = 0; i < num_cols; i ++)
    FIfld_set_mode(forms.parametric_parts_form_id, ATTR_NAME_MCF, i, 
                   FI_SINGLE_SELECT);

  FIfld_set_mode(forms.parametric_parts_form_id, CATALOG_DESC, 0, FI_REVIEW);

  /* create a pulldown for lists */
  list_size = 0;
  _pdm_debug("Creating GRpulldown", 0);
  GRcreate_pull_down_list(PARAMETRIC_PARTS_FORM, forms.parametric_parts_form_id,
                          VALUE_ASSOC_GADGET, MAX_ROWS, VIS_ROWS, 
                          PDU_value_list, list_size, 1, &PDU_value_pulldown);
  GRcreate_pull_down_list(PARAMETRIC_PARTS_FORM, 
                          forms.parametric_parts_form_id,
                          CLASS_ASSOC_GADGET, MAX_ROWS, VIS_ROWS, 
                          PDU_value_list, list_size, 1, &PDU_catalog_pulldown);
  _pdm_debug("After creating GRpulldown", 0);
  FImcf_set_scroll_link(forms.parametric_parts_form_id, ATTR_DATA_MCF, 
                        ATTR_NAME_MCF);

  FIg_disable(forms.parametric_parts_form_id, ADD_ROWS_FR_SEARCH);
  FIg_erase(forms.parametric_parts_form_id, LEVEL2_BTN);
  FIg_erase(forms.parametric_parts_form_id, LEVEL3_BTN);
  FIg_erase(forms.parametric_parts_form_id, LEVEL4_BTN);
  FIg_erase(forms.parametric_parts_form_id, LEVEL5_BTN);
  FIg_erase(forms.parametric_parts_form_id, LEVEL6_BTN);
  FIg_erase(forms.parametric_parts_form_id, LEVEL7_BTN);
  status = FIf_display(forms.parametric_parts_form_id);

  FIg_display(forms.parametric_parts_form_id, ATTR_DATA_MCF);
  FIg_display(forms.parametric_parts_form_id, ATTR_NAME_MCF);
  FIg_erase(forms.parametric_parts_form_id, CLASS_ASSOC_GADGET);
  FIg_erase(forms.parametric_parts_form_id, VALUE_ASSOC_GADGET);
  return(status);

}

int PDUparametric_part_form(prev_cat_name)
char *prev_cat_name;

{
  int status;

  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  status = parametric_part_form(prev_cat_name);
  _pdm_status("parametric_part_form", status);

  if (status == FI_SUCCESS)
    status = PDM_S_SUCCESS;

  return(status);
 }

int PDUload_data_into_mcf(attr_bufr, data_bufr, list_bufr)

MEMptr attr_bufr;
MEMptr data_bufr;
MEMptr list_bufr;
  {
  int status;
  int i,j;
  int num_rows = 0;
  int num_cols = 0;
  int check_col;
  long attribute;
  int buffer_number;
  char *string = NULL;
  char *function = NULL;
  char **attr_data = NULL;
  char **data_data = NULL;
  char **list_data = NULL;
  char **list_values = NULL;

  _pdm_debug("In PDUload_data_into_mcf", 0);
  
  status = MEMbuild_array(attr_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  attr_data = (char **)attr_bufr->data_ptr;

  if (data_bufr != NULL) 
    {
    status = MEMbuild_array(data_bufr);
    _pdm_status("MEMbuild_array", status);

    if (status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);

    data_data = (char **)data_bufr->data_ptr;
    }

  if (PDU_new_param_mode)
    {
    _pdm_debug("user wants to add parts", 0);
    check_col = PDU_NFM_WRITE_COL;
    }
  else
    {
    _pdm_debug("user wants to delete parts", 0);
    check_col = PDU_NFM_UPDATE_COL;
    }

  for (i = 0; i < attr_bufr->rows; i ++)
    {
    if (strcmp(attr_data[(attr_bufr->columns * i) + check_col], "Y") 
        == 0) 
      num_rows = num_rows + 1;
    }

  _pdm_debug("num_rows =  %d", (char *)num_rows);
  /* add extra row for col to select */
  num_rows = num_rows + 1;
  if (check_col == PDU_NFM_UPDATE_COL)
    num_rows = num_rows + 2;
  FImcf_get_num_cols(forms.parametric_parts_form_id, ATTR_DATA_MCF, &num_cols);
  _pdm_debug("Number of columns = %d", (char *)num_cols);
  if (num_rows < num_cols)
    {
    for (i = (num_rows - 1); i < num_cols; i++)
      {
      _pdm_debug("deleting columns <%d>", (char *)i);
      FImcf_delete_col(forms.parametric_parts_form_id, ATTR_DATA_MCF, num_rows);
      FImcf_delete_col(forms.parametric_parts_form_id, ATTR_NAME_MCF, num_rows);
      }
    }
      
  FImcf_get_num_cols(forms.parametric_parts_form_id, ATTR_DATA_MCF, &num_cols);
  _pdm_debug("Number of columns = %d", (char *)num_cols);
  for (i = num_cols; i < num_rows; i++)
    {
    _pdm_debug("i = %d",(char *) i);
    FImcf_insert_col(forms.parametric_parts_form_id, ATTR_NAME_MCF, i, 10,
                     FI_REVIEW, FI_ALPHA);
 
    FIfld_get_attr(forms.parametric_parts_form_id, ATTR_NAME_MCF, i, &attribute);
   
    attribute = attribute | FI_DISPLAY_HSCROLL;

    FIfld_set_attr(forms.parametric_parts_form_id, ATTR_NAME_MCF, i, attribute);

    FImcf_insert_col(forms.parametric_parts_form_id, ATTR_DATA_MCF, i, 10,
                     FI_INSERT, FI_ALPHA);

    /*FIfld_get_attr(forms.parametric_parts_form_id, ATTR_DATA_MCF, i, &attribute);
   
    attribute = attribute | FI_DISPLAY_HSCROLL;

    FIfld_set_attr(forms.parametric_parts_form_id, ATTR_DATA_MCF, i, attribute);
    */

    FIfld_get_attr(forms.parametric_parts_form_id, ATTR_DATA_MCF, i, &attribute);
    attribute = attribute | FI_NOTIFY_BY_LINE;

    FIfld_set_attr(forms.parametric_parts_form_id, ATTR_DATA_MCF, i, attribute);
    }

  num_rows = 1;

  FIfld_set_max_num_rows(forms.parametric_parts_form_id, ATTR_DATA_MCF,0);
  for (i = 0; i < attr_bufr->rows; i ++)
    {
    if ((strcmp(attr_data[(attr_bufr->columns * i) + check_col], "Y") 
        == 0) || (strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
        PDU_PARTID_ATTR) == 0) || (strcmp(attr_data[(attr_bufr->columns * i) + 
       PDU_NFM_ATTR_COL], PDU_REVISION_ATTR) == 0))
    {
    _pdm_debug("Display on MCF", 0);
    if (((strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_LISTNO_COL], "0") 
       == 0) || (strcmp(attr_data[(attr_bufr->columns * i) + 
       PDU_NFM_LISTNO_COL], "-1") == 0)) && (PDU_func_buffer))
      {
      _pdm_debug("No List assosciated with attribute", 0);
      status = PDUcheck_for_function(attr_data[(attr_bufr->columns * i) + 
                                     PDU_NFM_ATTR_COL], &function,
                                     PDU_func_buffer);
      _pdm_status("PDUcheck_for_function", status);
      if (status != PDM_S_SUCCESS)
      {
      _pdm_debug("No function assosciated with attribute", 0);
      if ((attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL]) && 
          (strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL], "") 
          != 0))
        {
        _pdm_debug("text = <%s>", attr_data[(attr_bufr->columns * i) + 
                                            PDU_NFM_SYN_COL]);
        FIfld_set_text(forms.parametric_parts_form_id, ATTR_NAME_MCF, 0,  
                     num_rows, 
                     attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL],
                     FALSE);
        }
      else
        {
        _pdm_debug("text = <%s>", attr_data[(attr_bufr->columns * i) + 
                                  PDU_NFM_ATTR_COL]);
        FIfld_set_text(forms.parametric_parts_form_id, ATTR_NAME_MCF, 0,  
                       num_rows, 
                       attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
                       FALSE);
        }
       }
       else
       {
       _pdm_debug("Function assosciated with attribute", 0);
        string = (char *)malloc(attr_bufr->row_size);
        memset(string, NULL, attr_bufr->row_size);
         if ((strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL], "")
             != 0) && (attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL]))
           {
           sprintf(string, "*%s", attr_data[(attr_bufr->columns * i) + 
                   PDU_NFM_SYN_COL]);
           _pdm_debug("string = <%s>", string);
           FIfld_set_text(forms.parametric_parts_form_id, ATTR_NAME_MCF, 0,  
                          num_rows, string, FALSE);
            }
          else
           {
           sprintf(string, "*%s", attr_data[(attr_bufr->columns * i) + 
                   PDU_NFM_ATTR_COL]);
           _pdm_debug("string = <%s>", string);
           FIfld_set_text(forms.parametric_parts_form_id, ATTR_NAME_MCF, 0,  
                          num_rows, string, FALSE);
            }
          if (string)
            free(string);
         }
      }
    else if ((strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_LISTNO_COL], "0") 
       == 0) || (strcmp(attr_data[(attr_bufr->columns * i) + 
       PDU_NFM_LISTNO_COL], "-1") == 0))
      {
      _pdm_debug("No List assosciated with attribute", 0);
      if ((attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL]) && 
          (strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL], "") 
          != 0))
        {
        _pdm_debug("text = <%s>", attr_data[(attr_bufr->columns * i) + 
                                            PDU_NFM_SYN_COL]);
        FIfld_set_text(forms.parametric_parts_form_id, ATTR_NAME_MCF, 0,  
                     num_rows, 
                     attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL],
                     FALSE);
        }
      else
        {
        _pdm_debug("text = <%s>", attr_data[(attr_bufr->columns * i) + 
                                  PDU_NFM_ATTR_COL]);
        FIfld_set_text(forms.parametric_parts_form_id, ATTR_NAME_MCF, 0,  
                       num_rows, 
                       attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
                       FALSE);
        }
      }
    else
      {
      _pdm_debug("buffer assosciated with attribute", 0);
      _pdm_debug("attribute = <%s>", attr_data[(attr_bufr->columns * i ) + 
                  PDU_NFM_ATTR_COL]);
      sscanf(attr_data[(attr_bufr->columns * i) + PDU_NFM_LISTNO_COL], "%d", 
             &buffer_number);
      status = MEMreset_buffer_no(list_bufr, buffer_number);
      _pdm_status("MEMreset_bufr_no", status);

      if (status != MEM_S_SUCCESS)
        return(PDM_E_RESET_BUFFER);

      list_data = (char **)list_bufr->column_ptr;

      _pdm_debug("list_data[0] = <%s>", list_data[0]);
      if (strcmp(list_data[0], "n_value") == 0)
        {
        string = (char *)malloc(attr_bufr->row_size);
        memset(string, NULL, attr_bufr->row_size);
         if ((strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL], "")
             != 0) && (attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL]))
           {
           sprintf(string, "*%s", attr_data[(attr_bufr->columns * i) + 
                   PDU_NFM_SYN_COL]);
           _pdm_debug("string = <%s>", string);
           FIfld_set_text(forms.parametric_parts_form_id, ATTR_NAME_MCF, 0,  
                          num_rows, string, FALSE);
            }
          else
           {
           sprintf(string, "*%s", attr_data[(attr_bufr->columns * i) + 
                   PDU_NFM_ATTR_COL]);
           _pdm_debug("string = <%s>", string);
           FIfld_set_text(forms.parametric_parts_form_id, ATTR_NAME_MCF, 0,  
                          num_rows, string, FALSE);
            }
          if (string)
            free(string);
         }
      else if ((strcmp(list_data[0], "n_input") == 0) &&
               (strcmp(list_data[1], "n_minvalue") == 0))
        {
        string = (char *)malloc(attr_bufr->row_size);
        memset(string, NULL, attr_bufr->row_size);
        list_values = (char **)list_bufr->data_ptr;
         if ((strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL], "")
             != 0) && (attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL]))
           {
            sprintf(string, "%s (min: %s max: %s)", 
                    attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL],
                    list_values[1], list_values[2]);
           _pdm_debug("string = <%s>", string);
           FIfld_set_text(forms.parametric_parts_form_id, ATTR_NAME_MCF, 0,  
                          num_rows, string, FALSE);
            }
          else
           {
           sprintf(string, "%s (min: %s max: %s)", 
                    attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
                    list_values[1], list_values[2]);
           _pdm_debug("string = <%s>", string);
           FIfld_set_text(forms.parametric_parts_form_id, ATTR_NAME_MCF, 0,  
                          num_rows, string, FALSE);
            }
          if (string)
            free(string);
         }
      else if (strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
               "n_aclno") == 0)
        {
        string = (char *)malloc(attr_bufr->row_size);
        memset(string, NULL, attr_bufr->row_size);
         if ((strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL], "")
             != 0) && (attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL]))
           {
           sprintf(string, "*%s", attr_data[(attr_bufr->columns * i) + 
                   PDU_NFM_SYN_COL]);
           _pdm_debug("string = <%s>", string);
           FIfld_set_text(forms.parametric_parts_form_id, ATTR_NAME_MCF, 0,  
                          num_rows, string, FALSE);
            }
          else
           {
           sprintf(string, "*%s", attr_data[(attr_bufr->columns * i) + 
                   PDU_NFM_ATTR_COL]);
           _pdm_debug("string = <%s>", string);
           FIfld_set_text(forms.parametric_parts_form_id, ATTR_NAME_MCF, 0,  
                          num_rows, string, FALSE);
            }
          if (string)
            free(string);
         }
       else
         {
         if ((strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_SYN_COL], "")
             != 0) && (attr_data[(attr_bufr->columns * i ) + PDU_NFM_SYN_COL]))
           FIfld_set_text(forms.parametric_parts_form_id, ATTR_NAME_MCF, 0,  
                          num_rows, attr_data[(attr_bufr->columns * i) 
                          + PDU_NFM_SYN_COL], FALSE);
         else
           FIfld_set_text(forms.parametric_parts_form_id, ATTR_NAME_MCF, 0,  
                          num_rows, attr_data[(attr_bufr->columns * i) 
                          + PDU_NFM_ATTR_COL], FALSE);
         }
      }
      if (PDU_change_param_mode)
        {
        _pdm_debug("setting data", 0);
        for (j = 0; j < data_bufr->rows; j++)
          {
          _pdm_debug("text = <%s>", data_data[(data_bufr->columns * j) + i]);
          if ((data_data[(data_bufr->columns * j) + i]) && 
              (strcmp(data_data[(data_bufr->columns * j) + i], "") != 0))
            {
            _pdm_debug("setting default values", 0);
      status = FIfld_set_text(forms.parametric_parts_form_id, ATTR_DATA_MCF, j, 
                           num_rows,
                           data_data[(data_bufr->columns * j) + i], FALSE);
           _pdm_status("FIfld_set_text", status);
            }
          else
            {
            FIfld_set_text(forms.parametric_parts_form_id, ATTR_DATA_MCF, j,
                           num_rows,
                           "", FALSE);
            }
           }
        }
      if (((strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
         PDU_PARTID_ATTR) == 0) || (strcmp(attr_data[(attr_bufr->columns * i) + 
         PDU_NFM_ATTR_COL], PDU_REVISION_ATTR) == 0)) && (PDU_change_param_mode))
         {
         FIfld_set_mode(forms.parametric_parts_form_id, ATTR_DATA_MCF, num_rows,
                         FI_REVIEW);
         FIfld_set_mode(forms.parametric_parts_form_id, ATTR_NAME_MCF, num_rows,
                         FI_REVIEW);
         }
      else if ((strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
         PDU_PARTID_ATTR) == 0) || (strcmp(attr_data[(attr_bufr->columns * i) + 
         PDU_NFM_ATTR_COL], PDU_REVISION_ATTR) == 0))
         {
         FIfld_set_mode(forms.parametric_parts_form_id, ATTR_DATA_MCF, num_rows,
                         FI_INSERT);
         FIfld_set_mode(forms.parametric_parts_form_id, ATTR_NAME_MCF, num_rows,
                         FI_SINGLE_SELECT);
         }
         
      else if (strcmp(attr_data[(attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
         PDU_PARTTYPE_ATTR) == 0)
         {
         FIfld_set_mode(forms.parametric_parts_form_id, ATTR_DATA_MCF, num_rows,
                         FI_REVIEW);
         FIfld_set_mode(forms.parametric_parts_form_id, ATTR_NAME_MCF, num_rows,
                         FI_REVIEW);
         }
      else
         {
         FIfld_set_mode(forms.parametric_parts_form_id, ATTR_DATA_MCF, num_rows,
                         FI_INSERT);
         FIfld_set_mode(forms.parametric_parts_form_id, ATTR_NAME_MCF, num_rows,
                         FI_SINGLE_SELECT);
         }

      num_rows = num_rows + 1;
      }
    }

   if (PDU_change_param_mode)
     FIfld_set_max_num_rows(forms.parametric_parts_form_id, ATTR_DATA_MCF,
                            data_bufr->rows);
   else
     {
     FIfld_set_max_num_rows(forms.parametric_parts_form_id, ATTR_DATA_MCF, 1);
     /*FIfld_set_num_rows(forms.parametric_parts_form_id, ATTR_DATA_MCF, 1);*/
     }
   return(PDM_S_SUCCESS);
   }

int PDUload_parametric_part_bufr(def_data)

MEMptr def_data;
  {
  int length;
  int select;
  int pos;
  int status;
  int i,j;
  int num_cols;
  int num_rows;
  int blank_row;
  int char_index;
  int n_col;
  int input_req;
  char msg[256];
  char *row = NULL;
  char *text = NULL;
  char **attr_data = NULL;
  char **default_data = NULL;

  _pdm_debug("In PDUload_parametric_part_bufr", 0);

  FIfld_get_num_rows(forms.parametric_parts_form_id, ATTR_DATA_MCF, &num_rows);
  FImcf_get_num_cols(forms.parametric_parts_form_id, ATTR_DATA_MCF, &num_cols);

  _pdm_debug("num_cols = %d", (char *)num_cols);
  _pdm_debug("num_rows = %d", (char *)num_rows);

  status = MEMbuild_array(PDU_parm_attr_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  attr_data = (char **)PDU_parm_attr_bufr->data_ptr;

  status = MEMbuild_array(def_data);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  default_data = (char **)def_data->data_ptr;

  row = (char *)malloc(PDU_parm_data_bufr->row_size);
  if (PDU_new_param_mode)
    n_col = PDU_NFM_WRITE_COL;
  else
    n_col = PDU_NFM_UPDATE_COL;

  FImcf_get_num_cols(forms.parametric_parts_form_id, ATTR_DATA_MCF, &num_cols);
  _pdm_debug("num_cols = <%d>", (char *)num_cols);

  if (num_rows != 1)
  {
  FIfld_set_active_row(forms.parametric_parts_form_id, ATTR_DATA_MCF, 
                       (num_rows - 1), 0);
  blank_row = TRUE;
  for (i = 0; i < num_cols; i++)
    {
     FImcf_set_active_col(forms.parametric_parts_form_id, ATTR_DATA_MCF,
                          i,0);
     FIfld_get_text_length(forms.parametric_parts_form_id,ATTR_DATA_MCF,
                           (num_rows - 1),i, &length);
     text = (char *) malloc (sizeof (char) * length + 1);
     memset(text, NULL, (length + 1));
     FIfld_get_text(forms.parametric_parts_form_id,ATTR_DATA_MCF,
                    (num_rows - 1),i,length, (unsigned char*)text,
                    &select,&pos);

     if ((text) && (strcmp(text, "") != 0))
       {
       blank_row = FALSE;
       break;
       }
     }
  if (blank_row)
    num_rows = num_rows - 1;
  }

  for (i = 0; i < num_rows; i++)
    {
    char_index = 0;
    memset(row, NULL, PDU_parm_data_bufr->row_size);
    FIfld_set_active_row(forms.parametric_parts_form_id, ATTR_DATA_MCF, i, 0);
    num_cols = 1;
    for (j = 0; j < PDU_parm_attr_bufr->rows; j++)
      {
      if (strcmp(attr_data[(PDU_parm_attr_bufr->columns * j) + n_col], "Y") 
         == 0)
        {
        if ((strcmp(attr_data[(PDU_parm_attr_bufr->columns * j) + 
            PDU_NFM_REQ_COL], "N") == 0) || 
           (strcmp(attr_data[(PDU_parm_attr_bufr->columns * j) + 
            PDU_NFM_ATTR_COL], PDU_PARTID_ATTR) == 0) ||
           (strcmp(attr_data[(PDU_parm_attr_bufr->columns * j) + 
            PDU_NFM_ATTR_COL], PDU_REVISION_ATTR) == 0))
          input_req = TRUE;
        else
          input_req = FALSE;

        FImcf_set_active_col(forms.parametric_parts_form_id, ATTR_DATA_MCF,
                             num_cols,0);
        FIfld_get_text_length(forms.parametric_parts_form_id,ATTR_DATA_MCF,
                              i,num_cols, &length);
        text = (char *) malloc (sizeof (char) * length + 1);
        memset(text, NULL, (length + 1));
        FIfld_get_text(forms.parametric_parts_form_id,ATTR_DATA_MCF,i,
                       num_cols,length, (unsigned char*)text,&select,&pos);
        /* add text to row */
        if ((text) && (strcmp(text, "") != 0))
          PDUadd_buffer_string(row, &char_index, text);
        else if (!input_req)
          row[char_index++] = '\1';
        else
          {
          sprintf(msg, "The attribute <%s> is requried to have a value", 
                  attr_data[(PDU_parm_attr_bufr->columns * j) + 
                  PDU_NFM_SYN_COL]);
          FIg_set_text(forms.parametric_parts_form_id, FI_MSG_FIELD, msg);
        FImcf_set_active_col(forms.parametric_parts_form_id, ATTR_DATA_MCF,0,0);
          return(PDM_E_FAILURE);
          }
        num_cols = num_cols + 1;
        }
      else if ((default_data[j]) && (strcmp(default_data[j], "") != 0))
          PDUadd_buffer_string(row, &char_index, default_data[j]);
      else 
        row[char_index++] = '\1';
      }
      _pdm_debug(" row = <%s>", row);
    status = MEMwrite(PDU_parm_data_bufr, row);
    _pdm_status("MEMwrite", status);

    if (status != MEM_S_SUCCESS)
      {
      status = PDM_E_WRITE_BUFFER;
      break;
      }
    else
      status = PDM_S_SUCCESS;
    }

  if (row)
    free(row);

  FImcf_set_active_col(forms.parametric_parts_form_id, ATTR_DATA_MCF,0,0);
  return(status);
  }

int PDUload_mod_parametric_part_bufr()

  {
  int length;
  int select;
  int pos;
  int status;
  int i,j;
  int num_cols;
  int num_rows;
  int char_index;
  int n_col;
  int input_req;
  char msg[256];
  char *row = NULL;
  char *text = NULL;
  char **attr_data = NULL;

  _pdm_debug("In PDUload_mod_parametric_part_bufr", 0);

  FIfld_get_num_rows(forms.parametric_parts_form_id, ATTR_DATA_MCF, &num_rows);
  FImcf_get_num_cols(forms.parametric_parts_form_id, ATTR_DATA_MCF, &num_cols);

  _pdm_debug("num_cols = %d", (char *)num_cols);
  _pdm_debug("num_rows = %d", (char *)num_rows);

  status = MEMbuild_array(PDU_parm_attr_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  attr_data = (char **)PDU_parm_attr_bufr->data_ptr;

  row = (char *)malloc(PDU_parm_data_bufr->row_size);
  status = MEMbuild_array(PDU_parm_data_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  n_col = PDU_NFM_UPDATE_COL;

  for (i = 0; i < num_rows; i++)
    {
    char_index = 0;
    memset(row, NULL, PDU_parm_data_bufr->row_size);
    FIfld_set_active_row(forms.parametric_parts_form_id, ATTR_DATA_MCF, i, 0);
    num_cols = 1;
    for (j = 0; j < PDU_parm_attr_bufr->rows; j++)
      {
    if ((strcmp(attr_data[(PDU_parm_attr_bufr->columns * j) + PDU_NFM_ATTR_COL],
         PDU_PARTID_ATTR) == 0) ||
        (strcmp(attr_data[(PDU_parm_attr_bufr->columns * j) + PDU_NFM_ATTR_COL],
         PDU_REVISION_ATTR) == 0))
        num_cols = num_cols + 1;
    else if (strcmp(attr_data[(PDU_parm_attr_bufr->columns * j) + n_col], "Y") 
         == 0)
        {
        _pdm_debug("j = <%d>", (char *)j);
        if (strcmp(attr_data[(PDU_parm_attr_bufr->columns * j) + 
            PDU_NFM_REQ_COL], "N") == 0)
          input_req = TRUE;
        else
          input_req = FALSE;
        FImcf_set_active_col(forms.parametric_parts_form_id, ATTR_DATA_MCF,
                             num_cols,0);
        FIfld_get_text_length(forms.parametric_parts_form_id,ATTR_DATA_MCF,
                              i,num_cols, &length);
        text = (char *) malloc (sizeof (char) * length + 1);
        memset(text, NULL, (length + 1));
        FIfld_get_text(forms.parametric_parts_form_id,ATTR_DATA_MCF,i,
                       num_cols,length, (unsigned char*)text,&select,&pos);

        if (((text == NULL) || (strcmp(text, "") == 0)) && (input_req))
          {
          sprintf(msg, "The attribute <%s> is requried to have a value", 
                  attr_data[(PDU_parm_attr_bufr->columns * j) + 
                  PDU_NFM_SYN_COL]);
          FIg_set_text(forms.parametric_parts_form_id, FI_MSG_FIELD, msg);
        FImcf_set_active_col(forms.parametric_parts_form_id, ATTR_DATA_MCF,0,0);
          return(PDM_E_FAILURE);
          }
        status = MEMwrite_data(PDU_parm_data_bufr, text, (i+1), (j + 1));
        _pdm_status("MEMwrite", status);

        if (status != MEM_S_SUCCESS)
          {
          status = PDM_E_WRITE_BUFFER;
          break;
          }
        else
          status = PDM_S_SUCCESS;
        num_cols = num_cols + 1;
       }
     }
   }
  FImcf_set_active_col(forms.parametric_parts_form_id, ATTR_DATA_MCF,0,0);
  return(status);
  }

int PDUload_deleted_parts(del_bufr)
MEMptr *del_bufr;

  {
  int status;
  int i,j;
  int num_rows;
  int char_index;
  int sel_flag;
  char *row = NULL;
  char **data_data = NULL;

  _pdm_debug("In PDUload_mod_parametric_part_bufr", 0);

  /* format new bufr */
  status = PDUupdate_parm_data_buffer(del_bufr, PDU_parm_attr_bufr);
  _pdm_status("PDUupdate_parm_data_bufr", status);

  if (status != PDM_S_SUCCESS)
    return(status);
  
  FIfld_get_num_rows(forms.parametric_parts_form_id, ATTR_DATA_MCF, &num_rows);

  _pdm_debug("num_rows = %d", (char *)num_rows);

  row = (char *)malloc(PDU_parm_data_bufr->row_size);
  status = MEMbuild_array(PDU_parm_data_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  data_data = (char **)PDU_parm_data_bufr->data_ptr;
  for (i = 0; i < num_rows; i++)
    {
   FIfld_get_select(forms.parametric_parts_form_id,ATTR_DATA_MCF,i,0,&sel_flag);
    if (sel_flag)
      {
      /* load coreesponding data from data bufr into delete bufr */
      char_index = 0;
      memset(row, NULL, PDU_parm_data_bufr->row_size);
      for (j = 0; j < PDU_parm_data_bufr->columns; j++)
       {
       if ((data_data[(PDU_parm_data_bufr->columns * i) + j])  && 
           (strcmp(data_data[(PDU_parm_data_bufr->columns * i) + j], "") != 0))
         PDUadd_buffer_string(row,&char_index,
                              data_data[(PDU_parm_data_bufr->columns * i) + j]);
       else
         row[char_index++] = '\1';
       }
      _pdm_debug("row = <%s>", row);
      status = MEMwrite(*del_bufr, row);
      _pdm_status("MEMwrite", status);
      if (status != MEM_S_SUCCESS)
        return(PDM_E_WRITE_BUFFER);
     }
   }
  return(PDM_S_SUCCESS);
  }

int PDUadd_row_with_defaults()

  {
  int status;
  int i;
  int num_rows;
  int num_cols;
  int check_col;
  char **data_data = NULL;
  char **attr_data = NULL;

  _pdm_debug("In PDUadd_row_with_defaults", 0);

  /* add row of default values */
  FIfld_get_num_rows(forms.parametric_parts_form_id, ATTR_DATA_MCF, &num_rows);

 /*if (num_rows != 0)
   num_rows = num_rows - 1;*/

  FIfld_set_max_num_rows(forms.parametric_parts_form_id, ATTR_DATA_MCF, 
                         (num_rows + 1));
  FIfld_set_num_rows(forms.parametric_parts_form_id, ATTR_DATA_MCF, 
                     (num_rows + 1));
 status = MEMbuild_array(PDU_parm_data_bufr);
 _pdm_status("MEMbuild_array", status);

 if (status != MEM_S_SUCCESS)
   return(PDM_E_BUILD_BUFFER_ARRAY);

 status = MEMbuild_array(PDU_parm_attr_bufr);
 _pdm_status("MEMbuild_array", status);

 if (status != MEM_S_SUCCESS)
   return(PDM_E_BUILD_BUFFER_ARRAY);

 attr_data = (char **)PDU_parm_attr_bufr->data_ptr;
 data_data = (char **)PDU_parm_data_bufr->data_ptr;

 if (PDU_new_param_mode)
   check_col = PDU_NFM_WRITE_COL;
 else
   check_col = PDU_NFM_UPDATE_COL;

  num_cols = 1;
 for ( i = 0; i < PDU_parm_attr_bufr->rows; i++)
    {
     if (strcmp(attr_data[(PDU_parm_attr_bufr->columns * i) + check_col],
         "Y") == 0)
       {
       _pdm_debug("data_data = <%s>", data_data[i]);
       FIfld_set_text(forms.parametric_parts_form_id, ATTR_DATA_MCF, num_rows,
                      num_cols , data_data[i], FALSE);
       num_cols = num_cols + 1;
       }
    }

  return(PDM_S_SUCCESS);
  }

int PDUload_delete_parts_bufr(buffer)

  MEMptr *buffer;

  {
  int length;
  int select;
  int pos;
  int status;
  int num_rows;
  int i, j;
  int char_index = 0;
  char *text = NULL;
  char *row = NULL;

  _pdm_debug("In PDUload_delete_parts_bufr", 0);

  status = PDUformat_delete_part_bufr(buffer);
  _pdm_status("PDUformat_delete_part_bufr", status);

  if (status != PDM_S_SUCCESS)
    return(status);

  FIfld_get_num_rows(forms.parametric_parts_form_id, ATTR_DATA_MCF, &num_rows);

  row = (char *) malloc((*buffer)->row_size);
  for (i = 0; i < num_rows; i++)
    {
    memset(row, NULL, (*buffer)->row_size);
    char_index = 0;
    FIfld_set_active_row(forms.parametric_parts_form_id, ATTR_DATA_MCF, i, i);
    for (j = 1; j < 4; j++)
      {
      FImcf_set_active_col(forms.parametric_parts_form_id, ATTR_DATA_MCF, j, j);
      FIfld_get_text_length(forms.parametric_parts_form_id,ATTR_DATA_MCF,i,j,
                            &length);
      text = (char *) malloc (sizeof (char) * length + 1);
      memset(text, NULL, (length + 1));
      FIfld_get_text(forms.parametric_parts_form_id,ATTR_DATA_MCF,i,j,length,
                     (unsigned char*)text,&select,&pos);
      if ((text) && (strcmp(text, "") != 0))
        PDUadd_buffer_string(row, &char_index, text);
      else
       row[char_index++]='\1';
      }
    status = MEMwrite(*buffer, row);
    _pdm_status("MEMwrite", status);
 
    if (status != MEM_S_SUCCESS)
      return(status);
    }

  if (row)
    free(row);

  if (text)
    free(text);

  return(PDM_S_SUCCESS);
  }

int PDUdisplay_where_used(bufr)

MEMptr bufr;

  {
  int status;
  int all_flag;
  int no_headings;
  char **headings = NULL;

  _pdm_debug("In PDUdisplay_where_used", 0);

  if (PDU_ret_bufr)
    {
    MEMclose(&PDU_ret_bufr);
    PDU_ret_bufr = NULL;
    }

  status = MEMsplit_copy_buffer(bufr, &PDU_ret_bufr, 0);
  _pdm_status("MEMsplit_copy_buffer", status);

  PDUsetup_single_buffer(PDU_ret_bufr);
  all_flag = FALSE;
  no_headings = 3;
  headings = (char **)malloc(sizeof (char *) * no_headings);
  memset(headings, NULL, no_headings);

   PDUfill_in_string(&headings[0], "n_itemname");
   PDUfill_in_string(&headings[1], "n_itemrev");
   PDUfill_in_string(&headings[2], "n_itemdesc");

    PDUsetup_popup_list(headings, no_headings, all_flag,
            PDU_ret_bufr);

    PDUsetup_form_fields(headings, no_headings, all_flag,
            PDU_ret_bufr);

   PDUfree_string_array(&headings,no_headings);

   status = PDUmcf_list_form("");
   _pdm_status("PDUmcf_list_form", status);

  FIfld_set_mode(forms.mcf_list_form_id, 12, 0,FI_REVIEW);
  FIfld_set_mode(forms.mcf_list_form_id, 12, 1,FI_REVIEW);
  FIfld_set_mode(forms.mcf_list_form_id, 12, 2,FI_REVIEW);
  FIg_display(forms.mcf_list_form_id, 12);

  _pdm_debug("leaving display_where_used", 0);
  return(PDM_S_SUCCESS);
  }

int PDUcheck_if_catalog(text)

char *text;

  {
  int status;
  int i;
  char **class_data = NULL;

  _pdm_debug("in PDUcheck_if_catalog", 0);

  status = MEMbuild_array(PDU_cat_class_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  class_data = (char **)PDU_cat_class_bufr->data_ptr;
  /* find text selected in classification buffer */
  for (i = 0; i < PDU_cat_class_bufr->rows; i ++)
    {
    _pdm_debug("check text for class or catalog", 0);
    if (strcmp(text, class_data[(PDU_cat_class_bufr->columns * i) + 1]) == 0)
      {
      _pdm_debug("match found", 0);
      if (strcmp(class_data[(PDU_cat_class_bufr->columns * i ) + 4], "C") == 0)
        {
        _pdm_debug("catalog selected", 0);
        status = PDM_S_SUCCESS;
        break;
        }
      else
        {
        _pdm_debug("classification selected ", 0);
        status = PDM_E_FAILURE;
        break;
        }
      }
    }
  return(status);
  }

int PDUupdate_class_buffer(old_bufr, new_bufr,level_no)

MEMptr old_bufr;
MEMptr *new_bufr;
int    level_no;

  {
  int status;
  int i,j;
  int char_index;
  char **old_data = NULL;
  char *row = NULL;

  _pdm_debug("PDUupdate_class_buffer", 0);

  /* format new buffer */
  status = PDUformat_classification_buffer(new_bufr);
  _pdm_status("PDUformat_classification_buffer", status);

  if (status != PDM_S_SUCCESS)
    return(status);

  status = MEMbuild_array(old_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  old_data = (char **)old_bufr->data_ptr;
  row = (char *)malloc(old_bufr->row_size);

  if (level_no == 0)
    {
    memset(row, NULL, old_bufr->row_size);
    sprintf(row, "\1\1");
    status = MEMwrite(*new_bufr, row);
    _pdm_status("MEMwrite", status);

    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);
    else
      return(PDM_S_SUCCESS);
    }
    
  for ( i = 0; i < level_no; i++)
    {
    char_index = 0;
    memset(row, NULL, old_bufr->row_size);
    for (j = 0; j < old_bufr->columns; j++)
      {
      if ((old_data[(old_bufr->columns * i) + j]) && 
          (strcmp(old_data[(old_bufr->columns * i) + j], "") != 0))
        PDUadd_buffer_string(row, &char_index, 
                             old_data[(old_bufr->columns * i) + j]);
      else
        row[char_index++] = '\1';
      }
    status = MEMwrite(*new_bufr, row);
    _pdm_status("MEMwrite", status);

    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);
    }  

  return(PDM_S_SUCCESS);
  }

int PDUget_parametric_part_attributes()

  {
  int status;
  char cat_type[5];
  char *msg = NULL;
  MEMptr dummy = NULL;

  _pdm_debug("In PDUget_parametric_part_attributes", 0);

 status = PDMquery_catalog_type(refresh->rev_catalog, cat_type);
 _pdm_status("PDMquery_catalog", status);

 if ((status != PDM_S_SUCCESS) || (cat_type == NULL))
   {
   printf("status != success or cat type = <%s> \n", cat_type);
   msg = (char *)PDUtranslate_message(PDM_E_CAT_NOT_PARAMETRIC);
   FIg_set_text(forms.parametric_parts_form_id, FI_MSG_FIELD, msg);
   FIg_set_text(forms.parametric_parts_form_id, CATALOG_NAME, "");
  if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
    PDUfill_in_string(&refresh->rev_catalog, NULL);
   return(status);
    }
  else if ((strcmp(cat_type, "P") != 0) && 
           (strcmp(cat_type, "PXT") != 0))
    {
    if (strcmp(cat_type, "CID") == 0)
      msg = (char *)PDUtranslate_message(PDM_E_VIEW_CATALOG);
    else
      msg = (char *)PDUtranslate_message(PDM_E_CAT_NOT_PARAMETRIC);
    FIg_set_text(forms.parametric_parts_form_id, FI_MSG_FIELD, msg);
    FIg_set_text(forms.parametric_parts_form_id, CATALOG_DESC,"");
    FIg_reset(forms.parametric_parts_form_id, ATTR_DATA_MCF);
    FIg_reset(forms.parametric_parts_form_id, ATTR_NAME_MCF);
    FIg_disable(forms.parametric_parts_form_id, ATTR_DATA_MCF);
    FIg_disable(forms.parametric_parts_form_id, ATTR_NAME_MCF);
    if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
      PDUfill_in_string(&refresh->rev_catalog, NULL);
    if ((PDU_cat_description) && (strcmp(PDU_cat_description, "") != 0))
      PDUfill_in_string(&PDU_cat_description, NULL);
    return(PDM_E_FAILURE);
    }

  if (PDU_parm_attr_bufr)
     {
     MEMclose(&PDU_parm_attr_bufr);
     PDU_parm_attr_bufr = NULL;
     }
  if (PDU_parm_data_bufr)
     {
    MEMclose(&PDU_parm_data_bufr);
     PDU_parm_data_bufr = NULL;
     }
  if (PDU_parm_list_bufr)
     {
    MEMclose(&PDU_parm_list_bufr);
     PDU_parm_list_bufr = NULL;
     }

  FIg_reset(forms.parametric_parts_form_id, ATTR_NAME_MCF);
  FIg_reset(forms.parametric_parts_form_id, ATTR_DATA_MCF);

  if (PDU_new_param_mode)
  {
  /* Display Message */
  PDUmessage(PDS_M_GET_TABLE_ATTR, 's');
  PDUload_exec_structure("",refresh->rev_catalog,"",cat_type,
                                  "", "", "", ADD_DATA, 
                                  PDM_PARAMETRIC_PART);
  _pdm_debug("Calling PDMsget_table_attributes", 0);
  status = PDMsget_table_attributes(&PDU_parm_attr_bufr, 
                                    &PDU_parm_data_bufr, 
                                    &PDU_parm_list_bufr);
  _pdm_status("PDMsget_table_attributes", status);

  if ((status != PDM_S_SUCCESS) || (PDU_parm_attr_bufr == NULL))
  {
  msg = (char *)PDUtranslate_message(status);
  FIg_set_text(forms.parametric_parts_form_id, FI_MSG_FIELD, msg);
  return(status);
  }
  if (PDM_debug_on)
  {
  MEMprint_buffer("parametric attributes", PDU_parm_attr_bufr, 
                   PDU_DEBUG_FILE); 
  MEMprint_buffer("parametric attributes", PDU_parm_data_bufr, 
                  PDU_DEBUG_FILE); 
  MEMprint_buffer("parametric attributes", PDU_parm_list_bufr, 
                  PDU_DEBUG_FILE); 
  }
  if (PDU_func_buffer)
      {
      MEMclose(&PDU_func_buffer);
      PDU_func_buffer = NULL;
      }
  PDUmessage(PDS_M_FUNCTION_FILES, 's');
  status = PDMmove_functions(refresh->rev_catalog, storage->storage_name,
                             &PDU_func_buffer);
  _pdm_status("PDMmove_functions", status);
   PDUmessage(status, 's');

  if ((PDU_func_buffer) && (PDM_debug_on))
    MEMprint_buffer("functions buffer", PDU_func_buffer, PDU_DEBUG_FILE);

  FIg_erase(forms.parametric_parts_form_id,ATTR_DATA_MCF);
  FIg_erase(forms.parametric_parts_form_id,ATTR_NAME_MCF);
  PDUload_data_into_mcf(PDU_parm_attr_bufr, dummy, PDU_parm_list_bufr);
  FIg_display(forms.parametric_parts_form_id,ATTR_DATA_MCF);
  FIg_display(forms.parametric_parts_form_id,ATTR_NAME_MCF);
  FIg_disable(forms.parametric_parts_form_id, ATTR_DATA_MCF);
  FIg_disable(forms.parametric_parts_form_id, ATTR_NAME_MCF);
  FIg_display(forms.parametric_parts_form_id, ATTR_DATA_MCF);
  FIg_display(forms.parametric_parts_form_id, ATTR_NAME_MCF);
  FIg_enable(forms.parametric_parts_form_id, ADD_PART);
  FIg_enable(forms.parametric_parts_form_id, ADD_ROW_DEF);
  FIg_enable(forms.parametric_parts_form_id, COPY_ROW);
  FIg_enable(forms.parametric_parts_form_id, CLEAR_ROW);
  }
  else
  {
  FIg_disable(forms.parametric_parts_form_id,ATTR_DATA_MCF);
  FIg_disable(forms.parametric_parts_form_id,ATTR_NAME_MCF);
  }
  status = PDUget_catalog_description();
  _pdm_status("PDUget_catalog_description", status);
  FIg_set_text(forms.parametric_parts_form_id, CATALOG_DESC, 
               PDU_cat_description);

  PDUmessage(PDM_S_SUCCESS, 's');
  return(PDM_S_SUCCESS);
  }

int PDUload_parametric_parts_after_select()

  {
  int status;
  int i;
  int cat_col;
  int part_col;
  int rev_col;
  int char_index;
  char *temp_part = NULL;
  char *temp_rev = NULL;
  char *row = NULL;
  char *msg = NULL;
  char cat_type[5];
  char **data_row = NULL;
  MEMptr part_bufr = NULL;
  extern MEMptr PDUsearch_part_list;

  _pdm_debug("In PDUload_parametric_parts_after_select", 0);

/* 1/8/95 MJG - TR 139528400 - set the PDU_form_id so that condition in PDMget_l
ist_for_modify does not pass if PDU_form_id = forms.rev_assy_form_id */

  PDU_form_id = forms.parametric_parts_form_id;

  FIg_set_state_off(forms.parametric_parts_form_id, ADD_ROWS_FR_SEARCH);
  if (PDUsearch_part_list == NULL)
    {
    FIf_display(forms.parametric_parts_form_id);
    status = PDM_E_NO_PARTS_FOUND;
    return(status);
    }
  else if (PDUsearch_part_list->rows == 0)
    {
    FIf_display(forms.parametric_parts_form_id);
    status = PDM_E_NO_PARTS_FOUND;
    return(status);
    }

  if (refresh->status == PDM_E_CMD_CANCELLED)
    {
    FIg_reset(forms.parametric_parts_form_id, ATTR_DATA_MCF);
    FIg_reset(forms.parametric_parts_form_id, ATTR_NAME_MCF);
    FIg_disable(forms.parametric_parts_form_id, ATTR_DATA_MCF);
    FIg_disable(forms.parametric_parts_form_id, ATTR_NAME_MCF);
    FIg_disable(forms.parametric_parts_form_id, CHANGE_PART);
    FIg_disable(forms.parametric_parts_form_id, DELETE_PART);
    FIg_disable(forms.parametric_parts_form_id, MOVE_NEXT_STATE);
    if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
     {
     status = PDMquery_catalog_type(refresh->rev_catalog, cat_type);
     _pdm_status("PDMquery_catalog", status);
     if ((strcmp(cat_type, "P") == 0) || 
         (strcmp(cat_type, "PXT") == 0))
        FIg_set_text(forms.parametric_parts_form_id, CATALOG_NAME, 
                     refresh->rev_catalog);
     else
       {
       if (strcmp(cat_type, "CID") == 0)
         msg = (char *)PDUtranslate_message(PDM_E_VIEW_CATALOG);
       else
         msg = (char *)PDUtranslate_message(PDM_E_CAT_NOT_PARAMETRIC);
       FIg_set_text(forms.parametric_parts_form_id,FI_MSG_FIELD, msg);
       PDUfill_in_string(&refresh->rev_catalog, NULL);
       FIg_set_text(forms.parametric_parts_form_id, CATALOG_NAME, "");
       }
     }
    else
      FIg_set_text(forms.parametric_parts_form_id, CATALOG_NAME, "");
    FIg_set_text(forms.parametric_parts_form_id, CATALOG_DESC, "");
    return(PDM_E_CMD_CANCELLED);
    }
  /* format buffer with only parts and revisions */
  status = PDUformat_update_parm_parts_bufr(&part_bufr);
  _pdm_status("PDUformat_update_parm_parts_bufr", status);

  if (status != PDM_S_SUCCESS)
    {
    FIf_display(forms.parametric_parts_form_id);
    return(status);
    }

  status = MEMbuild_array(PDUsearch_part_list);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    {
    FIf_display(forms.parametric_parts_form_id);
    return(PDM_E_BUILD_BUFFER_ARRAY);
    }

  PDUget_buffer_col(PDUsearch_part_list, "n_catalogname", &cat_col);
  PDUget_buffer_col(PDUsearch_part_list, "n_itemname", &part_col);
  PDUget_buffer_col(PDUsearch_part_list, "n_itemrev", &rev_col);
  PDUsetup_buffer(PDUsearch_part_list, ROW, &data_row);

  row = (char *)malloc(PDUsearch_part_list->row_size);
  for ( i = 0; i < PDUsearch_part_list->rows; i++)
    {
    memset(row, NULL, PDUsearch_part_list->row_size);
    char_index = 0;
    if (strcmp(refresh->rev_catalog,
         data_row[(PDUsearch_part_list->columns * i) + cat_col]) == 0)
      {
      PDUfill_in_string(&refresh->rev_catalog, 
                      data_row[(PDUsearch_part_list->columns * i) + cat_col]);
      }
    else
      {
      msg = (char *)PDUtranslate_message(PDM_E_SEL_MULT_CATALOGS);
      FIg_set_text(forms.parametric_parts_form_id,FI_MSG_FIELD, msg);
      FIg_disable(forms.parametric_parts_form_id, ATTR_DATA_MCF);
      FIg_disable(forms.parametric_parts_form_id, ATTR_NAME_MCF);
      return(PDM_S_SUCCESS);
      }
       
    PDUfill_in_string(&temp_part, data_row[(PDUsearch_part_list->columns * i) + 
                       part_col]);
    PDUfill_in_string(&temp_rev, data_row[(PDUsearch_part_list->columns * i) + 
                       rev_col]);
    if ((temp_part) && (strcmp(temp_part, "") != 0))
      PDUadd_buffer_string(row, &char_index, temp_part);
    else
      row[char_index++] = '\1';
    if ((temp_rev) && (strcmp(temp_rev, "") != 0))
      PDUadd_buffer_string(row, &char_index, temp_rev);
    else
      row[char_index++] = '\1';

    status = MEMwrite(part_bufr, row);
    _pdm_status("MEMwrite", status);
      
    if (status != MEM_S_SUCCESS)
      break;
    }

  if (row)
    free(row);

  if (status != MEM_S_SUCCESS)
    {
    FIf_display(forms.parametric_parts_form_id);
    return(PDM_E_WRITE_BUFFER);
    }

  if (PDU_parm_attr_bufr)
    {
    MEMclose(&PDU_parm_attr_bufr);
    PDU_parm_attr_bufr = NULL;
    }
  if (PDU_parm_data_bufr)
    {
    MEMclose(&PDU_parm_data_bufr);
    PDU_parm_data_bufr = NULL;
    }
  if (PDU_parm_list_bufr)
    {
    MEMclose(&PDU_parm_list_bufr);
    PDU_parm_list_bufr = NULL;
    }

  status = PDMquery_catalog_type(refresh->rev_catalog, cat_type);
  _pdm_status("PDMquery_catalog", status);

  /* Display Message */
  if ((strcmp(cat_type, "P") == 0) || 
      (strcmp(cat_type, "PXT") == 0))
  {
  PDUmessage(PDS_M_GET_TABLE_ATTR, 's');
  PDUload_exec_structure("",refresh->rev_catalog,"",cat_type,
                                  "", "", "", MODIFY_DATA,
                                  PDM_PARAMETRIC_PART);
  _pdm_debug("Calling PDMsget_table_attributes", 0);
  status = PDMsget_table_attributes(&PDU_parm_attr_bufr,
                                    &PDU_parm_data_bufr,
                                    &PDU_parm_list_bufr);
  _pdm_status("PDMsget_table_attributes", status);

  if (status != PDM_S_SUCCESS)
    {
    FIf_display(forms.parametric_parts_form_id);
    return(status);
    }

  if (PDU_func_buffer)
      {
      MEMclose(&PDU_func_buffer);
      PDU_func_buffer = NULL;
      }
  PDUmessage(PDS_M_FUNCTION_FILES, 's');
  status = PDMmove_functions(refresh->rev_catalog, storage->storage_name,
                             &PDU_func_buffer);
  _pdm_status("PDMmove_functions", status);
   PDUmessage(status, 's');

  if ((PDU_func_buffer) && (PDM_debug_on))
    MEMprint_buffer("functions buffer", PDU_func_buffer, PDU_DEBUG_FILE);

  PDUload_exec_structure("",refresh->rev_catalog,"","",
                                  "", "", "", 0, 0);
  status = PDMget_list_for_modify(&PDU_parm_attr_bufr, &PDU_parm_data_bufr, 
                                  cat_type, &part_bufr);
  _pdm_status("PDMget_list_for_modify", status);

  if (status != PDM_S_SUCCESS)
    {
    FIf_display(forms.parametric_parts_form_id);
    return(status);
    }

    if (PDMdebug_on)
     {
      MEMprint_buffer("parametric attributes buffer",PDU_parm_attr_bufr,
                      PDU_DEBUG_FILE);
      MEMprint_buffer("parametric data buffer",PDU_parm_data_bufr,
                      PDU_DEBUG_FILE);
      MEMprint_buffer("part buffer",part_bufr,
                      PDU_DEBUG_FILE);
     }

  FIg_reset(forms.parametric_parts_form_id, ATTR_NAME_MCF);
  FIg_reset(forms.parametric_parts_form_id, ATTR_DATA_MCF);
  status = PDUload_data_into_mcf(PDU_parm_attr_bufr, PDU_parm_data_bufr, 
                                 PDU_parm_list_bufr);
  _pdm_status("PDUload_data_into_mcf", status);

  FIg_set_text(forms.parametric_parts_form_id, CATALOG_NAME, 
               refresh->rev_catalog);
  if ((PDU_parm_data_bufr) && (PDU_parm_data_bufr->rows > 0))
  {
  FIg_enable(forms.parametric_parts_form_id, ATTR_NAME_MCF);
  FIg_enable(forms.parametric_parts_form_id, ATTR_DATA_MCF);
  FIg_display(forms.parametric_parts_form_id, ATTR_NAME_MCF);
  FIg_display(forms.parametric_parts_form_id, ATTR_DATA_MCF);
  FIf_display(forms.parametric_parts_form_id);
  FIg_enable(forms.parametric_parts_form_id, CHANGE_PART);
  FIg_enable(forms.parametric_parts_form_id, DELETE_PART);
  FIg_enable(forms.parametric_parts_form_id, MOVE_NEXT_STATE);
  if (PDU_parm_data_bufr->rows != part_bufr->rows)
    {
    msg = (char *)PDUtranslate_message(PDM_I_PARTS_USED_IN_ASSEM);
    FIg_set_text(forms.parametric_parts_form_id, FI_MSG_FIELD, msg);
    }
  }
  else
    {
    msg = (char *)PDUtranslate_message(PDM_I_PARTS_USED_IN_ASSEM);
    FIg_set_text(forms.parametric_parts_form_id, FI_MSG_FIELD, msg);
    FIg_disable(forms.parametric_parts_form_id, ATTR_DATA_MCF);
    FIg_disable(forms.parametric_parts_form_id, ATTR_NAME_MCF);
    }
  }
  else
    {
      if (strcmp(cat_type, "CID") == 0)
        msg = (char *)PDUtranslate_message(PDM_E_VIEW_CATALOG);
      else
        msg = (char *)PDUtranslate_message(PDM_E_CAT_NOT_PARAMETRIC);
      FIg_set_text(forms.parametric_parts_form_id,FI_MSG_FIELD, msg);
      PDUfill_in_string(&refresh->rev_catalog, NULL);
      FIg_disable(forms.parametric_parts_form_id, ATTR_DATA_MCF);
      FIg_disable(forms.parametric_parts_form_id, ATTR_NAME_MCF);
    }
    
  return(PDM_S_SUCCESS);
  } 

  int PDUprocess_class_pulldown()
  
  {
  int status;
  int list_size;
  int i;
  char *msg = NULL;
  char **data_data = NULL;
  Form fp;
  MEMptr temp_bufr = NULL;
  
  _pdm_debug("PDUprocess_class_pulldown", 0);
  fp = forms.parametric_parts_form_id;
  PDU_class_level = PDU_class_level + 1;

  if (PDU_query_class_bufr == NULL)
    {
    msg = (char *)PDUtranslate_message(PDM_I_SEL_LEVEL1_CLASS);
    FIg_set_text(fp, FI_MSG_FIELD, msg);
    return(PDM_S_SUCCESS);
    }
  else if (PDU_class_level < PDU_query_class_bufr->rows)
    {
    /* call function to update buffer */
    status = PDUupdate_class_buffer(PDU_query_class_bufr, &temp_bufr,
                                     PDU_class_level);
    _pdm_status("PDUupdate_class_buffer", status);

    if (status != PDM_S_SUCCESS)
     {
     msg = (char *)PDUtranslate_message(PDM_E_RETRIEVE_CLASS);
     FIg_set_text(fp, FI_MSG_FIELD, msg);
     return(status);
     }

    if (PDU_query_class_bufr)
      {
      MEMclose(&PDU_query_class_bufr);
      PDU_query_class_bufr = NULL;
      }
    MEMsplit_copy_buffer(temp_bufr, &PDU_query_class_bufr, 0);
    MEMclose(&temp_bufr); 
    }
    PDUload_exec_structure("", "", "", "", "", "", "", 0, 0);
    _pdm_debug("calling PDMquery_classification", 0);
    if (PDU_cat_class_bufr)
      {
      MEMclose(&PDU_cat_class_bufr);
      PDU_cat_class_bufr = NULL;
      }
    if (PDMdebug_on)
      MEMprint_buffer("query classification buffer",PDU_query_class_bufr,
                      PDU_DEBUG_FILE);
    status = PDMquery_classification(PDU_query_class_bufr, 
                                     &PDU_cat_class_bufr);
     _pdm_status("PDMquery_classification", status);

    if ((status != PDM_S_SUCCESS) || (PDU_cat_class_bufr == NULL))
      {
      msg = (char *)PDUtranslate_message(PDM_E_NO_CATALOGS);
      FIg_set_text(fp, FI_MSG_FIELD, msg);
      if (PDU_cat_class_bufr)
        {
        MEMclose(&PDU_cat_class_bufr);
        PDU_cat_class_bufr = NULL;
        }
      return(status);
      }
    if (PDMdebug_on)
      MEMprint_buffer("classification buffer",PDU_cat_class_bufr,
                      PDU_DEBUG_FILE);
    /* call function to load classes and catalogs into one buffer */
    status = PDUcreate_class_and_catalog_bufr(PDU_cat_class_bufr,
                                               &PDU_ret_bufr);
    _pdm_status("PDUcreate_class_and_catalog_bufr", status);

    if (status!= PDM_S_SUCCESS)
      {
       msg = (char *)PDUtranslate_message(PDM_E_PROCCESS_CLASS_LEVELS);
       FIg_set_text(fp, FI_MSG_FIELD, msg);
       if (PDU_cat_class_bufr)
         {
         MEMclose(&PDU_cat_class_bufr);
         PDU_cat_class_bufr = NULL;
         }
       return(status);
      }
   if (PDMdebug_on)
     MEMprint_buffer("listing buffer",PDU_ret_bufr,PDU_DEBUG_FILE);

   MEMbuild_array(PDU_ret_bufr);
   data_data = (char **)PDU_ret_bufr->data_ptr;
   /* load classes in to GRpulldown */
   list_size = PDU_ret_bufr->rows;
   for (i = 0; i < list_size; i++)
         PDUfill_in_string(&PDU_value_list[i],
                           data_data[(PDU_ret_bufr->columns * i) + 0]);
        
   GRdelete_pull_down_list(PDU_catalog_pulldown);
   GRcreate_pull_down_list(PARAMETRIC_PARTS_FORM, 
                          forms.parametric_parts_form_id,
                          CLASS_ASSOC_GADGET, list_size, VIS_ROWS, 
                          PDU_value_list, list_size, 1, &PDU_catalog_pulldown);
   GRchange_pull_down_text(PDU_catalog_pulldown,PDU_value_list,list_size);
   GRproc_pull_down_list(PDU_catalog_pulldown);

   return(PDM_S_SUCCESS);
   }

int PDUextract_refresh_from_mcf(selected_row)

int selected_row;

  {
  int length;
  int select;
  int pos;
  int status;
  int check_col;
  int i;
  int num_cols = 0;
  char *text = NULL;
  char **attr_data = NULL;

  _pdm_debug("In PDUextract_refresh_from_mcf", 0);

  status = MEMbuild_array(PDU_parm_attr_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(status);

  attr_data = (char **)PDU_parm_attr_bufr->data_ptr;

  FIfld_set_active_row(forms.parametric_parts_form_id, ATTR_DATA_MCF, 
                       selected_row, selected_row);

  check_col = PDU_NFM_UPDATE_COL;

  num_cols = 1;
  for (i = 0; i < PDU_parm_attr_bufr->rows; i ++)
    {
   if (strcmp(attr_data[(PDU_parm_attr_bufr->columns * i) + check_col], "Y")
         == 0) 
      {
      _pdm_debug("Column displayed on form", 0);
      num_cols = num_cols + 1;
      }
    else if (strcmp(attr_data[(PDU_parm_attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
        PDU_PARTID_ATTR) == 0) 
      {
      _pdm_debug("found part number column", 0);
      FImcf_set_active_col(forms.parametric_parts_form_id, ATTR_DATA_MCF,
                           num_cols, num_cols);
      _pdm_debug("num_col = <%d>", (char *)num_cols);
      FIfld_get_text_length(forms.parametric_parts_form_id,ATTR_DATA_MCF,
                            selected_row,num_cols, &length);
      text = (char *) malloc (sizeof (char) * length + 1);
      memset(text, NULL, (length + 1));
      FIfld_get_text(forms.parametric_parts_form_id,ATTR_DATA_MCF,
                     selected_row,num_cols,length, (unsigned char *)text,
                     &select,&pos);
      PDUfill_in_string(&refresh->rev_partid, text);
      num_cols = num_cols + 1;
      }
    else if (strcmp(attr_data[(PDU_parm_attr_bufr->columns * i) + PDU_NFM_ATTR_COL],
       PDU_REVISION_ATTR) == 0)
      {
      _pdm_debug("found part revision column", 0);
      FImcf_set_active_col(forms.parametric_parts_form_id, ATTR_DATA_MCF,
                           num_cols, num_cols);
      _pdm_debug("num_col = <%d>", (char *)num_cols);
     FIfld_get_text_length(forms.parametric_parts_form_id,ATTR_DATA_MCF,
                           selected_row,num_cols, &length);
     text = (char *) malloc (sizeof (char) * length + 1);
     memset(text, NULL, (length + 1));
     FIfld_get_text(forms.parametric_parts_form_id,ATTR_DATA_MCF,
                    selected_row,num_cols,length, (unsigned char*)text,
                    &select,&pos);

     PDUfill_in_string(&refresh->rev_revision, text);
     num_cols = num_cols + 1;
      }
    } 

  return(PDM_S_SUCCESS);
  }

int PDUfinish_parametric_move_to_next_state()

  {
  int status;
  int i;
  int sel_flag;
  int attr_row = -1;
  int n_stateno_col;
  int n_statename_col;
  int num_rows = 0;
  char            *msg = NULL;
  char            **states_bufr_row = NULL;
  char            **states_bufr_col = NULL;
  char            **states_bufr_format = NULL;
  char            **states_data_col = NULL;
  char            **states_data_row = NULL;
  MEMptr states_bufr1 = NULL;
  MEMptr delete_bufr = NULL;
  MEMptr status_bufr = NULL;

  _pdm_debug("In PDUfinish_parametric_move_to_next_state", 0);

   /* call function to load selected parts   in buffer */
    status = PDUload_deleted_parts(&delete_bufr);
    _pdm_status("PDUload_deleted_parts", status);
    if (status != PDM_S_SUCCESS)
      {
      msg = (char *)PDUtranslate_message(PDM_E_LOADING_DATA);
      FIg_set_text(forms.parametric_parts_form_id, FI_MSG_FIELD, msg);
      return(status);
      }

   status = PDUsetup_buffer_list(PDU_states_bufr,2,0,&states_bufr_row,
                                 &states_bufr_col,&states_bufr_format,
                                 &states_bufr1);

   states_data_col = (char **) states_bufr1->column_ptr;
   states_data_row = (char **) states_bufr1->data_ptr;

   status = PDUget_col_number(states_bufr1,"n_stateno",states_data_col,
                                &n_stateno_col);
   status = PDUget_col_number(states_bufr1,"n_statename",states_data_col,
                               &n_statename_col);

   attr_row = PDUfind_attr_in_buffer(PDU_parm_attr_bufr, PDU_NFM_STATE_NO);
   _pdm_debug("attr_row = <%d>", (char *)attr_row);

  status = MEMbuild_array(delete_bufr);
  _pdm_debug("state = <%s>", refresh->rev_description);
  if (refresh->rev_description == NULL)
    PDUfill_in_string(&refresh->rev_description, refresh->new_description);
  else if (strcmp(refresh->rev_description, "") == 0)
    PDUfill_in_string(&refresh->rev_description, refresh->new_description);
   if ((refresh->new_description) && 
       (strcmp(refresh->new_description, "") != 0))
     PDUfill_in_string(&refresh->new_description, "");
   for (i = 0; i < states_bufr1->rows; i ++)
     {
     if (strcmp(states_data_row[(states_bufr1->columns * i) + n_statename_col],
         refresh->rev_description) == 0)
       {
        status = MEMwrite_data(delete_bufr, 
                          states_data_row[(states_bufr1->columns*i) +
                          n_stateno_col], 1, (attr_row + 1));
        _pdm_status("MEMwrite",status);

            break;
        }
      }

    if (status != MEM_S_SUCCESS)
      {
      PDUmessage(PDM_E_WRITE_BUFFER, 's');
      return(PDM_E_WRITE_BUFFER);
      }

    PDUfill_in_string(&refresh->rev_description, NULL);
    if (PDM_debug_on)
      {
       MEMprint_buffer("parametric attributes", PDU_parm_attr_bufr,
                        PDU_DEBUG_FILE);
       MEMprint_buffer("parametric data", delete_bufr,
                        PDU_DEBUG_FILE);
       }

    /* load PDMexec structure */
    PDUload_exec_structure("", refresh->rev_catalog, "", "", "","","",0, 0);
    status = PDMmove_parametric_parts_to_next_state(PDU_parm_attr_bufr, 
                                           delete_bufr, "P", 
                                           &status_bufr);
    _pdm_status("PDMmove_parametric_parts", status);
    if (status != PDM_S_SUCCESS)
       {
       msg = (char *)PDUtranslate_message(PDM_E_MOVE_STATE_FAILED);
       FIg_set_text(forms.parametric_parts_form_id, FI_MSG_FIELD, msg);
       }

    PDUmessage(status, 's');
  FIfld_get_num_rows(forms.parametric_parts_form_id, ATTR_DATA_MCF, &num_rows);
  _pdm_debug("num_rows = %d", (char *)num_rows);
  for ( i = 0; i < num_rows; i++)
    {
    FIfld_get_select(forms.parametric_parts_form_id, ATTR_DATA_MCF, i, 0,
                     &sel_flag);
    if (sel_flag == TRUE)
      {
      FIfld_set_select(forms.parametric_parts_form_id, ATTR_DATA_MCF, i, 0,
                       FALSE);
      break;
      }
    }

    status = PDUprocess_move_to_next_state();
    _pdm_status("PDUprocess_move_to_next_state", status);

  return(status);
  }

int PDUprocess_move_to_next_state()

  {
  int status;
  int num_rows;
  int selected_rows;
  int i;
  int sel_flag;
  int n_status_col = 0;
  int n_statename_col = 0;
  int all_flag = 0;
  int no_headings = 0;
  char **attr_bufr_row = NULL;
  char **attr_bufr_col = NULL;
  char **attr_bufr_format = NULL;
  char **states_bufr_row = NULL;
  char **states_bufr_col = NULL;
  char **states_bufr_format = NULL;
  char **states_data_col = NULL;
  char **states_data_row = NULL;
  char **headings = NULL;
  MEMptr attr_bufr = NULL;
  MEMptr states_bufr1 = NULL;

  _pdm_debug("PDUprocess_move_to_next_state", 0);

  /* move to nect state selected row */
  FIg_set_state_off(forms.parametric_parts_form_id, MOVE_NEXT_STATE);
  FIfld_get_num_rows(forms.parametric_parts_form_id, ATTR_DATA_MCF, &num_rows);
  selected_rows = -1;
  _pdm_debug("num_rows = %d", (char *)num_rows);
  for ( i = 0; i < num_rows; i++)
    {
    FIfld_get_select(forms.parametric_parts_form_id, ATTR_DATA_MCF, i, 0, 
                     &sel_flag);
    if (sel_flag == TRUE)
      {
      selected_rows = i;
      break;
      }
    }
  _pdm_debug("selected row = %d", (char *)selected_rows);

  if (selected_rows == -1)
    return(PDM_E_FAILURE);

  status = PDUextract_refresh_from_mcf(selected_rows);
  _pdm_status("PDUextract_refresh_from_mcf", status);

  if (status != PDM_S_SUCCESS)
    return(PDM_E_FAILURE);
            
  PDUmessage(PDM_I_WORKING,'s');

  status = PDMget_trans(refresh->rev_catalog,refresh->rev_partid,
                        refresh->rev_revision);
  _pdm_status("PDMget_states",status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status,'s');
    return(status);
    }

  if (PDMdebug_on)
    MEMprint_buffers("THE PDU_states_bufr",PDU_states_bufr,PDU_DEBUG_FILE);

  status = PDUsetup_buffer_list(PDU_states_bufr,1,0,&attr_bufr_row,
                                &attr_bufr_col,&attr_bufr_format,
                                &attr_bufr);

  status = PDUsetup_buffer_list(PDU_states_bufr,2,0,&states_bufr_row,
                                &states_bufr_col,&states_bufr_format,
                                &states_bufr1);
 
  status = MEMbuild_array(states_bufr1);
  _pdm_status("MEMbuild_array",status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  states_data_col = (char **) states_bufr1->column_ptr;
  states_data_row = (char **) states_bufr1->data_ptr;

  status = PDUget_col_number(states_bufr1,"n_status",states_data_col,
                             &n_status_col);
  status = PDUget_col_number(states_bufr1,"n_statename",states_data_col,
                             &n_statename_col);

  status = MEMopen(&states_bufr, 512);
  _pdm_status("MEMopen",status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_OPEN_BUFFER);

  status = MEMwrite_format(states_bufr, "n_statename", "char(40)");
  _pdm_status("MEMwrite_format",status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_FORMAT);

  for (i = 0; i < states_bufr1->rows; ++i)
     {
     if (strcmp(states_data_row[(states_bufr1->columns * i) + n_status_col],
         "CURRENT STATE") != 0)
       {
       status = MEMwrite(states_bufr,
                         states_data_row[(states_bufr1->columns*i) +
                         n_statename_col]);
       _pdm_status("MEMwrite",status);

       if (status != MEM_S_SUCCESS)
         return(PDM_E_WRITE_BUFFER);
       PDUfill_in_string(&refresh->new_description, 
                         states_data_row[(states_bufr1->columns * i) + 
                         n_statename_col]);
       }
     }
  status = MEMwrite(states_bufr,"");
  _pdm_status("MEMwrite",status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_BUFFER);

  if (PDMdebug_on)
    MEMprint_buffer("STATES_BUFR",states_bufr,PDU_DEBUG_FILE);

  if (PDU_ret_bufr)
    {
    MEMclose(&PDU_ret_bufr);
    PDU_ret_bufr = NULL;
    }

  MEMsplit_copy_buffer(states_bufr, &PDU_ret_bufr, 0);
  PDUsetup_single_buffer(PDU_ret_bufr);

  PDU_form_id = forms.parametric_parts_form_id;
  PDU_update_struct[0] = &refresh->rev_description;

  all_flag = FALSE;
  no_headings = 1;
  headings = (char **) malloc (sizeof (char *) * no_headings);
  memset(headings, NULL, sizeof (char *) * no_headings);

  PDUfill_in_string(&headings[0], "n_statename");

  PDUsetup_popup_list(headings, no_headings, all_flag,
            PDU_ret_bufr);

  PDUsetup_struct_fields(headings, no_headings, all_flag,
            PDU_ret_bufr);

  PDUfree_string_array(&headings, no_headings);
  PDU_active_button = MOVE_NEXT_STATE;
  PDU_active_list = FALSE;

  status = PDUsingle_list_form();
  _pdm_status("PDUsingle_list_form",status);

 /* ALR    5/23/94  TR 139416881 */
  FIg_set_text(forms.single_list_form_id,12,(char *)PDUtranslate_message(PDM_S_STATE_LIST));
  FIf_display(forms.single_list_form_id);

  if (status == PDM_S_SUCCESS)
     PDUmessage(status,'s');
  return(status);
   }

int PDUcheck_all_parametric_parts_exist(attr_bufr, data_bufr, msg)
MEMptr attr_bufr;
MEMptr data_bufr;
char   *msg;

{
int status;
char *msg1 = NULL;
char **data_data = NULL;
int  partid_row = -1; 
int  partrev_row = -1; 
int  i;

_pdm_debug("PDUcheck_all_parametric_parts_exist", 0);  

if (attr_bufr == NULL)
return(PDM_E_NULL_BUFFER);

if (data_bufr == NULL)
return(PDM_E_NULL_BUFFER);

status = MEMbuild_array(attr_bufr);
_pdm_status("MEMbuild_array", status);
if (status != MEM_S_SUCCESS)
return(PDM_E_BUILD_BUFFER_ARRAY);

status = MEMbuild_array(data_bufr);
_pdm_status("MEMbuild_array", status);
if (status != MEM_S_SUCCESS)
return(PDM_E_BUILD_BUFFER_ARRAY);

data_data = (char **)data_bufr->data_ptr;

partid_row = PDUfind_attr_in_buffer(attr_bufr, PDU_PARTID_ATTR);
_pdm_debug("partid_row = <%d>", partid_row);
partrev_row = PDUfind_attr_in_buffer(attr_bufr, PDU_REVISION_ATTR);
_pdm_debug("partrev_row = <%d>", partrev_row);

if ((partid_row == -1) || (partrev_row == -1))
return(PDM_I_ATTR_NOT_FOUND);

for (i = 0; i < PDU_parm_data_bufr->rows; i++)
{
PDUload_exec_structure("", refresh->rev_catalog,
		   data_data[(data_bufr->columns * i) + partid_row],
		   data_data[(data_bufr->columns * i) + partrev_row],
		  "", "", "", 0, 0);
status = PDMvalidate_parametric_part();
_pdm_status("PDMvalidate_parametric_part", status);

if (status != PDM_S_SUCCESS)
{
msg1 = (char *)PDUtranslate_message(PDM_E_PART_EXISTS);
strcpy(msg, msg1);
break;
}
}
return(status);
}

int PDUcheck_all_parametric_parts_dup(attr_bufr, data_bufr, msg)
MEMptr attr_bufr;
MEMptr data_bufr;
char   *msg;

{
int status;
char **data_data = NULL;
int  partid_row = -1; 
int  partrev_row = -1; 
int  i,j;

_pdm_debug("PDUcheck_all_parametric_parts_exist", 0);  

if (attr_bufr == NULL)
return(PDM_E_NULL_BUFFER);

if (data_bufr == NULL)
return(PDM_E_NULL_BUFFER);

status = MEMbuild_array(attr_bufr);
_pdm_status("MEMbuild_array", status);
if (status != MEM_S_SUCCESS)
return(PDM_E_BUILD_BUFFER_ARRAY);

status = MEMbuild_array(data_bufr);
_pdm_status("MEMbuild_array", status);
if (status != MEM_S_SUCCESS)
return(PDM_E_BUILD_BUFFER_ARRAY);

data_data = (char **)data_bufr->data_ptr;

partid_row = PDUfind_attr_in_buffer(attr_bufr, PDU_PARTID_ATTR);
_pdm_debug("partid_row = <%d>", partid_row);
partrev_row = PDUfind_attr_in_buffer(attr_bufr, PDU_REVISION_ATTR);
_pdm_debug("partrev_row = <%d>", partrev_row);

if ((partid_row == -1) || (partrev_row == -1))
return(PDM_I_ATTR_NOT_FOUND);

status = PDM_S_SUCCESS;
for (i = 0; i < PDU_parm_data_bufr->rows; i++)
{
  for (j = 0; j < PDU_parm_data_bufr->rows; j ++)
    {
    if (i == j)
      continue;
    if ((strcmp(data_data[(data_bufr->columns * i) + partid_row],
         data_data[(data_bufr->columns * j) + partid_row]) == 0) &&
	 (strcmp(data_data[(data_bufr->columns * i) + partrev_row],
         data_data[(data_bufr->columns * j) + partrev_row]) == 0))
      {
      sprintf(msg, "Part <%s> revision <%s> already entered",
		   data_data[(data_bufr->columns * i) + partid_row],
		   data_data[(data_bufr->columns * i) + partrev_row]);
      status = PDM_E_FAILURE;
      break;
      }
    }
}
return(status);
}

int PDUupdate_parmpart_function_value(function_value)

char *function_value;
  {
  int num_rows = 0;
  int num_cols = 0;
  int selected_rows;
  int i;
  int sel_flag = FALSE;
  int act_col = 0;
  int pos = 0;
 
  _pdm_debug("PDUudpate_parmpart_function_value", 0);
  
  FIfld_get_num_rows(forms.parametric_parts_form_id, ATTR_DATA_MCF, &num_rows);
  _pdm_debug("num_rows = %d", (char *)num_rows);
  if (num_rows != 0)
    num_rows = num_rows - 1;
  selected_rows = -1;
  for ( i = 0; i < num_rows; i++)
     {
     FIfld_get_select(forms.parametric_parts_form_id, ATTR_DATA_MCF, i, 0, 
                      &sel_flag);
     if (sel_flag == TRUE)
       {
       selected_rows = i;
       break;
       }
     }
  _pdm_debug("selected row = %d", (char *)selected_rows);
  FImcf_get_active_col(forms.parametric_parts_form_id,ATTR_NAME_MCF, &act_col, 
                       &pos);
  _pdm_debug("act_col = <%d>", act_col);
  FImcf_get_num_cols(forms.parametric_parts_form_id, ATTR_NAME_MCF, &num_cols);
  _pdm_debug("num_cols = <%d>", num_cols);
  num_cols = num_cols -1;
  if (selected_rows == num_rows)
      selected_rows = -1;

  if (selected_rows == -1)
    FIfld_set_text(forms.parametric_parts_form_id, ATTR_DATA_MCF, num_rows, 
                   act_col, 
                   function_value, FALSE);
  else
    FIfld_set_text(forms.parametric_parts_form_id, ATTR_DATA_MCF, selected_rows,                   act_col, 
                   function_value, FALSE);
  return(PDM_S_SUCCESS);
  }
