/***********************************

		button_gdt.c

***********************************/

/*
  History
	04-28-92	sml		ANSI-ized; cast func args
*/

/*************************************/
/* */
/* This file contains functions for the "place button" and edit button */
/* commands. */
/* */
/* Programmer: Mack Draper */
/* Date: Dec. 6, 1988 */
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
/* used by button form */
/* */
/*************************/

#define DRAW_BTN 58
#define LG_BTN 33
#define MED_BTN 32
#define SM_BTN 31
#define BTN_ERR_FLD 10
#define FONT_FLD 40
#define HT_FLD 49
#define SYM_FLD 57
#define WD_FLD 48
#define X_FLD 46
#define Y_FLD 47
#define KEYIN_TOG 43
#define SYM_TOG 21
#define VALUE_TOG 11
#define FONT_TXT 16
#define TEXT_TXT 14
#define SYM_TXT 15
#define BTN_TEXT_FLD 19
#define X_TXT 25
#define Y_TXT 26

#define AUTO_TOG 41
#define SELECT_BTN 18
#define ADD_DIRECTORY_BTN 30
#define FIT_BTN 34

#define CHAR_FOREGROUND_CLR_BTN 47
#define CHAR_FOREGROUND2_CLR_BTN 48
#define CHAR_TEXT_FONT_BTN 46

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

Form button_form = NULL;

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern struct _FI_sym_st *_FI_symbols;

extern Form work_form;
extern struct dpb_struct dpb;
extern struct dpb_struct temp_dpb;
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
extern int Next_in_sequence;
extern int Next_link;

extern int Edit_sequence_array[100];
extern int Edit_data_link_array[100];
extern int Edit_sequence_count;
extern int Edit_data_link_count;

extern char Global_symbol_file[20];
extern Form Symbol_scroll;
extern Form Sym_dir_form;
extern Display *display;

extern char language[80];

/*************************************************************************/
/* */
/* kill_place_button() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to PLACE_BUTTON indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecteing the point. */
/* */
/*************************************************************************/

