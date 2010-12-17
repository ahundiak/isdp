#include "PDUerror.h"
#include "PDUcommand.h"
#include "PDUfile_def.h"
#include "PDUforms.h"
#include "PDUuser.h"
#include "PDUintdef.h"
#include "PDUstr.h"
#include "PDUproto.h"
#include "PDMproto.h"
#include "exdef.h"

extern int PDU_command;
extern int PDU_checkout_type;
extern int bufr_flag;
extern struct PDUuser *user;
extern MEMptr PDU_ret_bufr;
extern struct PDUrefresh *refresh;

void PDUppl_checkout_part(status, catalog, part, revision, activate_flag)
  int    *status;
  char   *catalog;
  char   *part;
  char   *revision;
  int    activate_flag;
{

  char   *state = NULL;
  char   *strings[1];
  char   **data_row;
  int    responses[1];
  int    file_col;
  int    type_col;
  MEMptr ret_bufr = NULL;

  _pdm_debug("in the macro PDUppl_checkout_part", 0);

  /* verify that a user is logged in */
  if (!(user->username))
    {
    _pdm_debug("no user is logged in to PDM", 0);
    *status = PDM_E_USER_LOGGED_IN;
    PDUmessage(PDM_E_USER_LOGGED_IN, 's');
    return;
    }

  /* check for parameters */
  if ((catalog) && (strcmp(catalog, "") == 0))
    {
    *status = PDM_I_ENTER_CATALOG;
    PDUmessage(*status, 's');
    return;
    }
  else if (!(catalog)) /* catalog = NULL */
    {
    *status = PDM_I_ENTER_CATALOG;
    PDUmessage(*status, 's');
    return;
    }

  if ((part) && (strcmp(part, "") == 0))
    {
    *status = PDM_I_ENTER_PART;
    PDUmessage(*status, 's');
    return;
    }
  else if (!(part))
    {
    *status = PDM_I_ENTER_PART;
    PDUmessage(*status, 's');
    return;
    }
  if ((revision) && (strcmp(revision, "") == 0))
    {
    *status = PDM_I_ENTER_REVISION;
    PDUmessage(*status, 's');
    return;
    }
  else if (!(revision))
    {
    *status = PDM_I_ENTER_REVISION;
    PDUmessage(*status, 's');
    return;
    }

  PDUmessage(PDC_M_CHECKOUT, 'c');

  /* verify catalog */
  bufr_flag = FALSE;
  *status = PDMrverify_catalog("", catalog);
  _pdm_status("PDMrverify_catalog", *status);

  if (*status != PDM_S_SUCCESS)
    {
    PDUmessage(*status, 's');
    return;
    }

  /* verify part and revision */
  *status = PDMcheck_partnum(catalog, part, revision);
  _pdm_status("PDMcheck_partnum", *status);
  MEMclose(&PDU_ret_bufr); PDU_ret_bufr = NULL;

  if (*status != PDM_S_SUCCESS)
    {
    PDUmessage(*status, 's');
    return;
    }

  /* retrieve a filename for the part */
  *status = PDMget_filenames(catalog, part, revision, &ret_bufr);
  _pdm_status("PDMget_filenames", *status);

  if ( *status != PDM_S_SUCCESS )
    {
    MEMclose(&ret_bufr);
    return;
    }

  if ((ret_bufr == NULL) || (ret_bufr->rows == 0))
    {
    *status = PDM_E_FILE_NOT_FOUND;
    return;
    }

  MEMbuild_array(ret_bufr);
  PDUsetup_buffer(ret_bufr, ROW, &data_row);
  PDUget_buffer_col(ret_bufr, "n_cofilename", &file_col);

  PDUfill_in_string(&refresh->rev_filename, 
                    data_row[(ret_bufr->columns * 0) + file_col]);
  MEMclose(&ret_bufr); ret_bufr = NULL;

  /* load parameters into the refresh */
  PDUfill_in_string(&refresh->rev_project, "");
  PDUfill_in_string(&refresh->rev_catalog, catalog);
  PDUfill_in_string(&refresh->rev_partid, part);
  PDUfill_in_string(&refresh->rev_revision, revision);
  PDUfill_in_string(&refresh->rev_description, "");

  /* query for part type */
  *status = PDMquery_part_type(refresh->rev_catalog, refresh->rev_partid,
                              refresh->rev_revision, &ret_bufr);
  _pdm_status("PDMquery_part_type", *status);

  if ((ret_bufr) && (*status == PDM_S_SUCCESS))
    {
    if (PDM_debug_on)
      MEMprint_buffer("part type buffer", ret_bufr, PDU_DEBUG_FILE);
    MEMbuild_array(ret_bufr);
    PDUget_buffer_col(ret_bufr, "p_parttype", &type_col);
    PDUsetup_buffer(ret_bufr, ROW, &data_row);

    PDUfill_in_string(&refresh->rev_parttype,
                data_row[(ret_bufr->columns * 0) + type_col]);
    _pdm_debug("parttype = <%s>", refresh->rev_parttype);
    MEMclose(&ret_bufr);
    }
  else
    {
    PDUmessage(*status, 's');
    MEMclose(&ret_bufr);
    return;
    }

  /* check to see if the part is checked in */
  *status = PDUget_file_status(catalog, part, revision, &state);
  _pdm_status("PDUget_file_status", *status);

  if ((state) && (strcmp(state, "") == 0)) /* part has never been checked in */
    {
    /* return error message */
    *status = PDM_E_NOTCHECK_IN;
    PDUmessage(*status, 's');
    return;
    }

  else if ((state) && (strcmp(state, "O") == 0)) /* part is checked out */
    {
    *status = PDM_E_PART_CHECKED_OUT;
    PDUmessage(*status, 's');
    return;
    }

  else if ((state) && (strcmp(state, "I") != 0)) 
    {
    if (strcmp(state, "S") == 0) /* checked out by another user */
      *status = PDM_E_ANOTHER_USER;
    PDUmessage(*status, 's');
    return;
    }

  else if ((state) && (strcmp(state, "I") == 0)) 
    {
    if (activate_flag == 1) /* check out and activate the part */
      {
      *status = PDUmacro_checkout_part();
      _pdm_status("PDUmacro_checkout_part", *status);

      if (*status == PDM_S_SUCCESS)
        {
        PDU_command = PDC_M_ACTIVATE_PART;
        responses[0] = EX_CMD_KEY;
        strings[0] = "PDAcPr";
  
        *status = PDUprepare_queue ( responses, strings, 1 );
        _pdm_status("PDUprepare_queue (check out and enter design)",*status);
        return;
        }
      else
        {
        PDUmessage(*status, 's');
        return;
        }
      }
    else /* check out the part */
      {
      *status = PDUmacro_checkout_part();
      _pdm_status("PDUmacro_checkout_part", *status);
      return;
      }
    }
}

