/***********************************

		toggle_gdt.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
	05-07-92	sml		casted func args for ANSI
*/

/*************************************/
/* */
/* This file contains functions for the "place toggle" and "edit toggle" */
/* commands. */
/* */
/* Programmer: Mack Draper */
/* Date: Jan. 8, 1988 */
/* */
/*************************************/

#include <stdio.h>

#include <X11/Xlib.h>

#include "FI.h"
#include "FIdyn.h"
#include "NFBpriv.h"
#include "UMS.h"
#include "FB.h"
#include "FImgt.h"

#include "XFIproto_pub.h"
#include "XFIproto_pri.h"
#include "XFBproto_pri.h"


#define LABEL_FLD 41 /* Needed by characteristics form */

/*************************/
/* */
/* used by toggle form */
/* */
/*************************/

#define TOGGLE_TYPE_TOG 24
#define VALUE_TOG 25

#define SM_TOG 26
#define MED_TOG 27
#define LG_TOG 28
#define DRAW_TOG 17

#define HT_FLD 43
#define WD_FLD 44

#define KEYIN_TOG 45
#define X_TEXT 20
#define Y_TEXT 21
#define X_FLD 41
#define Y_FLD 42

#define OFF_TEXT_TEXT 30
#define OFF_SYMBOL_FILE_TEXT 12
#define ON_TEXT_TEXT 11
#define ON_SYMBOL_FILE_TEXT 13
#define OFF_TEXT_FLD 34
#define ON_TEXT_FLD 38

#define OFF_SYMBOL_INDEX_TEXT 14
#define ON_SYMBOL_INDEX_TEXT 15
#define OFF_SYMBOL_INDEX_FLD 37
#define ON_SYMBOL_INDEX_FLD 40

#define SELECT_BTN 19
#define ADD_DIRECTORY_BTN 48
#define FIT_BTN 39
#define ROTATE_BTN 29
#define ERR_FLD 10

#define CHAR_FOREGROUND_CLR_BTN 47
#define CHAR_FOREGROUND2_CLR_BTN 48
#define CHAR_TEXT_FONT_BTN 46

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

Form Toggle_form = NULL;

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern struct _FI_sym_st *_FI_symbols;

extern Form work_form;
extern struct dpb_struct dpb;
extern int command_is_active;
extern char current_command_string[80];
extern struct gadget_struct gadget_attr;
extern struct dpb_struct temp_dpb;
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
extern int Next_in_sequence;
extern int Next_link;

extern int Edit_sequence_array[100];
extern int Edit_data_link_array[100];
extern int Edit_sequence_count;
extern int Edit_data_link_count;

extern char Global_symbol_file[20];
extern Form Symbol_scroll;
extern Form Sym_dir_form;

extern char language[80];
extern Display *display;

/*************************************************************************/
/* */
/* kill_place_toggle() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to PLACE_TOGGLE indicating that this command is */
/* executing. Thirdly command autokill is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecteing the point. */
/* */
/*************************************************************************/

