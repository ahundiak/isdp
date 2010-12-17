#include <stdio.h>
#include "FI.h"
#include "exdef.h"
#include "PDUextdef.h"
#include "PDUstr.h"
#include "PDUstorage.h"
#include "PDUforms.h"
#include "PDUform_def.h"
#include "PDUerror.h"
#include "PDUcommand.h"
#include "PDUfile_def.h"
#include "PDMmessage.h"
#include "PDUpart.h"
#include "PDUproto.h"
#include "PDMproto.h"
#include "MEMerrordef.h"
#include "PDUrev_str.h"

/* Gadgets */

#define VIEW_NAME  	   	20
#define QUANTITY      		21
#define USAGE_ID      		22
#define ALTTAG_NO     		23
#define TAG_NO        		24
#define USER_DEF_ATTR 		25
#define VIEWS_LIST_BTN          26
#define USER_DEF_GRP            29
#define VIEW_NAME_GRP           30
#define VALUE_ASSOC_GADGET	31
#define PLACEMENT_OPTIONS       32


/* Externs */

extern char * calloc();
extern char * realloc();
extern int FIg_get_text_length();

extern int FIg_get_text();
extern int FIg_get_value();
extern int FImcf_get_active_col();
extern int FIg_get_text_length();
extern int FIfld_get_text();
extern int GRcreate_pull_down_list();
extern int GRproc_pull_down_list();
extern int GRdelete_pull_down_list();
extern int GRchange_pull_down_list();
extern char *PDU_usage_id;
extern char *PDU_alt_tagno;
extern char *PDU_tagno;
extern char *PDU_quantity;
extern char PDU_attr_value[40];
extern MEMptr PDU_dyn_data_bufr;
extern MEMptr PDU_dyn_attr_bufr;
extern MEMptr PDU_dyn_value_bufr;
extern MEMptr PDU_viewnames;
extern MEMptr PDU_ret_bufr;
extern MEMptr PDU_func_buffer;
extern struct PDUforms forms;
extern struct PDUrefresh *refresh;
extern struct PDUpart *part;
extern char *** PDU_update_struct;
extern int *PDU_gadget_labels;
extern Form PDU_form_id;
extern char *PDU_popup_list_type;
extern int PDM_debug_on;
extern int PDU_design_opt_create;
extern int PDU_attr_label;
extern int PDU_value_pulldown;
extern int PDU_command;
extern Form PDU_calling_form;
extern short PDU_perm_window;
extern short PDU_display_dyn_attr;
extern short PDU_assy_perm_window;
extern short PDU_ng_placement;
extern struct PDUrev_assy *current_rev_assy;

extern struct PDUstorage *storage;
/* Global variables */
extern char *PDU_value_list[605];

