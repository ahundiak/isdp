#include <stdio.h>
#include <tools.h>
#include <FI.h>
#include <PDUerror.h>
#include <PDUstr.h>
#include <PDUcommand.h>
#include <PDUforms.h>
#include <PDUform_def.h>
#include <MEMerrordef.h>
#include "PDUfile_def.h"
#include "exdef.h"
#include "part_gadgets.h"
#include "PDUproto.h"
#include "PDMproto.h"

/* Gadgets */

#define ACL       		16
#define ACL_LIST_BTN            35
#define ACL_GRP	                29
#define AUTO_FILE     		21
#define TO_TXT                  25
#define CAT_CLASS_MCF           23
#define DEF_USAGEID             26
#define CLASS_ASSOC_GADGET      25
#define TEMPCAT_ASSOC_GADGET    39
#define CHANGE_BUTTON           22
#define NEW_BUTTON              21
#define CLASS_LEVEL_BTN         37
#define CATALOG_TYPE_TOG        19
#define DELETE_CATALOG          34
#define TEMP_GRP                24
#define DEF_USAGE_GRP           43
#define UPDATE_CLASS            40
#define CAT_LIST                41
#define TEMP_CAT_LIST           42

/* Externs */

extern char * calloc();
extern char * realloc();
extern int FIg_get_text_length();
extern int FIg_get_text();
extern struct PDUrefresh *refresh;
extern struct PDUforms forms;
extern char *** PDU_update_struct;
extern int *PDU_gadget_labels;
extern Form PDU_form_id;
extern MEMptr PDU_ret_bufr;
extern MEMptr PDU_cat_class_bufr;
extern MEMptr PDU_query_class_bufr;
extern char *PDU_popup_list_type;
extern int PDU_command;
extern char *PDU_template_catalog;
extern char *PDU_default_usageid;
extern int PDU_list_cat;
extern int PDU_parm_cat;
extern int PDU_class_level;
extern int PDU_mcf_list_created;
extern short PDU_load_assy;
extern short PDU_extadmin;
extern char *PDU_assy_catalog;

extern int PDU_cat_name_create;
extern int PDU_cat_name_display;
extern char *PDU_cat_description;
extern char * PDU_cat_aclno;
extern int  bufr_flag;
extern int  PDU_value_pulldown;
extern int  PDU_tempcat_pulldown;
extern int  PDU_view;
extern int  PDU_active_button;
extern int  PDU_active_list;
extern int  PDU_refresh_gadgets[7];
extern char *PDU_value_list[605];
extern int end_ep_cat_btn_flag;
extern int end_np_cat_btn_flag;
extern int PDM_debug_on;

extern char *PDU_cat_aclname;
extern MEMptr acl_bufr;

