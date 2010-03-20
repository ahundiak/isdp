/***********************************

		place_cbar.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
*/

/*************************************/
/* */
/* This file contains functions for the "place cbar" command. */
/* */
/* Programmer: Mack Draper */
/* Date: Jan. 9, 1988 */
/* */
/*************************************/

#include <stdio.h>

#include "FI.h"
#include "FIdyn.h"
#include "NFBpriv.h"
#include "UMS.h"
#include "FB.h"

#include "XFIproto_pub.h"
#include "XFBproto_pri.h"


/*********************************/
/* */
/* Gadget labels for cbar form */
/* */
/*********************************/

#define CANCEL 4
#define HELP 6
#define ACCEPT 1

/***********************/
/* */
/* used by cbar form */
/* */
/***********************/

#define HELP_BTN 12
#define CONVERT_BTN 13
#define CANCEL_BTN 14
#define REVERT_BTN 15
#define EXECUTE_BTN 16
#define ACCEPT_BTN 17

#define ERR_FLD 10

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

Form Cbar_form = NULL;

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern struct form_data form_attr;
extern Form work_form;
extern struct dpb_struct dpb;
extern int command_is_active;
extern char current_command_string[80];
extern struct gadget_struct gadget_attr;
extern char execute_dir[200];

extern char language[80];
extern Form Message_form;

/*************************************************************************/
/* */
/* kill_place_cbar() */
/* */
/* This function will be called by the executive. Three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to PLACE_CBAR indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_place_cbar(void)
{
  char t_str[256];

  if (Cbar_form != NULL)
    FIf_erase (Cbar_form);

  command_is_active = 0;
  strcpy (current_command_string, "None");

  FIfld_set_text (Message_form, 11, 0, 0, "", 0);

  UMSGetByNum (t_str, FB_P_SELCOM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}

/*********************************************************************/
/* */
/* create_control_gadget() */
/* */
/* This function creates a new cbar gadget and places it at */
/* the upper right hand corner of the work form. */
/* */
/*********************************************************************/

static void create_control_gadget (int x_position,
                                   int gadget_number)
{
  int status;

  Set_new_gadget_defaults();

  gadget_attr.text_gadget = 0;
  gadget_attr.off_color = dpb.off_color;
  gadget_attr.on_color = dpb.on_color;
  gadget_attr.default_value = 0;
  strcpy (gadget_attr.font_name, "FIsym");

  switch (gadget_number)
  {
  case FI_ACCEPT:
    gadget_attr.off_sym_index = 11;
    break;

  case FI_EXECUTE:
    gadget_attr.off_sym_index = 10;
    break;

  case FI_RESET:
    gadget_attr.off_sym_index = 9;
    break;

  case FI_CANCEL:
    gadget_attr.off_sym_index = 8;
    break;

  case FI_CVT_TO_PERM_WIN:
    gadget_attr.off_sym_index = 13;
    break;

  case FI_HELP:
    gadget_attr.off_sym_index = 12;
    break;
  }

  gadget_attr.x_pos = x_position;
  gadget_attr.y_pos = 5;
  gadget_attr.x_size = x_position + 30;
  gadget_attr.y_size = 35;

  Create_and_init_gadget (work_form, FI_BUTTON, gadget_number);

  if ((gadget_number != FI_ACCEPT) && (gadget_number != FI_CANCEL))
    FIbtn_set_auto_pop_up_on (work_form, gadget_number);
  else
    FIbtn_set_auto_pop_up_off (work_form, gadget_number);

  FIg_activate (work_form, gadget_number);

  status = FIg_display (work_form, gadget_number);
}

/*********************************************************************/
/* */
/* create_cbar_gadgets() */
/* */
/* This function creates new cbar gadgets and places them at */
/* the upper right hand corner of the work form. */
/* */
/*********************************************************************/

create_cbar_gadgets(void)
{
  int button_count;
  int state;
  int x_size, y_size;
  int first_x;

  /******************************************************************/
  /* */
  /* First kill all existing control bar buttons on the work form */
  /* */
  /******************************************************************/

  FIg_delete (work_form, 1);
  FIg_delete (work_form, 2);
  FIg_delete (work_form, 3);
  FIg_delete (work_form, 4);
  FIg_delete (work_form, 5);
  FIg_delete (work_form, 6);

  /**********************************************************/
  /* */
  /* Determine how many control buttons need to be placed */
  /* */
  /**********************************************************/

  button_count = 0;

  FIg_get_state (Cbar_form, HELP_BTN, &state);
  button_count += state;

  FIg_get_state (Cbar_form, CONVERT_BTN, &state);
  button_count += state;

  FIg_get_state (Cbar_form, CANCEL_BTN, &state);
  button_count += state;

  FIg_get_state (Cbar_form, REVERT_BTN, &state);
  button_count += state;

  FIg_get_state (Cbar_form, EXECUTE_BTN, &state);
  button_count += state;

  FIg_get_state (Cbar_form, ACCEPT_BTN, &state);
  button_count += state;

  /********************************************/
  /* */
  /* Now calculate at what X location to begin placing buttons */
  /* */
  /********************************************/

  FIf_get_size (work_form, &x_size, &y_size);

  first_x = x_size - 5 - (button_count * 30);

  /***************************************************************/
  /* */
  /* Create button gadgets for each selected control bar option */
  /* */
  /***************************************************************/

  FIg_get_state (Cbar_form, HELP_BTN, &state);
  if (state)
  {
    create_control_gadget (first_x, 6);
    first_x += 30;
    FIg_add_to_group (work_form, 6, FI_CTRL_GROUP);
  }

  FIg_get_state (Cbar_form, CONVERT_BTN, &state);
  if (state)
  {
    create_control_gadget (first_x, 5);
    first_x += 30;
    FIg_add_to_group (work_form, 5, FI_CTRL_GROUP);
  }

  FIg_get_state (Cbar_form, CANCEL_BTN, &state);
  if (state)
  {
    create_control_gadget (first_x, 4);
    first_x += 30;
    FIg_add_to_group (work_form, 4, FI_CTRL_GROUP);
  }

  FIg_get_state (Cbar_form, REVERT_BTN, &state);
  if (state)
  {
    create_control_gadget (first_x, 3);
    first_x += 30;
    FIg_add_to_group (work_form, 3, FI_CTRL_GROUP);
  }

  FIg_get_state (Cbar_form, EXECUTE_BTN, &state);
  if (state)
  {
    create_control_gadget (first_x, 2);
    first_x += 30;
    FIg_add_to_group (work_form, 2, FI_CTRL_GROUP);
  }

  FIg_get_state (Cbar_form, ACCEPT_BTN, &state);
  if (state)
  {
    create_control_gadget (first_x, 1);
    first_x += 30;
    FIg_add_to_group (work_form, 1, FI_CTRL_GROUP);
  }
}

