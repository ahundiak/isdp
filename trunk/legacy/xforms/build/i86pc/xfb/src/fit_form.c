/***********************************

		fit_form.c

***********************************/

/*
  History
	04-28-92	sml		ANSI-ized; initialized some vars
	05-07-92	sml		casted func args for ANSI
*/

/********************************/
/* */
/* These functions set the margin for the current work_form. */
/* */
/* Programmer: Mack Draper */
/* */
/* Date: Jan. 29, 1989 */
/* */
/********************************/

#include <stdio.h>

#include "FI.h"
#include "NFBpriv.h"
#include "UMS.h"
#include "FB.h"

#include "XFIproto_pub.h"
#include "XFBproto_pri.h"

#define MARGIN_FLD 14
#define ERR_FLD 10

/* Used in Control Bar form */

#define HELP_BTN      12
#define CONVERT_BTN   13
#define CANCEL_BTN    14
#define REVERT_BTN    15
#define EXECUTE_BTN   16
#define ACCEPT_BTN    17

extern Form work_form;
extern Form Message_form;
extern char current_command_string[80];
extern int command_is_active;
extern char dir[256];
extern char execute_dir[200];

extern char language[80];
extern Form Cbar_form;

static Form Fit_form = NULL;
static int global_margin;

/*------------------------------------------------------------------------*/

