#include "PDUerror.h"
#include "PDUstr.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "PDUintdef.h"
#include "PDUfile_def.h"
#include "PDMproto.h"
#include "PDUproto.h"

extern struct PDUrefresh *refresh;
extern short PDU_main_form_cat;
extern MEMptr PDU_ret_bufr;
extern MEMptr PDU_file_bufr;
extern MEMptr PDU_add_bufr;
extern int change_mode;

void PDUm_chg_part(	status,
                        cpr_catalog,
			cpr_partnum,
			cpr_revision,
			cpr_parttype,
			cpr_description,
			cpr_acl_name,
			cpr_stg_name,
			spr_attrs,
			spr_add_files,
			spr_chg_files)
  int     *status;
  char    *cpr_catalog;
  char    *cpr_partnum;
  char    *cpr_revision;
  char    *cpr_parttype;
  char    *cpr_description;
  char    *cpr_acl_name;
  char    *cpr_stg_name;
  struct   PDUattribute_info *spr_attrs;
  struct   file_info      *spr_add_files;
  struct   chg_file_info  *spr_chg_files;
{
  long  status1 = PDM_S_SUCCESS;
  int    name_col = 0;
  int    syn_col = 0;
  int    type_col = 0;
  int    parttype_col = 0;
  int    desc_col = 0;
  int    aclno_col = 0;
  int    acl_buffer_no = 0;
  int    stg_buffer_no = 0;
  int    cisano_col = 0;
  int    saname_col = 0;
  int    valueno_col = 0;
  int    aclname_col = 0;
  int    n_status_col = 0;
  int    i = 0;
  short  found = 0;
  char   part_status[5];
  char   ** data1_row;
  char   ** data1_col;
  char   ** data1_format;
  char   ** data2_row;
  char   ** data2_col;
  char   ** data2_format;
  char   ** data3_row;
  char   ** data3_col;
  char   ** data3_format;
  char   ** data4_row;
  char   ** data4_col;
  char   ** data4_format;
  char   ** file_data_row;
  char   ** add_data_row;
  char   ** dummy_col;
  char   ** dummy_format;
  char   aclno[5];
  char   stgno[5];
  MEMptr attr_bufr = NULL;
  MEMptr data_bufr = NULL;
  MEMptr list_bufr = NULL;
  MEMptr acl_bufr = NULL;
  MEMptr stg_bufr = NULL;
  MEMptr file_data_bufr = NULL;
  MEMptr add_data_bufr = NULL;
  extern void PDUcleanup_change_part();

  _pdm_debug("in the function PDUm_chg_part", 0);

  refresh->command = PDC_M_MODIFY_ELEMENT;

  _pdm_debug("validating catalog", 0);
  PDU_main_form_cat = FALSE;
 *status = PDUvalidate_catalog("", cpr_catalog, 0);
  _pdm_status("PDUvalidate_catalog",*status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUmessage(*status, 's');
    return;
    }

  _pdm_debug("validating partnum", 0);
  if (cpr_partnum == NULL)
    {
    *status = PDM_I_ENTER_PART;
    PDUmessage(*status, 's');
    return;
    }
  else if (strlen(cpr_partnum) == 0)
    {
    *status = PDM_I_ENTER_PART;
    PDUmessage(*status, 's');
    return;
    }

  _pdm_debug("validating revision", 0);
  if (cpr_revision == NULL)
    {
    *status = PDM_I_ENTER_REVISION;
    PDUmessage(*status, 's');
    return;
    }
  else if (strlen(cpr_revision) == 0)
    {
    *status = PDM_I_ENTER_REVISION;
    PDUmessage(*status, 's');
    return;
    }

  _pdm_debug("checking to see if part exists", 0);
 *status = PDMcheck_partnum(cpr_catalog, cpr_partnum, cpr_revision);
  _pdm_status("PDMcheck_partnum",status);
  MEMclose(&PDU_ret_bufr); PDU_ret_bufr = NULL;
  if (*status != PDM_S_SUCCESS)
    {
    PDUmessage(*status, 's');
    return;
    }

