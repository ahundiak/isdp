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
#include        <sys/types.h>
#include        <sys/stat.h>

#define LIST_MCF         11
#define CHECKOUT_BTN     35
#define COPY_LOCAL_BTN   37

extern MEMptr PDU_storage_area;
extern struct PDUforms  forms;
extern MEMptr PDU_parts_list_bufr;
extern struct PDUrefresh	*refresh;
extern struct PDUuser	        *user;
extern struct PDUpart	        *part;
extern MEMptr PDU_child_buffer;
extern MEMptr PDU_attach_bufr;
extern MEMptr PDU_view_buffer;
extern MEMptr PDU_param_buffer;
extern MEMptr PDUchild_dyn_buffer;
extern MEMptr PDU_dyn_attr_bufr;
extern MEMptr PDU_dyn_data_bufr;
extern int    PDU_mcf_list;
extern int    *PDU_parts_index;
extern int    PDU_selected_rows;
extern int    PDU_command;
extern struct PDUcat_node *PDU_param_cat_list;
extern Form   PDU_form_id;
extern int    PDU_dyn_index;
extern int    PDMdebug_on;
extern char *ep_project;
extern char *ep_catalog;
extern char *en_itemname;
extern char *ep_rev;
extern char *ep_parttype;
extern char *ep_desc;
extern short PDU_read_only_file;

int PDUext_checkin ()
  {
  int				status = PDM_S_SUCCESS;
  int				sts = PDM_S_SUCCESS;
  int                           type_col;
  char                          **list_row;
  MEMptr                        buffer = NULL;
  struct PDUcat_node            *head = NULL;
  MEMptr                        reformatted_buffer = NULL;
  
  
  _pdm_debug("In the PDUext_checkin function",0);

  _pdm_debug("catalog = <%s>", refresh->rev_catalog);
  _pdm_debug("partid = <%s>", refresh->rev_partid);
  _pdm_debug("revision = <%s>", refresh->rev_revision);
  _pdm_debug("parttype = <%s>", refresh->rev_parttype);
  _pdm_debug("filename = <%s>", refresh->rev_filename);

  /* Initialize PDU_dyn_index */
  PDU_dyn_index = 1;

  /* query for part type */
  if ((!refresh->rev_parttype) || (strcmp(refresh->rev_parttype, "") == 0))
    {
    status = PDMquery_part_type(refresh->rev_catalog,
                 refresh->rev_partid, refresh->rev_revision, &buffer);
    _pdm_status("PDMquery_part_type", status);

    if (PDMdebug_on)
      MEMprint_buffer("parttype buffer", buffer, PDU_DEBUG_FILE);

    if ((buffer) && (status == PDM_S_SUCCESS))
      {
      MEMbuild_array(buffer);
      status = PDUget_buffer_col(buffer, "p_parttype", &type_col);
      if (status != PDM_S_SUCCESS)
        return(status);

      PDUsetup_buffer(buffer, ROW, &list_row);

      PDUfill_in_string(&refresh->rev_parttype,
                  list_row[(buffer->columns * 0) + type_col]);
      _pdm_debug("parttype = <%s>", refresh->rev_parttype);
      MEMclose(&buffer);
      }
    }


  /* check to see if part is valid */
/* SUN */
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
      (strcmp(refresh->rev_parttype,"D") != 0) &&
      (strcmp(refresh->rev_parttype,"d") != 0) &&
      (strcmp(refresh->rev_parttype,"a") != 0)) 
      {
       return(PDM_E_INVALID_PART_TYPE);
      }

  /* check part type */
     
     /* if macro library */
/* SUN */
/*
  if (((refresh->rev_parttype != NULL)) && 
      (strcmp(refresh->rev_parttype,"M") == 0) ||
      (strcmp(refresh->rev_parttype,"m") == 0) )
*/
     /* put checkin parametric library command on queue */ 
/*
     {
      responses[0] = EX_CMD_KEY;
      strings[0] = "PDChInLb";
      sts = PDUprepare_queue(responses,strings,1);
      _pdm_status("PDMprepare_queue (checkin parametric part)",sts);
*/
/*
      return(sts);
     }
*/
  /* KLUDGE: must link the filename to a temporary name because nfm will 
     delete the local copy */
