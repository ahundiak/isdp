/***********************************

		button_pal.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
*/

/*************************************/
/* */
/* This file contains functions for the "place button palette" and */
/* "edit button palette" commands. */
/* */
/* Programmer: Mack Draper */
/* Date: Jan. 24, 1988 */
/* */
/*************************************/

#include <stdio.h>

#include <X11/Xlib.h>

#include "FI.h"
#include "FIdyn.h"
#include "NFBpriv.h"
#include "UMS.h"
#include "FB.h"

#include "FIform.h"

#include "XFIproto_pub.h"
#include "XFBproto_pri.h"

/*********************************/
/* */
/* used by button palette form */
/* */
/*********************************/

#define COLUMNS_FLD 43
#define ROWS_FLD 42
#define SELECT_TOG 40

#define SPECIFY_TOG 12

#define LG_BTN 29
#define MED_BTN 30
#define SM_BTN 23
#define SPECIFY_BTN 32

#define HEIGHT_TEXT 49
#define WIDTH_TEXT 46
#define HEIGHT_FLD 38
#define WIDTH_FLD 36

#define X_TEXT 24
#define Y_TEXT 25
#define X_FLD 52
#define Y_FLD 53

#define ERR_FLD 10

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

Form Palette_form = NULL;

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern Form work_form;
extern int command_is_active;
extern char current_command_string[80];
extern struct gadget_struct gadget_attr;
extern char execute_dir[200];

extern char language[80];
extern Display *display;
extern Form Message_form;

/*************************************************************************/
/* */
/* kill_place_palette() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to PLACE_PALETTE indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_place_palette(void)
{
  char t_str[256];

  if (Palette_form != NULL)
  {
    FIf_erase (Palette_form);
  }

  command_is_active = 0;
  strcpy (current_command_string, "None");

  UMSGetByNum (t_str, FB_P_SELCOM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
  FIfld_set_text (Message_form, 11, 0, 0, "", 0);
  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

}

/*************************************************************************/
/* */
/* setup_new_palette_form() */
/* */
/* This function is called each time the operator wishes to place a */
/* new palette on the work form. It will fill in default settings for */
/* the palette. These will be displayed in the palette definition form */
/* when the show_palette_info() function is called. */
/* */
/*************************************************************************/

static void setup_new_palette_form(void)
{
  Set_new_gadget_defaults();

  gadget_attr.x_size = 45;
  gadget_attr.y_size = 43;
  gadget_attr.off_text[0] = '\0'; /* NULL string */
  gadget_attr.text_gadget = 1;
  gadget_attr.default_value = 0;

  gadget_attr.num_rows = 4;
  gadget_attr.num_cols = 4;

  gadget_attr.orientation = 0; /* Single select */

  gadget_attr.poke_flag = 1;

}

/*************************************************************************/
/* */
/* show_palette_form_info() */
/* */
/* This function displays the information contained in the */
/* current_gadget struct into the palette form's gadgets. */
/* */
/*************************************************************************/

static void show_palette_form_info(void)
{
  char t_str[256];
  int status;

  sprintf (t_str, "%d", gadget_attr.x_size);
  status = FIfld_set_text (Palette_form, WIDTH_FLD, 0, 0, t_str, 0);

  sprintf (t_str, "%d", gadget_attr.y_size);
  status = FIfld_set_text (Palette_form, HEIGHT_FLD, 0, 0, t_str, 0);

  sprintf (t_str, "%d", gadget_attr.num_rows);
  status = FIfld_set_text (Palette_form, ROWS_FLD, 0, 0, t_str, 0);

  sprintf (t_str, "%d", gadget_attr.num_cols);
  status = FIfld_set_text (Palette_form, COLUMNS_FLD, 0, 0, t_str, 0);

  FIfld_set_text (Palette_form, X_FLD, 0, 0, "", 0);
  FIfld_set_text (Palette_form, Y_FLD, 0, 0, "", 0);
}

/*-------------------------------------------------------------------------*/

