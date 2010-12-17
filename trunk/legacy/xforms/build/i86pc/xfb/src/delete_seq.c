/***********************************

		delete_seq.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
*/

/*************************************/
/* */
/* This file contains functions for the "delete sequence" command. */
/* */
/* Programmer: Mack Draper */
/* Date: Apr. 2, 1989 */
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
/* kill_delete_sequence() */
/* */
/*************************************************************************/

void kill_delete_sequence(void)
{
  char t_str[256];

  if (command_is_active == DELETE_SEQUENCE)
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

/*--------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* execute_delete_sequence() */
/* */
/* This function is called by the executive command handler routine. */
/* It changes values contained in the message windows and sets the */
/* builder mode to on for the work_form. As a result the gadgets will */
/* no longer change their state when poked. They will simply call their */
/* gadget notification routine. */
/* */
/*************************************************************************/

void execute_delete_sequence(void)
{
  char t_str[256];
  int status;
  int seq_gadget;
  int not_finished, continue_inner_loop;
  int xsize, ysize, xpos, ypos;
  Window window;	/* change from int to Window for ANSI */
  int display_flag, hilite_flag;
  int accept_x, accept_y, mode;
  int x;
  int gadget_index = 0;

  if (work_form == NULL)
  {
    kill_delete_sequence();
  }
  else
  {
    UMSGetByNum (t_str, FB_I_DELSEQ, 0);
    FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
    UMSGetByNum (t_str, FB_I_DISPCURSEQ, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    Determine_current_sequences();

    Display_current_sequences ();

    FIf_set_builder_mode_on ((struct FIform_obj *)work_form);

    not_finished = 1;
    FIf_get_window (work_form, &window);

    while (not_finished)
    {
      mode = 0; /* make operator enter data point */

      UMSGetByNum (t_str, FB_I_SELSTARTGDT, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

      Refresh_lines();

      status = Select_gadget (&seq_gadget, &xsize, &ysize,
          &display_flag, &hilite_flag, &accept_x, &accept_y, mode);

      FIfld_set_text (Message_form, 22, 0, 0, "", 0);

      if (status == 2) /* Success */
      {
        FIg_get_next_in_seq (work_form, seq_gadget, &Next_in_sequence);

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

                seq_list[x].line_color = FI_RED;
                Paint_arrow (x);

                break;
              }
            }

            UMSGetByNum (t_str, FB_P_ACCREJLNK, 0);
            FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

            status = Poke_plain_point (window, &xpos, &ypos);

            if (status == 2) /* success */
            {
              for (x = 0; x < Total_gadgets; x++)
              {
                if (seq_list[x].gadget == seq_gadget)
                {
                  FIg_display (work_form, seq_list[x].gadget);
                  FIg_display (work_form, seq_list[x].to_gadget);
                
                  seq_list[x].line_color = FI_LT_GREY;
                  Paint_arrow (x);
                
                  seq_gadget = seq_list[x].to_gadget;
                  seq_list[x].to_gadget = 0;
                  FIg_set_next_in_seq (work_form, seq_list[x].gadget, 0);

                  if (seq_gadget <= 0)
                  {
                    continue_inner_loop = 0;
                  }
                
                  Refresh_lines();
                  break;
                }
              }
            }
            else
            {
              for (x = 0; x < Total_gadgets; x++)
              {
                if (seq_list[x].gadget == seq_gadget)
                {
                  FIg_display (work_form, seq_list[x].gadget);
                  FIg_display (work_form, seq_list[x].to_gadget);
                  seq_list[x].line_color = FI_YELLOW;
                  Paint_arrow (x);
                
                  continue_inner_loop = 0;
                  break;
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

    kill_delete_sequence();
    Clean_up_lines();
  }
}
