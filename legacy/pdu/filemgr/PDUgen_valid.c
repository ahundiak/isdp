#include "stdio.h"
#include "PDUerror.h"
#include "PDUsts_st.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "PDUintdef.h"
#include "PDUfile_def.h"
#include "PDUuser.h"
#include "PDUproto.h"
#include "PDMproto.h"

extern int change_mode;
extern short PDU_main_form_cat;
extern int bufr_flag;
extern Form PDU_form_id;
extern struct PDUuser *user;
extern MEMptr PDU_ret_bufr;

int PDUvalidate_project(project, catalog)
    char   *project;
    char   *catalog;
    {

    int  status = PDM_S_SUCCESS;

    _pdm_debug("Entering PDUvalidate_project",0);

    _pdm_debug("project to verify is <%s>", project);

       if (project == NULL)
          return(PDM_E_PROJECT_FLD_BLANK);

       if (project && (strlen(project) == 0))
          return(PDM_E_PROJECT_FLD_BLANK);

       if ( strlen(project) > 18 )
          return(PDM_E_PROJECT_FLD_TOO_LONG);

      change_mode = FALSE;
      status = PDMverify_project(project,catalog);
      _pdm_status("PDMverify_project", status);

      return(status);
    }


int PDUvalidate_catalog(project, catalog, buffer)
    char   *project;
    char   *catalog;
    short  buffer;
    {

    int  status = PDM_S_SUCCESS;

    _pdm_debug("Entering PDUvalidate_catalog",0);

    _pdm_debug("catalog to verify is <%s>", catalog);

    if (catalog == NULL)
      return(PDM_E_CAT_FIELD_BLANK);

    if (strlen(catalog) == 0)
       return(PDM_E_CAT_FIELD_BLANK);

    if ( strlen(catalog) > 16 )
       return(PDM_E_CATALOG_FIELD_TOO_LONG);

    if (isdigit (catalog[0]))
       return(PDM_E_INVALID_INPUT);

    bufr_flag = buffer;
    PDU_main_form_cat = FALSE;
    if (PDU_ret_bufr)
      {
      MEMclose(&PDU_ret_bufr);
      PDU_ret_bufr = NULL;
      }
    status = PDMrverify_catalog(project,catalog);
    _pdm_status("PDMrverify_catalog",status);

    return(status);
    }

int PDUcheck_part_syntax(partnum)
    char   *partnum;
    {
    int  char_index = 0;
    int  status = PDM_S_SUCCESS;
    char *msg = NULL;

   _pdm_debug("Entering PDUcheck_part_syntax",0);

   _pdm_debug("partnum to verify is <%s>", partnum);

    if (!partnum)
       return(PDM_E_PART_FIELD_BLANK);

    if (strlen(partnum) == 0)
       return(PDM_E_PART_FIELD_BLANK);

    _pdm_debug("parsing through string", 0);
    for (char_index = 0; char_index < (strlen(partnum)); ++char_index)
        {
        if ((partnum[char_index] == '!') ||
            (partnum[char_index] == '*') ||
            (partnum[char_index] == '?') ||
            (partnum[char_index] == ',') ||
            (partnum[char_index] == ':'))
           {
           msg = (char *)PDUtranslate_message(PDM_E_SPEC_CHAR_IN_FIELD);
           FIg_set_text(PDU_form_id,FI_MSG_FIELD, msg);
           return(PDM_E_INVALID_CHAR_IN_PART);
           }
        }

   return(status);
   }