int dynamic_attr_notification_routine ( f_label, g_label, value, fp )
int     f_label;       /* The label of the form   */
int     g_label;       /* The label of the gadget */
double  value;         /* The value of the gadget */
Form    fp;            /* Pointer to the form     */
  {
  static char   * text;
  int             status;
  int             view_row;
  int             all_flag;
  int             col, row, pos;
  int             list_row;
  int             length;
  int             select;
  int             responses[1];
  char          * strings[1];
  char          *data = NULL;
  char          *attr_name = NULL;
  char          **attr_data = NULL;
  char          *temp = NULL;
  char          *datatype = NULL;
  char          *ptr = NULL;
  char          msg[80];
  char		*msg_str;
  static int    pos_cursor = FALSE;

  FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
  fp = forms.dynamic_attr_form_id;

  switch ( g_label )
    {
    case VIEW_NAME:         /* Field Type:    ASCII    */

         /* Get the text string */

         FIfld_get_text_length(fp,VIEW_NAME,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         status = FIfld_get_text(fp,VIEW_NAME,0,0,length,
                                 (unsigned char*)text,&select,&pos);

         if ( status != FI_SUCCESS )
           {
           msg_str = (char *)PDUtranslate_message(PDM_E_VIEW_NAME_FORM);
           FIg_set_text(forms.dynamic_attr_form_id,FI_MSG_FIELD,msg_str);
           FIg_set_text(forms.dynamic_attr_form_id, VIEW_NAME, "");
           if (part->view)
             PDUfill_in_string(&part->view, NULL);
           break;
           }

         /* Code to process text string "text" */
         /* verify view name is valid */
         if (PDU_viewnames)
           {
           status = MEMbuild_array(PDU_viewnames);
           _pdm_status("MEMbuild_array", status);
 
           if (status != MEM_S_SUCCESS)
             {
             FIg_set_text(forms.design_form_id, VIEW_NAME, "");
             msg_str = (char *)PDUtranslate_message(PDM_E_VIEW_NAME_BUFFER);
             FIg_set_text(forms.design_form_id, FI_MSG_FIELD, msg_str);
             break;
             }
           view_row = PDUfind_attr_in_buffer(PDU_viewnames, text);
           if (view_row == -1)
             {
             _pdm_debug("View <%s> not found in the view buffer", text);
             msg_str = (char *)PDUtranslate_message(PDM_E_INVALID_VIEW_NAME);
             FIg_set_text(forms.design_form_id, FI_MSG_FIELD, msg_str);
             break;
             }

           /* put entered viewname in global PDU_viewname */
           PDUfill_in_string(&part->view, text);
           }
         break;

    case VIEWS_LIST_BTN:

         /* setup global variables for single list form */
         PDU_ret_bufr = PDU_viewnames;
         PDUsetup_single_buffer(PDU_ret_bufr);
         PDU_form_id = forms.dynamic_attr_form_id;

         PDU_gadget_labels[0] = VIEW_NAME;
         PDU_update_struct[0] = &part->view;

  /* set PDU_ret_bufr to PDU_viewnames */
  PDUfill_in_string(&PDU_popup_list_type, "sort");

  all_flag = TRUE;

  PDUsetup_popup_list(NULL, 0, all_flag, PDU_ret_bufr);

  PDUsetup_form_fields(NULL, 0, all_flag, PDU_ret_bufr);

  PDUsetup_struct_fields(NULL, 0, all_flag, PDU_ret_bufr);

  status = PDUsingle_list_form();

 break;

case QUANTITY:         /* Field Type:    ASCII    */

  /* Get the text string */

  FIfld_get_text_length(fp,QUANTITY,0,0,&length);
  text = (char *) malloc (sizeof (char) * length + 1);
  memset(text, NULL, sizeof (char) * length + 1);
  status = FIfld_get_text(fp,QUANTITY,0,0,length,
                          (unsigned char*)text,&select,&pos);

  if ( status != FI_SUCCESS )
    {
    msg_str = (char *)PDUtranslate_message(PDM_E_FORM_DATA);
    FIg_set_text(forms.dynamic_attr_form_id,FI_MSG_FIELD,msg_str);
    FIg_set_text(forms.dynamic_attr_form_id, QUANTITY, "");
    if (PDU_quantity)
      PDUfill_in_string(&PDU_quantity, NULL);
    break;
    }

  /* Code to process text string "text" */
  /* verify quantity is valid */
  status = PDUvalidate_quantity(text);
  _pdm_status("PDUvalidate_quantity", status);

  if (status != PDM_S_SUCCESS)
    {
    FIg_set_text(forms.dynamic_attr_form_id, QUANTITY, "");
    msg_str = (char *)PDUtranslate_message(PDM_E_INVALID_QUANTITY); 
    FIg_set_text(forms.dynamic_attr_form_id, FI_MSG_FIELD,msg_str);
    break;
    }
  
  /* put entered quantity in global PDU_quantity */
  PDUfill_in_string(&PDU_quantity, text);

 break;

case USAGE_ID:         /* Field Type:    ASCII    */

  /* Get the text string */

  FIfld_get_text_length(fp,USAGE_ID,0,0,&length);
  text = (char *) malloc (sizeof (char) * length + 1);
  memset(text, NULL, sizeof (char) * length + 1);
  status = FIfld_get_text(fp,USAGE_ID,0,0,length,(unsigned char*)text,
                          &select,&pos);

  if ( status != FI_SUCCESS )
    {
    msg_str = (char *)PDUtranslate_message(PDM_E_FORM_DATA);
    FIg_set_text(forms.dynamic_attr_form_id,FI_MSG_FIELD,msg_str);
    FIg_set_text(forms.dynamic_attr_form_id, USAGE_ID, "");
    if (PDU_usage_id)
      PDUfill_in_string(&PDU_usage_id, NULL);
    break;
    }

  if (PDU_usage_id != NULL)
    if ((PDU_command == PDC_M_EDIT_PART) && 
        (strcmp(PDU_usage_id, text) == 0))
      break;

  /* check for usagedid length > 25 */
  length = strlen(text);
  if (length > 25)
    {
    FIg_set_text(forms.dynamic_attr_form_id, USAGE_ID, "");
    msg_str = (char *)PDUtranslate_message(PDM_I_DEFAULT_USAGE_LENGTH);
    FIg_set_text(forms.dynamic_attr_form_id, FI_MSG_FIELD,msg_str);
    if ((PDU_usage_id != NULL) && (strcmp(PDU_usage_id, "") != 0))
      PDUfill_in_string(&PDU_usage_id, NULL);
    break;
    }
  /* Code to process text string "text" */
  /* verify the usage name is valid */
  if ((PDU_calling_form == 0) || (PDU_calling_form == forms.design_form_id))
    {
    if ((refresh->rev_parttype) && (strcmp(refresh->rev_parttype, "P") == 0))
      {
      status = PALusage_id_unique(text);
      _pdm_status("PALusage_id_unique", status);
      }
    else
    {
    status = PDUis_usage_unique(text);
    _pdm_status("PDUis_usage_unique", status);
    }
 
    if (status != 1)
      {
      FIg_set_text(forms.dynamic_attr_form_id, USAGE_ID, "");
      msg_str = (char *)PDUtranslate_message(PDM_E_DUPLICATE_USAGEID);
      FIg_set_text(forms.dynamic_attr_form_id, FI_MSG_FIELD,msg_str);
      _pdm_debug("Usage Id not unique", 0);
      if ((PDU_usage_id != NULL) && (strcmp(PDU_usage_id, "") != 0))
        PDUfill_in_string(&PDU_usage_id, NULL);
      break;
      }
    }
  else
    {
    status = PDUcheck_usageid_for_rev_assy(current_rev_assy, text);
    _pdm_status("PDUcheck_usageid_for_rev_assy", status);
    if (status != PDM_S_SUCCESS)
      {
      if (status == PDM_E_UNIQUE_USAGE)
        {
        _pdm_debug("usage id is NOT unique!!", 0);
        msg_str = (char *)PDUtranslate_message(PDM_E_DUPLICATE_USAGEID);
        FIg_set_text(forms.dynamic_attr_form_id, FI_MSG_FIELD, msg_str);
        }
      PDUmessage(status, 's');
      FIg_set_text(forms.dynamic_attr_form_id, USAGE_ID, "");
      FIfld_pos_cursor(forms.dynamic_attr_form_id, USAGE_ID, 0,0,0,0,1,1);
      if (PDU_usage_id)
        {
        _pdm_debug("freeing PDU_usage_id", 0);
        free(PDU_usage_id);
        PDU_usage_id = NULL;
        }
      break;
      }
    PDUfill_in_string(&(current_rev_assy)->new_usageid, text);
    }

  /* put text in PDU_usage_id */
  PDUfill_in_string(&PDU_usage_id, text);

 break;

case ALTTAG_NO:         /* Field Type:    ASCII    */

  /* Get the text string */

  FIfld_get_text_length(fp,ALTTAG_NO,0,0,&length);
  text = (char *) malloc (sizeof (char) * length + 1);
  memset(text, NULL, sizeof (char) * length + 1);
  status = FIfld_get_text(fp,ALTTAG_NO,0,0,length,
                          (unsigned char *)text,&select,&pos);

  if ( status != FI_SUCCESS )
    {
    msg_str = (char *)PDUtranslate_message(PDM_E_FORM_DATA);
    FIg_set_text(forms.dynamic_attr_form_id,FI_MSG_FIELD,msg_str);
    FIg_set_text(forms.dynamic_attr_form_id, ALTTAG_NO, "");
    if (PDU_alt_tagno)
      PDUfill_in_string(&PDU_alt_tagno, NULL);
    break;
    }

  if ((strcmp(text, "") == 0) || (text == NULL))
    break;

  /* Code to process text string "text" */
  /* verify entered alt_tagno is valid */
  if ((PDU_calling_form == 0) || (PDU_calling_form == forms.design_form_id))
    {
    status = PDUis_alt_tag_unique(text);
    _pdm_status("PDUis_alt_tag_unique", status);
  
    if (status != 1)
      {
      FIg_set_text(forms.dynamic_attr_form_id, ALTTAG_NO, "");
      msg_str = (char *)PDUtranslate_message(PDM_E_ALT_TAG_NOT_UNIQUE); 
      FIg_set_text(forms.dynamic_attr_form_id, FI_MSG_FIELD, msg_str);
      FIfld_pos_cursor(fp, ALTTAG_NO, 0,0,0,0,0,0);
      break;
      }
    }
  else
    {
    status = PDUcheck_alttag_for_rev_assy(current_rev_assy, text);
    _pdm_status("PDUcheck_alttag_for_rev_assy", status);
    if (status != PDM_S_SUCCESS)
      {
      _pdm_debug("alttagno is NOT unique!!", 0);
      FIg_set_text(forms.dynamic_attr_form_id, ALTTAG_NO, "");
      msg_str = (char *)PDUtranslate_message(PDM_E_ALT_TAG_NOT_UNIQUE); 
      FIg_set_text(forms.dynamic_attr_form_id, FI_MSG_FIELD, msg_str);
      FIfld_pos_cursor(fp, ALTTAG_NO, 0,0,0,0,0,0);
      break;
      }
    PDUfill_in_string(&(current_rev_assy)->p_alttagno, text);
    }

  /* put text in global PDU_alt_tagno */
  PDUfill_in_string(&PDU_alt_tagno, text);

 break;

case TAG_NO:         /* Field Type:    ASCII    */

  /* TAG_NO field is review mode ONLY */


 break;

case FI_HELP:     /* Member of group FI_CTRL_GROUP */

  _pdm_debug("f_label = <%d>", (char *)f_label);
  value = 0.0;
  status = PDUinitialize_help();
  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    break;
    }
  FIf_cvrt_to_perm_win(fp); 
  Help_topic("Dynamic");

 break;

case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

  /* delete the created pull down list */
  _pdm_debug("Delete pulldow", 0);
  if (PDU_dyn_attr_bufr)
    GRdelete_pull_down_list(PDU_value_pulldown);

  /* MEMclose and free global variables */
  _pdm_debug("Freeing up global variables", 0);
  if (PDU_viewnames != NULL)
    MEMclose(&PDU_viewnames);
  if ((PDU_calling_form != forms.rev_assy_form_id) || 
      (PDU_calling_form == 0))
    {
    _pdm_debug("Freeing up PDU_usage_id", 0);
    if (PDU_usage_id != NULL)
       PDUfill_in_string(&PDU_usage_id, NULL);
    }
  _pdm_debug("Freeing up PDU_alt_tagno", 0);
  if (PDU_alt_tagno != NULL)
     PDUfill_in_string(&PDU_alt_tagno, NULL);
  if ((PDU_calling_form != forms.rev_assy_form_id) ||
      (PDU_calling_form == 0))
    {
    _pdm_debug("freeing up PDU_quantity", 0);
    if (PDU_quantity != NULL)
       PDUfill_in_string(&PDU_quantity, NULL);
    }
  _pdm_debug("freeing up PDU_dyn_attr_bufr", 0);
  if (PDU_dyn_attr_bufr != NULL)
     {
     MEMclose(&PDU_dyn_attr_bufr); 
     PDU_dyn_attr_bufr = NULL;
     }
  _pdm_debug("freeing up PDU_dyn_data_bufr", 0);
  if (PDU_dyn_data_bufr)
     {
     MEMclose(&PDU_dyn_data_bufr);
     PDU_dyn_data_bufr = NULL;
     }
  _pdm_debug("freeing up PDU_dyn_value_bufr", 0);
  if (PDU_dyn_value_bufr != NULL)
     {
     MEMclose(&PDU_dyn_value_bufr);
     PDU_dyn_value_bufr = NULL;
     }

  /* Erase the displayed form */
  _pdm_debug("deleting form", 0);
 FIf_delete ( fp );

  if (PDU_calling_form == forms.rev_assy_form_id)
    {
    refresh->status = PDM_E_CMD_CANCELLED;
    FIf_display(PDU_calling_form);
    }

    if (!PDU_ng_placement)
      PDUsetup_design_struct();
    responses[0] = RESET;
    strings[0] = "";
    PDUprepare_queue(responses, strings, 1);

 break;

case FI_CVT_TO_PERM_WIN:

    break;
    
case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */

  /* make sure required data has been entered */
  if ((PDU_usage_id == NULL) || (strcmp(PDU_usage_id, "") == 0))
    {
    FIg_set_state_off(forms.dynamic_attr_form_id, FI_ACCEPT);
    msg_str = (char *)PDUtranslate_message(PDM_E_NO_USAGE_ID);
    FIg_set_text(forms.dynamic_attr_form_id, FI_MSG_FIELD, msg_str);
    break;
    }

  if ((PDU_quantity == NULL) || (strcmp(PDU_quantity, "") == 0))
    {
    FIg_set_state_off(forms.dynamic_attr_form_id, FI_ACCEPT);
    msg_str = (char *)PDUtranslate_message(PDM_E_NO_QUANTITY);
    FIg_set_text(forms.dynamic_attr_form_id, FI_MSG_FIELD, msg_str);
    break;
    }

  /* set refresh status to PDM_S_SUCCESS */
  refresh->status = PDM_S_SUCCESS;

  /* delete the created pull down list */
  if (PDU_dyn_attr_bufr)
    {
    _pdm_debug("Deleting GRpulldown", 0);
    GRdelete_pull_down_list(PDU_value_pulldown);
    strcpy(msg, "");
    status = PDUcheck_for_required_data(PDU_dyn_attr_bufr, PDU_dyn_data_bufr,
                                        msg);
    _pdm_status("PDUcheck_for_required_data", status);
    if (status != PDM_S_SUCCESS)
      {
      FIg_set_state_off(forms.dynamic_attr_form_id, FI_ACCEPT);
      FIg_set_text(forms.dynamic_attr_form_id, FI_MSG_FIELD, msg);
      break;
      }
    }

  _pdm_debug("part type before calling PDUadd_static_dyn_attributes :<%s>", 
              refresh->rev_parttype);
  if ((refresh->rev_parttype) && (strcmp(refresh->rev_parttype, "P") == 0))
    {
    if (PDM_debug_on)
      {
        MEMprint_buffer("PDU_dyn_attr", PDU_dyn_attr_bufr, PDU_DEBUG_FILE);
        MEMprint_buffer("PDU_dyn_data", PDU_dyn_data_bufr, PDU_DEBUG_FILE);
      }
    status = PDUadd_static_dyn_attributes(
                                          &PDU_dyn_attr_bufr,
                                          &PDU_dyn_data_bufr,
                                          PDU_usage_id, PDU_quantity,
                                          PDU_tagno, PDU_alt_tagno
                                         );
    _pdm_status("PDUadd_static_dyn_attributes",status);
    }

  if (PDM_debug_on)
    {
        MEMprint_buffer("PDU_dyn_attr", PDU_dyn_attr_bufr, PDU_DEBUG_FILE);
        MEMprint_buffer("PDU_dyn_data", PDU_dyn_data_bufr, PDU_DEBUG_FILE);
    }
  /* set global structures */

  /* Erase the displayed form */

  _pdm_debug("deleting form", 0);
  FIf_delete ( fp );
  PDU_perm_window = FALSE;

  /* Process form data */

  _pdm_debug("checking PDU_calling_form", 0);
  if (PDU_calling_form)
    FIf_display(PDU_calling_form);
  _pdm_debug("putting MOVE_ON to the queue", 0);
  responses[0] = MOVE_ON;
  strings[0] = "";
  PDUprepare_queue(responses, strings, 1);
  
 _pdm_debug("Leaving dynamic_attribute notification routine", 0);
 break;

    case USER_DEF_ATTR:     /* Sequenced to     */

         FImcf_get_active_col(forms.dynamic_attr_form_id, USER_DEF_ATTR, &col,
		       &pos);

         /* Get the text string */

         FIfld_get_active_row(forms.dynamic_attr_form_id, USER_DEF_ATTR, &row,
                              &pos);
         FIfld_get_text_length(fp,USER_DEF_ATTR,row,col,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp,USER_DEF_ATTR,row,col,length,
                        (unsigned char*)text,&select,&pos);

         if ((!pos_cursor) && ((text == NULL) || (strcmp(text, "") == 0)))
           {
           FIfld_get_active_row(forms.dynamic_attr_form_id, USER_DEF_ATTR, &row,
                                &pos);
           FIfld_pos_cursor(forms.dynamic_attr_form_id, USER_DEF_ATTR, 
                            row,pos,
                            1,1,0,0);
           pos_cursor = TRUE;
           break;
           }
        else if ((text == NULL) || (strcmp(text, "") == 0))
          break;

         pos_cursor = FALSE;
         if (col == 0)
         {
         if (text[0] == '*')
           {
           /* attribute has a value list assosciated with it */
           _pdm_debug("attribute is <%s>", text);
           PDUfill_in_string(&temp, text);
           /* strip off '*' from front of temp */
           temp = temp + 1;
           /*status = PDUprocess_pulldown_list(temp, PDU_dyn_attr_bufr, 
                                             PDU_dyn_value_bufr); */
           status = PDUprocess_dyn_pulldown_list(refresh->rev_catalog, temp,
                                                 PDU_dyn_attr_bufr);
           }
         else
           {
           msg_str = (char *)PDUtranslate_message(PDM_E_LIST_FUNC_NOT_EXISTS);
           FIg_set_text(fp, FI_MSG_FIELD, msg_str);
           FIfld_set_select(forms.dynamic_attr_form_id, USER_DEF_ATTR, row, 0, 
                            FALSE);
           }
          }
         else
         {
         _pdm_debug("ADD user data to dyn data buffer",0);
         PDUfill_in_string(&data, text);
         FImcf_set_active_col(forms.dynamic_attr_form_id, USER_DEF_ATTR, 0,0);
         FIfld_get_active_row(forms.dynamic_attr_form_id, USER_DEF_ATTR, &row,
                              &pos);
         FIfld_get_text_length(fp,USER_DEF_ATTR,row,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp,USER_DEF_ATTR,row,0,length,
                        (unsigned char*)text,&select,&pos);

         FImcf_set_active_col(forms.dynamic_attr_form_id, USER_DEF_ATTR, 1,1);
         if (((strcmp(text, "") == 0) || (text == NULL)) || ((data == NULL) ||
             (strcmp(data, "") == 0)))
           break;

       status = PDUvalidate_dyn_data_value(text, data, refresh->rev_catalog, 
                                       PDU_dyn_attr_bufr, 
                                       PDU_dyn_data_bufr);
       _pdm_status("PDUvalidate_dyn_data_value", status);

       if (status == PDM_E_FAILURE)
         {
         msg_str = (char *)PDUtranslate_message(PDM_E_ATTR_VALUE_GEN_FUNC);
         FIg_set_text(fp, FI_MSG_FIELD,msg_str);
         FIfld_set_text(fp, USER_DEF_ATTR, row, 1, "", FALSE);
         break;
         }

        if (text[0] == '*')
            text = text + 1;

       PDUfill_in_string(&attr_name, text);

       ptr = (char *)strrchr(attr_name, '(');
       if (ptr)
         {
          *((char *) strrchr(attr_name, '(')) = '\0';
          *((char *) strrchr(attr_name, ' ')) = '\0';
          }

        MEMbuild_array(PDU_dyn_attr_bufr);
       _pdm_debug("attr_name = <%s>", attr_name);
       row = PDUfind_dyn_attr_by_synonym(attr_name, PDU_dyn_attr_bufr);
       if (row != -1 )
         {
        _pdm_debug("row = %d", (char *)row);
        attr_data = (char **)PDU_dyn_attr_bufr->data_ptr;
        PDUfill_in_string(&attr_name, attr_data[(PDU_dyn_attr_bufr->columns * row) +
                           PDU_DYN_ATTR_COL]);
        _pdm_debug("attr_name = <%s>", attr_name);
        }
       row = PDUfind_attr_in_buffer(PDU_dyn_attr_bufr,attr_name);
       _pdm_debug("row = <%d>", (char *)row);
       attr_data = (char **)PDU_dyn_attr_bufr->data_ptr;
       PDUfill_in_string(&datatype, attr_data[(PDU_dyn_attr_bufr->columns * row)
                            + PDU_DYN_DATA_COL]);
        _pdm_debug("datatype = <%s>", datatype);


       if ((status != PDM_S_SUCCESS) && (strncmp(datatype, "char", 4) != 0))
       {
		/*  Commented out. See below
       status = PDUvalidate_expression(data);
       _pdm_status("PDUvalidate_expression", status);
		*/
		/* 139528430 fix - begin */
		char* tmp;
        tmp = ( char* ) malloc( strlen( data ) + 1 );
        strcpy( tmp, data );
        status =  parse_exp_and_get_value( &tmp );
    free (tmp);

    if (status == 1)
        status = PDM_S_SUCCESS;
        /*  139528430 fix - end */

       if (status != PDM_S_SUCCESS)
         {
         msg_str = (char *)PDUtranslate_message(PDM_E_BAD_DATA);
         FIg_set_text(fp, FI_MSG_FIELD, msg_str);
         FIfld_get_active_row(fp, USER_DEF_ATTR, &row, &pos);
         FIfld_set_text(fp, USER_DEF_ATTR,row, 1, "", FALSE);
         break;
         }
       else
         {
         _pdm_debug("User exntered expression", 0);
         }
         }
       else if (status != PDM_S_SUCCESS)
         {
         msg_str = (char *)PDUtranslate_message(status);
         FIg_set_text(forms.dynamic_attr_form_id,FI_MSG_FIELD,msg_str);
         FIfld_get_active_row(fp, USER_DEF_ATTR, &row, &pos);
         FIfld_set_text(fp, USER_DEF_ATTR,row, 1, "", FALSE);
         break;
         }

       status = PDUadd_dyn_data(attr_name, data, PDU_dyn_attr_bufr,
                                &PDU_dyn_data_bufr);
       if (status != PDM_S_SUCCESS)
         {
         msg_str = (char *)PDUtranslate_message(PDM_E_WRITE_BUFFER);
         FIg_set_text(forms.dynamic_attr_form_id, FI_MSG_FIELD, msg_str);
         break;
         }
       if (PDM_debug_on)
        MEMprint_buffer("PDU_dyn_data", PDU_dyn_data_bufr, PDU_DEBUG_FILE);
       }
         
         break;

    case VALUE_ASSOC_GADGET:

         list_row = value - 1;
         FIfld_get_active_row(fp, USER_DEF_ATTR, &row, &pos);
         FIfld_set_text(fp, USER_DEF_ATTR, row, 1, PDU_value_list[list_row], 
		        FALSE);
         _pdm_debug("value selected = <%s>", PDU_value_list[list_row]);
         FIfld_set_select(forms.dynamic_attr_form_id, USER_DEF_ATTR, row, 0, 
                          FALSE);
         /* write data selected to dyn_data buffer */
         FImcf_set_active_col(forms.dynamic_attr_form_id, USER_DEF_ATTR, 0,0);
         FIfld_get_text_length(fp,USER_DEF_ATTR,row,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp,USER_DEF_ATTR,row,0,length,
                        (unsigned char*)text,&select,&pos);
         
         FImcf_set_active_col(fp, USER_DEF_ATTR, 1,1);
         PDUfill_in_string(&temp, text);
         if (temp[0] == '*')
           temp = temp + 1;
        _pdm_debug("temp = <%s>", temp);
         status = MEMbuild_array(PDU_dyn_attr_bufr);
         _pdm_status("MMEbuild_array", status);

       row = PDUfind_dyn_attr_by_synonym(temp, PDU_dyn_attr_bufr);
       if (row != -1 )
         {
        _pdm_debug("row = %d", (char *)row);
        attr_data = (char **)PDU_dyn_attr_bufr->data_ptr;
        PDUfill_in_string(&attr_name, attr_data[(PDU_dyn_attr_bufr->columns * row) +
                            PDU_DYN_ATTR_COL]);
        _pdm_debug("attr_name = <%s>", attr_name);
        }
       else
         PDUfill_in_string(&attr_name, temp);

       status = PDUadd_dyn_data(attr_name, PDU_value_list[list_row], 
                                PDU_dyn_attr_bufr,
                                &PDU_dyn_data_bufr);
       if (status != PDM_S_SUCCESS)
         {
         msg_str = (char *)PDUtranslate_message(PDM_E_WRITE_BUFFER);
         FIg_set_text(forms.dynamic_attr_form_id, FI_MSG_FIELD, msg_str);
         break;
         }
       if (PDM_debug_on)
        MEMprint_buffer("PDU_dyn_data", PDU_dyn_data_bufr, PDU_DEBUG_FILE);
         break;

    case PLACEMENT_OPTIONS:

         FIf_erase(forms.dynamic_attr_form_id);

         PDU_calling_form = forms.dynamic_attr_form_id;

         status = PDUdesign_options_form();
         _pdm_status("PDUdesign_options_form", status);

         break;

    } /* END switch ( g_label ) */
    return(1);
} /* END dynamic_attr_notification_routine() */

