#include "PDUerror.h"
#include "MEMerrordef.h"
#include "PDUstr.h"
#include "PDUintdef.h"
#include "PDUfile_def.h"
#include "PDUproto.h"
#include "PDMproto.h"

extern MEMptr   PDU_ret_bufr;
extern struct   PDUrefresh    *refresh;
extern int bufr_flag;
extern int      PDMdebug_on;
extern short    PDU_main_form_cat;

void PDUm_add_part(status,
                  cpr_catalog,
                  cpr_partnum,
                  cpr_revision,
                  cpr_parttype,
                  cpr_description,
                  cpr_acl_name,
                  cpr_stg_name,
                  spr_attrs,
                  spr_files)

int    *status;
char    *cpr_catalog;
char    *cpr_partnum;
char    *cpr_revision;
char    *cpr_parttype;
char    *cpr_description;
char    *cpr_acl_name;
char    *cpr_stg_name;
struct   PDUattribute_info *spr_attrs;
struct   file_info      *spr_files;

{
  long   status1 = PDM_S_SUCCESS;
  int    name_col = 0;
  int    syn_col = 0;
  int    type_col = 0;
  int    itemname_col = 0;
  int    rev_col = 0;
  int    parttype_col = 0;
  int    desc_col = 0;
  int    aclno_col = 0;
  int    acl_buffer_no = 0;
  int    stg_buffer_no = 0;
  int    cisano_col = 0;
  int    saname_col = 0;
  int    valueno_col = 0;
  int    aclname_col = 0;
  int    i = 0;
  short  found = 0;
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
  char   aclno[5];
  char   stgno[5];
  MEMptr attr_bufr = NULL;
  MEMptr data_bufr = NULL;
  MEMptr list_bufr = NULL;
  MEMptr acl_bufr = NULL;
  MEMptr stg_bufr = NULL;
  MEMptr file_data = NULL;


  _pdm_debug("in the function PDUm_add_part", 0);

  refresh->command = PDC_M_CREATE_ELEMENT;

  _pdm_debug("verifying login", 0);

  _pdm_debug("validating catalog", 0);
  PDU_main_form_cat = FALSE;
 *status = PDUvalidate_catalog("", cpr_catalog, 1);
  _pdm_status("PDUvalidate_catalog",*status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUmessage(*status, 's');
    return;
    }