int PDUcheck_rev_syntax(rev)
    char   *rev;
    {
    int  string_len = 0;
    int  char_index = 0;
    int  status = PDM_S_SUCCESS;
    char *msg = NULL;

    _pdm_debug("Entering PDUvalid_rev",0);

    _pdm_debug("revision to verify is <%s>", rev);

    if (!rev)
      return(PDM_E_REV_FIELD_BLANK);

    if (strlen(rev) == 0)
      return(PDM_E_REV_FIELD_BLANK);

    string_len = strlen(rev);

    for (char_index = 0; char_index < string_len; ++char_index)
        {
        if ((rev[char_index] == '!') || (rev[char_index] == '*') ||
            (rev[char_index] == '?') || (rev[char_index] == ',') ||
            (rev[char_index] == ':'))
           {
           msg = (char *)PDUtranslate_message(PDM_E_SPEC_CHAR_IN_FIELD);
           FIg_set_text(PDU_form_id,FI_MSG_FIELD,msg);
           status = PDM_E_INVALID_CHAR_IN_REV;
           PDUmessage(status, 's');
           return(PDM_E_INVALID_CHAR_IN_REV);
           }
        }

   return(status);
   }

int PDUcheck_part_datatype(partnum, attr_bufr)
  char   *partnum;
  MEMptr  attr_bufr;
{

  char   *datatype = NULL;
  char   **data_row;
  int    i;
  int    n_name_col = 0;
  int    n_datatype_col = 0;
  int    status = PDM_S_SUCCESS;

  _pdm_debug("in the function PDUcheck_part_datatype", 0);

  _pdm_debug("partnum to verify is <%s>", partnum);

  if (!partnum)
     return(PDM_E_PART_FIELD_BLANK);

  if (strlen(partnum) == 0)
     return(PDM_E_PART_FIELD_BLANK);

  status = MEMbuild_array(attr_bufr);
  _pdm_status("MEMbuild_array", status);
  status = PDUsetup_buffer(attr_bufr, ROW, &data_row);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(attr_bufr,"n_name",&n_name_col);

  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(attr_bufr,"n_datatype", &n_datatype_col);

  if (status != PDM_S_SUCCESS)
    return(status);

  for (i = 0; i < attr_bufr->rows; ++i)
     {
     if (strcmp(data_row[(attr_bufr->columns * i) + n_name_col],
         "n_itemname") == 0)
        {
        PDUfill_in_string(&datatype,
                          data_row[(attr_bufr->columns * i) + n_datatype_col]);
        _pdm_debug("datatype = <%s>", datatype);
        break;
        }
     }

  status = PDUvalidate_value(partnum,datatype);
  _pdm_status("PDUvalidate_value",status);

  return(status);
}

int PDUcheck_rev_datatype(rev, attr_bufr)
  char   *rev;
  MEMptr  attr_bufr;
{

  char   *datatype = NULL;
  char   **data_row;
  int    i;
  int    n_name_col = 0;
  int    n_datatype_col = 0;
  int    status = PDM_S_SUCCESS;

  _pdm_debug("in the function PDUcheck_rev_datatype", 0);

  _pdm_debug("revision to verify is <%s>", rev);

  if (!rev)
    return(PDM_E_REV_FIELD_BLANK);

  if (strlen(rev) == 0)
    return(PDM_E_REV_FIELD_BLANK);

  status = MEMbuild_array(attr_bufr);
  _pdm_status("MEMbuild_array", status);
  status = PDUsetup_buffer(attr_bufr, ROW, &data_row);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(attr_bufr,"n_name",&n_name_col);

  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(attr_bufr,"n_datatype", &n_datatype_col);

  if (status != PDM_S_SUCCESS)
    return(status);

  for (i = 0; i < attr_bufr->rows; ++i)
     {
     if (strcmp(data_row[(attr_bufr->columns * i) + n_name_col],
         "n_itemrev") == 0)
        {
        PDUfill_in_string(&datatype,
                          data_row[(attr_bufr->columns * i) + n_datatype_col]);
        _pdm_debug("datatype = <%s>", datatype);
        break;
        }
     }

  status = PDUvalidate_value(rev,datatype);
  _pdm_status("PDUvalidate_value",status);

  return(status);
}