/*
      _pdm_debug("Linking the file to a temporary name",0);

      if ((refresh->rev_filename) && (strcmp(refresh->rev_filename,"")))
        {
	  save_filename = (char *) malloc (strlen(user->wrkst_cwd) + 
					strlen(filename) + 2);
	  strcpy(save_filename, user->wrkst_cwd);
	  strcat(save_filename,"/");
	  strcat(save_filename,refresh->rev_filename);

	  tmp_filename = (char *) malloc (strlen(user->wrkst_cwd) + 16);
	  strcpy(tmp_filename, user->wrkst_cwd);
	  strcat(tmp_filename,"/");
	  strcat(tmp_filename,"tmptmptmptmptm");
	
          status = link (save_filename, tmp_filename);
	  _pdm_debug(" link status = %d", status);

          if (status == -1)
            {
             _pdm_debug ("PDUext_checkin link (save, tmp) failed; errno = <%d>", errno);
            }
          }
  _pdm_debug("Calling PDMrcheckin",0);                      
*/

  /* Check to see if any parametric dyn. attrs are involved, if so, reformat
     the PDUchild_dyn_buffer buffer. */
  if (PDUchild_dyn_buffer)
     {
      status = PDMrecreate_validated_dyn_databufr(
                                                  PDUchild_dyn_buffer,
                                                  &reformatted_buffer
                                                 );
      _pdm_status("PDMrecreate_validated_dyn_databufr", status);

      if (status != PDM_S_SUCCESS)
         {
          _pdm_debug("PDMrecreate_validated_dyn_databufr failed", 0);

          sts = PDUmessage_trans(status, 's');
          _pdm_status("PDUmessage_trans", sts);

          return(status);
         }
     }

  status = PDMrcheckin_part(
                            refresh->rev_catalog,
                            refresh->rev_partid, 
			    refresh->rev_revision,
		     	    PDU_child_buffer,
                            PDU_attach_bufr, 
                            PDU_view_buffer,
                            PDU_dyn_attr_bufr,
                            PDU_dyn_data_bufr,
                            PDU_param_buffer,
                            reformatted_buffer,
                            PDU_param_cat_list
                           );
  _pdm_status("PDMrcheckin_part", status);

  /* Initialize global variables */
  if (PDU_child_buffer)
    {
     MEMclose(&PDU_child_buffer);
     PDU_child_buffer = NULL;
    }

  if (PDU_attach_bufr)
    {
     MEMclose(&PDU_attach_bufr);
     PDU_attach_bufr = NULL;
    }

  if (PDU_view_buffer)
    {
     MEMclose(&PDU_view_buffer);
     PDU_view_buffer = NULL; 
    }

  if (PDU_param_buffer)
    {
     MEMclose(&PDU_param_buffer);
     PDU_param_buffer = NULL;
    }

 if (PDUchild_dyn_buffer)
    {
     MEMclose(&PDUchild_dyn_buffer);
     PDUchild_dyn_buffer = NULL;
    }

 if (reformatted_buffer)
    {
     MEMclose(&reformatted_buffer);
    }

  /* Free up PDU_param_cat_list */
  if (PDU_param_cat_list)
     {
      head = PDU_param_cat_list;

      while (PDU_param_cat_list)
            {
             PDU_param_cat_list = PDU_param_cat_list->next;
             free(head);
             head = PDU_param_cat_list;
            } /* end while loop */

      PDU_param_cat_list = NULL;
     }

  /* Reset PDU_dyn_index */
  PDU_dyn_index = 1;

  sts = PDUmessage_trans(status, 's');
  _pdm_status("PDUmessage_trans", sts);

  /*status_msg = PDUtranslate_message(status);
  _pdm_debug("Error string = <%s>", status_msg);

  sts = PDMset_to_state ( status, "PDM", status_msg );
  _pdm_status ("PDMset_to_state", sts);*/

  if (status == NFM_E_NOT_CO_USER)
    status = PDM_E_NOT_CHECKOUT_USER;

  /* reset the file local and workflow state columns */
  if ((PDU_command != PDC_M_DEACTIVATE_CHECKIN) &&
      (PDU_command != PDC_M_CREATE_TOP_DOWN) &&
      (PDU_form_id != forms.part_operations_form_id) &&
      (PDU_mcf_list == TRUE) && (status == PDM_S_SUCCESS))
    PDUupdate_form_after_checkin_out(CHECKIN);

  refresh->status = status;
  return ( status );
  }
  			
