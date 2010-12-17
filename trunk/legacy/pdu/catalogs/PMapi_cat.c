#include "PDUerror.h"
#include "MEMerrordef.h"
#include "PDUstr.h"
#include "PDUintdef.h"
#include "PDMtypes.h"
#include "PDUfile_def.h"
#include "PDUproto.h"
#include "PDMproto.h"

extern int PDU_command;
extern int bufr_flag;
extern int PDU_view;
extern int PDU_parm_cat;
extern int PDMdebug_on;
extern char *PDU_cat_aclno;
extern char *PDU_template_catalog;
extern char *PDU_cat_atr;
extern char *PDU_cat_data;
extern char *PDU_cat_list;
extern char *PDU_dyn_attr;
extern char *PDU_dyn_data;
extern MEMptr PDU_cat_class_bufr;

void pdmoCreateCatalog(status,catalog, description, acl_name,temp_cat,
                       static_attr,dynamic_attr, catalog_type)

  int  *status;
  char *catalog; 
  char *description;
  char *acl_name;
  char *temp_cat;
  struct PDUattribute_info *static_attr;
  struct PDUattribute_info *dynamic_attr;
  char *catalog_type;

  {
  MEMptr acl_bufr = NULL;
  MEMptr ret_bufr = NULL;
  MEMptr cat_attr = NULL;
  MEMptr cat_data = NULL;
  MEMptr cat_list = NULL;
  MEMptr dyn_attr = NULL;
  MEMptr dyn_data = NULL;
  MEMptr dyn_list = NULL;
  MEMptr loc_attr = NULL;
  MEMptr loc_data = NULL;
  MEMptr loc_list = NULL;
  int    i;
  int    FOUND;
  int    char_index;
  int    attr_row;
  long   status1;
  char   **acl_data;
  char   *row = NULL;
  char   *dynamic_table = NULL;

  _pdm_debug("In pdmoCreateCatalog", 0);

  /* check catalog for existence */
  bufr_flag = FALSE;
  
  PDUload_exec_structure("", catalog, "", "", "", "", "", 0, 0);
  *status =  PDMverify_catalog(&ret_bufr);
  _pdm_status("PDMverify_catalog", *status);

  if (*status == PDM_S_SUCCESS)
    {
    *status = PDM_E_CATALOG_EXISTS;
    return;
    }

  if (ret_bufr)
    MEMclose(&ret_bufr);

  /* check template catalog for existence */
  if ((temp_cat) && (strcmp(temp_cat, "") != 0))
    {
    bufr_flag = FALSE;

    PDUload_exec_structure("", temp_cat, "", "", "", "", "", 0, 0);
    *status  = PDMverify_catalog(&ret_bufr);
    _pdm_status("PDMverify_catalog", *status);

    if (*status != PDM_S_SUCCESS)
      {
      *status = PDM_E_CATALOG_NOT_FOUND;
      return;
      }

    if (ret_bufr)
      MEMclose(&ret_bufr); 

    PDUfill_in_string(&PDU_template_catalog,temp_cat);
    PDU_command = PDC_M_CREATE_LIKE_CATALOG;
    PDU_view = FALSE;
    PDU_parm_cat = FALSE;
   }
 else
   {
    PDU_command = PDC_M_CREATE_CATALOG;
    PDU_view = FALSE;
    PDU_parm_cat = FALSE;
   }

  if ((catalog_type) && (strcmp(catalog_type, "P") == 0))
    PDU_parm_cat = TRUE;

  /* get default acl */
  PDUload_exec_structure("", "", "", "", "", "", "", 0, 0);
  *status = PDMshow_catalog_acls(&acl_bufr);
  if (*status != PDM_S_SUCCESS)
    return;

  *status = MEMbuild_array(acl_bufr);
  _pdm_status("MEMbuild_array", *status);

  if (*status != MEM_S_SUCCESS)
    {
    if (acl_bufr)
      MEMclose(&acl_bufr);
    *status = PDM_E_BUILD_BUFFER_ARRAY;
    return;
    }

  acl_data = (char **)acl_bufr->data_ptr;
  FOUND = FALSE;
  for (i = 0; i < acl_bufr->rows; i++)
    if (strcmp(acl_data[(acl_bufr->columns * i) + 1], acl_name) == 0)
      {
      PDUfill_in_string(&PDU_cat_aclno, acl_data[(acl_bufr->columns * i)]);
      FOUND = TRUE;
      break;
      }
    
  if (!FOUND)
    {
    *status = PDM_E_ACLWF_NOT_FOUND;
    if (acl_bufr)
      MEMclose(&acl_bufr);
    return;
    }

  /* call PDUcreate_catalog */
  *status = PDMvalidate_user_access ( "Create Catalog", NULLSTR,
                                     catalog, NULLSTR, NULLSTR, NULLSTR);
  _pdm_status ("PDMvalidate_user_access", status);

  if (*status != PDM_S_SUCCESS)
    return;

  /* get system attributes */
  
  if (PDU_command == PDC_M_CREATE_CATALOG)
    PDUload_exec_structure("", "pdmcatalog", "", "", "", "", "", ADD_TABLE, 
                           PDM_CATALOG);
  else
    PDUload_exec_structure("", "pdmcatalog", "", "", "", "", "", ADD_TABLE, 
                           PDM_CATALOG);
  *status = PDMsget_table_attributes(&cat_attr, &cat_data, &cat_list);
  _pdm_status("PDMsget_table_attributes", *status);

  if (*status != PDM_S_SUCCESS)
    return;

  PDU_cat_atr = (char *)cat_attr;
  PDU_cat_data = (char *)cat_data;
  PDU_cat_list = (char *)cat_list;
  PDU_dyn_attr = (char *)dyn_attr;
  PDU_dyn_data = (char *)dyn_data;
  /* if static attributes add to list */
  if (static_attr)
    {
    *status = PDUadd_static_attributes(static_attr);
    _pdm_status("PDUadd_static_attributes", *status);
 
   if (*status != PDM_S_SUCCESS)
     return;
   }

  if (dynamic_attr)
    {
    *status = PDUadd_dynamic_attributes(dynamic_attr);
    _pdm_status("PDUadd_dynamic_attributes", *status);
 
   if (*status != PDM_S_SUCCESS)
     return;
   }

  if (PDU_cat_class_bufr)
    {
    MEMclose(&PDU_cat_class_bufr);
    PDU_cat_class_bufr = NULL;
    }

  *status = PDUformat_cat_class_bufr(0, &PDU_cat_class_bufr);
  _pdm_status("PDUformat_cat_class_bufr", *status);

  if (*status != PDM_S_SUCCESS)
    return;

  row = (char *)malloc(PDU_cat_class_bufr->row_size);
  memset(row, NULL, PDU_cat_class_bufr->row_size);
  char_index = 0;
  PDUadd_buffer_string(row, &char_index, catalog);

  row[char_index++] = '\1';

  *status = MEMwrite(PDU_cat_class_bufr, row);
  _pdm_status("MEMwrite", *status);

  if (*status != MEM_S_SUCCESS)
    return;

  *status = PDUmadd_attribute_defaults();
  _pdm_status("PDUmadd_attribute_defaults", *status);

  cat_attr = (MEMptr)PDU_cat_atr;
  cat_data = (MEMptr)PDU_cat_data;
  cat_list = (MEMptr)PDU_cat_list;
  dyn_attr = (MEMptr)PDU_dyn_attr;
  dyn_data = (MEMptr)PDU_dyn_data;

  /* retrieve catalog attributes */
  PDUload_exec_structure("", "", "", "", "", "", "", ADD_DATA, PDM_LOC);
  *status = PDMsget_table_data(&loc_attr, &loc_data, &loc_list);
  _pdm_status("PDMsget_table_data", *status);

  if (*status != PDM_S_SUCCESS)
    return;
  
  if (PDMdebug_on)
    {
     MEMprint_buffer ("PDMget_table_data: data_buffer",
                      loc_data, PDU_DEBUG_FILE);
     MEMprint_buffer ("PDMget_table_data: list_buffers",
                      loc_attr, PDU_DEBUG_FILE);
    }

  *status = MEMbuild_array(loc_attr);
  _pdm_status("MEMbuild_array(loc_attr", *status);

  if (*status != MEM_S_SUCCESS)
    return;

  *status = MEMbuild_array(loc_data);
  _pdm_status("MEMbuild_array(loc_data)", *status);

  if (*status != MEM_S_SUCCESS)
    return;

  /* put the catalog application in the buffer */
  attr_row = PDUfind_col_in_buffer(loc_data, PDU_NFM_CATALOG_APPL);
  _pdm_debug("attr_row = %d", (char *)attr_row);
  if (attr_row != -1)
    {
    *status = MEMwrite_data(loc_data, "PDM", 1, (attr_row + 1));
    _pdm_status("MEMwrite_data", status);

    if (*status != MEM_S_SUCCESS)
      {
      *status = PDM_E_WRITE_BUFFER;
      return;
      }
    }

  /* put the catalog application in the buffer */
  attr_row = PDUfind_attr_in_buffer(loc_attr, PDU_NFM_CATALOG_NAME);
  if (attr_row != -1)
    {
    *status = MEMwrite_data(loc_attr, "char(12)", (attr_row + 1),
                           (PDU_NFM_DATA_COL + 1));
    _pdm_status("MEMwrite_data", status);

    if (*status != MEM_S_SUCCESS)
      {
      *status = PDM_E_WRITE_BUFFER;
      return;
      }
    }

  *status = MEMbuild_array(cat_attr); 
  _pdm_status("MEMbuild_array", *status);

  if (*status != MEM_S_SUCCESS)
    {
    *status = PDM_E_BUILD_BUFFER_ARRAY;
    return;
    }

  attr_row = PDUfind_attr_in_buffer(cat_attr, "p_altpartno");
  if (attr_row != -1)
    {
    _pdm_debug("catalog type is EXT", 0);
    attr_row = PDUfind_col_in_buffer(loc_data, PDU_NFM_CATALOG_TYPE);
    if (attr_row != -1)
      {
      *status = MEMwrite_data(loc_data, "EXT", 1, (attr_row + 1));
      _pdm_status("MEMwrite_data", *status);
      if (*status != MEM_S_SUCCESS)
        {
        *status = PDM_E_WRITE_BUFFER;
        return;
        }
      }
    }
  else if (dyn_attr)
    {
    *status = MEMbuild_array(dyn_attr);
    _pdm_status("MEMbuild_array", *status);

    if (*status != MEM_S_SUCCESS)
      {
      *status = PDM_E_BUILD_BUFFER_ARRAY;
      return;
      }
    attr_row = PDUfind_attr_in_buffer(dyn_attr, "p_altpartno");
    if (attr_row != -1)
      {
      _pdm_debug("catalog type is EXT", 0);
      attr_row = PDUfind_col_in_buffer(loc_data, PDU_NFM_CATALOG_TYPE);
      if (attr_row != -1)
        {
        *status = MEMwrite_data(loc_data, "EXT", 1, (attr_row + 1));
        _pdm_status("MEMwrite_data", *status);

        if (*status != MEM_S_SUCCESS)
          {
          *status = PDM_E_WRITE_BUFFER;
          return;
          }
        }
      }
    else
      {
      _pdm_debug("catalog type is standard", 0);
      attr_row = PDUfind_col_in_buffer(loc_data, PDU_NFM_CATALOG_TYPE);
      if (attr_row != -1)
        {
        *status = MEMwrite_data(loc_data, "C", 1, (attr_row + 1));
        _pdm_status("MEMwrite_data", *status);
     
        if (*status != MEM_S_SUCCESS)
          {
          *status = PDM_E_WRITE_BUFFER;
          return;
          }
        }
      }
    }
  else
    {
    _pdm_debug("catalog is standard", 0);
    attr_row = PDUfind_col_in_buffer(loc_data, PDU_NFM_CATALOG_TYPE);
    if (attr_row != -1)
      {
      *status = MEMwrite_data(loc_data, "C", 1, (attr_row + 1));
      _pdm_status("MEMwrite_data", *status);

      if (*status != MEM_S_SUCCESS)
        {
        *status = PDM_E_WRITE_BUFFER;
        return;
        }
      }
    }

  /* put the catalogname in the buffer */
  attr_row = PDUfind_col_in_buffer(loc_data, PDU_NFM_CATALOG_NAME);
  if (attr_row != -1)
    {
    *status = MEMwrite_data(loc_data, catalog, 1, (attr_row + 1));
    _pdm_status("MEMwrite_data", *status);
    if (*status != MEM_S_SUCCESS)
      {
      *status = PDM_E_WRITE_BUFFER;
      return;
      }
     }
  
  attr_row = PDUfind_col_in_buffer(loc_data, PDU_NFM_CATALOG_DESC);
  if ((attr_row != -1) && ((description) && (strcmp(description, "") != 0)))
    {
    *status = MEMwrite_data(loc_data, description, 1, (attr_row + 1));
    _pdm_status("MEMwrite_data", *status);
    
    if (*status != MEM_S_SUCCESS)
      {
      *status = PDM_E_WRITE_BUFFER;
      return;
      }
    }
    
  /* put the ACL in buffer */
  _pdm_debug("attr_row = %d PDU_NFM_ACL_NO", (char *)attr_row);
  attr_row = PDUfind_col_in_buffer(loc_data, PDU_NFM_ACL_NO);
  if (attr_row != -1)
    {
    *status = MEMwrite_data(loc_data, PDU_cat_aclno, 1, (attr_row + 1));
    _pdm_status("MEMwrite_data", *status);
 
    if (*status != MEM_S_SUCCESS)
      {
      *status = PDM_E_WRITE_BUFFER;
      return;
      }
    }
     
  _pdm_debug("Before NFMRtic_it", 0);
  status1 = NFMRtic_it(loc_data);
  status1 = NFMRtic_it(cat_data);
  status1 = NFMRtic_it(dyn_data);
  status1 = NFMRtic_it(cat_attr);
  status1 = NFMRtic_it(dyn_attr);

  _pdm_debug("Before MEMopen", 0);
  if (cat_list == NULL) MEMopen(&cat_list, 512);
  if (dyn_attr == NULL) MEMopen(&dyn_attr, 512);
  if (dyn_data == NULL) MEMopen(&dyn_data, 512);
  if (dyn_list == NULL) MEMopen(&dyn_list, 512);

  dynamic_table = (char *)malloc(strlen(catalog) + 5);
  memset(dynamic_table, NULL, (strlen(catalog) + 5));
  sprintf(dynamic_table, "%s%s", "y_", catalog);

  PDUload_exec_structure("", "", "", "", "", "", "", 0, 1);
  if (PDU_parm_cat)
    {
    *status = PDMcreate_parametric_catalog(loc_attr, loc_data, cat_attr, 
                                           cat_data, cat_list, dynamic_table,
                                           dyn_attr, dyn_data, dyn_list);
    _pdm_status("PDMcreate_parametric_catalog", *status);
    }
  else
    {
    *status = PDMcreate_catalog(loc_attr, loc_data, cat_attr, cat_data,cat_list,
                                dynamic_table, dyn_attr, dyn_data, dyn_list);
    _pdm_status("PDMcreate_catalog", *status);
    }

  if (*status != PDM_S_SUCCESS)
    {
    PDMset_to_state(*status, "PDM", "");
    return;
    }

  /* create classification */
  *status = PDMstore_classification(PDU_cat_class_bufr);
  _pdm_status("PDMstore_classification", *status);

  if (*status != PDM_S_SUCCESS)
    {
    PDMset_to_state(*status, "PDM", "");
    return;
    }

  if (acl_bufr)
    MEMclose(&acl_bufr);

  if ((PDU_cat_aclno) && (strcmp(PDU_cat_aclno, "") != 0))
    PDUfill_in_string(&PDU_cat_aclno, NULL);

  if (dynamic_table)
    free(dynamic_table);

  if (cat_attr)
    MEMclose(&cat_attr);
  if (cat_data)
    MEMclose(&cat_data);
  if (cat_list)
    MEMclose(&cat_list);

  if (loc_attr)
    MEMclose(&loc_attr);
  if (loc_data)
    MEMclose(&loc_data);
  if (loc_list)
    MEMclose(&loc_list); 
    
  PDU_cat_atr = NULL;
  PDU_cat_data = NULL;
  PDU_cat_list = NULL;
  PDU_dyn_attr = NULL;
  PDU_dyn_data = NULL;

  PDMset_to_state(*status, "PDM", "");
  return;
  }
