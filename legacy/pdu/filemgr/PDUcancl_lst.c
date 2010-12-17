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


/* Gadgets */

#define CANCEL_LIST_MCF          16

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
extern short PDU_cancel_list_displayed;
extern short PDU_cancel_list_created;
extern MEMptr  PDU_part_file_buffer;
extern MEMptr  PDU_parts_list_bufr;
extern struct  PDUrefresh *refresh;
extern struct  PDUforms forms;
extern char    ***PDU_update_struct;
extern int     *PDU_gadget_labels;
extern short   PDU_second_row;
extern short   PDU_perm_window;
extern short   PDU_local_perm_window;
extern int     *PDU_parts_index;
extern int     PDU_selected_rows;
extern int     PDM_debug_on;
extern int     PDU_command;
extern int     PDU_mcf_list;


int cancel_list_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  int           status = PDM_S_SUCCESS;
  int		act_row;
  int		act_pos;
  int		column, row;
  int           length;
  int		mcf_select = FALSE;
  int           select, pos;
  static char   *text;
  char          *catalog = NULL;
  char          *partid = NULL;
  char          *revision = NULL;
  char          *filename = NULL;
  char          *cancel_catalog = NULL;
  char          *cancel_partid = NULL;
  char          *cancel_revision = NULL;
  char          *cancel_description = NULL;
  char          *cancel_filename = NULL;
  short         row_found = FALSE;


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
         FIf_cvrt_to_perm_win(forms.cancel_list_form_id);
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
	 PDU_cancel_list_displayed = FALSE;
         FIf_delete ( fp );
	 PDU_cancel_list_created = FALSE;

         FIf_display(forms.local_files_form_id);

	 status = PDM_E_CMD_CANCELLED;
	 PDUmessage(status, 's');

         break;

    case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */

          /* Process form data */

          /* Erase the displayed form */
         FIf_erase ( fp );
	 PDU_cancel_list_displayed = FALSE;
         FIf_delete ( fp );
	 PDU_cancel_list_created = FALSE;

         FIf_display(forms.local_files_form_id);

	 PDUmessage(PDC_M_CANCEL_CHECKOUT, 'c');

         /* call the cancel checkout function */
         _pdm_debug("before PDUcancel_checkout, PDU_selected_rows = %d",
                    (char *)PDU_selected_rows);
         if (PDU_selected_rows > 0)
           {
           /* if the parts list is listed, check to see if any rows are
              selected */
           if ((PDU_parts_list_bufr) && (PDU_mcf_list))
             {
             row_found = FALSE;
 
             for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
                if (PDU_parts_index[row] != -1)
                  row_found = TRUE;
       
             if (row_found == FALSE)
               {
               _pdm_debug("resetting PDU_selected_rows; no rows selected", 0);
               PDU_selected_rows = 0;
               }
             }

           if ((!PDU_parts_list_bufr) || (!PDU_mcf_list))
             {
             _pdm_debug("resetting PDU_selected_rows because list is empty", 0);
             PDU_selected_rows = 0;
             }
           status = PDUcancel_checkout();
           _pdm_status("PDUcancel_checkout", status);
           }
         else
           {
           _pdm_debug("no rows selected", 0);
           status = PDM_E_CMD_CANCELLED;
           }
  
         PDUmessage(status, 's');

         /* reset the rows in the mcf */
         _pdm_debug("resetting parts mcf", 0);
         if (PDU_parts_list_bufr && PDU_mcf_list)
           {
           for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
              {
              if ((PDU_parts_index[row] != -99) &&
                  (PDU_parts_index[row] != -1))
                {
                FImcf_set_select(forms.local_files_form_id,LIST_MCF,row,FALSE);
                --PDU_selected_rows;
                }
              else if (PDU_parts_index[row] != -1)
                ++PDU_selected_rows;
              }
           }
         _pdm_debug("PDU_selected_rows = %d", (char *)PDU_selected_rows);

         if (PDU_selected_rows > 0)
           PDUmessage(PDM_E_FILE_NOT_DELETED, 's');

         break;

    case CANCEL_LIST_MCF: 

	 FIfld_get_active_row(fp, CANCEL_LIST_MCF, &act_row, &act_pos);
         FImcf_set_active_col(fp, CANCEL_LIST_MCF, 0, 0);
         FIfld_get_select(fp, CANCEL_LIST_MCF, act_row, 0, &mcf_select);

         /* loop through columns in mcf to get data selected */
         for (column = 0; column < 5; ++column)
            {
            FImcf_set_active_col( fp, CANCEL_LIST_MCF, column, column);
            FIfld_get_text_length(fp,CANCEL_LIST_MCF,act_row,column,&length);
            text = (char *) malloc (sizeof (char) * length + 1);
            memset(text, NULL, sizeof (char) * length + 1);
            FIfld_get_text(fp,CANCEL_LIST_MCF,act_row,column,length,
                          (unsigned char *)text, &select,&pos);

            /* update the structure */
            switch (column)
              {
              case 0:
                   PDUfill_in_string(&cancel_catalog, text);
                   _pdm_debug("cancel_catalog = <%s>", cancel_catalog);
                   break;
              case 1:
                   PDUfill_in_string(&cancel_partid, text);
                   _pdm_debug("cancel_part num = <%s>", cancel_partid);
                   break;
              case 2:
                   PDUfill_in_string(&cancel_revision, text);
                   _pdm_debug("cancel_revision = <%s>", cancel_revision);
                   break;
              case 3:
                   PDUfill_in_string(&cancel_description,text);
                   _pdm_debug("description = <%s>", cancel_description);
                   break;
              case 4:
                   PDUfill_in_string(&cancel_filename,text);
                   _pdm_debug("cancel_filename = <%s>", cancel_filename);
                   break;
              }
            }  /* end for column */

       if (PDU_parts_list_bufr && PDU_mcf_list)
         {
         if (mcf_select == FALSE)
           {
           /* find the equivalent row in the parts list and deselect it */
	   _pdm_debug("looking for matching row in parts list", 0);
	   for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
              {
              if (PDU_parts_index[row] != -1)
                {
		/* get the part information for that row */
                for (column = 0; column < 6; ++column)
                   {
		   FIfld_get_text_length(forms.local_files_form_id, LIST_MCF, 
                                         row, column, &length);
                   text = (char *) malloc (sizeof (char) * length + 1);
                   memset(text, NULL, sizeof (char) * length + 1);
                   FIfld_get_text(forms.local_files_form_id, LIST_MCF, row, 
                         column, length, (unsigned char *)text,&select,&pos);
                   _pdm_debug("text = <%s>", text);

                   switch (column)
                     {
                     case 0:
                       PDUfill_in_string(&catalog, text);
		       _pdm_debug("catalog = <%s>", catalog);
                       break;
                     case 1:
                       PDUfill_in_string(&partid, text);
		       _pdm_debug("partid = <%s>", partid);
                       break;
                     case 2:
                       PDUfill_in_string(&revision, text);
		       _pdm_debug("revision = <%s>", revision);
                       break;
                     case 5:
		       PDUfill_in_string(&filename, text);
		       _pdm_debug("filename = <%s>", filename);
                       break;
                     }
                   }
            
                if ((strcmp(catalog, cancel_catalog) == 0) &&
                    (strcmp(partid, cancel_partid) == 0) &&
                    (strcmp(revision, cancel_revision) == 0) &&
                    (strcmp(filename, cancel_filename) == 0))
                  {
                  /* unmark that row in the mcf */
                  _pdm_debug("matching row found in parts list", 0);
                  _pdm_debug("unmarking row in parts list", 0);
                  PDU_parts_index[row] = -1;
                  FImcf_set_select(forms.local_files_form_id, LIST_MCF,
	                           row, FALSE);
                  PDU_selected_rows = PDU_selected_rows - 1;
                  _pdm_debug("PDU_selected_rows = %d", 
                              (char *)PDU_selected_rows);
                  break;
                  }
                }
              }
           } 
         else
           {
           /* find the equivalent row in the parts list and reselect it */
	   _pdm_debug("looking for matching row in parts list", 0);
	   for (row = 0; row < PDU_parts_list_bufr->rows; ++row)
              {
	      /* get the part information for that row */
              for (column = 0; column < 6; ++column)
                 {
	         FIfld_get_text_length(forms.local_files_form_id, LIST_MCF, 
                                         row, column, &length);
                 text = (char *) malloc (sizeof (char) * length + 1);
                 memset(text, NULL, sizeof (char) * length + 1);
                 FIfld_get_text(forms.local_files_form_id, LIST_MCF, row, 
                         column, length, (unsigned char *)text,&select,&pos);
                 _pdm_debug("text = <%s>", text);

                 switch (column)
                   {
                   case 0:
                     PDUfill_in_string(&catalog, text);
		     _pdm_debug("catalog = <%s>", catalog);
                     break;
                   case 1:
                     PDUfill_in_string(&partid, text);
		     _pdm_debug("partid = <%s>", partid);
                     break;
                   case 2:
                     PDUfill_in_string(&revision, text);
		     _pdm_debug("revision = <%s>", revision);
                     break;
                   case 5:
		     PDUfill_in_string(&filename, text);
		     _pdm_debug("filename = <%s>", filename);
                     break;
                   }
                 }
            
              if ((strcmp(catalog, cancel_catalog) == 0) &&
                  (strcmp(partid, cancel_partid) == 0) &&
                  (strcmp(revision, cancel_revision) == 0) &&
                  (strcmp(filename, cancel_filename) == 0))
                {
                /* remark that row in the mcf */
                _pdm_debug("matching row found in parts list", 0);
                _pdm_debug("marking row in parts list", 0);
                PDU_parts_index[row] = row;
                FImcf_set_select(forms.local_files_form_id, LIST_MCF,
                                 row, TRUE);
                PDU_selected_rows = PDU_selected_rows + 1;
                       _pdm_debug("PDU_selected_rows = %d", 
                                   (char *)PDU_selected_rows);
                break;
                }
              }
           }
         }

         break;

  } /* END switch ( g_label ) */

  return(1);

} /* END notification_routine() */

