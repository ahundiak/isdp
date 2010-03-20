/***********************************

		 undelete_gdt.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
*/

/*************************************/
/* */
/* This file contains functions for the "undelete gadget" command. */
/* */
/* Programmer: Mack Draper */
/* Date: Apr. 20, 1989 */
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


/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

extern int Delete_gdt_display_flag;
extern int Delete_gdt_label;
extern int Delete_gdt_sequence_label;
extern int Delete_gdt_data_link_label;
extern int Delete_gdt_group_label;

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern Form work_form;
extern Form Message_form;
extern int command_is_active;
extern char current_command_string[80];

/*************************************************************************/
/* */
/* kill_undelete_gadget() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to MOVE_GADGET indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_undelete_gadget(void)
{
  char t_str[256];

  command_is_active = 0;
  strcpy (current_command_string, "None");

  FIfld_set_text (Message_form, 11, 0, 0, "", 0);
  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  UMSGetByNum (t_str, FB_P_SELCOM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}

/*************************************************************************/
/* */
/* execute_undelete_gadget() */
/* */
/* This function is called by the executive command handler routine. */
/* */
/*************************************************************************/

void execute_undelete_gadget(void)
{
  char t_str[256];
  int status;
  int attr;
  int type;


  if (work_form == NULL)
  {
    kill_undelete_gadget();
  }
  else
  {
    UMSGetByNum (t_str, FB_I_UNDELGDT, 0);
    FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
    UMSGetByNum (t_str, FB_I_UNDELGDT, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    status = FIg_get_type (work_form, -1000, &type);

    if (status == FI_SUCCESS)
    {
      FIg_erase (work_form, Delete_gdt_label);
      FIg_delete (work_form, Delete_gdt_label);

      FIg_copy (work_form, -1000, & Delete_gdt_label, 0);
      FIg_delete (work_form, -1000);

      if (Delete_gdt_display_flag == 1)
      {
        FIg_display (work_form, Delete_gdt_label);
        FIg_get_attr (work_form, Delete_gdt_label, &attr);
        FIg_set_default_attr ((struct FIform_obj *)work_form, Delete_gdt_label, attr);
      }

      FIg_set_next_in_seq (work_form, Delete_gdt_label,
          Delete_gdt_sequence_label);

      FIg_set_pass_data (work_form, Delete_gdt_label,
          Delete_gdt_data_link_label);

      FIg_add_to_group (work_form, Delete_gdt_label,
          Delete_gdt_group_label);

      Redisplay (work_form);
    }

    kill_undelete_gadget();
  }
}
