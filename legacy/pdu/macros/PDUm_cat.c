#include "PDUerror.h"
#include "MEMerrordef.h"
#include "PDUstr.h"
#include "PDUintdef.h"
#include "PDUproto.h"
#include "PDMproto.h"

extern int PDU_command;
extern int bufr_flag;
extern int PDU_view;
extern int PDU_parm_cat;
extern char *PDU_cat_aclno;
extern char *PDU_cat_description;
extern char *PDU_template_catalog;
extern char *PDU_cat_atr;
extern char *PDU_cat_data;
extern char *PDU_dyn_attr;
extern char *PDU_dyn_data;
extern struct PDUrefresh *refresh;
extern MEMptr PDU_cat_class_bufr;

void PDUprepare_create_catalog(status,catalog, description, acl_name,temp_cat,
                               static_attr,dynamic_attr)

  int  *status;
  char *catalog; 
  char *description;
  char *acl_name;
  char *temp_cat;
  struct PDUattribute_info *static_attr;
  struct PDUattribute_info *dynamic_attr;

  {
  MEMptr acl_bufr = NULL;
  int    i;
  int    FOUND;
  int    char_index;
  char   **acl_data;
  char   *row = NULL;

  _pdm_debug("In PDUprepare_create_catalog", 0);

  /* check catalog for existence */
  bufr_flag = FALSE;
  *status = PDUvalid_catalog("",catalog);
  _pdm_status("PDUvalid_catalog", *status);

  if (*status == PDM_S_SUCCESS)
    {
    *status = PDM_E_CATALOG_EXISTS;
    return;
    }

  refresh->rev_catalog = NULL;
  PDUfill_in_string(&refresh->rev_catalog, catalog);

  /* check template catalog for existence */
  if ((temp_cat) && (strcmp(temp_cat, "") != 0))
    {
    bufr_flag = FALSE;
    *status = PDUvalid_catalog("",temp_cat);
    _pdm_status("PDUvalid_catalog", *status);

    if (*status != PDM_S_SUCCESS)
      return;

    PDUfill_in_string(&PDU_template_catalog,temp_cat);
    PDU_command = PDC_M_CREATE_LIKE_CATALOG;
    refresh->command = PDC_M_CREATE_LIKE_CATALOG;
    PDU_view = FALSE;
    PDU_parm_cat = FALSE;
   }
 else
   {
    PDU_command = PDC_M_CREATE_CATALOG;
    refresh->command = PDC_M_CREATE_CATALOG;
    PDU_view = FALSE;
    PDU_parm_cat = FALSE;
   }

  if ((description) && (strcmp(description, "") != 0))
    PDUfill_in_string(&PDU_cat_description, description);
  else if ((PDU_cat_description) && (strcmp(PDU_cat_description, "") != 0))
    PDUfill_in_string(&PDU_cat_description, NULL);

  /* get default acl */
  *status = PDMcatalog_acls(&acl_bufr);
  _pdm_status("PDMcatalog_acls", *status);

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
  *status = PDUvalidate_access(refresh->command);
  _pdm_status("PDUvalidate_access", *status);

  if (*status != PDM_S_SUCCESS)
    return;

  /* get system attributes */
  *status = PDUget_catalog_buffers(PDU_command);
  _pdm_status("PDUget_catalog_buffers", *status);
 
  if (*status != PDM_S_SUCCESS)
    return;

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
    MEMclose(&PDU_cat_class_bufr);

  *status = PDUformat_cat_class_bufr(0, &PDU_cat_class_bufr);
  _pdm_status("PDUformat_cat_class_bufr", *status);

  if (*status != PDM_S_SUCCESS)
    return;

  row = (char *)malloc(PDU_cat_class_bufr->row_size);
  memset(row, NULL, PDU_cat_class_bufr->row_size);
  char_index = 0;
  PDUadd_buffer_string(row, &char_index, refresh->rev_catalog);

  row[char_index++] = '\1';

  *status = MEMwrite(PDU_cat_class_bufr, row);
  _pdm_status("MEMwrite", *status);

  if (*status != MEM_S_SUCCESS)
    return;

  *status = PDUmadd_attribute_defaults();
  _pdm_status("PDUmadd_attribute_defaults", *status);

   /* create catalog */
  *status = PDUcreate_catalog();
  _pdm_status("PDUcreate_catalog", *status);

  if (acl_bufr)
    MEMclose(&acl_bufr);

  PDUmessage_trans(*status, 's');

  return;
  }
