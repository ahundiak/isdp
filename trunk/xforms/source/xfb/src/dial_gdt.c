/***********************************

		dial_gdt.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
*/

/*************************************/
/* */
/* This file contains functions for the "place dial" and "edit dial" */
/* commands. */
/* */
/* Programmer: Mack Draper */
/* Date: Jan. 22, 1989 */
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

#define LABEL_FLD 41 /* Needed by characteristics form */

/***********************/
/* */
/* used by dial form */
/* */
/***********************/

#define HIGH_FLD 13
#define INITIAL_FLD 14
#define ZERO_LOC_FLD 15

#define HIGH_CK 63
#define INITIAL_CK 64

#define ROTATION_TOG 27
#define BORDER_TOG 36
#define FORMAT_TOG 53

#define PREVIEW_DIAL 44
#define TICKS_FLD 31
#define DEGREES_FLD 39
#define UNITS_FLD 40

#define FRACTION_TEXT 54
#define FRACTION_FLD 57
#define WHOLE_FLD 56
#define FORMAT_TEXT 58
#define INCREMENT_FLD 29

#define KEYIN_TOG 30
#define X_TEXT 37
#define Y_TEXT 38
#define X_FLD 16
#define Y_FLD 17
#define WIDTH_TEXT 33
#define HEIGHT_TEXT 32
#define WIDTH_FLD 18
#define HEIGHT_FLD 19

#define ERR_FLD 10

#define CHAR_FOREGROUND_CLR_BTN 47
#define CHAR_TEXT_FONT_BTN 46

static int temp_dial_fraction_digits;

static void create_dial_gadget();
static void setup_old_dial_form();
static void setup_new_dial_form();
static void show_dial_form_info();
static void update_dial_range_fields();

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

Form Dial_form = NULL;

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern Form work_form;
extern int command_is_active;
extern char current_command_string[80];
extern struct gadget_struct gadget_attr;
extern struct gadget_struct override_attr;

extern char execute_dir[200];

extern Form Characteristics_form;
extern Form FG_color_form;
extern Form Font_form;
extern Form Message_form;
extern int edit_hilite_flag;
extern int edit_display_flag;
extern int old_gadget_label;
extern int Next_in_sequence;
extern int Next_link;

extern int Edit_sequence_array[100];
extern int Edit_data_link_array[100];
extern int Edit_sequence_count;
extern int Edit_data_link_count;

extern char language[80];
extern Display *display;

/*************************************************************************/
/* */
/* kill_place_dial() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to PLACE_DIAL indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_place_dial(void)
{
  char t_str[256];

  if (Dial_form != NULL)
    FIf_erase (Dial_form);

  if (Characteristics_form != NULL)
    Clear_characteristics_form();

  FIfld_set_text (Message_form, 11, 0, 0, "", 0);
  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  if (command_is_active == PLACE_DIAL)
  {
    command_is_active = 0;
    strcpy (current_command_string, "None");

    UMSGetByNum (t_str, FB_P_SELCOM, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
  }
  else
  {
    Redisplay (work_form);
    execute_edit_gadget();
  }
}

/*-----------------------------------------------------------------------*/

static void update_dial_range_fields(void)
{
  char t_str[256], h_str[256], i_str[256];
  int x, y;

  if (gadget_attr.display_format == 1) /* Floating point format */
  {
    format_float_field (gadget_attr.high_value, h_str);
    format_float_field (gadget_attr.default_value, i_str);

    for (x = 0; x < gadget_attr.whole_digits; x++)
    {
      t_str[x] = 'X';
    }

    t_str[x] = '.';

    for (y = x + 1; y < (x + 1 + gadget_attr.fraction_digits); y++)
    {
      t_str[y] = 'X';
    }

    t_str[y] = (char) NULL;

    FIg_erase (Dial_form, FORMAT_TEXT);

    FIg_set_text (Dial_form, FORMAT_TEXT, t_str);

    FIg_display (Dial_form, FORMAT_TEXT);
  }
  else /* Integer format */
  {
    format_integer_field ((int)gadget_attr.high_value, h_str);
    format_integer_field ((int)gadget_attr.default_value, i_str);

    for (x = 0; x < gadget_attr.whole_digits; x++)
    {
      t_str[x] = 'X';
    }

    t_str[x] = (char) NULL;

    FIg_erase (Dial_form, FORMAT_TEXT);

    FIg_set_text (Dial_form, FORMAT_TEXT, t_str);

    FIg_display (Dial_form, FORMAT_TEXT);
  }

  FIfld_set_text (Dial_form, HIGH_FLD, 0, 0, h_str, 0);
  FIfld_set_text (Dial_form, INITIAL_FLD, 0, 0, i_str, 0);

  if (gadget_attr.display_format == 1) /* Floating point format */
  {
    FIg_set_value_format (Dial_form, PREVIEW_DIAL,
        gadget_attr.whole_digits + gadget_attr.fraction_digits + 1,
        gadget_attr.fraction_digits);
  }
  else
  {
    FIg_set_value_format (Dial_form, PREVIEW_DIAL,
        gadget_attr.whole_digits, 0);
  }

  FIg_erase (Dial_form, PREVIEW_DIAL);
  FIg_display (Dial_form, PREVIEW_DIAL);
}

