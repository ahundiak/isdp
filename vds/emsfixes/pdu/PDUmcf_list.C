/* $Id: PDUmcf_list.C,v 1.1 2001/09/07 18:30:59 jdsauby Exp $ */
/* -------------------------------------------------------------------
 * I/VDS
 *
 * File: vds/emsfixes/pdu/filemgr/PDUmcf_list.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *       $Log: PDUmcf_list.C,v $
 *       Revision 1.1  2001/09/07 18:30:59  jdsauby
 *       Final Checkin for AIM / PDU integration  - jds
 *
 *       Revision 1.1  2001/08/15 19:25:59  jdsauby
 *       Added to SP for AIM PDM integration - jds, tls
 *
 *
 *
 * Revision 1.3  2000/10/24  21:50:08  pinnacle
 * (No comment)
 *
 *
 * History:
 *       MM/DD/YY        AUTHOR          DESCRIPTION
 *       08/15/01	 js		 AIM integration
 * -------------------------------------------------------------------------*/


#include <stdio.h>
#include "FI.h"
#include "tools.h"
#include "PDUforms.h"
#include "PDUform_def.h"
#include "PDUerror.h"
#include "PDUintdef.h"
#include "PDUprompt.h"
#include "PDUfile_def.h"
#include "PDUstr.h"
#include "MEMstruct.h"
#include "PDUproto.h"
#include "exmacros.h"
/*#include "vadbgmacros.h" */

/* Gadgets */

#define MCF_LIST         12
#define PART_NUM_TEXT    13
#define DWG_NUM_TEXT     14
#define PART_GRP         18
#define ACL_GRP          22
#define MOVE_STATE_GRP   24
#define TITLE_FLD	 25

#define CATALOG_FLD      26

#define BASELINE        "Baseline"
#define RELEASE         "Release"
#define CHECKING        "Checking"
#define DEVELOPMENT     "Development"

/* Externs */

extern struct   PDUforms     forms;
extern int      PDU_mcf_list_created;
extern int      PDU_mcf_list_displayed;
extern int      end_np_cat_btn_flag;
extern int      end_np_part_btn_flag;
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
extern MEMptr   PDU_ret_bufr;
extern MEMptr   PDU_hold_acl_bufr;
extern MEMptr   PDU_ep_acl_bufr;
extern MEMptr   states_bufr;
extern Form     PDU_form_id;
extern short    PDU_perm_window;
extern short    PDU_local_perm_window;
extern short    PDU_assy_perm_window;
extern short    PDU_where_used_perm_window;
extern short    PDU_topdown_perm_window;
extern char     current_state[50];
extern struct PDUrefresh        *refresh;
extern int CheckAllowed();