int cat_name_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  static char   * text;
  int             status;
  int             state;
  int            no_headings;
  int            all_flag;
  char           ** headings;
  int            i;
  char           ** ret_data;
  int            row;
  int            pos;
  static int     list_size = 0;
  int            list_row;
  int            mode;
  int            num_rows;
  int            length;
  int            select;
  static int     act_row = 0;
  MEMptr         class_buffer = NULL;
  MEMptr         input_buffer = NULL;
  char          **class_data = NULL;
  int           responses[1];
  char          *strings[1];
  char          cat_type[5];
  char          **acl_data = NULL;
  char          **acl_cols = NULL;
  char          spec_char;
  char          *search_str = NULL;
  char		*msg;

  PDUdismiss_subforms();

  switch ( g_label )
  {
    case CATFLD:         /* Field Type:    ASCII    */

          /* set message strip to "" */
          FIg_set_text(forms.cat_name_form_id, FI_MSG_FIELD, NULL_STRING);

	  FIfld_get_text_length(fp, CATFLD, 0, 0, &length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          status = FIfld_get_text(fp, CATFLD, 0, 0, length,
                                  (unsigned char *)text,&select,&pos);

          if ( status != FI_SUCCESS )
            {
              /* Code to handle error */
              _pdm_debug("ERROR GETTING CATALOG NAME FROM CAT_NAME FORM",0);
              msg = (char *)PDUtranslate_message(PDM_E_CAT_NAME_FORM); 
              FIg_set_text(forms.cat_name_form_id, FI_MSG_FIELD,msg);
              FIg_set_text(forms.cat_name_form_id, CATFLD, "");
              break;
            }

           if (text == NULL)
             break;
           else if (strcmp(text, "") == 0)
             break;
           else
             {
             _pdm_debug("validate catalog name",0);
             length = strlen(text);
             for (i = 0; i < length; i++)
               if (text[i] == ' ')
                 {
                 msg = (char *)PDUtranslate_message(PDM_I_BLANK_CAT_NAME);
                 FIg_set_text(fp, FI_MSG_FIELD, msg);
                  FIg_set_text(fp, CATFLD, "");
                  if ((refresh->rev_catalog) && 
                      (strcmp(refresh->rev_catalog, "") != 0))
                    PDUfill_in_string(&refresh->rev_catalog, NULL);
                  break;
                 }
              }

          status = PDUcheck_char(text, &spec_char);
          _pdm_status("PDUcheck_char", status);

          if (status != PDM_S_SUCCESS)
            {
            search_str = (char *) malloc (sizeof (char) * 100);
            memset(search_str, NULL, 100);
            /*
            sprintf(search_str,"Catalog name cannot contain the character '%c'",
                    spec_char);
            */
            FIg_set_text(fp, CATFLD, "");
            msg = (char *)PDUtranslate_message(PDM_E_ILL_CHAR);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            free(search_str);
            if ((refresh->rev_catalog) && 
                (strcmp(refresh->rev_catalog, "") != 0))
              PDUfill_in_string(&refresh->rev_catalog, NULL);
            break;
            }
            
          status = PDUcheck_catalog_char(text, &spec_char);
          _pdm_status("PDUcheck_catalog_char", status);

          if (status != PDM_S_SUCCESS)
            {
            search_str = (char *) malloc (sizeof (char) * 100);
            memset(search_str, NULL, 100);
           /* 
            sprintf(search_str,"Catalog name cannot contain the character '%c'",
                    spec_char);
            */
            FIg_set_text(fp, CATFLD, "");
            msg = (char *)PDUtranslate_message(PDM_E_ILL_CHAR);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            free(search_str);
            if ((refresh->rev_catalog) && 
                (strcmp(refresh->rev_catalog, "") != 0))
              PDUfill_in_string(&refresh->rev_catalog, NULL);
            break;
            }
          /* test and see if view first */
          status = PDMcheck_for_view(text);
          _pdm_status("PDMcheck_for_view", status);

          if (status == PDM_I_VIEW_FOUND)
            {
            _pdm_debug("Table name is a view", 0);
            PDU_view = TRUE;
            PDU_parm_cat = TRUE;
            _pdm_debug("text = <%s>", text);
            PDUfill_in_string(&refresh->rev_catalog, text);
            FIg_set_state_on(fp, CATALOG_TYPE_TOG);
            FIg_disable(fp, CATALOG_TYPE_TOG);
            FIg_set_text(fp, TEMP_CATALOG, "");
            FIg_disable(fp, TEMP_CATALOG);
            FIg_disable(fp, TEMP_CAT_LIST);
            if (PDU_template_catalog)
              PDUfill_in_string(&PDU_template_catalog, NULL);
            if (PDU_command == PDC_M_MODIFY_CATALOG)
              {
             status = PDMget_class_of_cat(refresh->rev_catalog, &input_buffer);
             _pdm_status("PDMget_class_of_cat", status);

              if ((status == PDM_I_NO_CLASS) || (input_buffer == NULL))
                FIg_enable(fp,CAT_CLASS_MCF);
              else if (status != PDM_S_SUCCESS)
                FIg_enable(fp, CAT_CLASS_MCF);
              else
                {
                status = PDUfill_in_class(input_buffer);
                _pdm_status("PDUfill_in_class", status);
                }
              FIg_enable(fp, DELETE_CATALOG);
              FIg_enable(fp, UPDATE_CLASS);
              }
              break;
             }
        
           FIg_enable(fp, CATALOG_TYPE_TOG);
           status = PDUcheck_for_reserved_words(text);
           _pdm_status("PDUcheck_for_reserved_words", status);
           if (status != PDM_S_SUCCESS)
             {
             msg = (char *)PDUtranslate_message(PDM_E_CAT_RESERVED);
             FIg_set_text(fp, FI_MSG_FIELD, msg);
             FIg_set_text(fp, CATFLD, "");
             if ((refresh->rev_catalog) && 
                 (strcmp(refresh->rev_catalog, "") != 0))
                PDUfill_in_string(&refresh->rev_catalog, NULL);
             break;
             }
           PDU_view = FALSE;
           FIg_enable(fp, TEMP_CATALOG);
           FIg_enable(fp, TEMP_CAT_LIST);
           bufr_flag = FALSE;
          /* Code to process text string "text" */
          _pdm_debug("In CATALOG case of catname form", 0);

          /* validate catalog on the specific arg */
          status = PDUvalid_catalog("", text);
          _pdm_status("PDUvalid_catalog",status);
            PDUmessage(PDM_E_CLEAR_FIELD, 's');
          if ((status != PDM_S_SUCCESS) && 
               (PDU_command != PDC_M_CREATE_CATALOG))
            {
            _pdm_debug("catalog <%s> is not valid", text);
            msg = (char *)PDUtranslate_message(PDM_E_CATALOG_NOT_FOUND);
            FIg_set_text(forms.cat_name_form_id, FI_MSG_FIELD, msg);
            FIg_set_text(forms.cat_name_form_id, CATFLD, "");
            if (refresh->rev_catalog)
              PDUfill_in_string(&refresh->rev_catalog, NULL);
            FIg_disable(fp, DELETE_CATALOG);
            break;
            } 
          else if ((status == PDM_S_SUCCESS) && 
                   (PDU_command == PDC_M_CREATE_CATALOG))
            {
            _pdm_debug("catalog <%s> is not valid", text);
            msg = (char *)PDUtranslate_message(PDM_E_CATALOG_EXISTS);
            FIg_set_text(forms.cat_name_form_id, FI_MSG_FIELD, msg);
            FIg_set_text(forms.cat_name_form_id, CATFLD, "");
            if (refresh->rev_catalog)
              PDUfill_in_string(&refresh->rev_catalog, NULL);
            FIg_disable(fp, DELETE_CATALOG);
            break;
            } 
          else if (status == PDM_E_INVALID_INPUT)
            {
            _pdm_debug("catalog <%s> is not valid", text);
            msg = (char *)PDUtranslate_message(PDM_E_CAT_NAME_DIGITS);
            FIg_set_text(forms.cat_name_form_id, FI_MSG_FIELD, msg);
            FIg_set_text(forms.cat_name_form_id, CATFLD, "");
            FIfld_pos_cursor(forms.cat_name_form_id, CATFLD, 0, 0, 0, 0, 1, 1);
            if (refresh->rev_catalog)
              PDUfill_in_string(&refresh->rev_catalog, NULL);
            FIg_disable(fp, DELETE_CATALOG);
            break;
            }
          else if (status == PDM_E_CATALOG_FIELD_TOO_LONG)
            {
            _pdm_debug("catalog <%s> is not valid", text);
            msg = (char *)PDUtranslate_message(PDM_E_CATALOG_FIELD_TOO_LONG);
            FIg_set_text(forms.cat_name_form_id, FI_MSG_FIELD, msg);
            FIg_set_text(forms.cat_name_form_id, CATFLD, "");
            FIfld_pos_cursor(forms.cat_name_form_id, CATFLD, 0, 0, 0, 0, 1, 1);
            if (refresh->rev_catalog)
              PDUfill_in_string(&refresh->rev_catalog, NULL);
            FIg_disable(fp, DELETE_CATALOG);
            break;
            }
          else
            PDUfill_in_string(&refresh->rev_catalog, text);

           if (PDU_command == PDC_M_MODIFY_CATALOG)
             {
             status = PDUget_catalog_description();
             _pdm_status("PDUget_catalog_description", status);

             FIg_set_text(fp, CATDESCR, PDU_cat_description);
             status = PDMquery_catalog_type(refresh->rev_catalog, cat_type);
             _pdm_status("PDMquery_catalog_type", status);

             if ((strcmp(cat_type, "P") == 0) || (strcmp(cat_type, "PXT") == 0))
               {
               FIg_set_state_on(fp, CATALOG_TYPE_TOG);
               FIg_disable(fp, CATALOG_TYPE_TOG);
               PDU_parm_cat = TRUE;
               PDU_view = FALSE;
               }
             else if ((strcmp(cat_type, "CID") == 0) || (strcmp(cat_type, 
                       "EID") == 0))
               {
               FIg_set_state_on(fp, CATALOG_TYPE_TOG);
               FIg_disable(fp, CATALOG_TYPE_TOG);
               PDU_parm_cat = TRUE;
               PDU_view = TRUE;
               }
            else
               {
               FIg_set_state_off(fp, CATALOG_TYPE_TOG);
               FIg_disable(fp, CATALOG_TYPE_TOG);
               FIg_erase(fp, DEF_USAGE_GRP);
               PDU_parm_cat = FALSE;
               PDU_view = FALSE;
               }
                
             status = PDMget_class_of_cat(refresh->rev_catalog, &input_buffer);
             _pdm_status("PDMget_class_of_cat", status);

              if ((status == PDM_I_NO_CLASS) || (input_buffer == NULL))
                FIg_enable(fp,CAT_CLASS_MCF);
              else if (status != PDM_S_SUCCESS)
                FIg_enable(fp, CAT_CLASS_MCF);
              else
                {
                status = PDUfill_in_class(input_buffer);
                _pdm_status("PDUfill_in_class", status);
                }
             /* find default_usageid */
             if ((PDU_default_usageid != NULL) && 
                  (strcmp(PDU_default_usageid, "") != 0))
                PDUfill_in_string(&PDU_default_usageid, NULL);

             /* call PDM function to get stored usageid */
             status = PDMget_usageid_cat(refresh->rev_catalog, 
                                         &PDU_default_usageid);
             _pdm_status("PDMget_usageid", status);

             if ((status == PDM_S_SUCCESS) && (PDU_default_usageid != NULL) && 
                      (strcmp(PDU_default_usageid, "")!= 0))
               FIg_set_text(forms.cat_name_form_id, DEF_USAGEID, 
                    PDU_default_usageid);
              }
            else
              {
              status = PDMquery_lower_case_catalogname(refresh->rev_catalog);
              _pdm_status("PDMquery_lower_case_catalogname", status);
              if (status == PDM_S_SUCCESS)
                {
                _pdm_debug("catalog <%s> is not valid", text);
                msg = (char *)PDUtranslate_message(PDM_E_CATALOG_EXISTS);
                 FIg_set_text(forms.cat_name_form_id, FI_MSG_FIELD, msg);
                 FIg_set_text(forms.cat_name_form_id, CATFLD, "");
                if (refresh->rev_catalog)
                  PDUfill_in_string(&refresh->rev_catalog, NULL);
                FIg_disable(fp, DELETE_CATALOG);
                break;
                }
             }

            FIg_enable(fp, DELETE_CATALOG);
            FIg_enable(fp, UPDATE_CLASS);
            FIfld_pos_cursor(forms.cat_name_form_id, CATDESCR, 0, 0, 0, 0, 1,1);

          PDUmessage(PDM_S_SUCCESS, 's');
         break;

    case CAT_LIST:

          PDU_refresh_gadgets[1] = CATFLD;
          PDU_active_button = CAT_LIST;
          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
         status = PDUep_cat_btn();
         _pdm_status("PDUep_cat_btn",status);
       
         break;

    case CATDESCR:         /* Field Type:    ASCII    */

          /* set message strip to "" */
          FIg_set_text(forms.cat_name_form_id, FI_MSG_FIELD, NULL_STRING);

          /* Get the text string */

	  FIfld_get_text_length(fp, CATDESCR, 0, 0, &length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          status = FIfld_get_text(fp, CATDESCR, 0, 0, length,
                                 (unsigned char*)text,&select,&pos);

          if ( status != FI_SUCCESS )
            {
              /* Code to handle error */
              _pdm_debug("ERROR GETTING DESCRIPTION FROM CAT_NAME FORM", 0);
              msg = (char *)PDUtranslate_message(PDM_E_DESCRIPTION_FORM);
              FIg_set_text(forms.cat_name_form_id, FI_MSG_FIELD, msg);
              FIg_set_text(forms.cat_name_form_id, CATDESCR, "");
              break;
            }

          /* Code to process text string "text" */
         /* cat_desciption is a global structure to place the entered catalog
            description in the loc_data buffer */

         PDUfill_in_string(&PDU_cat_description, text);

         break;

    case ACL_LIST_BTN:         /* Field Type:    ASCII    */

          /* set message strip to "" */
          FIg_set_text(forms.cat_name_form_id, FI_MSG_FIELD, NULL_STRING);

          PDU_active_button = g_label;

          if (PDU_ret_bufr)
            {
            MEMclose(&PDU_ret_bufr);
            PDU_ret_bufr = NULL;
            }

          /* setup global variables for single list form */
          MEMsplit_copy_buffer(acl_bufr, &PDU_ret_bufr, 0);
          PDUsetup_single_buffer(PDU_ret_bufr);
          PDU_gadget_labels[0] = ACL;
          
          PDU_update_struct[0] = &PDU_cat_aclname;

          /* flag so buffer won't be erase */
          PDUfill_in_string(&PDU_popup_list_type, "sort");

          all_flag = FALSE;
          no_headings = 1;

          headings = (char **)malloc(sizeof (char *) * no_headings);
          memset(headings, NULL, sizeof (char *) * no_headings);

          PDUfill_in_string(&headings[0], "n_aclname");
          
          PDUsetup_popup_list(headings, no_headings, all_flag, 
                                       PDU_ret_bufr);

          PDUsetup_form_fields(headings, no_headings, all_flag,
                                        PDU_ret_bufr);

          PDUsetup_struct_fields(headings, no_headings, all_flag,
                                          PDU_ret_bufr);

          PDUfree_string_array(&headings, no_headings);
       
          status = PDUsingle_list_form();

         break;

    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

         _pdm_debug("f_label = <%d>", (char *)f_label);
         FIf_cvrt_to_perm_win(fp);
         status = PDUinitialize_help();
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }
         Help_topic("Create_cat1");

         break;

    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

          /* set refresh->catalog to NULL if command = CREATE_CATALOG */
          if ((PDU_command == PDC_M_CREATE_CATALOG) && ((refresh->rev_catalog !=
               NULL) && (strcmp(refresh->rev_catalog, "") != 0)))
            PDUfill_in_string(&refresh->rev_catalog, NULL);

          /* Erase the displayed form */

         FIf_delete ( fp );
         
         if (PDU_ret_bufr)
            {
            MEMclose(&PDU_ret_bufr);
            PDU_ret_bufr = NULL;
            }

	 PDU_command =0;
         PDU_form_id = forms.local_files_form_id;
         PDUrefresh_local_files_form();
         FIf_display(forms.local_files_form_id);

         break;

    case FI_RESET:

          PDU_command = PDC_M_CREATE_CATALOG;

         /* get acl if not already gotten */
         if (acl_bufr == NULL)
         {
         /* default catalog ACL */
         status = PDMcatalog_acls(&acl_bufr);
         _pdm_status("PDMcatalog_acls", status);
    
         if (status != PDM_S_SUCCESS)
           {
           _pdm_debug("Error getting ACLS from PDM", 0);
           PDUmessage(status, 's');
           break;
           }

         status = MEMbuild_array(acl_bufr);
         _pdm_status("MEMbuild_array(acl_bufr)", status);

         if (status != MEM_S_SUCCESS)
           _pdm_debug("Error in MEMbuild_array", 0);

         acl_data = (char **)acl_bufr->data_ptr;
         acl_cols = (char **)acl_bufr->column_ptr;

         for (i = 0; i < acl_bufr->columns; i++)
           if (strcmp(acl_cols[i],"n_aclname") == 0)
             {
             PDUfill_in_string(&PDU_cat_aclname, acl_data[i]);
             FIg_set_text(forms.cat_name_form_id, ACL, PDU_cat_aclname);
             break;
             }
          }
        else
          FIg_set_text(forms.cat_name_form_id, ACL, PDU_cat_aclname);

          if (acl_bufr->rows == 1)
            {
            FIg_erase(fp, ACL_LIST_BTN);
            FIg_disable(forms.cat_name_form_id, ACL_LIST_BTN);
            }

          if ((refresh->rev_catalog != NULL) && (strcmp(refresh->rev_catalog, 
               "") != 0))
             PDUfill_in_string(&refresh->rev_catalog, NULL);
          FIfld_set_text(fp, CATFLD, 0,0,"", FALSE);

         if ((PDU_cat_description != NULL) && (strcmp(PDU_cat_description, "")
            != 0))
           PDUfill_in_string(&PDU_cat_description, NULL);
         FIg_set_text(fp, CATDESCR, "");

         FIfld_get_num_rows(fp, CAT_CLASS_MCF, &num_rows);
         for (i = 0; i < num_rows; i++)
           FIfld_set_text(fp, CAT_CLASS_MCF,i,0,"",FALSE);
          FIfld_set_mode(fp, CAT_CLASS_MCF, 0, FI_SINGLE_SELECT);
          FIg_display(fp, CAT_CLASS_MCF);
 
         if ((PDU_template_catalog != NULL) && 
             (strcmp(PDU_template_catalog, "") != 0))
           PDUfill_in_string(&PDU_template_catalog, NULL);
         FIfld_set_text(fp, TEMP_CATALOG, 0,0,"", FALSE);
         FIfld_set_mode(fp, TEMP_CATALOG, 0, FI_INSERT);
         FIg_display(fp, TEMP_GRP);

         if ((PDU_default_usageid != NULL) && (strcmp(PDU_default_usageid, "")
             != 0))
           PDUfill_in_string(&PDU_default_usageid, NULL);
         FIfld_set_text(fp, DEF_USAGEID, 0,0,"", FALSE);

        FIg_erase(fp, DEF_USAGE_GRP);
        FIg_erase(fp, DELETE_CATALOG);
        FIg_erase(fp, CAT_LIST);
        FIg_erase(fp, UPDATE_CLASS);
        PDU_view = FALSE;
        PDU_parm_cat = FALSE;

        break;

    case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */

          /* set message strip to "" */
          FIg_set_text(forms.cat_name_form_id, FI_MSG_FIELD, NULL_STRING);

          /* Erase the displayed form */

          if ((refresh->rev_catalog == NULL) || 
              (strcmp(refresh->rev_catalog, "") == 0))
            {
            msg = (char *)PDUtranslate_message(PDM_E_CATNAME_NOT_FOUND);
            FIg_set_text(forms.cat_name_form_id, FI_MSG_FIELD, msg);
            FIg_set_state_off(forms.cat_name_form_id, FI_ACCEPT);
            break;
            }

       if (((PDU_cat_aclname == NULL) || (strcmp(PDU_cat_aclname, "") == 0)) && 
               (PDU_command != PDC_M_MODIFY_CATALOG))
            {
            msg = (char *)PDUtranslate_message(PDM_E_ACL_NAME_BLANK); 
            FIg_set_text(forms.cat_name_form_id, FI_MSG_FIELD, msg);
            FIg_set_state_off(forms.cat_name_form_id, FI_ACCEPT);
            break;
            }

          /* find aclno from aclname using the PDU_ret_bufr */
          if (PDU_command != PDC_M_MODIFY_CATALOG)
          {
          status = MEMbuild_array(acl_bufr);
          _pdm_status("MEMbuild_array", status);
          if (status != MEM_S_SUCCESS)
            {
            PDUmessage(PDM_E_BUILD_BUFFER_ARRAY, 's');
            break;
            }

          ret_data = (char **) acl_bufr->data_ptr;
          for (i = 0; i < acl_bufr->rows; i++)
            {
            if (strcmp(ret_data[(acl_bufr->columns * i) + 1], PDU_cat_aclname) 
                == 0)
              {
              PDUfill_in_string(&PDU_cat_aclno,
                                ret_data[(acl_bufr->columns * i)]);
              break;
              }
            }
          PDUfill_in_string(&PDU_cat_aclname, NULL);

          if (acl_bufr)
            {
            MEMclose(&acl_bufr);
            acl_bufr = NULL;
            }
          }

          /* get classification scheme from MCF */
            status = PDUget_classification_scheme();
            _pdm_status("PDUget_classification_scheme", status);

          if ((PDU_template_catalog) && (strcmp(PDU_template_catalog, "") != 0))
            PDU_command = PDC_M_CREATE_LIKE_CATALOG;

          refresh->command = PDU_command;
          status = PDUvalidate_access(refresh->command);

          if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            break;
            }

          GRdelete_pull_down_list(PDU_value_pulldown);
          GRdelete_pull_down_list(PDU_tempcat_pulldown);

          FIf_delete(fp);

          if (PDU_parm_cat)
            {
            PDUparametric_catalog_form();
            }
          else
            {
            PDUcatalog_attr_form();
            }

         break;

    case CAT_CLASS_MCF:         /* Field Type:    ASCII    */
 
         FIfld_get_active_row(fp, CAT_CLASS_MCF, &act_row, &pos);
         _pdm_debug("act_row = <%d>", (char *)act_row);
         
         FIfld_get_mode(fp, CAT_CLASS_MCF, 0,&mode);
         if (mode == FI_SINGLE_SELECT)
           {
           /* get classification levels from MCF */
           status = PDUload_classification(&input_buffer);
           _pdm_status("PDUload_classification", status);
           if ((status != PDM_S_SUCCESS) || (input_buffer == NULL))
             {
             PDUmessage(status, 's');
             break;
              }
              
            PDUload_exec_structure(refresh->rev_project, "", "", "", 
                                            "", "", "", 0, 0);

            _pdm_debug("calling PDMquery_classification", 0);
            status = PDMquery_classification(input_buffer, &class_buffer);
            _pdm_status("PDMquery_classification", status);

            if ((status != PDM_S_SUCCESS) || (class_buffer == NULL))
              {
             msg = (char *)PDUtranslate_message(PDM_E_NO_CLASSIFICATION_LEVEL);
             FIg_set_text(fp, FI_MSG_FIELD, msg);
              if (class_buffer)
               {
               MEMclose(&class_buffer);
               class_buffer = NULL;
               }
              FIfld_set_mode(fp, CAT_CLASS_MCF, 0, FI_INSERT);
              FIg_display(fp, CAT_CLASS_MCF);
              break;
              }

           /* clear out old values */
           for ( i = 0; i < list_size; i++)
              PDUfill_in_string(&PDU_value_list[i], "");

            if ((PDM_debug_on) && (class_buffer))
              MEMprint_buffer("classification buffer", class_buffer, 
                               PDU_DEBUG_FILE);

           MEMbuild_array(class_buffer);

           class_data = (char **)class_buffer->data_ptr;
           /* load values */
           PDUfill_in_string(&PDU_value_list[0], "new category");
           list_size = 1;
           for ( i = 0; i < class_buffer->rows; i++)
             if ((strcmp(class_data[(class_buffer->columns * i) + 1], "") != 0)
                && 
                (strcmp(class_data[(class_buffer->columns * i) + 4], "C") != 0))
             {
             PDUfill_in_string(&PDU_value_list[list_size], 
                               class_data[(class_buffer->columns * i) + 1]);
             list_size = list_size + 1;
             }

           /* put the values in the pull down list */
            PDUprocess_selected_pulldown_value(&act_row,pos,&list_size);
           }
         else
           {
           _pdm_debug("Verify classification path doesn't exist",0);
           }

         break; 

    case TEMP_CATALOG:

          /* set message strip to "" */
          FIg_set_text(forms.cat_name_form_id, FI_MSG_FIELD, NULL_STRING);

	  FIfld_get_text_length(fp, TEMP_CATALOG, 0, 0, &length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          status = FIfld_get_text(fp,TEMP_CATALOG,0,0,length,
                                  (unsigned char*)text,&select,&pos);

          if ( status != FI_SUCCESS )
            {
              /* Code to handle error */
              _pdm_debug("ERROR GETTING CATALOG NAME FROM CAT_NAME FORM",0);
              msg = (char *)PDUtranslate_message(PDM_E_CAT_NAME_FORM);
              FIg_set_text(forms.cat_name_form_id, FI_MSG_FIELD,msg);
              FIg_set_text(forms.cat_name_form_id, TEMP_CATALOG, "");
              break;
            }

           if (text == NULL)
             {
             if ((PDU_template_catalog) &&
                 (strcmp(PDU_template_catalog, "") != 0))
               PDUfill_in_string(&PDU_template_catalog, NULL);
             break;
             }
           else if (strcmp(text, "") == 0)
             {
             if ((PDU_template_catalog) &&
                 (strcmp(PDU_template_catalog, "") != 0))
               PDUfill_in_string(&PDU_template_catalog, NULL);
             break;
             }

          /* test and see if view first */
          status = PDMcheck_for_view(text);
          _pdm_status("PDMcheck_for_view", status);

          if (status == PDM_I_VIEW_FOUND)
            {
            _pdm_debug("Table name is a view", 0);
            FIg_set_text(fp, TEMP_CATALOG, "");
            msg = (char *)PDUtranslate_message(PDM_E_TEMPLATE_CAT_VIEW);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            if ((PDU_template_catalog) &&
                (strcmp(PDU_template_catalog, "") != 0))
              PDUfill_in_string(&PDU_template_catalog, NULL);
            break;
            }
        
           bufr_flag = FALSE;
          /* Code to process text string "text" */
          _pdm_debug("In TEMP CATALOG case of catname form", 0);

          /* validate catalog on the specific arg */
          status = PDUvalid_catalog("", text);
          _pdm_status("PDUvalid_catalog",status);
          if (status != PDM_S_SUCCESS) 
            {
            _pdm_debug("catalog <%s> is not valid", text);
            msg = (char *)PDUtranslate_message(PDM_E_CAT_NOT_FOUND);
            FIg_set_text(forms.cat_name_form_id, FI_MSG_FIELD, msg);
            FIg_set_text(forms.cat_name_form_id, TEMP_CATALOG, "");
            FIfld_pos_cursor(forms.cat_name_form_id, CATFLD, 0, 0, 0, 0, 1, 1);
            if (refresh->rev_catalog)
              PDUfill_in_string(&PDU_template_catalog, NULL);
            break;
            } 
          else
            PDUfill_in_string(&PDU_template_catalog, text);

          PDUcheck_catalog_template();
          PDUmessage(PDM_S_SUCCESS, 's');

          break;
    case TEMP_CAT_LIST:

          PDU_refresh_gadgets[1] = TEMP_CATALOG;
          PDU_active_button = TEMP_CAT_LIST;
          PDU_active_list = TEMP_CAT_LIST;
          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
         status = PDUep_cat_btn();
         _pdm_status("PDUep_cat_btn",status);

         break;

    case DEF_USAGEID:

         /* Get Text */
	  FIfld_get_text_length(fp, DEF_USAGEID, 0, 0, &length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          status = FIfld_get_text(fp,DEF_USAGEID,0,0,length,
                                  (unsigned char*)text,&select,&pos);

         /* verify text is valid */
         PDUfill_in_string(&PDU_default_usageid, text);

         break;

    case NEW_BUTTON:

         if (PDU_command == PDC_M_CREATE_CATALOG)
           break;

         /* get acl if not already gotten */
         if (acl_bufr == NULL)
         {
         /* default catalog ACL */
         status = PDMcatalog_acls(&acl_bufr);
         _pdm_status("PDMcatalog_acls", status);
    
         if (status != PDM_S_SUCCESS)
           {
           _pdm_debug("Error getting ACLS from PDM", 0);
           PDUmessage(status, 's');
           break;
           }

         status = MEMbuild_array(acl_bufr);
         _pdm_status("MEMbuild_array(acl_bufr)", status);

         if (status != MEM_S_SUCCESS)
           _pdm_debug("Error in MEMbuild_array", 0);

         acl_data = (char **)acl_bufr->data_ptr;
         acl_cols = (char **)acl_bufr->column_ptr;

         for (i = 0; i < acl_bufr->columns; i++)
           if (strcmp(acl_cols[i],"n_aclname") == 0)
             {
             PDUfill_in_string(&PDU_cat_aclname, acl_data[i]);
             FIg_set_text(forms.cat_name_form_id, ACL, PDU_cat_aclname);
             break;
             }
          }
        else
          FIg_set_text(forms.cat_name_form_id, ACL, PDU_cat_aclname);

         /* clear form for new mode */
         FIfld_set_text(fp, CATFLD,0,0, "", FALSE);

         if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
           PDUfill_in_string(&refresh->rev_catalog, NULL);

         FIg_set_text(fp, CATDESCR, "");
         if ((PDU_cat_description) && (strcmp(PDU_cat_description, "") != 0))
           PDUfill_in_string(&PDU_cat_description, NULL);

         /* get acls for new catalog */
         FIg_display(fp, ACL_GRP);

        if (acl_bufr->rows == 1)
          {
          FIg_erase(forms.cat_name_form_id, ACL_LIST_BTN);
          FIg_disable(forms.cat_name_form_id, ACL_LIST_BTN);
          }

         for (i = 0; i < list_size; i ++)
           FIfld_set_text(fp, CAT_CLASS_MCF, i, i, "", FALSE);

         FIfld_set_mode(fp, CAT_CLASS_MCF, 0, FI_SINGLE_SELECT);

         FIg_set_text(fp, DEF_USAGEID, "");
         if ((PDU_default_usageid) && (strcmp(PDU_default_usageid, "") != 0))
           PDUfill_in_string(&PDU_default_usageid, NULL);

         FIfld_set_text(fp, TEMP_CATALOG, 0, 0, "", FALSE);
         FIfld_set_mode(fp, TEMP_CATALOG, 0, FI_INSERT);
         if ((PDU_template_catalog) && (strcmp(PDU_template_catalog, "") != 0))
           PDUfill_in_string(&PDU_template_catalog, NULL);
         FIg_display(fp, TEMP_GRP);
         FIg_reset(fp, CAT_CLASS_MCF);

         FIg_erase(fp, DELETE_CATALOG);
         FIg_erase(fp, DEF_USAGE_GRP);
         FIg_erase(fp, CAT_LIST);
         FIg_erase(fp, UPDATE_CLASS);
         FIg_enable(fp, CATALOG_TYPE_TOG);
         FIg_set_state_off(fp, CATALOG_TYPE_TOG);
         PDU_parm_cat = FALSE;

         PDU_command = PDC_M_CREATE_CATALOG;
         break;

    case CHANGE_BUTTON:

         if (PDU_command == PDC_M_MODIFY_CATALOG)
           break;

         PDU_command = PDC_M_MODIFY_CATALOG;
         /* clear form for new mode */
         FIfld_set_text(fp, CATFLD,0,0, "", FALSE);

         if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
           PDUfill_in_string(&refresh->rev_catalog, NULL);

         FIg_set_text(fp, CATDESCR, "");
         if ((PDU_cat_description) && (strcmp(PDU_cat_description, "") != 0))
           PDUfill_in_string(&PDU_cat_description, NULL);


         FIg_erase(fp, ACL_GRP);

         for (i = 0; i < list_size; i ++)
           FIfld_set_text(fp, CAT_CLASS_MCF, i, i, "", FALSE);

         FIfld_set_mode (fp, CAT_CLASS_MCF, 0, FI_SINGLE_SELECT);

         FIg_set_text(fp, DEF_USAGEID, "");
         if ((PDU_default_usageid) && (strcmp(PDU_default_usageid, "") != 0))
           PDUfill_in_string(&PDU_default_usageid, NULL);

         FIg_reset(fp, CAT_CLASS_MCF);
         FIg_erase(fp, TEMP_GRP);
         FIg_disable(fp, DELETE_CATALOG);
         FIg_display(fp, DELETE_CATALOG);
         FIg_display(fp, CAT_LIST);
         FIg_disable(fp, UPDATE_CLASS);
         FIg_display(fp, UPDATE_CLASS);
         FIg_disable(fp, CATALOG_TYPE_TOG);

         break;

    case CATALOG_TYPE_TOG:

         FIg_get_state(fp, CATALOG_TYPE_TOG, &state);

         if (state == 0) 
           {
           PDU_parm_cat = FALSE;
           FIg_erase(fp, DEF_USAGE_GRP);
           }
         else
           {
           PDU_parm_cat = TRUE;
           FIg_display(fp, DEF_USAGE_GRP);
           }

         break;

    case CLASS_ASSOC_GADGET:
         
         list_row = value - 1;
         FIfld_get_num_rows(fp, CAT_CLASS_MCF, &num_rows);
         /* clear out any text below */
         _pdm_debug("act_row = %d", (char *)act_row);
         row = act_row;
         _pdm_debug("num_rows = %d", (char *)num_rows);
         for ( i = act_row; i < num_rows; i++)
           FIfld_set_text(fp, CAT_CLASS_MCF, i, 0, "", FALSE);
         if (strcmp(PDU_value_list[list_row], "new category") == 0)
           {
           FIfld_set_mode(fp, CAT_CLASS_MCF, 0, FI_INSERT);
           FIg_display(fp, CAT_CLASS_MCF);
           /*if (row != 0)
             row = row + 1;*/
           FIfld_pos_cursor(fp, CAT_CLASS_MCF, row, pos, 0,0,0,0);
           break;
           }
         FIfld_set_text(fp, CAT_CLASS_MCF, row, 0, PDU_value_list[list_row],
                        FALSE);
         FIfld_set_select(fp, CAT_CLASS_MCF, row, 0, FALSE);
         row = row + 1;
         FIfld_set_text(fp, CAT_CLASS_MCF, row, 0, "", FALSE);
         FIfld_set_active_row(forms.cat_name_form_id, CAT_CLASS_MCF, row, 0);
         FIfld_set_select(fp, CAT_CLASS_MCF, row, 0, FALSE);
           /* get classification levels from MCF */
           status = PDUload_classification(&input_buffer);
           _pdm_status("PDUload_classification", status);
           if ((status != PDM_S_SUCCESS) || (input_buffer == NULL))
             {
             PDUmessage(status, 's');
             break;
              }
              
            PDUload_exec_structure(refresh->rev_project, "", "", "", 
                                            "", "", "", 0, 0);

            _pdm_debug("calling PDMquery_classification", 0);
            status = PDMquery_classification(input_buffer, &class_buffer);
            _pdm_status("PDMquery_classification", status);

            if ((status != PDM_S_SUCCESS) || (class_buffer == NULL))
              {
             msg = (char *)PDUtranslate_message(PDM_E_NO_CLASSIFICATION_LEVEL);
             FIg_set_text(fp, FI_MSG_FIELD, msg);
              if (class_buffer)
               {
               MEMclose(&class_buffer);
               class_buffer = NULL;
               }
              FIfld_set_mode(fp, CAT_CLASS_MCF, 0, FI_INSERT);
              FIg_display(fp, CAT_CLASS_MCF);
              break;
              }

           /* clear out old values */
           for ( i = 0; i < list_size; i++)
              PDUfill_in_string(&PDU_value_list[i], "");

            if ((PDM_debug_on) && (class_buffer))
              MEMprint_buffer("classification buffer", class_buffer, 
                               PDU_DEBUG_FILE);

           MEMbuild_array(class_buffer);

           class_data = (char **)class_buffer->data_ptr;
           /* load values */
           PDUfill_in_string(&PDU_value_list[0], "new category");
           list_size = 1;
           for ( i = 0; i < class_buffer->rows; i++)
             if ((strcmp(class_data[(class_buffer->columns * i) + 1], "") != 0)
                && 
                (strcmp(class_data[(class_buffer->columns * i) + 4], "C") != 0))
             {
             PDUfill_in_string(&PDU_value_list[list_size], 
                               class_data[(class_buffer->columns * i) + 1]);
             list_size = list_size + 1;
             }

           act_row = act_row + 1;
           /* put the values in the pull down list */
           GRdelete_pull_down_list(PDU_value_pulldown);
           GRcreate_pull_down_list(CATALOG_NAME_FORM,forms.cat_name_form_id, 
                                   CLASS_ASSOC_GADGET, list_size, VIS_ROWS, 
                                   PDU_value_list,
                                   list_size, 1, &PDU_value_pulldown);
           GRchange_pull_down_text(PDU_value_pulldown, PDU_value_list,
                                   list_size);

           /* display the pulldown list */
           GRproc_pull_down_list(PDU_value_pulldown);
         /*FIfld_set_mode(fp, CAT_CLASS_MCF, 0, FI_SINGLE_SELECT);
         FIg_display(fp, CAT_CLASS_MCF);
         FIfld_set_text(fp, CAT_CLASS_MCF, row, 0, PDU_value_list[list_row],
                        FALSE);
         FIfld_set_select(fp, CAT_CLASS_MCF, row, 0, FALSE);
         row = row + 1;
         FIfld_set_text(fp, CAT_CLASS_MCF, row, 0, "", FALSE);*/
         
         
         break;

    case TEMPCAT_ASSOC_GADGET:
         
         list_row = value - 1;
         FIfld_set_text(fp, TEMP_CATALOG, 0,0,PDU_value_list[list_row], FALSE);
         PDUfill_in_string(&PDU_template_catalog, PDU_value_list[list_row]);
         
         break;

    case DELETE_CATALOG:

         FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);

         if (refresh->rev_catalog == NULL)
           {
           msg = (char *)PDUtranslate_message(PDM_E_CAT_NULL);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }
        else if (strcmp(refresh->rev_catalog, "") == 0)
           {
           msg = (char *)PDUtranslate_message(PDM_E_CAT_NULL);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }
        else if (strcmp(refresh->rev_catalog, "pdmseedfiles") == 0)
           {
           msg = (char *)PDUtranslate_message(PDM_E_SEEDFILES_NOT_DELETED);
           FIg_set_text(fp, FI_MSG_FIELD,msg);
           break;
           }

        if (PDU_ret_bufr)
          {
          MEMclose(&PDU_ret_bufr);
          PDU_ret_bufr = NULL;
          }

        if (!PDU_view)
        {
        status = PDMparts_listing(refresh->rev_catalog);
        _pdm_status("PDMpart_listing", status);

        if ((PDU_ret_bufr) && (PDU_ret_bufr->rows > 0))
          {
         msg = (char *)PDUtranslate_message(PDM_E_CAT_WITH_PART_NOT_DEL); 
         FIg_set_text(fp, FI_MSG_FIELD, msg);
         MEMclose(&PDU_ret_bufr);
         PDU_ret_bufr = NULL;
         PDUmessage(PDM_E_CATALOG_NOT_EMPTY, 's');
         break;
         }
        else if (PDU_ret_bufr)
          {
          MEMclose(&PDU_ret_bufr);
          PDU_ret_bufr = NULL;
          }
        }

         FIg_disable(fp, g_label);
         responses[0] = EX_CMD_KEY;

         strings[0] = "PDDlCt";

         status = PDUprepare_queue ( responses, strings, 1 );
         _pdm_status("PDUprepare_queue (delete catalog)",status);

         break;
         
    case UPDATE_CLASS:

          /* get classification scheme from MCF */
            status = PDUget_classification_scheme();
            _pdm_status("PDUget_classification_scheme", status);

         /* call function to change class */
         status = PDMstore_classification(PDU_cat_class_bufr);
         _pdm_status("PDMstore_classification", status);

         if (status != PDM_S_SUCCESS)
          {
           msg = (char *)PDUtranslate_message(PDM_E_CLASS_MODIFIED);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
          }
         else
           PDUmessage(status, 's');

         if (PDU_cat_class_bufr)
           {
           MEMclose(&PDU_cat_class_bufr);
           PDU_cat_class_bufr = NULL;
           }

         break;
           
  } /* END switch ( g_label ) */
  return(1);
} /* END cat_name_notification_routine() */

