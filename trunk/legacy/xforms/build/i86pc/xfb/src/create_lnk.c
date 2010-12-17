/***********************************

		create_lnk.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
    05-07-92    sml     casted func args for ANSI
*/

/*************************************/
/* */
/* This file contains all of the functions pertaining to the */
/* "create data link" command. */
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

extern int num_displayed_gadgets;
extern int display_array[1000];
extern int hilite_array[1000];

extern struct seq_struct seq_list[1001];

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern Form work_form;
extern Form Message_form;
extern Form Dynamics_form;
extern int command_is_active;
extern char current_command_string[80];

/*************************************************************************/
/* */
/* kill_create_data_link() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to CREATE_LNK indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_create_data_link(void)
{
  char t_str[256];

  if (command_is_active == CREATE_DATA_LINK)
  {
     command_is_active = 0;
     strcpy (current_command_string, "None");

     FIfld_set_text (Message_form, 11, 0, 0, "", 0);
     FIfld_set_text (Message_form, 44, 0, 0, "", 0);

     UMSGetByNum (t_str, FB_P_SELCOM, 0);
     FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

     if ( work_form )
        FIf_set_builder_mode_off ((struct FIform_obj *)work_form);
  }
}

/*--------------------------------------------------------------------*/

Determine_current_data_links(void)
{
  int form_xsize, form_ysize;
  int status, x, type;
  int attr;
  int num_gadgets, gadget_array[1000];

  Total_gadgets = 0;
  num_displayed_gadgets = 0;

  FIf_get_size (work_form, &form_xsize, &form_ysize);

  FIf_gadgets_inside_area (work_form, 0, 0, form_xsize, form_ysize,
      &num_gadgets, gadget_array);

  for (x = 0; x < num_gadgets; x++)
  {
    FIg_get_type (work_form, gadget_array[x], &type);

    seq_list[Total_gadgets].gadget = gadget_array[x];

    FIg_get_pass_data (work_form, gadget_array[x],
        &seq_list[Total_gadgets].to_gadget);

    if (seq_list[Total_gadgets].to_gadget > 0)
    {
      status = FIg_get_type (work_form,
          seq_list[Total_gadgets].to_gadget,
          &type);

      if ((status != FI_SUCCESS) ||
          (type == FI_SYM) ||
          (type == FI_RECT) ||
          (type == FI_LINE) ||
          (type == FI_BEZEL))
      {
        seq_list[Total_gadgets].to_gadget = 0;
        FIg_set_pass_data (work_form, gadget_array[x], -1);
      }
    }
    else
    {
      seq_list[Total_gadgets].to_gadget = 0;
    }

    FIg_get_attr (work_form, gadget_array[x], &attr);

    if (attr & FI_NOT_DISPLAYED)
      seq_list[Total_gadgets].display_flag = 0;
    else
      seq_list[Total_gadgets].display_flag = 1;

    if (attr & FI_HILITED)
      seq_list[Total_gadgets].hilite_flag = 1;
    else
      seq_list[Total_gadgets].hilite_flag = 0;

    Total_gadgets++;
  }
}

/*--------------------------------------------------------------------*/

int check_for_loop (int from_gadget,
                    int to_gadget)
{
  int x;
  int prev_gdt_in_link;
  int status;

  if (from_gadget == to_gadget)
  {
    return (1); /* loop attempted */
  }

  for (x = 0; x < Total_gadgets; x++)
  {
    if (seq_list[x].to_gadget == from_gadget)
    {
      prev_gdt_in_link = seq_list[x].gadget;
      if (prev_gdt_in_link == to_gadget)
        return (1); /* loop attempted */

      status = check_for_loop (prev_gdt_in_link, to_gadget);
      if (status)
        return (1);
    }
  }

  return (0); /* No loop attempted */
}

/*--------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* execute_create_data_link() */
/* */
/* This function is called by the executive command handler routine. */
/* It changes values contained in the message windows and sets the */
/* builder mode to on for the work_form. As a result the gadgets will */
/* no longer change their state when poked. They will simply call their */
/* gadget notification routine. */
/* */
/*************************************************************************/

