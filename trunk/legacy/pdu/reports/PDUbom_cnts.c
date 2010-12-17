#include <stdio.h>
#ifdef ENV5
#include <tools.h>
#endif
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
#include <PDMtypes.h>
#include <MEMerrordef.h>
#include <PDUproto.h>
#include <PDMproto.h>


/* Gadgets */

#define ATTR_MCF      15
#define BOM_ATTRIBUTE 20
#define CATALOG_ATTR  22
#define MAP_ATTRIBUTE 25
#define LIST_BOM_ATTR 26
#define CAT_LIST  27
#define CAT_ATTR_LIST 28
#define ADD_ATTRIBUTE 29
#define BOM_ATTR      31
#define SYNONYM       32
#define DATATYPE      30


/* Externs */

extern char * calloc();
extern char * realloc();
extern int FIg_get_text_length();
extern int FIg_get_text();
extern int FImcf_get_active_col();
extern int FIg_get_text_length();
extern int FIfld_get_text();

extern struct PDUforms forms;
extern struct PDUrefresh *refresh;
extern int    PDU_refresh_gadgets[7];
extern Form   PDU_form_id;
extern MEMptr PDU_ret_bufr;
extern MEMptr PDU_cat_attr_bufr;
extern char *** PDU_update_struct;
extern int *PDU_gadget_labels;
extern int PDU_selected_rows;
extern int PDU_active_button;
extern int PDM_debug_on;

/* Global Variables */
extern char *PDU_datatype;
extern char *PDU_attr_name;
extern char *PDU_synonym;
extern char *catalog_attr;
extern char *bom_attr;
extern MEMptr bom_map;
extern int    change_cat;
extern MEMptr PDU_bom_attr_bufr;
extern MEMptr PDU_bom_data_bufr;
extern MEMptr PDU_bom_list_bufr;
extern MEMptr PDU_bom_map_bufr;
extern char   *PDU_bom_datatype;
extern char   *PDU_attr_datatype;
extern char   *PDU_store_catalog;
extern short   PDU_select_bomattr;
extern short   PDU_select_catattr;


