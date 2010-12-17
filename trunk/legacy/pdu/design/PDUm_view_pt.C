#include <stdio.h>
#include "MEMerrordef.h"
#include "PDUstr.h"
#include "PDUintdef.h"
#include "PDUproto.h"
#include "PDUfile_def.h"
#include "PDUload_free.h"
#include "igrtypedef.h"

extern MEMptr   PDU_ret_bufr;
extern MEMptr   PDU_file_bufr;
extern struct   PDUrefresh    *refresh;
extern int      review_mode;
extern int      PDMdebug_on;

void PDUm_review_pt(status,catalog,part_id,rev,attrs,files)

IGRint    *status;
IGRchar   *catalog;
IGRchar   *part_id;
IGRchar   *rev;
struct  PDUattribute_info **attrs;
struct  file_info **files;

{

FILE          *fp, *fopen ();
MEMptr        attr_bufr = NULL;
MEMptr        data_bufr = NULL;
MEMptr        acl_bufr = NULL;
MEMptr        stg_bufr = NULL;
MEMptr        file_data_bufr = NULL;
MEMptr        dummy_bufr = NULL;
IGRchar       * acl_name = NULL;
IGRchar       * stg_name = NULL;
IGRchar       * state_name = NULL;
IGRchar       * filedesc = NULL;
IGRchar       * local_filename = NULL;
IGRchar       * stg_filename = NULL;
IGRchar       * filetype = NULL;
IGRchar       * attr = NULL;
IGRchar       * type = NULL;
IGRchar       * syn = NULL;
IGRchar       * val = NULL;
IGRchar       ** data1_row;
IGRchar       ** data1_col;
IGRchar       ** data1_format;
IGRchar       ** data2_row;
IGRchar       ** data2_col;
IGRchar       ** data2_format;
IGRchar       ** data3_row;
IGRchar       ** data3_col;
IGRchar       ** data3_format;
IGRchar       ** data4_row;
IGRchar       ** data4_col;
IGRchar       ** data4_format;
IGRchar       ** file_data_row;
IGRchar       ** file_data_col;
IGRchar       ** file_data_format;
IGRchar          header_str[100];
IGRchar        * acl_no = NULL;
IGRchar        * stg_no = NULL;
IGRint           acl_buffer_no = 0;
IGRint           stg_buffer_no = 0;
IGRint           aclbufr_aclname_col = 0;
IGRint           aclbufr_aclno_col = 0;
IGRint           n_cisano_col = 0;
IGRint           n_name_col = 0;
IGRint           n_syn_col = 0;
IGRint           p_filedesc_col = 0;
IGRint           n_cofilenm_col = 0;
IGRint           n_cifilenm_col = 0;
IGRint           n_filetype_col = 0;
IGRint           n_valueno_col = 0;
IGRint           i = 0;
IGRint           n_state_col = 0;
IGRint           n_aclno_col = 0;
IGRint           n_status_col = 0;
IGRint           stgbufr_saname_col = 0;
IGRint           stgbufr_sano_col = 0;
IGRint           n_datatype_col = 0;
IGRint           string_len = 0;
IGRint           found = 0;
IGRint           sts = 0;

   _pdm_debug("In PDUm_review_part",0);

   refresh->command = PDC_M_REVIEW_PART;

   *status = PDUvalidate_access(refresh->command);
   _pdm_status("PDUvalidate_access", *status);

   if (*status != PDM_S_SUCCESS)
      return;

   if ((catalog != NULL) && (strcmp(catalog,"") != 0))
      {
      string_len = strlen(catalog);

      if (string_len == 0)
         {
         *status = PDM_E_CAT_FIELD_BLANK;
         return;
         }
      }

   if ((part_id != NULL) && (strcmp(part_id,"") != 0))
      {
      string_len = strlen(part_id);

      if (string_len == 0)
         {
         *status = PDM_E_PART_FIELD_BLANK;
         return;
         }
      }

