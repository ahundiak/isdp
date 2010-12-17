#include	<PDUerror.h>
#include	<PDUstr.h>
#include        <PDUfile_def.h>
#include        <PDUforms.h>
#include        <PDUuser.h>
#include	<MEMstruct.h>
#include	<MEMerrordef.h>
#include        "PDUprompt.h"
#include        "PDUcommand.h"
#include        "PDUproto.h"
#include        "PDMproto.h"

#define LIST_MCF             11
#define CHECKIN_BTN          33   
#define DESIGN               46
#define REVIEW_DESIGN        72
#define DELETE_LOCAL_BTN     36

extern MEMptr PDU_storage_area;
extern struct PDUforms  forms;
extern struct PDUuser   *user;
extern MEMptr PDU_parts_list_bufr;
extern int PDU_checkout_type;
extern int PDU_mcf_list;
extern int PDU_structure_list;
extern int *PDU_parts_index;
extern int PDU_selected_rows;
extern int PDU_command;
extern MEMptr PDU_part_file_buffer;
extern short PDU_load_file_buffer;
extern short PDU_chkout_single;
extern struct PDUrefresh	*refresh;

int PDUext_checkout ()
  {
  int				status = PDM_S_SUCCESS;
  int				sts = PDM_S_SUCCESS;
  int                           row;
  int                           file_col;
  char                          *status_msg;
  char                          answer[2];
  char                          *file = NULL;
  char                          **data_row;
  char                          *prompt_str = NULL;
  char                          catalog[40];
  char                          part[40];
  char                          rev[40];
  MEMptr                        file_bufr = NULL;
  MEMptr                        files_bufr = NULL;
  MEMptr                        attach_info_bufr = NULL;
   
  _pdm_debug("PDU -- In the PDUext_checkout function",0);

  /* check to see if the part is checked in */
  if (PDU_checkout_type == NONACT) /* status has not been checked */
    {
    status = PDMrcheck_part_status(refresh->rev_catalog, refresh->rev_partid,
                                   refresh->rev_revision);
    _pdm_status("PDMrcheck_part_status", status);
  
    if (status == MEM_S_SUCCESS)
      {
      status = PDM_E_ERROR_RETRIEVING_STATUS;
      PDUmessage(status, 's');
      return(status);
      }

    if (PDU_command == PDC_M_CHECKOUT)
      {
      _pdm_debug("processing for PDU_command == PDC_M_CHECKOUT", 0);
      if ((status != PDM_I_CHECKED_IN) && 
          (status != PDM_I_COPIED_TO_LOCAL_BY_YOU) &&
          (status != PDM_I_ATTACHED_TO_LOCAL_ASSY))
        {
        PDUmessage(status, 's');
        return(status);
        }
      }

    else if (PDU_command == PDC_M_CHECKOUT_ACTIVATE)
      {
      if (status == PDM_I_CHECKED_OUT_BY_ANOTHER_USER)
        {
        PDUmessage(status, 's');
        return(status);
        }
      else if (((status == PDM_I_CHECKED_OUT_BY_YOU) ||
                (status == PDM_I_NEVER_CHECKED_IN)) && 
                (PDU_load_file_buffer == TRUE))
        {
        if (status == PDM_I_NEVER_CHECKED_IN)
          {
          _pdm_debug("checking filename for NULL", 0);
          if ((!(refresh->rev_filename) ||
             (refresh->rev_filename) && (!(strlen(refresh->rev_filename)))))
            {
            _pdm_debug("filename is NULL", 0);
            if ((refresh->rev_parttype) && 
                ((strcmp(refresh->rev_parttype, "N") == 0) ||
                (strcmp(refresh->rev_parttype, "n") == 0)))
              {
              PDUmessage(PDM_E_RETRIEVE_NONGRAPHIC, 's');
              return(PDM_E_RETRIEVE_NONGRAPHIC);
              }
            else
              {
              PDUmessage(PDM_E_NO_PART_FILES, 's'); 
              return(PDM_E_NO_PART_FILES);
              }
            }
          }
        _pdm_debug("setting status to PDM_E_PART_CHECKED_OUT", 0);
        status = PDM_E_PART_CHECKED_OUT;
  
        /* reset the rows in the mcf */
        PDUupdate_checked_out_parts();
  
        return(status);
        }
      else if ((status != PDM_I_CHECKED_IN) && 
               (status != PDM_I_CHECKED_OUT_BY_YOU) &&
               (status != PDM_I_NEVER_CHECKED_IN) && 
               (status != PDM_I_COPIED_TO_LOCAL_BY_YOU) && 
               (status != PDM_I_ATTACHED_TO_LOCAL_ASSY) && 
               (status != PDM_I_CHECKED_OUT_BY_ANOTHER_USER))
        {
        PDUmessage(status, 's');
        return(status);
        }
      }
    }

  sts = PDMvalidate_user_access("PDMCheck Out Part", NULLSTR,
           refresh->rev_catalog, NULLSTR, refresh->rev_partid,
           refresh->rev_revision );
  _pdm_status ("PDMvalidate_user_access", sts);

   if (sts != PDM_S_SUCCESS)
      {
       PDUmessage(status, 's');
       return(sts);
      }

  _pdm_debug("Default case ", 0);

  _pdm_debug("retrieving list of filenames for part", 0);
  status = PDMget_filenames(
                            refresh->rev_catalog,
                            refresh->rev_partid,
                            refresh->rev_revision,
                            &file_bufr
                           );
   _pdm_status("PDMget_filenames", status);
 
   if ( status != PDM_S_SUCCESS )
     {
     PDUmessage(status, 's');
     MEMclose(&file_bufr);
     file_bufr = NULL;
     return(status);
     }

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
        _pdm_debug("checking to see if file is managed by PDM", 0);
        status = PDMGetPartInfoGivenFileName(file, catalog, part, rev);
        _pdm_status("PDMGetPartInfoGivenFileName", status);
 
        if (status != PDM_S_SUCCESS)
          {
          _pdm_debug("file <%s> has no entry in the LFM", file);
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
            return(status);
            }
          }
        }
      }

  /* check if part type is parametric */
