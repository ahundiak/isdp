/***********************************

		delete_lnk.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
*/

/*************************************/
/* */
/* This file contains functions for the "delete data link" command. */
/* */
/* Programmer: Mack Draper */
/* Date: Apr. 4, 1989 */
/* */
/*************************************/


#include <stdio.h>

#include <X11/Xlib.h>

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

extern int Next_line_gadget_label;
extern int Total_gadgets;
extern int Next_in_sequence;
extern struct seq_struct seq_list[1001];

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
/* kill_delete_data_link() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to DELETE_LNK indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_delete_data_link(void)
{
  char t_str[256];

  if (command_is_active == DELETE_DATA_LINK)
  {
     command_is_active = 0;
     strcpy (current_command_string, "None");

     FIfld_set_text (Message_form, 11, 0, 0, "", 0);
     FIfld_set_text (Message_form, 44, 0, 0, "", 0);
     UMSGetByNum (t_str, FB_P_SELCOM, 0);
     FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

     if (work_form != NULL) /* Form already displayed */
     {
        FIf_set_builder_mode_off ((struct FIform_obj *)work_form);
     }
  }
}

/*--------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* execute_delete_data_link() */
/* */
/* This function is called by the executive command handler routine. */
/* It changes values contained in the message windows and sets the */
/* builder mode to on for the work_form. As a result the gadgets will */
/* no longer change their state when poked. They will simply call their */
/* gadget notification routine. */
/* */
/*************************************************************************/

void execute_delete_data_link(void)
{
  char t_str[256];
  int status;
  int seq_gadget;
  int not_finished, continue_inner_loop;
  int xsize, ysize, xpos, ypos;
  Window window;		/* change from Window to int for ANSI */
  int display_flag, hilite_flag;
  int accept_x, accept_y, mode;
  int x;
  int gadget_index = 0;

  if (work_form == NULL)
  {
    kill_delete_data_link();
  }
  else
  {
    UMSGetByNum (t_str, FB_I_DELDATLNK, 0);
    FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
    UMSGetByNum (t_str, FB_I_DISPDATLNK, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    Determine_current_data_links();

    Display_current_sequences();

    FIf_set_builder_mode_on ((struct FIform_obj *)work_form);

    not_finished = 1;
    FIf_get_window (work_form, &window);

    while (not_finished)
    {
      mode = 0; /* make operator enter data point */

      UMSGetByNum (t_str, FB_P_SELORGLNK, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

      status = Select_gadget (&seq_gadget, &xsize, &ysize, &display_flag,
          &hilite_flag, &accept_x, &accept_y, mode);

      FIfld_set_text (Message_form, 22, 0, 0, "", 0);

      if (status == 2) /* Success */
      {
        FIg_get_pass_data (work_form, seq_gadget, &Next_in_sequence);

        if (Next_in_sequence <= 0)
        {
          UMSGetByNum (t_str, FB_E_NOTLNKED, 0);
          FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);

          FIg_unhilite (work_form, seq_gadget);
        }
        else
        {
          continue_inner_loop = 1;

          while (continue_inner_loop)
          {
            for (x = 0; x < Total_gadgets; x++)
            {
              if (seq_list[x].gadget == seq_gadget)
              {
                gadget_index = x;
                break;
              }
            }

            seq_list[gadget_index].line_color = FI_RED;
            Paint_arrow (gadget_index);

            UMSGetByNum (t_str, FB_P_ACCREJLNK, 0);
            FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

            status = Poke_plain_point (window, &xpos, &ypos);

            FIg_unhilite (work_form, seq_gadget);

            if (status == 2) /* success */
            {
              seq_list[gadget_index].line_color = FI_LT_GREY;
              Paint_arrow (gadget_index);

              seq_list[gadget_index].to_gadget = 0;

              FIg_set_pass_data (work_form, seq_gadget, -1);

              for (x = 0; x < Total_gadgets; x++)
              {
                if (seq_list[x].gadget == Next_in_sequence)
                {
                  gadget_index = x;
                  break;
                }
              }

              seq_gadget = Next_in_sequence;

              FIg_get_pass_data (work_form, seq_gadget, 
                  &Next_in_sequence);

              if (Next_in_sequence != -1)
              {
                FIg_hilite (work_form, seq_gadget);
              }
              else
              {
                continue_inner_loop = 0;
              }
            }
            else
            {
              seq_list[gadget_index].line_color = FI_YELLOW;
              Paint_arrow (gadget_index);

              continue_inner_loop = 0;
            }
          }
        }
      }
      else
      {
        not_finished = 0;
      }
    }

    kill_delete_data_link();
    Clean_up_lines ();
  }
}