/*-------------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* setup_old_dial_form() */
/* */
/*************************************************************************/

static void setup_old_dial_form(void)
{
  int total_digits, x;
  float temp_float;

  setup_standard_attr (old_gadget_label);

  FIg_get_display (work_form, old_gadget_label, &x);

  if (x & FI_VALUE)
    gadget_attr.initial_display_flag = 1;
  else
    gadget_attr.initial_display_flag = 0;

  if (x & FI_HIGH_VALUE)
    gadget_attr.high_display_flag = 1;
  else
    gadget_attr.high_display_flag = 0;


  FIg_get_value_format (work_form, old_gadget_label, &total_digits,
      &gadget_attr.fraction_digits);

  gadget_attr.whole_digits = total_digits - gadget_attr.fraction_digits - 1;

  if (gadget_attr.fraction_digits == 0) /* Integer format */
    gadget_attr.display_format = 0;
  else
    gadget_attr.display_format = 1; /* Floating point format */

  FIdial_get_border_style (work_form, old_gadget_label,
      &gadget_attr.dial_bezel);

  FIg_get_minor_increments(work_form, old_gadget_label,
      &gadget_attr.dial_ticks);

  FIg_get_orientation (work_form, old_gadget_label,
      &gadget_attr.dial_rotation);

  FIdial_get_zero_location (work_form, old_gadget_label, &temp_float);

  gadget_attr.dial_zero_location = (double)temp_float;

  FIdial_get_range (work_form, old_gadget_label, &temp_float);
  gadget_attr.high_value = (double)temp_float;

  FIg_get_increment (work_form, old_gadget_label, &temp_float);
  gadget_attr.increment = (double)temp_float;

  if (gadget_attr.increment <= 0.0)
    gadget_attr.increment = 1.0;

  gadget_attr.draw_flag = 0;
  gadget_attr.poke_flag = 0;
  gadget_attr.gadget_type = FI_DIAL;
}

/*************************************************************************/
/* */
/* setup_new_dial_form() */
/* */
/* This function is called each time the operator wishes to place a */
/* dial gadget on the work form. It will fill in default settings for */
/* the dial. These will be displayed in the dial definition form */
/* when the show_dial_info() function is called. */
/* */
/*************************************************************************/

static void setup_new_dial_form(void)
{
  Set_new_gadget_defaults();

  gadget_attr.display_format = 0; /* Integer */
  gadget_attr.whole_digits = 4;
  gadget_attr.fraction_digits = 0;
  temp_dial_fraction_digits = 2;

  gadget_attr.dial_rotation = FI_COUNTER_CLOCKWISE;
  gadget_attr.dial_bezel = FI_DIAL_SHELF_BORDER;
  gadget_attr.dial_zero_location = 0;
  gadget_attr.dial_ticks = 8;

  gadget_attr.default_value = 0;
  gadget_attr.high_value = 360;
  gadget_attr.increment = 1.0;

  gadget_attr.initial_display_flag = 1;
  gadget_attr.high_display_flag = 1;

  gadget_attr.draw_flag = 1;
  gadget_attr.poke_flag = 0;
  gadget_attr.text_gadget = 1;
  gadget_attr.gadget_type = FI_DIAL;
  Next_in_sequence = 0;
  Next_link = -1;
}

/*************************************************************************/
/* */
/* show_dial_form_info() */
/* */
/* This function displays the information contained in the */
/* current_gadget struct into the dial form's gadgets. */
/* */
/*************************************************************************/

