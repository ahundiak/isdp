#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "MEMstruct.h"
#include "MEMerrordef.h"

#include <PDMcommand.h>
#include "PDUerror.h"
#include "PDUsts_st.h"
#include "PDUfile_def.h"
#include "PDMmessage.h"
#include "PDUstorage.h"

#include "PDUproto.h"
#include "PDMproto.h"

extern	int     PDMdebug_on;
static  long    status;
extern  struct  PDUstorage *storage;

int PDMrlist_local_files(MEMptr *buffer)
{
  int  status = PDM_S_SUCCESS;

  _pdm_debug("In the function PDMrlist_local_files",0);

  /* Display Message */
  PDUmessage(PDS_M_LIST_LOCAL_FILES, 's');

  /* load PDUexec structure */
  PDUload_exec_structure("", "", "", "", "","","",0, 0);

  _pdm_debug("calling PDMlist_local_files", 0);
  status = PDMlist_local_files(buffer);
  _pdm_status("PDMlist_local_files", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  if (PDMdebug_on)
    MEMprint_buffer("file list", *buffer, PDU_DEBUG_FILE);

  /* Display Message */
  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  _pdm_debug ("PDMrlist_local_files: returning SUCCESS", 0);
  return (status);
  }  /* end PDMlist_local_files */

int PDMlist_checkedout_files(MEMptr *buffer)
{
  int  status = PDM_S_SUCCESS;

  _pdm_debug("In the function PDMlist_checkedout_files",0);

  /* Display Message */
  PDUmessage(PDS_M_LIST_CHKOUT_FILES, 's');

  /* load PDUexec structure */
  PDUload_exec_structure("", "", "", "", "","","",0, 0);

  _pdm_debug("calling PDMlist_chkout_files", 0);
  status = PDMlist_chkout_files(buffer);
  _pdm_status("PDMlist_chkout_files", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  if (PDMdebug_on)
    MEMprint_buffer("file list", *buffer, PDU_DEBUG_FILE);

  /* Display Message */
  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  _pdm_debug ("PDMlist_checkedout_files: returning SUCCESS", 0);
  return (status);
  }  /* end PDMlist_checkedout_files */

int PDMlist_checkedin_files(MEMptr *buffer)
{
  int  status = PDM_S_SUCCESS;

  _pdm_debug("In the function PDMlist_checkedin_files",0);

  /* Display Message */
  PDUmessage(PDS_M_CHKIN_FILES_OF_USER, 's');

  /* load PDUexec structure */
  PDUload_exec_structure("", "", "", "", "","","",0, 0);

  _pdm_debug("calling PDMchkin_files_of_user", 0);
  status = PDMchkin_files_of_user(buffer);
  _pdm_status("PDMchkin_files_of_user", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  if (PDMdebug_on)
    MEMprint_buffer("file list", *buffer, PDU_DEBUG_FILE);

  /* Display Message */
  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  _pdm_debug ("PDMlist_checkedin_files: returning SUCCESS", 0);
  return (status);
}  /* end PDMlist_checkedin_files */


int PDMrdelete_local_files(file_bufr, ret_bufr)
  MEMptr	file_bufr;
  MEMptr	*ret_bufr;
  {

	_pdm_debug("ENTER:PDMrdelete_local_files", 0);
	if (PDMdebug_on)
    {
		MEMprint_buffer("file_bufr",file_bufr,PDU_DEBUG_FILE);
		PDUprint_storage_area();
    }

     /* Display Message */
     PDUmessage(PDS_M_DELETE_LOCAL_FILES, 's');

     /* load PDUexec structure */
     PDUload_exec_structure("", "", "", "", "","","",0, 0);
   
     _pdm_debug("calling PDMdelete_local_files", 0);
     PDUdeactivate_stop_sign();
     status = PDMdelete_local_files(file_bufr, ret_bufr);
     _pdm_status("PDMdelete_local_files", status);
     PDUactivate_stop_sign();
   
     if (status != PDM_S_SUCCESS)
       {
       MEMclose(ret_bufr);
       ret_bufr = NULL;
       PDUmessage(status, 's');
       return(status);
       }

        if (PDMdebug_on)
          MEMprint_buffer("file list", *ret_bufr, PDU_DEBUG_FILE);

	/* call function to delete the files locally */
        if (*ret_bufr)
          {
	  status = PDUremove_local_files_after_delete(*ret_bufr);
          _pdm_status("PDUremove_local_files_after_delete", status);
          }

        /* Display Message */
        PDUmessage(PDM_E_CLEAR_FIELD, 's');

	_pdm_debug ("PDMrdelete_local_files: returning SUCCESS", 0);
	return (PDM_S_SUCCESS);
  }

int PDMget_state(catalog, part, revision, buffer)
  char          *catalog;
  char          *part;
  char          *revision;
  MEMptr        *buffer;
  {
  _pdm_debug("In the function PDMget_state",0);

  _pdm_debug("catalog = <%s>", catalog);
  _pdm_debug("part = <%s>", part);
  _pdm_debug("revision = <%s>", revision);

  /* Display Message */
  PDUmessage(PDS_M_GET_STATE, 's');

  /* load PDUexec structure */
  PDUload_exec_structure("", catalog, part, revision, "","","",0, 0);

  _pdm_debug("calling PDMget_state_name", 0);
  status = PDMget_state_name(buffer);
  _pdm_status("PDMget_state_name", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  if (PDMdebug_on)
    MEMprint_buffer("state", *buffer, PDU_DEBUG_FILE);

  /* Display Message */
  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  _pdm_debug ("PDMget_state: returning SUCCESS", 0);
  return (status);
  }  /* end PDMget_state */

int PDMrcheck_part_status(char *catalog, char *part, char *revision)
{
  /* Display Message */
  PDUmessage(PDS_M_CHECK_PART_STATUS, 's');

  /* load PDUexec structure */
  PDUload_exec_structure("", catalog, part, revision, "","","",0, 0);

  status = PDMcheck_part_status();

  /* Display Message */
  PDUmessage(PDM_E_CLEAR_FIELD, 's');
  
  return (status);
}  /* end PDMrcheck_part_status */