int cat_name_form()
{
  int  status;
  char **acl_data = NULL;
  char **acl_cols = NULL;
  char cat_type[5];
  int i;
  int list_size;
  MEMptr input_buffer = NULL;

  status = FIf_new(CATALOG_NAME_FORM, "Create_cat1", 
                cat_name_notification_routine,
                &forms.cat_name_form_id);

  _pdm_debug("Creating Catalog Name Form", 0);

  PDU_cat_name_create = TRUE;

  PDU_form_id = forms.cat_name_form_id;

    PDU_command = PDC_M_CREATE_CATALOG;

    if (acl_bufr)
      {
      MEMclose(&acl_bufr);
      acl_bufr = NULL;
      }

  /* clear otu refresh */
  if ((refresh->rev_project) && (strcmp(refresh->rev_project, "") != 0))
    PDUfill_in_string(&refresh->rev_project, NULL);
  if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
    PDUfill_in_string(&refresh->rev_catalog, NULL);
  if ((refresh->rev_partid) && (strcmp(refresh->rev_partid, "") != 0))
    PDUfill_in_string(&refresh->rev_partid, NULL);
  if ((refresh->rev_revision) && (strcmp(refresh->rev_revision, "") != 0))
    PDUfill_in_string(&refresh->rev_revision, NULL);
  if ((refresh->rev_description) && (strcmp(refresh->rev_description, "") != 0))
    PDUfill_in_string(&refresh->rev_description, NULL);
  if ((refresh->rev_filename) && (strcmp(refresh->rev_filename, "") != 0))
    PDUfill_in_string(&refresh->rev_filename, NULL);
  if ((refresh->rev_parttype) && (strcmp(refresh->rev_parttype, "") != 0))
    PDUfill_in_string(&refresh->rev_filename, NULL);

  if ((PDU_template_catalog) && (strcmp(PDU_template_catalog, "") != 0))
    PDUfill_in_string(&PDU_template_catalog, NULL);

  if ((PDU_default_usageid) && (strcmp(PDU_default_usageid, "") != 0))
    PDUfill_in_string(&PDU_default_usageid, NULL);
  if ((PDU_cat_description) && (strcmp(PDU_cat_description, "") != 0))
    PDUfill_in_string(&PDU_cat_description, NULL);
  /* if command = PDC_M_MODIFY_CATALOG delete ACL gadgets */
  if (PDU_command == PDC_M_MODIFY_CATALOG)
     {
     FIg_erase(forms.cat_name_form_id, ACL_GRP);
     FIg_erase(forms.cat_name_form_id, TEMP_GRP);
     FIg_set_state_on(forms.cat_name_form_id, CHANGE_BUTTON);
     FIg_set_state_off(forms.cat_name_form_id, NEW_BUTTON);
     status = PDMquery_catalog_type(refresh->rev_catalog, cat_type);
     _pdm_status("PDMquery_catalog_type", status);
     _pdm_debug("cat_type = <%s>", cat_type);

     if ((strcmp(cat_type, "P") == 0) || (strcmp(cat_type, "PXT") == 0))
       {
       FIg_set_state_on(forms.cat_name_form_id, CATALOG_TYPE_TOG);
       FIg_disable(forms.cat_name_form_id, CATALOG_TYPE_TOG);
       PDU_parm_cat = TRUE;
       PDU_view = FALSE;
       }
    else if ((strcmp(cat_type, "CID") == 0) || (strcmp(cat_type, "EID") 
              == 0))
      {
      FIg_set_state_on(forms.cat_name_form_id, CATALOG_TYPE_TOG);
      FIg_disable(forms.cat_name_form_id, CATALOG_TYPE_TOG);
      PDU_parm_cat = TRUE;
      PDU_view = TRUE;
      }
    else
      {
      FIg_set_state_off(forms.cat_name_form_id, CATALOG_TYPE_TOG);
      FIg_disable(forms.cat_name_form_id, CATALOG_TYPE_TOG);
      FIg_erase(forms.cat_name_form_id, DEF_USAGE_GRP);
      PDU_parm_cat = FALSE;
      PDU_view = FALSE;
      }
                
     /* set the mode to fields with pulldowns to single_select */
     FIfld_set_mode(forms.cat_name_form_id, CAT_CLASS_MCF, 0, FI_SINGLE_SELECT);
     /* get catalog type from PDM  and description*/

     FIfld_set_text(forms.cat_name_form_id, CATFLD, 0, 0, refresh->rev_catalog,
                    FALSE);

     /* find default_usageid */
    if ((PDU_default_usageid != NULL) && (strcmp(PDU_default_usageid, "") != 0))
      PDUfill_in_string(&PDU_default_usageid, NULL);

    /* call PDM function to get stored usageid */
    status = PDMget_usageid_cat(refresh->rev_catalog, &PDU_default_usageid);
    _pdm_status("PDMget_usageid", status);

    if ((status == PDM_S_SUCCESS) && (PDU_default_usageid != NULL) && 
        (strcmp(PDU_default_usageid, "") != 0))
      FIg_set_text(forms.cat_name_form_id, DEF_USAGEID, PDU_default_usageid);
    status = PDMget_class_of_cat(refresh->rev_catalog, &input_buffer);
    _pdm_status("PDMget_class_of_cat", status);

    if ((PDM_debug_on) && (input_buffer))
      MEMprint_buffer("classification buffer", input_buffer, PDU_DEBUG_FILE);
    if ((status == PDM_I_NO_CLASS) || (input_buffer == NULL))
      FIg_enable(forms.cat_name_form_id,CAT_CLASS_MCF);
    else if (status != PDM_S_SUCCESS)
      FIg_enable(forms.cat_name_form_id, CAT_CLASS_MCF);
    else
      {
      status = PDUfill_in_class(input_buffer);
      _pdm_status("PDUfill_in_class", status);
      }
    }
  else
    {
    /* default catalog ACL */
    status = PDMcatalog_acls(&acl_bufr);
    _pdm_status("PDMcatalog_acls", status);
    
    if (status != PDM_S_SUCCESS)
      {
      _pdm_debug("Error getting ACLS from PDM", 0);
       PDU_command =0;
       PDU_form_id = forms.local_files_form_id;
      PDUrefresh_local_files_form();
      FIf_display(forms.local_files_form_id);
      return(status);
      }

    status = MEMbuild_array(acl_bufr);
    _pdm_status("MEMbuild_array(acl_bufr)", status);

    if (status != MEM_S_SUCCESS)
      _pdm_debug("Error in MEMbuild_array", 0);

    acl_data = (char **)acl_bufr->data_ptr;
    acl_cols = (char **)acl_bufr->column_ptr;

    for (i = 0; i < acl_bufr->columns; i++)
      if (strcmp(acl_cols[i],"n_aclname") == 0)
        {
        PDUfill_in_string(&PDU_cat_aclname, acl_data[i]);
        FIg_set_text(forms.cat_name_form_id, ACL, PDU_cat_aclname);
        break;
        }

    if (acl_bufr->rows == 1)
      FIg_erase(forms.cat_name_form_id, ACL_LIST_BTN);

    FIg_erase(forms.cat_name_form_id, DEF_USAGE_GRP);
    FIg_erase(forms.cat_name_form_id, DELETE_CATALOG);
    FIg_erase(forms.cat_name_form_id, CAT_LIST);
    FIg_erase(forms.cat_name_form_id, UPDATE_CLASS);
    /* set the mode to fields with pulldowns to single_select */
    FIfld_set_mode(forms.cat_name_form_id, CAT_CLASS_MCF, 0, FI_SINGLE_SELECT);
    FIfld_set_mode(forms.cat_name_form_id, TEMP_CATALOG, 0, FI_INSERT);
    }

  /* Create pulldown list */
  list_size = 0;
  /*GRcreate_pull_down_list(CATALOG_NAME_FORM,forms.cat_name_form_id, 
                         CLASS_ASSOC_GADGET, MAX_ROWS, VIS_ROWS, PDU_value_list,
                          list_size, 1, &PDU_value_pulldown);*/

  GRcreate_pull_down_list(CATALOG_NAME_FORM,forms.cat_name_form_id, 
                         TEMPCAT_ASSOC_GADGET, MAX_ROWS, VIS_ROWS, 
                          PDU_value_list,
                          list_size, 1, &PDU_tempcat_pulldown);

  /* Display the catalog name form and set the displayed flag to TRUE. */

  _pdm_debug("Displaying the Catalog Name Form", 0);

  status = FIf_display(forms.cat_name_form_id);
  if (PDU_command != PDC_M_MODIFY_CATALOG)
    FIfld_pos_cursor(forms.cat_name_form_id, CATFLD, 0, 0, 0, 0, 1, 1);
  PDU_cat_name_display = TRUE;

  if (PDU_extadmin)
    FIg_erase(forms.cat_name_form_id, CATALOG_TYPE_TOG);

  return(status); 
}

