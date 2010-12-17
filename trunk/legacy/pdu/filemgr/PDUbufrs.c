#include <stdio.h>
#include "FI.h"
#include "tools.h"
#include "PDUstr.h"
#include "PDUcommand.h"
#include "PDUstorage.h"
#include "PDUforms.h"
#include "PDUerror.h"
#include "PDUfile_def.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "part_gadgets.h"
#include "exdef.h"
#include "PDUform_def.h"
#include "PDMmessage.h"
#include "PDUproto.h"
#include "PDMproto.h"

/* Externs */

extern MEMptr   PDU_func_buffer;
extern MEMptr   PDU_ret_bufr;
extern MEMptr   PDU_file_bufr;
extern MEMptr   PDU_add_bufr;
extern MEMptr   PDU_ep_bufr;
extern MEMptr   PDU_hold_bufr;
extern MEMptr   PDU_copyof_ret_bufr;
extern MEMptr   PDU_ep_data_bufr;
extern int      pt_flag;
extern int      PDU_refresh_gadgets[7];
extern int      new_mode;
extern int      similar_mode;
extern int      change_mode;
extern int      review_mode;
extern int      PDMdebug_on;
extern int      PDU_simmode_cat_bufr;
extern int      PDM_debug_on;
extern char    *np_catalog;
extern char    *np_parttype;
extern char    *np_rev;
extern char    *np_desc;
extern char    *ep_parttype;
extern char    *ep_catalog;
extern char    *en_itemname;
extern char    *ep_rev;
extern char    *ep_desc;
extern struct   PDUforms   forms;
extern struct   PDUrefresh    *refresh;
extern struct   PDUstorage    *storage;
extern Form     PDU_form_id;
extern int      PDU_attr_label;
extern MEMptr   PDU_list_bufr;
extern int      PDU_simmode_copy;
extern int      PDU_simmode_checkin;

/* Globals */

extern MEMptr       PDU_attr_bufr;
extern MEMptr       PDU_data_bufr;
extern MEMptr       PDU_acl_bufr;
extern MEMptr       PDU_stg_bufr;
extern MEMptr       PDU_file_data_bufr;
extern MEMptr       PDU_sav_file_data_bufr;
extern MEMptr       PDU_add_data_bufr;
extern MEMptr       PDU_copyof_attr_bufr;
extern MEMptr       PDU_copyof_data_bufr;
extern MEMptr       PDU_copyof_stg_bufr;
extern MEMptr       PDU_copyof_acl_bufr;
extern char      ** PDU_attr_row;
extern char      ** PDU_attr_col;
extern char      ** PDU_attr_format;
extern char      ** PDU_data_row;
extern char      ** PDU_data_col;
extern char      ** PDU_data_format;
extern char      ** PDU_acl_row;
extern char      ** PDU_acl_col;
extern char      ** PDU_acl_format;
extern char      ** PDU_stg_row;
extern char      ** PDU_stg_col;
extern char      ** PDU_stg_format;
extern int          file_rows;
extern int          attr_rows;
extern int          PDU_func_bufr_exists;
extern int          PDU_part_checked_in;
extern int          PDU_disable_move_state_btn;
extern short        PDU_never_checked_in;
extern short        NULL_DATA;
extern short        PDU_disable_filedesc_col;
extern short        PDU_disable_localfn_col;
extern short        PDU_disable_storagefn_col;
extern short        PDU_disable_filetype_col;
extern short        PDU_filedesc_newfiles_disable;
extern short        PDU_localfn_newfiles_disable;
extern short        PDU_storagefn_newfiles_disable;
extern short        PDU_filetype_newfiles_disable;

int PDUinit_stack(stack,stack_size)

int ** stack;
int    stack_size;

{
   *stack = (int *) malloc (sizeof (int) * stack_size);
   memset(*stack, -1, sizeof (int) * stack_size);
   return(PDM_S_SUCCESS);

}

int PDUpush_into_stack(stack,stack_size,row_id)

int ** stack;
int    stack_size;
int    row_id;

{

   int  i;
   int  *temp;

   temp = (int *) malloc (sizeof (int) * stack_size);
   memset(temp, -1, sizeof (int) * stack_size);

   for (i = 0; i < stack_size - 1; ++i)
      {
      temp[i + 1] = (*stack)[i];
      }
   temp[0] = row_id;
   *stack = temp;
   return(PDM_S_SUCCESS);

}

int PDUget_top_of_stack(stack,top)

int  * stack;
int  * top;

{

   if (stack[0] != -1)
      *top = stack[0];
   else
      *top = -1;
   return(PDM_S_SUCCESS);
}

int PDUdelete_from_stack(stack,stack_size,row_id)

int  ** stack;
int  stack_size;
int  row_id;

{

   int  i,j;
   int  found = FALSE;

   for (i = 0; i < stack_size; ++i)
      {
      if ((*stack)[i] == row_id)
         {
         found = TRUE;
         for (j = i; j < stack_size - 1; ++j)
            {
            (*stack)[j] = (*stack)[j + 1];
            }
         (*stack)[stack_size - 1] = -1;
         }
      if (found)
         break;
      }
   if ((found) && (i == stack_size - 1))
      printf("No rows were deleted from the stack");
   return(PDM_S_SUCCESS);
}

int PDUprint_stack(stack,stack_size)
int  *stack;
int   stack_size;

{
   int  i;

   for (i = 0; i < stack_size; ++i)
      printf("stack[%d] = %d\n", i, stack[i]);
 
   return(PDM_S_SUCCESS);
}


/* This function will take the data from the attr_bufr, data_bufr, and list_bufr
   and place it in the appropriate fields and palettes on the Part Operations
   Form. This was incorporated into a function due to the fact that there is
   a lot of code to accomplish this task and it is used in many places which
   increased the size of the file. */

int  PDUpull_from_bufr()

