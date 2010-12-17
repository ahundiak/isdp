#include "PDUerror.h"
#include "PDUstr.h"
#include "PDUintdef.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "PDMproto.h"
#include "PDUproto.h"
 
extern struct PDUrefresh *refresh;
extern short PDU_main_form_cat;
extern MEMptr PDU_ret_bufr;
extern MEMptr PDU_states_bufr;

int pdmoGetTransitions(	cpr_catalog,
			cpr_partnum,
			cpr_revision,
			spm_trans_list)
  char   *cpr_catalog;
  char   *cpr_partnum;
  char   *cpr_revision;
  struct part_transition **spm_trans_list;
{
  long   status = PDM_S_SUCCESS;
  char   **dummy_row;
  char   **dummy_col;
  char   **dummy_format;
  MEMptr states_bufr = NULL;
  MEMptr attr_bufr = NULL;

  _pdm_debug("in the function pdmoGetTransitions", 0);

  refresh->command = 0;
 
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

  status = PDMget_trans(cpr_catalog, cpr_partnum, cpr_revision);
  _pdm_status("PDMget_trans",status);
  if (status == NFM_E_USER_ACCESS_PRIV)
    return(PDM_E_NO_TRANSITIONS);
  if (status != PDM_S_SUCCESS)
    return(status);

  PDUunlock_item(cpr_catalog, cpr_partnum, cpr_revision);

  status = PDUsetup_buffer_list(PDU_states_bufr,1,0,&dummy_row, &dummy_col,
                                &dummy_format, &attr_bufr);
  _pdm_status("PDUsetup_buffer_list",status);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUsetup_buffer_list(PDU_states_bufr,2,0,&dummy_row, &dummy_col,
                                &dummy_format, &states_bufr);
  _pdm_status("PDUsetup_buffer_list",status);
  if (status != PDM_S_SUCCESS)
    return(status);

  *spm_trans_list = NULL;
  status = PDUloadapi_transition_structure(states_bufr, spm_trans_list);
  _pdm_status("PDUloadapi_transition_structure",status);
  
  if (PDU_states_bufr)
    {
    MEMclose(&PDU_states_bufr);
    PDU_states_bufr = NULL;
    }
 
  if (attr_bufr)
    MEMclose(&attr_bufr);
 
  if (states_bufr)
    MEMclose(&states_bufr);

  return(status);
}

int pdmoFreeTransStructure(trans_list)
struct   part_transition  **trans_list;
{
 
  long   status = PDM_S_SUCCESS;
 
  _pdm_debug("in the function pdmoFreeTransStructure", 0);
 
  status = PDUfree_api_trans_structure(trans_list);
  _pdm_status("PDUfree_api_trans_structure", status);
 
  return(status);
}
