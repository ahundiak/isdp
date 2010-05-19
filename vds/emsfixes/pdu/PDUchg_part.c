/* $Id: PDUchg_part.c,v 1.4 2002/01/07 18:32:06 jdsauby Exp $ */
/* -------------------------------------------------------------------
 * I/VDS
 *
 * File: vds/emsfixes/pdu/filemgr/PDUchg_part.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *       $Log: PDUchg_part.c,v $
 *       Revision 1.4  2002/01/07 18:32:06  jdsauby
 *       JTSMP CR 5865
 *
 *       Revision 1.3  2001/10/29 17:16:03  jdsauby
 *       JTS CR 5536 - jds
 *
 *
 *
 * History:
 *       MM/DD/YY        AUTHOR          DESCRIPTION
 *       10/18/01	 js		 Creation for AIM
 * -------------------------------------------------------------------------*/

#include        <stdio.h>
#include        <FI.h>
#include        <PDUstr.h>
#include        <PDUextdef.h>
#include        <PDUerror.h>
#include        <PDMtypes.h>
#include        <MEMerrordef.h>
#include        <NFMerrordef.h>
#include        "part_gadgets.h"
#include        "PDUforms.h"
#include        "PDUfile_def.h"
#include        <PDUproto.h>
//#include        <PDMproto.h>
#include        <PDMmessage.h>

#define  LIST_MCF     11

/* Extern */

extern int          PDM_debug_on;
extern int          file_rows;
extern int          PDU_validate_access;
extern int          change_mode;
extern int          review_mode;
extern int          add_files_flag;
extern short        PDU_files_deleted;
extern struct       PDUforms   forms;
extern struct       PDUrefresh    *refresh;
extern char        *ep_catalog;
extern char        *en_itemname;
extern char        *ep_rev;
extern char        *ep_parttype;
extern char        *ep_desc;
extern char        *nn_itemname;
extern char        *np_rev;
extern char        *np_desc;
extern MEMptr       PDU_attr_bufr;
extern MEMptr       PDU_data_bufr;
extern MEMptr       PDU_acl_bufr;
extern MEMptr       PDU_stg_bufr;
extern MEMptr       PDU_file_data_bufr;
extern MEMptr       PDU_add_data_bufr;
extern MEMptr       PDU_parts_list_bufr;
extern char      ** PDU_attr_row;
extern Form         PDU_form_id;
extern int          PDMdebug_on;
extern short        PDU_disable_localfn_col;
extern short        PDU_disable_storagefn_col;
extern short        PDU_disable_filetype_col;
extern short        PDU_disable_filedesc_col;
extern short        PDU_filedesc_newfiles_disable;
extern short        PDU_localfn_newfiles_disable;
extern short        PDU_storagefn_newfiles_disable;
extern short        PDU_filetype_newfiles_disable;
extern int PDU_checkout_type;
extern int PDU_mcf_list;
extern int *PDU_parts_index;
extern int PDU_selected_rows;
extern int PDU_command;

extern long VDqryExecute(); // JTS MP CR 5536
extern long VDpdmInitPtHull(); // JTSMP CR 5865

/* This function facilitate the changing of the part by adding new files or
   changing existing files. */

int PDUchange_part()

