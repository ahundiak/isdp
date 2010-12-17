#include <FI.h>
#include <stdio.h>
#include <string.h>
#include <PDUint.h>
#include <PDUintdef.h>
#include <PDUprompt.h>
#include <PDUstr.h>
#include <PDUuser.h>
#include <PDUfile_def.h>
#include <PDUforms.h>
#include <PDUproto.h>
#include <MEMerrordef.h>

#define PART_BTN      57
#define PART_FILE_FLD 29
#define LIST_MCF      11
#define DELETE_LOCAL_BTN 36

extern struct PDUrefresh        *refresh;
extern struct PDUuser           *user;
extern struct PDUforms  forms;
extern MEMptr PDU_parts_list_bufr;
extern MEMptr PDU_part_file_buffer;
extern Form   PDU_form_id;
extern Form   place_part_f;
extern Form   ModifyPartForm;
extern int    PDU_validate_access;
extern int    PDU_selected_rows;
extern int    PDU_mcf_list;
extern int    PDMdebug_on;
extern int    PDU_file_rows;
extern int    *PDU_parts_index;
extern char   *PDU_save_filename;
extern char   *np_catalog;
extern char   **PDU_file_list;
extern int    new_mode;
extern int    similar_mode;
extern int    PDU_pdm_initialized;
extern int    PDU_local_files_created;
extern short  PDU_activate_copy;

#define LEVEL_COL	0

/****************************************************************************

Document:	PDUext_get_children

Description:
	This function provides external support to the PDU command
	PDC_M_CREATE_GRAPHICS.  It sends information from the review
	refresh partspec to the server, and receives a "child buffer",
	which contains information needed to place part pointers for
	the parts contained in a non-graphic assembly. 

Algoritm:
	1. Verify review refesh part specification.
	2. Retrieve child buffer from host (PDMget_children).
	3. Copy pointer to child buffer to refresh area.

Return Status:
	PDM_S_SUCCESS	-	Success
	Other Status	-	Error status returned from PDMget_children

Notes:
	The buffer has one column for each attribute in the CIT.

History:
	06/24/88	Bill Kirk	Created

*****************************************************************************/

int	PDUext_get_children ()
  {
  IGRint	status = PDM_S_SUCCESS;		/* return status */
  MEMptr	child_buffer = NULL;		/* child list buffer */

  _pdm_debug("In the function PDUext_get_children", 0);

  /* see if review refresh part spec is complete */
  status = PDUverify_part ( 'r' );
  _pdm_status("PDUverify_part", status);

  if ( 1&status )
     {
     _pdm_debug("part_list = %d", refresh->part_list);
     status = MEMclose ( (MEMptr *) &refresh->part_list );
     _pdm_status("MEMclose", status);

     /* get buffer with info for part pointers */
     status = PDMget_children ( refresh->rev_catalog, refresh->rev_partid, 
				refresh->rev_revision, &child_buffer );
     _pdm_status("PDMget_children", status);

    if  ( 1&status )
	{
	PDUbuffer_data( "child list buffer for PDC_M_CREATE_GRAPHICS", child_buffer); 

	refresh->part_list = (IGRchar *) child_buffer;
	}
     }

  return (status);
  }

int	PDUext_list_saved_views ( catalog, partid, revision, view_buffer)
  char	*catalog;
  char	*partid;
  char	*revision;
  MEMptr	*view_buffer;		/* view  buffer */
  {
  IGRint	status = PDM_S_SUCCESS;		/* return status */

  _pdm_debug("In the function PDUext_get_children", 0);

  if ( 1&status )
     {
     /* get buffer with info for part pointers */
     status = PDMshow_saved_views ( catalog, partid, revision, view_buffer );
     _pdm_status("PDMshow_saved_views", status);

     }

  return (status);
  }