int PDUcatalog_name_form()

{
  int status;

  PDU_cat_name_create = FALSE;
  PDU_cat_name_display = FALSE;

  /* initialize global vairiables to display catalog attribute form */
  PDU_parm_cat = FALSE;
  PDU_view = FALSE;

  _pdm_debug("Calling cat_name_form", 0);
  status = cat_name_form();
  _pdm_status("cat_name_form", status);

  if (status == FI_SUCCESS)
    status = PDM_S_SUCCESS;

  return(status);
}

int PDUget_classification_scheme()

  {
  int status;
  int num_rows;
  int i;
  int char_index;
  int select, pos, length;
  char *row = NULL;
  char *text = NULL;

  _pdm_debug("In PDUget_classification_scheme",0);
  
  if (PDU_cat_class_bufr)
    {
    MEMclose(&PDU_cat_class_bufr);
    PDU_cat_class_bufr = NULL;
    }

  /* format classification_buffer */
  FIfld_get_num_rows(forms.cat_name_form_id, CAT_CLASS_MCF, &num_rows);
  _pdm_debug("Num rows = %d", (char *)num_rows);
  for ( i = 0; i < num_rows; i ++)
     {
     FIfld_set_active_row(forms.cat_name_form_id, CAT_CLASS_MCF, i, 0);
     FIfld_get_text_length(forms.cat_name_form_id,CAT_CLASS_MCF,i,0,&length);
     text = (char *) malloc (sizeof (char) * length + 1);
     memset(text, NULL, sizeof (char) * length + 1);
     FIfld_get_text(forms.cat_name_form_id,CAT_CLASS_MCF,i,0,length,
                    (unsigned char*)text,
                    &select,&pos);

     if (text == NULL) 
       break; 
     else if (strcmp(text, "") == 0)
       break;
     }
  num_rows = i;
  _pdm_debug("Num rows = %d", (char *)num_rows);

  status = PDUformat_cat_class_bufr(num_rows,&PDU_cat_class_bufr);
  _pdm_status("PDUformat_cat_class_bufr", status);

  if (status != PDM_S_SUCCESS)
    return(status);

  if (PDM_debug_on)
   MEMprint_buffer("classification_buffer", PDU_cat_class_bufr, PDU_DEBUG_FILE);

  row = (char *)malloc(PDU_cat_class_bufr->row_size);
  memset(row, NULL, PDU_cat_class_bufr->row_size);

  char_index = 0;
  PDUadd_buffer_string(row, &char_index, refresh->rev_catalog);

  if ((PDU_default_usageid != NULL) && (strcmp(PDU_default_usageid, "") != 0))
    PDUadd_buffer_string(row, &char_index, PDU_default_usageid);
  else
    row[char_index++] = '\1';

  /* write catalog name to buffer */
  for (i = 0; i < num_rows; i++)
    {
    /* get text for each row */
    FIfld_set_active_row(forms.cat_name_form_id,CAT_CLASS_MCF, i, i);
    FIfld_get_text_length(forms.cat_name_form_id,CAT_CLASS_MCF,i,0,&length);
    text = (char *) malloc (sizeof (char) * length + 1);
    memset(text, NULL, sizeof (char) * length + 1);
    FIfld_get_text(forms.cat_name_form_id,CAT_CLASS_MCF,i,0,length,
                   (unsigned char *)text,
                   &select,&pos);
    /* write text to buffer */
    if ((text != NULL) && (strcmp(text, "") != 0))
     PDUadd_buffer_string(row, &char_index,text);
    else
      row[char_index++] = '\1';
    }
  status = MEMwrite(PDU_cat_class_bufr, row);
  _pdm_status("MEMwrite", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_BUFFER);

  if (PDM_debug_on)
   MEMprint_buffer("classification_buffer", PDU_cat_class_bufr, PDU_DEBUG_FILE);
  free(row);
  return(PDM_S_SUCCESS);
  }

