#include "PDUerror.h"
#include "PDUstr.h"
#include "PDUfile_def.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "NFMerrordef.h"
#include "PDUproto.h"
#include "PDMproto.h"

extern struct PDUrefresh *refresh;
extern MEMptr PDU_ret_bufr;
extern MEMptr PDU_file_bufr;
extern MEMptr PDU_add_bufr;
extern short PDU_main_form_cat;
extern int change_mode;
extern int PDM_debug_on;

int pdmoLoadAttrStructure(	cpr_attr_name,
				cpr_datatype,
				cpr_synonym,
				cpr_value,
				spm_attrs)

  char    *cpr_attr_name;
  char    *cpr_datatype;
  char    *cpr_synonym;
  char    *cpr_value;
  struct   attribute_info      **spm_attrs;
{

  long   status = PDM_S_SUCCESS;

  _pdm_debug("in the function pdmoLoadAttrStructure", 0);

  status = PDUloadapi_attr_structure(	cpr_attr_name,
					cpr_datatype,
					cpr_synonym,
					cpr_value,
					spm_attrs);
  _pdm_status("PDUloadapi_attr_structure", status);

  return(status);
}

int pdmoFreeAttrStructure(attr_list)
struct   attribute_info  **attr_list;
{

  long   status = PDM_S_SUCCESS;

  _pdm_debug("in the function pdmoFreeAttrStructure", 0);

  status = PDUfree_api_attr_structure(attr_list);
  _pdm_status("PDUfree_api_attr_structure", status);

  return(status);
}


int pdmoGetPartAttributes(cpr_catalog,
			 cpr_partnum,
			 cpr_revision,
			 attr_list)
  char    *cpr_catalog;
  char    *cpr_partnum;
  char    *cpr_revision;
  struct   attribute_info      **attr_list;
{
  long   status = PDM_S_SUCCESS;
  MEMptr attr_bufr = NULL;
  MEMptr data_bufr = NULL;
  int    current_mem_buf = 0;

  _pdm_debug("in the function pdmoGetPartAttributes", 0);

  _pdm_debug("verifying login", 0);
 
  status = pdmcheck_log_in();
  _pdm_status("pdmcheck_log_in", status);
  if (status != 1)
    return(PDM_E_USER_NOT_LOGGED_IN);
 
  _pdm_debug("validating catalog", 0);
  PDU_main_form_cat = FALSE;
  status = PDUvalidate_catalog("", cpr_catalog, 0);
  _pdm_status("PDUvalidate_catalog", status);
  if (status != PDM_S_SUCCESS)
    return(status);

  _pdm_debug("validating partnum", 0);
  if (cpr_partnum == NULL)
    return(PDM_I_ENTER_PART);
  else if (strlen(cpr_partnum) == 0)
    return(PDM_I_ENTER_PART);

  _pdm_debug("validating revision", 0);
  if (cpr_revision == NULL)
    return(PDM_I_ENTER_REVISION);
  else if (strlen(cpr_revision) == 0)
    return(PDM_I_ENTER_REVISION);

  _pdm_debug("checking to see if part exists", 0);
  status = PDMcheck_partnum(cpr_catalog, cpr_partnum, cpr_revision);
  _pdm_status("PDMcheck_partnum",status);
  MEMclose(&PDU_ret_bufr); PDU_ret_bufr = NULL;
  if (status != PDM_S_SUCCESS)
    return(status);

  _pdm_debug("retrieving list of attributes", 0);
  change_mode = TRUE;
  status = PDMget_existing_data(cpr_catalog, cpr_partnum, cpr_revision);
  _pdm_status("PDMget_existing_data",status);
  change_mode = FALSE;
  if (status != PDM_S_SUCCESS)
    {
    if (status == NFM_E_ITEM_LOCKED)
      status = PDM_E_ITEM_LOCKED;
    return(status);
    }

  status = MEMsplit_copy_buffer(PDU_ret_bufr, &attr_bufr, 0);
  _pdm_status("MEMsplit_copy_buffer", status);
  if (status != MEM_S_SUCCESS)
    {
    status = PDMcancel_modify_part(cpr_catalog, cpr_partnum, cpr_revision,
                                   attr_bufr, data_bufr);
    _pdm_status("PDMcancel_modify_part", status);
    return(PDM_E_COPY_BUFFER);
    }

  MEMreset_buffer(PDU_ret_bufr, &current_mem_buf);
  status = MEMsplit_copy_buffer(PDU_ret_bufr, &data_bufr, 0);
  _pdm_status("MEMsplit_copy_buffer", status);
  if (status != MEM_S_SUCCESS)
    {
    status = PDMcancel_modify_part(cpr_catalog, cpr_partnum, cpr_revision,
                                   attr_bufr, data_bufr);
    _pdm_status("PDMcancel_modify_part", status);
    return(PDM_E_COPY_BUFFER);
    }

  if (PDM_debug_on)
    {
    MEMprint_buffer("attr_bufr", attr_bufr, PDU_DEBUG_FILE);
    MEMprint_buffer("data_bufr", data_bufr, PDU_DEBUG_FILE);
    }

  _pdm_debug("copying attr list to buffer", 0);
  status = PDUloadapi_attr_list_from_buffer(attr_bufr, data_bufr, attr_list);
  _pdm_status("PDUloadapi_attr_list_from_buffer", status);
  if (status != PDM_S_SUCCESS)
    {
    status = PDMcancel_modify_part(cpr_catalog, cpr_partnum, cpr_revision,
                                   attr_bufr, data_bufr);
    _pdm_status("PDMcancel_modify_part", status);
    return(status);
    }

  status = PDMcancel_modify_part(cpr_catalog, cpr_partnum, cpr_revision,
                                 attr_bufr, data_bufr);
  _pdm_status("PDMcancel_modify_part", status);
  if (status != PDM_S_SUCCESS)
    return(status);

  MEMclose(&attr_bufr);
  MEMclose(&data_bufr);
  attr_bufr = NULL;
  data_bufr = NULL;
 
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

  if (PDU_add_bufr)
    {
    MEMclose(&PDU_add_bufr);
    PDU_add_bufr = NULL;
    }

  return(status);
}
