#include <FI.h>
#include <stdio.h>
#include <tools.h>
#include <PDUstr.h>
#include <PDUuser.h>
#include <PDUfile_def.h>
#include <PDUerror.h>
#include <PDUintdef.h>
#include <PDUforms.h>
#include <MEMstruct.h>
#include <MEMerrordef.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "PDUproto.h"
#include "PDMproto.h"

#define LIST_MCF       11
#define DWG_MCF       100
#define MCF_LIST_GRP   65
#define CATALOG_FLD              26
#define PARTNUM_FLD              27
#define PART_REV_FLD             28
#define PART_FILE_FLD            29
#define PART_DESC_FLD            31
#define PROJECT_FLD              24
#define STRUCTURE_MCF            57

extern struct PDUforms   forms;
extern struct PDUrefresh  *refresh;
extern struct PDUuser  *user;
extern int    PDU_selected_rows;
extern int    PDU_mcf_list;
extern short    PDU_structure_list;
extern short    PDU_activate_copy;
extern int    PDU_list_files;
extern int    PDU_file_rows;
extern int    *PDU_parts_index;
extern int    PDMdebug_on;
extern int    PDU_command;
extern MEMptr PDU_parts_list_bufr;
extern MEMptr PDU_storage_area;
extern MEMptr PDU_part_file_buffer;
extern MEMptr PDU_delete_buffer;
extern MEMptr PDU_part_file_buffer;
extern char   **PDU_file_list;
extern char   *PDU_save_filename;
extern Form   PDU_form_id;


