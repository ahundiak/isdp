/***********************************

		bezel_gdt.c

***********************************/

/*
  History
	04-28-92	sml		ANSI-ized; casted func args
*/

/*************************************/
/* */
/* This file contains functions for the "place bezel" and "edit bezel" */
/* commands. */
/* */
/* Programmer: Mack Draper */
/* Date: Feb. 2, 1989 */
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

/************************/
/* */
/* used by bezel form */
/* */
/************************/

#define SPECIFY_TOG 12

#define X_TEXT 18
#define Y_TEXT 19
#define WIDTH_TEXT 21
#define HEIGHT_TEXT 20

#define X_FLD 13
#define Y_FLD 14
#define WIDTH_FLD 15
#define HEIGHT_FLD 16

#define STATE_TOG 50

#define ERR_FLD 10

#define CHAR_FOREGROUND_CLR_BTN 47

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

Form Bezel_form = NULL;

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern Form work_form;
extern struct dpb_struct dpb;
extern int command_is_active;
extern char current_command_string[80];
extern struct gadget_struct gadget_attr;
extern struct gadget_struct override_attr;
extern char execute_dir[200];

extern Form Characteristics_form;
extern Form FG_color_form;
extern Form Message_form;
extern int edit_hilite_flag;
extern int edit_display_flag;
extern int old_gadget_label;

extern char language[80];
extern Display *display;

/*************************************************************************/
/* */
/* kill_place_bezel() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to PLACE_BEZEL indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_place_bezel(void)
{
  char t_str[256];

  if (Bezel_form != NULL)
  {
    FIf_erase (Bezel_form);
  }

  if (Characteristics_form != NULL)
  {
    Clear_characteristics_form();
  }

  FIfld_set_text (Message_form, 11, 0, 0, "", 0);
  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  if (command_is_active == PLACE_BEZEL)
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

/*************************************************************************/
/* */
/* setup_old_bezel_form() */
/* */
/*************************************************************************/

static void setup_old_bezel_form(void)
{
  setup_standard_attr (old_gadget_label);

  FIg_get_default_value (work_form, old_gadget_label,
      &gadget_attr.default_value);

  gadget_attr.draw_flag = 0;
  gadget_attr.gadget_type = FI_BEZEL;
}

/*************************************************************************/
/* */
/* setup_new_bezel_form() */
/* */
/* This function is called each time the operator wishes to place a */
/* new bezel on the work form. It will fill in default settings for */
/* the bezel. These will be displayed in the bezel definition */
/* form when the show_bezel_info() function is called. */
/* */
/*************************************************************************/

static void setup_new_bezel_form(void)
{
  Set_new_gadget_defaults();

  gadget_attr.selectable = 0;
  gadget_attr.complete_notify = 0;

  gadget_attr.off_color = dpb.bgcolor;
  gadget_attr.draw_flag = 1;
  gadget_attr.x_pos = 0;
  gadget_attr.default_value = 0;
  gadget_attr.gadget_type = FI_BEZEL;
}

/*************************************************************************/
/* */
/* show_bezel_form_info() */
/* */
/* This function displays the information contained in the */
/* current_gadget struct into the bezel form's gadgets. */
/* */
/*************************************************************************/

static void show_bezel_form_info(void)
{
  char t_str[256];
  int x;
  int status;

  FIg_erase (Bezel_form, 10);

  if (gadget_attr.x_pos != 0)
  {
    sprintf (t_str, "%d", gadget_attr.x_pos);
    status = FIfld_set_text (Bezel_form, X_FLD, 0, 0, t_str, 0);

    sprintf (t_str, "%d", gadget_attr.y_pos);
    status = FIfld_set_text (Bezel_form, Y_FLD, 0, 0, t_str, 0);

    sprintf (t_str, "%d", gadget_attr.x_size);
    status = FIfld_set_text (Bezel_form, WIDTH_FLD, 0, 0, t_str, 0);

    sprintf (t_str, "%d", gadget_attr.y_size);
    status = FIfld_set_text (Bezel_form, HEIGHT_FLD, 0, 0, t_str, 0);

    FIg_display (Bezel_form, X_FLD);
    FIg_display (Bezel_form, Y_FLD);
    FIg_display (Bezel_form, WIDTH_FLD);
    FIg_display (Bezel_form, HEIGHT_FLD);
    FIg_display (Bezel_form, X_TEXT);
    FIg_display (Bezel_form, Y_TEXT);
    FIg_display (Bezel_form, WIDTH_TEXT);
    FIg_display (Bezel_form, HEIGHT_TEXT);
  }
  else
  {
    FIfld_set_text (Bezel_form, X_FLD, 0, 0, "", 0);
    FIfld_set_text (Bezel_form, Y_FLD, 0, 0, "", 0);
    FIfld_set_text (Bezel_form, WIDTH_FLD, 0, 0, "", 0);
    FIfld_set_text (Bezel_form, HEIGHT_FLD, 0, 0, "", 0);
    FIg_erase (Bezel_form, X_FLD);
    FIg_erase (Bezel_form, Y_FLD);
    FIg_erase (Bezel_form, WIDTH_FLD);
    FIg_erase (Bezel_form, HEIGHT_FLD);
    FIg_erase (Bezel_form, X_TEXT);
    FIg_erase (Bezel_form, Y_TEXT);
    FIg_erase (Bezel_form, WIDTH_TEXT);
    FIg_erase (Bezel_form, HEIGHT_TEXT);
  }

  if ((int)gadget_attr.default_value == 0)
    FIg_set_state_off (Bezel_form, STATE_TOG);
  else
    FIg_set_state_on (Bezel_form, STATE_TOG);

  if (gadget_attr.draw_flag == 1)
    for (x = 13; x < 22; x++)
      FIg_erase (Bezel_form, x);

  if (gadget_attr.draw_flag == 1)
    FIg_set_state_off (Bezel_form, SPECIFY_TOG);
  else
    FIg_set_state_on (Bezel_form, SPECIFY_TOG);
}