int  PDUcopy (file_bufr, command, type)
  MEMptr        file_bufr;
  int        command;
  int        type;
  {
  IGRint        status = PDM_S_SUCCESS;
  IGRint        sts = PDM_S_SUCCESS;
  IGRint        action_col;
  IGRint        file_col;
  IGRint        row = 0;
  IGRchar       *status_msg;
  IGRchar       **file_data;
  IGRchar       **data_row;
  IGRchar       *action = NULL;
  IGRchar       *file = NULL;
  IGRchar       *prompt_str = NULL;
  IGRchar       status_list[200];
  IGRchar       answer[2];
  MEMptr        return_buffer = NULL;
  MEMptr        save_bufr = NULL;

  _pdm_debug ("In the function PDUcopy", 0);

  if ((file_bufr == NULL) || (file_bufr->rows == 0))
     {
     status = PDM_I_NO_FILES_FOUND;
     PDUmessage(status, 's');
     return(status);
     }
 
   status = MEMbuild_array(file_bufr);
   _pdm_status("MEMbuild_array", status);
 
   if (status != MEM_S_SUCCESS)
     {
     status = PDM_E_BUILD_BUFFER_ARRAY;
     PDUmessage(status, 's');
     return(status);
     }
 
   PDUsetup_buffer(file_bufr, ROW, &data_row);
   PDUget_buffer_col(file_bufr, "n_cofilename", &file_col);
 
   for (row = 0; row < file_bufr->rows; ++row)
      {
      PDUfill_in_string(
                        &file,
                        data_row[(file_bufr->columns * row) + file_col]
                       );
      _pdm_debug("row = %d", (char *)row);
      _pdm_debug("filename = <%s>", file);
 
      /* check to see if the file is already local */
      status = PDUverify_file(file);
      _pdm_status("PDUverify_file", status);
 
      if (status == PDM_S_SUCCESS)
        {
        prompt_str = (char *) PDUtranslate_message_and_vars(PDP_P_FILE_LOCAL,
                                                            file);
        UI_prompt(prompt_str);
        do
          {
          status = PDUget_keyin(answer);
 
          if ((answer) && (strlen(answer) > 0) &&
              (strcmp(answer,"y")) && (strcmp(answer,"Y")) &&
              (strcmp(answer,"n")) && (strcmp(answer,"N")))
            {
            status = PDM_E_INVALID_INPUT;
            }
 
          }
        while (status == PDM_E_INVALID_INPUT);
        UI_prompt(NULL_STRING);
 
        _pdm_debug("answer = <%s>", answer);
 
        if ((strcmp(answer, "n")== 0) || (strcmp(answer, "N")==0))
          {
          status = PDM_E_CMD_CANCELLED;
          PDUmessage(status, 's');
          return(status);
          }
        }
      }

  /* save off a copy of the file_bufr */
  status = MEMsplit_copy_buffer(file_bufr, &save_bufr, 0);
  _pdm_status("MEMsplit_copy_buffer", status);

  /* copy part graphics file to the workstation */
  status = PDMcopy(file_bufr, &return_buffer);
  _pdm_status ("PDMcopy (file)", status);

  if ((status != PDM_S_SUCCESS) && (PDU_form_id == forms.local_files_form_id) &&
       (PDU_mcf_list == TRUE))
    {
    /* reset the part listing area on the form */
    for (row = row; row < PDU_parts_list_bufr->rows; ++row)
       FImcf_set_select(forms.local_files_form_id, LIST_MCF, row, FALSE);

    /* reset the integer array that points to the rows */
    PDU_parts_index = (int *) malloc (sizeof (int) * PDU_parts_list_bufr->rows);
    memset((char *)PDU_parts_index, -1, sizeof (int) * PDU_parts_list_bufr->rows);
    PDU_selected_rows = 0;
 
    }

  else if ((status == PDM_S_SUCCESS) && (forms.local_files_form_id) &&
           (PDU_form_id == forms.local_files_form_id) && (PDU_mcf_list == TRUE))
    {
    /* call function to update the file local column on the form */
    if (type == REFRESH_PART)
      {
/* 2/7/96 MJG - TR 139526084 */
/* Added argument to function call.  The parts in save_bufr will be compared
   to those in return_bufr to determine which parts are attachments */

      status = PDUupdate_local_column_for_refresh(command, return_buffer,
                                                  save_bufr);
      _pdm_status("PDUupdate_local_column_for_refresh", status);
      }
    else if (type == LIST_PART)
      {
      status = PDUupdate_local_column(command, return_buffer, save_bufr);
      _pdm_status("PDUupdate_local_column", status);
      }
    }

  else if ((status == PDM_S_SUCCESS) && (forms.local_files_form_id) &&
           (PDU_form_id == forms.local_files_form_id) && (PDU_mcf_list != TRUE))
    {
    /* set up a string for the files that were not copied successfully */
    strcpy(status_list, "File(s) <");

    /* set up the file list buffer */
    MEMbuild_array(return_buffer);
    status = PDUget_buffer_col(return_buffer, "p_action", &action_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    status = PDUget_buffer_col(return_buffer, "n_cofilename", &file_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    PDUsetup_buffer(return_buffer, ROW, &file_data);

    for (row = 0; row < return_buffer->rows; ++row)
       {
       /* get the status from the return buffer */
       _pdm_debug("row = %d", (char *)row);
       PDUfill_in_string(&action,
                   file_data[(return_buffer->columns * row) + action_col]);
       _pdm_debug("action = <%s>", action);
       if ((action) && ((strcmp(action, "SUCCESS") == 0) ||
                         (strcmp(action, "NOT_MOVED") == 0) ||
                         (strcmp(action, "NO_UPDATE") == 0)))
         {
         FIg_enable(forms.local_files_form_id, DELETE_LOCAL_BTN);
         }
       else
         {
         _pdm_debug("adding data to the status list", 0);
         if (strlen(status_list) > 9)
           strcat(status_list, ", ");
         PDUfill_in_string(&file,
                   file_data[(return_buffer->columns * row) + file_col]);
         strcat(status_list, file);
         status = PDM_E_COPY_FILES;
         }
       }

      if (strlen(status_list) > 9)
      {
      strcat(status_list, "> could not be copied to local");
      FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, status_list);
      if (strlen(status_list) > 200)
        _pdm_debug("SEVERE ERROR: status_list exceeds 200 characters", 0);
      }

    }

  PDUmessage(status, 's');

  status_msg = (char *) PDUtranslate_message(status);
  _pdm_debug("Error string = <%s>", status_msg);

  sts = PDMset_to_state ( status, "PDM", status_msg );
  _pdm_status ("PDMset_to_state", sts);

  if ((status == PDM_S_SUCCESS) && (type == REFRESH_PART) && 
           (forms.local_files_form_id) &&
           (PDU_form_id == forms.local_files_form_id) && 
           (PDU_activate_copy) && (PDU_mcf_list == TRUE))
    {
    /* call function to display list of parts that may be activated */
    if ((PDU_part_file_buffer) && (PDU_part_file_buffer->rows > 0))
      {
      PDUpart_file_list_form();

      sts = WaitForEvent();
      _pdm_status("WaitForEvent", sts);

      if (!sts)
        {
         _pdm_debug("part listing form was cancelled", 0);
         PDUmessage(PDM_E_CMD_CANCELLED, 's');
         return(PDM_E_CMD_CANCELLED);
        }
      }
    else
      {
      MEMclose(&PDU_part_file_buffer);
      PDU_part_file_buffer = NULL;
      }
    }

  return (status);
  }

int PDUcopy_file()
{
char    *command_string = NULL;
int     command_type;
int     status = PDM_S_SUCCESS;

  _pdm_debug("in the function PDUcopy_file", 0);

  PDUfill_in_string(&command_string, "copy file to local");
  command_type = COPY_LOCAL;

  status = PDUcheck_part(command_string, command_type);
  _pdm_status("PDUcheck_part", status);

  return(status);
}  /* end PDUcopy_file */


int  PDUlogout ()
  {
  IGRint	status = PDM_S_SUCCESS;
  IGRint        PDMterminate();
  IGRint        *fn = NULL;
  extern IGRshort PDU_refresh_loaded;
  extern IGRint	PDU_connection;
  extern int    PDU_local_files_displayed;
  extern int    PDU_local_files_created;
  int           display;
  extern void   PDUreset_local_files_form();

  _pdm_debug ("In the function PDUlogout", 0);

  _pdm_debug("username = <%s>", user->username);
  if (!user->username)
    {
    _pdm_debug("no user is logged in", 0);
    PDUmessage(PDM_E_USER_LOGGED_IN, 's');
    return(PDM_E_USER_LOGGED_IN);
    }
  else if (strcmp(user->username, "") == 0)
    {
    _pdm_debug("no user is logged in", 0);
    PDUmessage(PDM_E_USER_LOGGED_IN, 's');
    return(PDM_E_USER_LOGGED_IN);
    }

  PDUdismiss_subforms();

  _pdm_debug("deleting PDU_form_id");
  if (PDU_form_id)
    {
    if (PDU_form_id == forms.local_files_form_id)
      {
      PDUreset_local_files_form();
      PDU_local_files_created = FALSE;
      PDU_local_files_displayed = FALSE;
      }
    else if (PDU_form_id == forms.design_form_id)
      forms.design_form_id = 0;
    FIf_erase( PDU_form_id );
    FIf_delete( PDU_form_id );
    }

  if (forms.design_form_id)
    {
    FIf_delete(forms.design_form_id);
    forms.design_form_id = 0;
    }

  if (PDU_local_files_created)
    {
    PDUreset_local_files_form();
    FIf_is_displayed(forms.local_files_form_id, &display);
    if (display)
      FIf_erase(forms.local_files_form_id);
    FIf_delete(forms.local_files_form_id);
    PDU_local_files_created = FALSE;
    PDU_local_files_displayed = FALSE;
    forms.local_files_form_id = 0;
    }

  /* check for the part selection form */
  _pdm_debug("deleting part selection form");
  if (place_part_f)
    {
    FIf_erase(place_part_f);
    FIf_delete(place_part_f);
    place_part_f = 0;
    }
  else if (ModifyPartForm)
    {
    FIf_erase(ModifyPartForm);
    FIf_delete(ModifyPartForm);
    ModifyPartForm = 0;
    }

  /* save refresh information in ascii file */
    status = PDUdefine_refresh();
    _pdm_status("PDUdefine_refresh", status);

  /* reset user structure */
  PDUuser_init();

  status = PDMrterminate ();
  _pdm_status("PDMrterminate", status);

  PDU_pdm_initialized = FALSE;

  if ( 1&status )
     {
      PDU_connection = FALSE;

      /* initialize refresh form */
      refresh_init();

      fn = (int *)PDMterminate;         
      exitdel(fn);
      status = PDM_S_SUCCESS;
     }

   return (status);
  }


int  PDUconnect ()
  {
  IGRint	status = PDM_S_SUCCESS;

  _pdm_debug ("In the function PDUconnect", 0);

/*  status = PDMreconnect(); */
  _pdm_status("PDMreconnect", status);

/*
  if ( status == PDM_S_SUCCESS )
     PDU_connection = TRUE;
  else
     PDU_connection = FALSE;
*/

  return (status);
  }



