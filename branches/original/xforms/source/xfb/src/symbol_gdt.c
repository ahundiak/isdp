/***********************************

		symbol_gdt.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
	05-07-92	sml		cast func args for ANSI
*/

/*************************************/
/* */
/* This file contains functions for the "place symbol" and "edit symbol" */
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

#include "XFIproto_pub.h"
#include "XFIproto_pri.h"
#include "XFBproto_pri.h"


#define LABEL_FLD 41 /* Needed by characteristics form */

/*************************/
/* */
/* used by symbol form */
/* */
/*************************/

#define SYMBOL_FILE_FLD 13
#define SYMBOL_INDEX_FLD 14

#define KEYIN_TOG 30
#define X_TEXT 15
#define X_FLD 16
#define Y_TEXT 33
#define Y_FLD 18

#define SELECT_BTN 17
#define ERR_FLD 10

#define CHAR_FOREGROUND_CLR_BTN 47
#define ADD_DIRECTORY_BTN 22

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

Form Symbol_form = NULL;

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
extern Form Sym_dir_form;
extern Form Message_form;
extern int edit_hilite_flag;
extern int edit_display_flag;
extern int old_gadget_label;

extern char Global_symbol_file[20];
extern Form Symbol_scroll;

extern char language[80];
extern Display *display;

/*************************************************************************/
/* */
/* kill_place_symbol() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to PLACE_SYMBOL indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecteing the point. */
/* */
/*************************************************************************/