/*-----------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* fi_cbar_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to select the control bar */
/* options that he wants to appear in the the work form. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_cbar_form (int form_label,
                  int gadget_label,
                  double value,
                  Form form_ptr)
{
  int status;
  char t_str[256];

  FIg_erase (Cbar_form, ERR_FLD);

  switch (gadget_label)
  {
  case CONVERT_BTN:

    if (form_attr.sr_flag != 1)
    {
      UMSGetByNum (t_str, FB_E_CONVONSR, 0);
      print_error (Cbar_form, ERR_FLD, t_str);
      FIg_set_state_off (Cbar_form, CONVERT_BTN);
    }
    break;

  case HELP:

    /* Help_topic ("Cbar") */
    break;

  case CANCEL:

    kill_place_cbar();
    FIg_set_state_off (Cbar_form, FI_CANCEL);
    break;

  case ACCEPT:

    status = FIf_erase (Cbar_form);
    FIg_set_state_off (Cbar_form, FI_ACCEPT);

    create_cbar_gadgets();

    FIf_calculate_size ((struct FIform_obj *)work_form);

    kill_place_cbar();
    break;
  }

  return;
}

/*************************************************************************/
/* */
/* execute_place_cbar() */
/* */
/* This function is called by the executive command handler routine. */
/* */
/* It displays the place cbar form then exits. After that point */
/* the fi_cbar_form() gadget notification routine will be in control. */
/* That is to say, every time the operator alters a gadget on */
/* the cbar form, the fi_cbar_form() function will be invoked. */
/* */
/*************************************************************************/

void execute_place_cbar(void)
{
  char t_str[256];
  int state, status;
  int any_buttons_exist;

  if (work_form == NULL) /* No form defined */
  {
    strcpy (current_command_string, "None");
    command_is_active = 0;
    return;
  }

  UMSGetByNum (t_str, FB_I_PCECNTLBUT, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENDEF, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  status = FIg_get_type (work_form, FI_CTRL_GROUP, &state);

  if (status != FI_SUCCESS)
    FIg_new (work_form, FI_GROUP, FI_CTRL_GROUP);

  if (Cbar_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlCnBar");
    status = FIf_new (133, t_str, (int (*)())fi_cbar_form, &Cbar_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  /*************************************************************************/
  /* */
  /* Select control bar buttons that match the ones already placed on the */
  /* work form. If none are present, then select default options of the */
  /* cancel and accept buttons. Help button used to be a default but not */
  /* anymore. */
  /* */
  /*************************************************************************/

  FIg_set_state_off (Cbar_form, HELP_BTN);
  FIg_set_state_off (Cbar_form, CONVERT_BTN);
  FIg_set_state_off (Cbar_form, CANCEL_BTN);
  FIg_set_state_off (Cbar_form, REVERT_BTN);
  FIg_set_state_off (Cbar_form, EXECUTE_BTN);
  FIg_set_state_off (Cbar_form, ACCEPT_BTN);

  any_buttons_exist = 0;

  status = FIg_get_type (work_form, 1, &state);
  if (status == FI_SUCCESS)
  {
    FIg_set_state_on (Cbar_form, ACCEPT_BTN);
    any_buttons_exist = 1;
  }

  status = FIg_get_type (work_form, 2, &state);
  if (status == FI_SUCCESS)
  {
    FIg_set_state_on (Cbar_form, EXECUTE_BTN);
    any_buttons_exist = 1;
  }

  status = FIg_get_type (work_form, 3, &state);
  if (status == FI_SUCCESS)
  {
    FIg_set_state_on (Cbar_form, REVERT_BTN);
    any_buttons_exist = 1;
  }

  status = FIg_get_type (work_form, 4, &state);
  if (status == FI_SUCCESS)
  {
    FIg_set_state_on (Cbar_form, CANCEL_BTN);
    any_buttons_exist = 1;
  }

  status = FIg_get_type (work_form, 5, &state);
  if (status == FI_SUCCESS)
  {
    FIg_set_state_on (Cbar_form, CONVERT_BTN);
    any_buttons_exist = 1;
  }

  status = FIg_get_type (work_form, 6, &state);
  if (status == FI_SUCCESS)
  {
    FIg_set_state_on (Cbar_form, HELP_BTN);
    any_buttons_exist = 1;
  }

  if (any_buttons_exist == 0) /* Assign default control bar buttons */
  {
    FIg_set_state_on (Cbar_form, CANCEL_BTN);
    FIg_set_state_on (Cbar_form, ACCEPT_BTN);
  }

  FIg_erase (Cbar_form, 10);

  FIf_display (Cbar_form);

  UMSGetByNum (t_str, FB_P_FILLCNTLBUT, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}
