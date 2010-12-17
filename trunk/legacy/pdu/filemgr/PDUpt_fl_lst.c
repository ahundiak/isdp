#include <stdio.h>
#include "FI.h"
#include "exdef.h"
#include "PDUform_def.h"
#include "PDUforms.h"
#include "PDUstr.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "PDUerror.h"
#include "PDUfile_def.h"
#include "PDUcommand.h"
#include "PDUproto.h"
#include "PDMproto.h"


/* Gadgets */

#define PART_FILE_LIST_MCF          16

/* Gadgets from local files form */
#define PROJECT_FLD              24
#define CATALOG_FLD              26
#define PARTNUM_FLD              27
#define PART_REV_FLD             28
#define PART_DESC_FLD            31
#define PART_FILE_FLD            29
#define LIST_MCF                 11
#define DESIGN                   46


/* Externs */

extern char * calloc();
extern char * realloc();
extern int FImcf_get_active_col();
extern int FIg_get_text_length();
extern int FIfld_get_text();
extern short PDU_part_file_list_displayed;
extern short PDU_part_file_list_created;
extern MEMptr  PDU_part_file_buffer;
extern MEMptr  PDU_parts_list_bufr;
extern struct  PDUrefresh *refresh;
extern struct  PDUforms forms;
extern char    ***PDU_update_struct;
extern int     *PDU_gadget_labels;
extern char    *PDU_save_catalog;
extern char    *PDU_save_partid;
extern char    *PDU_save_revision;
extern char    *PDU_save_description;
extern char    *PDU_save_filename;
extern short   PDU_second_row;
extern short   PDU_perm_window;
extern short   PDU_local_perm_window;
extern short   PDU_activate_copy;
extern int     *PDU_parts_index;
extern int     PDU_selected_rows;
extern int     PDM_debug_on;
extern Form    PDU_struct_type;
extern int     PDU_mcf_list;
extern int     PDU_local_files_created;


