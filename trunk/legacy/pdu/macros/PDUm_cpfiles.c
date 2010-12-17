#include "PDUerror.h"
#include "PDUcommand.h"
#include "PDUfile_def.h"
#include "PDUforms.h"
#include "PDUuser.h"
#include "PDUintdef.h"
#include "PDUstr.h"
#include "PDUfile_def.h"
#include "exdef.h"
#include "MEMerrordef.h"
#include "MEMstruct.h"
#include "PDUproto.h"
#include "PDMproto.h"

extern int PDU_command;
extern int bufr_flag;
extern struct PDUuser *user;
extern MEMptr PDU_ret_bufr;
extern struct PDUrefresh *refresh;

void PDUppl_copy_files(status, catalog, part, revision, activate_flag)
  int    *status;
  char   *catalog;
  char   *part;
  char   *revision;
  int    activate_flag;
{

  char   *state = NULL;
  char   *strings[1];
  int    responses[1];

  _pdm_debug("in the macro PDUppl_copy_files", 0);

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

  PDUmessage(PDC_M_COPY, 'c');

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
  PDUfill_in_string(&refresh->rev_filename, "");

  /* check to see if the part is checked in */
  *status = PDUget_file_status(catalog, part, revision, &state);
  _pdm_status("PDUget_file_status", *status);

  if (state && ((strcmp(state, "O") == 0) || (strcmp(state, "") == 0)))
    {
    *status = PDM_E_PART_NOT_CHECKEDIN;
    PDUmessage(*status, 's');
    return;
    }

  else if (state && (strcmp(state, "I") == 0))
    {
    _pdm_debug("copying file", 0);
    *status = PDUmacro_copy_file();
    _pdm_status("PDUmacro_copy_file", *status);
    PDUmessage(*status, 's');
    if (*status != PDM_S_SUCCESS)
      return;

    if (activate_flag == 1)
      {
      PDU_command = PDC_M_ACTIVATE_PART;
      responses[0] = EX_CMD_KEY;
      strings[0] = "PDAcPr";

      *status = PDUprepare_queue ( responses, strings, 1 );
      _pdm_status("PDUprepare_queue (enter design)",*status);
      return;
      }
    }
  else 
    {
    *status = PDM_E_PART_NOT_CHECKEDIN;
    PDUmessage(*status, 's');
    return;;
    }

}

