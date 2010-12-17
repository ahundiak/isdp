#include <stdio.h>
#include "FI.h"
#include "tools.h"
#include "PDUforms.h"
#include "PDUform_def.h"
#include "PDUerror.h"
#include "PDUintdef.h"
#include "MEMstruct.h"
#include "PDUproto.h"


/* Gadgets */

#define LISTING_FLD        11


/* Externs */

extern struct   PDUforms      forms;
extern int      PDU_single_list_created;
extern int      PDU_single_list_displayed;
extern MEMptr   PDU_ret_bufr;
extern MEMptr   PDU_hold_bufr;
extern MEMptr   PDU_ep_bufr;
extern MEMptr   PDU_hold_stg_bufr;
extern MEMptr   PDU_ep_stg_bufr;
extern MEMptr   states_bufr;
extern int      end_np_cat_btn_flag;
extern int      end_np_part_btn_flag;
extern int      end_np_parttype_btn_flag;
extern int      end_ep_proj_btn_flag;
extern int      end_ep_cat_btn_flag;
extern int      end_ep_part_fld_flag;
extern int      end_ep_part_btn_flag;
extern int      end_ep_rev_btn_flag;
extern int      end_ep_desc_fld_flag;
extern int      end_ep_desc_btn_flag;
extern int      end_move_to_state_btn_flag;
extern int      pdu_hold_stg_bufr_flag;
extern int      pdu_ep_stg_bufr_flag;
extern int      pdu_hold_acl_bufr_flag;
extern int      pdu_ep_acl_bufr_flag;
extern int      PDU_active_button;
extern int      PDU_active_list;
extern int      PDU_list_cat;
extern Form     PDU_form_id;
extern Form     place_part_f;
extern Form     ModifyPartForm;
extern short    PDU_perm_window;
extern short    PDU_local_perm_window;
extern short    PDU_assy_perm_window;
extern short    PDU_where_used_perm_window;
extern short    PDU_topdown_perm_window;

int single_list_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  int             status = PDM_S_SUCCESS;
  fp = forms.single_list_form_id;

  value = 0.0;
  f_label = 0;

  switch ( g_label )
  {
    case LISTING_FLD:         /* Field Type:    ASCII    */

        FIf_erase(fp);
        PDU_single_list_displayed = FALSE;

        if (pdu_hold_stg_bufr_flag == TRUE)
           status = PDUbufr_to_form_fields(forms.single_list_form_id,
                                           LISTING_FLD, &PDU_hold_stg_bufr);
        else if (pdu_ep_stg_bufr_flag == TRUE)
           status = PDUbufr_to_form_fields(forms.single_list_form_id,
                                           LISTING_FLD, &PDU_ep_stg_bufr);
        else if (end_move_to_state_btn_flag == TRUE)
           status = PDUbufr_to_form_fields(forms.single_list_form_id, 
                                           LISTING_FLD, &states_bufr);
        else
           {
           _pdm_debug("Calling with PDU_ret_bufr", 0);
           status = PDUbufr_to_form_fields(forms.single_list_form_id,
                                           LISTING_FLD, &PDU_ret_bufr);
           }

        break;

    case FI_CANCEL:     

         if (PDU_single_list_displayed == TRUE)
           {
           FIf_erase ( fp );
           PDU_single_list_displayed = FALSE;
           }

         if (PDU_single_list_created == TRUE)
           {
           FIf_delete ( fp );
           PDU_single_list_created = FALSE;
           }

         if ((PDU_active_button != -1) && (PDU_form_id == forms.design_form_id))
           {
           FIg_set_state_off(PDU_form_id, PDU_active_list);
           FIg_display(PDU_form_id, PDU_active_list);
           /* restore active button */
           PDU_active_button = -1;
           }
        else if (PDU_active_button != -1)
          {
          FIg_set_state_off(PDU_form_id, PDU_active_button);
          FIg_display(PDU_form_id, PDU_active_button);
          /* restore active button */
          PDU_active_button = -1;
          }

          end_np_cat_btn_flag = FALSE;
          end_np_part_btn_flag = FALSE;
          end_np_parttype_btn_flag = FALSE;
          end_ep_proj_btn_flag = FALSE;
          end_ep_cat_btn_flag = FALSE;
          end_ep_part_fld_flag = FALSE;
          end_ep_part_btn_flag = FALSE;
          end_ep_rev_btn_flag = FALSE;
          end_ep_desc_fld_flag = FALSE;
          end_ep_desc_btn_flag = FALSE;
          end_move_to_state_btn_flag = FALSE;
          pdu_hold_stg_bufr_flag = FALSE;
          pdu_hold_acl_bufr_flag = FALSE;
          pdu_ep_stg_bufr_flag = FALSE;
          pdu_ep_acl_bufr_flag = FALSE;
          PDU_list_cat = FALSE;

         break;

  } /* END switch ( g_label ) */

  /*if (end_np_cat_btn_flag == TRUE)
     {
     end_np_cat_btn_flag = FALSE;
     PDUmessage(status,'s');
     }*/

  return(status);

} /* END notification_routine() */

/* This function loads/creates, initializes, and displays the login form. */