{
MEMptr        attr_bufr = NULL;
MEMptr        data_bufr = NULL;
MEMptr        acl_bufr = NULL;
MEMptr        stg_bufr = NULL;
MEMptr        file_data_bufr = NULL;
MEMptr        add_data_bufr = NULL;
MEMptr        file_bufr = NULL;
MEMptr        add_bufr = NULL;
char       ** data1_row;
char       ** data1_col;
char       ** data1_format;
char       ** data2_row;
char       ** data2_col;
char       ** data2_format;
char       ** data3_row;
char       ** data3_col;
char       ** data3_format;
char       ** data4_row;
char       ** data4_col;
char       ** data4_format;
char       ** file_data_row;
char       ** file_data_col;
char       ** file_data_format;
char       ** add_data_row;
char       ** add_data_col;
char       ** add_data_format;
char       ** file_bufr_data_row;
char       ** file_bufr_data_col;
char       ** file_bufr_data_format;
char       ** add_bufr_data_row;
char       ** add_bufr_data_col;
char       ** add_bufr_data_format;
char        * strings[1];
char        * part_status = NULL;
int           length;
int           select;
int           pos;
int           found_filedesc = FALSE;   
int           found_localfn = FALSE;   
int           found_storagefn = FALSE;   
int           found_filetype = FALSE;   
int           vis_rows = 0;
int           acl_buffer_no = 0;
int           stg_buffer_no = 0;
int           status = PDM_S_SUCCESS;
int           status1 = PDM_S_SUCCESS;
int           max_rows;
int           count;
int           n_name_col;
int           n_syn_col;
int           p_filedesc_col;
int           n_cofilenm_col;
int           n_cifilenm_col;
int           n_filetype_col;
int           n_valueno_col;
int           n_aclname_col;
int           n_wf_col;
int           n_saname_col;
int           n_state_col;
int           p_parttype_col;
int           form_row = 1;
int           i,j;
int           n_aclno_col_for_data;
int           n_aclno_col;
int           n_cisano_col_for_data;
int           n_sano_col;
int           acl_row = 0;
int           cisano_row = 0;
int           attr_row;
int           n_status_col;
int           PDMterminate();
int           *fn = NULL;
int           responses[1];
int           update_col;
int           read_col;
char          *update = NULL;
char          *read = NULL;
static char   * text;
char          *msg = NULL;
short         filedesc_write = TRUE;
short         filetype_write = TRUE;
short         cifile_write = TRUE;
short         cofile_write = TRUE;
short         filedesc_read = TRUE;
short         filetype_read = TRUE;
short         cifile_read = TRUE;
short         cofile_read = TRUE;
short         filedesc_update = TRUE;
short         filetype_update = TRUE;
short         cifile_update = TRUE;
short         cofile_update = TRUE;
short         found = FALSE;

   _pdm_debug("Entering PDUpull_from_bufr",0);

   PDU_part_checked_in = FALSE;
   PDU_never_checked_in = FALSE;

   PDU_disable_filedesc_col = FALSE;
   PDU_disable_localfn_col = FALSE;
   PDU_disable_storagefn_col = FALSE;
   PDU_disable_filetype_col = FALSE;
   PDU_filedesc_newfiles_disable = FALSE;
   PDU_localfn_newfiles_disable = FALSE;
   PDU_storagefn_newfiles_disable = FALSE;
   PDU_filetype_newfiles_disable = FALSE;

   /* Blank out the ATTRIBUTE_VALUE_MCF */

   /* Find maximum number of rows */

   FIfld_get_num_rows(forms.part_operations_form_id,
                      ATTRIBUTE_VALUE_MCF,&max_rows);

   PDUremove_data(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF,
                  max_rows,2);
   FIg_reset(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF);
   FIfld_set_active_row(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF,0,0);

   if ((new_mode == TRUE) || (review_mode == TRUE))
      {
      /* Blank out the FILE_INFO_MCF */

      FIfld_get_num_rows(forms.part_operations_form_id,
                         FILE_INFO_MCF,&max_rows);

      PDUremove_data(forms.part_operations_form_id,FILE_INFO_MCF,
                     max_rows,4);
      }
   else if (similar_mode == TRUE)
      {
      /* Blank out the SIMILAR_MODE_MCF */

      FIfld_get_num_rows(forms.part_operations_form_id,
                         SIMILAR_MODE_MCF,&max_rows);

      PDUremove_data(forms.part_operations_form_id,SIMILAR_MODE_MCF,
                     max_rows,5);
      }
   else if (change_mode == TRUE)
      {
      /* Blank out the EXISTING_FILES_MCF */

      FIfld_get_num_rows(forms.part_operations_form_id,
                         EXISTING_FILES_MCF,&max_rows);

      PDUremove_data(forms.part_operations_form_id,EXISTING_FILES_MCF,
                     max_rows,4);

      /* Blank out the NEW_FILES_MCF */

      FIfld_get_num_rows(forms.part_operations_form_id,
                         NEW_FILES_MCF,&max_rows);

      PDUremove_data(forms.part_operations_form_id,NEW_FILES_MCF,
                     max_rows,4);
      }

   /* Blank out following fields */

   FIfld_set_text(forms.part_operations_form_id,STORAGE_AREA_FLD,0,0,
                  "",FALSE);
   FIfld_set_text(forms.part_operations_form_id,STATE_NAME_FLD,0,0,"",
                  FALSE);
   FIfld_set_text(forms.part_operations_form_id,WORKFLOW_FLD,0,0,"",
                  FALSE);
   FIfld_set_text(forms.part_operations_form_id,ACL_NAME_FLD,0,0,"",
                  FALSE);

      /* Using PDU_copyof_ret_bufr because PDU_ep_bufr was MEMreset_buffer in
         the function PDUsetup_buffer_list and this screws up the buffer
         pointer so that it cannot be set back to the first buffer. This
         results in only part of the buffers being copied. */
/*
   if (PDU_simmode_cat_bufr == TRUE)
      {
      MEMsplit_copy_buffer(PDU_copyof_ret_bufr,&PDU_ret_bufr,1);
      PDU_simmode_cat_bufr = FALSE;
      }
*/

   if (PDU_ret_bufr == NULL)
     _pdm_debug("PDU_ret_bufr is NULL", 0);

   status = PDUsetup_buffer_list(PDU_ret_bufr, 1, 0, &data1_row,
                                 &data1_col,&data1_format,&attr_bufr);
   _pdm_status("PDUsetup_buffer_list",status);

   if (status != PDM_S_SUCCESS)
      return(status);
       
   status = PDUsetup_buffer_list(PDU_ret_bufr, 2, 0, &data2_row,
                                 &data2_col,&data2_format,&data_bufr);
   _pdm_status("PDUsetup_buffer_list",status);

   if (status != PDM_S_SUCCESS)
      return(status);

/* QUESTION - Do we even have a PDU_ep_data_bufr */
/* case: enter form with no data, select similar, select catalog, select part
   NO :  we have PDU_ret_bufr, PDU_hold_bufr, PDU_ep_bufr - all identicle */

   /* save copy of data_bufr */
   if (PDU_ep_data_bufr)
      {
      MEMclose(&PDU_file_data_bufr);
      PDU_file_data_bufr = NULL;
      }

   if (similar_mode && (np_catalog == NULL))
     {
     _pdm_debug("creating PDU_ep_data_bufr", 0);
     status = MEMsplit_copy_buffer(data_bufr, &PDU_ep_data_bufr,0);
     }
   else if (similar_mode && ((strcmp(np_catalog, "") == 0) || 
                             (strcmp(np_catalog, ep_catalog) == 0)))
     {
     _pdm_debug("creating PDU_ep_data_bufr", 0);
     status = MEMsplit_copy_buffer(data_bufr, &PDU_ep_data_bufr,0);
     }

   /* Fill in the default Atrributes and Values */
 
   PDU_attr_label = ATTRIBUTE_VALUE_MCF;

   status = MEMreset_buffer_no(PDU_ret_bufr, 3);
   _pdm_status("MEMreset_buffer_no", status);

   status = MEMsplit_copy_buffer(PDU_ret_bufr, &PDU_list_bufr, 1);
   _pdm_status("MEMsplit_copy_buffer_no", status);

   if (PDMdebug_on)
      MEMprint_buffers("list_buffer", PDU_list_bufr, PDU_DEBUG_FILE);

   if ((new_mode == TRUE) || (similar_mode))
   {
   FIfld_get_text_length(forms.part_operations_form_id,NP_CATALOG_FLD,0,0,
                         &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id,NP_CATALOG_FLD,0,0,length,
                  (unsigned char *)text, &select, &pos);

   PDUfill_in_string1(&np_catalog, text);

   PDUmessage(PDS_M_FUNCTION_FILES, 's');
   status = PDMmove_functions(np_catalog,storage->storage_name,
                              &PDU_func_buffer);
   _pdm_status("PDMrmove_functions",status);
   PDUmessage(status, 's');

   if (status != PDM_S_SUCCESS)
      return(status);
   }
  else if (change_mode == TRUE)
   {
   PDUmessage(PDS_M_FUNCTION_FILES, 's');
   status = PDMmove_functions(refresh->rev_catalog,storage->storage_name,
                              &PDU_func_buffer);
   _pdm_status("PDMrmove_functions",status);

   if (status != PDM_S_SUCCESS)
      return(status);
   PDUmessage(status, 's');
   }
   if (PDMdebug_on)
      MEMprint_buffers("PDU_func_buffer inside PDUpull_from_bufr", 
                       PDU_func_buffer, PDU_DEBUG_FILE);

   status = PDUfill_attribute_list(attr_bufr, data_bufr, PDU_list_bufr);
   _pdm_status("PDUfill_attribute_list", status);

   if (status != PDM_S_SUCCESS)
      return(status);

   /* Set number of row in ATTRIBUTE_VALUE_MCF */
   FIfld_get_num_rows(PDU_form_id,ATTRIBUTE_VALUE_MCF, &attr_rows);
   FIfld_set_num_rows(PDU_form_id,ATTRIBUTE_VALUE_MCF, attr_rows);

   status = PDUget_col_number(attr_bufr,"n_name",data1_col,&n_name_col);
   _pdm_status("PDUget_col_number",status);

   if (status != PDM_S_SUCCESS)
      {
      PDUmessage(status, 's');
      return (status);
      }

   status = PDUget_col_number(attr_bufr,"n_synonym",data1_col, &n_syn_col);
   _pdm_status("PDUget_col_number",status);

   if (status != PDM_S_SUCCESS)
      if (status != PDM_S_SUCCESS)
      {
      PDUmessage(status, 's');
      return (status);
      }

   /* Fill in Part Type */

   FIfld_get_text_length(forms.part_operations_form_id,NP_CATALOG_FLD,0,0,
                         &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id,NP_CATALOG_FLD,0,0,length,
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&np_catalog, text);

   if (pt_flag == TRUE)
      {
      _pdm_debug("retrieving parttype", 0);
      status = PDUget_col_number(data_bufr,"p_parttype",data2_col,
                                 &p_parttype_col);

      _pdm_debug("checking parttype for read permission", 0);
      attr_row = PDUfind_attr_in_buffer(attr_bufr, "p_parttype");
      if (attr_row != -1)
        {
        status = PDUget_buffer_col(attr_bufr, "n_read", &read_col);
        if (status != PDM_S_SUCCESS)
          {
          PDUmessage(status, 's');
          return(status);
          }
        PDUfill_in_string(&read,
               data1_row[(attr_bufr->columns * attr_row)+read_col]);
        _pdm_debug("read = <%s>", read);
        if (strcmp(read, "Y") == 0)
          {
          _pdm_debug("displaying parttype", 0);

          for (i = 0; i < attr_bufr->rows; ++i)
            {
            if (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                data2_col[p_parttype_col]) == 0)
               {
               if ((similar_mode == TRUE) &&
                   (np_catalog == NULL) || (strcmp(np_catalog,"") == 0))
                  {
                  FIfld_set_text(forms.part_operations_form_id,
                                 EP_PARTTYPE_FLD,0,0,
                                 data2_row[(data_bufr->columns * 0) +
                                 p_parttype_col],FALSE);
   
                  PDUfill_in_string1(&ep_parttype,
                         data2_row[(data_bufr->columns * 0) + p_parttype_col]);
   
                  PDUfill_in_string(&refresh->rev_parttype,
                         data2_row[(data_bufr->columns * 0) + p_parttype_col]);
                  }
               else if ((new_mode == TRUE) || (similar_mode == TRUE))
                  {
                  FIfld_set_text(forms.part_operations_form_id,
                                 NP_PARTTYPE_FLD,0, 0, 
                                 data2_row[(data_bufr->columns * 0) +
                                 p_parttype_col],FALSE);
   
                  PDUfill_in_string1(&np_parttype,
                         data2_row[(data_bufr->columns * 0) + p_parttype_col]);
   
                  PDUfill_in_string(&refresh->new_parttype,
                         data2_row[(data_bufr->columns * 0) + p_parttype_col]);
   
                  PDUfill_in_string(&refresh->rev_parttype,
                         data2_row[(data_bufr->columns * 0) + p_parttype_col]);
   
                  PDUfill_in_string(&ep_parttype,
                         data2_row[(data_bufr->columns * 0) + p_parttype_col]);
                  }
               if ((change_mode == TRUE) || (review_mode == TRUE))
                  {
                  FIfld_set_text(PDU_form_id, EP_PARTTYPE_FLD, 0, 0, 
                    data2_row[(data_bufr->columns * 0) + p_parttype_col],FALSE);
   
                  PDUfill_in_string1(&ep_parttype,
                         data2_row[(data_bufr->columns * 0) + p_parttype_col]);
   
                  PDUfill_in_string(&refresh->rev_parttype,
                         data2_row[(data_bufr->columns * 0) + p_parttype_col]);
                  }
               break;
               }
            } 
          }
        else
           {
           _pdm_debug("parttype is NO READ", 0);
           FIg_set_text(forms.part_operations_form_id, EP_PARTTYPE_FLD,
                        NULL_STRING);
           FIg_disable(forms.part_operations_form_id,EP_PARTTYPE_FLD);
           FIg_disable(forms.part_operations_form_id,EP_PARTTYPE_BTN);
           PDUfill_in_string1(&ep_parttype,
                         data2_row[(data_bufr->columns * 0) + p_parttype_col]);
           PDUfill_in_string(&refresh->rev_parttype,
                         data2_row[(data_bufr->columns * 0) + p_parttype_col]);
           }
          }
        }

   /* Fill in Local Filename, Storage Filename, and File Type */
   if ((new_mode == TRUE) || (change_mode == TRUE) || (review_mode == TRUE) ||
       ((similar_mode == TRUE) &&
       (np_catalog != NULL) && (strcmp(np_catalog,"") != 0)))
      {
      _pdm_debug("setting file information", 0);
      if ((new_mode == TRUE) || (review_mode) ||
         ((similar_mode == TRUE) &&
          (np_catalog != NULL) && (strcmp(np_catalog,"") != 0)))
         {
         _pdm_debug("setting file information for review/similar/new mode", 0);
         status = PDUcheck_file_info_privileges(NULL, attr_bufr,
                             &filedesc_update, &filedesc_read, &filedesc_write,
                             &cofile_update, &cofile_read, &cofile_write,
                             &cifile_update, &cifile_read, &cifile_write,
                             &filetype_update, &filetype_read, &filetype_write);
         _pdm_status("PDUcheck_file_info_privileges", status);
         if (status != PDM_S_SUCCESS)
           _pdm_debug("failed to get file info permissions", 0);

         _pdm_debug("resetting attr_bufr pointers", 0);
         status = MEMbuild_array(attr_bufr);
         _pdm_status("MEMbuild_array", status);
         if (status != MEM_S_SUCCESS)
           return(PDM_E_BUILD_BUFFER_ARRAY);

         PDUsetup_buffer(attr_bufr, ROW, &data1_row);
         PDUsetup_buffer(attr_bufr, COL, &data1_col);

         if (new_mode)
           {
           if (!cofile_write)
             {
             FIfld_set_mode(PDU_form_id,FILE_INFO_MCF, 0, FI_REVIEW);
             FIfld_set_mode(PDU_form_id,FILE_INFO_MCF, 1, FI_REVIEW);
             FIfld_set_mode(PDU_form_id,FILE_INFO_MCF, 2, FI_REVIEW);
             FIfld_set_mode(PDU_form_id,FILE_INFO_MCF, 3, FI_REVIEW);
             msg = (char *) PDUtranslate_message(PDM_E_NO_WRITE_LOCAL_FILE);
             FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
             PDU_disable_localfn_col = TRUE;
             PDU_disable_storagefn_col = TRUE;
             PDU_disable_filedesc_col = TRUE;
             PDU_disable_filetype_col = TRUE;
             }
           if (!filedesc_write)
             {
             FIfld_set_mode(PDU_form_id,FILE_INFO_MCF, 0, FI_REVIEW);
             PDU_disable_filedesc_col = TRUE;
             }
           if (!cifile_write)
             {
             FIfld_set_mode(PDU_form_id,FILE_INFO_MCF, 2, FI_REVIEW);
             PDU_disable_storagefn_col = TRUE;
             }
           if (!filetype_write)
             {
             FIfld_set_mode(PDU_form_id,FILE_INFO_MCF, 3, FI_REVIEW);
             PDU_disable_filetype_col = TRUE;
             }
           }

         if (similar_mode)
           {
           if (!cofile_write)
             {
             FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 0, FI_REVIEW);
             FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 2, FI_REVIEW);
             FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 3, FI_REVIEW);
             FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 4, FI_REVIEW);
             msg = (char *) PDUtranslate_message(PDM_E_NO_WRITE_LOCAL_FILE);
             FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
             FIg_disable(PDU_form_id, SIMMODE_COPY_TGL);
             PDU_disable_localfn_col = TRUE;
             PDU_disable_storagefn_col = TRUE;
             PDU_disable_filedesc_col = TRUE;
             PDU_disable_filetype_col = TRUE;
             }
           if (!filedesc_write)
             {
             FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 0, FI_REVIEW);
             PDU_disable_filedesc_col = TRUE;
             }
           if (!cifile_write)
             {
             _pdm_debug("disabling storage filename column", 0);
             FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 3, FI_REVIEW);
             PDU_disable_storagefn_col = TRUE;
             }
           if (!filetype_write)
             {
             FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 4, FI_REVIEW);
             PDU_disable_filetype_col = TRUE;
             }
           }
         }
      else if (change_mode == TRUE)
         {
         if (PDU_file_bufr != NULL)
            {
            status = PDUsetup_buffer_list(PDU_file_bufr, 2, 0,
                                          &file_bufr_data_row,
                                          &file_bufr_data_col,
                                          &file_bufr_data_format, &file_bufr);

            if ((status != PDM_S_SUCCESS) && (status != PDM_E_NULL_BUFFER))
               return(status);

            if (PDMdebug_on)
               MEMprint_buffer("FILE_BUFR",file_bufr,PDU_DEBUG_FILE);

            status = PDUcheck_file_info_privileges(file_bufr, attr_bufr,
                             &filedesc_update, &filedesc_read, &filedesc_write,
                             &cofile_update, &cofile_read, &cofile_write,
                             &cifile_update, &cifile_read, &cifile_write,
                             &filetype_update, &filetype_read, &filetype_write);
            _pdm_status("PDUcheck_file_info_privileges", status);
            if (status != PDM_S_SUCCESS)
              _pdm_debug("failed to get file info permissions", 0);

            _pdm_debug("resetting file_bufr", 0);
            status = MEMbuild_array(file_bufr);
            _pdm_status("MEMbuild_array", status);
            if (status != MEM_S_SUCCESS)
              return(PDM_E_BUILD_BUFFER_ARRAY);
   
            PDUsetup_buffer(attr_bufr, ROW, &file_bufr_data_row);
            PDUsetup_buffer(attr_bufr, COL, &file_bufr_data_col);
            }
          else
            {
            status = PDUcheck_file_info_privileges(NULL, attr_bufr,
                             &filedesc_update, &filedesc_read, &filedesc_write,
                             &cofile_update, &cofile_read, &cofile_write,
                             &cifile_update, &cifile_read, &cifile_write,
                             &filetype_update, &filetype_read, &filetype_write);
            _pdm_status("PDUcheck_file_info_privileges", status);
            if (status != PDM_S_SUCCESS)
              _pdm_debug("failed to get file info permissions", 0);
            }

          _pdm_debug("resetting attr_bufr", 0);
          status = MEMbuild_array(attr_bufr);
          _pdm_status("MEMbuild_array", status);
          if (status != MEM_S_SUCCESS)
            return(PDM_E_BUILD_BUFFER_ARRAY);
 
          PDUsetup_buffer(attr_bufr, ROW, &data1_row);
          PDUsetup_buffer(attr_bufr, COL, &data1_col);

            if (!filedesc_update)
              {
              PDU_disable_filedesc_col = TRUE;
              FIfld_set_mode(PDU_form_id, EXISTING_FILES_MCF,0, FI_REVIEW);
              }
            else
              {
              PDU_disable_filedesc_col = FALSE;
              FIfld_set_mode(PDU_form_id, EXISTING_FILES_MCF,0, FI_INSERT);
              }

            if (!cofile_update)
              {
              PDU_disable_localfn_col = TRUE;
              FIfld_set_mode(PDU_form_id, EXISTING_FILES_MCF,1, FI_REVIEW);
              }
            else
              {
              PDU_disable_localfn_col = FALSE;
              FIfld_set_mode(PDU_form_id, EXISTING_FILES_MCF,1, FI_INSERT);
              }

            if (!cifile_update)
              {
              PDU_disable_storagefn_col = TRUE;
              FIfld_set_mode(PDU_form_id, EXISTING_FILES_MCF,2, FI_REVIEW);
              }
            else
              {
              PDU_disable_storagefn_col = FALSE;
              FIfld_set_mode(PDU_form_id, EXISTING_FILES_MCF,2, FI_INSERT);
              }

            if (!filetype_update)
              {
              PDU_disable_filetype_col = TRUE;
              FIfld_set_mode(PDU_form_id, EXISTING_FILES_MCF,3, FI_REVIEW);
              }
            else
              {
              PDU_disable_filetype_col = FALSE;
              FIfld_set_mode(PDU_form_id, EXISTING_FILES_MCF,3, FI_INSERT);
              }

            _pdm_debug("checking write permissions for NEW_FILES_MCF", 0);
            if (!cofile_write)
              {
              _pdm_debug("cofilename is not writable", 0);
              FIfld_set_mode(PDU_form_id, NEW_FILES_MCF, 0, FI_REVIEW);
              FIfld_set_mode(PDU_form_id, NEW_FILES_MCF, 1, FI_REVIEW);
              FIfld_set_mode(PDU_form_id, NEW_FILES_MCF, 2, FI_REVIEW);
              FIfld_set_mode(PDU_form_id, NEW_FILES_MCF, 3, FI_REVIEW);
              PDU_filedesc_newfiles_disable = TRUE;
              PDU_localfn_newfiles_disable = TRUE;
              PDU_storagefn_newfiles_disable = TRUE;
              PDU_filetype_newfiles_disable = TRUE;
              }
            if (!filedesc_write)
              {
              FIfld_set_mode(PDU_form_id, NEW_FILES_MCF, 0, FI_REVIEW);
              PDU_filedesc_newfiles_disable = TRUE;
              }
            if (!cifile_write)
              {
              FIfld_set_mode(PDU_form_id, NEW_FILES_MCF, 2, FI_REVIEW);
              PDU_storagefn_newfiles_disable = TRUE;
              }
            if (!filetype_write)
              {
              FIfld_set_mode(PDU_form_id, NEW_FILES_MCF, 3, FI_REVIEW);
              PDU_filetype_newfiles_disable = TRUE;
              }

         _pdm_debug("PDU_disable_localfn_col = %d", (char *)PDU_disable_localfn_col);
         _pdm_debug("PDU_disable_storagefn_col = %d", (char *)PDU_disable_storagefn_col);

         found_filedesc = FALSE;
         found_localfn = FALSE;
         found_storagefn = FALSE;
         found_filetype = FALSE;

         if (PDU_add_bufr != NULL)
            {
            status = PDUsetup_buffer_list(PDU_add_bufr, 2, 0,
                                          &add_bufr_data_row,
                                          &add_bufr_data_col,
                                          &add_bufr_data_format,
                                          &add_bufr);

            if ((status != PDM_S_SUCCESS) && (status != PDM_E_NULL_BUFFER))
               return(status);

            /* Search ADD BUFFER for columns */
            for (i = 0; i < add_bufr->columns; i++)
               {
               if (strcmp(add_bufr_data_col[i],"p_filedesc") == 0)
                  {
                  found_filedesc = TRUE;
                  PDU_filedesc_newfiles_disable = FALSE;
                  FIfld_set_mode(PDU_form_id, NEW_FILES_MCF,0, FI_INSERT);
                  }
               else if (strcmp(add_bufr_data_col[i],"n_cofilename") == 0)
                  {
                  found_localfn = TRUE;
                  PDU_localfn_newfiles_disable = FALSE;
                  FIfld_set_mode(PDU_form_id, NEW_FILES_MCF,1, FI_INSERT);
                  FIg_enable(PDU_form_id, NEW_FILES_MCF);
                  }
               else if (strcmp(add_bufr_data_col[i],"n_cifilename") == 0)
                  {
                  found_storagefn = TRUE;
                  PDU_storagefn_newfiles_disable = FALSE;
                  FIfld_set_mode(PDU_form_id, NEW_FILES_MCF,2, FI_INSERT);
                  }
               else if (strcmp(add_bufr_data_col[i],"n_filetype") == 0)
                  {
                  found_filetype = TRUE;
                  PDU_filetype_newfiles_disable = FALSE;
                  FIfld_set_mode(PDU_form_id, NEW_FILES_MCF,3, FI_INSERT);
                  }
               }
            if (found_filedesc == FALSE)
               {
               PDU_filedesc_newfiles_disable = TRUE;
               FIfld_set_mode(PDU_form_id, NEW_FILES_MCF,0, FI_REVIEW);
               }
            if (found_localfn == FALSE)
               {
               PDU_localfn_newfiles_disable = TRUE;
               FIfld_set_mode(PDU_form_id, NEW_FILES_MCF,1, FI_REVIEW);
               FIg_disable(PDU_form_id, NEW_FILES_MCF);
               }
            if (found_storagefn == FALSE)
               {
               PDU_storagefn_newfiles_disable = TRUE;
               FIfld_set_mode(PDU_form_id, NEW_FILES_MCF,2, FI_REVIEW);
               }
            if (found_filetype == FALSE)
               {
               PDU_filetype_newfiles_disable = TRUE;
               FIfld_set_mode(PDU_form_id, NEW_FILES_MCF,3, FI_REVIEW);
               }
            found_filedesc = FALSE;
            found_localfn = FALSE;
            found_storagefn = FALSE;
            found_filetype = FALSE;
            }
         }

         /* This loads multiple local filenames, storage filenames, file types,
            and file descriptions one row at a time instead of each columns 
            separately. */

         if ((change_mode == TRUE) || (review_mode == TRUE))
            {
            _pdm_debug("Change or review mode", 0);

            form_row = 0;
            count = 0;

            status = PDUsetup_buffer_list(PDU_file_bufr, 2, 0, &file_data_row,
                                          &file_data_col,&file_data_format,
                                          &file_data_bufr);
           
            if ((status != PDM_S_SUCCESS) && (status != PDM_E_NULL_BUFFER))
               return(status);

            if (review_mode == TRUE) 
               {
               FIfld_set_mode(PDU_form_id,FILE_INFO_MCF,0, FI_REVIEW);
               FIfld_set_mode(PDU_form_id,FILE_INFO_MCF,1, FI_REVIEW);
               FIfld_set_mode(PDU_form_id,FILE_INFO_MCF,2, FI_REVIEW);
               FIfld_set_mode(PDU_form_id,FILE_INFO_MCF,3, FI_REVIEW);
               }

            if (PDMdebug_on)
               MEMprint_buffer("FILE_DATA_BUFR",file_data_bufr,PDU_DEBUG_FILE);

            status = PDUget_col_number(data_bufr,"n_status",data2_col,
                                       &n_status_col);
            _pdm_status("PDUget_col_number", 0);

            if (status != PDM_S_SUCCESS)
              {
              PDUmessage(status, 's');
              return (status);
              }

            FIfld_get_num_vis_rows(PDU_form_id,FILE_INFO_MCF, &vis_rows);

/*
            FIfld_get_text_length(PDU_form_id,PDU_refresh_gadgets[4],0,0,
                                  &length);
            text = (char *) malloc (sizeof (char) * length + 1);
            memset(text, NULL, sizeof (char) * length + 1);
            FIfld_get_text(PDU_form_id,PDU_refresh_gadgets[4],0,0,length,
                  (unsigned char *)text, &select, &pos);
*/
            PDUfill_in_string1(&ep_parttype,refresh->rev_parttype);
            _pdm_debug("ep_parttype = %s", ep_parttype);

            PDUfill_in_string1(&part_status, 
                data2_row[(data_bufr->columns * 0) + n_status_col]);
            _pdm_debug("part_status = <%s>", part_status);
            if (part_status == NULL)
              {
              _pdm_debug("part status is NULL", 0);
              part_status = NULL_STRING;
              }

            if (change_mode)
               FIg_enable(PDU_form_id,DELETE_BTN);
            if ((change_mode == TRUE) &&
                ((strcmp(data2_row[(data_bufr->columns * 0) + n_status_col],
                  "O") == 0) ||
                (strcmp(data2_row[(data_bufr->columns * 0) + n_status_col],"S")
                 == 0)))
               {
               /* Part is checked out, therefore, user cannot move the part to
                  the next state */ 
               PDU_disable_move_state_btn = TRUE;
               FIg_disable(PDU_form_id,MOVE_STATE_BTN);

               _pdm_debug("file is checked out", 0);
               msg = (char *) PDUtranslate_message(PDM_E_CANNOT_DELETE_FILES);
               FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
               FIg_disable(PDU_form_id,DELETE_FILES_TGL);
               FIg_disable(PDU_form_id,DELETE_BTN);
               }
            else if (change_mode)
               {
               if ((strcmp(ep_parttype, "N") != 0) && 
                   (strcmp(ep_parttype, "n") != 0))
                 FIg_enable(PDU_form_id,DELETE_FILES_TGL);
               PDU_disable_move_state_btn = FALSE;
               FIg_enable(PDU_form_id,MOVE_STATE_BTN);
               }

            /* Moved, added, and/or modified for PDU21 */
            if ((strcmp(data2_row[(data_bufr->columns * 0) + n_status_col],"")
                 == 0) &&
                ((strcmp(ep_parttype,"N") != 0) &&
                (strcmp(ep_parttype,"n") != 0)) &&
                (change_mode == TRUE))
              {
               FIg_enable(PDU_form_id, DELETE_FILES_TGL);
              }

            if ((strcmp(data2_row[(data_bufr->columns * 0) + n_status_col],"I")
                 == 0) &&
                ((strcmp(ep_parttype,"N") != 0) &&
                (strcmp(ep_parttype,"n") != 0)) &&
                (change_mode == TRUE))
               {
               PDU_part_checked_in = TRUE;
               msg = (char *) PDUtranslate_message(PDM_E_CANNOT_ADD_FILES);
               FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
               FIg_erase(PDU_form_id,STORAGE_AREA_BTN);
               FIg_disable(PDU_form_id,NEW_FILES_MCF);
               _pdm_debug("THE STATUS OF THIS PART IS 'I', THERFORE, NO ADD_BUFR", 0);
               FIg_enable(PDU_form_id, DELETE_FILES_TGL);
               }         
            else if ((strcmp(data2_row[(data_bufr->columns * 0) + n_status_col],
                      "I") != 0) &&
                     ((strcmp(ep_parttype,"N") != 0) &&
                     (strcmp(ep_parttype,"n") != 0)) &&
                     (change_mode == TRUE) &&
                     (PDU_localfn_newfiles_disable == FALSE))
               {
               FIg_enable(PDU_form_id,CHANGE_MODE_GRP);

               if ((strcmp(data2_row[(data_bufr->columns * 0) + n_status_col],
                   "") == 0) && PDU_file_bufr)
                 {
                 PDU_never_checked_in = TRUE;
                 _pdm_debug("part has never been checked in", 0);
                 }

               /* There will be an add_data_bufr */
               status = PDUsetup_buffer_list(PDU_add_bufr, 2, 0, &add_data_row,
                                             &add_data_col,&add_data_format,
                                             &add_data_bufr);
               if ((status != PDM_S_SUCCESS) && (status != PDM_E_NULL_BUFFER))
                  return(status);

               if (PDMdebug_on)
                  MEMprint_buffer("ADD_DATA_BUFR",add_data_bufr,PDU_DEBUG_FILE);

/* 1/14/94  this was being done twice - mjg
               _pdm_debug("checking part status for status != I", 0);
               if ((part_status) && (strcmp(part_status, "") == 0))
                 FIg_enable(PDU_form_id, DELETE_FILES_TGL);
               else
                 FIg_disable(PDU_form_id, DELETE_FILES_TGL);
               _pdm_debug("after checking part status", 0);
*/
               }
            else if ((strcmp(data2_row[(data_bufr->columns * 0) + n_status_col],
                      "I") != 0) &&
                     ((strcmp(ep_parttype,"N") != 0) &&
                     (strcmp(ep_parttype,"n") != 0)) &&
                     (change_mode == TRUE) &&
                     (PDU_localfn_newfiles_disable == TRUE))
               {
               msg = (char *) PDUtranslate_message(PDM_E_NO_WRITE_LOCAL_FILE);
               FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
               FIg_enable(PDU_form_id,CHANGE_MODE_GRP);
               FIg_disable(PDU_form_id,NEW_FILES_MCF);

               _pdm_debug("checking part status", 0);
               if ((part_status) && (strcmp(part_status, "") == 0))
                 FIg_enable(PDU_form_id, DELETE_FILES_TGL);
               else
                 FIg_disable(PDU_form_id, DELETE_FILES_TGL);
               _pdm_debug("after checking part status", 0);
               }
            else if ((strcmp(ep_parttype,"N") == 0) ||
                     (strcmp(ep_parttype,"n") == 0))
               {
               if (change_mode == TRUE)
                  {
                  /*FIg_erase(PDU_form_id,FILE_INFO_BEZ);*/
                  FIg_erase(PDU_form_id,CHANGE_MODE_GRP);
                  }
               else if (review_mode == TRUE)
                  {
                  /*FIg_erase(PDU_form_id,FILE_INFO_BEZ);*/
                  FIg_erase(PDU_form_id,FILE_INFO_GRP);
                  FIg_erase(PDU_form_id,EXISTING_FILE_TXT);
                  }

               if (((strcmp(ep_parttype,"N") == 0) ||
                   (strcmp(ep_parttype,"n") == 0)) && (change_mode))
                  {
                  FIg_erase(PDU_form_id, DELETE_FILES_TGL);
                  }
               }

            if (PDMdebug_on)
               MEMprint_buffer("THE FILE_DATA_BUFR",file_data_bufr,
                               PDU_DEBUG_FILE);

            if ((change_mode == TRUE) && (file_data_bufr == NULL))
               {
               FIg_disable(PDU_form_id,EXISTING_FILES_MCF);
               FIg_disable(PDU_form_id,DELETE_FILES_TGL);
               }
            else if (change_mode == TRUE)
               {
               FIg_enable(PDU_form_id,EXISTING_FILES_MCF);
               }

         _pdm_debug("PDU_disable_localfn_col = %d", (char *)PDU_disable_localfn_col);
         _pdm_debug("PDU_disable_storagefn_col = %d", (char *)PDU_disable_storagefn_col);
            if ((file_data_bufr != NULL) && (file_data_bufr->rows > 0))
               {
               _pdm_debug("entering KLUDGE for file information", 0);
               n_cofilenm_col = -1;
               n_cifilenm_col = -1;
               n_filetype_col = -1;
               p_filedesc_col = -1;

               _pdm_debug("getting file columns", 0);

               status = PDUget_col_number(file_data_bufr,"n_cofilename",
                                          file_data_col, &n_cofilenm_col);
               _pdm_status("PDUget_col_number", status);

               status = PDUget_col_number(file_data_bufr,"n_cifilename",
                                          file_data_col, &n_cifilenm_col);
               _pdm_status("PDUget_col_number", status);

               status = PDUget_col_number(file_data_bufr,"n_filetype",
                                          file_data_col, &n_filetype_col);
               _pdm_status("PDUget_col_number", status);

               status = PDUget_col_number(file_data_bufr,"p_filedesc",
                                          file_data_col, &p_filedesc_col);
               _pdm_status("PDUget_col_number", status);

               if (change_mode == TRUE)
                  status = FIfld_set_max_num_rows(PDU_form_id,
                                                  EXISTING_FILES_MCF,
                                                  file_data_bufr->rows);
 
               for (i = 0; i < file_data_bufr->rows; i++)
                  {
                  for (j = 0; j < attr_bufr->rows; j++)
                     {
                     if ((strcmp(data1_row[(attr_bufr->columns * j) +
                          n_name_col], "n_cofilename") == 0) ||
                         (strcmp(data1_row[(attr_bufr->columns * j) +
                          n_name_col], "n_cifilename") == 0) ||
                         (strcmp(data1_row[(attr_bufr->columns * j) + 
                          n_name_col], "n_filetype") == 0) ||
                         (strcmp(data1_row[(attr_bufr->columns * j) +
                          n_name_col], "p_filedesc") == 0))
                        {
                        if ((strcmp(data1_row[(attr_bufr->columns * j) + 
                            n_name_col], "n_cofilename") == 0) &&
                            (n_cofilenm_col != -1))
                           {
/* 8/20/93 - Mychelle - write the information to the form whether disable is
   TRUE or FALSE, per Kumar.  Because the item may have read permission but
   no update permission.  In both cases, the item is not in the attr bufr */

                           _pdm_debug("processing n_cofilename", 0);
                           if (strcmp(data1_row[(attr_bufr->columns * j) + 
                               n_name_col], 
                               file_data_col[n_cofilenm_col]) == 0)
                              {
                              _pdm_debug("writing local filename to mcf", 0);
                              if ((change_mode == TRUE) && (cofile_read))
                                FIfld_set_text(PDU_form_id,
                                             EXISTING_FILES_MCF,form_row,1,
                                             file_data_row[(file_data_bufr->                                                 columns * i) + n_cofilenm_col],
                                             FALSE);
                              if (review_mode == TRUE)
                                FIfld_set_text(PDU_form_id,
                                             FILE_INFO_MCF,form_row,1,
                                             file_data_row[(file_data_bufr->                                                 columns * i) + n_cofilenm_col],
                                             FALSE);
                              continue;
                              }
                           } 
                        else if ((strcmp(data1_row[(attr_bufr->columns * j) +
                                 n_name_col], "n_cifilename") == 0) &&
                                 (n_cifilenm_col != -1))
                           {
_pdm_debug("cifilename = <%s>", file_data_row[(file_data_bufr->columns * i) + n_cifilenm_col]);
                           if (strcmp(data1_row[(attr_bufr->columns * j) +
                               n_name_col], 
                               file_data_col[n_cifilenm_col]) == 0)
                              {
                              _pdm_debug("writing storage filename to mcf", 0);
                              if ((change_mode == TRUE) && (cifile_read))
                                FIfld_set_text(PDU_form_id, EXISTING_FILES_MCF,
                                          form_row,2, 
                                          file_data_row[(file_data_bufr-> 
                                          columns * i) + n_cifilenm_col],FALSE);
                              if (review_mode == TRUE)
                                FIfld_set_text(PDU_form_id,
                                             FILE_INFO_MCF,form_row,2,
                                             file_data_row[(file_data_bufr->
                                             columns * i) + n_cifilenm_col],                                                 FALSE);
                              continue;
                              }
                           }
                        else if ((strcmp(data1_row[(attr_bufr->columns * j) +
                                 n_name_col], "n_filetype") == 0) &&
                                 (n_filetype_col != -1))
                           {
                           _pdm_debug("processing n_filetype", 0);
                           if (strcmp(data1_row[(attr_bufr->columns * j) +
                               n_name_col], 
                               file_data_col[n_filetype_col]) == 0)
                              {
                              _pdm_debug("writing filetype to mcf", 0);
                              if ((change_mode == TRUE) && (filetype_read))
                                FIfld_set_text(PDU_form_id,
                                             EXISTING_FILES_MCF,form_row,3,
                                             file_data_row[(file_data_bufr->                                                 columns * i) + n_filetype_col],                                                 FALSE);
                              if (review_mode == TRUE)
                                FIfld_set_text(PDU_form_id,
                                             FILE_INFO_MCF,form_row,3,
                                             file_data_row[(file_data_bufr->                                                 columns * i) + n_filetype_col],                                                 FALSE);
                              continue;
                              }
                           }
                        else if ((strcmp(data1_row[(attr_bufr->columns * j) +
                                 n_name_col], "p_filedesc") == 0) &&
                                 (p_filedesc_col != -1))
                           {
                           _pdm_debug("processing n_filedesc", 0);
                           if (strcmp(data1_row[(attr_bufr->columns * j) +
                               n_name_col],
                               file_data_col[p_filedesc_col]) == 0)
                              {
                              _pdm_debug("writing filedesc to mcf", 0);
                              if (change_mode && filedesc_read)
                                FIfld_set_text(PDU_form_id,
                                             EXISTING_FILES_MCF,form_row,0,
                                             file_data_row[(file_data_bufr->
                                             columns * i) + p_filedesc_col],
                                             FALSE);
                              if (review_mode == TRUE)
                                FIfld_set_text(PDU_form_id,
                                             FILE_INFO_MCF,form_row,0,
                                             file_data_row[(file_data_bufr->
                                             columns * i) + p_filedesc_col],
                                             FALSE);
                              continue;
                              }
                           }
                        _pdm_debug("after loading file information", 0);
                        } 
                     }
                  ++form_row; 
                  }
               }
            }

         /* Fill in acl name and workflow name */
         _pdm_debug("setting acl name", 0);
         if ((new_mode == TRUE) || (similar_mode))
            {
            status = PDUget_col_number(attr_bufr,"n_valueno",data1_col,
                                       &n_valueno_col);
            _pdm_status("PDUget_col_number",status);

            if (status != PDM_S_SUCCESS)
                {
                PDUmessage(status, 's');
                return (status);
                }
          
            _pdm_debug("getting acl_buffer_no", 0);
            for (i = 0; i < attr_bufr->rows; ++i)
               {
               if (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                   "n_aclno") == 0)
                  {
                  acl_buffer_no = atoi(data1_row[(attr_bufr->columns * i) +
                                       n_valueno_col]);
                  break;
                  }
               }

            status = PDUsetup_buffer_list(PDU_ret_bufr, 3, acl_buffer_no,
                                          &data3_row, &data3_col,&data3_format,
                                          &acl_bufr);
            _pdm_status("PDUsetup_buffer_list",status);

            if (PDMdebug_on)
            MEMprint_buffer("acl_bufr", acl_bufr, PDU_DEBUG_FILE);

            if (status != PDM_S_SUCCESS)
               return(status);

            if (status == PDM_S_SUCCESS)
               {
               if (acl_bufr->rows < 2)
                  FIg_erase(PDU_form_id,ACL_NAME_BTN);
               else
                  FIg_display(PDU_form_id,ACL_NAME_BTN);

               status = PDUget_col_number(acl_bufr,"n_aclno",data3_col,
                                          &n_aclno_col);
               if (status != PDM_S_SUCCESS)
                 {
                 PDUmessage(status, 's');
                 return (status);
                 }
               status = PDUget_col_number(acl_bufr,"n_aclname",data3_col,
                                          &n_aclname_col);
               if (status != PDM_S_SUCCESS)
                 {
                 PDUmessage(status, 's');
                 return (status);
                 }
               status = PDUget_col_number(acl_bufr,"n_workflowname",data3_col,
                                          &n_wf_col);
               if (status != PDM_S_SUCCESS)
                 {
                 PDUmessage(status, 's');
                 return (status);
                 }
               status = PDUget_col_number(data_bufr,"n_aclno",data2_col,
                                          &n_aclno_col_for_data);
               if (status != PDM_S_SUCCESS)
                 {
                 PDUmessage(status, 's');
                 return (status);
                 }

               if (PDMdebug_on)
                  {
                  MEMprint_buffer("acl_buffer", acl_bufr, PDU_DEBUG_FILE);
                  MEMprint_buffer("data_buffer", data_bufr, PDU_DEBUG_FILE);
                  }

               attr_row = PDUfind_attr_in_buffer(attr_bufr, PDU_NFM_ACL_NO);
               _pdm_debug("attr_row = %d", (char *)attr_row);
               /* find defaulted aclno's row in acl_bufr */

               _pdm_debug("checking buffer for acl number", 0);
               if ((strcmp(data2_row[attr_row], "") == 0) ||
                    (((data2_row[attr_row])[0]) == '\0'))
                 {
                 _pdm_debug("acl number has not been defaulted in buffer", 0);
                 _pdm_debug("defaulting acl number to 6", 0);
                 
                 _pdm_debug("looking for aclno=6 in buffer", 0);
                 acl_row = -1;
                 for (i = 0; i < acl_bufr->rows; ++i)
                    {
                    if (strcmp(data3_row[(acl_bufr->columns * i) + n_aclno_col],
                        "6") == 0)
                      {
                      acl_row = i;
                      _pdm_debug("default row found", 0);
                      break;
                      }
                    }
                 if (acl_row == -1)
                   {
                   _pdm_debug("SEVERE ERROR:  default acl not found", 0);
                   acl_row = 0;
                   }
                 }
               else
                 {
                 for (i = 0; i < acl_bufr->rows; i ++)
                    {
                    _pdm_debug("row = %d", (char *)i);
                    _pdm_debug("data string = <%s>", data3_row[(acl_bufr->columns * i) + n_aclno_col]);
                    _pdm_debug("string to match = <%s>", data2_row[attr_row]);
                    if (strcmp(data3_row[(acl_bufr->columns * i) + n_aclno_col], 
                        data2_row[attr_row]) == 0)
                       {
                       acl_row = i;
                       _pdm_debug("setting acl row to %d", (char *)acl_row);
                       break;
                       }
                    }
                 }

               /* Write acl name and workflow name to the part form */

               _pdm_debug("setting acl name on form", 0);
               FIfld_set_text(forms.part_operations_form_id,ACL_NAME_FLD,0,0,
                       data3_row[(acl_bufr->columns * acl_row) + n_aclname_col],
                       FALSE);
               FIfld_set_text(forms.part_operations_form_id,WORKFLOW_FLD,0,0,
                            data3_row[(acl_bufr->columns * acl_row) + n_wf_col],
                            FALSE);

               /*Put the default acl number for the new part in the data 
                 buffer*/

               _pdm_debug("writing acl name to buffer", 0);
               status = MEMwrite_data(data_bufr,
                         data3_row[(acl_bufr->columns * acl_row) + n_aclno_col],
                         1,n_aclno_col_for_data + 1);
               }

            /* Fill in the storage area name */

            _pdm_debug("setting storage area name", 0);
            for (i = 0; i < attr_bufr->rows; ++i)
               {
               if (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                   "n_cisano") == 0)
                  {
                  stg_buffer_no = atoi(data1_row[(attr_bufr->columns * i) +
                                       n_valueno_col]);
                  break;
                  }
               }

            status = PDUsetup_buffer_list(PDU_ret_bufr, 3, stg_buffer_no,
                                          &data4_row, &data4_col,&data4_format,
                                          &stg_bufr);
            _pdm_status("PDUsetup_buffer_list",status);

            if (status != PDM_S_SUCCESS)
               return(status);

            if (status == PDM_S_SUCCESS)
               {
               if (stg_bufr->rows < 2)
                  FIg_erase(PDU_form_id,STORAGE_AREA_BTN);
               else
                  FIg_display(PDU_form_id,STORAGE_AREA_BTN);

               status = PDUget_col_number(stg_bufr,"n_sano",data4_col,
                                          &n_sano_col);
               if (status != PDM_S_SUCCESS)
                 {
                 PDUmessage(status, 's');
                 return (status);
                 }
               status = PDUget_col_number(stg_bufr,"n_saname",data4_col,
                                          &n_saname_col);
               if (status != PDM_S_SUCCESS)
                 {
                 PDUmessage(status, 's');
                 return (status);
                 }
               status = PDUget_col_number(data_bufr,"n_cisano",data2_col,
                                          &n_cisano_col_for_data);
               if (status != PDM_S_SUCCESS)
                 {
                 PDUmessage(status, 's');
                 return (status);
                 }

               /* Find defaulted storage area in the stg_bufr */

               for (i = 0; i < stg_bufr->rows; i ++)
                  {
                  if (strcmp(data4_row[(stg_bufr->columns * i) + n_sano_col],
                      data2_row[n_cisano_col_for_data]) == 0)
                     {
                     cisano_row = i;
                     break;
                     }
                  }

               /* Write storage area name to part form */
               FIfld_set_text(forms.part_operations_form_id,STORAGE_AREA_FLD,0,
                              0,data4_row[(stg_bufr->columns * cisano_row) + 
                              n_saname_col], FALSE);

               /* Put default storage area number into the data buffer */

               status = MEMwrite_data(data_bufr,
                       data4_row[(stg_bufr->columns * cisano_row) + n_sano_col],
                       1,n_cisano_col_for_data + 1);
               }
            }
         else if ((change_mode == TRUE) || (review_mode == TRUE))
            {    
            status = PDUget_col_number(attr_bufr,"n_valueno",data1_col,
                                       &n_valueno_col);
            _pdm_status("PDUget_col_number",status);

            if (status != PDM_S_SUCCESS)
                 {
                 PDUmessage(status, 's');
                 return (status);
                 }

            for (i = 0; i < attr_bufr->rows; ++i)
               {
               if (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                   "n_aclno") == 0)
                  {
                  acl_buffer_no = atoi(data1_row[(attr_bufr->columns * i) +
                                       n_valueno_col]);
                  break;
                  }
               }

            _pdm_debug("setting up acl bufr", 0);
            status = PDUsetup_buffer_list(PDU_ret_bufr, 3, acl_buffer_no,
                                          &data3_row, &data3_col,&data3_format,
                                          &acl_bufr);
            _pdm_status("PDUsetup_buffer_list",status);

            if (status != PDM_S_SUCCESS)
               return(status);

            if (PDMdebug_on)
              MEMprint_buffer("acl_bufr", acl_bufr, PDU_DEBUG_FILE);

            FIg_erase(PDU_form_id,ACL_NAME_BTN);

            if (change_mode && acl_bufr && (acl_bufr->rows > 1))
              {
              _pdm_debug("checking aclno for update permission", 0);
              attr_row = PDUfind_attr_in_buffer(attr_bufr, "n_aclno");
              if (attr_row != -1)
                {
                status = PDUget_buffer_col(attr_bufr, "n_update", &update_col);
                if (status != PDM_S_SUCCESS)
                  {
                  PDUmessage(status, 's');
                  return(status);
                  }
                _pdm_debug("attr_row = %d", (char *) attr_row);
                _pdm_debug("update_col = %d", (char *) update_col);
                PDUfill_in_string(&update,
                       data1_row[(attr_bufr->columns * attr_row)+update_col]);
                _pdm_debug("update = <%s>", update);
                if (update && (strcmp(update, "Y") == 0))
                  FIg_display(PDU_form_id,ACL_NAME_BTN);
                }
              }
            else
              _pdm_debug("acl_bufr is NULL", 0);

            if (status == PDM_S_SUCCESS)
               {
               if (PDMdebug_on)
                  MEMprint_buffer("ACL_BUFR",acl_bufr,PDU_DEBUG_FILE);

               status = PDUget_col_number(data_bufr,"n_aclno",data2_col,
                                          &n_aclno_col_for_data);
               if (status != PDM_S_SUCCESS)
                 {
                 PDUmessage(status, 's');
                 return (status);
                 }
               status = PDUget_col_number(acl_bufr,"n_aclno",data3_col,
                                          &n_aclno_col);
               if (status != PDM_S_SUCCESS)
                 {
                 PDUmessage(status, 's');
                 return (status);
                 }
               status = PDUget_col_number(acl_bufr,"n_workflowname",data3_col,
                                          &n_wf_col);
               if (status != PDM_S_SUCCESS)
                 {
                 PDUmessage(status, 's');
                 return (status);
                 }
               status = PDUget_col_number(acl_bufr,"n_aclname",data3_col,
                                          &n_aclname_col);
               if (status != PDM_S_SUCCESS)
                 {
                 PDUmessage(status, 's');
                 return (status);
                 }

               found = FALSE;
               for (i = 0; i < acl_bufr->rows; ++i)
                  {
                  if (strcmp(data2_row[(data_bufr->columns * 0) +                                            n_aclno_col_for_data],
                             data3_row[(acl_bufr->columns * i) + n_aclno_col])                               == 0)
                     {
                     found = TRUE;
                     acl_row = i;
                     break;
                     }
                  }

               if (!found)
                 {
                 status = PDM_E_NOT_ACL_USER;
                 PDUmessage(status, 's');
                 return(status);
                 }

               /* Write acl name and workflow name to the part form */

               _pdm_debug("writing aclname to form", 0);
               FIfld_set_text(forms.part_operations_form_id,ACL_NAME_FLD                                      ,0,0, data3_row[(acl_bufr->columns * acl_row) + 
                              n_aclname_col], FALSE);
               FIfld_set_text(forms.part_operations_form_id,WORKFLOW_FLD,                                     0,0, data3_row[(acl_bufr->columns * acl_row) +
                              n_wf_col], FALSE);
               }

            /* Fill in the storage area name */

            _pdm_debug("setting storage name", 0);
            for (i = 0; i < attr_bufr->rows; ++i)
               {
               if (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                   "n_cisano") == 0)
                  {
                  stg_buffer_no = atoi(data1_row[(attr_bufr->columns * i) +
                                        n_valueno_col]);
                  break;
                  }
               }

            status = PDUsetup_buffer_list(PDU_ret_bufr, 3, stg_buffer_no,
                                          &data4_row, &data4_col,&data4_format,
                                          &stg_bufr);
            _pdm_status("PDUsetup_buffer_list for stg_bufr",status);

            if (status != PDM_S_SUCCESS)
               return(status);

            if (status == PDM_S_SUCCESS)
               {
               if ((stg_bufr->rows < 2) || (review_mode == TRUE))
                  FIg_erase(PDU_form_id,STORAGE_AREA_BTN);
               else
                  FIg_display(PDU_form_id,STORAGE_AREA_BTN);

               status = PDUget_col_number(data_bufr,"n_cisano",data2_col,
                                          &n_cisano_col_for_data);
               status1 = PDUget_col_number(stg_bufr,"n_sano",data4_col,
                                          &n_sano_col);
               if ((status == PDM_S_SUCCESS) && (status1 == PDM_S_SUCCESS))
                 {
                 for (i = 0; i < stg_bufr->rows; ++i)
                    {
                    if (strcmp(data2_row[(data_bufr->columns * 0) +
                               n_cisano_col_for_data],
                               data4_row[(stg_bufr->columns * i) + n_sano_col])
                               == 0)
                       {
                       cisano_row = i;
                       break;
                       }
                    }
                 }

               /* Write storage area name to part form */
               status = PDUget_col_number(stg_bufr,"n_saname",data4_col,
                                          &n_saname_col);
               if (status == PDM_S_SUCCESS)
                 {
                 FIfld_set_text(forms.part_operations_form_id,STORAGE_AREA_FLD
                              ,0,0, data4_row[(stg_bufr->columns * cisano_row) +
                              n_saname_col], FALSE);
                 }
               }
            }

         /* Fill in State name */

         _pdm_debug("Get state name",0);

         status = PDUget_col_number(data_bufr,"n_cocomment",data2_col,
                                    &n_state_col);
         _pdm_status("PDUget_col_number",status);

         if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            return (status);
            }

         for (i = 0; i < attr_bufr->rows; ++i)
            {
_pdm_debug("attr_bufr state = <%s>", data1_row[(attr_bufr->columns * i) + n_name_col]);
_pdm_debug("data bufr state = <%s>", data2_col[n_state_col]);
            if (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                data2_col[n_state_col]) == 0)
               {
               _pdm_debug("setting text", 0);
               _pdm_debug("i = %d", (char *)i);
               FIfld_set_text(forms.part_operations_form_id, STATE_NAME_FLD,0,
                              0, data2_row[(data_bufr->columns * 0) +
                              n_state_col],FALSE);
               break;
               }
            }
         }