   if ((rev != NULL) && (strcmp(rev,"") != 0))
      {
      string_len = strlen(rev);

      if (string_len == 0)
         {
         *status = PDM_E_REV_FIELD_BLANK;
         return;
         }
      }

   review_mode = TRUE;

   /* Call function to retrieve buffer */

   if (PDU_ret_bufr)
     {
     MEMclose(&PDU_ret_bufr);
     PDU_ret_bufr = NULL;
     }
   if (PDU_file_bufr)
     {
     MEMclose(&PDU_file_bufr);
     PDU_file_bufr = NULL;
     }

   *status = PDMget_existing_data(catalog,part_id,rev);
   _pdm_status("PDUget_existing_data",*status);

   PDUunlock_item(catalog,part_id,rev);

   if (*status != PDM_S_SUCCESS)
      return;

   if (PDMdebug_on)
     MEMprint_buffers("PDU_ret_bufr", PDU_ret_bufr, PDU_DEBUG_FILE);

   /* MEMsplit the buffers */
   *status = PDUsetup_buffer_list(PDU_ret_bufr, 1, 0, &data1_row,
                                 &data1_col,&data1_format,&attr_bufr);
   _pdm_status("PDUsetup_buffer_list",*status);

   if (*status != PDM_S_SUCCESS)
      return;

   *status = PDUsetup_buffer_list(PDU_ret_bufr, 2, 0, &data2_row,
                                 &data2_col,&data2_format,&data_bufr);
   _pdm_status("PDUsetup_buffer_list",*status);

   if (*status != PDM_S_SUCCESS)
      return;

   *status = PDUsetup_buffer_list(PDU_file_bufr, 2, 0, &file_data_row,
                                 &file_data_col,&file_data_format,
                                 &file_data_bufr);
   _pdm_status("PDUsetup_buffer_list",*status);

   if ((*status != PDM_S_SUCCESS) && (*status != PDM_E_NULL_BUFFER))
      return;

   if (PDMdebug_on)
     MEMprint_buffer("file_data_bufr", file_data_bufr, PDU_DEBUG_FILE);

   if (file_data_bufr)
      {
      *status = MEMbuild_array(file_data_bufr);
      _pdm_status("MEMbuild_array", *status);
      if (*status != MEM_S_SUCCESS)
        return;

      _pdm_debug("calling PDUsetup_buffer", 0);
      PDUsetup_buffer(file_data_bufr, ROW, &file_data_row);

      _pdm_debug("getting buffer columns", 0);
      *status =PDUget_buffer_col(file_data_bufr,"n_cofilename",&n_cofilenm_col);
      if (*status != PDM_S_SUCCESS)
          return;

      *status =PDUget_buffer_col(file_data_bufr,"n_cifilename",&n_cifilenm_col);
      if (*status != PDM_S_SUCCESS)
          return;

      *status = PDUget_buffer_col(file_data_bufr,"n_filetype", &n_filetype_col);
      if (*status != PDM_S_SUCCESS)
          return;

      *status = PDUget_buffer_col(file_data_bufr,"p_filedesc", &p_filedesc_col);
      if (*status != PDM_S_SUCCESS)
          return;

      *status = PDUget_buffer_col(file_data_bufr,"n_status", &n_status_col);
      if (*status != PDM_S_SUCCESS)
          return;
      }

   *status = PDUget_col_number(attr_bufr,"n_name",data1_col,&n_name_col);
   _pdm_status("PDUget_col_number",*status);

   if (*status != PDM_S_SUCCESS)
      return;

   *status = PDUget_col_number(attr_bufr,"n_synonym",data1_col,
                              &n_syn_col);
   _pdm_status("PDUget_col_number",*status);

   if (*status != PDM_S_SUCCESS)
      return;

   *status = PDUget_col_number(attr_bufr,"n_valueno",data1_col,
                               &n_valueno_col);
   _pdm_status("PDUget_col_number",*status);