int PDUsingle_list_form()
{
  int   sts = PDM_S_SUCCESS;
  int   status = FI_SUCCESS;
  int   xpos;
  int   ypos;

  if (PDU_single_list_displayed == TRUE)
    return(sts);

  PDU_single_list_created = FALSE;
  PDU_single_list_displayed = FALSE;


  if (pdu_hold_stg_bufr_flag == TRUE)
    {
    _pdm_debug("entering case for pdu_hold_stg_bufr_flag = TRUE", 0);
    if ((PDU_hold_stg_bufr) && (PDU_hold_stg_bufr->rows < 2))
      {
      sts = PDUbufr_to_form(forms.single_list_form_id, LISTING_FLD,
                             &PDU_hold_stg_bufr);
      return(sts);
      }
    }
  else if (pdu_ep_stg_bufr_flag == TRUE)
    {
    _pdm_debug("entering case for pdu_ep_stg_bufr_flag = TRUE", 0);
    if ((PDU_ep_stg_bufr) && (PDU_ep_stg_bufr->rows < 2))
      {
      sts = PDUbufr_to_form(forms.single_list_form_id, LISTING_FLD,
                             &PDU_ep_stg_bufr);
      return(sts);
      }
    }
  else if (end_move_to_state_btn_flag == TRUE)
    {
    _pdm_debug("entering case for end_move_to_state_btn_flag = TRUE", 0);
    if ((states_bufr) && (states_bufr->rows < 2))
      {
      sts = PDUbufr_to_form(forms.single_list_form_id, LISTING_FLD,
                             &states_bufr);
      return(sts);
      }
    }
  else
    {
    if ((PDU_ret_bufr) && (PDU_ret_bufr->rows < 2) && 
        (!end_ep_cat_btn_flag) && (!end_np_cat_btn_flag))
      {
      _pdm_debug("entering case for end_move_to_state_btn_flag = TRUE", 0);
      sts = PDUbufr_to_form(forms.single_list_form_id, LISTING_FLD,
                             &PDU_ret_bufr);
      return(sts);
      }
    }
    
  if ((end_ep_cat_btn_flag) || (end_np_cat_btn_flag))
    PDU_list_cat = TRUE;

  sts = FIf_new(SINGLE_LIST_FORM, "single_list", 
                single_list_notification_routine, &forms.single_list_form_id);

  _pdm_debug("Creating single_list form", 0);
  PDU_single_list_created = TRUE;

  /* Call function to load the buffer into the form */

    if (pdu_hold_stg_bufr_flag == TRUE)
       sts = PDUbufr_to_form(forms.single_list_form_id, LISTING_FLD,
                             &PDU_hold_stg_bufr);
    else if (pdu_ep_stg_bufr_flag == TRUE)
       sts = PDUbufr_to_form(forms.single_list_form_id, LISTING_FLD,
                             &PDU_ep_stg_bufr);
    else if (end_move_to_state_btn_flag == TRUE)
       sts = PDUbufr_to_form(forms.single_list_form_id, LISTING_FLD,
                             &states_bufr);
    else
       sts = PDUbufr_to_form(forms.single_list_form_id, LISTING_FLD,
                             &PDU_ret_bufr);

  /* get the location of the active button */
  if (PDU_active_button != -1)
    {
    status = FIg_get_location(PDU_form_id, PDU_active_button, &xpos, &ypos);

    if (status == FI_SUCCESS)
      {
      if ((PDU_form_id != forms.design_form_id) &&
          (PDU_form_id != place_part_f) && (PDU_form_id != ModifyPartForm))
        FIf_set_location(forms.single_list_form_id, xpos, ypos + 75);
      else
        FIf_set_location(forms.single_list_form_id, xpos, ypos + 400);
      }
    else
      _pdm_debug("could not get location of active button", 0);

    /* reset the active button number */
    /*PDU_active_button = -1;*/
    }
    
  /* convert this form to a permanent window if the calling form is not
     save/restore */
  if ((PDU_form_id != forms.design_form_id) &&
      (PDU_form_id != forms.report_form_id) &&
      (PDU_form_id != forms.topdown_form_id) &&
      (PDU_form_id != forms.local_files_form_id) &&
      (PDU_form_id != forms.parametric_parts_form_id) &&
      (PDU_form_id != forms.cat_name_form_id) &&
      (PDU_form_id != forms.where_used_form_id))
    {
    _pdm_debug("converting form to permanent window", 0);
    FIf_cvrt_to_perm_win(forms.single_list_form_id);
    }
  else
    {
    if (((PDU_form_id == forms.design_form_id) ||
        (PDU_form_id == forms.parametric_parts_form_id) ||
        (PDU_form_id == forms.report_form_id)) &&
        (PDU_perm_window == TRUE))
      {
      _pdm_debug("converting form to permanent window", 0);
      FIf_cvrt_to_perm_win(forms.single_list_form_id);
      }
    else if ((PDU_form_id == forms.local_files_form_id) &&
        (PDU_local_perm_window == TRUE))
      {
      _pdm_debug("converting form to permanent window", 0);
      FIf_cvrt_to_perm_win(forms.single_list_form_id);
      }
    else if ((PDU_form_id == forms.where_used_form_id) &&
        (PDU_where_used_perm_window == TRUE))
      {
      _pdm_debug("converting form to permanent window", 0);
      FIf_cvrt_to_perm_win(forms.single_list_form_id);
      }
    else if ((PDU_form_id == forms.topdown_form_id) &&
        (PDU_topdown_perm_window == TRUE))
      {
      _pdm_debug("converting form to permanent window", 0);
      FIf_cvrt_to_perm_win(forms.single_list_form_id);
      }
    }

  /* Display the single_list form and set the displayed flag to TRUE. */
  _pdm_debug("Displaying the single_list form", 0);

  sts = FIf_display(forms.single_list_form_id);
  PDU_single_list_displayed = TRUE;
  return(sts);
}