void kill_place_button(void)
{
  char t_str[256];

  if (button_form != NULL)
  {
    FIf_erase (button_form);
  }

  if (Characteristics_form != NULL)
  {
    Clear_characteristics_form();
  }

  if (Symbol_scroll != NULL)
  {
    FIf_erase (Symbol_scroll);
  }

  if (Sym_dir_form != NULL)
  {
    FIf_erase (Sym_dir_form);
  }

  FIfld_set_text (Message_form, 11, 0, 0, "", 0);
  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  if (command_is_active == PLACE_BUTTON)
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
/* setup_old_button_form() */
/* */
/*************************************************************************/

static void setup_old_button_form(void)
{
  setup_standard_attr (old_gadget_label);

  if (gadget_attr.text_gadget == 0)
  {
    strcpy (gadget_attr.font_name, dpb.font_name);
  }

  FIbtn_get_auto_pop_up_state (work_form, old_gadget_label,
      &gadget_attr.auto_popup_flag);

  FIg_get_text_style (work_form, old_gadget_label, 
      &gadget_attr.text_style);

  FIg_get_justification (work_form, old_gadget_label,
      &gadget_attr.text_justification);

  gadget_attr.draw_flag = 0;
  gadget_attr.poke_flag = 0;
  gadget_attr.gadget_type = FI_BUTTON;
  gadget_attr.scroll_mode = NO_SCROLLING; /* to allow justification */
}

/*************************************************************************/
/* */
/* setup_new_button_form() */
/* */
/* This function is called each time the operator wishes to place a */
/* new button on the work form. It will fill in default settings for */
/* the button. These will be displayed in the button definition form */
/* when the show_button_info() function is called. */
/* */
/*************************************************************************/

static void setup_new_button_form(void)
{
  Set_new_gadget_defaults();

  gadget_attr.x_pos = 0;
  gadget_attr.x_size = 90;
  gadget_attr.y_size = 60;

  strcpy (gadget_attr.symbol_file, Global_symbol_file);
  strcpy (gadget_attr.off_text, "");

  gadget_attr.draw_flag = 0;
  gadget_attr.poke_flag = 1;
  gadget_attr.text_gadget = 1;
  gadget_attr.off_text[0] = '\0';
  gadget_attr.default_value = 0;
  gadget_attr.auto_popup_flag = 0;
  gadget_attr.scroll_mode = NO_SCROLLING; /* to allow justification */

  gadget_attr.text_justification = FI_CENTER_JUSTIFIED;

  gadget_attr.gadget_type = FI_BUTTON;
  Next_in_sequence = 0;
  Next_link = -1;
}

/*************************************************************************/
/* */
/* show_button_form_info() */
/* */
/* This function displays the information contained in the */
/* current_gadget struct into the button form's gadgets. */
/* */
/*************************************************************************/

static void show_button_form_info(void)
{
  char t_str[256];

  if (gadget_attr.auto_popup_flag == 1)
  {
    FIg_set_state_on (button_form, AUTO_TOG);
  }
  else
  {
    FIg_set_state_off (button_form, AUTO_TOG);
  }

  FIg_set_state_off (button_form, SELECT_BTN);
  FIg_set_state_off (button_form, ADD_DIRECTORY_BTN);

  if (gadget_attr.text_gadget == 1) /* text button */
  {
    FIg_set_state_off (button_form, SYM_TOG);
    FIfld_set_text (button_form, BTN_TEXT_FLD, 0, 0,
        gadget_attr.off_text, 0);

    Break_up_multi_line_string (button_form, BTN_TEXT_FLD,
        gadget_attr.off_text);

    FIg_erase (button_form, SYM_FLD);
    FIg_erase (button_form, SYM_TXT);
    FIg_erase (button_form, FONT_TXT);
    FIg_erase (button_form, FONT_FLD);
    FIg_erase (button_form, SELECT_BTN);
    FIg_erase (button_form, ADD_DIRECTORY_BTN);

    FIg_display (button_form, TEXT_TXT);
    FIg_display (button_form, BTN_TEXT_FLD);
  }
  else /* symbol button */
  {
    FIg_set_state_on (button_form, SYM_TOG);

    FIg_erase (button_form, TEXT_TXT);
    FIg_erase (button_form, BTN_TEXT_FLD);

    FIfld_set_text (button_form, FONT_FLD, 0, 0,
        gadget_attr.symbol_file, 0);

    FIg_display (button_form, FONT_FLD);

    sprintf (t_str, "%d", gadget_attr.off_sym_index);
    FIfld_set_text (button_form, SYM_FLD, 0, 0, t_str, 0);

    FIg_display (button_form, SYM_FLD);
    FIg_display (button_form, SYM_TXT);
    FIg_display (button_form, FONT_TXT);

    FIg_display (button_form, SELECT_BTN);
    FIg_display (button_form, ADD_DIRECTORY_BTN);
  }

  if ((int)gadget_attr.default_value == 0)
  {
    FIg_set_state_off (button_form, VALUE_TOG);
  }
  else
  {
    FIg_set_state_on (button_form, VALUE_TOG);
  }

  sprintf (t_str, "%d", gadget_attr.x_size);
  FIfld_set_text (button_form, WD_FLD, 0, 0, t_str, 0);

  sprintf (t_str, "%d", gadget_attr.y_size);
  FIfld_set_text (button_form, HT_FLD, 0, 0, t_str, 0);

  FIg_set_state_off (button_form, DRAW_BTN);
  FIg_set_state_off (button_form, SM_BTN);
  FIg_set_state_off (button_form, MED_BTN);
  FIg_set_state_off (button_form, LG_BTN);

  if ((gadget_attr.x_size == 45) && (gadget_attr.y_size == 43))
  {
    FIg_set_state_on (button_form, SM_BTN);
  }
  else if ((gadget_attr.x_size == 60) && (gadget_attr.y_size == 50))
  {
    FIg_set_state_on (button_form, MED_BTN);
  }
  else if ((gadget_attr.x_size == 90) && (gadget_attr.y_size == 60))
  {
    FIg_set_state_on (button_form, LG_BTN);
  }

  if (gadget_attr.x_pos != 0)
  {
    sprintf (t_str, "%d", gadget_attr.x_pos);
    FIfld_set_text (button_form, X_FLD, 0, 0, t_str, 0);

    sprintf (t_str, "%d", gadget_attr.y_pos);
    FIfld_set_text (button_form, Y_FLD, 0, 0, t_str, 0);

    FIg_set_state_on (button_form, KEYIN_TOG);

    FIg_display (button_form, X_TXT);
    FIg_display (button_form, Y_TXT);
    FIg_display (button_form, X_FLD);
    FIg_display (button_form, Y_FLD);
  }
  else
  {
    FIg_set_state_off (button_form, KEYIN_TOG);
    FIg_erase (button_form, X_TXT);
    FIg_erase (button_form, Y_TXT);
    FIg_erase (button_form, X_FLD);
    FIg_erase (button_form, Y_FLD);
    FIfld_set_text (button_form, X_FLD, 0, 0, "", 0);
    FIfld_set_text (button_form, Y_FLD, 0, 0, "", 0);
  }
}



/*********************************************************************/
/* */
/* create_button_gadget() */
/* */
/* This function creates a new button gadget and places it at */
/* the position that was poked by the operator. */
/* */
/*********************************************************************/

static void create_button_gadget(void)
{
  int x, y, ii;
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
  /* If the work form and the place button form intersect, */
  /* then send a window update message to the work_form */
  /* */
  /***********************************************************/

  Refresh_work_form();

  if (gadget_attr.draw_flag == 0)
  {
    if (gadget_attr.poke_flag == 1) /* Get datapoint for location */
    {
      UMSGetByNum (t_str, FB_P_POKBUT, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

      status = Get_first_point (window, &gadget_attr.x_pos,
          &gadget_attr.y_pos,
          gadget_attr.x_size,
          gadget_attr.y_size, 0, 0);

      if (status != 2) /* Operator wants to abort place button */
        return;
    }
  }
  else /* Get two datapoints for size and location of button */
  {
    UMSGetByNum (t_str, FB_P_POKBUTANC, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    status = Get_first_point (window, &x, &y, 0, 0, 0, 0);

    if (status == 2) /* Success */
    {
      UMSGetByNum (t_str, FB_I_ANCX, "%d%d", x, y);
      FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);
      UMSGetByNum (t_str, FB_P_POKBUTSWI, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

      status = Get_second_point (window, x, y,
          &gadget_attr.x_pos,
          &gadget_attr.y_pos,
          &gadget_attr.x_size,
          &gadget_attr.y_size, 0, -1);

      FIfld_set_text (Message_form, 22, 0, 0, "", 0);

      if (status == 2) /* Success */
      {
        gadget_attr.x_size -= gadget_attr.x_pos;
        gadget_attr.y_size -= gadget_attr.y_pos;
      }
      else
        return;
    }
    else /* Operator wants to abort the place operation */
      return;
  }

  if (gadget_attr.text_gadget == 0)
  {
    strcpy (gadget_attr.default_str, gadget_attr.font_name);
    strcpy (gadget_attr.font_name, gadget_attr.symbol_file);
  }
  else /* text gadget */
  {
    Form_multi_line_string (button_form, BTN_TEXT_FLD, gadget_attr.off_text);
  }

  x = gadget_attr.x_size;
  y = gadget_attr.y_size;
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

  Create_and_init_gadget (work_form, FI_BUTTON, gadget_attr.gadget_label);

  if (gadget_attr.text_gadget == 1)
  {
    FIg_set_text_style (work_form, gadget_attr.gadget_label,
        gadget_attr.text_style);

    FIg_set_justification (work_form, gadget_attr.gadget_label,
        gadget_attr.text_justification);
  }
  else
  {
    FIg_set_justification (work_form, gadget_attr.gadget_label,
        FI_CENTER_JUSTIFIED);
  }

  if (gadget_attr.auto_popup_flag == 1)
    FIbtn_set_auto_pop_up_on (work_form, gadget_attr.gadget_label);
  else
    FIbtn_set_auto_pop_up_off (work_form, gadget_attr.gadget_label);

  FIg_activate (work_form, gadget_attr.gadget_label);

  FIg_set_next_in_seq (work_form, gadget_attr.gadget_label, Next_in_sequence);
  FIg_set_pass_data (work_form, gadget_attr.gadget_label, Next_link);

  for (ii = 0; ii < Edit_sequence_count; ii++)
  {
    FIg_set_next_in_seq (work_form, Edit_sequence_array[ii],
        gadget_attr.gadget_label);
  }

  for (ii = 0; ii < Edit_data_link_count; ii++)
  {
    FIg_set_pass_data (work_form, Edit_data_link_array[ii],
        gadget_attr.gadget_label);
  }

  if (gadget_attr.display == 1)
  {
    FIg_display (work_form, gadget_attr.gadget_label);
  }

  if (group_label != 0)
  {
    FIg_add_to_group (work_form, gadget_attr.gadget_label, group_label);
  }

  gadget_attr.x_size = x;
  gadget_attr.y_size = y;

  if (gadget_attr.text_gadget == 0)
  {
    strcpy (gadget_attr.font_name, gadget_attr.default_str);
  }
}

/*-----------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* fi_button_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the default */
/* settings for a new button gadget, or alter the settings of an */
/* existing button gadget. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_button_form (int form_label,
                    int gadget_label,
                    double value,
                    Form form_ptr)
{
  int num_flag, i, j;
  char sym_name[200];
  int sym_value;
  int status;
  int state, height, width;
  char t_str[256];
  int dummy_int;

  FIg_erase (button_form, BTN_ERR_FLD);

  switch (gadget_label)
  {
  case FIT_BTN:

    gadget_attr.draw_flag = 0;
    FIg_get_state (button_form, KEYIN_TOG, &state);
    if (state == 0)
      gadget_attr.poke_flag = 1;
    else
      gadget_attr.poke_flag = 0;
    FIg_set_state_off (button_form, FIT_BTN);

    if (gadget_attr.text_gadget == 1)
    {
      Form_multi_line_string (button_form, BTN_TEXT_FLD, gadget_attr.off_text);

      Calculate_text_size (gadget_attr.off_text, temp_dpb.font_name,
          temp_dpb.bodysize, &width, &height);

      if (height < 20)
        height = 20;

      if (width < 20)
        width = 20;
    }
    else /* button uses a symbol */
    {
      char path[200];
      Font  symbol_id;

      status = _FI_find_symbol_path_and_id (path, gadget_attr.symbol_file, (int *)&symbol_id);
      if (status == FI_SUCCESS)
      {
        width =
            _FI_symbols[symbol_id].sym_slot[gadget_attr.off_sym_index].sym_width;
        height =
            _FI_symbols[symbol_id].sym_slot[gadget_attr.off_sym_index].sym_height;
      }
      else
      {
        width = 1;
        height = 1;
      }

      if (height < 20)
        height = 20;

      if (width < 20)
        width = 20;
    }
    height += 15;
    width += 15;

    FIg_set_state_off (button_form, SM_BTN);
    FIg_set_state_off (button_form, MED_BTN);
    FIg_set_state_off (button_form, LG_BTN);
    FIg_set_state_off (button_form, DRAW_BTN);

    gadget_attr.y_size = height;
    gadget_attr.x_size = width;
    sprintf (t_str, "%d", height);
    FIg_set_text (button_form, HT_FLD, t_str);
    sprintf (t_str, "%d", width);
    FIg_set_text (button_form, WD_FLD, t_str);
    break;

  case ADD_DIRECTORY_BTN:

    if ((int)value == 1)
      Display_symbol_dir_form();
    else
      FIf_erase (Sym_dir_form);
    break;

  case AUTO_TOG:

    gadget_attr.auto_popup_flag = (int)value;
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

      Init_scroll_area (gadget_attr.symbol_file,
          gadget_attr.off_sym_index);
      FIf_display (Symbol_scroll);
    }
    else
    {
      if (Symbol_scroll != NULL)
        FIf_erase (Symbol_scroll);
    }
    break;

  case SYM_TOG:

    if ((int)value == 0)
    {
      if (Symbol_scroll != NULL)
        FIf_erase (Symbol_scroll);

      if (Sym_dir_form != NULL)
        FIf_erase (Sym_dir_form);

      gadget_attr.text_gadget = 1; /* text button */

      if (Characteristics_form != NULL)
      {
        FIg_set_state_off (Characteristics_form, CHAR_TEXT_FONT_BTN);
        FIg_enable (Characteristics_form, CHAR_TEXT_FONT_BTN);
      }

      FIfld_set_text (button_form, FONT_FLD, 0, 0,
          gadget_attr.off_text, 0);

      FIg_erase (button_form, SELECT_BTN);
      FIg_set_state_off (button_form, SELECT_BTN);
      FIg_erase (button_form, ADD_DIRECTORY_BTN);
      FIg_set_state_off (button_form, ADD_DIRECTORY_BTN);
      FIg_erase (button_form, SYM_FLD);
      FIg_erase (button_form, SYM_TXT);
      FIg_erase (button_form, FONT_TXT);
      FIg_erase (button_form, 40);

      FIg_display (button_form, TEXT_TXT);
      FIg_display (button_form, BTN_TEXT_FLD);
    }
    else
    {
      gadget_attr.text_gadget = 0; /* symbol button */

      if (Characteristics_form != NULL)
      {
        FIf_erase (Font_form);
        FIg_set_state_off (Characteristics_form, CHAR_TEXT_FONT_BTN);
        FIg_disable (Characteristics_form, CHAR_TEXT_FONT_BTN);
      }

      FIg_erase (button_form, TEXT_TXT);
      FIg_erase (button_form, BTN_TEXT_FLD);

      FIfld_set_text (button_form, FONT_FLD, 0, 0,
          gadget_attr.symbol_file, 0);

      FIg_display (button_form, FONT_FLD);

      sprintf (t_str, "%d", gadget_attr.off_sym_index);
      FIfld_set_text (button_form, SYM_FLD, 0, 0,
          t_str, 0);

      FIg_display (button_form, SYM_FLD);
      FIg_display (button_form, SYM_TXT);
      FIg_display (button_form, FONT_TXT);
      FIg_display (button_form, SELECT_BTN);
      FIg_display (button_form, ADD_DIRECTORY_BTN);
      FIg_display (button_form, 40);
    }
    break;

  case VALUE_TOG:

    gadget_attr.default_value = value;
    break;

  case BTN_TEXT_FLD:

    FIfld_get_text (button_form, BTN_TEXT_FLD, 0, 0, 255, (unsigned char *)t_str,
        &dummy_int, &dummy_int);

    strcpy (gadget_attr.off_text, t_str);
    strcpy (gadget_attr.on_text, t_str);
    break;

  case FONT_FLD:

    FIfld_get_text (button_form, FONT_FLD, 0, 0, 255, (unsigned char *)t_str,
        &dummy_int, &dummy_int);

    strcpy (gadget_attr.symbol_file, t_str);
    strcpy (Global_symbol_file, t_str);
    if (Symbol_scroll != NULL)
      Set_scroll_symbol_file (t_str);
    break;

  case SYM_FLD:

    num_flag = 1;
    i = 0; 
    j = 0;

    FIfld_get_text(button_form, SYM_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    if ((t_str[0] == '\'') || (t_str[0] == '\\'))
    {
      i = 1;
      if (t_str[1] == '\\')
        i = 2;
    }
    while ((t_str[i] != '\0') && num_flag != 0)
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
      i++;
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

      if ((sym_value < 0) || (sym_value > 255))
      {
        UMSGetByNum (t_str, FB_E_RANGE255, 0);
        print_error (button_form, BTN_ERR_FLD, t_str);
      }
      else
      {
        gadget_attr.on_sym_index = sym_value;
        gadget_attr.off_sym_index = sym_value;

        if (Symbol_scroll != NULL)
          Set_scroll_view_area (sym_value);
      }
    }
    else
    {
      UMSGetByNum (t_str, FB_E_INVALIDSYM, 0);
      print_error (button_form, BTN_ERR_FLD, t_str);
    }
    break;

  case SM_BTN:

    gadget_attr.draw_flag = 0;

    FIg_get_state (button_form, KEYIN_TOG, &state);
    if (state == 0)
      gadget_attr.poke_flag = 1;
    else
      gadget_attr.poke_flag = 0;

    FIg_set_state_on (button_form, SM_BTN);
    FIg_set_state_off (button_form, MED_BTN);
    FIg_set_state_off (button_form, LG_BTN);
    FIg_set_state_off (button_form, DRAW_BTN);

    gadget_attr.x_size = 45;
    sprintf (t_str, "%d", gadget_attr.x_size);
    FIfld_set_text (button_form, WD_FLD, 0, 0, t_str, 0);

    gadget_attr.y_size = 43;
    sprintf (t_str, "%d", gadget_attr.y_size);
    FIfld_set_text (button_form, HT_FLD, 0, 0, t_str, 0);

    break;

  case MED_BTN:

    gadget_attr.draw_flag = 0;

    FIg_get_state (button_form, KEYIN_TOG, &state);
    if (state == 0)
      gadget_attr.poke_flag = 1;
    else
      gadget_attr.poke_flag = 0;

    FIg_set_state_off (button_form, SM_BTN);
    FIg_set_state_on (button_form, MED_BTN);
    FIg_set_state_off (button_form, LG_BTN);
    FIg_set_state_off (button_form, DRAW_BTN);

    gadget_attr.x_size = 60;
    sprintf (t_str, "%d", gadget_attr.x_size);
    FIfld_set_text (button_form, WD_FLD, 0, 0, t_str, 0);

    gadget_attr.y_size = 50;
    sprintf (t_str, "%d", gadget_attr.y_size);
    FIfld_set_text (button_form, HT_FLD, 0, 0, t_str, 0);

    break;

  case LG_BTN:

    gadget_attr.draw_flag = 0;

    FIg_get_state (button_form, KEYIN_TOG, &state);
    if (state == 0)
      gadget_attr.poke_flag = 1;
    else
      gadget_attr.poke_flag = 0;

    FIg_set_state_off (button_form, SM_BTN);
    FIg_set_state_off (button_form, MED_BTN);
    FIg_set_state_on (button_form, LG_BTN);
    FIg_set_state_off (button_form, DRAW_BTN);

    gadget_attr.x_size = 90;
    sprintf (t_str, "%d", gadget_attr.x_size);
    FIfld_set_text (button_form, WD_FLD, 0, 0, t_str, 0);

    gadget_attr.y_size = 60;
    sprintf (t_str, "%d", gadget_attr.y_size);
    FIfld_set_text (button_form, HT_FLD, 0, 0, t_str, 0);

    break;

  case DRAW_BTN:

    gadget_attr.draw_flag = 1;
    gadget_attr.poke_flag = 0;

    FIg_set_state_off (button_form, SM_BTN);
    FIg_set_state_off (button_form, MED_BTN);
    FIg_set_state_off (button_form, LG_BTN);
    FIg_set_state_on (button_form, DRAW_BTN);

    FIg_set_state_off (button_form, KEYIN_TOG);
    FIg_erase (button_form, X_TXT);
    FIg_erase (button_form, Y_TXT);
    FIg_erase (button_form, X_FLD);
    FIg_erase (button_form, Y_FLD);

    FIfld_set_text (button_form, WD_FLD, 0, 0, " ", 0);
    FIfld_set_text (button_form, HT_FLD, 0, 0, " ", 0);
    break;

  case HT_FLD:

    FIfld_get_text (button_form, HT_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, button_form,
        BTN_ERR_FLD, &status);
    if (status)
      if (i > 0) /* Valid input */
      {
        gadget_attr.draw_flag = 0;

        FIg_get_state (button_form, KEYIN_TOG, &state);
        if (state == 0)
          gadget_attr.poke_flag = 1;
        else
          gadget_attr.poke_flag = 0;

        FIg_set_state_off (button_form, SM_BTN);
        FIg_set_state_off (button_form, MED_BTN);
        FIg_set_state_off (button_form, LG_BTN);
        FIg_set_state_off (button_form, DRAW_BTN);

        gadget_attr.y_size = i;
      }
      else
      {
        UMSGetByNum (t_str, FB_E_HTGTZERO, 0);
        print_error (button_form, BTN_ERR_FLD, t_str);
      }
    break;

  case WD_FLD:

    FIfld_get_text (button_form, WD_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, button_form,
        BTN_ERR_FLD, &status);

    if (status)
      if (i > 0) /* Valid input */
      {
        gadget_attr.draw_flag = 0;

        FIg_get_state (button_form, KEYIN_TOG, &state);
        if (state == 0)
          gadget_attr.poke_flag = 1;
        else
          gadget_attr.poke_flag = 0;

        FIg_set_state_off (button_form, SM_BTN);
        FIg_set_state_off (button_form, MED_BTN);
        FIg_set_state_off (button_form, LG_BTN);
        FIg_set_state_off (button_form, DRAW_BTN);

        gadget_attr.x_size = i;
      }
      else
      {
        UMSGetByNum (t_str, FB_E_WDGTZERO, 0);
        print_error (button_form, BTN_ERR_FLD, t_str);
      }
    break;

  case KEYIN_TOG:

    if ((int)value == 1) /* Use keyin for location */
    {
      FIg_set_state_off (button_form, DRAW_BTN);
      gadget_attr.draw_flag = 0;

      gadget_attr.poke_flag = 0;
      FIg_display (button_form, X_TXT);
      FIg_display (button_form, Y_TXT);
      FIg_display (button_form, X_FLD);
      FIg_display (button_form, Y_FLD);

      sprintf(t_str, "%d", gadget_attr.x_pos);
      FIfld_set_text (button_form, X_FLD, 0, 0, t_str, 0);

      sprintf(t_str, "%d", gadget_attr.y_pos);
      FIfld_set_text (button_form, Y_FLD, 0, 0, t_str, 0);

      sprintf (t_str, "%d", gadget_attr.x_size);
      FIfld_set_text (button_form, WD_FLD, 0, 0, t_str, 0);

      sprintf (t_str, "%d", gadget_attr.y_size);
      FIfld_set_text (button_form, HT_FLD, 0, 0, t_str, 0);
    }
    else
    {
      gadget_attr.poke_flag = 1;
      FIg_erase (button_form, X_TXT);
      FIg_erase (button_form, Y_TXT);
      FIg_erase (button_form, X_FLD);
      FIg_erase (button_form, Y_FLD);
    }

    break;

  case X_FLD:

    FIfld_get_text (button_form, X_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, button_form,
        BTN_ERR_FLD, &status);

    if (status) /* Valid input */
      if (i >= 0)
        gadget_attr.x_pos = i;
      else
      {
        UMSGetByNum (t_str, FB_E_XNOTNEG, 0);
        print_error (button_form, BTN_ERR_FLD, t_str);
      }
    break;

  case Y_FLD:

    FIfld_get_text (button_form, Y_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, button_form,
        BTN_ERR_FLD, &status);

    if (status) /* Valid input */
      if (i >= 0)
        gadget_attr.y_pos = i;
      else
      {
        UMSGetByNum (t_str, FB_E_YNOTNEG, 0);
        print_error (button_form, BTN_ERR_FLD, t_str);
      }
    break;

  case FI_HELP:

    /* Help_topic ("Button") */
    break;

  case FI_CANCEL:

    if (command_is_active == EDIT_GADGET)
    {
      if (edit_hilite_flag == 0)
        FIg_unhilite (work_form, old_gadget_label);

      if (edit_display_flag == 0)
        FIg_erase (work_form, old_gadget_label);
    }

    kill_place_button();
    FIg_set_state_off (button_form, FI_CANCEL);
    break;

  case FI_ACCEPT:

    FIf_erase (button_form);

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
      FIg_set_state_off (Characteristics_form,CHAR_FOREGROUND2_CLR_BTN);
      FIg_set_state_off (Characteristics_form, CHAR_TEXT_FONT_BTN);

      replace_attr_with_overrides(); /* character.c */
    }

    create_button_gadget();

    FIg_set_state_off (button_form, FI_ACCEPT);

    if (command_is_active == EDIT_GADGET)
      kill_place_button();
    else if (button_form != NULL) /* Do this command again */
    {
      FIf_display (button_form);

      FIg_get_state (button_form, SELECT_BTN, &state);

      if ((Symbol_scroll != NULL) && (state == 1))
        FIf_display (Symbol_scroll);

      FIg_get_state (button_form, ADD_DIRECTORY_BTN, &state);

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

      UMSGetByNum (t_str, FB_E_FILLBUT, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
    }
    break;
  }
  return;
}