/* MEMsplit_copy the attr_bufr, data_bufr, stg_bufr, and acl_bufr to global
   buffers to allow the users to enter information for the new or changed part 
   before adding the the new part info or changed part info to the database. */

   _pdm_debug("closing buffers", 0);
   if (PDU_attr_bufr)
      {
      MEMclose(&PDU_attr_bufr);
      PDU_attr_bufr = NULL;
      }
   if (PDU_data_bufr)
      {
      MEMclose(&PDU_data_bufr);
      PDU_data_bufr = NULL;
      }
   if (PDU_acl_bufr)
      {
      MEMclose(&PDU_acl_bufr);
      PDU_acl_bufr = NULL;
      }
   if (PDU_stg_bufr)
      {
      MEMclose(&PDU_stg_bufr);
      PDU_stg_bufr = NULL;
      }
   if (PDU_file_data_bufr)
      {
      MEMclose(&PDU_file_data_bufr);
      PDU_file_data_bufr = NULL;
      }
   if (PDU_add_data_bufr)
      {
      MEMclose(&PDU_add_data_bufr);
      PDU_add_data_bufr = NULL;
      }

   status = MEMsplit_copy_buffer(attr_bufr, &PDU_attr_bufr,0);
   status = MEMsplit_copy_buffer(data_bufr, &PDU_data_bufr,0);

   if (PDMdebug_on)
     MEMprint_buffer("PDU_data_bufr leaving pull_from_bufr", PDU_data_bufr,
                     PDU_DEBUG_FILE);

   if ((new_mode == TRUE) || (change_mode == TRUE) || (review_mode == TRUE) ||
       ((similar_mode == TRUE) &&
        (np_catalog != NULL) && (strcmp(np_catalog,"") != 0)))  
      {
      status = MEMsplit_copy_buffer(acl_bufr, &PDU_acl_bufr,0);
      status = MEMsplit_copy_buffer(stg_bufr, &PDU_stg_bufr,0);
      }

   if (((change_mode == TRUE) || (review_mode == TRUE)) &&
       ((strcmp(ep_parttype,"N") != 0) &&
        (strcmp(ep_parttype,"n") != 0)))
      {
      if ((file_data_bufr != NULL) && (file_data_bufr->rows > 0))
         { 
         status = MEMsplit_copy_buffer(file_data_bufr, &PDU_file_data_bufr,0);
         if (PDMdebug_on)
         MEMprint_buffer("PDU_file_data_bufr",PDU_file_data_bufr,
                         PDU_DEBUG_FILE);
         status = MEMsplit_copy_buffer(file_data_bufr, &PDU_sav_file_data_bufr,
                                       0);
         if (PDMdebug_on)
         MEMprint_buffer("PDU_sav_file_data_bufr",PDU_sav_file_data_bufr,
                         PDU_DEBUG_FILE);
         }

      if ((strcmp(data2_row[(data_bufr->columns * 0) + n_status_col],"I")
               != 0) &&
         ((add_data_bufr != NULL) && (add_data_bufr->rows > 0)))
         status = MEMsplit_copy_buffer(add_data_bufr, &PDU_add_data_bufr,0);

      if (status != MEM_S_SUCCESS)
         return(status);
      }

   if (((status == MEM_S_SUCCESS) || (status == PDM_S_SUCCESS)) && 
      (change_mode == TRUE))
      {
      fn = (int *)PDMterminate;
      exitdel(fn);
      fn = (int *)PDMcancel_modify;
      exitadd(fn);
      fn = (int *)PDMterminate;
      exitadd(fn);
      } 

   if (((status == MEM_S_SUCCESS) || (status == PDM_S_SUCCESS)) &&
      (review_mode == TRUE))
      {
      fn = (int *)PDMterminate;
      exitdel(fn);
      fn = (int *)PDMcancel_modify;
      exitadd(fn);
      fn = (int *)PDMterminate;
      exitadd(fn);
      }

   if (status == MEM_S_SUCCESS)
      status = PDM_S_SUCCESS;

   if (PDU_func_buffer != NULL)
      {
      PDU_func_bufr_exists = TRUE;
      _pdm_debug("Put command on queue to call get_atr_val ppl",PDU_DEBUG_FILE);

      PDUmessage(PDC_M_GET_ATTR_VALUES,'c');

      responses[0] = EX_CMD_KEY;
      strings[0] = "PDGtAtrVal";

      status = PDUprepare_queue (responses, strings, 1);
      _pdm_status("PDUprepare_queue",status);
      }
   else
      PDU_func_bufr_exists = FALSE;

return (status);
}


/* The following seven buffers are for use when listing a part type in the 
   PDU 2.0 interface. */


int  PDUlist_dmgn_bufr(buffer)

MEMptr * buffer;

{
int      status;

  status = MEMopen(buffer, 512);

  status = MEMwrite_format(*buffer, "parttype", "char(5)");

  status = MEMwrite(*buffer,"D\n");
  status = MEMwrite(*buffer,"M\n");
  status = MEMwrite(*buffer,"G\n");
  status = MEMwrite(*buffer,"N\n");

  if (PDMdebug_on)
     status = MEMprint_buffer("PDUlist_agn_bufr buffer content", *buffer, 
                              PDU_DEBUG_FILE);

  if (status == MEM_S_SUCCESS)
     status = PDM_S_SUCCESS;

return(status);
}

int  PDUlist_pgn_bufr(buffer)

MEMptr * buffer;

{
int      status;

  status = MEMopen(buffer, 512);

  status = MEMwrite_format(*buffer, "parttype", "char(40)");

  status = MEMwrite(*buffer,"D\n");
  status = MEMwrite(*buffer,"G\n");
  status = MEMwrite(*buffer,"N\n");

  if (status == MEM_S_SUCCESS)
     status = PDM_S_SUCCESS;

return(status);
}

int  PDUlist_pan_bufr(buffer)

MEMptr * buffer;

{
int      status;

  status = MEMopen(buffer, 512);

  status = MEMwrite_format(*buffer, "parttype", "char(40)");

  status = MEMwrite(*buffer,"P\n");
  status = MEMwrite(*buffer,"A\n");
  status = MEMwrite(*buffer,"N\n");

  if (status == MEM_S_SUCCESS)
     status = PDM_S_SUCCESS;

return(status);
}

int  PDUlist_pag_bufr(buffer)

MEMptr * buffer;

{
int      status;

  status = MEMopen(buffer, 512);

  status = MEMwrite_format(*buffer, "parttype", "char(40)");

  status = MEMwrite(*buffer,"P\n");
  status = MEMwrite(*buffer,"A\n");
  status = MEMwrite(*buffer,"G\n");

  if (status == MEM_S_SUCCESS)
     status = PDM_S_SUCCESS;

return(status);
}

int  PDUlist_gn_bufr(buffer)

MEMptr * buffer;

{
int      status;

  status = MEMopen(buffer, 512);

  status = MEMwrite_format(*buffer, "parttype", "char(40)");

  status = MEMwrite(*buffer,"G\n");
  status = MEMwrite(*buffer,"N\n");

  if (status == MEM_S_SUCCESS)
     status = PDM_S_SUCCESS;

return(status);
}

int  PDUlist_an_bufr(buffer)

MEMptr * buffer;

{
int      status;

  status = MEMopen(buffer, 512);

  status = MEMwrite_format(*buffer, "parttype", "char(40)");

  status = MEMwrite(*buffer,"A\n");
  status = MEMwrite(*buffer,"N\n");

  if (PDMdebug_on)
     status = MEMprint_buffer( "PDUlist_an_bufr buffer content", *buffer, 
                              PDU_DEBUG_FILE);

  if (status == MEM_S_SUCCESS)
     status = PDM_S_SUCCESS;

return (status);
}

int  PDUlist_ag_bufr(buffer)

MEMptr * buffer;

{
int      status;

  status = MEMopen(buffer, 512);

  status = MEMwrite_format(*buffer, "parttype", "char(40)");

  status = MEMwrite(*buffer,"A\n");
  status = MEMwrite(*buffer,"G\n");

  if (status == MEM_S_SUCCESS)
     status = PDM_S_SUCCESS;

return(status);
}

PDUremove_data(fp,field_label,max_rows,num_cols)

Form    fp;
int     field_label;
int     max_rows;
int     num_cols;

{

int    i,j;

if (max_rows > 0)
   {
   for (i = 0; i < max_rows; ++i)
      {
      for (j = 0; j < num_cols; ++j)
         {
         FIfld_set_text(fp,field_label,i,j,"",FALSE);
         }
      }
   }
}

int PDUremove_col_data(fp,field_label,max_rows,col)

Form    fp;
int     field_label;
int     max_rows;
int     col;

{

int    i;
int    status = PDM_S_SUCCESS;

if (max_rows > 0)
   {
   for (i = 0; i < max_rows; ++i)
      {
      status = FIfld_set_text(fp,field_label,i,col,"",FALSE);

      if (status != FI_SUCCESS)
         break;
      }
   }
return(status);
}

