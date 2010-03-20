/***********************************

		scroll_gdt.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
	05-07-92	sml		casted func args
*/

/*************************************/
/* */
/* This file contains functions for the "place slider" and "edit slider" */
/* commands. */
/* */
/* Programmer: Mack Draper */
/* Date: Apr. 13, 1989 */
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
#define LOW_FLD 17

#define ORIENTATION_TOG 32

#define KEYIN_TOG 31
#define X_TEXT 30
#define Y_TEXT 8
#define X_FLD 11
#define Y_FLD 19
#define WIDTH_TEXT 20
#define HEIGHT_TEXT 22
#define WIDTH_FLD 24
#define HEIGHT_FLD 25

#define PERCENTAGE_FLD 12
#define VIEW_GAUGE 18

#define ERR_FLD 10

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

Form Scroll_form = NULL;

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

extern double validate_double_field();
extern char language[80];
extern Display *display;

/*************************************************************************/
/* */
/* kill_place_scroll() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to PLACE_SCROLL indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_place_scroll(void)
{
  char t_str[256];

  if (Scroll_form != NULL)
    FIf_erase (Scroll_form);

  if (Characteristics_form != NULL)
    Clear_characteristics_form();

  FIfld_set_text (Message_form, 11, 0, 0, "", 0);
  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  if (command_is_active == PLACE_SCROLL)
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
/* setup_old_scroll_form() */
/* */
/*************************************************************************/

static void setup_old_scroll_form(void)
{
  setup_standard_attr (old_gadget_label);

  FIg_get_orientation (work_form, old_gadget_label,
      &gadget_attr.orientation);

  FIg_get_low_value (work_form, old_gadget_label, &gadget_attr.low_value);
  FIg_get_high_value (work_form, old_gadget_label, &gadget_attr.high_value);

  FIscrl_get_view (work_form, old_gadget_label, &gadget_attr.increment);

  gadget_attr.draw_flag = 0;
  gadget_attr.poke_flag = 0;
  gadget_attr.gadget_type = FI_SCROLL;
}

/*************************************************************************/
/* */
/* setup_new_scroll_form() */
/* */
/* This function is called each time the operator wishes to place a */
/* scroll gadget on the work form. It will fill in default settings for */
/* the scroll. These will be displayed in the scroll definition form */
/* when the show_scroll_info() function is called. */
/* */
/*************************************************************************/

static void setup_new_scroll_form(void)
{
  Set_new_gadget_defaults();

  gadget_attr.orientation = FI_VERTICAL; /* Vertical */

  gadget_attr.low_value = 0;
  gadget_attr.high_value = 1000;

  gadget_attr.draw_flag = 1;
  gadget_attr.poke_flag = 0;

  gadget_attr.increment = 0.20; /* view percentage */

  gadget_attr.text_gadget = 1;
  gadget_attr.gadget_type = FI_SCROLL;
  Next_in_sequence = 0;
  Next_link = -1;
}

/*************************************************************************/
/* */
/* show_scroll_form_info() */
/* */
/* This function displays the information contained in the */
/* current_gadget struct into the slider form's gadgets. */
/* */
/*************************************************************************/