int PDUcheck_part( command, type)
char  *command;
int    type;
{
char         **list_row;
char         *msg = NULL;
int          row = 0;
int          status = PDM_S_SUCCESS;
int          cat_col;
int          part_col;
int          rev_col;
int          desc_col;
int          file_col;
int          type_col;
int          local_col;
int          state_col;
short        first_row = TRUE;
short        row_found = FALSE;
MEMptr       buffer = NULL;

  _pdm_debug("in the function PDUcheck_part", 0);

  if ((PDU_mcf_list == TRUE) && (PDU_parts_list_bufr != NULL) && 
      (PDU_parts_list_bufr->rows > 0))
    {
    MEMbuild_array(PDU_parts_list_bufr);
    status = PDUget_buffer_col(PDU_parts_list_bufr, "p_local", &local_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    status = PDUget_buffer_col(PDU_parts_list_bufr, "n_statename", &state_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    PDUsetup_buffer(PDU_parts_list_bufr, ROW, &list_row);
    }

  if (((PDU_structure_list || PDU_mcf_list)) && 
       (PDU_parts_list_bufr != NULL) &&
       (PDU_parts_list_bufr->rows > 0))
    {
    MEMbuild_array(PDU_parts_list_bufr);
    status = PDUget_buffer_col(PDU_parts_list_bufr, "n_catalogname", &cat_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    status = PDUget_buffer_col(PDU_parts_list_bufr, "n_itemname", &part_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    status = PDUget_buffer_col(PDU_parts_list_bufr, "n_itemrev", &rev_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    status = PDUget_buffer_col(PDU_parts_list_bufr, "n_itemdesc", &desc_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    status = PDUget_buffer_col(PDU_parts_list_bufr, "n_cofilename", &file_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    status = PDUget_buffer_col(PDU_parts_list_bufr, "p_parttype", &type_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    PDUsetup_buffer(PDU_parts_list_bufr, ROW, &list_row);
    }

  /* Check the refresh for a partid and filename, and check to see if the 
     listing area is populated */

  if (((refresh->rev_partid == NULL)            ||
       (strcmp(refresh->rev_partid, "") == 0)   ||
       (refresh->rev_filename == NULL)          ||
       (strcmp(refresh->rev_filename, "") == 0)) &&
       (PDU_selected_rows == 0))
    {
    if ((refresh->rev_partid == NULL) ||
        (strcmp(refresh->rev_partid, "") == 0))
      {
      _pdm_debug("User depressed <%s> button w/o selecting a part", command);
      msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
      FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, msg);
      }
    else if ((refresh->rev_filename == NULL) ||
             (strcmp(refresh->rev_filename, "") == 0))
      {
      _pdm_debug("User depressed <%s> button w/o entering a filename", command);
      msg = (char *) PDUtranslate_message(PDM_E_ENTER_FILENAME);
      FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, msg);
      }
    }

  if ((PDU_selected_rows == 0) ||
      (PDU_parts_list_bufr == NULL)) /* part in refresh will be used */
    {
    _pdm_debug("Invoking <%s> on part in the part selection area", command);
    if (forms.local_files_form_id)
      FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, NULL_STRING);
    switch (type)
      {
      case  CHECKIN:
  
            status = PDUint_checkin();
            _pdm_status("PDUint_checkin", status);

            if (status == PDM_S_SUCCESS)
              {
              status = PDUext_checkin();
              _pdm_status("PDUext_checkin", status);
              }

	    if (PDU_structure_list)
              {
              for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
                 FImcf_set_select(forms.local_files_form_id, STRUCTURE_MCF,
                                  row, FALSE);
              }
            break;

      case POST_DATABASE:
  
            status = PDUpost_to_database(refresh->rev_catalog, 
                                         refresh->rev_partid, 
                                         refresh->rev_revision, FALSE);
            _pdm_status("PDUpost_to_database", status);

	    if (PDU_structure_list)
              {
              for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
                 FImcf_set_select(forms.local_files_form_id, STRUCTURE_MCF,
                                  row, FALSE);
              }

           if ((PDU_mcf_list == TRUE) && (status == PDM_S_SUCCESS))
             PDUupdate_form_after_checkin_out(CHECKOUT);

            break;
      case  CHECKOUT:
            status = PDUext_checkout();
            _pdm_status("PDUext_checkout", status);

	    if ((PDU_structure_list) && (status == PDM_S_SUCCESS))
              {
              for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
                 FImcf_set_select(forms.local_files_form_id, STRUCTURE_MCF,
                                  row, FALSE);
              }
            break;

      case  COPY_LOCAL:

            status = PDUcreate_file_buffer_from_refresh(COPY_LOCAL, &buffer);
            _pdm_status("PDUcreate_file_buffer_from_refresh", status);

            if (status != PDM_S_SUCCESS)
              {
              PDUmessage(status, 's');
              break;
              }

            if ((buffer) && (buffer->rows == 0))
              {
              status = PDM_E_COPY_LIST_EMPTY;
              PDUmessage(status, 's');
              MEMclose(&buffer);
              break;
              }

            status = PDUcopy(buffer, COPY_LOCAL, REFRESH_PART);
            _pdm_status("PDUcopy", status);

	    if ((PDU_structure_list) && (status == PDM_S_SUCCESS) &&
                (forms.local_files_form_id))
              {
              for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
                 FImcf_set_select(forms.local_files_form_id, STRUCTURE_MCF,
                                  row, FALSE);
              }
            break;

      case  DELETE_LOCAL:

            _pdm_debug("loading file buffer", 0);
            status=PDUcreate_file_buffer_from_refresh(DELETE_LOCAL, &buffer);
            _pdm_status("PDUcreate_file_bufferfrom_refresh", status);

            if (status != PDM_S_SUCCESS)
              {
              PDUmessage(status, 's');
              return(status);
              }

            if ((buffer) && (buffer->rows == 0))
              {
              status = PDM_E_DELETE_LIST_EMPTY;
              PDUmessage(status, 's');
              MEMclose(&buffer);
              break;
              }

            status = PDUdelete_local_files(buffer,DELETE_LOCAL, REFRESH_PART);
            _pdm_status("PDUdelete_local_files", status);

            break;

      case  CANCEL_CHECKOUT:

            status = PDUext_cancel_checkout();
            _pdm_status("PDUext_cancel_checkout", status);

            break;

      case  PDC_M_DELETE_ELEMENT:

            _pdm_debug("refresh->rev_parttype = <%s>", refresh->rev_parttype);

            if (refresh->rev_parttype &&
               ((strcmp(refresh->rev_parttype, "P") == 0) ||
               (strcmp(refresh->rev_parttype, "p") == 0)))
              {
              _pdm_debug("skipping parametric part", 0);
              status = PDM_E_DELETE_PARAMETRIC_PART;
              return(status);
              }
            else
              {
              status = PDUmulti_delete_part();
              _pdm_status("PDUmulti_delete_part", status);
              }

            _pdm_debug("resetting refresh", 0);
            if (status == PDM_S_SUCCESS)
              {
              refresh->rev_partid = NULL;
              refresh->rev_revision = NULL;
              refresh->rev_description = NULL;
              refresh->rev_filename = NULL;
              refresh->rev_parttype = NULL;

              FIg_set_text(PDU_form_id, PARTNUM_FLD, NULL_STRING);
              FIg_set_text(PDU_form_id, PART_REV_FLD, NULL_STRING);
              FIg_set_text(PDU_form_id, PART_DESC_FLD, NULL_STRING);
              FIg_set_text(PDU_form_id, PART_FILE_FLD, NULL_STRING);
              }

            PDUmessage(status, 's');

            break;

      case  FLAG_PART:

            status = PDUflag_part(PDU_command);
            _pdm_status("PDUflag_part", status);

            if ((status == PDM_S_SUCCESS) && PDU_mcf_list)
              {
              PDUselect_row_in_list_mcf(refresh->rev_catalog,
                                         refresh->rev_partid,
                                         refresh->rev_revision, FALSE);
              }

            PDUmessage(status, 's');

            if (status != PDM_S_SUCCESS)
              sleep(3);

        } /* end switch (type) */
      }
    else  /* parts from listing area will be used */
      {
      _pdm_debug("performing <%s> on parts in the part listing area", command);
      /*FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, NULL_STRING);*/
      _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);

      row_found = FALSE;

      for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
         {
         if ((PDU_parts_index[row] != -1) && (PDU_parts_index[row] != -99))
          {
          _pdm_debug("accessing PDU_parts_list_bufr", 0);
          MEMbuild_array(PDU_parts_list_bufr);
          PDUsetup_buffer(PDU_parts_list_bufr, ROW, &list_row);
          row_found = TRUE;

          _pdm_debug("updating refresh", 0);
          _pdm_debug("old refresh->rev_catalog = <%s>", refresh->rev_catalog);
          _pdm_debug("old refresh->rev_partid = <%s>", refresh->rev_partid);
          _pdm_debug("old refresh->rev_revision = <%s>", refresh->rev_revision);
          _pdm_debug("old refresh->rev_description = <%s>", refresh->rev_description);
          _pdm_debug("old refresh->rev_filename = <%s>", refresh->rev_filename);

          if (!refresh->rev_catalog)
            refresh->rev_catalog = NULL_STRING;
          if (!refresh->rev_partid)
            refresh->rev_partid = NULL_STRING;
          if (!refresh->rev_revision)
            refresh->rev_revision = NULL_STRING;
          if (!refresh->rev_description)
            refresh->rev_description = NULL_STRING;
          if (!refresh->rev_filename)
            refresh->rev_filename = NULL_STRING;
          if (!refresh->rev_parttype)
            refresh->rev_parttype = NULL_STRING;

          /* check for multiple files */
          if (!first_row)
            {
            if ((strcmp(refresh->rev_catalog,
             list_row[(PDU_parts_list_bufr->columns * row) + cat_col]) == 0) &&
             (strcmp(refresh->rev_partid,
             list_row[(PDU_parts_list_bufr->columns * row) + part_col]) == 0) &&
             (strcmp(refresh->rev_revision,
             list_row[(PDU_parts_list_bufr->columns * row) + rev_col]) == 0))
             {
             _pdm_debug("skipping row; multiple files", 0);
             continue;
             }
            }

          first_row = FALSE;

          PDUfill_in_string(&refresh->rev_catalog, 
            list_row[(PDU_parts_list_bufr->columns * row) + cat_col]);
          PDUfill_in_string(&refresh->rev_partid, 
            list_row[(PDU_parts_list_bufr->columns * row) + part_col]);
          PDUfill_in_string(&refresh->rev_revision,
            list_row[(PDU_parts_list_bufr->columns * row) + rev_col]);
          PDUfill_in_string(&refresh->rev_filename,
            list_row[(PDU_parts_list_bufr->columns * row) + file_col]);
          if (PDU_mcf_list == TRUE)
            {
            PDUfill_in_string(&refresh->rev_description,
              list_row[(PDU_parts_list_bufr->columns * row) + desc_col]);
            PDUfill_in_string(&refresh->rev_parttype,
              list_row[(PDU_parts_list_bufr->columns * row) + type_col]);
            }
	  else
            PDUfill_in_string(&refresh->rev_description, "");

          _pdm_debug("after updating refresh", 0);
          _pdm_debug("new refresh->rev_catalog = <%s>", refresh->rev_catalog);
          _pdm_debug("new refresh->rev_partid = <%s>", refresh->rev_partid);
          _pdm_debug("new refresh->rev_revision = <%s>", refresh->rev_revision);
          _pdm_debug("new refresh->rev_description = <%s>", refresh->rev_description);
          _pdm_debug("new refresh->rev_filename = <%s>", refresh->rev_filename);

          /* copy current refresh information into form fields */
          _pdm_debug("updating form fields", 0);
          FIfld_set_text(forms.local_files_form_id, CATALOG_FLD, 0, 0, 
                         refresh->rev_catalog, FALSE);
          FIfld_set_text(forms.local_files_form_id, PARTNUM_FLD, 0, 0, 
                         refresh->rev_partid, FALSE);
          FIfld_set_text(forms.local_files_form_id, PART_REV_FLD, 0, 0, 
                         refresh->rev_revision, FALSE);
          FIfld_set_text(forms.local_files_form_id, PART_DESC_FLD, 0, 0, 
                         refresh->rev_description, FALSE);
          FIfld_set_text(forms.local_files_form_id, PART_FILE_FLD, 0, 0, 
                         refresh->rev_filename, FALSE);

          switch (type)
           {
           case  CHECKIN:
                 _pdm_debug("entering case for checkin", 0);
                 status = PDUint_checkin();
                 _pdm_status("PDUint_checkin", status);

                 if (status == PDM_S_SUCCESS)
                   {
                   status = PDUext_checkin();
                   _pdm_status("PDUext_checkin", status);

                   if ((status == PDM_S_SUCCESS) && (PDU_structure_list))
                     FImcf_set_select(forms.local_files_form_id, STRUCTURE_MCF,
                                      row, FALSE);
                   }
                 break;
  
           case POST_DATABASE:
                 _pdm_debug("entering case for checkin", 0);

                 status = PDUpost_to_database(refresh->rev_catalog,
                                              refresh->rev_partid,
                                              refresh->rev_revision, FALSE);
                 _pdm_status("PDUpost_to_database", status);

                 if ((status == PDM_S_SUCCESS) && (PDU_structure_list))
                   FImcf_set_select(forms.local_files_form_id, STRUCTURE_MCF,
                                    row, FALSE);

                 if ((PDU_mcf_list == TRUE) && (status == PDM_S_SUCCESS))
                   PDUupdate_form_after_checkin_out(CHECKOUT);

                 break;
  
           case  CHECKOUT:
                 _pdm_debug("entering case for checkout", 0);
                 status = PDUext_checkout();
                 _pdm_status("PDUext_checkout", status);

                 if ((status == PDM_E_PART_CHECKED_OUT) &&
                     (PDU_command == PDC_M_CHECKOUT_ACTIVATE))
                   {
                   _pdm_debug("calling PDUload_file_buffer", 0);
                   status = PDUload_file_buffer(refresh->rev_catalog,
                              refresh->rev_partid, refresh->rev_revision,
                              refresh->rev_description, "");
                   _pdm_status("PDUload_file_buffer", status);
                   if (status != PDM_S_SUCCESS)
                     _pdm_debug("failed to load file buffer after checkout", 0);
                   status = PDM_S_SUCCESS;
                   }

		 if (((status == PDM_E_PART_CHECKED_OUT) || 
                      (status == PDM_S_SUCCESS)) && (PDU_structure_list))
                   FImcf_set_select(forms.local_files_form_id, STRUCTURE_MCF,
                                    row, FALSE);

                 break;
  
           case  DELETE_LOCAL:

                 if ((!PDU_delete_buffer) ||
                     ((PDU_delete_buffer) && (PDU_delete_buffer->rows == 0)))
                   {
                   status = PDM_E_DELETE_LIST_EMPTY;
                   PDUmessage(status, 's');
                   MEMclose(&PDU_delete_buffer);
                   PDU_delete_buffer = NULL;
                   break;
                   }

/*
                 for (f_row = 0; f_row < PDU_delete_buffer->rows; ++f_row)
                    {
                    _pdm_debug("row to delete = %d", (char *)f_row);
                    status = PDUextract_row_from_buffer(&file_buffer, 
                                                      PDU_delete_buffer,f_row);
                    _pdm_status("PDUextract_row_from_buffer", status);

                    status = PDUdelete_local_files(file_buffer,
                                                   DELETE_LOCAL, LIST_PART);
                    _pdm_status("PDUdelete_local_files", status);
                    }
*/
                 status = PDUdelete_local_files(PDU_delete_buffer,
                                                DELETE_LOCAL, LIST_PART);
                 _pdm_status("PDUdelete_local_files", status);

		 if (PDU_delete_buffer)
                   {
                   MEMclose(&PDU_delete_buffer);
                   PDU_delete_buffer = NULL;
                   }

                 row = PDU_parts_list_bufr->rows;
                 break;
  
           case  COPY_LOCAL:
  
                 /* call function to create buffer of files to copy */
                 if (PDU_mcf_list || PDU_structure_list)
                   {
                   status = PDUcreate_file_buffer(COPY_LOCAL, &buffer);
                   _pdm_status("PDUcreate_file_buffer", status);
                   }
                 else
                   {
                   status = PDM_E_NO_PARTS_SELECTED;
                   PDUmessage(status, 's');
                   break;
                   }

                 if (status != PDM_S_SUCCESS)
                   {
                   PDUmessage(status, 's');
                   return(status);
                   }

                if ((buffer) && (buffer->rows == 0) && (!PDU_activate_copy))
                  {
                  status = PDM_E_COPY_LIST_EMPTY;
                  PDUmessage(status, 's');
                  row = PDU_parts_list_bufr->rows;
                  break;
                  } 

                if ((buffer) && (buffer->rows == 0) && (PDU_activate_copy))
                  {
                  if ((PDU_part_file_buffer == NULL) ||
                      (PDU_part_file_buffer->rows == 0))
                    {
                    status = PDM_E_COPY_LIST_EMPTY;
                    PDUmessage(status, 's');
                    row = PDU_parts_list_bufr->rows;
                    break;
                    } 
		  else
                    {
                    PDUpart_file_list_form();

                    status = WaitForEvent();
                    _pdm_status("WaitForEvent", status);

                    if (!status)
                      {
                       _pdm_debug("part listing form was cancelled", 0);
                       PDUmessage(PDM_E_CMD_CANCELLED, 's');
                       break;
                      }

                    row = PDU_parts_list_bufr->rows;
                    break;
                    }
                  }

/*
                for (f_row = 0; f_row < buffer->rows; ++f_row)
                   {
                   _pdm_debug("row to delete = %d", (char *)f_row);
                   status = PDUextract_row_from_buffer(&file_buffer, 
                                                       buffer, f_row);
                   _pdm_status("PDUextract_row_from_buffer", status);

                   status = PDUcopy(file_buffer, COPY_LOCAL, LIST_PART);
                   _pdm_status("PDUcopy", status);
                   }
*/

                 status = PDUcopy(buffer, COPY_LOCAL, LIST_PART);
                 _pdm_status("PDUcopy", status);

	         if ((PDU_structure_list) && (status == PDM_S_SUCCESS))
                   {
                   for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
                      FImcf_set_select(forms.local_files_form_id, STRUCTURE_MCF,
                                       row, FALSE);
                   }

                 row = PDU_parts_list_bufr->rows;
                 break;

           case  CANCEL_CHECKOUT:

                 status = PDUext_cancel_checkout();
                 _pdm_status("PDUext_cancel_checkout", status);

                 if (status != PDM_S_SUCCESS)
                   {
                   _pdm_debug("marking row for failure", 0);
                   PDU_parts_index[row] = -99;
                   }

                 break;
  
           case  PDC_M_DELETE_ELEMENT:
     
                 _pdm_debug("parttype = <%s>", refresh->rev_parttype);

                 if (refresh->rev_parttype &&
                    ((strcmp(refresh->rev_parttype, "P") == 0) ||
                    (strcmp(refresh->rev_parttype, "p") == 0)))
                   {
                   _pdm_debug("skipping parametric part", 0);
                   status = PDM_E_DELETE_PARAMETRIC_PART;
                   PDUmessage(status, 's');
                   continue;
                   }
                 else
                   {
                   status = PDUmulti_delete_part();
                   _pdm_status("PDUmulti_delete_part", status);
                   }

                 _pdm_debug("resetting refresh", 0);
                 if (status == PDM_S_SUCCESS)
                   {
                   refresh->rev_partid = NULL;
                   refresh->rev_revision = NULL;
                   refresh->rev_description = NULL;
                   refresh->rev_filename = NULL;
                   refresh->rev_parttype = NULL;
     
                   FIg_set_text(PDU_form_id, PARTNUM_FLD, NULL_STRING);
                   FIg_set_text(PDU_form_id, PART_REV_FLD, NULL_STRING);
                   FIg_set_text(PDU_form_id, PART_DESC_FLD, NULL_STRING);
                   FIg_set_text(PDU_form_id, PART_FILE_FLD, NULL_STRING);
                   }
                 PDUmessage(status, 's');
     
                 break;

           case  FLAG_PART:
     
                 status = PDUflag_part(PDU_command);
                 _pdm_status("PDUflag_part", status);
     
                 if ((status == PDM_S_SUCCESS) && PDU_mcf_list)
                   {
                   PDUselect_row_in_list_mcf(refresh->rev_catalog,
                                              refresh->rev_partid,
                                              refresh->rev_revision, FALSE);
                   }

                 PDUmessage(status, 's');

            } /* end switch (type) */
         } /* end if PDU_parts_index != -1 */
        }    /* end for loop */
      /* KLUDGE for cancel checkout when no parts have been selected in the
         parts listing area but a part is selected on the cancel checkout
         form */
/* commented 12/6/93 for TR139313614 - mjg
      if ((PDU_command == PDC_M_CANCEL_CHECKOUT) &&
          (PDU_selected_rows > 0))
        {
        row_found = TRUE;

        status = PDUext_cancel_checkout();
        _pdm_status("PDUext_cancel_checkout", status);
        }
*/
      if (row_found == FALSE)
        {
        msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
        FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, msg);
        status = PDM_I_ENTER_PART;
        }
      }

  return(status);

} /* end PDUcheck_part() */

int PDUcreate_file_buffer(command, file_bufr)
int        command;
MEMptr     *file_bufr;
{
int        type = 0;
int        char_index;
int        status = PDM_S_SUCCESS;
int        file_status;
int        row = 0;
int        select = 0;
int        pos = 0;
int        length = 0;
int        load_row = 0;
int        field = 0;
int        file_col = 0;
int        ptype_col = 0;
int        cat_col = 0;
int        part_col = 0;
int        rev_col = 0;
int        file2_col = 0;
int        file_row = 0;
short      validate_part = TRUE;
char     * line = NULL;
char     * filename = NULL;
char     **data_row;
char     **list_row;
char     * msg = NULL;
static char *text;
Form       form;
MEMptr   buffer = NULL;

  _pdm_debug("In the function PDUcreate_file_buffer", 0);

  if (!PDU_parts_list_bufr)
    return(PDM_E_NULL_BUFFER);

  command = 0;

  form = forms.local_files_form_id;

  if (PDU_mcf_list)
    field = LIST_MCF;
  else if (PDU_structure_list)
    field = STRUCTURE_MCF;

  /* create buffer */
  type = PDU_FILE_BUFFER;

  status = PDUformat_buffer (type, file_bufr);
  _pdm_status("PDUformat_buffer", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  line = (char*) malloc ((*file_bufr)->row_size);

  MEMbuild_array(PDU_parts_list_bufr);
  PDUsetup_buffer(PDU_parts_list_bufr, ROW, &list_row);

  status = PDUget_buffer_col(PDU_parts_list_bufr, "n_catalogname", &cat_col);
  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  status = PDUget_buffer_col(PDU_parts_list_bufr, "n_itemname", &part_col);
  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  status = PDUget_buffer_col(PDU_parts_list_bufr, "n_itemrev", &rev_col);
  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  status = PDUget_buffer_col(PDU_parts_list_bufr, "n_cofilename", &file2_col);
  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  status = PDUget_buffer_col(PDU_parts_list_bufr, "p_parttype", &ptype_col);
  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
     {
     load_row = TRUE;
     if (PDU_parts_index[row] != -1)
       {
       validate_part = TRUE;

         _pdm_debug("checking for blank row", 0);
         FIfld_get_text_length(form, field, row, 1, &length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL_STRING, sizeof (char) * length + 1);
         FIfld_get_text(form, field, row, 1, length, 
                       (unsigned char *)text,&select,&pos);
  
         _pdm_debug("text = <%s>", text);

         if (strcmp(text, "") == 0)
           {
           validate_part = FALSE;
           load_row = FALSE;
           continue;
           }

         _pdm_debug("getting part info", 0);
         PDUfill_in_string(&refresh->rev_catalog,
            list_row[(PDU_parts_list_bufr->columns * row) + cat_col]);

         PDUfill_in_string(&refresh->rev_partid,
            list_row[(PDU_parts_list_bufr->columns * row) + part_col]);

         PDUfill_in_string(&refresh->rev_revision,
            list_row[(PDU_parts_list_bufr->columns * row) + rev_col]);

         PDUfill_in_string(&refresh->rev_filename,
            list_row[(PDU_parts_list_bufr->columns * row) + file2_col]);

         PDUfill_in_string(&refresh->rev_parttype,
            list_row[(PDU_parts_list_bufr->columns * row) + ptype_col]);

       if (PDU_activate_copy)
       {
       /* check to see if the part is checked in */
       status = PDMrcheck_part_status(refresh->rev_catalog, 
                                      refresh->rev_partid,
                                      refresh->rev_revision);

       _pdm_status("PDMrcheck_part_status", status);

       if ((status == PDM_I_CHECKED_OUT_BY_YOU) ||
           (status == PDM_I_COPIED_TO_LOCAL_BY_YOU) ||
           (status == PDM_I_NEVER_CHECKED_IN))
         {
         file_status = status;
         /* check to see if file is already local */
         status = PDUverify_file(refresh->rev_filename);
         _pdm_status("PDUverify_file", status);

         if (status == PDM_S_SUCCESS)  /* file is already local */
           {
           /* call function to load part into global buffer */
           _pdm_debug("loading local part into file buffer", 0);
           status = PDUload_file_buffer_after_copy(NULL, 0, 0, 
                               refresh->rev_catalog,
                               refresh->rev_partid, 
                               refresh->rev_revision, 
                               refresh->rev_filename);
           _pdm_status("PDUload_file_buffer_after_copy", status);
           if (status != PDM_S_SUCCESS)
             _pdm_debug("failed to load copied part into buffer", 0);
           }
         else
           {
           if (file_status == PDM_I_NEVER_CHECKED_IN)
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
                 msg = (char *) PDUtranslate_message(PDM_E_RETRIEVE_NONGRAPHIC);
                 FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, msg);
                 PDUmessage(PDM_E_RETRIEVE_NONGRAPHIC, 's');
                 sleep(2);
                 }
               else
                 {
                 msg = (char *) PDUtranslate_message(PDM_E_NO_PART_FILES);
                 FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, msg);
                 PDUmessage(PDM_E_NO_PART_FILES, 's');
                 sleep(2);
                 }
               }
             }
           else
             {
             msg = (char *) PDUtranslate_message_and_vars(PDM_E_FILE_NOT_LOCAL,
                                                        refresh->rev_filename);
             FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, msg);
             PDUfill_in_string(&PDU_save_filename, refresh->rev_filename);
             status = PDM_E_FILE_NOT_LOCAL;
             PDUmessage(PDM_E_FILE_NOT_LOCAL, 's');
             sleep(2);
             }
           }
         load_row = FALSE;
         status = MEM_S_SUCCESS;
         }
       else if ((status == PDM_I_CHECKED_IN) ||
                (status == PDM_I_ATTACHED_TO_LOCAL_ASSY) ||
                (status == PDM_I_CHECKED_OUT_BY_ANOTHER_USER))
         {
         _pdm_debug("preparing file for copy to local", 0);
         if (validate_part == TRUE)
           load_row = TRUE;
         else
           {
           load_row = FALSE;
           status = MEM_S_SUCCESS;
           }
         }
       else if (status == MEM_S_SUCCESS)
         {
         status = PDM_E_ERROR_RETRIEVING_STATUS;
         PDUmessage(status, 's');
         load_row = FALSE;
         }
       else
         {
         status = PDM_E_NOTCHECK_IN;
         PDUmessage(status, 's');
         load_row = FALSE;
         }
       }
       else
       {
       /* check to see if the part is checked in */
       status = PDMrcheck_part_status(refresh->rev_catalog, 
                                      refresh->rev_partid,
                                      refresh->rev_revision);

       _pdm_status("PDMrcheck_part_status", status);
       
       if (status == MEM_S_SUCCESS)
         {
         PDUmessage(PDM_E_ERROR_RETRIEVING_STATUS, 's');
         break;
         }
 
       if ((status != PDM_I_CHECKED_IN) &&
           (status != PDM_I_ATTACHED_TO_LOCAL_ASSY) &&
           (status != PDM_I_CHECKED_OUT_BY_ANOTHER_USER))
         {
         PDUmessage(status, 's');
         load_row = FALSE;
         }
       }

       if (load_row == FALSE)
         continue;

       if (validate_part == TRUE)
         {
         _pdm_debug("validating access for copy files", 0);
         status = PDMvalidate_user_access("PDMCopy File To Local", NULLSTR,
                                          refresh->rev_catalog,
                                          NULLSTR,
                                          refresh->rev_partid, 
                                          refresh->rev_revision);
         _pdm_status ("PDMvalidate_user_access", status);
  
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           _pdm_debug("User does not have access to copy this part", 0);
           if (buffer)
             {
             MEMclose(&buffer);
             buffer = NULL;
             }
           if (*file_bufr)
             {
             MEMclose(file_bufr);
             *file_bufr = NULL;
             }
           if (PDU_part_file_buffer)
             {
             MEMclose(&PDU_part_file_buffer);
             PDU_part_file_buffer = NULL;
             }
           return(status);
           }
         }

       if (load_row == FALSE)
         continue;

       _pdm_debug("retrieving list of filenames", 0);
       MEMclose(&buffer);
       buffer = NULL;
       status = PDMget_filenames(refresh->rev_catalog, refresh->rev_partid, 
                                 refresh->rev_revision, &buffer);
       _pdm_status("PDMget_filenames", status);
      
       if ( status != PDM_S_SUCCESS )
         {
         msg = (char *) PDUtranslate_message(status);
         FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, msg);
         MEMclose(&buffer);
         PDUmessage(status, 's');
         return(status);
         }
      
       if (buffer == NULL)
         {
         msg = (char *) PDUtranslate_message(PDM_E_NO_PART_FILES);
         FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, msg);
         return(PDM_I_NO_FILES_FOUND);
         }
 
       if ((buffer) && (buffer->rows > 0))
         {
         MEMbuild_array(buffer);
         status = PDUget_buffer_col(buffer, "n_cofilename", &file_col);
         if (status != PDM_S_SUCCESS)
           return(status);
      
         PDUsetup_buffer(buffer, ROW, &data_row);
         }
       else
         return(PDM_I_NO_FILES_FOUND);
 
       status = PDM_S_SUCCESS;

       for (file_row = 0; file_row < buffer->rows; ++file_row)
          {
          memset (line, NULL, (*file_bufr)->row_size);
          char_index = 0;

          PDUfill_in_string(&filename, 
                            data_row[(buffer->columns * file_row) + file_col]);
          PDUfill_in_string(&refresh->rev_filename, filename);
          _pdm_debug("filename = <%s>", filename);

          /* add the n_catalogno and n_itemno columns to the buffer */
          line[char_index++] = '\1';    /* entry for n_catalono */
          line[char_index++] = '\1';    /* entry for n_itemno */
   
          /* add part information to buffer */
          if ((refresh->rev_catalog != NULL) && 
              (strcmp(refresh->rev_catalog, "") != 0))
            PDUadd_buffer_string(line, &char_index, refresh->rev_catalog);
          else
            line[char_index++] = '\1';
   
          if ((refresh->rev_partid != NULL) && 
              (strcmp(refresh->rev_partid, "") != 0))
            PDUadd_buffer_string(line, &char_index, refresh->rev_partid);
          else
            line[char_index++] = '\1';
   
          if ((refresh->rev_revision != NULL) && 
              (strcmp(refresh->rev_revision, "") != 0))
            PDUadd_buffer_string(line, &char_index, refresh->rev_revision);
          else
            line[char_index++] = '\1';
   
          if (filename && (strcmp(filename, "") != 0))
            PDUadd_buffer_string(line, &char_index, filename);
          else
            line[char_index++] = '\1';
   
          if ((refresh->rev_parttype != NULL) && 
              (strcmp(refresh->rev_parttype, "") != 0))
            PDUadd_buffer_string(line, &char_index, refresh->rev_parttype);
          else
            line[char_index++] = '\1';
   
          line[char_index++] = '\1';    /* entry for p_action */
          _pdm_debug("line = <%s>", line);
          status = MEMwrite (*file_bufr, line);

          if (status != MEM_S_SUCCESS)
            {
            _pdm_debug("Error writing to file buffer", 0);
            _pdm_status("MEMwrite_format ()", status);
   
            memset (line, NULL, (*file_bufr)->row_size);
            }
          }
       }  /* end if */

     }  /* end for row */
  if (PDMdebug_on)
    MEMprint_buffer("file buffer", *file_bufr, PDU_DEBUG_FILE);

  if (status == MEM_S_SUCCESS)
    status = PDM_S_SUCCESS;

  return(status);
} /* end PDUcreate_file_buffer */

