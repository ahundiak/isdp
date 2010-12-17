#include <stdio.h>
#include "FI.h"
#include "tools.h"
#include "PDUstr.h"
#include <PDUforms.h>
#include "PDUerror.h"
#include "PDUfile_def.h"
#include "PDUcommand.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "part_gadgets.h"
#include "PDMmessage.h"
#include "PDUproto.h"
#include "PDMproto.h"

#define CATALOG_LIST_BTN 44
#define PROJECT_LIST_BTN 45

/* Externs */

extern int PDMdebug_on;
extern short  PDU_default_env;
extern short  PDU_list_filenames;
extern short  PDU_check_file_refresh;
extern short  PDU_second_row;
extern short  PDU_multiple_revs;
extern int    PDU_active_button;
extern int    PDU_active_list;
extern int    PDU_command;
extern int    end_ep_cat_btn_flag;
extern int   PDU_list_cat;
extern Form PDU_form_id;
extern int * PDU_display_column;
extern char **  PDU_data_row;
extern char **  PDU_data_col;
extern char **  PDU_data_format;
extern char *** PDU_update_struct;
extern char *   PDU_popup_list_type;
extern struct   PDUforms   forms;
extern int    * PDU_display_column;
extern int    * PDU_buffer_columns;
extern int    * PDU_struct_fields;
extern int    * PDU_gadget_labels;
extern struct   PDUforms      forms;
extern int      end_np_cat_btn_flag;
extern int      end_np_part_btn_flag;
extern int      end_np_parttype_btn_flag;
extern int      end_ep_proj_btn_flag;
extern int      end_ep_part_fld_flag;
extern int      end_ep_part_btn_flag;
extern int      end_ep_rev_btn_flag;
extern int      end_ep_parttype_btn_flag;
extern int      end_ep_desc_fld_flag;
extern int      end_ep_desc_btn_flag;
extern int      end_stg_area_btn_flag;
extern int      end_acl_wf_btn_flag;
extern int      end_move_to_state_btn_flag;
extern int      pdu_hold_stg_bufr_flag;
extern int      pdu_hold_acl_bufr_flag;
extern int      pdu_ep_stg_bufr_flag;
extern int      pdu_ep_acl_bufr_flag;
extern int      PDU_simmode_cat_bufr;
extern int      PDU_refresh_gadgets[7];
extern int      PDU_mcf_list_created;
extern int      PDU_single_list_created;
extern int      single_flag;
extern int      PDU_login_created;
extern char     *en_itemname;
extern char     *ep_rev;
extern struct PDUrefresh  *refresh;
extern MEMptr   PDU_display_buffer;
extern MEMptr   PDU_ret_bufr;

void PDUsetup_single_buffer(buffer)
MEMptr    buffer;
{
  _pdm_debug("In the function PDUsetup_single_buffer", 0);

  if ((buffer->rows > 0) && (buffer))
    {
    MEMbuild_array(buffer);
    PDUsetup_buffer(buffer, COL, &PDU_data_col);
    PDUsetup_buffer(buffer, ROW, &PDU_data_row);
    PDUsetup_buffer(buffer, FORMAT, &PDU_data_format);
    }

  PDU_display_column = (int *) malloc (sizeof (int) * buffer->columns);
  memset(PDU_display_column, -1, sizeof (int) * buffer->columns);

  PDU_buffer_columns = (int *) malloc (sizeof (int) * buffer->columns);
  memset(PDU_buffer_columns, -1, sizeof (int) * buffer->columns);

  PDU_struct_fields = (int *) malloc (sizeof (int) * buffer->columns);
  memset(PDU_struct_fields, -1, sizeof (int) * buffer->columns);

  PDU_gadget_labels = (int *) malloc (sizeof (int) * buffer->columns);
  memset(PDU_gadget_labels, -1, sizeof (int) * buffer->columns);

  PDU_update_struct = (char ***) malloc (sizeof (char **) * buffer->columns);
  memset(PDU_update_struct, NULL, sizeof (char **) * buffer->columns);

} /* end PDUsetup_single_buffer */