static void show_scroll_form_info(void)
{
  /* dmb:09/17/91:Do we need h_str, v_str, &l_str? */
  char t_str[256], h_str[256], v_str[256], l_str[256];

  FIg_erase (Scroll_form, 10);

  sprintf (h_str, "%7.2f", gadget_attr.high_value);
  FIfld_set_text (Scroll_form, HIGH_FLD, 0, 0, h_str, 0);
  sprintf (l_str, "%7.2f", gadget_attr.low_value);
  FIfld_set_text (Scroll_form, LOW_FLD, 0, 0, l_str, 0);
  sprintf (v_str, "%5.2f", gadget_attr.increment * 100);
  FIfld_set_text (Scroll_form, PERCENTAGE_FLD, 0, 0, v_str, 0);
  FIg_set_value (Scroll_form, VIEW_GAUGE, gadget_attr.increment * 100);

  if (gadget_attr.orientation == FI_HORIZONTAL)
    FIg_set_state_on (Scroll_form, ORIENTATION_TOG);
  else
    FIg_set_state_off (Scroll_form, ORIENTATION_TOG);

  if (gadget_attr.draw_flag == 0)
  {
    FIg_set_state_on (Scroll_form, KEYIN_TOG);

    sprintf (t_str, "%d", gadget_attr.x_size);
    FIfld_set_text (Scroll_form, WIDTH_FLD, 0, 0, t_str, 0);
    sprintf (t_str, "%d", gadget_attr.y_size);
    FIfld_set_text (Scroll_form, HEIGHT_FLD, 0, 0, t_str, 0);
    sprintf (t_str, "%d", gadget_attr.x_pos);
    FIfld_set_text (Scroll_form, X_FLD, 0, 0, t_str, 0);
    sprintf (t_str, "%d", gadget_attr.y_pos);
    FIfld_set_text (Scroll_form, Y_FLD, 0, 0, t_str, 0);

    FIg_display (Scroll_form, WIDTH_TEXT);
    FIg_display (Scroll_form, HEIGHT_TEXT);
    FIg_display (Scroll_form, X_TEXT);
    FIg_display (Scroll_form, Y_TEXT);
    FIg_display (Scroll_form, WIDTH_FLD);
    FIg_display (Scroll_form, HEIGHT_FLD);
    FIg_display (Scroll_form, X_FLD);
    FIg_display (Scroll_form, Y_FLD);
  }
  else
  {
    FIg_set_state_off (Scroll_form, KEYIN_TOG);

    FIfld_set_text (Scroll_form, WIDTH_FLD, 0, 0, "", 0);
    FIfld_set_text (Scroll_form, HEIGHT_FLD, 0, 0, "", 0);
    FIfld_set_text (Scroll_form, X_FLD, 0, 0, "", 0);
    FIfld_set_text (Scroll_form, Y_FLD, 0, 0, "", 0);

    FIg_erase (Scroll_form, WIDTH_TEXT);
    FIg_erase (Scroll_form, HEIGHT_TEXT);
    FIg_erase (Scroll_form, X_TEXT);
    FIg_erase (Scroll_form, Y_TEXT);
    FIg_erase (Scroll_form, WIDTH_FLD);
    FIg_erase (Scroll_form, HEIGHT_FLD);
    FIg_erase (Scroll_form, X_FLD);
    FIg_erase (Scroll_form, Y_FLD);
  }
}

/*-------------------------------------------------------------------------*/


/*********************************************************************/
/* */
/* create_scroll_gadget() */
/* */
/* This function creates a new scroll gadget and places it at */
/* the position that was poked by the operator. */
/* */
/*********************************************************************/