/*-------------------------------------------------------------------------*/

/*********************************************************************/
/* */
/* create_bezel_gadget() */
/* */
/* This function creates a new bezel gadget and places it at */
/* the position that was poked by the operator. */
/* */
/*********************************************************************/

static void create_bezel_gadget(void)
{
  int x, y;
  Window window;
  char t_str[256];
  int not_finished;
  int group_label;
  int xsize, ysize;
  int status;
  
  /************************************************************/
  /* */
  /* If the work form and the place bezel form intersect, */
  /* then send a window update message to the work_form */
  /* */
  /************************************************************/

  Refresh_work_form();

  FIf_get_window (work_form, &window);
  FIf_get_size (work_form, &xsize, &ysize);

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
    {
      group_label = 0;
    }

    x = gadget_attr.x_size;
    y = gadget_attr.y_size;

    gadget_attr.x_size = gadget_attr.x_pos + gadget_attr.x_size;
    gadget_attr.y_size = gadget_attr.y_pos + gadget_attr.y_size;

    Create_and_init_gadget (work_form, FI_BEZEL, gadget_attr.gadget_label);

    if (group_label != 0)
    {
      FIg_add_to_group (work_form, gadget_attr.gadget_label, group_label);
    }

    FIg_activate (work_form, gadget_attr.gadget_label);

    if (gadget_attr.display == 1)
    {
      status = FIg_display (work_form, gadget_attr.gadget_label);
    }

    _FI_bez_pop_to_bottom ((struct FIform_obj *)work_form, gadget_attr.gadget_label);

    FIf_paint_area (work_form, 0, 0, xsize, ysize);

    gadget_attr.x_size = x;
    gadget_attr.y_size = y;
  }
  else /* Get two datapoints for size and location of bezel */
  {
    not_finished = 1;

    while (not_finished)
    {
      UMSGetByNum (t_str, FB_P_POKBEZANC, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

      status = Get_first_point (window, &x, &y, 0, 0, 0, 0);

      if (status == 2) /* Success */
      {
        UMSGetByNum (t_str, FB_I_ANCX, "%d%d", x, y);
        FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);
        UMSGetByNum (t_str, FB_P_POKBEZSWG, 0);
        FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

        status = Get_second_point (window, x, y,
            &gadget_attr.x_pos,
            &gadget_attr.y_pos,
            &gadget_attr.x_size,
            &gadget_attr.y_size, 0, -1);

        FIfld_set_text (Message_form, 22, 0, 0, "", 0);

        if (status == 2) /* Success */
        {
          if (command_is_active == EDIT_GADGET)
          {
            FIg_erase (work_form, old_gadget_label);
            FIg_delete (work_form, old_gadget_label);
            old_gadget_label = -1;
          }

          Create_and_init_gadget (work_form, FI_BEZEL,
              gadget_attr.gadget_label);

          /* Mack - do we need to add to group here? */

          FIg_activate (work_form, gadget_attr.gadget_label);

          if (gadget_attr.display == 1)
            status = FIg_display (work_form, gadget_attr.gadget_label );

          _FI_bez_pop_to_bottom ((struct FIform_obj *)work_form, gadget_attr.gadget_label);

          FIf_paint_area (work_form, 0, 0, xsize, ysize);

          FIf_get_next_label (work_form, &gadget_attr.gadget_label);

          if (Characteristics_form != NULL)
          {
            sprintf (t_str, "%d", gadget_attr.gadget_label);

            FIfld_set_text (Characteristics_form, LABEL_FLD,
                0, 0, t_str, 0);
          }

          not_finished = 0;
        }
        else /* replace anchor point */
        {
          /* Do nothing */
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
/* fi_bezel_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the default */
/* settings for a new bezel gadget, or alter the settings of an */
/* existing bezel gadget. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_bezel_form (int form_label,
                   int gadget_label,
                   double value,
                   Form form_ptr)
{
  int i, x;
  int status;
  char t_str[256];
  int dummy_int;

  FIg_erase (Bezel_form, ERR_FLD);

  switch (gadget_label)
  {
  case STATE_TOG:

    gadget_attr.default_value = value;
    break;

  case SPECIFY_TOG:

    if ((int)value == 0)
    {
      gadget_attr.draw_flag = 1;

      for (x = 13; x < 23; x++)
        FIg_erase (Bezel_form, x);
    }
    else
    {
      gadget_attr.draw_flag = 0;

      for (x = 13; x < 23; x++)
        if (x != 17)
          FIg_display (Bezel_form, x);
    }
    break;

  case HEIGHT_FLD:
  case WIDTH_FLD:
  case X_FLD:
  case Y_FLD:

    FIfld_get_text (Bezel_form, gadget_label, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Bezel_form,
        ERR_FLD, &status);
    if (status)
      if (i > 0) /* Valid input */
      {
        if (gadget_label == HEIGHT_FLD)
          gadget_attr.y_size = i;
        if (gadget_label == WIDTH_FLD)
          gadget_attr.x_size = i;
        if (gadget_label == X_FLD)
          gadget_attr.x_pos = i;
        if (gadget_label == Y_FLD)
          gadget_attr.y_pos = i;
      }
      else
      {
        UMSGetByNum (t_str, FB_E_VALGT0, 0);
        print_error (Bezel_form, ERR_FLD, t_str);
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

    kill_place_bezel();
    FIg_set_state_off (Bezel_form, FI_CANCEL);
    break;

  case FI_ACCEPT:

    status = FIf_erase (Bezel_form);

    if (Characteristics_form != NULL)
    {
      FIf_erase (FG_color_form);
      FIg_set_state_off (Characteristics_form, CHAR_FOREGROUND_CLR_BTN);

      replace_attr_with_overrides(); /* character.c */
    }

    create_bezel_gadget();

    FIg_set_state_off (Bezel_form, FI_ACCEPT);

    if (command_is_active == EDIT_GADGET)
      kill_place_bezel();
    else if (Bezel_form != NULL)
    {
      FIf_display (Bezel_form);

      FIf_get_next_label (work_form, &gadget_attr.gadget_label);

      if (Characteristics_form != NULL)
      {
        override_attr.gadget_label = gadget_attr.gadget_label;

        sprintf (t_str, "%d", override_attr.gadget_label);
        FIfld_set_text (Characteristics_form, LABEL_FLD,
            0, 0, t_str, 0);
        FIg_erase (Characteristics_form, 10);
      }

      UMSGetByNum (t_str, FB_P_FILLBEZ, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
    }
    break;
  }
  return;
}

/*************************************************************************/
/* */
/* execute_place_bezel() */
/* */
/* This function is called by the executive command handler routine. */
/* */
/* It displays the Bezel form then exits. After that point */
/* the fi_bezel_form() gadget notification routine will be in */
/* control. That is to say, every time the operator alters a gadget on */
/* the Bezel form, the fi_bezel_form() function will be invoked. */
/* */
/*************************************************************************/

void execute_place_bezel(void)
{
  char t_str[256];
  int status;

  if (work_form == NULL) /* No form defined */
  {
    strcpy (current_command_string, "None");
    command_is_active = 0;
    return;
  }

  UMSGetByNum (t_str, FB_I_PLABEZ, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENDEF, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Bezel_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlBzl");
    status = FIf_new (444, t_str, (int (*)())fi_bezel_form, &Bezel_form);

    if (status != 0)
      Report_fatal_form_error (status, t_str);
  }

  setup_new_bezel_form();
  show_bezel_form_info();

  FIf_display (Bezel_form);

  FIf_get_next_label (work_form, &gadget_attr.gadget_label);

  if (Characteristics_form != NULL)
    Update_characteristics_form();

  UMSGetByNum (t_str, FB_P_FILLBEZ, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}

/*************************************************************************/
/* */
/* edit_bezel_gadget() */
/* */
/*************************************************************************/

void edit_bezel_gadget(void)
{
  char t_str[256];
  int status;

  gadget_attr.gadget_label = old_gadget_label;

  UMSGetByNum (t_str, FB_I_EDBEZ, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENCUR, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Bezel_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlBzl");
    status = FIf_new (444, t_str, (int (*)())fi_bezel_form, &Bezel_form);

    if (status != FI_SUCCESS)
    {
      Report_fatal_form_error (status, t_str);
    }
  }

  setup_old_bezel_form();
  show_bezel_form_info();

  FIf_display (Bezel_form);

  if (Characteristics_form != NULL)
  {
    Update_characteristics_form();
  }

  UMSGetByNum (t_str, FB_P_FILLBEZ, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}