   if (*status != PDM_S_SUCCESS)
      return;

   *status = PDUget_col_number(attr_bufr,"n_datatype",data1_col,
                              &n_datatype_col);
   _pdm_status("PDUget_col_number",*status);

   if (*status != PDM_S_SUCCESS)
      return;

   *status = PDUget_col_number(data_bufr,"n_aclno",data2_col,
                               &n_aclno_col);
   if (*status != PDM_S_SUCCESS)
      return;

   *status = PDUget_col_number(data_bufr,"n_cisano",data2_col,
                               &n_cisano_col);
   if (*status != PDM_S_SUCCESS)
       return;

   /* Write acl number to data buffer */

   _pdm_debug("getting acl buffer number", 0);
   for (i = 0; i < attr_bufr->rows; ++i)
      {
      if (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
          "n_aclno") == 0)
         {
         acl_buffer_no = atoi(data1_row[(attr_bufr->columns * i) +
                              n_valueno_col]);
         PDUfill_in_string1(&acl_no,
                            data2_row[(data_bufr->columns * 0) + n_aclno_col]);
         _pdm_debug("acl_buffer number = <%s>", acl_no);
         break;
         }
      }

   *status = PDUsetup_buffer_list(PDU_ret_bufr, 3, acl_buffer_no,
                                  &data3_row, &data3_col,&data3_format,
                                  &acl_bufr);
   _pdm_status("PDUsetup_buffer_list",*status);

   if (*status != PDM_S_SUCCESS)
       return;

   *status = PDUget_col_number(acl_bufr,"n_aclname",
                               data3_col, &aclbufr_aclname_col);
   if (*status != PDM_S_SUCCESS)
      return;

   *status = PDUget_col_number(acl_bufr,"n_aclno",data3_col,
                               &aclbufr_aclno_col);
   if (*status != PDM_S_SUCCESS)
       return;

   _pdm_debug("getting acl_name", 0);
   for (i = 0; i < acl_bufr->rows; ++i)
       {
       if (strcmp(acl_no,
                 data3_row[(acl_bufr->columns * i) + aclbufr_aclno_col]) == 0)
          {
          found = 1;
          _pdm_debug("writing acl_name to buffer", 0);
          PDUfill_in_string1(&acl_name,data3_row[(acl_bufr->columns * i) +
                             aclbufr_aclname_col]);
          _pdm_debug("acl_name = <%s>", acl_name);
          }
       }

    if (found == 0)
       {
       /* Default to first one in buffer */
       PDUfill_in_string1(&acl_name,data3_row[(acl_bufr->columns * 0) +
                          aclbufr_aclname_col]);
/*
       *status = PDM_E_ACLNAME_NOT_FOUND;
       return;
*/
       }

   /* Write storage number to data buffer */

   found = 0;

   _pdm_debug("getting storage buffer number", 0);
   for (i = 0; i < attr_bufr->rows; ++i)
      {
      if (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
          "n_cisano") == 0)
         {
         stg_buffer_no = atoi(data1_row[(attr_bufr->columns * i) +
                              n_valueno_col]);
         PDUfill_in_string1(&stg_no,
                            data2_row[(data_bufr->columns * 0) + n_cisano_col]);
         _pdm_debug("stg buffer number = <%s>", stg_no);
         break;
         }
      }

   *status = PDUsetup_buffer_list(PDU_ret_bufr, 3, stg_buffer_no, &data4_row,
                                  &data4_col,&data4_format,&stg_bufr);

   _pdm_status("PDUsetup_buffer_list",*status);

   if (*status != PDM_S_SUCCESS)
       return;

   if (PDMdebug_on)
     MEMprint_buffer("STORAGE BUFFER", stg_bufr, PDU_DEBUG_FILE);

   *status = PDUget_col_number(stg_bufr,"n_sano",data4_col,
                               &stgbufr_sano_col);
   if (*status != PDM_S_SUCCESS)
       return;

   *status = PDUget_col_number(stg_bufr,"n_saname",data4_col,
                               &stgbufr_saname_col);
   if (*status != PDM_S_SUCCESS)
       return;

   _pdm_debug("checking for storage name", 0);
   for (i = 0; i < stg_bufr->rows; ++i)
      {
      if ((stg_name) && (strcmp(stg_name,data4_row[(stg_bufr->columns * i)
          + stgbufr_saname_col]) == 0))
          {
          _pdm_debug("matching storage name was found", 0);
          found = 1;
          PDUfill_in_string1(&stg_name,data4_row[(stg_bufr->columns * i) +
                             stgbufr_saname_col]);
          _pdm_debug("stg_name = <%s>", stg_name);
          }
       }

    if (found == 0)
       {
       _pdm_debug("matching storage name was not found", 0);
       PDUfill_in_string1(&stg_name,data4_row[(stg_bufr->columns * 0) +
                          stgbufr_saname_col]);
/*
       *status = PDM_E_STGNAME_NOT_FOUND;
       return;
*/
       }

    found = 0;

    *status = PDUget_col_number(data_bufr,"n_cocomment",data2_col,
                                &n_state_col);

    if (*status != PDM_S_SUCCESS)
       return;

    _pdm_debug("getting statename", 0);
    for (i = 0; i < attr_bufr->rows; ++i)
       {
       if (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
           "n_cocomment") == 0)
          {
          PDUfill_in_string1(&state_name,data2_row[(data_bufr->columns * 0) +
                             n_state_col]);
          _pdm_debug("statename = <%s>", state_name);
          break;
          }
       }

   /* Write attributes and values from the attribute and data buffer to the
      PDUattribute_info structure */

   _pdm_debug("opening REVIEW_PT file", 0);
   if ((fp = fopen ("REVIEW_PT", "a")) == NULL)
      {
      _pdm_debug("Could not open file",PDU_DEBUG_FILE);
      *status = PDM_E_OPEN_FILE;
      return;
      }

   header_str[0] = '\0';
   sprintf(header_str,"REVIEW PART:  Catalog <%s> * Part Number <%s> * Revision <%s>\n\n\n",catalog,part_id,rev);
   fprintf(fp,header_str);

   fprintf(fp,"Attribute Information:\n");
   fprintf(fp,"______________________\n\n");

   for (i = 0; i < attr_bufr->rows; ++i)
       {
       if ((strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
           "n_itemname")) &&
           (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
           "n_itemrev")) &&
           (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
           "n_aclno")) &&
           (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
           "n_cisano")) &&
           (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
           "n_cofilename")) &&
           (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
           "n_cifilename")) &&
           (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
           "n_filetype")) &&
           (strcmp(data1_row[(attr_bufr->columns * i) + n_name_col],
           "p_filedesc")))
          {
          PDUfill_in_string(&attr, 
                    data1_row[(attr_bufr->columns * i) + n_name_col]);
          PDUfill_in_string(&type, 
		    data1_row[(attr_bufr->columns * i) + n_datatype_col]);
          PDUfill_in_string(&syn, 
                    data1_row[(attr_bufr->columns * i) + n_syn_col]);
          PDUfill_in_string(&val, data2_row[(data_bufr->columns * 0) + i]);

          fprintf(fp,"ATTRIBUTE: ");
          fprintf(fp,attr);
          fprintf(fp,"\n");
          fprintf(fp,"DATATYPE: ");
          fprintf(fp,type);
          fprintf(fp,"\n");
          fprintf(fp,"SYNONYM: ");
          fprintf(fp,syn);
          fprintf(fp,"\n");
          fprintf(fp,"VALUE: ");
          fprintf(fp,val);
          fprintf(fp,"\n\n");

          _pdm_debug("calling pdm$load_attribute_structure", 0);
          _pdm_debug("attribute = <%s>", attr);
          _pdm_debug("datatype  = <%s>", type);
          _pdm_debug("synonym   = <%s>", syn);
          _pdm_debug("value     = <%s>", val);
          pdm$load_attribute_structure(status = &sts,
              				attribute = attr,
              				datatype = type,
              				synonym = syn,
              				value = val,
              				attr_list = attrs);
          }
       }

   if ((*attrs) && (PDMdebug_on))
     PDUprint_PDUattr_list(*attrs);

   /* Add two more spaces between Attribute and File information */
   fprintf(fp,"\n\n");

   /* Write file information from the file data buffer to the 
      file_info structure */

   _pdm_debug("accessing file information", 0);

   if (PDMdebug_on)
     MEMprint_buffer("file_data_bufr", file_data_bufr, PDU_DEBUG_FILE);

   /* Check the file_data_bufr */
   if (file_data_bufr)
      {
      fprintf(fp,"File Information:\n");
      fprintf(fp,"_________________\n\n");

      for (i = 0; i < file_data_bufr->rows; ++i)
          {
          _pdm_debug("getting buffer data", 0);
          PDUfill_in_string(&filedesc,
               file_data_row[(file_data_bufr->columns * i) + p_filedesc_col]);
          PDUfill_in_string(&local_filename,
	       file_data_row[(file_data_bufr->columns * i) + n_cofilenm_col]);
          PDUfill_in_string(&stg_filename,
	       file_data_row[(file_data_bufr->columns * i) + n_cifilenm_col]);
          PDUfill_in_string(&filetype,
	       file_data_row[(file_data_bufr->columns * i) + n_filetype_col]);

          fprintf(fp,"FILE DESC: ");
          fprintf(fp,filedesc);
          fprintf(fp,"\n");
          fprintf(fp,"LOCAL FILENAME: ");
          fprintf(fp,local_filename);
          fprintf(fp,"\n");
          fprintf(fp,"STORAGE FILENAME: ");
          fprintf(fp,stg_filename);
          fprintf(fp,"\n");
          fprintf(fp,"FILE TYPE: ");
          fprintf(fp,filetype);
          fprintf(fp,"\n\n");

          _pdm_debug("calling pdm$load_file_structure", 0);
          _pdm_debug("filedesc = <%s>", filedesc);
          _pdm_debug("local_filename = <%s>", local_filename);
          _pdm_debug("stg_filename = <%s>", stg_filename);
          _pdm_debug("filetype = <%s>", filetype);

          pdm$load_file_structure(status = &sts,
                     file_desc = filedesc,
                     local_fn = local_filename,
                     storage_fn = stg_filename,
                     file_type = filetype,
                     mode = NULL,
                     file_list = files);
          }
       }

   _pdm_debug("freeing variables", 0);
   if (filedesc) free (filedesc);
   if (local_filename) free (local_filename);
   if (stg_filename) free (stg_filename);
   if (filetype) free (filetype);
   if (attr) free (attr);
   if (type) free (type);
   if (syn) free (syn);
   if (val) free (val);

   fprintf(fp,"CURRENT STATE OF PART: %s\n\n",state_name);
   fprintf(fp,"ACL NAME: %s\n\n",acl_name);
   fprintf(fp,"STORAGE NAME: %s\n\n",stg_name);
   fprintf(fp,"\n");


   if (*status != PDM_S_SUCCESS)
      return;

   if (PDU_ret_bufr)
      MEMclose(&PDU_ret_bufr);
 
   if (attr_bufr)
      MEMclose(&attr_bufr);
 
   if (data_bufr)
      MEMclose(&data_bufr);

   if (acl_bufr)
      MEMclose(&acl_bufr);

   if (stg_bufr)
      MEMclose(&stg_bufr);

   if (file_data_bufr)
      MEMclose(&file_data_bufr);

   fclose(fp);

   review_mode = FALSE;

   *status = PDM_S_SUCCESS;
}