int  PDUpull_when_diff()
{
static char   * text;

MEMptr        hold_attr_bufr = NULL;
MEMptr        hold_data_bufr = NULL;
MEMptr        hold_acl_bufr = NULL;
MEMptr        hold_stg_bufr = NULL;
MEMptr        ep_attr_bufr = NULL;
MEMptr        ep_data_bufr = NULL;
MEMptr        attr_bufr = NULL;
MEMptr        data_bufr = NULL;
char        * string = NULL;
char       ** hd_attr_bufr_row = NULL;
char       ** hd_attr_bufr_col = NULL;
char       ** hd_attr_bufr_format = NULL;
char       ** hd_data_bufr_row = NULL;
char       ** hd_data_bufr_col = NULL;
char       ** hd_data_bufr_format = NULL;
char       ** hd_acl_bufr_row;
char       ** hd_acl_bufr_col;
char       ** hd_acl_bufr_format;
char       ** hd_stg_bufr_row;
char       ** hd_stg_bufr_col;
char       ** hd_stg_bufr_format;
char       ** ep_attr_bufr_row = NULL;
char       ** ep_attr_bufr_col = NULL;
char       ** ep_attr_bufr_format = NULL;
char       ** ep_data_bufr_row = NULL;
char       ** ep_data_bufr_col = NULL;
char       ** ep_data_bufr_format = NULL;
char       ** list_data = NULL;
char       ** func_data = NULL;
char       ** dummy_row = NULL;
char       ** dummy_col = NULL;
char       ** dummy_format = NULL;
char       ** list_row = NULL;
char       ** data_row = NULL;
int           length;
int           select;
int           pos;
int           status;
int           max_rows = 0;
int           acl_buffer_no = 0;
int           stg_buffer_no = 0;
int           n_attr_col = 0;
int           n_write_col = 0;
int           n_name_col = 0;
int           n_syn_col = 0;
int           n_update_col = 0;
int           n_read_col = 0;
int           n_valueno_col = 0;
int           n_aclno_col_for_ep_data = 0;
int           n_aclno_col_for_hd_data = 0;
int           n_aclno_col = 0;
int           n_aclname_col = 0;
int           n_wf_col = 0;
int           n_cisano_col_for_ep_data = 0;
int           n_cisano_col_for_hd_data;
int           n_sano_col;
int           n_state_col = 0;
int           p_parttype_col;
int           n_saname_col;
int           form_row = 0;
int           i,j,k;
int           found = 0;
int           buffer_number;
int           cisano_row = 0;
int           acl_row = 0;
int           FOUND = FALSE;
int           cofile_col = 0;
int           cifile_col = 0;
int           responses[1];
char          *strings[1];
MEMptr        list_bufr = NULL;
short         filedesc_write = TRUE;
short         filetype_write = TRUE;
short         cifile_write = TRUE;
short         cofile_write = TRUE;
short         filedesc_read = TRUE;
short         filetype_read = TRUE;
short         cifile_read = TRUE;
short         cofile_read = TRUE;
short         filedesc_update = TRUE;
short         filetype_update = TRUE;
short         cifile_update = TRUE;
short         cofile_update = TRUE;
char          *msg = NULL;


   _pdm_debug("Entering PDUpull_when_diff",0);
/* change mode of fields for functions that could have had functions */
FIfld_set_mode(forms.part_operations_form_id, NP_PARTNUM_FLD, 0, FI_INSERT);
FIfld_set_mode(forms.part_operations_form_id, NP_REV_FLD, 0, FI_INSERT);
FIfld_set_mode(forms.part_operations_form_id, NP_DESC_FLD, 0, FI_INSERT);
FIfld_set_mode(forms.part_operations_form_id, NP_PARTTYPE_FLD, 0, FI_INSERT);
FIg_display(forms.part_operations_form_id, NP_PARTNUM_FLD);
FIg_display(forms.part_operations_form_id, NP_REV_FLD);
FIg_display(forms.part_operations_form_id, NP_DESC_FLD);
FIg_display(forms.part_operations_form_id, NP_PARTTYPE_FLD);
if ((ep_parttype) && (strcmp(ep_parttype, "N") != 0) && 
    (strcmp(ep_parttype, "n") != 0))
  {
  _pdm_debug("setting SIMILAR_MODE_MCF to insert mode", 0);
  FIfld_set_mode(forms.part_operations_form_id, SIMILAR_MODE_MCF, 0, FI_INSERT);
  FIfld_set_mode(forms.part_operations_form_id, SIMILAR_MODE_MCF, 2, FI_INSERT);
  FIfld_set_mode(forms.part_operations_form_id, SIMILAR_MODE_MCF, 3, FI_INSERT);
  FIfld_set_mode(forms.part_operations_form_id, SIMILAR_MODE_MCF, 4, FI_INSERT);
  FIg_display(forms.part_operations_form_id, SIMILAR_MODE_MCF);
  }

   FIfld_get_num_rows(forms.part_operations_form_id,
                      ATTRIBUTE_VALUE_MCF,&max_rows);

   PDUremove_data(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF,
                  max_rows,2);
   FIg_reset(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF);
   FIfld_set_active_row(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF,0,0);

   if (similar_mode)
     {
     if (!PDU_copyof_ret_bufr)
       {
       status = MEMsplit_copy_buffer(PDU_ret_bufr, &PDU_copyof_ret_bufr, 1);
       _pdm_status("MEMsplit_copy_buffer", status);
       if (status != MEM_S_SUCCESS)
         return(PDM_E_COPY_BUFFER);
       }
     if (!PDU_hold_bufr)
       {
       _pdm_debug("copying PDU_copyof_ret_bufr to PDU_hold_bufr", 0);
       status = MEMsplit_copy_buffer(PDU_copyof_ret_bufr, &PDU_hold_bufr, 1);
       _pdm_status("MEMsplit_copy_buffer", status);
       if (status != MEM_S_SUCCESS)
         return(PDM_E_COPY_BUFFER);
       }
     if (PDMdebug_on)
       {
       MEMprint_buffers("PDU_ret_bufr in PDUpull_when_diff", PDU_ret_bufr,
                       PDU_DEBUG_FILE);
       MEMprint_buffers("PDU_hold_bufr in PDUpull_when_diff", PDU_hold_bufr,
                       PDU_DEBUG_FILE);
       }
     }

   status = PDUsetup_buffer_list(PDU_hold_bufr,1,0,&hd_attr_bufr_row,
                                 &hd_attr_bufr_col,&hd_attr_bufr_format,
                                 &hold_attr_bufr);
   _pdm_status("PDUsetup_buffer_list",status);

   if (status != PDM_S_SUCCESS)
      return(status);

   if (PDMdebug_on)
     MEMprint_buffer("hold_attr_bufr", hold_attr_bufr, PDU_DEBUG_FILE);

   status = PDUsetup_buffer_list(PDU_hold_bufr,2,0,&hd_data_bufr_row,
                                 &hd_data_bufr_col,&hd_data_bufr_format,
                                 &hold_data_bufr);

   if (PDMdebug_on)
      MEMprint_buffer("HOLD_DATA_BUFR",hold_data_bufr,PDU_DEBUG_FILE);

   _pdm_status("PDUsetup_buffer_list",status);

   if (status != PDM_S_SUCCESS)
      return(status);

   status = PDUsetup_buffer_list(PDU_ep_bufr, 1, 0, &ep_attr_bufr_row,
                                 &ep_attr_bufr_col,&ep_attr_bufr_format,
                                 &ep_attr_bufr);
   _pdm_status("PDUsetup_buffer_list",status);

   if (status != PDM_S_SUCCESS)
      return(status);

   status = PDUsetup_buffer_list(PDU_ep_bufr, 2, 0, &ep_data_bufr_row,
                                 &ep_data_bufr_col,&ep_data_bufr_format,
                                 &ep_data_bufr);

   _pdm_status("PDUsetup_buffer_list",status);

   if (status != PDM_S_SUCCESS)
      return(status);

   /* save copy of ep_data_bufr */
   if (similar_mode)
     {
     if (PDU_ep_data_bufr)
        {
        MEMclose(&PDU_ep_data_bufr);
        PDU_ep_data_bufr = NULL;
        }

     _pdm_debug("creating PDU_ep_data_bufr", 0);
     status = MEMsplit_copy_buffer(ep_data_bufr, &PDU_ep_data_bufr,0);
     }

   status = PDUget_col_number(ep_attr_bufr,"n_name",ep_attr_bufr_col,&n_name_col);
   if (status != PDM_S_SUCCESS)
      {
      PDUmessage(status, 's');
      return (status);
      }
 
   FIfld_get_text_length(forms.part_operations_form_id,NP_CATALOG_FLD,0,0,
                         &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id,NP_CATALOG_FLD,0,0,length,
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&np_catalog, text);

   FIfld_get_text_length(forms.part_operations_form_id,EP_CATALOG_FLD,0,0,
                         &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id,EP_CATALOG_FLD,0,0,length,
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_catalog, text);

   if (((ep_catalog != NULL) && (strcmp(ep_catalog,"") != 0)) &&
      ((en_itemname != NULL) && (strcmp(en_itemname,"") != 0)))
      {
      status = PDUget_col_number(ep_data_bufr,"p_parttype",ep_data_bufr_col,
                                 &p_parttype_col);

      if (status == PDM_S_SUCCESS)
      {
      for (i = 0; i < ep_attr_bufr->rows; ++i)
         {
         if (strcmp(ep_attr_bufr_row[(ep_attr_bufr->columns * i) +
             n_name_col], ep_data_bufr_col[p_parttype_col]) == 0)
            {
            FIfld_set_text(forms.part_operations_form_id,
                           EP_PARTTYPE_FLD,0,0, 
                           ep_data_bufr_row[(ep_data_bufr->columns * 0) +
                           p_parttype_col],FALSE);

            PDUfill_in_string(&refresh->rev_parttype,
                              ep_data_bufr_row[(ep_data_bufr->columns * 0) +
                              p_parttype_col]);
            PDUfill_in_string(&ep_parttype,
                              ep_data_bufr_row[(ep_data_bufr->columns * 0) +
                              p_parttype_col]);
            _pdm_debug("parttype = <%s>", ep_parttype);
            break;
            }
         }
       }
      }

   if (((np_catalog != NULL) && (strcmp(np_catalog,"") != 0)) &&
        (np_parttype && (strcmp(np_parttype, "") == 0)))
      {
      status = PDUget_col_number(hold_data_bufr,"p_parttype",
                                 hd_data_bufr_col, &p_parttype_col);

      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return (status);
        }

      for (i = 0; i < hold_attr_bufr->rows; ++i)
         {
         if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
             n_name_col], hd_data_bufr_col[p_parttype_col]) == 0)
            {
            FIfld_set_text(PDU_form_id, NP_PARTTYPE_FLD,0,0,
                           hd_data_bufr_row[(hold_data_bufr->columns * 0) +
                           p_parttype_col],FALSE);
            PDUfill_in_string(&refresh->new_parttype,
                              hd_data_bufr_row[(hold_data_bufr->columns * 0) +
                              p_parttype_col]);
            PDUfill_in_string(&np_parttype, refresh->new_parttype);
            break;
            }
         }
      }

   /* Fill in the Attributes and Values */
   if (PDU_func_buffer)
     {
     MEMclose(&PDU_func_buffer);
     PDU_func_buffer = NULL;
     }

   if ((new_mode == TRUE) || (similar_mode))
   {
   FIfld_get_text_length(forms.part_operations_form_id,NP_CATALOG_FLD,0,0,
                         &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id,NP_CATALOG_FLD,0,0,length,
                  (unsigned char *)text, &select, &pos);

   PDUfill_in_string1(&np_catalog, text);

   PDUmessage(PDS_M_FUNCTION_FILES, 's');
   status = PDMmove_functions(np_catalog,storage->storage_name,
                              &PDU_func_buffer);
   _pdm_status("PDMrmove_functions",status);
   PDUmessage(status, 's');

   if (status != PDM_S_SUCCESS)
      return(status);
   }
  else if (change_mode == TRUE)
   {
   PDUmessage(PDS_M_FUNCTION_FILES, 's');
   status = PDMmove_functions(refresh->rev_catalog,storage->storage_name,
                              &PDU_func_buffer);
   _pdm_status("PDMrmove_functions",status);

   if (status != PDM_S_SUCCESS)
      return(status);
   PDUmessage(status, 's');
   }
   if (PDMdebug_on)
      MEMprint_buffers("PDU_func_buffer inside PDUpull_when_diff",
                       PDU_func_buffer, PDU_DEBUG_FILE);


   PDU_attr_label = ATTRIBUTE_VALUE_MCF;

   status = MEMreset_buffer_no(PDU_hold_bufr, 3);
   _pdm_status("MEMreset_buffer_no", status);

   status = MEMsplit_copy_buffer(PDU_hold_bufr, &PDU_list_bufr, 1);
   _pdm_status("MEMsplit_copy_buffer_no", status);

   if (PDM_debug_on)
      MEMprint_buffers("list_buffer", PDU_list_bufr, PDU_DEBUG_FILE);

   if (PDM_debug_on)
      MEMprint_buffers("hold_attr_bufr", hold_attr_bufr, PDU_DEBUG_FILE);

   _pdm_debug("getting column numbers for hold_attr_bufr", 0);
   if ((new_mode == TRUE) || (similar_mode == TRUE))
      {
      status = PDUget_col_number(hold_attr_bufr,"n_write",hd_attr_bufr_col,
                                 &n_write_col);
      n_attr_col = n_write_col;
      }
   else if (change_mode == TRUE)
      {
      status = PDUget_col_number(hold_attr_bufr,"n_update",hd_attr_bufr_col,
                                 &n_update_col);
      n_attr_col = n_update_col;
      }
   else if (review_mode == TRUE)
      {
      status = PDUget_col_number(hold_attr_bufr,"n_read",hd_attr_bufr_col,
                                 &n_read_col);
      n_attr_col = n_read_col;
      }

   if (status != PDM_S_SUCCESS)
     {
     PDUmessage(status, 's');
     return (status);
     }

   status = PDUget_col_number(hold_attr_bufr,"n_name",hd_attr_bufr_col,&n_name_col);
   if (status != PDM_S_SUCCESS)
     {
     PDUmessage(status, 's');
     return (status);
     }

   status = PDUget_col_number(hold_attr_bufr,"n_synonym",hd_attr_bufr_col,&n_syn_col);
   if (status != PDM_S_SUCCESS)
     {
     PDUmessage(status, 's');
     return (status);
     }

   status = PDUget_col_number(hold_attr_bufr,"n_valueno",hd_attr_bufr_col,
                     &n_valueno_col);
   if (status != PDM_S_SUCCESS)
     {
     PDUmessage(status, 's');
     return (status);
     }


   _pdm_debug("looping through hold_attr_bufr", 0);
   for (i = 0; i < hold_attr_bufr->rows; i++)
      {
      if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) + n_attr_col],
          "Y") == 0)
         {
         if ((strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +                         n_name_col], "n_itemname")) &&
             (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) + 
              n_name_col], "n_itemrev")) &&
             (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +                         n_name_col], "p_parttype")) &&
             (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) + 
              n_name_col], "n_itemdesc")) &&
             (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) + 
              n_name_col], "n_aclno")) &&
             (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) + 
              n_name_col], "n_filetype")) &&
             (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) + 
              n_name_col], "n_cifilename")) &&
             (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) + 
              n_name_col], "n_cisano")) &&
             (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) + 
              n_name_col], "p_filedesc")) &&
             (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
              n_name_col], "n_cofilename")))
            {
            if ((strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                n_valueno_col], "0") == 0) && (PDU_func_buffer))
               {
               _pdm_debug("check for function", 0);
               status = MEMbuild_array(PDU_func_buffer);
               _pdm_status("MEMbuild_array", status);

               if (status != MEM_S_SUCCESS)
                 return(PDM_E_BUILD_BUFFER_ARRAY);
               func_data = (char **)PDU_func_buffer->data_ptr;

               FOUND = FALSE;
               for (j = 0; j < PDU_func_buffer->rows; j ++)
                 {
                 if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                     n_name_col], func_data[(PDU_func_buffer->columns * j) + 0])
                      == 0)
                   {
                   FOUND = TRUE;
                   string = (char *)malloc(sizeof (char) * hold_attr_bufr->row_size);
                   if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_syn_col], "") != 0)
                     {
                     sprintf(string, "*%s", hd_attr_bufr_row[(hold_attr_bufr->columns * i) + n_syn_col]);
                     _pdm_debug("string after sprintf = <%s>", string);
                      FIfld_set_text(forms.part_operations_form_id,
                                 ATTRIBUTE_VALUE_MCF,
                                 form_row,0,
                                 string, FALSE);
                     }
                   else
                     {
                     sprintf(string, "*%s", hd_attr_bufr_row[(hold_attr_bufr->columns * i) + n_name_col]);
                     _pdm_debug("string after sprintf = <%s>", string);
                      FIfld_set_text(forms.part_operations_form_id,
                                 ATTRIBUTE_VALUE_MCF,
                                 form_row,0,
                                 string, FALSE);
                     }
                   free(string);
                   break;
                   }
                 }
               if (!FOUND)
               {
               if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                   n_syn_col], "") == 0)
                  {
                  FIfld_set_text(forms.part_operations_form_id,
                                 ATTRIBUTE_VALUE_MCF,
                                 form_row,0,
                                 hd_attr_bufr_row[(hold_attr_bufr->columns*i)
                                 + n_name_col],FALSE);
                  }
               else
                  {
                  FIfld_set_text(forms.part_operations_form_id,
                                 ATTRIBUTE_VALUE_MCF,
                                 form_row,0,
                                 hd_attr_bufr_row[(hold_attr_bufr->columns*i)
                                 + n_syn_col],FALSE);
                  }
               }
            }
            else if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                n_valueno_col], "0") == 0)
               {
               if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) + 
                   n_syn_col], "") == 0)
                  {
                  FIfld_set_text(forms.part_operations_form_id,
                                 ATTRIBUTE_VALUE_MCF,
                                 form_row,0,
                                 hd_attr_bufr_row[(hold_attr_bufr->columns*i)
                                 + n_name_col],FALSE);
                  }
               else
                  {
                  FIfld_set_text(forms.part_operations_form_id,
                                 ATTRIBUTE_VALUE_MCF,
                                 form_row,0,
                                 hd_attr_bufr_row[(hold_attr_bufr->columns*i)
                                 + n_syn_col],FALSE);
                  }
               }
            else
               {
               sscanf(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                      n_valueno_col], "%d", &buffer_number);
               _pdm_debug("setting buffer # to %d", (char *)buffer_number);
               _pdm_debug("i = %d", (char *) i);
               _pdm_debug("n_valueno_col = %d", (char *) n_valueno_col);

               if (PDMdebug_on)
                MEMprint_buffers("PDU_list_bufr before reset_buffer_no", 
                                 PDU_list_bufr, PDU_DEBUG_FILE);

               status = PDUsetup_buffer_list(PDU_list_bufr,buffer_number,0,
                         &list_row, &list_data,&dummy_format, &list_bufr);
               _pdm_status("PDUsetup_buffer_list",status);
            
               if (status != PDM_S_SUCCESS)
                  return(status);

               if (PDMdebug_on)
                MEMprint_buffer("list_bufr", list_bufr, PDU_DEBUG_FILE);

               if (strcmp(list_data[0], "n_value") == 0)
                  {
                  _pdm_debug("mallocing string", 0);
                  string = (char *)malloc(sizeof (char) * (hold_attr_bufr)->row_size);
                  if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_syn_col], "") != 0)
                     {
                     _pdm_debug("writing synonym to string", 0);
                     sprintf(string, "*%s",
                             hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                             n_syn_col]);
                     _pdm_debug("string after sprintf = <%s>", string);
                     FIfld_set_text(PDU_form_id, PDU_attr_label, form_row, 0,
                                    string,FALSE);
                     }
                  else
                     {
                     _pdm_debug("writing n_name to string", 0);
                     sprintf(string, "*%s",
                             hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                             n_name_col]);
                     _pdm_debug("string after sprintf = <%s>", string);
                     FIfld_set_text(PDU_form_id, PDU_attr_label, form_row, 0,
                                    string,FALSE);
                     }
                  free(string);
                  }
               else if ((strcmp(list_data[0], "n_input") == 0) &&
                        (strcmp(list_data[1], "n_minvalue") == 0))
                  {
                  string = (char *)malloc(hold_attr_bufr->row_size);
                  memset(string, NULL, hold_attr_bufr->row_size);
                  if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_syn_col], "") != 0)
                    {
                    sprintf(string, "%s (min: %s max: %s)",
                        hd_attr_bufr_row[(hold_attr_bufr->columns * i) + 
                        n_syn_col], list_row[1], list_row[2]);
                    _pdm_debug("string after sprintf = <%s>", string);
                    FIfld_set_text(PDU_form_id, PDU_attr_label, form_row, 0,
                                    string,FALSE);
                    }
                  else
                    {
                    sprintf(string, "%s (min: %s max: %s)",
                        hd_attr_bufr_row[(hold_attr_bufr->columns * i) + 
                        n_name_col], list_row[1], list_row[2]);
                    _pdm_debug("string after sprintf = <%s>", string);
                    FIfld_set_text(PDU_form_id, PDU_attr_label, form_row, 0,
                                    string,FALSE);
                    }
                  free(string);
                  }
               else
                  {
                  _pdm_debug("setting text for PDU_attr_label", 0);
                  if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_syn_col], "") != 0)
                    {
                     FIfld_set_text(PDU_form_id, PDU_attr_label, form_row, 0,
                               hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                               n_syn_col],FALSE);
                    }
                  else
                     FIfld_set_text(PDU_form_id, PDU_attr_label, form_row, 0,
                               hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                               n_name_col],FALSE);
                  }
               }
 