int PDUload_classification(input_buffer)

MEMptr *input_buffer;

  {
  int status;
  int act_row;
  int i;
  int select, pos, length;
  char *row = NULL;
  char *text = NULL;

  _pdm_debug("In PDUload_classification_buffer", 0);

  status = PDUformat_classification_buffer(input_buffer);
  _pdm_status("PDUformat_classification_buffer", status);

  if (status != PDM_S_SUCCESS)
    return(status);

  FIfld_get_active_row(forms.cat_name_form_id, CAT_CLASS_MCF, &act_row, &pos);
  _pdm_debug("act_row = <%d>", (char *)act_row);
  
  /* don't include row selected */
  /*act_row = act_row - 1;
  _pdm_debug("act_row = <%d>", act_row);*/

  row = (char *)malloc((*input_buffer)->row_size);
  memset(row, NULL, (*input_buffer)->row_size);
  if (act_row == 0)
    {
    sprintf(row, "\1\1");
    status = MEMwrite(*input_buffer, row);
    _pdm_status("MEMwrite", status);
    if (status != MEM_S_SUCCESS)
      status = PDM_E_WRITE_BUFFER;
    else
      status = PDM_S_SUCCESS;
    }

  for (i = 0; i < act_row; i ++)
    {
    FIfld_set_active_row(forms.cat_name_form_id, CAT_CLASS_MCF, i, i);
    FIfld_get_text_length(forms.cat_name_form_id,CAT_CLASS_MCF,i,0,&length);
    text = (char *) malloc (sizeof (char) * length + 1);
    memset(text, NULL, sizeof (char) * length + 1);
    FIfld_get_text(forms.cat_name_form_id,CAT_CLASS_MCF,i,0,length,
                   (unsigned char*)text,
                   &select,&pos);
    sprintf(row, "%d\1%s\1", (i + 1), text);
    status = MEMwrite(*input_buffer, row);
    _pdm_status("MEMwrite", status);
    if (status != MEM_S_SUCCESS)
      {
      status = PDM_E_WRITE_BUFFER;
      break;
      }
    else
      status = PDM_S_SUCCESS;
    memset(row, NULL, (*input_buffer)->row_size);
    }

  if (PDM_debug_on)
   MEMprint_buffer("classification_buffer", *input_buffer, PDU_DEBUG_FILE);
  return(status);
  }

