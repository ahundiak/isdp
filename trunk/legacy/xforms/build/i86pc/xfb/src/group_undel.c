/***********************************

		group_undel.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
*/

/*************************************/
/* */
/* This file contains functions for the "group undelete" command. */
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

extern int Active_group;
extern int Single_select_flag;
extern int Pass_on_flag;

extern int Group_delete_total_gadgets;
extern int Group_delete_gdt_array[1000];
extern int Group_delete_display_array[1000];
extern int Group_delete_group;

extern int Delete_sequence_array[1000];
extern int Delete_data_link_array[1000];

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern int Total_gadgets;

extern Form work_form;
extern Form Message_form;
extern int command_is_active;
extern char current_command_string[80];

/*************************************************************************/
/* */
/* kill_group_undelete() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to GROUP_UNDELETE indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_group_undelete(void)
{
  char t_str[256];

  command_is_active = 0;
  strcpy (current_command_string, "None");

  FIfld_set_text (Message_form, 11, 0, 0, "", 0);

  UMSGetByNum (t_str, FB_P_SELCOM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}

/*-------------------------------------------------------------------*/


/*************************************************************************/
/* */
/* execute_group_undelete() */
/* */
/*************************************************************************/

void execute_group_undelete(void)
{
  char t_str[256];
  int status;
  int attr;
  int x;
  int type;

  if (work_form == NULL)
  {
    command_is_active = 0;
    strcpy (current_command_string, "None");
  }
  else
  {
    UMSGetByNum (t_str, FB_I_GRPUNDEL, 0);
    FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
    FIfld_set_text (Message_form, 33, 0, 0, "", 0);

    status = FIg_get_type (work_form, -3000, &type);

    if (status == FI_SUCCESS)
    {
      FIg_delete (work_form, Group_delete_group);

      FIg_copy (work_form, -4000, & Group_delete_group, 0 );

      FIg_delete (work_form, -4000);

      for (x = 0; x < Group_delete_total_gadgets; x++)
      {
        FIg_erase (work_form, Group_delete_gdt_array[x]);
        FIg_delete (work_form, Group_delete_gdt_array[x]);
        FIg_copy (work_form, ((-3000) - x), & Group_delete_gdt_array[x], 0);
        FIg_delete (work_form, ((-3000) - x));
        if (Group_delete_display_array[x] == 1)
          FIg_display (work_form, Group_delete_gdt_array[x]);
        FIg_get_attr (work_form, Group_delete_gdt_array[x], &attr);
        FIg_set_default_attr ((struct FIform_obj *)work_form, Group_delete_gdt_array[x], attr);
        FIg_add_to_group (work_form, Group_delete_gdt_array[x],
            Group_delete_group);

        FIg_set_next_in_seq (work_form, Group_delete_gdt_array[x],
            Delete_sequence_array[x]);

        FIg_set_pass_data (work_form, Group_delete_gdt_array[x],
            Delete_data_link_array[x]);
      }
    }

    kill_group_undelete();
  }
}
