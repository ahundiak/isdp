/***********************************

		edit_gdt.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
*/

/*************************************/
/* */
/* This file contains functions for the "edit gadget" command. */
/* */
/* Programmer: Mack Draper */
/* Date: Feb. 28, 1989 */
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

int edit_hilite_flag;
int edit_display_flag;
int old_gadget_label;
int Next_in_sequence;
int Next_link;

int Edit_sequence_array[100];
int Edit_data_link_array[100];
int Edit_sequence_count;
int Edit_data_link_count;

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern Form work_form;
extern Form Characteristics_form;
extern int command_is_active;
extern char current_command_string[80];
extern struct gadget_struct gadget_attr;

extern Form button_form;
extern Form cklist_form;
extern Form text_form;
extern Form Symbol_form;
extern Form Toggle_form;
extern Form Slider_form;
extern Form Dial_form;
extern Form Rectangle_form;
extern Form Line_form;
extern Form Bezel_form;
extern Form Master_field_form;
extern Form Scroll_field_form;
extern Form Edit_field_form;
extern Form Verify_field_form;
extern Form Assoc_list_field_form;
extern Form Scroll_form;
extern Form Place_multi_column_form;
extern Form Edit_column_form;
extern Form Column_mode_form;
extern Form Verify_column_form;
extern Form Gauge_form;
extern Form Message_form;

/*************************************************************************/
/* */
/* kill_edit_gadget() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to EDIT_GADGET indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_edit_gadget(void)
{
  char t_str[256];

  if (command_is_active == EDIT_GADGET)
  {
     command_is_active = 0;
     strcpy (current_command_string, "None");

     if (button_form != NULL)
        FIf_erase (button_form);

     if (cklist_form != NULL)
        FIf_erase (cklist_form);

     if (text_form != NULL)
        FIf_erase (text_form);

     if (Symbol_form != NULL)
        FIf_erase (Symbol_form);

     if (Toggle_form != NULL)
        FIf_erase (Toggle_form);

     if (Slider_form != NULL)
        FIf_erase (Slider_form);

     if (Dial_form != NULL)
        FIf_erase (Dial_form);

     if (Rectangle_form != NULL)
        FIf_erase (Rectangle_form);

     if (Line_form != NULL)
        FIf_erase (Line_form);

     if (Bezel_form != NULL)
        FIf_erase (Bezel_form);

     if (Master_field_form != NULL)
        FIf_erase (Master_field_form);

     if (Scroll_field_form != NULL)
        FIf_erase (Scroll_field_form);

     if (Edit_field_form != NULL)
        FIf_erase (Edit_field_form);

     if (Verify_field_form != NULL)
        FIf_erase (Verify_field_form);

     if (Assoc_list_field_form != NULL)
        FIf_erase (Assoc_list_field_form);

     if (Scroll_form != NULL)
        FIf_erase (Scroll_form);

     if (Place_multi_column_form != NULL)
     {
        FIf_erase (Place_multi_column_form);
        FIg_delete (work_form, 1000);
     }

     if (Edit_column_form != NULL)
        FIf_erase (Edit_column_form);

     if (Column_mode_form != NULL)
        FIf_erase (Column_mode_form);

     if (Verify_column_form != NULL)
        FIf_erase (Verify_column_form);

     if (Gauge_form != NULL)
        FIf_erase (Gauge_form);

     if (Characteristics_form != NULL)
        Clear_characteristics_form();

     if (old_gadget_label != -1)
     {
        int gadget_type;
        int xpos, ypos, xsize, ysize;

        if (edit_hilite_flag == 0)
           FIg_unhilite (work_form, old_gadget_label);

        if (edit_display_flag == 0)
           FIg_erase (work_form, old_gadget_label);

        FIg_get_type (work_form, old_gadget_label, &gadget_type);
        FIg_get_location (work_form, old_gadget_label, &xpos, &ypos);
        FIg_get_size (work_form, old_gadget_label, &xsize, &ysize);
     }

     FIfld_set_text (Message_form, 11, 0, 0, "", 0);
     FIfld_set_text (Message_form, 44, 0, 0, "", 0);
     UMSGetByNum (t_str, FB_P_SELCOM, 0);
     FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

     if (work_form != NULL) /* Form already displayed */
     {
        FIf_set_builder_mode_off ((struct FIform_obj *)work_form);
     }

     if (work_form != NULL)
        Redisplay (work_form);
  }
}

/*************************************************************************/
/* */
/* execute_edit_gadget() */
/* */
/* This function is called by the executive command handler routine. */
/* It changes values contained in the message windows and sets the */
/* builder mode to on for the work_form. As a result the gadgets will */
/* no longer change their state when poked. They will simply call their */
/* gadget notification routine. */
/* */
/*************************************************************************/

