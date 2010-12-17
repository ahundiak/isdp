/***********************************

		gauge_gdt.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
	05-07-92	sml		casted func args for ANSI
*/

/*************************************/
/* */
/* This file contains functions for the "place gauge" and "edit gauge" */
/* commands. */
/* */
/* Programmer: Mack Draper */
/* Date: Mar. 20, 1989 */
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
/* used by gauge form */
/* */
/*************************/

#define HIGH_FLD 12
#define INITIAL_FLD 13
#define INCREMENT_FLD 14

#define ORIENTATION_TOG 18
#define KEYIN_TOG 19

#define X_TEXT 22
#define Y_TEXT 23
#define X_FLD 26
#define Y_FLD 27
#define WIDTH_TEXT 20
#define HEIGHT_TEXT 21
#define WIDTH_FLD 24
#define HEIGHT_FLD 25

#define ERR_FLD 10

#define CHAR_FOREGROUND_CLR_BTN 47
#define CHAR_FOREGROUND2_CLR_BTN 48

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

Form Gauge_form = NULL;

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
extern Form FG2_color_form;
extern Form Message_form;
extern int edit_hilite_flag;
extern int edit_display_flag;
extern int old_gadget_label;
extern int Next_link;

extern int Edit_data_link_array[100];
extern int Edit_data_link_count;

extern char language[80];
extern Display *display;

/*************************************************************************/
/* */
/* kill_place_gauge() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to PLACE_GAUGE indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_place_gauge(void)
{
  char t_str[256];

  if (Gauge_form != NULL)
    FIf_erase (Gauge_form);

  if (Characteristics_form != NULL)
    Clear_characteristics_form();

  FIfld_set_text (Message_form, 11, 0, 0, "", 0);
  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  if (command_is_active == PLACE_GAUGE)
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

/*-------------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* setup_old_gauge_form() */
/* */
/*************************************************************************/

static void setup_old_gauge_form(void)
{
  setup_standard_attr (old_gadget_label);

  FIg_get_orientation (work_form, old_gadget_label,
      &gadget_attr.orientation);

  FIg_get_high_value (work_form, old_gadget_label,
      &gadget_attr.high_value);

  FIg_get_minor_increments(work_form, old_gadget_label,
      &gadget_attr.dial_ticks);
  gadget_attr.draw_flag = 0;
  gadget_attr.poke_flag = 0;
  gadget_attr.gadget_type = FI_GAUGE;
}

/*************************************************************************/
/* */
/* setup_new_gauge_form() */
/* */
/* This function is called each time the operator wishes to place a */
/* gauge gadget on the work form. It will fill in default settings for */
/* the gauge. These will be displayed in the gauge definition form */
/* when the show_gauge_info() function is called. */
/* */
/*************************************************************************/

static void setup_new_gauge_form(void)
{
  Set_new_gadget_defaults();

  gadget_attr.orientation = FI_VERTICAL; /* Vertical */

  gadget_attr.default_value = 0;
  gadget_attr.high_value = 1000;
  gadget_attr.dial_ticks = 10;

  gadget_attr.draw_flag = 1;
  gadget_attr.poke_flag = 0;

  gadget_attr.text_gadget = 1;
  gadget_attr.gadget_type = FI_GAUGE;
  Next_link = -1;
}

/*************************************************************************/
/* */
/* show_gauge_form_info() */
/* */
/* This function displays the information contained in the */
/* current_gadget struct into the gauge form's gadgets. */
/* */
/*************************************************************************/