/*********************************************************************/
/* */
/* create_button_palette() */
/* */
/* This function creates a new button palette and places it at */
/* the position that was poked by the operator. */
/* */
/*********************************************************************/

static void create_button_palette(void)
{
  int x, y, temp_xpos, temp_ypos, temp_xsize, temp_ysize;
  int new_label;
  int group_label;
  char t_str[256];

  Window window;
  int status;

  /***********************************************************/
  /* */
  /* If the work form and the place palette form intersect, */
  /* then send a window update message to the work_form */
  /* */
  /***********************************************************/

  Refresh_work_form();

  if (gadget_attr.poke_flag == 1)
  {
    UMSGetByNum (t_str, FB_P_POKPAL, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    FIf_get_window (work_form, &window);

    status = Get_first_point (window, &gadget_attr.x_pos,
        &gadget_attr.y_pos,
        gadget_attr.x_size * gadget_attr.num_cols,
        gadget_attr.y_size * gadget_attr.num_rows, 0, 0);

    if (status == 2) /* Success */
    {
      /* Success */
    }
    else /* Operator wants to kill this command */
      return;
  }

  status = FIf_get_next_label (work_form, &group_label);

  status = FIg_new (work_form, FI_GROUP, group_label);

  temp_xpos = gadget_attr.x_pos;
  temp_ypos = gadget_attr.y_pos;
  temp_xsize = gadget_attr.x_size;
  temp_ysize = gadget_attr.y_size;

  for (x = 0; x < gadget_attr.num_rows; x++)
    for (y = 0; y < gadget_attr.num_cols; y++)
    {
      gadget_attr.x_pos = temp_xpos + (y * temp_xsize);
      gadget_attr.y_pos = temp_ypos + (x * temp_ysize);
      gadget_attr.x_size = temp_xpos + ((y + 1) * temp_xsize);
      gadget_attr.y_size = temp_ypos + ((x + 1) * temp_ysize);

      FIf_get_next_label (work_form, &new_label);

      Create_and_init_gadget (work_form, FI_BUTTON, new_label);

      FIg_activate (work_form, new_label);

      status = FIg_display (work_form, new_label);

      status = FIg_add_to_group (work_form, new_label, group_label);
    }

  FIf_calculate_size ((struct FIform_obj *)work_form);
  FIgrp_calculate_size ((struct FIform_obj *)work_form, group_label);

  if (gadget_attr.orientation == 0)
    FIgrp_set_single_select_on (work_form, group_label);

  gadget_attr.x_pos = temp_xpos;
  gadget_attr.y_pos = temp_ypos;
  gadget_attr.x_size = temp_xsize;
  gadget_attr.y_size = temp_ysize;
}



/*************************************************************************/
/* */
/* fi_palette_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the default */
/* settings for a new button palette, or alter the settings of an */
/* existing button palette. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_palette_form(int form_label,
                    int gadget_label,
                    double value,
                    Form form_ptr)
{
  int i;
  int status;
  char t_str[256];
  int dummy_int;

  FIg_erase (Palette_form, ERR_FLD);

  switch (gadget_label)
  {
  case SELECT_TOG:

    gadget_attr.orientation = (int)value;
    break;

  case SM_BTN:

    FIg_set_state_on (Palette_form, SM_BTN);
    FIg_set_state_off (Palette_form, MED_BTN);
    FIg_set_state_off (Palette_form, LG_BTN);
    FIg_set_state_off (Palette_form, SPECIFY_BTN);

    gadget_attr.x_size = 45;
    sprintf (t_str, "%d", gadget_attr.x_size);
    FIfld_set_text (Palette_form, WIDTH_FLD, 0, 0, t_str, 0);

    gadget_attr.y_size = 43;
    sprintf (t_str, "%d", gadget_attr.y_size);
    FIfld_set_text (Palette_form, HEIGHT_FLD, 0, 0, t_str, 0);

    break;

  case MED_BTN:

    FIg_set_state_off (Palette_form, SM_BTN);
    FIg_set_state_on (Palette_form, MED_BTN);
    FIg_set_state_off (Palette_form, LG_BTN);
    FIg_set_state_off (Palette_form, SPECIFY_BTN);

    gadget_attr.x_size = 60;
    sprintf (t_str, "%d", gadget_attr.x_size);
    FIfld_set_text (Palette_form, WIDTH_FLD, 0, 0, t_str, 0);

    gadget_attr.y_size = 50;
    sprintf (t_str, "%d", gadget_attr.y_size);
    FIfld_set_text (Palette_form, HEIGHT_FLD, 0, 0, t_str, 0);

    break;

  case LG_BTN:

    FIg_set_state_off (Palette_form, SM_BTN);
    FIg_set_state_off (Palette_form, MED_BTN);
    FIg_set_state_on (Palette_form, LG_BTN);
    FIg_set_state_off (Palette_form, SPECIFY_BTN);

    gadget_attr.x_size = 90;
    sprintf (t_str, "%d", gadget_attr.x_size);
    FIfld_set_text (Palette_form, WIDTH_FLD, 0, 0, t_str, 0);

    gadget_attr.y_size = 60;
    sprintf (t_str, "%d", gadget_attr.y_size);
    FIfld_set_text (Palette_form, HEIGHT_FLD, 0, 0, t_str, 0);

    break;

  case SPECIFY_BTN:

    FIg_set_state_off (Palette_form, SM_BTN);
    FIg_set_state_off (Palette_form, MED_BTN);
    FIg_set_state_off (Palette_form, LG_BTN);
    FIg_set_state_on (Palette_form, SPECIFY_BTN);

    break;

  case ROWS_FLD:

    FIfld_get_text (Palette_form, ROWS_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Palette_form, ERR_FLD, &status);

    if (status)
      if (i > 0) /* Valid input */
      {
        gadget_attr.num_rows = i;
      }
      else
      {
        UMSGetByNum (t_str, FB_E_ROWGTZERO, 0);
        print_error (Palette_form, ERR_FLD, t_str);
      }
    break;

  case COLUMNS_FLD:

    FIfld_get_text (Palette_form, COLUMNS_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Palette_form, ERR_FLD, &status);

    if (status)
      if (i > 0) /* Valid input */
      {
        gadget_attr.num_cols = i;
      }
      else
      {
        UMSGetByNum (t_str, FB_E_COLGTZERO, 0);
        print_error (Palette_form, ERR_FLD, t_str);
      }
    break;

  case HEIGHT_FLD:

    FIfld_get_text (Palette_form, HEIGHT_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Palette_form, ERR_FLD, &status);

    if (status)
      if (i > 0) /* Valid input */
      {
        FIg_set_state_off (Palette_form, SM_BTN);
        FIg_set_state_off (Palette_form, MED_BTN);
        FIg_set_state_off (Palette_form, LG_BTN);
        FIg_set_state_on (Palette_form, SPECIFY_BTN);

        gadget_attr.y_size = i;
      }
      else
      {
        UMSGetByNum (t_str, FB_E_HTGTZERO, 0);
        print_error (Palette_form, ERR_FLD, t_str);
      }
    break;

  case WIDTH_FLD:

    FIfld_get_text (Palette_form, WIDTH_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Palette_form, ERR_FLD, &status);

    if (status)
      if (i > 0) /* Valid input */
      {
        FIg_set_state_off (Palette_form, SM_BTN);
        FIg_set_state_off (Palette_form, MED_BTN);
        FIg_set_state_off (Palette_form, LG_BTN);
        FIg_set_state_on (Palette_form, SPECIFY_BTN);

        gadget_attr.x_size = i;
      }
      else
      {
        UMSGetByNum (t_str, FB_E_WDGTZERO, 0);
        print_error (Palette_form, ERR_FLD, t_str);
      }
    break;

  case SPECIFY_TOG:

    if ((int)value == 1)
    {
      FIg_display (Palette_form, X_TEXT);
      FIg_display (Palette_form, Y_TEXT);
      FIg_display (Palette_form, X_FLD);
      FIg_display (Palette_form, Y_FLD);
      gadget_attr.poke_flag = 0;

      sprintf (t_str, "%d", gadget_attr.x_pos);
      FIfld_set_text (Palette_form, X_FLD, 0, 0, t_str, 0);

      sprintf (t_str, "%d", gadget_attr.y_pos);
      FIfld_set_text (Palette_form, Y_FLD, 0, 0, t_str, 0);
    }
    else
    {
      FIg_erase (Palette_form, X_TEXT);
      FIg_erase (Palette_form, Y_TEXT);
      FIg_erase (Palette_form, X_FLD);
      FIg_erase (Palette_form, Y_FLD);
      gadget_attr.poke_flag = 1;
    }
    break;

  case X_FLD:

    FIfld_get_text (Palette_form, X_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Palette_form, ERR_FLD, &status);

    if (status) /* Valid input */
      if (i >= 0)
        gadget_attr.x_pos = i;
      else
      {
        UMSGetByNum (t_str, FB_E_XNOTNEG, 0);
        print_error (Palette_form, ERR_FLD, t_str);
      }
    break;

  case Y_FLD:

    FIfld_get_text (Palette_form, Y_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Palette_form, ERR_FLD, &status);

    if (status) /* Valid input */
      if (i >= 0)
        gadget_attr.y_pos = i;
      else
      {
        UMSGetByNum (t_str, FB_E_YNOTNEG, 0);
        print_error (Palette_form, ERR_FLD, t_str);
      }
    break;

  case FI_HELP:

    /* Help_topic ("Button palette") */
    break;

  case FI_CANCEL:

    kill_place_palette();
    FIg_set_state_off (Palette_form, FI_CANCEL);
    break;

  case FI_ACCEPT:

    status = FIf_erase (Palette_form);

    create_button_palette();

    FIg_set_state_off (Palette_form, FI_ACCEPT);

    FIf_display (Palette_form);

    UMSGetByNum (t_str, FB_I_FILLPAL, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
    break;
  }

  return;
}

