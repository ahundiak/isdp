/***********************************

		slider_gdt.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
	05-07-92	sml		casted func args for ANSI
*/

/*************************************/
/* */
/* This file contains functions for the "place slider" and "edit slider" */
/* commands. */
/* */
/* Programmer: Mack Draper */
/* Date: Jan. 10, 1989 */
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

/*************************/
/* */
/* used by slider form */
/* */
/*************************/

#define HIGH_FLD 15
#define INITIAL_FLD 16
#define LOW_FLD 17

#define HIGH_CK 37
#define INITIAL_CK 38
#define LOW_CK 39
#define MAX_TOG 21

#define ORIENTATION_TOG 32
#define FORMAT_TOG 33

#define FRACTION_TEXT 43
#define FRACTION_FLD 34
#define WHOLE_FLD 40
#define FORMAT_TEXT 55
#define INCREMENT_FLD 18

#define KEYIN_TOG 31
#define X_TEXT 30
#define Y_TEXT 8
#define X_FLD 46
#define Y_FLD 19
#define WIDTH_TEXT 20
#define HEIGHT_TEXT 22
#define WIDTH_FLD 24
#define HEIGHT_FLD 25

#define ERR_FLD 10

#define CHAR_FOREGROUND_CLR_BTN 47
#define CHAR_TEXT_FONT_BTN 46

static void create_slider_gadget();
static void setup_new_slider_form();
static void setup_old_slider_form();
static void show_slider_form_info();
static void update_slider_range_fields();

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

Form Slider_form = NULL;
static int temp_slider_fraction_digits;

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

char current_fld_value[80]; /* use to restore value if bad one entered */


/*************************************************************************/
/* */
/* kill_place_slider() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to PLACE_SLIDER indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_place_slider(void)
{
  char t_str[256];

  if (Slider_form != NULL)
    FIf_erase (Slider_form);

  if (Characteristics_form != NULL)
    Clear_characteristics_form();

  FIfld_set_text (Message_form, 11, 0, 0, "", 0);
  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  if (command_is_active == PLACE_SLIDER)
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

void format_integer_field (value, format_string)
int value;
char *format_string;
{
  char f_str[256];

  sprintf (f_str, "%%%dd", gadget_attr.whole_digits);
  sprintf (format_string, f_str, value);
}

/*------------------------------------------------------------------------*/

void format_float_field (double value,
                         char *format_string)
{
  char f_str[256];
  int total_digits;

  total_digits = gadget_attr.whole_digits + gadget_attr.fraction_digits + 1;

  sprintf (f_str, "%%%d.%df", total_digits, gadget_attr.fraction_digits);
  sprintf (format_string, f_str, value);
}

/*-------------------------------------------------------------------------*/

static void update_slider_range_fields(void)
{
  char t_str[256], h_str[256], i_str[256], l_str[256];
  int x, y;

  if (gadget_attr.display_format == 1) /* Floating point format */
  {
    format_float_field (gadget_attr.high_value, h_str);
    format_float_field (gadget_attr.default_value, i_str);
    format_float_field (gadget_attr.low_value, l_str);

    for (x = 0; x < gadget_attr.whole_digits; x++)
      t_str[x] = 'X';

    t_str[x] = '.';

    for (y = x + 1; y < (x + 1 + gadget_attr.fraction_digits); y++)
      t_str[y] = 'X';

    t_str[y] = '\0';

    FIg_erase (Slider_form, FORMAT_TEXT);

    FIg_set_off_text (Slider_form, FORMAT_TEXT, t_str);

    FIg_display (Slider_form, FORMAT_TEXT);
  }
  else /* Integer format */
  {
    format_integer_field ((int)gadget_attr.high_value, h_str);
    format_integer_field ((int)gadget_attr.default_value, i_str);
    format_integer_field ((int)gadget_attr.low_value, l_str);

    for (x = 0; x < gadget_attr.whole_digits; x++)
      t_str[x] = 'X';

    t_str[x] = '\0';

    FIg_erase (Slider_form, FORMAT_TEXT);

    FIg_set_off_text (Slider_form, FORMAT_TEXT, t_str);

    FIg_display (Slider_form, FORMAT_TEXT);
  }

  FIfld_set_text (Slider_form, HIGH_FLD, 0, 0, h_str, 0);
  FIfld_set_text (Slider_form, INITIAL_FLD, 0, 0, i_str, 0);
  FIfld_set_text (Slider_form, LOW_FLD, 0, 0, l_str, 0);
}