int PDUbufr_to_form(form, gadget, buffer)
Form   form;
int    gadget;
MEMptr  *buffer;
{
  int    i, j, form_col;
  int    form_input;
  int    struct_input;
  int    cur_row;
  char  *tmp_string = NULL;
  int    status = PDM_S_SUCCESS;
  char   templatetype[2]; /* added JP for reports */

  _pdm_debug("In the function PDUbufr_to_form", 0);

  _pdm_debug("PDU_list_cat = %d", (char *)PDU_list_cat);

  if (((*buffer)->rows == 1) && (!PDU_list_cat))
    {
    _pdm_debug("defaulting input; only one string in popup list", 0);
    form_input = 0;
    struct_input = 0;
    cur_row = 0;
    for (j = 0; j < (*buffer)->columns; ++j)
       {
       if (PDU_buffer_columns[j] != -1)
         {
         FIfld_set_text(PDU_form_id,
                 PDU_gadget_labels[form_input], 0, 0,
           PDU_data_row[((*buffer)->columns * cur_row) + PDU_buffer_columns[j]],
                  FALSE);
         ++form_input;
         }
       if (PDU_struct_fields[j] != -1)
         {
         PDUfill_in_string(PDU_update_struct[struct_input],
           PDU_data_row[((*buffer)->columns * cur_row) + PDU_struct_fields[j]]);
         ++struct_input;
         }
       } /* end for */

    /* restore PDU_active_button */
    if (PDU_active_button != -1)
      {
      FIg_set_state_off(PDU_form_id, PDU_active_button);
      FIg_display(PDU_form_id, PDU_active_button);
      /* restore active button */
      PDU_active_button = -1;
      }

    if (PDU_form_id == 0)
      return(PDM_S_SUCCESS);

    if ((PDU_form_id == forms.login_form_id) && (PDU_default_env == TRUE) &&
        (PDU_login_created) && (forms.login_form_id))
      {
      status = PDUdefault_env(forms.login_form_id);
      _pdm_status("PDUdefault_env", status);
      return(status);
      }

    if ((PDU_form_id == forms.local_files_form_id) ||
        (PDU_form_id == forms.seed_form_form_id))
      {
      if (PDU_check_file_refresh == TRUE)
        {
        status = PDUcheck_file_commands();
        _pdm_status("PDUcheck_file_commands", status);
        }
      if ((PDU_form_id == forms.local_files_form_id) && 
          (PDU_list_filenames == TRUE))
         PDUmessage(PDM_S_SUCCESS, 's');
      }

    if (PDU_form_id == forms.bom_contents_form_id)
      status = PDUcheck_bom_mapping_commands();

    if ((PDU_form_id == forms.cat_name_form_id) && 
        (PDU_command == PDC_M_MODIFY_CATALOG))
      {
      status = PDUcheck_catalog_commands();
      end_ep_cat_btn_flag = FALSE;
      _pdm_debug("after PDUcheck_catalog_commands",0);
      }
  else if (PDU_form_id == forms.cat_name_form_id)
      {
      status = PDUcheck_catalog_template();
      end_ep_cat_btn_flag = FALSE;
      }

    if (PDU_form_id == forms.define_lib_form_id)
      status = PDUdefine_support_update();

    if ((PDU_form_id == forms.parametric_parts_form_id) && 
        (!PDU_active_list))
      status = PDUfinish_parametric_move_to_next_state();

    if (PDU_form_id == forms.report_form_id)
      {
      PDUget_templatetype(templatetype);
      status = PDUcheck_reportname(templatetype);
      }

    if (PDU_form_id == forms.ex_file_form_id)
      {
      status = PDUprocess_ex_file_form_after_select();
      _pdm_status("PDUprocess_ex_file_form_after_select", status);
      }

    if ((PDU_form_id == forms.topdown_form_id) &&
        (PDU_command == PDC_M_CREATE_TOP_DOWN))
      {
      status = PDUcheck_topdown_files();
      _pdm_status("PDUcheck_topdown_files", status);
      }

    } /* end if */
  else
    {
    for (i = 0; i < (*buffer)->rows; ++i)
       {
       form_col = 0;
       for (j = 0; j < (*buffer)->columns; ++j)
          {
          if (PDU_display_column[j] != -1)
            {
            PDUfill_in_string(&tmp_string,
              PDU_data_row[((*buffer)->columns * i) + PDU_display_column[j] ]);
            FIfld_set_text( form, gadget, i, form_col, tmp_string, FALSE);
            ++form_col;
            }
          }
       } /* end for */
    } /* end else */

  /* need to call function to update form after selecting a new catalog */
  if (((*buffer)->rows == 1) && (PDU_list_cat))
    {
    _pdm_debug("entering case for listing catalogs", 0);
    if (PDU_form_id == 0)
      {
      PDU_list_cat = FALSE;
      return(PDM_S_SUCCESS);
      }

    if (PDU_form_id == forms.seed_form_form_id)
      if (PDU_check_file_refresh == TRUE)
        {
        status = PDUcheck_file_commands();
        _pdm_status("PDUcheck_file_commands", status);
        }

    if (PDU_form_id == forms.local_files_form_id)
      {
      if (PDU_check_file_refresh == TRUE)
        {
        status = PDUcheck_file_commands();
        _pdm_status("PDUcheck_file_commands", status);
        }
      else if (PDU_list_filenames == TRUE)
       PDUmessage(PDM_S_SUCCESS, 's');
      }
    }

  _pdm_debug("end_ep_part_btn_flag = %d", (char *)end_ep_part_btn_flag);
  if ((end_ep_part_btn_flag || end_ep_rev_btn_flag) &&
      ((PDU_form_id != forms.part_operations_form_id) && 
      ((*buffer)->rows == 1)))
     {
     _pdm_debug("setting en_itemname and ep_rev", 0);
     PDUfill_in_string(&en_itemname, refresh->rev_partid);
     PDUfill_in_string(&ep_rev, refresh->rev_revision);
     _pdm_debug("en_itemname = <%s>", en_itemname);
     _pdm_debug("ep_rev = <%s>", ep_rev);
     end_ep_part_btn_flag = FALSE;
     PDUmessage(status,'s');
     }

  if (((*buffer)->rows == 1) && (!PDU_list_cat))
     {
     _pdm_debug("checking for part form functions", 0);
     _pdm_debug("end_move = %d", (char *)end_move_to_state_btn_flag);
     if (end_ep_part_fld_flag == TRUE)
        {
        end_ep_part_fld_flag = FALSE;
        status = PDUend_ep_part_fld();
        _pdm_status("PDUend_ep_part_fld",status);
        if (status == PDM_S_SUCCESS)
           single_flag = TRUE;
        return(status);
        }
     else if (end_ep_parttype_btn_flag == TRUE)
        {
        end_ep_parttype_btn_flag = FALSE;
        status = PDUep_parttype_fld();
        _pdm_status("PDUep_parttype_fld",status);
        if (status == PDM_S_SUCCESS)
           single_flag = TRUE;
        return(status);
        }
     else if (end_ep_proj_btn_flag == TRUE)
        {
        end_ep_proj_btn_flag = FALSE;
        status = PDUend_ep_proj_btn();
        _pdm_status("PDUend_ep_proj_btn",status);
        if (status == PDM_S_SUCCESS)
           single_flag = TRUE;
        return(status);
        }
     else if ((end_ep_desc_fld_flag == TRUE) || (end_ep_desc_btn_flag == TRUE))
        {
        status = PDUend_ep_desc_fld();
        _pdm_status("PDUend_ep_desc_fld",status);
        if (status == PDM_S_SUCCESS)
           single_flag = TRUE;
        return(status);
        }
     else if (end_ep_rev_btn_flag == TRUE)
        {
        end_ep_rev_btn_flag = FALSE;
        status = PDUep_rev_fld();
        _pdm_status("PDUep_rev_fld",status);
        if (status == PDM_S_SUCCESS)
           single_flag = TRUE;
        return(status);
        }
     else if (PDU_form_id == forms.part_operations_form_id)
        {
        if (end_ep_part_btn_flag == TRUE)
           {
           end_ep_part_btn_flag = FALSE;
           PDUmessage(PDS_M_GET_TABLE_DATA,'s');
           status = PDUpull_bufr_info();
           _pdm_status("PDUpull_bufr_info",status);
           if (status == PDM_S_SUCCESS)
              single_flag = TRUE;
           return(status);
           }
        else if (end_ep_cat_btn_flag == TRUE)
           {
           end_ep_cat_btn_flag = FALSE;
           status = PDUep_cat_fld();
           _pdm_status("PDUep_cat_fld",status);
           if (status == PDM_S_SUCCESS)
              single_flag = TRUE;
           return(status);
           }
        else if (end_np_part_btn_flag == TRUE)
           {
           end_np_part_btn_flag = FALSE;
           status = PDUnp_part_fld();
           _pdm_status("PDUnp_part_fld",status);
           if (status == PDM_S_SUCCESS)
              single_flag = TRUE;
           return(status);
           }
        else if (end_np_parttype_btn_flag == TRUE)
           {
           end_np_parttype_btn_flag = TRUE;
           status = PDUnp_parttype_fld();
           _pdm_status("PDUnp_parttype_fld",status);
           if (status == PDM_S_SUCCESS)
              single_flag = TRUE;
           return(status);
           }
        else if (end_stg_area_btn_flag == TRUE)
           {
           status = PDUend_stg_area_btn();
           _pdm_status("PDUend_stg_area_btn",status);
           if (status == PDM_S_SUCCESS)
              single_flag = TRUE;
           end_stg_area_btn_flag = FALSE;
           pdu_hold_stg_bufr_flag = FALSE;
           pdu_ep_stg_bufr_flag = FALSE;
           end_stg_area_btn_flag = FALSE;
           return(status);
           }
        else if (end_acl_wf_btn_flag == TRUE)
           {
           status = PDUend_acl_wf_btn();
           _pdm_status("PDUend_acl_wf_btn",status);
           if (status == PDM_S_SUCCESS)
              single_flag = TRUE;
           end_acl_wf_btn_flag = FALSE;
           pdu_hold_acl_bufr_flag = FALSE;
           pdu_ep_acl_bufr_flag = FALSE;
           return(status);
           }
        else if (end_move_to_state_btn_flag == TRUE)
           {
           _pdm_debug("calling PDUend_move_to_state_btn", 0);
           status = PDUend_move_to_state_btn();
           _pdm_status("PDUend_move_to_state_btn",status);
           if (status == PDM_S_SUCCESS)
             single_flag = TRUE;
           end_move_to_state_btn_flag = FALSE;
           return(status);
           }
        }
     }
  PDU_list_cat = FALSE;
  _pdm_debug("exiting PDUbufr_to_form", 0);
  return(status);
} /* end PDUbufr_to_form */