  _pdm_debug("validating access", 0);
 *status = PDUwf_check(PDC_M_MODIFY_ELEMENT);
  _pdm_status("PDUwf_check",*status);
  if (*status == PDM_S_SUCCESS)
    {
   *status = PDMvalidate_user_access ( "PDMChange Part", NULLSTR, cpr_catalog,
                                        NULLSTR, cpr_partnum, cpr_revision );
    _pdm_status("PDMvalidate_access",*status);
    if (*status != PDM_S_SUCCESS)
      {
      PDUmessage(*status, 's');
      return;
      }
    }
  else
   *status = PDM_S_SUCCESS;

  _pdm_debug("retrieving list of attributes", 0);
  change_mode = TRUE;
 *status = PDMget_existing_data(cpr_catalog, cpr_partnum, cpr_revision);
  _pdm_status("PDMget_existing_data",status);
  change_mode = FALSE;
  if (*status != PDM_S_SUCCESS)
    {
    PDUmessage(*status, 's');
    return;
    }

  _pdm_debug("splitting return buffer into attr and data buffers", 0);
 *status = PDUsetup_buffer_list(PDU_ret_bufr, 1, 0, &data1_row,
                                &data1_col,&data1_format,&attr_bufr);
  _pdm_status("PDUsetup_buffer_list",status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    PDUmessage(*status, 's');
    return;
    }
 
 *status = PDUsetup_buffer_list(PDU_ret_bufr, 2, 0, &data2_row,
                                &data2_col,&data2_format,&data_bufr);
  _pdm_status("PDUsetup_buffer_list",status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    PDUmessage(*status, 's');
    return;
    }
 
 *status = MEMbuild_array(data_bufr);
  _pdm_status("MEMbuild_array",*status);
  if (*status != MEM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    *status = PDM_E_BUILD_BUFFER_ARRAY;
    PDUmessage(*status, 's');
    return;
    }

 *status = MEMsplit_copy_buffer(PDU_ret_bufr, &list_bufr, 1);
  _pdm_status("MEMsplit_copy_buffer",*status);
  if (*status != MEM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    *status = PDM_E_COPY_BUFFER;
    PDUmessage(*status, 's');
    return;
    }
 
 *status = MEMbuild_array(list_bufr);
  _pdm_status("MEMbuild_array",*status);
  if (*status != MEM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    *status = PDM_E_BUILD_BUFFER_ARRAY;
    PDUmessage(*status, 's');
    return;
    }

 *status = PDUget_col_number(attr_bufr,"n_name",data1_col,&name_col);
  _pdm_status("PDUget_col_number",status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    PDUmessage(*status, 's');
    return;
    }
 
 *status = PDUget_col_number(attr_bufr,"n_synonym",data1_col, &syn_col);
  _pdm_status("PDUget_col_number",status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    PDUmessage(*status, 's');
    return;
    }
 
 *status = PDUget_col_number(attr_bufr,"n_datatype",data1_col, &type_col);
  _pdm_status("PDUget_col_number",status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    PDUmessage(*status, 's');
    return;
    }
 
 *status = PDUget_col_number(attr_bufr,"n_valueno",data1_col, &valueno_col);
  _pdm_status("PDUget_col_number",status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    PDUmessage(*status, 's');
    return;
    }

  _pdm_debug("getting acl buffer number", 0);
  for (i = 0; i < attr_bufr->rows; ++i)
     {
     if (strcmp(data1_row[(attr_bufr->columns * i) + name_col], "n_aclno")==0)
       {
       acl_buffer_no = atoi(data1_row[(attr_bufr->columns * i) + valueno_col]);
       _pdm_debug("acl_buffer_no = %d", (char *)acl_buffer_no);
       break;
       }
     }
 
 *status = PDUsetup_buffer_list(PDU_ret_bufr, 3, acl_buffer_no, &data3_row,
                                &data3_col,&data3_format, &acl_bufr);
  _pdm_status("PDUsetup_buffer_list",status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    PDUmessage(*status, 's');
    return;
    }
 
 *status = MEMbuild_array(acl_bufr);
  _pdm_status("MEMbuild_array",*status);
  if (*status != MEM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    *status = PDM_E_BUILD_BUFFER_ARRAY;
    PDUmessage(*status, 's');
    return;
    }