void kill_fit_form(void)
{
  char t_str[256];

  if (Fit_form != NULL)
    FIf_erase (Fit_form);

  FIfld_set_text (Message_form, 11, 0, 0, "", 0);

  UMSGetByNum (t_str, FB_P_SELCOM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  command_is_active = 0;
  strcpy (current_command_string, "None");
}

/*------------------------------------------------------------------------*/
/*************************************************************************/
/* */
/* fi_fit_form() */
/* */
/* This routine allows you to set the margin of the form which is */
/* about to be fitted. */
/* */
/* Control Bar gadgets and message field gadgets screw up the fit */
/* algorithm, so the following steps are taken to prevent this. */
/* */
/* First a note is made of all control bar buttons. Then all control */
/* bar buttons are erased. Next the exact centerpoint of the form is */
/* calculated. Then all Control bar buttons are moved so that their */
/* centerpoint matches the form's centerpoint. */
/* */
/* Next a note is made of all message fields prior to erasing them. */
/* The message fields are then reduced to one character in length. Then */
/* they are moved so that their centerpoint aligns with the centerpoint */
/* of the form. At this point the fit form operation is performed. */
/* */
/* Now the control bar buttons are repositioned based on the new size */
/* of the form. They are then redisplayed. For message fields the new */
/* message field size is calculated based on the new form size. Then */
/* the message fields are moved to their new location and re-displayed */
/* if necessary. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_fit_form (int form_label,
                 int gadget_label,
                 double value,
                 Form form_ptr)
{
  char t_str[256];
  int status;
  int i, x, type;
  int xsize, ysize;
/*  int center_x, center_y;		NOT USED */
  int display9_flag = 0;
  int display10_flag = 0;
  int control_gdt[11];
  int button_count, first_x;
  int attr;
  int dummy_int;

  FIg_erase (Fit_form, ERR_FLD);

  switch (gadget_label)
  {
  case FI_HELP:
    break;

  case FI_CANCEL:

    kill_fit_form();
    FIg_set_state_off (Fit_form, FI_CANCEL);
    break;

  case FI_ACCEPT:

    FIf_erase (Fit_form);
    FIg_set_state_off (Fit_form, FI_ACCEPT);

    for (x = 1; x <= 6; x++)
    {
      status = FIg_get_type (work_form, x, &type);
      if (status == FI_SUCCESS)
      {
        control_gdt[x] = 1;
        FIg_delete (work_form, x);
      }
      else
        control_gdt[x] = 0;
    }

    for (x = 9; x <= 10; x++)
    {
      status = FIg_get_type (work_form, x, &type);
      if (status == FI_SUCCESS)
      {
        control_gdt[x] = 1;

        FIg_get_attr (work_form, x, &attr);
        if (attr & FI_NOT_DISPLAYED)
        {
          if (x == 9)
            display9_flag = 0;
          else
            display10_flag = 0;
        }
        else
        {
          if (x == 9)
            display9_flag = 1;
          else
            display10_flag = 1;
        }
        FIg_erase (work_form, x);
        FIg_delete (work_form, x);
      }
      else
        control_gdt[x] = 0;
    }

    FIf_calculate_size ((struct FIform_obj *)work_form);

    FIf_fit_to_gadgets ((struct FIform_obj *)work_form, global_margin);

    FIf_calculate_size ((struct FIform_obj *)work_form);

    /************************************************************/
    /* */
    /* Now restore control bar buttons to their proper position */
    /* */
    /************************************************************/

    button_count = 0;

    for (x = 1; x <= 6; x++)
      if (control_gdt[x] == 1)
        button_count++;

    /***************************************************************/
    /* */
    /* Now calculate at what X location to begin placing buttons */
    /* */
    /***************************************************************/

    FIf_get_size (work_form, &xsize, &ysize);

    first_x = xsize - 5 - (button_count * 30);

    /********************************************************/
    /* */
    /* Move control bar buttons to their proper locations */
    /* */
    /********************************************************/

    for (x = 6; x > 0; x--)
      if (control_gdt[x] == 1)
      {
        FIg_set_location (work_form, x, first_x, 5);
        first_x += 30;
        FIg_display (work_form, x);
        FIg_add_to_group (work_form, x, FI_CTRL_GROUP);
      }

         /* Insure that Cbar_form exists */

         if (Cbar_form == NULL)
         {
            strcpy (t_str, execute_dir);
            strcat (t_str, "/config/");
            strcat (t_str, language);
            strcat (t_str, "/forms/FBPlCnBar");
            status = FIf_new (133, t_str, (int (*)())fi_cbar_form, &Cbar_form);

            if (status != 0)
               Report_fatal_form_error (status, t_str);
         }         

    /* Now set the state of the buttons on the Cbar_form   */
    /* to match whether or not the buttons existed on the  */
    /* work_form before they were deleted.                 */

         FIg_set_state (Cbar_form, ACCEPT_BTN,  control_gdt[1]);
         FIg_set_state (Cbar_form, EXECUTE_BTN, control_gdt[2]);
         FIg_set_state (Cbar_form, REVERT_BTN,  control_gdt[3]);
         FIg_set_state (Cbar_form, CANCEL_BTN,  control_gdt[4]);
         FIg_set_state (Cbar_form, CONVERT_BTN, control_gdt[5]);
         FIg_set_state (Cbar_form, HELP_BTN,    control_gdt[6]);

    /* Calling the create_cbar_gadgets function will re-create the  */
    /* control bar gadgets in their proper location.                */

    create_cbar_gadgets();

    /**************************************************/
    /* */
    /* Move Message fields to their proper locations */
    /* after adjusting size */
    /* */
    /**************************************************/

    if ((control_gdt[9] == 1) || (control_gdt[10] == 1))
    {
      execute_place_err_msg_flds();

      if (control_gdt[9] == 0)
      {
        FIg_erase (work_form, 9);
        FIg_delete (work_form, 9);
      }
      else
        if (display9_flag == 0)
          FIg_erase (work_form, 9);

      if (control_gdt[10] == 0)
      {
        FIg_erase (work_form, 10);
        FIg_delete (work_form, 10);
      }
      else
        if (display10_flag == 0)
          FIg_erase (work_form, 10);
    }

    kill_fit_form();
    break;

  case MARGIN_FLD:

    /* Find out what the operator just typed in */

    FIfld_get_text (Fit_form, MARGIN_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Fit_form, ERR_FLD, &status);

    if (status)
      if (i > 0)
        global_margin = i;
      else
      {
        UMSGetByNum (t_str, FB_E_MUSTGTZERO, 0);
        print_error (Fit_form, ERR_FLD, t_str);
      }
    break;
  }

  return;
}

/*************************************************************************/

void execute_fit_form(void)
{
  int status;
  char t_str[256];

  if (work_form == NULL)
  {
    command_is_active = 0;
    strcpy (current_command_string, "None");
  }
  else
  {
    UMSGetByNum (t_str, FB_I_FITFORM, 0);
    FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
    FIfld_set_text (Message_form, 33, 0, 0, "", 0);

    if (Fit_form == NULL)
    {
      strcpy (t_str, execute_dir);
      strcat (t_str, "/config/");
      strcat (t_str, language);
      strcat (t_str, "/forms/FBFitFrm");
      status = FIf_new (100, t_str, (int (*)())fi_fit_form, &Fit_form);

      if (status != FI_SUCCESS)
        Report_fatal_form_error (status, t_str);
    }

    FIg_set_state_off (Fit_form, FI_ACCEPT);
    FIg_set_state_off (Fit_form, FI_CANCEL);
    FIg_erase (Fit_form, 10); /* Error field */
    FIfld_set_text (Fit_form, MARGIN_FLD, 0, 0, "15", 0);

    global_margin = 15;

    FIf_display (Fit_form);

    UMSGetByNum (t_str, FB_P_FILLFIT, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
  }
}
