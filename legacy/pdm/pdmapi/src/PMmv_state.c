#include "stdio.h"
#include "PDUerror.h"
#include "PDUstr.h"
#include "PDUintdef.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "PDMproto.h"
#include "PDUproto.h"
 
extern struct PDUrefresh *refresh;
extern short PDU_main_form_cat;
extern MEMptr PDU_ret_bufr;
extern MEMptr PDU_states_bufr;

int pdmoMoveToNextState(	cpr_catalog,
				cpr_partnum,
				cpr_revision,
				ir_stateno,
				cpr_statename)
  char   *cpr_catalog;
  char   *cpr_partnum;
  char   *cpr_revision;
  int    ir_stateno;
  char   *cpr_statename;
{
  long   status = PDM_S_SUCCESS;
  long   status1 = PDM_S_SUCCESS;
  char   **dummy_row;
  char   **dummy_col;
  char   **dummy_format;
  char   **data_row;
  char   statename[40];
  char   *state = NULL;
  int    stateno = 0;
  int    status_col = 0;
  int    statename_col = 0;
  int    stateno_col = 0;
  int    row = 0;
  short  found = FALSE;
  MEMptr attr_bufr = NULL;
  MEMptr states_bufr = NULL;

  _pdm_debug("in the function pdmoMoveToNextState", 0);

  refresh->command = 0;
 
  if (!cpr_statename)
    return(PDM_E_REQUIRED_DATA);
  else if (strlen(cpr_statename) == 0)
    return(PDM_E_REQUIRED_DATA);

  if (ir_stateno == 0)
    return(PDM_E_BAD_DATA);
 
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
 
  _pdm_debug("validating access", 0);
  status = PDMvalidate_user_access ( "Make Item Transition", NULLSTR, 
                           cpr_catalog, NULLSTR, cpr_partnum, cpr_revision );
  _pdm_status("PDMvalidate_access", status);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDMget_trans(cpr_catalog, cpr_partnum, cpr_revision);
  _pdm_status("PDMget_trans",status);
  if (status != PDM_S_SUCCESS)
    return(status);

  PDUunlock_item(cpr_catalog, cpr_partnum, cpr_revision);
 
  status = PDUsetup_buffer_list(PDU_states_bufr,1,0,&dummy_row, &dummy_col,
                                &dummy_format, &attr_bufr);
  _pdm_status("PDUsetup_buffer_list",status);
  if (status != PDM_S_SUCCESS)
    return(status);
 
  status = PDUsetup_buffer_list(PDU_states_bufr,2,0,&data_row, &dummy_col,
                                &dummy_format, &states_bufr);
  _pdm_status("PDUsetup_buffer_list",status);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = MEMbuild_array(states_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  status = PDUget_buffer_col(states_bufr, "n_statename", &statename_col);
  _pdm_status("PDUget_buffer_col", status);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(states_bufr, "n_stateno", &stateno_col);
  _pdm_status("PDUget_buffer_col", status);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(states_bufr, "n_status", &status_col);
  _pdm_status("PDUget_buffer_col", status);
  if (status != PDM_S_SUCCESS)
    return(status);

  _pdm_debug("input statename = <%s>", cpr_statename);
  _pdm_debug("input stateno = <%d>", (char *)ir_stateno);

  _pdm_debug("marking transition in buffer", 0);
  statename[0] = '\0';
  for (row = 0; row < states_bufr->rows; ++row)
     {
     strcpy(statename, data_row[(states_bufr->columns * row) + statename_col]);
     stateno = atoi(data_row[(states_bufr->columns* row) + stateno_col]);
     _pdm_debug("buffer statename = <%s>", statename);
     _pdm_debug("buffer stateno = <%d>", (char *)stateno);

     if ((strcmp(statename, cpr_statename) == 0) &&
         (stateno == ir_stateno))
       {
       _pdm_debug("writing to buffer", 0);
       status = MEMwrite_data(states_bufr, "next", row + 1, status_col + 1);
       _pdm_status("MEMwrite_data", status);
       if (status != MEM_S_SUCCESS)
         return(PDM_E_WRITE_BUFFER);
       found = TRUE;
       }
     }

  if (!found)
    {
    _pdm_debug("matching row not found in buffer", 0);
    return(PDM_E_SET_TO_STATE);
    }

  status = PDMrmake_transition(	cpr_catalog, 
				cpr_partnum, 
				cpr_revision, 
				attr_bufr,
				states_bufr);
  _pdm_status("PDMrmake_transition", status);

  PDUunlock_item(cpr_catalog, cpr_partnum, cpr_revision);

  _pdm_debug("setting the state", 0);
  /* ex$message cannot be used to translate the message key to a string */
  status1 = PDMset_to_state ( status, "PDM", "" );
  _pdm_status ("PDMset_to_state", status1);
 
  if (PDU_states_bufr)
    {
    MEMclose(&PDU_states_bufr);
    PDU_states_bufr = NULL;
    }
  
  return(status);
}