static void show_gauge_form_info(void)
{
  char t_str[256];

  FIg_erase (Gauge_form, 10);

  sprintf (t_str, "%d", (int)gadget_attr.high_value);
  FIfld_set_text (Gauge_form, HIGH_FLD, 0, 0, t_str, 0);

  sprintf (t_str, "%d", (int)gadget_attr.default_value);
  FIfld_set_text (Gauge_form, INITIAL_FLD, 0, 0, t_str, 0);

  if (gadget_attr.orientation == 1)
    FIg_set_state_on (Gauge_form, ORIENTATION_TOG);
  else
    FIg_set_state_off (Gauge_form, ORIENTATION_TOG);

  if (gadget_attr.draw_flag == 0)
  {
    FIg_set_state_on (Gauge_form, KEYIN_TOG);

    sprintf (t_str, "%d", gadget_attr.x_size);
    FIfld_set_text (Gauge_form, WIDTH_FLD, 0, 0, t_str, 0);
    sprintf (t_str, "%d", gadget_attr.y_size);
    FIfld_set_text (Gauge_form, HEIGHT_FLD, 0, 0, t_str, 0);
    sprintf (t_str, "%d", gadget_attr.x_pos);
    FIfld_set_text (Gauge_form, X_FLD, 0, 0, t_str, 0);
    sprintf (t_str, "%d", gadget_attr.y_pos);
    FIfld_set_text (Gauge_form, Y_FLD, 0, 0, t_str, 0);

    FIg_display (Gauge_form, WIDTH_TEXT);
    FIg_display (Gauge_form, HEIGHT_TEXT);
    FIg_display (Gauge_form, X_TEXT);
    FIg_display (Gauge_form, Y_TEXT);
    FIg_display (Gauge_form, WIDTH_FLD);
    FIg_display (Gauge_form, HEIGHT_FLD);
    FIg_display (Gauge_form, X_FLD);
    FIg_display (Gauge_form, Y_FLD);
  }
  else
  {
    FIg_set_state_off (Gauge_form, KEYIN_TOG);
    FIg_erase (Gauge_form, WIDTH_TEXT);
    FIg_erase (Gauge_form, HEIGHT_TEXT);
    FIg_erase (Gauge_form, X_TEXT);
    FIg_erase (Gauge_form, Y_TEXT);
    FIg_erase (Gauge_form, WIDTH_FLD);
    FIg_erase (Gauge_form, HEIGHT_FLD);
    FIg_erase (Gauge_form, X_FLD);
    FIg_erase (Gauge_form, Y_FLD);

    FIfld_set_text (Gauge_form, WIDTH_FLD, 0, 0, "", 0);
    FIfld_set_text (Gauge_form, HEIGHT_FLD, 0, 0, "", 0);
    FIfld_set_text (Gauge_form, X_FLD, 0, 0, "", 0);
    FIfld_set_text (Gauge_form, Y_FLD, 0, 0, "", 0);
  }

  sprintf (t_str, "%3d", gadget_attr.dial_ticks);
  FIfld_set_text (Gauge_form, INCREMENT_FLD, 0, 0, t_str, 0);
}

/*-------------------------------------------------------------------------*/

/*********************************************************************/
/* */
/* create_gauge_gadget() */
/* */
/* This function creates a new gauge gadget and places it at */
/* the position that was poked by the operator. */
/* */
/*********************************************************************/

