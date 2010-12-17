#include <stdio.h>
#include "FI.h"
#include "tools.h"
#include "PDUfile_def.h"
#include "PDUstr.h"
#include <PDUforms.h>
#include <PDUform_def.h>
#include "PDUerror.h"
#include "PDUintdef.h"
#include "MEMstruct.h"
#include "PDUproto.h"
#include "PDMproto.h"


/* Gadgets */

#define LISTING_FLD        11
#define CANCEL_BTN         12


/* Externs */

extern struct   PDUforms      forms;
extern struct   PDUrefresh    *refresh;
extern int      PDU_file_list_created;
extern int      PDU_file_list_displayed;
extern char     **PDU_file_list;
extern short    PDU_second_row;
extern short    PDU_perm_window;
extern int      PDU_file_rows;

int file_list_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  int             status = PDM_S_SUCCESS;
  int             count;
  int             row;
  int             length;
  int             select, pos;
  int             mcf_select = FALSE;
  int             num_rows;
  static char     *text;
  
  switch ( g_label )
  {
    case LISTING_FLD:         /* Field Type:    ASCII    */
 	 f_label = 0;
	 value = 0.0;

        break;

    case FI_CANCEL:     

         PDU_file_list = (char **) malloc (sizeof (char *) * 1);
         memset(PDU_file_list, NULL, sizeof (char *) * 1);
         PDU_file_list[0] = NULL;

         if (PDU_file_list_displayed == TRUE)
           {
           FIf_erase ( fp );
           PDU_file_list_displayed = FALSE;
           }

         if (PDU_file_list_created == TRUE)
           FIf_delete ( fp );

         break;

    case FI_ACCEPT:     

         /* check to see if any rows have been selected in the field */
         FIfld_get_num_rows(fp, LISTING_FLD, &num_rows);

         PDU_file_list = (char **) malloc (sizeof (char *) * num_rows);
         memset(PDU_file_list, NULL, sizeof (char *) * num_rows);

         count = 0;
         for (row = 0; row < num_rows; ++row)
            {
            FIfld_get_select(fp, LISTING_FLD, row, 0, &mcf_select);
            if (mcf_select == TRUE)
              {
              FIfld_get_text_length(fp, LISTING_FLD, row, 0, &length);
              text = (char *) malloc (sizeof (char) * length + 1);
              memset(text, NULL, sizeof (char) * length + 1);
              FIfld_get_text(fp, LISTING_FLD,row,0,length,
                            (unsigned char *)text, &select, &pos);

              if ((text != NULL) && (strcmp(text, "") != 0))
                PDUfill_in_string(&PDU_file_list[count], text);
              PDUfree_string(&text);

              ++count;
              PDU_file_rows = count;
              }
            }

         if (count == 0)
           {
           break;
           }

         if (PDU_file_list_displayed == TRUE)
           {
           FIf_erase ( fp );
           PDU_file_list_displayed = FALSE;
           }

         if (PDU_file_list_created == TRUE)
           FIf_delete ( fp );

         break;

  } /* END switch ( g_label ) */

  return(status);

} /* END notification_routine() */

/* This function loads/creates, initializes, and displays the login form. */

int PDUfile_list_form()
{
  int   status = PDM_S_SUCCESS;
  int    file_col;
  char   **data_row;
  MEMptr ret_bufr = NULL;
  int    no_headings;
  int    all_flag;
  char   **headings;

  if (PDU_file_list_displayed == TRUE)
    return(status);

  PDU_file_list_created = FALSE;
  PDU_file_list_displayed = FALSE;

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

  if (ret_bufr == NULL)
    {
    return(PDM_I_NO_FILES_FOUND);
    }

  /* if there is only one file go ahead and put it in the array */
  if (ret_bufr->rows == 1)
    {
    PDU_file_list = (char **) malloc (sizeof (char *) * 1);
    memset(PDU_file_list, NULL, sizeof (char *) * 1);

    MEMbuild_array(ret_bufr);
    PDUsetup_buffer(ret_bufr, ROW, &data_row);
    status = PDUget_buffer_col(ret_bufr, "n_cofilename", &file_col);
    if (status != PDM_S_SUCCESS)
      return(status);

    PDUfill_in_string(&PDU_file_list[0], 
                      data_row[(ret_bufr->columns * 0) + file_col]);
    PDU_file_rows = 1;
    return(PDM_S_SUCCESS);
    }

  PDUsetup_single_buffer(ret_bufr);
  all_flag = FALSE;
  no_headings = 1;
  headings = (char **) malloc (sizeof (char *) * no_headings);
  memset(headings, NULL, sizeof (char *) * no_headings);

  PDUfill_in_string(&headings[0], "n_cofilename");
  PDUsetup_popup_list(headings, no_headings, all_flag, ret_bufr);
  PDUfree_string_array(&headings, no_headings);

  status = FIf_new(FILE_LIST_FORM, "file_list", 
                file_list_notification_routine, &forms.file_list_form_id);

  _pdm_debug("Creating file_list form", 0);
  PDU_file_list_created = TRUE;

  /* load the buffer into the form */
  PDU_second_row = FALSE;
  PDUbufr_to_mcf(ret_bufr,forms.file_list_form_id,LISTING_FLD);

  FIfld_set_num_rows(forms.file_list_form_id,LISTING_FLD,ret_bufr->rows);

  /* Display the file_list form and set the displayed flag to TRUE. */

  if (PDU_perm_window == TRUE)
    {
    _pdm_debug("converting form to permanent window", 0);
    FIf_cvrt_to_perm_win(forms.file_list_form_id);
    }

  _pdm_debug("Displaying the file_list form", 0);

  status = FIf_display(forms.file_list_form_id);
#ifdef sparc 
  PDUpaint_form(forms.file_list_form_id);
#endif
  PDU_file_list_displayed = TRUE;
  return(status);
}

int PDUload_file_list(type)
  int          type;
{
  MEMptr       ret_bufr = NULL;
  char         **data_row;
  int          file_col;
  int          row;
  int          status = PDM_S_SUCCESS;

  _pdm_debug("in the PDUload_file_list", 0);

  if (type == COPY_LOCAL)
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

  if (ret_bufr == NULL)
    {
    return(PDM_I_NO_FILES_FOUND);
    }

  PDU_file_list = (char **) malloc (sizeof (char *) * ret_bufr->rows);
  memset(PDU_file_list, NULL, sizeof (char *) * ret_bufr->rows);

  MEMbuild_array(ret_bufr);
  PDUsetup_buffer(ret_bufr, ROW, &data_row);
  status = PDUget_buffer_col(ret_bufr, "n_cofilename", &file_col);
  if (status != PDM_S_SUCCESS)
    return(status);

  PDU_file_rows = 0;

  /* load the files into the array */
  for (row = 0; row < ret_bufr->rows; ++row)
    {
    PDUfill_in_string(&PDU_file_list[row], 
                      data_row[(ret_bufr->columns * row) + file_col]);
    ++PDU_file_rows;
    }

  _pdm_debug("PDU_file_rows = <%d>", 0);
  _pdm_debug("PDU_file_list:", 0);

  for (row = 0; row < PDU_file_rows; ++row)
     _pdm_debug("PDU_file_list entry = <%s>", PDU_file_list[row]);

  return(PDM_S_SUCCESS);
}