/* This section is to compare the existing part buffer with the new part buffer
   and place the existing buffer catalog attribute values for those catalog 
   attributes that are the same. All attributes in the new catalog that are
   not in the existing catalog will have their default values placed on the
   form. However, the existing attributes that are not in the new catalog will
   not be placed. */

            if ((strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                        n_name_col], "n_itemno")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_itemname")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_itemrev")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "p_filedesc")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_stateno")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_creator")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_creationdate")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_creationtime")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) + 
                       n_name_col], "n_updater")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_updatedate")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_setindicator")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_updatetime")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_itemlock")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_status")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_colevel")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_archivestate")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_prevstateno")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_itemnum")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_fileno")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_fileclass")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_fileversion")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_archiveno")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) + 
                       n_name_col], "n_pendingflag")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_pendinguser")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) + 
                       n_name_col], "n_cifilename")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_cifilesize")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_ciuser")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_cidate")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_citime")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_fileco")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_cocomment")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_cosano")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_cofilename")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_couser")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_codate")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) + 
                       n_name_col], "n_cotime")))
               {
               found = 0;

               for (k =0; k < ep_data_bufr->columns; ++k)
                  {
                  if (k < ep_attr_bufr->rows)
                    {
                   if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i)                           + n_name_col], 
                      ep_attr_bufr_row[(ep_attr_bufr->columns * k) 
                      + n_name_col]) == 0)
                     { 
                     for (j = 0; j < ep_data_bufr->columns; ++j)
                        {
/* Mychelle 6/23/93 TR#139308280  & 139308268 */
                        if (i < ep_attr_bufr->rows)
                          {
                          if (strcmp(ep_attr_bufr_row[(ep_attr_bufr->columns 
                              * i) + n_name_col],ep_data_bufr_col[j]) == 0)
                             {
                             FIfld_set_text(forms.part_operations_form_id,                                                  ATTRIBUTE_VALUE_MCF,form_row,1,                                                 ep_data_bufr_row[(ep_data_bufr->                                                columns * 0) + k],FALSE);
                             MEMwrite_data(hold_data_bufr,
                                           ep_data_bufr_row[(ep_data_bufr->                                                columns * 0) + k],1,i+1);
                             ++form_row;
                             found = 1;
                             break;
                             } 
                          }
                        }/* for the for loop */
                     }
                   }
                  }
               }

            if (found == 0)
               {
               for (j = 0; j < hold_data_bufr->columns; ++j)
                  {
/* Mychelle 6/23/93 TR#139308280 & 139308268 */
                  if (i < hold_attr_bufr->rows)
                    {
                    if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->                                       columns * i) + n_name_col],hd_data_bufr_col[j])                                 == 0)
                       {
                       FIfld_set_text(forms.part_operations_form_id,                                                  ATTRIBUTE_VALUE_MCF,form_row,1,                                                 hd_data_bufr_row[(hold_data_bufr->                                              columns * 0) + j],FALSE);
                       ++form_row;
                       break;
                       }
                    }
                  }
               } /* if condition for found */
            }
         }
      }
   _pdm_debug("after looping through hold_attr_bufr", 0);

   _pdm_debug("setting file information for similar", 0);
   status = PDUcheck_file_info_privileges(NULL, hold_attr_bufr,
                       &filedesc_update, &filedesc_read, &filedesc_write,
                       &cofile_update, &cofile_read, &cofile_write,
                       &cifile_update, &cifile_read, &cifile_write,
                       &filetype_update, &filetype_read, &filetype_write);
   _pdm_status("PDUcheck_file_info_privileges", status);
   if (status != PDM_S_SUCCESS)
     _pdm_debug("failed to get file info permissions", 0);

   _pdm_debug("resetting hold_attr_bufr pointers", 0);
   status = MEMbuild_array(hold_attr_bufr);
   _pdm_status("MEMbuild_array", status);
   if (status != MEM_S_SUCCESS)
     return(PDM_E_BUILD_BUFFER_ARRAY);

   PDUsetup_buffer(hold_attr_bufr, ROW, &hd_attr_bufr_row);
   PDUsetup_buffer(hold_attr_bufr, COL, &hd_attr_bufr_col);

   if (similar_mode)
     {
     if (!cofile_write)
       {
       FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 0, FI_REVIEW);
       FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 2, FI_REVIEW);
       FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 3, FI_REVIEW);
       FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 4, FI_REVIEW);
       msg = (char *) PDUtranslate_message(PDM_E_NO_WRITE_LOCAL_FILE);
       FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
       FIg_disable(PDU_form_id, SIMMODE_COPY_TGL);
       PDU_disable_localfn_col = TRUE;
       PDU_disable_storagefn_col = TRUE;
       PDU_disable_filedesc_col = TRUE;
       PDU_disable_filetype_col = TRUE;
       }
     if (!filedesc_write)
       {
       FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 0, FI_REVIEW);
       PDU_disable_filedesc_col = TRUE;
       }
     if (!cifile_write)
       {
       _pdm_debug("disabling storage filename column", 0);
       FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 3, FI_REVIEW);
       PDU_disable_storagefn_col = TRUE;
       }
     if (!filetype_write)
       {
       FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 4, FI_REVIEW);
       PDU_disable_filetype_col = TRUE;
       }
     }


   /* Fill in acl name and workflow name */

   status = PDUget_col_number(hold_attr_bufr,"n_valueno",
                              hd_attr_bufr_col, &n_valueno_col);
   _pdm_status("PDUget_col_number",status);
       
   if (status != PDM_S_SUCCESS)
     {
     PDUmessage(status, 's');
     return (status);
     }

   for (i = 0; i < hold_attr_bufr->rows; ++i)
      {
      if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                 n_name_col], "n_aclno") == 0)
         {
         acl_buffer_no = atoi(hd_attr_bufr_row[(hold_attr_bufr->columns *                                     i) + n_valueno_col]);
         break;
         }
      }

   if (PDMdebug_on)
      MEMprint_buffer("PDU_HOLD_BUFR before PDUsetup_buffer_list (acl)",
                      PDU_hold_bufr, PDU_DEBUG_FILE);

   status = PDUsetup_buffer_list(PDU_hold_bufr, 3, acl_buffer_no, 
                                 &hd_acl_bufr_row, &hd_acl_bufr_col,
                                 &hd_acl_bufr_format, &hold_acl_bufr);
   _pdm_status("PDUsetup_buffer_list",status);

   if (status != PDM_S_SUCCESS)
      return(status);

   if (status == PDM_S_SUCCESS)
      {
      if (hold_acl_bufr->rows < 2)
         FIg_erase(forms.part_operations_form_id,ACL_NAME_BTN);
      else
         FIg_display(forms.part_operations_form_id,ACL_NAME_BTN);
      }

   if (status == PDM_S_SUCCESS)
      {
      status = PDUget_col_number(hold_data_bufr,"n_aclno",
                                 hd_data_bufr_col,
                                 &n_aclno_col_for_hd_data);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return (status);
        }

      status = PDUget_col_number(ep_data_bufr,"n_aclno",ep_data_bufr_col,
                                 &n_aclno_col_for_ep_data);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return (status);
        }

      status = PDUget_col_number(hold_acl_bufr,"n_aclno",hd_acl_bufr_col,
                                 &n_aclno_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return (status);
        }

      status = PDUget_col_number(hold_acl_bufr,"n_aclname",
                                 hd_acl_bufr_col, &n_aclname_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return (status);
        }

      status = PDUget_col_number(hold_acl_bufr,"n_workflowname",
                                 hd_acl_bufr_col, &n_wf_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return (status);
        }


      for (i = 0; i < hold_acl_bufr->rows; ++i)
         if (strcmp(ep_data_bufr_row[(ep_data_bufr->columns * 0) +
                    n_aclno_col_for_ep_data],
                    hd_acl_bufr_row[(hold_acl_bufr->columns * i) +
                    n_aclno_col]) == 0)
            {
            acl_row = i;
            break;
            }

      if (PDMdebug_on)
        {
        MEMprint_buffer("hold_acl_bufr", hold_acl_bufr, PDU_DEBUG_FILE);
        MEMprint_buffer("hold_data_bufr", hold_data_bufr, PDU_DEBUG_FILE);
        }

      _pdm_debug("acl number = %d",  hd_acl_bufr_row[(hold_acl_bufr->columns * acl_row) + n_aclno_col]);

      /* Write acl name and workflow name to the part form */

      FIfld_set_text(forms.part_operations_form_id,ACL_NAME_FLD,0,0, 
                     hd_acl_bufr_row[(hold_acl_bufr->columns * acl_row) +                            n_aclname_col], FALSE);
      FIfld_set_text(forms.part_operations_form_id,WORKFLOW_FLD,
                     0,0, hd_acl_bufr_row[(hold_acl_bufr->columns                                    * acl_row) + n_wf_col], FALSE);

      /* Put default acl number in the data buffer */

      status = MEMwrite_data(hold_data_bufr,
                            hd_acl_bufr_row[(hold_acl_bufr->columns * acl_row) +
                            n_aclno_col],1,n_aclno_col_for_hd_data + 1); 
      if (hold_data_bufr->rows > 1)
        {
        status = MEMwrite_data(hold_data_bufr,
                            hd_acl_bufr_row[(hold_acl_bufr->columns * acl_row) +
                            n_aclno_col],2,n_aclno_col_for_hd_data + 1); 
        }
      if (PDMdebug_on)
        MEMprint_buffer("hold_data_bufr", hold_data_bufr, PDU_DEBUG_FILE);
      }

   /* Fill in the storage area name */

   for (i = 0; i < hold_attr_bufr->rows; ++i)
      {
      if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                 n_name_col], "n_cisano") == 0)
         {
         stg_buffer_no = atoi(hd_attr_bufr_row[(hold_attr_bufr->columns *                                     i) + n_valueno_col]);
         break;
         }
      }

   if (PDMdebug_on)
      MEMprint_buffer("PDU_HOLD_BUFR before PDUsetup_buffer_list (stg)",
                      PDU_hold_bufr, PDU_DEBUG_FILE);

   status = PDUsetup_buffer_list(PDU_hold_bufr, 3, stg_buffer_no, 
                                 &hd_stg_bufr_row, &hd_stg_bufr_col,
                                 &hd_stg_bufr_format,&hold_stg_bufr);

   if (status != PDM_S_SUCCESS)
      return(status);

   if (status == PDM_S_SUCCESS)
      {
      if (hold_stg_bufr->rows < 2)
         FIg_erase(PDU_form_id,STORAGE_AREA_BTN);
      else
         FIg_display(PDU_form_id,STORAGE_AREA_BTN);
      }

   status = PDUget_col_number(ep_data_bufr,"n_cisano",ep_data_bufr_col,
                              &n_cisano_col_for_ep_data);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return (status);
        }

   status = PDUget_col_number(hold_data_bufr,"n_cisano",hd_data_bufr_col,                                     &n_cisano_col_for_hd_data);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return (status);
        }

   status = PDUget_col_number(hold_stg_bufr,"n_sano",hd_stg_bufr_col,
                              &n_sano_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return (status);
        }

   status = PDUget_col_number(hold_stg_bufr,"n_saname",hd_stg_bufr_col,
                              &n_saname_col);
      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return (status);
        }


   /* Find defaulted storage area in the stg_bufr */

   for (i = 0; i < hold_stg_bufr->rows; ++i)
      {
      if (strcmp(ep_data_bufr_row[(ep_data_bufr->columns * 0) +
                 n_cisano_col_for_ep_data],
                 hd_stg_bufr_row[(hold_stg_bufr->columns * i) +
                 n_sano_col]) == 0)
         {
         cisano_row = i;
         break;
         }
      }

   /* Write storage area name to part form */
   FIfld_set_text(forms.part_operations_form_id,STORAGE_AREA_FLD,
                  0,0, hd_stg_bufr_row[(hold_stg_bufr->columns *                                 cisano_row) + n_saname_col], FALSE);

   /* Put default storage area number in data buffer */

   if (PDMdebug_on)
      MEMprint_buffer("HOLD_DATA_BUFR before writing stg area",
                      hold_data_bufr, PDU_DEBUG_FILE);

   /* Put default storage area number into the data buffer */
   status = MEMwrite_data(hold_data_bufr,
                          hd_stg_bufr_row[(hold_stg_bufr->columns *
                          cisano_row) + n_sano_col],1,
                          n_cisano_col_for_hd_data + 1);
   _pdm_status("MEMwrite_data",status);

   if (status != MEM_S_SUCCESS)
      return(status);

   if (PDMdebug_on)
      MEMprint_buffer("HOLD_DATA_BUFR after writing stg area",
                      hold_data_bufr, PDU_DEBUG_FILE);

   /* Fill in State name */

   if (PDMdebug_on)
      MEMprint_buffer("HOLD_DATA_BUFR before getting state name",
                      hold_data_bufr,PDU_DEBUG_FILE);

   status = PDUget_col_number(hold_data_bufr,"n_cocomment",
                              hd_data_bufr_col, &n_state_col);

   if (status != PDM_S_SUCCESS)
     {
     PDUmessage(status, 's');
     return (status);
     }

   for (i = 0; i < hold_attr_bufr->rows; ++i)
      {
      if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                 n_name_col], hd_data_bufr_col[n_state_col]) == 0)
         {
         FIfld_set_text(forms.part_operations_form_id, STATE_NAME_FLD,0,
                        0, hd_data_bufr_row[(hold_data_bufr->columns * 0)                               + n_state_col],FALSE);
         break;
         }
      }

   /* MEMsplit_copy the attr_bufr and data_bufr to global buffers to allow the 
   users to enter information for the new part before adding the the new part 
   info to the database. */

   if (PDU_attr_bufr)
      {
      MEMclose(&PDU_attr_bufr);
      PDU_attr_bufr = NULL;
      }
   if (PDU_data_bufr)
      {
      MEMclose(&PDU_data_bufr);
      PDU_data_bufr = NULL;
      }

   if (attr_bufr)
     {
     MEMclose(&attr_bufr);
     attr_bufr = NULL;
     }
   if (data_bufr)
     {
     MEMclose(&data_bufr);
     data_bufr = NULL;
     }

   status = PDUsetup_buffer_list(PDU_copyof_ret_bufr,1,0,&dummy_row,
                                 &dummy_col,&dummy_format, &attr_bufr);
   _pdm_status("PDUsetup_buffer_list",status);

   if (status != PDM_S_SUCCESS)
      return(status);

   status = PDUsetup_buffer_list(PDU_copyof_ret_bufr,2,0,&dummy_row,
                                 &dummy_col,&dummy_format, &data_bufr);
   _pdm_status("PDUsetup_buffer_list",status);

   if (status != PDM_S_SUCCESS)
      return(status);

   status = MEMsplit_copy_buffer(hold_attr_bufr, &PDU_attr_bufr,0);
   status = MEMsplit_copy_buffer(hold_data_bufr, &PDU_data_bufr,0);

   if (status == MEM_S_SUCCESS)
      status = PDM_S_SUCCESS;

   if (attr_bufr)
     {
     MEMclose(&attr_bufr);
     attr_bufr = NULL;
     }
   if (data_bufr)
     {
     MEMclose(&data_bufr);
     data_bufr = NULL;
     }

   MEMbuild_array(PDU_data_bufr);
   PDUsetup_buffer(PDU_data_bufr, ROW, &data_row);
   PDUget_buffer_col(PDU_data_bufr, "n_cofilename", &cofile_col);
   PDUget_buffer_col(PDU_data_bufr, "n_cifilename", &cifile_col);

   MEMwrite_data(PDU_data_bufr, NULL_STRING, 1, cofile_col + 1);
   MEMwrite_data(PDU_data_bufr, NULL_STRING, 1, cifile_col + 1);

   if (PDU_func_buffer != NULL)
      {
      PDU_func_bufr_exists = TRUE;
      _pdm_debug("Put command on queue to call get_atr_val ppl",PDU_DEBUG_FILE);

      PDUmessage(PDC_M_GET_ATTR_VALUES,'c');

      responses[0] = EX_CMD_KEY;
      strings[0] = "PDGtAtrVal";

      status = PDUprepare_queue (responses, strings, 1);
      _pdm_status("PDUprepare_queue",status);
      }
   else
      PDU_func_bufr_exists = FALSE;

return (status);
}

/* This function is used by the PDUpart_form.c file for pulling out the values
   of existing parts. It is used when the mode of operation is similar and the
   Existing Part Palette is modified. */

int  PDUpull_diff_values()

{

MEMptr        attr_bufr;
MEMptr        data_bufr;
MEMptr        epattr_bufr;
MEMptr        epdata_bufr;
MEMptr        acl_bufr = NULL;
MEMptr        stg_bufr = NULL;
char       ** epdata1_row;
char       ** epdata1_col;
char       ** epdata1_format;
char       ** epdata2_row;
char       ** epdata2_col;
char       ** data1_row;
char       ** data1_col;
char       ** data1_format;
char       ** data2_row;
char       ** data2_col;
char       ** data2_format;
int           acl_buffer_no = 0;
int           stg_buffer_no = 0;
int           max_rows;
int           status;
int           n_attr_col = 0;
int           n_write_col = 0;
int           n_name_col = 0;
int           n_syn_col = 0;
int           n_update_col = 0;
int           n_read_col = 0;
int           form_row = 0;
int           i,j,k;
int           found = 0;


_pdm_debug("Entering PDUpull_diff_values",0);

/* Blank out the ATTRIBUTE_VALUE_MCF */

/* Find maximum number of rows */

FIfld_get_num_rows(forms.part_operations_form_id,
                   ATTRIBUTE_VALUE_MCF,&max_rows);

PDUremove_data(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF,
               max_rows,2);
FIg_reset(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF);
FIfld_set_active_row(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF,0,0);

/* Extract buffers and columns */

PDUsetup_buffer_list(PDU_ret_bufr, 1, 0, &data1_row, &data1_col,
                     &data1_format,&attr_bufr);
PDUsetup_buffer_list(PDU_ret_bufr, 2, 0, &data2_row, &data2_col,
                     &data2_format,&data_bufr);
PDUsetup_buffer_list(PDU_ep_bufr, 1, 0, &epdata1_row,
                     &epdata1_col,&epdata1_format,&epattr_bufr);
PDUsetup_buffer_list(PDU_ep_bufr, 2, 0, &epdata2_row,
                     &epdata2_col,&data2_format,&epdata_bufr);

status = PDUget_col_number(attr_bufr,"n_name",data1_col,&n_name_col);

if (status != PDM_S_SUCCESS)
  {
  PDUmessage(status, 's');
  return (status);
  }

/* Fill in the default Attributes and Values */

          if ((new_mode == TRUE) || (similar_mode == TRUE))
             {
             status = PDUget_col_number(attr_bufr,"n_write",data1_col,
                                        &n_write_col);
             n_attr_col = n_write_col;
             }
          else if (change_mode == TRUE)
             {
             status = PDUget_col_number(attr_bufr,"n_update",data1_col,
                                        &n_update_col);
             n_attr_col = n_update_col;
             }
          else if (review_mode == TRUE)
             {
             status = PDUget_col_number(attr_bufr,"n_read",data1_col,
                                        &n_read_col);
             n_attr_col = n_read_col;
             }

          if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            return (status);
            }

          status = PDUget_col_number(attr_bufr,"n_name",data1_col,&n_name_col);
          if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            return (status);
            }

          status = PDUget_col_number(attr_bufr,"n_synonym",data1_col,&n_syn_col);
          if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status, 's');
            return (status);
            }

          for (i = 0; i < attr_bufr->rows; i++)
             {
             if (strcmp(data1_row[(attr_bufr->columns * i) + n_attr_col],"Y")
                 == 0)
                {
                if ((strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                        "n_itemname")) &&
                    (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                        "n_itemrev")) &&
                    (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                        "p_parttype")) &&
                    (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                        "n_itemdesc")) &&
                    (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                        "n_aclno")) &&
                    (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                        "n_filetype")) &&
                    (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                        "n_cifilename")) &&
                    (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                        "n_cisano")) &&
                    (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                        "n_cofilename")))
                   {

                   if (strcmp(data1_row[(attr_bufr->columns * i) + n_syn_col],
                       "") == 0)
                      {
                      FIfld_set_text(forms.part_operations_form_id,
                                     ATTRIBUTE_VALUE_MCF,
                                     form_row,0,data1_row[(attr_bufr->columns*i)
                                     + n_name_col],FALSE);
                      }
                   else
                      {
                      FIfld_set_text(forms.part_operations_form_id,
                                     ATTRIBUTE_VALUE_MCF,
                                     form_row,0,data1_row[(attr_bufr->columns*i)
                                     + n_syn_col],FALSE);
                      }


/* This section is to compare the existing part buffer with the new part buffer
   and place the existing buffer catalog attribute values for those catalog
   attributes that are the same. All attributes in the new catalog that are
   not in the existing catalog will have their default values placed on the
   form. However, the existing attributes that are not in the new catalog will
   not be placed. */
                  if ((strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_itemno")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_itemname")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_itemrev")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_stateno")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_creator")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_creationdate")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_creationtime")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_updater")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_updatedate")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_setindicator")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_updatetime")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_itemlock")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_status")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_colevel")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_archivestate")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_prevstateno")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_itemnum")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_fileno")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_fileclass")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_fileversion")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_archiveno")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_pendingflag")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_pendinguser")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_cifilename")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_cifilesize")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_ciuser")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_cidate")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_citime")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_fileco")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_cocomment")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_cosano")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_cofilename")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_couser")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_codate")) &&
                     (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                              "n_cotime")))

                   {

                   found = 0;

                   for (k =0; k < epdata_bufr->columns; ++k)
                      {
                      if (strcmp(data1_row[(attr_bufr->columns * i) +
                          n_name_col],
                          epdata1_row[(epattr_bufr->columns * k) +
                          n_name_col]) == 0)
                         {
                         for (j = 0; j < epdata_bufr->columns; ++j)
                            {
                            if (strcmp(epdata1_row[(epattr_bufr->columns * i) +
                                n_name_col],epdata2_col[j]) == 0)
                               {
                               FIfld_set_text(forms.part_operations_form_id,
                                              ATTRIBUTE_VALUE_MCF,form_row,1,
                                              epdata2_row[(epdata_bufr->columns
                                              * 0) + k],FALSE);
                               MEMwrite_data(data_bufr,
                                             epdata2_row[(epdata_bufr->columns *
                                                          0) + k],1,i+1);
                               ++form_row;
                               found = 1;
                               break;
                               }
                            }/* for the for loop */
                         }
                      }
                   } 

                   if (found == 0)
                      {
                      for (j = 0; j < data_bufr->columns; ++j)
                         {
                         if (strcmp(data1_row[(attr_bufr->columns * i) +
                             n_name_col],data2_col[j]) == 0)
                            {
                            FIfld_set_text(forms.part_operations_form_id,
                                           ATTRIBUTE_VALUE_MCF,form_row,1,
                                           data2_row[(data_bufr->columns * 0) +
                                           j],FALSE);
                            ++form_row;
                            break;
                            }
                         }
                      } /* if condition for found */

                   }
                }
             }

/* MEMappend buffers back together into PDU_ret_bufr so that it can be used
   with the updated information in the data buffer. */

           if (PDU_ret_bufr)
              {
              MEMclose(&PDU_ret_bufr);
              PDU_ret_bufr = NULL;
              }

           PDU_ret_bufr = attr_bufr;
           status = MEMappend(data_bufr,PDU_ret_bufr);
           _pdm_status("MEMappend",status);
           if (status != MEM_S_SUCCESS)
              return(status);

           if (status == MEM_S_SUCCESS)
              MEMappend(stg_bufr,acl_bufr);
           _pdm_status("MEMappend",status);
           if (status != MEM_S_SUCCESS)
              return(status);

           if (status == MEM_S_SUCCESS)
              MEMappend(acl_bufr,PDU_ret_bufr);
           _pdm_status("MEMappend",status);
           if (status != MEM_S_SUCCESS)
              return(status);

           /*if (status == MEM_S_SUCCESS)
              MEMprint_buffers("New PDU_ret_bufr from PDUpull_diff_values",
                                PDU_ret_bufr,0);*/

/* Set up global buffers from PDU_ret_bufr to allow for the construction of a
   new PDU_ret_bufr when the user enters information for a new part and 
   selects the Add Part command. */

           status = PDUsetup_buffer_list(PDU_ret_bufr, 1, 0, &PDU_attr_row,
                                &PDU_attr_col, &PDU_attr_format,&PDU_attr_bufr);
           _pdm_status("PDUsetup_buffer_list",status);
           status = PDUsetup_buffer_list(PDU_ret_bufr, 2, 0, &PDU_data_row,
                                &PDU_data_col, &PDU_data_format,&PDU_data_bufr);
           _pdm_status("PDUsetup_buffer_list",status);
           status =  PDUsetup_buffer_list(PDU_ret_bufr, 3, acl_buffer_no,
                                &PDU_acl_row, &PDU_acl_col, &PDU_acl_format, 
                                &PDU_acl_bufr);
           _pdm_status("PDUsetup_buffer_list",status);
           status = PDUsetup_buffer_list(PDU_ret_bufr, 3, stg_buffer_no,
                                &PDU_stg_row, &PDU_stg_col, &PDU_stg_format, 
                                &PDU_stg_bufr);
           _pdm_status("PDUsetup_buffer_list",status);

return (status);
}

/* This function will default the buffer information for the catalog entered
   in the case where the user has added a part to the catalog, only changes the
   part number or the revision and wants to change the default and add the part    to the same catalog. The buffer used is a copy of the original buffer of the    catalog when it was first entered. */

int PDUsamecat_defaults()