static void create_gauge_gadget(void)
{
  int x, y, temp_x, temp_y;
  Window window;
  char t_str[256];
  int group_label;
  int status;

  /***********************************************************/
  /* */
  /* If the work form and the place gauge form intersect, */
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
    UMSGetByNum (t_str, FB_P_POKGGEANC, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    FIf_get_window (work_form, &window);

    status = Get_first_point (window, &x, &y, 0, 0, 0, 0);

    if (status == 2) /* Success */
    {
      UMSGetByNum (t_str, FB_I_ANCX, "%d%d", x, y);
      FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);
      UMSGetByNum (t_str, FB_P_POKGGESWG, 0);
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

  Create_and_init_gadget (work_form, FI_GAUGE, gadget_attr.gadget_label);

  if (group_label != 0)
    FIg_add_to_group (work_form, gadget_attr.gadget_label, group_label);

  gadget_attr.x_size = temp_x;
  gadget_attr.y_size = temp_y;

  FIg_set_orientation (work_form, gadget_attr.gadget_label,
      gadget_attr.orientation);

  FIg_set_high_value (work_form, gadget_attr.gadget_label,
      gadget_attr.high_value);

  FIg_set_minor_increments (work_form, gadget_attr.gadget_label,
      gadget_attr.dial_ticks);

  FIg_activate (work_form, gadget_attr.gadget_label);

  FIg_set_pass_data (work_form, gadget_attr.gadget_label, Next_link);

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
/* fi_gauge_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the default */
/* settings for a new gauge gadget, or alter the settings of an */
/* existing gauge gadget. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_gauge_form (int form_label,
                   int gadget_label,
                   double value,
                   Form form_ptr)
{
  int i;
  int status;
  char t_str[256];
  double f;
  int dummy_int;

  FIg_erase (Gauge_form, ERR_FLD);

  switch (gadget_label)
  {

  case ORIENTATION_TOG:

    if ((int)value == 0)
      gadget_attr.orientation = FI_VERTICAL;
    else
      gadget_attr.orientation = FI_HORIZONTAL;
    break;

  case INCREMENT_FLD:

    FIfld_get_text (Gauge_form, INCREMENT_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Gauge_form, ERR_FLD, &status);

    if (status)
    {
      if (i <= 0)
      {
        UMSGetByNum (t_str, FB_E_INCSGTZERO, 0);
        print_error (Gauge_form, ERR_FLD, t_str);
      }
      else
        gadget_attr.dial_ticks = i;
    }
    break;

  case HIGH_FLD:

    FIfld_get_text (Gauge_form, HIGH_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Gauge_form, ERR_FLD, &status);
    f = (double)i;

    if (status)
    {
      if (f <= 0)
      {
        UMSGetByNum (t_str, FB_E_HIGHGTZERO, 0);
        print_error (Gauge_form, ERR_FLD, t_str);
      }
      else if (f < gadget_attr.default_value)
      {
        UMSGetByNum (t_str, FB_E_HIGHGEINIT, 0);
        print_error (Gauge_form, ERR_FLD, t_str);
      }
      else
        gadget_attr.high_value = f;
    }
    break;

  case INITIAL_FLD:

    FIfld_get_text (Gauge_form, INITIAL_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Gauge_form, ERR_FLD, &status);
    f = (double)i;

    if (status)
    {
      if (f < 0)
      {
        UMSGetByNum (t_str, FB_E_DEFGEZERO, 0);
        print_error (Gauge_form, ERR_FLD, t_str);
      }
      else if (f > gadget_attr.high_value)
      {
        UMSGetByNum (t_str, FB_E_DEFLEHIGH, 0);
        print_error (Gauge_form, ERR_FLD, t_str);
      }
      else
        gadget_attr.default_value = f;
    }
    break;

  case KEYIN_TOG:

    if ((int)value == 1)
    {
      gadget_attr.draw_flag = 0;
      FIg_display (Gauge_form, X_TEXT);
      FIg_display (Gauge_form, Y_TEXT);
      FIg_display (Gauge_form, X_FLD);
      FIg_display (Gauge_form, Y_FLD);
      FIg_display (Gauge_form, WIDTH_TEXT);
      FIg_display (Gauge_form, HEIGHT_TEXT);
      FIg_display (Gauge_form, WIDTH_FLD);
      FIg_display (Gauge_form, HEIGHT_FLD);
    }
    else
    {
      gadget_attr.draw_flag = 1;
      FIg_erase (Gauge_form, X_TEXT);
      FIg_erase (Gauge_form, Y_TEXT);
      FIg_erase (Gauge_form, X_FLD);
      FIg_erase (Gauge_form, Y_FLD);
      FIg_erase (Gauge_form, WIDTH_TEXT);
      FIg_erase (Gauge_form, HEIGHT_TEXT);
      FIg_erase (Gauge_form, WIDTH_FLD);
      FIg_erase (Gauge_form, HEIGHT_FLD);
    }
    break;

  case X_FLD:

    FIfld_get_text (Gauge_form, X_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Gauge_form,
        ERR_FLD, &status);

    if (status)
      if (i >= 0)
        gadget_attr.x_pos = i;
      else
      {
        UMSGetByNum (t_str, FB_E_XNOTNEG, 0);
        print_error (Gauge_form, ERR_FLD, t_str);
      }
    break;

  case Y_FLD:

    FIfld_get_text (Gauge_form, Y_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Gauge_form,
        ERR_FLD, &status);

    if (status)
      if (i >= 0)
        gadget_attr.y_pos = i;
      else
      {
        UMSGetByNum (t_str, FB_E_YNOTNEG, 0);
        print_error (Gauge_form, ERR_FLD, t_str);
      }
    break;

  case WIDTH_FLD:

    FIfld_get_text (Gauge_form, WIDTH_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Gauge_form, ERR_FLD, &status);

    if (status)
      if (i > 0)
        gadget_attr.x_size = i;
      else
      {
        UMSGetByNum (t_str, FB_E_WDGTZERO, 0);
        print_error (Gauge_form, ERR_FLD, t_str);
      }
    break;

  case HEIGHT_FLD:

    FIfld_get_text (Gauge_form, HEIGHT_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Gauge_form, ERR_FLD, &status);

    if (status)
      if (i > 0)
        gadget_attr.y_size = i;
      else
      {
        UMSGetByNum (t_str, FB_E_HTGTZERO, 0);
        print_error (Gauge_form, ERR_FLD, t_str);
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

    kill_place_gauge();
    FIg_set_state_off (Gauge_form, FI_CANCEL);
    break;

  case FI_ACCEPT:

    FIf_erase (Gauge_form);
    FIg_set_state_off (Gauge_form, FI_ACCEPT);

    if (Characteristics_form != NULL)
    {
      FIf_erase (FG_color_form);
      FIf_erase (FG2_color_form);
      FIg_set_state_off (Characteristics_form, CHAR_FOREGROUND_CLR_BTN);

      replace_attr_with_overrides(); /* character.c */
    }

    create_gauge_gadget();

    if (command_is_active == EDIT_GADGET)
      kill_place_gauge();
    else if (Gauge_form != NULL) /* Do this command again */
    {
      FIf_display (Gauge_form);

      FIf_get_next_label (work_form, &gadget_attr.gadget_label);

      if (Characteristics_form != NULL)
      {
        override_attr.gadget_label = gadget_attr.gadget_label;

        sprintf (t_str, "%d", override_attr.gadget_label);
        FIfld_set_text (Characteristics_form, LABEL_FLD,
            0, 0, t_str, 0);
        FIg_erase (Characteristics_form, 10);
      }

      UMSGetByNum (t_str, FB_P_FILLGGE, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
    }
    break;
  }

  return;
}

