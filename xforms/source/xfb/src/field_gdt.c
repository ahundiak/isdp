/***********************************

		 field_gdt.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
	05-07-92	sml		casted func args; changed var types for ANSI
*/

/*************************************/
/* */
/* This file contains functions for the "place field" and "edit field" */
/* commands. */
/* */
/* Programmer: Mack Draper */
/* Date: Dec. 15, 1988 */
/* */
/*************************************/

#include <stdio.h>

#include <X11/Xlib.h>

#include "FI.h"
#include "FIdyn.h"
#include "NFBpriv.h"
#include "UMS.h"
#include "FB.h"
#include "FEI.h"

#include "XFIproto_pub.h"
#include "XFIproto_pri.h"
#include "XFBproto_pri.h"

#define LABEL_FLD 41 /* Needed by characteristics form */

/*******************************/
/* */
/* used by Master field form */
/* */
/*******************************/

#define DRAW_TOG 22
#define KEYIN_TOG 27
#define NUM_LINES_TOG 102

#define ROWS_TEXT 24
#define COLS_TEXT 23
#define ROWS_FLD 32
#define COLS_FLD 33

#define X_POS_TEXT 25
#define Y_POS_TEXT 26
#define X_POS_FLD 29
#define Y_POS_FLD 31

#define ASCII_CK 14
#define INT_CK 12
#define FLOAT_CK 15

#define SCROLL_OPT_CK 98
#define EDIT_OPT_CK 99
#define VERIFY_OPT_CK 100
#define ASSOC_LIST_CK 101

#define ERR_FLD 10

/********************************/
/* */
/* Used by Scroll_field_form */
/* */
/********************************/

#define NO_SCROLL_CK 15
#define VERT_SCROLL_CK 75
#define HORZ_SCROLL_CK 102
#define BOTH_SCROLL_CK 103

#define VERT_NOTIFY_TOG 16

#define BUILDER_TIME_TOG 91
#define DISPLAY_VERT_TOG 80
#define DISPLAY_HORZ_TOG 21
#define ROLL_THROUGH_TOG 79
#define WRAP_TOG 81

#define SCROLL_GROUP_OPTIONS 14
#define SCROLL_ERR_FLD 10

/*****************************/
/* */
/* Used by Edit field form */
/* */
/*****************************/

#define REVIEW_CK 111
#define SINGLE_SELECT_CK 53
#define MULTI_SELECT_CK 45
#define CHANGE_CK 72
#define INSERT_CK 112

#define REPLACE_TEXT_TOG 64
#define EDIT_ERR_FLD 10

#define NOTIFICATION_TOG 12
#define ECHO_TOG 13
#define REQUIRED_TOG 15

#define EDIT_GROUP_OPTIONS 14

#define RIGHT_TO_LEFT_TOG 18
#define REVERSE_INPUT_TOG 20
#define REVERSE_OUTPUT_TOG 19

/*******************************/
/* */
/* Used by Verify field form */
/* */
/*******************************/

#define DEFAULT_STR_FLD 92
#define MINIMUM_FLD 41
#define MAXIMUM_FLD 40
#define INITIAL_VALUES_FLD 100

#define MIN_TEXT 20
#define MAX_TEXT 18
#define DEF_TEXT 94
#define INITIAL_TEXT 93

#define FORMAT_TEXT 16
#define FORMAT_FLD 17

#define VERIFY_LIST_TOG 12

#define VERIFY_ERR_FLD 10

/**********************************/
/* */
/* Used by Associated list form */
/* */
/**********************************/

#define LIST_DRAW_TOG 22
#define LIST_KEYIN_TOG 27
#define LIST_DISPLAY_TOG 30

#define SINGLE_SELECT_RESELECT_CK 45
#define MULTI_SELECT_LIST_CK 46
#define SINGLE_SELECT_DISMISS_CK 96

#define LIST_ROWS_TEXT 24
#define LIST_COLS_TEXT 23
#define LIST_X_POS_TEXT 25
#define LIST_Y_POS_TEXT 26

#define LIST_ROWS_FLD 32
#define LIST_COLS_FLD 33
#define LIST_X_POS_FLD 29
#define LIST_Y_POS_FLD 31

#define LIST_VALUES_FLD 41
#define DEFINE_LIST_TOG 34
#define LIST_ERR_FLD 10

#define CHAR_FOREGROUND_CLR_BTN 47
#define CHAR_FOREGROUND2_CLR_BTN 48
#define CHAR_TEXT_FONT_BTN 46

#define VERT_SCROLL_TOG 15
#define HORZ_SCROLL_TOG 16

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

Form Master_field_form = NULL;
Form Scroll_field_form = NULL;
Form Edit_field_form = NULL;
Form Verify_field_form = NULL;
Form Assoc_list_field_form = NULL;
int number_of_lines;

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

/* extern double atof(); dmb:10/18/92:Interferes with ANSI */

extern Form work_form;
extern Form Message_form;
extern struct dpb_struct dpb;
extern int command_is_active;
extern char current_command_string[80];
extern struct gadget_struct gadget_attr;
extern struct gadget_struct override_attr;
extern char execute_dir[200];

extern Form Characteristics_form;
extern Form FG_color_form;
extern Form FG2_color_form;
extern Form Font_form;
extern int edit_hilite_flag;
extern int edit_display_flag;
extern int old_gadget_label;
extern int Next_in_sequence;
extern int Next_link;

extern int Edit_sequence_array[100];
extern int Edit_data_link_array[100];
extern int Edit_sequence_count;
extern int Edit_data_link_count;

extern char language[80];
extern struct dpb_struct temp_dpb;

extern GC xfb_GC;
extern XGCValues GC_values;
extern hilite_plane;
extern Display *display;

/*************************************************************************/
/* */
/* kill_place_field() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to PLACE_FIELD indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecteing the point. */
/* */
/*************************************************************************/