int PDUupdate_local_column(command, file_bufr, orig_bufr)
  int       command;
  MEMptr    file_bufr;
  MEMptr    orig_bufr;
{
  char      *state = NULL;
  char      *action = NULL;
  int       status = PDM_S_SUCCESS;
  int       file_row = 0;
  int       action_col = 0;
  int       local_col = 0;
  int       update_col = 0;
  int       bufr_cat = 0;
  int       bufr_item = 0;
  int       bufr_rev = 0;
  int       bufr_file = 0;
  int       form_cat_col = 0;
  int       form_item_col = 0;
  int       form_rev_col = 0;
  int       form_file_col = 0;
  int       row = 0;
  char      **file_data;
  char      **form_data;
  char      status_list[200];
  char      *file_cat = NULL;
  char      *file_part = NULL;
  char      *file_rev = NULL;
  char      *file_file = NULL;
  char      *form_cat = NULL;
  char      *form_part = NULL;
  char      *form_rev = NULL;
  char      *form_file = NULL;
  Form      form;
  int       field = 0;
  int       mcf_select = 0;
  short     copied = TRUE;

  _pdm_debug("In the function PDUupdate_local_column", 0);

  form = forms.local_files_form_id;
  field = LIST_MCF;

  if (PDU_parts_list_bufr)
    MEMbuild_array(PDU_parts_list_bufr);
  else
    return(PDM_E_NULL_BUFFER);

  _pdm_debug("getting columns from the PDU_parts_list_bufr", 0);
  status = PDUget_buffer_col(PDU_parts_list_bufr,"n_catalogname",&form_cat_col);
  if (status != PDM_S_SUCCESS)
      return(status);

  status = PDUget_buffer_col(PDU_parts_list_bufr, "n_itemname", &form_item_col);
  if (status != PDM_S_SUCCESS)
      return(status);

  status = PDUget_buffer_col(PDU_parts_list_bufr, "n_itemrev", &form_rev_col);
  if (status != PDM_S_SUCCESS)
      return(status);

  status = PDUget_buffer_col(PDU_parts_list_bufr,"n_cofilename",&form_file_col);
  if (status != PDM_S_SUCCESS)
      return(status);

  status = PDUget_buffer_col(PDU_parts_list_bufr, "p_local", &local_col);
  if (status != PDM_S_SUCCESS)
      return(status);

  status = PDUget_buffer_col(PDU_parts_list_bufr, "p_update", &update_col);
  if (status != PDM_S_SUCCESS)
      return(status);

  PDUsetup_buffer(PDU_parts_list_bufr, ROW, &form_data);

  /* set up the file list buffer */
  if (file_bufr)
    MEMbuild_array(file_bufr);
  else
    {
    status = PDM_E_READ_PARTS;
    PDUmessage(status, 's');
    return(status);
    }

  _pdm_debug("getting columns from file_bufr", 0);
  status = PDUget_buffer_col(file_bufr, "n_catalogname", &bufr_cat);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(file_bufr, "n_itemname", &bufr_item);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(file_bufr, "n_itemrev", &bufr_rev);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(file_bufr, "p_action", &action_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  status = PDUget_buffer_col(file_bufr, "n_cofilename", &bufr_file);
  if (status != PDM_S_SUCCESS)
    return(status);

  PDUsetup_buffer(file_bufr, ROW, &file_data);

  /* set up a string for the files that were not copied successfully */
  strcpy(status_list, "File(s) <");

for (file_row = 0; file_row < file_bufr->rows; ++file_row)
   {
   _pdm_debug("reading part info from file_bufr", 0);
   PDUfill_in_string(&file_cat, 
                 file_data[(file_bufr->columns * file_row) + bufr_cat]);
   PDUfill_in_string(&file_part, 
                 file_data[(file_bufr->columns * file_row) + bufr_item]);
   PDUfill_in_string(&file_rev, 
                 file_data[(file_bufr->columns * file_row) + bufr_rev]);
   PDUfill_in_string(&file_file, 
                 file_data[(file_bufr->columns * file_row) + bufr_file]);
   PDUfill_in_string(&action, 
                 file_data[(file_bufr->columns * file_row) + action_col]);

   _pdm_debug("file_cat = <%s>", file_cat);
   _pdm_debug("file_part = <%s>", file_part);
   _pdm_debug("file_rev = <%s>", file_rev);
   _pdm_debug("file_file = <%s>", file_file);
   _pdm_debug("action = <%s>", action);

/* 2/7/96 MJG - TR 139526084 */
/* Only parent parts will be marked COPIED TO LOCAL.  Child parts will be
   marked ATTACHED.  */

   if (orig_bufr)
     {
     _pdm_debug("check to see if part is in original buffer", 0);
     copied = PDUis_part_in_buffer(file_cat, file_part, file_rev, orig_bufr);
     _pdm_debug("PDUis_part_in_buffer returns %d", (char*) copied);
     }

   for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
     {
     _pdm_debug("reading part info from PDU_parts_list_bufr", 0);
     PDUfill_in_string(&form_cat, 
               form_data[(PDU_parts_list_bufr->columns * row) + form_cat_col]);
     PDUfill_in_string(&form_part, 
               form_data[(PDU_parts_list_bufr->columns * row) + form_item_col]);
     PDUfill_in_string(&form_rev, 
               form_data[(PDU_parts_list_bufr->columns * row) + form_rev_col]);
     PDUfill_in_string(&form_file, 
               form_data[(PDU_parts_list_bufr->columns * row) + form_file_col]);

     _pdm_debug("form_cat = <%s>", form_cat);
     _pdm_debug("form_part = <%s>", form_part);
     _pdm_debug("form_rev = <%s>", form_rev);
     _pdm_debug("form_file = <%s>", form_file);

     _pdm_debug("checking cat/part/rev for NULL", 0);
     if ( file_cat && file_part && file_rev && file_file &&
          form_cat && form_part && form_rev && form_file &&
        (strcmp(file_cat, form_cat) == 0) &&
        (strcmp(file_part, form_part) == 0) &&
        (strcmp(file_file, form_file) == 0) &&
        (strcmp(file_rev, form_rev) == 0) )
       {
       _pdm_debug("match found on row = %d", (char *)row);
       if ((action) && (strcmp(action, "SUCCESS") == 0))
         {
         if (command == DELETE_LOCAL)
           PDUfill_in_string(&state, "DELETED");
         else if (command == COPY_LOCAL)
           {
           if (copied)
             PDUfill_in_string(&state, "COPIED TO LOCAL");
           else
             PDUfill_in_string(&state, "ATTACHED");
           }

         if ((command == COPY_LOCAL) && PDU_activate_copy)
           {
	   /* call function to load part into global buffer */
           status = PDUload_file_buffer_after_copy(file_bufr, 1, file_row, 
                                                   "","","","");
           _pdm_status("PDUload_file_buffer_after_copy", status);
	   if (status != PDM_S_SUCCESS)
             _pdm_debug("failed to load file buffer after copy", 0);
           status = PDM_S_SUCCESS;
           }

         _pdm_debug("updating MCF on form", 0);
         FIfld_set_text(form,field,row,local_col, state,FALSE);
         FIfld_set_text(form,field,row,update_col, "Y",FALSE);

         _pdm_debug("calling MEMwrite_data", 0);
         MEMwrite_data(PDU_parts_list_bufr, state, row + 1, local_col + 1);
         MEMwrite_data(PDU_parts_list_bufr, "Y", row + 1, update_col + 1);
         }
       else if ((action) && (strcmp(action, "REFERENCED") == 0) &&
                (command == DELETE_LOCAL))
         {
         _pdm_debug("file is still referenced locally", 0);
         _pdm_debug("updating MCF on form", 0);
         PDUfill_in_string(&state, "DELETED");
         FIfld_set_text(form,field,row,local_col, state,FALSE);
         FIfld_set_text(form,field,row,update_col, "Y",FALSE);

         _pdm_debug("calling MEMwrite_data", 0);
         MEMwrite_data(PDU_parts_list_bufr, state, row + 1, local_col + 1);
         MEMwrite_data(PDU_parts_list_bufr, "Y", row + 1, update_col + 1);
         }
       else if ((action) && (strcmp(action, "CHECKED OUT") == 0) &&
                (command == DELETE_LOCAL))
         {
         _pdm_debug("file is still referenced locally", 0);
         _pdm_debug("updating MCF on form", 0);
         PDUfill_in_string(&state, "CHECKED OUT");
         FIfld_set_text(form,field,row,local_col, state,FALSE);
         FIfld_set_text(form,field,row,update_col, "Y",FALSE);

         _pdm_debug("calling MEMwrite_data", 0);
         MEMwrite_data(PDU_parts_list_bufr, state, row + 1, local_col + 1);
         MEMwrite_data(PDU_parts_list_bufr, "Y", row + 1, update_col + 1);
         }
       else if (strcmp(action, "NO_UPDATE") == 0) /* added for copy local */
         {
         if (command == DELETE_LOCAL)
           PDUfill_in_string(&state, "DELETED");
         else if (command == COPY_LOCAL)
           {
           if (copied)
             PDUfill_in_string(&state, "COPIED TO LOCAL");
           else
             PDUfill_in_string(&state, "ATTACHED");
           }

         if ((command == COPY_LOCAL) && PDU_activate_copy)
           {
           /* call function to load part into global buffer */
           status = PDUload_file_buffer_after_copy(file_bufr, 1, file_row,
                                                     "","","","");
           _pdm_status("PDUload_file_buffer_after_copy", status);
           if (status != PDM_S_SUCCESS)
             _pdm_debug("failed to load file buffer after copy", 0);
           }

         _pdm_debug("updating MCF on form", 0);
         FIfld_set_text(form,field,row,local_col, state,FALSE);
         FIfld_set_text(form,field,row,update_col, "Y",FALSE);

         _pdm_debug("calling MEMwrite_data", 0);
         MEMwrite_data(PDU_parts_list_bufr, state, row + 1, local_col + 1);
         MEMwrite_data(PDU_parts_list_bufr, "Y", row + 1, update_col + 1);
         }
       else if ((action) && (strcmp(action, "NOT_MOVED") == 0))
         {
         if (command == DELETE_LOCAL)
           PDUfill_in_string(&state, "DELETED");
         else if (command == COPY_LOCAL)
           {
           if (copied)
             PDUfill_in_string(&state, "COPIED TO LOCAL");
           else
             PDUfill_in_string(&state, "ATTACHED");
           }

         if ((command == COPY_LOCAL) && PDU_activate_copy)
           {
	   /* call function to load part into global buffer */
           status = PDUload_file_buffer_after_copy(file_bufr, 1, file_row, 
                                                   "","","","");
           _pdm_status("PDUload_file_buffer_after_copy", status);
	   if (status != PDM_S_SUCCESS)
             _pdm_debug("failed to load file buffer after copy", 0);
           status = PDM_S_SUCCESS;
           }

         _pdm_debug("updating MCF on form", 0);
         FIfld_set_text(form,field,row,local_col, state,FALSE);
         FIfld_set_text(form,field,row,update_col, "Y",FALSE);

         _pdm_debug("calling MEMwrite_data", 0);
         MEMwrite_data(PDU_parts_list_bufr, state, row + 1, local_col + 1);
         MEMwrite_data(PDU_parts_list_bufr, "Y", row + 1, update_col + 1);
         }
       else if (strcmp(action, "NO_UPDATE") != 0) /* added for copy local */
         {
         _pdm_debug("adding data to the status list", 0);
         _pdm_debug("status_list = <%s>", status_list);
         if (strlen(status_list) > 9)
           strcat(status_list, ", ");
         _pdm_debug("file = <%s>", file_file);
         strcat(status_list, file_file);
         _pdm_debug("status_list (after strcat) = <%s>", status_list);
         }
       FIfld_get_select(forms.local_files_form_id,LIST_MCF,row,0,&mcf_select);
       if (mcf_select)
         {
         PDU_parts_index[row] = -1;
         FImcf_set_select(forms.local_files_form_id, LIST_MCF, row, FALSE);
         PDU_selected_rows = PDU_selected_rows - 1;
         }

       form_cat = NULL_STRING;
       form_part = NULL_STRING;
       form_rev = NULL_STRING;
       form_file = NULL_STRING;

       break;
       }
     }
   file_cat = NULL_STRING;
   file_part = NULL_STRING;
   file_rev = NULL_STRING;
   file_file = NULL_STRING;
   }

  if (strlen(status_list) > 9)
    {
    if (command == DELETE_LOCAL)
      {
      strcat(status_list, "> could not be deleted");
      status = PDM_E_DELETE_FILES;
      if (strlen(status_list) > 200)
        _pdm_debug("SEVERE ERROR: status_list exceeds 200 characters", 0);
      }
    else if (command == COPY_LOCAL)
      {
      strcat(status_list, "> could not be copied to local");
      status = PDM_E_COPY_FILES;
      if (strlen(status_list) > 200)
        _pdm_debug("SEVERE ERROR: status_list exceeds 200 characters", 0);
      }
    FIg_set_text(form, FI_MSG_FIELD, status_list);
    }

  MEMclose(&file_bufr);
  file_bufr = NULL;

  return(status);
}

int PDUcreate_file_buffer_from_refresh(action, file_bufr)
int	   action;
MEMptr     *file_bufr;
{
int        type = 0;
int        char_index = 0;
int        status = PDM_S_SUCCESS;
int        row = 0;
int        type_col = 0;
int        file_col = 0;
char     * line = NULL;
char     * parttype = NULL;
char     * filename = NULL;
char     **data_row;
char     * msg = NULL;
MEMptr     buffer = NULL;

  _pdm_debug("In the function PDUcreate_file_buffer_from_refresh", 0);

  if (action == COPY_LOCAL)
    {
    _pdm_debug("validating access for copy files", 0);
    status = PDMvalidate_user_access("PDMCopy File To Local", NULLSTR,
                                   refresh->rev_catalog, NULLSTR,
                                   refresh->rev_partid, refresh->rev_revision);
    _pdm_status ("PDMvalidate_user_access", status);
 
    if (status != PDM_S_SUCCESS)
      {
      PDUmessage(status, 's');
      _pdm_debug("User does not have access to copy this part", 0);
      return(status);
      }
    }

  /* create buffer */
  type = PDU_FILE_BUFFER;

  status = PDUformat_buffer (type, file_bufr);
  _pdm_status("PDUformat_buffer", status);

  if (status != PDM_S_SUCCESS)
    {
    PDUmessage(status, 's');
    return(status);
    }

  line = (char*) malloc ((*file_bufr)->row_size);

  /* query for part type */
  _pdm_debug("querying for parttype", 0);
  status = PDMquery_part_type(refresh->rev_catalog, 
                              refresh->rev_partid, 
                              refresh->rev_revision, &buffer);

  if ((buffer) && (status == PDM_S_SUCCESS))
    {
    MEMbuild_array(buffer);
    status = PDUget_buffer_col(buffer, "p_parttype", &type_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    PDUsetup_buffer(buffer, ROW, &data_row);

    PDUfill_in_string(&parttype,
                data_row[(buffer->columns * 0) + type_col]);
    _pdm_debug("parttype = <%s>", parttype);
    if (buffer)
      {
      MEMclose(&buffer);
      buffer = NULL;
      }
    }
  else
    {
    PDUmessage(status, 's');
    if (buffer)
      {
      MEMclose(&buffer);
      buffer = NULL;
      }
    return(status);
    }

  _pdm_debug("retrieving list of filenames", 0);
  status = PDMget_filenames(refresh->rev_catalog,refresh->rev_partid,
                         refresh->rev_revision, &buffer);
  _pdm_status("PDMget_filenames", status);
 
  if ( status != PDM_S_SUCCESS )
    {
    msg = (char *) PDUtranslate_message(status);
    FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, msg);
    MEMclose(&buffer);
    PDUmessage(status, 's');
    return(status);
    }
 
  if (buffer == NULL)
    {
    msg = (char *) PDUtranslate_message(PDM_I_NO_FILES_FOUND);
    FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, msg);
    return(PDM_I_NO_FILES_FOUND);
    }

  if ((buffer) && (buffer->rows > 0))
    {
    MEMbuild_array(buffer);
    status = PDUget_buffer_col(buffer, "n_cofilename", &file_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    PDUsetup_buffer(buffer, ROW, &data_row);
    }
  else
    return(PDM_I_NO_FILES_FOUND);


  for (row = 0; row < buffer->rows; ++row)
     {
     status = PDM_S_SUCCESS;
     PDUfill_in_string(&filename, data_row[(buffer->columns * row) + file_col]);
/*
     if (action == DELETE_LOCAL)
       {
       status = PDUverify_file(filename);
       _pdm_status("PDUverify_file", status);

       if (status != PDM_S_SUCCESS)
         {
         msg = (char *) PDUtranslate_message_and_vars(PDM_E_FILE_NOT_LOCAL,
                                                      filename);
         FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, msg);
         PDUfill_in_string(&PDU_save_filename, filename);
         PDUmessage(PDM_E_FILE_NOT_LOCAL, 's');
         status = PDM_E_FILE_NOT_LOCAL;
         }
       }
*/

     if (status == PDM_S_SUCCESS)
       {
       memset (line, NULL, (*file_bufr)->row_size);
       char_index = 0;

       /* add the n_catalogno and n_itemno columns to the buffer */
       line[char_index++] = '\1';    /* entry for n_catalono */
       line[char_index++] = '\1';    /* entry for n_itemno */
  
       /* add the refresh information to the buffer */
       if (refresh->rev_catalog && (strlen (refresh->rev_catalog )))
         PDUadd_buffer_string(line, &char_index, refresh->rev_catalog);
       else
         line[char_index++] = '\1';
  
       if (refresh->rev_partid && (strlen (refresh->rev_partid )))
         PDUadd_buffer_string(line, &char_index, refresh->rev_partid);
       else
         line[char_index++] = '\1';
  
       if (refresh->rev_revision && (strlen (refresh->rev_revision )))
         PDUadd_buffer_string(line, &char_index, refresh->rev_revision);
       else
         line[char_index++] = '\1';
  
       if (filename && (strlen (filename )))
         PDUadd_buffer_string(line, &char_index, filename);
       else
         line[char_index++] = '\1';
  
       if (parttype && (strlen (parttype )))
         PDUadd_buffer_string(line, &char_index, parttype);
       else
         line[char_index++] = '\1';
  
       line[char_index++] = '\1';    /* entry for p_action */
       _pdm_debug("line = <%s>", line);
       status = MEMwrite (*file_bufr, line);
    
       if (status != MEM_S_SUCCESS)
         {
         _pdm_debug("Error writing to file buffer", 0);
         _pdm_status("MEMwrite_format ()", status);
  
         memset (line, NULL, (*file_bufr)->row_size);
         }
       }
     }  /* end for row */

  if (PDMdebug_on)
    MEMprint_buffer("file buffer", *file_bufr, PDU_DEBUG_FILE);

  if (status == MEM_S_SUCCESS)
    status = PDM_S_SUCCESS;

  return(status);
} /* end PDUcreate_file_buffer_from_refresh */

int PDUupdate_local_column_for_refresh(command, file_bufr, orig_bufr)
  int       command;
  MEMptr    file_bufr;
  MEMptr    orig_bufr;
{
  char      *state = NULL;
  char      *action = NULL;
  char      *catalog = NULL_STRING;
  char      *partid = NULL_STRING;
  char      *revision = NULL_STRING;
  char      *filename = NULL_STRING;
  char      *file = NULL;
  static char *text;
  char      **file_data;
  int       status = PDM_S_SUCCESS;
  int       local_col;
  int       action_col;
  int       file_col;
  int       update_col;
  int       row;
  int       column;
  int       length;
  int       select, pos;
  int       field;
  int       file_row;
  Form      form;
  char      status_list[200];
  short     copied = TRUE;

  _pdm_debug("In the function PDUupdate_local_column_for_refresh", 0);

  form = forms.local_files_form_id;
  field = LIST_MCF;

  if (PDM_debug_on)
    {
    MEMprint_buffer("PDU_parts_list_bufr", PDU_parts_list_bufr, PDU_DEBUG_FILE);
    MEMprint_buffer("file_bufr", file_bufr, PDU_DEBUG_FILE);
    }

  /* set up the parts list buffer */
  MEMbuild_array(PDU_parts_list_bufr);
  status = PDUget_buffer_col(PDU_parts_list_bufr, "p_local", &local_col);
  if (status != PDM_S_SUCCESS)
      return(status);

  status = PDUget_buffer_col(PDU_parts_list_bufr, "p_update", &update_col);
  if (status != PDM_S_SUCCESS)
      return(status);

  /* set up the file list buffer */
  MEMbuild_array(file_bufr);

  status = PDUget_buffer_col(file_bufr, "p_action", &action_col);
  if (status != PDM_S_SUCCESS)
    {
    status = PDM_E_COL_NOT_IN_BUFFER;
    PDUmessage(status, 's');
    return(status);
    }

  status = PDUget_buffer_col(file_bufr, "n_cofilename", &file_col);
  if (status != PDM_S_SUCCESS)
    {
    status = PDM_E_COL_NOT_IN_BUFFER;
    PDUmessage(status, 's');
    return(status);
    }
  PDUsetup_buffer(file_bufr, ROW, &file_data);

  /* set up a buffer for multiple files */
  status = PDUformat_buffer (PDU_PART_FILE_BUFFER, &PDU_part_file_buffer);
  _pdm_status("PDUformat_buffer", status);

  if (status != PDM_S_SUCCESS)
    _pdm_debug("error formatting PDU_part_file_buffer", 0);
  else
    _pdm_debug("PDU_part_file_buffer successfully formatted", 0);

  /* set up a string for the files that were not copied successfully */
  strcpy(status_list, "File(s) <");

  /* set select off for all the rows in the mcf */
  for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
     FImcf_set_select(forms.local_files_form_id, LIST_MCF, row, FALSE);

  /* reset the integer array that points to the rows */
  PDU_parts_index = (int *) malloc (sizeof (int) * PDU_parts_list_bufr->rows);
  memset(PDU_parts_index, -1, sizeof (int) * PDU_parts_list_bufr->rows);
  PDU_selected_rows = 0;

  file_row = 0;
  for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
     {
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

     if ((strcmp(refresh->rev_catalog, catalog) == 0) &&
         (strcmp(refresh->rev_partid, partid) == 0) &&
         (strcmp(refresh->rev_revision, revision) == 0))
       {
/* 2/7/96 MJG - TR 139526084 */
/* Only parent parts will be marked COPIED TO LOCAL.  Child parts will be
   marked ATTACHED.  */

       if (orig_bufr)
         {
         _pdm_debug("check to see if part is in original buffer", 0);
         copied = PDUis_part_in_buffer(catalog, partid, revision, orig_bufr);
         _pdm_debug("PDUis_part_in_buffer returns %d", (char*) copied);
         }
    
       /* get the status from the return buffer */
       PDUfill_in_string(&action, 
                  file_data[(file_bufr->columns * file_row) + action_col]);
       if ((action) && (strcmp(action, "SUCCESS") == 0))
         {
         if (command == DELETE_LOCAL)
           PDUfill_in_string(&state, "DELETED");
         else if (command == COPY_LOCAL)
           {
           if (copied)
             PDUfill_in_string(&state, "COPIED TO LOCAL");
           else
             PDUfill_in_string(&state, "ATTACHED");
           }

         FIfld_set_text(form,field,row,local_col, state,FALSE);
         FIfld_set_text(form,field,row,update_col, "Y",FALSE);
         MEMwrite_data(PDU_parts_list_bufr, state, row + 1, local_col + 1);
         MEMwrite_data(PDU_parts_list_bufr, "Y", row + 1, update_col + 1);

         if (command == COPY_LOCAL)
           {
           /* get the filename from the buffer */
           PDUfill_in_string(&filename,
                    file_data[(file_bufr->columns * file_row) + file_col]);

           /* add a row to the file list buffer */
           status = PDUload_file_buffer_after_copy(NULL, 0, 0, catalog, partid,
                                                     revision, filename);
           _pdm_status("PDUload_file_buffer_after_copy", status);
           if (status != PDM_S_SUCCESS)
             _pdm_debug("failed to load copied parts into buffer", 0);
           }
         }
       else
         {
         if (strcmp(action, "NO_UPDATE") != 0) /* added for copy local */
           {
           _pdm_debug("adding data to the status list", 0);
           if (strlen(status_list) > 9)
             strcat(status_list, ", ");
           PDUfill_in_string(&file,
                     file_data[(file_bufr->columns * file_row) + file_col]);
           strcat(status_list, file);
           }
         }
       ++file_row;

       /* check for multiple files */
       for (row = row + 1; row < PDU_parts_list_bufr->rows; ++row)
          {
          _pdm_debug("row = <%d>", (char *)row);
          FIfld_get_text_length(form, LIST_MCF, row, 0, &length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL_STRING, sizeof (char) * length + 1);
          FIfld_get_text(form, LIST_MCF, row, 0, length, (unsigned char *)text,
                         &select, &pos);
          _pdm_debug("text = <%s>", text);
          if (strcmp(text, "") == 0)
            {
            /* get the status from the return buffer */
            PDUfill_in_string(&action, 
                       file_data[(file_bufr->columns * file_row) + action_col]);
            if ((action) && (strcmp(action, "SUCCESS") == 0))
              {
              if (command == DELETE_LOCAL)
                PDUfill_in_string(&state, "DELETED");
              else if (command == COPY_LOCAL)
                {
                if (copied)
                  PDUfill_in_string(&state, "COPIED TO LOCAL");
                else
                  PDUfill_in_string(&state, "ATTACHED");
                }

              FIfld_set_text(form,field,row,local_col, state,FALSE);
              FIfld_set_text(form,field,row,update_col, "Y",FALSE);
              MEMwrite_data(PDU_parts_list_bufr, state, row + 1, local_col + 1);
              MEMwrite_data(PDU_parts_list_bufr, "Y", row + 1, update_col + 1);

              /* get the filename from the buffer */
              if (command == COPY_LOCAL)
                {
                PDUfill_in_string(&filename,
                       file_data[(file_bufr->columns * file_row) + file_col]);
     
                /* add a row to the file list buffer */
                status = PDUload_file_buffer_after_copy(NULL, 0, 0, catalog,
                                                   partid, revision, filename);
                _pdm_status("PDUload_file_buffer_after_copy", status);
                if (status != PDM_S_SUCCESS)
                  _pdm_debug("failed to load copied parts into buffer", 0);
                }
              }
            else
              {
              if (strcmp(action, "NO_UPDATE") != 0) /* added for copy local */
                {
                _pdm_debug("adding data to the status list", 0);
                if (strlen(status_list) > 9)
                  strcat(status_list, ", ");
                PDUfill_in_string(&file,
                        file_data[(file_bufr->columns * file_row) + file_col]);
                strcat(status_list, file);
                }
              }
            ++file_row;
            }
          else
            {
            _pdm_debug("no more multiple files found", 0);
            break;
            }
          }
       break;
       }
     
     /* clear out the fields */
     catalog = NULL_STRING;
     partid = NULL_STRING;
     revision = NULL_STRING;
     }

  if (strlen(status_list) > 9)
    {
    if (command == DELETE_LOCAL)
      {
      strcat(status_list, "> could not be deleted");
      status = PDM_E_DELETE_FILES;
      if (strlen(status_list) > 200)
        _pdm_debug("SEVERE ERROR: status_list exceeds 200 characters", 0);
      }
    else if (command == COPY_LOCAL)
      {
      strcat(status_list, "> could not be copied to local");
      status = PDM_E_COPY_FILES;
      if (strlen(status_list) > 200)
        _pdm_debug("SEVERE ERROR: status_list exceeds 200 characters", 0);
      }
    FIg_set_text(form, FI_MSG_FIELD, status_list);
    }

  MEMclose(&file_bufr);
  file_bufr = NULL;

  return(status);
}

int PDUprint_refresh()
{
  _pdm_debug("refresh->rev_catalog = <%s>", refresh->rev_catalog);
  _pdm_debug("refresh->rev_partid = <%s>", refresh->rev_partid);
  _pdm_debug("refresh->rev_revision = <%s>", refresh->rev_revision);
  _pdm_debug("refresh->rev_parttype = <%s>", refresh->rev_parttype);
  _pdm_debug("refresh->rev_filename = <%s>", refresh->rev_filename);
  return(PDM_S_SUCCESS);
}

int PDUcreate_delete_buffer()
{
int        char_index;
int        status = PDM_S_SUCCESS;
int        part_status = PDM_S_SUCCESS;
int        row;
int        file_row;
int        column;
int        select;
int        pos;
int        length;
int        load_row;
short      mul_file = FALSE; 
char     * line = NULL;
static char *text;
Form       form;
int        field = 0;
int        ptype_col;
int        file_col;
int        file_col2;
char       *catalog = NULL;
char       *partid = NULL;
char       *revision = NULL;
char       *description = NULL;
char       *filename = NULL;
char       *parttype = NULL;
char       **list_row = NULL;
char       **data_row = NULL;
char       **file_data = NULL;
char     * msg = NULL;
char       invalid_list[256];
MEMptr     file_bufr = NULL;

  _pdm_debug("In the function PDUcreate_delete_buffer", 0);

  form = forms.local_files_form_id;
  if (PDU_mcf_list)
    field = LIST_MCF;
  else if (PDU_structure_list)
    field = STRUCTURE_MCF;

  if (PDU_delete_buffer)
    {
    MEMclose(&PDU_delete_buffer);
    PDU_delete_buffer = NULL;
    }

  if (PDU_part_file_buffer)
    {
    MEMclose(&PDU_part_file_buffer);
    PDU_part_file_buffer = NULL;
    }

  /* create delete buffer */
  status = PDUformat_buffer (PDU_FILE_BUFFER, &PDU_delete_buffer);
  _pdm_status("PDUformat_buffer", status);

  if (status != PDM_S_SUCCESS)
    {
    _pdm_debug("error formatting PDU_delete_buffer", 0);
    PDUmessage(status, 's');
    return(status);
    }

  /* create cancel buffer */
  status = PDUformat_buffer (PDU_PART_FILE_BUFFER, &PDU_part_file_buffer);
  _pdm_status("PDUformat_buffer", status);

  if (status != PDM_S_SUCCESS)
    {
    _pdm_debug("error formatting PDU_part_file_buffer", 0);
    PDUmessage(status, 's');
    return(status);
    }

  _pdm_debug("mallocing space for line", 0);
  line = (char*) malloc (PDU_delete_buffer->row_size);
   
  if (!PDU_parts_list_bufr)
    {
    _pdm_debug("parts list bufr is NULL; using refresh", 0);
    PDUfill_in_string1(&catalog, refresh->rev_catalog);
    PDUfill_in_string1(&partid, refresh->rev_partid);
    PDUfill_in_string1(&revision, refresh->rev_revision);
    PDUfill_in_string1(&description, refresh->rev_description);
    PDUfill_in_string1(&parttype, refresh->rev_parttype);

    _pdm_debug("querying for filenames", 0);
    status = PDMget_filenames(catalog, partid, revision, &file_bufr);
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

    status = PDUget_buffer_col(file_bufr, "n_cofilename", &file_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    PDUsetup_buffer(file_bufr, ROW, &data_row);
  
    for (row = 0; row < file_bufr->rows; ++row)
       {
       _pdm_debug("writing data to buffer", 0);
       memset (line, NULL, PDU_delete_buffer->row_size);
       char_index = 0;

       PDUfill_in_string(&filename, 
                         data_row[(file_bufr->columns * row) + file_col]);
       _pdm_debug("filename = <%s>", filename);

       /* add the n_catalogno and n_itemno columns to the buffer */
       line[char_index++] = '\1';    /* entry for n_catalono */
       line[char_index++] = '\1';    /* entry for n_itemno */
   
       if (catalog && (strlen(catalog)))
         PDUadd_buffer_string(line, &char_index, catalog);
       else
         line[char_index++] = '\1';
   
       if (partid && (strlen(partid)))
         PDUadd_buffer_string(line, &char_index, partid);
       else
         line[char_index++] = '\1';
   
       if (revision && (strlen(revision)))
         PDUadd_buffer_string(line, &char_index, revision);
       else
         line[char_index++] = '\1';
   
       if (filename && (strlen(filename)))
         PDUadd_buffer_string(line, &char_index, filename);
       else
         line[char_index++] = '\1';
   
       if (parttype && (strlen(parttype)))
         PDUadd_buffer_string(line, &char_index, parttype);
       else
         line[char_index++] = '\1';

       line[char_index++] = '\1';    /* entry for p_action */
       _pdm_debug("line = <%s>", line);
       status = MEMwrite (PDU_delete_buffer, line);
    
       if (status != MEM_S_SUCCESS)
         {
         _pdm_debug("Error writing to file buffer", 0);
         _pdm_status("MEMwrite ()", status);
         return(PDM_E_WRITE_BUFFER);
         }
       }

    if (PDMdebug_on)
      MEMprint_buffer("PDU_delete_buffer", PDU_delete_buffer, PDU_DEBUG_FILE);
  
    if (status == MEM_S_SUCCESS)
      status = PDM_S_SUCCESS;

    return(status);
    }

/* 1/5/96 MJG - If using the structure MCF, set up the parts_list_bufr */
  status = MEMbuild_array(PDU_parts_list_bufr);
  _pdm_status("MEMbuild_array", status);
  if (status != MEM_S_SUCCESS)
    return(PDM_E_BUILD_BUFFER_ARRAY);

  PDUsetup_buffer(PDU_parts_list_bufr, ROW, &file_data);
  status = PDUget_buffer_col(PDU_parts_list_bufr, "n_cofilename", &file_col2);
  if (status != PDM_S_SUCCESS)
    return(status);
/* END setup buffer */

  invalid_list[0] = '\0';

  _pdm_debug("loading parts from MCF", 0);
  for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
     {
     _pdm_debug("resetting part variables", 0);
     catalog = NULL_STRING;
     partid = NULL_STRING;
     revision = NULL_STRING;
     description = NULL_STRING;
     filename = NULL_STRING;

     mul_file = FALSE;
     load_row = TRUE;

     if (PDU_parts_index[row] != -1)
       {
       for (column = 0; column <= 5; ++column)
          {
          _pdm_debug("getting part information", 0);
          FIfld_get_text_length(form, field, row, column, &length);
          text = (char *) malloc (sizeof (char) * length + 1);
          memset(text, NULL, sizeof (char) * length + 1);
          FIfld_get_text(form, field, row, column, length, 
                          (unsigned char *)text,&select,&pos);
          _pdm_debug("text = <%s>", text);

          if ((strcmp(text, "") == 0) && (column == 1))
            {
            mul_file = TRUE;
            load_row = FALSE;
            continue;
            }

/* 1/5/96 MJG - TR 139528280 - Need separate cases for LIST and STRUCTURE MCFs.  Added case for structure mcf */

          if (PDU_mcf_list)
            {
            if ((column == 0) && (strcmp(text, "") != 0))
               PDUfill_in_string(&catalog, text);
  
            else if ((column == 1) && (strcmp(text, "") != 0))
               PDUfill_in_string(&partid, text);
  
            else if ((column == 2) && (strcmp(text, "") != 0))
               PDUfill_in_string(&revision, text);
  
            else if ((column == 5) && (strcmp(text, "") != 0))
               PDUfill_in_string(&filename, text);
  
            else if ((column == 3) && (strcmp(text, "") != 0))
               PDUfill_in_string(&description, text);
            }
          else if (PDU_structure_list)
            {
            if ((column == 1) && (strcmp(text, "") != 0))
               PDUfill_in_string(&catalog, text);
  
            else if ((column == 2) && (strcmp(text, "") != 0))
               PDUfill_in_string(&partid, text);
  
            else if ((column == 3) && (strcmp(text, "") != 0))
               PDUfill_in_string(&revision, text);
  
            else if ((column == 4) && (strcmp(text, "") != 0))
               PDUfill_in_string(&description, text);
   
            }

          PDUfree_string(&text);
          }  /* end for column */

       if (PDU_structure_list)
         {
         _pdm_debug("getting filename from bufr for structure MCF", 0);
         PDUfill_in_string(&filename, file_data[(PDU_parts_list_bufr->columns * 
                           row) + file_col2]);
         _pdm_debug("filename = <%s>", filename);
         }

       if (load_row == FALSE)
         continue;

       if (mul_file == FALSE) /* part is not a multiple file */
         {
         /* get the parttype */
         _pdm_debug("updating parttype", 0);
         MEMbuild_array(PDU_parts_list_bufr);
         PDUsetup_buffer(PDU_parts_list_bufr,ROW, &list_row);
         status=PDUget_buffer_col(PDU_parts_list_bufr,"p_parttype",&ptype_col);
         if (status != PDM_S_SUCCESS)
           return(status);

         PDUfill_in_string(&parttype,
              list_row[(PDU_parts_list_bufr->columns * row) + ptype_col]);
         _pdm_debug("parttype = <%s>", parttype);
  
         /* get the status of the part */
         part_status = PDMrcheck_part_status(catalog, partid, revision);
         _pdm_status("PDMrcheck_part_status", part_status);
         }
   
         if (part_status == PDM_I_COPIED_TO_LOCAL_BY_YOU)
           {
           /* reset load_row to TRUE if part has been copied; all copied parts
              get loaded into the delete_buffer, unless the local file cannot
              be verified */
           if (mul_file == FALSE)
             load_row = TRUE;
  
/*
           FIfld_get_text_length(form, field, row, 5, &length);
           text = (char *) malloc (sizeof (char) * length + 1);
           memset(text, NULL, sizeof (char) * length + 1);
           FIfld_get_text(form, field, row, 5, length, 
                          (unsigned char *)text,&select,&pos);
           _pdm_debug("filename = <%s>", text);
  
           PDUfill_in_string(&filename, text);
           PDUfree_string(&text);
*/
  
           /* make sure the file is local */
           status = PDUverify_file(filename);
           _pdm_status("PDUverify_file", status);
  
           if (status != PDM_S_SUCCESS)  /* file was not found */
             {
             msg = (char *) PDUtranslate_message_and_vars(PDM_E_FILE_NOT_LOCAL,
                                                         filename);
             FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, msg);
             PDUfill_in_string(&PDU_save_filename, filename);
             status = PDM_E_FILE_NOT_LOCAL;
             PDUmessage(PDM_E_FILE_NOT_LOCAL, 's');
             load_row = FALSE;
             }
           }
         else if ((part_status == PDM_I_CHECKED_OUT_BY_YOU) && 
                  (mul_file == FALSE))
           {
           _pdm_debug("bypassing row %d", (char *)PDU_parts_index[row]);
           PDU_parts_index[row] = PDU_parts_index[row] + 10000;
           load_row = FALSE;
  
           /* call function to load this row into cancel checkout buffer */
           status = PDUload_file_buffer(catalog, partid, revision, 
                                        description, filename);
           _pdm_status("PDUload_file_buffer", status);
           if (status != PDM_S_SUCCESS)
             _pdm_debug("failed to load file buffer for cancel checkout", 0);
           }
         else
           {
           _pdm_debug("invalid part status", 0);
           load_row = FALSE;
           if (!strlen(invalid_list))
             {
             strcpy(invalid_list, "The following files have an invalid status for deletion: ");
             }
           strcat(invalid_list, " ");
           strcat(invalid_list, filename);

           if (strlen(invalid_list) > 255)
             _pdm_debug("SEVERE ERROR:  invalid_list exceeded 255 characters", 0);

           PDU_parts_index[row] = -99;
           }

       if (load_row == FALSE)
         continue;

       _pdm_debug("querying for filenames", 0);
       MEMclose(&file_bufr);
       file_bufr = NULL;
       status = PDMget_filenames(catalog, partid, revision, &file_bufr);
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

       status = PDUget_buffer_col(file_bufr, "n_cofilename", &file_col);
       if (status != PDM_S_SUCCESS)
         return(status);

       PDUsetup_buffer(file_bufr, ROW, &data_row);
  
       for (file_row = 0; file_row < file_bufr->rows; ++file_row)
         {
         _pdm_debug("writing data to buffer", 0);
         memset (line, NULL, PDU_delete_buffer->row_size);
         char_index = 0;
  
         PDUfill_in_string(&filename, 
                       data_row[(file_bufr->columns * file_row) + file_col]);
         _pdm_debug("filename = <%s>", filename);

         /* add the n_catalogno and n_itemno columns to the buffer */
         line[char_index++] = '\1';    /* entry for n_catalono */
         line[char_index++] = '\1';    /* entry for n_itemno */

         if (catalog && (strlen(catalog)))
           PDUadd_buffer_string(line, &char_index, catalog);
         else
           line[char_index++] = '\1';

         if (partid && (strlen(partid)))
           PDUadd_buffer_string(line, &char_index, partid);
         else
           line[char_index++] = '\1';

         if (revision && (strlen(revision)))
           PDUadd_buffer_string(line, &char_index, revision);
         else
           line[char_index++] = '\1';

         if (filename && (strlen(filename)))
           PDUadd_buffer_string(line, &char_index, filename);
         else
           line[char_index++] = '\1';

         if (parttype && (strlen(parttype)))
           PDUadd_buffer_string(line, &char_index, parttype);
         else
           line[char_index++] = '\1';

         line[char_index++] = '\1';    /* entry for p_action */
         _pdm_debug("line = <%s>", line);
         status = MEMwrite (PDU_delete_buffer, line);
  
         if (status != MEM_S_SUCCESS)
           {
           _pdm_debug("Error writing to file buffer", 0);
           _pdm_status("MEMwrite ()", status);
           return(PDM_E_WRITE_BUFFER);
           }
         }
       }  /* end if */

     }  /* end for row */
  if (PDMdebug_on)
    MEMprint_buffer("PDU_delete_buffer", PDU_delete_buffer, PDU_DEBUG_FILE);

  if (status == MEM_S_SUCCESS)
    status = PDM_S_SUCCESS;

  _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);

  if (invalid_list && (strlen(invalid_list)))
    {
    _pdm_debug("invalid_list = <%s>", invalid_list);
    FIg_set_text(form, FI_MSG_FIELD, invalid_list);
    }

  return(status);
} /* end PDUcreate_delete_buffer */