{
  static char   * text = NULL_STRING;
  int       i;
  int       max_rows = 0;
  int       n_cofilenm_col;
  int       n_cifilenm_col;
  int       n_filetype_col;
  int       n_cisaname_col;
  int       p_filedesc_col;
  int       add_bufr_row = 1;
  int       status = PDM_S_SUCCESS;
  int       length;
  void      PDMcancel_modify();
  int       select_flag;
  int       pos = 0;
  int       max_row_length = 0;
  int       row_length = 0;
  int  *    fn;
  char *    max_row_text = NULL;
  char *    cisaname_text = NULL;
  char *    string = NULL;
  char *    cofile_text = NULL;
  char *    cifile_text = NULL;
  char *    filetype_text = NULL;
  char *    filedesc_text = NULL;
  char *    msg = NULL;
  char **   add1_data_col;
  long      status1 = NFM_S_SUCCESS;
  Form      form;
  MEMptr    add_data_bufr = NULL;
  MEMptr    file_data_bufr = NULL;

  // SAUBY, JTSMP CR 5865
  int hull_cfg_on;

   _pdm_debug("ENTER FUNCTION: PDUchange_part",0);

   form = forms.part_operations_form_id;

   if ((PDU_disable_localfn_col == TRUE) &&
       (PDU_disable_storagefn_col == TRUE) &&
       (PDU_disable_filetype_col == TRUE) &&
       (PDU_disable_filedesc_col == TRUE)) 
      {
      _pdm_debug("File info pallette is read-only; no files changed", 0);
      return(0);
      }

   _pdm_debug("CALL: PDUget_part_field_info",0);
   status = PDUget_part_field_info();
   _pdm_status("PDMget_part_field_info", status);

   if (status != PDM_S_SUCCESS)
      return(status);

   status = PDUcheck_for_required_attributes();
   _pdm_status("PDUcheck_for_required_attributes",status);
 
   if (status != PDM_S_SUCCESS)
      {
      PDUenable_gadgets_after_change_part();
      return(status);
      }

   _pdm_debug("CALL: NFMRtic_it",0);
   status1 = NFMRtic_it(PDU_data_bufr);
   _pdm_status("NFMRtic_it",status1);

   if (status1 != NFM_S_SUCCESS)
      return(status);

   PDUmessage(PDS_M_PROCESS_FILE, 's');

   /* This section is used to write files added to the NEW_FILES_MCF into
      the PDU_add_data_bufr so that PDM can add them to the list
      of files associated with the part. */
   if (add_files_flag == TRUE)
      {
      _pdm_debug("ENTER: Writing files to PDU_add_data_bufr",0);
      add_files_flag = FALSE;

      status = MEMbuild_array(PDU_add_data_bufr);
      _pdm_status("MEMbuild_array",status);

      if (status != MEM_S_SUCCESS)
        {
        _pdm_debug("MEMbuild_array failed", 0);
        return(status);
        }

      add1_data_col = (char **) PDU_add_data_bufr->column_ptr;

      if (PDMdebug_on)
         MEMprint_buffer("PDU_ADD_DATA_BUFR INSIDE PDUchange_part",
                         PDU_add_data_bufr,PDU_DEBUG_FILE);

      string = (char *) malloc (sizeof (char) * PDU_add_data_bufr->row_size);
      memset(string, NULL, (sizeof (char) * PDU_add_data_bufr->row_size));

      for (i = 0; i < PDU_add_data_bufr->columns; ++i)
         string[i] = '\1';

      FIfld_get_num_rows(form,NEW_FILES_MCF, &max_rows);

      if (max_rows == 0)
         {
         _pdm_debug("There are no files to be added",0);
         return(0);
         }

      _pdm_debug("checking for extra rows in mcfs", 0);
      for (i = max_rows - 1; i > -1; --i)
         {
         FIfld_get_text_length(form, NEW_FILES_MCF, i, 1, &max_row_length);
         max_row_text = (char *)malloc(sizeof(char)*max_row_length+1);
         memset(max_row_text,NULL,sizeof (char) * max_row_length + 1);
         FIfld_get_text (form, NEW_FILES_MCF, i, 1,
                 max_row_length+1, (unsigned char *)max_row_text, 
                 &select_flag, &pos );
         if ((max_row_text == NULL) || (strcmp(max_row_text,"") == 0))
            {
            max_rows = max_rows - 1;
            _pdm_debug("empty row in MCF; decrementing max_rows", 0);
            _pdm_debug("max_rows = %d", max_rows);
            }
         }

      if (PDU_filedesc_newfiles_disable == FALSE)
         {
         status = PDUget_col_number(PDU_add_data_bufr,"p_filedesc",
                                    add1_data_col, &p_filedesc_col);
         _pdm_status("PDUget_col_number",status);

         if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status,'s');
            return (status);
            }
         }

      if (PDU_localfn_newfiles_disable == FALSE)
         {
         status = PDUget_col_number(PDU_add_data_bufr,"n_cofilename",
                                    add1_data_col, &n_cofilenm_col);
         _pdm_status("PDUget_col_number",status);

         if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status,'s');
            return (status);
            }
         }

      if (PDU_storagefn_newfiles_disable == FALSE)
         {
         status = PDUget_col_number(PDU_add_data_bufr,"n_cifilename",
                                    add1_data_col, &n_cifilenm_col);
         _pdm_status("PDUget_col_number",status);

         if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status,'s');
            return (status);
            }
         }

      if (PDU_filetype_newfiles_disable == FALSE)
         {
         status = PDUget_col_number(PDU_add_data_bufr,"n_filetype",
                                    add1_data_col, &n_filetype_col);
         _pdm_status("PDUget_col_number",status);

         if (status != PDM_S_SUCCESS)
            {
            PDUmessage(status,'s');
            return (status);
            }
         }

      status = PDUget_col_number(PDU_add_data_bufr, "n_cisaname",
                                 add1_data_col, &n_cisaname_col);
      _pdm_status("PDUget_col_number",status);

      if (status != PDM_S_SUCCESS)
         {
         PDUmessage(status,'s');
         return (status);
         }

      FIfld_get_text_length(PDU_form_id, STORAGE_AREA_FLD, 0, 0, &length);
      text = (char *) malloc (sizeof (char) * length + 1);
      memset(text, NULL, sizeof (char) * length + 1);
      FIfld_get_text (PDU_form_id, STORAGE_AREA_FLD, 0, 0, length + 1,
                      (unsigned char *)text, &select_flag, &pos );
      _pdm_debug("STORAGE_AREA_FLD = <%s>",text);
      if ((text) && (strcmp(text, "") != 0))
        PDUfill_in_string(&cisaname_text,text);

      for (i = 0; i < max_rows; ++i)
         {
         status = MEMwrite(PDU_add_data_bufr,string);
         _pdm_status("MEMwrite",status);

         if (status != MEM_S_SUCCESS)
            return(status);

         status = MEMbuild_array(PDU_add_data_bufr);
         _pdm_status("MEMbuild_array",status);

         if (status != MEM_S_SUCCESS)
           {
           _pdm_debug("MEMbuild_array failed", 0);
           return(status);
           }

         if (PDU_localfn_newfiles_disable == FALSE)
            {
            FIfld_get_text_length(form, NEW_FILES_MCF, i,1,&row_length);
            cofile_text = (char *) malloc (sizeof (char) * row_length + 1);
            memset(cofile_text, NULL,sizeof (char) * row_length + 1);
            FIfld_get_text (form, NEW_FILES_MCF, i, 1,row_length+1, 
                         (unsigned char *)cofile_text, &select_flag, &pos );

            if ((cofile_text == NULL) || (strcmp(cofile_text,"") == 0))
               {
               msg = (char *) PDUtranslate_message(PDM_E_ENTER_FILENAME);
               FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
               return(PDM_E_ENTER_FILENAME);
               }
            else
               {
               _pdm_debug("Writing the Local Filename to the PDU_add_data_bufr",0);
               status = MEMwrite_data(PDU_add_data_bufr,cofile_text,
                                      add_bufr_row + 1, n_cofilenm_col + 1);
               _pdm_status("MEMwrite_data",status);

               if (status != MEM_S_SUCCESS)
                  {
                  _pdm_debug("MEMwrite_data Failed", 0);
                  return(status);
                  }
               }            
            }
           
         if (PDU_storagefn_newfiles_disable == FALSE)
            {
            FIfld_get_text_length(form, NEW_FILES_MCF, i,2,&row_length);
            cifile_text = (char *) malloc (sizeof (char) * row_length + 1);
            memset(cifile_text, NULL,sizeof (char) * row_length + 1);
            FIfld_get_text (form, NEW_FILES_MCF, i, 2,row_length+1, 
                           (unsigned char *)cifile_text, &select_flag, &pos );

            if ((cifile_text != NULL) && (strcmp(cifile_text,"") != NULL)) 
               {
               status = MEMbuild_array(PDU_add_data_bufr);
               _pdm_status("MEMbuild_array",status);

               if (status != MEM_S_SUCCESS)
                 {
                 _pdm_debug("MEMbuild_array failed", 0);
                 return(status);
                 }

               _pdm_debug("Writing the Storage Filename to the PDU_add_data_bufr",0); 
               status = MEMwrite_data(PDU_add_data_bufr,cifile_text,
                                      add_bufr_row + 1, n_cifilenm_col + 1);
               _pdm_status("MEMwrite_data",status);

               if (status != MEM_S_SUCCESS)
                  {
                  _pdm_debug("MEMwrite_data Failed", 0);
                  return(status);
                  }
               }
            }                   

         if (PDU_filetype_newfiles_disable == FALSE)
            {
            FIfld_get_text_length(form, NEW_FILES_MCF, i,3,&row_length);
            filetype_text = (char *) malloc (sizeof (char) * row_length + 1);
            memset(filetype_text,NULL,sizeof(char)*row_length + 1);
            FIfld_get_text (form, NEW_FILES_MCF, i, 3,row_length+1, 
                         (unsigned char *)filetype_text, &select_flag, &pos );

            if ((filetype_text != NULL) && (strcmp(filetype_text,"") != 0))
               {
               status = MEMbuild_array(PDU_add_data_bufr);
               _pdm_status("MEMbuild_array",status);

               if (status != MEM_S_SUCCESS)
                 {
                 _pdm_debug("MEMbuild_array failed", 0);
                 return(status);
                 }

              _pdm_debug("Writing the File Type to the PDU_add_data_bufr",0);
               status = MEMwrite_data(PDU_add_data_bufr,filetype_text,
                                      add_bufr_row + 1, n_filetype_col + 1);
               _pdm_status("MEMwrite_data",status);

               if (status != MEM_S_SUCCESS)
                  {
                  _pdm_debug("MEMwrite_data Failed", 0);
                  return(status);
                  }
               }
            }

         if (PDU_filedesc_newfiles_disable == FALSE)
            {
            FIfld_get_text_length(form, NEW_FILES_MCF, i,0,&row_length);
            filedesc_text = (char *) malloc (sizeof (char) * row_length + 1);
            memset(filedesc_text,NULL,sizeof(char)*row_length + 1);
            FIfld_get_text (form, NEW_FILES_MCF, i, 0,row_length+1,
                          (unsigned char *)filedesc_text, &select_flag, &pos );

            if ((filedesc_text != NULL) && (strcmp(filedesc_text,"") != 0))
               {
               status = MEMbuild_array(PDU_add_data_bufr);
               _pdm_status("MEMbuild_array",status);

               if (status != MEM_S_SUCCESS)
                 {
                 _pdm_debug("MEMbuild_array failed", 0);
                 return(status);
                 }

               _pdm_debug("Writing the File Description to the PDU_add_data_bufr",0);
               status = MEMwrite_data(PDU_add_data_bufr,filedesc_text,
                                      add_bufr_row + 1, p_filedesc_col + 1);
               _pdm_status("MEMwrite_data",status);

               if (status != MEM_S_SUCCESS)
                  {
                  _pdm_debug("MEMwrite_data Failed", 0);
                  return(status);
                  }
               }
            }

         status = MEMbuild_array(PDU_add_data_bufr);
         _pdm_status("MEMbuild_array",status);

         if (status != MEM_S_SUCCESS)
           {
           _pdm_debug("MEMbuild_array failed", 0);
           return(status);
           }

         status = MEMwrite_data(PDU_add_data_bufr,cisaname_text,
                                add_bufr_row + 1, n_cisaname_col + 1);
         _pdm_status("MEMwrite_data",status);

         if (status != MEM_S_SUCCESS)
            {
            _pdm_debug("MEMwrite_data Failed", 0);
            return(status);
            }

         add_bufr_row = add_bufr_row + 1;
         }

      if ((PDU_add_data_bufr) && (PDMdebug_on))
         MEMprint_buffer("PDU_add_data_bufr before change part",
                         PDU_add_data_bufr,PDU_DEBUG_FILE);
      }

   if (PDU_add_data_bufr == NULL)
      {
      _pdm_debug("closing PDU_add_data_bufr", 0);
      status = MEMclose(&PDU_add_data_bufr);
      _pdm_status("MEMclose",status);

      if (status != MEM_S_SUCCESS)
         return(status);
   
      status = MEMopen(&PDU_add_data_bufr,512);
      _pdm_status("MEMopen",status);

      if (status != MEM_S_SUCCESS)
         return(status);
      }

   if (PDU_file_data_bufr == NULL)
      {
      _pdm_debug("closing PDU_file_data_bufr", 0);
      status = MEMclose(&PDU_file_data_bufr);
      _pdm_status("MEMclose",status);

      if (status != MEM_S_SUCCESS)
         return(status);

      status = MEMopen(&PDU_file_data_bufr,512);
      _pdm_status("MEMopen",status);

      if (status != MEM_S_SUCCESS)
         return(status);
      }

   /* TR 139416225 - copy PDU_add_data_bufr to another buffer, because NFM
      may be closing this buffer in the case of failure  - MJG 1/27/94 */

      MEMsplit_copy_buffer(PDU_add_data_bufr, &add_data_bufr, 0);
      MEMsplit_copy_buffer(PDU_file_data_bufr, &file_data_bufr, 0);

   PDUdisable_gadgets_for_change_part();

   status = PDMrmodify_part (ep_catalog,en_itemname,
                             ep_rev, 0, PDU_attr_bufr, PDU_data_bufr, 
                             file_data_bufr, add_data_bufr);
   _pdm_status("PDMmodify_part", status);

   if ( status != PDM_S_SUCCESS )
      {
      PDUmessage(status,'s');

      status1 = PDMcancel_modify_part(refresh->rev_catalog, refresh->rev_partid,
                                     refresh->rev_revision, PDU_attr_bufr, 
                                     PDU_data_bufr);
      _pdm_status("PDMcancel_modify_part",status1);
      status1 = PDM_S_SUCCESS;

      fn = (int *)PDMcancel_modify;
      exitdel(fn);

      if (PDU_attr_bufr) {
        MEMclose(&PDU_attr_bufr); PDU_attr_bufr = NULL; }
      if (PDU_data_bufr) {
        MEMclose(&PDU_data_bufr); PDU_data_bufr = NULL; }
      if (PDU_acl_bufr) {
        MEMclose(&PDU_acl_bufr); PDU_acl_bufr = NULL; }
      if (PDU_stg_bufr) {
        MEMclose(&PDU_stg_bufr); PDU_stg_bufr = NULL; }
      if (PDU_file_data_bufr) {
        MEMclose(&PDU_file_data_bufr); PDU_file_data_bufr = NULL; }
      if (PDU_add_data_bufr) {
        MEMclose(&PDU_add_data_bufr);   PDU_add_data_bufr = NULL; }

      status1 = status;
      }

   /* ----------------------------------------------
    * Added for JTSMP CR 5865, SAUBY
    * **/
   hull_cfg_on = 0;
   FIg_get_state(form,87,&hull_cfg_on);
   if (hull_cfg_on) VDpdmInitPtHull();
   // end of CR5865


   PDUenable_gadgets_after_change_part();

   status = PDUupdate_part_form_change_mode();
   _pdm_status("PDUupdate_part_form_change_mode", status);

   if (status == MEM_S_SUCCESS)
     status = PDM_S_SUCCESS;

   if (status == PDM_S_SUCCESS)
      {
      fn = (int *)PDMcancel_modify;
      exitdel(fn);
      }

   if (status1 != PDM_S_SUCCESS)
     status = status1;

   PDUmessage(status,'s');