static void create_scroll_gadget(void)
{
  int x, y, temp_x, temp_y;
  Window window;
  char t_str[256];
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
    UMSGetByNum (t_str, FB_P_POKSCRANC, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    FIf_get_window (work_form, &window);

    status = Get_first_point (window, &x, &y, 0, 0, 0, 0);

    if (status == 2) /* Success */
    {
      UMSGetByNum (t_str, FB_I_ANCX, "%d%d", x, y);
      FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);
      UMSGetByNum (t_str, FB_P_POKSCRSWG, 0);
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

  Create_and_init_gadget (work_form, FI_SCROLL, gadget_attr.gadget_label);

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

  FIscrl_set_view (work_form, gadget_attr.gadget_label, gadget_attr.increment);

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
/* fi_scroll_form() */
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
void fi_scroll_form (int form_label,
                    int gadget_label,
                    double value,
                    Form form_ptr)
{
  int i;
  int status;
  char t_str[256];
  double f;
  int dummy_int;

  FIg_erase (Scroll_form, ERR_FLD);

  switch (gadget_label)
  {

  case ORIENTATION_TOG:

    if ((int)value == 0)
      gadget_attr.orientation = FI_VERTICAL;
    else
      gadget_attr.orientation = FI_HORIZONTAL;
    break;

  case HIGH_FLD:

    FIfld_get_text (Scroll_form, HIGH_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    f = validate_double_field (t_str, Scroll_form, ERR_FLD, &status);

    if (status)
    {
      if (f < gadget_attr.low_value)
      {
        UMSGetByNum (t_str, FB_E_HGHGELOW, 0);
        print_error (Scroll_form, ERR_FLD, t_str);
      }
      else
      {
        gadget_attr.high_value = f;
      }
    }
    break;

  case LOW_FLD:

    FIfld_get_text (Scroll_form, LOW_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    f = validate_double_field (t_str, Scroll_form, ERR_FLD, &status);

    if (status)
    {
      if (f > gadget_attr.high_value)
      {
        UMSGetByNum (t_str, FB_E_LOWLEHGH, 0);
        print_error (Scroll_form, ERR_FLD, t_str);
      }
      else
      {
        gadget_attr.low_value = f;
      }
    }
    break;

  case PERCENTAGE_FLD:

    FIfld_get_text (Scroll_form, PERCENTAGE_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    f = validate_double_field (t_str, Scroll_form, ERR_FLD, &status);

    if (status)
    {
      if (f > 100)
      {
        UMSGetByNum (t_str, FB_E_PERLE100, 0);
        print_error (Scroll_form, ERR_FLD, t_str);
      }
      else if (f < 5)
      {
        UMSGetByNum (t_str, FB_E_PERGE5, 0);
        print_error (Scroll_form, ERR_FLD, t_str);
      }
      else
      {
        FIg_set_value (Scroll_form, VIEW_GAUGE, f);
        gadget_attr.increment = f / 100;
      }
    }
    break;

  case KEYIN_TOG:

    if ((int)value == 1)
    {
      gadget_attr.draw_flag = 0;
      FIg_display (Scroll_form, X_TEXT);
      FIg_display (Scroll_form, Y_TEXT);
      FIg_display (Scroll_form, X_FLD);
      FIg_display (Scroll_form, Y_FLD);
      FIg_display (Scroll_form, WIDTH_TEXT);
      FIg_display (Scroll_form, HEIGHT_TEXT);
      FIg_display (Scroll_form, WIDTH_FLD);
      FIg_display (Scroll_form, HEIGHT_FLD);
    }
    else
    {
      gadget_attr.draw_flag = 1;
      FIg_erase (Scroll_form, X_TEXT);
      FIg_erase (Scroll_form, Y_TEXT);
      FIg_erase (Scroll_form, X_FLD);
      FIg_erase (Scroll_form, Y_FLD);
      FIg_erase (Scroll_form, WIDTH_TEXT);
      FIg_erase (Scroll_form, HEIGHT_TEXT);
      FIg_erase (Scroll_form, WIDTH_FLD);
      FIg_erase (Scroll_form, HEIGHT_FLD);
    }
    break;

  case X_FLD:

    FIfld_get_text (Scroll_form, X_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Scroll_form,
        ERR_FLD, &status);

    if (status)
      if (i >= 0)
        gadget_attr.x_pos = i;
      else
      {
        UMSGetByNum (t_str, FB_E_XNOTNEG, 0);
        print_error (Scroll_form, ERR_FLD, t_str);
      }
    break;

  case Y_FLD:

    FIfld_get_text (Scroll_form, Y_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Scroll_form,
        ERR_FLD, &status);

    if (status)
      if (i >= 0)
        gadget_attr.y_pos = i;
      else
      {
        UMSGetByNum (t_str, FB_E_YNOTNEG, 0);
        print_error (Scroll_form, ERR_FLD, t_str);
      }
    break;

  case WIDTH_FLD:

    FIfld_get_text (Scroll_form, WIDTH_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Scroll_form, ERR_FLD, &status);

    if (status)
      if (i > 0)
        gadget_attr.x_size = i;
      else
      {
        UMSGetByNum (t_str, FB_E_WDGTZERO, 0);
        print_error (Scroll_form, ERR_FLD, t_str);
      }
    break;

  case HEIGHT_FLD:

    FIfld_get_text (Scroll_form, HEIGHT_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Scroll_form, ERR_FLD, &status);

    if (status)
      if (i > 0)
        gadget_attr.y_size = i;
      else
      {
        UMSGetByNum (t_str, FB_E_HTGTZERO, 0);
        print_error (Scroll_form, ERR_FLD, t_str);
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

    kill_place_scroll();
    FIg_set_state_off (Scroll_form, FI_CANCEL);
    break;

  case FI_ACCEPT:

    FIf_erase (Scroll_form);
    FIg_set_state_off (Scroll_form, FI_ACCEPT);

    if (Characteristics_form != NULL)
    {
      replace_attr_with_overrides(); /* character.c */
    }

    create_scroll_gadget();

    if (command_is_active == EDIT_GADGET)
      kill_place_scroll();
    else if (Scroll_form != NULL) /* Do this command again */
    {
      FIg_set_state_off (Scroll_form, FI_ACCEPT);

      FIf_display (Scroll_form);

      FIf_get_next_label (work_form, &gadget_attr.gadget_label);

      if (Characteristics_form != NULL)
      {
        override_attr.gadget_label = gadget_attr.gadget_label;

        sprintf (t_str, "%d", override_attr.gadget_label);
        FIfld_set_text (Characteristics_form, LABEL_FLD,
            0, 0, t_str, 0);
        FIg_erase (Characteristics_form, 10);
      }

      UMSGetByNum (t_str, FB_P_FILLSCRFRM, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
    }
    break;
  }

  return;
}


/*************************************************************************/
/* */
/* execute_place_scroll() */
/* */
/* This function is called in one of two ways. The first is to be */
/* called by the executive command handler routine. The second is to */
/* be called after scroll has been successfully placed. */
/* */
/* It displays the scroll form then exits. After that point */
/* the fi_scroll_form() gadget notification routine will be in */
/* control. That is to say, every time the operator alters a gadget on */
/* the scroll form, the fi_scroll_form() function will be invoked. */
/* */
/*************************************************************************/

void execute_place_scroll(void)
{
  char t_str[256];
  int status;

  if (work_form == NULL) /* No form defined */
  {
    strcpy (current_command_string, "None");
    command_is_active = 0;
    return;
  }

  UMSGetByNum (t_str, FB_I_PCESCRBAR, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENDEF, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Scroll_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlScBr");
    status = FIf_new (144, t_str, (int (*)())fi_scroll_form, &Scroll_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  setup_new_scroll_form();
  show_scroll_form_info();

  FIf_display (Scroll_form);

  FIf_get_next_label (work_form, &gadget_attr.gadget_label);

  if (Characteristics_form != NULL)
    Update_characteristics_form();

  UMSGetByNum (t_str, FB_P_FILLSCRFRM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}

/*-------------------------------------------------------------------------*/

void edit_scroll_gadget(void)
{
  char t_str[256];
  int status;

  gadget_attr.gadget_label = old_gadget_label;

  UMSGetByNum (t_str, FB_I_EDTSCRBAR, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENCUR, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Scroll_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlScBr");
    status = FIf_new (144, t_str, (int (*)())fi_scroll_form, &Scroll_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  setup_old_scroll_form();
  show_scroll_form_info();

  FIf_display (Scroll_form);

  if (Characteristics_form != NULL)
    Update_characteristics_form();

  UMSGetByNum (t_str, FB_P_FILLSCRFRM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}