/*
 * CR #:139525526. 05/sep/95 - raj. New version of PDUbufr_to_form() to display even a single row.
 */
int PDUbufr_to_form_single(form, gadget, buffer)
Form   form;
int    gadget;
MEMptr  *buffer;
{
  int    i, j, form_col;
  int    form_input;
  int    struct_input;
  int    cur_row;
  char  *tmp_string = NULL;
  int    status = PDM_S_SUCCESS;
  char   templatetype[2]; /* added JP for reports */

  _pdm_debug("In the function PDUbufr_to_form_single", 0);

  _pdm_debug("PDU_list_cat = %d", (char *)PDU_list_cat);

    for (i = 0; i < (*buffer)->rows; ++i)
       {
       form_col = 0;
       for (j = 0; j < (*buffer)->columns; ++j)
          {
          if (PDU_display_column[j] != -1)
            {
            PDUfill_in_string(&tmp_string,
              PDU_data_row[((*buffer)->columns * i) + PDU_display_column[j] ]);
            FIfld_set_text( form, gadget, i, form_col, tmp_string, FALSE);
            ++form_col;
            }
          }
       } /* end for */
  _pdm_debug("exiting PDUbufr_to_form_single", 0);
  return(PDM_S_SUCCESS);
} /* end PDUbufr_to_form_single */