{
MEMptr        hold_attr_bufr = NULL;
MEMptr        hold_data_bufr = NULL;
MEMptr        hold_acl_bufr = NULL;
MEMptr        hold_stg_bufr = NULL;
MEMptr        ep_attr_bufr = NULL;
MEMptr        ep_data_bufr = NULL;
char        * string = NULL;
char       ** hd_attr_bufr_row = NULL;
char       ** hd_attr_bufr_col = NULL;
char       ** hd_attr_bufr_format = NULL;
char       ** hd_data_bufr_row = NULL;
char       ** hd_data_bufr_col = NULL;
char       ** hd_data_bufr_format = NULL;
char       ** hd_acl_bufr_row;
char       ** hd_acl_bufr_col;
char       ** hd_acl_bufr_format;
char       ** hd_stg_bufr_row;
char       ** hd_stg_bufr_col;
char       ** hd_stg_bufr_format;
char       ** ep_attr_bufr_row = NULL;
char       ** ep_attr_bufr_col = NULL;
char       ** ep_attr_bufr_format = NULL;
char       ** ep_data_bufr_row = NULL;
char       ** ep_data_bufr_col = NULL;
char       ** ep_data_bufr_format = NULL;
char       ** func_data = NULL;
int           n_aclno_col_for_ep_data;
int           n_aclno_col_for_hd_data;
int           n_cisano_col_for_ep_data;
int           n_cisano_col_for_hd_data;
char       ** list_data = NULL;
int           found = 0;
int           buffer_number;
MEMptr        attr_bufr = NULL;
MEMptr        data_bufr = NULL;
MEMptr        acl_bufr = NULL;
MEMptr        stg_bufr = NULL;
MEMptr        list_bufr = NULL;
char       ** data1_row;
char       ** data1_col;
char       ** data1_format;
char       ** data2_row;
char       ** data2_col;
char       ** data2_format;
char       ** data3_row;
char       ** data3_col;
char       ** data3_format;
char       ** data4_row;
char       ** data4_col;
char       ** data4_format;
char       ** list_row;
char       ** dummy_format;
int           length;
int           select;
int           pos;
int           acl_buffer_no = 0;
int           stg_buffer_no = 0;
int           status;
int           max_rows;
int           n_attr_col = 0;
int           n_write_col = 0;
int           n_name_col = 0;
int           n_syn_col = 0;
int           n_valueno_col = 0;
int           n_aclname_col = 0;
int           n_wf_col = 0;
int           n_saname_col = 0;
int           n_state_col = 0;
int           p_parttype_col = 0;
int           form_row = 0;
int           i,j,k;
int           n_aclno_col_for_data;
int           n_aclno_col;
int           n_cisano_col_for_data;
int           n_sano_col;
int           acl_row = 0;
int           attr_row;
int           cisano_row = 0;
int           responses[1];
char          *tmp_parttype = NULL;
char          *strings[1];
short         FOUND = FALSE;
static char   * text;
char          *msg = NULL;
short         filedesc_write = TRUE;
short         filetype_write = TRUE;
short         cifile_write = TRUE;
short         cofile_write = TRUE;
short         filedesc_read = TRUE;
short         filetype_read = TRUE;
short         cifile_read = TRUE;
short         cofile_read = TRUE;
short         filedesc_update = TRUE;
short         filetype_update = TRUE;
short         cifile_update = TRUE;
short         cofile_update = TRUE;
short         update = 1;
short         read = 1;
short         write = 1;
char          *attr1 = NULL;
char          *attr2 = NULL;

_pdm_debug("Entering PDUsamecat_defaults",0);

PDU_disable_filedesc_col = FALSE;
PDU_disable_localfn_col = FALSE;
PDU_disable_storagefn_col = FALSE;
PDU_disable_filetype_col = FALSE;


FIg_enable(forms.part_operations_form_id,NP_PARTTYPE_BTN);
/* change mode of fields for functions that could have had functions */
FIfld_set_mode(forms.part_operations_form_id, NP_PARTNUM_FLD, 0, FI_INSERT);
FIfld_set_mode(forms.part_operations_form_id, NP_REV_FLD, 0, FI_INSERT);
FIfld_set_mode(forms.part_operations_form_id, NP_DESC_FLD, 0, FI_INSERT);
FIfld_set_mode(forms.part_operations_form_id, NP_PARTTYPE_FLD, 0, FI_INSERT);
FIg_display(forms.part_operations_form_id, NP_PARTNUM_FLD);
FIg_display(forms.part_operations_form_id, NP_REV_FLD);
FIg_display(forms.part_operations_form_id, NP_DESC_FLD);
FIg_display(forms.part_operations_form_id, NP_PARTTYPE_FLD);
if (similar_mode == TRUE)
  {
  FIfld_set_mode(forms.part_operations_form_id, SIMILAR_MODE_MCF, 0, FI_INSERT);
  FIfld_set_mode(forms.part_operations_form_id, SIMILAR_MODE_MCF, 2, FI_INSERT);
  FIfld_set_mode(forms.part_operations_form_id, SIMILAR_MODE_MCF, 3, FI_INSERT);
  FIfld_set_mode(forms.part_operations_form_id, SIMILAR_MODE_MCF, 4, FI_INSERT);
  FIg_display(forms.part_operations_form_id, SIMILAR_MODE_MCF);
  }
else if (new_mode == TRUE)
  {
  FIfld_set_mode(forms.part_operations_form_id, FILE_INFO_MCF, 0, FI_INSERT);
  FIfld_set_mode(forms.part_operations_form_id, FILE_INFO_MCF, 1, FI_INSERT);
  FIfld_set_mode(forms.part_operations_form_id, FILE_INFO_MCF, 2, FI_INSERT);
  FIfld_set_mode(forms.part_operations_form_id, FILE_INFO_MCF, 3, FI_INSERT);
  FIg_display(forms.part_operations_form_id, FILE_INFO_MCF);
  }
if (similar_mode == TRUE)
   {
   /* Blank out the ATTRIBUTE_VALUE_MCF */

   /* Find maximum number of rows */

   FIfld_get_num_rows(forms.part_operations_form_id,
                      ATTRIBUTE_VALUE_MCF,&max_rows);

   PDUremove_data(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF,
                  max_rows,2);
   FIg_reset(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF);
   FIfld_set_active_row(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF,0,0);

   status = PDUsetup_buffer_list(PDU_hold_bufr,1,0,&hd_attr_bufr_row,
                                 &hd_attr_bufr_col,&hd_attr_bufr_format,
                                 &hold_attr_bufr);
   _pdm_status("PDUsetup_buffer_list",status);

   if (status != PDM_S_SUCCESS)
      return(status);

   status = PDUsetup_buffer_list(PDU_hold_bufr,2,0,&hd_data_bufr_row,
                                 &hd_data_bufr_col,&hd_data_bufr_format,
                                 &hold_data_bufr);

   _pdm_status("PDUsetup_buffer_list",status);

   if (status != PDM_S_SUCCESS)
      return(status);

   status = PDUsetup_buffer_list(PDU_ep_bufr, 1, 0, &ep_attr_bufr_row,
                                 &ep_attr_bufr_col,&ep_attr_bufr_format,
                                 &ep_attr_bufr);
   _pdm_status("PDUsetup_buffer_list",status);

   if (status != PDM_S_SUCCESS)
      return(status);

   status = PDUsetup_buffer_list(PDU_ep_bufr, 2, 0, &ep_data_bufr_row,
                                 &ep_data_bufr_col,&ep_data_bufr_format,
                                 &ep_data_bufr);

   _pdm_status("PDUsetup_buffer_list",status);

   if (status != PDM_S_SUCCESS)
      return(status);

   if (PDMdebug_on)
     {
     MEMprint_buffer("HOLD BUFFER", hold_data_bufr, PDU_DEBUG_FILE);
     MEMprint_buffer("EP BUFFER", ep_data_bufr, PDU_DEBUG_FILE);
     }

   status = PDUget_col_number(ep_attr_bufr,"n_name",ep_attr_bufr_col,&n_name_col);
   if (status != PDM_S_SUCCESS)
     {
     PDUmessage(status, 's');
     return (status);
     }

   /* Fill in the Attributes and Values */

   PDU_attr_label = ATTRIBUTE_VALUE_MCF;

   status = MEMreset_buffer_no(PDU_hold_bufr, 3);
   _pdm_status("MEMreset_buffer_no", status);

   status = MEMsplit_copy_buffer(PDU_hold_bufr, &PDU_list_bufr, 1);
   _pdm_status("MEMsplit_copy_buffer_no", status);

   if (PDM_debug_on)
      MEMprint_buffers("list_buffer", PDU_list_bufr, PDU_DEBUG_FILE);

   if ((new_mode == TRUE) || (similar_mode == TRUE))
      {
      status = PDUget_col_number(hold_attr_bufr,"n_write",hd_attr_bufr_col,
                                 &n_write_col);
      n_attr_col = n_write_col;

      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return (status);
        }
      }

   status = PDUget_col_number(hold_attr_bufr,"n_name",hd_attr_bufr_col,&n_name_col);
   if (status != PDM_S_SUCCESS)
     {
     PDUmessage(status, 's');
     return (status);
     }

   status = PDUget_col_number(hold_attr_bufr,"n_synonym",hd_attr_bufr_col,&n_syn_col);
   if (status != PDM_S_SUCCESS)
     {
     PDUmessage(status, 's');
     return (status);
     }

   status = PDUget_col_number(hold_attr_bufr,"n_valueno",hd_attr_bufr_col,
                     &n_valueno_col);
   if (status != PDM_S_SUCCESS)
     {
     PDUmessage(status, 's');
     return (status);
     }


   if (hold_attr_bufr)
     _pdm_debug("hold_attr_bufr->rows = %d", (char *)hold_attr_bufr->rows);
   if (PDU_func_buffer)
     _pdm_debug("PDU_func_buffer->rows = %d", (char *)PDU_func_buffer->rows);
   if (ep_data_bufr)
     _pdm_debug("ep_data_bufr->columns = %d", (char *)ep_data_bufr->columns);
   for (i = 0; i < hold_attr_bufr->rows; i++)
      {
      _pdm_debug("beginning of loop", 0);
      _pdm_debug("i (hold_attr_bufr->rows) = %d", (char *)i);
      if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) + n_attr_col],
          "Y") == 0)
         {
         if ((strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
              n_name_col], "n_itemname")) &&
             (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
              n_name_col], "n_itemrev")) &&
             (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
              n_name_col], "p_parttype")) &&
             (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
              n_name_col], "n_itemdesc")) &&
             (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
              n_name_col], "n_aclno")) &&
             (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
              n_name_col], "n_filetype")) &&
             (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
              n_name_col], "n_cifilename")) &&
             (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
              n_name_col], "n_cisano")) &&
             (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
              n_name_col], "p_filedesc")) &&
             (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
              n_name_col], "n_cofilename")))
            {
            _pdm_debug("checking for PDU_func_bufr", 0);
            if ((strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                n_valueno_col], "0") == 0) && (PDU_func_buffer))
               {
               _pdm_debug("check for function", 0);
               status = MEMbuild_array(PDU_func_buffer);
               _pdm_status("MEMbuild_array", status);

               if (status != MEM_S_SUCCESS)
                 return(PDM_E_BUILD_BUFFER_ARRAY);
               func_data = (char **)PDU_func_buffer->data_ptr;

               FOUND = FALSE;
               for (j = 0; j < PDU_func_buffer->rows; j ++)
                 {
                 _pdm_debug("j (PDU_func_buffer->rows) = %d", (char *)j);
                 if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                     n_name_col], func_data[(PDU_func_buffer->columns * j) + 0])
                      == 0)
                   {
                   FOUND = TRUE;
                   string = (char *)malloc(sizeof (char) * hold_attr_bufr->row_size);
                   memset(string,NULL,sizeof (char) * hold_attr_bufr->row_size);
                   if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_syn_col], "") != 0)
                     {
                     sprintf(string, "*%s", hd_attr_bufr_row[(hold_attr_bufr->columns * i) + n_syn_col]);
                     _pdm_debug("string after sprintf = <%s>", string);
                      FIfld_set_text(PDU_form_id, ATTRIBUTE_VALUE_MCF, 
                                     form_row, 0, string, FALSE);
                     }
                   else
                     {
                     sprintf(string, "*%s", hd_attr_bufr_row[(hold_attr_bufr->columns * i) + n_name_col]);
                     _pdm_debug("string after sprintf = <%s>", string);
                      FIfld_set_text(PDU_form_id, ATTRIBUTE_VALUE_MCF,
                                     form_row,0, string, FALSE);
                     }
                   if (string) free(string);
                   break;
                   }
                 }
               if (!FOUND)
               {
               if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                   n_syn_col], "") == 0)
                  {
                  FIfld_set_text(forms.part_operations_form_id,
                                 ATTRIBUTE_VALUE_MCF,
                                 form_row,0,
                                 hd_attr_bufr_row[(hold_attr_bufr->columns*i)
                                 + n_name_col],FALSE);
                  }
               else
                  {
                  FIfld_set_text(forms.part_operations_form_id,
                                 ATTRIBUTE_VALUE_MCF,
                                 form_row,0,
                                 hd_attr_bufr_row[(hold_attr_bufr->columns*i)
                                 + n_syn_col],FALSE);
                  }
               }
             }
            else if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                n_valueno_col], "0") == 0)
               {
               _pdm_debug("comparing n_syn_col", 0);
               if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                   n_syn_col], "") == 0)
                  {
                  FIfld_set_text(forms.part_operations_form_id,
                                 ATTRIBUTE_VALUE_MCF,
                                 form_row,0,
                                 hd_attr_bufr_row[(hold_attr_bufr->columns*i)
                                 + n_name_col],FALSE);
                  }
               else
                  {
                  FIfld_set_text(forms.part_operations_form_id,
                                 ATTRIBUTE_VALUE_MCF,
                                 form_row,0,
                                 hd_attr_bufr_row[(hold_attr_bufr->columns*i)
                                 + n_syn_col],FALSE);
                  }
               }
            else
               {
               sscanf(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                      n_valueno_col], "%d", &buffer_number);
               _pdm_debug("buffer_number = %d", (char *)buffer_number);

               status = PDUsetup_buffer_list(PDU_list_bufr,buffer_number,0,
                         &list_row, &list_data,&dummy_format, &list_bufr);
               _pdm_status("PDUsetup_buffer_list",status);

               if (status != PDM_S_SUCCESS)
                  return(status);

               if (PDMdebug_on)
                MEMprint_buffer("list_bufr", list_bufr, PDU_DEBUG_FILE);

               _pdm_debug("comparing list_data", 0);
               if (strcmp(list_data[0], "n_value") == 0)
                  {
                  string = (char *)malloc(sizeof (char) * (hold_attr_bufr)->row_size);
                  memset(string,NULL,sizeof(char) * (hold_attr_bufr)->row_size);
                  if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_syn_col], "") != 0)
                     {
                     sprintf(string, "*%s",
                             hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                             n_syn_col]);
                     _pdm_debug("string after sprintf = <%s>", string);
                     FIfld_set_text(PDU_form_id, PDU_attr_label, form_row, 0,
                                    string,FALSE);
                     }
                  else
                     {
                     sprintf(string, "*%s",
                             hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                             n_name_col]);
                     _pdm_debug("string after sprintf = <%s>", string);
                     FIfld_set_text(PDU_form_id, PDU_attr_label, form_row, 0,
                                    string,FALSE);
                     }
                  if (string) free(string);
                  }
               else if ((strcmp(list_data[0], "n_input") == 0) &&
                        (strcmp(list_data[1], "n_minvalue") == 0))
                  {
                  string = (char *)malloc(hold_attr_bufr->row_size);
                  memset(string, NULL, hold_attr_bufr->row_size);
                  if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_syn_col], "") != 0)
                    {
                    sprintf(string, "%s (min: %s max: %s)",
                        hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                        n_syn_col], list_row[1], list_row[2]);
                    _pdm_debug("string after sprintf = <%s>", string);
                    FIfld_set_text(PDU_form_id, PDU_attr_label, form_row, 0,
                                    string,FALSE);
                    }
                  else
                    {
                    sprintf(string, "%s (min: %s max: %s)",
                        hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                        n_name_col], list_row[1], list_row[2]);
                    _pdm_debug("string after sprintf = <%s>", string);
                    FIfld_set_text(PDU_form_id, PDU_attr_label, form_row, 0,
                                    string,FALSE);
                    }
                  free(string);
                  }
               else
                  {
                  if (PDMdebug_on)
                    MEMprint_buffer("hold_attr_bufr", hold_attr_bufr, 
                                    PDU_DEBUG_FILE);

                  if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_syn_col], "") != 0)
                      {
                      _pdm_debug("writing synonym text", 0);
                      FIfld_set_text(PDU_form_id, PDU_attr_label, form_row, 0,
                               hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                               n_syn_col],FALSE);
                      }
                  else
                      {
                      _pdm_debug("writing  name text", 0);
                     FIfld_set_text(PDU_form_id, PDU_attr_label, form_row, 0,
                               hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                               n_name_col],FALSE);
                      }
                  _pdm_debug("after comparing synonyms", 0);
                  }
               }

/* This section is to compare the existing part buffer with the new part buffer
   and place the existing buffer catalog attribute values for those catalog
   attributes that are the same. All attributes in the new catalog that are
   not in the existing catalog will have their default values placed on the
   form. However, the existing attributes that are not in the new catalog will
   not be placed. */

_pdm_debug("comparing buffers", 0);

            if ((strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                 n_name_col], "n_itemno")) &&
                (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                 n_name_col], "n_itemname")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "p_filedesc")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                n_name_col], "n_itemrev")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_stateno")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_creator")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_creationdate")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_creationtime")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_updater")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_updatedate")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_setindicator")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_updatetime")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_itemlock")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_status")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_colevel")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_archivestate")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_prevstateno")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_itemnum")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_fileno")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_fileclass")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_fileversion")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_archiveno")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_pendingflag")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_pendinguser")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_cifilename")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_cifilesize")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_ciuser")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_cidate")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_citime")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_fileco")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_cocomment")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_cosano")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_cofilename")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_couser")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_codate")) &&
               (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                       n_name_col], "n_cotime")))
              {
              found = 0;

              for (k =0; k < ep_data_bufr->columns; ++k)
                 {
                 _pdm_debug("k (ep_data_bufr->columns) = %d", (char *)k);
                 if (k < ep_attr_bufr->rows)
                   {
                   PDUfill_in_string(&attr1, 
                hd_attr_bufr_row[(hold_attr_bufr->columns * i) + n_name_col]);
                   PDUfill_in_string(&attr2, 
                ep_attr_bufr_row[(ep_attr_bufr->columns * k) + n_name_col]);
                   if (attr1 && attr2 && (strcmp(attr1, attr2) == 0))
                    {
                    for (j = 0; j < ep_data_bufr->columns; ++j)
                       {
                       if (i < ep_attr_bufr->rows)
                        {
                        PDUfill_in_string(&attr1,
                     ep_attr_bufr_row[(ep_attr_bufr->columns* i) + n_name_col]);
                        if (attr1 && (strcmp(attr1, ep_data_bufr_col[j]) == 0))
                          {
                          FIfld_set_text(forms.part_operations_form_id,
                                         ATTRIBUTE_VALUE_MCF,form_row,1,
                                         ep_data_bufr_row[(ep_data_bufr->
                                         columns * 0) + k],FALSE);
                          MEMwrite_data(hold_data_bufr,
                                        ep_data_bufr_row[(ep_data_bufr->
                                        columns * 0) + k],1,i+1);
                          ++form_row;
                          found = 1;
                          break;
                          }
                        }
                       }/* for the for loop */
                    }
                  }
                 }
              }
           _pdm_debug("after comparing buffers", 0);

           if (found == 0)
              {
              _pdm_debug("entering case for found", 0);
              for (j = 0; j < hold_data_bufr->columns; ++j)
                 {
                 if (i < hold_attr_bufr->rows)
                  {
                  PDUfill_in_string(&attr1, 
                 hd_attr_bufr_row[(hold_attr_bufr->columns * i) + n_name_col]);
                  if (attr1 && (strcmp(attr1, hd_data_bufr_col[j]) == 0))
                    {
                    FIfld_set_text(forms.part_operations_form_id,
                                   ATTRIBUTE_VALUE_MCF,form_row,1,
                                   hd_data_bufr_row[(hold_data_bufr->
                                   columns * 0) + j],FALSE);
                    ++form_row;
                    break;
                    }
                  }
                 }
              } /* if condition for found */
           }
        }
     }

  _pdm_debug("EXITING HUGE LOOP", 0);

  /* Fill in acl name and workflow name */

  status = PDUget_col_number(hold_attr_bufr,"n_valueno",
                             hd_attr_bufr_col, &n_valueno_col);
  _pdm_status("PDUget_col_number",status);

  if (status != PDM_S_SUCCESS)
     {
     PDUmessage(status, 's');
     return (status);
     }

  for (i = 0; i < hold_attr_bufr->rows; ++i)
     {
     if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                n_name_col], "n_aclno") == 0)
        {
        acl_buffer_no = atoi(hd_attr_bufr_row[(hold_attr_bufr->columns *
                           i) + n_valueno_col]);
        break;
        }
     }

  status = PDUsetup_buffer_list(PDU_hold_bufr, 3, acl_buffer_no,
                                &hd_acl_bufr_row, &hd_acl_bufr_col,
                                &hd_acl_bufr_format, &hold_acl_bufr);
  _pdm_status("PDUsetup_buffer_list",status);

  if (status != PDM_S_SUCCESS)
     return(status);

  if (status == PDM_S_SUCCESS)
     {
     status = PDUget_col_number(hold_data_bufr,"n_aclno",
                                hd_data_bufr_col,
                                &n_aclno_col_for_hd_data);
     if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return (status);
        }

     status = PDUget_col_number(ep_data_bufr,"n_aclno",ep_data_bufr_col,
                                &n_aclno_col_for_ep_data);
     if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return (status);
        }

     status = PDUget_col_number(hold_acl_bufr,"n_aclno",hd_acl_bufr_col,
                                &n_aclno_col);
     if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return (status);
        }

     status = PDUget_col_number(hold_acl_bufr,"n_aclname",
                                hd_acl_bufr_col, &n_aclname_col);
     if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return (status);
        }

     status = PDUget_col_number(hold_acl_bufr,"n_workflowname",
                                hd_acl_bufr_col, &n_wf_col);
     if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return (status);
        }

     for (i = 0; i < hold_acl_bufr->rows; ++i)
        {
        if (strcmp(ep_data_bufr_row[(ep_data_bufr->columns * 0) +
                   n_aclno_col_for_ep_data],
                   hd_acl_bufr_row[(hold_acl_bufr->columns * i) +
                   n_aclno_col]) == 0)
           {
           FIfld_set_text(forms.part_operations_form_id,ACL_NAME_FLD
                          ,0,0, hd_acl_bufr_row[(hold_acl_bufr->columns
                          * i) + n_aclname_col], FALSE);
           FIfld_set_text(forms.part_operations_form_id,WORKFLOW_FLD,
                          0,0, hd_acl_bufr_row[(hold_acl_bufr->columns
                          * i) + n_wf_col], FALSE);

           /* Put default acl number in the data buffer */

           status = MEMwrite_data(hold_data_bufr,
                                  hd_acl_bufr_row[(hold_acl_bufr->columns * i) +
                                  n_aclno_col],1,n_aclno_col_for_hd_data + 1);

           found = 1;
           break;
           }
        }

     if (found == 0)
        {
        FIfld_set_text(forms.part_operations_form_id,ACL_NAME_FLD,0,
                       0, hd_acl_bufr_row[(hold_acl_bufr->columns * 0
                       ) + n_aclname_col], FALSE);
        FIfld_set_text(forms.part_operations_form_id,WORKFLOW_FLD,0,
                       0, hd_acl_bufr_row[(hold_acl_bufr->columns * 0
                       ) + n_wf_col], FALSE);

        /* Put default acl number in the data buffer */

        status = MEMwrite_data(hold_data_bufr,
                               hd_acl_bufr_row[(hold_acl_bufr->columns * 0) +
                               n_aclno_col],1,n_aclno_col_for_hd_data + 1);
        }
     }

     /* Fill in the storage area name */

    for (i = 0; i < hold_attr_bufr->rows; ++i)
       {
       if (strcmp(hd_attr_bufr_row[(hold_attr_bufr->columns * i) +
                  n_name_col], "n_cisano") == 0)
          {
          stg_buffer_no = atoi(hd_attr_bufr_row[(hold_attr_bufr->columns *
                              i) + n_valueno_col]);
          break;
          }
       }

    PDUsetup_buffer_list(PDU_hold_bufr, 3, stg_buffer_no,
                         &hd_stg_bufr_row, &hd_stg_bufr_col,
                         &hd_stg_bufr_format,&hold_stg_bufr);

    status = PDUget_col_number(ep_data_bufr,"n_cisano",ep_data_bufr_col,
                               &n_cisano_col_for_ep_data);
     if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return (status);
        }

    status = PDUget_col_number(hold_data_bufr,"n_cisano",hd_data_bufr_col,
                               &n_cisano_col_for_hd_data);
     if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return (status);
        }

    status = PDUget_col_number(hold_stg_bufr,"n_sano",hd_stg_bufr_col,
                               &n_sano_col);
     if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return (status);
        }

    status = PDUget_col_number(hold_stg_bufr,"n_saname",hd_stg_bufr_col,
                               &n_saname_col);
     if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return (status);
        }

    for (i = 0; i < hold_stg_bufr->rows; ++i)
       {
       if (strcmp(ep_data_bufr_row[(hold_data_bufr->columns * 0) +
                  n_cisano_col_for_ep_data],
                  hd_stg_bufr_row[(hold_stg_bufr->columns * i) +
                  n_sano_col]) == 0)
          {
          FIfld_set_text(forms.part_operations_form_id,STORAGE_AREA_FLD,
                         0,0, hd_stg_bufr_row[(hold_stg_bufr->columns *
                         i) + n_saname_col], FALSE);

          /* Put default storage area number in data buffer */

          status = MEMwrite_data(hold_data_bufr,
                                 hd_stg_bufr_row[(hold_stg_bufr->columns * i) +
                                 n_sano_col],1,n_cisano_col_for_hd_data + 1);

          found = 1;
          break;
          }
       }

    if (found == 0)
       {
       FIfld_set_text(forms.part_operations_form_id,STORAGE_AREA_FLD,0,
                      0, hd_stg_bufr_row[(hold_stg_bufr->columns * 0) +
                      n_saname_col], FALSE);

       /* Put default storage area number in data buffer */

       status = MEMwrite_data(hold_data_bufr,
                              hd_stg_bufr_row[(hold_stg_bufr->columns * 0) +
                              n_sano_col],1,n_cisano_col_for_hd_data + 1);
       }
   } 

