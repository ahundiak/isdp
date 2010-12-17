#include "PDUerror.h"
#include "PDUstr.h"
#include "PDUintdef.h"
#include "PDUfile_def.h"
#include "PDMproto.h"
#include "PDUproto.h"
 
extern struct PDUrefresh *refresh;
extern short PDU_main_form_cat;
extern MEMptr PDU_ret_bufr;

int pdmoDeletePart(	cpr_catalog,
			cpr_partnum,
			cpr_revision)
  char   *cpr_catalog;
  char   *cpr_partnum;
  char   *cpr_revision;
{
  long   status = PDM_S_SUCCESS;
  long   status1 = PDM_S_SUCCESS;
  char   *state = NULL;
  char   *parttype = NULL;
  char   **data_row;
  MEMptr ret_bufr = NULL;
  int    type_col = 0;

  _pdm_debug("in the function pdmoDeletePart", 0);

  refresh->command = PDC_M_DELETE_ELEMENT;
 
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

  _pdm_debug("checking to see if part is checked in", 0);
  status = PDUget_file_status(cpr_catalog, cpr_partnum, cpr_revision, &state);
  _pdm_status("PDUget_file_status", status);
  if ((state) && (strcmp(state, "") != 0) && (strcmp(state, "I") != 0))
    return(PDM_I_PART_CHECKIN);

  _pdm_debug("checking parttype", 0);
  status = PDMquery_part_type(cpr_catalog, cpr_partnum, cpr_revision,&ret_bufr);
  _pdm_status("PDMquery_part_type", status);

  if ((ret_bufr) && (status == PDM_S_SUCCESS))
    {
    MEMbuild_array(ret_bufr);
    status = PDUget_buffer_col(ret_bufr, "p_parttype", &type_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    PDUsetup_buffer(ret_bufr, ROW, &data_row);

    PDUfill_in_string(&parttype, data_row[(ret_bufr->columns * 0) + type_col]);
    _pdm_debug("parttype = <%s>", parttype);
    MEMclose(&ret_bufr);
    }
  else
    MEMclose(&ret_bufr);
      
  if (parttype && (strcmp(parttype, "P") == 0) || (strcmp(parttype, "p") == 0))
    {
    free(parttype);
    _pdm_debug("part is parametric", 0);
    return(PDM_E_DELETE_PARAMETRIC_PART);
    }
  if (parttype) free(parttype);

  _pdm_debug("validating access", 0);
  status = PDUwf_check(PDC_M_DELETE_ELEMENT);
  _pdm_status("PDUwf_check", status);
  if (status == PDM_S_SUCCESS)
    {
    status = PDMvalidate_user_access ( "PDMDelete Part", NULLSTR, cpr_catalog,
                                        NULLSTR, cpr_partnum, cpr_revision );
    _pdm_status("PDMvalidate_access", status);
    if (status != PDM_S_SUCCESS)
      return(status);
    }
  else
    status = PDM_S_SUCCESS;

  _pdm_debug("checking to see if part can be deleted", 0);
  status = PDMcheck_delete_part(cpr_catalog, cpr_partnum, cpr_revision);
  _pdm_status("PDMcheck_delete_part",status);
 
  if (status == PDM_I_PART_IN_ASS)
    return(PDM_E_PART_OCCURS_IN_ASSEMBLY);
  else if (status != PDM_S_SUCCESS)
    return(status);

  _pdm_debug("calling PDMrdelete_part", 0);
  status = PDMrdelete_part(cpr_catalog, cpr_partnum, cpr_revision);
  _pdm_status("PDMrdelete_part",status);

  _pdm_debug("setting the state", 0);
  status1 = PDUwf_check(PDC_M_DELETE_ELEMENT);
  _pdm_status("PDUwf_check", status1);
 
  /* ex$message cannot be used to translate the message key to a string */
  status1 = PDMset_to_state ( status, "PDM", "" );
  _pdm_status ("PDMset_to_state", status1);
 
  return(status);
}