int PDUfill_in_class(input_buffer)
MEMptr input_buffer;

  {
  int status;
  int i;
  char **input_data = NULL;
  
  _pdm_debug("PDUfill_in_class", 0);
  FIg_reset(forms.cat_name_form_id, CAT_CLASS_MCF);

  status = MEMbuild_array(input_buffer);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  input_data = (char **)input_buffer->data_ptr;

  for (i = 0; i < input_buffer->columns; i ++)
    FIfld_set_text(forms.cat_name_form_id, CAT_CLASS_MCF, i, 0,  
                   input_data[i], FALSE);

  return(PDM_S_SUCCESS);
  }
int PDUcheck_catalog_commands()

  {
  int status;
  char cat_type[5];
  MEMptr input_buffer = NULL;

  _pdm_debug("In PDUcheck_catalog_commands", 0);

  if (forms.cat_name_form_id == NULL)
    return(PDM_S_SUCCESS);
  if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
    {
    FIg_enable(forms.cat_name_form_id, DELETE_CATALOG);
    FIg_enable(forms.cat_name_form_id, UPDATE_CLASS);
    FIg_set_text(forms.cat_name_form_id, CATFLD, 
                 refresh->rev_catalog);
    status = PDUget_catalog_description();
     _pdm_status("PDUget_catalog_description", status);

    FIg_set_text(forms.cat_name_form_id, CATDESCR, PDU_cat_description);
    status = PDMquery_catalog_type(refresh->rev_catalog, cat_type);
    _pdm_status("PDMquery_catalog_type", status);
    if ((strcmp(cat_type, "P") == 0) || (strcmp(cat_type, "PXT") == 0))
      {
      FIg_set_state_on(forms.cat_name_form_id, CATALOG_TYPE_TOG);
      FIg_disable(forms.cat_name_form_id, CATALOG_TYPE_TOG);
      PDU_parm_cat = TRUE;
      PDU_view = FALSE;
      }
    else if ((strcmp(cat_type, "CID") == 0) || (strcmp(cat_type, "EID") == 0))
      {
      FIg_set_state_on(forms.cat_name_form_id, CATALOG_TYPE_TOG);
      FIg_disable(forms.cat_name_form_id, CATALOG_TYPE_TOG);
      PDU_parm_cat = TRUE;
      PDU_view = TRUE;
      }
    else
      {
      FIg_set_state_off(forms.cat_name_form_id, CATALOG_TYPE_TOG);
      FIg_disable(forms.cat_name_form_id, CATALOG_TYPE_TOG);
      FIg_erase(forms.cat_name_form_id, DEF_USAGE_GRP);
      PDU_parm_cat = FALSE;
      PDU_view = FALSE;
      }
                
    /* call PDM function to get stored usageid */
    status = PDMget_usageid_cat(refresh->rev_catalog, 
                                &PDU_default_usageid);
     _pdm_status("PDMget_usageid", status);

    if ((status == PDM_S_SUCCESS) && (PDU_default_usageid != NULL) && 
         (strcmp(PDU_default_usageid, "")!= 0))
      FIg_set_text(forms.cat_name_form_id, DEF_USAGEID, 
                   PDU_default_usageid);

   status = PDMget_class_of_cat(refresh->rev_catalog, &input_buffer);
   _pdm_status("PDMget_class_of_cat", status);

   if ((PDM_debug_on) && (input_buffer))
     MEMprint_buffer("classification buffer", input_buffer, PDU_DEBUG_FILE);
   if ((status == PDM_I_NO_CLASS) || (input_buffer == NULL))
     FIg_enable(forms.cat_name_form_id,CAT_CLASS_MCF);
   else if (status != PDM_S_SUCCESS)
      FIg_enable(forms.cat_name_form_id, CAT_CLASS_MCF);
   else
    {
     status = PDUfill_in_class(input_buffer);
     _pdm_status("PDUfill_in_class", status);
    }
    }
  else
    {
    FIg_disable(forms.cat_name_form_id, DELETE_CATALOG);
    FIg_disable(forms.cat_name_form_id, UPDATE_CLASS);
    FIg_set_text(forms.cat_name_form_id, CATFLD, "");
    FIg_set_text(forms.cat_name_form_id, CATDESCR, "");
    }
  return(PDM_S_SUCCESS);
  }

