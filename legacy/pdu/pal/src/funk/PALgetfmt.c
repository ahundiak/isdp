#include <stdio.h>
#include "FI.h"
#include "exdef.h"
#include "PDUerror.h"
#include "PDUforms.h"
#include "PDUform_def.h"
#include "PDUintdef.h"
#include "PDUcommand.h"
#include "PDUfile_def.h"
#include "PDMdebug.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"


/* Gadgets */

#define FORMAT_NAME        11
#define FORMAT_LIST        13
#define ASSOC_FIELD        14


/* Externs */

extern char * calloc();
extern char * realloc();
extern int FIg_get_text_length();
extern int FIg_get_text();
extern int PDU_value_pulldown;
extern int PDMdebug_on;
extern short PDU_search_format_created;
extern short PDU_search_format_displayed;
extern char *PDU_value_list[605];
extern char *PDU_search_format;
extern MEMptr PDU_display_buffer;
extern struct PDUforms forms;
extern Form place_part_f;


int search_format_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  static char   * text;
  int             status = PDM_S_SUCCESS;
  int             length, select, pos;
  int             row;
  int             name_col = 0;
  int             list_size = 0;
  int             list_row = 0;
  int             responses[1];
  char            *strings[1];
  short           found = FALSE;
  char            **data_row;

  PDUmessage(PDM_E_CLEAR_FIELD, 's');
  _pdm_debug("f_label = <%d>", (char *)f_label);

  switch ( g_label )
  {
    case FI_CANCEL:

          /* Erase the displayed form */

         GRdelete_pull_down_list(PDU_value_pulldown);

         FIf_erase ( fp );
         PDU_search_format_displayed = FALSE;

         FIf_delete ( fp );
         PDU_search_format_created = FALSE;

         PDUmessage(PDM_E_CMD_CANCELLED, 's');

         responses[0] = RESET;
         strings[0] = "";
         PDUprepare_queue(responses, strings, 1);

         break;

    case FI_ACCEPT:

          /* Erase the displayed form */
         _pdm_debug("deleting pull down list", 0);
         GRdelete_pull_down_list(PDU_value_pulldown);

         FIf_erase ( fp );
         PDU_search_format_displayed = FALSE;

         _pdm_debug("getting format name", 0);
         FIfld_get_text_length(fp, FORMAT_NAME, 0, 0, &length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp, FORMAT_NAME, 0, 0, length,
                       (unsigned char *)text, &select, &pos);
         PDUfill_in_string(&PDU_search_format, text);
         _pdm_debug("selected format = <%s>", PDU_search_format);

         FIf_delete ( fp );
         PDU_search_format_created = FALSE;

         responses[0] = MOVE_ON;
         strings[0] = "";
         PDUprepare_queue(responses, strings, 1);

         _pdm_debug("leaving notification routine", 0);

         break;

    case FORMAT_NAME:

         /* Get the text string */
         FIfld_get_text_length(fp, g_label, 0, 0, &length);
         text = (char *) malloc (sizeof (char) * length + 1);
         memset(text, NULL, sizeof (char) * length + 1);
         FIfld_get_text(fp, g_label, 0, 0, length,
                       (unsigned char *)text, &select, &pos);
         if (strcmp(text, "") == 0)
           break;

         _pdm_debug("format name = <%s>", text);

         if (strcmp(text, "All Attributes") == 0)
           break;

         if (!PDU_display_buffer)
           {
           status = PDMlist_reports("C", &PDU_display_buffer);
           _pdm_status("PDMlist_reports", status);
           if (status != PDM_S_SUCCESS)
             {
             PDUmessage(status, 's');
             break;
             }
   
           if (PDMdebug_on)
           MEMprint_buffer("format buffer", PDU_display_buffer, PDU_DEBUG_FILE);
   
           if (!PDU_display_buffer)
             {
             status = PDM_E_NULL_BUFFER;
             PDUmessage(status, 's');
             break;
             }
           }
 
          status = MEMbuild_array(PDU_display_buffer);
         _pdm_status("MEMbuild_array", status);
         if (status != MEM_S_SUCCESS)
           {
           status = PDM_E_BUILD_BUFFER_ARRAY;
           PDUmessage(status, 's');
           break;
           }
 
         PDUsetup_buffer(PDU_display_buffer, ROW, &data_row);
         PDUget_buffer_col(PDU_display_buffer, "p_templatename", &name_col);

         found = FALSE;
         for (row = 0; row < PDU_display_buffer->rows; ++row)
            {
            if (strcmp(text, 
                data_row[(PDU_display_buffer->columns * row) + name_col]) == 0)
              {
              found = TRUE;
              _pdm_debug("matching format name found", 0);
              }
            }

         if (!found)
           {
           _pdm_debug("matching format name not found", 0);
           PDUmessage(PDM_E_INVALID_FORMAT_NAME, 's');
           FIg_set_text(fp, g_label, NULL_STRING);
           break;
           }
 
         break;

    case FORMAT_LIST:

         _pdm_debug("retrieving list list of report formats", 0);
         if (!PDU_display_buffer)
           {
           status = PDMlist_reports("C", &PDU_display_buffer);
           _pdm_status("PDMlist_reports", status);

           if (status != PDM_S_SUCCESS)
             {
             _pdm_debug("PDMlist_reports failed: resetting PDU_display_buffer",0);
             if (PDU_display_buffer)
               {
               MEMclose(&PDU_display_buffer);
               PDU_display_buffer = NULL;
               }
             }
   
           if (PDMdebug_on)
           MEMprint_buffer("format buffer", PDU_display_buffer, PDU_DEBUG_FILE);
           }

         if (!PDU_display_buffer)
           {
           FIg_set_text(fp, FORMAT_NAME, "All Attributes");
           PDUmessage(PDM_S_SUCCESS, 's');
           break;
           }
 
         _pdm_debug("resetting PDU_value_list", 0);
         for (row = 0; row < 605; ++row)
            PDUfill_in_string(&PDU_value_list[row], NULL_STRING);
         list_size = 0;
 
         if (PDU_display_buffer)
           {
           status = MEMbuild_array(PDU_display_buffer);
           _pdm_status("MEMbuild_array", status);
           if (status != MEM_S_SUCCESS)
             {
             status = PDM_E_BUILD_BUFFER_ARRAY;
             PDUmessage(status, 's');
             break;
             }
   
           PDUsetup_buffer(PDU_display_buffer, ROW, &data_row);
           PDUget_buffer_col(PDU_display_buffer, "p_templatename", &name_col);
  
           _pdm_debug("copying buffer to list", 0);
           for (row = 0; row < PDU_display_buffer->rows; ++row)
              {
              PDUfill_in_string(&PDU_value_list[list_size],
                     data_row[(PDU_display_buffer->columns * row) + name_col]);
              ++list_size;
              }
           }

         PDUfill_in_string(&PDU_value_list[list_size], "All Attributes");
         ++list_size;

         _pdm_debug("list_size = %d", (char *)list_size);
         GRchange_pull_down_text(PDU_value_pulldown, PDU_value_list, list_size);
         GRproc_pull_down_list(PDU_value_pulldown);

         break;

    case ASSOC_FIELD:

         list_row = value - 1;
         FIg_set_text(fp,FORMAT_NAME,PDU_value_list[list_row]);
         _pdm_debug("selected format = <%s>", PDU_value_list[list_row]);

         _pdm_debug("resetting PDU_value_list", 0);
         for (row = 0; row < list_size; ++row)
            PDUfill_in_string(&PDU_value_list[row], NULL_STRING);

         FIg_set_state_off(fp, FORMAT_LIST);

         break;

  } /* END switch ( g_label ) */

  return(status);

} /* END notification_routine() */