  _pdm_debug("getting storage buffer number", 0);
  for (i = 0; i < attr_bufr->rows; ++i)
     {
     if (strcmp(data1_row[(attr_bufr->columns * i) + name_col],"n_cisano") == 0)
       {
       stg_buffer_no = atoi(data1_row[(attr_bufr->columns * i) + valueno_col]);
       _pdm_debug("stg_buffer_no = %d", (char *)stg_buffer_no);
       break;
       }
     }
 
 *status = PDUsetup_buffer_list(PDU_ret_bufr, 3, stg_buffer_no, &data4_row,
                                &data4_col,&data4_format,&stg_bufr);
  _pdm_status("PDUsetup_buffer_list",status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    PDUmessage(*status, 's');
    return;
    }
 
 *status = MEMbuild_array(stg_bufr);
  _pdm_status("MEMbuild_array",*status);
  if (*status != MEM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    *status = PDM_E_BUILD_BUFFER_ARRAY;
    PDUmessage(*status, 's');
    return;
    }
 
  _pdm_debug("validating description", 0);
  if (!cpr_description)
    cpr_description = NULL_STRING;
  if (strlen(cpr_description))
    {
   *status = PDUcheck_desc_datatype(cpr_description, attr_bufr);
    _pdm_status("PDUcheck_desc_datatype",*status);
    if (*status != PDM_S_SUCCESS)
      {
      PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
       attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
      PDUmessage(*status, 's');
      return;
      }
    }
 
  _pdm_debug("validating parttype", 0);
 *status = PDUvalidate_parttype(cpr_catalog, cpr_parttype);
  _pdm_status("PDMvalidate_parttype",*status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    PDUmessage(*status, 's');
    return;
    }
 