int PDUcheckin()
{
char    *command_string = NULL;
int     command_type;
int     status = PDM_S_SUCCESS;
struct  stat file_status;
mode_t  mode;
char    dir_entry_name[256];

  if ((PDU_command == PDC_M_DEACTIVATE_CHECKIN) ||
      (PDU_command == PDC_M_CREATE_TOP_DOWN) ||
      (PDU_form_id == forms.part_operations_form_id) ||
      (PDU_form_id == forms.rev_assy_form_id))
    {
    status = PDUint_checkin();
    _pdm_status("PDUint_checkin", status);

    if (status == PDM_S_SUCCESS)
       {
        status = PDUext_checkin();
        _pdm_status("PDUext_checkin", status);

        if ((status == PDM_S_SUCCESS) && (forms.local_files_form_id))
          {
          _pdm_debug("enabling command buttons", 0);
          FIg_enable(forms.local_files_form_id, CHECKOUT_BTN);
          FIg_enable(forms.local_files_form_id, COPY_LOCAL_BTN);
          }

        /* find the selected row if the part list area is displayed */
        if ((PDU_mcf_list == TRUE) && (status == PDM_S_SUCCESS) &&
            (PDU_form_id != forms.part_operations_form_id))
          {
          _pdm_debug("calling PDUupdate_list_after_deactchkin", 0);
          status = PDUupdate_list_after_deactchkin(forms.local_files_form_id,
                                                   LIST_MCF);
          _pdm_status("PDUupdate_list_after_deactchkin", status);
          }

        if (PDU_form_id == forms.part_operations_form_id)
          {
          _pdm_debug("resetting refresh information",0);
          PDUfill_in_string(&refresh->rev_project,ep_project);
          PDUfill_in_string(&refresh->rev_catalog,ep_catalog);
          PDUfill_in_string(&refresh->rev_partid,en_itemname);
          PDUfill_in_string(&refresh->rev_revision,ep_rev);
          PDUfill_in_string(&refresh->rev_parttype,ep_parttype);
          PDUfill_in_string(&refresh->rev_description,ep_desc);

          if (PDU_read_only_file)
            {
            dir_entry_name[0] = '\0';
            strcpy(dir_entry_name, user->wrkst_cwd);
            strcat(dir_entry_name, "/");
            strcat(dir_entry_name, refresh->rev_filename);
            _pdm_debug("changing permissions on <%s>", dir_entry_name);
            status = stat(dir_entry_name, &file_status);
            if (status == 0)
               {
                /* Change file permissions to read only */
                mode = S_IRUSR | S_IRGRP | S_IROTH;
                status = PDUchmod(dir_entry_name, mode);
                _pdm_status("PDUchmod", status);
                if (status != PDM_S_SUCCESS)
                  return(status);
               }
            PDU_read_only_file = FALSE;
            }
          }
      }

    PDUmessage(status, 's');
    }
  else
    {
    PDUfill_in_string(&command_string, "check in");
    command_type = CHECKIN;
  
    status = PDUcheck_part(command_string, command_type);
    _pdm_status("PDUcheck_part", status);
  
    if ((status == PDM_S_SUCCESS) && (forms.local_files_form_id))
      {
      _pdm_debug("enabling command buttons", 0);
      FIg_enable(forms.local_files_form_id, CHECKOUT_BTN);
      FIg_enable(forms.local_files_form_id, COPY_LOCAL_BTN);
      }
    }

  return(status);
}  /* end PDUcheckin */