/*-----------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* setup_old_slider_form() */
/* */
/*************************************************************************/

static void setup_old_slider_form(void)
{
  int x, total_digits;
  float temp_increment;

  setup_standard_attr (old_gadget_label);

  FIg_get_orientation (work_form, old_gadget_label,
      &gadget_attr.orientation);

  FIg_get_low_value (work_form, old_gadget_label,
      &gadget_attr.low_value);

  FIg_get_high_value (work_form, old_gadget_label,
      &gadget_attr.high_value);

  FIg_get_increment (work_form, old_gadget_label, &temp_increment);
  gadget_attr.increment = (double) temp_increment;

  if (gadget_attr.increment <= 1.0)
  {
    gadget_attr.increment = 1.0;
  }

  FIg_get_display (work_form, old_gadget_label, &x);

  if (x & FI_LOW_VALUE)
    gadget_attr.low_display_flag = 1;
  else
    gadget_attr.low_display_flag = 0;

  if (x & FI_VALUE)
    gadget_attr.initial_display_flag = 1;
  else
    gadget_attr.initial_display_flag = 0;

  if (x & FI_HIGH_VALUE)
    gadget_attr.high_display_flag = 1;
  else
    gadget_attr.high_display_flag = 0;

  if (x & FI_MAX_MIN)
    gadget_attr.auto_popup_flag = 1;
  else
    gadget_attr.auto_popup_flag = 0;

  FIg_get_value_format (work_form, old_gadget_label, &total_digits,
      &gadget_attr.fraction_digits);

  gadget_attr.whole_digits = total_digits - gadget_attr.fraction_digits - 1;

  if (gadget_attr.fraction_digits == 0) /* Integer format */
    gadget_attr.display_format = 0;
  else
    gadget_attr.display_format = 1; /* Floating point format */

  gadget_attr.draw_flag = 0;
  gadget_attr.poke_flag = 0;
  gadget_attr.gadget_type = FI_SLIDER;
}

/*************************************************************************/
/* */
/* setup_new_slider_form() */
/* */
/* This function is called each time the operator wishes to place a */
/* slider gadget on the work form. It will fill in default settings for */
/* the slider. These will be displayed in the slider definition form */
/* when the show_slider_info() function is called. */
/* */
/*************************************************************************/

static void setup_new_slider_form(void)
{
  Set_new_gadget_defaults();

  gadget_attr.on_color = FI_BLACK;

  gadget_attr.orientation = FI_VERTICAL; /* Vertical */
  gadget_attr.display_format = 0; /* Integer */
  gadget_attr.whole_digits = 5;
  gadget_attr.fraction_digits = 0;
  temp_slider_fraction_digits = 2;

  gadget_attr.low_value = 0;
  gadget_attr.default_value = 500;
  gadget_attr.high_value = 1000;
  gadget_attr.increment = 1.0;

  gadget_attr.low_display_flag = 1; /* Display */
  gadget_attr.initial_display_flag = 1; /* Display */
  gadget_attr.high_display_flag = 1; /* Display */
  gadget_attr.auto_popup_flag = 0; /* Minimum to Maximum display */
  gadget_attr.draw_flag = 1;
  gadget_attr.poke_flag = 0;

  gadget_attr.text_gadget = 1;
  gadget_attr.gadget_type = FI_SLIDER;
  Next_in_sequence = 0;
  Next_link = -1;
}

/*************************************************************************/
/* */
/* show_slider_form_info() */
/* */
/* This function displays the information contained in the */
/* current_gadget struct into the slider form's gadgets. */
/* */
/*************************************************************************/