int PDUcheck_for_class()

  {
  int status;
  int i;
  int num_rows;
  int sel_flag;
  int select, pos, length;
  char *text = NULL;
  char **class_data = NULL;

  _pdm_debug("In PDUcheck_for_class", 0);

  status = MEMbuild_array(PDU_cat_class_bufr);
  _pdm_status("MEMbuild_array", status);
  
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  class_data = (char **)PDU_cat_class_bufr->data_ptr;

  FIfld_get_num_rows(forms.class_cat_form_id,12,&num_rows);
  _pdm_debug("num_rows = <%d>", (char *)num_rows);
  for (i = 0; i < num_rows; i++)
    {
    FIfld_get_select(forms.class_cat_form_id,12,i,0,&sel_flag);
    if (sel_flag)
      {
      FIfld_set_active_row(forms.class_cat_form_id,12,i,0);
      FIfld_get_text_length(forms.class_cat_form_id,12,i,0,&length);
      text = (char *) malloc (sizeof (char) * length + 1);
      memset(text, NULL, sizeof (char) * length + 1);
      FIfld_get_text(forms.class_cat_form_id,12,i,0,length,(unsigned char*)text,
                     &select,&pos);
      break;
      }
    }
     
  _pdm_debug("text = <%s>", text);
  _pdm_debug("row = <%d>", (char *)PDU_cat_class_bufr->rows);
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
        status = PDM_E_FAILURE;
        break;
        }
      else
        {
        _pdm_debug("classification selected ", 0);
        status = PDM_S_SUCCESS;
        break;
        }
      }
    }
  return(status);
  }

int PDUget_classification_for_listing()

  {
  int status;
  int no_headings;
  int all_flag;
  int select, pos, length, act_row = 0;
  char **headings = NULL;
  char *text = NULL;
  char *row = NULL;

  _pdm_debug("In PDUget_classification_for_listing", 0);

  if (PDU_class_level == 0)
    {
    if (PDU_query_class_bufr)
      {
      MEMclose(&PDU_query_class_bufr);
      PDU_query_class_bufr = NULL;
      }
    status = PDUformat_classification_buffer(&PDU_query_class_bufr);
    _pdm_status("PDUformat_classification", status);

    if (status != PDM_S_SUCCESS)
      return(status);
    }

  PDU_class_level = PDU_class_level + 1;
  _pdm_debug("PDU_class_level = <%d>", (char *)PDU_class_level);
  FIfld_get_active_row(forms.class_cat_form_id, 12, &act_row, &pos);
  FIfld_get_text_length(forms.class_cat_form_id,12,act_row,0,&length);
  text = (char *) malloc (sizeof (char) * length + 1);
  memset(text, NULL, sizeof (char) * length + 1);
  FIfld_get_text(forms.class_cat_form_id,12,act_row,0,length,
                 (unsigned char*)text, &select,
                 &pos);

  row = (char *)malloc(PDU_query_class_bufr->row_size);
  memset(row, NULL, PDU_query_class_bufr->row_size);

  sprintf(row, "%d\1%s\1", PDU_class_level,text);
  _pdm_debug("row = <%s>", row);
  status = MEMwrite(PDU_query_class_bufr, row);
  _pdm_status("MEMwrite", status);

  if (status != MEM_S_SUCCESS) 
    return(PDM_E_WRITE_BUFFER);

  if (PDU_cat_class_bufr)
    {
    MEMclose(&PDU_cat_class_bufr);
    PDU_cat_class_bufr = NULL;
    }

  if ((PDU_form_id == forms.part_operations_form_id) &&
      (PDU_gadget_labels[0] == NP_CATALOG_FLD))
    PDUload_exec_structure(refresh->new_project, "", "", "", "", "", "", 0, 0);
  else
    PDUload_exec_structure(refresh->rev_project, "", "", "", "", "", "", 0, 0);

  status = PDMquery_classification(PDU_query_class_bufr, &PDU_cat_class_bufr);
  _pdm_status("PDMquery_classification", status);

  if ((status != PDM_S_SUCCESS) || (PDU_cat_class_bufr == NULL))
    {
    PDU_list_cat = FALSE;
    end_ep_cat_btn_flag = FALSE;
    end_np_cat_btn_flag = FALSE;
    return(PDM_I_NO_CLASS);
    }
  else if (PDU_cat_class_bufr->rows == 0)
    {
    PDUmessage(PDM_E_NO_CATALOG_MAP, 's');
    PDU_list_cat = FALSE;
    end_ep_cat_btn_flag = FALSE;
    end_np_cat_btn_flag = FALSE;
    return(PDM_E_NO_CATALOG_MAP);
    }

  if (PDU_ret_bufr)
    {
    MEMclose(&PDU_ret_bufr);
    PDU_ret_bufr = NULL;
    }

  status = PDUcreate_class_and_catalog_bufr(PDU_cat_class_bufr, &PDU_ret_bufr);
  _pdm_status("PDUcreate_class_and_catalog_bufr", status);

  if (status != PDM_S_SUCCESS)
    return(status);

  if (PDU_ret_bufr->rows == 0)
    {
    PDUmessage(PDM_E_NO_CATALOG_MAP, 's');
    return(PDM_E_NO_CATALOG_MAP);
    }

  FIf_delete(forms.class_cat_form_id);
  PDU_mcf_list_created = FALSE;
   if ((PDM_debug_on) && (PDU_ret_bufr))
     MEMprint_buffer("classification buffer", PDU_ret_bufr, PDU_DEBUG_FILE);
  PDUsetup_single_buffer(PDU_ret_bufr);
   if ((PDM_debug_on) && (PDU_ret_bufr))
     MEMprint_buffer("classification buffer", PDU_ret_bufr, PDU_DEBUG_FILE);
   if ((PDU_form_id == forms.part_operations_form_id) &&
       (end_ep_cat_btn_flag))
      PDU_gadget_labels[0] = EP_CATALOG_FLD;
   else if ((PDU_form_id == forms.part_operations_form_id) &&
       (end_np_cat_btn_flag))
      PDU_gadget_labels[0] = NP_CATALOG_FLD;
   else if (PDU_form_id == forms.local_files_form_id)
      PDU_gadget_labels[0] = CATALOG_FLD;
   else if (PDU_form_id == forms.design_form_id)
      PDU_gadget_labels[0] = CATALOG;
   else if (PDU_form_id == forms.report_form_id)
      PDU_gadget_labels[0] = CATALOG_NAME;
   else if (PDU_form_id == forms.bom_contents_form_id)
      PDU_gadget_labels[0] = CAT_NAME;
   else if (PDU_form_id == forms.topdown_form_id)
      PDU_gadget_labels[0] = TD_CATALOG;
   else if (PDU_form_id == forms.seed_form_form_id)
      PDU_gadget_labels[0] = NFC_CATALOG_FLD;
   else if (PDU_form_id == forms.define_lib_form_id)
      PDU_gadget_labels[0] = CAT_NAME_FLD;
     /* ALR   TR139418288  */
   else if (PDU_form_id == forms.ex_file_form_id)
      PDU_gadget_labels[0] = EX_CATALOG_FLD;
   else if ((PDU_form_id == forms.cat_name_form_id) && 
            (PDU_command == PDC_M_MODIFY_CATALOG))
      PDU_gadget_labels[0] = CATFLD;
   else if (PDU_form_id == forms.cat_name_form_id)
      PDU_gadget_labels[0] = TEMP_CATALOG;

   if ((PDU_load_assy == FALSE) && (end_np_cat_btn_flag == TRUE))
     PDU_update_struct[0] = &refresh->new_catalog;
   else if (PDU_load_assy == FALSE)
     PDU_update_struct[0] = &refresh->rev_catalog;
   else
     PDU_update_struct[0] = &PDU_assy_catalog;

   if ((PDU_form_id == forms.cat_name_form_id) && 
       (PDU_command == PDC_M_MODIFY_CATALOG))
     {
     _pdm_debug("Modify Catalog",0);
     PDU_update_struct[0] = &refresh->rev_catalog;
     }
   else if (PDU_form_id == forms.cat_name_form_id)
     {
     _pdm_debug("Copy and Change Catalog", 0);
     PDU_update_struct[0] = &PDU_template_catalog;
     }

   all_flag = TRUE;
   no_headings = 1;
   headings = (char **) malloc (sizeof (char *) * no_headings);
   memset(headings, NULL, sizeof (char *) * no_headings);

   PDUfill_in_string(&headings[0], "n_name");
   PDUsetup_popup_list(headings, no_headings, all_flag,
            PDU_ret_bufr);

   all_flag = FALSE;
   PDUsetup_form_fields(headings, no_headings, all_flag,
            PDU_ret_bufr);

   PDUsetup_struct_fields(headings, no_headings, all_flag,
            PDU_ret_bufr);

   PDUfree_string_array(&headings, no_headings);

   PDUclass_cat_list_form();

   if (PDM_debug_on) 
     MEMprint_buffer("classification buffer", PDU_ret_bufr, PDU_DEBUG_FILE);
  return(PDM_S_SUCCESS);
  }