void PDUbufr_to_form1(form, gadget, buffer)
Form   form;
int    gadget;
MEMptr  *buffer;
{
  int    i, j, form_col;
  int    form_input;
  int    struct_input;
  int    cur_row;
  char  *tmp_string = NULL;

  _pdm_debug("In the function PDUbufr_to_form1", 0);

  if ((*buffer)->rows == 1)
    {
    _pdm_debug("defaulting input; only one string in popup list", 0);
    form_input = 1;
    struct_input = 0;
    cur_row = 0;
    for (j = 0; j < (*buffer)->columns; ++j)
       {
       if (PDU_buffer_columns[j] != -1)
         {
         FIfld_set_text(PDU_form_id,
                 PDU_gadget_labels[form_input], 0, 0,
                 PDU_data_row[((*buffer)->columns * cur_row) + j],
                  FALSE);
         ++form_input;
         }
       if (PDU_struct_fields[j] != -1)
         {
         PDUfill_in_string(PDU_update_struct[struct_input],
                PDU_data_row[((*buffer)->columns * cur_row) + j]);
         ++struct_input;
         }
       } /* end for */
    MEMclose(buffer);
    *buffer = NULL;
    } /* end if */
  else
    {
    for (i = 0; i < (*buffer)->rows; ++i)
       {
       form_col = 1;
       for (j = 0; j < (*buffer)->columns; ++j)
          {
          if (PDU_display_column[j] != -1)
            {
            PDUfill_in_string(&tmp_string,
                  PDU_data_row[((*buffer)->columns * i) + j]);
            FIfld_set_text( form, gadget, i,
                            form_col, tmp_string, FALSE);
            ++form_col;
            }
          }
       } /* end for */
    } /* end else */
} /* end PDUbufr_to_form1 */