/*************************************************************************/
/* */
/* execute_place_button() */
/* */
/* This function is called in one of three ways. The first is to be */
/* called by the executive command handler routine. The second is to */
/* be called after a button has been successfully placed. The third is */
/* to be called after a button palette has been successfully placed. */
/* */
/* It displays the button_type form then exits. After that point */
/* the fi_button_type_form() gadget notification routine will be in */
/* control. That is, every time the operator alters a gadget on */
/* the button type form, the fi_button_type_form() function will be */
/* invoked. */
/* */
/*************************************************************************/

void execute_place_button(void)
{
  char t_str[256];
  int status;

  if (work_form == NULL) /* No form defined */
  {
    strcpy (current_command_string, "None");
    command_is_active = 0;
    return;
  }

  UMSGetByNum (t_str, FB_I_PLABTN, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENDEF, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (button_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlBtn");
    status = FIf_new (F_button, t_str, (int (*)())fi_button_form, &button_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  setup_new_button_form();
  show_button_form_info();

  FIf_display (button_form);

  FIf_get_next_label (work_form, &gadget_attr.gadget_label);

  if (Characteristics_form != NULL)
  {
    Update_characteristics_form();
  }

  UMSGetByNum (t_str, FB_E_FILLBUT, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}

/*-------------------------------------------------------------------------*/

void edit_button_gadget(void)
{
  char t_str[256];
  int status;

  gadget_attr.gadget_label = old_gadget_label;

  UMSGetByNum (t_str, FB_I_EDBTN, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENCUR, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (button_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlBtn");
    status = FIf_new (F_button, t_str, (int (*)())fi_button_form, &button_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  setup_old_button_form();
  show_button_form_info();

  FIf_display (button_form);

  if (Characteristics_form != NULL)
  {
    Update_characteristics_form();

    if (gadget_attr.text_gadget == 0)
    {
      FIg_disable (Characteristics_form, CHAR_TEXT_FONT_BTN);
    }
  }

  UMSGetByNum (t_str, FB_E_FILLBUT, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}
