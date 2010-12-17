#include "PDUerror.h"
#include "PDUstr.h"
#include "MEMerrordef.h"
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "PDUintdef.h"
#include "PDUfile_def.h"
#include "NFMapi.h"
#include "PDMproto.h"
#include "PDUproto.h"

extern struct PDUrefresh *refresh;
extern short PDU_main_form_cat;
extern MEMptr PDU_file_bufr;
extern MEMptr PDU_ret_bufr;
extern int change_mode;

int pdmoDeleteFiles(	cpr_catalog,
			cpr_partnum,
			cpr_revision,
			spr_delete_files)
  char    *cpr_catalog;
  char    *cpr_partnum;
  char    *cpr_revision;
  struct   file_info      *spr_delete_files;
{
  long   status = PDM_S_SUCCESS;
  long   status1 = PDM_S_SUCCESS;
  char   ** file_data_row;
  char   ** dummy_col;
  char   ** dummy_format;
  char   *state = NULL;
  MEMptr file_data_bufr = NULL;

  _pdm_debug("in the function pdmoDeleteFiles", 0);

  if (!spr_delete_files)
    return(PDM_E_NULL_FILE_LIST);

  refresh->command = PDC_M_DELETE_FILES;

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

  _pdm_debug("validating access", 0);
  status = PDUwf_check(PDC_M_DELETE_FILES);
  _pdm_status("PDUwf_check", status);
  if (status == PDM_S_SUCCESS)
    {
    status = PDMvalidate_user_access ( "PDMDelete Files For Part", NULLSTR, 
                             cpr_catalog, NULLSTR, cpr_partnum, cpr_revision );
    _pdm_status("PDMvalidate_access", status);
    if (status != PDM_S_SUCCESS)
      return(status);
    }
  else
    status = PDM_S_SUCCESS;

  _pdm_debug("checking part status", 0);
  status = PDUget_file_status(cpr_catalog, cpr_partnum, cpr_revision, &state);
  _pdm_status("PDUget_file_status", status);
  if ((state) && (strcmp(state, "") != 0) && (strcmp(state, "I") != 0))
    return(PDM_E_CANNOT_DELETE_FILES);

  _pdm_debug("retrieving file data buffer", 0);
  change_mode = TRUE;
  PDUload_exec_structure("", cpr_catalog, cpr_partnum, cpr_revision, 
                         "", "", "", 0, NFM_CHANGE_FILE_INFORMATION);

  if (PDU_file_bufr != NULL)
      {
      MEMclose(&PDU_file_bufr);
      PDU_file_bufr = NULL;
      }

   _pdm_debug("calling PDMprepare_file_info", 0);
   status = PDMprepare_file_info(&PDU_file_bufr);
   _pdm_status("PDMprepare_file_info", status);
   if (status == NFM_E_NO_ITEM_FILES_FOUND)
    {
    MEMclose(&PDU_file_bufr);
    PDU_file_bufr = NULL;
    return(PDM_E_NO_PART_FILES);
    }
  else if (status == NFM_E_ITEM_LOCKED)
    {
    MEMclose(&PDU_file_bufr);
    PDU_file_bufr = NULL;
    return(PDM_E_ITEM_LOCKED);
    }
    

  status = PDUsetup_buffer_list(PDU_file_bufr, 2, 0, &file_data_row,
                                &dummy_col,&dummy_format, &file_data_bufr);
  _pdm_status("PDUsetup_buffer_list", status);
  if ((status != PDM_S_SUCCESS) && (status != PDM_E_NULL_BUFFER))
    {
    MEMclose(&file_data_bufr);
    return(status);
    }

  if (PDM_debug_on)
    MEMprint_buffer("file_data_bufr", file_data_bufr, PDU_DEBUG_FILE);

  if ((spr_delete_files) && (file_data_bufr == NULL))
    {
    MEMclose(&file_data_bufr);
    return(PDM_E_NO_PART_FILES);
    }

  if (spr_delete_files)
    {
    status = PDUverify_delete_file_list(cpr_catalog, cpr_partnum, cpr_revision,
                                        spr_delete_files);
    _pdm_status("PDUverify_delete_file_list", status);
    if ((status != PDM_S_SUCCESS) && (status != PDM_E_NULL_BUFFER))
      {
      MEMclose(&file_data_bufr);
      return(status);
      }

    status = PDUmark_files_for_delete(&file_data_bufr, spr_delete_files);
    _pdm_status("PDUmark_files_for_delete", status);
    if ((status != PDM_S_SUCCESS) && (status != PDM_E_NULL_BUFFER))
      {
      MEMclose(&file_data_bufr);
      return(status);
      }
    }

  if (file_data_bufr == NULL)
    {
    MEMclose(&file_data_bufr);
    status = MEMopen(&file_data_bufr, 512);
    _pdm_status("MEMopen", status);
    if (status != MEM_S_SUCCESS)
      return(PDM_E_OPEN_BUFFER);
    }

  status = PDMdelete_files(     cpr_catalog,
				cpr_partnum,
				cpr_revision,
				file_data_bufr);
  _pdm_status("PDMdelete_files", status);

  _pdm_debug("setting the state", 0);
  status1 = PDUwf_check(PDC_M_DELETE_FILES);
  _pdm_status("PDUwf_check", status1);
 
  /* ex$message cannot be used to translate the message key to a string */
  status1 = PDMset_to_state ( status, "PDM", "" );
  _pdm_status ("PDMset_to_state", status1);

  _pdm_debug("closing buffers", 0);
  
  if (PDU_file_bufr)
    {
    MEMclose(&PDU_file_bufr);
    PDU_file_bufr = NULL;
    }
  
  return(status);
}