int PDUbufr_to_form_fields(form, gadget, buffer)
Form    form;
int     gadget;
MEMptr  *buffer;
{
  int rows = 0;
  int cur_row, j, form_input, struct_input;
  int row_found = FALSE;
  int select = FALSE;
  int status = FI_SUCCESS;
  char templatetype[2]; /* added JP for reports */

  _pdm_debug("In the function PDUbufr_to_form_fields", 0);

  /* Get the number of rows in the field */
  rows = 0;
  status = FIfld_get_num_rows( form, gadget, &rows);
  _pdm_debug("rows = %d", (char *)rows);

  if ( status != FI_SUCCESS )
    {
      _pdm_debug("Error getting number of rows in listing field", 0);
      status = PDM_E_FORM_DATA;
      return(status);
    }

  /* copy selected line into variable */
  _pdm_debug("copying selected line into variable", 0);

  _pdm_debug("rows = %d", (char *)rows);

  for (cur_row = 0; cur_row < rows; ++cur_row)
    {
     if (row_found == TRUE)
       cur_row = rows;

     FIfld_set_active_row(form, gadget,
                          cur_row, cur_row);
     FIfld_get_select(form, gadget, cur_row,
                      0, &select);

     if (select == TRUE)
       {
       row_found = TRUE;
       form_input = 0;
       struct_input = 0;
       _pdm_debug("Before Displaying PDUform_id", 0);
	  if (PDMdebug_on)
            MEMprint_buffer("return buffer", *buffer, PDU_DEBUG_FILE);
       _pdm_debug("columns = <%d>", (char *)(*buffer)->columns);
       for (j = 0; j < (*buffer)->columns; ++j)
          {
          if (PDU_buffer_columns[j] != -1)
            {
            _pdm_debug("Setting text", 0);
            _pdm_debug("gadget label = <%d>", 
                       (char *)PDU_gadget_labels[form_input]);
            FIfld_set_text(PDU_form_id,
                     PDU_gadget_labels[form_input], 0, 0,
                     PDU_data_row[((*buffer)->columns * cur_row) +
                                  PDU_buffer_columns[j] ], FALSE);
            ++form_input;
            }
          if (PDU_struct_fields[j] != -1)
            {
            _pdm_debug("Setting structure", 0);
            PDUfill_in_string(PDU_update_struct[struct_input],
                    PDU_data_row[((*buffer)->columns * cur_row) +
                                 PDU_struct_fields[j] ]);
            ++struct_input;
            }
          }
       } /* end if select */
    } /* end for */

  if (PDU_popup_list_type == NULL) 
    {
    MEMclose(buffer);
    *buffer = NULL;
    }
 else if (strcmp(PDU_popup_list_type,"") == 0)
    {
    MEMclose(buffer);
    *buffer = NULL;
    }
 else if (strcmp(PDU_popup_list_type,"sort")!=0)
    {
    MEMclose(buffer);
    *buffer = NULL;
    }

/* MJG - TR 139420503 - both forms were being deleted; set flag in PDUmcf_list.c for CANCEL case.  11/21/95 */
  if (PDU_single_list_created)
     {
     _pdm_debug("deleting single list form", 0);
     FIf_delete ( forms.single_list_form_id );
     PDU_single_list_created = FALSE;
     }

  if (PDU_mcf_list_created)
     {
     _pdm_debug("deleting mcf list form", 0);
     FIf_delete (forms.mcf_list_form_id);
     PDU_mcf_list_created = FALSE;
     }

  if (PDU_active_button != -1)
    {
    _pdm_debug("PDU_active_button = %d", (char *)PDU_active_button);
    FIg_set_state_off(PDU_form_id, PDU_active_button);
    FIg_display(PDU_form_id, PDU_active_button);
    /* restore active button */
    PDU_active_button = -1;
    }
 
  if ((end_ep_part_btn_flag || end_ep_rev_btn_flag) && 
      (PDU_form_id != forms.part_operations_form_id))
     {
     _pdm_debug("setting en_itemname and ep_rev", 0);
     PDUfill_in_string(&en_itemname, refresh->rev_partid);
     PDUfill_in_string(&ep_rev, refresh->rev_revision);
     _pdm_debug("en_itemname = <%s>", en_itemname);
     _pdm_debug("ep_rev = <%s>", ep_rev);
     end_ep_part_btn_flag = FALSE;
     end_ep_rev_btn_flag = FALSE;

     if (PDU_multiple_revs)
       {
       PDU_multiple_revs = FALSE;

       status = PDUpull_pt_desc_for_rev();
       _pdm_status("PDUpull_pt_desc_for_rev", status);

       if ((PDU_form_id == forms.local_files_form_id) ||
           (PDU_form_id == forms.seed_form_form_id))
         {
         status = PDUcheck_file_commands();
         _pdm_status("PDUcheck_file_commands", status);
         }
       }
     else
       {
       status = PDUend_ep_rev_btn();
       _pdm_status("PDUend_ep_rev_btn", 0);
       }
     PDUmessage(status,'s');
     }

  if ((end_ep_rev_btn_flag) && (PDU_multiple_revs) &&
      (PDU_form_id == forms.part_operations_form_id))
     {
     PDU_multiple_revs = FALSE;
     end_ep_rev_btn_flag = FALSE;

     _pdm_debug("en_itemname = <%s>", en_itemname);
     _pdm_debug("ep_rev = <%s>", ep_rev);
     status = PDUpull_pt_desc_for_rev();
     _pdm_status("PDUpull_pt_desc_for_rev", status);

     status = PDUpull_bufr_info();
     PDUmessage(status,'s');
     }
   

  if ((PDU_form_id == forms.local_files_form_id) ||
      (PDU_form_id == forms.seed_form_form_id))
    {
    if (PDU_check_file_refresh == TRUE)
      {
      status = PDUcheck_file_commands();
      _pdm_status("PDUcheck_file_commands", status);
      }
    if ((PDU_form_id == forms.local_files_form_id) && 
        (PDU_list_filenames == TRUE))
       PDUmessage(PDM_S_SUCCESS, 's');
    }

  if (PDU_form_id == 0)
    return(PDM_S_SUCCESS);

  if (PDU_form_id == forms.bom_contents_form_id)
    status = PDUcheck_bom_mapping_commands();

  if ((PDU_form_id == forms.cat_name_form_id) && 
      (PDU_command == PDC_M_MODIFY_CATALOG))
    {
    status = PDUcheck_catalog_commands();
    end_ep_cat_btn_flag = FALSE;
    }
  else if (PDU_form_id == forms.cat_name_form_id)
    {
    status = PDUcheck_catalog_template();
    end_ep_cat_btn_flag = FALSE;
    }

    if (PDU_form_id == forms.define_lib_form_id)
      status = PDUdefine_support_update();

    if ((PDU_form_id == forms.parametric_parts_form_id) && 
        (!PDU_active_list))
      status = PDUfinish_parametric_move_to_next_state();

  if (PDU_form_id == forms.report_form_id)
      {
      PDUget_templatetype(templatetype);
      status = PDUcheck_reportname(templatetype);
      }

    if (PDU_form_id == forms.ex_file_form_id)
      {
      status = PDUprocess_ex_file_form_after_select();
      _pdm_status("PDUprocess_ex_file_form_after_select", status);
      }

  if ((PDU_form_id == forms.topdown_form_id) &&
      (PDU_command == PDC_M_CREATE_TOP_DOWN))
    {
    status = PDUcheck_topdown_files();
    _pdm_status("PDUcheck_topdown_files", status);
    }

  _pdm_debug("end_ep_part_fld_flag = %d", (char *)end_ep_part_fld_flag);
  if (end_ep_part_fld_flag == TRUE)
     {
     end_ep_part_fld_flag = FALSE;
     status = PDUend_ep_part_fld();
     _pdm_status("PDUend_ep_part_fld",status);
     return(status);
     }
  else if (end_ep_parttype_btn_flag == TRUE)
     {
     end_ep_parttype_btn_flag = FALSE;
     status = PDUep_parttype_fld();
     _pdm_status("PDUep_parttype_fld",status);
     return(status);
     } 
  else if (end_ep_cat_btn_flag == TRUE)
     {
     end_ep_cat_btn_flag = FALSE;
     status = PDUprocess_ep_catalog();
     _pdm_status("PDUprocess_ep_catalog",status);
     return(status);
     }
  else if (end_ep_proj_btn_flag == TRUE)
     {
     end_ep_proj_btn_flag = FALSE;
     status = PDUend_ep_proj_btn();
     _pdm_status("PDUend_ep_proj_btn",status);
     return(status);
     }
  else if ((end_ep_desc_fld_flag == TRUE) || (end_ep_desc_btn_flag == TRUE))
     {
     status = PDUend_ep_desc_fld();
     _pdm_status("PDUend_ep_desc_fld",status);
     return(status);
     }
  else if (end_ep_rev_btn_flag == TRUE)
     {
     end_ep_rev_btn_flag = FALSE;
     status = PDUep_rev_fld();
     _pdm_status("PDUep_rev_fld",status);
     return(status);
     }

  if ((PDU_form_id == forms.login_form_id) && (PDU_default_env == TRUE) &&
      (PDU_login_created) && (forms.login_form_id))
    {
    _pdm_debug("entering case for login form", 0);
    status = PDUdefault_env(forms.login_form_id);
    _pdm_status("PDUdefault_env", status);
    return(PDM_S_SUCCESS);
    }

  if (PDU_form_id == forms.part_operations_form_id)
     {
     if (end_ep_part_btn_flag == TRUE)
        {
        PDUmessage(PDS_M_GET_TABLE_DATA,'s');
        end_ep_part_btn_flag = FALSE;
        status = PDUpull_bufr_info();
        _pdm_status("PDUpull_bufr_info",status);
        return(status);
        }
     else if (end_np_cat_btn_flag == TRUE)
        {
        end_np_cat_btn_flag = FALSE;
        status = PDUprocess_np_catalog();
        _pdm_status("PDUprocess_np_catalog",status);
        return(status);
        }
     else if (end_np_part_btn_flag == TRUE)
        {
        end_np_part_btn_flag = FALSE;
        status = PDUnp_part_fld();
        _pdm_status("PDUnp_part_fld",status);
        return(status);
        }
     else if (end_np_parttype_btn_flag == TRUE)
        {
        end_np_parttype_btn_flag = FALSE;
        status = PDUnp_parttype_fld();
        _pdm_status("PDUnp_parttype_fld",status);
        return(status);
        }
     else if (end_stg_area_btn_flag == TRUE)
        {
        status = PDUend_stg_area_btn();
        _pdm_status("PDUend_stg_area_btn",status);
        end_stg_area_btn_flag = FALSE;
        pdu_hold_stg_bufr_flag = FALSE;
        pdu_ep_stg_bufr_flag = FALSE;
        return(status);
        }

     else if (end_acl_wf_btn_flag == TRUE)
        {
        status = PDUend_acl_wf_btn();
        _pdm_status("PDUend_acl_wf_btn",status);
        end_acl_wf_btn_flag = FALSE;
        pdu_hold_acl_bufr_flag = FALSE;
        pdu_ep_acl_bufr_flag = FALSE;
        return(status);
        } 
     else if (end_move_to_state_btn_flag == TRUE)
        {
        end_move_to_state_btn_flag = FALSE;
        status = PDUend_move_to_state_btn();
        _pdm_status("PDUend_move_to_state_btn",status);
        return(status);
        }
     }

  return(status);
} /* end PDUbufr_to_form_fields */

