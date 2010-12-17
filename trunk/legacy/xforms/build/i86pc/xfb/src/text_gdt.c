/***********************************

		text_gdt.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
	05-07-92	sml		cast func args for ANSI
*/

/*************************************/
/* */
/* This file contains functions for the "place text" and "edit text" */
/* commands. */
/* */
/* Programmer: Mack Draper */
/* Date: Jan. 3, 1989 */
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
/* used by text form */
/* */
/***********************/

#define STRING_FLD 13
#define KEYIN_TOG 21

#define X_TEXT 15
#define Y_TEXT 23
#define X_FLD 16
#define Y_FLD 18

#define TEXT_ERR_FLD 10

#define CHAR_FOREGROUND_CLR_BTN 47
#define CHAR_FOREGROUND_CLR2_BTN 48
#define CHAR_TEXT_FONT_BTN 46

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

Form text_form = NULL;

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
extern Form Font_form;
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
/* kill_place_text() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to PLACE_TEXT indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecteing the point. */
/* */
/*************************************************************************/

void kill_place_text(void)
{
  char t_str[256];

  if (text_form != NULL)
    FIf_erase (text_form);

  if (Characteristics_form != NULL)
    Clear_characteristics_form();

  FIfld_set_text (Message_form, 11, 0, 0, "", 0);
  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  if (command_is_active == PLACE_TEXT)
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
/* setup_old_text_form() */
/* */
/*************************************************************************/

static void setup_old_text_form(void)
{
  setup_standard_attr (old_gadget_label);

  FIg_get_text_style (work_form, old_gadget_label,
      &gadget_attr.text_style);

  FIg_get_justification (work_form, old_gadget_label,
      &gadget_attr.text_justification);

  gadget_attr.scroll_mode = NO_SCROLLING; /* To allow Justification */

  gadget_attr.draw_flag = 0;
  gadget_attr.poke_flag = 0;
  gadget_attr.gadget_type = FI_TEXT;
}

/*************************************************************************/
/* */
/* setup_new_text_form() */
/* */
/* This function is called each time the operator wishes to place a */
/* text string on the work form. It will fill in default settings for */
/* the text. These will be displayed in the button definition form */
/* when the show_text_info() function is called. */
/* */
/*************************************************************************/

static void setup_new_text_form(void)
{
  Set_new_gadget_defaults();

  gadget_attr.off_text[0] = (char) NULL;
  gadget_attr.poke_flag = 1;
  gadget_attr.text_gadget = 1;
  gadget_attr.gadget_type = FI_TEXT;
  gadget_attr.text_justification = FI_LEFT_JUSTIFIED;
  gadget_attr.scroll_mode = NO_SCROLLING; /* To allow justification */
  Next_link = -1;
}

/*************************************************************************/
/* */
/* show_text_form_info() */
/* */
/* This function displays the information contained in the */
/* current_gadget struct into the text form's gadgets. */
/* */
/*************************************************************************/

static void show_text_form_info(void)
{
  char t_str[256];

  FIfld_set_num_rows (text_form, STRING_FLD, 0);
  Break_up_multi_line_string (text_form, STRING_FLD, gadget_attr.off_text);

  FIg_display (text_form, STRING_FLD);

  if (gadget_attr.poke_flag == 0)
  {
    sprintf (t_str, "%d", gadget_attr.x_pos);
    FIfld_set_text (text_form, X_FLD, 0, 0, t_str, 0);

    sprintf (t_str, "%d", gadget_attr.y_pos);
    FIfld_set_text (text_form, Y_FLD, 0, 0, t_str, 0);

    FIg_set_state_on (text_form, KEYIN_TOG);
    FIg_display (text_form, X_TEXT);
    FIg_display (text_form, Y_TEXT);
    FIg_display (text_form, X_FLD);
    FIg_display (text_form, Y_FLD);
  }
  else
  {
    FIfld_set_text (text_form, X_FLD, 0, 0, "", 0);
    FIfld_set_text (text_form, Y_FLD, 0, 0, "", 0);

    FIg_set_state_off (text_form, KEYIN_TOG);
    FIg_erase (text_form, X_TEXT);
    FIg_erase (text_form, Y_TEXT);
    FIg_erase (text_form, X_FLD);
    FIg_erase (text_form, Y_FLD);
  }

}

/*-------------------------------------------------------------------*/

/*********************************************************************/
/* */
/* create_text_gadget() */
/* */
/* This function creates a new text gadget and places it at */
/* the position that was poked by the operator. */
/* */
/*********************************************************************/

static void create_text_gadget(void)
{
  int x;
  char t_str[256];
  int group_label;
  Window window;
  int status;

  /*************************************************/
  /* */
  /* Locate the window number associated with the */
  /* bulletin board of the work_form. */
  /* */
  /*************************************************/

  FIf_get_window (work_form, &window);

  /***********************************************************/
  /* */
  /* If the work form and the place text form intersect, */
  /* then send a window update message to the work_form */
  /* */
  /***********************************************************/

  Refresh_work_form();

  if (gadget_attr.poke_flag == 1)
  {
    UMSGetByNum (t_str, FB_P_POKUPPTXT, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    Form_multi_line_string (text_form, STRING_FLD, gadget_attr.off_text);

    status = Poke_text_location (window, &gadget_attr.x_pos,
        &gadget_attr.y_pos,
        0, 0, gadget_attr.off_text,
        gadget_attr.text_justification,
        gadget_attr.font_name,
        gadget_attr.bodysize);

    FIfld_set_text (Message_form, 44, 0, 0, "", 0);

    if (status != 2) /* Operator wants to abort the place */
      return;
  }

  if (command_is_active == EDIT_GADGET)
  {
    FIg_get_group_label (work_form, old_gadget_label, &group_label);
    FIg_erase (work_form, old_gadget_label);
    FIg_delete (work_form, old_gadget_label);
    old_gadget_label = -1;
  }
  else
    group_label = 0;

  Form_multi_line_string (text_form, STRING_FLD, gadget_attr.off_text);

  Create_and_init_gadget (work_form, FI_TEXT,
      gadget_attr.gadget_label);

  if (group_label != 0)
    FIg_add_to_group (work_form, gadget_attr.gadget_label, group_label);

  FIg_set_text_style (work_form, gadget_attr.gadget_label,
      gadget_attr.text_style);

  FIg_set_justification (work_form, gadget_attr.gadget_label,
      gadget_attr.text_justification);

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

/*-----------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* fi_text_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the default */
/* settings for a new text gadget, or alter the settings of an */
/* existing text gadget. */
/* */
/*************************************************************************/
/* ARGSUSED */
void fi_text_form (int form_label,
                  int gadget_label,
                  double value,
                  Form form_ptr)
{
  int i;
  int status;
  char t_str[256];
  int dummy_int;


  FIg_erase (text_form, TEXT_ERR_FLD);

  switch (gadget_label)
  {
  case STRING_FLD:

    FIfld_get_text (text_form, STRING_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    strcpy (gadget_attr.off_text, t_str);
    break;

  case KEYIN_TOG:

    if ((int)value == 1) /* Use keyin for location */
    {
      gadget_attr.poke_flag = 0;
      FIg_display (text_form, X_TEXT);
      FIg_display (text_form, Y_TEXT);
      FIg_display (text_form, X_FLD);
      FIg_display (text_form, Y_FLD);
    }
    else
    {
      gadget_attr.poke_flag = 1;
      FIg_erase (text_form, X_TEXT);
      FIg_erase (text_form, Y_TEXT);
      FIg_erase (text_form, X_FLD);
      FIg_erase (text_form, Y_FLD);
    }
    break;

  case X_FLD:

    FIfld_get_text (text_form, X_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, text_form,
        TEXT_ERR_FLD, &status);

    if (status) /* Valid input */
      if (i >= 0)
        gadget_attr.x_pos = i;
      else
      {
        UMSGetByNum (t_str, FB_E_XNOTNEG, 0);
        print_error (text_form, TEXT_ERR_FLD, t_str);
      }
    break;

  case Y_FLD:

    FIfld_get_text (text_form, Y_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, text_form,
        TEXT_ERR_FLD, &status);

    if (status) /* Valid input */
      if (i >= 0)
        gadget_attr.y_pos = i;
      else
      {
        UMSGetByNum (t_str, FB_E_YNOTNEG, 0);
        print_error (text_form, TEXT_ERR_FLD, t_str);
      }
    break;

  case FI_HELP:

    /* Help_topic ("Text") */
    FIg_set_state_off (text_form, FI_HELP);
    break;

  case FI_CANCEL:

    if (command_is_active == EDIT_GADGET)
    {
      if (edit_hilite_flag == 0)
        FIg_unhilite (work_form, old_gadget_label);

      if (edit_display_flag == 0)
        FIg_erase (work_form, old_gadget_label);
    }

    kill_place_text();
    FIg_set_state_off (text_form, FI_CANCEL);
    break;

  case FI_ACCEPT:

    FIf_erase (text_form);
    FIg_set_state_off (text_form, FI_ACCEPT);

    if (Characteristics_form != NULL)
    {
      FIf_erase (FG_color_form);
      FIf_erase (FG2_color_form);
      FIf_erase (Font_form);
      FIg_set_state_off (Characteristics_form, CHAR_FOREGROUND_CLR_BTN);
      FIg_set_state_off (Characteristics_form, CHAR_TEXT_FONT_BTN);

      replace_attr_with_overrides(); /* character.c */
    }

    create_text_gadget();

    if (command_is_active == EDIT_GADGET)
      kill_place_text();
    else if (text_form != NULL) /* Do this command again */
    {
      FIg_set_state_off (text_form, FI_ACCEPT);

      FIf_display (text_form);

      FIf_get_next_label (work_form, &gadget_attr.gadget_label);

      if (Characteristics_form != NULL)
      {
        override_attr.gadget_label = gadget_attr.gadget_label;

        sprintf (t_str, "%d", override_attr.gadget_label);
        FIfld_set_text (Characteristics_form, LABEL_FLD,
            0, 0, t_str, 0);
        FIg_erase (Characteristics_form, 10);
      }

      UMSGetByNum (t_str, FB_P_FILLTXTFRM, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
    }
    break;
  }

  return;
}

/*************************************************************************/
/* */
/* execute_place_text() */
/* */
/* This function is called in one of two ways. The first is to be */
/* called by the executive command handler routine. The second is to */
/* be called after text has been successfully placed. */
/* */
/* It displays the Text form then exits. After that point */
/* the fi_text_form() gadget notification routine will be in */
/* control. That is to say, every time the operator alters a gadget on */
/* the text form, the fi_text_form() function will be invoked. */
/* */
/*************************************************************************/

void execute_place_text(void)
{
  char t_str[256];
  int status;

  if (work_form == NULL) /* No form defined */
  {
    strcpy (current_command_string, "None");
    command_is_active = 0;
    return;
  }

  UMSGetByNum (t_str, FB_I_PCETXTSTR, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENDEF, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (text_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlTx");
    status = FIf_new (199, t_str, (int (*)())fi_text_form, &text_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  setup_new_text_form();
  show_text_form_info();
  FIf_display (text_form);

  FIf_get_next_label (work_form, &gadget_attr.gadget_label);

  if (Characteristics_form != NULL)
    Update_characteristics_form();

  UMSGetByNum (t_str, FB_P_FILLTXTFRM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  FIf_process_point (text_form, 34, 82, 1, 2, 0);	/* add last arg
													for ANSI */
  /*
FIg_start_seq (text_form, STRING_FLD);
*/
}

/*-------------------------------------------------------------------------*/

void edit_text_gadget(void)
{
  char t_str[256];
  int status;

  gadget_attr.gadget_label = old_gadget_label;

  UMSGetByNum (t_str, FB_I_EDTTXTSTR, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENCUR, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (text_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlTx");
    status = FIf_new (199, t_str, (int (*)())fi_text_form, &text_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  setup_old_text_form();
  show_text_form_info();

  FIf_display (text_form);

  if (Characteristics_form != NULL)
    Update_characteristics_form();

  UMSGetByNum (t_str, FB_P_FILLTXTFRM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  FIf_process_point (text_form, 34, 82, 1, 2, 0);	/* add last arg
													for ANSI */

  /*
FIg_start_seq (text_form, STRING_FLD);
*/

}
