#include <stdio.h>
#include <tools.h>
#include <FI.h>
#include <PDUerror.h>
#include <PDUstr.h>
#include <PDUcommand.h>
#include <PDUforms.h>
#include "PDUform_def.h"
#include <MEMerrordef.h>
#include "PDUfile_def.h"
#include "PDUassy.h"
#include "MEMstruct.h"
#include "PDUproto.h"
#include "PDMproto.h"

/* Gadgets */

#define MACRO_LIBRARY 14
#define LIB_DESCR     15
#define MCF2_GRP      39
#define LIB_MCF       18
#define MCF1_GRP      38
#define SUP_LIB_MCF   17
#define ADD_LIB       42
#define CAT_NAME_FLD  45
#define CAT_LIST      52
#define DELETE_LIB    40
#define CAT_DESCR     43


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
extern char   *PDU_macro_library;
extern char   *PDU_macro_catalog;
extern char   *PDU_macro_partrev;
extern char   *PDU_macro_partid;
extern char   *PDU_store_catalog;
extern int    bufr_flag;
extern int    PDU_selected_rows;
extern int    PDMdebug_on;
extern int  PDU_active_button;
extern int  PDU_refresh_gadgets[7];
extern Form PDU_form_id;
extern MEMptr PDU_cat_class_bufr;

static MEMptr save_class_bufr = NULL;