void PDUsetup_popup_list(headers, count, flag, buffer)
char **headers;
int    count;
int    flag;
MEMptr buffer;
{
  int i, j;
  
  _pdm_debug("In the function PDUsetup_popup_list", 0);

  if (flag == TRUE)
    {
    /* all fields should be displayed in the popup list */
    for (i = 0; i < buffer->columns; ++i)
       {
       PDU_display_column[i] = i;
       }
    }
  else
    {
    for (j = 0; j < count; ++j)
       {
       for (i = 0; i < buffer->columns; ++i)
          {
           if (strcmp(headers[j], PDU_data_col[i]) == 0)
             {
             /* Fields that need to be displayed in the popup list */
/* Stan 1/19/92
             PDU_display_column[i] = i;
*/
             PDU_display_column[j] = i;
             i = buffer->columns;
             }
           }
        }
    }
} /* end PDUsetup_popup_list */

void PDUsetup_form_fields(headers, count, flag, buffer)
char **headers;
int    count;
int    flag;
MEMptr buffer;
{
  int i, j;
  
  _pdm_debug("In the function PDUsetup_form_fields", 0);

  if (flag == TRUE)
    {
    /* all fields should be loaded on the calling form */
    for (i = 0; i < buffer->columns; ++i)
       {
       PDU_buffer_columns[i] = i;
       }
    }
  else
    {
    for (j = 0; j < count; ++j)
       {
       for (i = 0; i < buffer->columns; ++i)
          {
           if (strcmp(headers[j], PDU_data_col[i]) == 0)
             {
             /* Fields that need to loaded onto the calling form */
/* Stan 1/19/92
             PDU_buffer_columns[i] = i;
*/
             PDU_buffer_columns[j] = i;
             i = buffer->columns;
             }
           }
        }
    }
} /* end PDUsetup_form_fields */