int PDUmacro_copy_file()
{
  int        status = PDM_S_SUCCESS;
  int        sts = PDM_S_SUCCESS;
  int        type;
  int        char_index;
  int        row;
  int        action_col;
  int        file_col;
  char       *line = NULL;
  char       **file_data;
  char       **data_row;
  char       *action = NULL;
  char       *status_msg;
  MEMptr     file_bufr = NULL;
  MEMptr     return_buffer = NULL;
  MEMptr     ret_bufr = NULL;

  _pdm_debug("in the function PDUmacro_copy_file", 0);

  /* get the list of files */
  status = PDMget_filenames(refresh->rev_catalog,refresh->rev_partid,
                         refresh->rev_revision, &ret_bufr);
  _pdm_status("PDMget_filenames", status);

  if ( status != PDM_S_SUCCESS )
    {
    MEMclose(&ret_bufr);
    PDUmessage(status, 's');
    return(status);
    }

  if ((ret_bufr == NULL) || (ret_bufr->rows == 0))
    return(PDM_I_NO_FILES_FOUND);

  MEMbuild_array(ret_bufr);
  PDUsetup_buffer(ret_bufr, ROW, &data_row);
  PDUget_buffer_col(ret_bufr, "n_cofilename", &file_col);

  /* create file buffer */
  type = PDU_FILE_BUFFER;

  status = PDUformat_buffer (type, &file_bufr);
  _pdm_status("PDUformat_buffer", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  line = (char*) malloc (file_bufr->row_size);

  /* load part information into file buffer */
  for (row = 0; row < ret_bufr->rows; ++row)
     {
     memset (line, NULL, file_bufr->row_size);
     char_index = 0;

     /* add the n_catalogno and n_itemno columns to the buffer */
     line[char_index++] = '\1';    /* entry for n_catalono */
     line[char_index++] = '\1';    /* entry for n_itemno */

     /* add the refresh information to the buffer */
     if ((strlen (refresh->rev_catalog )) && refresh->rev_catalog)
       PDUadd_buffer_string(line, &char_index, refresh->rev_catalog);
     else
       line[char_index++] = '\1';

     if ((strlen (refresh->rev_partid )) && refresh->rev_partid)
       PDUadd_buffer_string(line, &char_index, refresh->rev_partid);
     else
       line[char_index++] = '\1';

     if ((strlen (refresh->rev_revision )) && refresh->rev_revision)
       PDUadd_buffer_string(line, &char_index, refresh->rev_revision);
     else
       line[char_index++] = '\1';

     PDUfill_in_string(&refresh->rev_filename,
                       data_row[(ret_bufr->columns * row) + file_col]);
     if ((strlen (refresh->rev_filename )) && refresh->rev_filename)
       PDUadd_buffer_string(line, &char_index, refresh->rev_filename);
     else
       line[char_index++] = '\1';

     line[char_index++] = '\1';    /* entry for p_action */
     _pdm_debug("line = <%s>", line);
     status = MEMwrite (file_bufr, line);

     if (status != MEM_S_SUCCESS)
       {
       _pdm_debug("Error writing to file buffer", 0);
       _pdm_status("MEMwrite_format ()", status);

       memset (line, NULL, file_bufr->row_size);

       /* close buffers */
       if (file_bufr)  MEMclose(&file_bufr);
       if (ret_bufr)   MEMclose(&ret_bufr);
       if (return_buffer)  MEMclose(&return_buffer);
       return(PDM_E_WRITE_BUFFER);
       }
     }

  if (PDM_debug_on)
    MEMprint_buffer("file buffer", file_bufr, PDU_DEBUG_FILE);

  /* validate access */
  status = PDMvalidate_user_access("PDMCopy File To Local", NULLSTR,
           refresh->rev_catalog, NULLSTR, refresh->rev_partid,
           refresh->rev_revision );
  _pdm_status ("PDMvalidate_user_access", status);

  if (status != PDM_S_SUCCESS)
    {
    /* close buffers */
    if (file_bufr)  MEMclose(&file_bufr);
    if (ret_bufr)   MEMclose(&ret_bufr);
    if (return_buffer)  MEMclose(&return_buffer);
    return(status);
    }

  /* copy files to local workstation */
  status = PDMcopy(file_bufr, &return_buffer);
  _pdm_status ("PDMcopy (file)", status);

  status_msg = (char *) PDUtranslate_message(status);
  _pdm_debug("Error string = <%s>", status_msg);

  sts = PDMset_to_state ( status, "PDM", status_msg );
  _pdm_status ("PDMset_to_state", sts);

  if (status != PDM_S_SUCCESS)
    {
    /* close buffers */
    if (ret_bufr)   MEMclose(&ret_bufr);
    if (return_buffer)  MEMclose(&return_buffer);

    PDUmessage(status, 's');
    return(status);
    }

  /* check for uncopied files */
  MEMbuild_array(return_buffer);
  PDUget_buffer_col(return_buffer, "p_action", &action_col);
  PDUsetup_buffer(return_buffer, ROW, &file_data);

  for (row = 0; row < return_buffer->rows; ++row)
     {
     /* get the status from the return buffer */
     PDUfill_in_string(&action,
                 file_data[(return_buffer->columns * row) + action_col]);
     if ((action) && (strcmp(action, "SUCCESS") != 0))
       {
       _pdm_debug("all files could not be copied to local working area", 0);
       status = PDM_E_COPY_FILES;
       break;
       }
     }

  /* close buffers */
  if (ret_bufr)   MEMclose(&ret_bufr);
  if (return_buffer)  MEMclose(&return_buffer);

  return(status);
}
