/***********************************

		copy_gdt.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
    05-07-92    sml     changed local vars types for ANSI
*/

/*************************************/
/* */
/* This file contains functions for the "copy gadget" command. */
/* */
/* Programmer: Mack Draper */
/* Date: Feb. 7, 1989 */
/* */
/*************************************/

#include <stdio.h>

#include <X11/Xlib.h>

#include "FI.h"
#include "FIdyn.h"
#include "UMS.h"
#include "FB.h"
#include "NFBpriv.h"

#include "XFIproto_pub.h"
#include "XFIproto_pri.h"
#include "XFBproto_pri.h"

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
extern Form Message_form;
extern int command_is_active;
extern char current_command_string[80];

extern Display *display;

/*************************************************************************/
/* */
/* kill_copy_gadget() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to COPY_GADGET indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has pressed the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_copy_gadget(void)
{
  char t_str[256];

  if (command_is_active == COPY_GADGET)
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

/*************************************************************************/
/* */
/* execute_copy_gadget() */
/* */
/* This function is called by the executive command handler routine. */
/* It changes values contained in the message windows and sets the */
/* builder mode to on for the work_form. As a result the gadgets will */
/* no longer change their state when poked. They will simply call their */
/* gadget notification routine. */
/* */
/*************************************************************************/