void PDUsetup_struct_fields(headers, count, flag, buffer)
char **headers;
int    count;
int    flag;
MEMptr buffer;
{
  int i, j;

  _pdm_debug("In the function PDUsetup_struct_fields", 0);

  if (flag == TRUE)
    {
    /* all fields in the structure should be written to */
    for (i = 0; i < buffer->columns; ++i)
       {
       PDU_struct_fields[i] = i;
       }
    }
  else
    {
    for (j = 0; j < count; ++j)
       {
       for (i = 0; i < buffer->columns; ++i)
          {
           if (strcmp(headers[j], PDU_data_col[i]) == 0)
             {
             /* Fields in the structure to be written to */
             PDU_struct_fields[i] = i;
             i = buffer->columns;
             }
           }
        }
    }
} /* end PDUsetup_struct_fields */


void PDUbufr_to_mcf(buffer, form, field)
MEMptr       buffer;
Form         form;
int          field;
{
int          row;
int          column;
int          form_col;
char         *tmp_string = NULL;

  _pdm_debug("in the function PDUbufr_to_mcf", 0);

if (PDU_second_row == FALSE)
  {
  for (row = 0; row < buffer->rows; ++row)
     {
     form_col = 0;
     for (column = 0; column < buffer->columns; ++column)
        {
        if (PDU_display_column[column] != -1)
          {
          PDUfill_in_string(&tmp_string,
            PDU_data_row[(buffer->columns * row) + PDU_display_column[column]]);
          FIfld_set_text( form, field, row, form_col, tmp_string, FALSE);
          ++form_col;
          }        
        }
     } /* end for */
  }
else
  {
  for (row = 1; row < buffer->rows; ++row)
     {
     form_col = 0;
     for (column = 0; column < buffer->columns; ++column)
        {
        if (PDU_display_column[column] != -1)
          {
          PDUfill_in_string(&tmp_string,
            PDU_data_row[(buffer->columns * row) + PDU_display_column[column]]);
          FIfld_set_text( form, field, row - 1, form_col, tmp_string, FALSE);
          ++form_col;
          }
        }
     } /* end for */
  }

}  /* end PDUbufr_to_mcf */