void execute_create_data_link(void)
{
  char t_str[256];
  int status;
  int seq_gadget, seq2_gadget;
  int not_finished, continue_inner_loop;
  int xsize, ysize, xpos, ypos;
  Window window;		/* changed from int to Window type for ANSI */
  int display_flag, hilite_flag;
  int gadget_type;
  int accept_x, accept_y, mode;
  int x1, y1, x2, y2, x;
  int from_xpos, from_ypos, from_xsize, from_ysize;
  int to_xpos, to_ypos, to_xsize, to_ysize;
  int gadget_index = 0;
  int line_accepted;

  if (work_form == NULL)
  {
    kill_create_data_link();
  }
  else
  {
    UMSGetByNum (t_str, FB_I_CREDATLNK, 0);
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

      UMSGetByNum (t_str, FB_P_SELLNKORG, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

      status = Select_gadget (&seq_gadget, &xsize, &ysize, &display_flag,
          &hilite_flag, &accept_x, &accept_y, mode);

      FIfld_set_text (Message_form, 22, 0, 0, "", 0);

      if (status == 2) /* Success */
      {
        FIg_get_type (work_form, seq_gadget, &gadget_type);

        if ((gadget_type == FI_SYM) ||
            (gadget_type == FI_LINE) ||
            (gadget_type == FI_RECT) ||
            (gadget_type == FI_BEZEL))
        {
          UMSGetByNum (t_str, FB_E_NOTINLNK, 0);
          FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);

          FIg_unhilite (work_form, seq_gadget);
        }
        else
        {
          continue_inner_loop = 1;

          while (continue_inner_loop)
          {
            UMSGetByNum (t_str, FB_P_POKNXTLNK, 0);
            FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

            FIg_get_location (work_form, seq_gadget,
                &from_xpos, &from_ypos);

            FIg_get_size (work_form, seq_gadget,
                &from_xsize, &from_ysize);

            x1 = from_xpos + (from_xsize / 2);
            y1 = from_ypos + (from_ysize / 2);

            status = Poke_arrow_endpoint (x1, y1, &x2, &y2);

            if (status == 2) /* success */
            {
              mode = 1; /* Don't let the operator enter data point */
              accept_x = x2;
              accept_y = y2;

              status = Select_gadget (&seq2_gadget, &xsize, &ysize,
                  &display_flag, &hilite_flag,
                  &accept_x, &accept_y, mode);

              FIfld_set_text (Message_form, 22, 0, 0, "", 0);

              if (status == 2)
              {
                FIg_get_type (work_form, seq2_gadget, &gadget_type);

                if ((gadget_type == FI_SYM) ||
                    (gadget_type == FI_LINE) ||
                    (gadget_type == FI_RECT) ||
                    (gadget_type == FI_BEZEL))
                {
                  UMSGetByNum (t_str, FB_E_NOTINLNK, 0);
                  FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);

                  FIg_unhilite (work_form, seq2_gadget);
                }
                /*
                else if (check_for_loop (seq_gadget, seq2_gadget) == 1)
                {
                UMEMsgStrip (2, CENTER, FB_P_LOOPNOTALL, 0);
                
                OLD_Refresh_lines (seq2_gadget);
                
                }
                */
                else if (seq_gadget == seq2_gadget)
                {
                  FIfld_set_text (Message_form, 22, 0, 0,
                      "Gadget cannot be sequenced to itself", 0);
                }
                else
                {
                  FIg_get_location (work_form, seq2_gadget,
                      &to_xpos, &to_ypos);
                
                  FIg_get_size (work_form, seq2_gadget,
                      &to_xsize, &to_ysize);
                
                  x2 = to_xpos + (to_xsize / 2);
                  y2 = to_ypos + (to_ysize / 2);
                
                  for (x = 0; x < Total_gadgets; x++)
                  {
                    if (seq_list[x].gadget == seq_gadget)
                    {
                      gadget_index = x;
                      break;
                    }
                  }
                
                  line_accepted = 1;
                
                  if (seq_list[gadget_index].to_gadget != 0)
                  {
                    Draw_arrow (FI_GREEN, x1, y1, x2, y2, 1000);
                
                    seq_list[gadget_index].line_color = FI_RED;
                    Paint_arrow (gadget_index);
                    Paint_arrow (1000);
                
                    UMSGetByNum (t_str, FB_P_ACCREJ, 0);
                    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
                
                    status = Poke_plain_point (window, &xpos, &ypos);
                
                    if (status == 2) /* Success */
                    {
                      seq_list[gadget_index].line_color = FI_LT_GREY;
                      Paint_arrow (gadget_index);
                      seq_list[gadget_index].line_color = FI_YELLOW;
                
                      for (x = 0; x < 3; x++)
                      {
                        seq_list[gadget_index].xlo[x] =
                            seq_list[1000].xlo[x];
                        seq_list[gadget_index].ylo[x] =
                            seq_list[1000].ylo[x];
                        seq_list[gadget_index].xhi[x] =
                            seq_list[1000].xhi[x];
                        seq_list[gadget_index].yhi[x] =
                            seq_list[1000].yhi[x];
                      }
                      Paint_arrow (gadget_index);
                
                      seq_list[1000].xlo[0] = 0;
                      seq_list[1000].ylo[0] = 0;
                
                      line_accepted = 1;
                    }
                    else /* Rejected */
                    {
                      seq_list[1000].line_color = FI_LT_GREY;
                      Paint_arrow (1000);
                      seq_list[1000].xlo[0] = 0;
                      seq_list[1000].ylo[0] = 0;
                
                      seq_list[gadget_index].line_color = FI_YELLOW;
                      Paint_arrow (gadget_index);
                
                      line_accepted = 0;
                    }
                  }
                  else
                  {
                    Draw_arrow (FI_YELLOW, x1, y1, x2, y2, gadget_index);
                    Paint_arrow (gadget_index);
                  }
                
                  if (line_accepted == 1)
                  {
                    FIg_unhilite (work_form, seq_gadget);
                
                    FIg_set_pass_data (work_form,
                        seq_gadget, seq2_gadget);
                    seq_list[gadget_index].to_gadget = seq2_gadget;
                    seq_gadget = seq2_gadget;
                  }

                  Refresh_lines();
                }
              }
            }
            else
            {
              continue_inner_loop = 0;

              FIg_unhilite (work_form, seq_gadget);
            }
          }
        }
      }
      else
        not_finished = 0;
    }

    kill_create_data_link();
    Clean_up_lines ();
  }
}