/* SUN */
  if ( ((refresh->rev_parttype)) &&
       (strcmp(refresh->rev_parttype,"P") == 0) ||
       (strcmp(refresh->rev_parttype,"p") == 0) )
       return(PDM_E_CAN_NOT_CHECKOUT_PARAMETRIC_PART);

  /* check if part type is non-graphic */
/* SUN */
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

  _pdm_debug("PDU_chkout_single = %d", (char *)PDU_chkout_single);

  if (PDU_chkout_single)
    {
    status = PDUcheckout_part(files_bufr, attach_info_bufr, 1);
    _pdm_status("PDUcheckout_part", status);
    }
  else
    {
    status = PDUcheckout_part(files_bufr, attach_info_bufr, 0);
    _pdm_status("PDUcheckout_part", status);
    }

  if (status != PDM_S_SUCCESS)
     {
      _pdm_debug("PDUcheckout_part failed", 0);
      return(status);
     }

  /* reset the file local and workflow state columns */
  if ((PDU_mcf_list == TRUE) && (status == PDM_S_SUCCESS))
    PDUupdate_form_after_checkin_out(CHECKOUT);

  if ((status == PDM_S_SUCCESS) && (PDU_load_file_buffer == TRUE))
    {
    status = PDUload_file_buffer(refresh->rev_catalog, refresh->rev_partid,
                               refresh->rev_revision, refresh->rev_description,
                               "");
    _pdm_status("PDUload_file_buffer", status);
    if (status != PDM_S_SUCCESS)
      _pdm_debug("failed to load file buffer after checkout", 0);
    }

  status_msg = (char *) PDUtranslate_message(status);
  _pdm_debug("Error string = <%s>", status_msg);

  sts = PDMset_to_state ( status, "PDM", status_msg );
  _pdm_status ("PDMset_to_state", sts);

  PDUmessage(status, 's');

  return ( status );
 }
 