int PDUadd_catalog_to_buffer(search_catalog, buffer)
char            *search_catalog;
MEMptr          *buffer;
{
  MEMptr       temp_buffer = NULL;
  int          char_index;
  int          row;
  int          column;
  int          status = PDM_S_SUCCESS;
  char         *line;
  char         *string = NULL;
  char         **data;

  _pdm_debug("In the function PDUadd_catalog_to_buffer", 0);
  _pdm_debug("adding catalog <%s> to PDU_assy_parts_bufr", search_catalog);

  MEMopen(&temp_buffer, 512);

  MEMwrite_format(temp_buffer, "n_catalogname", "char(15)");
  MEMwrite_format(temp_buffer, "n_itemname", "char(15)");
  MEMwrite_format(temp_buffer, "n_itemrev", "char(15)");
  MEMwrite_format(temp_buffer, "n_itemdesc", "char(40)");
  MEMwrite_format(temp_buffer, "p_parttype", "char(2)");
  
  MEMbuild_array(*buffer);
  PDUsetup_buffer(*buffer, ROW, &data);

  line = (char*) malloc (temp_buffer->row_size);
  memset (line, NULL, temp_buffer->row_size);

  char_index = 0;

  for (row = 0; row < (*buffer)->rows; ++row)
     {
     for (column = 0; column < temp_buffer->columns; ++column)
        {
        if (column == 0)
          {
          PDUadd_buffer_string(line, &char_index, search_catalog);
          _pdm_debug("line = <%s>", line);
          }
        else
          {
          PDUfill_in_string(&string, data[((*buffer)->columns * row)+column-1]);
          if ((strlen(string)) && string)
            {
            PDUadd_buffer_string(line, &char_index, string);
            _pdm_debug("line = <%s>", line);
            }
          else
            line[char_index++] = '\1';
          }
        }
     _pdm_debug("line = <%s>", line);

     status = MEMwrite (temp_buffer, line);
     if (status != MEM_S_SUCCESS)
       {
       _pdm_debug("Error writing catalog name to PDU_assy_parts_bufr", 0);
       _pdm_status("MEMwrite_format ()", status);
       }
     char_index = 0;
     memset (line, NULL, temp_buffer->row_size);
     }

  *buffer = temp_buffer;
  if (PDMdebug_on)
    MEMprint_buffer("buffer with catalog name", *buffer, "");

  return(status);

} /* end PDUadd_catalog_to_buffer */