if (similar_mode != TRUE)
   {
   /* Blank out the ATTRIBUTE_VALUE_MCF */

   /* Find maximum number of rows */

   FIfld_get_num_rows(forms.part_operations_form_id,
                      ATTRIBUTE_VALUE_MCF,&max_rows);

   PDUremove_data(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF,
                  max_rows,2);
   FIg_reset(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF);
   FIfld_set_active_row(forms.part_operations_form_id,ATTRIBUTE_VALUE_MCF,0,0);
   }

   /* Blank out the FILE_INFO_MCF */

   FIfld_get_text_length(forms.part_operations_form_id,EP_PARTTYPE_FLD,0,0,
                         &length);
   text = (char *) malloc (sizeof (char) * length + 1);
   memset(text, NULL, sizeof (char) * length + 1);
   FIfld_get_text(forms.part_operations_form_id,EP_PARTTYPE_FLD,0,0,length,
                  (unsigned char *)text, &select, &pos);
   PDUfill_in_string1(&ep_parttype, text);
   PDUfill_in_string1(&refresh->rev_parttype, text);

   if (new_mode == TRUE) 
      {
      FIfld_get_num_rows(PDU_form_id,FILE_INFO_MCF, &max_rows);
      PDUremove_data(PDU_form_id,FILE_INFO_MCF, max_rows,4);
      FIg_reset(forms.part_operations_form_id,FILE_INFO_MCF);
      FIg_display(forms.part_operations_form_id,FILE_INFO_GRP);
      FIg_display(forms.part_operations_form_id,NEW_FILE_TXT);
      }
   if (similar_mode == TRUE)
      {
      FIfld_get_num_rows(PDU_form_id,SIMILAR_MODE_MCF, &max_rows);
      PDUremove_data(PDU_form_id,SIMILAR_MODE_MCF, max_rows,5);

      if (np_parttype && (strcmp(np_parttype, "N") != 0) ||
                         (strcmp(np_parttype, "n") != 0))
        {
        FIg_reset(forms.part_operations_form_id,SIMILAR_MODE_MCF);
        FIg_display(forms.part_operations_form_id,SIMILAR_MODE_GRP);
        FIg_display(forms.part_operations_form_id,NEW_FILE_TXT);
        FIg_erase(forms.part_operations_form_id,SIMMODE_CHECKIN_TGL);

        FIfld_set_text(PDU_form_id,SIMILAR_MODE_MCF,0,0,"",FALSE);
        FIfld_set_text(PDU_form_id,SIMILAR_MODE_MCF,0,1,"",FALSE);
        FIfld_set_text(PDU_form_id,SIMILAR_MODE_MCF,0,2,"",FALSE);
        FIfld_set_text(PDU_form_id,SIMILAR_MODE_MCF,0,3,"",FALSE);
        FIfld_set_text(PDU_form_id,SIMILAR_MODE_MCF,0,4,"",FALSE);
        }
      }
   else if (((change_mode == TRUE) || (review_mode == TRUE)) &&
            ((ep_parttype == "G") || (ep_parttype == "g")))
      {
      FIfld_get_num_rows(PDU_form_id,FILE_INFO_MCF, &max_rows);
      PDUremove_data(PDU_form_id,FILE_INFO_MCF, max_rows,3);

      FIfld_set_text(PDU_form_id,EP_PARTNUM_FLD,0,0, "",FALSE);
      FIfld_set_text(PDU_form_id,EP_REV_FLD,0,0, "",FALSE);
      FIfld_set_text(PDU_form_id,EP_PARTTYPE_FLD,0,0, "",FALSE);
      FIfld_set_text(PDU_form_id,EP_DESC_FLD,0,0, "",FALSE);
      }

   /* Blank out following fields */
   if (similar_mode != TRUE)
      {
      FIfld_set_text(PDU_form_id,STORAGE_AREA_FLD,0,0, "",FALSE);
      FIfld_set_text(PDU_form_id,WORKFLOW_FLD,0,0,"", FALSE);
      FIfld_set_text(PDU_form_id,ACL_NAME_FLD,0,0,"", FALSE);
      }

   FIfld_set_text(PDU_form_id,STATE_NAME_FLD,0,0,"", FALSE);

   _pdm_debug("PDUsetup_buffer_list for attr_bufr",0);
   status = PDUsetup_buffer_list(PDU_copyof_ret_bufr,1, 0, &data1_row,
                                 &data1_col,&data1_format,&attr_bufr);
   if (status != PDM_S_SUCCESS)
      return(status);

   _pdm_debug("PDUsetup_buffer_list for data_bufr",0);
   status = PDUsetup_buffer_list(PDU_copyof_ret_bufr,2, 0, &data2_row,
                                 &data2_col,&data2_format,&data_bufr);
   if (status != PDM_S_SUCCESS)
      return(status);

   if (PDMdebug_on)
   MEMprint_buffers("PDU_copyof_ret_bufr", PDU_copyof_ret_bufr, PDU_DEBUG_FILE);

   if (similar_mode != TRUE)
      {
      /* Fill in the default Atrributes and Values */

      PDU_attr_label = ATTRIBUTE_VALUE_MCF;

      status = MEMreset_buffer_no(PDU_copyof_ret_bufr, 3);
      _pdm_status("MEMreset_buffer_no", status);

      status = MEMsplit_copy_buffer(PDU_copyof_ret_bufr, &PDU_list_bufr, 1);
      _pdm_status("MEMsplit_copy_buffer_no", status);

      status = PDUfill_attribute_list(attr_bufr, data_bufr, PDU_list_bufr);
      _pdm_status("PDUfill_attribute_list", status);
      }

   status = PDUget_col_number(attr_bufr,"n_name",data1_col,&n_name_col);

   if (status != PDM_S_SUCCESS)
     {
     PDUmessage(status, 's');
     return (status);
     }

   status = PDUget_col_number(attr_bufr,"n_synonym",data1_col,
                              &n_syn_col);
   if (status != PDM_S_SUCCESS)
     {
     PDUmessage(status, 's');
     return (status);
     }

   if (new_mode || similar_mode)
     {
     if (attr_bufr)
       {
       _pdm_debug("setting file information for review/similar/new mode", 0);
       status = PDUcheck_file_info_privileges(NULL, attr_bufr,
                           &filedesc_update, &filedesc_read, &filedesc_write,
                           &cofile_update, &cofile_read, &cofile_write,
                           &cifile_update, &cifile_read, &cifile_write,
                           &filetype_update, &filetype_read, &filetype_write);
       _pdm_status("PDUcheck_file_info_privileges", status);
       if (status != PDM_S_SUCCESS)
         _pdm_debug("failed to get file info permissions", 0);

       _pdm_debug("resetting attr_bufr", 0);
       status = MEMbuild_array(attr_bufr);
       _pdm_status("MEMbuild_array", status);
       if (status != MEM_S_SUCCESS)
         return(PDM_E_BUILD_BUFFER_ARRAY);

       PDUsetup_buffer(attr_bufr, ROW, &data1_row);
       PDUsetup_buffer(attr_bufr, COL, &data1_col);

       if (new_mode && (!cofile_write))
         {
         FIfld_set_mode(PDU_form_id,FILE_INFO_MCF, 0, FI_REVIEW);
         FIfld_set_mode(PDU_form_id,FILE_INFO_MCF, 1, FI_REVIEW);
         FIfld_set_mode(PDU_form_id,FILE_INFO_MCF, 2, FI_REVIEW);
         FIfld_set_mode(PDU_form_id,FILE_INFO_MCF, 3, FI_REVIEW);
         msg = (char *) PDUtranslate_message(PDM_E_NO_WRITE_LOCAL_FILE);
         FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
         PDU_disable_localfn_col = TRUE;
         PDU_disable_storagefn_col = TRUE;
         PDU_disable_filedesc_col = TRUE;
         PDU_disable_filetype_col = TRUE;
         }
       if (new_mode && (!filedesc_write))
         {
         FIfld_set_mode(PDU_form_id,FILE_INFO_MCF, 0, FI_REVIEW);
         PDU_disable_filedesc_col = TRUE;
         }
       if (new_mode && (!cifile_write))
         {
         FIfld_set_mode(PDU_form_id,FILE_INFO_MCF, 2, FI_REVIEW);
         PDU_disable_storagefn_col = TRUE;
         }
       if (new_mode && (!filetype_write))
         {
         FIfld_set_mode(PDU_form_id,FILE_INFO_MCF, 3, FI_REVIEW);
         PDU_disable_filetype_col = TRUE;
         }

       if (similar_mode)
         {
         if (!cofile_write)
           {
           FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 0, FI_REVIEW);
           FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 2, FI_REVIEW);
           FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 3, FI_REVIEW);
           FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 4, FI_REVIEW);
           msg = (char *) PDUtranslate_message(PDM_E_NO_WRITE_LOCAL_FILE);
           FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
           FIg_disable(PDU_form_id, SIMMODE_COPY_TGL);
           PDU_disable_localfn_col = TRUE;
           PDU_disable_storagefn_col = TRUE;
           PDU_disable_filedesc_col = TRUE;
           PDU_disable_filetype_col = TRUE;
           }
         if (!filedesc_write)
           {
           FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 0, FI_REVIEW);
           PDU_disable_filedesc_col = TRUE;
           }
         if (!cifile_write)
           {
           _pdm_debug("disabling storage filename column", 0);
           FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 3, FI_REVIEW);
           PDU_disable_storagefn_col = TRUE;
           }
         if (!filetype_write)
           {
           FIfld_set_mode(PDU_form_id,SIMILAR_MODE_MCF, 4, FI_REVIEW);
           PDU_disable_filetype_col = TRUE;
           }
         }
       }

      /* Fill in acl name and workflow name */
      status = PDUget_col_number(attr_bufr,"n_valueno",data1_col,
                                 &n_valueno_col);
      _pdm_status("PDUget_col_number",status);

      if (status != PDM_S_SUCCESS)
         {
         PDUmessage(status, 's');
         return (status);
         }

      for (i = 0; i < attr_bufr->rows; ++i)
         {
         if (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
            "n_aclno") == 0)
            {
            acl_buffer_no = atoi(data1_row[(attr_bufr->columns * i) +
                                 n_valueno_col]);
            break;
            }
         }

      _pdm_debug("PDUsetup_buffer_list for the acl_bufr",0);
      status = PDUsetup_buffer_list(PDU_copyof_ret_bufr, 3, acl_buffer_no,
                                    &data3_row, &data3_col,&data3_format,
                                    &acl_bufr);
      _pdm_status("PDUsetup_buffer_list",status);

      if (status != PDM_S_SUCCESS)
         return(status);

      if (status == PDM_S_SUCCESS)
         {
         status = PDUget_col_number(acl_bufr,"n_aclno",data3_col,
                                    &n_aclno_col);
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           return (status);
           }

         status = PDUget_col_number(acl_bufr,"n_aclname",data3_col,
                                    &n_aclname_col);
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           return (status);
           }

         status = PDUget_col_number(acl_bufr,"n_workflowname",data3_col,
                                    &n_wf_col);
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           return (status);
           }

         status = PDUget_col_number(data_bufr,"n_aclno",data2_col,
                                    &n_aclno_col_for_data);
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           return (status);
           }


         attr_row = PDUfind_attr_in_buffer(attr_bufr, PDU_NFM_ACL_NO);
         _pdm_debug("attr_row = %d", (char *)attr_row);
         /* find defaulted aclno's row in acl_bufr */

         _pdm_debug("checking buffer for acl number", 0);
         if ((strcmp(data2_row[attr_row], "") == 0) ||
              (((data2_row[attr_row])[0]) == '\0'))
           {
           _pdm_debug("acl number has not been defaulted in buffer", 0);
           _pdm_debug("defaulting acl number to 6", 0);

           _pdm_debug("looking for aclno=6 in buffer", 0);
           acl_row = -1;
           for (i = 0; i < acl_bufr->rows; ++i)
              {
              if (strcmp(data3_row[(acl_bufr->columns * i) + n_aclno_col],
                  "6") == 0)
                {
                acl_row = i;
                _pdm_debug("default row found", 0);
                break;
                }
              }
           if (acl_row == -1)
             {
             _pdm_debug("SEVERE ERROR:  default acl not found", 0);
             acl_row = 0;
             }
           }
         else
           {
           for (i = 0; i < acl_bufr->rows; i ++)
              {
              if (strcmp(data3_row[(acl_bufr->columns * i) + n_aclno_col],

                  data2_row[attr_row]) == 0)
                 {
                 acl_row = i;
                 break;
                 }
              }
           }

         /* Write acl name and workflow name to the part form */

         FIfld_set_text(forms.part_operations_form_id,ACL_NAME_FLD,0,0,
                       data3_row[(acl_bufr->columns * acl_row) + n_aclname_col],
                       FALSE);
         FIfld_set_text(forms.part_operations_form_id,WORKFLOW_FLD,0,0,
                       data3_row[(acl_bufr->columns * acl_row) + n_wf_col],
                       FALSE);

         /*Put the default acl number for the new part in the data buffer*/

         status = MEMwrite_data(data_bufr,
                         data3_row[(acl_bufr->columns * acl_row) + n_aclno_col],
                         1,n_aclno_col_for_data + 1);
         }

         /* Fill in the storage area name */

         for (i = 0; i < attr_bufr->rows; ++i)
            {
            if (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                "n_cisano") == 0)
               {
               stg_buffer_no = atoi(data1_row[(attr_bufr->columns * i) +
                                    n_valueno_col]);
               break;
               }
            }

         _pdm_debug("PDUsetup_buffer_list for the stg_buffer",0);
         PDUsetup_buffer_list(PDU_copyof_ret_bufr,3, stg_buffer_no, &data4_row,
                              &data4_col,&data4_format,&stg_bufr);

         status = PDUget_col_number(stg_bufr,"n_sano",data4_col,
                                    &n_sano_col);
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           return (status);
           }

         status = PDUget_col_number(stg_bufr,"n_saname",data4_col,
                                    &n_saname_col);
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           return (status);
           }

         status = PDUget_col_number(data_bufr,"n_cisano",data2_col,
                                    &n_cisano_col_for_data);
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           return (status);
           }


         /* Find defaulted storage area in the stg_bufr */

         for (i = 0; i < stg_bufr->rows; i ++)
            if (strcmp(data4_row[(stg_bufr->columns * i) + n_sano_col],
                data2_row[n_cisano_col_for_data]) == 0)
               {
               cisano_row = i;
               break;
               }

         /* Write storage area name to part form */
         FIfld_set_text(forms.part_operations_form_id,STORAGE_AREA_FLD,0,0,
                        data4_row[(stg_bufr->columns * cisano_row) +
                        n_saname_col], FALSE);

         /* Put default storage area number into the data buffer */

         status = MEMwrite_data(data_bufr,
                       data4_row[(stg_bufr->columns * cisano_row) + n_sano_col],
                       1,n_cisano_col_for_data + 1);

         }
      else if ((change_mode == TRUE) || (review_mode == TRUE))
         {
         /* Fill in acl name and workflow name */
         status = PDUget_col_number(attr_bufr,"n_valueno",data1_col,
                                    &n_valueno_col);
         _pdm_status("PDUget_col_number",status);

         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           return (status);
           }

         for (i = 0; i < attr_bufr->rows; ++i)
            {
            if (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                "n_aclno") == 0)
               {
               acl_buffer_no = atoi(data1_row[(attr_bufr->columns * i) +
                                  n_valueno_col]);
               break;
               }
            }

         status = PDUsetup_buffer_list(PDU_copyof_ret_bufr, 3, acl_buffer_no,
                                       &data3_row, &data3_col,&data3_format,
                                       &acl_bufr);
         _pdm_status("PDUsetup_buffer_list",status);

         if (status != PDM_S_SUCCESS)
            return(status);

         if (status == PDM_S_SUCCESS)
            {
            status = PDUget_col_number(data_bufr,"n_aclno",data2_col,
                                       &n_aclno_col_for_data);
            if (status != PDM_S_SUCCESS)
              {
              PDUmessage(status, 's');
              return (status);
              }

            status = PDUget_col_number(acl_bufr,"n_aclno",data3_col,
                                       &n_aclno_col);
            if (status != PDM_S_SUCCESS)
              {
              PDUmessage(status, 's');
              return (status);
              }

            status = PDUget_col_number(acl_bufr,"n_workflowname",data3_col,
                                       &n_wf_col);
            if (status != PDM_S_SUCCESS)
              {
              PDUmessage(status, 's');
              return (status);
              }

            status = PDUget_col_number(acl_bufr,"n_aclname",data3_col,
                                       &n_aclname_col);
            if (status != PDM_S_SUCCESS)
              {
              PDUmessage(status, 's');
              return (status);
              }

            for (i = 0; i < acl_bufr->rows; ++i)
               {
               if (strcmp(data2_row[(data_bufr->columns * 0) +
                          n_aclno_col_for_data],
                          data3_row[(acl_bufr->columns * i) + n_aclno_col])
                          == 0)
                  {
                  FIfld_set_text(forms.part_operations_form_id,ACL_NAME_FLD
                                 ,0,0, data3_row[(acl_bufr->columns * i) +
                                 n_aclname_col], FALSE);
                  FIfld_set_text(forms.part_operations_form_id,WORKFLOW_FLD,
                                 0,0, data3_row[(acl_bufr->columns * i) +
                                 n_wf_col], FALSE);
                  }
               }
            }

         /* Fill in the storage area name */

         for (i = 0; i < attr_bufr->rows; ++i)
            {
            if (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
                "n_cisano") == 0)
               {
               stg_buffer_no = atoi(data1_row[(attr_bufr->columns * i) +
                                    n_valueno_col]);
               break;
               }
            }

         PDUsetup_buffer_list(PDU_copyof_ret_bufr,3, stg_buffer_no, &data4_row,
                              &data4_col,&data4_format,&stg_bufr);

         status = PDUget_col_number(data_bufr,"n_cisano",data2_col,
                                    &n_cisano_col_for_data);
            if (status != PDM_S_SUCCESS)
              {
              PDUmessage(status, 's');
              return (status);
              }

         status = PDUget_col_number(stg_bufr,"n_sano",data4_col,
                                    &n_sano_col);
            if (status != PDM_S_SUCCESS)
              {
              PDUmessage(status, 's');
              return (status);
              }

         status = PDUget_col_number(stg_bufr,"n_saname",data4_col,
                                    &n_saname_col);
            if (status != PDM_S_SUCCESS)
              {
              PDUmessage(status, 's');
              return (status);
              }

         for (i = 0; i < stg_bufr->rows; ++i)
            {
            if (strcmp(data2_row[(data_bufr->columns * 0) +
                       n_cisano_col_for_data],
                       data4_row[(stg_bufr->columns * i) + n_sano_col])
                       == 0)
               {
               FIfld_set_text(forms.part_operations_form_id,ACL_NAME_FLD
                              ,0,0, data4_row[(stg_bufr->columns * i) +
                              n_saname_col], FALSE);
               }
            }
         }

    if ((new_mode == TRUE) || (similar_mode == TRUE))
      {
      if ((np_catalog != NULL) && (strcmp(np_catalog,"") != 0))
        {
        status = PDUcheck_for_np_defaults(data_bufr);
        _pdm_status("PDUcheck_for_np_defaults", status);
        if (status != PDM_S_SUCCESS)
          _pdm_debug("error checking for defaults for np_catalog", 0);

        status = MEMbuild_array(data_bufr);
        _pdm_status("MEMbuild_array", status);
        if (status != MEM_S_SUCCESS)
          {
          PDUmessage(PDM_E_BUILD_BUFFER_ARRAY, 's');
          return(PDM_E_BUILD_BUFFER_ARRAY);
          }

        PDUsetup_buffer(data_bufr, ROW, &data2_row);
        PDUsetup_buffer(data_bufr, COL, &data2_col);

        _pdm_debug("checking for pdmlibraries catalog", 0);
        if (strcmp(np_catalog, "pdmlibraries") == 0)
          {
          PDUfill_in_string1(&np_parttype, "M");
          PDUfill_in_string1(&refresh->new_parttype,np_parttype);
          /*FIg_disable(forms.part_operations_form_id,NP_PARTTYPE_BTN);*/
          }

        _pdm_debug("checking for pdmseedfiles catalog", 0);
        if (strcmp(np_catalog, "pdmseedfiles") == 0)
          {
          PDUfill_in_string1(&np_parttype, "G");
          PDUfill_in_string1(&refresh->new_parttype,np_parttype);
          }
        }

      status = PDUcheck_parttype_privileges(attr_bufr, &update, &read, &write);
      _pdm_status("PDUcheck_parttype_privileges", status);
      if (status != PDM_S_SUCCESS)
        _pdm_debug("error checking parttype privs for np_catalog", 0);
   
      if (!write)
        {
        _pdm_debug("parttype is NO WRITE", 0);
        FIg_disable(forms.part_operations_form_id, NP_PARTTYPE_FLD);
        FIg_disable(forms.part_operations_form_id, NP_PARTTYPE_BTN);
      
        if (similar_mode && 
           (ep_catalog) && (strcmp(ep_catalog, np_catalog) == 0))
          {
          _pdm_debug("disabling EP fields for similar mode", 0);
          FIg_disable(forms.part_operations_form_id, EP_PARTTYPE_FLD);
          FIg_disable(forms.part_operations_form_id, EP_PARTTYPE_BTN);
          }
        }
      }

      /* Fill in State name */

      status = PDUget_col_number(data_bufr,"n_cocomment",data2_col,
                                 &n_state_col);

      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return (status);
        }

      for (i = 0; i < attr_bufr->rows; ++i)
         {
         if (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
             data2_col[n_state_col]) == 0)
            {
            FIfld_set_text(forms.part_operations_form_id, STATE_NAME_FLD,0,
                           0, data2_row[(data_bufr->columns * 0) +
                           n_state_col],FALSE);
            break;
            }
         }

      /* Change part type back to previous */

      status = PDUget_col_number(data_bufr,"p_parttype",data2_col,
                                 &p_parttype_col);

      if (status != PDM_S_SUCCESS)
        {
        PDUmessage(status, 's');
        return (status);
        }

      _pdm_debug("checking for reset parttype", 0);
      for (i = 0; i < attr_bufr->rows; ++i)
         {
         if (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
             data2_col[p_parttype_col]) == 0)
            {
            PDUfill_in_string(&tmp_parttype,
                data2_row[(data_bufr->columns * 0) + p_parttype_col]);

            if ((new_mode || similar_mode) && (tmp_parttype &&
                (strcmp(tmp_parttype, "") != 0)))
               {
               FIfld_set_text(forms.part_operations_form_id,
                              NP_PARTTYPE_FLD,0, 0,tmp_parttype, FALSE);

               PDUfill_in_string1(&np_parttype, tmp_parttype);
               PDUfill_in_string(&refresh->new_parttype, tmp_parttype);
               PDUfill_in_string(&refresh->rev_parttype, tmp_parttype);
               PDUfill_in_string(&ep_parttype, tmp_parttype);
               }
            else if ((change_mode == TRUE) || (review_mode == TRUE))
               {
               FIfld_set_text(forms.part_operations_form_id, EP_PARTTYPE_FLD,0,
                              0, tmp_parttype, FALSE);

               PDUfill_in_string1(&ep_parttype,tmp_parttype);
               PDUfill_in_string(&refresh->rev_parttype,tmp_parttype);
               }
            _pdm_debug("setting parttype = <%s>", tmp_parttype);
            break;
            }
         }

     if ((new_mode == TRUE) || (similar_mode == TRUE))
        {
        FIfld_get_text_length(forms.part_operations_form_id,NP_PARTTYPE_FLD,0,0,
                              &length);
        text = (char *) malloc (sizeof (char) * length + 1);
        memset(text, NULL, sizeof (char) * length + 1);
        FIfld_get_text(forms.part_operations_form_id,NP_PARTTYPE_FLD,0,0,length,
                  (unsigned char *)text, &select, &pos);
        PDUfill_in_string1(&np_parttype,text);
      
        if ((strcmp(np_parttype,"N") != 0) && 
           (strcmp(np_parttype,"n") != 0))
           {
           if (new_mode == TRUE)
              FIg_display(PDU_form_id,FILE_INFO_GRP);
           else if (similar_mode == TRUE)
              {
              FIg_display(PDU_form_id,SIMILAR_MODE_GRP);

              if (PDU_simmode_copy == FALSE)
                 FIg_set_state_off(PDU_form_id,SIMMODE_COPY_TGL);
              else
                 {
                 FIg_display(PDU_form_id,SIMMODE_COPY_TGL);
                 FIg_set_state_on(PDU_form_id,SIMMODE_COPY_TGL);
                 if (ep_catalog && en_itemname && ep_rev &&
                    (strlen(ep_catalog)) && (strlen(en_itemname)) && 
                    (strlen(ep_rev)))
                   FIg_enable(PDU_form_id,SIMMODE_COPY_TGL);
                 else
                   FIg_disable(PDU_form_id,SIMMODE_COPY_TGL);
                 }
 
              if (PDU_simmode_checkin == FALSE)
                 FIg_erase(PDU_form_id,SIMMODE_CHECKIN_TGL);
              else
                 {
                 FIg_display(PDU_form_id,SIMMODE_CHECKIN_TGL);
                 FIg_set_state_on(PDU_form_id,SIMMODE_CHECKIN_TGL);
                 }
              }
 
           FIg_erase(forms.part_operations_form_id, EXISTING_FILE_TXT);
           FIg_display(forms.part_operations_form_id, NEW_FILE_TXT);
           } 
        else if ((strcmp(np_parttype,"N") == 0) ||
                 (strcmp(np_parttype,"n") == 0))
           {
           if (new_mode == TRUE)
              FIg_erase(forms.part_operations_form_id,FILE_INFO_GRP);
           else if (similar_mode == TRUE)
              FIg_erase(forms.part_operations_form_id,SIMILAR_MODE_GRP);
           FIg_erase(forms.part_operations_form_id, NEW_FILE_TXT);
           }
        }
     else if ((change_mode == TRUE) || (review_mode == TRUE))
        {
        FIfld_get_text_length(forms.part_operations_form_id,EP_PARTTYPE_FLD,0,0,
                              &length);
        text = (char *) malloc (sizeof (char) * length + 1);
        memset(text, NULL, sizeof (char) * length + 1);
        FIfld_get_text(forms.part_operations_form_id,EP_PARTTYPE_FLD,0,0,length,
                  (unsigned char *)text, &select, &pos);
        PDUfill_in_string1(&ep_parttype,text);

        if ((strcmp(ep_parttype,"N") != 0) &&
           (strcmp(ep_parttype,"n") != 0))
           {
           if (change_mode == TRUE)
              FIg_display(PDU_form_id,CHANGE_MODE_GRP);
           else if (review_mode == TRUE)
              FIg_display(PDU_form_id,FILE_INFO_GRP);

           FIg_erase(forms.part_operations_form_id, NEW_FILE_TXT);
           }
        else if ((strcmp(np_parttype,"N") == 0) ||
                (strcmp(np_parttype,"n") == 0))
           {
           if (change_mode == TRUE)
              FIg_erase(forms.part_operations_form_id,CHANGE_MODE_GRP);
           else if (review_mode == TRUE)
              FIg_erase(forms.part_operations_form_id,FILE_INFO_GRP);
           }
        }

