/***********************************

		line_gdt.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
	05-07-92	sml		casted func arg for ANSI
*/

/*************************************/
/* */
/* This file contains functions for the "place line" and "edit line" */
/* commands. */
/* */
/* Programmer: Mack Draper */
/* Date: Jan. 24, 1989 */
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


#define LABEL_FLD 41 /* needed by Characteristics form */

/***********************/
/* */
/* used by line form */
/* */
/***********************/

#define SPECIFY_TOG 12

#define X1_TEXT 18
#define Y1_TEXT 19
#define X2_TEXT 21
#define Y2_TEXT 20

#define X1_FLD 13
#define Y1_FLD 14
#define X2_FLD 15
#define Y2_FLD 16

#define ERR_FLD 10

#define CHAR_FOREGROUND_CLR_BTN 47
#define CHAR_LINE_STYLE_BTN 27
#define CHAR_LINE_WEIGHT_BTN 26

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

Form Line_form = NULL;

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
extern struct standard_st default_attr;
extern char execute_dir[200];
extern Form Characteristics_form;
extern Form FG_color_form;
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
/* kill_place_line() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to PLACE_LINE indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecteing the point. */
/* */
/*************************************************************************/

void kill_place_line(void)
{
  char t_str[256];

  if (Line_form != NULL)
    FIf_erase (Line_form);

  if (Characteristics_form != NULL)
    Clear_characteristics_form();

  FIfld_set_text (Message_form, 11, 0, 0, "", 0);
  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  if (command_is_active == PLACE_LINE)
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
/* setup_old_line_form */
/* */
/*************************************************************************/

static void setup_old_line_form (void)
{
  setup_standard_attr (old_gadget_label);

  gadget_attr.x_size = gadget_attr.x_pos + gadget_attr.x_size;
  gadget_attr.y_size = gadget_attr.y_pos + gadget_attr.y_size;

  /************************************************/
  /* */
  /* Now specify items unique to the line gadget */
  /* */
  /************************************************/

  FIg_get_line_style (work_form, old_gadget_label, &gadget_attr.line_style);

  FIg_get_line_depth (work_form, old_gadget_label, &gadget_attr.line_depth);

  FIg_get_line_weight (work_form, old_gadget_label, &gadget_attr.line_weight);

  gadget_attr.draw_flag = 0;

  gadget_attr.gadget_type = FI_LINE;
}

/*************************************************************************/
/* */
/* setup_new_line_form() */
/* */
/* This function is called each time the operator wishes to place a */
/* new line on the work form. It will fill in default settings for */
/* the line. These will be displayed in the line definition */
/* form when the show_line_info() function is called. */
/* */
/*************************************************************************/

static void setup_new_line_form(void)
{
  Set_new_gadget_defaults();

  gadget_attr.selectable = 0;
  gadget_attr.complete_notify = 0;

  gadget_attr.gadget_type = FI_LINE;
  gadget_attr.draw_flag = 1;
  gadget_attr.x_pos = -1;   /* GMD 2/5/92 */
}

/*************************************************************************/
/* */
/* show_line_form_info() */
/* */
/* This function displays the information contained in the */
/* current_gadget struct into the line form's gadgets. */
/* */
/*************************************************************************/

static void show_line_form_info(void)
{
  char t_str[256];
  int x;

  FIg_erase (Line_form, 10);

  if (gadget_attr.x_pos != -1)  /* GMD 2/5/92 */
   {
    FIg_set_state_on (Line_form, SPECIFY_TOG);
    sprintf (t_str, "%d", gadget_attr.x_pos);
    FIfld_set_text (Line_form, X1_FLD, 0, 0, t_str, 0);

    sprintf (t_str, "%d", gadget_attr.y_pos);
    FIfld_set_text (Line_form, Y1_FLD, 0, 0, t_str, 0);

    sprintf (t_str, "%d", gadget_attr.x_size);
    FIfld_set_text (Line_form, X2_FLD, 0, 0, t_str, 0);

    sprintf (t_str, "%d", gadget_attr.y_size);
    FIfld_set_text (Line_form, Y2_FLD, 0, 0, t_str, 0);

    for (x = 13; x < 24; x++)
      FIg_display (Line_form, x);
  }
  else
  {
    FIg_set_state_off (Line_form, SPECIFY_TOG);

    FIfld_set_text (Line_form, X1_FLD, 0, 0, "", 0);
    FIfld_set_text (Line_form, Y1_FLD, 0, 0, "", 0);
    FIfld_set_text (Line_form, X2_FLD, 0, 0, "", 0);
    FIfld_set_text (Line_form, Y2_FLD, 0, 0, "", 0);

    for (x = 13; x < 24; x++)
      FIg_erase (Line_form, x);
  }

}

/*-------------------------------------------------------------------------*/

/*********************************************************************/
/* */
/* create_line_gadget() */
/* */
/* This function creates a new line gadget and places it at */
/* the position that was poked by the operator. */
/* */
/*********************************************************************/

static void create_line_gadget(void)
{
  int status;
  char t_str[256];
  int not_finished;
  int top_loop;
  int group_label;
  int next_x, next_y;
  int temp_x, temp_y;

  Window window;

  /************************************************************/
  /* */
  /* If the work form and the place line form intersect, */
  /* then send a window update message to the work_form */
  /* */
  /************************************************************/

  Refresh_work_form();

  FIf_get_window (work_form, &window);

  if (gadget_attr.draw_flag == 0) /* Operator used keyin */
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

    Create_and_init_gadget (work_form, FI_LINE, gadget_attr.gadget_label);

    if (group_label != 0)
      FIg_add_to_group (work_form, gadget_attr.gadget_label, group_label);

    FIg_set_line_depth (work_form, gadget_attr.gadget_label,
        gadget_attr.line_depth);

    /* GMD 2/4/92    Set line weight regardless of line style */

    FIg_set_line_weight (work_form, gadget_attr.gadget_label,
        gadget_attr.line_weight);    

    FIg_set_line_style (work_form, gadget_attr.gadget_label,
        gadget_attr.line_style);

    FIg_activate (work_form, gadget_attr.gadget_label);

    if (gadget_attr.display == 1)
      FIg_display (work_form, gadget_attr.gadget_label);

    /*
FIf_calculate_size (work_form);
*/
    /*******************************/
    /* */
    /* Get set to place next line */
    /* */
    /*******************************/

    gadget_attr.x_pos = gadget_attr.x_size;
    gadget_attr.y_pos = gadget_attr.y_size;

    sprintf (t_str, "%d", gadget_attr.x_pos);
    FIfld_set_text (Line_form, X1_FLD, 0, 0, t_str, 0);
    sprintf (t_str, "%d", gadget_attr.y_pos);
    FIfld_set_text (Line_form, Y1_FLD, 0, 0, t_str, 0);
    strcpy (t_str, "");
    FIfld_set_text (Line_form, X2_FLD, 0, 0, t_str, 0);
    FIfld_set_text (Line_form, Y2_FLD, 0, 0, t_str, 0);
  }
  else /* Get two datapoints for size and location of line */
  {
    top_loop = 1;
    while (top_loop)
    {
      UMSGetByNum (t_str, FB_P_POKLINANC, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

      status = Get_first_point (window, &gadget_attr.x_pos,
          &gadget_attr.y_pos, 0, 0, 0, 0);

      if (status == 2) /* Success */
      {
        UMSGetByNum (t_str, FB_P_POKLINEND, 0);
        FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

        not_finished = 1;

        while (not_finished)
        {
          UMSGetByNum (t_str, FB_I_ANCX, "%d%d", gadget_attr.x_pos,
              gadget_attr.y_pos);
          FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);

          status = Get_endpoint (window, gadget_attr.x_pos,
              gadget_attr.y_pos,
              &gadget_attr.x_size,
              &gadget_attr.y_size);

          FIfld_set_text (Message_form, 22, 0, 0, "", 0);

          next_x = gadget_attr.x_size;
          next_y = gadget_attr.y_size;

          if (gadget_attr.x_pos == gadget_attr.x_size)
          {
            if (gadget_attr.y_size < gadget_attr.y_pos)
            {
              temp_y = gadget_attr.y_pos;
              gadget_attr.y_pos = gadget_attr.y_size;
              gadget_attr.y_size = temp_y;
            }
            else
            {
            }
          }
          else
          {
            if (gadget_attr.x_size < gadget_attr.x_pos)
            {
              temp_x = gadget_attr.x_pos;
              gadget_attr.x_pos = gadget_attr.x_size;
              gadget_attr.x_size = temp_x;

              temp_y = gadget_attr.y_pos;
              gadget_attr.y_pos = gadget_attr.y_size;
              gadget_attr.y_size = temp_y;
            }
          }

          if (status == 2) /* Success */
          {
            if (command_is_active == EDIT_GADGET)
            {
              FIg_get_group_label (work_form, old_gadget_label,
                  &group_label);
              FIg_erase (work_form, old_gadget_label);
              FIg_delete (work_form, old_gadget_label);
              old_gadget_label = -1;
              top_loop = 0;
            }
            else
              group_label = 0;

            Create_and_init_gadget (work_form, FI_LINE,
                gadget_attr.gadget_label);

            if (group_label != 0)
              FIg_add_to_group (work_form, gadget_attr.gadget_label,
                  group_label);

            FIg_set_line_depth (work_form, gadget_attr.gadget_label,
                gadget_attr.line_depth);

            /* GMD 2/4/92    Set line weight regardless of line style */

            FIg_set_line_weight (work_form, gadget_attr.gadget_label,
                gadget_attr.line_weight);

            FIg_set_line_style (work_form, gadget_attr.gadget_label,
                gadget_attr.line_style);

            FIg_activate (work_form, gadget_attr.gadget_label);

            if (gadget_attr.display == 1)
              FIg_display (work_form, gadget_attr.gadget_label);

            FIf_calculate_size ((struct FIform_obj *)work_form);

            gadget_attr.x_pos = next_x;
            gadget_attr.y_pos = next_y;

            FIf_get_next_label (work_form, &gadget_attr.gadget_label);

            if (Characteristics_form != NULL)
            {
              sprintf (t_str, "%d", gadget_attr.gadget_label);
              FIfld_set_text (Characteristics_form, LABEL_FLD,
                  0, 0, t_str, 0);
            }
          }
          else /* Operator wants to select a new starting point */
          {
            not_finished = 0;
            FIfld_set_text (Message_form, 44, 0, 0, "", 0);
          }
        }
      }
      else /* Operator wants to quit placing lines */
      {
        return;
      }
    }
  }
}



