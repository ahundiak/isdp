/***********************************

		fence_undel.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
*/

/*************************************/
/* */
/* This file contains functions for the "fence undelete" command. */
/* */
/* Programmer: Mack Draper */
/* Date: Apr. 7, 1989 */
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

extern int Fence_delete_total_gadgets;
extern int Fence_delete_gdt_array[1000];
extern int Fence_delete_display_array[1000];

extern int Delete_sequence_array[1000];
extern int Delete_data_link_array[1000];
extern int Delete_group_array[1000];

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
/* kill_fence_undelete() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to FENCE_UNDELETE indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_fence_undelete(void)
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
/* execute_fence_undelete() */
/* */
/* This function is called by the executive command handler routine. */
/* */
/*************************************************************************/

void execute_fence_undelete(void)
{
  char t_str[256];
  int status;
  int attr;
  int x, type;


  if (work_form == NULL)
  {
    kill_fence_undelete();
  }
  else
  {
    UMSGetByNum (t_str, FB_I_FCEUNDEL, 0);
    FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
    UMSGetByNum (t_str, FB_I_UNDELFCE, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    status = FIg_get_type (work_form, -2000, &type);

    if (status == FI_SUCCESS)
    {
      for (x = 0; x < Fence_delete_total_gadgets; x++)
      {
        FIg_erase (work_form, Fence_delete_gdt_array[x]);
        FIg_delete (work_form, Fence_delete_gdt_array[x]);

        FIg_copy (work_form, ((-2000) - x), & Fence_delete_gdt_array[x], 0 );

        FIg_delete (work_form, ((-2000) - x));

        FIg_get_attr (work_form, Fence_delete_gdt_array[x], &attr);
        FIg_set_default_attr ((struct FIform_obj *)work_form, Fence_delete_gdt_array[x], attr);

        if (Fence_delete_display_array[x] == 1)
          FIg_display (work_form, Fence_delete_gdt_array[x]);

        FIg_set_next_in_seq (work_form, Fence_delete_gdt_array[x],
            Delete_sequence_array[x]);

        FIg_set_pass_data (work_form, Fence_delete_gdt_array[x],
            Delete_data_link_array[x]);

        FIg_add_to_group (work_form, Fence_delete_gdt_array[x],
            Delete_group_array[x]);
      }
    }
    kill_fence_undelete();
  }
}