return(status);
}

/* This function facilitates the removing of file(s) associted with the part
   being reviewed. */

int PDUdelete_files()

{

  int       i;
  int       n_cofilenm_col = 0;
  int       n_cifilenm_col = 0;
  int       n_filetype_col = 0;
  int       p_filedesc_col = 0;
  int       n_status_col = 0;
  int       num_rows = 0;
  int       row_selected = 0;
  int       status = PDM_S_SUCCESS;
  char **   file_data_col;
  char **   data_col;
  char **   data_row;
  char      *msg = NULL;
  Form      form;

   _pdm_debug("ENTER FUNCTION: PDUdelete_files",0);

   form = forms.part_operations_form_id;

   /* when this flag is set, the parts listing area on the main form will
      be cleared out when returning from the part form */
   PDU_files_deleted = TRUE;

   _pdm_debug("ep_catalog = <%s>", ep_catalog);
   _pdm_debug("en_itemname = <%s>", en_itemname);
   _pdm_debug("ep_revision = <%s>", ep_rev);
   _pdm_debug("ep_parttype = <%s>", ep_parttype);

   if (strcmp(ep_catalog, "") == 0)
     _pdm_debug("ep_catalog field is EMPTY", 0);
   if (strcmp(en_itemname, "") == 0)
     _pdm_debug("en_itemname field is EMPTY", 0);
   if (strcmp(ep_rev, "") == 0)
     _pdm_debug("ep_rev field is EMPTY", 0);
   if (strcmp(ep_parttype, "") == 0)
     _pdm_debug("ep_parttype field is EMPTY", 0);

   if ((change_mode == TRUE) &&
       (strcmp(ep_catalog,"") != 0) &&
       (strcmp(en_itemname,"") != 0) &&
       (strcmp(ep_rev,"") != 0) &&
       (strcmp(ep_parttype,"") != 0))
      {
      if (PDU_data_bufr)
         {
         status = MEMbuild_array(PDU_data_bufr);
         _pdm_status("MEMbuild_array",status);

         if (status != MEM_S_SUCCESS)
            {
            status = PDM_E_BUILD_BUFFER_ARRAY;
            msg = (char *) PDUtranslate_message(PDM_E_BUILD_BUFFER_ARRAY);
            FIg_set_text(form, FI_MSG_FIELD,msg);
            return(status);
            }

         data_col = (char **) PDU_data_bufr->column_ptr;
         data_row = (char **) PDU_data_bufr->data_ptr;
         }
      else
         {
         _pdm_debug("PDU_data_bufr is NULL", 0);
         PDUmessage(status, 's');
         return(PDM_E_NULL_BUFFER);
         }

      if (PDU_file_data_bufr)
         {
         status = MEMbuild_array(PDU_file_data_bufr);
         _pdm_status("MEMbuild_array",status);
 
         if (status != MEM_S_SUCCESS)
            {
            status = PDM_E_BUILD_BUFFER_ARRAY;
            msg = (char *) PDUtranslate_message(PDM_E_BUILD_BUFFER_ARRAY);
            FIg_set_text(form, FI_MSG_FIELD,msg);
            return(status);
            }

         file_data_col = (char **) PDU_file_data_bufr->column_ptr;
         }
      else
         {
         _pdm_debug("PDU_file_data_bufr is NULL", 0);
         PDUmessage(status, 's');
         return(PDM_E_NULL_BUFFER);
         }

      if (PDU_disable_localfn_col == FALSE)
         {
         status = PDUget_col_number(PDU_file_data_bufr,"n_cofilename",
                           file_data_col, &n_cofilenm_col);
         _pdm_status("PDUget_col_number", status);

         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           return(status);
           }
         }

      if (PDU_disable_storagefn_col == FALSE)
         {
         status = PDUget_col_number(PDU_file_data_bufr,"n_cifilename",
                           file_data_col, &n_cifilenm_col);
         _pdm_status("PDUget_col_number", status);

         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           return(status);
           }
         }

      if (PDU_disable_filetype_col == FALSE)
         {
         status = PDUget_col_number(PDU_file_data_bufr,"n_filetype",
                           file_data_col, &n_filetype_col);
         _pdm_status("PDUget_col_number", status);

         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           return(status);
           }
         }

      if (PDU_disable_filedesc_col == FALSE)
         {
         status = PDUget_col_number(PDU_file_data_bufr,"p_filedesc",
                                    file_data_col, &p_filedesc_col);
         _pdm_status("PDUget_col_number", status);

         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           return(status);
           }
         }

      status = PDUget_col_number(PDU_file_data_bufr,"n_status",file_data_col,
                        &n_status_col);
      _pdm_status("PDUget_col_number", status);

      if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           return(status);
           }

      FIfld_get_num_rows(form,EXISTING_FILES_MCF,&num_rows);
 
      for (i=0; i < num_rows; ++i)
          {
          FIfld_set_active_row(form,EXISTING_FILES_MCF, i,0);
          FImcf_get_select(form,EXISTING_FILES_MCF,i, &row_selected);
    
          if (row_selected == TRUE)
             {
             status=MEMwrite_data(PDU_file_data_bufr,"Y",i + 1, n_status_col+1);
             _pdm_status("MEMwrite_data",status);
 
             if (status != MEM_S_SUCCESS)
               {
               _pdm_debug("MEMwrite_data Failed", 0);
               return(status);
               }
             }
          }

      if (PDMdebug_on)
         MEMprint_buffer("PDU_file_data_bufr",PDU_file_data_bufr,
                         PDU_DEBUG_FILE);

      if (status == MEM_S_SUCCESS)
         status = PDM_S_SUCCESS;

      if (status != PDM_S_SUCCESS)
         return(status);

      status = PDMdelete_files (refresh->rev_catalog,
                                refresh->rev_partid,
                                refresh->rev_revision,
                                PDU_file_data_bufr);
      }

      if ( status != PDM_S_SUCCESS )
         {
         if (PDU_acl_bufr)
           {
           MEMclose(&PDU_acl_bufr); PDU_acl_bufr = NULL;
           }
         if (PDU_stg_bufr)
           {
           MEMclose(&PDU_stg_bufr); PDU_stg_bufr = NULL;
           }
         if (PDU_file_data_bufr)
           {
           MEMclose(&PDU_file_data_bufr); PDU_file_data_bufr = NULL;
           }
         if (PDU_add_data_bufr)
            {
            MEMclose(&PDU_add_data_bufr); 
            PDU_add_data_bufr = NULL;
            }
         PDUmessage(status,'s');
         return(status);
         }
      else
         {
         PDUupdate_part_form_change_mode();

         FIg_set_state_off(form, DELETE_FILES_TGL);
         FIg_disable(form, DELETE_FILES_TGL);
         FIg_disable(PDU_form_id, DELETE_FILES_BTN);

         /* enable all other commands */
         FIg_enable(forms.part_operations_form_id, ADD_TO_PROJECT_BTN);
         FIg_enable(forms.part_operations_form_id, DELETE_BTN);
         FIg_enable(forms.part_operations_form_id, WHERE_USED_BTN);
         FIg_enable(forms.part_operations_form_id, CHANGE_BTN);
         FIg_enable(forms.part_operations_form_id, FLAG_CANCELFLAG_BTN);
         FIg_enable(forms.part_operations_form_id, MOVE_STATE_BTN);
         FIg_enable(forms.part_operations_form_id, SEARCH_BTN);

         PDUmessage(status,'s');
         }