static void show_dial_form_info(void)
{
  char t_str[256], h_str[256], i_str[256];
  int x, y;
  int t_mask;

  FIg_set_off_color (Dial_form, PREVIEW_DIAL, gadget_attr.off_color);

  FIg_erase (Dial_form, FORMAT_TEXT);
  FIg_erase (Dial_form, 10);

  if (gadget_attr.display_format == 1) /* Floating point format */
  {
    FIg_set_state_on (Dial_form, FORMAT_TOG);

    FIg_display (Dial_form, FRACTION_FLD);
    FIg_display (Dial_form, FRACTION_TEXT);

    format_float_field (gadget_attr.high_value, h_str);
    format_float_field (gadget_attr.default_value, i_str);

    for (x = 0; x < gadget_attr.whole_digits; x++)
    {
      t_str[x] = 'X';
    }

    t_str[x] = '.';

    for (y = x + 1; y < (x + 1 + gadget_attr.fraction_digits); y++)
    {
      t_str[y] = 'X';
    }

    t_str[y] = (char) NULL;

    FIg_set_off_text (Dial_form, FORMAT_TEXT, t_str);
  }
  else /* Integer format */
  {
    FIg_set_state_off (Dial_form, FORMAT_TOG);
    FIg_erase (Dial_form, FRACTION_FLD);
    FIg_erase (Dial_form, FRACTION_TEXT);

    format_integer_field ((int)gadget_attr.high_value, h_str);
    format_integer_field ((int)gadget_attr.default_value, i_str);

    for (x = 0; x < gadget_attr.whole_digits; x++)
      t_str[x] = 'X';

    t_str[x] = (char) NULL;

    FIg_set_off_text (Dial_form, FORMAT_TEXT, t_str);
  }

  FIg_display (Dial_form, FORMAT_TEXT);

  FIfld_set_text (Dial_form, HIGH_FLD, 0, 0, h_str, 0);
  FIfld_set_text (Dial_form, INITIAL_FLD, 0, 0, i_str, 0);

  sprintf (t_str, "%f", gadget_attr.increment);
  FIfld_set_text (Dial_form, INCREMENT_FLD, 0, 0, t_str, 0);

  if (gadget_attr.high_display_flag == 1)
    FIg_set_state_on (Dial_form, HIGH_CK);
  else
    FIg_set_state_off (Dial_form, HIGH_CK);

  if (gadget_attr.initial_display_flag == 1)
    FIg_set_state_on (Dial_form, INITIAL_CK);
  else
    FIg_set_state_off (Dial_form, INITIAL_CK);

  sprintf (t_str, "%d", gadget_attr.whole_digits);
  FIfld_set_text (Dial_form, WHOLE_FLD, 0, 0, t_str, 0);

  sprintf (t_str, "%d", gadget_attr.fraction_digits);
  FIfld_set_text (Dial_form, FRACTION_FLD, 0, 0, t_str, 0);

  if (gadget_attr.draw_flag == 0)
  {
    FIg_set_state_on (Dial_form, KEYIN_TOG);

    sprintf (t_str, "%d", gadget_attr.x_size);
    FIfld_set_text (Dial_form, WIDTH_FLD, 0, 0, t_str, 0);
    sprintf (t_str, "%d", gadget_attr.y_size);
    FIfld_set_text (Dial_form, HEIGHT_FLD, 0, 0, t_str, 0);
    sprintf (t_str, "%d", gadget_attr.x_pos);
    FIfld_set_text (Dial_form, X_FLD, 0, 0, t_str, 0);
    sprintf (t_str, "%d", gadget_attr.y_pos);
    FIfld_set_text (Dial_form, Y_FLD, 0, 0, t_str, 0);
    FIg_display (Dial_form, X_TEXT);
    FIg_display (Dial_form, Y_TEXT);
    FIg_display (Dial_form, HEIGHT_TEXT);
    FIg_display (Dial_form, WIDTH_TEXT);
    FIg_display (Dial_form, X_FLD);
    FIg_display (Dial_form, Y_FLD);
    FIg_display (Dial_form, HEIGHT_FLD);
    FIg_display (Dial_form, WIDTH_FLD);
  }
  else
  {
    FIfld_set_text (Dial_form, WIDTH_FLD, 0, 0, "", 0);
    FIfld_set_text (Dial_form, HEIGHT_FLD, 0, 0, "", 0);
    FIfld_set_text (Dial_form, X_FLD, 0, 0, "", 0);
    FIfld_set_text (Dial_form, Y_FLD, 0, 0, "", 0);
    FIg_set_state_off (Dial_form, KEYIN_TOG);
    FIg_erase (Dial_form, X_TEXT);
    FIg_erase (Dial_form, Y_TEXT);
    FIg_erase (Dial_form, HEIGHT_TEXT);
    FIg_erase (Dial_form, WIDTH_TEXT);
    FIg_erase (Dial_form, X_FLD);
    FIg_erase (Dial_form, Y_FLD);
    FIg_erase (Dial_form, HEIGHT_FLD);
    FIg_erase (Dial_form, WIDTH_FLD);
  }

  sprintf (t_str, "%8.2f", gadget_attr.dial_zero_location);
  FIfld_set_text (Dial_form, ZERO_LOC_FLD, 0, 0, t_str, 0);

  sprintf (t_str, "%5d", gadget_attr.dial_ticks);
  FIfld_set_text (Dial_form, TICKS_FLD, 0, 0, t_str, 0);

  if (gadget_attr.dial_ticks != 0)
  {
    sprintf (t_str, "%8.2f", (double)(360 / gadget_attr.dial_ticks));
    FIfld_set_text (Dial_form, DEGREES_FLD, 0, 0, t_str, 0);
    sprintf (t_str, "%8.2f", gadget_attr.high_value /
        gadget_attr.dial_ticks);
    FIfld_set_text (Dial_form, UNITS_FLD, 0, 0, t_str, 0);
  }
  else
  {
    strcpy (t_str, "inf");
    FIfld_set_text (Dial_form, DEGREES_FLD, 0, 0, t_str, 0);
    FIfld_set_text (Dial_form, UNITS_FLD, 0, 0, t_str, 0);
  }

  /****************************************************/
  /* */
  /* Now set up the appearance of the preview dial */
  /* */
  /****************************************************/

  FIdial_set_border_style (Dial_form, PREVIEW_DIAL,
      gadget_attr.dial_bezel);
  FIg_set_minor_increments(Dial_form, PREVIEW_DIAL, gadget_attr.dial_ticks);
  FIg_set_orientation (Dial_form, PREVIEW_DIAL, gadget_attr.dial_rotation);

  FIdial_set_zero_location (Dial_form, PREVIEW_DIAL,
      gadget_attr.dial_zero_location);

  FIdial_set_range (Dial_form, PREVIEW_DIAL, gadget_attr.high_value);

  if (gadget_attr.dial_bezel == FI_DIAL_NO_BORDER)
    FIg_set_state_on (Dial_form, BORDER_TOG);
  else
    FIg_set_state_off (Dial_form, BORDER_TOG);

  if (gadget_attr.dial_rotation == FI_COUNTER_CLOCKWISE)
    FIg_set_state_on (Dial_form, ROTATION_TOG);
  else
    FIg_set_state_off (Dial_form, ROTATION_TOG);

  t_mask = 0;

  if (gadget_attr.initial_display_flag == 1)
    t_mask |= FI_VALUE;

  if (gadget_attr.high_display_flag == 1)
    t_mask |= FI_HIGH_VALUE;

  FIg_set_display (Dial_form, PREVIEW_DIAL, t_mask);

  x = gadget_attr.whole_digits + gadget_attr.fraction_digits + 1;

  FIg_set_value_format (Dial_form, PREVIEW_DIAL, x,
      gadget_attr.fraction_digits);

  FIg_set_increment (Dial_form, PREVIEW_DIAL, gadget_attr.increment);

  FIg_set_value (Dial_form, PREVIEW_DIAL, gadget_attr.default_value);

  FIg_erase (Dial_form, PREVIEW_DIAL);
  FIg_display (Dial_form, PREVIEW_DIAL);
}