int bom_contents_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  static char   * text;
  int             length;
  int             select;
  int             pos;
  int             status;
  int             i;
  int             act_row = 0;
  int             attr_row= -1;
  int             VALID = FALSE;
  int             rows;
  int             no_headings;
  int             all_flag;
  char            **headings = NULL;
  char            **attr_data = NULL;
  char            *msg = NULL, msg_str[180];
  MEMptr          dyn_attr = NULL;
  MEMptr          dyn_data = NULL;
  MEMptr          dyn_list = NULL;

  FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
  PDU_select_bomattr = FALSE;
  PDU_select_catattr = FALSE;
  PDU_form_id = forms.bom_contents_form_id;

  switch ( g_label )
  {
    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

         _pdm_debug("f_label = <%d>", (char *)f_label);
         value = 0.0;
         status = PDUinitialize_help();
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }
         Help_topic("bom_contents");

         break;

    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

          /* Erase the displayed form */

         FIf_erase ( fp );

         PDUsetup_report_struct();
         PDUupdate_report_form();
         FIf_display(forms.report_form_id);

         break;

    case FI_RESET:

         PDUload_attributes_for_mapping(&PDU_bom_attr_bufr);

         FIg_erase(fp, LIST_BOM_ATTR);
         FIg_disable(fp, ADD_ATTRIBUTE);
         FIg_disable(fp, MAP_ATTRIBUTE);
         FIg_set_text(fp, BOM_ATTR, "");
         FIg_set_text(fp, DATATYPE, "");
         FIg_set_text(fp, SYNONYM, "");
         FIg_set_text(fp, BOM_ATTRIBUTE, "");
         FIg_set_text(fp, CAT_NAME, "");
         FIg_set_text(fp, CATALOG_ATTR, "");

         if ((PDU_attr_name) && (strcmp(PDU_attr_name, "") != 0))
           PDUfill_in_string(&PDU_attr_name, NULL);
         if ((PDU_datatype) && (strcmp(PDU_datatype, "") != 0))
           PDUfill_in_string(&PDU_datatype, NULL);
         if ((PDU_synonym) && (strcmp(PDU_synonym, "") != 0))
           PDUfill_in_string(&PDU_synonym, NULL);
         if ((bom_attr) && (strcmp(bom_attr, "") != 0))
           PDUfill_in_string(&bom_attr, NULL);
         if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
           PDUfill_in_string(&refresh->rev_catalog, NULL);
         if ((catalog_attr) && (strcmp(catalog_attr, "") != 0))
           PDUfill_in_string(&catalog_attr, NULL);

         break;

    case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */

          /* Erase the displayed form */

         FIf_erase ( fp );


         status = MEMbuild_array(PDU_bom_attr_bufr);
         _pdm_status("MEMbuild_array", status);

         attr_data = (char **)PDU_bom_attr_bufr->data_ptr;
         /*for (i = 0; i < PDU_bom_attr_bufr->rows; i++)
           for (j = 16; j < PDU_bom_attr_bufr->columns; j++)
             {
             if ((attr_data[(PDU_bom_attr_bufr->columns * i) + j]) &&
                 (strcmp(attr_data[(PDU_bom_attr_bufr->columns * i) + j], "") 
                 != 0))
             {
             status = MEMwrite_data(PDU_bom_attr_bufr, "", (i + 1), (j + 1));
             _pdm_status("MEMwrite_data", status);
             }
             }*/
         /* call bom contents function */
         status = PDMmodify_bom_content(PDU_bom_attr_bufr, PDU_bom_data_bufr,
                                        PDU_bom_list_bufr, PDU_bom_map_bufr);
         _pdm_status("PDMmodify_bom_contents", status);

          refresh->status = status;
          PDUmessage_trans(status, 's');
          PDUmessage(status, 's');
          /* Process form data */
         PDUsetup_report_struct();
         PDUupdate_report_form();

         FIf_display(forms.report_form_id);

         break;

    case ATTR_MCF:     /* Sequenced to     */

          /* Get the text string */

          FIfld_get_active_row(fp, ATTR_MCF, &act_row, &pos);
          FImcf_set_active_col(fp, ATTR_MCF, 0,0);
          FIfld_get_text_length(fp,ATTR_MCF,act_row,0,&length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          FIfld_get_text(fp,ATTR_MCF,act_row,0,length,
                         (unsigned char*)text,&select,&pos);
          if (strcmp(text, "") == 0)
            break;

          PDUfill_in_string(&bom_attr, text);
          FIg_set_text(fp, BOM_ATTRIBUTE, text);

          FImcf_set_active_col(fp, ATTR_MCF, 1,1);
          FIfld_get_text_length(fp,ATTR_MCF,act_row,1,&length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          FIfld_get_text(fp,ATTR_MCF,act_row,1,length,
                         (unsigned char*)text,&select,&pos);

          PDUfill_in_string(&PDU_bom_datatype, text);

          /* Code to process text string "text" */
         PDUcheck_bom_mapping_commands();


         break;

    case BOM_ATTRIBUTE:     /* Sequenced to     */
                             /* Field Type:    ASCII    */

          /* Get the text string */

          FIfld_get_text_length(fp,BOM_ATTRIBUTE,0,0,&length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          FIfld_get_text(fp,BOM_ATTRIBUTE,0,0,length,
                         (unsigned char*)text,&select,&pos);

          if (text == NULL)
            break;
          else if (strcmp(text, "") == 0)
            break;

          /* Code to process text string "text" */
          /* verify attribute is a bom attribute */
          MEMbuild_array(PDU_bom_attr_bufr);
          attr_data = (char **) PDU_bom_attr_bufr->data_ptr;

          VALID = FALSE;
          for ( i = 0; i < PDU_bom_attr_bufr->rows; i ++)
            {
            if (strcmp(text, attr_data[(PDU_bom_attr_bufr->columns * i) + 
                       PDU_NFM_ATTR_COL]) == 0)
              {
              PDUfill_in_string(&PDU_bom_datatype, 
               attr_data[(PDU_bom_attr_bufr->columns * i) + PDU_NFM_DATA_COL]);
              VALID = TRUE;
              break;
              }
            }

          if (!VALID)
            {
             msg = (char *)PDUtranslate_message(PDM_E_ERROR_BOM_ATTR);
             FIg_set_text(fp, FI_MSG_FIELD, msg);
             PDUmessage(PDM_E_ERROR_BOM_ATTR, 's');
             if (bom_attr)
               PDUfill_in_string(&bom_attr, NULL);
             if (PDU_bom_datatype)
               PDUfill_in_string(&PDU_bom_datatype, NULL);
             FIfld_pos_cursor(fp, BOM_ATTRIBUTE, 0,0,0,0,0,0);
            break;
            }

         PDUfill_in_string(&bom_attr, text);
         FIfld_pos_cursor(fp, CAT_NAME, 0,0,0,0,0,0);
         PDUcheck_bom_mapping_commands();

         break;

    case CAT_NAME:     /* Sequenced to     */
                             /* Field Type:    ASCII    */


         _pdm_debug("Entering CATALOG",0);

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

         PDUmessage(status,'s');

         break;

    case CATALOG_ATTR:     /* Sequenced to     */
                             /* Field Type:    ASCII    */

         PDU_select_catattr = TRUE;
          if ((refresh->rev_catalog == NULL) || 
              (strcmp(refresh->rev_catalog, "") == 0))
            {
            FIg_set_text(fp, g_label, "");
            msg = (char *)PDUtranslate_message(PDM_E_CAT_FIELD_BLANK);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            PDUmessage(PDM_E_CAT_FIELD_BLANK, 's');
            break;
            }

          /* Get the text string */

          FIfld_get_text_length(fp,CATALOG_ATTR,0,0,&length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          FIfld_get_text(fp,CATALOG_ATTR,0,0,length,
                         (unsigned char*)text,&select,&pos);

          if (text == NULL)
            break;
          else if (strcmp(text, "") == 0)
            break;

         if (((PDU_store_catalog) && (strcmp(PDU_store_catalog, "") != 0) &&
             (strcmp(PDU_store_catalog, refresh->rev_catalog) != 0)) ||
             (PDU_cat_attr_bufr == NULL))
          {
          if (PDU_cat_attr_bufr)
            MEMclose(&PDU_cat_attr_bufr);

         PDUfill_in_string(&PDU_store_catalog, refresh->rev_catalog);
         status = PDMquery_table_definition(refresh->rev_catalog,
                                            "catalog", &PDU_cat_attr_bufr);
         _pdm_status("PDMquery_table_definition", status);

         if (status != PDM_S_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_E_ERROR_RET_CAT_ATTR);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           PDUmessage(PDM_E_ERROR_RET_CAT_ATTR, 's');
           break;
           }
         /* get dynamic attributes */
         status = PDMget_dynamic_attributes(refresh->rev_catalog, &dyn_attr,
                                            &dyn_data, &dyn_list);
         _pdm_status("PDMget_dynamic_attributes", status);

         PDUmessage(PDM_E_CLEAR_FIELD, 's');

         if (dyn_data)
           MEMclose(&dyn_data);
         if (dyn_list)
           MEMclose(&dyn_list);

         /* if dyn_attr merge into catalog attribute buffer */
         if (dyn_attr)
           {
           status = PDUmerge_cat_and_dyn_attr(dyn_attr, &PDU_cat_attr_bufr);
           _pdm_status("PDUmerge_cat_and_dyn_attr_bufr", status);

           if (status != PDM_S_SUCCESS)
             {
             msg = (char *)PDUtranslate_message(PDM_E_PROCESS_CAT_ATTRS);
             FIg_set_text(fp, FI_MSG_FIELD, msg);
             PDUmessage(PDM_E_PROCESS_CAT_ATTRS, 's');
             break;
             }
           else
             MEMclose(&dyn_attr);
           }
         }

         status = PDUcreate_list_of_cat_attributes(PDU_cat_attr_bufr, 
                                                   &PDU_ret_bufr);
         _pdm_status("PDUcreate_list_of_cat_attributes", status);

           if (status != PDM_S_SUCCESS)
             {
             msg = (char *)PDUtranslate_message(PDM_E_PROCESS_CAT_ATTRS);
             FIg_set_text(fp, FI_MSG_FIELD, msg);
             PDUmessage(PDM_E_PROCESS_CAT_ATTRS, 's');
             break;
             }

          if (PDU_ret_bufr == NULL)
            {
            msg = (char *)PDUtranslate_message(PDM_E_NO_CAT_ATTRS);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            PDUmessage(PDM_E_NO_CAT_ATTRS, 's');
            if (catalog_attr)
              PDUfill_in_string(&catalog_attr, NULL);
            FIg_set_text(fp, CATALOG_ATTR,"");
             break;
             }
          else if (PDU_ret_bufr->rows == 0)
            {
            msg = (char *)PDUtranslate_message(PDM_E_NO_CAT_ATTRS);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            PDUmessage(PDM_E_NO_CAT_ATTRS, 's');
            if (catalog_attr)
              PDUfill_in_string(&catalog_attr, NULL);
            FIg_set_text(fp, CATALOG_ATTR,"");
             break;
            }

         MEMbuild_array(PDU_ret_bufr);
         attr_data = (char **)PDU_ret_bufr->data_ptr;

         VALID = FALSE;
         for (i = 0; i < PDU_ret_bufr->rows; i ++)
            {
            if (strcmp(text, attr_data[(PDU_ret_bufr->columns * i) +
                PDU_NFM_ATTR_COL]) == 0)
              {
              VALID = TRUE;
              break;
              }
           }

            if (!VALID) 
            {
            msg = (char *)PDUtranslate_message(PDM_E_INVALID_CAT_ATTR);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            PDUmessage(PDM_E_INVALID_CAT_ATTR, 's');
            if (catalog_attr)
              PDUfill_in_string(&catalog_attr, NULL);
            FIg_set_text(fp, CATALOG_ATTR,"");
            break;
            }

         PDUfill_in_string(&catalog_attr, text);
         PDUcheck_bom_mapping_commands();

         break;

    case MAP_ATTRIBUTE:     /* Sequenced to     */

         if ((bom_attr == NULL) || (strcmp(bom_attr, "") == 0))
           {
           msg = (char *)PDUtranslate_message(PDM_E_SELECT_BOM_ATTR);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           PDUmessage(PDM_E_SELECT_BOM_ATTR, 's');
           FIfld_pos_cursor(fp, BOM_ATTRIBUTE, 0,0,0,0,0,0);
           break;
           }

         if ((refresh->rev_catalog == NULL) || 
             (strcmp(refresh->rev_catalog, "") == 0))
           {
           msg = (char *)PDUtranslate_message(PDM_I_ENTER_CATALOG);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           PDUmessage(PDM_I_ENTER_CATALOG, 's');
           FIfld_pos_cursor(fp, CAT_NAME, 0,0,0,0,0,0);
           break;
           }

         if ((catalog_attr == NULL) || (strcmp(catalog_attr, "") == 0))
           {
           msg = (char *)PDUtranslate_message(PDM_E_SELECT_CAT_ATTR);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           PDUmessage(PDM_E_SELECT_CAT_ATTR, 's');
           FIfld_pos_cursor(fp, CATALOG_ATTR, 0,0,0,0,0,0);
           break;
           }

         if (strncmp(PDU_bom_datatype, "char", 4) == 0)
           {
           _pdm_debug("Catalog attribute must be of character datatype", 0);
           if (strncmp(PDU_attr_datatype, "char", 4) != 0)
             {
             msg = (char *)PDUtranslate_message(PDM_E_SAME_ATTR_DATATYPE);
             FIg_set_text(fp, FI_MSG_FIELD, msg);
             PDUmessage(PDM_E_SAME_ATTR_DATATYPE, 's');
             break;
             }
           }
         else if (strcmp(PDU_bom_datatype, PDU_attr_datatype) != 0)
           {
           msg = (char *)PDUtranslate_message(PDM_E_SAME_ATTR_DATATYPE);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           PDUmessage(PDM_E_SAME_ATTR_DATATYPE, 's');
           break;
           }

         if (PDU_bom_map_bufr == NULL)
           {
           status = PDUformat_bom_map_bufr(&PDU_bom_map_bufr);
           _pdm_status("PDUformat_bom_map_bufr", status);
         
           if (status != PDM_S_SUCCESS)
             {
             msg = (char *)PDUtranslate_message(PDM_E_ERROR_MAP_ATTR);
             FIg_set_text(fp, FI_MSG_FIELD, msg);
             PDUmessage(PDM_E_ERROR_MAP_ATTR, 's');
             break;
             }
           }

         /* map attribute to BOM */
        status = PDUmap_attribute(bom_attr, refresh->rev_catalog, catalog_attr);
        _pdm_status("PDUmap_attribute", status);

        if (status != PDM_S_SUCCESS)
          {
          msg = (char *)PDUtranslate_message(PDM_E_BOM_ATTR_MAPPED );
          FIg_set_text(fp, FI_MSG_FIELD, msg);
          PDUmessage(PDM_E_BOM_ATTR_MAPPED , 's');
          break;
          }
         PDUmessage(status, 's');
         FIg_set_text(fp, BOM_ATTRIBUTE, "");
         PDUfill_in_string(&bom_attr, NULL);
         FIg_set_text(fp, CATALOG_ATTR, "");
         PDUfill_in_string(&catalog_attr, NULL);

         PDUcheck_bom_mapping_commands();
         break;

    case LIST_BOM_ATTR:     

         PDU_select_bomattr = TRUE;
         if (PDU_ret_bufr)
           MEMclose(&PDU_ret_bufr);

          /* MEMsplit_copy of bom buffer to PDU_ret_bufr */
          status = MEMsplit_copy_buffer(PDU_bom_attr_bufr, &PDU_ret_bufr, 0);
          _pdm_status("MEMsplit_copy_buffer", status);

          /* setup global variables for single list form */
          PDUsetup_single_buffer(PDU_ret_bufr);
          PDU_form_id = forms.bom_contents_form_id;

          PDU_gadget_labels[0] = BOM_ATTRIBUTE;

          PDU_update_struct[0] = &bom_attr;

          all_flag = FALSE;
          no_headings = 1;

          headings = (char **)malloc(sizeof (char *) * no_headings);
          memset(headings, NULL, sizeof (char *) * no_headings);

          PDUfill_in_string(&headings[0], "n_name");

          PDUsetup_popup_list(headings, no_headings, all_flag,
                                       PDU_ret_bufr);

          PDUsetup_form_fields(headings, no_headings, all_flag,
                                        PDU_ret_bufr);

          PDUsetup_struct_fields(headings, no_headings, all_flag,
                                          PDU_ret_bufr);

          PDUfree_string_array(&headings, no_headings);

          status = PDUsingle_list_form();

         break;

    case CAT_LIST:     

         PDU_active_button = CAT_LIST;

         if ((refresh->rev_partid) && (strcmp(refresh->rev_partid, "") != 0)) 
          PDUfill_in_string(&refresh->rev_partid, NULL);
        if ((refresh->rev_revision) && (strcmp(refresh->rev_revision, "") != 0))
          PDUfill_in_string(&refresh->rev_revision, NULL);
         if ((refresh->rev_description) && 
              (strcmp(refresh->rev_description, "") != 0))
           PDUfill_in_string(&refresh->rev_description, NULL);
        if ((refresh->rev_filename) && (strcmp(refresh->rev_filename, "") != 0))
           PDUfill_in_string(&refresh->rev_filename, NULL);

         status = PDUep_cat_btn();
         _pdm_status("PDUep_cat_btn",status);

         break;

    case CAT_ATTR_LIST:     

         PDU_select_catattr = TRUE;
         if ((refresh->rev_catalog == NULL) || 
             (strcmp(refresh->rev_catalog, "") == 0))
           {
           msg = (char *)PDUtranslate_message(PDM_E_CAT_FIELD_BLANK );
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           PDUmessage(PDM_E_CAT_FIELD_BLANK , 's');
           FIfld_pos_cursor(fp, CAT_NAME, 0,0,0,0,0,0);
           break;
           }

         if (PDU_ret_bufr)
           MEMclose(&PDU_ret_bufr);

         if (((PDU_store_catalog) && (strcmp(PDU_store_catalog, "") != 0) &&
             (strcmp(PDU_store_catalog, refresh->rev_catalog) != 0)) ||
             (PDU_cat_attr_bufr == NULL))
         {
         if (PDU_cat_attr_bufr)
           MEMclose(&PDU_cat_attr_bufr);

         PDUfill_in_string(&PDU_store_catalog, refresh->rev_catalog);
         status = PDMquery_table_definition(refresh->rev_catalog,
                                            "catalog", &PDU_cat_attr_bufr);
         _pdm_status("PDMquery_table_definition", status);

         if (status != PDM_S_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_E_ERROR_RET_CAT_ATTR);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           PDUmessage(PDM_E_ERROR_RET_CAT_ATTR , 's');
           break;
           }

         status = PDMget_dynamic_attributes(refresh->rev_catalog, &dyn_attr,
                                            &dyn_data, &dyn_list);
         _pdm_status("PDMget_dynamic_attributes", status);

         PDUmessage(PDM_E_CLEAR_FIELD, 's');

         if (dyn_data)
           MEMclose(&dyn_data);
         if (dyn_list)
           MEMclose(&dyn_list);

         if (dyn_attr)
           {
           status = PDUmerge_cat_and_dyn_attr(dyn_attr, &PDU_cat_attr_bufr);
           _pdm_status("PDUmerge_cat_and_dyn_attr_bufr", status);

           if (status != PDM_S_SUCCESS)
             {
             msg = (char *)PDUtranslate_message(PDM_E_PROCESS_CAT_ATTRS);
             FIg_set_text(fp, FI_MSG_FIELD, msg);
             PDUmessage(PDM_E_PROCESS_CAT_ATTRS , 's');
             break;
             }
           else
             MEMclose(&dyn_attr);
           }
         }
         /*status = MEMsplit_copy_buffer(PDU_cat_attr_bufr, &PDU_ret_bufr, 0);
         _pdm_status("MEMsplit_copy_buffer", status);*/

         status = PDUcreate_list_of_cat_attributes(PDU_cat_attr_bufr, 
                                                   &PDU_ret_bufr);
         _pdm_status("PDUcreate_list_of_cat_attributes", status);

           if (status != PDM_S_SUCCESS)
             {
             msg = (char *)PDUtranslate_message(PDM_E_PROCESS_CAT_ATTRS);
             FIg_set_text(fp, FI_MSG_FIELD, msg);
             PDUmessage(PDM_E_PROCESS_CAT_ATTRS , 's');
             break;
             }

          if (PDU_ret_bufr == NULL)
            {
            msg = (char *)PDUtranslate_message(PDM_E_NO_CAT_ATTRS);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            PDUmessage(PDM_E_NO_CAT_ATTRS , 's');
            break;
            }
          else if (PDU_ret_bufr->rows == 0)
            {
            msg = (char *)PDUtranslate_message(PDM_E_NO_CAT_ATTRS);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            PDUmessage(PDM_E_NO_CAT_ATTRS , 's');
            break;
            }

          /* setup global variables for single list form */
          PDUsetup_single_buffer(PDU_ret_bufr);
          PDU_form_id = forms.bom_contents_form_id;

          PDU_gadget_labels[0] = CATALOG_ATTR;

          PDU_update_struct[0] = &catalog_attr;

          all_flag = FALSE;
          no_headings = 1;

          headings = (char **)malloc(sizeof (char *) * no_headings);
          memset(headings, NULL, sizeof (char *) * no_headings);

          PDUfill_in_string(&headings[0], "n_name");

          PDUsetup_popup_list(headings, no_headings, all_flag,
                                       PDU_ret_bufr);

          PDUsetup_form_fields(headings, no_headings, all_flag,
                                        PDU_ret_bufr);

          PDUsetup_struct_fields(headings, no_headings, all_flag,
                                          PDU_ret_bufr);

          PDUfree_string_array(&headings, no_headings);

          status = PDUsingle_list_form();

         break;

    case ADD_ATTRIBUTE:     /* Sequenced to     */

        if ((PDU_attr_name == NULL) ||
            (strcmp(PDU_attr_name, "") == 0))
          {
          msg = (char *)PDUtranslate_message(PDM_E_ENTER_ATTR_NAME);
          FIg_set_text(fp, FI_MSG_FIELD, msg);
          PDUmessage(PDM_E_ENTER_ATTR_NAME , 's');
          FIfld_pos_cursor(fp, BOM_ATTR, 0,0,0,0,0,0);
          break;
          }

        if ((PDU_datatype == NULL) || 
            (strcmp(PDU_datatype, "") == 0))
          {
          msg = (char *)PDUtranslate_message(PDM_E_ENTER_ATTR_DATATYPE);
          FIg_set_text(fp, FI_MSG_FIELD, msg);
          PDUmessage(PDM_E_ENTER_ATTR_DATATYPE , 's');
          FIfld_pos_cursor(fp, BOM_ATTR, 0,0,0,0,0,0);
          break;
          }

        /* add attribute to contents */
        status = PDUadd_to_contents(PDU_attr_name, PDU_datatype, PDU_synonym,
                                      &PDU_bom_attr_bufr);
        _pdm_status("PDUadd_to_contents", status);

        if (status != PDM_S_SUCCESS)
          {
          msg = (char *)PDUtranslate_message(PDM_E_ADD_ATTR);
          FIg_set_text(fp, FI_MSG_FIELD, msg);
          PDUmessage(PDM_E_ADD_ATTR , 's');
          PDUmessage(status, 's');
          break;
          }

        /* get number of rows of the mcf */
        status = FIfld_get_num_rows(fp,ATTR_MCF, &rows);
        if (status != FI_SUCCESS)
          break;

         if (rows == 1)
           {
           /* see if the first row is null */

           FIfld_get_text_length(fp,ATTR_MCF,(rows - 1),0,&length);
           text = (char *) malloc (sizeof (char) * length + 1);
           memset(text, NULL, sizeof (char) * length + 1);
           FIfld_get_text(fp,ATTR_MCF,(rows - 1),0,length,
                          (unsigned char*)text,&select,&pos);

           if ((text == NULL) || (strcmp(text, "") == 0))
             rows = rows - 1;
           FIfld_set_num_rows(fp, ATTR_MCF, (rows + 1));
           }

         /* put the new PDU_attr_name in the mcf */
         FIfld_set_text(fp, ATTR_MCF, rows ,0, 
                        PDU_attr_name, FALSE);

         PDUfill_in_string(&PDU_attr_name, NULL);
         FIg_set_text(fp, BOM_ATTR, "");

         /* put the new datatype in the mcf */
         FIfld_set_text(fp, ATTR_MCF, rows ,1, 
                        PDU_datatype, FALSE);

         PDUfill_in_string(&PDU_datatype, NULL);
         FIg_set_text(fp, DATATYPE, "");

         /* put the new PDU_synonymonym in the mcf */
         if ((PDU_synonym != NULL) && (strcmp(PDU_synonym, "")!= 0))
           {
           FIfld_set_text(fp, ATTR_MCF,rows ,2, 
                          PDU_synonym,FALSE);
           PDUfill_in_string(&PDU_synonym, NULL);
           FIg_set_text(fp, SYNONYM, "");
           }

         PDUcheck_bom_mapping_commands();
         break;

    case BOM_ATTR:         /* Field Type:    ASCII    */

          /* Get the text string */

          FIfld_get_text_length(fp,BOM_ATTR,0,0,&length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          FIfld_get_text(fp,BOM_ATTR,0,0,length,
                         (unsigned char*)text,&select,&pos);

          if (text == NULL)
            break;
          else if (strcmp(text, "") == 0)
            break;

          /* Code to process text string "text" */
          msg = (char *) malloc (sizeof (char) * 100);
          status = PDUvalid_attr(text, "", msg);
          _pdm_status("PDUvalid_attr", status);

          if (status != PDM_S_SUCCESS)
            {
            FIg_set_text(fp, BOM_ATTR, "");
            msg = (char *)PDUtranslate_message(PDM_E_INVALID_ATTR);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            PDUmessage(PDM_E_INVALID_ATTR , 's');
            if (PDU_attr_name)
              PDUfill_in_string(&PDU_attr_name, NULL);
            break;
            }

          status = PDUcheck_for_reserved_words(text);
          if (status != PDM_S_SUCCESS)
            {
            FIg_set_text(fp, BOM_ATTR, "");
            msg = (char *)PDUtranslate_message(PDM_E_RESERVED_ATTR);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            PDUmessage(PDM_E_RESERVED_ATTR , 's');
            if (PDU_attr_name)
              PDUfill_in_string(&PDU_attr_name, NULL);
            break;
            }

          MEMbuild_array(PDU_bom_attr_bufr);
          attr_row = PDUfind_attr_in_buffer(PDU_bom_attr_bufr, text);
          if (attr_row != -1)
            {
            FIg_set_text(fp, BOM_ATTR, "");
            msg = (char *)PDUtranslate_message(PDM_E_ATTR_EXISTS);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            PDUmessage(PDM_E_ATTR_EXISTS , 's');
            if (PDU_attr_name)
              PDUfill_in_string(&PDU_attr_name, NULL);
            break;
            }

          PDUfill_in_string(&PDU_attr_name, text); 
          FIfld_pos_cursor(fp, DATATYPE, 0,0,0,0,0,0);

          PDUcheck_bom_mapping_commands();
         break;

    case SYNONYM:         /* Field Type:    ASCII    */

          /* Get the text string */

          FIfld_get_text_length(fp,SYNONYM,0,0,&length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          FIfld_get_text(fp,SYNONYM,0,0,length,
                         (unsigned char*)text,&select,&pos);

          if (text == NULL)
            break;
          else if (strcmp(text, "") == 0)
            break;

          /* Code to process text string "text" */
          status = PDUvalid_synonym(text, "", msg);
          _pdm_status("PDUvalid_PDU_synonymonym", status);

          if (status != PDM_S_SUCCESS)
            {
            msg = (char *)PDUtranslate_message(PDM_E_INVALID_SYNONYM);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            PDUmessage(PDM_E_INVALID_SYNONYM , 's');
            FIg_set_text(fp, SYNONYM, "");
            if (PDU_synonym)
              PDUfill_in_string(&PDU_synonym, NULL);
            break;
            }

           PDUfill_in_string(&PDU_synonym, text);
          PDUcheck_bom_mapping_commands();

         break;

    case DATATYPE:         /* Field Type:    ASCII    */

          /* Get the text string */

          FIfld_get_text_length(fp,DATATYPE,0,0,&length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          FIfld_get_text(fp,DATATYPE,0,0,length,
                         (unsigned char*)text,&select,&pos);

          if (text == NULL)
            break;
          else if (strcmp(text, "") == 0)
            break;

          /* Code to process text string "text" */
          status = PDUvalid_datatype(text, "", msg_str);
          _pdm_status("PDUvalid_datatype", status);

          if (status != PDM_S_SUCCESS)
            {
            FIg_set_text(fp, DATATYPE, "");
            FIg_set_text(fp, FI_MSG_FIELD, msg_str);
            if (PDU_datatype)
              PDUfill_in_string(&PDU_datatype, NULL);
            break;
            }

           PDUfill_in_string(&PDU_datatype, text);
           FIfld_pos_cursor(fp, SYNONYM,0,0,0,0,0,0);

          PDUcheck_bom_mapping_commands();
         break;

  } /* END switch ( g_label ) */
  return(1);
} /* END notification_routine() */

int bom_contents_form()
{
int           status = PDM_S_SUCCESS;
char          *msg = NULL;


  status = FIf_new(BOM_CONTENTS_FORM, "bom_contents",
                bom_contents_notification_routine,
                &forms.bom_contents_form_id);

  _pdm_debug("Creating BOM Contents Form", 0);

  /* set global structures */
  PDU_form_id = forms.bom_contents_form_id;

  PDU_refresh_gadgets[1] = CAT_NAME;

  if (PDU_bom_attr_bufr)
    MEMclose(&PDU_bom_attr_bufr);

  if (PDU_bom_data_bufr)
    MEMclose(&PDU_bom_data_bufr);

  if (PDU_bom_list_bufr)
    MEMclose(&PDU_bom_list_bufr);

  if (PDU_bom_map_bufr)
    MEMclose(&PDU_bom_map_bufr);

  FIg_disable(forms.bom_contents_form_id,MAP_ATTRIBUTE);
  FIg_disable(forms.bom_contents_form_id,ADD_ATTRIBUTE);

  status = PDMget_table_attributes(MODIFY_TABLE, PDM_BOMCONTENT, "", 
                                   &PDU_bom_attr_bufr,
                                   &PDU_bom_data_bufr, &PDU_bom_list_bufr);
  _pdm_status("PDMget_table_attributes", status);

  /* load content of buffer into mcf */
  if ((PDU_bom_attr_bufr == NULL) || (PDU_bom_attr_bufr->rows == 0))
    {
    msg = (char *)PDUtranslate_message(PDM_E_ERROR_BOM_ATTR);
    FIg_set_text(forms.bom_contents_form_id, FI_MSG_FIELD, msg);
    PDUmessage(PDM_E_ERROR_BOM_ATTR , 's');
    return(status);
    }

  if (PDM_debug_on)
    MEMprint_buffer("bom_list", PDU_bom_attr_bufr, PDU_DEBUG_FILE);

  PDUload_attributes_for_mapping(&PDU_bom_attr_bufr);

  if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
    FIg_set_text(forms.bom_contents_form_id, CAT_NAME, refresh->rev_catalog);

  if (refresh->rev_partid)
    PDUfill_in_string(&refresh->rev_partid, NULL);
  if (refresh->rev_revision)
    PDUfill_in_string(&refresh->rev_revision, NULL);
  if (refresh->rev_description)
    PDUfill_in_string(&refresh->rev_description, NULL);
  if (refresh->rev_filename)
    PDUfill_in_string(&refresh->rev_filename, NULL);

  if (PDU_cat_attr_bufr)
    MEMclose(&PDU_cat_attr_bufr);

  /* Display the catalog operations form and set the displayed flag to TRUE. */

  _pdm_debug("Displaying the BOM Contents Form", 0);

  FIg_erase(forms.bom_contents_form_id,LIST_BOM_ATTR);
  status = FIf_display(forms.bom_contents_form_id);

  return(status);
}

int PDUbom_contents_form()

{
  int status;

  status = bom_contents_form();
  _pdm_status("bom_contents_form", status);
  if (status == FI_SUCCESS)
    status = PDM_S_SUCCESS;
  else
    FIf_display(forms.report_form_id);
  return(status);
}

int PDUcheck_bom_mapping_commands()
{
char ** attr_data = NULL; 
int  attr_row = -1;

  _pdm_debug("In the function PDUcheck_bom_mapping_commands", 0);

  if ((PDU_attr_name) && (strcmp(PDU_attr_name, "") != 0) &&
      (PDU_datatype) && (strcmp(PDU_datatype, "") != 0))
    FIg_enable(forms.bom_contents_form_id, ADD_ATTRIBUTE);
  else
    FIg_disable(forms.bom_contents_form_id, ADD_ATTRIBUTE);

  if ((bom_attr) && (strcmp(bom_attr, "") != 0) && (refresh->rev_catalog) &&
      (strcmp(refresh->rev_catalog, "") != 0) && (catalog_attr) &&
      (strcmp(catalog_attr, "") != 0))
    FIg_enable(forms.bom_contents_form_id, MAP_ATTRIBUTE);
  else
    FIg_disable(forms.bom_contents_form_id, MAP_ATTRIBUTE);

  if (PDU_select_bomattr)
    {
    MEMbuild_array(PDU_bom_attr_bufr);
    attr_row = PDUfind_attr_in_buffer(PDU_bom_attr_bufr, bom_attr);

    if (attr_row != -1)
      {
      attr_data = (char **)PDU_bom_attr_bufr->data_ptr;
      PDUfill_in_string(&PDU_bom_datatype, attr_data[(PDU_bom_attr_bufr->columns * attr_row) + PDU_NFM_DATA_COL]);
      }
    }
 
  if (PDU_select_catattr)
    {
    MEMbuild_array(PDU_cat_attr_bufr);
    attr_row = PDUfind_attr_by_synonym(catalog_attr, PDU_cat_attr_bufr);
    if (attr_row != -1)
      {
      attr_data = (char **)PDU_cat_attr_bufr->data_ptr;
      PDUfill_in_string(&catalog_attr, attr_data[(PDU_cat_attr_bufr->columns * 
                        attr_row) + PDU_NFM_ATTR_COL]);
      }

    attr_row = PDUfind_attr_in_buffer(PDU_cat_attr_bufr, catalog_attr);

    if (attr_row != -1)
      {
      attr_data = (char **)PDU_cat_attr_bufr->data_ptr;
      PDUfill_in_string(&PDU_attr_datatype, attr_data[(PDU_cat_attr_bufr->columns * attr_row) + PDU_NFM_DATA_COL]);
      }
    }

  return(PDM_S_SUCCESS);
}

int PDUadd_to_contents(attr_name, datatype, synonym, attr_bufr)

char *attr_name;
char *datatype;
char *synonym;
MEMptr *attr_bufr;

{
  int status;
  int num_rows;
  char *row = NULL;

  _pdm_debug("In the function PDUadd_to_contents", 0);

  row = (char *)malloc((*attr_bufr)->row_size);
  memset(row, NULL, (*attr_bufr)->row_size);

  num_rows = (*attr_bufr)->rows + 1;
  if (synonym)
  sprintf(row, "%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%d\1\1\1%s\1%s\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1",
                attr_name, datatype, synonym, "PDM","Y",
               "Y","Y", "Y", "Y", num_rows, "0","0");
  else
  sprintf(row, "%s\1%s\1\1%s\1%s\1%s\1%s\1%s\1%s\1\1\1%d\1\1\1%s\1%s\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1\1",
                attr_name, datatype, "PDM","Y",
               "Y","Y", "Y", "Y", num_rows, "0","0");
 
  status = MEMwrite(*attr_bufr, row);
  _pdm_status("MEMwrite", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_BUFFER);

  /* update_data buffer */
  status = PDUupdate_data_buffer(&PDU_bom_data_bufr, PDU_bom_attr_bufr);
  _pdm_status("PDUudpate_data_buffer", status);
  
  if (status != PDM_S_SUCCESS)
    return(status);

  return(PDM_S_SUCCESS);
}

int PDUmap_attribute(bom_attribute, catalog, catalog_attribute)

char *bom_attribute;
char *catalog;
char *catalog_attribute;

  {
  int status;
  int char_index;
  int cat_row;
  int attr_row;
  char  *bomattrno = NULL;
  char  *mapattrno = NULL;
  char **cat_attr_data = NULL;
  char **bom_attr_data = NULL;
  char *row = NULL;

  _pdm_debug("PDUmap_attribute", 0);

  status = MEMbuild_array(PDU_bom_attr_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
   return(PDM_E_BUILD_BUFFER_ARRAY);

  /* find bom attribute in buffer */
  attr_row = PDUfind_attr_in_buffer(PDU_bom_attr_bufr, bom_attribute);

  if (attr_row == -1)
    return(PDM_E_FAILURE);

  status = MEMbuild_array(PDU_cat_attr_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  cat_row = PDUfind_attr_in_buffer(PDU_cat_attr_bufr, catalog_attribute);

  if (cat_row == -1)
    return(PDM_E_FAILURE);

  /*status = MEMbuild_array(PDU_bom_map_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);*/

  cat_attr_data = (char **) PDU_cat_attr_bufr->data_ptr;
  bom_attr_data = (char **) PDU_bom_attr_bufr->data_ptr;
  /*bom_map_data = (char **) PDU_bom_map_bufr->data_ptr;*/

  /* get catalog attribute number from attribute buffer */
  PDUfill_in_string(&mapattrno, cat_attr_data[(PDU_cat_attr_bufr->columns * 
                    cat_row) + PDU_NFM_ATTRNO_COL]);
  
  /* get bom attribute number */
  if ((bom_attr_data[(PDU_bom_attr_bufr->columns * attr_row) + 
       PDU_NFM_ATTRNO_COL] != NULL) && 
       (strcmp(bom_attr_data[(PDU_bom_attr_bufr->columns * attr_row) + 
       PDU_NFM_ATTRNO_COL], "") != 0))
    PDUfill_in_string(&bomattrno, bom_attr_data[(PDU_bom_attr_bufr->columns * 
                       attr_row) + PDU_NFM_ATTRNO_COL]);

  /*for (i = 0; i < PDU_bom_map_bufr->rows; i++)
    {
    if ((strcmp(bom_map_data[(PDU_bom_map_bufr->columns * i) + 1], bom_attr)
      == 0) && (strcmp(bom_map_data[(PDU_bom_map_bufr->columns * i) + 3], 
      catalog) == 0))
    {
    _pdm_debug("duplicate map", 0);
    return(PDM_E_FAILURE);
    }
  }*/
  row = (char *)malloc(PDU_bom_map_bufr->row_size);
  memset(row, NULL, PDU_bom_map_bufr->row_size);

  char_index = 0;

  if ((bomattrno != NULL) && (strcmp(bomattrno, "") != 0))
    PDUadd_buffer_string(row, &char_index, bomattrno);
  else
    row[char_index++] = '\1';

  if ((bom_attribute != NULL) && (strcmp(bom_attribute, "") != 0))
    PDUadd_buffer_string(row, &char_index, bom_attribute);
  else
    row[char_index++] = '\1';

  /* catalog number will not be know so add '\1' */
  
  row[char_index++] = '\1';

  if ((catalog != NULL) && (strcmp(catalog, "") != 0))
    PDUadd_buffer_string(row, &char_index, catalog);
  else
    row[char_index++] = '\1';

  if ((mapattrno != NULL) && (strcmp(mapattrno, "") != 0))
    PDUadd_buffer_string(row, &char_index, mapattrno);
  else
    row[char_index++] = '\1';

  status = MEMwrite(PDU_bom_map_bufr, row);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_BUFFER);

  return(PDM_S_SUCCESS);
}

int PDUmerge_cat_and_dyn_attr(dyn_attr, attr_bufr)

  MEMptr dyn_attr;
  MEMptr *attr_bufr;

  {
  int status;
  int char_index;
  int i,j;
  char **dyn_data = NULL;
  char *row = NULL;

  _pdm_debug("In PDUmerge_cat_and_dyn_bufr", 0);

  status = MEMbuild_array(dyn_attr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  dyn_data = (char **)dyn_attr->data_ptr;
  row = (char *)malloc(dyn_attr->row_size);

  for (i = 0; i < dyn_attr->rows; i ++)
    {
    memset(row, NULL, dyn_attr->row_size);
    char_index = 0;
    for ( j = 0; j < dyn_attr->columns; j++)
      {
      if (j < 16)
        {
        if ((dyn_data[(dyn_attr->columns * i ) + j]) &&
            (strcmp(dyn_data[(dyn_attr->columns * i) + j], "") != 0))
          PDUadd_buffer_string(row, &char_index, 
                               dyn_data[(dyn_attr->columns * i) + j]);
        else
          row[char_index ++] = '\1';
        }
      }
    _pdm_debug(" row = <%s>", row);
    status = MEMwrite(*attr_bufr, row);
    _pdm_status("MEMwrite", status);

    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);
    }

  return(PDM_S_SUCCESS);
  }

int PDUload_attributes_for_mapping(attribute_buffer)

MEMptr *attribute_buffer;

  {
  int status;
  int i;
  int num_rows;
  char **attribute_buffer_data = NULL;

  _pdm_debug("In PDUload_attributes_for_mapping", 0);

  status = MEMbuild_array(*attribute_buffer);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  attribute_buffer_data = (char **)(*attribute_buffer)->data_ptr;

  num_rows = 0;
  for (i = 0; i < (*attribute_buffer)->rows; i++)
    {
    if ((strncmp(attribute_buffer_data[((*attribute_buffer)->columns * i) +
                   PDU_NFM_ATTR_COL], "p_",2) == 0) ||
        (strncmp(attribute_buffer_data[((*attribute_buffer)->columns * i) +
                   PDU_NFM_ATTR_COL], "n_",2) == 0))
      _pdm_debug("system attributes not displayed", 0);
    else
    {
    FIfld_set_text(forms.bom_contents_form_id, ATTR_MCF, num_rows, 0,
                   attribute_buffer_data[((*attribute_buffer)->columns * i) + 
                   PDU_NFM_ATTR_COL], FALSE);
    FIfld_set_text(forms.bom_contents_form_id, ATTR_MCF, num_rows, 1,
                   attribute_buffer_data[((*attribute_buffer)->columns * i) + 
                   PDU_NFM_DATA_COL], FALSE);
    FIfld_set_text(forms.bom_contents_form_id, ATTR_MCF, num_rows, 2,
                   attribute_buffer_data[((*attribute_buffer)->columns * i) + 
                   PDU_NFM_SYN_COL], FALSE);
    num_rows = num_rows + 1;
    }
    /*status = MEMwrite_data(*attribute_buffer, "0", (i + 1), 
                          (PDU_NFM_MOD_OFFSET + 
                           PDU_NFM_LISTNO_COL + 1));
    _pdm_status("MEMwrite_data", status);
    status = MEMwrite_data(*attribute_buffer, "0", (i + 1), 
                           (PDU_NFM_MOD_OFFSET + 
                           PDU_NFM_ADVICE_COL + 1));
    _pdm_status("MEMwrite_data", status);*/
    }

  return(PDM_S_SUCCESS);
  }