  _pdm_debug("validating access", 0);
 *status = PDMvalidate_user_access ( "PDMAdd Part", NULLSTR, cpr_catalog,
                                      NULLSTR, NULLSTR, NULLSTR );
  _pdm_status("PDMvalidate_access",*status);
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
    PDUmessage(*status, 's');
    return;
    }
 
 *status = PDUsetup_buffer_list(PDU_ret_bufr, 2, 0, &data2_row,
                                &data2_col,&data2_format,&data_bufr);
  _pdm_status("PDUsetup_buffer_list",status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUmessage(*status, 's');
    return;
    }

 *status = MEMsplit_copy_buffer(PDU_ret_bufr, &list_bufr, 1);
  _pdm_status("MEMsplit_copy_buffer",*status);
  if (*status != MEM_S_SUCCESS)
    {
    *status = PDM_E_COPY_BUFFER;
    PDUmessage(*status, 's');
    return;
    }

 *status = MEMbuild_array(list_bufr);
  _pdm_status("MEMbuild_array",*status);
  if (*status != MEM_S_SUCCESS)
    {
    *status = PDM_E_BUILD_BUFFER_ARRAY;
    PDUmessage(*status, 's');
    return;
    }

 *status = PDUget_col_number(attr_bufr,"n_name",data1_col,&name_col);
  _pdm_status("PDUget_col_number",status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUmessage(*status, 's');
    return;
    }

 *status = PDUget_col_number(attr_bufr,"n_synonym",data1_col, &syn_col);
  _pdm_status("PDUget_col_number",status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUmessage(*status, 's');
    return;
    }
 
 *status = PDUget_col_number(attr_bufr,"n_datatype",data1_col, &type_col);
  _pdm_status("PDUget_col_number",status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUmessage(*status, 's');
    return;
    }
 
 *status = PDUget_col_number(attr_bufr,"n_valueno",data1_col, &valueno_col);
  _pdm_status("PDUget_col_number",status);
  if (*status != PDM_S_SUCCESS)
    {
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
    PDUmessage(*status, 's');
    return;
    }
 
 *status = MEMbuild_array(acl_bufr);
  _pdm_status("MEMbuild_array",*status);
  if (*status != MEM_S_SUCCESS)
    {
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
    PDUmessage(*status, 's');
    return;
    }

 *status = MEMbuild_array(stg_bufr);
  _pdm_status("MEMbuild_array",*status);
  if (*status != MEM_S_SUCCESS)
    {
    *status = PDM_E_BUILD_BUFFER_ARRAY;
    PDUmessage(*status, 's');
    return;
    }

  _pdm_debug("validating partnum", 0);
 *status = PDUcheck_part_syntax(cpr_partnum);
  _pdm_status("PDUcheck_part_syntax",*status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUmessage(*status, 's');
    return;
    }

 *status = PDUcheck_part_datatype(cpr_partnum, attr_bufr);
  _pdm_status("PDUcheck_part_datatype",*status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUmessage(*status, 's');
    return;
    }

  _pdm_debug("validating revision", 0);
 *status = PDUcheck_rev_syntax(cpr_revision);
  _pdm_status("PDUcheck_rev_syntax",*status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUmessage(*status, 's');
    return;
    }

 *status = PDUcheck_rev_datatype(cpr_revision, attr_bufr);
  _pdm_status("PDUcheck_rev_datatype",*status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUmessage(*status, 's');
    return;
    }

 *status = PDMcheck_partnum(cpr_catalog, cpr_partnum, cpr_revision);
  _pdm_status("PDMcheck_partnum",status);
  MEMclose(&PDU_ret_bufr); PDU_ret_bufr = NULL;
  if (*status == PDM_S_SUCCESS)
    {
    *status = PDM_E_PART_EXISTS;
    PDUmessage(*status, 's');
    return;
    }
  else if (*status == PDM_E_PARTREV_NOT_FOUND)
   *status = PDM_S_SUCCESS;
  else if (*status != PDM_S_SUCCESS)
    {
    PDUmessage(*status, 's');
    return;
    }

  _pdm_debug("validating description", 0);
  if (cpr_description && (strlen(cpr_description)))
    {
   *status = PDUcheck_desc_datatype(cpr_description, attr_bufr);
    _pdm_status("PDUcheck_desc_datatype",*status);
    if (*status != PDM_S_SUCCESS)
      {
      PDUmessage(*status, 's');
      return;
      }
    }

  _pdm_debug("validating parttype", 0);
 *status = PDUvalidate_parttype(cpr_catalog, cpr_parttype);
  _pdm_status("PDMvalidate_parttype",*status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUmessage(*status, 's');
    return;
    }

  if (((strcmp(cpr_parttype, "N") == 0) || (strcmp(cpr_parttype, "n") == 0)) &&
     (spr_files))
    {
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
    PDUmessage(*status, 's');
    return;
    }

 if (PDMdebug_on)
   MEMprint_buffer("data_bufr", data_bufr, PDU_DEBUG_FILE);

 *status = MEMbuild_array(data_bufr);
  _pdm_status("MEMbuild_array",*status);
  if (*status != MEM_S_SUCCESS)
    {
    *status = PDM_E_BUILD_BUFFER_ARRAY;
    PDUmessage(*status, 's');
    return;
    }

 *status = PDUget_buffer_col(data_bufr,"n_aclno", &aclno_col);
  _pdm_status("PDUget_buffer_col",*status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUmessage(*status, 's');
    return;
    }

 *status = PDUget_buffer_col(acl_bufr,"n_aclname", &aclname_col);
  _pdm_status("PDUget_buffer_col",*status);
  if (*status != PDM_S_SUCCESS)
    {
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
    PDUmessage(*status, 's');
    return;
    }

 if (PDMdebug_on)
   MEMprint_buffer("data_bufr", data_bufr, PDU_DEBUG_FILE);

 *status = MEMbuild_array(data_bufr);
  _pdm_status("MEMbuild_array",*status);
  if (*status != MEM_S_SUCCESS)
    {
    *status = PDM_E_BUILD_BUFFER_ARRAY;
    PDUmessage(*status, 's');
    return;
    }

 *status = PDUget_buffer_col(data_bufr,"n_cisano", &cisano_col);
  _pdm_status("PDUget_buffer_col",*status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUmessage(*status, 's');
    return;
    }
  
 *status = PDUget_buffer_col(stg_bufr,"n_saname", &saname_col);
  _pdm_status("PDUget_buffer_col",*status);
  if (*status != PDM_S_SUCCESS)
    {
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

  _pdm_debug("writing part information to data buffer", 0);

 if (PDMdebug_on)
   MEMprint_buffer("data_bufr", data_bufr, PDU_DEBUG_FILE);

 *status = MEMbuild_array(data_bufr);
  _pdm_status("MEMbuild_array",*status);
  if (*status != MEM_S_SUCCESS)
    {
    *status = PDM_E_BUILD_BUFFER_ARRAY;
    PDUmessage(*status, 's');
    return;
    }

 *status = PDUget_buffer_col(data_bufr,"n_itemname", &itemname_col);
  _pdm_status("PDUget_buffer_col",*status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUmessage(*status, 's');
    return;
    }

 *status = PDUget_buffer_col(data_bufr,"n_itemrev", &rev_col);
  _pdm_status("PDUget_buffer_col",*status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUmessage(*status, 's');
    return;
    }

 *status = PDUget_buffer_col(data_bufr,"p_parttype", &parttype_col);
  _pdm_status("PDUget_buffer_col",*status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUmessage(*status, 's');
    return;
    }

 *status = PDUget_buffer_col(data_bufr,"n_itemdesc", &desc_col);
  _pdm_status("PDUget_buffer_col",*status);
  if (*status != PDM_S_SUCCESS)
    {
    PDUmessage(*status, 's');
    return;
    }

 *status = MEMwrite_data(data_bufr,cpr_partnum,1,itemname_col + 1);
  _pdm_status("MEMwrite_data",*status);
  if (*status != MEM_S_SUCCESS)
    {
    *status = PDM_E_WRITE_BUFFER;
    PDUmessage(*status, 's');
    return;
    }

 *status = MEMwrite_data(data_bufr,cpr_revision,1,rev_col + 1);
  _pdm_status("MEMwrite_data",*status);
  if (*status != MEM_S_SUCCESS)
    {
    *status = PDM_E_WRITE_BUFFER;
    PDUmessage(*status, 's');
    return;
    }

 *status = MEMwrite_data(data_bufr,cpr_parttype,1,parttype_col + 1);
  _pdm_status("MEMwrite_data",*status);
  if (*status != MEM_S_SUCCESS)
    {
    *status = PDM_E_WRITE_BUFFER;
    PDUmessage(*status, 's');
    return;
    }

 *status = MEMwrite_data(data_bufr,cpr_description,1,desc_col + 1);
  _pdm_status("MEMwrite_data",*status);
  if (*status != MEM_S_SUCCESS)
    {
    *status = PDM_E_WRITE_BUFFER;
    PDUmessage(*status, 's');
    return;
    }

 if (PDMdebug_on)
   MEMprint_buffer("data_bufr", data_bufr, PDU_DEBUG_FILE);

 *status = MEMbuild_array(data_bufr);
  _pdm_status("MEMbuild_array",*status);
  if (*status != MEM_S_SUCCESS)
    {
    *status = PDM_E_BUILD_BUFFER_ARRAY;
    PDUmessage(*status, 's');
    return;
    }

  _pdm_debug("verifying file list", 0);
  if (spr_files)
    {
   *status = PDUverify_add_file_list(cpr_catalog, cpr_partnum, cpr_revision,
                                     cpr_stg_name, spr_files);
    _pdm_status("PDUverify_file_list",*status);
    if (*status != PDM_S_SUCCESS)
      {
      PDUmessage(*status, 's');
      return;
      }
    }

  _pdm_debug("verifying attr list", 0);
  if (spr_attrs)
    {
   *status = PDUverify_PDUattr_list(spr_attrs,attr_bufr,
                                    list_bufr,&data_bufr,ADD);
    _pdm_status("PDUverify_attr_list",*status);
    if (*status != PDM_S_SUCCESS)
      {
      PDUmessage(*status, 's');
      return;
      }
    }

  if (spr_files)
    {
    _pdm_debug("writing file list to file buffer", 0);
   *status = PDUadd_files_to_buffer(&file_data, spr_files, cpr_stg_name);
    _pdm_status("PDUadd_files_to_buffer",*status);
    if (*status != PDM_S_SUCCESS)
      {
      PDUmessage(*status, 's');
      return;
      }
    }

  _pdm_debug("calling PDMadd_part", 0);
 *status = PDMradd_part("", cpr_catalog, cpr_partnum, cpr_revision, 
                        attr_bufr, data_bufr, file_data);
  _pdm_status("PDMadd_part",*status);

  _pdm_debug("setting the state", 0);
  status1 = PDUmessage_trans(*status, 's');
  _pdm_status("PDUmessage_trans", status1);

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

  if (file_data)
    MEMclose(&file_data);

   PDUmessage(*status,'s');
   return;
}