int part_file_list_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  int           length;
  int           select;
  int           pos;
  int           status = PDM_S_SUCCESS;
  int		act_row;
  int		act_pos;
  int		column;
  int		mcf_select = FALSE;
  int           responses[1];
  int           type_col;
  char          *strings[1];
  static char   *text;
  char          *msg = NULL;
  char          **data_row;
  MEMptr        ret_bufr = NULL;

  FIg_set_text(fp, FI_MSG_FIELD, NULL_STRING);
  FIg_set_text(fp, FI_PROMPT_FIELD, NULL_STRING);
  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  switch ( g_label )
  {
    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

	 f_label = 0;
         value = 0.0;

         if (PDU_local_perm_window == FALSE)
           {
           FIf_cvrt_to_perm_win(forms.local_files_form_id);
           PDU_local_perm_window = TRUE;
           }
         FIf_cvrt_to_perm_win(forms.part_file_list_form_id);
         status = PDUinitialize_help();
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }
         Help_topic("part_listing");
         break;

    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */

          /* Erase the displayed form */

         FIf_erase ( fp );
	 PDU_part_file_list_displayed = FALSE;
         FIf_delete ( fp );
	 PDU_part_file_list_created = FALSE;

         if (forms.local_files_form_id)
           {
           FIf_display(forms.local_files_form_id);
           }

	 /* reset global variables */
	 PDU_save_catalog = NULL_STRING;
	 PDU_save_partid = NULL_STRING;
	 PDU_save_revision = NULL_STRING;
	 PDU_save_description = NULL_STRING;
	 PDU_save_filename = NULL_STRING;

	 status = PDM_E_CMD_CANCELLED;
	 PDUmessage(status, 's');

         responses[0] = RESET;
         strings[0] = "";
         PDUprepare_queue(responses, strings, 1);

         break;

    case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */

          /* Process form data */

	 if ((strcmp(PDU_save_catalog, "") == 0) ||
             (strcmp(PDU_save_partid, "") == 0) ||
             (strcmp(PDU_save_revision, "") == 0) ||
             (strcmp(PDU_save_filename, "") == 0))
	   {
           status = PDM_E_NO_PARTS_SELECTED;
           PDUmessage(status, 's');
           msg = (char *)PDUtranslate_message(status);
	   FIg_set_text(fp, FI_MSG_FIELD, msg);
	   FIg_set_state_off(fp, FI_ACCEPT);
	   break;
           }

         _pdm_debug("query for parttype", 0);
         status = PDMquery_part_type(PDU_save_catalog,
                        PDU_save_partid, PDU_save_revision, &ret_bufr);
         _pdm_status("PDMquery_part_type", status);

         if ((ret_bufr) && (status == PDM_S_SUCCESS))
           {
           MEMbuild_array(ret_bufr);
           status = PDUget_buffer_col(ret_bufr, "p_parttype", &type_col);
           if (status != PDM_S_SUCCESS)
             return(status);

           PDUsetup_buffer(ret_bufr, ROW, &data_row);

           PDUfill_in_string(&refresh->rev_parttype,
                       data_row[(ret_bufr->columns * 0) + type_col]);
           _pdm_debug("parttype = <%s>", refresh->rev_parttype);
           MEMclose(&ret_bufr);
           }
         else
           {
           PDUmessage(status, 's');
           MEMclose(&ret_bufr);
           }

         if ((refresh->rev_parttype) &&
             (strcmp(refresh->rev_parttype, "G") != 0) &&
             (strcmp(refresh->rev_parttype, "g") != 0) &&
             (strcmp(refresh->rev_parttype, "D") != 0) &&
             (strcmp(refresh->rev_parttype, "d") != 0))
           {
           msg = (char *)PDUtranslate_message(PDM_E_RETRIEVE_NONGRAPHIC);
           FIg_set_text(fp, FI_MSG_FIELD,msg);
           PDUmessage(PDM_E_RETRIEVE_NONGRAPHIC, 's');
           break;
           }

	 PDUfill_in_string(&refresh->rev_catalog, PDU_save_catalog);
	 PDUfill_in_string(&refresh->rev_partid, PDU_save_partid);
	 PDUfill_in_string(&refresh->rev_revision, PDU_save_revision);
	 PDUfill_in_string(&refresh->rev_description, PDU_save_description);
	 PDUfill_in_string(&refresh->rev_filename, PDU_save_filename);

	 /* reset global variables */
	 PDU_save_catalog = NULL_STRING;
	 PDU_save_partid = NULL_STRING;
	 PDU_save_revision = NULL_STRING;
	 PDU_save_description = NULL_STRING;
	 PDU_save_filename = NULL_STRING;

          /* Erase the displayed form */
         FIf_erase ( fp );
	 PDU_part_file_list_displayed = FALSE;
         FIf_delete ( fp );
	 PDU_part_file_list_created = FALSE;

         if (forms.local_files_form_id)
         {
	 /* fill in the local files form */
	 FIg_set_text(forms.local_files_form_id, PROJECT_FLD, "");
	 FIg_set_text(forms.local_files_form_id, CATALOG_FLD, 
                      refresh->rev_catalog);
	 FIg_set_text(forms.local_files_form_id, PARTNUM_FLD, 
                      refresh->rev_partid);
	 FIg_set_text(forms.local_files_form_id, PART_REV_FLD, 
                      refresh->rev_revision);
	 FIg_set_text(forms.local_files_form_id, PART_FILE_FLD, 
                      refresh->rev_filename);
	 FIg_set_text(forms.local_files_form_id, PART_DESC_FLD,
                      refresh->rev_description);

	 /* put activate command onthe queue */
	 PDU_struct_type = forms.local_files_form_id;
         FIf_erase(forms.local_files_form_id);
         }

         if (PDU_activate_copy)
           {
           status = PDUconvert_file_before_review();
           _pdm_status("PDUconvert_file_before_review", status);

           PDUchange_review_file_permissions(refresh->rev_filename, FALSE);
           }
         PDUactivate();

         responses[0] = MOVE_ON;
         strings[0] = "";
         PDUprepare_queue(responses, strings, 1);

         break;

    case PART_FILE_LIST_MCF: 

	 FIfld_get_active_row(fp, PART_FILE_LIST_MCF, &act_row, &act_pos);
         _pdm_debug("active row = %d", (char *) act_row);
         FImcf_set_active_col(fp, PART_FILE_LIST_MCF, 0, 0);
         _pdm_debug("getting selected row", 0);
         FIfld_get_select(fp, PART_FILE_LIST_MCF, act_row, 0, &mcf_select);

         _pdm_debug("entering loop", 0);
         if (mcf_select == TRUE)
           {
           /* loop through columns in mcf to get data selected */
           for (column = 0; column < 5; ++column)
              {
              FImcf_set_active_col( fp, PART_FILE_LIST_MCF, column, column);
              FIfld_get_text_length(fp,PART_FILE_LIST_MCF,act_row,column,&length);
              _pdm_debug("text length = %d", (char *) length);
              text = (char *) malloc (sizeof (char) * length + 1);
              memset(text, NULL, sizeof (char) * length + 1);
              FIfld_get_text(fp,PART_FILE_LIST_MCF,act_row,column,length+1,
                            (unsigned char *)text, &select,&pos);
              _pdm_debug("text = <%s>", text);

              /* update the structure */
              switch (column)
                {
                case 0:
                     PDUfill_in_string(&PDU_save_catalog, text);
                     _pdm_debug("catalog = <%s>", PDU_save_catalog);
                     break;
                case 1:
                     PDUfill_in_string(&PDU_save_partid, text);
                     _pdm_debug("part num = <%s>", PDU_save_partid);
                     break;
                case 2:
                     PDUfill_in_string(&PDU_save_revision, text);
                     _pdm_debug("revision = <%s>", PDU_save_revision);
                     break;
                case 3:
                     PDUfill_in_string(&PDU_save_description,text);
                     _pdm_debug("description = <%s>", PDU_save_description);
                     break;
                case 4:
                     PDUfill_in_string(&PDU_save_filename,text);
                     _pdm_debug("filename = <%s>", PDU_save_filename);
                     break;
                }
              }  /* end for column */
           }  /* end if select */
         else
           {
	   PDU_save_catalog = NULL_STRING;
	   PDU_save_partid = NULL_STRING;
	   PDU_save_revision = NULL_STRING;
	   PDU_save_description = NULL_STRING;
	   PDU_save_filename = NULL_STRING;
           }

         break;

  } /* END switch ( g_label ) */

  return(status);

} /* END notification_routine() */

