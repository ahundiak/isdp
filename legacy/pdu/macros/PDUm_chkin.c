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
extern int bufr_flag;
extern int PDM_debug_on;
extern struct PDUuser *user;
extern MEMptr PDU_ret_bufr;
extern struct PDUrefresh *refresh;
extern MEMptr PDU_child_buffer;
extern MEMptr PDU_attach_buffer;
extern MEMptr PDU_view_buffer;

void PDUppl_checkin_part(status, catalog, part, revision)
  int    *status;
  char   *catalog;
  char   *part;
  char   *revision;
{

  char   **data_row;
  int    type_col;
  MEMptr ret_bufr = NULL;

  _pdm_debug("in the macro PDUppl_checkin_part", 0);

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

  PDUmessage(PDC_M_CHECKIN, 'c');

  /* call checkin functions */
  *status = PDUint_checkin();
  _pdm_status("PDUint_checkin", *status);

  if (*status == PDM_S_SUCCESS)
    {
    *status = PDUmacro_checkin_part();
    _pdm_status("PDUmacro_checkin_part", *status);
    }

  PDUmessage(*status, 's');
  return;
}

int PDUmacro_checkin_part()
{
  int                           status = PDM_S_SUCCESS;
  int                           sts = PDM_S_SUCCESS;

  _pdm_debug("in the function PDUmacro_checkin_part", 0);

  _pdm_debug("catalog = <%s>", refresh->rev_catalog);
  _pdm_debug("partid = <%s>", refresh->rev_partid);
  _pdm_debug("revision = <%s>", refresh->rev_revision);
  _pdm_debug("parttype = <%s>", refresh->rev_parttype);
  _pdm_debug("filename = <%s>", refresh->rev_filename);

  /* check to see if part is valid */
  if ((refresh->rev_parttype != NULL) &&
      (strcmp(refresh->rev_parttype,"G") != 0) &&
      (strcmp(refresh->rev_parttype,"g") != 0) &&
      (strcmp(refresh->rev_parttype,"N") != 0) &&
      (strcmp(refresh->rev_parttype,"n") != 0) &&
      (strcmp(refresh->rev_parttype,"P") != 0) &&
      (strcmp(refresh->rev_parttype,"p") != 0) &&
      (strcmp(refresh->rev_parttype,"C") != 0) &&
      (strcmp(refresh->rev_parttype,"c") != 0) &&
      (strcmp(refresh->rev_parttype,"m") != 0) &&
      (strcmp(refresh->rev_parttype,"M") != 0) &&
      (strcmp(refresh->rev_parttype,"A") != 0) &&
      (strcmp(refresh->rev_parttype,"a") != 0))
      {
       return(PDM_E_INVALID_PART_TYPE);
      }

  status = PDMrcheckin_part (
                            refresh->rev_catalog,
                            refresh->rev_partid,
                            refresh->rev_revision,
                            PDU_child_buffer,
                            PDU_attach_buffer,
                            PDU_view_buffer,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL
                           );
  _pdm_status("PDU -- PDMrcheckin ", status);

  /* Initialize global variables */
  PDU_child_buffer = NULL;
  PDU_attach_buffer = NULL;
  PDU_view_buffer = NULL;

  sts = PDUmessage_trans(status, 's');
  _pdm_status("PDUmessage_trans", sts);

  return(status);
}