return(status);
}


/* This function facilitates the removal of a part from the catalog */

int PDUdelete_part()

{
  void            PDMcancel_modify();
  void            PDUreset_part_form_after_delete_part();
  int             status = PDM_S_SUCCESS;
  int           * fn;
  Form            form;

   _pdm_debug("ENTER FUNCTION: PDUdelete_part",0);

   form = forms.part_operations_form_id;

   status = PDMcheck_delete_part(ep_catalog,en_itemname,ep_rev);
   _pdm_status("PDMcheck_delete_part",status);

   if (status == PDM_I_PART_IN_ASS)
      {
      status = PDM_E_PART_OCCURS_IN_ASSEMBLY;
      PDUreset_part_form_after_delete_part(PDM_E_PART_OCCURS_IN_ASSEMBLY);
      PDUmessage(status,'s');
      return (status);
      }

   if (status != PDM_S_SUCCESS)
      {
      PDUreset_part_form_after_delete_part(status);
      PDUmessage(status, 's');
      return(status);
      }

   _pdm_debug("checking to see if part is checked in", 0);
   status = PDMrcheck_part_status(ep_catalog, en_itemname, ep_rev);
   _pdm_status("PDMrcheck_part_status", status);
   if (status == PDM_I_COPIED_TO_LOCAL_BY_YOU) 
     {
     status = PDM_E_FILES_CANNOT_BE_LOCAL;
     PDUreset_part_form_after_delete_part(PDM_E_FILES_CANNOT_BE_LOCAL);
     PDUmessage(status,'s');
     return (status);
     }
   else if ((status != PDM_I_NEVER_CHECKED_IN) &&
            (status != PDM_I_CHECKED_IN))
     {
     PDUreset_part_form_after_delete_part(PDM_I_PART_CHECKIN);
     PDUmessage(PDM_I_PART_CHECKIN, 's');
     return(PDM_I_PART_CHECKIN);
     }

   status = PDMcancel_modify_part(ep_catalog,en_itemname,ep_rev,
                                  PDU_attr_bufr, PDU_data_bufr);
   _pdm_status("PDMcancel_modify_part",status);

   if (status == PDM_S_SUCCESS)
      {
      fn = (int *)PDMcancel_modify;
      exitdel(fn);
      }
   else
      {
      PDUmessage(status,'s');
      return(status);
      }

   status = PDMrdelete_part(ep_catalog,en_itemname,ep_rev);
   _pdm_status("PDMdelete_element",status);

   // Need to Clean out the posted to database entries for this part as well
   // JTS MP CR 5536
   VDqryExecute(NULL,NULL,ep_catalog,en_itemname,ep_rev,"Delete Part");

   PDUreset_part_form_after_delete_part(status);

  PDUmessage(status,'s');

  return(status);
}


