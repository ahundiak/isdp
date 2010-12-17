#include <stdio.h>
#include "FI.h"
#ifdef ENV5
#include "tools.h"
#endif
#include "exdef.h"
#include "PDUforms.h"
#include "PDUform_def.h"
#include "PDUerror.h"
#include "PDUintdef.h"
#include "PDUfile_def.h"
#include "PDUproto.h"
#include "MEMstruct.h"


/* Gadgets */

#define LISTING_FLD        11


/* Externs */
extern char * calloc();
extern char * realloc();

extern struct   PDUforms      forms;
extern struct   PDUlist_origins_info *PDU_list_origins_info;
extern struct   PDUpart_node *PDU_origins_id_list;
extern int      PDU_command;
extern int      PDMdebug_on;
extern int      PDU_selected_rows;
extern MEMptr   PDU_ret_bufr;


int origin_list_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  int             status;
  int             num_rows;
  int             sel_flag;
  int             i;
  int             responses[1];
  char            *strings[1];
  char 		  *msg;


  switch ( g_label )
  {
    case LISTING_FLD:         /* Field Type:    ASCII    */

        break;

    case FI_CANCEL:     

          _pdm_debug("f_label = <%d>", (char *)f_label);
          value = 0.0;
          responses[0] = RESET;
          strings[0] = "";
          PDUprepare_queue(responses, strings, 1);

           FIf_erase ( fp );

           FIf_delete ( fp );

           FIf_display(forms.design_form_id);
         break;

    case FI_ACCEPT:     

          /* process selection */
          FIfld_get_num_rows(fp, LISTING_FLD, &num_rows);
          sel_flag = FALSE;
          for (i = 0; i < num_rows; i++)
            {
            FIfld_get_select(fp, LISTING_FLD, i, 0, &sel_flag);
            if (sel_flag)
              break;
            }

           if (!sel_flag)
             {
             msg = (char *)PDUtranslate_message(PDM_I_SEL_ORIGIN);
             FIg_set_text(fp, FI_MSG_FIELD, msg);
             break;
             }
         
           _pdm_debug("Before PDUload_origins", 0);
           if (PDU_origins_id_list == NULL)
             _pdm_debug("PDU_origins_id_list is NULL", 0);
           status = PDUload_origins();
           _pdm_status("PDUload_origins", status);

           if (PDU_origins_id_list == NULL)
             _pdm_debug("PDU_origins_id_list is NULL", 0);
          responses[0] = MOVE_ON;
          strings[0] = "";
          PDUprepare_queue(responses, strings, 1);

           FIf_erase ( fp );

           FIf_delete ( fp );
         break;
  } /* END switch ( g_label ) */
  return(1);
} /* END notification_routine() */

/* This function loads/creates, initializes, and displays the login form. */

int PDUdisplay_origins()
{
  int   sts;
  int   status;
  int   i;
  char  **headings = NULL;

  /* Standard Environ V calls needed before entering forms system */

  if (PDU_origins_id_list == NULL)
    _pdm_debug("PDU_origins_id_list is NULL", 0);

  sts = FIf_new(ORIGIN_LIST_FORM, "origin_list", 
                origin_list_notification_routine, &forms.origin_list_form_id);

  PDU_selected_rows = 0;
  _pdm_debug("Creating single_list form", 0);

  if (PDU_ret_bufr)
     {
      MEMclose(&PDU_ret_bufr);
      PDU_ret_bufr = NULL;
     }

  /* call function to extract origins from OS */
  status = PDUlist_all_origins_in_os(&PDU_ret_bufr);
  _pdm_status("PDUlist_all_origins_in_os", status);

  if (PDU_ret_bufr == NULL)
    return(PDM_E_FAILURE);

  MEMprint_buffer("origin buffer", PDU_ret_bufr, PDU_DEBUG_FILE);
  if (PDU_origins_id_list == NULL)
    _pdm_debug("PDU_origins_id_list is NULL", 0);
  MEMbuild_array(PDU_ret_bufr);
  headings = (char **)PDU_ret_bufr->data_ptr;

  _pdm_debug("before setting text", 0);
  if (PDU_origins_id_list == NULL)
    _pdm_debug("PDU_origins_id_list is NULL", 0);
  for (i = 0; i < PDU_ret_bufr->rows; i++)
    FIfld_set_text(forms.origin_list_form_id, LISTING_FLD, i, 0,
                   headings[(PDU_ret_bufr->columns * i) + 2], FALSE);
             
  _pdm_debug("Before displaying form", 0);
  FIf_display(forms.origin_list_form_id);
  if (PDU_origins_id_list == NULL)
    _pdm_debug("PDU_origins_id_list is NULL", 0);
  return(PDM_S_SUCCESS);
}

int PDUload_origins()
  {
  int length;
  int select;
  int pos;
  int num_rows;
  int sel_flag;
  int i;
  char *text = NULL;
  struct PDUlist_origins_info *temp;
  struct PDUlist_origins_info *tail;

  _pdm_debug("In PDUload_origins", 0);

   FIfld_get_num_rows(forms.origin_list_form_id, LISTING_FLD, &num_rows);
   _pdm_debug("num_rows = <%d>", (char *)num_rows);

  for (i = 0; i < num_rows; i++)
    {
    FIfld_get_select(forms.origin_list_form_id, LISTING_FLD, i, 0, &sel_flag);
    if (sel_flag)
      {
      _pdm_debug("Selected row = <%d>", (char *)i);
      temp = (struct PDUlist_origins_info *)
              malloc(sizeof(struct PDUlist_origins_info));

      /* Initialize temp fields */
      temp->view_name = NULL;
      temp->next = NULL;

      FIfld_set_active_row(forms.origin_list_form_id, LISTING_FLD, i, 0);
      FImcf_set_active_col(forms.origin_list_form_id, LISTING_FLD, 0, 0);
      FIfld_get_text_length(forms.origin_list_form_id,LISTING_FLD,i,0,&length);
      text = (char *) malloc (sizeof (char) * length + 1);
      memset(text, NULL, sizeof (char) * length + 1);
      FIfld_get_text(forms.origin_list_form_id,LISTING_FLD,i,0,length,
                     (unsigned char*)text,
                     &select,&pos);

      PDUfill_in_string(&(temp->view_name), text);

     /* Add origin info node to the end of PDU_list_parts_info */
     if (PDU_list_origins_info)
        {
         /* Get to the end of list */
         _pdm_debug("adding origin info node to the end", 0);

         tail = PDU_list_origins_info;
         while (tail->next)
               {
                tail = tail->next;
               }

         /* Add part to path link list */
         tail->next = temp;
        }

     else
        {
         /* This is the first node in the list */
         _pdm_debug("adding origin info node to the front", 0);

         PDU_list_origins_info = temp;
        }
     PDU_selected_rows = PDU_selected_rows + 1;
     }
   }

  return(PDM_S_SUCCESS);
  }