int mcf_list_notification_routine ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  int             status = PDM_S_SUCCESS;

  int   select, pos, length, num_rows;
  int   row = 0;
  int   mcf_select = FALSE, response;
  char state[20], response_data[50];

  static char *text1, *text2, *text3;

  fp = forms.mcf_list_form_id;
  _pdm_debug("in mcf_list_notification_routine", 0);

  f_label = 0;
  value = 0.0;
  switch ( g_label )
  {
    case FI_CANCEL:     


         _pdm_debug("erasing mcf form", 0);
         if (PDU_mcf_list_displayed == TRUE)
           {
           FIf_erase ( fp );
           PDU_mcf_list_displayed = FALSE;
           }
         if (PDU_mcf_list_created == TRUE)
           {
           FIf_delete ( fp );
           PDU_mcf_list_created = FALSE;
           }

         _pdm_debug("deleteing mcf form", 0);
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
          end_move_to_state_btn_flag = FALSE;

         _pdm_debug("leaving notification routine",0);
         break;

    case FI_ACCEPT:     


         /*printf("\nFI_ACCEPTING cat %s, part %s, rev %s",
            refresh->rev_catalog, refresh->rev_partid, refresh->rev_revision);*/
         FIfld_get_num_rows(forms.mcf_list_form_id, MCF_LIST, &num_rows);
         __DBGpr_int("nos", num_rows);
         for(row = 0; row < num_rows; row++)
         {
           FIfld_get_select(forms.mcf_list_form_id, MCF_LIST,
                            row, 0, &mcf_select);
           if(mcf_select)
           {
             FIfld_get_text_length(forms.mcf_list_form_id, MCF_LIST,
                                   row, 0, &length);
             FIfld_get_text(forms.mcf_list_form_id, MCF_LIST, row, 0,
                            length, (unsigned char*)state, &select, &pos);
             //__DBGpr_str("state", state);
           }
         }
          if(!strcmp(state, DEVELOPMENT))
          {
	      _pdm_debug("Rejecting Part");
            //__DBGpr_com("Rejecting part");
            status = CMReject();
            if(status)
            {
              UI_status("Couldnot Change AR States in AIM.");
              break;
            }
          }
          if(!strcmp(state, BASELINE))
          {
	      _pdm_debug("Baselining MDC.");
            //__DBGpr_com("Baselining MDC.");
            status = CMBaseline();
            if(status)
            {
              UI_status("Couldnot Baseline M D C.");
              break;
            }
          }
          if(!strcmp(state, RELEASE))
          {
	      _pdm_debug("Releasing Part.");
            //__DBGpr_com("Releasing Part.");
            status = CMRelease();
            if(status)
            {
              UI_status("Couldnot Revise M D C.");
              break;
            }
          }
          if(!strcmp(state, CHECKING))
          {
            status = CMstate_form();
            do
            {
              ex$wait_for_input( response = &response,
                       buffer = response_data,
                       mode = EX_ALL_ASCII_MODE,
                       byte = &status );
            } while( response != EX_FORM_FINISHED );
            if(CheckAllowed() == 0)
            {
              UI_status("Couldnot move to Checking.");
              break;
            }
          }


         if (!end_move_to_state_btn_flag)
           break;
         else
            {
            FIf_erase(fp);
            PDU_mcf_list_displayed = FALSE;

            status = PDUbufr_to_form_fields(forms.mcf_list_form_id,
                                            MCF_LIST, &states_bufr);
            }
         break;

    case MCF_LIST:     /* Sequenced to     */

         /*printf("\n cat %s, part %s, rev %s", refresh->rev_catalog,
         *        refresh->rev_partid, refresh->rev_revision);
         *FIfld_get_num_rows(forms.mcf_list_form_id, MCF_LIST, &num_rows);
         *printf("\n nos %d", num_rows);
         *for(row = 0; row < num_rows; row++)
         *{
         *  FIfld_get_select(forms.mcf_list_form_id, MCF_LIST,
         *                   row, 0, &mcf_select);
         *  if(mcf_select)
         *  {
         *    FIfld_get_text_length(forms.mcf_list_form_id, MCF_LIST,
         *                           row, 0, &length);
         *    FIfld_get_text(forms.mcf_list_form_id, MCF_LIST, row, 0, 
         *                   length, (unsigned char*)state, &select, &pos);
         *    printf("\n state %s", state);
         *  }
         *}*/
        /* MOVED THIS TO EXECUTE *
         * if(!strcmp(state, CHECKING))
         * {
         *   FIg_disable(forms.mcf_list_form_id, FI_ACCEPT );
         *   status =0;
         *   status = CMstate_form();
         *   if(status)
         *     FIg_disable(forms.mcf_list_form_id, FI_ACCEPT );
         * }
         * */


       //  if (end_move_to_state_btn_flag == FALSE)
  
         //  { 
          //  FIf_erase(fp);
          //  PDU_mcf_list_displayed = FALSE;

          //  if (pdu_hold_acl_bufr_flag == TRUE)
            //   status = PDUbufr_to_form_fields(forms.mcf_list_form_id,
              //                                 MCF_LIST, &PDU_hold_acl_bufr);
           // else if (pdu_ep_acl_bufr_flag == TRUE)
             //  status = PDUbufr_to_form_fields(forms.mcf_list_form_id,
               //                                MCF_LIST, &PDU_ep_acl_bufr);
           // else
             //  status = PDUbufr_to_form_fields(forms.mcf_list_form_id, MCF_LIST,
               //                                &PDU_ret_bufr);
           // break;
           // }
	    

	FIfld_get_text_length(forms.local_files_form_id, CATALOG_FLD, 0, 0,
	&length);
	
	text1 = (char *) malloc (sizeof (char) * length + 1);
	memset(text1, NULL, sizeof (char) * length + 1);
	
         FIfld_get_text(forms.local_files_form_id, CATALOG_FLD, 0, 0, length,
	              (unsigned char *)text1, &select, &pos);



	 FIfld_get_active_row(forms.mcf_list_form_id, MCF_LIST, &row, &pos);

    FIfld_get_text_length(forms.mcf_list_form_id, MCF_LIST, row, 0, &length);

	 text2 = (char *) malloc (sizeof (char) * length + 1);
	 memset(text2, NULL, sizeof (char) * length + 1 );

	 FIfld_get_text(forms.mcf_list_form_id, MCF_LIST, row, 0, length, 
	               (unsigned char *)text2, &select, &pos);


      FIfld_get_text_length(forms.mcf_list_form_id, MCF_LIST, row, 0, &length);
	 
	 text3 = (char *) malloc (sizeof (char) * length + 1 );
	 memset(text3, NULL, sizeof (char) * length + 1);
	 

	 FIfld_get_text(forms.mcf_list_form_id, MCF_LIST, row, 1, length,
	               (unsigned char *)text3, &select, &pos);



if (end_move_to_state_btn_flag == FALSE)
  
      { 
            FIf_erase(fp);
            PDU_mcf_list_displayed = FALSE;
          if (pdu_hold_acl_bufr_flag == TRUE)
 	  status = PDUbufr_to_form_fields(forms.mcf_list_form_id,
                                          MCF_LIST, &PDU_hold_acl_bufr);
					
	else if
	(pdu_ep_acl_bufr_flag == TRUE)
	  status = PDUbufr_to_form_fields(forms.mcf_list_form_id,
		                         MCF_LIST, &PDU_ep_acl_bufr);
	else
        status = PDUbufr_to_form_fields(forms.mcf_list_form_id, MCF_LIST,
	                                &PDU_ret_bufr);
 
	  break;
									              }
         break;

  } /* END switch ( g_label ) */

  return(status);

} /* END notification_routine() */