int PDUpart_file_list_form()
{
  int           sts = PDM_S_SUCCESS;
  int           status = PDM_S_SUCCESS;
  int           all_flag = FALSE;
  int           no_headings;
  int           row;
  int           cat_col;
  int           part_col;
  int           rev_col;
  int           desc_col;
  int           file_col;
  int           responses[1];
  char          *strings[1];
  char          **data;
  char          **headings;
  char          *msg;

  if (PDU_part_file_list_created == TRUE)
    return(PDM_S_SUCCESS);

  PDU_part_file_list_created = FALSE;
  PDU_part_file_list_displayed = FALSE;

  /* set global variables */
  PDU_save_catalog = NULL_STRING;
  PDU_save_partid = NULL_STRING;
  PDU_save_revision = NULL_STRING;
  PDU_save_description = NULL_STRING;
  PDU_save_filename = NULL_STRING;

  /* load the buffer into the form */
  if (PDM_debug_on)
    MEMprint_buffer("list buffer", PDU_part_file_buffer, PDU_DEBUG_FILE);

  if (PDU_part_file_buffer->rows == 1)
    {
    /* get the data from the buffer */
    MEMbuild_array(PDU_part_file_buffer);
    PDUget_buffer_col(PDU_part_file_buffer, "n_catalogname", &cat_col);
    PDUget_buffer_col(PDU_part_file_buffer, "n_itemname", &part_col);
    PDUget_buffer_col(PDU_part_file_buffer, "n_itemrev", &rev_col);
    PDUget_buffer_col(PDU_part_file_buffer, "n_itemdesc", &desc_col);
    PDUget_buffer_col(PDU_part_file_buffer, "n_cofilename", &file_col);
    PDUsetup_buffer(PDU_part_file_buffer, ROW, &data);

    PDUfill_in_string(&refresh->rev_catalog, 
                      data[(PDU_part_file_buffer->columns * 0) + cat_col]);
    PDUfill_in_string(&refresh->rev_partid,
                      data[(PDU_part_file_buffer->columns * 0) + part_col]);
    PDUfill_in_string(&refresh->rev_revision,
                      data[(PDU_part_file_buffer->columns * 0) + rev_col]);
    PDUfill_in_string(&refresh->rev_description,
                      data[(PDU_part_file_buffer->columns * 0) + desc_col]);
    PDUfill_in_string(&refresh->rev_filename,
                      data[(PDU_part_file_buffer->columns * 0) + file_col]);

    /* fill in the local files form */
    if (PDU_local_files_created)
    {
    FIg_set_text(forms.local_files_form_id, PROJECT_FLD, "");
    FIg_set_text(forms.local_files_form_id, CATALOG_FLD, refresh->rev_catalog);
    FIg_set_text(forms.local_files_form_id, PARTNUM_FLD, refresh->rev_partid);
    FIg_set_text(forms.local_files_form_id, PART_REV_FLD,refresh->rev_revision);
    FIg_set_text(forms.local_files_form_id, PART_FILE_FLD,
                 refresh->rev_filename);
    FIg_set_text(forms.local_files_form_id, PART_DESC_FLD,
                 refresh->rev_description);
    FIf_erase(forms.local_files_form_id);
    }

    /* put activate command on the queue */
    PDU_struct_type = forms.local_files_form_id;

    if (PDU_activate_copy)
      {
      status = PDUconvert_file_before_review();
      _pdm_status("PDUconvert_file_before_review", status);

      PDUchange_review_file_permissions(refresh->rev_filename, FALSE);
      }
    PDUactivate();

    responses[0] = MOVE_ON;
    strings[0] = "";
    PDUprepare_queue(responses, strings, 1);

    return(status);
    }

  sts = FIf_new(PART_FILE_LIST_FORM, "part_file_list",
                part_file_list_notification_routine,
                &forms.part_file_list_form_id);

  _pdm_debug("Creating part_file_list form", 0);
  PDU_part_file_list_created = TRUE;

  PDUsetup_single_buffer(PDU_part_file_buffer);

  all_flag = FALSE;
  no_headings = 5;
  headings = (char **) malloc (sizeof (char *) * no_headings);
  memset(headings, NULL, sizeof (char *) * no_headings);

  PDUfill_in_string(&headings[0], "n_catalogname");
  PDUfill_in_string(&headings[1], "n_itemname");
  PDUfill_in_string(&headings[2], "n_itemrev");
  PDUfill_in_string(&headings[3], "n_itemdesc");
  PDUfill_in_string(&headings[4], "n_cofilename");

  PDUsetup_popup_list(headings, no_headings, all_flag, PDU_part_file_buffer);

  PDUfree_string_array(&headings, no_headings);

  PDU_second_row = FALSE;
  PDUbufr_to_mcf(PDU_part_file_buffer, forms.part_file_list_form_id, 
                 PART_FILE_LIST_MCF);

  FIfld_set_num_rows(forms.part_file_list_form_id, PART_FILE_LIST_MCF,
                     PDU_part_file_buffer->rows);

  FIfld_set_active_row(forms.part_file_list_form_id, PART_FILE_LIST_MCF, 0, 0);

  /* reset the mcf on the local files form */
  if (PDU_mcf_list)
  {
  PDU_selected_rows = 0;
  PDU_parts_index = (int *) malloc (sizeof (int)*PDU_parts_list_bufr->rows);
  memset(PDU_parts_index, -1, sizeof (int) * PDU_parts_list_bufr->rows);
  for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
     FImcf_set_select(forms.local_files_form_id, LIST_MCF, row, FALSE); 
  }

/*
  if ((PDU_local_perm_window == TRUE) || (PDM_debug_on))
    {
    _pdm_debug("converting form to permanent window", 0);
    FIf_cvrt_to_perm_win(forms.part_file_list_form_id);
    }

    FIf_cvrt_to_perm_win(forms.local_files_form_id);
    FIf_cvrt_to_perm_win(forms.part_file_list_form_id);
*/

  msg = (char *)PDUtranslate_message(PDM_I_PART_FILE_DESIGN_REV);
  FIg_set_text(forms.part_file_list_form_id, FI_PROMPT_FIELD, msg);

  if (forms.local_files_form_id)
    FIf_erase(forms.local_files_form_id);

  /* display the form */
  FIf_display(forms.part_file_list_form_id);
#ifdef sparc
  PDUpaint_form(forms.part_file_list_form_id);
#endif
  PDU_part_file_list_displayed = TRUE;

  return(PDM_S_SUCCESS);
}