int PDUupdate_list_after_deactchkin(form, field)
  Form  form;
  int   field;
{
  int    status = PDM_S_SUCCESS;
  int    row;
  int    column;
  int    num_rows;
  int    local_col;
  int    state_col;
  int    update_col;
  int    length;
  int    select, pos;
  int    index;
  char   *catalog = NULL;
  char   *partid = NULL;
  char   *revision = NULL;
  char   *string = NULL;
  char   **data_row;
  static char *text;
  MEMptr ret_bufr = NULL;

  _pdm_debug("in the function PDUupdate_list_after_deactchkin", 0);

  status = PDMget_state(refresh->rev_catalog, refresh->rev_partid,
                        refresh->rev_revision, &ret_bufr);
  _pdm_status(" PDMget_state", status);

  if (ret_bufr != NULL)
    {
    MEMbuild_array(ret_bufr);
    PDUsetup_buffer(ret_bufr, ROW, &data_row);
    PDUfill_in_string(&string, data_row[(ret_bufr->columns * 0) + 0]);
    }

  FIfld_get_num_rows(form, field, &num_rows);
  for (row = 0; row < num_rows; ++row)
     {
     for (column = 0; column < 3; ++column)
        {
        FIfld_get_text_length(form, field, row, column, &length);
        text = (char *) malloc (sizeof (char) * length + 1);
        memset(text, NULL, sizeof (char) * length + 1);
        FIfld_get_text(form, field, row, column, length, (unsigned char *)text, 
                       &select, &pos);

        if (column == 0) PDUfill_in_string(&catalog, text);
        if (column == 1) PDUfill_in_string(&partid, text);
        if (column == 2) PDUfill_in_string(&revision, text);
        PDUfree_string(&text);
        }

      if (catalog && partid && revision &&
         (strcmp(catalog, refresh->rev_catalog) == 0) &&
         (strcmp(partid, refresh->rev_partid) == 0) &&
         (strcmp(revision, refresh->rev_revision) == 0))
        {
        /* reset the file local and workflow state columns */
        MEMbuild_array(PDU_parts_list_bufr);
        status = PDUget_buffer_col(PDU_parts_list_bufr, "p_local", &local_col);
        if (status != PDM_S_SUCCESS)
          return(status);

        status =PDUget_buffer_col(PDU_parts_list_bufr,"n_statename",&state_col);
        if (status != PDM_S_SUCCESS)
          return(status);

        status = PDUget_buffer_col(PDU_parts_list_bufr, "p_update",&update_col);
        if (status != PDM_S_SUCCESS)
          return(status);


        /* unselect the row that of the part */
        if (PDU_parts_index[row] != -1)
          {
          FImcf_set_select(form,field,row,FALSE);
          PDU_parts_index[row] = -1;
          PDU_selected_rows = PDU_selected_rows - 1;
          _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
          }

        /* reset the file local column */
        FIfld_set_text(form,field,row,local_col,"CHECKED IN",FALSE);
        MEMwrite_data(PDU_parts_list_bufr, "CHECKED IN", row + 1, local_col+1);

        /* reset the state column */
        FIfld_set_text(form, field, row,state_col, string, FALSE);
        MEMwrite_data(PDU_parts_list_bufr,string,row + 1, state_col + 1);

        /* reset the update column */
        FIfld_set_text(form, field, row,update_col, "NA", FALSE);
        MEMwrite_data(PDU_parts_list_bufr,"NA",row + 1, update_col + 1);
        break;
        }

     /* clear out the fields */
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
       _pdm_debug("text = <%s>", text);
       if (strcmp(text, "") == 0)
         {
         /* unselect the row that of the part */
         _pdm_debug("PDU_parts_index[row] = <%d>", (char *)PDU_parts_index[row]);
         if (PDU_parts_index[row] != -1)
          {
          FImcf_set_select(form,field,row,FALSE);
          PDU_parts_index[row] = -1;
          PDU_selected_rows = PDU_selected_rows - 1;
          _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);
          }

        /* reset the file local column */
        FIfld_set_text(form,field,row,local_col,"CHECKED IN",FALSE);
        MEMwrite_data(PDU_parts_list_bufr, "CHECKED IN", row + 1,local_col+1);

        /* reset the update column */
        FIfld_set_text(form, field, row,update_col, "NA", FALSE);
        MEMwrite_data(PDU_parts_list_bufr,"NA",row + 1, update_col + 1);
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