/* This function loads/creates, initializes, and displays the login form. */

int PDUmcf_list_form(title_str)
char title_str[80];
{
  int   sts = PDM_S_SUCCESS;
  int   status = FI_SUCCESS;
  int   xpos, ypos;

  if (PDU_mcf_list_displayed == TRUE)
    return(sts);

  PDU_mcf_list_created = FALSE;
  PDU_mcf_list_displayed = FALSE;

  /* call function to load data into the form */
  if (pdu_hold_acl_bufr_flag == TRUE)
    {
    if ((PDU_hold_acl_bufr) && (PDU_hold_acl_bufr->rows < 2))
      {
      sts = PDUbufr_to_form(forms.mcf_list_form_id, MCF_LIST,
                            &PDU_hold_acl_bufr);
      return(sts);
      }
    }
  else if (pdu_ep_acl_bufr_flag == TRUE)
    {
    if ((PDU_ep_acl_bufr) && (PDU_ep_acl_bufr->rows < 2))
      {
      sts = PDUbufr_to_form(forms.mcf_list_form_id, MCF_LIST,
                            &PDU_ep_acl_bufr);
      return(sts);
      }
    }
  else if (end_move_to_state_btn_flag == TRUE)
    {
    if ((states_bufr) && (states_bufr->rows < 2))
      {
      sts = PDUbufr_to_form(forms.mcf_list_form_id, MCF_LIST,
                             &states_bufr);
      return(sts);
      }
    }
  else
    {
    if ((PDU_ret_bufr) && (PDU_ret_bufr->rows < 2))
      {
      PDUbufr_to_form(forms.mcf_list_form_id, MCF_LIST, &PDU_ret_bufr);
      return(sts);
      }
    }

  sts = FIf_new(MCF_LIST_FORM, "mcf_list", mcf_list_notification_routine,
                &forms.mcf_list_form_id);

  _pdm_debug("Creating mcf_list form", 0);
  PDU_mcf_list_created = TRUE;

  /* call function to load data into the form */
  if (pdu_hold_acl_bufr_flag == TRUE)
     sts = PDUbufr_to_form(forms.mcf_list_form_id, MCF_LIST,
                           &PDU_hold_acl_bufr);
  else if (pdu_ep_acl_bufr_flag == TRUE)
     sts = PDUbufr_to_form(forms.mcf_list_form_id, MCF_LIST,
                           &PDU_ep_acl_bufr);
  else if (end_move_to_state_btn_flag == TRUE)
     sts = PDUbufr_to_form(forms.mcf_list_form_id, MCF_LIST,
                           &states_bufr);
  else
     PDUbufr_to_form(forms.mcf_list_form_id, MCF_LIST, &PDU_ret_bufr);

  /* change labels if this is an ACL listing */
  if ((pdu_hold_acl_bufr_flag == TRUE) || (pdu_ep_acl_bufr_flag == TRUE))
     {
     FIg_erase(forms.mcf_list_form_id, PART_GRP);
     FIg_display(forms.mcf_list_form_id, ACL_GRP);
     }
  else if (end_move_to_state_btn_flag == TRUE)
     {
     FIg_erase(forms.mcf_list_form_id, PART_GRP);
     FIg_display(forms.mcf_list_form_id, MOVE_STATE_GRP);
     }

  /* hide the FI_ACCEPT button */
  if (!end_move_to_state_btn_flag)
    {
    FIg_erase(forms.mcf_list_form_id, FI_ACCEPT);
    FIg_set_location(forms.mcf_list_form_id, FI_CANCEL, 428, 5);
    }
  
  /* get the location of the active button */
  if (PDU_active_button != -1)
    {
    _pdm_debug("PDU_active_button = %d", (char *)PDU_active_button);
    status = FIg_get_location(PDU_form_id, PDU_active_button, &xpos, &ypos);

    if (status == FI_SUCCESS)
      {
      if (PDU_form_id != forms.design_form_id)
        FIf_set_location(forms.mcf_list_form_id, xpos, ypos + 75);
      else
        FIf_set_location(forms.mcf_list_form_id, xpos, ypos + 400);
      }
    else
      _pdm_debug("could not get location of active button", 0);
  
    /* reset the active button number */
    /*PDU_active_button = -1; */
    }

  /* convert this form to a permanent window if the calling form is not
     save/restore */
  if ((PDU_form_id != forms.design_form_id) &&
      (PDU_form_id != forms.report_form_id) &&
      (PDU_form_id != forms.topdown_form_id) &&
      (PDU_form_id != forms.local_files_form_id) &&
      (PDU_form_id != forms.where_used_form_id) &&
      (PDU_form_id != forms.parametric_parts_form_id))
    {
    _pdm_debug("converting form to permanent window", 0);
    sts = FIf_cvrt_to_perm_win(forms.mcf_list_form_id);
    _pdm_status("FIf_cvrt_to_perm_win", sts);
    }
  else
    {
    if (((PDU_form_id == forms.design_form_id) ||
        (PDU_form_id == forms.report_form_id) ||
        (PDU_form_id == forms.parametric_parts_form_id)) &&
        (PDU_perm_window == TRUE))
      {
      _pdm_debug("converting form to permanent window", 0);
      FIf_cvrt_to_perm_win(forms.mcf_list_form_id);
      }
    else if ((PDU_form_id == forms.local_files_form_id) &&
        (PDU_local_perm_window == TRUE))
      {
      _pdm_debug("converting form to permanent window", 0);
      FIf_cvrt_to_perm_win(forms.mcf_list_form_id);
      }
    else if ((PDU_form_id == forms.where_used_form_id) &&
        (PDU_where_used_perm_window == TRUE))
      {
      _pdm_debug("converting form to permanent window", 0);
      FIf_cvrt_to_perm_win(forms.mcf_list_form_id);
      }
    else if ((PDU_form_id == forms.topdown_form_id) &&
        (PDU_topdown_perm_window == TRUE))
      {
      _pdm_debug("converting form to permanent window", 0);
      FIf_cvrt_to_perm_win(forms.mcf_list_form_id);
      }
    }

  _pdm_debug("Setting text on title field |%s|",title_str); 
  if (strcmp(title_str,"") != 0)
   FIg_set_text(forms.mcf_list_form_id,TITLE_FLD,title_str);

  /* Display the mcf_list form and set the displayed flag to TRUE. */
  _pdm_debug("Displaying the mcf_list form", 0);

  FIf_set_size(forms.mcf_list_form_id, 463, 278);

  sts = FIf_display(forms.mcf_list_form_id);
  PDU_mcf_list_displayed = TRUE;
  return(PDM_S_SUCCESS);
}