static void show_slider_form_info(void)
{
  char t_str[256], h_str[256], i_str[256], l_str[256], n_str[256];
  int x, y;

  FIg_erase (Slider_form, 10);

  if (gadget_attr.display_format == 1) /* Floating point format */
  {
    FIg_set_state_on (Slider_form, FORMAT_TOG);

    format_float_field (gadget_attr.high_value, h_str);
    format_float_field (gadget_attr.default_value, i_str);
    format_float_field (gadget_attr.low_value, l_str);
    format_float_field (gadget_attr.increment, n_str);

    for (x = 0; x < gadget_attr.whole_digits; x++)
      t_str[x] = 'X';

    t_str[x] = '.';

    for (y = x + 1; y < (x + 1 + gadget_attr.fraction_digits); y++)
      t_str[y] = 'X';

    t_str[y] = '\0';

    FIg_set_off_text (Slider_form, FORMAT_TEXT, t_str);

    FIg_display (Slider_form, FRACTION_TEXT);
    FIg_display (Slider_form, FRACTION_FLD);
  }
  else /* Integer format */
  {
    FIg_set_state_off (Slider_form, FORMAT_TOG);

    format_integer_field ((int)gadget_attr.high_value, h_str);
    format_integer_field ((int)gadget_attr.default_value, i_str);
    format_integer_field ((int)gadget_attr.low_value, l_str);
    format_integer_field ((int)gadget_attr.increment, n_str);

    for (x = 0; x < gadget_attr.whole_digits; x++)
      t_str[x] = 'X';

    t_str[x] = '\0';

    FIg_set_off_text (Slider_form, FORMAT_TEXT, t_str);

    FIg_erase (Slider_form, FRACTION_TEXT);
    FIg_erase (Slider_form, FRACTION_FLD);
  }

  FIfld_set_text (Slider_form, HIGH_FLD, 0, 0, h_str, 0);
  FIfld_set_text (Slider_form, INITIAL_FLD, 0, 0, i_str, 0);
  FIfld_set_text (Slider_form, LOW_FLD, 0, 0, l_str, 0);
  FIfld_set_text (Slider_form, INCREMENT_FLD, 0, 0, n_str, 0);

  if (gadget_attr.high_display_flag == 1)
    FIg_set_state_on (Slider_form, HIGH_CK);
  else
    FIg_set_state_off (Slider_form, HIGH_CK);

  if (gadget_attr.initial_display_flag == 1)
    FIg_set_state_on (Slider_form, INITIAL_CK);
  else
    FIg_set_state_off (Slider_form, INITIAL_CK);

  if (gadget_attr.low_display_flag == 1)
    FIg_set_state_on (Slider_form, LOW_CK);
  else
    FIg_set_state_off (Slider_form, LOW_CK);

  if (gadget_attr.orientation == 1)
    FIg_set_state_on (Slider_form, ORIENTATION_TOG);
  else
    FIg_set_state_off (Slider_form, ORIENTATION_TOG);

  if (gadget_attr.auto_popup_flag == 1)
    FIg_set_state_on (Slider_form, MAX_TOG);
  else
    FIg_set_state_off (Slider_form, MAX_TOG);

  sprintf (t_str, "%d", gadget_attr.whole_digits);
  FIfld_set_text (Slider_form, WHOLE_FLD, 0, 0, t_str, 0);

  sprintf (t_str, "%d", gadget_attr.fraction_digits);
  FIfld_set_text (Slider_form, FRACTION_FLD, 0, 0, t_str, 0);

  if (gadget_attr.draw_flag == 0)
  {
    FIg_set_state_on (Slider_form, KEYIN_TOG);

    sprintf (t_str, "%d", gadget_attr.x_size);
    FIfld_set_text (Slider_form, WIDTH_FLD, 0, 0, t_str, 0);
    sprintf (t_str, "%d", gadget_attr.y_size);
    FIfld_set_text (Slider_form, HEIGHT_FLD, 0, 0, t_str, 0);
    sprintf (t_str, "%d", gadget_attr.x_pos);
    FIfld_set_text (Slider_form, X_FLD, 0, 0, t_str, 0);
    sprintf (t_str, "%d", gadget_attr.y_pos);
    FIfld_set_text (Slider_form, Y_FLD, 0, 0, t_str, 0);

    FIg_display (Slider_form, WIDTH_TEXT);
    FIg_display (Slider_form, HEIGHT_TEXT);
    FIg_display (Slider_form, X_TEXT);
    FIg_display (Slider_form, Y_TEXT);
    FIg_display (Slider_form, WIDTH_FLD);
    FIg_display (Slider_form, HEIGHT_FLD);
    FIg_display (Slider_form, X_FLD);
    FIg_display (Slider_form, Y_FLD);
  }
  else
  {
    FIg_set_state_off (Slider_form, KEYIN_TOG);

    FIfld_set_text (Slider_form, WIDTH_FLD, 0, 0, "", 0);
    FIfld_set_text (Slider_form, HEIGHT_FLD, 0, 0, "", 0);
    FIfld_set_text (Slider_form, X_FLD, 0, 0, "", 0);
    FIfld_set_text (Slider_form, Y_FLD, 0, 0, "", 0);

    FIg_erase (Slider_form, WIDTH_TEXT);
    FIg_erase (Slider_form, HEIGHT_TEXT);
    FIg_erase (Slider_form, X_TEXT);
    FIg_erase (Slider_form, Y_TEXT);
    FIg_erase (Slider_form, WIDTH_FLD);
    FIg_erase (Slider_form, HEIGHT_FLD);
    FIg_erase (Slider_form, X_FLD);
    FIg_erase (Slider_form, Y_FLD);
  }
}