int PDUmulti_delete_part()

{
  int             status = PDM_S_SUCCESS;
  int             sts = PDM_S_SUCCESS;
  Form            form;
  char            *status_msg = NULL;

   _pdm_debug("ENTER FUNCTION: PDUmulti_delete_part",0);

   form = forms.local_files_form_id;

   _pdm_debug("validating access", 0);
   status = PDUmessage_trans(PDU_command, 'v');
   _pdm_debug("PDUmessage_trans", status);

   if (status != PDM_S_SUCCESS)
     {
     PDUmessage(status, 's');
     return(status);
     }

  if ((refresh->rev_parttype) && ((strcmp(refresh->rev_parttype, "P") == 0) ||
      (strcmp(refresh->rev_parttype, "p") == 0)))
     {
     status = PDM_E_DELETE_PARAMETRIC_PART;
     PDUmessage(status,'s');
     return (status);
     }

   status = PDMcheck_delete_part(refresh->rev_catalog,refresh->rev_partid,
                                 refresh->rev_revision);
   _pdm_status("PDMcheck_delete_part",status);

   if (status == PDM_I_PART_IN_ASS) 
     {
     status = PDM_E_PART_OCCURS_IN_ASSEMBLY;
     PDUmessage(status,'s');
     return (status);
     }
   else if (status != PDM_S_SUCCESS)
     return(status);

   _pdm_debug("checking to see if part is checked in", 0);
   status = PDMrcheck_part_status(refresh->rev_catalog, refresh->rev_partid, 
                                  refresh->rev_revision);
   _pdm_status("PDMrcheck_part_status", status);
   if (status == PDM_I_COPIED_TO_LOCAL_BY_YOU) 
     {
     status = PDM_E_FILES_CANNOT_BE_LOCAL;
     PDUmessage(status,'s');
     return (status);
     }
   else if (status == SQL_E_UNKNOWN_RELATION)
     {
     status = PDM_E_DELETE_PARAMETRIC_PART;
     PDUmessage(status,'s');
     return (status);
     }
   else if ((status != PDM_I_NEVER_CHECKED_IN) &&
            (status != PDM_I_CHECKED_IN))
     return(PDM_I_PART_CHECKIN);

   status = PDMrdelete_part(refresh->rev_catalog,refresh->rev_partid,
                            refresh->rev_revision);
   _pdm_status("PDMdelete_element",status);

   _pdm_debug("setting the state", 0);
   status_msg = (char *) PDUtranslate_message(status);
   _pdm_debug("Error string = <%s>", status_msg);

   sts = PDMset_to_state ( status, "PDM", status_msg );
   _pdm_status ("PDMset_to_state", sts);

   if (status == PDM_S_SUCCESS)
     {
     _pdm_debug("clearing form fields", 0);

     // delete the dynamic tables data for this part
     // JTS MP CR 5536
     VDqryExecute(NULL,NULL,
	          refresh->rev_catalog,
		  refresh->rev_partid,
		  refresh->rev_revision,
		  "Delete Part");
     
     FIg_set_text(form, PARTNUM_FLD, "");
     FIg_set_text(form, PART_REV_FLD, "");
     FIg_set_text(form, PART_DESC_FLD, "");
     FIg_set_text(form, PART_FILE_FLD, "");

     if ((PDU_mcf_list) && (status == PDM_S_SUCCESS))
       PDUupdate_form_after_delete_part();
     }

PDUmessage(status,'s');

return(status);
}