void kill_place_field(void)
{
  char t_str[256];

  if (Master_field_form != NULL)
    FIf_erase (Master_field_form);

  if (Scroll_field_form != NULL)
    FIf_erase (Scroll_field_form);

  if (Edit_field_form != NULL)
    FIf_erase (Edit_field_form);

  if (Verify_field_form != NULL)
    FIf_erase (Verify_field_form);

  if (Assoc_list_field_form != NULL)
    FIf_erase (Assoc_list_field_form);

  if (Characteristics_form != NULL)
    Clear_characteristics_form();

  if (command_is_active == PLACE_FIELD)
  {
    command_is_active = 0;
    strcpy (current_command_string, "None");

    FIfld_set_text (Message_form, 11, 0, 0, "", 0);
    FIfld_set_text (Message_form, 22, 0, 0, "", 0);

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
/* setup_old_field_form() */
/* */
/*************************************************************************/

static void setup_old_field_form (void)
{
  int height, width, line_spacing;
  long attr;
  float dummy_float;
  int list_mode, row_count, x;
  char t_str[256];
  int status, font_type;
  Font font_id;
  int dummy_int;

  setup_standard_attr (old_gadget_label);

  FIfld_get_mode (work_form, old_gadget_label, 0, &gadget_attr.field_mode);
  FIfld_get_type (work_form, old_gadget_label, 0, &gadget_attr.field_type);

  FIfld_get_attr (work_form, old_gadget_label, 0, &attr);

  if (attr & FI_RIGHT_TO_LEFT)
    gadget_attr.right_to_left = 1;
  else
    gadget_attr.right_to_left = 0;

  if (attr & FI_REVERSE_INPUT)
    gadget_attr.reverse_input_flag = 1;
  else
    gadget_attr.reverse_input_flag = 0;

  if (attr & FI_REVERSE_OUTPUT)
    gadget_attr.reverse_output_flag = 1;
  else
    gadget_attr.reverse_output_flag = 0;

  if (attr & FI_WRAP)
    gadget_attr.wrap_flag = 1;
  else
    gadget_attr.wrap_flag = 0;

  if (attr & FI_REQUIRED)
    gadget_attr.required_flag = 1;
  else
    gadget_attr.required_flag = 0;

  if (attr & FI_DISPLAY_VSCROLL)
    gadget_attr.vert_scroll_flag = 1;
  else
    gadget_attr.vert_scroll_flag = 0;

  if (attr & FI_DISPLAY_HSCROLL)
    gadget_attr.horz_scroll_flag = 1;
  else
    gadget_attr.horz_scroll_flag = 0;

  if (attr & FI_CLEAR_ON_SELECTION)
    gadget_attr.replace_text_flag = 0;
  else
    gadget_attr.replace_text_flag = 1;

  if (attr & FI_ROLL_THRU)
    gadget_attr.roll_through_flag = 1;
  else
    gadget_attr.roll_through_flag = 0;

  if (attr & FI_NOTIFY_BY_LINE)
    gadget_attr.line_notification = 1;
  else
    gadget_attr.line_notification = 0;

  if (attr & FI_NO_ECHO)
    gadget_attr.echo_flag = 0;
  else
    gadget_attr.echo_flag = 1;

  if ((!(attr & FI_VERT_SCROLL)) &&
      (!(attr & FI_HORT_SCROLL)))
    gadget_attr.scroll_mode = NO_SCROLLING;

  if (attr & FI_VERT_SCROLL)
    if (attr & FI_HORT_SCROLL)
      gadget_attr.scroll_mode = BOTH_DIRECTION_SCROLL;
    else
      gadget_attr.scroll_mode = VERTICAL_SCROLL_ONLY;


  if (attr & FI_HORT_SCROLL)
    if (!(attr & FI_VERT_SCROLL))
      gadget_attr.scroll_mode = HORIZONTAL_SCROLL_ONLY;

  status = FIg_get_low_value (work_form, old_gadget_label,
      &gadget_attr.minimum_value);

  status = FIg_get_high_value (work_form, old_gadget_label,
      &gadget_attr.maximum_value);

  FIfld_get_text (work_form, old_gadget_label, 0, 0, 2000,
      (unsigned char *)gadget_attr.default_str, &dummy_int, &dummy_int);

  FIg_get_justification (work_form, old_gadget_label,
      &gadget_attr.text_justification);

  FIfld_get_format_string (work_form, old_gadget_label, 0,
      (unsigned char *)gadget_attr.on_text);

  if (gadget_attr.on_text[0] == 0)
  {
    if (gadget_attr.field_type != FI_DOUBLE)
      strcpy (gadget_attr.on_text, "%d");
    else
      strcpy (gadget_attr.on_text, "%lG");
  }

  /*****************************************/
  /* */
  /* Now set up associated list attributes */
  /* */
  /*****************************************/

  if ((attr & FI_ASSOCIATED_LIST) ||
      (attr & FI_POPUP_ASSO_LIST))
  {
    gadget_attr.list_exists_flag = 1;
    FIfld_get_list_scroll (work_form, old_gadget_label,
        &gadget_attr.list_vert_flag,
        &gadget_attr.list_horz_flag);
  }
  else
  {
    gadget_attr.list_exists_flag = 0;
    gadget_attr.list_vert_flag = 1;
    gadget_attr.list_horz_flag = 0;
  }

  if (attr & FI_VALIDATE_BY_LIST)
    gadget_attr.list_verify_flag = 1;
  else
    gadget_attr.list_verify_flag = 0;

  if (attr & FI_POPUP_ASSO_LIST)
  {
    gadget_attr.list_display_flag = 0;
    gadget_attr.list_exists_flag = 1;
  }
  else
    gadget_attr.list_display_flag = 1;

  if (attr & FI_DISMISS_LIST_ON_SEL)
    gadget_attr.list_mode = 3;
  else
  {
    FIfld_get_list_mode (work_form, old_gadget_label, 0, &list_mode);

    if (list_mode == FI_SINGLE_SELECT)
      gadget_attr.list_mode = 1;
    else
      gadget_attr.list_mode = 2;
  }

  /* figure out num_rows, num_cols */

  _FI_find_font_id (gadget_attr.font_name, gadget_attr.bodysize,
      &font_id, &dummy_float, FI_FIELD, &font_type);

  _FI_calc_text (font_id, "M", 1, &height, &width, &line_spacing, font_type);

  if (gadget_attr.roll_through_flag == 1)
    gadget_attr.x_size -= 10;

  if (gadget_attr.list_exists_flag == 1)
    gadget_attr.x_size -= 10;

  FIfld_get_num_vis_rows (work_form, old_gadget_label,
      &gadget_attr.num_rows);
  FIfld_get_num_vis_chars (work_form, old_gadget_label, 0,
      &gadget_attr.num_cols);

  if (gadget_attr.list_exists_flag == 0)
  {
    gadget_attr.list_draw_flag = 1;
    gadget_attr.list_poke_flag = 0;
  }
  else
  {
    gadget_attr.list_draw_flag = 0;
    gadget_attr.list_poke_flag = 0;

    FIfld_get_list_size (work_form, old_gadget_label, 0,
        &gadget_attr.list_xsize, &gadget_attr.list_ysize);

    FIfld_get_list_location (work_form, old_gadget_label, 0,
        &gadget_attr.list_x_pos, &gadget_attr.list_y_pos);

    gadget_attr.list_num_rows = gadget_attr.list_ysize / line_spacing;
    gadget_attr.list_num_cols = gadget_attr.list_xsize / width;
  }

  gadget_attr.draw_flag = 0;
  gadget_attr.poke_flag = 0;
  gadget_attr.gadget_type = FI_FIELD;

  /*****************************************/
  /* */
  /* Now set up initial values for field */
  /* */
  /*****************************************/

  FIfld_set_num_rows (Verify_field_form, INITIAL_VALUES_FLD, 0);

  FIfld_get_num_rows (work_form, old_gadget_label, &row_count);

  for (x = 0; x < row_count; x++)
  {
    FIfld_get_text (work_form, old_gadget_label, x, 0, 255, 
		(unsigned char *)t_str,
        &dummy_int, &dummy_int);

    FIfld_set_text (Verify_field_form, INITIAL_VALUES_FLD, x, 0, t_str, 0);
  }

  /***********************************************/
  /* */
  /* Set up initial values for associated list */
  /* */
  /***********************************************/

  FIfld_set_num_rows (Assoc_list_field_form, LIST_VALUES_FLD, 0);

  if (gadget_attr.list_exists_flag == 1)
  {
    FIfld_get_list_num_rows (work_form, old_gadget_label, 0, &row_count);

    for (x = 0; x < row_count; x++)
    {
      FIfld_get_list_text (work_form, old_gadget_label, x, 0, 255, 
		  (unsigned char *)t_str,
          &dummy_int); /* remove this extraneous arg , &dummy_int); */

      FIfld_set_text (Assoc_list_field_form, LIST_VALUES_FLD,
          x, 0, t_str, 0);
    }
  }
}

/*************************************************************************/
/* */
/* setup_new_field_form() */
/* */
/* This function is called each time the operator wishes to place a */
/* new field on the work form. It will fill in default settings for */
/* the field. These will be displayed in the field definition form */
/* when the show_field_info() function is called. */
/* */
/*************************************************************************/

static void setup_new_field_form(void)
{

  Set_new_gadget_defaults();

  number_of_lines = 5;

  /**********************************************/
  /* */
  /* Force this font for all new field gadgets */
  /* unless overridden by the operator. */
  /* */
  /**********************************************/

  strcpy (gadget_attr.font_name, "mono821b");
  gadget_attr.bodysize = 15.0;

  gadget_attr.draw_flag = 1;
  gadget_attr.poke_flag = 0;

  gadget_attr.num_rows = 1;
  gadget_attr.num_cols = 1;
  gadget_attr.field_mode = FI_INSERT;
  gadget_attr.field_type = FI_ALPHA;

  gadget_attr.vert_scroll_notify = 0;

  gadget_attr.wrap_flag = 0;
  gadget_attr.required_flag = 0;
  gadget_attr.vert_scroll_flag = 1;
  gadget_attr.horz_scroll_flag = 0;
  gadget_attr.roll_through_flag = 0;
  gadget_attr.scroll_mode = HORIZONTAL_SCROLL_ONLY;
  gadget_attr.replace_text_flag = 1;
  gadget_attr.line_notification = 0;
  gadget_attr.echo_flag = 1;
  gadget_attr.text_justification = FI_LEFT_JUSTIFIED;
  gadget_attr.right_to_left = 0; /* Text will run left to right */
  gadget_attr.reverse_input_flag = 0;
  gadget_attr.reverse_output_flag = 1;

  strcpy (gadget_attr.default_str, "");
  gadget_attr.minimum_value = 0;
  gadget_attr.maximum_value = 0;
  strcpy (gadget_attr.on_text, "%d");

  gadget_attr.list_exists_flag = 0; /* No associated list defined */
  gadget_attr.list_verify_flag = 0;
  gadget_attr.list_num_rows = 1;
  gadget_attr.list_num_cols = 1;
  gadget_attr.list_x_pos = 0;
  gadget_attr.list_y_pos = 0;

  gadget_attr.list_vert_flag = 1;
  gadget_attr.list_horz_flag = 0;

  gadget_attr.list_mode = 1; /* Need to change this to a constant */
  /* once I know what a meaningful one is */

  gadget_attr.list_display_flag = 1; /* Always displayed */

  gadget_attr.list_draw_flag = 1;
  gadget_attr.list_poke_flag = 0;

  gadget_attr.gadget_type = FI_FIELD;
  Next_in_sequence = 0;
  Next_link = -1;
}

/*************************************************************************/
/* */
/* show_master_field_form_info() */
/* */
/* This function displays the information contained in the */
/* current_gadget struct into the Master field form's gadgets. */
/* */
/*************************************************************************/

static void show_master_field_form_info(void)
{
  char t_str[256];
  int x;

  /* 1/4/90 Why is this needed?
FIg_erase (Scroll_field_form, BUILDER_TIME_TOG);
*/

  if (gadget_attr.num_rows == 1)
    FIg_set_state_off (Master_field_form, NUM_LINES_TOG);
  else
    FIg_set_state_on (Master_field_form, NUM_LINES_TOG);

  if (gadget_attr.field_type == FI_ALPHA)
  {
    FIg_set_state_off (Master_field_form, INT_CK);
    FIg_set_state_off (Master_field_form, FLOAT_CK);
    FIg_set_state_on (Master_field_form, ASCII_CK);
  }
  else if (gadget_attr.field_type == FI_INT)
  {
    FIg_set_state_off (Master_field_form, ASCII_CK);
    FIg_set_state_off (Master_field_form, FLOAT_CK);
    FIg_set_state_on (Master_field_form, INT_CK);
  }
  else if (gadget_attr.field_type == FI_DOUBLE)
  {
    FIg_set_state_off (Master_field_form, ASCII_CK);
    FIg_set_state_off (Master_field_form, INT_CK);
    FIg_set_state_on (Master_field_form, FLOAT_CK);
  }

  if (gadget_attr.draw_flag == 0)
  {
    FIg_set_state_on (Master_field_form, DRAW_TOG);

    FIg_display (Master_field_form, ROWS_TEXT);
    FIg_display (Master_field_form, COLS_TEXT);
    FIg_display (Master_field_form, ROWS_FLD);
    FIg_display (Master_field_form, COLS_FLD);

    sprintf (t_str, "%d", gadget_attr.num_cols);
    FIfld_set_text (Master_field_form, COLS_FLD, 0, 0, t_str, 0);

    sprintf (t_str, "%d", gadget_attr.num_rows);
    FIfld_set_text (Master_field_form, ROWS_FLD, 0, 0, t_str, 0);

    if (gadget_attr.poke_flag == 0)
    {
      FIg_set_state_on (Master_field_form, KEYIN_TOG);

      FIg_display (Master_field_form, X_POS_TEXT);
      FIg_display (Master_field_form, Y_POS_TEXT);
      FIg_display (Master_field_form, X_POS_FLD);
      FIg_display (Master_field_form, Y_POS_FLD);

      sprintf (t_str, "%d", gadget_attr.x_pos);
      FIfld_set_text (Master_field_form, X_POS_FLD, 0, 0, t_str, 0);

      sprintf (t_str, "%d", gadget_attr.y_pos);
      FIfld_set_text (Master_field_form, Y_POS_FLD, 0, 0, t_str, 0);
    }
  }
  else /* Draw mode enabled */
  {
    FIg_set_state_off (Master_field_form, DRAW_TOG);
    FIg_set_state_off (Master_field_form, KEYIN_TOG);

    FIg_erase (Master_field_form, ROWS_TEXT);
    FIg_erase (Master_field_form, COLS_TEXT);
    FIg_erase (Master_field_form, ROWS_FLD);
    FIg_erase (Master_field_form, COLS_FLD);

    FIg_erase (Master_field_form, X_POS_TEXT);
    FIg_erase (Master_field_form, Y_POS_TEXT);
    FIg_erase (Master_field_form, X_POS_FLD);
    FIg_erase (Master_field_form, Y_POS_FLD);

    sprintf (t_str, "%d", gadget_attr.num_cols);
    FIfld_set_text (Master_field_form, COLS_FLD, 0, 0, t_str, 0);

    sprintf (t_str, "%d", gadget_attr.num_rows);
    FIfld_set_text (Master_field_form, ROWS_FLD, 0, 0, t_str, 0);

    sprintf (t_str, "%d", gadget_attr.x_pos);
    FIfld_set_text (Master_field_form, X_POS_FLD, 0, 0, t_str, 0);

    sprintf (t_str, "%d", gadget_attr.y_pos);
    FIfld_set_text (Master_field_form, Y_POS_FLD, 0, 0, t_str, 0);
  }

  /****************************************/
  /* */
  /* Verification Options form set-up */
  /* */
  /****************************************/

  if (gadget_attr.list_verify_flag == 1)
    FIg_set_state_on (Verify_field_form, VERIFY_LIST_TOG);
  else
    FIg_set_state_off (Verify_field_form, VERIFY_LIST_TOG);

  if ((gadget_attr.num_rows == 1) &&
      (gadget_attr.roll_through_flag != 1) &&
      ((gadget_attr.scroll_mode == NO_SCROLLING) ||
      (gadget_attr.scroll_mode == HORIZONTAL_SCROLL_ONLY)))
  {
    FIfld_set_text (Verify_field_form, DEFAULT_STR_FLD, 0, 0,
        gadget_attr.default_str, 0);

    FIg_erase (Verify_field_form, INITIAL_TEXT);
    FIg_erase (Verify_field_form, INITIAL_VALUES_FLD);

    FIg_display (Verify_field_form, DEF_TEXT);
    FIg_display (Verify_field_form, DEFAULT_STR_FLD);
  }
  else
  {
    FIg_erase (Verify_field_form, DEF_TEXT);
    FIg_erase (Verify_field_form, DEFAULT_STR_FLD);

    FIg_display (Verify_field_form, INITIAL_TEXT);
    FIg_display (Verify_field_form, INITIAL_VALUES_FLD);

    /* Initial values being set up in Setup_old_field_form() */
  }

  if (gadget_attr.field_type == FI_INT)
  {
    sprintf (t_str, "%d", (int)gadget_attr.minimum_value);
    FIfld_set_text (Verify_field_form, MINIMUM_FLD, 0, 0, t_str, 0);

    sprintf (t_str, "%d", (int)gadget_attr.maximum_value);
    FIfld_set_text (Verify_field_form, MAXIMUM_FLD, 0, 0, t_str, 0);

    FIfld_set_text (Verify_field_form, FORMAT_FLD, 0, 0,
        gadget_attr.on_text, 0);

    FIg_display (Verify_field_form, MIN_TEXT);
    FIg_display (Verify_field_form, MAX_TEXT);
    FIg_display (Verify_field_form, MINIMUM_FLD);
    FIg_display (Verify_field_form, MAXIMUM_FLD);
    FIg_display (Verify_field_form, FORMAT_FLD);
    FIg_display (Verify_field_form, FORMAT_TEXT);
  }

  if (gadget_attr.field_type == FI_DOUBLE)
  {
    sprintf (t_str, "%lG", gadget_attr.minimum_value);
    FIfld_set_text (Verify_field_form, MINIMUM_FLD, 0, 0, t_str, 0);

    sprintf (t_str, "%lG", gadget_attr.maximum_value);
    FIfld_set_text (Verify_field_form, MAXIMUM_FLD, 0, 0, t_str, 0);

    FIfld_set_text (Verify_field_form, FORMAT_FLD, 0, 0,
        gadget_attr.on_text, 0);

    FIg_display (Verify_field_form, MIN_TEXT);
    FIg_display (Verify_field_form, MAX_TEXT);
    FIg_display (Verify_field_form, MINIMUM_FLD);
    FIg_display (Verify_field_form, MAXIMUM_FLD);
    FIg_display (Verify_field_form, FORMAT_FLD);
    FIg_display (Verify_field_form, FORMAT_TEXT);
  }

  if (gadget_attr.field_type == FI_ALPHA)
  {
    FIg_erase (Verify_field_form, MIN_TEXT);
    FIg_erase (Verify_field_form, MAX_TEXT);
    FIg_erase (Verify_field_form, MINIMUM_FLD);
    FIg_erase (Verify_field_form, MAXIMUM_FLD);
    FIg_erase (Verify_field_form, FORMAT_FLD);
    FIg_erase (Verify_field_form, FORMAT_TEXT);
  }

  /***********************************/
  /* */
  /* Associated list form set-up */
  /* */
  /***********************************/

  if (gadget_attr.list_exists_flag == 1)
    FIg_set_state_on (Assoc_list_field_form, DEFINE_LIST_TOG);
  else
    FIg_set_state_off (Assoc_list_field_form, DEFINE_LIST_TOG);

  if (gadget_attr.list_display_flag == 0)
    FIg_set_state_on (Assoc_list_field_form, LIST_DISPLAY_TOG);
  else
    FIg_set_state_off (Assoc_list_field_form, LIST_DISPLAY_TOG);

  if (gadget_attr.list_vert_flag)
    FIg_set_state_off (Assoc_list_field_form, VERT_SCROLL_TOG);
  else
    FIg_set_state_on (Assoc_list_field_form, VERT_SCROLL_TOG);

  if (gadget_attr.list_horz_flag)
    FIg_set_state_off (Assoc_list_field_form, HORZ_SCROLL_TOG);
  else
    FIg_set_state_on (Assoc_list_field_form, HORZ_SCROLL_TOG);

  if (gadget_attr.list_mode == 1)
  {
    FIg_set_state_off (Assoc_list_field_form, MULTI_SELECT_LIST_CK);
    FIg_set_state_off (Assoc_list_field_form, SINGLE_SELECT_DISMISS_CK);
    FIg_set_state_on (Assoc_list_field_form, SINGLE_SELECT_RESELECT_CK);
  }
  else if (gadget_attr.list_mode == 2)
  {
    FIg_set_state_off (Assoc_list_field_form, SINGLE_SELECT_RESELECT_CK);
    FIg_set_state_off (Assoc_list_field_form, SINGLE_SELECT_DISMISS_CK);
    FIg_set_state_on (Assoc_list_field_form, MULTI_SELECT_LIST_CK);
  }
  else if (gadget_attr.list_mode == 3)
  {
    FIg_set_state_off (Assoc_list_field_form, SINGLE_SELECT_RESELECT_CK);
    FIg_set_state_off (Assoc_list_field_form, MULTI_SELECT_LIST_CK);
    FIg_set_state_on (Assoc_list_field_form, SINGLE_SELECT_DISMISS_CK);
  }

  /***********************************************************************/
  /* */
  /* Note: Default values, if any, must be set up in setup_old_form() */
  /* */
  /***********************************************************************/

  if (gadget_attr.list_draw_flag == 0)
  {
    FIg_set_state_on (Assoc_list_field_form, LIST_DRAW_TOG);

    sprintf (t_str, "%d", gadget_attr.list_num_cols);
    FIfld_set_text (Assoc_list_field_form, LIST_COLS_FLD, 0, 0, t_str, 0);

    sprintf (t_str, "%d", gadget_attr.list_num_rows);
    FIfld_set_text (Assoc_list_field_form, LIST_ROWS_FLD, 0, 0, t_str, 0);

    if (gadget_attr.list_poke_flag == 0)
    {
      FIg_set_state_on (Assoc_list_field_form, LIST_KEYIN_TOG);

      sprintf (t_str, "%d", gadget_attr.list_x_pos);
      FIfld_set_text (Assoc_list_field_form, LIST_X_POS_FLD, 0, 0, t_str, 0);

      sprintf (t_str, "%d", gadget_attr.list_y_pos);
      FIfld_set_text (Assoc_list_field_form, LIST_Y_POS_FLD, 0, 0, t_str, 0);
    }
  }
  else
  {
    FIg_set_state_off (Assoc_list_field_form, LIST_DRAW_TOG);
    FIg_set_state_off (Assoc_list_field_form, LIST_KEYIN_TOG);

    FIg_erase (Assoc_list_field_form, LIST_COLS_FLD);
    FIg_erase (Assoc_list_field_form, LIST_ROWS_FLD);
    FIg_erase (Assoc_list_field_form, LIST_COLS_TEXT);
    FIg_erase (Assoc_list_field_form, LIST_ROWS_TEXT);
    FIg_erase (Assoc_list_field_form, LIST_X_POS_FLD);
    FIg_erase (Assoc_list_field_form, LIST_Y_POS_FLD);
    FIg_erase (Assoc_list_field_form, LIST_X_POS_TEXT);
    FIg_erase (Assoc_list_field_form, LIST_Y_POS_TEXT);

    sprintf (t_str, "%d", gadget_attr.list_num_cols);
    FIfld_set_text (Assoc_list_field_form, LIST_COLS_FLD, 0, 0, t_str, 0);

    sprintf (t_str, "%d", gadget_attr.list_num_rows);
    FIfld_set_text (Assoc_list_field_form, LIST_ROWS_FLD, 0, 0, t_str, 0);

  }

  if (gadget_attr.list_exists_flag == 1)
  {
    if (gadget_attr.list_draw_flag == 0)
    {
      FIg_display (Assoc_list_field_form, LIST_ROWS_TEXT);
      FIg_display (Assoc_list_field_form, LIST_COLS_TEXT);
      FIg_display (Assoc_list_field_form, LIST_ROWS_FLD);
      FIg_display (Assoc_list_field_form, LIST_COLS_FLD);

      if (gadget_attr.list_poke_flag == 0)
      {
        FIg_display (Assoc_list_field_form, LIST_X_POS_TEXT);
        FIg_display (Assoc_list_field_form, LIST_Y_POS_TEXT);
        FIg_display (Assoc_list_field_form, LIST_X_POS_FLD);
        FIg_display (Assoc_list_field_form, LIST_Y_POS_FLD);
      }
    }
  }
  else
  {
    for (x = 13; x < 34; x++)
      FIg_erase (Assoc_list_field_form, x);

    for (x = 35; x < 97; x++)
      FIg_erase (Assoc_list_field_form, x);
  }

  /********************************/
  /* */
  /* Edit options form set-up */
  /* */
  /********************************/

  if (gadget_attr.field_mode == FI_REVIEW)
  {
    FIg_set_state_off (Edit_field_form, EDIT_GROUP_OPTIONS);
    FIg_set_state_on (Edit_field_form, REVIEW_CK);
    FIg_erase (Edit_field_form, REPLACE_TEXT_TOG);
    FIg_erase (Edit_field_form, NOTIFICATION_TOG);
    FIg_erase (Edit_field_form, ECHO_TOG);
  }
  else if (gadget_attr.field_mode == FI_SINGLE_SELECT)
  {
    FIg_set_state_off (Edit_field_form, EDIT_GROUP_OPTIONS);
    FIg_set_state_on (Edit_field_form, SINGLE_SELECT_CK);
    FIg_erase (Edit_field_form, REPLACE_TEXT_TOG);
    FIg_erase (Edit_field_form, NOTIFICATION_TOG);
    FIg_erase (Edit_field_form, ECHO_TOG);
  }
  else if (gadget_attr.field_mode == FI_MULTI_SELECT)
  {
    FIg_set_state_off (Edit_field_form, EDIT_GROUP_OPTIONS);
    FIg_set_state_on (Edit_field_form, MULTI_SELECT_CK);
    FIg_erase (Edit_field_form, REPLACE_TEXT_TOG);
    FIg_erase (Edit_field_form, NOTIFICATION_TOG);
    FIg_erase (Edit_field_form, ECHO_TOG);
  }
  else if (gadget_attr.field_mode == FI_APPEND)
  {
    FIg_set_state_off (Edit_field_form, EDIT_GROUP_OPTIONS);
    FIg_set_state_on (Edit_field_form, CHANGE_CK);
    FIg_display (Edit_field_form, REPLACE_TEXT_TOG);
    FIg_display (Edit_field_form, NOTIFICATION_TOG);
    FIg_display (Edit_field_form, ECHO_TOG);
  }
  else if (gadget_attr.field_mode == FI_INSERT)
  {
    FIg_set_state_off (Edit_field_form, EDIT_GROUP_OPTIONS);
    FIg_set_state_on (Edit_field_form, INSERT_CK);
    FIg_display (Edit_field_form, REPLACE_TEXT_TOG);
    FIg_display (Edit_field_form, NOTIFICATION_TOG);
    FIg_display (Edit_field_form, ECHO_TOG);
  }

  if (gadget_attr.replace_text_flag == 0)
    FIg_set_state_on (Edit_field_form, REPLACE_TEXT_TOG);
  else
    FIg_set_state_off (Edit_field_form, REPLACE_TEXT_TOG);

  if (gadget_attr.line_notification == 1)
    FIg_set_state_on (Edit_field_form, NOTIFICATION_TOG);
  else
    FIg_set_state_off (Edit_field_form, NOTIFICATION_TOG);

  if (gadget_attr.echo_flag == 0)
    FIg_set_state_on (Edit_field_form, ECHO_TOG);
  else
    FIg_set_state_off (Edit_field_form, ECHO_TOG);

  if (gadget_attr.required_flag == 1)
    FIg_set_state_on (Edit_field_form, REQUIRED_TOG);
  else
    FIg_set_state_off (Edit_field_form, REQUIRED_TOG);

  if (gadget_attr.right_to_left == 0)
  {
    FIg_set_state_off (Edit_field_form, RIGHT_TO_LEFT_TOG);
    FIg_erase (Edit_field_form, REVERSE_INPUT_TOG);
    FIg_erase (Edit_field_form, REVERSE_OUTPUT_TOG);
  }
  else
  {
    FIg_set_state_on (Edit_field_form, RIGHT_TO_LEFT_TOG);
    if (gadget_attr.reverse_input_flag == 1)
      FIg_set_state_off (Edit_field_form, REVERSE_INPUT_TOG);
    else
      FIg_set_state_on (Edit_field_form, REVERSE_INPUT_TOG);

    if (gadget_attr.reverse_output_flag == 1)
      FIg_set_state_off (Edit_field_form, REVERSE_OUTPUT_TOG);
    else
      FIg_set_state_on (Edit_field_form, REVERSE_OUTPUT_TOG);

    FIg_display (Edit_field_form, REVERSE_OUTPUT_TOG);
    FIg_display (Edit_field_form, REVERSE_INPUT_TOG);
  }

  /***************************************************/
  /* */
  /* Now fill in information for scroll sub-form */
  /* */
  /***************************************************/

  if (gadget_attr.vert_scroll_flag == 0)
    FIg_set_state_off (Scroll_field_form, DISPLAY_VERT_TOG);
  else
    FIg_set_state_on (Scroll_field_form, DISPLAY_VERT_TOG);

  if (gadget_attr.vert_scroll_notify)
    FIg_set_state_on (Scroll_field_form, VERT_NOTIFY_TOG);
  else
    FIg_set_state_off (Scroll_field_form, VERT_NOTIFY_TOG);

  if (gadget_attr.horz_scroll_flag == 0)
    FIg_set_state_off (Scroll_field_form, DISPLAY_HORZ_TOG);
  else
    FIg_set_state_on (Scroll_field_form, DISPLAY_HORZ_TOG);

  if (gadget_attr.roll_through_flag == 1)
    FIg_set_state_on (Scroll_field_form, ROLL_THROUGH_TOG);
  else
    FIg_set_state_off (Scroll_field_form, ROLL_THROUGH_TOG);

  if (gadget_attr.wrap_flag == 1)
    FIg_set_state_on (Scroll_field_form, WRAP_TOG);
  else
    FIg_set_state_off (Scroll_field_form, WRAP_TOG);

  if (gadget_attr.scroll_mode == NO_SCROLLING)
  {
    FIg_set_state_off (Scroll_field_form, SCROLL_GROUP_OPTIONS);
    FIg_set_state_on (Scroll_field_form, NO_SCROLL_CK);
    FIg_erase (Scroll_field_form, DISPLAY_VERT_TOG);
    FIg_erase (Scroll_field_form, DISPLAY_HORZ_TOG);
    FIg_erase (Scroll_field_form, VERT_NOTIFY_TOG);
  }
  else if (gadget_attr.scroll_mode == VERTICAL_SCROLL_ONLY)
  {
    FIg_set_state_off (Scroll_field_form, SCROLL_GROUP_OPTIONS);
    FIg_set_state_on (Scroll_field_form, VERT_SCROLL_CK);
    FIg_erase (Scroll_field_form, DISPLAY_HORZ_TOG);
    FIg_display (Scroll_field_form, DISPLAY_VERT_TOG);
    if (gadget_attr.vert_scroll_flag == 1)
      FIg_display (Scroll_field_form, VERT_NOTIFY_TOG);
    else
      FIg_erase (Scroll_field_form, VERT_NOTIFY_TOG);
  }
  else if (gadget_attr.scroll_mode == HORIZONTAL_SCROLL_ONLY)
  {
    FIg_set_state_off (Scroll_field_form, SCROLL_GROUP_OPTIONS);
    FIg_set_state_on (Scroll_field_form, HORZ_SCROLL_CK);
    FIg_erase (Scroll_field_form, DISPLAY_VERT_TOG);
    FIg_display (Scroll_field_form, DISPLAY_HORZ_TOG);
    FIg_erase (Scroll_field_form, VERT_NOTIFY_TOG);
  }
  else if (gadget_attr.scroll_mode == BOTH_DIRECTION_SCROLL)
  {
    FIg_set_state_off (Scroll_field_form, SCROLL_GROUP_OPTIONS);
    FIg_set_state_on (Scroll_field_form, BOTH_SCROLL_CK);
    FIg_display (Scroll_field_form, DISPLAY_VERT_TOG);
    FIg_display (Scroll_field_form, DISPLAY_HORZ_TOG);
    if (gadget_attr.vert_scroll_flag == 1)
      FIg_display (Scroll_field_form, VERT_NOTIFY_TOG);
    else
      FIg_erase (Scroll_field_form, VERT_NOTIFY_TOG);
  }
}

/*-----------------------------------------------------------------------*/

/*********************************************************************/
/* */
/* create_field_gadget() */
/* */
/* This function creates a new field gadget and places it at */
/* the position that was specified by the operator. */
/* */
/*********************************************************************/

static void create_field_gadget(void)
{
  int x, y;
  int x_lo, y_lo, x_hi, y_hi;
  int characteristics;
  Window window;	/* change from int to Window for ANSI */
  char t_str[256];
  int num_rows;
  int width, height, font_type;
  Font font_id;
  float dummy_float;
  int rows, columns;
  int state;
  int line_spacing;
  int single_line_mode;
  int group_label;
  int horz_flag, vert_flag, icon_flag;
  int vert_size, icon_size;
  int selectable_flag;
  int dummy_int;
  int status;
 
  long attr;  /* sml:05-07-92  added this for FIfld_get_attr callin ANSI */
 
  /***********************************************************/
  /* */
  /* If the work form and the place field form intersect, */
  /* then send a window update message to the work_form */
  /* */
  /***********************************************************/

  Refresh_work_form();

  /*******************************************************************/
  /* */
  /* Determine the width of each character in the monospaced font */
  /* that the user has selected. */
  /* */
  /*******************************************************************/

  _FI_find_font_id (gadget_attr.font_name, gadget_attr.bodysize,
      &font_id, &dummy_float, FI_FIELD, &font_type);

  _FI_calc_text (font_id, "M", 1, &height, &width, &line_spacing, font_type);

  FIg_get_state (Master_field_form, NUM_LINES_TOG, &state);

  if (state == 0) /* single line */
    single_line_mode = 1;
  else
    single_line_mode = 0;

  if ((gadget_attr.horz_scroll_flag) &&
      ((gadget_attr.scroll_mode == HORIZONTAL_SCROLL_ONLY) ||
      (gadget_attr.scroll_mode == BOTH_DIRECTION_SCROLL)))
    horz_flag = 1;
  else
    horz_flag = 0;

  if ((gadget_attr.vert_scroll_flag) &&
      ((gadget_attr.scroll_mode == VERTICAL_SCROLL_ONLY) ||
      (gadget_attr.scroll_mode == BOTH_DIRECTION_SCROLL)))
    vert_flag = 1;
  else
    vert_flag = 0;

  if (gadget_attr.roll_through_flag ||
      gadget_attr.list_exists_flag)
    icon_flag = 1;
  else
    icon_flag = 0;

  if ((gadget_attr.field_mode == FI_SINGLE_SELECT) ||
      (gadget_attr.field_mode == FI_MULTI_SELECT))
    selectable_flag = 1;
  else
    selectable_flag = 0;

  /****************************************************************/
  /* */
  /* Specify the position and size of the field, either through */
  /* keyin values, or through data point entries. */
  /* */
  /****************************************************************/

  /* dmb:09/16/91:Why multiply by the selectable_flag ?!? */
  /* gmd:09/30/91:Because in Motif, selectable lines are taller than */
  /*              editable lines.  However, since this is not Motif, */
  /*              this modification can be removed safely.           */
/*
  gadget_attr.y_size = gadget_attr.num_rows *
      (line_spacing + (selectable_flag * 2));
*/
  gadget_attr.y_size = gadget_attr.num_rows * line_spacing;
  gadget_attr.x_size = gadget_attr.num_cols * width;

  if (gadget_attr.draw_flag == 0)
  {
    if (gadget_attr.poke_flag == 1) /* Get datapt for field location */
   {
      UMSGetByNum (t_str, FB_P_POKFLD, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

      FIf_get_window (work_form, &window);

      status = Move_field_box (window, &gadget_attr.x_pos,
          &gadget_attr.y_pos,
          gadget_attr.x_size,
          gadget_attr.y_size, 0, 0,
          single_line_mode,
          horz_flag,
          vert_flag,
          icon_flag);

      if (status != 2) /* Operator wants to abort the place */
        return;
    }
  }
  else /* Get two datapoints for size and location of field */
  {
    UMSGetByNum (t_str, FB_P_POKFLDANC, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    FIf_get_window (work_form, &window);

    status = Get_first_point (window, &x, &y, 0, 0, 0, 0);

    if (status == 2) /* Success */
    {
      UMSGetByNum (t_str, FB_I_FLDFNT, "%s%d", gadget_attr.font_name,
          (int)gadget_attr.bodysize);
      FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);
      UMSGetByNum (t_str, FB_P_POKFLDSWG, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

      status = Define_field_box (window, x, y,
          &gadget_attr.x_pos,
          &gadget_attr.y_pos,
          &gadget_attr.x_size,
          &gadget_attr.y_size,
          &rows, &columns, width, line_spacing,
          single_line_mode,
          horz_flag,
          vert_flag,
          icon_flag,
          selectable_flag);

      if (status == 2) /* Success */
      {
        gadget_attr.x_size -= gadget_attr.x_pos;
        gadget_attr.y_size -= gadget_attr.y_pos;

        gadget_attr.num_rows = rows;
        gadget_attr.num_cols = columns;
      }
      else /* Operator wants to abort the place */
        return;
    }
    else /* Operator wants to abort the place */
      return;
  }

  /*******************************************************************/
  /* */
  /* If an associated list is defined for this field then it must */
  /* be placed in the exact same manner that the regular field was. */
  /* */
  /*******************************************************************/

  if (gadget_attr.list_exists_flag == 1)
  {
    gadget_attr.list_ysize = gadget_attr.list_num_rows * line_spacing;
    gadget_attr.list_xsize = gadget_attr.list_num_cols * width;

    if (gadget_attr.list_draw_flag == 0)
    {
      if (gadget_attr.list_poke_flag == 1) /* Datapt for assoc list loc. */
      {
        Window window;
        int (*my_translate_color)();

        UMSGetByNum (t_str, FB_P_POKASSLST, 0);
        FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

        FIf_get_window (work_form, &window);

        x_lo = gadget_attr.x_pos;
        y_lo = gadget_attr.y_pos;
        x_hi = gadget_attr.x_pos + (gadget_attr.num_cols * width) + 10;
        y_hi = gadget_attr.y_pos + (gadget_attr.num_rows * line_spacing) + 4;

        XSetSubwindowMode (display, xfb_GC, IncludeInferiors);
        FI_get_env (FI_TRANSLATE_COLOR, &my_translate_color);
        XSetForeground (display, xfb_GC, (*my_translate_color)( 0, FI_WHITE ));
        _FI_draw_box (window, x_lo, y_lo, x_hi, y_hi);

        if (icon_flag)
          icon_size = 15;
        else
          icon_size = 0;

        vert_size = 15;

        if (horz_flag)
        {
          _FI_draw_box (window, x_lo, y_hi, x_hi, y_hi + 15);
        }

        if (icon_flag)
        {
          _FI_draw_box (window, x_hi, y_lo, x_hi + 15, y_hi);
        }

        if (vert_flag)
        {
          _FI_draw_box (window, x_hi + icon_size, y_lo,
              x_hi + icon_size + vert_size, y_hi);
        }

        XFlush (display);

        horz_flag = gadget_attr.list_horz_flag;
        vert_flag = gadget_attr.list_vert_flag;
        icon_flag = 0;

        status = Move_field_box (window, &gadget_attr.list_x_pos,
            &gadget_attr.list_y_pos,
            gadget_attr.list_xsize,
            gadget_attr.list_ysize, 0, 0,
            0,
            horz_flag,
            vert_flag,
            icon_flag);

        if (status != 2) /* Operator wants to abort the place */
        {
          Redisplay (work_form);
          return;
        }
      }
    }
    else /* Get two datapoints for size and location of associated list */
    {
      Window window;
      int (*my_translate_color)();

      UMSGetByNum (t_str, FB_P_POKLSTANC, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

      FIf_get_window (work_form, &window);

      x_lo = gadget_attr.x_pos;
      y_lo = gadget_attr.y_pos;
      x_hi = gadget_attr.x_pos + (gadget_attr.num_cols * width) + 10;
      y_hi = gadget_attr.y_pos + (gadget_attr.num_rows * line_spacing) + 4;

      XSetSubwindowMode (display, xfb_GC, IncludeInferiors);
      FI_get_env (FI_TRANSLATE_COLOR, &my_translate_color);
      XSetForeground (display, xfb_GC, (*my_translate_color)( 0, FI_WHITE ));
      _FI_draw_box (window, x_lo, y_lo, x_hi, y_hi);

      if (icon_flag)
        icon_size = 15;
      else
        icon_size = 0;

      vert_size = 15;

      if (horz_flag)
      {
        _FI_draw_box (window, x_lo, y_hi, x_hi, y_hi + 15);
      }

      if (icon_flag)
      {
        _FI_draw_box (window, x_hi, y_lo, x_hi + 15, y_hi);
      }

      if (vert_flag)
      {
        _FI_draw_box (window, x_hi + icon_size, y_lo,
            x_hi + icon_size + vert_size, y_hi);
      }

      XFlush (display);

      status = Get_first_point (window, &x, &y, 0, 0, 0, 0);

      if (status == 2) /* Success */
      {
        UMSGetByNum (t_str, FB_I_FLDFNT, "%s%d", gadget_attr.font_name,
            (int)gadget_attr.bodysize);
        FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);
        UMSGetByNum (t_str, FB_P_POKLSTSWG, 0);
        FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

        state = 0; /* Multiple lines for assoc list */

        horz_flag = gadget_attr.list_horz_flag;
        vert_flag = gadget_attr.list_vert_flag;
        icon_flag = 0;

        status = Define_field_box (window, x, y,
            &x_lo, &y_lo, &x_hi, &y_hi,
            &rows, &columns, width, line_spacing, 0,
            horz_flag,
            vert_flag,
            icon_flag,
            1); /* list is selectable */

        if (status == 2) /* Success */
        {
          gadget_attr.list_x_pos = x_lo;
          gadget_attr.list_y_pos = y_lo;
          gadget_attr.list_xsize = x_hi - x_lo;
          gadget_attr.list_ysize = y_hi - y_lo;
        }
        else /* Operator wants to abort the place operation */
        {
          Redisplay (work_form);
          return;
        }
      }
      else /* Operator wants to abort the place operation */
      {
        Redisplay (work_form);
        return;
      }
    }
  }

  gadget_attr.x_size += gadget_attr.x_pos;
  gadget_attr.y_size += gadget_attr.y_pos;

  if (command_is_active == EDIT_GADGET)
  {
    FIg_get_group_label (work_form, old_gadget_label, &group_label);
    FIg_erase (work_form, old_gadget_label);
    status = FIg_delete (work_form, old_gadget_label);

    old_gadget_label = -1;
  }
  else
    group_label = 0;

  Create_and_init_gadget (work_form, FI_FIELD, gadget_attr.gadget_label);

  if (group_label != 0)
    FIg_add_to_group (work_form, gadget_attr.gadget_label, group_label);

  characteristics = 0;

  if (gadget_attr.right_to_left == 1)
  {
    characteristics |= FI_RIGHT_TO_LEFT;
    if (gadget_attr.reverse_input_flag)
      characteristics |= FI_REVERSE_INPUT;
    if (gadget_attr.reverse_output_flag)
      characteristics |= FI_REVERSE_OUTPUT;
  }

  if (gadget_attr.scroll_mode == VERTICAL_SCROLL_ONLY)
    characteristics |= FI_VERT_SCROLL;

  if (gadget_attr.scroll_mode == HORIZONTAL_SCROLL_ONLY)
    characteristics |= FI_HORT_SCROLL;

  if (gadget_attr.scroll_mode == BOTH_DIRECTION_SCROLL)
  {
    characteristics |= FI_VERT_SCROLL;
    characteristics |= FI_HORT_SCROLL;
  }

  if (((gadget_attr.scroll_mode == VERTICAL_SCROLL_ONLY) ||
      (gadget_attr.scroll_mode == BOTH_DIRECTION_SCROLL)) &&
      (gadget_attr.vert_scroll_flag == 1))
  {
    characteristics |= FI_DISPLAY_VSCROLL;
  }

  if (((gadget_attr.scroll_mode == HORIZONTAL_SCROLL_ONLY) ||
      (gadget_attr.scroll_mode == BOTH_DIRECTION_SCROLL)) &&
      (gadget_attr.horz_scroll_flag == 1))
  {
    characteristics |= FI_DISPLAY_HSCROLL;
  }

  if (gadget_attr.wrap_flag == 1)
    characteristics |= FI_WRAP;

  if (gadget_attr.required_flag == 1)
    characteristics |= FI_REQUIRED;

  if (gadget_attr.roll_through_flag == 1)
    characteristics |= FI_ROLL_THRU;

  if (gadget_attr.replace_text_flag == 0)
    characteristics |= FI_CLEAR_ON_SELECTION;

  if (gadget_attr.line_notification == 1)
    characteristics |= FI_NOTIFY_BY_LINE;

  if (gadget_attr.echo_flag == 0)
    characteristics |= FI_NO_ECHO;

  if (gadget_attr.list_exists_flag == 1)
  {
    characteristics |= FI_ASSOCIATED_LIST;

    if (gadget_attr.list_verify_flag == 1)
      characteristics |= FI_VALIDATE_BY_LIST;

    if (gadget_attr.list_display_flag == 0)
    {
      characteristics |= FI_POPUP_ASSO_LIST;
    }

    if (gadget_attr.list_mode == 3)
      characteristics |= FI_DISMISS_LIST_ON_SEL;
  }


  FIfld_set_attr (work_form, gadget_attr.gadget_label, 0, characteristics);

  FIfld_get_attr (work_form, gadget_attr.gadget_label, 0, &attr);


  status = FIfld_set_mode (work_form, gadget_attr.gadget_label, 0,
      gadget_attr.field_mode);

  FIfld_set_type (work_form, gadget_attr.gadget_label, 0,
      gadget_attr.field_type);

  if (gadget_attr.list_exists_flag == 1)
  {

    status = FIfld_set_list_size (work_form, gadget_attr.gadget_label, 0,
        gadget_attr.list_xsize,
        gadget_attr.list_ysize);

    status = FIfld_set_list_location (work_form, gadget_attr.gadget_label, 0,
        gadget_attr.list_x_pos,
        gadget_attr.list_y_pos);

    if ((gadget_attr.list_mode == 1) ||
        (gadget_attr.list_mode == 3))
      FIfld_set_list_mode (work_form, gadget_attr.gadget_label, 0,
          FI_SINGLE_SELECT);

    if (gadget_attr.list_mode == 2)
      FIfld_set_list_mode (work_form, gadget_attr.gadget_label, 0,
          FI_MULTI_SELECT);
  }

  status = FIg_set_high_value (work_form, gadget_attr.gadget_label,
      gadget_attr.maximum_value);

  status = FIg_set_low_value (work_form, gadget_attr.gadget_label,
      gadget_attr.minimum_value);

  FIfld_set_num_vis_chars (work_form, gadget_attr.gadget_label, 0,
      gadget_attr.num_cols);
  FIfld_set_num_vis_rows (work_form, gadget_attr.gadget_label,
      gadget_attr.num_rows);

  status = FIg_activate (work_form, gadget_attr.gadget_label);

  FIg_set_justification (work_form, gadget_attr.gadget_label,
      gadget_attr.text_justification);

  FIfld_set_format_string (work_form, gadget_attr.gadget_label, 0,
      gadget_attr.on_text);

  /************************************************/
  /* */
  /* Now fill in any default text for the field */
  /* */
  /************************************************/

  FIg_get_state (Master_field_form, NUM_LINES_TOG, &state);

  if ((state == 0) &&
      (gadget_attr.roll_through_flag == 0) &&
      ((gadget_attr.scroll_mode == NO_SCROLLING) ||
      (gadget_attr.scroll_mode == HORIZONTAL_SCROLL_ONLY)))
  {
    FIfld_get_text (Verify_field_form, DEFAULT_STR_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    if (strlen (t_str) != 0)
      status = FIfld_set_default_text (work_form,
          gadget_attr.gadget_label, 0, 0, t_str, 0);

  }
  else
  {
    FIfld_get_num_rows (Verify_field_form, INITIAL_VALUES_FLD, &num_rows);

    for (x = 0; x < num_rows; x++)
    {
      if ((gadget_attr.roll_through_flag == 1) ||
          (gadget_attr.scroll_mode == VERTICAL_SCROLL_ONLY) ||
          (gadget_attr.scroll_mode == BOTH_DIRECTION_SCROLL) ||
          (x < gadget_attr.num_rows))
      {

        FIfld_get_text (Verify_field_form, INITIAL_VALUES_FLD, x,
            0, 255, (unsigned char *)t_str, &dummy_int, &dummy_int);

        status = FIfld_set_default_text (work_form, 
            gadget_attr.gadget_label, x, 0, t_str, 0);

        status = FIfld_set_text (work_form, gadget_attr.gadget_label,
            x, 0, t_str, 0);
      }
    }
  }

  if (gadget_attr.list_exists_flag == 1)
  {
    FIfld_get_num_rows (Assoc_list_field_form, LIST_VALUES_FLD, &num_rows);

    for (x = 0; x < num_rows; x++)
    {
      FIfld_get_text (Assoc_list_field_form, LIST_VALUES_FLD,
          x, 0, 255, (unsigned char *)t_str, &dummy_int, &dummy_int);

      FIfld_set_list_default_text (work_form,
          gadget_attr.gadget_label, x, 0, t_str, 0);
    }
  }

  if (gadget_attr.selectable == 0)
  {
    FIg_enable (work_form, gadget_attr.gadget_label);
    FIg_disable (work_form, gadget_attr.gadget_label);
  }

  if (gadget_attr.hilite == 1)
  {
    FIg_unhilite (work_form, gadget_attr.gadget_label);
    FIg_hilite (work_form, gadget_attr.gadget_label);
  }

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

  FIfld_set_list_scroll (work_form, gadget_attr.gadget_label,
      gadget_attr.list_vert_flag,
      gadget_attr.list_horz_flag);

  if (gadget_attr.display == 1)
    FIg_display (work_form, gadget_attr.gadget_label);
  else
    FIg_erase (work_form, gadget_attr.gadget_label);

  FIfld_set_list_scroll (work_form, gadget_attr.gadget_label,
      gadget_attr.list_vert_flag,
      gadget_attr.list_horz_flag);

  /*
FIf_calculate_size (work_form);
*/
}

/*************************************************************************/
/* */
/* fi_assoc_list_field_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the default */
/* settings for a new field gadget, or alter the settings of an */
/* existing field gadget. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_assoc_list_field_form (int form_label,
                              int gadget_label,
                              double value,
                              Form form_ptr)
{
  int i, x;
  char t_str[256];
  int dummy_int;
  int status;

  FIg_erase (Assoc_list_field_form, LIST_ERR_FLD);

  switch (gadget_label)
  {
  case VERT_SCROLL_TOG:

    FIg_get_state (Assoc_list_field_form, VERT_SCROLL_TOG, &i);
    if (i)
      gadget_attr.list_vert_flag = 0;
    else
      gadget_attr.list_vert_flag = 1;
    break;

  case HORZ_SCROLL_TOG:

    FIg_get_state (Assoc_list_field_form, HORZ_SCROLL_TOG, &i);
    if (i)
      gadget_attr.list_horz_flag = 0;
    else
      gadget_attr.list_horz_flag = 1;
    break;

  case DEFINE_LIST_TOG:

    if ((int)value == 1)
    {
      int field_is_selectable, state;

      field_is_selectable = 0;
      FIg_get_state (Edit_field_form, SINGLE_SELECT_CK, &state);
      if (state == 1)
        field_is_selectable = 1;
      FIg_get_state (Edit_field_form, MULTI_SELECT_CK, &state);
      if (state == 1)
        field_is_selectable = 1;

      if (gadget_attr.roll_through_flag == 1)
      {
        FIg_set_state_off (Assoc_list_field_form, DEFINE_LIST_TOG);

        UMSGetByNum (t_str, FB_E_ROLLTHRUINV, 0);
        print_error (Assoc_list_field_form, LIST_ERR_FLD, t_str);
      }
      else if (field_is_selectable)
      {
        FIg_set_state_off (Assoc_list_field_form, DEFINE_LIST_TOG);

        UMSGetByNum (t_str, FB_E_NOTWITHSELECT, 0);
        print_error (Assoc_list_field_form, LIST_ERR_FLD, t_str);
      }
      else
      {
        gadget_attr.list_exists_flag = 1;

        for (x=14; x < 23; x++)
          FIg_display (Assoc_list_field_form, x);

        FIg_display (Assoc_list_field_form, 27);
        FIg_display (Assoc_list_field_form, 28);
        FIg_display (Assoc_list_field_form, 30);
        FIg_display (Assoc_list_field_form, 34);
        FIg_display (Assoc_list_field_form, 35);

        for (x=37; x < 97; x++)
          FIg_display (Assoc_list_field_form, x);

        FIg_display (Assoc_list_field_form, 18);

        if (gadget_attr.list_draw_flag == 0)
        {
          FIg_display (Assoc_list_field_form, LIST_ROWS_TEXT);
          FIg_display (Assoc_list_field_form, LIST_COLS_TEXT);
          FIg_display (Assoc_list_field_form, LIST_ROWS_FLD);
          FIg_display (Assoc_list_field_form, LIST_COLS_FLD);

          if (gadget_attr.list_poke_flag == 0)
          {
            FIg_display (Assoc_list_field_form, LIST_X_POS_TEXT);
            FIg_display (Assoc_list_field_form, LIST_Y_POS_TEXT);
            FIg_display (Assoc_list_field_form, LIST_X_POS_FLD);
            FIg_display (Assoc_list_field_form, LIST_Y_POS_FLD);
          }
        }
      }
    }
    else
    {
      gadget_attr.list_exists_flag = 0;
      FIg_set_state_off (Verify_field_form, VERIFY_LIST_TOG);
      gadget_attr.list_verify_flag = 0;

      for (x=13; x < 34; x++)
        FIg_erase (Assoc_list_field_form, x);

      for (x=35; x < 97; x++)
        FIg_erase (Assoc_list_field_form, x);
    }
    break;

  case LIST_DISPLAY_TOG:

    if ((int)value == 0)
    {
      gadget_attr.list_display_flag = 1;
    }
    else
    {
      gadget_attr.list_display_flag = 0;
    }
    break;

  case LIST_DRAW_TOG:

    if ((int)value == 0) /* DRAW mode */
    {
      gadget_attr.list_draw_flag = 1;
      gadget_attr.list_poke_flag = 0;

      FIg_erase (Assoc_list_field_form, LIST_ROWS_TEXT);
      FIg_erase (Assoc_list_field_form, LIST_COLS_TEXT);
      FIg_erase (Assoc_list_field_form, LIST_ROWS_FLD);
      FIg_erase (Assoc_list_field_form, LIST_COLS_FLD);

      FIg_set_state_off (Assoc_list_field_form, LIST_KEYIN_TOG);

      FIg_erase (Assoc_list_field_form, LIST_X_POS_TEXT);
      FIg_erase (Assoc_list_field_form, LIST_Y_POS_TEXT);
      FIg_erase (Assoc_list_field_form, LIST_X_POS_FLD);
      FIg_erase (Assoc_list_field_form, LIST_Y_POS_FLD);
    }
    else /* Specify rows/columns */
    {
      gadget_attr.list_draw_flag = 0;
      gadget_attr.list_poke_flag = 1;

      FIg_display (Assoc_list_field_form, LIST_ROWS_TEXT);
      FIg_display (Assoc_list_field_form, LIST_COLS_TEXT);
      FIg_display (Assoc_list_field_form, LIST_ROWS_FLD);
      FIg_display (Assoc_list_field_form, LIST_COLS_FLD);
    }
    break;

  case LIST_KEYIN_TOG:

    if ((int)value == 0)
    {
      if (gadget_attr.list_draw_flag != 1)
      {
        gadget_attr.list_poke_flag = 1;

        FIg_erase (Assoc_list_field_form, LIST_X_POS_TEXT);
        FIg_erase (Assoc_list_field_form, LIST_Y_POS_TEXT);
        FIg_erase (Assoc_list_field_form, LIST_X_POS_FLD);
        FIg_erase (Assoc_list_field_form, LIST_Y_POS_FLD);
      }
    }
    else /* Switch to keyin mode */
    {
      if (gadget_attr.list_draw_flag == 1)
      {
        FIg_set_state_off (Assoc_list_field_form, LIST_KEYIN_TOG);

        FIg_display (Assoc_list_field_form, LIST_ERR_FLD);

        UMSGetByNum (t_str, FB_E_MSTETRDTP, 0);
        FIfld_set_text (Assoc_list_field_form, LIST_ERR_FLD, 0, 0,
            t_str, 0);
      }
      else
      {
        gadget_attr.list_poke_flag = 0;

        FIg_display (Assoc_list_field_form, LIST_X_POS_TEXT);
        FIg_display (Assoc_list_field_form, LIST_Y_POS_TEXT);
        FIg_display (Assoc_list_field_form, LIST_X_POS_FLD);
        FIg_display (Assoc_list_field_form, LIST_Y_POS_FLD);
      }
    }
    break;


  case LIST_ROWS_FLD:

    FIfld_get_text (Assoc_list_field_form, LIST_ROWS_FLD, 0, 0,
        255, (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Assoc_list_field_form,
        LIST_ERR_FLD, &status);

    if (status)
      if (i > 0) /* Valid input */
      {
        if (i == 1)
        {
          gadget_attr.list_num_rows = 1;
        }
        else
        {
          gadget_attr.list_num_rows = i;
        }
      }
      else
      {
        UMSGetByNum (t_str, FB_E_ROWSGTZERO, 0);
        print_error (Assoc_list_field_form, LIST_ERR_FLD, t_str);
      }
    break;

  case LIST_COLS_FLD:

    FIfld_get_text (Assoc_list_field_form, LIST_COLS_FLD, 0, 0,
        255, (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Assoc_list_field_form,
        LIST_ERR_FLD, &status);

    if (status)
      if (i > 0) /* Valid input */
      {
        gadget_attr.list_num_cols = i;
      }
      else
      {
        UMSGetByNum (t_str, FB_E_COLSGTZERO, 0);
        print_error (Assoc_list_field_form, LIST_ERR_FLD, t_str);
      }
    break;

  case LIST_X_POS_FLD:

    FIfld_get_text (Assoc_list_field_form, LIST_X_POS_FLD, 0, 0,
        255, (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Assoc_list_field_form,
        LIST_ERR_FLD, &status);
    if (status)
      if (i >= 0)
        gadget_attr.list_x_pos = i;
      else
      {
        UMSGetByNum (t_str, FB_E_XNOTNEG, 0);
        print_error (Assoc_list_field_form, LIST_ERR_FLD, t_str);
      }
    break;

  case LIST_Y_POS_FLD:

    FIfld_get_text (Assoc_list_field_form, LIST_Y_POS_FLD, 0, 0,
        255, (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Assoc_list_field_form,
        LIST_ERR_FLD, &status);

    if (status)
      if (i >= 0)
        gadget_attr.list_y_pos = i;
      else
      {
        UMSGetByNum (t_str, FB_E_YNOTNEG, 0);
        print_error (Assoc_list_field_form, LIST_ERR_FLD, t_str);
      }
    break;

  case SINGLE_SELECT_RESELECT_CK:

    FIg_set_state_on (Assoc_list_field_form, SINGLE_SELECT_RESELECT_CK);

    gadget_attr.list_mode = 1; /* Change this to CONSTANT later */
    break;

  case MULTI_SELECT_LIST_CK:

    FIg_set_state_on (Assoc_list_field_form, MULTI_SELECT_LIST_CK);

    gadget_attr.list_mode = 2; /* Change this to CONSTANT later */
    break;

  case SINGLE_SELECT_DISMISS_CK:

    FIg_set_state_on (Assoc_list_field_form, SINGLE_SELECT_DISMISS_CK);

    gadget_attr.list_mode = 3; /* Change this to CONSTANT later */
    break;
  }

  return;
}

/*************************************************************************/
/* */
/* fi_edit_field_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the default */
/* settings for a new field gadget, or alter the settings of an */
/* existing field gadget. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_edit_field_form (int form_label,
                        int gadget_label,
                        double value,
                        Form form_ptr)
{
  char t_str[256];

  FIg_erase (Edit_field_form, EDIT_ERR_FLD);

  switch (gadget_label)
  {
  case REVIEW_CK:

    if (gadget_attr.roll_through_flag == 1)
    {
      FIg_set_state_off (Edit_field_form, REVIEW_CK);
      FIg_set_state_on (Edit_field_form, SINGLE_SELECT_CK);

      UMSGetByNum (t_str, FB_E_REWINVROLL, 0);
      print_error (Edit_field_form, EDIT_ERR_FLD, t_str);
    }
    else
    {
      FIg_erase (Edit_field_form, REPLACE_TEXT_TOG);
      FIg_erase (Edit_field_form, NOTIFICATION_TOG);
      FIg_erase (Edit_field_form, ECHO_TOG);
      gadget_attr.field_mode = FI_REVIEW;
    }
    break;

  case SINGLE_SELECT_CK:

    FIg_erase (Edit_field_form, REPLACE_TEXT_TOG);
    FIg_erase (Edit_field_form, NOTIFICATION_TOG);
    FIg_erase (Edit_field_form, ECHO_TOG);
    gadget_attr.field_mode = FI_SINGLE_SELECT;
    break;

  case MULTI_SELECT_CK:

    if (gadget_attr.roll_through_flag == 1)
    {
      FIg_set_state_off (Edit_field_form, MULTI_SELECT_CK);
      FIg_set_state_on (Edit_field_form, SINGLE_SELECT_CK);

      UMSGetByNum (t_str, FB_E_MULINVROLL, 0);
      print_error (Edit_field_form, EDIT_ERR_FLD, t_str);
    }
    else
    {
      FIg_erase (Edit_field_form, REPLACE_TEXT_TOG);
      FIg_erase (Edit_field_form, NOTIFICATION_TOG);
      FIg_erase (Edit_field_form, ECHO_TOG);
      gadget_attr.field_mode = FI_MULTI_SELECT;
    }
    break;

  case CHANGE_CK:

    if (gadget_attr.roll_through_flag == 1)
    {
      FIg_set_state_off (Edit_field_form, CHANGE_CK);
      FIg_set_state_on (Edit_field_form, SINGLE_SELECT_CK);

      UMSGetByNum (t_str, FB_E_CHAINVROLL, 0);
      print_error (Edit_field_form, EDIT_ERR_FLD, t_str);
    }
    else
    {
      FIg_display (Edit_field_form, REPLACE_TEXT_TOG);
      FIg_display (Edit_field_form, NOTIFICATION_TOG);
      FIg_display (Edit_field_form, ECHO_TOG);
      gadget_attr.field_mode = FI_APPEND;
    }
    break;

  case INSERT_CK:

    if (gadget_attr.roll_through_flag == 1)
    {
      FIg_set_state_off (Edit_field_form, INSERT_CK);
      FIg_set_state_on (Edit_field_form, SINGLE_SELECT_CK);

      UMSGetByNum (t_str, FB_E_INSINVROLL, 0);
      print_error (Edit_field_form, EDIT_ERR_FLD, t_str);
    }
    else
    {
      FIg_display (Edit_field_form, REPLACE_TEXT_TOG);
      FIg_display (Edit_field_form, NOTIFICATION_TOG);
      FIg_display (Edit_field_form, ECHO_TOG);
      gadget_attr.field_mode = FI_INSERT;
    }
    break;

  case REPLACE_TEXT_TOG:

    if ((int)value == 0)
      gadget_attr.replace_text_flag = 1;
    else
      gadget_attr.replace_text_flag = 0;
    break;

  case NOTIFICATION_TOG:

    gadget_attr.line_notification = (int)value;
    break;

  case ECHO_TOG:

    if ((int)value == 0)
    {
      gadget_attr.echo_flag = 1;
    }
    else
    {
      if (gadget_attr.num_rows != 1)
      {
        FIg_set_state_off (Edit_field_form, ECHO_TOG);
        UMSGetByNum (t_str, FB_E_ECHSNGLNE, 0);
        print_error (Edit_field_form, EDIT_ERR_FLD, t_str);
      }
      else if (gadget_attr.replace_text_flag == 1)
      {
        FIg_set_state_off (Edit_field_form, ECHO_TOG);
        UMSGetByNum (t_str, FB_E_ECHCLRONSEL, 0);
        print_error (Edit_field_form, EDIT_ERR_FLD, t_str);
      }
      else if (gadget_attr.list_exists_flag == 1)
      {
        FIg_set_state_off (Edit_field_form, ECHO_TOG);
        UMSGetByNum (t_str, FB_E_ECHNOLST, 0);
        print_error (Edit_field_form, EDIT_ERR_FLD, t_str);
      }
      else
        gadget_attr.echo_flag = 0;
    }
    break;

  case REQUIRED_TOG:

    gadget_attr.required_flag = (int)value;
    break;

  case FI_HELP:

    break;

  case RIGHT_TO_LEFT_TOG:
    gadget_attr.right_to_left = (int) value;

    if ((int)value == 0)
    {
      FIg_erase (Edit_field_form, REVERSE_INPUT_TOG);
      FIg_erase (Edit_field_form, REVERSE_OUTPUT_TOG);
    }
    else
    {
      if (gadget_attr.reverse_input_flag == 1)
        FIg_set_state_off (Edit_field_form, REVERSE_INPUT_TOG);
      else
        FIg_set_state_on (Edit_field_form, REVERSE_INPUT_TOG);

      if (gadget_attr.reverse_output_flag == 1)
        FIg_set_state_off (Edit_field_form, REVERSE_OUTPUT_TOG);
      else
        FIg_set_state_on (Edit_field_form, REVERSE_OUTPUT_TOG);

      FIg_display (Edit_field_form, REVERSE_OUTPUT_TOG);
      FIg_display (Edit_field_form, REVERSE_INPUT_TOG);
    }
    break;

  case REVERSE_INPUT_TOG:
    if ((int)value == 0)
      gadget_attr.reverse_input_flag = 1;
    else
      gadget_attr.reverse_input_flag = 0;
    break;

  case REVERSE_OUTPUT_TOG:
    if ((int)value == 0)
      gadget_attr.reverse_output_flag = 1;
    else
      gadget_attr.reverse_output_flag = 0;
    break;
  }
  return;
}

/*************************************************************************/
/* */
/* fi_scroll_field_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the default */
/* settings for a new field gadget, or alter the settings of an */
/* existing field gadget. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_scroll_field_form (int form_label,
                          int gadget_label,
                          double value,
                          Form form_ptr)
{
  char t_str[256];
  int status;

  FIg_erase (Scroll_field_form, SCROLL_ERR_FLD);

  switch (gadget_label)
  {
  case NO_SCROLL_CK:

    FIg_set_state_on (Scroll_field_form, NO_SCROLL_CK);
    FIg_set_state_off (Scroll_field_form, VERT_SCROLL_CK);
    FIg_set_state_off (Scroll_field_form, HORZ_SCROLL_CK);
    FIg_set_state_off (Scroll_field_form, BOTH_SCROLL_CK);

    FIg_erase (Scroll_field_form, DISPLAY_VERT_TOG);
    FIg_erase (Scroll_field_form, DISPLAY_HORZ_TOG);
    FIg_erase (Scroll_field_form, VERT_NOTIFY_TOG);

    gadget_attr.scroll_mode = NO_SCROLLING;

    FIg_get_state (Master_field_form, NUM_LINES_TOG, &status);

    if (status == 0)
    {
      status = FIg_erase (Verify_field_form, INITIAL_TEXT);

      FIg_erase (Verify_field_form, INITIAL_VALUES_FLD);
      FIg_display (Verify_field_form, DEF_TEXT);
      FIg_display (Verify_field_form, DEFAULT_STR_FLD);
    }
    break;

  case VERT_SCROLL_CK:

    if (gadget_attr.roll_through_flag == 1)
    {
      FIg_set_state_off (Scroll_field_form, VERT_SCROLL_CK);

      UMSGetByNum (t_str, FB_E_VRTINVROLL, 0);
      print_error (Scroll_field_form, SCROLL_ERR_FLD, t_str);

      if (gadget_attr.scroll_mode == NO_SCROLLING)
        FIg_set_state_on (Scroll_field_form, NO_SCROLL_CK);
      else if (gadget_attr.scroll_mode == HORIZONTAL_SCROLL_ONLY)
        FIg_set_state_on (Scroll_field_form, HORZ_SCROLL_CK);
    }
    else
    {
      FIg_set_state_on (Scroll_field_form, VERT_SCROLL_CK);
      FIg_set_state_off (Scroll_field_form, HORZ_SCROLL_CK);
      FIg_set_state_off (Scroll_field_form, BOTH_SCROLL_CK);
      FIg_set_state_off (Scroll_field_form, NO_SCROLL_CK);

      FIg_display (Scroll_field_form, DISPLAY_VERT_TOG);
      FIg_erase (Scroll_field_form, DISPLAY_HORZ_TOG);
      if (gadget_attr.vert_scroll_flag == 1)
        FIg_display (Scroll_field_form, VERT_NOTIFY_TOG);
      else
        FIg_erase (Scroll_field_form, VERT_NOTIFY_TOG);

      gadget_attr.scroll_mode = VERTICAL_SCROLL_ONLY;

      FIg_erase (Verify_field_form, DEF_TEXT);
      FIg_erase (Verify_field_form, DEFAULT_STR_FLD);
      FIg_display (Verify_field_form, INITIAL_TEXT);
      FIg_display (Verify_field_form, INITIAL_VALUES_FLD);
    }
    break;

  case HORZ_SCROLL_CK:

    if (gadget_attr.wrap_flag == 1)
    {
      FIg_set_state_off (Scroll_field_form, HORZ_SCROLL_CK);

      UMSGetByNum (t_str, FB_E_HORZINVWRP, 0);
      print_error (Scroll_field_form, SCROLL_ERR_FLD, t_str);

      if (gadget_attr.scroll_mode == VERTICAL_SCROLL_ONLY)
        FIg_set_state_on (Scroll_field_form, VERT_SCROLL_CK);
      else if (gadget_attr.scroll_mode == NO_SCROLLING)
        FIg_set_state_on (Scroll_field_form, NO_SCROLL_CK);
    }
    else if ((temp_dpb.text_justification == FI_CENTER_JUSTIFIED) ||
        (temp_dpb.text_justification == FI_RIGHT_JUSTIFIED))
    {
      FIg_set_state_off (Scroll_field_form, HORZ_SCROLL_CK);

      UMSGetByNum (t_str, FB_E_HORZINVJUST, 0);
      print_error (Scroll_field_form, SCROLL_ERR_FLD, t_str);

      if (gadget_attr.scroll_mode == VERTICAL_SCROLL_ONLY)
        FIg_set_state_on (Scroll_field_form, VERT_SCROLL_CK);
      else if (gadget_attr.scroll_mode == NO_SCROLLING)
        FIg_set_state_on (Scroll_field_form, NO_SCROLL_CK);
    }
    else
    {
      FIg_set_state_on (Scroll_field_form, HORZ_SCROLL_CK);
      FIg_set_state_off (Scroll_field_form, VERT_SCROLL_CK);
      FIg_set_state_off (Scroll_field_form, BOTH_SCROLL_CK);
      FIg_set_state_off (Scroll_field_form, NO_SCROLL_CK);

      FIg_display (Scroll_field_form, DISPLAY_HORZ_TOG);
      FIg_erase (Scroll_field_form, DISPLAY_VERT_TOG);
      FIg_erase (Scroll_field_form, VERT_NOTIFY_TOG);

      gadget_attr.scroll_mode = HORIZONTAL_SCROLL_ONLY;

      FIg_get_state (Master_field_form, NUM_LINES_TOG, &status);

      if (status == 0)
      {
        status = FIg_erase (Verify_field_form, INITIAL_TEXT);

        FIg_erase (Verify_field_form, INITIAL_VALUES_FLD);
        FIg_display (Verify_field_form, DEF_TEXT);
        FIg_display (Verify_field_form, DEFAULT_STR_FLD);
      }
      else
      {
        FIg_erase (Verify_field_form, DEF_TEXT);
        FIg_erase (Verify_field_form, DEFAULT_STR_FLD);
        FIg_display (Verify_field_form, INITIAL_TEXT);
        FIg_display (Verify_field_form, INITIAL_VALUES_FLD);
      }
    }
    break;

  case BOTH_SCROLL_CK:

    if (gadget_attr.wrap_flag == 1)
    {
      FIg_set_state_off (Scroll_field_form, BOTH_SCROLL_CK);

      UMSGetByNum (t_str, FB_E_HORZINVWRP, 0);
      print_error (Scroll_field_form, SCROLL_ERR_FLD, t_str);

      if (gadget_attr.scroll_mode == VERTICAL_SCROLL_ONLY)
        FIg_set_state_on (Scroll_field_form, VERT_SCROLL_CK);
      else if (gadget_attr.scroll_mode == NO_SCROLLING)
        FIg_set_state_on (Scroll_field_form, NO_SCROLL_CK);
    }
    else if (gadget_attr.roll_through_flag == 1)
    {
      FIg_set_state_off (Scroll_field_form, BOTH_SCROLL_CK);

      UMSGetByNum (t_str, FB_E_VRTINVROLL, 0);
      print_error (Scroll_field_form, SCROLL_ERR_FLD, t_str);

      if (gadget_attr.scroll_mode == NO_SCROLLING)
        FIg_set_state_on (Scroll_field_form, NO_SCROLL_CK);
      else if (gadget_attr.scroll_mode == HORIZONTAL_SCROLL_ONLY)
        FIg_set_state_on (Scroll_field_form, HORZ_SCROLL_CK);
    }
    else if ((temp_dpb.text_justification == FI_CENTER_JUSTIFIED) ||
        (temp_dpb.text_justification == FI_RIGHT_JUSTIFIED))
    {
      FIg_set_state_off (Scroll_field_form, BOTH_SCROLL_CK);

      UMSGetByNum (t_str, FB_E_HORZINVJUST, 0);
      print_error (Scroll_field_form, SCROLL_ERR_FLD, t_str);

      if (gadget_attr.scroll_mode == VERTICAL_SCROLL_ONLY)
        FIg_set_state_on (Scroll_field_form, VERT_SCROLL_CK);
      else if (gadget_attr.scroll_mode == NO_SCROLLING)
        FIg_set_state_on (Scroll_field_form, NO_SCROLL_CK);
    }
    else
    {
      FIg_set_state_on (Scroll_field_form, BOTH_SCROLL_CK);
      FIg_set_state_off (Scroll_field_form, VERT_SCROLL_CK);
      FIg_set_state_off (Scroll_field_form, HORZ_SCROLL_CK);
      FIg_set_state_off (Scroll_field_form, NO_SCROLL_CK);

      FIg_display (Scroll_field_form, DISPLAY_VERT_TOG);
      FIg_display (Scroll_field_form, DISPLAY_HORZ_TOG);
      if (gadget_attr.vert_scroll_flag == 1)
        FIg_display (Scroll_field_form, VERT_NOTIFY_TOG);
      else
        FIg_erase (Scroll_field_form, VERT_NOTIFY_TOG);

      gadget_attr.scroll_mode = BOTH_DIRECTION_SCROLL;

      FIg_erase (Verify_field_form, DEF_TEXT);
      FIg_erase (Verify_field_form, DEFAULT_STR_FLD);
      FIg_display (Verify_field_form, INITIAL_TEXT);
      FIg_display (Verify_field_form, INITIAL_VALUES_FLD);
    }
    break;

  case WRAP_TOG:

    if ((int)value == 0)
    {
      gadget_attr.wrap_flag = 0;
    }
    else
    {
      if ((gadget_attr.scroll_mode != HORIZONTAL_SCROLL_ONLY) &&
          (gadget_attr.scroll_mode != BOTH_DIRECTION_SCROLL))
      {
        gadget_attr.wrap_flag = 1;
      }
      else
      {
        FIg_set_state_off (Scroll_field_form, WRAP_TOG);

        UMSGetByNum (t_str, FB_E_NOWRPHRZSCRL, 0);
        print_error (Scroll_field_form, SCROLL_ERR_FLD, t_str);
      }
    }
    break;

  case DISPLAY_VERT_TOG:

    if ((int)value == 0)
    {
      gadget_attr.vert_scroll_flag = 0;
      FIg_erase (Scroll_field_form, VERT_NOTIFY_TOG);
    }
    else
    {
      gadget_attr.vert_scroll_flag = 1;
      FIg_display (Scroll_field_form, VERT_NOTIFY_TOG);
    }
    break;

  case VERT_NOTIFY_TOG:

    gadget_attr.vert_scroll_notify = (int)value;
    break;

  case DISPLAY_HORZ_TOG:

    if ((int)value == 0)
      gadget_attr.horz_scroll_flag = 0;
    else
      gadget_attr.horz_scroll_flag = 1;
    break;

  case ROLL_THROUGH_TOG:

    if ((int)value == 0)
    {
      /* Use checklist to determine scroll options */

      gadget_attr.roll_through_flag = 0;

      if ((gadget_attr.scroll_mode == NO_SCROLLING) ||
          (gadget_attr.scroll_mode == HORIZONTAL_SCROLL_ONLY))
      {
        FIg_erase (Verify_field_form, INITIAL_TEXT);
        FIg_erase (Verify_field_form, INITIAL_VALUES_FLD);
        FIg_display (Verify_field_form, DEF_TEXT);
        FIg_display (Verify_field_form, DEFAULT_STR_FLD);
      }
    }
    else
    {
      if (gadget_attr.num_rows != 1)
      {
        FIg_set_state_off (Scroll_field_form, ROLL_THROUGH_TOG);

        UMSGetByNum (t_str, FB_E_ROLLINVMUL, 0);
        print_error (Scroll_field_form, SCROLL_ERR_FLD, t_str);
      }
      else if (gadget_attr.list_exists_flag == 1)
      {
        FIg_set_state_off (Scroll_field_form, ROLL_THROUGH_TOG);

        UMSGetByNum (t_str, FB_E_ROLLNOLST, 0);
        print_error (Scroll_field_form, SCROLL_ERR_FLD, t_str);
      }
      else if ((gadget_attr.scroll_mode == VERTICAL_SCROLL_ONLY) ||
          (gadget_attr.scroll_mode == BOTH_DIRECTION_SCROLL))
      {
        FIg_set_state_off (Scroll_field_form, ROLL_THROUGH_TOG);

        UMSGetByNum (t_str, FB_E_ROLLINVVERT, 0);
        print_error (Scroll_field_form, SCROLL_ERR_FLD, t_str);
      }
      else if (gadget_attr.field_mode != FI_SINGLE_SELECT)
      {
        FIg_set_state_off (Scroll_field_form, ROLL_THROUGH_TOG);

        UMSGetByNum (t_str, FB_E_ROLLSNGSEL, 0);
        print_error (Scroll_field_form, SCROLL_ERR_FLD, t_str);
      }
      else
      {
        gadget_attr.roll_through_flag = 1;

        FIg_erase (Verify_field_form, DEF_TEXT);
        FIg_erase (Verify_field_form, DEFAULT_STR_FLD);
        FIg_display (Verify_field_form, INITIAL_TEXT);
        FIg_display (Verify_field_form, INITIAL_VALUES_FLD);

        gadget_attr.display_scroll_flag = 1;
      }
    }
    break;
  }
  return;
}

/*************************************************************************/
/* */
/* fi_verify_field_form() */
/* */
/* This function works inthe same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the default */
/* settings for a new field gadget, or alter the settings of an */
/* existing field gadget. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_verify_field_form (int form_label,
                          int gadget_label,
                          double value,
                          Form form_ptr)
{
  char t_str[256];
  int i;
  double f;
  int dummy_int;
  int status;

  FIg_erase (Verify_field_form, VERIFY_ERR_FLD);

  switch (gadget_label)
  {
  case FORMAT_FLD:

    FIfld_get_text (Verify_field_form, FORMAT_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);
    strcpy (gadget_attr.on_text, t_str);
    break;

  case VERIFY_LIST_TOG:

    if ((int)value == 0)
      gadget_attr.list_verify_flag = 0;
    else
    {
      if (gadget_attr.list_exists_flag == 0)
      {
        UMSGetByNum (t_str, FB_E_DEFASSLST, 0);
        print_error (Verify_field_form, VERIFY_ERR_FLD, t_str);
        FIg_set_state_off (Verify_field_form, VERIFY_LIST_TOG);
      }
      else
        gadget_attr.list_verify_flag = 1;
    }
    break;


  case DEFAULT_STR_FLD:

    FIfld_get_text (Verify_field_form, DEFAULT_STR_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    if (gadget_attr.field_type == FI_ALPHA)
    {
      strcpy (gadget_attr.default_str, t_str);
    }

    if (gadget_attr.field_type == FI_INT)
    {
      i = validate_integer_field (t_str, Verify_field_form,
          VERIFY_ERR_FLD, &status);
      if (status)
        if (((i < (int)gadget_attr.minimum_value) ||
            (i > (int)gadget_attr.maximum_value)) &&
            (i != 0) &&
            (gadget_attr.minimum_value != gadget_attr.maximum_value))
        {
          UMSGetByNum (t_str, FB_E_VALOUTLMT, 0);
          print_error (Verify_field_form, VERIFY_ERR_FLD, t_str);
        }
        else
          strcpy (gadget_attr.default_str, t_str);
    }

    if (gadget_attr.field_type == FI_DOUBLE)
    {
      f = validate_double_field (t_str, Verify_field_form,
          VERIFY_ERR_FLD, &status);

      if (status)
        if (((f < gadget_attr.minimum_value) ||
            (f > gadget_attr.maximum_value)) &&
            (f != 0) &&
            (gadget_attr.minimum_value != gadget_attr.maximum_value))
        {
          UMSGetByNum (t_str, FB_E_VALOUTLMT, 0);
          print_error (Verify_field_form, VERIFY_ERR_FLD, t_str);
        }
        else
        {
          sprintf (t_str, "%lG", f);
          strcpy (gadget_attr.default_str, t_str);
        }
    }
    break;

  case MINIMUM_FLD:

    FIfld_get_text (Verify_field_form, MINIMUM_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    if (gadget_attr.field_type == FI_INT)
    {
      i = validate_integer_field (t_str, Verify_field_form,
          VERIFY_ERR_FLD, &status);
      if (status)
        if (i > (int)gadget_attr.maximum_value)
        {
          UMSGetByNum (t_str, FB_E_MINLEMAX, 0);
          print_error (Verify_field_form, VERIFY_ERR_FLD, t_str);
        }
        else
          if ((i > (atoi (gadget_attr.default_str))) &&
              (gadget_attr.num_rows == 1) &&
              (atoi (gadget_attr.default_str) != 0))
          {
            UMSGetByNum (t_str, FB_E_MINLEDEF, 0);
            print_error (Verify_field_form, VERIFY_ERR_FLD, t_str);
          }
          else
            gadget_attr.minimum_value = (double)i;
    }

    if (gadget_attr.field_type == FI_DOUBLE)
    {
      f = validate_double_field (t_str, Verify_field_form,
          VERIFY_ERR_FLD, &status);
      if (status)
        if (f > gadget_attr.maximum_value)
        {
          UMSGetByNum (t_str, FB_E_MINLEMAX, 0);
          print_error (Verify_field_form, VERIFY_ERR_FLD, t_str);
        }
        else
          if ((f > (atof (gadget_attr.default_str))) &&
              (gadget_attr.num_rows == 1) &&
              (atof (gadget_attr.default_str) != 0))
          {
            UMSGetByNum (t_str, FB_E_MINLEDEF, 0);
            print_error (Verify_field_form, VERIFY_ERR_FLD, t_str);
          }
          else
            gadget_attr.minimum_value = f;
    }
    break;

  case MAXIMUM_FLD:

    FIfld_get_text (Verify_field_form, MAXIMUM_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    if (gadget_attr.field_type == FI_INT)
    {
      i = validate_integer_field (t_str, Verify_field_form,
          VERIFY_ERR_FLD, &status);
      if (status)
        if (i < (int)gadget_attr.minimum_value)
        {
          UMSGetByNum (t_str, FB_E_MAXGEMIN, 0);
          print_error (Verify_field_form, VERIFY_ERR_FLD, t_str);
        }
        else
          if ((i < (atoi (gadget_attr.default_str))) &&
              (gadget_attr.num_rows == 1) &&
              (atoi (gadget_attr.default_str) != 0))
          {
            UMSGetByNum (t_str, FB_E_MAXGEDEF, 0);
            print_error (Verify_field_form, VERIFY_ERR_FLD, t_str);
          }
          else
            gadget_attr.maximum_value = (double)i;
    }

    if (gadget_attr.field_type == FI_DOUBLE)
    {
      f = validate_double_field (t_str, Verify_field_form,
          VERIFY_ERR_FLD, &status);
      if (status)
        if (f < gadget_attr.minimum_value)
        {
          UMSGetByNum (t_str, FB_E_MAXGEMIN, 0);
          print_error (Verify_field_form, VERIFY_ERR_FLD, t_str);
        }
        else
          if ((f < (atof (gadget_attr.default_str))) &&
              (gadget_attr.num_rows == 1) &&
              (atof (gadget_attr.default_str) != 0))
          {
            UMSGetByNum (t_str, FB_E_MAXGEDEF, 0);
            print_error (Verify_field_form, VERIFY_ERR_FLD, t_str);
          }
          else
            gadget_attr.maximum_value = f;
    }
    break;
  }
  return;
}

/*-----------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* fi_master_field_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the default */
/* settings for a new field gadget, or alter the settings of an */
/* existing field gadget. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_master_field_form (int form_label,
                          int gadget_label,
                          double value,
                          Form form_ptr)
{
  int i, x;
  char t_str[256];
  int dummy_int;
  int status;

  FIg_erase (Master_field_form, ERR_FLD);

  switch (gadget_label)
  {
  case NUM_LINES_TOG:

    if ((int)value == 0)
    {
      FIfld_set_text (Master_field_form, ROWS_FLD, 0, 0, "1", 0);
      gadget_attr.num_rows = 1;

      if (((gadget_attr.scroll_mode == NO_SCROLLING) ||
          (gadget_attr.scroll_mode == HORIZONTAL_SCROLL_ONLY)) &&
          (gadget_attr.roll_through_flag == 0))
      {
        FIg_erase (Verify_field_form, INITIAL_TEXT);
        FIg_erase (Verify_field_form, INITIAL_VALUES_FLD);
        FIg_get_text (Verify_field_form, INITIAL_VALUES_FLD, t_str);
        FIg_set_text (Verify_field_form, DEFAULT_STR_FLD, t_str);
        strcpy (gadget_attr.default_str, t_str);
        FIg_display (Verify_field_form, DEF_TEXT);
        FIg_display (Verify_field_form, DEFAULT_STR_FLD);
      }
    }
    else
    {
      FIg_erase (Verify_field_form, DEF_TEXT);
      FIg_erase (Verify_field_form, DEFAULT_STR_FLD);
      if ((gadget_attr.scroll_mode == NO_SCROLLING) ||
          (gadget_attr.scroll_mode == HORIZONTAL_SCROLL_ONLY))
      {
        FIg_get_text (Verify_field_form, DEFAULT_STR_FLD, t_str);
        FIg_set_text (Verify_field_form, INITIAL_VALUES_FLD, t_str);
      }
      FIg_display (Verify_field_form, INITIAL_TEXT);
      FIg_display (Verify_field_form, INITIAL_VALUES_FLD);

      gadget_attr.roll_through_flag = 0;
      FIg_set_state_off (Scroll_field_form, ROLL_THROUGH_TOG);

      sprintf (t_str, "%d", number_of_lines);
      FIfld_set_text (Master_field_form, ROWS_FLD, 0, 0, t_str, 0);
      gadget_attr.num_rows = number_of_lines;
    }
    break;

  case DRAW_TOG:

    if ((int)value == 0) /* DRAW mode */
    {
      gadget_attr.draw_flag = 1;
      gadget_attr.poke_flag = 0;

      FIg_erase (Master_field_form, ROWS_TEXT);
      FIg_erase (Master_field_form, COLS_TEXT);
      FIg_erase (Master_field_form, ROWS_FLD);
      FIg_erase (Master_field_form, COLS_FLD);

      FIg_set_state_off (Master_field_form, KEYIN_TOG);

      FIg_erase (Master_field_form, X_POS_TEXT);
      FIg_erase (Master_field_form, Y_POS_TEXT);
      FIg_erase (Master_field_form, X_POS_FLD);
      FIg_erase (Master_field_form, Y_POS_FLD);
    }
    else /* Specify rows/columns */
    {
      gadget_attr.draw_flag = 0;
      gadget_attr.poke_flag = 1;

      FIg_display (Master_field_form, ROWS_TEXT);
      FIg_display (Master_field_form, COLS_TEXT);
      FIg_display (Master_field_form, ROWS_FLD);
      FIg_display (Master_field_form, COLS_FLD);
    }
    break;

  case KEYIN_TOG:

    if ((int)value == 0)
    {
      if (gadget_attr.draw_flag != 1)
      {
        gadget_attr.poke_flag = 1;

        FIg_erase (Master_field_form, X_POS_TEXT);
        FIg_erase (Master_field_form, Y_POS_TEXT);
        FIg_erase (Master_field_form, X_POS_FLD);
        FIg_erase (Master_field_form, Y_POS_FLD);
      }
    }
    else /* Switch to keyin mode */
    {
      if (gadget_attr.draw_flag == 1)
      {
        UMSGetByNum (t_str, FB_E_MSTETRDTP, 0);
        print_error (Master_field_form, ERR_FLD, t_str);

        FIg_set_state_off (Master_field_form, KEYIN_TOG);
      }
      else
      {
        gadget_attr.poke_flag = 0;

        FIg_display (Master_field_form, X_POS_TEXT);
        FIg_display (Master_field_form, Y_POS_TEXT);
        FIg_display (Master_field_form, X_POS_FLD);
        FIg_display (Master_field_form, Y_POS_FLD);
      }
    }
    break;


  case ROWS_FLD:

    FIfld_get_text (Master_field_form, ROWS_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Master_field_form,
        ERR_FLD, &status);

    if (status)
      if (i > 0) /* Valid input */
      {
        if (i == 1)
        {
          FIg_set_state_off (Master_field_form, NUM_LINES_TOG);
          gadget_attr.num_rows = 1;

          if (((gadget_attr.scroll_mode == NO_SCROLLING) ||
              (gadget_attr.scroll_mode == HORIZONTAL_SCROLL_ONLY)) &&
              (gadget_attr.roll_through_flag == 0))
          {
            FIg_erase (Verify_field_form, INITIAL_TEXT);
            FIg_erase (Verify_field_form, INITIAL_VALUES_FLD);
            FIg_get_text (Verify_field_form, INITIAL_VALUES_FLD, t_str);
            FIg_set_text (Verify_field_form, DEFAULT_STR_FLD, t_str);
            strcpy (gadget_attr.default_str, t_str);
            FIg_display (Verify_field_form, DEF_TEXT);
            FIg_display (Verify_field_form, DEFAULT_STR_FLD);
          }
        }
        else
        {
          FIg_set_state_on (Master_field_form, NUM_LINES_TOG);
          gadget_attr.num_rows = i;
          number_of_lines = i;

          FIg_set_state_off (Scroll_field_form, ROLL_THROUGH_TOG);
          gadget_attr.roll_through_flag = 0;

          FIg_erase (Verify_field_form, DEF_TEXT);
          FIg_erase (Verify_field_form, DEFAULT_STR_FLD);
          FIg_display (Verify_field_form, INITIAL_TEXT);
          FIg_display (Verify_field_form, INITIAL_VALUES_FLD);
        }
        gadget_attr.y_size = i * 16;
      }
      else /* Invalid input */
      {
        UMSGetByNum (t_str, FB_E_ROWSGTZERO, 0);
        print_error (Master_field_form, ERR_FLD, t_str);
      }
    break;

  case COLS_FLD:

    FIfld_get_text (Master_field_form, COLS_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Master_field_form,
        ERR_FLD, &status);

    if (status)
      if (i > 0) /* Valid input */
      {
        gadget_attr.num_cols = i;
      }
      else /* Invalid input */
      {
        UMSGetByNum (t_str, FB_E_COLSGTZERO, 0);
        print_error (Master_field_form, ERR_FLD, t_str);
      }
    break;

  case X_POS_FLD:

    FIfld_get_text (Master_field_form, X_POS_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Master_field_form,
        ERR_FLD, &status);

    if (status)
      if (i < 0)
      {
        UMSGetByNum (t_str, FB_E_XNOTNEG, 0);
        print_error (Master_field_form, ERR_FLD, t_str);
      }
      else
        gadget_attr.x_pos = i;
    break;

  case Y_POS_FLD:

    FIfld_get_text (Master_field_form, Y_POS_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Master_field_form,
        ERR_FLD, &status);

    if (status)
      if (i < 0)
      {
        UMSGetByNum (t_str, FB_E_YNOTNEG, 0);
        print_error (Master_field_form, ERR_FLD, t_str);
      }
      else
        gadget_attr.y_pos = i;
    break;

  case ASCII_CK:

    FIg_set_state_on (Master_field_form, ASCII_CK);

    gadget_attr.field_type = FI_ALPHA;

    FIg_erase (Verify_field_form, MIN_TEXT);
    FIg_erase (Verify_field_form, MAX_TEXT);
    FIg_erase (Verify_field_form, MINIMUM_FLD);
    FIg_erase (Verify_field_form, MAXIMUM_FLD);
    FIg_erase (Verify_field_form, FORMAT_FLD);
    FIg_erase (Verify_field_form, FORMAT_TEXT);

    gadget_attr.minimum_value = 0.0;
    gadget_attr.maximum_value = 0.0;

    break;

  case INT_CK:

    FIg_set_state_on (Master_field_form, INT_CK);

    gadget_attr.field_type = FI_INT;

    FIg_display (Verify_field_form, MIN_TEXT);
    FIg_display (Verify_field_form, MAX_TEXT);
    FIg_display (Verify_field_form, MINIMUM_FLD);
    FIg_display (Verify_field_form, MAXIMUM_FLD);
    FIg_display (Verify_field_form, FORMAT_TEXT);
    FIg_display (Verify_field_form, FORMAT_FLD);

    strcpy (gadget_attr.on_text, "%d");
    FIfld_set_text (Verify_field_form, 17, 0, 0, "%d", 0);

    break;

  case FLOAT_CK:

    FIg_set_state_on (Master_field_form, FLOAT_CK);

    gadget_attr.field_type = FI_DOUBLE;

    FIg_display (Verify_field_form, MIN_TEXT);
    FIg_display (Verify_field_form, MAX_TEXT);
    FIg_display (Verify_field_form, MINIMUM_FLD);
    FIg_display (Verify_field_form, MAXIMUM_FLD);
    FIg_display (Verify_field_form, FORMAT_TEXT);
    FIg_display (Verify_field_form, FORMAT_FLD);

    strcpy (gadget_attr.on_text, "%lG");
    FIfld_set_text (Verify_field_form, 17, 0, 0, "%lG", 0);

    break;

  case SCROLL_OPT_CK:

    status = FIg_set_state_on (Master_field_form, SCROLL_OPT_CK);

    FIf_is_displayed (Assoc_list_field_form, &status);

    if (status)
      FIf_erase (Assoc_list_field_form);

    FIf_is_displayed (Edit_field_form, &status);

    if (status)
      FIf_erase (Edit_field_form);

    FIf_is_displayed (Verify_field_form, &status);

    if (status)
      FIf_erase (Verify_field_form);

    FIf_is_displayed (Scroll_field_form, &status);

    if (!status)
      FIf_display (Scroll_field_form);
    break;

  case EDIT_OPT_CK:

    FIg_set_state_on (Master_field_form, EDIT_OPT_CK);

    FIf_is_displayed (Assoc_list_field_form, &status);

    if (status)
      FIf_erase (Assoc_list_field_form);

    FIf_is_displayed (Scroll_field_form, &status);

    if (status)
      FIf_erase (Scroll_field_form);

    FIf_is_displayed (Verify_field_form, &status);

    if (status)
      FIf_erase (Verify_field_form);

    FIf_is_displayed (Edit_field_form, &status);

    if (!status)
      FIf_display (Edit_field_form);
    break;

  case VERIFY_OPT_CK:

    FIg_set_state_on (Master_field_form, VERIFY_OPT_CK);

    FIf_is_displayed (Assoc_list_field_form, &status);

    if (status)
      FIf_erase (Assoc_list_field_form);

    FIf_is_displayed (Edit_field_form, &status);

    if (status)
      FIf_erase (Edit_field_form);

    FIf_is_displayed (Scroll_field_form, &status);

    if (status)
      FIf_erase (Scroll_field_form);

    FIf_is_displayed (Verify_field_form, &status);

    if (!status)
      FIf_display (Verify_field_form);
    break;

  case ASSOC_LIST_CK:

    FIg_set_state_on (Master_field_form, ASSOC_LIST_CK);

    FIf_is_displayed (Scroll_field_form, &status);

    if (status)
      FIf_erase (Scroll_field_form);

    FIf_is_displayed (Edit_field_form, &status);

    if (status)
      FIf_erase (Edit_field_form);

    FIf_is_displayed (Verify_field_form, &status);

    if (status)
      FIf_erase (Verify_field_form);

    FIf_is_displayed (Assoc_list_field_form, &status);

    if (!status)
      FIf_display (Assoc_list_field_form);
    break;

  case FI_HELP:

    /* Help_topic ("Field") */
    break;

  case FI_CANCEL:

    if (command_is_active == EDIT_GADGET)
    {
      if (edit_hilite_flag == 0)
        FIg_unhilite (work_form, old_gadget_label);

      if (edit_display_flag == 0)
        FIg_erase (work_form, old_gadget_label);
    }

    kill_place_field();
    FIg_set_state_off (Master_field_form, FI_CANCEL);
    break;

  case FI_ACCEPT:

    FIf_erase (Master_field_form);
    FIf_erase (Scroll_field_form);
    FIf_erase (Edit_field_form);
    FIf_erase (Verify_field_form);
    FIf_erase (Assoc_list_field_form);

    for (x = 98; x < 102; x++)
      FIg_set_state_off (Master_field_form, x);

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

    create_field_gadget();

    FIg_set_state_off (Master_field_form, FI_ACCEPT);

    if (command_is_active == EDIT_GADGET)
      kill_place_field();
    else /* Do this command again */
    {
      Redisplay (work_form);
      FIf_display (Master_field_form);

      FIf_get_next_label (work_form, &gadget_attr.gadget_label);

      if (Characteristics_form != NULL)
      {
        override_attr.gadget_label = gadget_attr.gadget_label;

        sprintf (t_str, "%d", override_attr.gadget_label);
        FIfld_set_text (Characteristics_form, LABEL_FLD,
            0, 0, t_str, 0);
        FIg_erase (Characteristics_form, 10);
      }

      UMSGetByNum (t_str, FB_I_FILLFLD, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
    }
    break;
  }
  return;
}

/*************************************************************************/
/* */
/* execute_place_field() */
/* */
/* This function is called by the executive command handler routine. */
/* */
/* It displays the Master_field_form then exits. After that point */
/* the fi_button_type_form() gadget notification routines will be in */
/* control. That is to say, every time the operator alters a gadget on */
/* one of these forms, the appropriate gadget notification routine will */
/* be invoked. */
/* */
/*************************************************************************/

void execute_place_field(void)
{
  char t_str[256];
  int status;


  if (work_form == NULL) /* No form defined */
  {
    strcpy (current_command_string, "None");
    command_is_active = 0;
    return;
  }

  UMSGetByNum (t_str, FB_I_PLAFLD, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENDEF, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Assoc_list_field_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlAsLsFl");
    status = FIf_new (101, t_str, (int (*)())fi_assoc_list_field_form,
        &Assoc_list_field_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  if (Edit_field_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBEdFlOpt");
    status = FIf_new (102, t_str, (int (*)())fi_edit_field_form, &Edit_field_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  if (Scroll_field_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBSlScFlOp");
    status = FIf_new (103, t_str, (int (*)())fi_scroll_field_form, &Scroll_field_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  if (Verify_field_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBVrAsLsFl");
    status = FIf_new (104, t_str, (int (*)())fi_verify_field_form, &Verify_field_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  if (Master_field_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlMstFl");
    status = FIf_new (100, t_str, (int (*)())fi_master_field_form, &Master_field_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }
  FIfld_set_num_rows (Verify_field_form, INITIAL_VALUES_FLD, 0);
  FIfld_set_num_rows (Assoc_list_field_form, LIST_VALUES_FLD, 0);

  setup_new_field_form();
  show_master_field_form_info();

  FIg_set_state_off (Master_field_form, SCROLL_OPT_CK);
  FIg_set_state_off (Master_field_form, EDIT_OPT_CK);
  FIg_set_state_off (Master_field_form, VERIFY_OPT_CK);
  FIg_set_state_off (Master_field_form, ASSOC_LIST_CK);

  FIg_erase (Master_field_form, 10);
  FIg_erase (Assoc_list_field_form, 10);
  FIg_erase (Edit_field_form, 10);
  FIg_erase (Scroll_field_form, 10);
  FIg_erase (Verify_field_form, 10);

  FIf_display (Master_field_form);

  FIf_get_next_label (work_form, &gadget_attr.gadget_label);

  if (Characteristics_form != NULL)
    Update_characteristics_form();

  UMSGetByNum (t_str, FB_I_FILLFLD, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

}

/*************************************************************************/
/* */
/* edit_field_gadget() */
/* */
/*************************************************************************/

void edit_field_gadget(void)
{
  char t_str[256];
  int status;

  gadget_attr.gadget_label = old_gadget_label;

  UMSGetByNum (t_str, FB_I_EDTFLD, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENCUR, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Assoc_list_field_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlAsLsFl");
    status = FIf_new (101, t_str, (int (*)())fi_assoc_list_field_form, 
        &Assoc_list_field_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  if (Edit_field_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBEdFlOpt");
    status = FIf_new (102, t_str, (int (*)())fi_edit_field_form, &Edit_field_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  if (Scroll_field_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBSlScFlOp");
    status = FIf_new (103, t_str, (int (*)())fi_scroll_field_form, &Scroll_field_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  if (Verify_field_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBVrAsLsFl");
    status = FIf_new (104, t_str, (int (*)())fi_verify_field_form, &Verify_field_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  if (Master_field_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlMstFl");
    status = FIf_new (100, t_str, (int (*)())fi_master_field_form, &Master_field_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  setup_old_field_form();

  show_master_field_form_info();

  FIg_set_state_off (Master_field_form, SCROLL_OPT_CK);
  FIg_set_state_off (Master_field_form, EDIT_OPT_CK);
  FIg_set_state_off (Master_field_form, VERIFY_OPT_CK);
  FIg_set_state_off (Master_field_form, ASSOC_LIST_CK);

  FIg_erase (Master_field_form, 10);
  FIg_erase (Assoc_list_field_form, 10);
  FIg_erase (Edit_field_form, 10);
  FIg_erase (Scroll_field_form, 10);
  FIg_erase (Verify_field_form, 10);

  FIf_display (Master_field_form);

  if (Characteristics_form != NULL)
  {
    Update_characteristics_form();
  }

  UMSGetByNum (t_str, FB_I_FILLFLD, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}