/*-------------------------------------------------------------------------*/

/*********************************************************************/
/* */
/* create_slider_gadget() */
/* */
/* This function creates a new slider gadget and places it at */
/* the position that was poked by the operator. */
/* */
/*********************************************************************/

static void create_slider_gadget(void)
{
  int x, y, temp_x, temp_y;
  Window window;
  char t_str[256];
  int total_digits;
  int group_label;
  int status;

  /***********************************************************/
  /* */
  /* If the work form and the place button form intersect, */
  /* then send a window update message to the work_form */
  /* */
  /***********************************************************/

  Refresh_work_form();

  if (gadget_attr.draw_flag == 0)
  {
    x = gadget_attr.x_size;
    y = gadget_attr.y_size;
  }
  else
  {
    UMSGetByNum (t_str, FB_P_POKSLIANC, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    FIf_get_window (work_form, &window);

    status = Get_first_point (window, &x, &y, 0, 0, 0, 0);

    if (status == 2) /* Success */
    {
      UMSGetByNum (t_str, FB_I_ANCX, "%d%d", x, y);
      FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);
      UMSGetByNum (t_str, FB_P_POKSLISWG, 0);
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
      else /* Operator wants to abort placing the gadget */
        return;
    }
    else /* Operator wants to abort placing the gadget */
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

  Create_and_init_gadget (work_form, FI_SLIDER, gadget_attr.gadget_label);

  if (group_label != 0)
    FIg_add_to_group (work_form, gadget_attr.gadget_label, group_label);

  gadget_attr.x_size = temp_x;
  gadget_attr.y_size = temp_y;

  FIg_set_orientation (work_form, gadget_attr.gadget_label,
      gadget_attr.orientation);

  FIg_set_low_value (work_form, gadget_attr.gadget_label,
      gadget_attr.low_value);
  FIg_set_high_value (work_form, gadget_attr.gadget_label,
      gadget_attr.high_value);
  FIg_set_increment (work_form, gadget_attr.gadget_label,
      gadget_attr.increment);

  x = 0;

  if (gadget_attr.low_display_flag == 1)
    x |= FI_LOW_VALUE;

  if (gadget_attr.initial_display_flag == 1)
    x |= FI_VALUE;

  if (gadget_attr.high_display_flag == 1)
    x |= FI_HIGH_VALUE;

  if (gadget_attr.auto_popup_flag == 1)
    x |= FI_MAX_MIN;

  FIg_set_display (work_form, gadget_attr.gadget_label, x);

  FIg_set_value (work_form, gadget_attr.gadget_label,
      gadget_attr.default_value);

  total_digits = gadget_attr.whole_digits + gadget_attr.fraction_digits + 1;

  FIg_set_value_format (work_form, gadget_attr.gadget_label, total_digits,
      gadget_attr.fraction_digits);

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

/*-----------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* fi_slider_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the default */
/* settings for a new slider gadget, or alter the settings of an */
/* existing slider gadget. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_slider_form (int form_label,
                    int gadget_label,
                    double value,
                    Form form_ptr)
{
  int i;
  int status;
  char t_str[256];
  double f;
  int dummy_int;

  FIg_erase (Slider_form, ERR_FLD);

  switch (gadget_label)
  {

  case ORIENTATION_TOG:

    if ((int)value == 0)
      gadget_attr.orientation = FI_VERTICAL;
    else
      gadget_attr.orientation = FI_HORIZONTAL;
    break;

  case INCREMENT_FLD:

    FIfld_get_text (Slider_form, INCREMENT_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    if (gadget_attr.display_format == 0) /* Integer */
    {
      i = validate_integer_field (t_str, Slider_form, ERR_FLD, &status);
      f = (double)i;
      format_integer_field (i, t_str);
    }
    else
    {
      f = validate_double_field (t_str, Slider_form, ERR_FLD, &status);
      format_float_field (f, t_str);
    }

    if (status)
    {
      if (f <= 0)
      {
        UMSGetByNum (t_str, FB_E_HIGHGTZERO, 0);
        print_error (Slider_form, ERR_FLD, t_str);
      }
      else
        gadget_attr.increment = f;
    }
    break;

  case HIGH_FLD:

    FIfld_get_text (Slider_form, HIGH_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    if (gadget_attr.display_format == 0) /* Integer */
    {
      i = validate_integer_field (t_str, Slider_form, ERR_FLD, &status);
      f = (double)i;
      format_integer_field (i, t_str);
    }
    else
    {
      f = validate_double_field (t_str, Slider_form, ERR_FLD, &status);
      format_float_field (f, t_str);
    }

    if (status)
    {
      if (f < gadget_attr.default_value)
      {
        UMSGetByNum (t_str, FB_E_HIGHGEINIT, 0);
        print_error (Slider_form, ERR_FLD, t_str);

		/*reset field to old value */
		FIfld_set_text(Slider_form, gadget_label, 0, 0,
		  current_fld_value, 0);
      }
      else
        if (f < gadget_attr.low_value)
        {
          UMSGetByNum (t_str, FB_E_HGHGELOW, 0);
          print_error (Slider_form, ERR_FLD, t_str);

		  /*reset field to old value */
		  FIfld_set_text(Slider_form, gadget_label, 0, 0,
		    current_fld_value, 0);
        }
        else
        {
          FIfld_set_text (Slider_form, HIGH_FLD, 0, 0, t_str, 0);
          gadget_attr.high_value = f;
        }
    }
    break;

  case INITIAL_FLD:

    FIfld_get_text (Slider_form, INITIAL_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    if (gadget_attr.display_format == 0) /* Integer */
    {
      i = validate_integer_field (t_str, Slider_form, ERR_FLD, &status);
      f = (double)i;
      format_integer_field (i, t_str);
    }
    else
    {
      f = validate_double_field (t_str, Slider_form, ERR_FLD, &status);
      format_float_field (f, t_str);
    }

    if (status)
    {
      if (f < gadget_attr.low_value)
      {
        UMSGetByNum (t_str, FB_E_INITGELOW, 0);
        print_error (Slider_form, ERR_FLD, t_str);

		/*reset field to old value */
		FIfld_set_text(Slider_form, gadget_label, 0, 0,
		  current_fld_value, 0);
      }
      else
        if (f > gadget_attr.high_value)
        {
          UMSGetByNum (t_str, FB_E_INITLEHIGH, 0);
          print_error (Slider_form, ERR_FLD, t_str);

		  /*reset field to old value */
		  FIfld_set_text(Slider_form, gadget_label, 0, 0,
		    current_fld_value, 0);
        }
        else
        {
          FIfld_set_text (Slider_form, INITIAL_FLD, 0, 0, t_str, 0);
          gadget_attr.default_value = f;
        }
    }
    break;

  case LOW_FLD:

    FIfld_get_text (Slider_form, LOW_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    if (gadget_attr.display_format == 0) /* Integer */
    {
      i = validate_integer_field (t_str, Slider_form, ERR_FLD, &status);
      f = (double)i;
      format_integer_field (i, t_str);
    }
    else
    {
      f = validate_double_field (t_str, Slider_form, ERR_FLD, &status);
      format_float_field (f, t_str);
    }
    if (status)
    {
      if (f > gadget_attr.default_value)
      {
        UMSGetByNum (t_str, FB_E_LOWLEINIT, 0);
        print_error (Slider_form, ERR_FLD, t_str);

		/*reset field to old value */
		FIfld_set_text(Slider_form, gadget_label, 0, 0,
		  current_fld_value, 0);
      }
      else
        if (f > gadget_attr.high_value)
        {
          UMSGetByNum (t_str, FB_E_LOWLEHIGH, 0);
          print_error (Slider_form, ERR_FLD, t_str);

		  /*reset field to old value */
		  FIfld_set_text(Slider_form, gadget_label, 0, 0,
		    current_fld_value, 0);
        }
        else
        {
          FIfld_set_text (Slider_form, LOW_FLD, 0, 0, t_str, 0);
          gadget_attr.low_value = f;
        }
    }
    break;

  case HIGH_CK:

    gadget_attr.high_display_flag = (int)value;
    break;

  case INITIAL_CK:

    gadget_attr.initial_display_flag = (int)value;
    break;

  case LOW_CK:

    gadget_attr.low_display_flag = (int)value;
    break;

  case MAX_TOG:

    gadget_attr.auto_popup_flag = (int)value;
    break;

  case KEYIN_TOG:

    if ((int)value == 1)
    {
      gadget_attr.draw_flag = 0;
      FIg_display (Slider_form, X_TEXT);
      FIg_display (Slider_form, Y_TEXT);
      FIg_display (Slider_form, X_FLD);
      FIg_display (Slider_form, Y_FLD);
      FIg_display (Slider_form, WIDTH_TEXT);
      FIg_display (Slider_form, HEIGHT_TEXT);
      FIg_display (Slider_form, WIDTH_FLD);
      FIg_display (Slider_form, HEIGHT_FLD);
    }
    else
    {
      gadget_attr.draw_flag = 1;
      FIg_erase (Slider_form, X_TEXT);
      FIg_erase (Slider_form, Y_TEXT);
      FIg_erase (Slider_form, X_FLD);
      FIg_erase (Slider_form, Y_FLD);
      FIg_erase (Slider_form, WIDTH_TEXT);
      FIg_erase (Slider_form, HEIGHT_TEXT);
      FIg_erase (Slider_form, WIDTH_FLD);
      FIg_erase (Slider_form, HEIGHT_FLD);
    }
    break;

  case X_FLD:

    FIfld_get_text (Slider_form, X_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Slider_form,
        ERR_FLD, &status);

    if (status)
      if (i >= 0)
        gadget_attr.x_pos = i;
      else
      {
        UMSGetByNum (t_str, FB_E_XNOTNEG, 0);
        print_error (Slider_form, ERR_FLD, t_str);
      }
    break;

  case Y_FLD:

    FIfld_get_text (Slider_form, Y_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Slider_form,
        ERR_FLD, &status);

    if (status)
      if (i >= 0)
        gadget_attr.y_pos = i;
      else
      {
        UMSGetByNum (t_str, FB_E_YNOTNEG, 0);
        print_error (Slider_form, ERR_FLD, t_str);
      }
    break;

  case WIDTH_FLD:

    FIfld_get_text (Slider_form, WIDTH_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Slider_form, ERR_FLD, &status);

    if (status)
      if (i > 0)
        gadget_attr.x_size = i;
      else
      {
        UMSGetByNum (t_str, FB_E_WDGTZERO, 0);
        print_error (Slider_form, ERR_FLD, t_str);
      }
    break;

  case HEIGHT_FLD:

    FIfld_get_text (Slider_form, HEIGHT_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Slider_form, ERR_FLD, &status);

    if (status)
      if (i > 0)
        gadget_attr.y_size = i;
      else
      {
        UMSGetByNum (t_str, FB_E_HTGTZERO, 0);
        print_error (Slider_form, ERR_FLD, t_str);
      }
    break;

  case FORMAT_TOG:

    if ((int)value == 0) /* Integer */
    {
      gadget_attr.display_format = 0;

      FIg_erase (Slider_form, FRACTION_TEXT);
      FIg_erase (Slider_form, FRACTION_FLD);
      temp_slider_fraction_digits = gadget_attr.fraction_digits;
      gadget_attr.fraction_digits = 0;

      update_slider_range_fields();
    }
    else
    {
      gadget_attr.display_format = 1;

      gadget_attr.fraction_digits = temp_slider_fraction_digits;

      sprintf (t_str, "%d", gadget_attr.fraction_digits);
      FIfld_set_text (Slider_form, FRACTION_FLD, 0, 0, t_str, 0);

      FIg_display (Slider_form, FRACTION_TEXT);
      FIg_display (Slider_form, FRACTION_FLD);

      update_slider_range_fields();
    }
    break;

  case WHOLE_FLD:

    FIfld_get_text (Slider_form, WHOLE_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Slider_form, ERR_FLD, &status);

    if (status)
      if (i > 0)
      {
        gadget_attr.whole_digits = i;
        update_slider_range_fields();
      }
      else
      {
        UMSGetByNum (t_str, FB_E_WHLGTZERO, 0);
        print_error (Slider_form, ERR_FLD, t_str);
      }
    break;

  case FRACTION_FLD:

    FIfld_get_text (Slider_form, FRACTION_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Slider_form, ERR_FLD, &status);

    if (status)
      if (i >= 0)
      {
        gadget_attr.fraction_digits = i;
        update_slider_range_fields();
      }
      else
      {
        UMSGetByNum (t_str, FB_E_FRACNOTNEG, 0);
        print_error (Slider_form, ERR_FLD, t_str);
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

    kill_place_slider();
    FIg_set_state_off (Slider_form, FI_CANCEL);
    break;

  case FI_ACCEPT:

    FIf_erase (Slider_form);
    FIg_set_state_off (Slider_form, FI_ACCEPT);

    if (Characteristics_form != NULL)
    {
      FIf_erase (FG_color_form);
      FIf_erase (Font_form);
      FIg_set_state_off (Characteristics_form, CHAR_FOREGROUND_CLR_BTN);
      FIg_set_state_off (Characteristics_form, CHAR_TEXT_FONT_BTN);

      replace_attr_with_overrides(); /* character.c */
    }

    create_slider_gadget();

    if (command_is_active == EDIT_GADGET)
      kill_place_slider();
    else if (Slider_form != NULL) /* Do this command again */
    {
      FIf_display (Slider_form);

      FIf_get_next_label (work_form, &gadget_attr.gadget_label);

      if (Characteristics_form != NULL)
      {
        override_attr.gadget_label = gadget_attr.gadget_label;

        sprintf (t_str, "%d", override_attr.gadget_label);
        FIfld_set_text (Characteristics_form, LABEL_FLD,
            0, 0, t_str, 0);
        FIg_erase (Characteristics_form, 10);
      }

      UMSGetByNum (t_str, FB_P_FILLSLIFRM, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
    }
    break;
  }
  return;
}

/*************************************************************************/
/* */
/* execute_place_slider() */
/* */
/* This function is called in one of two ways. The first is to be */
/* called by the executive command handler routine. The second is to */
/* be called after slider has been successfully placed. */
/* */
/* It displays the slider form then exits. After that point */
/* the fi_slider_form() gadget notification routine will be in */
/* control. That is to say, every time the operator alters a gadget on */
/* the slider form, the fi_slider_form() function will be invoked. */
/* */
/*************************************************************************/

void execute_place_slider(void)
{
  char t_str[256];
  int status;

  if (work_form == NULL) /* No form defined */
  {
    strcpy (current_command_string, "None");
    command_is_active = 0;
    return;
  }

  UMSGetByNum (t_str, FB_I_PCESLI, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENDEF, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Slider_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlSli");

    status = FIf_new (144, t_str, (int (*)())fi_slider_form, &Slider_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);

	/* save original field value in case invalid one is entered */
	status = FIf_set_initial_notification_routine(Slider_form, 
	  (int (*)())initial_notify_slider);
  }

  setup_new_slider_form();
  show_slider_form_info();

  FIf_display (Slider_form);

  FIf_get_next_label (work_form, &gadget_attr.gadget_label);

  if (Characteristics_form != NULL)
    Update_characteristics_form();

  UMSGetByNum (t_str, FB_P_FILLSLIFRM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}

/*-------------------------------------------------------------------------*/

void edit_slider_gadget(void)
{
  char t_str[256];
  int status;

  gadget_attr.gadget_label = old_gadget_label;

  UMSGetByNum (t_str, FB_I_EDTSLI, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENCUR, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Slider_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlSli");
    status = FIf_new (144, t_str, (int (*)())fi_slider_form, &Slider_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);

	/* save original field value in case invalid one is entered */
	status = FIf_set_initial_notification_routine(Slider_form, 
	  (int (*)())initial_notify_slider);

  }

  setup_old_slider_form();
  show_slider_form_info();

  FIf_display (Slider_form);

  if (Characteristics_form != NULL)
    Update_characteristics_form();

  UMSGetByNum (t_str, FB_P_FILLSLIFRM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}


/* sml:08-14-92	added this to save original value in case an
				invalid value is entered into the field
*/
/*ARGSUSED*/
void initial_notify_slider(int    form,
                           int    gadget,
                           double value,
                           Form   fp)
{
  int row_pos, sel_flag;
  int length;


  switch(gadget)
  {
	case HIGH_FLD:
	case LOW_FLD:
	case INITIAL_FLD:
	  strcpy(current_fld_value, "");

	  FIfld_get_text_length(fp, gadget, (int)value, 0, &length);
	  length++;
	  FIfld_get_text(fp, gadget, (int)value, 0, length, 
		(unsigned char *)current_fld_value, &row_pos, &sel_flag);

	  break;

	default:
	  break;
  }
}