void PDUload_file_structure(    status,
                                cpr_desc,
                                cpr_localfn,
                                cpr_stgfn,
                                cpr_type,
                                ir_mode,
                                spm_file_list)
int    *status;
char   *cpr_desc;
char   *cpr_localfn;
char   *cpr_stgfn;
char   *cpr_type;
int     ir_mode;
struct file_info **spm_file_list;
{
 
  struct file_info *tail, *temp, *head;
  struct file_info *current = NULL;
 
  _pdm_debug("in the function PDUload_file_structure", 0);

  *status = PDM_S_SUCCESS;
 
  if (cpr_desc == NULL)
    cpr_desc = NULL_STRING;
  if (cpr_localfn == NULL)
    cpr_localfn = NULL_STRING;
  if (cpr_stgfn == NULL)
    cpr_stgfn = NULL_STRING;
  if (cpr_type == NULL)
    cpr_type = NULL_STRING;
 
  if (strcmp(cpr_localfn, "") == 0)
    {
    _pdm_debug("local filename is blank", 0);
    *status = PDM_E_FILENAME_BLANK;
    PDUmessage(*status, 's');
    return;
    }
 
  current = *spm_file_list;
  _pdm_debug("checking for duplicate filenames", 0);
  if (*spm_file_list)
    {
    _pdm_debug("checking for duplicate filenames", 0);
    while (current)
      {
      if (strcmp(cpr_localfn, current->local_fn) == 0)
        {
        _pdm_debug("filename is duplicate", 0);
        *status = PDM_E_DUPLICATE_FILENAME;
        PDUmessage(*status, 's');
        return;
        }
      if ((strcmp(cpr_stgfn, current->storage_fn) == 0) &&
          (strcmp(cpr_stgfn, "") != 0))
        {
        _pdm_debug("filename is duplicate", 0);
        *status = PDM_E_DUPLICATE_FILENAME;
        PDUmessage(*status, 's');
        return;
        }
      current = current->next;
      }
    }
 
