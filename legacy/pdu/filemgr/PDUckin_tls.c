#include	<PDUstr.h>
#include	<PDUuser.h>
#include	<PDUerror.h>
#include        <PDUint.h>
#include        <PDUintdef.h>
#include        <PDUfile_def.h>
#include        <PDUforms.h>
#include        <PDUpart.h>
#include        <exdef.h>
#include        <errno.h>
#include        <MEMstruct.h>
#include        <MEMerrordef.h>
#include        <NFMerrordef.h>
#include        "PDUproto.h"
#include        "PDMproto.h"

int PDUverify_files_exist_locally(cpr_catalogname, cpr_itemname, cpr_itemrev, 
                                  filenames)
char *cpr_catalogname;
char *cpr_itemname;
char *cpr_itemrev;
MEMptr *filenames;

  {
  int status;
  int i;
  int filename_col = -1;
  char **filenames_data = NULL;

  _pdm_debug("PDUverify_files_exist_locally", 0);

  status = PDMget_filenames(cpr_catalogname, cpr_itemname, cpr_itemrev, 
                            filenames);
  _pdm_status("PDMget_filenames", status);
  if (status != PDM_S_SUCCESS)
    return(status);
  else if (*filenames == NULL)
    return(PDM_I_NO_FILES_FOUND);
  else if ((*filenames)->rows == 0)
    return(PDM_I_NO_FILES_FOUND);
    
  /* verify all files exist locally */
  status = MEMbuild_array(*filenames);
  _pdm_status("MEMbuild_array", status);

  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_ARRAY);
  filenames_data = (char **) (*filenames)->data_ptr;
  PDUget_buffer_col(*filenames, "n_cofilename", &filename_col);
  if (filename_col == -1)
    return(PDM_E_REQ_COLUMN_NOT_FOUND);
  for ( i = 0; i < (*filenames)->rows; i ++)
    {
    status = PDUverify_file(filenames_data[((*filenames)->columns * i) + 
                            filename_col]);
    _pdm_status("PDUverify_file", status);
    if (status != PDM_S_SUCCESS)
      return(status);
    }

  return(PDM_S_SUCCESS);
  }