/*************************************************************************/
/* */
/* execute_place_palette() */
/* */
/* This function is called by the executive command handler routine. */
/* */
/* It displays the Palette form then exits. After that point */
/* the fi_palette_form() gadget notification routine will be in */
/* control. That is to say, every time the operator alters a gadget on */
/* the Palette form, the fi_palette_form() function will be invoked. */
/* */
/*************************************************************************/

void execute_place_palette(void)
{
  char t_str[256];
  int status;
  extern void Report_fatal_form_error();

  if (work_form == NULL) /* No form defined */
  {
    strcpy (current_command_string, "None");
    command_is_active = 0;
    return;
  }

  UMSGetByNum (t_str, FB_I_PLAPAL, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENDEF, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Palette_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlBtPal");
    status = FIf_new (937, t_str, (int (*)())fi_palette_form, &Palette_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  setup_new_palette_form();
  show_palette_form_info();

  FIg_erase (Palette_form, 10); /* Error field */
  FIg_set_state_off (Palette_form, SELECT_TOG);
  FIg_set_state_off (Palette_form, SPECIFY_TOG);

  FIg_set_state_on (Palette_form, SM_BTN);
  FIg_set_state_off (Palette_form, LG_BTN);
  FIg_set_state_off (Palette_form, MED_BTN);
  FIg_set_state_off (Palette_form, SPECIFY_BTN);

  FIg_display (Palette_form, HEIGHT_TEXT);
  FIg_display (Palette_form, WIDTH_TEXT);
  FIg_display (Palette_form, HEIGHT_FLD);
  FIg_display (Palette_form, WIDTH_FLD);

  FIg_erase (Palette_form, X_TEXT);
  FIg_erase (Palette_form, Y_TEXT);
  FIg_erase (Palette_form, X_FLD);
  FIg_erase (Palette_form, Y_FLD);

  FIf_display (Palette_form);

  UMSGetByNum (t_str, FB_I_FILLPAL, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}