int PALget_format()
{
  int  status = PDM_S_SUCCESS;
  int  list_size = 0;
  char *msg = NULL;

  _pdm_debug("entering PALget_format", 0);

  if (PDU_display_buffer)
    {
    MEMclose(&PDU_display_buffer);
    PDU_display_buffer = NULL;
    }

  if (PDU_search_format_created == TRUE)
    return(PDM_S_SUCCESS);

  PDU_search_format_created = FALSE;
  PDU_search_format_displayed = FALSE;

  _pdm_debug("Creating search_format form", 0);
  status = FIf_new(SEARCH_FORMAT, "PALgetformat", 
                search_format_notification_routine,
                &forms.search_format_form_id);
  _pdm_status("FIf_new", status);

  PDU_search_format_created = TRUE;

  /* create the GRpulldown_list */
  _pdm_debug("creating GRcreate_pull_down_list", 0);
  GRcreate_pull_down_list(SEARCH_FORMAT, forms.search_format_form_id,
                 ASSOC_FIELD,MAX_ROWS,VIS_ROWS,PDU_value_list, list_size,
                 1, &PDU_value_pulldown);

  /* Display the search_format form and set the displayed flag to TRUE. */
  _pdm_debug("Displaying the search_format form", 0);

  status = FIf_display(forms.search_format_form_id);
  PDU_search_format_displayed = TRUE;

  _pdm_debug("current search format = <%s>", PDU_search_format);

  if ((PDU_search_format) && (strlen(PDU_search_format)))
    FIg_set_text(forms.search_format_form_id, FORMAT_NAME, PDU_search_format);

  msg = (char *) PDUtranslate_message(PDM_I_SELECT_LIST_DEFN);
  FIg_set_text(forms.search_format_form_id,FI_MSG_FIELD,msg); 

  _pdm_debug("leaving PALget_format", 0);

  return(PDM_S_SUCCESS);
}