int PDUmacro_checkout_part()
{
  int                           status = PDM_S_SUCCESS;
  int                           sts = PDM_S_SUCCESS;
  char                          *status_msg;
  MEMptr                        files_bufr = NULL;
  MEMptr                        attach_info_bufr = NULL;

  _pdm_debug("in the function PDUmacro_checkout_part", 0);

  sts = PDMvalidate_user_access("PDMCheck Out Part", NULLSTR,
           refresh->rev_catalog, NULLSTR, refresh->rev_partid,
           refresh->rev_revision );
  _pdm_status ("PDMvalidate_user_access", sts);

  if (sts != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(sts);
    }

  /* check if part type is parametric */
  if ( ((refresh->rev_parttype)) &&
       (strcmp(refresh->rev_parttype,"P") == 0) ||
       (strcmp(refresh->rev_parttype,"p") == 0) )
       return(PDM_E_CAN_NOT_CHECKOUT_PARAMETRIC_PART);

  /* check if part type is non-graphic */
  if ( ((refresh->rev_parttype)) &&
       (strcmp(refresh->rev_parttype,"N") == 0) ||
       (strcmp(refresh->rev_parttype,"n") == 0) )
       return(PDM_E_INVALID_PART_TYPE);

  status = PDMrcheckout_part (
                             refresh->rev_catalog,
                             refresh->rev_partid,
                             refresh->rev_revision,
                             refresh->rev_filename,
                             &files_bufr,
                             &attach_info_bufr
                            );
  _pdm_status ("PDMrcheckout_part", status);

  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("SEVERE error: PDMrcheckout_part failed", 0);
      return(status);
     }

  status = PDUcheckout_part(files_bufr, attach_info_bufr, 1);
    _pdm_status("PDUcheckout_part", status);

  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUcheckout_part failed", 0);
      return(status);
     }

  /* Need to check if attach info needs to be updated */
/*
  status = PDUfind_PDU_design_file(files_bufr, attach_info_bufr);
  _pdm_status("PDUfind_PDU_design_file", status);

  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUfind_PDU_design_file failed", 0);
      return(status);
     }
*/

  status_msg = (char *) PDUtranslate_message(status);
  _pdm_debug("Error string = <%s>", status_msg);

  sts = PDMset_to_state ( status, "PDM", status_msg );
  _pdm_status ("PDMset_to_state", sts);

  PDUmessage(status, 's');

  /* MEMclose buffers */
  if (files_bufr) MEMclose(&files_bufr);
  if (attach_info_bufr) MEMclose(&attach_info_bufr);

  return ( status );
}
