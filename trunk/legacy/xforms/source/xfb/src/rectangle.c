/***********************************

		rectangle.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
	05-07-92	sml		casted func arg for ANSI
*/

/*************************************/
/* */
/* This file contains functions for the "place rectangle" and */
/* "edit rectangle" commands. */
/* */
/* Programmer: Mack Draper */
/* Date: Jan. 23, 1989 */
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
#include "XFIproto_pri.h"
#include "XFBproto_pri.h"


#define LABEL_FLD 41 /* needed by characteristics form */

/****************************/
/* */
/* used by rectangle form */
/* */
/****************************/

#define SPECIFY_TOG 12

#define X_TEXT 18
#define Y_TEXT 19
#define WIDTH_TEXT 21
#define HEIGHT_TEXT 20

#define X_FLD 13
#define Y_FLD 14
#define WIDTH_FLD 15
#define HEIGHT_FLD 16

#define FILLED_TOG 23

#define ERR_FLD 10

#define CHAR_FOREGROUND_CLR_BTN 47
#define CHAR_FOREGROUND2_CLR_BTN 48
#define CHAR_LINE_STYLE_BTN 27
#define CHAR_LINE_WEIGHT_BTN 26
#define CHAR_LINE_DEPTH_TOG 25

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

Form Rectangle_form = NULL;
static int Filled_flag;

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
extern Form Line_weight_form;
extern Form Line_style_form;
extern Form Message_form;
extern int edit_hilite_flag;
extern int edit_display_flag;
extern int old_gadget_label;

extern char language[80];
extern Display *display;

/*************************************************************************/
/* */
/* kill_place_rectangle() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to PLACE_RECTANGLE indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecteing the point. */
/* */
/*************************************************************************/