int PDUload_file_buffer(catalog, partid, revision, description, filename)
  char  *catalog;
  char  *partid;
  char  *revision;
  char  *description;
  char  *filename;
{
  int   status = PDM_S_SUCCESS;
  char  *line = NULL;
  char  *msg = NULL;
  int   char_index;
  int   file_col;
  int   row;
  char  **data_row;
  MEMptr ret_bufr = NULL;

  _pdm_debug("In the function PDUload_file_buffer", 0);

  if (!PDU_part_file_buffer)
    {
    _pdm_debug("PDU_part_file_buffer has not been formatted", 0);
    _pdm_debug("formatting PDU_part_file_buffer", 0);

    status = PDUformat_buffer (PDU_PART_FILE_BUFFER, &PDU_part_file_buffer);
    _pdm_status("PDUformat_buffer", status);

    if (status != PDM_S_SUCCESS)
      _pdm_debug("error formatting PDU_part_file_buffer", 0);
    else
      _pdm_debug("PDU_part_file_buffer successfully formatted", 0);
    }

  status = PDMget_filenames(catalog, partid, revision, &ret_bufr);
  _pdm_status("PDMget_filenames", status);

  if ( status != PDM_S_SUCCESS )
    {
    PDUmessage(status, 's');
    MEMclose(&ret_bufr);
    return(status);
    }

  if ((ret_bufr == NULL) || (ret_bufr->rows == 0))
    {
    msg = (char *)PDUtranslate_message(PDM_E_NO_PART_FILES);
    FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD,msg);
    return(PDM_E_FILE_NOT_FOUND);
    }

  MEMbuild_array(ret_bufr);
  PDUsetup_buffer(ret_bufr, ROW, &data_row);
  status = PDUget_buffer_col(ret_bufr, "n_cofilename", &file_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  line = (char*) malloc (PDU_part_file_buffer->row_size);

  for (row = 0; row < ret_bufr->rows; ++row)
     {
     char_index = 0;
     memset (line, NULL, PDU_part_file_buffer->row_size);

     PDUfill_in_string(&filename, data_row[(ret_bufr->columns * row)+file_col]);

     if (catalog && (strlen (catalog )))
       PDUadd_buffer_string(line, &char_index, catalog);
     else
       line[char_index++] = '\1';
   
     if (partid && (strlen (partid )))
       PDUadd_buffer_string(line, &char_index, partid);
     else
       line[char_index++] = '\1';

     if (revision && (strlen (revision )))
       PDUadd_buffer_string(line, &char_index, revision);
     else
       line[char_index++] = '\1';

     if (description && (strlen (description )))
       PDUadd_buffer_string(line, &char_index, description);
     else
       line[char_index++] = '\1';
   
     if (filename && (strlen (filename )))
       PDUadd_buffer_string(line, &char_index, filename);
     else
       line[char_index++] = '\1';

     _pdm_debug("line = <%s>", line);

     status = MEMwrite (PDU_part_file_buffer, line);

     if (status != MEM_S_SUCCESS)
       {
       _pdm_debug("Error writing to PDU_part_file_buffer", 0);
       _pdm_status("MEMwrite ()", status);
       }
     else
       status = PDM_S_SUCCESS;
     }

/*
  PDUfree_string(&line);
*/

  return(status);
}