/*************************************************************************/
/* */
/* fi_line_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the default */
/* settings for a new line gadget, or alter the settings of an */
/* existing line gadget. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_line_form (int form_label,
                  int gadget_label,
                  double value,
                  Form form_ptr)
{
  int i, x;
  int status;
  char t_str[256];
  int dummy_int;

  FIg_erase (Line_form, ERR_FLD);

  switch (gadget_label)
  {
  case SPECIFY_TOG:

    if ((int)value == 0)
    {
      gadget_attr.draw_flag = 1;

      for (x = 13; x < 24; x++)
        FIg_erase (Line_form, x);
    }
    else
    {
      gadget_attr.draw_flag = 0;

      for (x = 13; x < 24; x++)
        if (x != 17)
          FIg_display (Line_form, x);
    }
    break;

  case Y2_FLD:
  case X2_FLD:
  case X1_FLD:
  case Y1_FLD:

    FIfld_get_text (Line_form, gadget_label, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Line_form, ERR_FLD, &status);

    if (status)
    {
      if (i >= 0) /* Valid input */
      {
        if (gadget_label == Y2_FLD)
        {
          gadget_attr.y_size = i;
        }
        else if (gadget_label == X2_FLD)
        {
          gadget_attr.x_size = i;
        }
        else if (gadget_label == Y1_FLD)
        {
          gadget_attr.y_pos = i;
        }
        else if (gadget_label == X1_FLD)
        {
          gadget_attr.x_pos = i;
        }
      }
      else
      {
        UMSGetByNum (t_str, FB_E_ENDPTGEZERO, 0);
        print_error (Line_form, ERR_FLD, t_str);
      }
    }
    break;

  case FI_HELP:

    /* Help_topic ("Line") */
    break;

  case FI_CANCEL:

    if (command_is_active == EDIT_GADGET)
    {
      if (edit_hilite_flag == 0)
        FIg_unhilite (work_form, old_gadget_label);

      if (edit_display_flag == 0)
        FIg_erase (work_form, old_gadget_label);
    }

    kill_place_line();
    FIg_set_state_off (Line_form, FI_CANCEL);
    break;

  case FI_ACCEPT:

    FIf_erase (Line_form);
    FIg_set_state_off (Line_form, FI_ACCEPT);

    if (Characteristics_form != NULL)
    {
      FIf_erase (FG_color_form);
      FIf_erase (Line_weight_form);
      FIf_erase (Line_style_form);

      FIg_set_state_off (Characteristics_form, CHAR_FOREGROUND_CLR_BTN);
      FIg_set_state_off (Characteristics_form, CHAR_LINE_WEIGHT_BTN);
      FIg_set_state_off (Characteristics_form, CHAR_LINE_STYLE_BTN);

      replace_attr_with_overrides(); /* character.c */
    }

    create_line_gadget();

    if (command_is_active == EDIT_GADGET)
    {
      kill_place_line();
    }
    else if (Line_form != NULL) /* Do this command again */
    {
      FIf_display (Line_form);

      FIf_get_next_label (work_form, &gadget_attr.gadget_label);

      if (Characteristics_form != NULL)
      {
        override_attr.gadget_label = gadget_attr.gadget_label;
        sprintf (t_str, "%d", gadget_attr.gadget_label);
        FIfld_set_text (Characteristics_form, LABEL_FLD,
            0, 0, t_str, 0);
        FIg_erase (Characteristics_form, 10);
      }

      UMSGetByNum (t_str, FB_P_FILLLNEFRM, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
    }
    break;
  }

  return;
}

