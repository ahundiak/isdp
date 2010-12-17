/***********************************

		group_copy.c

***********************************/

/*
  History
	04-28-92	sml		ANSI-ized; initialized some vars
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

extern int Active_group;
extern int Pass_on_flag;


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

extern Display *display;

/*************************************************************************/
/* */
/* kill_group_copy() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to GROUP_COPY indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_group_copy(void)
{
  char t_str[256];

  if (command_is_active == GROUP_COPY)
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
/* execute_group_copy() */
/* */
/* This function is called by the executive command handler routine. */
/* It changes values contained in the message windows and sets the */
/* builder mode to on for the work_form. As a result the gadgets will */
/* no longer change their state when poked. They will simply call their */
/* gadget notification routine. */
/* */
/*************************************************************************/

void execute_group_copy(void)
{
  char t_str[256];
  int status;
  int grp_gadget;
  /* sml:04-29-92	initialize new_gadget to avoid ANSI warning */
  int new_gadget = -100;
  int not_finished;
  int xsize, ysize, xpos, ypos;
  Window window;
  int display_flag, hilite_flag;
  int offset_x, offset_y;
  int gadget_type;
  int index;
  char symbol_file[200];
  char font_name[200];
  char off_text[50000];
  float bodysize;
  int accept_x, accept_y, mode;
  int x;
  int temp_group;
  int save_xpos, save_ypos;
  int delta_x, delta_y;
  int copy_has_been_done;
  int new_gadget_array[1000];

  int justify;

  if (work_form == NULL)
  {
    command_is_active = 0;
    strcpy (current_command_string, "None");
  }
  else
  {
    UMSGetByNum (t_str, FB_I_GRPCPY, 0);
    FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);

    Determine_current_gadgets();

    FIf_set_builder_mode_on ((struct FIform_obj *)work_form);

    not_finished = 1;
    FIf_get_window (work_form, &window);

    while (not_finished)
    {
      mode = 0; /* make operator enter data point */

      UMSGetByNum (t_str, FB_P_SELMEMGRP, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

      status = Select_gadget (&grp_gadget, &xsize, &ysize, &display_flag,
          &hilite_flag, &accept_x, &accept_y, mode);

      if (status == 2) /* Success */
      {
        FIg_get_group_label (work_form, grp_gadget, &Active_group);

        if (Active_group == 0)
        {
          /*********************************************************/
          /* */
          /* That gadget does not belong to a group, so allow the */
          /* operator to choose another gadget. */
          /* */
          /*********************************************************/

          UMSGetByNum (t_str, FB_E_NOTMBRGRP, 0);
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
          /* mode. Then allow the user to move the gadget */
          /* that was originally poked to indicate the amount */
          /* all gadgets in the group should be moved by. */
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

          copy_has_been_done = 0;

          while (status == 2)
          {
            UMSGetByNum (t_str, FB_P_POKNEWPOS, 0);
            FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

            if (copy_has_been_done == 0)
            {
              FIg_get_location (work_form, grp_gadget, &xpos, &ypos);
            }
            else
            {
			  if (new_gadget != -100) /* has been set */
                FIg_get_location (work_form, new_gadget, &xpos, &ypos);
            }

            save_xpos = xpos;
            save_ypos = ypos;

            UMSGetByNum (t_str, FB_I_OLDXOLDY, "%d%d", xpos, ypos);
            FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);

            offset_x = accept_x - xpos;
            offset_y = accept_y - ypos;

            FIg_get_type (work_form, grp_gadget, &gadget_type);

            if (gadget_type == FI_SYM)
            {
              FIg_get_symbol_file (work_form, grp_gadget, symbol_file);

              FIg_get_off_symbol_index (work_form, grp_gadget, &index);

              status = Poke_symbol_location (window, &xpos, &ypos,
                  symbol_file, index, offset_x, offset_y);
            }
            else if (gadget_type == FI_LINE)
            {
              status = Move_line_gadget (window, &xpos, &ypos,
                  xsize, ysize, offset_x, offset_y);
            }
            else if (gadget_type == FI_TEXT)
            {
              FIg_get_off_text (work_form, grp_gadget, off_text);

              FIg_get_font (work_form, grp_gadget, font_name,
                  &bodysize);

              FIg_get_justification (work_form, grp_gadget, &justify);

              status = Poke_text_location (window, &xpos, &ypos,
                  offset_x, offset_y,
                  off_text, justify, font_name,
                  bodysize);
            }
            else
              status = Get_first_point (window, &xpos, &ypos, xsize, ysize,
                  offset_x, offset_y);

            FIfld_set_text (Message_form, 22, 0, 0, "", 0);

            accept_x = xpos;
            accept_y = ypos;

            if (status == 2) /* success */
            {
              xpos -= offset_x;
              ypos -= offset_y;
              delta_x = xpos - save_xpos;
              delta_y = ypos - save_ypos;

              for (x = 0; x < Total_gadgets; x++)
              {
                FIg_get_group_label (work_form, seq_list[x].gadget,
                    &temp_group);

                if (temp_group == Active_group)
                {
                  if (copy_has_been_done == 0)
                  {
                    FIg_copy (work_form, seq_list[x].gadget,
                        &new_gadget_array[x], 1);
                
                    if (seq_list[x].gadget == grp_gadget)
                    {
                      new_gadget = new_gadget_array[x];
                    }
                
                    /* New 10/21/89 */
                    if (new_gadget != -100) /* make sure it is set */
                      _FI_g_verify_erase_color ((struct FIform_obj *)work_form, new_gadget,
                        FI_FORM_GROUP);
                  }
                  FIg_get_location (work_form, new_gadget_array[x],
                      &xpos, &ypos);
                
                  FIg_set_location (work_form, new_gadget_array[x],
                      xpos + delta_x, ypos + delta_y);
                }
              }
              if (copy_has_been_done == 0)
              {
                copy_has_been_done = 1;
              }

              Redisplay (work_form);
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
                
                  if (copy_has_been_done)
                  {
                    if (seq_list[x].hilite_flag == 0)
                    {
                      FIg_unhilite (work_form, new_gadget_array[x]);
                    }
                    else
                    {
                      FIg_hilite (work_form, new_gadget_array[x]);
                    }
                
                    if (seq_list[x].display_flag == 0)
                    {
                      FIg_erase (work_form, new_gadget_array[x]);
                    }
                    else
                    {
                      FIg_display (work_form, new_gadget_array[x]);
                    }
                  }
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

    kill_group_copy();
  }
}