int define_lib_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  static char   * text;
  int             status;
  int             length;
  int             select;
  int             pos;
  MEMptr          parts_bufr = NULL;
  MEMptr          ass_bufr = NULL;
  char            *msg;

  switch ( g_label )
  {
    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

          /* Erase the displayed form */

         _pdm_debug("f_label = <%d>", (char *)f_label);
         value = 0.0;
         if (PDU_cat_class_bufr)
           {
           MEMclose(&PDU_cat_class_bufr);
           PDU_cat_class_bufr = NULL;
           }
         if (save_class_bufr)
           {
           MEMsplit_copy_buffer(save_class_bufr, &PDU_cat_class_bufr, 0);
           MEMclose(&save_class_bufr);
           }
        
         FIf_delete ( fp );

         if ((PDU_store_catalog) && (strcmp(PDU_store_catalog, "") != 0))
           {
           PDUfill_in_string(&refresh->rev_catalog, PDU_store_catalog);
           PDUfill_in_string(&PDU_store_catalog, NULL);
           }

         FIf_display(forms.parametric_catalog_form_id);

         break;

    case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */

          /* Erase the displayed form */
         if (PDU_cat_class_bufr)
           {
           MEMclose(&PDU_cat_class_bufr);
           PDU_cat_class_bufr = NULL;
           }

         if (save_class_bufr)
           {
           MEMsplit_copy_buffer(save_class_bufr, &PDU_cat_class_bufr, 0);
           MEMclose(&save_class_bufr);
           }

         FIf_erase ( fp );

          /* Process form data */
         if ((PDU_store_catalog) && (strcmp(PDU_store_catalog, "") != 0))
           {
           PDUfill_in_string(&refresh->rev_catalog, PDU_store_catalog);
           PDUfill_in_string(&PDU_store_catalog, NULL);
           }

         /* load buffer info */
         status = PDUload_support_lib_bufr(&ass_bufr);
         _pdm_status("PDUload_support_lib_bufr", status);

         if (PDMdebug_on)
           MEMprint_buffer("assembly buffer", ass_bufr, PDU_DEBUG_FILE);
 
         status = PDMdefine_support_libraries(PDU_macro_catalog, 
                                              PDU_macro_partid, 
                                              PDU_macro_partrev,
                                              ass_bufr);
         _pdm_status("PDMdefine_support_libraries", status);

         if (ass_bufr)
           MEMclose(&ass_bufr);

         PDUmessage(status, 's');
         FIf_delete ( fp );
         
         FIf_display(forms.parametric_catalog_form_id);
         break;

    case MACRO_LIBRARY:         /* Field Type:    ASCII    */

         break;

    case LIB_DESCR:         /* Field Type:    ASCII    */

          /* Get the text string */

         FIfld_get_text_length(fp,LIB_DESCR,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         status = FIfld_get_text(fp,LIB_DESCR,0,0,length,
                                 (unsigned char*)text,&select,&pos);

          if ( status != FI_SUCCESS )
            {
              /* Code to handle error */
              msg = (char *)PDUtranslate_message(PDM_E_LIBRARY_FORM);
              FIg_set_text(fp, FI_MSG_FIELD, msg);
              break;
            }

          /* Code to process text string "text" */


         break;

    case LIB_MCF:     /* Member of group GROUP1  */
                             /* Sequenced to    */

         status = PDUcheck_for_mcf_select(fp, LIB_MCF);
         _pdm_status("PDUcheck_for_mcf_select", status);

         if (status == PDM_S_SUCCESS)
           FIg_enable(fp, ADD_LIB);
         else
           FIg_disable(fp, ADD_LIB);

         break;

    case SUP_LIB_MCF:     /* Member of group GROUP2  */
                             /* Sequenced to    */

         status = PDUcheck_for_mcf_select(fp, SUP_LIB_MCF);
         _pdm_status("PDUcheck_for_mcf_select", status);

         if (status == PDM_S_SUCCESS)
           FIg_enable(fp, DELETE_LIB);
         else
           FIg_disable(fp, DELETE_LIB);

         break;

    case ADD_LIB:     /* Sequenced to     */

         status = PDUadd_define_library();
         _pdm_status("PDUadd_define_library", status);

         if (status != PDM_S_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_I_SEL_LIBRARY);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }

         break;

    case CAT_NAME_FLD:         /* Field Type:    ASCII    */

          /* Get the text string */

         FIfld_get_text_length(fp,CAT_NAME_FLD,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         status = FIfld_get_text(fp,CAT_NAME_FLD,0,0,length,
                                 (unsigned char*)text,&select,&pos);

          if ( status != FI_SUCCESS )
            {
              /* Code to handle error */
              msg = (char *)PDUtranslate_message(PDM_E_CAT_NAME_FORM);
              FIg_set_text(fp, FI_MSG_FIELD, msg);
              break;
            }

          /* Code to process text string "text" */
           bufr_flag = FALSE;

          /* validate catalog on the specific arg */
          status = PDUvalid_catalog("", text);
          _pdm_status("PDUvalid_catalog",status);
 
          if (status != PDM_S_SUCCESS)
            {
            msg = (char *)PDUtranslate_message(PDM_E_INVALID_CHAR_IN_CAT);
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            FIg_set_text(fp, CAT_NAME_FLD, "");
            if ((refresh->rev_catalog) && 
                (strcmp(refresh->rev_catalog, "") != 0))
              PDUfill_in_string(&refresh->rev_catalog, NULL);
            break;
            }

          PDUfill_in_string(&refresh->rev_catalog,text);

          /* get parts in catalog */
          status = PDMsearch_parts_in_catalog(refresh->rev_catalog, 
                                              &parts_bufr);
          _pdm_status("PDMsearch_parts_in_catalog", status);

          if ((status != PDM_S_SUCCESS) || (parts_bufr == NULL))
            {
            msg = (char *)PDUtranslate_message(PDM_E_CAT_NO_PARTS); 
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }
          else if (parts_bufr->rows == 0)
            {
            msg = (char *)PDUtranslate_message(PDM_E_CAT_NO_PARTS); 
            FIg_set_text(fp, FI_MSG_FIELD, msg);
            break;
            }


          PDUload_define_support_library_mcf(LIB_MCF, parts_bufr);
          if (parts_bufr)
            MEMclose(&parts_bufr);

         break;

    case CAT_LIST:     

          PDU_refresh_gadgets[1] = CAT_NAME_FLD;
          PDU_active_button = CAT_LIST;
          FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
         status = PDUep_cat_btn();
         _pdm_status("PDUep_cat_btn",status);

         break;

    case DELETE_LIB:     

         status = PDUdelete_support_library();
         _pdm_status("PDUdelete_support_library", status);

         if (status != PDM_S_SUCCESS)
           {
           msg = (char *)PDUtranslate_message(PDM_I_SEL_LIBRARY_DEL);
           FIg_set_text(fp, FI_MSG_FIELD, msg);
           break;
           }

         break;

    case CAT_DESCR:         /* Field Type:    ASCII    */

          /* Get the text string */

         FIfld_get_text_length(fp,CAT_DESCR,0,0,&length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         status = FIfld_get_text(fp,CAT_DESCR,0,0,length,
                                 (unsigned char*)text,&select,&pos);

          if ( status != FI_SUCCESS )
            {
              /* Code to handle error */
            }

          /* Code to process text string "text" */


         break;

  } /* END switch ( g_label ) */
  return(1);
} /* END notification_routine() */

int define_lib_form()
{
  int  status;
  int  i;
  char *string = NULL;
  int length;
  MEMptr asm_bufr = NULL;

  status = FIf_new(DEFINE_LIB_FORM, "define_lib",
                define_lib_notification_routine,
                &forms.define_lib_form_id);

  if ((PDU_store_catalog) && (strcmp(PDU_store_catalog, "") != 0))
    PDUfill_in_string(&PDU_store_catalog, NULL);

  if ((refresh->rev_catalog) && (strcmp(refresh->rev_catalog, "") != 0))
    {
    PDUfill_in_string(&PDU_store_catalog, refresh->rev_catalog);
    PDUfill_in_string(&refresh->rev_catalog, NULL);
    }

  length = strlen(PDU_macro_catalog) + strlen(PDU_macro_partid) + 
           strlen(PDU_macro_partrev) + 5;
  string = (char *)malloc(length);
  memset(string, NULL, length);
  sprintf(string, "%s:%s:%s", PDU_macro_catalog, PDU_macro_partid, 
          PDU_macro_partrev);
  _pdm_debug("string = <%s>", string);
  FIg_set_text(forms.define_lib_form_id, MACRO_LIBRARY, string);

  status = PDMget_assembly_structure(PDU_macro_catalog, PDU_macro_partid, 
                                     PDU_macro_partrev, MAX_LEVEL, &asm_bufr,0);
  _pdm_status("PDMget_assembly_structure", status);
  if (PDMdebug_on)
    MEMprint_buffer("assembly buffer", asm_bufr, PDU_DEBUG_FILE);
  MEMbuild_array(asm_bufr);
  for ( i = 0; i < asm_bufr->columns; i ++)
    MEMwrite_data(asm_bufr, "", 1, (i + 1));
  PDUload_define_support_library_mcf(SUP_LIB_MCF, asm_bufr);
  /* disable command buttons */
  FIg_disable(forms.define_lib_form_id, ADD_LIB);
  FIg_disable(forms.define_lib_form_id, DELETE_LIB);

  status = FIf_display(forms.define_lib_form_id);

  PDU_form_id = forms.define_lib_form_id;
  return(status);

}

int PDUdefine_library_form()

{
  int status;

  if (save_class_bufr)
    MEMclose(&save_class_bufr);
  if (PDU_cat_class_bufr)
    MEMsplit_copy_buffer(PDU_cat_class_bufr, &save_class_bufr, 0);

  status = define_lib_form();
  _pdm_status("define_lib_form", status);

  if (status == FI_SUCCESS)
    status = PDM_S_SUCCESS;

  return(status);
 }

int PDUload_define_support_library_mcf(gadget_label, buffer)

int gadget_label;
MEMptr buffer;

  {
  int no_headings;
  int all_flag;
  char **headings = NULL;

  _pdm_debug("In PDUload_define_support_library_mcf gadget_label = %d", 
              gadget_label);

  if (PDMdebug_on)
    MEMprint_buffer("library buffer", buffer, PDU_DEBUG_FILE);

  PDUsetup_single_buffer(buffer);

  all_flag = FALSE;
  if (gadget_label == SUP_LIB_MCF)
    no_headings = 3;
  else
    no_headings = 9;
  headings = (char **)malloc(sizeof (char *) * no_headings);
  memset(headings, NULL, sizeof (char *) * no_headings);

  PDUfill_in_string(&headings[0], "n_catalogname");
  PDUfill_in_string(&headings[1], "n_itemname");
  PDUfill_in_string(&headings[2], "n_itemrev");
  if (gadget_label != SUP_LIB_MCF)
    {
    PDUfill_in_string(&headings[3], "n_itemdesc");
    PDUfill_in_string(&headings[4], "n_filetype");
    PDUfill_in_string(&headings[5], "n_cofilename");
    PDUfill_in_string(&headings[6], "p_local");
    PDUfill_in_string(&headings[7], "n_statename");
    PDUfill_in_string(&headings[8], "p_update");
    }

  PDUsetup_popup_list(headings, no_headings, all_flag, buffer);
  _pdm_debug("After PDUsetup_popup_list", 0);

  PDUfree_string_array(&headings, no_headings);
  PDU_selected_rows = 0;

  _pdm_debug("Before PDU_bufr_to_mcf", 0);
  PDUbufr_to_mcf(buffer, forms.define_lib_form_id, gadget_label);
  FIfld_set_num_rows(forms.define_lib_form_id, gadget_label,buffer->rows);

  FIfld_set_active_row(forms.define_lib_form_id, gadget_label, 0, 0);
  if (gadget_label == SUP_LIB_MCF)
    FIfld_delete_rows(forms.define_lib_form_id, gadget_label, 0, 1);

  return(PDM_S_SUCCESS);
  }  

int PDUcheck_for_mcf_select(fp, gadget_label)
Form fp;
int gadget_label;

  {
  int status = PDM_S_SUCCESS;
  int num_rows;
  int i;
  int sel_flag;

  _pdm_debug("PDUcheck_for_mcf_select", 0);

  FIfld_get_num_rows(fp, gadget_label, &num_rows);

  for ( i = 0; i < num_rows ; i++)
    {
    FIfld_get_select(fp, gadget_label, i, 0, &sel_flag);
    if (sel_flag)
      {
      status = PDM_S_SUCCESS;
      break;
      }
    else
      status = PDM_E_FAILURE;
     }

  return(status);
  }

int PDUadd_define_library()

  {
  int length;
  int select;
  int pos;
  int sel_row;
  int num_rows;
  int num_cols;
  int i;
  int sel_flag;
  char *text = NULL;
 
  _pdm_debug("In PDUadd_define_library", 0);

  FIfld_get_num_rows(forms.define_lib_form_id, LIB_MCF, &num_rows);
  sel_row = -1; 
  for ( i = 0; i < num_rows; i++)
    {
    FIfld_get_select(forms.define_lib_form_id, LIB_MCF, i, 0, &sel_flag);
    if (sel_flag)
      sel_row = i;
    }

  if (sel_row == -1)
    return(PDM_E_FAILURE);

  FImcf_get_num_cols(forms.define_lib_form_id, LIB_MCF, &num_cols);
  FIfld_get_num_rows(forms.define_lib_form_id, SUP_LIB_MCF, &num_rows);
  FIfld_set_active_row(forms.define_lib_form_id, LIB_MCF, sel_row, 0);
  for ( i = 0; i < num_cols; i++)
    {
    if (i == 4)
      continue;
    FImcf_set_active_col(forms.define_lib_form_id, LIB_MCF, i, i);
    FIfld_get_text_length(forms.define_lib_form_id,LIB_MCF,sel_row,i,&length);
    text = (char *) malloc (sizeof (char) * length + 1);
    memset(text, NULL, sizeof (char) * length + 1);
    FIfld_get_text(forms.define_lib_form_id,LIB_MCF,sel_row,i,length,
                   (unsigned char*)text,
                   &select,&pos);

    if (i > 4)
      FIfld_set_text(forms.define_lib_form_id, SUP_LIB_MCF, num_rows, (i -1),
                    text, 
                   FALSE);
    else
      FIfld_set_text(forms.define_lib_form_id, SUP_LIB_MCF, num_rows, i, text, 
                     FALSE);
    }
  return(PDM_S_SUCCESS);
  }

int PDUdelete_support_library()

  {
  int sel_row;
  int num_rows;
  int i;
  int sel_flag;
 
  _pdm_debug("In PDUdelete_support_library", 0);

  FIfld_get_num_rows(forms.define_lib_form_id, SUP_LIB_MCF, &num_rows);
  sel_row = -1; 
  for ( i = 0; i < num_rows; i++)
    {
    FIfld_get_select(forms.define_lib_form_id, SUP_LIB_MCF, i, 0, &sel_flag);
    if (sel_flag)
      sel_row = i;
    }

  if (sel_row == -1)
    return(PDM_E_FAILURE);

  /*FImcf_get_num_cols(forms.define_lib_form_id, LIB_MCF, &num_cols);
  FIfld_get_num_rows(forms.define_lib_form_id, SUP_LIB_MCF, &num_rows);
  FIfld_set_active_row(forms.define_lib_form_id, LIB_MCF, sel_row, 0);
  for ( i = 0; i < num_cols; i++)
    {
    FImcf_set_active_col(forms.define_lib_form_id, LIB_MCF, i, i);
    FIfld_get_text_length(forms.define_lib_form_id,LIB_MCF, sel_row, i,&length);
    text = (char *) malloc (sizeof (char) * length + 1);
    memset(text, NULL, sizeof (char) * length + 1);
    FIfld_get_text(forms.define_lib_form_id,LIB_MCF, sel_row, i, length, 
                   (unsigned char*)text,
               &select, &pos);

    FIfld_set_text(forms.define_lib_form_id, SUP_LIB_MCF, num_rows, i, text, 
                   FALSE);
    }*/
  FIfld_delete_rows(forms.define_lib_form_id, SUP_LIB_MCF, sel_row,1);
  return(PDM_S_SUCCESS);
  }

int PDUload_support_lib_bufr(ass_bufr)

MEMptr *ass_bufr;

   {
   int length;
   int select;
   int pos;
   int status;
   int num_rows;
   int i;
   int char_index;
   char *text = NULL;
   char *row = NULL;

   _pdm_debug("PDUload_support_lib_bufr", 0);

  status = PDUformat_define_support_lib_bufr(ass_bufr);
  _pdm_status("PDUformat_define_support_lib_bufr", status);

  if (status != PDM_S_SUCCESS)
    return(status);

  FIfld_get_num_rows(forms.define_lib_form_id, SUP_LIB_MCF, &num_rows);
  _pdm_debug("num_rows = <%d>", (char *)num_rows);

  row = (char *)malloc((*ass_bufr)->row_size);
  memset(row, NULL, (*ass_bufr)->row_size);

  for (i = 0; i < num_rows; i++)
    {
    memset(row, NULL, (*ass_bufr)->row_size);
    char_index = 0;
    FIfld_set_active_row(forms.define_lib_form_id,SUP_LIB_MCF, i, 0);
    FImcf_set_active_col(forms.define_lib_form_id, SUP_LIB_MCF,0,0);
    FIfld_get_text_length(forms.define_lib_form_id,SUP_LIB_MCF, i, 0, &length);
    text = (char *) malloc (sizeof (char) * length + 1);
    memset(text, NULL, sizeof (char) * length + 1);
    FIfld_get_text(forms.define_lib_form_id, SUP_LIB_MCF, i, 0, length, 
                   (unsigned char*)text,
               &select, &pos);

    PDUadd_buffer_string(row, &char_index, text);
    FImcf_set_active_col(forms.define_lib_form_id, SUP_LIB_MCF,1,1);
    FIfld_get_text_length(forms.define_lib_form_id,SUP_LIB_MCF, i, 1, &length);
    text = (char *) malloc (sizeof (char) * length + 1);
    memset(text, NULL, sizeof (char) * length + 1);
    FIfld_get_text(forms.define_lib_form_id, SUP_LIB_MCF, i,1, length, 
                   (unsigned char*)text,
               &select, &pos);

    PDUadd_buffer_string(row, &char_index, text);
    FImcf_set_active_col(forms.define_lib_form_id, SUP_LIB_MCF,2,2);
    FIfld_get_text_length(forms.define_lib_form_id,SUP_LIB_MCF, i, 2, &length);
    text = (char *) malloc (sizeof (char) * length + 1);
    memset(text, NULL, sizeof (char) * length + 1);
    FIfld_get_text(forms.define_lib_form_id, SUP_LIB_MCF, i, 2, length, 
                   (unsigned char*)text,
               &select, &pos);
    PDUadd_buffer_string(row, &char_index, text);
    row[char_index++] = '\1';
    row[char_index++] = '\1';
    _pdm_debug("row = <%s>", row);
    status = MEMwrite(*ass_bufr, row);
    _pdm_status("MEMwrite", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_WRITE_BUFFER);
    }
  return(PDM_S_SUCCESS);
  }

int PDUdefine_support_update()

  {
  int status;
  MEMptr parts_bufr = NULL;
  char *msg;

  _pdm_debug("In PDUdefine_support_update", 0);


 /* get parts in catalog */
 status = PDMsearch_parts_in_catalog(refresh->rev_catalog,
                                      &parts_bufr);
 _pdm_status("PDMsearch_parts_in_catalog", status);

 if ((status != PDM_S_SUCCESS) || (parts_bufr == NULL))
   {
   msg = (char *)PDUtranslate_message(PDM_E_CAT_NO_PARTS);
   FIg_set_text(forms.define_lib_form_id, FI_MSG_FIELD, msg);
   return(PDM_S_SUCCESS);
   }
 else if (parts_bufr->rows == 0)
   {
   msg = (char *)PDUtranslate_message(PDM_E_CAT_NO_PARTS);
   FIg_set_text(forms.define_lib_form_id, FI_MSG_FIELD, msg);
   return(PDM_S_SUCCESS);
   }

  PDUload_define_support_library_mcf(LIB_MCF, parts_bufr);
   if (parts_bufr)
     MEMclose(&parts_bufr);

  return(PDM_S_SUCCESS);
  }