void execute_edit_gadget(void)
{
  char t_str[256];
  int status;
  int edit_gadget;
  int not_finished;
  int xsize, ysize;
  Window window;		/* change from int to Window for ANSI */
  int display_flag, hilite_flag;
  int gadget_type;
  int accept_x, accept_y, mode;
  int x, type, seq;

  old_gadget_label = -1;
  Edit_sequence_count = 0;
  Edit_data_link_count = 0;

  if (work_form == NULL)
  {
    kill_edit_gadget();
  }
  else
  {
    UMSGetByNum (t_str, FB_I_EDTGDT, 0);
    FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
    UMSGetByNum (t_str, FB_P_SELGDT, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    FIf_set_builder_mode_on ((struct FIform_obj *)work_form);

    not_finished = 1;
    FIf_get_window (work_form, &window);

    mode = 0; /* Force operator to select a point */

    status = Select_gadget (&edit_gadget, &xsize, &ysize, &display_flag,
        &hilite_flag, &accept_x, &accept_y, mode);

    if (status == 2) /* Success */
    {
      FIg_get_type (work_form, edit_gadget, &gadget_type);

      edit_hilite_flag = hilite_flag;
      edit_display_flag = display_flag;
      old_gadget_label = edit_gadget;

      for (x = 0; x < 1000; x++)
      {
        if (x != old_gadget_label)
        {
          status = FIg_get_type (work_form, x, &type);

          if (status == FI_SUCCESS)
          {
            FIg_get_next_in_seq (work_form, x, &seq);

            if (seq == old_gadget_label)
            {
              Edit_sequence_array[Edit_sequence_count] = x;
              Edit_sequence_count++;
            }

            FIg_get_pass_data (work_form, x, &seq);

            if (seq == old_gadget_label)
            {
              Edit_data_link_array[Edit_data_link_count] = x;
              Edit_data_link_count++;
            }
          }
        }
      }

      switch (gadget_type)
      {
      case FI_LINE:

        edit_line_gadget();
        break;

      case FI_RECT:

        edit_rectangle_gadget();
        break;

      case FI_BEZEL:

        edit_bezel_gadget();
        break;

      case FI_BUTTON:

        edit_button_gadget();
        break;

      case FI_TEXT:

        edit_text_gadget();
        break;

      case FI_CHECKLIST:

        edit_cklist_gadget();
        break;

      case FI_SYM:

        edit_symbol_gadget();
        break;

      case FI_TOGGLE:

        edit_toggle_gadget();
        break;

      case FI_SLIDER:

        edit_slider_gadget();
        break;

      case FI_DIAL:

        edit_dial_gadget();
        break;

      case FI_FIELD:

        edit_field_gadget();
        break;

      case FI_GAUGE:

        edit_gauge_gadget();
        break;

      case FI_SCROLL:

        edit_scroll_gadget();
        break;

      case FI_MULTI_COL:

        edit_multi_col_field_gadget();
        break;
      }
      return;
    }

    kill_edit_gadget();
  }
}

/**************************************************************************/

void setup_standard_attr (int edit_gadget)
{
  int attr;

  FIg_get_attr (work_form, edit_gadget, &attr);

  if (edit_display_flag == 0)
    gadget_attr.display = 0;
  else
    gadget_attr.display = 1;

  if (attr & FI_NOT_ENABLED)
    gadget_attr.selectable = 0;
  else
    gadget_attr.selectable = 1;

  if (edit_hilite_flag == 1)
    gadget_attr.hilite = 1;
  else
    gadget_attr.hilite = 0;

  if (attr & FI_NO_DITHERING)
    gadget_attr.dither = 1;
  else
    gadget_attr.dither = 0;

  if (attr & FI_VERT_SCROLL_NOTIFY)
    gadget_attr.vert_scroll_notify = 1;
  else
    gadget_attr.vert_scroll_notify = 0;

  if (attr & FI_INITIAL_NOTIFY)
    gadget_attr.initial_notify = 1;
  else
    gadget_attr.initial_notify = 0;

  if (attr & FI_NO_COMPLETE_NOTIFY)
    gadget_attr.complete_notify = 0;
  else
    gadget_attr.complete_notify = 1;

  if (attr & FI_HELP_TOPIC)
    gadget_attr.help = 1;
  else
    gadget_attr.help = 0;

  if (attr & FI_CMD_STRING)
    gadget_attr.cmd_string = 1;
  else
    gadget_attr.cmd_string = 0;

  if (attr & FI_CMD_KEY)
    gadget_attr.cmd_key = 1;
  else
    gadget_attr.cmd_key = 0;

  if (attr & FI_TEXT_GADGET)
    gadget_attr.text_gadget = 1;
  else
    gadget_attr.text_gadget = 0;

  FIg_get_location (work_form, edit_gadget, &gadget_attr.x_pos,
      &gadget_attr.y_pos);

  FIg_get_size (work_form, edit_gadget, &gadget_attr.x_size,
      &gadget_attr.y_size);

  FIg_get_off_color (work_form, edit_gadget, &gadget_attr.off_color);

  FIg_get_on_color (work_form, edit_gadget, &gadget_attr.on_color);

  FIg_get_command (work_form, edit_gadget, gadget_attr.command_string);

  FIg_get_help_topic (work_form, edit_gadget, gadget_attr.help_topic);

  FIg_get_default_value (work_form, edit_gadget, &gadget_attr.default_value);

  FIg_get_font (work_form, edit_gadget, gadget_attr.font_name,
      &gadget_attr.bodysize);

  FIg_get_off_text (work_form, edit_gadget, gadget_attr.off_text);

  if (gadget_attr.text_gadget == 0) /* symbol gadget */
  {
    FIg_get_symbol_file (work_form, edit_gadget, gadget_attr.symbol_file);

    FIg_get_off_symbol_index (work_form, edit_gadget,
        &gadget_attr.off_sym_index);
  }

  FIg_get_next_in_seq (work_form, edit_gadget, &Next_in_sequence);
  FIg_get_pass_data (work_form, edit_gadget, &Next_link);
}