int PDUcheck_desc_datatype(desc, attr_bufr)
  char   *desc;
  MEMptr  attr_bufr;
{

  char   *datatype = NULL;
  char   **data_row;
  int    i;
  int    n_name_col = 0;
  int    n_datatype_col = 0;
  int    status = PDM_S_SUCCESS;

  _pdm_debug("in the function PDUcheck_desc_datatype", 0);

  _pdm_debug("desc to verify is <%s>", desc);

  if (!desc)
    return(PDM_E_DESC_FIELD_BLANK);

  if (strlen(desc) == 0)
    return(PDM_E_DESC_FIELD_BLANK);

  status = MEMbuild_array(attr_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  status = PDUsetup_buffer(attr_bufr, ROW, &data_row);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(attr_bufr,"n_name",&n_name_col);

  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(attr_bufr,"n_datatype", &n_datatype_col);

  if (status != PDM_S_SUCCESS)
    return(status);

  for (i = 0; i < attr_bufr->rows; ++i)
     {
     if (strcmp(data_row[(attr_bufr->columns * i) + n_name_col],
         "n_itemdesc") == 0)
        {
        PDUfill_in_string(&datatype,
                          data_row[(attr_bufr->columns * i) + n_datatype_col]);
        break;
        }
     }

  if (!datatype)
     PDUfill_in_string(&datatype, "char(40)");
   else if (strcmp(datatype, "") == 0)
     PDUfill_in_string(&datatype, "char(40)");

  status = PDUvalidate_value(desc,datatype);
  _pdm_status("PDUvalidate_value",status);

  return(status);
}

int PDUvalidate_parttype(catalog, parttype)
char    *catalog;
char    *parttype;
{
   char    type[10];
   int     status = PDM_S_SUCCESS;

  _pdm_debug("in the function PDUvalidate_parttype", 0);

  _pdm_debug("parttype to verify is <%s>", parttype);

   if (!parttype)
     {
     status = PDM_E_ENTER_PARTTYPE;
     return(status);
     }

   if (strlen(parttype) == 0)
     {
     status = PDM_E_ENTER_PARTTYPE;
     return(status);
     }

   status = PDMquery_catalog_type(catalog,type);
   _pdm_status("PDMquery_catalog_type",status);

   _pdm_debug("catalog type = <%s>", type);

   if (status != PDM_S_SUCCESS)
      return(status);

   if (strcmp(type,"C") == 0)
      {
      if ((strcmp(parttype,"D") != 0) && (strcmp(parttype,"d") != 0) &&
         (strcmp(parttype,"M") != 0) && (strcmp(parttype,"m") != 0) &&
         (strcmp(parttype,"G") != 0) && (strcmp(parttype,"g") != 0) &&
         (strcmp(parttype,"N") != 0) && (strcmp(parttype,"n") != 0))
         {
         status = PDM_E_INVALID_PARTTYPE;
         return(status);
         }
      }
 
   if ((strcmp(type,"P") == 0) || (strcmp(type,"CID") == 0) ||
       (strcmp(type,"EID") == 0) || (strcmp(type,"PXT") == 0))
      {
      status = PDM_E_PARAM_PART_API;
      return(status);
      }

   if (strcmp(type,"EXT") == 0)
      {
      if ((strcmp(parttype,"P") != 0) && (strcmp(parttype,"p") != 0) &&
         (strcmp(parttype,"G") != 0) && (strcmp(parttype,"g") != 0) &&
         (strcmp(parttype,"N") != 0) && (strcmp(parttype,"n") != 0))
         {
         status = PDM_E_INVALID_PARTTYPE;
         return(status);
         }
      }

  return(status);
}

int PDUverify_file_desc(file_desc)
char   *file_desc;
{

  int   status = PDM_S_SUCCESS;

  _pdm_debug("in the function PDUverify_file_desc", 0);

  _pdm_debug("filedesc to verify is <%s>", file_desc);

  if (!file_desc)
    return(PDM_E_FILEDESC_BLANK);

  if (strlen(file_desc) > 40)
    status = PDM_E_FILE_DESC_TOO_LONG;

  return(status);
}

int PDUverify_addpart_filename(filename)
char   *filename;
{
  int   status = PDM_S_SUCCESS;
  char  spec_char;

  _pdm_debug("in the function PDUverify_addpart_filename", 0);

  _pdm_debug("filename to verify is <%s>", filename);

  if (!filename)
    {
    status = PDM_E_FILENAME_BLANK;
    return(status);
    }

  if (strlen(filename) == 0)
    {
    status = PDM_E_FILENAME_BLANK;
    return(status);
    }

  if (strlen(filename) > 14)
    {
    status = PDM_E_FILENAME_TOO_LONG;
    return(status);
    }

  status = PDUcheck_char(filename,&spec_char);
  _pdm_status("PDUcheck_char",status);

  if (status != PDM_S_SUCCESS)
    status = PDM_E_INVALID_CHAR_IN_FILENAME;

  return(status);
}

int PDUverify_filetype(filetype)
char   *filetype;
{

  int   status = PDM_S_SUCCESS;
  char  spec_char;

  _pdm_debug("in the function PDUverify_filetype", 0);

  _pdm_debug("filetype to verify is <%s>", filetype);

  if (!filetype)
    return(status);

  if (strlen(filetype) == 0)
    return(status);

  if (strlen(filetype) > 5)
    {
    status = PDM_E_FILETYPE_TOO_LONG;
    return(status);
    }

  if ((strcmp(filetype,"M") == 0) || (strcmp(filetype,"m") == 0))
    {
    status = PDM_E_INVALID_FILETYPE;
    return(status);
    }

  status = PDUcheck_char(filetype,&spec_char);
  _pdm_status("PDUcheck_char",status);

  if (status != PDM_S_SUCCESS)
    status = PDM_E_INVALID_FILETYPE;

  return(status);
}

int PDUverify_aclname(aclname, aclno, acl_bufr)
char   *aclname;
char   aclno[5];
MEMptr  acl_bufr;
{
  int   status = PDM_S_SUCCESS;
  int   aclname_col = 0;
  int   aclno_col = 0;
  int   i = 0;
  short found = FALSE;
  char  **data_row;

  _pdm_debug("in the function PDUverify_aclname", 0);

  if (!acl_bufr)
    return(PDM_E_NULL_BUFFER);

  if (aclname == NULL)
    return(PDM_E_ACL_NAME_BLANK);

  if (strlen(aclname) == 0)
    return(PDM_E_ACL_NAME_BLANK);

  if (PDM_debug_on)
  MEMprint_buffer("acl buffer", acl_bufr, PDU_DEBUG_FILE);

  status = MEMbuild_array(acl_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  status = PDUsetup_buffer(acl_bufr, ROW, &data_row);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(acl_bufr, "n_aclname", &aclname_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(acl_bufr, "n_aclno", &aclno_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  _pdm_debug("acl_name to verify is <%s>", aclname);

  if (PDM_debug_on)
  MEMprint_buffer("acl buffer", acl_bufr, PDU_DEBUG_FILE);

  for (i = 0; i < acl_bufr->rows; ++i)
     {
     if (strcmp(aclname, data_row[(acl_bufr->columns * i) + aclname_col]) == 0)
       {
       strcpy(aclno, data_row[(acl_bufr->columns * i) + aclno_col]);
       _pdm_debug("aclno = %s", aclno);
       found = TRUE;
       break;
       }
     }

  if (!found)
    return(PDM_E_ACLNAME_NOT_FOUND);

  return(status);
}

int PDUverify_storage_name(stgname, stgno, stg_bufr)
char   *stgname;
char   stgno[5];
MEMptr  stg_bufr;
{
  int   status = PDM_S_SUCCESS;
  int   stgname_col = 0;
  int   stgno_col = 0;
  int   i = 0;
  short found = FALSE;
  char  **data_row;

  _pdm_debug("in the function PDUverify_storage_name", 0);

  if (!stg_bufr)
    return(PDM_E_NULL_BUFFER);

  if (stgname == NULL)
    return(PDM_E_STG_NAME_BLANK);

  if (strlen(stgname) == 0)
    return(PDM_E_STG_NAME_BLANK);

  status = MEMbuild_array(stg_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  status = PDUsetup_buffer(stg_bufr, ROW, &data_row);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(stg_bufr, "n_saname", &stgname_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(stg_bufr, "n_sano", &stgno_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  _pdm_debug("storage name to verify is <%s>", stgname);

  if (PDM_debug_on)
  MEMprint_buffer("storage buffer", stg_bufr, PDU_DEBUG_FILE);

  for (i = 0; i < stg_bufr->rows; ++i)
     {
     if (strcmp(stgname, data_row[(stg_bufr->columns * i) + stgname_col]) == 0)
       {
       strcpy(stgno,data_row[(stg_bufr->columns * i) + stgno_col]);
       _pdm_debug("stgno = %s", stgno);
       found = TRUE;
       break;
       }
     }

  if (!found)
    return(PDM_E_STGNAME_NOT_FOUND);

  return(status);
}

void PDUunlock_item(catalog, part, revision)
char   *catalog;
char   *part;
char   *revision;
{
  char sql_str[512];

  _pdm_debug("in the function PDUunlock_item", 0);

  sql_str[0] = '\0';
  sprintf (sql_str, 
  "UPDATE %s SET n_itemlock = 'N' WHERE n_itemname = '%s' AND n_itemrev = '%s'",
   catalog,part,revision);

  _pdm_debug("sql_str = <%s>", sql_str);

  SQLstmt(sql_str);

  return;
}

int PDUget_storage_name(stgname, stgno, stg_bufr, data_bufr)
char   **stgname;
char   stgno[5];
MEMptr  stg_bufr;
MEMptr  data_bufr;
{
  int   status = PDM_S_SUCCESS;
  int   stgname_col = 0;
  int   stgno_col = 0;
  int   stg_col = 0;
  int   row = 0;
  char  **data_row;

  _pdm_debug("in the function PDUget_storage_name", 0);

  if ((!stg_bufr) || (!data_bufr))
    return(PDM_E_NULL_BUFFER);

  status = MEMbuild_array(data_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  status = PDUsetup_buffer(data_bufr, ROW, &data_row);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(data_bufr, "n_cisano", &stg_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  _pdm_debug("getting storage number from data buffer", 0);
  strcpy(stgno,data_row[(data_bufr->columns * 0) + stg_col]);
  _pdm_debug("stgno = %s", stgno);

  status = MEMbuild_array(stg_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  status = PDUsetup_buffer(stg_bufr, ROW, &data_row);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(stg_bufr, "n_saname", &stgname_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(stg_bufr, "n_sano", &stgno_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  if (PDM_debug_on)
  MEMprint_buffer("storage buffer", stg_bufr, PDU_DEBUG_FILE);

  _pdm_debug("searching for storage name in storage buffer", 0);
  for (row = 0; row < stg_bufr->rows; ++row)
     {
     if (strcmp(stgno, data_row[(stg_bufr->columns * row) + stgno_col]) == 0)
       {
       _pdm_debug("matching storage number found", 0);
       PDUfill_in_string(stgname,
                         data_row[(stg_bufr->columns * row) + stgname_col]);
       _pdm_debug("stgname = %s", *stgname);
       }
     }

  return(status);
}

int PDUget_acl_name(aclname, aclno, acl_bufr)
char   **aclname;
char   aclno[5];
MEMptr  acl_bufr;
{
  int   status = PDM_S_SUCCESS;
  int   aclname_col = 0;
  int   aclno_col = 0;
  char  **data_row;

  _pdm_debug("in the function PDUget_acl_name", 0);

  if (!acl_bufr)
    return(PDM_E_NULL_BUFFER);

  status = MEMbuild_array(acl_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  status = PDUsetup_buffer(acl_bufr, ROW, &data_row);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(acl_bufr, "n_aclname", &aclname_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(acl_bufr, "n_aclno", &aclno_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  if (PDM_debug_on)
  MEMprint_buffer("acl buffer", acl_bufr, PDU_DEBUG_FILE);

  strcpy(aclno,data_row[(acl_bufr->columns * 0) + aclno_col]);
  PDUfill_in_string(aclname,data_row[(acl_bufr->columns * 0) + aclname_col]);
  _pdm_debug("aclno = %s", aclno);
  _pdm_debug("aclname = %s", *aclname);

  return(status);
}