void kill_place_rectangle(void)
{
  char t_str[256];

  if (Rectangle_form != NULL)
    FIf_erase (Rectangle_form);

  if (Characteristics_form != NULL)
    Clear_characteristics_form();

  FIfld_set_text (Message_form, 11, 0, 0, "", 0);
  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  if (command_is_active == PLACE_RECTANGLE)
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

/*********************************************************************/
/* */
/* setup_old_rectangle_form() */
/* */
/*********************************************************************/

static void setup_old_rectangle_form(void)
{
  setup_standard_attr (old_gadget_label);

  /******************************************************/
  /* */
  /* Now specify items unique to the rectangle gadget */
  /* */
  /******************************************************/

  FIg_get_line_style (work_form, old_gadget_label, &gadget_attr.line_style);

  FIg_get_line_depth (work_form, old_gadget_label, &gadget_attr.line_depth);
  if (gadget_attr.line_depth == 2)
    Filled_flag = 1;
  else
    Filled_flag = 0;

  FIg_get_line_weight (work_form, old_gadget_label, &gadget_attr.line_weight);

  gadget_attr.draw_flag = 0;
  gadget_attr.gadget_type = FI_RECT;
}

/*************************************************************************/
/* */
/* setup_new_rectangle_form() */
/* */
/* This function is called each time the operator wishes to place a */
/* new rectangle on the work form. It will fill in default settings for */
/* the rectangle. These will be displayed in the rectangle definition */
/* form when the show_rectangle_info() function is called. */
/* */
/*************************************************************************/

static void setup_new_rectangle_form(void)
{
  Set_new_gadget_defaults();

  gadget_attr.selectable = 0;
  gadget_attr.complete_notify = 0;
  Filled_flag = 0;

  gadget_attr.draw_flag = 1;
  gadget_attr.x_pos = 0;
  gadget_attr.gadget_type = FI_RECT;
}

/*************************************************************************/
/* */
/* show_rectangle_form_info() */
/* */
/* This function displays the information contained in the */
/* current_gadget struct into the rectangle form's gadgets. */
/* */
/*************************************************************************/

static void show_rectangle_form_info(void)
{
  char t_str[256];
  int x;

  FIg_erase (Rectangle_form, 10);

  if (gadget_attr.x_pos != 0)
  {
    sprintf (t_str, "%d", gadget_attr.x_pos);
    FIfld_set_text (Rectangle_form, X_FLD, 0, 0, t_str, 0);

    sprintf (t_str, "%d", gadget_attr.y_pos);
    FIfld_set_text (Rectangle_form, Y_FLD, 0, 0, t_str, 0);

    sprintf (t_str, "%d", gadget_attr.x_size);
    FIfld_set_text (Rectangle_form, WIDTH_FLD, 0, 0, t_str, 0);

    sprintf (t_str, "%d", gadget_attr.y_size);
    FIfld_set_text (Rectangle_form, HEIGHT_FLD, 0, 0, t_str, 0);
    for (x = 13; x < 22; x++)
      FIg_display (Rectangle_form, x);
  }
  else
  {
    FIfld_set_text (Rectangle_form, X_FLD, 0, 0, "", 0);
    FIfld_set_text (Rectangle_form, Y_FLD, 0, 0, "", 0);
    FIfld_set_text (Rectangle_form, WIDTH_FLD, 0, 0, "", 0);
    FIfld_set_text (Rectangle_form, HEIGHT_FLD, 0, 0, "", 0);

    for (x = 13; x < 22; x++)
      FIg_erase (Rectangle_form, x);
  }

  if (gadget_attr.draw_flag == 1)
    FIg_set_state_off (Rectangle_form, SPECIFY_TOG);
  else
    FIg_set_state_on (Rectangle_form, SPECIFY_TOG);

  if (gadget_attr.line_depth != 2)
    FIg_set_state_off (Rectangle_form, FILLED_TOG);
  else
    FIg_set_state_on (Rectangle_form, FILLED_TOG);
}

/*-------------------------------------------------------------------------*/

/*********************************************************************/
/* */
/* create_rectangle_gadget() */
/* */
/* This function creates a new rectangle gadget and places it at */
/* the position that was poked by the operator. */
/* */
/*********************************************************************/

static void create_rectangle_gadget(void)
{
  int x, y;
  Window window;
  char t_str[256];
  int group_label;
  int not_finished;
  int status;


  /************************************************************/
  /* */
  /* If the work form and the place rectangle form intersect, */
  /* then send a window update message to the work_form */
  /* */
  /************************************************************/

  Refresh_work_form();

  FIf_get_window (work_form, &window);

  if (gadget_attr.draw_flag == 0)
  {
    if (command_is_active == EDIT_GADGET)
    {
      FIg_get_group_label (work_form, old_gadget_label, &group_label);
      FIg_erase (work_form, old_gadget_label);
      FIg_delete (work_form, old_gadget_label);
      old_gadget_label = -1;
    }
    else
      group_label = 0;

    x = gadget_attr.x_size;
    y = gadget_attr.y_size;

    gadget_attr.x_size = gadget_attr.x_pos + gadget_attr.x_size;
    gadget_attr.y_size = gadget_attr.y_pos + gadget_attr.y_size;

    Create_and_init_gadget (work_form, FI_RECT, gadget_attr.gadget_label);

    if (group_label != 0)
      FIg_add_to_group (work_form, gadget_attr.gadget_label, group_label);

    if (Filled_flag)
      gadget_attr.line_depth = 2;
    else
      if (gadget_attr.line_depth == 2)
        gadget_attr.line_depth = 0;

    FIg_set_line_depth (work_form, gadget_attr.gadget_label,
        gadget_attr.line_depth);
    FIg_set_line_weight (work_form, gadget_attr.gadget_label,
        gadget_attr.line_weight);
    FIg_set_line_style (work_form, gadget_attr.gadget_label,
        gadget_attr.line_style);

    FIg_activate (work_form, gadget_attr.gadget_label);

    if (gadget_attr.display == 1)
      FIg_display (work_form, gadget_attr.gadget_label);

    _FI_bez_pop_to_bottom ((struct FIform_obj *)work_form, gadget_attr.gadget_label);
    /*
FIf_calculate_size (work_form);
*/
    gadget_attr.x_size = x;
    gadget_attr.y_size = y;
  }
  else /* Get two datapoints for size and location of rectangle */
  {
    not_finished = 1;

    while (not_finished)
    {
      UMSGetByNum (t_str, FB_P_POKRCTANC, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

      status = Get_first_point (window, &x, &y, 0, 0, 0, 0);

      if (status == 2) /* Success */
      {
        UMSGetByNum (t_str, FB_I_ANCX, "%d%d", x, y);
        FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);
        UMSGetByNum (t_str, FB_P_POKRCTSWG, 0);
        FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

        status = Get_second_point (window, x, y,
            &gadget_attr.x_pos,
            &gadget_attr.y_pos,
            &gadget_attr.x_size,
            &gadget_attr.y_size,
            gadget_attr.line_weight,
            gadget_attr.line_style);

        FIfld_set_text (Message_form, 22, 0, 0, "", 0);

        if (status == 2) /* Success */
        {
          if (command_is_active == EDIT_GADGET)
          {
            FIg_get_group_label (work_form, old_gadget_label,
                &group_label);
            FIg_erase (work_form, old_gadget_label);
            FIg_delete (work_form, old_gadget_label);
            old_gadget_label = -1;
          }
          else
            group_label = 0;

          Create_and_init_gadget (work_form, FI_RECT,
              gadget_attr.gadget_label);

          if (group_label != 0)
          {
            FIg_add_to_group (work_form,
                gadget_attr.gadget_label,
                group_label);
          }

          if (Filled_flag)
            gadget_attr.line_depth = 2;

          FIg_set_line_depth (work_form, gadget_attr.gadget_label,
              gadget_attr.line_depth);
          FIg_set_line_weight (work_form, gadget_attr.gadget_label,
              gadget_attr.line_weight);
          FIg_set_line_style (work_form, gadget_attr.gadget_label,
              gadget_attr.line_style);

          FIg_activate (work_form, gadget_attr.gadget_label);

          if (gadget_attr.display == 1)
            FIg_display (work_form, gadget_attr.gadget_label);

          _FI_bez_pop_to_bottom ((struct FIform_obj *)work_form, gadget_attr.gadget_label);
          /*
FIf_calculate_size ((struct FIform_obj *)work_form);
*/
          FIf_get_next_label (work_form, &gadget_attr.gadget_label);

          if (Characteristics_form != NULL)
          {
            sprintf (t_str, "%d", gadget_attr.gadget_label);
            FIfld_set_text (Characteristics_form, LABEL_FLD,
                0, 0, t_str, 0);
          }
          not_finished = 0;
        }
        else /* Operator wants to re-place anchor point */
        {
          /* Do nothing and loop back around */
        }
      }
      else /* Operator wants to exit draw mode */
      {
        return;
      }
    }
  }
}

/*--------------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* fi_rectangle_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the default */
/* settings for a new rectangle gadget, or alter the settings of an */
/* existing rectangle gadget. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_rectangle_form (int form_label,
                       int gadget_label,
                       double value,
                       Form form_ptr)
{
  int i, x;
  int status;
  char t_str[256];
  int dummy_int;


  FIg_erase (Rectangle_form, ERR_FLD);

  switch (gadget_label)
  {
  case FILLED_TOG:

    if ((int)value == 0)
    {
      if (Characteristics_form == NULL)
        gadget_attr.line_depth = FI_2D_LINE;
      else
      {
        FIg_get_state (Characteristics_form, CHAR_LINE_DEPTH_TOG, &i);
        gadget_attr.line_depth = i;
      }
      Filled_flag = 0;
    }
    else
    {
      gadget_attr.line_depth = FI_FILLED;
      Filled_flag = 1;
    }
    break;

  case SPECIFY_TOG:

    if ((int)value == 0)
    {
      gadget_attr.draw_flag = 1;

      for (x = 13; x < 23; x++)
        FIg_erase (Rectangle_form, x);
    }
    else
    {
      gadget_attr.draw_flag = 0;

      for (x = 13; x < 23; x++)
        if (x != 17)
          FIg_display (Rectangle_form, x);
    }
    break;

  case HEIGHT_FLD:
  case WIDTH_FLD:
  case X_FLD:
  case Y_FLD:

    FIfld_get_text (Rectangle_form, gadget_label, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Rectangle_form,
        ERR_FLD, &status);
    if (status)
      if (i > 0) /* Valid input */
      {
        if (gadget_label == HEIGHT_FLD)
        {
          gadget_attr.y_size = i;
        }
        else if (gadget_label == WIDTH_FLD)
        {
          gadget_attr.x_size = i;
        }
        else if (gadget_label == X_FLD)
        {
          gadget_attr.x_pos = i;
        }
        else if (gadget_label == Y_FLD)
        {
          gadget_attr.y_pos = i;
        }
      }
      else
      {
        UMSGetByNum (t_str, FB_E_MUSTGTZERO, 0);
        print_error (Rectangle_form, ERR_FLD, t_str);
      }
    break;

  case FI_HELP:

    /* Help_topic ("Rectangle") */
    break;

  case FI_CANCEL:

    if (command_is_active == EDIT_GADGET)
    {
      if (edit_hilite_flag == 0)
        FIg_unhilite (work_form, old_gadget_label);

      if (edit_display_flag == 0)
        FIg_erase (work_form, old_gadget_label);
    }

    kill_place_rectangle();
    FIg_set_state_off (Rectangle_form, FI_CANCEL);
    break;

  case FI_ACCEPT:

    FIf_erase (Rectangle_form);
    FIg_set_state_off (Rectangle_form, FI_ACCEPT);

    if (Characteristics_form != NULL)
    {
      FIf_erase (FG_color_form);
      FIf_erase (FG2_color_form);
      FIf_erase (Line_weight_form);
      FIf_erase (Line_style_form);

      FIg_set_state_off (Characteristics_form, CHAR_FOREGROUND_CLR_BTN);
      FIg_set_state_off (Characteristics_form, CHAR_FOREGROUND2_CLR_BTN);
      FIg_set_state_off (Characteristics_form, CHAR_LINE_WEIGHT_BTN);
      FIg_set_state_off (Characteristics_form, CHAR_LINE_STYLE_BTN);

      replace_attr_with_overrides(); /* character.c */
    }

    create_rectangle_gadget();

    if (command_is_active == EDIT_GADGET)
      kill_place_rectangle();
    else if (Rectangle_form != NULL) /* Do this command again */
    {
      FIg_set_state_off (Rectangle_form, FI_ACCEPT);

      FIf_display (Rectangle_form);

      FIf_get_next_label (work_form, &gadget_attr.gadget_label);

      if (Characteristics_form != NULL)
      {
        override_attr.gadget_label = gadget_attr.gadget_label;
        sprintf (t_str, "%d", override_attr.gadget_label);
        FIfld_set_text (Characteristics_form, LABEL_FLD,
            0, 0, t_str, 0);
        FIg_erase (Characteristics_form, 10);
      }

      UMSGetByNum (t_str, FB_P_FILLRCT, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
    }
    break;
  }

  return;
}