int PDUupdate_form_after_delete_part()
{
  int				status = PDM_S_SUCCESS;
  int                           local_col;
  int                           column;
  int                           row;
  int                           length;
  int                           field;
  int                           select, pos;
  int                           index;
  static char                   *text;
  char                          *catalog = NULL;
  char                          *partid = NULL;
  char                          *revision = NULL;
  Form                          form;

    _pdm_debug("in the function PDUupdate_form_after_delete_part", 0);

    form = forms.local_files_form_id;
    field = LIST_MCF;

    status = MEMbuild_array(PDU_parts_list_bufr);
    _pdm_status("MEMbuild_array", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_BUILD_BUFFER_ARRAY);

    status = PDUget_buffer_col(PDU_parts_list_bufr, "p_local", &local_col);
    if (status != PDM_S_SUCCESS)
      return(status);
 
    _pdm_debug("PDU_parts_list_bufr->rows = %d", 
                (char *)PDU_parts_list_bufr->rows);

    /* find row in the part listing area that matches the part in the refresh */
    for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
       {
       _pdm_debug("row = %d", (char *)row);
       for (column = 0; column < 3; ++column)
          {
          FIfld_get_text_length(form, field, row, column, &length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          FIfld_get_text(form, field, row, column, length, 
                        (unsigned char *)text, &select, &pos);

          if (column == 0) PDUfill_in_string(&catalog, text);
          else if (column == 1) PDUfill_in_string(&partid, text);
          else if (column == 2) PDUfill_in_string(&revision, text);
          PDUfree_string(&text);
          }

          _pdm_debug("checking cat/part/rev for NULL", 0);
          if ((strcmp(refresh->rev_catalog, catalog) == 0) &&
               (strcmp(refresh->rev_partid, partid) == 0) &&
               (strcmp(refresh->rev_revision, revision) == 0) )
            {
            _pdm_debug("match found", 0);
            if (PDU_parts_index[row] != -1)
              {
              FImcf_set_select(form,field,row,FALSE);
              PDU_parts_index[row] = -1;
              PDU_selected_rows = PDU_selected_rows - 1;
              _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
              }
            _pdm_debug("marking row for deletion", 0);
            MEMwrite_data(PDU_parts_list_bufr,"DELETED", row+1, local_col+1);
            FIfld_set_text(form, field, row, local_col, "DELETED", FALSE);
  
            break;
            }
       /* clear out fields */
       _pdm_debug("clearing part fields", 0);
       catalog = NULL_STRING;
       partid = NULL_STRING;
       revision = NULL_STRING;
       }

    index = row;

    /* check for multiple files */
    for (row = index + 1; row < PDU_parts_list_bufr->rows; ++row)
       {
       _pdm_debug("row = <%d>", (char *)row);
       FIfld_get_text_length(form, LIST_MCF, row, 0, &length);
       text = (char *) malloc (sizeof (char) * length + 1);
       memset(text, NULL, sizeof (char) * length + 1);
       FIfld_get_text(form, LIST_MCF, row, 0, length, (unsigned char *)text,
                      &select, &pos);
       if (strcmp(text, "") == 0)
         {
         /* unselect the row that of the part */
         _pdm_debug("multiple file found", 0);
         if (PDU_parts_index[row] != -1)
           {
           FImcf_set_select(form,field,row,FALSE);
           PDU_parts_index[row] = -1;
           PDU_selected_rows = PDU_selected_rows - 1;
           _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
           }
         _pdm_debug("marking row for deletion", 0);
         MEMwrite_data(PDU_parts_list_bufr,"DELETED", row+1, local_col+1);
         FIfld_set_text(form, field, row, local_col, "DELETED", FALSE);

         }
       else
         {
         _pdm_debug("multiple files not found", 0);
         break;
         }
       PDUfree_string(&text);
       }

    return(status);
 } 

int PDUupdate_buffer_after_delete_part()
{
  int    status = PDM_S_SUCCESS;
  int    cat_col = 0;
  int    part_col = 0;
  int    rev_col = 0;
  int    desc_col = 0;
  int    ftype_col = 0;
  int    file_col = 0;
  int    update_col = 0;
  int    local_col = 0;
  int    ptype_col = 0;
  int    state_col = 0;
  int    char_index = 0;
  int    row = 0;
  int    num_rows = 0;
  int    rows_deleted = 0;
  int    select, pos, length;
  static char *text = NULL;
  char   catalog[20];
  char   part[40];
  char   revision[40];
  char   desc[40];
  char   filename[15];
  char   local[120];
  char   state[40];
  char   update[3];
  char   parttype[2];
  char   filetype[5];
  char   *line = NULL;
  char   **data_row = NULL;
  MEMptr buffer = NULL;

  _pdm_debug ("in the function PDUupdate_buffer_after_delete_part", 0);

  catalog[0] = '\0';
  part[0] = '\0';
  revision[0] = '\0';
  desc[0] = '\0';
  filetype[0] = '\0';
  filename[0] = '\0';
  local[0] = '\0';
  state[0] = '\0';
  update[0] = '\0';
  parttype[0] = '\0';

  status = MEMbuild_array(PDU_parts_list_bufr);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  _pdm_debug("getting columns for PDU_parts_list_bufr", 0);
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

  status = PDUget_buffer_col(PDU_parts_list_bufr, "n_filetype", &ftype_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(PDU_parts_list_bufr, "n_cofilename", &file_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(PDU_parts_list_bufr, "p_local", &local_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(PDU_parts_list_bufr, "n_statename", &state_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(PDU_parts_list_bufr, "p_update", &update_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(PDU_parts_list_bufr, "p_parttype", &ptype_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  PDUsetup_buffer(PDU_parts_list_bufr, ROW, &data_row);

  _pdm_debug("formatting temp buffer", 0);
  status = PDUformat_buffer (PDU_PARTS_MCF_BUFFER, &buffer);
  _pdm_status("PDUformat_buffer", status);
 
  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  line = (char*) malloc (buffer->row_size);

  rows_deleted = 0;

  for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
     {
     memset (line, NULL, buffer->row_size);
     char_index = 0;

     _pdm_debug("reading from PDU_parts_list_bufr on row %d", (char *)row);
     strcpy(local, data_row[(PDU_parts_list_bufr->columns*row) + local_col]);
     if (strcmp(local, "DELETED") == 0)
       {
       _pdm_debug("deleting part on row %d", (char *)row);
       FIfld_get_num_rows(forms.local_files_form_id, LIST_MCF, &num_rows);
       if (num_rows > 0)
         {
         FIfld_get_text_length(forms.local_files_form_id, LIST_MCF, 
                               row - rows_deleted, local_col, &length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(forms.local_files_form_id, LIST_MCF, row - rows_deleted,
                      local_col, length, (unsigned char *)text, &select, &pos);
         _pdm_debug("text = <%s>", text);
         if (strcmp(text, "DELETED") == 0)
           {
           FIfld_delete_rows(forms.local_files_form_id, LIST_MCF, 
                             row - rows_deleted, 1);
           FIfld_set_num_rows(forms.local_files_form_id, LIST_MCF, num_rows-1);
           ++rows_deleted;
           }
         else
           _pdm_debug("row in mcf is not marked for deletion", 0);
         }
       continue;
       }

     strcpy(catalog, 
            data_row[(PDU_parts_list_bufr->columns*row) + cat_col]);
     strcpy(part, 
            data_row[(PDU_parts_list_bufr->columns*row) + part_col]);
     strcpy(revision, 
            data_row[(PDU_parts_list_bufr->columns*row) + rev_col]);
     strcpy(desc, 
            data_row[(PDU_parts_list_bufr->columns*row) + desc_col]);
     strcpy(update, 
            data_row[(PDU_parts_list_bufr->columns*row) + update_col]);
     strcpy(filetype, 
            data_row[(PDU_parts_list_bufr->columns*row) + ftype_col]);
     strcpy(filename, 
            data_row[(PDU_parts_list_bufr->columns*row) + file_col]);
     strcpy(parttype, 
            data_row[(PDU_parts_list_bufr->columns*row) + ptype_col]);
     strcpy(state, 
            data_row[(PDU_parts_list_bufr->columns*row) + state_col]);

     _pdm_debug("writing row to temp buffer", 0);
     if (strlen(catalog))
       PDUadd_buffer_string(line, &char_index, catalog);
     else
       line[char_index++] = '\1';

     if (strlen(part))
       PDUadd_buffer_string(line, &char_index, part);
     else
       line[char_index++] = '\1';

     if (strlen(revision))
       PDUadd_buffer_string(line, &char_index, revision);
     else
       line[char_index++] = '\1';

     if (strlen(desc))
       PDUadd_buffer_string(line, &char_index, desc);
     else
       line[char_index++] = '\1';

     if (strlen(filetype))
       PDUadd_buffer_string(line, &char_index, filetype);
     else
       line[char_index++] = '\1';

     if (strlen(filename))
       PDUadd_buffer_string(line, &char_index, filename);
     else
       line[char_index++] = '\1';

     if (strlen(local))
       PDUadd_buffer_string(line, &char_index, local);
     else
       line[char_index++] = '\1';

     if (strlen(state))
       PDUadd_buffer_string(line, &char_index, state);
     else
       line[char_index++] = '\1';

     if (strlen(update))
       PDUadd_buffer_string(line, &char_index, update);
     else
       line[char_index++] = '\1';

     if (strlen(parttype))
       PDUadd_buffer_string(line, &char_index, parttype);
     else
       line[char_index++] = '\1';

     _pdm_debug("line = <%s>", line);
     status = MEMwrite (buffer, line);
     _pdm_status("MEMwrite_format ()", status);
 
     if (status != MEM_S_SUCCESS)
       {
       _pdm_debug("Error writing to temp buffer", 0);
       return(PDM_E_WRITE_BUFFER);
       }
     memset (line, NULL, buffer->row_size);
     }

  if (PDU_parts_list_bufr)
    {
    MEMclose(&PDU_parts_list_bufr);
    PDU_parts_list_bufr = NULL;
    }

  status = MEMsplit_copy_buffer(buffer, &PDU_parts_list_bufr, 0);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_COPY_BUFFER);

  _pdm_debug("resetting PDU_parts_index", 0);
  PDU_parts_index = (int *) malloc (sizeof (int)*PDU_parts_list_bufr->rows);
  memset(PDU_parts_index, -1, sizeof (int) * PDU_parts_list_bufr->rows);
  FIfld_get_num_rows(forms.local_files_form_id, LIST_MCF, &num_rows);
  if (num_rows > 0)
    for (row = 0; row < num_rows; ++row)
       {
       FImcf_get_select(forms.local_files_form_id,LIST_MCF,row, &select);
       if (select)
         PDU_parts_index[row] = row;
       }

  MEMclose(&buffer);
  buffer = NULL;
  if (line)
    free(line);

  if (PDM_debug_on)
    MEMprint_buffer("parts_list_buffer", PDU_parts_list_bufr, PDU_DEBUG_FILE);

  if (status == MEM_S_SUCCESS)
    status = PDM_S_SUCCESS;

  _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
  if (PDU_selected_rows > 0)
    status = PDM_E_NOT_DELETED;

  return(status);
}

void PDUreset_part_form_after_delete_part(ret_stat)
int  ret_stat;
{

Form    form;

  _pdm_debug("in the function PDUreset_part_form_after_delete_part", 0);

  form = forms.part_operations_form_id;

  if (ret_stat == PDM_S_SUCCESS)
      {
      _pdm_debug("resetting form for SUCCESS", 0);
      PDUupdate_part_form_change_mode();
      }
   else
      {
      _pdm_debug("resetting form for ERROR", 0);
      FIg_enable(PDU_form_id,EP_PARTNUM_FLD);
      FIg_enable(PDU_form_id,EP_REV_FLD);
      FIg_enable(PDU_form_id,EP_PARTNUM_BTN);
      FIg_enable(PDU_form_id,EP_REV_BTN);
      }
}

int PDUupdate_part_form_change_mode()
{
  int status = PDM_S_SUCCESS;
  int max_rows = 0;
  Form  form;

  _pdm_debug("in the function PDUupdate_part_form_change_mode", 0);

   form = forms.part_operations_form_id;

   /* Clear out the following fields */
   FIfld_set_text(form,NP_PARTNUM_FLD,0,0,"",FALSE);
   FIfld_set_text(form,NP_REV_FLD,0,0,"", FALSE);
   FIfld_set_text(form,NP_DESC_FLD,0,0,"", FALSE);
   FIfld_set_text(form,EP_PARTNUM_FLD,0,0,"", FALSE);
   FIfld_set_text(form,EP_REV_FLD,0,0,"", FALSE);
   FIfld_set_text(form,EP_DESC_FLD,0,0,"", FALSE);

   nn_itemname = NULL_STRING;
   np_rev = NULL_STRING;
   np_desc = NULL_STRING;
 
   en_itemname = NULL_STRING;
   ep_rev = NULL_STRING;
   ep_desc = NULL_STRING;

   refresh->new_partid = NULL_STRING;
   refresh->new_revision = NULL_STRING;
   refresh->new_description = NULL_STRING;

   refresh->rev_partid = NULL_STRING;
   refresh->rev_revision = NULL_STRING;
   refresh->rev_description = NULL_STRING;

   FIfld_set_text(form,STORAGE_AREA_FLD,0,0, "",FALSE);
   FIfld_set_text(form,STATE_NAME_FLD,0,0,"", FALSE);
   FIfld_set_text(form,WORKFLOW_FLD,0,0,"", FALSE);
   FIfld_set_text(form,ACL_NAME_FLD,0,0,"", FALSE);

   FIg_enable(PDU_form_id,EP_PROJECT_FLD);
   FIg_enable(PDU_form_id,EP_CATALOG_FLD);
   FIg_enable(PDU_form_id,EP_PARTNUM_FLD);
   FIg_enable(PDU_form_id,EP_REV_FLD);
   FIg_enable(PDU_form_id,EP_PROJECT_BTN);
   FIg_enable(PDU_form_id,EP_CATALOG_BTN);
   FIg_enable(PDU_form_id,EP_PARTNUM_BTN);
   FIg_enable(PDU_form_id,EP_REV_BTN);

   /* change mode of fields that could have been changed by functions */
   FIfld_set_mode(PDU_form_id, EP_DESC_FLD, 0, FI_INSERT);
   FIfld_set_mode(PDU_form_id, EP_PARTTYPE_FLD, 0, FI_INSERT);
   FIfld_set_mode(PDU_form_id, NEW_FILES_MCF, 0, FI_INSERT);
   FIfld_set_mode(PDU_form_id, NEW_FILES_MCF, 1, FI_INSERT);
   FIfld_set_mode(PDU_form_id, NEW_FILES_MCF, 2, FI_INSERT);
   FIfld_set_mode(PDU_form_id, NEW_FILES_MCF, 3, FI_INSERT);
   FIg_display(PDU_form_id, EP_DESC_FLD);
   FIg_display(PDU_form_id, EP_PARTTYPE_FLD);

   /* Blank out the ATTRIBUTE_VALUE_MCF */
   FIfld_get_num_rows(form, ATTRIBUTE_VALUE_MCF, &max_rows);
   PDUremove_data(form,ATTRIBUTE_VALUE_MCF,max_rows,2);

   /* Blank out the EXISTING_FILES_MCF */
   FIfld_get_num_rows(form,EXISTING_FILES_MCF, &max_rows);
   PDUremove_data(form,EXISTING_FILES_MCF, max_rows,4);
   FIg_reset(form,EXISTING_FILES_MCF);
   FIfld_set_max_num_rows(form, EXISTING_FILES_MCF,0);

   /* Blank out the NEW_FILES_MCF */
   FIfld_get_num_rows(form,NEW_FILES_MCF, &max_rows);
   PDUremove_data(form,NEW_FILES_MCF, max_rows,4);
   FIg_reset(form,NEW_FILES_MCF);

   FIg_display(form,CHANGE_MODE_GRP);

   /* Set first row to be the first visable row in the mcf */
   FIfld_set_active_row(form,NEW_FILES_MCF,0,0);

   FIfld_pos_cursor(PDU_form_id,EP_PARTNUM_FLD,0,0,0,0,0,0);

   _pdm_debug("resetting parttype", 0);
   if (refresh->rev_catalog && 
      (strcmp(refresh->rev_catalog, "pdmseedfiles") == 0))
     {
     PDUfill_in_string1(&ep_parttype, "G");
     PDUfill_in_string1(&refresh->rev_parttype,ep_parttype);
     }
   else if (refresh->rev_catalog && 
           (strcmp(refresh->rev_catalog, "pdmlibraries") == 0))
     {
     PDUfill_in_string1(&ep_parttype, "M");
     PDUfill_in_string1(&refresh->rev_parttype,ep_parttype);
     FIg_disable(forms.part_operations_form_id,EP_PARTTYPE_BTN);
     }
   else
     {
     PDUfill_in_string1(&ep_parttype, "G");
     PDUfill_in_string1(&refresh->rev_parttype,ep_parttype);
     }
   FIg_set_text(PDU_form_id, EP_PARTTYPE_FLD, ep_parttype);

  return(status);
}
