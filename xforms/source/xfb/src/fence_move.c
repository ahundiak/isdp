/***********************************

		fence_move.c

***********************************/

/*
  History
	04-28-92	sml		ANSI-ized; initialized some vars
*/

/*************************************/
/* */
/* This file contains functions for the "fence move" command. */
/* */
/* Programmer: Mack Draper */
/* Date: Feb. 12, 1989 */
/* */
/*************************************/

#include <stdio.h>

#include <X11/Xlib.h>

#include "FI.h"
#include "FIdyn.h"
#include "NFBpriv.h"
#include "FEI.h"

#include "UMS.h"
#include "FB.h"

#include "XFIproto_pub.h"
#include "XFIproto_pri.h"
#include "XFBproto_pri.h"

#define BEZEL 3
#define BTN_SIZE 12
#define BUTTON_SPACING 1
#define MIN_SLIDE_AREA 12

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/


/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern Form work_form;
extern struct dpb_struct dpb;
extern Form Message_form;
extern int command_is_active;
extern char current_command_string[80];

extern GC xfb_GC;
extern XGCValues GC_values;
extern int hilite_plane;
extern Display *display;

/*************************************************************************/
/* */
/* kill_fence_move() */
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

void kill_fence_move(void)
{
  char t_str[256];

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

/*************************************************************************/
/* */
/* execute_fence_move() */
/* */
/* This function is called by the executive command handler routine. */
/* It changes values contained in the message windows and sets the */
/* builder mode to on for the work_form. As a result the gadgets will */
/* no longer change their state when poked. They will simply call their */
/* gadget notification routine. */
/* */
/*************************************************************************/

void execute_fence_move(void)
{
  char t_str[256];
  int status;
  int not_finished;
  int xpos, ypos;
  int attr;
  Window window;
  int offset_x, offset_y;
  int xlo, ylo, xhi, yhi;
  int gadget_array[1000];
  char display_array[1000], hilite_array[1000];
  int num_gadgets;
  int pos_x, pos_y;
  int delta_x, delta_y;
  int x;
  int save_xpos, save_ypos;
  int fgcolor, bgcolor;
  /* sml:04-29-92	initialized to 0 to avoid ANSI warning */
  int xlo_save=0, ylo_save=0, xhi_save=0, yhi_save=0;
  int (*my_translate_color)();
  int save_boundary_mode;

  save_boundary_mode = 0;


  FIf_get_color (work_form, &bgcolor);
  FI_get_env (FI_TRANSLATE_COLOR, &my_translate_color);
  bgcolor = (*my_translate_color)( 0, bgcolor );
  fgcolor = (*my_translate_color)( 0, FI_WHITE );

  if (work_form == NULL)
  {
    kill_fence_move();
  }
  else
  {
    UMSGetByNum (t_str, FB_I_FCEMOVE, 0);
    FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);

    FIf_set_builder_mode_on ((struct FIform_obj *)work_form);

    not_finished = 1;
    FIf_get_window (work_form, &window);

    while (not_finished)
    {
      UMSGetByNum (t_str, FB_P_POKANCPNT, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
      status = Get_first_point (window, &xpos, &ypos, 0, 0, 0, 0);

      if (status == 2)
      {
        UMSGetByNum (t_str, FB_P_SELFCEAREA, 0);
        FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

        if (dpb.expansion4 == 1)
        {
          save_boundary_mode = 1;
          dpb.expansion4 = 0;
        }

        status = Get_second_point (window, xpos, ypos,
            &xlo, &ylo, &xhi, &yhi, 0, -1);

        dpb.expansion4 = save_boundary_mode;

        if (status == 2)
        {
          FIf_gadgets_inside_area (work_form, xlo, ylo, xhi, yhi,
              &num_gadgets, gadget_array);

          if (num_gadgets > 0)
          {
            for (x = 0; x < num_gadgets; x++)
            {
              FIg_get_attr (work_form, gadget_array[x], &attr);

              if (attr & FI_NOT_DISPLAYED)
              {
                display_array[x] = 0;
              }
              else
              {
                display_array[x] = 1;
              }
              if (attr & FI_HILITED)
              {
                hilite_array[x] = 1;
              }
              else
              {
                hilite_array[x] = 0;
              }
            }

            for (x = 0; x < num_gadgets; x++)
            {
              FIg_erase (work_form, gadget_array[x]);
              FIg_hilite (work_form, gadget_array[x]);
              FIg_display (work_form, gadget_array[x]);
            }

            XSetForeground (display, xfb_GC, fgcolor);
            XDrawLine (display, window, xfb_GC, xlo, ylo, xlo, yhi);
            XDrawLine (display, window, xfb_GC, xlo, yhi, xhi, yhi);
            XDrawLine (display, window, xfb_GC, xhi, yhi, xhi, ylo);
            XDrawLine (display, window, xfb_GC, xhi, ylo, xlo, ylo);
            XFlush (display);

            xlo_save = xlo;
            ylo_save = ylo;
            xhi_save = xhi;
            yhi_save = yhi;

            UMSGetByNum (t_str, FB_P_ACCREJFCE, 0);
            FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

            status = Poke_plain_point (window, &xpos, &ypos);

            save_xpos = xpos;
            save_ypos = ypos;

            if (status == 2)
            {
              while (status == 2)
              {
                UMSGetByNum (t_str, FB_I_MVEFCEAREA, 0);
                FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

                offset_x = save_xpos - xlo;
                offset_y = save_ypos - ylo;

                if (dpb.expansion4 == 1)
                {
                  save_boundary_mode = 1;
                  dpb.expansion4 = 0;
                }

                status = Get_first_point (window, &xpos, &ypos,
                    xhi - xlo, yhi - ylo,
                    offset_x, offset_y);

                dpb.expansion4 = save_boundary_mode;

                save_xpos = xpos;
                save_ypos = ypos;

                if (status == 2)
                {
                  for (x = 0; x < num_gadgets; x++)
                  {
                    FIg_erase (work_form, gadget_array[x]);
                  }
                  pos_x = xpos - offset_x;
                  pos_y = ypos - offset_y;
                  delta_x = pos_x - xlo;
                  delta_y = pos_y - ylo;
                
                  xlo += delta_x;
                  ylo += delta_y;
                  xhi += delta_x;
                  yhi += delta_y;
                
                  for (x = 0; x < num_gadgets; x++)
                  {
                    FIg_get_location (work_form, gadget_array[x],
                        &xpos, &ypos);
                    FIg_set_location (work_form, gadget_array[x],
                        xpos + delta_x, ypos + delta_y);
                
                    /* new 10/21/89 */
                
                    _FI_g_verify_erase_color ((struct FIform_obj *)work_form, gadget_array[x],
                        FI_FORM_GROUP);
                  }
                  for (x = 0; x < num_gadgets; x++)
                  {
                    FIg_display (work_form, gadget_array[x]);
                  }
                }
                else
                {
                  for (x = 0; x < num_gadgets; x++)
                  {
                    if (hilite_array[x] == 0)
                    {
                      FIg_unhilite (work_form, gadget_array[x]);
                    }
                    if (display_array[x] == 0)
                    {
                      FIg_erase (work_form, gadget_array[x]);
                    }
                  }
                }
              }
            }
            else
            {
              for (x = 0; x < num_gadgets; x++)
              {
                if (hilite_array[x] == 0)
                {
                  FIg_unhilite (work_form, gadget_array[x]);
                }
                if (display_array[x] == 0)
                {
                  FIg_erase (work_form, gadget_array[x]);
                }
              }
            }
          }
          XSetForeground (display, xfb_GC, bgcolor);
          XDrawLine (display, window, xfb_GC, xlo_save, ylo_save,
              xlo_save, yhi_save);
          XDrawLine (display, window, xfb_GC, xlo_save, yhi_save,
              xhi_save, yhi_save);
          XDrawLine (display, window, xfb_GC, xhi_save, yhi_save,
              xhi_save, ylo_save);
          XDrawLine (display, window, xfb_GC, xhi_save, ylo_save,
              xlo_save, ylo_save);
          XFlush (display);
        }
        else
        {
          /* Do nothing, loop back around */
        }
      }
      else
      {
        kill_fence_move();
        return;
      }
    }
  }
}