/*************************************************************************/
/* */
/* execute_place_rectangle() */
/* */
/* This function is called by the executive command handler routine. */
/* */
/* It displays the Rectangle form then exits. After that point */
/* the fi_rectangle_form() gadget notification routine will be in */
/* control. That is to say, every time the operator alters a gadget on */
/* the Rectangle form, the fi_rectangle_form() function will be */
/* invoked. */
/* */
/*************************************************************************/

void execute_place_rectangle(void)
{
  char t_str[256];
  int status;

  if (work_form == NULL) /* No form defined */
  {
    strcpy (current_command_string, "None");
    command_is_active = 0;
    return;
  }

  UMSGetByNum (t_str, FB_I_PCERCT, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENDEF, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Rectangle_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlRct");
    status = FIf_new (444, t_str, (int (*)())fi_rectangle_form, &Rectangle_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  setup_new_rectangle_form();
  show_rectangle_form_info();

  FIf_display (Rectangle_form);

  FIf_get_next_label (work_form, &gadget_attr.gadget_label);

  if (Characteristics_form != NULL)
    Update_characteristics_form();

  UMSGetByNum (t_str, FB_P_FILLRCT, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}

/************************************************************************/
/* */
/* edit_rectangle_gadget() */
/* */
/************************************************************************/

void edit_rectangle_gadget(void)
{
  char t_str[256];
  int status;

  gadget_attr.gadget_label = old_gadget_label;

  UMSGetByNum (t_str, FB_I_EDTRCT, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENCUR, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Rectangle_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlRct");
    status = FIf_new (444, t_str, (int (*)())fi_rectangle_form, &Rectangle_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  setup_old_rectangle_form();
  show_rectangle_form_info();

  FIf_display (Rectangle_form);

  if (Characteristics_form != NULL)
    Update_characteristics_form();

  UMSGetByNum (t_str, FB_P_FILLRCT, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}