int PDUadd_dyn_data(attr_name,data,dyn_attr, dyn_data)

  char *attr_name;
  char *data;
  MEMptr dyn_attr;
  MEMptr *dyn_data;
  
  {
  int status;
  int row;
  MEMptr data_bufr;

  _pdm_debug("In PDUadd_dyn_data", 0);

  status = MEMbuild_array(dyn_attr);
  _pdm_status("MEMbuild_array(dyn_attr)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  row = PDUfind_attr_in_buffer(dyn_attr,attr_name);
  _pdm_debug("row = <%d>", (char *)row);
  if (row == -1)
    return(PDM_E_REQ_COLUMN_NOT_FOUND);

  data_bufr = *dyn_data;

  status = MEMbuild_array(data_bufr);
  _pdm_status("MEMbuild_array(data_bufr)", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  _pdm_debug("data = <%s>", data);
  status = MEMwrite_data(data_bufr, data, (row + 1),1);
  _pdm_status("MEMwrite", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_BUFFER);

  *dyn_data = data_bufr;
  return(PDM_S_SUCCESS);
  }
  
int dynamic_attr_form()
  {
  int  status;
  int  list_size;
  int  i;
  int  length;
  char **view_bufr_col = NULL;
  char **view_bufr_data = NULL;
  char *msg_str = NULL;

  status = FIf_new(DYNAMIC_ATTR_FORM, "Dynamic", 
	           dynamic_attr_notification_routine,
	           &forms.dynamic_attr_form_id);

  PDU_form_id = forms.dynamic_attr_form_id;
  PDU_attr_label = USER_DEF_ATTR;

  /* call dummy functions */
  /*status = PDUdummy_buffer(&PDU_dyn_attr_bufr, &PDU_dyn_data_bufr, 2);
  status = PDUdummy_list(&PDU_dyn_value_bufr);*/

  /* fill in the dynamic attribute list */
  if (PDU_dyn_attr_bufr)
    {
    _pdm_debug("dynamic attributes were defined", 0);
    if (PDU_func_buffer)
      MEMclose(&PDU_func_buffer);
    PDUmessage(PDS_M_FUNCTION_FILES, 's');
  status = PDMmove_functions(refresh->rev_catalog, storage->storage_name, 
                             &PDU_func_buffer);
  _pdm_status("PDMmove_functions", status);
    PDUmessage(status, 's');

  /*if ((PDU_func_buffer) && (PDM_debug_on))
    MEMprint_buffer("functions buffer", PDU_func_buffer, PDU_DEBUG_FILE);*/

   PDUfill_attribute_list1(PDU_dyn_attr_bufr,PDU_dyn_data_bufr);
   /* create the GRpulldown_list */
   list_size = 0;
   GRcreate_pull_down_list(DYNAMIC_ATTR_FORM, forms.dynamic_attr_form_id, 
		 VALUE_ASSOC_GADGET,MAX_ROWS,VIS_ROWS,PDU_value_list, list_size,
		  1, &PDU_value_pulldown);
    }
  else
    {
    _pdm_debug("no dynamic attributes defined", 0);
    FIg_erase(forms.dynamic_attr_form_id, USER_DEF_ATTR);
    FIg_erase(forms.dynamic_attr_form_id, USER_DEF_GRP);
    }

   if (PDU_viewnames == NULL)
     {
     /* erase the gadgets assosciated with viewnames */
     FIg_erase(forms.dynamic_attr_form_id, VIEW_NAME_GRP);
     }
   else
     {
     /* set default to first view name in viewname buffer*/
     status = MEMbuild_array(PDU_viewnames);
     view_bufr_col = (char **) PDU_viewnames->column_ptr;
     view_bufr_data = (char **) PDU_viewnames->data_ptr;
     for (i = 0; i < PDU_viewnames->columns; i++)
       if (strcmp(view_bufr_col[i], "p_view") == 0)
         {
         PDUfill_in_string(&part->view, view_bufr_data[i]);
         break;
         } 
      }

  /* set text in the viename, usage_id, tagno, alt_tagno, and quanity fields */
  if (part->view != NULL)
    FIg_set_text(forms.dynamic_attr_form_id, VIEW_NAME, part->view);

  _pdm_debug("PDU_usage_id = <%s>", PDU_usage_id);
  _pdm_debug("PDU_tagno = <%s>", PDU_tagno);
  _pdm_debug("PDU_alt_tagno = <%s>", PDU_alt_tagno);

  if ((PDU_usage_id) && (strcmp(PDU_usage_id, "") != 0))
  {
  length = strlen(PDU_usage_id);
  if (length > 25)
    {
    msg_str = (char *)PDUtranslate_message(PDM_I_DEFAULT_USAGE_LENGTH);
    FIg_set_text(forms.dynamic_attr_form_id, FI_MSG_FIELD,msg_str);
    PDUfill_in_string(&PDU_usage_id, NULL);
    }
  else
    FIg_set_text(forms.dynamic_attr_form_id, USAGE_ID, PDU_usage_id);
  }
  else FIg_set_text(forms.dynamic_attr_form_id, USAGE_ID,"");

  if ((PDU_quantity) && (strcmp(PDU_quantity,"") != 0))
    FIg_set_text(forms.dynamic_attr_form_id, QUANTITY, PDU_quantity);
  if ((PDU_tagno) && (strcmp(PDU_tagno, "") != 0))
    FIg_set_text(forms.dynamic_attr_form_id, TAG_NO, PDU_tagno);
  if ((PDU_alt_tagno) && (strcmp(PDU_alt_tagno, "") != 0))
    FIg_set_text(forms.dynamic_attr_form_id, ALTTAG_NO, PDU_alt_tagno);

  if (PDU_ng_placement)
    {
    /*FIg_erase(forms.dynamic_attr_form_id, USER_DEF_GRP);*/
    FIfld_set_mode(forms.dynamic_attr_form_id, USER_DEF_ATTR, 0, FI_REVIEW);
    FIfld_set_mode(forms.dynamic_attr_form_id, USER_DEF_ATTR, 1, FI_REVIEW);
    }

  FIg_erase(forms.dynamic_attr_form_id, PLACEMENT_OPTIONS);
  FIf_set_orig_coord(forms.dynamic_attr_form_id, 502, 562);
  FIf_display(forms.dynamic_attr_form_id);
  return(status); 
  }

int PDUdynamic_attr_form()

  {
  int status;

  status = dynamic_attr_form();
  return(status);
  }

int PDUdisplay_dynamic_form()

   {
   
   PDU_form_id = forms.dynamic_attr_form_id;
   FIf_set_orig_coord(forms.dynamic_attr_form_id, 502, 562);
   FIf_display(forms.dynamic_attr_form_id);

  return(PDM_S_SUCCESS);
  }

int PDUdynamics_for_part(input_bufr,filter_bufr, default_bufr)

  MEMptr  input_bufr;
  MEMptr  filter_bufr;
  MEMptr  default_bufr;

  {
  int status;
  int display_flag = FALSE;
  int  responses[1];
  char *strings[1];
  char usageid[40];
  char temp_usageid[256];
  char *p_explode = NULL;
  
  _pdm_debug("In the function PDUdynamics_for_part", 0);

  /*if ((input_bufr) && (PDM_debug_on))
    MEMprint_buffer("input buffer", input_bufr, PDU_DEBUG_FILE);*/

  if (PDU_dyn_attr_bufr)
    MEMclose(&PDU_dyn_attr_bufr);

  if (PDU_dyn_data_bufr)
    MEMclose(&PDU_dyn_data_bufr);

  if (PDU_dyn_value_bufr)
    MEMclose(&PDU_dyn_value_bufr);

  status = PDMquery_dynamic_attrs(refresh->rev_catalog, refresh->rev_partid, 
                                 refresh->rev_revision, &PDU_dyn_attr_bufr, 
                                 &PDU_dyn_data_bufr, &PDU_dyn_value_bufr, 
                                 &p_explode);
  _pdm_status("PDMquery_dynamic_attr", status);

  if (status != PDM_S_SUCCESS)
    return(status);

  if (input_bufr)
    {
    if (input_bufr->rows > 0)
    {
    status = PDUmerge_dynamic_attribute_bufrs(input_bufr);
    _pdm_status("PDUmerge_dynamic_attribute_bufrs", status);
    
    if (status != PDM_S_SUCCESS)
      return(status);
    }
    }

  if ((filter_bufr) && (filter_bufr->rows > 0))
    {
    status = PDUfilter_dynamic_attribute_bufrs(filter_bufr);
    _pdm_status("PDUfilter_dynamic_attribute_bufrs", status);
    }
    
  PDU_calling_form = 0;
  PDUfill_in_string(&PDU_quantity, "1");
  /* generate tag no */
  status = PDUgenerate_tag_no(&PDU_tagno, 0);
  _pdm_status("PDUgenerate_tag_no", status);
  _pdm_debug("generate tag = <%s>", PDU_tagno);
  if ((PDU_usage_id) && (strcmp(PDU_usage_id, "") != 0))
    {
    strcpy(temp_usageid, "");
    strcpy(temp_usageid, ":");
    strcat(temp_usageid,refresh->act_filename);
    strcat(temp_usageid,":PDU:macro_parts:");
    strcat(temp_usageid,PDU_usage_id);
    _pdm_debug("temp_usageid <%s>", temp_usageid);
    status = PALusage_id_unique(temp_usageid);
    _pdm_status("PALusage_id_unique", status);
    if (status != 1)
      {
      /* generate usageid */
      status = PDUget_default_usage_id(refresh->rev_catalog,refresh->rev_partid,
                                       refresh->rev_revision, usageid);
      _pdm_status("PDUget_default_usageid", status);

      if ((usageid != NULL) && (strcmp(usageid, "") != 0))
        {
        _pdm_debug("usageid = <%s>", usageid);
        PDUfill_in_string(&PDU_usage_id, usageid);
        }
      }
    }
  else
    {
    /* generate usageid */
    status = PDUget_default_usage_id(refresh->rev_catalog,refresh->rev_partid,
                                     refresh->rev_revision, usageid);
    _pdm_status("PDUget_default_usageid", status);

    if ((usageid != NULL) && (strcmp(usageid, "") != 0))
      {
      _pdm_debug("usageid = <%s>", usageid);
      PDUfill_in_string(&PDU_usage_id, usageid);
      }
    }

    if (default_bufr)
      {
      status = PDUdefault_values_for_copy_parametric_part(PDU_dyn_attr_bufr,
                                                          &PDU_dyn_data_bufr,
                                                          default_bufr);
      _pdm_status("PDUdefault_vales_for_copy_parametric_part", status);
      }
      
    if (PDU_display_dyn_attr)
    {
    status = PDUdynamic_attr_form();
    _pdm_status("PDUdynamic_attr_form", status);
    }
    else 
    {
    _pdm_debug("Check to see if form needs to be displayed", 0);
    if (PDU_dyn_attr_bufr == NULL)
      display_flag = FALSE;
    else if (PDU_dyn_attr_bufr->rows == 0)
      display_flag = FALSE;
/*  else *//* Modified by raj.	*/
    else if (default_bufr == NULL)
      display_flag = PDUcheck_display_dynamic_attr(PDU_dyn_attr_bufr,
                                                   PDU_dyn_data_bufr);
/* added by raj.	*/
    else
      display_flag = TRUE;    

    _pdm_debug("display_flag = <%d>", (char*)display_flag);
    if (display_flag)
      {
      status = PDUdynamic_attr_form();
      _pdm_status("PDUdynamic_attr_form", status);
      }
    else
      {
      status = PDUadd_static_dyn_attributes(
                                          &PDU_dyn_attr_bufr,
                                          &PDU_dyn_data_bufr,
                                          PDU_usage_id, PDU_quantity,
                                          PDU_tagno, PDU_alt_tagno
                                         );
      _pdm_debug("putting MOVE_ON to the queue", 0);
      responses[0] = MOVE_ON;
      strings[0] = "";
      PDUprepare_queue(responses, strings, 1);
      }
    }
  return(PDM_S_SUCCESS);
  }

int PDUmerge_dynamic_attribute_bufrs(input_bufr)

MEMptr input_bufr;

  {
  int status;
  int i;
  int attr_row;
  char *row = NULL;
  char **input_data;

  _pdm_debug("In PDUmerge_dynamic_attribute_bufrs", 0);

  status = MEMbuild_array(input_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  input_data = (char **)input_bufr->data_ptr;

  row = (char *)malloc(input_bufr->row_size);
  memset(row, NULL, input_bufr->row_size);

  if (PDU_dyn_attr_bufr == NULL)
    status = PDUcreate_new_dynamic_attr_buffr(&PDU_dyn_attr_bufr);
  else if (PDU_dyn_attr_bufr->rows == 0)
    {
    MEMclose(&PDU_dyn_attr_bufr);
    status = PDUcreate_new_dynamic_attr_buffr(&PDU_dyn_attr_bufr);
    }
  else
    MEMbuild_array(PDU_dyn_attr_bufr);
  for (i = 0; i < input_bufr->rows; i ++)
    {
    if (PDU_dyn_attr_bufr->rows > 0)
      {
      MEMbuild_array(PDU_dyn_attr_bufr);
      attr_row = PDUfind_attr_in_buffer(PDU_dyn_attr_bufr, 
                      input_data[(input_bufr->columns * i) + PDU_NFM_ATTR_COL]);
      }
    else
      attr_row = -1;

      if (attr_row == -1)
      {
      _pdm_debug("Adding atribute to buffer", 0);
    sprintf(row,
    "\1%s\1%s\1%s\1%s\1%s\1",
    input_data[(input_bufr->columns * i) + PDU_NFM_ATTR_COL],
    input_data[(input_bufr->columns * i) + PDU_NFM_DATA_COL],
    input_data[(input_bufr->columns * i) + PDU_NFM_SYN_COL],"Y","N");
    _pdm_debug("row = <%s>", row);
    status = MEMwrite(PDU_dyn_attr_bufr, row);
    _pdm_status("MEMwrite", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);
    }
    else 
      {
      _pdm_debug("Attribute already existed",0);
      status = MEMwrite_data(PDU_dyn_attr_bufr, "N", (attr_row + 1), 
                             (PDU_DYN_REQ_COL + 1));
      _pdm_status("MEMwrite_data", status);
      if (status != MEM_S_SUCCESS)
        return(PDM_E_WRITE_BUFFER);
      }
    memset(row, NULL, input_bufr->row_size);
    }

  if (row)
    free(row);

  /* TR# 139419259. Do not update if PDU_dyn_data_bufr is NULL.	*/
  /* Causes a crash in PDUupdate_dyn_data_buffer().		*/
  if (PDU_dyn_data_bufr)
  {
    status = PDUupdate_dyn_data_buffer(&PDU_dyn_data_bufr, PDU_dyn_attr_bufr);
    _pdm_status("PDUupdate_data_buffer", status);
  }

  return(PDM_S_SUCCESS);
  }

int PDUfilter_dynamic_attribute_bufrs(filter_bufr)

MEMptr filter_bufr;

  {
  int status;
  int i;
  int attr_row;
  char **filter_data;

  _pdm_debug("In PDUfilter_dynamic_attribute_bufrs", 0);

  status = MEMbuild_array(filter_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  filter_data = (char **)filter_bufr->data_ptr;

  if (PDU_dyn_attr_bufr == NULL)
    {
    _pdm_debug("no dynamic attributes to filter out", 0);
    return(PDM_S_SUCCESS);
    }
  else if (PDU_dyn_attr_bufr->rows == 0)
    {
    _pdm_debug("no dynamic attributes to filter out", 0);
    return(PDM_S_SUCCESS);
    }

  for (i = 0; i < filter_bufr->rows; i ++)
    {
      MEMbuild_array(PDU_dyn_attr_bufr);
      attr_row = PDUfind_attr_in_buffer(PDU_dyn_attr_bufr, 
                   filter_data[(filter_bufr->columns * i) + PDU_NFM_ATTR_COL]);
      if (attr_row != -1)
      {
      status = MEMwrite_data(PDU_dyn_attr_bufr, "N", (attr_row + 1), 
                             (PDU_DYN_WRITE_COL + 1));
      _pdm_status("MEMwrite_data", status);
      if (status != MEM_S_SUCCESS)
        return(PDM_E_WRITE_BUFFER);
      }
    }

  return(PDM_S_SUCCESS);
  }

int PDUadd_static_dyn_attributes(dyn_bufr,dyn_data,usageid,quantity,tagno,
                                 alttagno)

MEMptr *dyn_bufr;
MEMptr *dyn_data;
char *usageid;
char *quantity;
char *tagno;
char *alttagno;

  {
  int status;
  int i,j;
  int char_index;
  char *row = NULL;
  char **attr_data = NULL;
  char **data_data = NULL;
  MEMptr buffer = NULL;
  MEMptr data_buffer = NULL;

  _pdm_debug("PDUadd_static_dyn_attributes", 0);
  
  /* format new buffer */
  status = PDUcreate_new_dynamic_attr_buffr(&buffer);
  _pdm_status("PDUcreate_new_dynamic_attr_buffr", status);

  if (status != PDM_S_SUCCESS)
    return(status);

  /* write static dynamic attributes to new buffer */
  row = (char *)malloc(buffer->row_size);
  memset(row, NULL, buffer->row_size);

  sprintf(row, "\1%s\1%s\1\1\1\1", "p_quantity", "double");
  status = MEMwrite(buffer, row);
  _pdm_status("MEMwrite", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_BUFFER);

  sprintf(row, "\1%s\1%s\1\1\1\1", "p_usageid", "char(25)");
  status = MEMwrite(buffer, row);
  _pdm_status("MEMwrite", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_BUFFER);

  sprintf(row, "\1%s\1%s\1\1\1\1", "p_tagno", "integer");
  status = MEMwrite(buffer, row);
  _pdm_status("MEMwrite", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_BUFFER);

  sprintf(row, "\1%s\1%s\1\1\1\1", "p_alttagno", 
          "char(25)");
  status = MEMwrite(buffer, row);
  _pdm_status("MEMwrite", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_BUFFER);

  /* write dynamic attributes into new buffer */
  
  if (*dyn_bufr)
  {
  status = MEMbuild_array(*dyn_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

   attr_data = (char **) (*dyn_bufr)->data_ptr;
  for (i = 0; i < (*dyn_bufr)->rows; i++)
    {
    char_index = 0;
    memset(row, NULL, (*dyn_bufr)->row_size);
    for (j = 0; j < (*dyn_bufr)->columns; j++)
      {
      if ((attr_data[((*dyn_bufr)->columns * i) + j]) &&
          (strcmp(attr_data[((*dyn_bufr)->columns * i) + j], "") != 0))
        PDUadd_buffer_string(row, &char_index, attr_data[((*dyn_bufr)->columns 
                             * i) + j]);
      else
        row[char_index++]='\1';
      }
    _pdm_debug("row = <%s>", row);
    status = MEMwrite(buffer, row);
    _pdm_status("MEMwrite", status);

    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);
    }
    }

  /* format data buffer according to new attribute buffer */
  status = PDUupdate_dyn_data_buffer1(&data_buffer, buffer);
  _pdm_status("PDUupdate_dyn_data_buffer1", status);

  if (status != PDM_S_SUCCESS)
    return(status);

  /* write old data to new data buffer */
  if (*dyn_data)
  {
  status = MEMbuild_array(*dyn_data);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);
  
   data_data = (char **) (*dyn_data)->data_ptr;
  }

  free(row);
  row = (char *)malloc(data_buffer->row_size);
  memset(row, NULL, data_buffer->row_size);

  char_index = 0;
  if ((quantity) && (strcmp(quantity, "") != 0))
    PDUadd_buffer_string(row, &char_index, quantity);
  else
    row[char_index++] = '\1';
  
  /* write "" for n_listno */
  row[char_index++] = '\1';

  /* write "" for n_maxvalue */
  row[char_index++] = '\1';

  /* write "" for n_minvalue */
  row[char_index++] = '\1';

  status = MEMwrite(data_buffer, row);
  _pdm_status("MEMwrite", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_BUFFER);

  memset(row, NULL, data_buffer->row_size);
  char_index = 0;
  if ((usageid) && (strcmp(usageid, "") != 0))
    PDUadd_buffer_string(row, &char_index, usageid);
  else
    row[char_index++] = '\1';
  /* write "" for n_listno */
  row[char_index++] = '\1';

  /* write "" for n_maxvalue */
  row[char_index++] = '\1';

  /* write "" for n_minvalue */
  row[char_index++] = '\1';

  status = MEMwrite(data_buffer, row);
  _pdm_status("MEMwrite", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_BUFFER);

  memset(row, NULL, data_buffer->row_size);
  char_index = 0;
  _pdm_debug("tagno = <%s>", tagno);
  if ((tagno) && (strcmp(tagno, "") != 0))
    PDUadd_buffer_string(row, &char_index, tagno);
  else
    row[char_index++] = '\1';

  /* write "" for n_listno */
  row[char_index++] = '\1';

  /* write "" for n_maxvalue */
  row[char_index++] = '\1';

  /* write "" for n_minvalue */
  row[char_index++] = '\1';
  _pdm_debug("row = %s", row);
  status = MEMwrite(data_buffer, row);
  _pdm_status("MEMwrite", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_BUFFER);

  memset(row, NULL, data_buffer->row_size);
  char_index = 0;
  if ((alttagno) && (strcmp(alttagno, "") != 0))
    PDUadd_buffer_string(row, &char_index, alttagno);
  else
    row[char_index++] = '\1';

  /* write "" for n_listno */
  row[char_index++] = '\1';

  /* write "" for n_maxvalue */
  row[char_index++] = '\1';

  /* write "" for n_minvalue */
  row[char_index++] = '\1';

  status = MEMwrite(data_buffer, row);
  _pdm_status("MEMwrite", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_BUFFER);

  if (*dyn_data)
  {
  for ( i = 0; i < (*dyn_data)->rows; i++)
    {
    char_index = 0;
    memset(row, NULL, data_buffer->row_size);
    for ( j = 0; j < (*dyn_data)->columns; j ++)
    {
    if ((data_data[((*dyn_data)->columns * i) + j]) && 
        (strcmp(data_data[((*dyn_data)->columns * i) + j], "") != 0))
      PDUadd_buffer_string(row, &char_index, data_data[((*dyn_data)->columns * 
                           i) + j]);
    else
      row[char_index++] = '\1';
    }
    status = MEMwrite(data_buffer, row);
    _pdm_status("MEMwrite", status);

    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);
    }
  }

  /* close input buffers */
  if (*dyn_bufr)
    MEMclose(dyn_bufr);
  if (*dyn_data)
    MEMclose(dyn_data);

  status = MEMsplit_copy_buffer(buffer, dyn_bufr, 0);
  _pdm_status("MEMsplit_copy_buffer", status);

  if (status != MEM_S_SUCCESS)
    return(status);

  status = MEMsplit_copy_buffer(data_buffer, dyn_data, 0);
  _pdm_status("MEMsplit_copy_buffer", status);

   if (status != MEM_S_SUCCESS)
     return(status);

  MEMclose(&buffer);
  MEMclose(&data_buffer);

  return(PDM_S_SUCCESS);
  }

int PDUupdate_dynamics()

  {
  int length;
  int select;
  int status;
  Form fp;
  int row;
  int pos;
  char *text = NULL;
  char *temp = NULL;
  char *attr_name = NULL;
  char **attr_data = NULL;
  char *msg_str;

  _pdm_debug("In PDUupdate_dynamics", 0);
  fp = forms.dynamic_attr_form_id;

  _pdm_debug("getting active row", 0);
  FIfld_get_active_row(fp, USER_DEF_ATTR, &row, &pos);
  _pdm_debug("setting text", 0);
  FIfld_set_text(fp, USER_DEF_ATTR, row, 1, PDU_attr_value,
                 FALSE);
  _pdm_debug("value selected = <%s>", PDU_attr_value);
  FIfld_set_select(forms.dynamic_attr_form_id, USER_DEF_ATTR, row, 0,
                   FALSE);
  /* write data selected to dyn_data buffer */
  FImcf_set_active_col(forms.dynamic_attr_form_id, USER_DEF_ATTR, 0,0);
  FIfld_get_text_length(fp,USER_DEF_ATTR,row,0,&length);
  text = (char *) malloc (sizeof (char) * length + 1);
  memset(text, NULL, sizeof (char) * length + 1);
  FIfld_get_text(fp,USER_DEF_ATTR,row,0,length,
                 (unsigned char*)text,&select,&pos);

  FImcf_set_active_col(fp, USER_DEF_ATTR, 1,1);
  PDUfill_in_string(&temp, text);
  if (temp[0] == '*')
    temp = temp + 1;
  _pdm_debug("temp = <%s>", temp);
  status = MEMbuild_array(PDU_dyn_attr_bufr);
  _pdm_status("MMEbuild_array", status);

  row = PDUfind_dyn_attr_by_synonym(temp, PDU_dyn_attr_bufr);
  if (row != -1 )
    {
    _pdm_debug("row = %d", (char *)row);
   attr_data = (char **)PDU_dyn_attr_bufr->data_ptr;
   PDUfill_in_string(&attr_name, attr_data[(PDU_dyn_attr_bufr->columns * row) +
                            PDU_DYN_ATTR_COL]);
    _pdm_debug("attr_name = <%s>", attr_name);
    }
  else
    PDUfill_in_string(&attr_name, temp);

    status = PDUadd_dyn_data(attr_name, PDU_attr_value, PDU_dyn_attr_bufr,
                             &PDU_dyn_data_bufr);
  if (status != PDM_S_SUCCESS)
    {
     msg_str = (char *)PDUtranslate_message(PDM_E_WRITE_BUFFER);
     FIg_set_text(forms.dynamic_attr_form_id, FI_MSG_FIELD,msg_str);
      return(status);
    }
  /*if (PDM_debug_on)
    MEMprint_buffer("PDU_dyn_data", PDU_dyn_data_bufr, PDU_DEBUG_FILE);*/

 return(PDM_S_SUCCESS);
  }

int PDUcheck_for_required_data(attr_bufr, data_bufr, msg)

MEMptr attr_bufr;
MEMptr data_bufr;
char *msg;

  {
  int status = PDM_S_SUCCESS;
  int i;
  char **attr_data = NULL;
  char **data_data = NULL;
  
  _pdm_debug("In PDUcheck_for_required_data", 0);

  if (attr_bufr == NULL)
    return(PDM_S_SUCCESS);
  
  if (data_bufr == NULL)
    return(PDM_S_SUCCESS);

  status = MEMbuild_array(attr_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  status = MEMbuild_array(data_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  status = PDM_S_SUCCESS;
  attr_data = (char **)attr_bufr->data_ptr;
  data_data = (char **)data_bufr->data_ptr;

  for (i = 0; i < attr_bufr->rows; i++)
    {
   if ((strcmp(attr_data[(attr_bufr->columns * i) + PDU_DYN_REQ_COL], "N") == 0)
      && (strcmp(attr_data[(attr_bufr->columns * i) + PDU_DYN_ATTR_COL],
          "p_pdcno") != 0))
      {
      _pdm_debug("attribute <%s> is required to have a value", 
                  attr_data[(attr_bufr->columns * i) + PDU_DYN_REQ_COL]);
      if ((data_data[(data_bufr->columns * i) + PDU_DYN_DEFAULT_VAL_COL]) && 
          (strcmp(data_data[(data_bufr->columns * i) + PDU_DYN_DEFAULT_VAL_COL],
           "") != 0))
        continue;
      else
        {
        if ((attr_data[(attr_bufr->columns * i) + PDU_DYN_SYN_COL]) && 
            (strcmp(attr_data[(attr_bufr->columns * i) + PDU_DYN_SYN_COL], "")
            != 0))
        sprintf(msg, "The attribute %s is required to have a value", 
                attr_data[(attr_bufr->columns * i) + PDU_DYN_SYN_COL]);
        else
        sprintf(msg, "The attribute %s is required to have a value", 
                attr_data[(attr_bufr->columns * i) + PDU_DYN_ATTR_COL]);
        status = PDM_E_REQATTR_NOT_FOUND;
        break;
        }
      }
     }
  return(status);
  }

int PDUcheck_display_dynamic_attr(attr_bufr, data_bufr)

MEMptr attr_bufr;
MEMptr data_bufr;

  {
  int status;
  int i;
  int display_flag = FALSE;
  char **attr_data = NULL;
  char **data_data = NULL; 

  _pdm_debug("PDUcheck_display_dynamic_attr", 0);
  
  if (attr_bufr == NULL)
    return(FALSE);
  else if (attr_bufr->rows == 0)
    return(FALSE);
  
  if (data_bufr == NULL)
    return(FALSE);
  else if (data_bufr->rows == 0)
    return(FALSE);

  status = MEMbuild_array(attr_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(TRUE);
  
  status = MEMbuild_array(data_bufr);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(TRUE);

  attr_data = (char **)attr_bufr->data_ptr;
  data_data = (char **)data_bufr->data_ptr;

  for (i = 0; i < attr_bufr->rows; i++)
    {
    if ((attr_data[(attr_bufr->columns * i) + PDU_DYN_ATTR_COL]) &&
         (strcmp(attr_data[(attr_bufr->columns * i) + PDU_DYN_ATTR_COL], 
         "p_pdcno") == 0))
      continue;
    else if (((attr_data[(attr_bufr->columns * i) + PDU_DYN_WRITE_COL]) &&
    (strcmp(attr_data[(attr_bufr->columns * i) + PDU_DYN_WRITE_COL], "Y") == 0))
    && ((attr_data[(attr_bufr->columns * i) + PDU_DYN_REQ_COL]) &&
    (strcmp(attr_data[(attr_bufr->columns * i) + PDU_DYN_REQ_COL], "N") == 0)))
      {
      _pdm_debug("attribute is required", 0);
      if ((data_data[(data_bufr->columns * i) + PDU_DYN_DEFAULT_VAL_COL]) && 
          (strcmp(data_data[(data_bufr->columns * i) + PDU_DYN_DEFAULT_VAL_COL],
           "") != 0))
        continue;
      else
        display_flag = TRUE;
      }
    }

  return(display_flag);
  }
        
int PDUdefault_values_for_copy_parametric_part(attr_bufr,data_bufr,default_bufr)

  MEMptr attr_bufr;
  MEMptr *data_bufr;
  MEMptr default_bufr;
  {
  int status;
  int attrname_col = -1; 
  int value_col = -1; 
  int data_value_col = -1; 
  int i;
  int j;
  char **default_data = NULL;
  char **attr_data = NULL;

  _pdm_debug("In PDUdefault_values_for_copy_parametric_part", 0);
  if (*data_bufr == NULL)
    return(PDM_E_NULL_BUFFER);
  else if ((*data_bufr)->rows == 0)
    return(PDM_E_NULL_BUFFER);
  else if (default_bufr == NULL)
    return(PDM_E_NULL_BUFFER);
  else if (default_bufr->rows == 0)
    return(PDM_E_NULL_BUFFER); 

  status = MEMbuild_array(*data_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  status = MEMbuild_array(default_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  status = MEMbuild_array(attr_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  attr_data = (char **)attr_bufr->data_ptr;
  default_data = (char **)default_bufr->data_ptr;

  PDUget_buffer_col(default_bufr, "n_name", &attrname_col);
  PDUget_buffer_col(default_bufr, "n_value", &value_col);
  PDUget_buffer_col(*data_bufr, "n_defaultvalue", &data_value_col);
  for ( i = 0; i < default_bufr->rows; i++)
    {
    for ( j = 0; j < attr_bufr->rows; j++)
       {
       if (strcmp(attr_data[(attr_bufr->columns * j) + PDU_DYN_ATTR_COL], 
           default_data[(default_bufr->columns * i) + 
          attrname_col]) == 0)
         { 
         _pdm_debug("match found", 0);
         status = MEMwrite_data(*data_bufr, default_data[(default_bufr->columns
                                * i) + value_col], (j + 1), (data_value_col + 1));
         _pdm_status("MEMwrite_data", status);
         if (status != MEM_S_SUCCESS)
           break;
         }
       }
    }
  if (status != MEM_S_SUCCESS)
    return(PDM_E_WRITE_BUFFER);
  return(PDM_S_SUCCESS);
  }