  temp = NULL;
  tail = NULL;
  head = NULL;
 
  temp = (struct file_info *)malloc(sizeof(struct file_info));
  temp->next = NULL;
  temp->file_desc[0] = '\0';
  temp->local_fn[0] = '\0';
  temp->storage_fn[0] = '\0';
  temp->file_type[0] = '\0';
  temp->mode = 0;
 
  strcpy((temp->file_desc), cpr_desc);
  strcpy((temp->local_fn), cpr_localfn);
  strcpy((temp->storage_fn), cpr_stgfn);
  strcpy((temp->file_type), cpr_type);
 
  temp->mode = ir_mode;
 
  if (*spm_file_list)
    {
    tail = *spm_file_list;
    while (tail)
      {
      head = tail;
      tail = tail->next;
      }
    head->next = temp;
    }
  else
    *spm_file_list = temp;
 
  if ((*spm_file_list) && (PDMdebug_on))
    PDUprint_file_list(*spm_file_list);

  *status = PDM_S_SUCCESS;
 
  return;
}

void PDUload_change_structure(		status,
                                        cpr_desc, 
					cpr_chg_desc, 
					cpr_localfn, 
					cpr_chg_localfn, 
					cpr_stgfn, 
					cpr_chg_stgfn, 
					cpr_type, 
					cpr_chg_type, 
					ir_mode, 
					spm_chg_list)
int    *status;
char   *cpr_desc;
char   *cpr_chg_desc;
char   *cpr_localfn;
char   *cpr_chg_localfn;
char   *cpr_stgfn;
char   *cpr_chg_stgfn;
char   *cpr_type;
char   *cpr_chg_type;
int     ir_mode;
struct chg_file_info **spm_chg_list;
{

  struct chg_file_info *tail, *temp, *head;
  struct chg_file_info *current = NULL;

  _pdm_debug("in the function PDUload_change_structure", 0);

  *status = PDM_S_SUCCESS;

  ir_mode = 2;

  if (cpr_chg_desc == NULL)
    cpr_chg_desc = NULL_STRING;
  if (cpr_chg_localfn == NULL)
    cpr_chg_localfn = NULL_STRING;
  if (cpr_chg_stgfn == NULL)
    cpr_chg_stgfn = NULL_STRING;
  if (cpr_chg_type == NULL)
    cpr_chg_type = NULL_STRING;