/*-------------------------------------------------------------------------*/

/*********************************************************************/
/* */
/* create_dial_gadget() */
/* */
/* This function creates a new dial gadget and places it at */
/* the position that was poked by the operator. */
/* */
/*********************************************************************/

static void create_dial_gadget(void)
{
  int x, y, temp_x, temp_y;
  Window window;
  char t_str[256];
  int total_digits;
  double dial_zero_location;
  int group_label;
  int status;
  int t_mask;

  /***********************************************************/
  /* */
  /* If the work form and the place dial form intersect, */
  /* then send a window update message to the work_form */
  /* */
  /***********************************************************/

  Refresh_work_form();

  if (gadget_attr.draw_flag == 0)
  {
    x = gadget_attr.x_size;
    y = gadget_attr.y_size;
  }
  else /* Get two datapoints for size and location of dial */
  {
    UMSGetByNum (t_str, FB_P_POKDILANC, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    FIf_get_window (work_form, &window);

    status = Get_first_point (window, &x, &y, 0, 0, 0, 0);

    if (status == 2) /* Success */
    {
      UMSGetByNum (t_str, FB_I_ANCX, "%d%d", x, y);
      FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);
      UMSGetByNum (t_str, FB_P_POKDILSWG, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

      status = Get_second_point (window, x, y,
          &gadget_attr.x_pos,
          &gadget_attr.y_pos,
          &gadget_attr.x_size,
          &gadget_attr.y_size, 0, -1);

      FIfld_set_text (Message_form, 22, 0, 0, "", 0);

      if (status == 2) /* Success */
      {
        x = gadget_attr.x_size - gadget_attr.x_pos;
        y = gadget_attr.y_size - gadget_attr.y_pos;
      }
      else /* Operator wants to abort placement */
        return;
    }
    else /* Operator wants to abort placement */
      return;
  }

  temp_x = gadget_attr.x_size;
  temp_y = gadget_attr.y_size;

  gadget_attr.x_size = gadget_attr.x_pos + x;
  gadget_attr.y_size = gadget_attr.y_pos + y;

  if (command_is_active == EDIT_GADGET)
  {
    FIg_get_group_label (work_form, old_gadget_label, &group_label);
    FIg_erase (work_form, old_gadget_label);
    FIg_delete (work_form, old_gadget_label);
    old_gadget_label = -1;
  }
  else
    group_label = 0;

  Create_and_init_gadget (work_form, FI_DIAL, gadget_attr.gadget_label);

  if (group_label != 0)
    FIg_add_to_group (work_form, gadget_attr.gadget_label, group_label);

  gadget_attr.x_size = temp_x;
  gadget_attr.y_size = temp_y;

  FIdial_set_border_style (work_form, gadget_attr.gadget_label,
      gadget_attr.dial_bezel);

  FIg_set_minor_increments (work_form, gadget_attr.gadget_label,
      gadget_attr.dial_ticks);
  FIg_set_orientation (work_form, gadget_attr.gadget_label,
      gadget_attr.dial_rotation);

  dial_zero_location = gadget_attr.dial_zero_location;

  FIdial_set_zero_location (work_form, gadget_attr.gadget_label,
      dial_zero_location);

  FIdial_set_range (work_form, gadget_attr.gadget_label,
      gadget_attr.high_value);

  t_mask = 0;

  if (gadget_attr.initial_display_flag == 1)
    t_mask |= FI_VALUE;

  if (gadget_attr.high_display_flag == 1)
    t_mask |= FI_HIGH_VALUE;

  FIg_set_display (work_form, gadget_attr.gadget_label, t_mask);

  total_digits = gadget_attr.whole_digits + gadget_attr.fraction_digits + 1;

  FIg_set_value_format (work_form, gadget_attr.gadget_label, total_digits,
      gadget_attr.fraction_digits);
  FIg_set_increment (work_form, gadget_attr.gadget_label,
      gadget_attr.increment);

  FIg_activate (work_form, gadget_attr.gadget_label);

  FIg_set_next_in_seq (work_form, gadget_attr.gadget_label, Next_in_sequence);
  FIg_set_pass_data (work_form, gadget_attr.gadget_label, Next_link);

  for (x = 0; x < Edit_sequence_count; x++)
  {
    FIg_set_next_in_seq (work_form, Edit_sequence_array[x],
        gadget_attr.gadget_label);
  }

  for (x = 0; x < Edit_data_link_count; x++)
  {
    FIg_set_pass_data (work_form, Edit_data_link_array[x],
        gadget_attr.gadget_label);
  }

  if (gadget_attr.display == 1)
    FIg_display (work_form, gadget_attr.gadget_label);

  /*
FIf_calculate_size (work_form);
*/
}

/*--------------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* fi_dial_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the default */
/* settings for a new dial gadget, or alter the settings of an */
/* existing dial gadget. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_dial_form (int form_label,
                  int gadget_label,
                  double value,
                  Form form_ptr)
{
  int t_integer, t_mask;
  int status;
  char t_str[256];
  double t_double;
  int dummy_int;

  FIg_erase (Dial_form, ERR_FLD);

  switch (gadget_label)
  {
  case ROTATION_TOG:

    if ((int)value == 0)
      gadget_attr.dial_rotation = FI_CLOCKWISE;
    else
      gadget_attr.dial_rotation = FI_COUNTER_CLOCKWISE;

    FIg_erase (Dial_form, PREVIEW_DIAL);
    FIg_set_orientation (Dial_form, PREVIEW_DIAL,
        gadget_attr.dial_rotation);
    FIg_display (Dial_form, PREVIEW_DIAL);
    break;

  case BORDER_TOG:

    if ((int)value == 0)
    {
      gadget_attr.dial_bezel = FI_DIAL_SHELF_BORDER;
      FIg_erase (Dial_form, PREVIEW_DIAL);
      FIdial_set_border_style (Dial_form, PREVIEW_DIAL,
          FI_DIAL_SHELF_BORDER);
      FIg_display (Dial_form, PREVIEW_DIAL);
    }
    else
    {
      gadget_attr.dial_bezel = FI_DIAL_NO_BORDER;
      FIg_erase (Dial_form, PREVIEW_DIAL);
      FIdial_set_border_style (Dial_form, PREVIEW_DIAL,
          FI_DIAL_NO_BORDER);
      FIg_display (Dial_form, PREVIEW_DIAL);
    }
    break;

  case ZERO_LOC_FLD:

    FIfld_get_text (Dial_form, ZERO_LOC_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    t_double = validate_double_field (t_str, Dial_form, ERR_FLD,
        &status);

    if (status)
    {
      if (t_double >= 0)
      {
        sprintf (t_str, "%8.2f", t_double);
        FIfld_set_text (Dial_form, ZERO_LOC_FLD, 0, 0, t_str, 0);

        while (t_double > 360)
        {
          t_double -= 360;
        }

        gadget_attr.dial_zero_location = t_double;

        FIg_erase (Dial_form, PREVIEW_DIAL);
        FIdial_set_zero_location (Dial_form, PREVIEW_DIAL,
            t_double);
        FIg_display (Dial_form, PREVIEW_DIAL);

      }
      else
      {
        UMSGetByNum (t_str, FB_E_ZEROLOCBAD, 0);
        print_error (Dial_form, ERR_FLD, t_str);
      }
    }
    break;

  case TICKS_FLD:

    FIfld_get_text (Dial_form, TICKS_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    t_integer = validate_integer_field (t_str, Dial_form, ERR_FLD, &status);

    if (status)
    {
      if (t_integer < 0)
      {
        UMSGetByNum (t_str, FB_E_TIKMBPOS, 0);
        print_error (Dial_form, ERR_FLD, t_str);
      }
      else
      {
        gadget_attr.dial_ticks = t_integer;
        if (t_integer != 0)
        {
          sprintf (t_str, "%5d", t_integer);
          FIfld_set_text (Dial_form, TICKS_FLD, 0, 0, t_str, 0);
          t_double = 360 / (double)t_integer;
          sprintf (t_str, "%8.2f", t_double);
          FIfld_set_text (Dial_form, DEGREES_FLD, 0, 0, t_str, 0);
          t_double = gadget_attr.high_value / (double)t_integer;
          sprintf (t_str, "%8.2f", t_double);
          FIfld_set_text (Dial_form, UNITS_FLD, 0, 0, t_str, 0);
        }
        else
        {
          FIfld_set_text (Dial_form, DEGREES_FLD, 0, 0, "inf", 0);
          FIfld_set_text (Dial_form, UNITS_FLD, 0, 0, "inf", 0);
        }

        FIg_erase (Dial_form, PREVIEW_DIAL);
        FIg_set_minor_increments (Dial_form, PREVIEW_DIAL, t_integer);
        FIg_display (Dial_form, PREVIEW_DIAL);
      }
    }
    break;

  case DEGREES_FLD:

    FIfld_get_text (Dial_form, DEGREES_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    t_double = validate_double_field (t_str, Dial_form, ERR_FLD, &status);

    if (status)
    {
      if (t_double > 0)
      {
        sprintf (t_str, "%8.2f", t_double);
        FIfld_set_text (Dial_form, DEGREES_FLD, 0, 0, t_str, 0);
        gadget_attr.dial_ticks = (int)(360 / t_double);
        sprintf (t_str, "%5d", gadget_attr.dial_ticks);
        FIfld_set_text (Dial_form, TICKS_FLD, 0, 0, t_str, 0);
        t_double = gadget_attr.high_value / (double)gadget_attr.dial_ticks;
        sprintf (t_str, "%8.2f", t_double);
        FIfld_set_text (Dial_form, UNITS_FLD, 0, 0, t_str, 0);
      }
      else
      {
        UMSGetByNum (t_str, FB_E_DEGGTZERO, 0);
        print_error (Dial_form, ERR_FLD, t_str);
      }

      FIg_erase (Dial_form, PREVIEW_DIAL);
      FIg_set_minor_increments (Dial_form, PREVIEW_DIAL,
          gadget_attr.dial_ticks);
      FIg_display (Dial_form, PREVIEW_DIAL);
    }
    break;

  case UNITS_FLD:

    FIfld_get_text (Dial_form, UNITS_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    t_double = validate_double_field (t_str, Dial_form, ERR_FLD, &status);

    if (status)
    {
      if (t_double > 0)
      {
        sprintf (t_str, "%8.2f", t_double);
        FIfld_set_text (Dial_form, UNITS_FLD, 0, 0, t_str, 0);
        gadget_attr.dial_ticks = (int)(gadget_attr.high_value / t_double);
        sprintf (t_str, "%5d", gadget_attr.dial_ticks);
        FIfld_set_text (Dial_form, TICKS_FLD, 0, 0, t_str, 0);
        t_double = 360 / (double)gadget_attr.dial_ticks;
        sprintf (t_str, "%8.2f", t_double);
        FIfld_set_text (Dial_form, DEGREES_FLD, 0, 0, t_str, 0);
      }
      else
      {
        UMSGetByNum (t_str, FB_E_UNTGTZERO, 0);
        print_error (Dial_form, ERR_FLD, t_str);
      }

      FIg_erase (Dial_form, PREVIEW_DIAL);
      FIg_set_minor_increments (Dial_form, PREVIEW_DIAL,
          gadget_attr.dial_ticks);
      FIg_display (Dial_form, PREVIEW_DIAL);
    }
    break;

  case HIGH_FLD:

    FIfld_get_text (Dial_form, HIGH_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    if (gadget_attr.display_format == 0) /* Integer */
    {
      t_integer = validate_integer_field (t_str, Dial_form, ERR_FLD, &status);
      t_double = (double)t_integer;
      format_integer_field (t_integer, t_str);
    }
    else
    {
      t_double = validate_double_field (t_str, Dial_form, ERR_FLD, &status);
      format_float_field (t_double, t_str);
    }

    if (status)
    {
      if (t_double < gadget_attr.default_value)
      {
        UMSGetByNum (t_str, FB_E_HIGHGEINIT, 0);
        print_error (Dial_form, ERR_FLD, t_str);
      }
      else
        if (t_double <= 0)
        {
          UMSGetByNum (t_str, FB_E_HIGHGTZERO, 0);
          print_error (Dial_form, ERR_FLD, t_str);
        }
        else
        {
          FIfld_set_text (Dial_form, HIGH_FLD, 0, 0, t_str, 0);
          gadget_attr.high_value = t_double;

          FIg_erase (Dial_form, PREVIEW_DIAL);
          FIg_set_high_value (Dial_form, PREVIEW_DIAL, t_double);
          FIdial_set_range (Dial_form, PREVIEW_DIAL, t_double);
          FIg_display (Dial_form, PREVIEW_DIAL);

          t_double = gadget_attr.high_value / gadget_attr.dial_ticks;
          sprintf (t_str, "%f", t_double);
          FIfld_set_text (Dial_form, UNITS_FLD, 0, 0, t_str, 0);
        }
    }
    break;

  case INCREMENT_FLD:

    FIfld_get_text (Dial_form, INCREMENT_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);
    t_double = validate_double_field (t_str, Dial_form, ERR_FLD, &status);
    format_float_field (t_double, t_str);

    if (status)
    {
      if (t_double <= 0)
      {
        UMSGetByNum (t_str, FB_E_INCGTZERO, 0);
        print_error (Dial_form, ERR_FLD, t_str);
      }
      else
      {
        gadget_attr.increment = t_double;
        FIg_set_increment (Dial_form, PREVIEW_DIAL, t_double);
      }
    }
    break;

  case INITIAL_FLD:

    FIfld_get_text (Dial_form, INITIAL_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    if (gadget_attr.display_format == 0) /* Integer */
    {
      t_integer = validate_integer_field (t_str, Dial_form, ERR_FLD, &status);
      t_double = (double)t_integer;
      format_integer_field (t_integer, t_str);
    }
    else
    {
      t_double = validate_double_field (t_str, Dial_form, ERR_FLD, &status);
      format_float_field (t_double, t_str);
    }

    if (status)
    {
      if (t_double < 0)
      {
        UMSGetByNum (t_str, FB_E_INITGEZERO, 0);
        print_error (Dial_form, ERR_FLD, t_str);
      }
      else
        if (t_double > gadget_attr.high_value)
        {
          UMSGetByNum (t_str, FB_E_INITLEHIGH, 0);
          print_error (Dial_form, ERR_FLD, t_str);
        }
        else
        {
          FIfld_set_text (Dial_form, INITIAL_FLD, 0, 0, t_str, 0);
          gadget_attr.default_value = t_double;
          FIg_erase (Dial_form, PREVIEW_DIAL);
          FIg_set_value (Dial_form, PREVIEW_DIAL, t_double);
          FIg_display (Dial_form, PREVIEW_DIAL);
        }
    }
    break;

  case PREVIEW_DIAL:

    gadget_attr.default_value = value;
    update_dial_range_fields();
    break;

  case HIGH_CK:

    gadget_attr.high_display_flag = (int)value;

    t_mask = 0;

    if (gadget_attr.high_display_flag == 1)
      t_mask |= FI_HIGH_VALUE;

    if (gadget_attr.initial_display_flag == 1)
      t_mask |= FI_VALUE;

    FIg_erase (Dial_form, PREVIEW_DIAL);
    FIg_set_display (Dial_form, PREVIEW_DIAL, t_mask);
    FIg_display (Dial_form, PREVIEW_DIAL);
    break;

  case INITIAL_CK:

    gadget_attr.initial_display_flag = (int)value;

    t_mask = 0;

    if (gadget_attr.high_display_flag == 1)
      t_mask |= FI_HIGH_VALUE;

    if (gadget_attr.initial_display_flag == 1)
      t_mask |= FI_VALUE;

    FIg_erase (Dial_form, PREVIEW_DIAL);
    FIg_set_display (Dial_form, PREVIEW_DIAL, t_mask);
    FIg_display (Dial_form, PREVIEW_DIAL);
    break;

  case KEYIN_TOG:

    if ((int)value == 1)
    {
      gadget_attr.draw_flag = 0;
      FIg_display (Dial_form, X_TEXT);
      FIg_display (Dial_form, Y_TEXT);
      FIg_display (Dial_form, X_FLD);
      FIg_display (Dial_form, Y_FLD);
      FIg_display (Dial_form, WIDTH_TEXT);
      FIg_display (Dial_form, HEIGHT_TEXT);
      FIg_display (Dial_form, WIDTH_FLD);
      FIg_display (Dial_form, HEIGHT_FLD);
    }
    else
    {
      gadget_attr.draw_flag = 1;
      FIg_erase (Dial_form, X_TEXT);
      FIg_erase (Dial_form, Y_TEXT);
      FIg_erase (Dial_form, X_FLD);
      FIg_erase (Dial_form, Y_FLD);
      FIg_erase (Dial_form, WIDTH_TEXT);
      FIg_erase (Dial_form, HEIGHT_TEXT);
      FIg_erase (Dial_form, WIDTH_FLD);
      FIg_erase (Dial_form, HEIGHT_FLD);
    }
    break;

  case X_FLD:

    FIfld_get_text (Dial_form, X_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    t_integer = validate_integer_field (t_str, Dial_form,
        ERR_FLD, &status);

    if (status)
      if (t_integer >= 0)
        gadget_attr.x_pos = t_integer;
      else
      {
        UMSGetByNum (t_str, FB_E_XNOTNEG, 0);
        print_error (Dial_form, ERR_FLD, t_str);
      }
    break;

  case Y_FLD:

    FIfld_get_text (Dial_form, Y_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    t_integer = validate_integer_field (t_str, Dial_form,
        ERR_FLD, &status);

    if (status)
      if (t_integer >= 0)
        gadget_attr.y_pos = t_integer;
      else
      {
        UMSGetByNum (t_str, FB_E_YNOTNEG, 0);
        print_error (Dial_form, ERR_FLD, t_str);
      }
    break;

  case WIDTH_FLD:

    FIfld_get_text (Dial_form, WIDTH_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    t_integer = validate_integer_field (t_str, Dial_form, ERR_FLD, &status);

    if (status)
      if (t_integer > 0)
        gadget_attr.x_size = t_integer;
      else
      {
        UMSGetByNum (t_str, FB_E_WDGTZERO, 0);
        print_error (Dial_form, ERR_FLD, t_str);
      }
    break;

  case HEIGHT_FLD:

    FIfld_get_text (Dial_form, HEIGHT_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    t_integer = validate_integer_field (t_str, Dial_form, ERR_FLD, &status);

    if (status)
      if (t_integer > 0)
        gadget_attr.y_size = t_integer;
      else
      {
        UMSGetByNum (t_str, FB_E_HTGTZERO, 0);
        print_error (Dial_form, ERR_FLD, t_str);
      }
    break;

  case FORMAT_TOG:

    if ((int)value == 0) /* Integer */
    {
      gadget_attr.display_format = 0;

      FIg_erase (Dial_form, FRACTION_TEXT);
      FIg_erase (Dial_form, FRACTION_FLD);
      temp_dial_fraction_digits = gadget_attr.fraction_digits;
      gadget_attr.fraction_digits = 0;

      update_dial_range_fields();
    }
    else
    {
      gadget_attr.display_format = 1;

      gadget_attr.fraction_digits = temp_dial_fraction_digits;

      sprintf (t_str, "%d", gadget_attr.fraction_digits);
      FIfld_set_text (Dial_form, FRACTION_FLD, 0, 0, t_str, 0);

      FIg_display (Dial_form, FRACTION_TEXT);
      FIg_display (Dial_form, FRACTION_FLD);

      update_dial_range_fields();
    }
    break;

  case WHOLE_FLD:

    FIfld_get_text (Dial_form, WHOLE_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    t_integer = validate_integer_field (t_str, Dial_form, ERR_FLD, &status);

    if (status)
      if (t_integer > 0)
      {
        gadget_attr.whole_digits = t_integer;
        update_dial_range_fields();
      }
      else
      {
        UMSGetByNum (t_str, FB_E_WHLGTZERO, 0);
        print_error (Dial_form, ERR_FLD, t_str);
      }
    break;

  case FRACTION_FLD:

    FIfld_get_text (Dial_form, FRACTION_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    t_integer = validate_integer_field (t_str, Dial_form, ERR_FLD, &status);

    if (status)
      if (t_integer >= 0)
      {
        gadget_attr.fraction_digits = t_integer;
        update_dial_range_fields();
      }
      else
      {
        UMSGetByNum (t_str, FB_E_FRACNOTNEG, 0);
        print_error (Dial_form, ERR_FLD, t_str);
      }
    break;

  case FI_HELP:

    /* Help_topic ("Slider") */
    break;

  case FI_CANCEL:

    if (command_is_active == EDIT_GADGET)
    {
      if (edit_hilite_flag == 0)
        FIg_unhilite (work_form, old_gadget_label);

      if (edit_display_flag == 0)
        FIg_erase (work_form, old_gadget_label);
    }

    kill_place_dial();
    FIg_set_state_off (Dial_form, FI_CANCEL);
    break;

  case FI_ACCEPT:

    status = FIf_erase (Dial_form);
    FIg_set_state_off (Dial_form, FI_ACCEPT);

    if (Characteristics_form != NULL)
    {
      FIf_erase (FG_color_form);
      FIf_erase (Font_form);
      FIg_set_state_off (Characteristics_form, CHAR_FOREGROUND_CLR_BTN);
      FIg_set_state_off (Characteristics_form, CHAR_TEXT_FONT_BTN);

      replace_attr_with_overrides(); /* character.c */
    }

    create_dial_gadget();

    if (command_is_active == EDIT_GADGET)
      kill_place_dial();
    else if (Dial_form != NULL) /* Do this command again */
    {
      FIf_display (Dial_form);

      FIf_get_next_label (work_form, &gadget_attr.gadget_label);

      if (Characteristics_form != NULL)
      {
        override_attr.gadget_label = gadget_attr.gadget_label;

        sprintf (t_str, "%d", override_attr.gadget_label);
        FIfld_set_text (Characteristics_form, LABEL_FLD,
            0, 0, t_str, 0);
        FIg_erase (Characteristics_form, 10);
      }

      UMSGetByNum (t_str, FB_P_FILLDIL, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
    }
    break;
  }
  return;
}

/*************************************************************************/
/* */
/* execute_place_dial() */
/* */
/* This function is called in one of two ways. The first is to be */
/* called by the executive command handler routine. The second is to */
/* be called after dial has been successfully placed. */
/* */
/* It displays the dial form then exits. After that point */
/* the fi_dial_form() gadget notification routine will be in */
/* control. That is to say, every time the operator alters a gadget on */
/* the dial form, the fi_dial_form() function will be invoked. */
/* */
/*************************************************************************/

void execute_place_dial(void)
{
  char t_str[256];
  int status;

  if (work_form == NULL) /* No form defined */
  {
    strcpy (current_command_string, "None");
    command_is_active = 0;
    return;
  }

  UMSGetByNum (t_str, FB_I_PLACEDIL, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENDEF, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Dial_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlDil");
    status = FIf_new (144, t_str, (int (*)())fi_dial_form, &Dial_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  setup_new_dial_form();
  show_dial_form_info();

  FIf_display (Dial_form);

  FIf_get_next_label (work_form, &gadget_attr.gadget_label);

  if (Characteristics_form != NULL)
    Update_characteristics_form();

  UMSGetByNum (t_str, FB_P_FILLDIL, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}

/*--------------------------------------------------------------------------*/

void edit_dial_gadget(void)
{
  char t_str[256];
  int status;

  gadget_attr.gadget_label = old_gadget_label;

  UMSGetByNum (t_str, FB_I_EDTDIL, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENCUR, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Dial_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlDil");
    status = FIf_new (144, t_str, (int (*)())fi_dial_form, &Dial_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  setup_old_dial_form();
  show_dial_form_info();

  FIf_display (Dial_form);

  if (Characteristics_form != NULL)
    Update_characteristics_form();

  UMSGetByNum (t_str, FB_P_FILLDIL, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}