int PDUcancel_list_form()
{
  int           sts = PDM_S_SUCCESS;
  int           all_flag = FALSE;
  int           no_headings;
  int           row;
  char          **headings;
  char          *msg_str = NULL;

  if (PDU_cancel_list_created == TRUE)
    return(PDM_S_SUCCESS);

  PDU_cancel_list_created = FALSE;
  PDU_cancel_list_displayed = FALSE;

  /* load the buffer into the form */
  if (PDM_debug_on)
    MEMprint_buffer("cancel buffer", PDU_part_file_buffer, PDU_DEBUG_FILE);

  sts = FIf_new(CANCEL_LIST_FORM, "cancel_list",
                cancel_list_notification_routine,
                &forms.cancel_list_form_id);

  _pdm_debug("Creating cancel_list form", 0);
  PDU_cancel_list_created = TRUE;

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
  PDUbufr_to_mcf(PDU_part_file_buffer, forms.cancel_list_form_id, 
                 CANCEL_LIST_MCF);

  FIfld_set_num_rows(forms.cancel_list_form_id, CANCEL_LIST_MCF,
                     PDU_part_file_buffer->rows);

  msg_str = (char *)PDUtranslate_message(PDM_I_CHECKOUT_CANCEL_HIGH);
  FIfld_set_active_row(forms.cancel_list_form_id, CANCEL_LIST_MCF, 0, 0);
  FIg_set_text(forms.cancel_list_form_id, FI_PROMPT_FIELD,msg_str);

  /* highlight all the rows in the field */
  for (row = 0; row < PDU_part_file_buffer->rows; ++row)
     FImcf_set_select(forms.cancel_list_form_id, CANCEL_LIST_MCF, row, TRUE);
  PDU_selected_rows = PDU_part_file_buffer->rows;

/*
  if ((PDU_local_perm_window == TRUE) || (PDM_debug_on))
    {
    _pdm_debug("converting form to permanent window", 0);
    FIf_cvrt_to_perm_win(forms.cancel_list_form_id);
    }

    FIf_cvrt_to_perm_win(forms.local_files_form_id);
    PDU_local_perm_window = TRUE;
    FIf_cvrt_to_perm_win(forms.cancel_list_form_id);
*/

  FIf_erase(forms.local_files_form_id);

  /* display the form */
  FIf_display(forms.cancel_list_form_id);
#ifdef sparc
  PDUpaint_form(forms.cancel_list_form_id);
#endif
  PDU_cancel_list_displayed = TRUE;

  return(PDM_S_SUCCESS);
}