int PDUload_file_buffer_after_copy(file_buffer, load_buffer, row, 
                                   catalog, partid, revision, filename)
  MEMptr  file_buffer;
  int     load_buffer;
  int     row;
  char    *catalog;
  char    *partid;
  char    *revision;
  char    *filename;
{
  int   status = PDM_S_SUCCESS;
  char  *line;
  int   char_index;
  int   cat_col;
  int   part_col;
  int   rev_col;
  int   file_col;
  char  *description = NULL_STRING;
  char  **file_data;

  _pdm_debug("In the function PDUload_file_buffer_after_copy", 0);

  if (!PDU_part_file_buffer)
    {
    _pdm_debug("PDU_part_file_buffer has no been formatted", 0);
    _pdm_debug("formatting PDU_part_file_buffer", 0);

    status = PDUformat_buffer (PDU_PART_FILE_BUFFER, &PDU_part_file_buffer);
    _pdm_status("PDUformat_buffer", status);

    if (status != PDM_S_SUCCESS)
      _pdm_debug("error formatting PDU_part_file_buffer", 0);
    else
      _pdm_debug("PDU_part_file_buffer successfully formatted", 0);
    }

  if (load_buffer == TRUE)
    {
    _pdm_debug("entering case for load file buffer = TRUE", 0);

    if ((file_buffer == NULL) || (file_buffer->rows == 0))
      return(PDM_E_READ_PARTS);

    /* set up the file buffer */
    MEMbuild_array(file_buffer);
    PDUsetup_buffer(file_buffer, ROW, &file_data);
    PDUget_buffer_col(file_buffer, "n_catalogname", &cat_col);
    PDUget_buffer_col(file_buffer, "n_itemname", &part_col);
    PDUget_buffer_col(file_buffer, "n_itemrev", &rev_col);
    PDUget_buffer_col(file_buffer, "n_cofilename", &file_col);

    catalog = NULL;
    partid = NULL;
    revision = NULL;
    description = NULL_STRING;
    filename = NULL;

    PDUfill_in_string(&catalog,
                    file_data[(file_buffer->columns * row) + cat_col]);
    PDUfill_in_string(&partid,
                    file_data[(file_buffer->columns * row) + part_col]);
    PDUfill_in_string(&revision,
                    file_data[(file_buffer->columns * row) + rev_col]);
    PDUfill_in_string(&filename,
                    file_data[(file_buffer->columns * row) + file_col]);

    char_index = 0;

    line = (char*) malloc (PDU_part_file_buffer->row_size);
    memset (line, NULL, PDU_part_file_buffer->row_size);

    if (catalog && (strlen (catalog )))
      PDUadd_buffer_string(line, &char_index, catalog);
    else
      line[char_index++] = '\1';

    if (partid && (strlen (partid )))
      PDUadd_buffer_string(line, &char_index, partid);
    else
      line[char_index++] = '\1';

    if (revision && (strlen (revision )))
      PDUadd_buffer_string(line, &char_index, revision);
    else
      line[char_index++] = '\1';

    if (description && (strlen (description )))
      PDUadd_buffer_string(line, &char_index, description);
    else
      line[char_index++] = '\1';

    if (filename && (strlen (filename )))
      PDUadd_buffer_string(line, &char_index, filename);
    else
      line[char_index++] = '\1';

    _pdm_debug("line = <%s>", line);
     
    status = MEMwrite (PDU_part_file_buffer, line);

    if (status != MEM_S_SUCCESS)
      {
      _pdm_debug("Error writing to PDU_part_file_buffer", 0);
      _pdm_status("MEMwrite ()", status);
      }
    else
      status = PDM_S_SUCCESS;
     
    PDUfree_string(&line);
    }
  else
    {

    char_index = 0;

    line = (char*) malloc (PDU_part_file_buffer->row_size);
    memset (line, NULL, PDU_part_file_buffer->row_size);

    if (catalog && (strlen (catalog )))
      PDUadd_buffer_string(line, &char_index, catalog);
    else
      line[char_index++] = '\1';

    if (partid && (strlen (partid )))
      PDUadd_buffer_string(line, &char_index, partid);
    else
      line[char_index++] = '\1';

    if (revision && (strlen (revision )))
      PDUadd_buffer_string(line, &char_index, revision);
    else
      line[char_index++] = '\1';

    if (description && (strlen (description )))
      PDUadd_buffer_string(line, &char_index, description);
    else
      line[char_index++] = '\1';

    if (filename && (strlen (filename )))
      PDUadd_buffer_string(line, &char_index, filename);
    else
      line[char_index++] = '\1';

    _pdm_debug("line = <%s>", line);

    status = MEMwrite (PDU_part_file_buffer, line);

    if (status != MEM_S_SUCCESS)
      {
      _pdm_debug("Error writing to PDU_part_file_buffer", 0);
      _pdm_status("MEMwrite ()", status);
      }
    else
      status = PDM_S_SUCCESS;

    PDUfree_string(&line);
    }

  return(status);
}
