#include "PDUerror.h"
#include "PDMproto.h"
#include "PDUproto.h"

int pdmoLoadFileStructure(	cpr_file_desc,
				cpr_local_fn,
				cpr_storage_fn,
				cpr_file_type,
				ir_mode,
				spm_file_list)

  char    *cpr_file_desc;
  char    *cpr_local_fn;
  char    *cpr_storage_fn;
  char    *cpr_file_type;
  int      ir_mode;
  struct   file_info  **spm_file_list;
{

  long   status = PDM_S_SUCCESS;

  _pdm_debug("in the function pdmoLoadFileStructure", 0);

  if ((ir_mode != 1) && (ir_mode != 3))
    return(PDM_E_INVALID_MODE);

  status = PDUloadapi_file_structure(cpr_file_desc, cpr_local_fn,
                 cpr_storage_fn, cpr_file_type, ir_mode, spm_file_list);
  _pdm_status("PDUloadapi_file_structure", status);

  return(status);
}


int pdmoLoadChangeStructure(	cpr_file_desc,
				cpr_chg_file_desc,
				cpr_local_fn,
				cpr_chg_local_fn,
				cpr_storage_fn,
				cpr_chg_storage_fn,
				cpr_file_type,
				cpr_chg_file_type,
				ir_mode,
				spm_chg_list)

  char    *cpr_file_desc;
  char    *cpr_chg_file_desc;
  char    *cpr_local_fn;
  char    *cpr_chg_local_fn;
  char    *cpr_storage_fn;
  char    *cpr_chg_storage_fn;
  char    *cpr_file_type;
  char    *cpr_chg_file_type;
  int      ir_mode;
  struct   chg_file_info  **spm_chg_list;
{

  long   status = PDM_S_SUCCESS;

  _pdm_debug("in the function pdmoLoadChangeStructure", 0);

  if (ir_mode != 2)
    return(PDM_E_INVALID_MODE);

  status = PDUloadapi_change_structure(	cpr_file_desc, 
					cpr_chg_file_desc,
					cpr_local_fn,
					cpr_chg_local_fn,
					cpr_storage_fn, 
					cpr_chg_storage_fn,
					cpr_file_type, 
					cpr_chg_file_type,
					ir_mode, spm_chg_list);
  _pdm_status("PDUloadapi_change_structure", status);

  return(status);
}

int pdmoFreeFileStructure(file_list)
struct   file_info  **file_list;
{

  long   status = PDM_S_SUCCESS;

  _pdm_debug("in the function pdmoFreeFileStructure", 0);

  status = PDUfree_api_file_structure(file_list);
  _pdm_status("PDUfree_api_file_structure", status);

  return(status);
}

int pdmoFreeChangeStructure(file_list)
struct   chg_file_info  **file_list;
{

  long   status = PDM_S_SUCCESS;

  _pdm_debug("in the function pdmoFreeChangeStructure", 0);

  status = PDUfree_api_change_file_structure(file_list);
  _pdm_status("PDUfree_api_change_file_structure", status);

  return(status);
}