void kill_place_symbol(void)
{
  char t_str[256];

  if (Symbol_form != NULL)
    FIf_erase (Symbol_form);

  if (Sym_dir_form != NULL)
    FIf_erase (Sym_dir_form);

  if (Symbol_scroll != NULL)
    FIf_erase (Symbol_scroll);

  if (Characteristics_form != NULL)
    Clear_characteristics_form();

  FIfld_set_text (Message_form, 11, 0, 0, "", 0);
  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  if (command_is_active == PLACE_SYMBOL)
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
/* setup_old_symbol_form() */
/* */
/*************************************************************************/

static void setup_old_symbol_form(void)
{
  setup_standard_attr (old_gadget_label);

  gadget_attr.draw_flag = 0;
  gadget_attr.poke_flag = 0;
  gadget_attr.text_gadget = 0;

  gadget_attr.gadget_type = FI_SYM;
}

/*************************************************************************/
/* */
/* setup_new_symbol_form() */
/* */
/* This function is called each time the operator wishes to place a */
/* new symbol on the work form. It will fill in default settings for */
/* the symbol. These will be displayed in the symbol definition form */
/* when the show_symbol_info() function is called. */
/* */
/*************************************************************************/

static void setup_new_symbol_form(void)
{
  Set_new_gadget_defaults();

  gadget_attr.selectable = 1;

  strcpy (gadget_attr.symbol_file, Global_symbol_file);
  gadget_attr.off_sym_index = 0;

  gadget_attr.x_pos = 0;

  gadget_attr.poke_flag = 1;
  gadget_attr.text_gadget = 0;

  gadget_attr.gadget_type = FI_SYM;
}

/*************************************************************************/
/* */
/* show_symbol_form_info() */
/* */
/* This function displays the information contained in the */
/* current_gadget struct into the symbol form's gadgets. */
/* */
/*************************************************************************/

static void show_symbol_form_info(void)
{
  char t_str[256];

  FIg_erase (Symbol_form, 10);
  FIg_set_state_off (Symbol_form, SELECT_BTN);
  FIg_set_state_off (Symbol_form, ADD_DIRECTORY_BTN);

  FIfld_set_text (Symbol_form, SYMBOL_FILE_FLD, 0, 0,
      gadget_attr.symbol_file, 0);

  sprintf (t_str, "%d", gadget_attr.off_sym_index);
  FIfld_set_text (Symbol_form, SYMBOL_INDEX_FLD, 0, 0, t_str, 0);

  if (gadget_attr.poke_flag == 0)
  {
    FIg_set_state_on (Symbol_form, KEYIN_TOG);

    sprintf (t_str, "%d", gadget_attr.x_pos);
    FIfld_set_text (Symbol_form, X_FLD, 0, 0, t_str, 0);
    sprintf (t_str, "%d", gadget_attr.y_pos);
    FIfld_set_text (Symbol_form, Y_FLD, 0, 0, t_str, 0);

    FIg_display (Symbol_form, X_TEXT);
    FIg_display (Symbol_form, X_FLD);
    FIg_display (Symbol_form, Y_TEXT);
    FIg_display (Symbol_form, Y_FLD);
  }
  else
  {
    FIg_set_state_off (Symbol_form, KEYIN_TOG);

    FIfld_set_text (Symbol_form, X_FLD, 0, 0, "", 0);
    FIfld_set_text (Symbol_form, Y_FLD, 0, 0, "", 0);

    FIg_erase (Symbol_form, X_TEXT);
    FIg_erase (Symbol_form, X_FLD);
    FIg_erase (Symbol_form, Y_TEXT);
    FIg_erase (Symbol_form, Y_FLD);
  }
}



/*********************************************************************/
/* */
/* create_symbol_gadget() */
/* */
/* This function creates a new symbol gadget and places it at */
/* the position that was poked by the operator. */
/* */
/*********************************************************************/

static void create_symbol_gadget(void)
{
  Window window;
  char t_str[256];
  int group_label;
  int width, height;
  Font symbol_id;
  int status;
  int xoff, yoff, total_width, total_height;

  /***********************************************************/
  /* */
  /* If the work form and the place symbol form intersect, */
  /* then send a window update message to the work_form */
  /* */
  /***********************************************************/

  Refresh_work_form();

  if (gadget_attr.poke_flag == 1)
  {
    UMSGetByNum (t_str, FB_P_POKUPPSYM, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    FIf_get_window (work_form, &window);

    status = Poke_symbol_location (window, &gadget_attr.x_pos,
        &gadget_attr.y_pos, gadget_attr.symbol_file,
        gadget_attr.off_sym_index, 0, 0);

    FIfld_set_text (Message_form, 44, 0, 0, "", 0);

    if (status != 2) /* Operator wants to cancel place command */
      return;
  }

  strcpy (gadget_attr.default_str, gadget_attr.font_name);
  strcpy (gadget_attr.font_name, gadget_attr.symbol_file);

  if (command_is_active == EDIT_GADGET)
  {
    FIg_get_group_label (work_form, old_gadget_label, &group_label);
    FIg_erase (work_form, old_gadget_label);
    FIg_delete (work_form, old_gadget_label);
    old_gadget_label = -1;
  }
  else
    group_label = 0;

  /* dmb:10/16/92:Is this still neccessary? */
  _FI_find_symbol_path_and_id (t_str, gadget_attr.symbol_file, (int *)&symbol_id);

/*   This only worked when symbols were being treated as .snf fonts
                  GMD 10/1/91
  t_str [0] = gadget_attr.off_sym_index;
  t_str [1] = NULL;
  _FI_calc_text (symbol_id, t_str, 1, &height, &width, &line_spacing);
*/

  FI_inq_symbol_attr (gadget_attr.symbol_file,
                      gadget_attr.off_sym_index,
                      &total_width, &total_height, &xoff, &yoff,
                      &width, &height);

  gadget_attr.x_size = gadget_attr.x_pos + width;
  gadget_attr.y_size = gadget_attr.y_pos + height;

  Create_and_init_gadget (work_form, FI_SYM, gadget_attr.gadget_label);

  if (group_label != 0)
    FIg_add_to_group (work_form, gadget_attr.gadget_label, group_label);

  strcpy (gadget_attr.font_name, gadget_attr.default_str);

  FIg_activate (work_form, gadget_attr.gadget_label);

  if (gadget_attr.display == 1)
    FIg_display (work_form, gadget_attr.gadget_label);

  /*
FIf_calculate_size (work_form);
*/
}

/*--------------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* fi_symbol_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the default */
/* settings for a new symbol gadget, or alter the settings of an */
/* existing symbol gadget. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_symbol_form (int form_label,
                    int gadget_label,
                    double value,
                    Form form_ptr)
{
  int num_flag, i, j;
  char sym_name[256];
  int sym_value;
  int status;
  int state;
  char t_str[256];
  int dummy_int;

  FIg_erase (Symbol_form, ERR_FLD);

  switch (gadget_label)
  {
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

  case SYMBOL_FILE_FLD:

    FIfld_get_text (Symbol_form, SYMBOL_FILE_FLD, 0, 0, 255, 
		(unsigned char *)t_str,
        &dummy_int, &dummy_int);

    strcpy (gadget_attr.symbol_file, t_str);
    strcpy (Global_symbol_file, t_str);

    if (Symbol_scroll != NULL)
      Set_scroll_symbol_file (t_str);
    /*
else
{
UMSGetByNum (t_str, FB_E_SYMFILNOTFND, 0);
print_error (Symbol_form, ERR_FLD, t_str);
}
*/
    break;

  case SYMBOL_INDEX_FLD:

    num_flag = 1;
    i = 0; 
    j = 0;

    FIfld_get_text(Symbol_form, SYMBOL_INDEX_FLD,
        0, 0, 255, (unsigned char *)t_str, &dummy_int, &dummy_int);

    if ((t_str[0] == '\'') || (t_str[0] == '\\'))
    {
      i = 1;
      if (t_str[1] == '\\')
        i = 2;
    }

    while ((t_str[i] != (char) NULL) && num_flag)
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
        print_error (Symbol_form, ERR_FLD, t_str);
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
      print_error (Symbol_form, ERR_FLD, t_str);
    }
    break;

  case ADD_DIRECTORY_BTN:

    if ((int)value == 1)
      Display_symbol_dir_form();
    else
      FIf_erase (Sym_dir_form);
    break;

  case KEYIN_TOG:

    if ((int)value == 1) /* Use keyin for location */
    {
      gadget_attr.poke_flag = 0;
      FIg_display (Symbol_form, X_TEXT);
      FIg_display (Symbol_form, Y_TEXT);
      FIg_display (Symbol_form, X_FLD);
      FIg_display (Symbol_form, Y_FLD);

      sprintf(t_str, "%d", gadget_attr.x_pos);
      FIfld_set_text (Symbol_form, X_FLD, 0, 0, t_str, 0);

      sprintf(t_str, "%d", gadget_attr.y_pos);
      FIfld_set_text (Symbol_form, Y_FLD, 0, 0, t_str, 0);
    }
    else
    {
      gadget_attr.poke_flag = 1;
      FIg_erase (Symbol_form, X_TEXT);
      FIg_erase (Symbol_form, Y_TEXT);
      FIg_erase (Symbol_form, X_FLD);
      FIg_erase (Symbol_form, Y_FLD);
    }

    break;

  case X_FLD:

    FIfld_get_text (Symbol_form, X_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Symbol_form, ERR_FLD, &status);

    if (status) /* Valid input */
      if (i >= 0)
        gadget_attr.x_pos = i;
      else
      {
        UMSGetByNum (t_str, FB_E_XNOTNEG, 0);
        print_error (Symbol_form, ERR_FLD, t_str);
      }
    break;

  case Y_FLD:

    FIfld_get_text (Symbol_form, Y_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Symbol_form, ERR_FLD, &status);

    if (status) /* Valid input */
      if (i >= 0)
        gadget_attr.y_pos = i;
      else
      {
        UMSGetByNum (t_str, FB_E_YNOTNEG, 0);
        print_error (Symbol_form, ERR_FLD, t_str);
      }
    break;

  case FI_HELP:

    /* Help_topic ("Symbol") */
    break;

  case FI_CANCEL:

    if (command_is_active == EDIT_GADGET)
    {
      if (edit_hilite_flag == 0)
        FIg_unhilite (work_form, old_gadget_label);

      if (edit_display_flag == 0)
        FIg_erase (work_form, old_gadget_label);
    }

    kill_place_symbol();
    FIg_set_state_off (Symbol_form, FI_CANCEL);
    break;

  case FI_ACCEPT:

    FIf_erase (Symbol_form);
    FIg_set_state_off (Symbol_form, FI_ACCEPT);

    if (Symbol_scroll != NULL)
      FIf_erase (Symbol_scroll);
    if (Sym_dir_form != NULL)
      FIf_erase (Sym_dir_form);

    if (Characteristics_form != NULL)
    {
      FIf_erase (FG_color_form);
      FIg_set_state_off (Characteristics_form, CHAR_FOREGROUND_CLR_BTN);

      replace_attr_with_overrides(); /* character.c */
    }

    create_symbol_gadget();

    if (command_is_active == EDIT_GADGET)
      kill_place_symbol();
    else if (Symbol_form != NULL) /* Do this command again */
    {
      FIg_get_state (Symbol_form, SELECT_BTN, &state);
      FIf_display (Symbol_form);
      if ((Symbol_scroll != NULL) && (state == 1))
        FIf_display (Symbol_scroll);
      FIg_get_state (Symbol_form, ADD_DIRECTORY_BTN, &state);
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

      UMSGetByNum (t_str, FB_P_FILLSYMFRM, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
    }
    break;
  }

  return;
}