void kill_place_toggle(void)
{
  char t_str[256];

  if (Toggle_form != NULL)
    FIf_erase (Toggle_form);

  if (Characteristics_form != NULL)
    Clear_characteristics_form ();

  if (Symbol_scroll != NULL)
    FIf_erase (Symbol_scroll);

  if (Sym_dir_form != NULL)
    FIf_erase (Sym_dir_form);

  FIfld_set_text (Message_form, 11, 0, 0, "", 0);
  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  if (command_is_active == PLACE_TOGGLE)
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
/* setup_old_toggle_form() */
/* */
/*************************************************************************/

static void setup_old_toggle_form(void)
{
  setup_standard_attr (old_gadget_label);

  if (gadget_attr.text_gadget == 0)
    strcpy (gadget_attr.font_name, dpb.font_name);

  FIg_get_text_style (work_form, old_gadget_label,
      &gadget_attr.text_style);

  FIg_get_on_symbol_index (work_form, old_gadget_label,
      &gadget_attr.on_sym_index);

  if (gadget_attr.text_gadget != 0)   /* GMD 10/5/91  */
     FIg_get_on_text (work_form, old_gadget_label, gadget_attr.on_text);

  FIg_get_justification (work_form, old_gadget_label,
      &gadget_attr.text_justification);

  gadget_attr.scroll_mode = NO_SCROLLING; /* To allow justification */

  gadget_attr.draw_flag = 0;
  gadget_attr.poke_flag = 0;
  gadget_attr.gadget_type = FI_TOGGLE;
}

/*************************************************************************/
/* */
/* setup_new_toggle_form() */
/* */
/* This function is called each time the operator wishes to place a */
/* new toggle on the work form. It will fill in default settings for */
/* the toggle. These will be displayed in the toggle definition form */
/* when the show_toggle_info() function is called. */
/* */
/*************************************************************************/

static void setup_new_toggle_form(void)
{
  Set_new_gadget_defaults();

  gadget_attr.off_color = gadget_attr.on_color;

  gadget_attr.x_pos = 0;
  gadget_attr.x_size = 90;
  gadget_attr.y_size = 60;
  gadget_attr.default_value = 0;

  strcpy (gadget_attr.symbol_file, Global_symbol_file);
  strcpy (gadget_attr.off_text, "");
  strcpy (gadget_attr.on_text, "");

  gadget_attr.draw_flag = 0;
  gadget_attr.poke_flag = 1;
  gadget_attr.text_gadget = 1;
  gadget_attr.text_justification = FI_CENTER_JUSTIFIED;
  gadget_attr.scroll_mode = NO_SCROLLING; /* To allow justification */

  gadget_attr.gadget_type = FI_TOGGLE;
  Next_in_sequence = 0;
  Next_link = -1;
}

/*************************************************************************/
/* */
/* show_toggle_form_info() */
/* */
/* This function displays the information contained in the */
/* current_gadget struct into the toggle form's gadgets. */
/* */
/*************************************************************************/

static void show_toggle_form_info(void)
{
  char t_str[256];

  FIg_erase (Toggle_form, 10);
  FIg_erase (Toggle_form, ROTATE_BTN);
  FIg_set_off_symbol_index (Toggle_form, ROTATE_BTN, 65);
  FIg_set_state_off (Toggle_form, SELECT_BTN);
  FIg_set_state_off (Toggle_form, ADD_DIRECTORY_BTN);

  if (gadget_attr.text_gadget == 1) /* text toggle */
  {
    FIg_set_state_off (Toggle_form, TOGGLE_TYPE_TOG);

    Break_up_multi_line_string (Toggle_form, 13, gadget_attr.off_text);

    Break_up_multi_line_string (Toggle_form, ON_TEXT_FLD,
        gadget_attr.on_text);

    FIg_erase (Toggle_form, 34);
    FIg_erase (Toggle_form, OFF_SYMBOL_FILE_TEXT);
    FIg_erase (Toggle_form, OFF_SYMBOL_INDEX_TEXT);
    FIg_erase (Toggle_form, ON_SYMBOL_INDEX_TEXT);
    FIg_erase (Toggle_form, OFF_SYMBOL_INDEX_FLD);
    FIg_erase (Toggle_form, ON_SYMBOL_INDEX_FLD);

    FIg_erase (Toggle_form, SELECT_BTN);
    FIg_erase (Toggle_form, ADD_DIRECTORY_BTN);

    FIg_display (Toggle_form, OFF_TEXT_TEXT);
    FIg_display (Toggle_form, ON_TEXT_TEXT);
    FIg_display (Toggle_form, 13);
    FIg_display (Toggle_form, ON_TEXT_FLD);
  }
  else /* symbol toggle */
  {
    FIg_set_state_on (Toggle_form, TOGGLE_TYPE_TOG);

    FIg_erase (Toggle_form, OFF_TEXT_TEXT);
    FIg_erase (Toggle_form, ON_TEXT_TEXT);
    FIg_erase (Toggle_form, ON_TEXT_FLD);
    FIg_erase (Toggle_form, 13);
    FIfld_set_num_rows (Toggle_form, ON_TEXT_FLD, 0);
    FIfld_set_num_rows (Toggle_form, 13, 0);
    FIg_display (Toggle_form, OFF_SYMBOL_FILE_TEXT);
    FIg_display (Toggle_form, 34);

    FIfld_set_text (Toggle_form, 34, 0, 0,
        gadget_attr.symbol_file, 0);

    sprintf (t_str, "%d", gadget_attr.off_sym_index);
    FIfld_set_text (Toggle_form, OFF_SYMBOL_INDEX_FLD, 0, 0, t_str, 0);

    sprintf (t_str, "%d", gadget_attr.on_sym_index);
    FIfld_set_text (Toggle_form, ON_SYMBOL_INDEX_FLD, 0, 0, t_str, 0);

    FIg_display (Toggle_form, OFF_SYMBOL_INDEX_TEXT);
    FIg_display (Toggle_form, ON_SYMBOL_INDEX_TEXT);
    FIg_display (Toggle_form, OFF_SYMBOL_INDEX_FLD);
    FIg_display (Toggle_form, ON_SYMBOL_INDEX_FLD);

    FIg_set_state_off (Toggle_form, SELECT_BTN);
    FIg_display (Toggle_form, SELECT_BTN);
    FIg_set_state_off (Toggle_form, ADD_DIRECTORY_BTN);
    FIg_display (Toggle_form, ADD_DIRECTORY_BTN);
  }

  if ((int)gadget_attr.default_value == 0)
    FIg_set_state_off (Toggle_form, VALUE_TOG);
  else
    FIg_set_state_on (Toggle_form, VALUE_TOG);

  sprintf (t_str, "%d", gadget_attr.x_size);
  FIfld_set_text (Toggle_form, WD_FLD, 0, 0, t_str, 0);

  sprintf (t_str, "%d", gadget_attr.y_size);
  FIfld_set_text (Toggle_form, HT_FLD, 0, 0, t_str, 0);

  FIg_set_state_off (Toggle_form, DRAW_TOG);
  FIg_set_state_off (Toggle_form, SM_TOG);
  FIg_set_state_off (Toggle_form, MED_TOG);
  FIg_set_state_off (Toggle_form, LG_TOG);

  if ((gadget_attr.x_size == 45) &&
      (gadget_attr.y_size == 43))
    FIg_set_state_on (Toggle_form, SM_TOG);

  if ((gadget_attr.x_size == 60) &&
      (gadget_attr.y_size == 50))
    FIg_set_state_on (Toggle_form, MED_TOG);

  if ((gadget_attr.x_size == 90) &&
      (gadget_attr.y_size == 60))
    FIg_set_state_on (Toggle_form, LG_TOG);

  if (gadget_attr.poke_flag == 0)
  {
    FIg_set_state_on (Toggle_form, KEYIN_TOG);
    FIg_display (Toggle_form, X_TEXT);
    FIg_display (Toggle_form, Y_TEXT);
    FIg_display (Toggle_form, X_FLD);
    FIg_display (Toggle_form, Y_FLD);

    sprintf (t_str, "%d", gadget_attr.x_pos);
    FIfld_set_text (Toggle_form, X_FLD, 0, 0, t_str, 0);

    sprintf (t_str, "%d", gadget_attr.y_pos);
    FIfld_set_text (Toggle_form, Y_FLD, 0, 0, t_str, 0);
  }
  else
  {
    FIg_set_state_off (Toggle_form, KEYIN_TOG);
    FIg_erase (Toggle_form, X_TEXT);
    FIg_erase (Toggle_form, Y_TEXT);
    FIg_erase (Toggle_form, X_FLD);
    FIg_erase (Toggle_form, Y_FLD);

    FIfld_set_text (Toggle_form, X_FLD, 0, 0, "", 0);
    FIfld_set_text (Toggle_form, Y_FLD, 0, 0, "", 0);
  }

}

/*-------------------------------------------------------------------------*/

/*********************************************************************/
/* */
/* create_toggle_gadget() */
/* */
/* This function creates a new toggle gadget and places it at */
/* the position that was poked by the operator. */
/* */
/*********************************************************************/

static void create_toggle_gadget(void)
{
  int x, y;
  Window window;
  char t_str[256];
  int group_label;
  int status;

  /***********************************************************/
  /* */
  /* If the work form and the place toggle form intersect, */
  /* then send a window update message to the work_form */
  /* */
  /***********************************************************/

  Refresh_work_form();

  if (gadget_attr.draw_flag == 0)
  {
    if (gadget_attr.poke_flag == 0)
    {
      x = gadget_attr.x_size;
      y = gadget_attr.y_size;
    }
    else /* Get datapoint for toggle gadget location */
    {
      UMSGetByNum (t_str, FB_P_POKUPPTOG, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

      FIf_get_window (work_form, &window);

      status = Get_first_point (window, &gadget_attr.x_pos,
          &gadget_attr.y_pos,
          gadget_attr.x_size,
          gadget_attr.y_size, 0, 0);

      if (status == 2) /* Success */
      {
        x = gadget_attr.x_size;
        y = gadget_attr.y_size;
      }
      else /* Operator wants to kill this command */
        return;
    }
  }
  else /* Get two datapoints for size and location of toggle */
  {
    UMSGetByNum (t_str, FB_P_POKTOGANC, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    FIf_get_window (work_form, &window);

    status = Get_first_point (window, &x, &y, 0, 0, 0, 0);

    if (status == 2) /* Success */
    {
      UMSGetByNum (t_str, FB_I_ANCX, "%d%d", x, y);
      FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);
      UMSGetByNum (t_str, FB_P_POKTOGSWG, 0);
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
      else /* Operator wants to abort placing the toggle */
        return;
    }
    else /* Operator wants to abort placing the toggle */
      return;
  }

  if (gadget_attr.text_gadget == 0)
  {
    strcpy (gadget_attr.default_str, gadget_attr.font_name);
    strcpy (gadget_attr.font_name, gadget_attr.symbol_file);
  }
  else
  {
    Form_multi_line_string (Toggle_form, 13, gadget_attr.off_text);
    Form_multi_line_string (Toggle_form, ON_TEXT_FLD, gadget_attr.on_text);
  }

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

  Create_and_init_gadget (work_form, FI_TOGGLE, gadget_attr.gadget_label);

  if (group_label != 0)
    FIg_add_to_group (work_form, gadget_attr.gadget_label, group_label);

  gadget_attr.x_size = x;
  gadget_attr.y_size = y;

  if (gadget_attr.text_gadget == 0) /* symbol toggle */
  {
    FIg_set_on_symbol_index (work_form, gadget_attr.gadget_label,
        gadget_attr.on_sym_index);
    strcpy (gadget_attr.font_name, gadget_attr.default_str);

    FIg_set_justification (work_form, gadget_attr.gadget_label,
        FI_CENTER_JUSTIFIED);
  }
  else
  {
    FIg_set_on_text (work_form, gadget_attr.gadget_label,
        gadget_attr.on_text);

    FIg_set_text_style (work_form, gadget_attr.gadget_label,
        gadget_attr.text_style);

    FIg_set_justification (work_form, gadget_attr.gadget_label,
        gadget_attr.text_justification);
  }

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
/* fi_toggle_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the default */
/* settings for a new toggle gadget, or alter the settings of an */
/* existing toggle gadget. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_toggle_form (int form_label,
                    int gadget_label,
                    double value,
                    Form form_ptr)
{
  int num_flag, i, j, x;
  char sym_name[256];
  int sym_value;
  int status;
  int state;
  char t_str[256];
  int height, width, width2, height2;
  int dummy_int;

  FIg_erase (Toggle_form, ERR_FLD);

  switch (gadget_label)
  {
  case FIT_BTN:

    gadget_attr.draw_flag = 0;
    FIg_get_state (Toggle_form, KEYIN_TOG, &state);
    if (state == 0)
      gadget_attr.poke_flag = 1;
    else
      gadget_attr.poke_flag = 0;
    FIg_set_state_off (Toggle_form, FIT_BTN);

    if (gadget_attr.text_gadget == 1)
    {
      Form_multi_line_string (Toggle_form, 13, gadget_attr.off_text);
      Form_multi_line_string (Toggle_form, ON_TEXT_FLD, gadget_attr.on_text);

      Calculate_text_size (gadget_attr.off_text, temp_dpb.font_name,
          temp_dpb.bodysize, &width, &height);
      Calculate_text_size (gadget_attr.on_text, temp_dpb.font_name,
          temp_dpb.bodysize, &width2, &height2);

/* dmb:09/18/91:Do we need to do this?
      _FI_mlt_get_lines (gadget_attr.off_text, &num_lines, &width,
          font_id, font_type);
      _FI_mlt_get_lines (gadget_attr.on_text, &num_lines2, &width2,
          font_id, font_type);
*/

      if (width2 > width)
        width = width2;

/* dmb:09/18/91:Do we need to do this?
      if (num_lines2 > num_lines)
        num_lines = num_lines2;

      height = height * num_lines;
*/

      if (height2 > height)
        height = height2;

      if (height < 20)
        height = 20;

      if (width < 20)
        width = 20;
    }
    else /* toggle uses symbols */
    {
      Font symbol_id;
      char path [256];

      status = _FI_find_symbol_path_and_id (path,
          gadget_attr.symbol_file, (int *)&symbol_id);
      if (status == FI_SUCCESS)
      {
        width =
            _FI_symbols[symbol_id].sym_slot[gadget_attr.off_sym_index].sym_width;
        height =
            _FI_symbols[symbol_id].sym_slot[gadget_attr.off_sym_index].sym_height;

        width2 =
            _FI_symbols[symbol_id].sym_slot[gadget_attr.on_sym_index].sym_width;
        height2 =
            _FI_symbols[symbol_id].sym_slot[gadget_attr.on_sym_index].sym_height;
      }
      else
      {
        width = 1;
        height = 1;
      }

      if (width2 > width)
        width = width2;

      if (height2 > height)
        height = height2;

/* dmb:09/18/91: Didn't we already do this?
      if (status != FI_SUCCESS)
      {
        width = 1;
        height = 1;
      }
*/
      if (height < 20)
        height = 20;

      if (width < 20)
        width = 20;
    }
    height += 15;
    width += 30;

    FIg_set_state_off (Toggle_form, SM_TOG);
    FIg_set_state_off (Toggle_form, MED_TOG);
    FIg_set_state_off (Toggle_form, LG_TOG);
    FIg_set_state_off (Toggle_form, DRAW_TOG);

    gadget_attr.y_size = height;
    gadget_attr.x_size = width;
    sprintf (t_str, "%d", height);
    FIg_set_text (Toggle_form, HT_FLD, t_str);
    sprintf (t_str, "%d", width);
    FIg_set_text (Toggle_form, WD_FLD, t_str);
    break;

  case ADD_DIRECTORY_BTN:

    if ((int)value == 1)
      Display_symbol_dir_form();
    else
      FIf_erase (Sym_dir_form);
    break;

  case ROTATE_BTN:

    FIg_set_state_off (Toggle_form, ROTATE_BTN);
    FIg_get_off_symbol_index (Toggle_form, ROTATE_BTN, &state);

    if (state == 65)
    {
      for (x = 66; x < 70; x++)
      {
        FIg_set_off_symbol_index (Toggle_form, ROTATE_BTN, x);
        FIg_activate (Toggle_form, ROTATE_BTN);
        FIg_display (Toggle_form, ROTATE_BTN);
      }
      if (Symbol_scroll != NULL)
        Set_scroll_view_area (gadget_attr.on_sym_index);
    }
    else
    {
      for (x = 68; x > 64; x--)
      {
        FIg_set_symbol_index (Toggle_form, ROTATE_BTN, x);
        FIg_activate (Toggle_form, ROTATE_BTN);
        FIg_display (Toggle_form, ROTATE_BTN);
      }
      if (Symbol_scroll != NULL)
        Set_scroll_view_area (gadget_attr.off_sym_index);
    }
    break;

  case SELECT_BTN:

    if ((int)value == 1)
    {
      if (Symbol_scroll == NULL)
      {
        strcpy (t_str, execute_dir);
        strcat (t_str, "/config/");
        strcat (t_str, language);
        strcat (t_str, "/forms/FBSymSel");
        status = FIf_new (444, t_str, (int (*)())fi_symbol_scroll, &Symbol_scroll);

        if (status != FI_SUCCESS)
          Report_fatal_form_error (status, t_str);
      }

      FIg_set_off_symbol_index (Toggle_form, ROTATE_BTN, 65); /* First */
      FIg_display (Toggle_form, ROTATE_BTN);

      Init_scroll_area (gadget_attr.symbol_file,
          gadget_attr.off_sym_index);
      FIf_display (Symbol_scroll);
    }
    else
    {
      if (Symbol_scroll != NULL)
      {
        FIf_erase (Symbol_scroll);
        FIg_erase (Toggle_form, ROTATE_BTN);
      }
    }
    break;

  case TOGGLE_TYPE_TOG:

    if ((int)value == 0)
    {
      if (Characteristics_form != NULL)
      {
        FIg_set_state_off (Characteristics_form, CHAR_TEXT_FONT_BTN);
        FIg_enable (Characteristics_form, CHAR_TEXT_FONT_BTN);
      }

      if (Symbol_scroll != NULL)
        FIf_erase (Symbol_scroll);

      if (Sym_dir_form != NULL)
        FIf_erase (Sym_dir_form);

      gadget_attr.text_gadget = 1; /* text toggle */

      FIfld_set_text (Toggle_form, OFF_TEXT_FLD, 0, 0,
          gadget_attr.off_text, 0);

      FIfld_set_text (Toggle_form, ON_TEXT_FLD, 0, 0,
          gadget_attr.on_text, 0);

      FIg_erase (Toggle_form, SELECT_BTN);
      FIg_set_state_off (Toggle_form, SELECT_BTN);
      FIg_erase (Toggle_form, ADD_DIRECTORY_BTN);
      FIg_set_state_off (Toggle_form, ADD_DIRECTORY_BTN);
      FIg_erase (Toggle_form, ROTATE_BTN);
      FIg_set_symbol_index (Toggle_form, ROTATE_BTN, 16);

      FIg_erase (Toggle_form, OFF_SYMBOL_INDEX_TEXT);
      FIg_erase (Toggle_form, ON_SYMBOL_INDEX_TEXT);
      FIg_erase (Toggle_form, OFF_SYMBOL_INDEX_FLD);
      FIg_erase (Toggle_form, ON_SYMBOL_INDEX_FLD);
      FIg_erase (Toggle_form, OFF_SYMBOL_FILE_TEXT);
      FIg_erase (Toggle_form, 34);

      FIg_display (Toggle_form, ON_TEXT_TEXT);
      FIg_display (Toggle_form, OFF_TEXT_TEXT);
      FIg_display (Toggle_form, ON_TEXT_FLD);
      FIg_display (Toggle_form, 13);
    }
    else
    {
      if (Characteristics_form != NULL)
      {
        FIg_set_state_off (Characteristics_form, CHAR_TEXT_FONT_BTN);
        FIg_disable (Characteristics_form, CHAR_TEXT_FONT_BTN);
      }

      gadget_attr.text_gadget = 0; /* symbol toggle */

      FIg_erase (Toggle_form, ON_TEXT_TEXT);
      FIg_erase (Toggle_form, OFF_TEXT_TEXT);
      FIg_erase (Toggle_form, ON_TEXT_FLD);
      FIg_erase (Toggle_form, 13);

      FIfld_set_text (Toggle_form, OFF_TEXT_FLD, 0, 0,
          gadget_attr.symbol_file, 0);

      FIg_display (Toggle_form, OFF_SYMBOL_FILE_TEXT);

      sprintf (t_str, "%d", gadget_attr.off_sym_index);
      FIfld_set_text (Toggle_form, OFF_SYMBOL_INDEX_FLD, 0, 0,
          t_str, 0);

      sprintf (t_str, "%d", gadget_attr.on_sym_index);
      FIfld_set_text (Toggle_form, ON_SYMBOL_INDEX_FLD, 0, 0,
          t_str, 0);

      FIg_display (Toggle_form, OFF_SYMBOL_INDEX_TEXT);
      FIg_display (Toggle_form, ON_SYMBOL_INDEX_TEXT);
      FIg_display (Toggle_form, OFF_SYMBOL_INDEX_FLD);
      FIg_display (Toggle_form, ON_SYMBOL_INDEX_FLD);
      FIg_display (Toggle_form, SELECT_BTN);
      FIg_display (Toggle_form, ADD_DIRECTORY_BTN);
      FIg_display (Toggle_form, 34);
    }
    break;

  case VALUE_TOG:

    gadget_attr.default_value = value;
    break;

  case OFF_TEXT_FLD:

    FIfld_get_text (Toggle_form, OFF_TEXT_FLD, 0, 0, 255, 
		(unsigned char *)t_str,
        &dummy_int, &dummy_int);

    if (gadget_attr.text_gadget == 1) /* text */
    {
      strcpy (gadget_attr.off_text, t_str);
    }
    else
    {
      strcpy (gadget_attr.symbol_file, t_str);
      strcpy (Global_symbol_file, t_str);

      if (Symbol_scroll != NULL)
        Set_scroll_symbol_file (t_str);

      /*
else
{
UMSGetByNum (t_str, FB_E_SYMFILNOTFND, 0);
print_error (Toggle_form, ERR_FLD, t_str);
}
*/
    }
    break;

  case 13:

    FIfld_get_text (Toggle_form, 13, 0, 0, 255, 
		(unsigned char *)t_str,
        &dummy_int, &dummy_int);

    strcpy (gadget_attr.off_text, t_str);
    break;

  case ON_TEXT_FLD:

    FIfld_get_text (Toggle_form, ON_TEXT_FLD, 0, 0, 255, 
		(unsigned char *)t_str,
        &dummy_int, &dummy_int);

    strcpy (gadget_attr.on_text, t_str);
    break;

  case OFF_SYMBOL_INDEX_FLD:
  case ON_SYMBOL_INDEX_FLD:

    num_flag = 1;
    i = 0; 
    j = 0;

    if (gadget_label == OFF_SYMBOL_INDEX_FLD)
      FIfld_get_text (Toggle_form, OFF_SYMBOL_INDEX_FLD,
          0, 0, 255, (unsigned char *)t_str, &dummy_int, &dummy_int);
    else
      FIfld_get_text (Toggle_form, ON_SYMBOL_INDEX_FLD,
          0, 0, 255, (unsigned char *)t_str, &dummy_int, &dummy_int);

    if ((t_str[0] == '\'') ||
        (t_str[0] == '\\'))
    {
      i = 1;
      if (t_str[1] == '\\')
        i = 2;
    }
    while ((t_str[i] != '\0') &&
        (num_flag))
    {
      if (t_str[i] != '\'')
      {
        if (isdigit (t_str[i]))
        {
          if (( t_str[0] == '\'' ) &&
              ( t_str[1] == '\\'))
          {
            sym_name[i - 2] = t_str[i];
          }
          else if ( t_str[0] == '\\' )
          {
            sym_name[i - 1] = t_str[i];
          }
          else
          {
            sym_name[ i ] = t_str[i];
          }
          j++;
        }
        else
        {
          num_flag = 0;
        }
      }
      i = i + 1;
    }

    if ( num_flag )
    {
      sym_name[j] = (char) NULL;
      if (( t_str[0] == '\'' ) ||
          ( t_str[0] == '\\'))
      {
        sscanf ( sym_name, "%o", &sym_value );
      }
      else
      {
        sscanf (t_str, "%d", &sym_value);
      }

      if ((sym_value < 0) ||
          (sym_value > 255))
      {
        UMSGetByNum (t_str, FB_E_RANGE255, 0);
        print_error (Toggle_form, ERR_FLD, t_str);
      }
      else
      {
        if (gadget_label == ON_SYMBOL_INDEX_FLD)
        {
          gadget_attr.on_sym_index = sym_value;

          FIg_get_off_symbol_index (Toggle_form, ROTATE_BTN, &state);

          if (state == 65)
          {
            for (x = 66; x < 70; x++)
            {
              FIg_set_off_symbol_index (Toggle_form, ROTATE_BTN, x);
              FIg_activate (Toggle_form, ROTATE_BTN);

              if (Symbol_scroll != NULL)
                FIg_display (Toggle_form, ROTATE_BTN);
            }
          }
        }
        else
        {
          gadget_attr.off_sym_index = sym_value;

          FIg_get_off_symbol_index (Toggle_form, ROTATE_BTN, &state);
          if (state == 69)
          {
            for (x = 68; x > 64; x--)
            {
              FIg_set_symbol_index (Toggle_form, ROTATE_BTN, x);
              FIg_activate (Toggle_form, ROTATE_BTN);

              if (Symbol_scroll != NULL)
                FIg_display (Toggle_form, ROTATE_BTN);
            }
          }
        }
        if (Symbol_scroll != NULL)
          Set_scroll_view_area (sym_value);
      }
    }
    else
    {
      UMSGetByNum (t_str, FB_E_INVALIDSYM, 0);
      print_error (Toggle_form, ERR_FLD, t_str);
    }
    break;

  case SM_TOG:

    gadget_attr.draw_flag = 0;

    FIg_get_state (Toggle_form, KEYIN_TOG, &state);
    if (state == 0)
      gadget_attr.poke_flag = 1;
    else
      gadget_attr.poke_flag = 0;

    FIg_set_state_on (Toggle_form, SM_TOG);
    FIg_set_state_off (Toggle_form, MED_TOG);
    FIg_set_state_off (Toggle_form, LG_TOG);
    FIg_set_state_off (Toggle_form, DRAW_TOG);

    gadget_attr.x_size = 45;
    sprintf (t_str, "%d", gadget_attr.x_size);
    FIfld_set_text (Toggle_form, WD_FLD, 0, 0, t_str, 0);

    gadget_attr.y_size = 43;
    sprintf (t_str, "%d", gadget_attr.y_size);
    FIfld_set_text (Toggle_form, HT_FLD, 0, 0, t_str, 0);
    break;

  case MED_TOG:

    gadget_attr.draw_flag = 0;

    FIg_get_state (Toggle_form, KEYIN_TOG, &state);
    if (state == 0)
      gadget_attr.poke_flag = 1;
    else
      gadget_attr.poke_flag = 0;

    FIg_set_state_off (Toggle_form, SM_TOG);
    FIg_set_state_on (Toggle_form, MED_TOG);
    FIg_set_state_off (Toggle_form, LG_TOG);
    FIg_set_state_off (Toggle_form, DRAW_TOG);

    gadget_attr.x_size = 60;
    sprintf (t_str, "%d", gadget_attr.x_size);
    FIfld_set_text (Toggle_form, WD_FLD, 0, 0, t_str, 0);

    gadget_attr.y_size = 50;
    sprintf (t_str, "%d", gadget_attr.y_size);
    FIfld_set_text (Toggle_form, HT_FLD, 0, 0, t_str, 0);
    break;

  case LG_TOG:

    gadget_attr.draw_flag = 0;

    FIg_get_state (Toggle_form, KEYIN_TOG, &state);
    if (state == 0)
      gadget_attr.poke_flag = 1;
    else
      gadget_attr.poke_flag = 0;

    FIg_set_state_off (Toggle_form, SM_TOG);
    FIg_set_state_off (Toggle_form, MED_TOG);
    FIg_set_state_on (Toggle_form, LG_TOG);
    FIg_set_state_off (Toggle_form, DRAW_TOG);

    gadget_attr.x_size = 90;
    sprintf (t_str, "%d", gadget_attr.x_size);
    FIfld_set_text (Toggle_form, WD_FLD, 0, 0, t_str, 0);

    gadget_attr.y_size = 60;
    sprintf (t_str, "%d", gadget_attr.y_size);
    FIfld_set_text (Toggle_form, HT_FLD, 0, 0, t_str, 0);
    break;

  case DRAW_TOG:

    gadget_attr.draw_flag = 1;
    gadget_attr.poke_flag = 0;

    FIg_set_state_off (Toggle_form, SM_TOG);
    FIg_set_state_off (Toggle_form, MED_TOG);
    FIg_set_state_off (Toggle_form, LG_TOG);
    FIg_set_state_on (Toggle_form, DRAW_TOG);

    FIg_set_state_off (Toggle_form, KEYIN_TOG);
    FIg_erase (Toggle_form, X_TEXT);
    FIg_erase (Toggle_form, Y_TEXT);
    FIg_erase (Toggle_form, X_FLD);
    FIg_erase (Toggle_form, Y_FLD);

    FIfld_set_text (Toggle_form, WD_FLD, 0, 0, " ", 0);
    FIfld_set_text (Toggle_form, HT_FLD, 0, 0, " ", 0);
    break;

  case HT_FLD:

    FIfld_get_text (Toggle_form, HT_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Toggle_form, ERR_FLD, &status);

    if (status)
      if (i > 0) /* Valid input */
      {
        gadget_attr.draw_flag = 0;

        FIg_get_state (Toggle_form, KEYIN_TOG, &state);
        if (state == 0)
          gadget_attr.poke_flag = 1;
        else
          gadget_attr.poke_flag = 0;

        FIg_set_state_off (Toggle_form, SM_TOG);
        FIg_set_state_off (Toggle_form, MED_TOG);
        FIg_set_state_off (Toggle_form, LG_TOG);
        FIg_set_state_off (Toggle_form, DRAW_TOG);

        gadget_attr.y_size = i;
      }
      else
      {
        UMSGetByNum (t_str, FB_E_HTGTZERO, 0);
        print_error (Toggle_form, ERR_FLD, t_str);
      }
    break;

  case WD_FLD:

    FIfld_get_text (Toggle_form, WD_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Toggle_form, ERR_FLD, &status);

    if (status)
      if (i > 0) /* Valid input */
      {
        gadget_attr.draw_flag = 0;

        FIg_get_state (Toggle_form, KEYIN_TOG, &state);
        if (state == 0)
          gadget_attr.poke_flag = 1;
        else
          gadget_attr.poke_flag = 0;

        FIg_set_state_off (Toggle_form, SM_TOG);
        FIg_set_state_off (Toggle_form, MED_TOG);
        FIg_set_state_off (Toggle_form, LG_TOG);
        FIg_set_state_off (Toggle_form, DRAW_TOG);

        gadget_attr.x_size = i;
      }
      else
      {
        UMSGetByNum (t_str, FB_E_WDGTZERO, 0);
        print_error (Toggle_form, ERR_FLD, t_str);
      }
    break;

  case KEYIN_TOG:

    if ((int)value == 1) /* Use keyin for location */
    {
      FIg_set_state_off (Toggle_form, DRAW_TOG);
      gadget_attr.draw_flag = 0;

      gadget_attr.poke_flag = 0;
      FIg_display (Toggle_form, X_TEXT);
      FIg_display (Toggle_form, Y_TEXT);
      FIg_display (Toggle_form, X_FLD);
      FIg_display (Toggle_form, Y_FLD);

      sprintf(t_str, "%d", gadget_attr.x_pos);
      FIfld_set_text (Toggle_form, X_FLD, 0, 0, t_str, 0);

      sprintf(t_str, "%d", gadget_attr.y_pos);
      FIfld_set_text (Toggle_form, Y_FLD, 0, 0, t_str, 0);

      sprintf(t_str, "%d", gadget_attr.x_size);
      FIfld_set_text (Toggle_form, WD_FLD, 0, 0, t_str, 0);

      sprintf(t_str, "%d", gadget_attr.y_size);
      FIfld_set_text (Toggle_form, HT_FLD, 0, 0, t_str, 0);
    }
    else
    {
      gadget_attr.poke_flag = 1;
      FIg_erase (Toggle_form, X_TEXT);
      FIg_erase (Toggle_form, Y_TEXT);
      FIg_erase (Toggle_form, X_FLD);
      FIg_erase (Toggle_form, Y_FLD);
    }
    break;

  case X_FLD:

    FIfld_get_text (Toggle_form, X_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Toggle_form, ERR_FLD, &status);

    if (status) /* Valid input */
      if (i >= 0)
        gadget_attr.x_pos = i;
      else
      {
        UMSGetByNum (t_str, FB_E_XNOTNEG, 0);
        print_error (Toggle_form, ERR_FLD, t_str);
      }
    break;

  case Y_FLD:

    FIfld_get_text (Toggle_form, Y_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Toggle_form, ERR_FLD, &status);

    if (status) /* Valid input */
      if (i >= 0)
        gadget_attr.y_pos = i;
      else
      {
        UMSGetByNum (t_str, FB_E_YNOTNEG, 0);
        print_error (Toggle_form, ERR_FLD, t_str);
      }
    break;

  case FI_HELP:

    /* Help_topic ("Toggle") */
    break;

  case FI_CANCEL:

    if (command_is_active == EDIT_GADGET)
    {
      if (edit_hilite_flag == 0)
        FIg_unhilite (work_form, old_gadget_label);

      if (edit_display_flag == 0)
        FIg_erase (work_form, old_gadget_label);
    }

    kill_place_toggle();
    FIg_set_state_off (Toggle_form, FI_CANCEL);
    break;

  case FI_ACCEPT:

    FIf_erase (Toggle_form);
    FIg_set_state_off (Toggle_form, FI_ACCEPT);

    if (Symbol_scroll != NULL)
      FIf_erase (Symbol_scroll);

    if (Sym_dir_form != NULL)
      FIf_erase (Sym_dir_form);

    if (Characteristics_form != NULL)
    {
      FIf_erase (FG_color_form);
      FIf_erase (FG2_color_form);
      FIf_erase (Font_form);
      FIg_set_state_off (Characteristics_form, CHAR_FOREGROUND_CLR_BTN);
      FIg_set_state_off (Characteristics_form, CHAR_FOREGROUND2_CLR_BTN);
      FIg_set_state_off (Characteristics_form, CHAR_TEXT_FONT_BTN);

      replace_attr_with_overrides(); /* character.c */
    }

    create_toggle_gadget();

    if (command_is_active == EDIT_GADGET)
      kill_place_toggle();
    else if (Toggle_form != NULL) /* Do this command again */
    {
      FIg_set_state_off (Toggle_form, FI_ACCEPT);

      FIg_get_state (Toggle_form, SELECT_BTN, &state);

      FIf_display (Toggle_form);
      if ((Symbol_scroll != NULL) && (state == 1))
        FIf_display (Symbol_scroll);

      FIg_get_state (Toggle_form, ADD_DIRECTORY_BTN, &state);

      FIf_display (Toggle_form);
      if ((Sym_dir_form != NULL) && (state == 1))
        FIf_display (Sym_dir_form);

      FIf_get_next_label (work_form, &gadget_attr.gadget_label);

      if (Characteristics_form != NULL)
      {
        override_attr.gadget_label = gadget_attr.gadget_label;

        sprintf (t_str, "%d", override_attr.gadget_label);
        FIfld_set_text (Characteristics_form, LABEL_FLD,
            0, 0, t_str, 0);
        FIg_erase (Characteristics_form, 10);
      }

      UMSGetByNum (t_str, FB_P_FILLTOGFRM, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
    }
    break;
  }

  return;
}

/*************************************************************************/
/* */
/* execute_place_toggle() */
/* */
/* This function is called in one of two ways. The first is to be */
/* called by the executive command handler routine. The second is to */
/* be called after a toggle has been successfully placed. */
/* */
/* It displays the place toggle form then exits. After that point */
/* the fi_toggle_form() gadget notification routine will be in */
/* control. That is to say, every time the operator alters a gadget on */
/* the place toggle form, the fi_toggle_form() function will be */
/* invoked. */
/* */
/*************************************************************************/

void execute_place_toggle(void)
{
  char t_str[256];
  int status;

  if (work_form == NULL) /* No form defined */
  {
    strcpy (current_command_string, "None");
    command_is_active = 0;
    return;
  }

  UMSGetByNum (t_str, FB_I_PCETOG, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENDEF, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Toggle_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlTgl");
    status = FIf_new (122, t_str, (int (*)())fi_toggle_form, &Toggle_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  FIg_erase (Toggle_form, 37);
  FIg_erase (Toggle_form, 40);
  FIg_erase (Toggle_form, 29);
  FIg_erase (Toggle_form, 14);
  FIg_erase (Toggle_form, 15);
  FIg_erase (Toggle_form, 19);

  setup_new_toggle_form();
  show_toggle_form_info();

  FIf_display (Toggle_form);

  FIf_get_next_label (work_form, &gadget_attr.gadget_label);

  if (Characteristics_form != NULL)
    Update_characteristics_form();

  UMSGetByNum (t_str, FB_P_FILLTOGFRM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}

/*--------------------------------------------------------------------------*/

void edit_toggle_gadget(void)
{
  char t_str[256];
  int status;

  gadget_attr.gadget_label = old_gadget_label;

  UMSGetByNum (t_str, FB_I_EDTTOG, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENCUR, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Toggle_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlTgl");
    status = FIf_new (122, t_str, (int (*)())fi_toggle_form, &Toggle_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  FIg_erase (Toggle_form, 37);
  FIg_erase (Toggle_form, 40);
  FIg_erase (Toggle_form, 29);
  FIg_erase (Toggle_form, 14);
  FIg_erase (Toggle_form, 15);
  FIg_erase (Toggle_form, 19);

  setup_old_toggle_form();
  show_toggle_form_info();

  FIf_display (Toggle_form);

  if (Characteristics_form != NULL)
  {
    Update_characteristics_form();

    if (gadget_attr.text_gadget == 0)
      FIg_disable (Characteristics_form, CHAR_TEXT_FONT_BTN);
  }

  UMSGetByNum (t_str, FB_P_FILLTOGFRM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}