int PDUextract_row_from_buffer(return_buffer, in_bufr, f_row)
MEMptr    *return_buffer;
MEMptr    in_bufr;
int       f_row;
{
int     status = PDM_S_SUCCESS;
int	cat_col;
int	part_col;
int     rev_col;
int     file_col;
int     type_col;
int     char_index;
int     row;
char    *catalog = NULL;
char    *partid = NULL;
char    *revision = NULL;
char    *filename = NULL;
char    *parttype = NULL;
char    *line = NULL;
char    **data_row;
MEMptr  file_bufr = NULL;

  _pdm_debug("In the function PDUextract_row_from_buffer", 0);

  /* set up the return buffer */
  status = PDUformat_buffer (PDU_FILE_BUFFER, return_buffer);
  _pdm_status("PDUformat_buffer", status);

  if (status != PDM_S_SUCCESS)
    {
    _pdm_debug("error formatting return_buffer", 0);
    PDUmessage(status, 's');
    return(status);
    }

  /* access the in_bufr */
  if ((in_bufr != NULL) && (in_bufr->rows > 0))
    {
    MEMbuild_array(in_bufr);
    status = PDUget_buffer_col(in_bufr, "n_catalogname", &cat_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    status = PDUget_buffer_col(in_bufr, "n_itemname", &part_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    status = PDUget_buffer_col(in_bufr, "n_itemrev", &rev_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    status = PDUget_buffer_col(in_bufr, "n_cofilename", &file_col);
    if (status != PDM_S_SUCCESS)
      return(status);
  
    status = PDUget_buffer_col(in_bufr, "p_parttype", &type_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    PDUsetup_buffer(in_bufr, ROW, &data_row);

    _pdm_debug("reading part info from buffer", 0);
    PDUfill_in_string(&catalog, 
                 data_row[(in_bufr->columns * f_row) + cat_col]);
    PDUfill_in_string(&partid, 
                 data_row[(in_bufr->columns * f_row) + part_col]);
    PDUfill_in_string(&revision, 
                 data_row[(in_bufr->columns * f_row) + rev_col]);
    PDUfill_in_string(&parttype, 
                 data_row[(in_bufr->columns * f_row) + type_col]);
    }
  else
    {
    _pdm_debug("no rows in in_bufr!!!", 0);
    return(PDM_E_DELETE_LIST_EMPTY);
    }

  _pdm_debug("checking for multiple files", 0);
  status = PDMget_filenames(catalog, partid, revision, &file_bufr);
  _pdm_status("PDMget_filenames", status);

  if ((file_bufr) && (file_bufr->rows > 0))
    {
    MEMbuild_array(file_bufr);
    PDUsetup_buffer(file_bufr, ROW, &data_row);
    status = PDUget_buffer_col(file_bufr, "n_cofilename", &file_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    line = (char*) malloc ((*return_buffer)->row_size);

    for (row = 0; row < file_bufr->rows; ++row)
       {
       char_index = 0;
       memset (line, NULL, (*return_buffer)->row_size);

       PDUfill_in_string(&filename, 
                         data_row[(file_bufr->columns * row)+file_col]);

       /* add the n_catalogno and n_itemno columns to the buffer */
       line[char_index++] = '\1';    /* entry for n_catalono */
       line[char_index++] = '\1';    /* entry for n_itemno */
     
       if (catalog && (strlen(catalog)))
         PDUadd_buffer_string(line, &char_index, catalog);
       else
         line[char_index++] = '\1';
     
       if (partid && (strlen(partid)))
         PDUadd_buffer_string(line, &char_index, partid);
       else
         line[char_index++] = '\1';
     
       if (revision && (strlen(revision)))
         PDUadd_buffer_string(line, &char_index, revision);
       else
         line[char_index++] = '\1';
     
       if (filename && (strlen(filename)))
         PDUadd_buffer_string(line, &char_index, filename);
       else
         line[char_index++] = '\1';
     
       if (parttype && (strlen(parttype)))
         PDUadd_buffer_string(line, &char_index, parttype);
       else
         line[char_index++] = '\1';
   
       line[char_index++] = '\1';    /* entry for p_action */
       _pdm_debug("line = <%s>", line);
       status = MEMwrite (*return_buffer, line);
   
       if (status != MEM_S_SUCCESS)
         {
         _pdm_debug("Error writing to return_buffer", 0);
         _pdm_status("MEMwrite ()", status);
         }
       else
         status = PDM_S_SUCCESS;
       }
    }
   
  free(line);

  PDUfill_in_string(&refresh->rev_catalog, catalog);
  PDUfill_in_string(&refresh->rev_partid, partid);
  PDUfill_in_string(&refresh->rev_revision, revision);
  PDUfill_in_string(&refresh->rev_filename, filename);
  PDUfill_in_string(&refresh->rev_parttype, parttype);
  PDUfill_in_string(&refresh->rev_description, "");

  /* copy current refresh information into form fields */
  FIfld_set_text(forms.local_files_form_id, CATALOG_FLD, 0, 0, 
                 refresh->rev_catalog, FALSE);
  FIfld_set_text(forms.local_files_form_id, PARTNUM_FLD, 0, 0, 
                 refresh->rev_partid, FALSE);
  FIfld_set_text(forms.local_files_form_id, PART_REV_FLD, 0, 0, 
                 refresh->rev_revision, FALSE);
  FIfld_set_text(forms.local_files_form_id, PART_DESC_FLD, 0, 0, 
                 refresh->rev_description, FALSE);
  FIfld_set_text(forms.local_files_form_id, PART_FILE_FLD, 0, 0, 
                 refresh->rev_filename, FALSE);

  return(status);
}

int PDUcheckout_structure( command, type)
char   *command;
int    type;
{
char         **list_row;
char         *msg = NULL;
char         *catalog = NULL;
char         *partid = NULL;
char         *revision = NULL;
int          row = 0;
int          status = PDM_S_SUCCESS;
int          cat_col;
int          part_col;
int          rev_col;
int          desc_col;
int          file_col;
int          type_col;
int          field;
int          index = 0;
int          column = 0;
int          length, select, pos;
MEMptr       buffer = NULL;
Form         form;
static char  *text = NULL;

  _pdm_debug("in the function PDUcheckout_structure", 0);

  if ((PDU_parts_list_bufr != NULL) && (PDU_parts_list_bufr->rows > 0))
    {
    MEMbuild_array(PDU_parts_list_bufr);
    status = PDUget_buffer_col(PDU_parts_list_bufr, "n_catalogname", &cat_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    status = PDUget_buffer_col(PDU_parts_list_bufr, "n_itemname", &part_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    status = PDUget_buffer_col(PDU_parts_list_bufr, "n_itemrev", &rev_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    status = PDUget_buffer_col(PDU_parts_list_bufr, "n_itemdesc", &desc_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    status = PDUget_buffer_col(PDU_parts_list_bufr, "n_cofilename", &file_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    status = PDUget_buffer_col(PDU_parts_list_bufr, "p_parttype", &type_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    PDUsetup_buffer(PDU_parts_list_bufr, ROW, &list_row);
    }

  /* Check the refresh for a partid and filename, and check to see if the 
     listing area is populated */

  if (((refresh->rev_partid == NULL)            ||
       (strcmp(refresh->rev_partid, "") == 0)   ||
       (refresh->rev_filename == NULL)          ||
       (strcmp(refresh->rev_filename, "") == 0)) &&
       (PDU_selected_rows == 0))
    {
    if ((refresh->rev_partid == NULL) ||
        (strcmp(refresh->rev_partid, "") == 0))
      {
      _pdm_debug("User depressed <%s> button w/o selecting a part", command);
      msg = (char *) PDUtranslate_message(PDM_I_ENTER_PART);
      FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, msg);
      }
    else if ((refresh->rev_filename == NULL) ||
             (strcmp(refresh->rev_filename, "") == 0))
      {
      _pdm_debug("User depressed <%s> button w/o entering a filename", command);
      msg = (char *) PDUtranslate_message(PDM_E_ENTER_FILENAME);
      FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, msg);
      }
    }

      _pdm_debug("performing <%s> on parts in the part listing area", command);
      FIg_set_text(forms.local_files_form_id, FI_MSG_FIELD, NULL_STRING);
      _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);

      for (row = PDU_parts_list_bufr->rows - 1; row >= 0; --row)
         {
         if ((PDU_parts_index[row] != -1) && (PDU_parts_index[row] != -99))
          {
          _pdm_debug("accessing PDU_parts_list_bufr", 0);
          MEMbuild_array(PDU_parts_list_bufr);
          PDUsetup_buffer(PDU_parts_list_bufr, ROW, &list_row);

          _pdm_debug("updating refresh", 0);
          _pdm_debug("old refresh->rev_catalog = <%s>", refresh->rev_catalog);
          _pdm_debug("old refresh->rev_partid = <%s>", refresh->rev_partid);
          _pdm_debug("old refresh->rev_revision = <%s>", refresh->rev_revision);
          _pdm_debug("old refresh->rev_description = <%s>", refresh->rev_description);
          _pdm_debug("old refresh->rev_filename = <%s>", refresh->rev_filename);

          if (!refresh->rev_catalog)
            refresh->rev_catalog = NULL_STRING;
          if (!refresh->rev_partid)
            refresh->rev_partid = NULL_STRING;
          if (!refresh->rev_revision)
            refresh->rev_revision = NULL_STRING;
          if (!refresh->rev_description)
            refresh->rev_description = NULL_STRING;
          if (!refresh->rev_filename)
            refresh->rev_filename = NULL_STRING;
          if (!refresh->rev_parttype)
            refresh->rev_parttype = NULL_STRING;

          PDUfill_in_string(&refresh->rev_catalog, 
            list_row[(PDU_parts_list_bufr->columns * row) + cat_col]);
          PDUfill_in_string(&refresh->rev_partid, 
            list_row[(PDU_parts_list_bufr->columns * row) + part_col]);
          PDUfill_in_string(&refresh->rev_revision,
            list_row[(PDU_parts_list_bufr->columns * row) + rev_col]);
          PDUfill_in_string(&refresh->rev_filename,
            list_row[(PDU_parts_list_bufr->columns * row) + file_col]);
          PDUfill_in_string(&refresh->rev_description,
            list_row[(PDU_parts_list_bufr->columns * row) + desc_col]);
          PDUfill_in_string(&refresh->rev_parttype,
            list_row[(PDU_parts_list_bufr->columns * row) + type_col]);

          _pdm_debug("after updating refresh", 0);
          _pdm_debug("new refresh->rev_catalog = <%s>", refresh->rev_catalog);
          _pdm_debug("new refresh->rev_partid = <%s>", refresh->rev_partid);
          _pdm_debug("new refresh->rev_revision = <%s>", refresh->rev_revision);
          _pdm_debug("new refresh->rev_description = <%s>", refresh->rev_description);
          _pdm_debug("new refresh->rev_filename = <%s>", refresh->rev_filename);

          /* copy current refresh information into form fields */
          _pdm_debug("updating form fields", 0);
          FIfld_set_text(forms.local_files_form_id, CATALOG_FLD, 0, 0, 
                         refresh->rev_catalog, FALSE);
          FIfld_set_text(forms.local_files_form_id, PARTNUM_FLD, 0, 0, 
                         refresh->rev_partid, FALSE);
          FIfld_set_text(forms.local_files_form_id, PART_REV_FLD, 0, 0, 
                         refresh->rev_revision, FALSE);
          FIfld_set_text(forms.local_files_form_id, PART_DESC_FLD, 0, 0, 
                         refresh->rev_description, FALSE);
          FIfld_set_text(forms.local_files_form_id, PART_FILE_FLD, 0, 0, 
                         refresh->rev_filename, FALSE);
          switch (type)
           {
           case  CHECKOUT:
                 _pdm_debug("entering case for checkout", 0);
                 status = PDUext_checkout();
                 _pdm_status("PDUext_checkout", status);

                 if ((status == PDM_E_PART_CHECKED_OUT) &&
                     (PDU_command == PDC_M_CHECKOUT_ACTIVATE))
                   {
                   _pdm_debug("calling PDUload_file_buffer", 0);
                   status = PDUload_file_buffer(refresh->rev_catalog,
                              refresh->rev_partid, refresh->rev_revision,
                              refresh->rev_description, "");
                   _pdm_status("PDUload_file_buffer", status);
                   if (status != PDM_S_SUCCESS)
                     _pdm_debug("failed to load file buffer after checkout", 0);
                   status = PDM_S_SUCCESS;
                   }

                 if (((status == PDM_E_PART_CHECKED_OUT) ||
                      (status == PDM_S_SUCCESS)) && (PDU_structure_list))
                   FImcf_set_select(forms.local_files_form_id, STRUCTURE_MCF,
                                    row, FALSE);

                 break;

           default:
                 _pdm_debug("entered default case", 0);
                 break;
           }

          _pdm_debug("check for other rows with the same part", 0);
          form = forms.local_files_form_id;
          field = STRUCTURE_MCF;
          for (index = 0; index < PDU_parts_list_bufr->rows; ++index)
             {
             for (column = 1; column < 4; ++column)
                {
                FIfld_get_text_length(form, field, index, column, &length);
                text = (char *) malloc (sizeof (char) * length + 1);
                memset(text, NULL, sizeof (char) * length + 1);
                FIfld_get_text(form, field, index, column, length,
                              (unsigned char *)text, &select, &pos);

                if (column == 1) PDUfill_in_string(&catalog, text);
                else if (column == 2) PDUfill_in_string(&partid, text);
                else if (column == 3) PDUfill_in_string(&revision, text);
                PDUfree_string(&text);

                if ((refresh->rev_catalog) &&
                    (refresh->rev_partid)  &&
                    (refresh->rev_revision) &&
                    (catalog) && (partid) && (revision) &&
                    (strcmp(refresh->rev_catalog, catalog) == 0) &&
                    (strcmp(refresh->rev_partid, partid) == 0) &&
                    (strcmp(refresh->rev_revision, revision) == 0))
                  {
                  _pdm_debug("another instance of part was found", 0);
                  if (PDU_parts_index[index] != -1)
                    {
                    FImcf_set_select(form, field, index, FALSE);
                    PDU_parts_index[index] = -1;
                    PDU_selected_rows = PDU_selected_rows - 1;
                    }
                  }
                }
             }
          }
         }

  return(status);
}