/* MEMsplit_copy the attr_bufr, data_bufr, stg_bufr, and acl_bufr to global
   buffers to allow the users to enter information for the new part before
   adding the part. */

   if (PDU_attr_bufr)
      {
      MEMclose(&PDU_attr_bufr);
      PDU_attr_bufr = NULL;
      }
   if (PDU_data_bufr)
      {
      MEMclose(&PDU_data_bufr);
      PDU_data_bufr = NULL;
      }
   if (PDU_acl_bufr)
      {
      MEMclose(&PDU_acl_bufr);
      PDU_acl_bufr = NULL;
      }
   if (PDU_stg_bufr)
      {
      MEMclose(&PDU_stg_bufr);
      PDU_stg_bufr = NULL;
      }

   if (similar_mode == TRUE)
      {
      status = MEMsplit_copy_buffer(hold_attr_bufr, &PDU_attr_bufr,0);
      _pdm_status("MEMsplit_copy_buffer",status);

      if (status != MEM_S_SUCCESS)
         {
         PDUmessage(status,'s');
         return(status);
         }

      status = MEMsplit_copy_buffer(hold_data_bufr, &PDU_data_bufr,0);
      _pdm_status("MEMsplit_copy_buffer",status);

      if (status != MEM_S_SUCCESS)
         {
         PDUmessage(status,'s');
         return(status);
         }

      status = MEMsplit_copy_buffer(hold_acl_bufr, &PDU_acl_bufr,0);
      _pdm_status("MEMsplit_copy_buffer",status);

      if (status != MEM_S_SUCCESS)
         {
         PDUmessage(status,'s');
         return(status);
         }

      status = MEMsplit_copy_buffer(hold_stg_bufr, &PDU_stg_bufr,0);
      _pdm_status("MEMsplit_copy_buffer",status);

      if (status != MEM_S_SUCCESS)
         {
         PDUmessage(status,'s');
         return(status);
         }
      }

   if (similar_mode != TRUE)
      {
      status = MEMsplit_copy_buffer(attr_bufr, &PDU_attr_bufr,0);
      _pdm_status("MEMsplit_copy_buffer",status);

      if (status != MEM_S_SUCCESS)
         {
         PDUmessage(status,'s');
         return(status);
         }

      status = MEMsplit_copy_buffer(data_bufr, &PDU_data_bufr,0);
      _pdm_status("MEMsplit_copy_buffer",status);

      if (status != MEM_S_SUCCESS)
         {
         PDUmessage(status,'s');
         return(status);
         }

      status = MEMsplit_copy_buffer(acl_bufr, &PDU_acl_bufr,0);
      _pdm_status("MEMsplit_copy_buffer",status);

      if (status != MEM_S_SUCCESS)
         {
         PDUmessage(status,'s');
         return(status);
         }

      status = MEMsplit_copy_buffer(stg_bufr, &PDU_stg_bufr,0);
      _pdm_status("MEMsplit_copy_buffer",status);

      if (status != MEM_S_SUCCESS)
         {
         PDUmessage(status,'s');
         return(status);
         }
      }

   if (status != MEM_S_SUCCESS)
      return(status);

   if (status == MEM_S_SUCCESS)
      status = PDM_S_SUCCESS;

   if (PDU_func_buffer != NULL)
      {
      PDU_func_bufr_exists = TRUE;
      _pdm_debug("Put command on queue to call get_atr_val ppl",PDU_DEBUG_FILE);

      PDUmessage(PDC_M_GET_ATTR_VALUES,'c');

      responses[0] = EX_CMD_KEY;
      strings[0] = "PDGtAtrVal";

      status = PDUprepare_queue (responses, strings, 1);
      _pdm_status("PDUprepare_queue",status);
      }
return (status);
}

/* This function will make an exact copy of the columns and format of the
   buffer entered. */

int PDUcopy_buffer_format(bufr1,bufr2)

MEMptr bufr1;
MEMptr *bufr2;
{

int i=0;
int status;
char **format, **column;

    status = MEMbuild_array(bufr1);

    if (status != MEM_S_SUCCESS)
       {
       MEMclose(&bufr1);
       MEMclose(bufr2);
       return(PDM_E_BUILD_ARRAY);
       }

    format = (char **) bufr1->format_ptr;
    column = (char **) bufr1->column_ptr;

    MEMopen(bufr2,1024);

    for (i=0; i<bufr1->columns; i++)
        {
        status = MEMwrite_format(*bufr2,column[i],format[i]);

        if (status != MEM_S_SUCCESS)
           {
           MEMclose(bufr2);
           MEMclose(&bufr1);
           return(status);
           }
        }
        if (status == MEM_S_SUCCESS)
           MEMwrite(*bufr2,"\1\1\1\1\1\1\1");

        if (status == MEM_S_SUCCESS)
           status = PDM_S_SUCCESS;
     
return (status);
}

int PDUcheck_file_info_privileges(file_bufr, attr_bufr,
                             filedesc_update, filedesc_read, filedesc_write,
                             cofile_update, cofile_read, cofile_write,
                             cifile_update, cifile_read, cifile_write,
                             filetype_update, filetype_read, filetype_write)
  MEMptr  file_bufr;
  MEMptr  attr_bufr;
  short *filedesc_update;
  short *filedesc_read;
  short *filedesc_write;
  short *cofile_update;
  short *cofile_read;
  short *cofile_write;
  short *cifile_update;
  short *cifile_read;
  short *cifile_write;
  short *filetype_update;
  short *filetype_read;
  short *filetype_write;
{
  int   status = PDM_S_SUCCESS;
  int   i = 0;
  int   attr_row = 0;
  int   read_col = 0;
  int   write_col = 0;
  int   update_col = 0;
  int   n_name_col = 0;
  char  *read = NULL_STRING;
  char  *write = NULL_STRING;
  char  *update = NULL_STRING;
  char  **file_col;
  char  **data_row;
  short filetype_found = FALSE;

  _pdm_debug("in the function PDUcheck_file_info_privileges", 0);

  if (file_bufr)
    {
    status = MEMbuild_array(file_bufr);
    _pdm_status("MEMbuild_array", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);
  
    PDUsetup_buffer(file_bufr, COL, &file_col);
    }

  status = MEMbuild_array(attr_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  PDUsetup_buffer(attr_bufr, ROW, &data_row);

  status = PDUget_buffer_col(attr_bufr, "n_update", &update_col);
  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  status = PDUget_buffer_col(attr_bufr, "n_read", &read_col);
  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  status = PDUget_buffer_col(attr_bufr, "n_write", &write_col);
  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

if (file_bufr)
  {
  filetype_found = FALSE;
  for (i = 0; i < file_bufr->columns; i++)
     {
     if (strcmp(file_col[i],"p_filedesc") == 0)
       {
       _pdm_debug("checking for p_filedesc",0);
       attr_row = -1;
       attr_row = PDUfind_attr_in_buffer(attr_bufr, "p_filedesc");
       if (attr_row != -1)
         {
         PDUfill_in_string(&update,
                       data_row[(attr_bufr->columns * attr_row)+update_col]);
         _pdm_debug("update = <%s>", update);
         if (strcmp(update, "N") == 0)
           *filedesc_update = FALSE;
         else
           *filedesc_update = TRUE;

         PDUfill_in_string(&read,
                       data_row[(attr_bufr->columns * attr_row)+read_col]);
         _pdm_debug("read = <%s>", read);
         if (strcmp(read, "N") == 0)
           *filedesc_read = FALSE;
         else
           *filedesc_read = TRUE;

         PDUfill_in_string(&write,
                       data_row[(attr_bufr->columns * attr_row)+write_col]);
         _pdm_debug("write = <%s>", write);
         if (strcmp(write, "N") == 0)
           *filedesc_write = FALSE;
         else
           *filedesc_write = TRUE;
         }
       else
         {
         _pdm_debug("attribute p_filedesc not found in attr_bufr", 0);
         if (new_mode || similar_mode)
           *filedesc_write = FALSE;
         if (change_mode)
           *filedesc_update = FALSE;
         if (review_mode)
           *filedesc_read = FALSE;
         }
       }

     if (strcmp(file_col[i],"n_cofilename") == 0)
       {
       _pdm_debug("checking for n_cofilename",0);
       attr_row = -1;
       attr_row = PDUfind_attr_in_buffer(attr_bufr, "n_cofilename");
       if (attr_row != -1)
         {
         PDUfill_in_string(&update,
                       data_row[(attr_bufr->columns * attr_row)+update_col]);
         _pdm_debug("update = <%s>", update);
         if (strcmp(update, "N") == 0)
           *cofile_update = FALSE;
         else
           *cofile_update = TRUE;

         PDUfill_in_string(&read,
                       data_row[(attr_bufr->columns * attr_row)+read_col]);
         _pdm_debug("read = <%s>", read);
         if (strcmp(read, "N") == 0)
           *cofile_read = FALSE;
         else
           *cofile_read = TRUE;

         PDUfill_in_string(&write,
                       data_row[(attr_bufr->columns * attr_row)+write_col]);
         _pdm_debug("write = <%s>", write);
         if (strcmp(write, "N") == 0)
           *cofile_write = FALSE;
         else
           *cofile_write = TRUE;
         }
       else
         {
         _pdm_debug("attribute n_cofilename not found in attr_bufr", 0);
         if (new_mode || similar_mode)
           *cofile_write = FALSE;
         if (change_mode)
           *cofile_update = FALSE;
         if (review_mode)
           *cofile_read = FALSE;
         }
       }

     if (strcmp(file_col[i],"n_cifilename") == 0)
       {
       _pdm_debug("checking for n_cifilename",0);
       attr_row = -1;
       attr_row = PDUfind_attr_in_buffer(attr_bufr, "n_cifilename");
       if (attr_row != -1)
         {
         PDUfill_in_string(&update,
                       data_row[(attr_bufr->columns * attr_row)+update_col]);
         _pdm_debug("update = <%s>", update);
         if (strcmp(update, "N") == 0)
           *cifile_update = FALSE;
         else
           *cifile_update = TRUE;

         PDUfill_in_string(&read,
                       data_row[(attr_bufr->columns * attr_row)+read_col]);
         _pdm_debug("read = <%s>", read);
         if (strcmp(read, "N") == 0)
           *cifile_read = FALSE;
         else
           *cifile_read = TRUE;

         PDUfill_in_string(&write,
                       data_row[(attr_bufr->columns * attr_row)+write_col]);
         _pdm_debug("write = <%s>", write);
         if (strcmp(write, "N") == 0)
           *cifile_write = FALSE;
         else
           *cifile_write = TRUE;
         }
       else
         {
         _pdm_debug("attribute n_cifilename not found in attr_bufr", 0);
         if (new_mode || similar_mode)
           *cifile_write = FALSE;
         if (change_mode)
           *cifile_update = FALSE;
         if (review_mode)
           *cifile_read = FALSE;
         }
       }

     if (strcmp(file_col[i],"n_filetype") == 0)
       {
       filetype_found = TRUE;
       _pdm_debug("checking for n_filetype",0);
       attr_row = -1;
       attr_row = PDUfind_attr_in_buffer(attr_bufr, "n_filetype");
       if (attr_row != -1)
         {
         PDUfill_in_string(&update,
                       data_row[(attr_bufr->columns * attr_row)+update_col]);
         _pdm_debug("update = <%s>", update);
         if (strcmp(update, "N") == 0)
           *filetype_update = FALSE;
         else
           *filetype_update = TRUE;

         PDUfill_in_string(&read,
                       data_row[(attr_bufr->columns * attr_row)+read_col]);
         _pdm_debug("read = <%s>", read);
         if (strcmp(read, "N") == 0)
           *filetype_read = FALSE;
         else
           *filetype_read = TRUE;

         PDUfill_in_string(&write,
                       data_row[(attr_bufr->columns * attr_row)+write_col]);
         _pdm_debug("write = <%s>", write);
         if (strcmp(write, "N") == 0)
           *filetype_write = FALSE;
         else
           *filetype_write = TRUE;
         }
       else
         {
         _pdm_debug("attribute n_filetype not found in attr_bufr", 0);
         if (new_mode || similar_mode)
           *filetype_write = FALSE;
         if (change_mode)
           *filetype_update = FALSE;
         if (review_mode)
           *filetype_read = FALSE;
         }
       }
     }
  if (!filetype_found)
    {
    _pdm_debug("attribute n_filetype not found in attr_bufr", 0);
    if (new_mode || similar_mode)
      *filetype_write = FALSE;
    if (change_mode)
      *filetype_update = FALSE;
    if (review_mode)
      *filetype_read = FALSE;
    }
  }
else
  {
  status = PDUget_buffer_col(attr_bufr, "n_name", &n_name_col);
  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }
 
  filetype_found = FALSE;

  for (i = 0; i < attr_bufr->rows; i++)
     {
     if ((strcmp(data_row[(attr_bufr->columns * i) + n_name_col],
          "p_filedesc") == 0) ||
         (strcmp(data_row[(attr_bufr->columns * i) + n_name_col],
          "n_cofilename") == 0) ||
         (strcmp(data_row[(attr_bufr->columns * i) + n_name_col],
          "n_cifilename") == 0) ||
         (strcmp(data_row[(attr_bufr->columns * i) + n_name_col],
          "n_filetype") == 0))
        {
        if (strcmp(data_row[(attr_bufr->columns * i) + n_name_col],
            "p_filedesc") == 0)
          {
          _pdm_debug("checking for p_filedesc",0);
          attr_row = -1;
          attr_row = PDUfind_attr_in_buffer(attr_bufr, "p_filedesc");
          if (attr_row != -1)
            {
            PDUfill_in_string(&update,
                          data_row[(attr_bufr->columns * attr_row)+update_col]);
            _pdm_debug("update = <%s>", update);
            if (strcmp(update, "N") == 0)
              *filedesc_update = FALSE;
            else
              *filedesc_update = TRUE;
   
            PDUfill_in_string(&read,
                          data_row[(attr_bufr->columns * attr_row)+read_col]);
            _pdm_debug("read = <%s>", read);
            if (strcmp(read, "N") == 0)
              *filedesc_read = FALSE;
            else
              *filedesc_read = TRUE;
   
            PDUfill_in_string(&write,
                          data_row[(attr_bufr->columns * attr_row)+write_col]);
            _pdm_debug("write = <%s>", write);
            if (strcmp(write, "N") == 0)
              *filedesc_write = FALSE;
            else
              *filedesc_write = TRUE;
            }
          else
            {
            _pdm_debug("attribute p_filedesc not found in attr_bufr", 0);
            if (new_mode || similar_mode)
              *filedesc_write = FALSE;
            if (change_mode)
              *filedesc_update = FALSE;
            if (review_mode)
              *filedesc_read = FALSE;
            }
          }

        if (strcmp(data_row[(attr_bufr->columns * i) + n_name_col],
            "n_cofilename") == 0)
          {
          _pdm_debug("checking for n_cofilename",0);
          attr_row = -1;
          attr_row = PDUfind_attr_in_buffer(attr_bufr, "n_cofilename");
          if (attr_row != -1)
            {
            PDUfill_in_string(&update,
                          data_row[(attr_bufr->columns * attr_row)+update_col]);
            _pdm_debug("update = <%s>", update);
            if (strcmp(update, "N") == 0)
              *cofile_update = FALSE;
            else
              *cofile_update = TRUE;
   
            PDUfill_in_string(&read,
                          data_row[(attr_bufr->columns * attr_row)+read_col]);
            _pdm_debug("read = <%s>", read);
            if (strcmp(read, "N") == 0)
              *cofile_read = FALSE;
            else
              *cofile_read = TRUE;
   
            PDUfill_in_string(&write,
                          data_row[(attr_bufr->columns * attr_row)+write_col]);
            _pdm_debug("write = <%s>", write);
            if (strcmp(write, "N") == 0)
              *cofile_write = FALSE;
            else
              *cofile_write = TRUE;
            }
          else
            {
            _pdm_debug("attribute n_cofilename not found in attr_bufr", 0);
            if (new_mode || similar_mode)
              *cofile_write = FALSE;
            if (change_mode)
              *cofile_update = FALSE;
            if (review_mode)
              *cofile_read = FALSE;
            }
          }

        if (strcmp(data_row[(attr_bufr->columns * i) + n_name_col],
            "n_cifilename") == 0)
          {
          _pdm_debug("checking for n_cifilename",0);
          attr_row = -1;
          attr_row = PDUfind_attr_in_buffer(attr_bufr, "n_cifilename");
          if (attr_row != -1)
            {
            PDUfill_in_string(&update,
                          data_row[(attr_bufr->columns * attr_row)+update_col]);
            _pdm_debug("update = <%s>", update);
            if (strcmp(update, "N") == 0)
              *cifile_update = FALSE;
            else
              *cifile_update = TRUE;
   
            PDUfill_in_string(&read,
                          data_row[(attr_bufr->columns * attr_row)+read_col]);
            _pdm_debug("read = <%s>", read);
            if (strcmp(read, "N") == 0)
              *cifile_read = FALSE;
            else
              *cifile_read = TRUE;
   
            PDUfill_in_string(&write,
                          data_row[(attr_bufr->columns * attr_row)+write_col]);
            _pdm_debug("write = <%s>", write);
            if (strcmp(write, "N") == 0)
              *cifile_write = FALSE;
            else
              *cifile_write = TRUE;
            }
          else
            {
            _pdm_debug("attribute n_cifilename not found in attr_bufr", 0);
            if (new_mode || similar_mode)
              *cifile_write = FALSE;
            if (change_mode)
              *cifile_update = FALSE;
            if (review_mode)
              *cifile_read = FALSE;
            }
          }

        if (strcmp(data_row[(attr_bufr->columns * i) + n_name_col],
            "n_filetype") == 0)
          {
          filetype_found = TRUE;
          _pdm_debug("checking for n_filetype",0);
          attr_row = -1;
          attr_row = PDUfind_attr_in_buffer(attr_bufr, "n_filetype");
          if (attr_row != -1)
            {
            PDUfill_in_string(&update,
                          data_row[(attr_bufr->columns * attr_row)+update_col]);
            _pdm_debug("update = <%s>", update);
            if (strcmp(update, "N") == 0)
              *filetype_update = FALSE;
            else
              *filetype_update = TRUE;
   
            PDUfill_in_string(&read,
                          data_row[(attr_bufr->columns * attr_row)+read_col]);
            _pdm_debug("read = <%s>", read);
            if (strcmp(read, "N") == 0)
              *filetype_read = FALSE;
            else
              *filetype_read = TRUE;
   
            PDUfill_in_string(&write,
                          data_row[(attr_bufr->columns * attr_row)+write_col]);
            _pdm_debug("write = <%s>", write);
            if (strcmp(write, "N") == 0)
              *filetype_write = FALSE;
            else
              *filetype_write = TRUE;
            }
          else
            {
            _pdm_debug("attribute n_filetype not found in attr_bufr", 0);
            if (new_mode || similar_mode)
              *filetype_write = FALSE;
            if (change_mode)
              *filetype_update = FALSE;
            if (review_mode)
              *filetype_read = FALSE;
            }
          }
        }
     }

  if (!filetype_found)
    {
    _pdm_debug("attribute n_filetype not found in attr_bufr", 0);
    if (new_mode || similar_mode || change_mode)
      *filetype_write = FALSE;
    if (change_mode)
      *filetype_update = FALSE;
    if (review_mode)
      *filetype_read = FALSE;
    }
  }

  return(status);
}
