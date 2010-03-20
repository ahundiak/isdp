/***********************************

		cklist_gdt.c

***********************************/

/*
  History
	04-28-92	sml		ANSI-ized; casted func args; changed local vars
*/

/*************************************/
/* */
/* This file contains functions for the "place cklist" and "edit cklist" */
/* commands. */
/* */
/* Programmer: Mack Draper */
/* Date: Dec. 20, 1988 */
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
#define TYPEFACE_LIST_FLD 22

/****************************/
/* */
/* Used by checklist form */
/* */
/****************************/

#define ERR_FLD 10

#define STRING_FLD 14

#define KEYIN_TOG 12
#define SELECTED_TOG 15

#define X_FLD 33
#define Y_FLD 55
#define X_TXT 49
#define Y_TXT 51

#define SYM_SELECT_BTN 13
#define CKLIST_TYPE_TOG 11
#define STRING_TEXT 17

#define SYMBOL_FILE_TEXT 19
#define INDEX_TEXT 21
#define SYMBOL_FILE_FLD 20
#define INDEX_FLD 22

#define ADD_DIRECTORY_BTN 25

#define CHAR_FOREGROUND_CLR_BTN 47
#define CHAR_FOREGROUND2_CLR_BTN 48
#define CHAR_TEXT_FONT_BTN 46

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

Form cklist_form = NULL;
int loop_count;
int top_point_y;
int bottom_point_y;

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
extern struct gadget_struct override_attr;
extern char execute_dir[200];

extern Form Characteristics_form;
extern Form FG_color_form;
extern Form FG2_color_form;
extern Form Sym_dir_form;
extern Form Message_form;
extern edit_hilite_flag;
extern edit_display_flag;
extern int old_gadget_label;
extern int Next_in_sequence;
extern int Next_link;

extern int Edit_sequence_array[100];
extern int Edit_data_link_array[100];
extern int Edit_sequence_count;
extern int Edit_data_link_count;

extern char Global_symbol_file[20];
extern Form Symbol_scroll;

extern char language[80];
extern Display *display;

extern int font_count;
extern Form Font_form;
extern Font Font_array[200];

/*************************************************************************/
/* */
/* kill_place_cklist() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to PLACE_CKLIST indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has pressed the reset mouse button instead of */
/* selecteing the point. */
/* */
/*************************************************************************/