int PDUcheckout()
{
char    *command_string = NULL;
int     command_type;
int     status = PDM_S_SUCCESS;
char    *msg = NULL;

  _pdm_debug("In the function PDUcheckout", 0);

  _pdm_debug("refresh->rev_filename = <%s>", refresh->rev_filename);

  if (PDU_checkout_type == ACT)
    {
    if ((refresh->rev_catalog == NULL) || (strcmp(refresh->rev_catalog, "")==0))
      {
      msg = (char *) PDUtranslate_message(PDM_I_ENTER_CATALOG);
      FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, msg);
      status = PDM_I_ENTER_CATALOG;
      return(status);
      }

    if ((refresh->rev_partid == NULL) || (strcmp(refresh->rev_partid, "") ==0))
      {
      msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
      FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, msg);
      status = PDM_I_ENTER_PART;
      return(status);
      }
  
    if ((refresh->rev_revision == NULL) || 
        (strcmp(refresh->rev_revision, "")==0))
      {
      msg = (char *) PDUtranslate_message(PDM_I_ENTER_REVISION);
      FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, msg);
      status = PDM_I_ENTER_REVISION;
      return(status);
      }

    if ((refresh->rev_filename == NULL) || 
        (strcmp(refresh->rev_filename, "")==0))
      {
      msg = (char *) PDUtranslate_message(PDM_E_ENTER_FILENAME);
      FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, msg);
      status = PDM_E_ENTER_FILENAME;
      return(status);
      }

    status = PDUext_checkout();
    _pdm_status(" PDUext_checkout (and activate)", 0);

    refresh->status = status;

    if ((status == PDM_S_SUCCESS) && (forms.local_files_form_id))
      {
      FIg_enable(forms.local_files_form_id, CHECKIN_BTN);
      FIg_enable(forms.local_files_form_id, DESIGN);
      FIg_enable(forms.local_files_form_id, REVIEW_DESIGN);
      }
    else
      {
      PDUmessage(status, 's');
      return(status);
      }
    }
  else
    {
    PDUfill_in_string(&command_string, "check out");
    command_type = CHECKOUT;
  

    if ((PDU_structure_list) && (PDU_selected_rows > 1))
      {
      status = PDUcheckout_structure(command_string, command_type);
      _pdm_status("PDUcheckout_structure", status);
      }
    else
      {
      status = PDUcheck_part(command_string, command_type);
      _pdm_status("PDUcheck_part", status);
      }

    if ((status == PDM_S_SUCCESS) && (forms.local_files_form_id))
      {
      FIg_enable(forms.local_files_form_id, CHECKIN_BTN);
      FIg_enable(forms.local_files_form_id, DESIGN);
      FIg_enable(forms.local_files_form_id, REVIEW_DESIGN);
      FIg_enable(forms.local_files_form_id, DELETE_LOCAL_BTN);
      }
    }

  return(status);
}  /* end PDUcheckout */