/*************************************************************************/
/* */
/* execute_place_symbol() */
/* */
/* This function is called in one of two ways. The first is to be */
/* called by the executive command handler routine. The second is to */
/* be called after a symbol has been successfully placed. */
/* */
/* It displays the place symbol form then exits. After that point */
/* the fi_symbol_form() gadget notification routine will be in */
/* control. That is to say, every time the operator alters a gadget on */
/* the place symbol form, the fi_symbol_form() function will be */
/* invoked. */
/* */
/*************************************************************************/

void execute_place_symbol(void)
{
  char t_str[256];
  int status;

  if (work_form == NULL) /* No form defined */
  {
    strcpy (current_command_string, "None");
    command_is_active = 0;
    return;
  }

  UMSGetByNum (t_str, FB_I_PCESYMB, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENDEF, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Symbol_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlSym");
    status = FIf_new (111, t_str, (int (*)())fi_symbol_form, &Symbol_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  setup_new_symbol_form();
  show_symbol_form_info();

  FIf_display (Symbol_form);

  FIf_get_next_label (work_form, &gadget_attr.gadget_label);

  if (Characteristics_form != NULL)
    Update_characteristics_form();

  UMSGetByNum (t_str, FB_P_FILLSYMFRM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}

/*-------------------------------------------------------------------------*/

void edit_symbol_gadget(void)
{
  char t_str[256];
  int status;

  gadget_attr.gadget_label = old_gadget_label;

  UMSGetByNum (t_str, FB_I_EDTSYMB, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENCUR, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Symbol_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlSym");
    status = FIf_new (111, t_str, (int (*)())fi_symbol_form, &Symbol_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  setup_old_symbol_form();
  show_symbol_form_info();

  FIf_display (Symbol_form);

  if (Characteristics_form != NULL)
    Update_characteristics_form();

  UMSGetByNum (t_str, FB_P_FILLSYMFRM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}