void kill_place_cklist(void)
{
  char t_str[256];

  if (cklist_form != NULL)
    FIf_erase (cklist_form);

  if (Characteristics_form != NULL)
    Clear_characteristics_form();

  if (Symbol_scroll != NULL)
    FIf_erase (Symbol_scroll);

  if (Sym_dir_form != NULL)
    FIf_erase (Sym_dir_form);

  FIfld_set_text (Message_form, 11, 0, 0, "", 0);
  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  if (command_is_active == PLACE_CHECKLIST)
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
/* setup_old_cklist_form() */
/* */
/*************************************************************************/

static void setup_old_cklist_form(void)
{
  int state;

  setup_standard_attr (old_gadget_label);

  if (gadget_attr.text_gadget == 0)
  {
    strcpy (gadget_attr.font_name, dpb.font_name);
  }

  FIg_get_text_style (work_form, old_gadget_label,
      &gadget_attr.text_style);

  FIg_get_state (work_form, old_gadget_label, &state);

  FIg_get_justification (work_form, old_gadget_label,
      &gadget_attr.text_justification);

  if (state == 1)
    gadget_attr.default_value = 1;
  else
    gadget_attr.default_value = 0;

  gadget_attr.scroll_mode = NO_SCROLLING; /* To allow justification */

  gadget_attr.draw_flag = 0;
  gadget_attr.poke_flag = 0;
  loop_count = 1;

  gadget_attr.gadget_type = FI_CHECKLIST;
}

/*************************************************************************/
/* */
/* setup_new_cklist_form() */
/* */
/* This function is called each time the operator wishes to place a */
/* new cklist on the work form. It will fill in default settings for */
/* the cklist. These will be displayed in the cklist definition form */
/* when the show_cklist_info() function is called. */
/* */
/*************************************************************************/

static void setup_new_cklist_form(void)
{
  Set_new_gadget_defaults();

  strcpy (gadget_attr.symbol_file, Global_symbol_file);

  gadget_attr.default_value = 0;
  gadget_attr.x_pos = 0;
  gadget_attr.draw_flag = 0;
  gadget_attr.poke_flag = 1;
  gadget_attr.off_text[0] = '\0';
  gadget_attr.text_gadget = 1;
  gadget_attr.scroll_mode = NO_SCROLLING; /* To allow justification */

  gadget_attr.text_justification = FI_LEFT_JUSTIFIED;

  gadget_attr.gadget_type = FI_CHECKLIST;
  Next_in_sequence = 0;
  Next_link = -1;
}

/*************************************************************************/
/* */
/* show_cklist_form_info() */
/* */
/* This function displays the information contained in the */
/* current_gadget struct into the cklist form's gadgets. */
/* */
/*************************************************************************/

static void show_cklist_form_info(void)
{
  char t_str[256];

  FIg_erase (cklist_form, 10);
  FIg_set_state_off (cklist_form, SYM_SELECT_BTN);
  FIg_set_state_off (cklist_form, ADD_DIRECTORY_BTN);

  if (gadget_attr.text_gadget == 1)
  {
    FIg_set_state_off (cklist_form, CKLIST_TYPE_TOG);

    FIg_erase (cklist_form, SYM_SELECT_BTN);
    FIg_erase (cklist_form, SYMBOL_FILE_TEXT);
    FIg_erase (cklist_form, INDEX_TEXT);
    FIg_erase (cklist_form, SYMBOL_FILE_FLD);
    FIg_erase (cklist_form, INDEX_FLD);
    FIg_erase (cklist_form, ADD_DIRECTORY_BTN);

    FIg_display (cklist_form, STRING_TEXT);
    FIg_display (cklist_form, STRING_FLD);
  }
  else
  {
    FIg_set_state_on (cklist_form, CKLIST_TYPE_TOG);

    FIg_erase (cklist_form, STRING_TEXT);
    FIg_erase (cklist_form, STRING_FLD);

    FIfld_set_text (cklist_form, SYMBOL_FILE_FLD, 0, 0,
        gadget_attr.symbol_file, 0);

    sprintf (t_str, "%d", gadget_attr.off_sym_index);
    FIfld_set_text (cklist_form, INDEX_FLD, 0, 0, t_str, 0);

    FIg_display (cklist_form, SYM_SELECT_BTN);
    FIg_display (cklist_form, SYMBOL_FILE_TEXT);
    FIg_display (cklist_form, INDEX_TEXT);
    FIg_display (cklist_form, SYMBOL_FILE_FLD);
    FIg_display (cklist_form, INDEX_FLD);
    FIg_display (cklist_form, ADD_DIRECTORY_BTN);
  }

  if ((int)gadget_attr.default_value == 0)
  {
    FIg_set_state_off (cklist_form, SELECTED_TOG);
  }
  else
    FIg_set_state_on (cklist_form, SELECTED_TOG);

  Break_up_multi_line_string (cklist_form, STRING_FLD, gadget_attr.off_text);

  if (gadget_attr.poke_flag == 0)
  {
    sprintf (t_str, "%d", gadget_attr.x_pos);
    FIfld_set_text (cklist_form, X_FLD, 0, 0, t_str, 0);

    sprintf (t_str, "%d", gadget_attr.y_pos);
    FIfld_set_text (cklist_form, Y_FLD, 0, 0, t_str, 0);

    FIg_display (cklist_form, X_TXT);
    FIg_display (cklist_form, Y_TXT);
    FIg_display (cklist_form, X_FLD);
    FIg_display (cklist_form, Y_FLD);

    FIg_set_state_on (cklist_form, KEYIN_TOG);
  }
  else
  {
    FIg_set_state_off (cklist_form, KEYIN_TOG);
    FIfld_set_text (cklist_form, X_FLD, 0, 0, "", 0);
    FIfld_set_text (cklist_form, Y_FLD, 0, 0, "", 0);

    FIg_erase (cklist_form, X_TXT);
    FIg_erase (cklist_form, Y_TXT);
    FIg_erase (cklist_form, X_FLD);
    FIg_erase (cklist_form, Y_FLD);
  }
}



/*********************************************************************/
/* */
/* create_cklist_gadget() */
/* */
/* This function creates a new cklist gadget and places it at */
/* the position that was poked by the operator. */
/* */
/*********************************************************************/

static void create_cklist_gadget(void)
{
  int x;
  char t_str[256];
  int temp_x, temp_y;
  int width, height;
  int group_label;
  int status;

  Window window;

  
  /***********************************************************/
  /* */
  /* If the work form and the place cklist form intersect, */
  /* then send a window update message to the work_form. */
  /* */
  /***********************************************************/

  Refresh_work_form();

  if (gadget_attr.text_gadget == 0)
  {
    strcpy (gadget_attr.default_str, gadget_attr.font_name);
    strcpy (gadget_attr.font_name, gadget_attr.symbol_file);
  }

  if (gadget_attr.text_gadget == 1)
  {
    Form_multi_line_string (cklist_form, STRING_FLD,
        gadget_attr.off_text);

    Calculate_text_size (gadget_attr.off_text, gadget_attr.font_name,
        gadget_attr.bodysize, &width, &height);

    if (height < 20)
      height = 20;

  }
  else /* Checklist is a symbol */
  {
    char path[256];
    Font symbol_id;

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
  }

  if (loop_count == 1)
  {
    if (gadget_attr.poke_flag == 0)
    {
    }
    else /* Get datapoint for button gadget location */
    {
      UMSGetByNum (t_str, FB_P_POKCKLST, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

      FIf_get_window (work_form, &window);

      status = Get_first_point (window, &gadget_attr.x_pos,
          &gadget_attr.y_pos,
          28 + width, height,
          0, 0);
      if (height > 20)
        gadget_attr.y_pos += ((height - 20) / 2);

      if (status == 2) /* Success */
      {
        FIg_erase (cklist_form, X_FLD);
        FIg_erase (cklist_form, Y_FLD);
        FIg_erase (cklist_form, X_TXT);
        FIg_erase (cklist_form, Y_TXT);
        FIg_set_state_off (cklist_form, KEYIN_TOG);
      }
      else /* Operator wants to abort the place operation */
      {
        loop_count = 0;
        return;
      }
    }

    if (height <= 20)
    {
      top_point_y = gadget_attr.y_pos;
      bottom_point_y = gadget_attr.y_pos + 20;
    }
    else
    {
      top_point_y = gadget_attr.y_pos - ((height - 20) / 2);
      bottom_point_y = gadget_attr.y_pos + 20 + ((height - 20) / 2);
    }
  }
  else /* on second & later iterations ask for high/low point */
  {
    UMSGetByNum (t_str, FB_P_POKABVBLW, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    FIf_get_window (work_form, &window);
    status = Poke_plain_point (window, &temp_x, &temp_y);

    if (status == 2) /* Success */
    {
      if (temp_y < top_point_y) /* Add to top of list */
      {
        int x, new_top_point;

        x = top_point_y - 10;
        new_top_point = x - height;

        if (height <= 20)
          gadget_attr.y_pos = new_top_point;
        else
          gadget_attr.y_pos = new_top_point + ((height - 20) / 2);

        top_point_y = new_top_point;
      }
      else /* Add to bottom of list */
      {
        int x, new_bottom_point;

        x = bottom_point_y + 10;
        new_bottom_point = x + height;

        if (height <= 20)
          gadget_attr.y_pos = x;
        else
          gadget_attr.y_pos = x + ((height - 20) / 2);

        bottom_point_y = new_bottom_point;
      }
    }
    else /* Operator wants to abort the placement */
    {
      loop_count--;
      return;
    }
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

  gadget_attr.x_size = gadget_attr.x_pos + width + 28;
  gadget_attr.y_size = gadget_attr.y_pos + height;

  Create_and_init_gadget (work_form, FI_CHECKLIST,
      gadget_attr.gadget_label);

  if (group_label != 0)
    FIg_add_to_group (work_form, gadget_attr.gadget_label, group_label);

  FIg_set_text_style (work_form, gadget_attr.gadget_label,
      gadget_attr.text_style);

  FIg_set_justification (work_form, gadget_attr.gadget_label,
      gadget_attr.text_justification);

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
  if (gadget_attr.text_gadget == 0)
    strcpy (gadget_attr.font_name, gadget_attr.default_str);
}



/*************************************************************************/
/* */
/* fi_cklist_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the default */
/* settings for a new cklist gadget, or alter the settings of an */
/* existing cklist gadget. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_cklist_form (int form_label,
                    int gadget_label,
                    double value,
                    Form form_ptr)
{
  char t_str[256];
  int i;
  int status, state;
  int dummy_int;

  FIg_erase (cklist_form, ERR_FLD);

  switch (gadget_label)
  {
  case ADD_DIRECTORY_BTN:

    if ((int)value == 1)
      Display_symbol_dir_form();
    else
      FIf_erase (Sym_dir_form);
    break;

  case CKLIST_TYPE_TOG:

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

      FIg_erase (cklist_form, SYM_SELECT_BTN);
      FIg_set_state_off (cklist_form, SYM_SELECT_BTN);
      FIg_erase (cklist_form, ADD_DIRECTORY_BTN);
      FIg_set_state_off (cklist_form, ADD_DIRECTORY_BTN);

      FIg_erase (cklist_form, SYMBOL_FILE_TEXT);
      FIg_erase (cklist_form, INDEX_TEXT);
      FIg_erase (cklist_form, SYMBOL_FILE_FLD);
      FIg_erase (cklist_form, INDEX_FLD);

      FIg_display (cklist_form, STRING_TEXT);
      FIg_display (cklist_form, STRING_FLD);
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

      FIg_erase (cklist_form, STRING_TEXT);
      FIg_erase (cklist_form, STRING_FLD);

      FIfld_set_text (cklist_form, SYMBOL_FILE_FLD, 0, 0,
          gadget_attr.symbol_file, 0);

      sprintf (t_str, "%d", gadget_attr.off_sym_index);
      FIfld_set_text (cklist_form, INDEX_FLD, 0, 0, t_str, 0);

      FIg_display (cklist_form, SYMBOL_FILE_FLD);
      FIg_display (cklist_form, SYMBOL_FILE_TEXT);
      FIg_display (cklist_form, INDEX_TEXT);
      FIg_display (cklist_form, INDEX_FLD);
      FIg_display (cklist_form, SYM_SELECT_BTN);
      FIg_display (cklist_form, ADD_DIRECTORY_BTN);
    }
    break;

  case SYM_SELECT_BTN:

    if ((int)value == 1)
    {
      strcpy (t_str, execute_dir);
      strcat (t_str, "/config/");
      strcat (t_str, language);
      strcat (t_str, "/forms/FBSymSel");
      status = FIf_new (444, t_str, (int (*)())fi_symbol_scroll, &Symbol_scroll);

      if (status != FI_SUCCESS)
        Report_fatal_form_error (status, t_str);

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

  case SYMBOL_FILE_FLD:

    {
      FIfld_get_text (cklist_form, SYMBOL_FILE_FLD, 0, 0, 255,
          (unsigned char *)t_str, &dummy_int, &dummy_int);

      strcpy (gadget_attr.symbol_file, t_str);
      strcpy (Global_symbol_file, t_str);

      if (Symbol_scroll != NULL)
        Set_scroll_symbol_file (t_str);
      /*
else
{
UMSGetByNum (t_str, FB_E_SYMFILNOTFND, 0);
print_error (cklist_form, ERR_FLD, t_str);
}
*/
    }
    break;

  case INDEX_FLD:

    {
      int num_flag, i, j;
      char sym_name[256];
      int sym_value;

      num_flag = 1;
      i = 0; 
      j = 0;

      FIfld_get_text(cklist_form, INDEX_FLD, 0, 0, 255,
          (unsigned char *)t_str, &dummy_int, &dummy_int);

      if ((t_str[0] == '\'') || (t_str[0] == '\\'))
      {
        i = 1;
        if (t_str[1] == '\\')
          i = 2;
      }

      while ((t_str[i] != '\0') && (num_flag))
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
        if (( t_str[0] == '\'' ) || ( t_str[0] == '\\'))
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
          print_error (cklist_form, ERR_FLD, t_str);
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
        print_error (cklist_form, ERR_FLD, t_str);
      }
    }
    break;

  case SELECTED_TOG:

    gadget_attr.default_value = value;
    break;

  case STRING_FLD:

    FIfld_get_text (cklist_form, STRING_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    strcpy (gadget_attr.off_text, t_str);
    strcpy (gadget_attr.on_text, t_str);
    break;

  case KEYIN_TOG:

    if ((int)value == 1) /* Use keyin for location */
    {
      if (loop_count > 1)
      {
        UMSGetByNum (t_str, FB_E_DTPTREQ, 0);
        print_error (cklist_form, ERR_FLD, t_str);
        FIg_set_state_off (cklist_form, KEYIN_TOG);
      }
      else
      {
        gadget_attr.poke_flag = 0;
        FIg_display (cklist_form, X_TXT);
        FIg_display (cklist_form, Y_TXT);
        FIg_display (cklist_form, X_FLD);
        FIg_display (cklist_form, Y_FLD);
      }
    }
    else
    {
      gadget_attr.poke_flag = 1;
      FIg_erase (cklist_form, X_TXT);
      FIg_erase (cklist_form, Y_TXT);
      FIg_erase (cklist_form, X_FLD);
      FIg_erase (cklist_form, Y_FLD);
    }
    break;

  case X_FLD:

    FIfld_get_text (cklist_form, X_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, cklist_form, ERR_FLD, &status);

    if (status)
      if (i >= 0)
        gadget_attr.x_pos = i;
      else
      {
        UMSGetByNum (t_str, FB_E_XNOTNEG, 0);
        print_error (cklist_form, ERR_FLD, t_str);
      }
    break;

  case Y_FLD:

    FIfld_get_text (cklist_form, Y_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, cklist_form, ERR_FLD, &status);

    if (status)
      if (i >= 0)
        gadget_attr.y_pos = i;
      else
      {
        UMSGetByNum (t_str, FB_E_YNOTNEG, 0);
        print_error (cklist_form, ERR_FLD, t_str);
      }
    break;

  case FI_HELP:

    /* Help_topic ("???") */
    break;

  case FI_CANCEL:

    if (command_is_active == EDIT_GADGET)
    {
      if (edit_hilite_flag == 0)
        FIg_unhilite (work_form, old_gadget_label);

      if (edit_display_flag == 0)
        FIg_erase (work_form, old_gadget_label);
    }

    kill_place_cklist();
    FIg_set_state_off (cklist_form, FI_CANCEL);
    break;

  case FI_ACCEPT:

    status = FIf_erase (cklist_form);

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

    create_cklist_gadget();

    loop_count++;

    FIg_set_state_off (cklist_form, FI_ACCEPT);

    if (command_is_active == EDIT_GADGET)
      kill_place_cklist();
    else if (cklist_form != NULL) /* Do this command again */
    {
      FIf_display (cklist_form);

      FIg_get_state (cklist_form, SYM_SELECT_BTN, &state);
      if ((Symbol_scroll != NULL) && (state == 1))
      {
        FIf_display (Symbol_scroll);
      }

      FIg_get_state (cklist_form, ADD_DIRECTORY_BTN, &state);
      if ((Sym_dir_form != NULL) && (state == 1))
      {
        FIf_display (Sym_dir_form);
      }

      FIf_get_next_label (work_form, &gadget_attr.gadget_label);

      if (Characteristics_form != NULL)
      {
        override_attr.gadget_label = gadget_attr.gadget_label;

        sprintf (t_str, "%d", override_attr.gadget_label);
        FIfld_set_text (Characteristics_form, LABEL_FLD,
            0, 0, t_str, 0);

        FIg_erase (Characteristics_form, 10);
      }

      UMSGetByNum (t_str, FB_P_FILLCKLST, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
    }
    break;
  }

  return;
}

/*************************************************************************/
/* */
/* execute_place_cklist() */
/* */
/* This function is called by the executive command handler routine. */
/* */
/* It displays the checklist form then exits. After that point */
/* the fi_cklist_type_form() gadget notification routine will be in */
/* control. That is, every time the operator alters a gadget on */
/* the button type form, the fi_cklist_type_form() function will be */
/* invoked. */
/* */
/*************************************************************************/

void execute_place_cklist(void)
{
  char t_str[256];
  int status;

  /* sml:04-30-92	add this for last arg to FIf_process_point */
  Time ttag = (Time) 0;


  if (work_form == NULL) /* No form defined */
  {
    strcpy (current_command_string, "None");
    command_is_active = 0;
    return;
  }

  UMSGetByNum (t_str, FB_I_PLACKLST, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENDEF, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (cklist_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlCkLs");
    status = FIf_new (100, t_str, (int (*)())fi_cklist_form, &cklist_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  setup_new_cklist_form();
  show_cklist_form_info();

  FIf_display (cklist_form);

  FIf_get_next_label (work_form, &gadget_attr.gadget_label);

  if (Characteristics_form != NULL)
    Update_characteristics_form();

  UMSGetByNum (t_str, FB_P_FILLCKLST, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  /* The loop count is used to insure that the operator only has to */
  /* place the first checklist item. After that the software will */
  /* keep the items arranged in a neat column. */

  loop_count = 1;

  /* sml:04-30-92	add ttag as last arg */
  FIf_process_point (cklist_form, 35, 147, 1, 2, ttag);

  /*
FIg_start_seq (cklist_form, STRING_FLD);
*/
}

/*********************************************************************/
/* */
/* edit_cklist_gadget() */
/* */
/*********************************************************************/

void edit_cklist_gadget(void)
{
  char t_str[256];
  int status;

  /* sml:04-30-92	add this for last arg to FIf_process_point */
  Time ttag = (Time) 0;

  gadget_attr.gadget_label = old_gadget_label;

  UMSGetByNum (t_str, FB_I_EDCKLST, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENCUR, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (cklist_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlCkLs");
    status = FIf_new (100, t_str, (int (*)())fi_cklist_form, &cklist_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  setup_old_cklist_form();
  show_cklist_form_info();

  FIf_display (cklist_form);

  if (Characteristics_form != NULL)
    Update_characteristics_form();

  UMSGetByNum (t_str, FB_P_FILLCKLST, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  /* The loop count is used to insure that the operator only has to */
  /* place the first checklist item. After that the software will */
  /* keep the items arranged in a neat column. */

  loop_count = 1;

  /* sml:04-30-92	add ttag as last arg */
  FIf_process_point (cklist_form, 35, 147, 1, 2, ttag);

  /*
FIg_start_seq (cklist_form, STRING_FLD);
*/
}