int PDUupdate_form_after_checkin_out(type)
    int      type;
{
  int				status = PDM_S_SUCCESS;
  int                           local_col;
  int                           state_col;
  int                           update_col;
  int                           column;
  int                           row;
  int                           length;
  int                           field;
  int                           select, pos;
  int                           index;
  static char                   *text;
  char                          *state = NULL;
  char                          *catalog = NULL;
  char                          *partid = NULL;
  char                          *revision = NULL;
  char                          **data_row;
  MEMptr                        ret_bufr = NULL;
  Form                          form;

    _pdm_debug("in the function PDUupdate_form_after_checkin_out", 0);

    form = forms.local_files_form_id;
    field = LIST_MCF;

    status = PDMget_state(refresh->rev_catalog, refresh->rev_partid,
                          refresh->rev_revision, &ret_bufr);
    _pdm_status(" PDMget_state", status);

    if (ret_bufr != NULL)
      {
      MEMbuild_array(ret_bufr);
      PDUsetup_buffer(ret_bufr, ROW, &data_row);
      PDUfill_in_string(&state, data_row[(ret_bufr->columns * 0) + 0]);
      }

    status = MEMbuild_array(PDU_parts_list_bufr);
    _pdm_status("MEMbuild_array", status);

    if (status != MEM_S_SUCCESS)
      return(status);
 
    status = PDUget_buffer_col(PDU_parts_list_bufr, "p_local", &local_col);
    if (status != PDM_S_SUCCESS)
          return(status);

    status = PDUget_buffer_col(PDU_parts_list_bufr, "n_statename", &state_col);
    if (status != PDM_S_SUCCESS)
          return(status);

    status = PDUget_buffer_col(PDU_parts_list_bufr, "p_update", &update_col);
    if (status != PDM_S_SUCCESS)
          return(status);

    _pdm_debug("PDU_parts_list_bufr->rows = %d", 
                (char *)PDU_parts_list_bufr->rows);

    /* find row in the part listing area that matches the part in the refresh */
    for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
       {
       _pdm_debug("row = %d", (char *)row);
       for (column = 0; column < 3; ++column)
          {
          FIfld_get_text_length(form, field, row, column, &length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          FIfld_get_text(form, field, row, column, length, 
                        (unsigned char *)text, &select, &pos);

          if (column == 0) PDUfill_in_string(&catalog, text);
          else if (column == 1) PDUfill_in_string(&partid, text);
          else if (column == 2) PDUfill_in_string(&revision, text);
          PDUfree_string(&text);
          }

          _pdm_debug("checking cat/part/rev for NULL", 0);
          if ( catalog && partid && revision &&
               (strcmp(refresh->rev_catalog, catalog) == 0) &&
               (strcmp(refresh->rev_partid, partid) == 0) &&
               (strcmp(refresh->rev_revision, revision) == 0) )
            {
            /* unselect the row that of the part */
            /*if ((PDU_parts_index[row] != -1) && (PDU_checkout_type != ACT))*/
            if (PDU_parts_index[row] != -1)
              {
              FImcf_set_select(form,field,row,FALSE);
              PDU_parts_index[row] = -1;
              PDU_selected_rows = PDU_selected_rows - 1;
              _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
              }
  
            if (type == CHECKOUT)
              {
              /* reset the file local column */
              FIfld_set_text(form,field,row,local_col,"CHECKED OUT",FALSE);
              MEMwrite_data(PDU_parts_list_bufr, "CHECKED OUT", row + 1, 
                            local_col + 1);
         
              /* reset the update column */
              FIfld_set_text(form,field,row,update_col,"Y",FALSE);
              MEMwrite_data(PDU_parts_list_bufr, "Y", row + 1, 
                            update_col + 1);
              }

            else if ((type == CHECKIN) || (type == CANCEL_CHECKOUT))
              {
              /* reset the file local column */
              FIfld_set_text(form,field,row,local_col,"CHECKED IN",FALSE);
              MEMwrite_data(PDU_parts_list_bufr, "CHECKED IN", row + 1, 
                            local_col + 1);
         
              /* reset the update column */
              FIfld_set_text(form,field,row,update_col,"NA",FALSE);
              MEMwrite_data(PDU_parts_list_bufr, "NA", row + 1, 
                            update_col + 1);
              }

            FIfld_set_text(form, field, row, state_col, state, FALSE);
            MEMwrite_data(PDU_parts_list_bufr,state, row + 1, state_col + 1);
          
            break;
            }
       /* clear out fields */
       catalog = NULL_STRING;
       partid = NULL_STRING;
       revision = NULL_STRING;
       }

    index = row;

    /* check for multiple files */
    for (row = index + 1; row < PDU_parts_list_bufr->rows; ++row)
       {
       _pdm_debug("row = <%d>", (char *)row);
       FIfld_get_text_length(form, LIST_MCF, row, 0, &length);
       text = (char *) malloc (sizeof (char) * length + 1);
       memset(text, NULL, sizeof (char) * length + 1);
       FIfld_get_text(form, LIST_MCF, row, 0, length, (unsigned char *)text,
                      &select, &pos);
       if (strcmp(text, "") == 0)
         {
         /* unselect the row that of the part */
         if (PDU_parts_index[row] != -1)
           {
           FImcf_set_select(form,field,row,FALSE);
           PDU_parts_index[row] = -1;
           PDU_selected_rows = PDU_selected_rows - 1;
           _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
           }
  
         if (type == CHECKOUT)
           {
           /* reset the file local column */
           FIfld_set_text(form,field,row,local_col,"CHECKED OUT",FALSE);
           MEMwrite_data(PDU_parts_list_bufr, "CHECKED OUT", row + 1, 
                         local_col + 1);
      
           /* reset the update column */
           FIfld_set_text(form,field,row,update_col,"Y",FALSE);
           MEMwrite_data(PDU_parts_list_bufr, "Y", row + 1, 
                         update_col + 1);
           }

         else if ((type == CHECKIN) || (type == CANCEL_CHECKOUT))
           {
           /* reset the file local column */
           FIfld_set_text(form,field,row,local_col,"CHECKED IN",FALSE);
           MEMwrite_data(PDU_parts_list_bufr, "CHECKED IN", row + 1, 
                         local_col + 1);
         
           /* reset the update column */
           FIfld_set_text(form,field,row,update_col,"NA",FALSE);
           MEMwrite_data(PDU_parts_list_bufr, "NA", row + 1, 
                         update_col + 1);
           }
         }
       else
         {
         _pdm_debug("multiple files not found", 0);
         break;
         }
       PDUfree_string(&text);
       }

    return(status);
 } 

int PDUupdate_checked_out_parts()
{
  int				status = PDM_S_SUCCESS;
  int                           column;
  int                           row;
  int                           length;
  int                           field;
  int                           select, pos;
  int                           index;
  static char                   *text;
  char                          *catalog = NULL;
  char                          *partid = NULL;
  char                          *revision = NULL;
  Form                          form;

    _pdm_debug("in the function PDUupdate_checked_out_parts", 0);

    form = forms.local_files_form_id;
    field = LIST_MCF;

    _pdm_debug("updating part:", 0);
    _pdm_debug("refresh->rev_catalog = <%s>", refresh->rev_catalog);
    _pdm_debug("refresh->rev_partid = <%s>", refresh->rev_partid);
    _pdm_debug("refresh->rev_revision = <%s>", refresh->rev_revision);

    _pdm_debug("PDU_parts_list_bufr->rows = %d", 
               (char *)PDU_parts_list_bufr->rows);

    /* find row in the part listing area that matches the part in the refresh */
    for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
       {
       _pdm_debug("row = %d", (char *)row);
       for (column = 0; column < 3; ++column)
          {
          FIfld_get_text_length(form, field, row, column, &length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          FIfld_get_text(form, field, row, column, length, 
                        (unsigned char *)text, &select, &pos);

          if (column == 0) PDUfill_in_string(&catalog, text);
          else if (column == 1) PDUfill_in_string(&partid, text);
          else if (column == 2) PDUfill_in_string(&revision, text);
          PDUfree_string(&text);
          }

          _pdm_debug("checking cat/part/rev for NULL", 0);
          if ( catalog && partid && revision &&
               (strcmp(refresh->rev_catalog, catalog) == 0) &&
               (strcmp(refresh->rev_partid, partid) == 0) &&
               (strcmp(refresh->rev_revision, revision) == 0) )
            {
            /* unselect the row that of the part */
            if (PDU_parts_index[row] != -1)
              {
              FImcf_set_select(form,field,row,FALSE);
              PDU_parts_index[row] = -1;
              PDU_selected_rows = PDU_selected_rows - 1;
              _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
              }
            break;
            }
       /* clear out fields */
       catalog = NULL_STRING;
       partid = NULL_STRING;
       revision = NULL_STRING;
       }

    index = row;

    /* check for multiple files */
    for (row = index + 1; row < PDU_parts_list_bufr->rows; ++row)
       {
       _pdm_debug("row = <%d>", (char *)row);
       FIfld_get_text_length(form, LIST_MCF, row, 0, &length);
       text = (char *) malloc (sizeof (char) * length + 1);
       memset(text, NULL, sizeof (char) * length + 1);
       FIfld_get_text(form, LIST_MCF, row, 0, length, (unsigned char *)text,
                      &select, &pos);
       if (strcmp(text, "") == 0)
         {
         /* unselect the row that of the part */
         if (PDU_parts_index[row] != -1)
           {
           FImcf_set_select(form,field,row,FALSE);
           PDU_parts_index[row] = -1;
           PDU_selected_rows = PDU_selected_rows - 1;
           _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
           }
         }
       else
         {
         _pdm_debug("multiple files not found", 0);
         break;
         }
       PDUfree_string(&text);
       }

    return(status);
}