/*************************************************************************/
/* */
/* execute_place_gauge() */
/* */
/* This function is called in one of two ways. The first is to be */
/* called by the executive command handler routine. The second is to */
/* be called after slider has been successfully placed. */
/* */
/* It displays the gauge form then exits. After that point */
/* the fi_gauge_form() gadget notification routine will be in */
/* control. That is to say, every time the operator alters a gadget on */
/* the gauge form, the fi_gauge_form() function will be invoked. */
/* */
/*************************************************************************/

void execute_place_gauge(void)
{
  char t_str[256];
  int status;

  if (work_form == NULL) /* No form defined */
  {
    strcpy (current_command_string, "None");
    command_is_active = 0;
    return;
  }

  UMSGetByNum (t_str, FB_I_PLAGGE, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENDEF, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Gauge_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlGge");
    status = FIf_new (144, t_str, (int (*)())fi_gauge_form, &Gauge_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  setup_new_gauge_form();
  show_gauge_form_info();

  FIf_display (Gauge_form);

  FIf_get_next_label (work_form, &gadget_attr.gadget_label);

  if (Characteristics_form != NULL)
    Update_characteristics_form();

  UMSGetByNum (t_str, FB_P_FILLGGE, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}

/*-------------------------------------------------------------------------*/

void edit_gauge_gadget(void)
{
  char t_str[256];
  int status;

  gadget_attr.gadget_label = old_gadget_label;

  UMSGetByNum (t_str, FB_I_EDTGGE, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENCUR, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Gauge_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlGge");
    status = FIf_new (144, t_str, (int (*)())fi_gauge_form, &Gauge_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  setup_old_gauge_form();
  show_gauge_form_info();

  FIf_display (Gauge_form);

  if (Characteristics_form != NULL)
    Update_characteristics_form();

  UMSGetByNum (t_str, FB_P_FILLGGE, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}
