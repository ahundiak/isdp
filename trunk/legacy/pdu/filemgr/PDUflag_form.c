#include <stdio.h>
#include <FI.h>
#include <PDUforms.h>
#include <PDUerror.h>
#include <PDUintdef.h>
#include <PDUform_def.h>
#include <PDUfile_def.h>
#include <PDUcommand.h>
#include "PDUproto.h"
#include "PDMproto.h"


/* Gadgets */

#define ARCHIVE		13
#define BACKUP 		14
#define DELETE_BTN  	15
#define RESTORE  	16
#define FLAG_TGL	17


/* Externs */

extern char * calloc();
extern char * realloc();
extern short PDU_flag_form_created;
extern short PDU_flag_form_displayed;
extern short PDU_flag_perm_window;
extern short PDU_local_perm_window;
extern int PDU_command;
extern int PDU_selected_rows;
extern struct PDUforms      forms;


int flag_notification_routine ( f_label, g_label, value, fp )
  int     f_label;        /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;          /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  int             status = PDM_S_SUCCESS;
  int             state = 1;

  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  switch ( g_label )
  {
    case FI_HELP:     /* Member of group FI_CTRL_GROUP */

	 f_label = 0;
         value = 0.0;

         _pdm_debug ("User selected the HELP button", 0);
         if (PDU_flag_perm_window == FALSE)
           {
           FIf_cvrt_to_perm_win(forms.local_files_form_id);
           FIf_cvrt_to_perm_win(forms.flag_form_id);
           PDU_local_perm_window = TRUE;
           PDU_flag_perm_window = TRUE;
           }
         status = PDUinitialize_help();
         _pdm_status("PDUinitialize_help", status);
         if (status != PDM_S_SUCCESS)
           {
           PDUmessage(status, 's');
           break;
           }

         Help_topic("flagopts");

         break;

    case FI_CANCEL:     /* Member of group FI_CTRL_GROUP */
         PDUmessage(PDM_E_CMD_CANCELLED, 's');

         _pdm_debug("User selected the cancel button", 0);

         if (PDU_flag_form_displayed == TRUE)
           FIf_erase( fp );
         if (PDU_flag_form_created == TRUE)
           FIf_delete( fp );

         PDU_flag_form_displayed = FALSE;
         PDU_flag_form_created = FALSE;
         PDU_flag_perm_window = FALSE;

         break;

    case FI_CVT_TO_PERM_WIN:     /* Member of group FI_CTRL_GROUP */
 
         value = 0.0;
         f_label = 0;
  
         PDU_flag_perm_window = TRUE;
         break;

    case ARCHIVE:
         
         _pdm_debug("entering case for ARCHIVE", 0);
         FIg_get_state(fp, FLAG_TGL, &state);

         if (!state)
           {
           _pdm_debug("flag for archive", 0); 
           PDU_command = PDC_M_ARCHIVE_PENDING;
           }
         else
           {
           _pdm_debug("unflag for archive", 0); 
           PDU_command = PDC_M_UNFLAG_ARCHIVE;
           }

         if (PDU_flag_form_displayed == TRUE)
           FIf_erase( fp );
         if (PDU_flag_form_created == TRUE)
           FIf_delete( fp );
 
         PDU_flag_form_displayed = FALSE;
         PDU_flag_form_created = FALSE;
         PDU_flag_perm_window = FALSE;

         status = PDUcheck_part("flag/unflag part", FLAG_PART);
         _pdm_status("PDUcheck_part", status);

         if (PDU_selected_rows > 0)
           if (PDU_command == PDC_M_ARCHIVE_PENDING)
             status = PDM_E_NOT_FLAGGED;
           else
             status = PDM_E_NOT_CANCELED;

         PDUmessage(status, 's');

         break;
      
    case BACKUP:
         
         _pdm_debug("entering case for BACKUP", 0);
         FIg_get_state(fp, FLAG_TGL, &state);

         if (!state)
           {
           _pdm_debug("flag for archive", 0); 
           PDU_command = PDC_M_BACKUP_PENDING;
           }
         else
           {
           _pdm_debug("unflag for archive", 0); 
           PDU_command = PDC_M_UNFLAG_BACKUP;
           }

         if (PDU_flag_form_displayed == TRUE)
           FIf_erase( fp );
         if (PDU_flag_form_created == TRUE)
           FIf_delete( fp );
 
         PDU_flag_form_displayed = FALSE;
         PDU_flag_form_created = FALSE;
         PDU_flag_perm_window = FALSE;

         status = PDUcheck_part("flag/unflag part", FLAG_PART);
         _pdm_status("PDUcheck_part", status);

         if (PDU_selected_rows > 0)
           if (PDU_command == PDC_M_BACKUP_PENDING)
             status = PDM_E_NOT_FLAGGED;
           else
             status = PDM_E_NOT_CANCELED;

         PDUmessage(status, 's');

         break;
      
    case DELETE_BTN:
         
         _pdm_debug("entering case for DELETE_BTN", 0);
         FIg_get_state(fp, FLAG_TGL, &state);

         if (!state)
           {
           _pdm_debug("flag for archive", 0); 
           PDU_command = PDC_M_DELETE_PENDING;
           }
         else
           {
           _pdm_debug("unflag for archive", 0); 
           PDU_command = PDC_M_UNFLAG_DELETE;
           }

         if (PDU_flag_form_displayed == TRUE)
           FIf_erase( fp );
         if (PDU_flag_form_created == TRUE)
           FIf_delete( fp );
 
         PDU_flag_form_displayed = FALSE;
         PDU_flag_form_created = FALSE;
         PDU_flag_perm_window = FALSE;

         status = PDUcheck_part("flag/unflag part", FLAG_PART);
         _pdm_status("PDUcheck_part", status);

         if (PDU_selected_rows > 0)
           if (PDU_command == PDC_M_DELETE_PENDING)
             status = PDM_E_NOT_FLAGGED;
           else
             status = PDM_E_NOT_CANCELED;

         PDUmessage(status, 's');

         break;
      
    case RESTORE:
         
         _pdm_debug("entering case for RESTORE", 0);
         FIg_get_state(fp, FLAG_TGL, &state);

         if (!state)
           {
           _pdm_debug("flag for archive", 0); 
           PDU_command = PDC_M_RETRIEVE_PENDING;
           }
         else
           {
           _pdm_debug("unflag for archive", 0); 
           PDU_command = PDC_M_UNFLAG_RESTORE;
           }

         if (PDU_flag_form_displayed == TRUE)
           FIf_erase( fp );
         if (PDU_flag_form_created == TRUE)
           FIf_delete( fp );
 
         PDU_flag_form_displayed = FALSE;
         PDU_flag_form_created = FALSE;
         PDU_flag_perm_window = FALSE;

         status = PDUcheck_part("flag/unflag part", FLAG_PART);
         _pdm_status("PDUcheck_part", status);

         if (PDU_selected_rows > 0)
           if (PDU_command == PDC_M_RETRIEVE_PENDING)
             status = PDM_E_NOT_FLAGGED;
           else
             status = PDM_E_NOT_CANCELED;

         PDUmessage(status, 's');

         break;
      
    case FLAG_TGL:
         
         break;
      

  } /* END switch ( g_label ) */

  return(status);

} /* END notification_routine() */

/* This function loads/creates, initializes, and displays the login form. */

int PDUflag_form()
{
  int  sts = PDM_S_SUCCESS;

  PDUmessage(PDM_E_CLEAR_FIELD, 's');

  if (PDU_flag_form_created == TRUE)
    return(PDM_S_SUCCESS);

  PDU_flag_form_created = FALSE;
  PDU_flag_form_displayed = FALSE;
  PDU_flag_perm_window = FALSE;

  sts = FIf_new(FLAG_FORM, "flagopts", flag_notification_routine,
                &forms.flag_form_id);

  _pdm_debug("Creating flag form", 0);
  PDU_flag_form_created = TRUE;

  if (PDU_local_perm_window == TRUE)
    {
    _pdm_debug("converting form", 0);
    FIf_cvrt_to_perm_win(forms.flag_form_id);
    }

  /* Display the flag form and set the displayed flag to TRUE. */
  _pdm_debug("Displaying the flag form", 0);

  sts = FIf_display(forms.flag_form_id);
  PDU_flag_form_displayed = TRUE;

  return(PDM_S_SUCCESS);
}
