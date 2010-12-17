#include <stdio.h>
#include "FI.h"
#include "tools.h"
#include "exdef.h"
#include "PDUforms.h"
#include "PDUform_def.h"
#include "PDUerror.h"
#include "PDUintdef.h"
#include "MEMstruct.h"
#include "PDUproto.h"


/* Gadgets */

#define LISTING_FLD        11
#define CANCEL_BTN         12
#define msg_field          10


/* Externs */

extern struct   PDUforms      forms;
extern int      PDU_single_list_created;
extern int      PDU_single_list_displayed;
extern MEMptr   PDU_ret_bufr;
extern Form     PDU_form_id;
extern short    PDU_perm_window;
extern short    PDU_local_perm_window;
extern short    PDU_assy_perm_window;
extern short    PDU_where_used_perm_window;
extern short    PDU_topdown_perm_window;


int attach_single_list_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  int             status;
  int             responses[1];
  char            *strings[1];

  switch ( g_label )
  {
    case LISTING_FLD:         /* Field Type:    ASCII    */

        PDU_single_list_created = FALSE;
        PDU_single_list_displayed = FALSE;
         
        status = PDUbufr_to_form_fields(forms.single_list_form_id,LISTING_FLD,
                                        &PDU_ret_bufr);

        _pdm_debug("Prepare to move on", 0);
        responses[0] = MOVE_ON;
        strings[0] = "";
        PDUprepare_queue(responses, strings, 1);

        FIf_delete(fp);
        break;

    case FI_CANCEL:     

          _pdm_debug("f_label = <%d>", (char *)f_label);
          value = 0.0;
          responses[0] = RESET;
          strings[0] = "";
          PDUprepare_queue(responses, strings, 1);

         if (PDU_single_list_displayed == TRUE)
           FIf_erase ( fp );

         if (PDU_single_list_created == TRUE)
           FIf_delete ( fp );
         break;

  } /* END switch ( g_label ) */
  return(1);
} /* END notification_routine() */

/* This function loads/creates, initializes, and displays the login form. */

int PDUattach_single_list_form(title_str,msg_str)
char title_str[40], msg_str[80];
{
  int   sts;
  int   responses[1];
  char  *strings[1];

  /* Standard Environ V calls needed before entering forms system */

  PDU_single_list_created = FALSE;
  PDU_single_list_displayed = FALSE;

  sts = FIf_new(SINGLE_LIST_FORM, "single_list", 
                attach_single_list_notification_routine, &forms.single_list_form_id);

  _pdm_debug("Creating single_list form", 0);
  PDU_single_list_created = TRUE;

  /* Call function to load the buffer into the form */
  if (PDU_ret_bufr->rows  == 1)
    {
    PDUbufr_to_form(forms.single_list_form_id, LISTING_FLD, &PDU_ret_bufr);
    responses[0] = MOVE_ON;
    strings[0] = "";
    PDUprepare_queue(responses, strings, 1);
    return(PDM_S_SUCCESS);
    }

    PDUbufr_to_form(forms.single_list_form_id, LISTING_FLD, &PDU_ret_bufr);

  /* Display the single_list form and set the displayed flag to TRUE. */

  _pdm_debug("Displaying the single_list form", 0);

  FIg_set_text(forms.single_list_form_id,12,title_str);
  FIg_set_text(forms.single_list_form_id,msg_field,msg_str);
  sts = FIf_display(forms.single_list_form_id);
  PDU_single_list_displayed = TRUE;
  return(PDM_S_SUCCESS);
}

/*
 * CR #:139525526. 05/sep/95 - raj. New version of PDUattach_single_list_form()
 * to display even when there's a single value.
 */
/* This function loads/creates, initializes, and displays the login form. */

int PDUattach_single_list_form_single(title_str,msg_str)
char title_str[40], msg_str[80];
{
  int   sts;
  int   responses[1];
  char  *strings[1];

  /* Standard Environ V calls needed before entering forms system */

  PDU_single_list_created = FALSE;
  PDU_single_list_displayed = FALSE;

  sts = FIf_new(SINGLE_LIST_FORM, "single_list", 
                attach_single_list_notification_routine, &forms.single_list_form_id);

  _pdm_debug("Creating single_list form in single function", 0);
  PDU_single_list_created = TRUE;

  PDUbufr_to_form_single(forms.single_list_form_id, LISTING_FLD, &PDU_ret_bufr);

  /* Display the single_list form and set the displayed flag to TRUE. */

  _pdm_debug("Displaying the single_list form in single function", 0);

  FIg_set_text(forms.single_list_form_id,12,title_str);
  FIg_set_text(forms.single_list_form_id,msg_field,msg_str);
  sts = FIf_display(forms.single_list_form_id);
  PDU_single_list_displayed = TRUE;
  return(PDM_S_SUCCESS);
}