int PDUcheck_catalog_template()

  {
  int status;
  char cat_type[5];
  char *msg;

  _pdm_debug("In PDUcheck_catalog_commands", 0);

  if ((PDU_template_catalog) && (strcmp(PDU_template_catalog, "") != 0))
    {
    status = PDMquery_catalog_type(PDU_template_catalog, cat_type);
    _pdm_status("PDMquery_catalog_type", status);
    if ((strcmp(cat_type, "P") == 0) || (strcmp(cat_type, "CID") == 0) ||
         (strcmp(cat_type, "EID") == 0) || (strcmp(cat_type, "PXT") == 0))
      {
      FIg_set_text(forms.cat_name_form_id, TEMP_CATALOG, "");
      msg = (char *)PDUtranslate_message(PDM_E_TEMPLATE_NOT_PARAM);
      FIg_set_text(forms.cat_name_form_id, FI_MSG_FIELD,msg);
      }
    }

  return(PDM_S_SUCCESS);
  }

int PDUcheck_catalog_char(filename,spec_char)

char  * filename;
char  * spec_char;

{
  int             string_len;
  int             char_index;
  int             status = PDM_S_SUCCESS;

           if (strchr(filename, '\'') != NULL)
                   {
                   *spec_char = '\'';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
            string_len = strlen(filename);

            for (char_index = 0; char_index < string_len; ++char_index)
                {
                if (filename[char_index] == '.')
                   {
                   *spec_char = '.';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == ';')
                   {
                   *spec_char = ';';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == ' ')
                   {
                   *spec_char = ' ';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '=')
                   {
                   *spec_char = '=';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '!')
                   {
                   *spec_char = '!';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '*')
                   {
                   *spec_char = '*';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '\\')
                   {
                   *spec_char = '\\';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '(')
                   {
                   *spec_char = '(';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == ')')
                   {
                   *spec_char = ')';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '{')
                   {
                   *spec_char = '{';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '}')
                   {
                   *spec_char = '}';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '[')
                   {
                   *spec_char = '[';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == ']')
                   {
                   *spec_char = ']';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '<')
                   {
                   *spec_char = '<';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '>')
                   {
                   *spec_char = '>';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '&')
                   {
                   *spec_char = '&';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '?')
                   {
                   *spec_char = '?';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '$')
                   {
                   *spec_char = '$';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '@')
                   {
                   *spec_char = '@';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '+')
                   {
                   *spec_char = '+';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '-')
                   {
                   *spec_char = '-';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == ':')
                   {
                   *spec_char = ':';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else if (filename[char_index] == '|')
                   {
                   *spec_char = '|';
                   status = PDM_E_BAD_DATA;
                   return(status);
                   }
                else
                   status = PDM_S_SUCCESS;
                }
return(status);
}

int PDUprocess_selected_pulldown_value(act_row,pos,list_size)
int *act_row;
int pos;
int *list_size;
{

  int num_rows;
  int row;
  int list_row = 0;
  int i;
  int ind;
  int sts;
  int status;
  MEMptr class_buffer = NULL;
  MEMptr input_buffer = NULL;
  char          **class_data = NULL;
  char *msg;

  _pdm_debug("In PDUprocess_selected_pulldown_value", 0);
  if (*list_size == 1)
    {
    row = *act_row;
    FIfld_set_mode(forms.cat_name_form_id, CAT_CLASS_MCF, 0, FI_INSERT);
    FIg_display(forms.cat_name_form_id, CAT_CLASS_MCF);
    FIfld_pos_cursor(forms.cat_name_form_id, CAT_CLASS_MCF, row, pos, 0,0,0,0);
    return(0);
    }
  pull_main(CATALOG_NAME_FORM,forms.cat_name_form_id, 
            CAT_CLASS_MCF, 0,0,PDU_value_list,*list_size, 1,
            0, VIS_ROWS, &sts, &ind);
  if (!sts)
    return(0);
  list_row = ind;
  FIfld_get_num_rows(forms.cat_name_form_id, CAT_CLASS_MCF, &num_rows);
  /* clear out any text below */
  _pdm_debug("act_row = %d", (char *)act_row);
  row = *act_row;
   _pdm_debug("num_rows = %d", (char *)num_rows);
  for ( i = *act_row; i < num_rows; i++)
  FIfld_set_text(forms.cat_name_form_id, CAT_CLASS_MCF, i, 0, "", FALSE);
  if (strcmp(PDU_value_list[list_row], "new category") == 0)
    {
    FIfld_set_mode(forms.cat_name_form_id, CAT_CLASS_MCF, 0, FI_INSERT);
    FIg_display(forms.cat_name_form_id, CAT_CLASS_MCF);
    FIfld_pos_cursor(forms.cat_name_form_id, CAT_CLASS_MCF, row, pos, 0,0,0,0);
    return(0);
    }
  FIfld_set_text(forms.cat_name_form_id, CAT_CLASS_MCF, row, 0, 
                 PDU_value_list[list_row],
                 FALSE);
  FIfld_set_select(forms.cat_name_form_id, CAT_CLASS_MCF, row, 0, FALSE);
  row = row + 1;
  FIfld_set_text(forms.cat_name_form_id, CAT_CLASS_MCF, row, 0, "", FALSE);
  FIfld_set_active_row(forms.cat_name_form_id, CAT_CLASS_MCF, row, 0);
  FIfld_set_select(forms.cat_name_form_id, CAT_CLASS_MCF, row, 0, FALSE);
  /* get classification levels from MCF */
  status = PDUload_classification(&input_buffer);
  _pdm_status("PDUload_classification", status);
  if ((status != PDM_S_SUCCESS) || (input_buffer == NULL))
    {
    PDUmessage(status, 's');
    return(0);
    }
         
  PDUload_exec_structure(refresh->rev_project, "", "", "", 
                         "", "", "", 0, 0);

  _pdm_debug("calling PDMquery_classification", 0);
  status = PDMquery_classification(input_buffer, &class_buffer);
  _pdm_status("PDMquery_classification", status);

  if ((status != PDM_S_SUCCESS) || (class_buffer == NULL))
    {
    msg = (char *)PDUtranslate_message(PDM_E_NO_CLASSIFICATION_LEVEL);
    FIg_set_text(forms.cat_name_form_id, FI_MSG_FIELD, msg);
    if (class_buffer)
      {
      MEMclose(&class_buffer);
      class_buffer = NULL;
      }
    FIfld_set_mode(forms.cat_name_form_id, CAT_CLASS_MCF, 0, FI_INSERT);
    FIg_display(forms.cat_name_form_id, CAT_CLASS_MCF);
    return(0);
    }

   /* clear out old values */
   for ( i = 0; i < *list_size; i++)
      PDUfill_in_string(&PDU_value_list[i], "");

    if ((PDM_debug_on) && (class_buffer))
         MEMprint_buffer("classification buffer", class_buffer, 
                          PDU_DEBUG_FILE);

    MEMbuild_array(class_buffer);

    class_data = (char **)class_buffer->data_ptr;
    /* load values */
    PDUfill_in_string(&PDU_value_list[0], "new category");
    *list_size = 1;
    for ( i = 0; i < class_buffer->rows; i++)
       if ((strcmp(class_data[(class_buffer->columns * i) + 1], "") != 0) &&
           (strcmp(class_data[(class_buffer->columns * i) + 4], "C") != 0))
         {
         PDUfill_in_string(&PDU_value_list[*list_size], 
                           class_data[(class_buffer->columns * i) + 1]);
         *list_size = *list_size + 1;
         }

       *act_row = *act_row + 1;
       PDUprocess_selected_pulldown_value(act_row,pos,list_size);
       return(1);
}