  if (cpr_desc == NULL)
    cpr_desc = NULL_STRING;
  if (cpr_localfn == NULL)
    cpr_localfn = NULL_STRING;
  if (cpr_stgfn == NULL)
    cpr_stgfn = NULL_STRING;
  if (cpr_type == NULL)
    cpr_type = NULL_STRING;

  if ((strcmp(cpr_chg_desc, "") == 0) &&
      (strcmp(cpr_chg_localfn, "") == 0) &&
      (strcmp(cpr_chg_stgfn, "") == 0) &&
      (strcmp(cpr_chg_type, "") == 0))
    {
    *status = PDM_E_REQUIRED_DATA;
    PDUmessage(*status, 's');
    return;
    }

  else if ((strcmp(cpr_desc, "") == 0) &&
           (strcmp(cpr_localfn, "") == 0) &&
           (strcmp(cpr_stgfn, "") == 0) &&
           (strcmp(cpr_type, "") == 0))
    {
    *status = PDM_E_REQUIRED_DATA;
    PDUmessage(*status, 's');
    return;
    }

  current = *spm_chg_list;
  if (*spm_chg_list)
    {
    _pdm_debug("checking for duplicate filenames", 0);
    while (current)
      {
      if ((strlen(current->chg_local_fn)) &&
          (strcmp(cpr_chg_localfn, current->chg_local_fn) == 0))
        {
        *status = PDM_E_DUPLICATE_FILENAME;
        PDUmessage(*status, 's');
        return;
        }
      if ((strlen(current->chg_storage_fn)) &&
          (strcmp(cpr_chg_stgfn, current->chg_storage_fn) == 0))
        {
        *status = PDM_E_DUPLICATE_FILENAME;
        PDUmessage(*status, 's');
        return;
        }
      current = current->next;
      }
    }

  temp = NULL;
  tail = NULL;
  head = NULL;

  temp = (struct chg_file_info *)malloc(sizeof(struct chg_file_info));
  temp->next = NULL;
  temp->file_desc[0] = '\0';
  temp->chg_file_desc[0] = '\0';
  temp->local_fn[0] = '\0';
  temp->chg_local_fn[0] = '\0';
  temp->storage_fn[0] = '\0';
  temp->chg_storage_fn[0] = '\0';
  temp->file_type[0] = '\0';
  temp->chg_file_type[0] = '\0';
  temp->mode = 0;

  strcpy((temp->file_desc), cpr_desc);
  strcpy((temp->chg_file_desc), cpr_chg_desc);
  strcpy((temp->local_fn), cpr_localfn);
  strcpy((temp->chg_local_fn), cpr_chg_localfn);
  strcpy((temp->storage_fn), cpr_stgfn);
  strcpy((temp->chg_storage_fn), cpr_chg_stgfn);
  strcpy((temp->file_type), cpr_type);
  strcpy((temp->chg_file_type), cpr_chg_type);

  /* mode = 2 for CHANGE */
  temp->mode = 2;

  if (*spm_chg_list)
    {
    tail = *spm_chg_list;
    while (tail)
      {
      head = tail;
      tail = tail->next;
      }
    head->next = temp;
    }
  else
    *spm_chg_list = temp;

  if ((*spm_chg_list) && (PDMdebug_on))
    PDUprint_change_list(*spm_chg_list);

  return;
}

void PDUfree_file_structure(status, file_list)
int    *status;
struct file_info **file_list;
{
  struct file_info * head = NULL;

  _pdm_debug("in the function PDUfree_file_structure", 0);
 
  if (*file_list)
    {
    head = *file_list;
    while (*file_list)
      {
      *file_list = (*file_list)->next;
      free(head);
      head = *file_list;
      }
    *file_list = NULL;
    }
  else
    {
    *status = PDM_E_NULL_FILE_LIST;
    PDUmessage(*status, 's');
    return;
    }

  *status = PDM_S_SUCCESS;
  return;
}

void PDUfree_change_file_structure(status, file_list)
int    *status;
struct chg_file_info **file_list;
{
  struct chg_file_info * head = NULL;
 
  _pdm_debug("in the function PDUfree_change_file_structure", 0);

  if (*file_list)
    {
    head = *file_list;
    while (*file_list)
      {
      *file_list = (*file_list)->next;
      free(head);
      head = *file_list;
      }
    *file_list = NULL;
    }
  else
    {
    *status = PDM_E_NULL_FILE_LIST;
    PDUmessage(*status, 's');
    return;
    }

  *status = PDM_S_SUCCESS;
  return;
}