  if (((strcmp(cpr_parttype, "N") == 0) || (strcmp(cpr_parttype, "n") == 0)) &&
      ((spr_add_files) || (spr_chg_files)))
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    *status = PDM_E_ADD_FILES_NG_PART;
    PDUmessage(*status, 's');
    return;
    }

  _pdm_debug("verifying acl name", 0);
  aclno[0] = '\0';
 *status = PDUverify_aclname(cpr_acl_name, aclno, acl_bufr);
  _pdm_status("PDUverify_aclname",*status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    PDUmessage(*status, 's');
    return;
    }
 
  _pdm_debug("calling PDUget_col_number", 0);
 *status = PDUget_col_number(data_bufr,"n_aclno",data2_col, &aclno_col);
  _pdm_status("PDUget_col_number",*status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    PDUmessage(*status, 's');
    return;
    }
 
 *status = PDUget_col_number(acl_bufr,"n_aclname", data3_col, &aclname_col);
  _pdm_status("PDUget_col_number",*status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    PDUmessage(*status, 's');
    return;
    }
 
  PDUsetup_buffer(acl_bufr, ROW, &data3_row);
 
  _pdm_debug("writing aclname to buffer", 0);
  _pdm_debug("aclname_col = %d", (char *)aclname_col);
  _pdm_debug("aclno_col = %d", (char *)aclno_col);
  found = 0;
  for (i = 0; i < acl_bufr->rows; ++i)
     {
     if (strcmp(cpr_acl_name,
               data3_row[(acl_bufr->columns * i) + aclname_col]) == 0)
       {
      *status = MEMwrite_data(data_bufr, aclno,1, (aclno_col + 1));
       _pdm_status("MEMwrite_data",status);
       if (*status != MEM_S_SUCCESS)
         {
         PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
           attr_bufr,data_bufr,file_data_bufr,add_data_bufr,acl_bufr,stg_bufr);
         *status = PDM_E_WRITE_BUFFER;
         PDUmessage(*status, 's');
         return;
         }
       found = 1;
       break;
       }
     }
 
  if (found == 0)
    {
    *status = PDM_E_ACLNAME_NOT_FOUND;
    PDUmessage(*status, 's');
    return;
    }
 
  _pdm_debug("verifying storage name", 0);
 *status = PDUverify_storage_name(cpr_stg_name, stgno, stg_bufr);
  _pdm_status("PDUverify_storage_name",*status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    PDUmessage(*status, 's');
    return;
    }

 *status = PDUget_col_number(data_bufr,"n_cisano",data2_col, &cisano_col);
  _pdm_status("PDUget_col_number",*status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    PDUmessage(*status, 's');
    return;
    }
 
 *status = PDUget_col_number(stg_bufr,"n_saname",data4_col, &saname_col);
  _pdm_status("PDUget_col_number",*status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    PDUmessage(*status, 's');
    return;
    }
 
  found = 0;
  for (i = 0; i < stg_bufr->rows; ++i)
     {
      if (strcmp(cpr_stg_name,
                 data4_row[(stg_bufr->columns * i) + saname_col]) == 0)
        {
       *status = MEMwrite_data(data_bufr, stgno,1, cisano_col+1);
        _pdm_status("MEMwrite_data",*status);
        if (*status != MEM_S_SUCCESS)
          {
          PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
            attr_bufr,data_bufr,file_data_bufr,add_data_bufr,acl_bufr,stg_bufr);
          *status = PDM_E_WRITE_BUFFER;
          PDUmessage(*status, 's');
          return;
          }
        found = 1;
        }
     }
 
   if (found == 0)
    {
    *status = PDM_E_STGNAME_NOT_FOUND;
    PDUmessage(*status, 's');
    return;
    }

 *status = PDUget_col_number(data_bufr,"p_parttype",data2_col, &parttype_col);
  _pdm_status("PDUget_col_number",*status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    PDUmessage(*status, 's');
    return;
    }
 
 *status = PDUget_col_number(data_bufr,"n_itemdesc",data2_col, &desc_col);
  _pdm_status("PDUget_col_number",*status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    PDUmessage(*status, 's');
    return;
    }

 *status = MEMwrite_data(data_bufr,cpr_parttype,1,parttype_col + 1);
  _pdm_status("MEMwrite_data",*status);
  if (*status != MEM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    PDUmessage(*status, 's');
    return;
    }
 
 *status = MEMwrite_data(data_bufr,cpr_description,1,desc_col + 1);
  _pdm_status("MEMwrite_data",*status);
  if (*status != MEM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    PDUmessage(*status, 's');
    return;
    }

  _pdm_debug("verifying attr list", 0);
  if (spr_attrs)
    {
   *status = PDUverify_PDUattr_list(spr_attrs, attr_bufr, list_bufr, &data_bufr,
                                    CHANGE);
    _pdm_status("PDUverify_attr_list",*status);
    if (*status != PDM_S_SUCCESS)
      {
      PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
       attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
      PDUmessage(*status, 's');
      return;
      }
    }

  _pdm_debug("checking part*status", 0);
 *status = PDUget_buffer_col(data_bufr, "n_status", &n_status_col);
  _pdm_status("PDUget_col_number",*status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    PDUmessage(*status, 's');
    return;
    }

  part_status[0] = '\0';
  strcpy(part_status, data2_row[(data_bufr->columns * 0) + n_status_col]);
  _pdm_debug("part*status = <%s>", part_status);

  if (((strcmp(part_status, "O") != 0) && 
       (strcmp(part_status, "S") != 0) &&
       (strcmp(part_status, "") != 0)) && 
       (spr_add_files))
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    *status = PDM_E_CANNOT_ADD_FILES;
    PDUmessage(*status, 's');
    return;
    }

  if ((strcmp(part_status, "I") != 0) && 
      (strcmp(part_status, "") != 0) &&
      (spr_chg_files))
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    *status = PDM_E_CANNOT_CHANGE_FILES;
    PDUmessage(*status, 's');
    return;
    }

 *status = PDUsetup_buffer_list(PDU_file_bufr, 2, 0, &file_data_row,
                                &dummy_col,&dummy_format, &file_data_bufr);
  _pdm_status("PDUsetup_buffer_list",*status);
  if ((*status != PDM_S_SUCCESS) && (*status != PDM_E_NULL_BUFFER))
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    PDUmessage(*status, 's');
    return;
    }

 *status = PDUsetup_buffer_list(PDU_add_bufr, 2, 0, &add_data_row,
                                &dummy_col,&dummy_format, &add_data_bufr);
  _pdm_status("PDUsetup_buffer_list",*status);
  if ((*status != PDM_S_SUCCESS) && (*status != PDM_E_NULL_BUFFER))
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    PDUmessage(*status, 's');
    return;
    }

  if (PDM_debug_on)
    {
    MEMprint_buffer("file_data_bufr", file_data_bufr, PDU_DEBUG_FILE);
    MEMprint_buffer("add_data_bufr", add_data_bufr, PDU_DEBUG_FILE);
    }

  if ((spr_chg_files) && (file_data_bufr == NULL))
    {
    PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
      attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
    *status = PDM_E_NO_PART_FILES;
    PDUmessage(*status, 's');
    return;
    }

  if (spr_add_files)
    {
   *status = PDUverify_add_file_list(cpr_catalog, cpr_partnum, cpr_revision,
                                     cpr_stg_name, spr_add_files);
    _pdm_status("PDUverify_add_file_list",*status);
    if (*status != PDM_S_SUCCESS)
      {
      PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
       attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
      *status = PDM_E_NO_PART_FILES;
      PDUmessage(*status, 's');
      return;
      }

    _pdm_debug("writing file list to file buffer", 0);
   *status = PDUadd_files_to_buffer(&add_data_bufr, spr_add_files, 
                                    cpr_stg_name);
    _pdm_status("PDUadd_files_to_buffer",*status);
    if (*status != PDM_S_SUCCESS)
      {
      PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
       attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
      PDUmessage(*status, 's');
      return;
      }
    }

  if (spr_chg_files)
    {
   *status = PDUverify_change_file_list(cpr_catalog, cpr_partnum, cpr_revision,
                                        cpr_stg_name, spr_chg_files);
    _pdm_status("PDUverify_change_file_list",*status);
    if (*status != PDM_S_SUCCESS)
      {
      PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
       attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
      PDUmessage(*status, 's');
      return;
      }
    
   *status = PDUchange_files_in_buffer(&file_data_bufr, spr_chg_files);
    _pdm_status("PDUchange_files_in_buffer",*status);
    if (*status != PDM_S_SUCCESS)
      {
      PDUcleanup_change_part(cpr_catalog, cpr_partnum, cpr_revision, 
       attr_bufr, data_bufr, file_data_bufr, add_data_bufr, acl_bufr, stg_bufr);
      PDUmessage(*status, 's');
      return;
      }
    }
  
  if (file_data_bufr == NULL)
    {
    MEMclose(&file_data_bufr);
   *status = MEMopen(&file_data_bufr, 512);
    _pdm_status("MEMopen",*status);
    if (*status != MEM_S_SUCCESS)
      {
      *status = PDM_E_OPEN_BUFFER;
      PDUmessage(*status, 's');
      return;
      }
    }

  if (add_data_bufr == NULL)
    {
    MEMclose(&add_data_bufr);
   *status = MEMopen(&add_data_bufr, 512);
    _pdm_status("MEMopen",*status);
    if (*status != MEM_S_SUCCESS)
      {
      *status = PDM_E_OPEN_BUFFER;
      PDUmessage(*status, 's');
      return;
      }
    }

 *status = PDMrmodify_part(     cpr_catalog,
				cpr_partnum,
				cpr_revision,
				0,
				attr_bufr,
				data_bufr,
				file_data_bufr,
				add_data_bufr);
  _pdm_status("PDUrmodify_part",*status);

  _pdm_debug("setting the state", 0);
  status1 = PDUmessage_trans(*status, 's');
  _pdm_status("PDUmessage_trans", status1);

  if (*status != PDM_S_SUCCESS)
    {
   *status = PDMcancel_modify_part(cpr_catalog, cpr_partnum, cpr_revision,
                                   attr_bufr, data_bufr);
    _pdm_status("PDMcancel_modify_part",*status);
    }

  if (PDU_add_bufr)
    {
    MEMclose(&PDU_add_bufr);
    PDU_add_bufr = NULL;
    }
  
  if (PDU_file_bufr)
    {
    MEMclose(&PDU_file_bufr);
    PDU_file_bufr = NULL;
    }
  
  if (PDU_ret_bufr)
    {
    MEMclose(&PDU_ret_bufr);
    PDU_ret_bufr = NULL;
    }
  
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
 
   if (add_data_bufr)
      MEMclose(&add_data_bufr);

   if (list_bufr)
      MEMclose(&list_bufr);

   *status = PDM_S_SUCCESS;

  return;
}