/*************************************************************************/
/* */
/* execute_place_line() */
/* */
/* This function is called by the executive command handler routine. */
/* */
/* It displays the Line form then exits. After that point */
/* the fi_line_form() gadget notification routine will be in */
/* control. That is to say, every time the operator alters a gadget on */
/* the Line form, the fi_line_form() function will be invoked. */
/* */
/*************************************************************************/

void execute_place_line(void)
{
  char t_str[256];
  int status, label;

  if (work_form == NULL) /* No form defined */
  {
    strcpy (current_command_string, "None");
    command_is_active = 0;
    return;
  }

  UMSGetByNum (t_str, FB_I_PLCLNE, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENDEF, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Line_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlLn");
    status = FIf_new (532, t_str, (int (*)())fi_line_form, &Line_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  setup_new_line_form();
  show_line_form_info();

  FIf_display (Line_form);

  FIf_get_next_label (work_form, &label);

  gadget_attr.gadget_label = label;

  if (Characteristics_form != NULL)
    Update_characteristics_form();

  UMSGetByNum (t_str, FB_P_FILLLNEFRM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}

/*************************************************************************/
/* */
/* edit_line_gadget() */
/* */
/*************************************************************************/

void edit_line_gadget (void)
{
  int status;
  char t_str[256];

  gadget_attr.gadget_label = old_gadget_label;

  UMSGetByNum (t_str, FB_I_EDTLNE, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENCUR, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Line_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlLn");
    status = FIf_new (532, t_str, (int (*)())fi_line_form, &Line_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  setup_old_line_form();
  show_line_form_info();

  FIf_display (Line_form);

  if (Characteristics_form != NULL)
    Update_characteristics_form();

  UMSGetByNum (t_str, FB_P_FILLLNEFRM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}
