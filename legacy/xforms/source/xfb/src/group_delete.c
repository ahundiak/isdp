/***********************************

		group_delete.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
	05-07-92	sml		changed var type for ANSI
*/

/*************************************/
/* */
/* This file contains functions for the "group move" command. */
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

extern int Active_group;
extern int Single_select_flag;
extern int Pass_on_flag;

int Group_delete_total_gadgets;
int Group_delete_gdt_array[1000];
int Group_delete_display_array[1000];
int Group_delete_group;

extern int Delete_sequence_array[1000];
extern int Delete_data_link_array[1000];

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern int Total_gadgets;
extern struct seq_struct seq_list[1001];

extern Form work_form;
extern Form Message_form;
extern int command_is_active;
extern char current_command_string[80];

/*************************************************************************/
/* */
/* kill_group_delete() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to GROUP_DELETE indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_group_delete(void)
{
  char t_str[256];

  if (command_is_active == GROUP_DELETE)
  {
     command_is_active = 0;
     strcpy (current_command_string, "None");

     FIfld_set_text (Message_form, 11, 0, 0, "", 0);
     FIfld_set_text (Message_form, 22, 0, 0, "", 0);
     FIfld_set_text (Message_form, 44, 0, 0, "", 0);

     UMSGetByNum (t_str, FB_P_SELCOM, 0);
     FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

     if (work_form != NULL) /* Form already displayed */
     {
        FIf_set_builder_mode_off ((struct FIform_obj *)work_form);
     }
  }
}

/*-------------------------------------------------------------------*/


/*************************************************************************/
/* */
/* execute_group_delete() */
/* */
/* This function is called by the executive command handler routine. */
/* It changes values contained in the message windows and sets the */
/* builder mode to on for the work_form. As a result the gadgets will */
/* no longer change their state when poked. They will simply call their */
/* gadget notification routine. */
/* */
/*************************************************************************/

void execute_group_delete(void)
{
  char t_str[256];
  int status;
  int grp_gadget;
  int not_finished;
  int xsize, ysize, xpos, ypos;
  int attr;
  Window window;	/* changed from int to Window for ANSI */
  int display_flag, hilite_flag;
  int undelete_gadget;
  int accept_x, accept_y, mode;
  int x;
  int temp_group;
  int type;

  if (work_form == NULL)
  {
    command_is_active = 0;
    strcpy (current_command_string, "None");
  }
  else
  {
    UMSGetByNum (t_str, FB_I_GRPDELETE, 0);
    FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);

    Determine_current_gadgets();

    FIf_set_builder_mode_on ((struct FIform_obj *)work_form);

    not_finished = 1;
    FIf_get_window (work_form, &window);

    while (not_finished)
    {
      FIfld_set_text (Message_form, 44, 0, 0, "", 0);

      mode = 0; /* make operator enter data point */

      UMSGetByNum (t_str, FB_P_SELMEMGRP, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

      status = Select_gadget (&grp_gadget, &xsize, &ysize, &display_flag,
          &hilite_flag, &accept_x, &accept_y, mode);

      if (status == 2) /* Success */
      {
        status = FIg_get_group_label (work_form, grp_gadget, &Active_group);

        if (Active_group == 0)
        {
          /*********************************************************/
          /* */
          /* That gadget does not belong to a group, so allow the */
          /* operator to choose another gadget. */
          /* */
          /*********************************************************/

          UMSGetByNum (t_str, FB_E_NOTMEMGRP, 0);
          FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);

          if (hilite_flag == 0)
          {
            FIg_unhilite (work_form, grp_gadget);
          }

          if (display_flag == 0)
          {
            FIg_erase (work_form, grp_gadget);
          }
        }
        else
        {
          /*****************************************************/
          /* */
          /* The gadget belongs to a group, so first display */
          /* all gadgets that belong to the group in highlight */
          /* mode. Then make the user poke again to insure */
          /* that he really wants to delete the gadgets in */
          /* the group as well as the group itself. */
          /* */
          /*****************************************************/

          FIfld_set_text (Message_form, 22, 0, 0, "", 0);

          FIgrp_get_pass (work_form, Active_group, &Pass_on_flag);

          FIgrp_set_pass_on (work_form, Active_group);

          FIg_hilite (work_form, Active_group);

          FIg_display (work_form, Active_group);

          if (Pass_on_flag == 0)
          {
            FIgrp_set_pass_off (work_form, Active_group);
          }

          UMSGetByNum (t_str, FB_P_ACCREJGRPDEL, 0);
          FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

          status = Poke_plain_point (window, &xpos, &ypos);

          if (status == 2) /* success */
          {
            status = FIg_get_type (work_form, -3000, &type);

            if (status == FI_SUCCESS)
            {
              FIg_delete (work_form, Group_delete_group);

              for (x = 0; x < Group_delete_total_gadgets; x++)
              {
                FIg_delete (work_form, ((-3000) - x));
              }
            }

            Group_delete_total_gadgets = 0;

            for (x = 0; x < Total_gadgets; x++)
            {
              FIg_get_group_label (work_form, seq_list[x].gadget,
                  &temp_group);

              if (temp_group == Active_group)
              {
                if (seq_list[x].hilite_flag == 0)
                {
                  FIg_unhilite (work_form, seq_list[x].gadget);
                }

                Group_delete_display_array[Group_delete_total_gadgets] =
                    seq_list[x].display_flag;

                Group_delete_gdt_array[Group_delete_total_gadgets] =
                    seq_list[x].gadget;

                FIg_get_next_in_seq (work_form, seq_list[x].gadget,
                    &Delete_sequence_array[Group_delete_total_gadgets]);

                FIg_get_pass_data (work_form, seq_list[x].gadget,
                    &Delete_data_link_array[Group_delete_total_gadgets]);

                undelete_gadget = (-3000) - Group_delete_total_gadgets ;
                FIg_copy (work_form, seq_list[x].gadget,
                    &undelete_gadget, 0 );

                FIg_delete (work_form, seq_list[x].gadget);

                FIg_erase (work_form, (-3000) - Group_delete_total_gadgets);
                FIg_get_attr (work_form,
                    ((-3000) - Group_delete_total_gadgets),
                    &attr);

                attr |= FI_NOT_DISPLAYED;

                FIg_set_default_attr ((struct FIform_obj *)work_form,
                    ((-3000) - Group_delete_total_gadgets),
                    attr);

                Group_delete_total_gadgets++;
              }
            }
            FIg_delete (work_form, -4000);

            Group_delete_group = Active_group;

            undelete_gadget = -4000;
            FIg_copy (work_form, Active_group,
                &undelete_gadget, 0 );

            status = FIgrp_delete (work_form, Active_group);

            Redisplay (work_form);

            UMSGetByNum (t_str, FB_P_SELGDT, 0);
            FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
          }
          else
          {
            for (x = 0; x < Total_gadgets; x++)
            {
              FIg_get_group_label (work_form, seq_list[x].gadget,
                  &temp_group);

              if (temp_group == Active_group)
              {
                if (seq_list[x].hilite_flag == 0)
                {
                  FIg_unhilite (work_form, seq_list[x].gadget);
                }
                else
                {
                  FIg_hilite (work_form, seq_list[x].gadget);
                }

                if (seq_list[x].display_flag == 0)
                {
                  FIg_erase (work_form, seq_list[x].gadget);
                }
                else
                {
                  FIg_display (work_form, seq_list[x].gadget);
                }
              }
            }
          }
        }
      }
      else
      {
        not_finished = 0;
      }
    }

    kill_group_delete();
  }
}