void execute_copy_gadget(void)
{
  char t_str[512];
  int status;
  int copy_gadget;
  int new_gadget;
  int not_finished;
  int xsize, ysize, xpos, ypos;
  long attr;
  Window window;
  int display_flag, hilite_flag;
  int offset_x, offset_y;
  int gadget_type;
  int index;
  char symbol_file[256];
  char font_name[256];
  char off_text[50000];
  float bodysize;
  float dummy_float = 0;
  int accept_x, accept_y, mode;
  int old_x, old_y, delta_x, delta_y;
  int single_line_mode, vert_flag, horz_flag, icon_flag, button_flag;
  int copy_has_been_done, row_select_flag;
  int justify;

  if (work_form == NULL)
  {
    kill_copy_gadget();
  }
  else
  {
    UMSGetByNum (t_str, FB_I_CPYGDT, 0);
    FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
    UMSGetByNum (t_str, FB_P_SELGDT, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    FIf_set_builder_mode_on ((struct FIform_obj *)work_form);

    not_finished = 1;
    FIf_get_window (work_form, &window);

    mode = 0; /* make operator enter data point */

    while (not_finished)
    {
      copy_has_been_done = 0;
      status = Select_gadget (&copy_gadget, &xsize, &ysize, &display_flag,
          &hilite_flag, &accept_x, &accept_y, mode);

      if (status == 2) /* Success */
      {
        while (status == 2)
        {
          UMSGetByNum (t_str, FB_P_POKGDT, 0);
          FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

          if (copy_has_been_done == 0)
            FIg_get_location (work_form, copy_gadget, &xpos, &ypos);
          else
            FIg_get_location (work_form, new_gadget, &xpos, &ypos);

          UMSGetByNum (t_str, FB_I_OLDXOLDY, "%d%d", xpos, ypos);
          FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);

          offset_x = accept_x - xpos;
          offset_y = accept_y - ypos;

          FIg_get_type (work_form, copy_gadget, &gadget_type);

          if (gadget_type == FI_SYM)
          {
            FIg_get_symbol_file (work_form, copy_gadget, symbol_file);

            FIg_get_off_symbol_index (work_form, copy_gadget, &index);

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
            FIg_get_off_text (work_form, copy_gadget, off_text);

            FIg_get_font (work_form, copy_gadget, font_name, &bodysize);

            FIg_get_justification (work_form, copy_gadget, &justify);

            status = Poke_text_location (window, &xpos, &ypos,
                offset_x, offset_y, off_text, justify, font_name,
                bodysize);
          }
          else if (gadget_type == FI_FIELD)
          {
            char font_name[256];
            float bodysize;
            int width, height, line_spacing;
            int rows, columns;
            int selectable_flag;
            int mode;
            Font font_id;
            int font_type;

			/* sml:05-07-92 for FIfld_get_num_vis_rows */
 			int num_rows;

/*            FIfld_get_num_vis_rows (work_form, copy_gadget, &attr);*/
            FIfld_get_num_vis_rows (work_form, copy_gadget, &num_rows);

            if (num_rows == 1)  /* not    if (attr == 1) */
              single_line_mode = 1;
            else
              single_line_mode = 0;

            FIfld_get_attr (work_form, copy_gadget, 0, &attr);

            if (attr & FI_DISPLAY_VSCROLL)
              vert_flag = 1;
            else
              vert_flag = 0;

            if (attr & FI_DISPLAY_HSCROLL)
              horz_flag = 1;
            else
              horz_flag = 0;

            if ((attr & FI_ASSOCIATED_LIST) ||
                (attr & FI_ROLL_THRU))
              icon_flag = 1;
            else
              icon_flag = 0;

            FIfld_get_mode (work_form, copy_gadget, 0, &mode);
            if ((mode == FI_SINGLE_SELECT) || (mode == FI_MULTI_SELECT))
              selectable_flag = 1;
            else
              selectable_flag = 0;

            FIg_get_font (work_form, copy_gadget, font_name, &bodysize);

            _FI_find_font_id (font_name, bodysize, &font_id, &dummy_float,
                FI_FIELD, &font_type);

            _FI_calc_text (font_id, "M", 1, &height, &width, &line_spacing, font_type);

            FIfld_get_num_vis_rows (work_form, copy_gadget, &rows);
            FIfld_get_num_vis_chars (work_form, copy_gadget, 0, &columns);

            xsize = width * columns;
            ysize = (line_spacing + (selectable_flag * 2)) * rows;

            status = Move_field_box (window, &xpos, &ypos, xsize, ysize,
                offset_x, offset_y,
                single_line_mode,
                horz_flag,
                vert_flag,
                icon_flag);
          }
          else if (gadget_type == FI_MULTI_COL)
          {
            int num_cols, zzz;
	    long attr2;
	    int num_rows; /* sml:05-07-92 for FIfld_get_num_vis_rows */

			/* sml:05-07-92	use num_rows instead of attr */
            FIfld_get_num_vis_rows (work_form, copy_gadget, &num_rows);
            FImcf_get_num_cols (work_form, copy_gadget, &num_cols);

            if (num_rows == 1) /* use num_rows not attr */
              single_line_mode = 1;
            else
              single_line_mode = 0;

            FImcf_get_attr (work_form, copy_gadget, &attr);

            if (attr & FI_DISPLAY_VSCROLL)
              vert_flag = 1;
            else
              vert_flag = 0;

            if (attr & FI_DISPLAY_HSCROLL)
              horz_flag = 1;
            else
              horz_flag = 0;

            button_flag = 0;
            for (zzz = 0; zzz < num_cols; zzz++)
            {
              FIfld_get_attr (work_form, copy_gadget, zzz, &attr2);
              if ((attr2 & FI_DISPLAY_HSCROLL) &&
                  (attr2 & FI_HORT_SCROLL))
              {
                button_flag = 1;
                zzz = num_cols;
              }
            }

            if (attr & FI_NO_ROW_BUTTONS)
              row_select_flag = 0;
            else
              row_select_flag = 1;

            status = Move_MCF_box (window, &xpos, &ypos, xsize, ysize,
                offset_x, offset_y,
                single_line_mode,
                horz_flag,
                vert_flag,
                button_flag,
                row_select_flag);
            if (row_select_flag == 0)
            {
              xpos -= 10;
              if (xpos < 0)
                xpos = 0;
            }
          }
          else
          {
            status = Get_first_point (window, &xpos, &ypos,
                xsize, ysize, offset_x, offset_y);
          }

          if (status == 2) /* success */
          {
            if (copy_has_been_done == 0)
              FIg_get_location (work_form, copy_gadget, &old_x, &old_y);
            else
              FIg_get_location (work_form, new_gadget, &old_x, &old_y);

            accept_x = xpos;
            accept_y = ypos;

            xpos -= offset_x;
            ypos -= offset_y;

            if (xpos < 0)
              xpos = 0;

            if (ypos < 0)
              ypos = 0;

            if (gadget_type == FI_CHECKLIST)
            {
              if (ysize > 20)
                ypos = ypos + ((ysize - 20) / 2);
            }

            delta_x = xpos - old_x;
            delta_y = ypos - old_y;


            if (copy_has_been_done == 0)
            {
              FIg_copy (work_form, copy_gadget, &new_gadget, 1);

              /* New 10/21/89 */

              _FI_g_verify_erase_color ((struct FIform_obj *)work_form, new_gadget, FI_FORM_GROUP);

              copy_has_been_done = 1;
            }
            else
              FIg_erase (work_form, new_gadget);

            FIg_set_location (work_form, new_gadget, xpos, ypos);

            FIg_display (work_form, new_gadget);

            if ((gadget_type != FI_FIELD) &&
                (gadget_type != FI_MULTI_COL))
            {
              int xsize, ysize;

              FIg_get_size (work_form, copy_gadget, &xsize, &ysize);
              FIf_paint_area (work_form, old_x, old_y,
                  old_x + xsize, old_y + ysize);
            }
            else
              Redisplay (work_form);

            UMSGetByNum (t_str, FB_P_SELCOM, 0);
            FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
          }
          else
          {
            if (hilite_flag == 0)
              FIg_unhilite (work_form, copy_gadget);

            if (display_flag == 0)
              FIg_erase (work_form, copy_gadget);

            if (copy_has_been_done)
            {
              if (hilite_flag == 0)
                FIg_unhilite (work_form, new_gadget);

              if (display_flag == 0)
                FIg_erase (work_form, new_gadget);
            }
          }
        }
        FIfld_set_text (Message_form, 22, 0, 0, "", 0);
        FIfld_set_text (Message_form, 44, 0, 0, "", 0);
      }
      else
        not_finished = 0;
    }

    kill_copy_gadget();
  }
}
