/***********************************

		multi_col.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
*/

/*************************************/
/* */
/* This file contains functions for the "place multi column field" and */
/* "edit multi column field" commands. */
/* */
/* Programmer: Mack Draper */
/* Date: Feb. 9, 1989 */
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

#define CHAR_FOREGROUND_CLR_BTN 47
#define CHAR_FOREGROUND2_CLR_BTN 48
#define CHAR_TEXT_FONT_BTN 46

/*************************************/
/* */
/* used by Place Multi Column Form */
/* */
/*************************************/

#define NUMBER_OF_ROWS_FLD 20
#define NUMBER_OF_COLS_FLD 21
#define VISIBLE_COLUMNS_FLD 22

#define X_POS_TEXT 15
#define Y_POS_TEXT 16
#define X_POS_FLD 24
#define Y_POS_FLD 25

#define KEYIN_TOG 23

#define ENABLE_VERT_SCROLL 31
#define DISPLAY_VERT_SCROLL 26
#define COLUMN_SCROLL_TOG 18
#define VERT_NOTIFY_TOG 37

#define HEADER_MCF_FLD 28
#define ROW_SELECT_TOG 17
#define POKE_TO_SELECT_ROW_TOG 35

#define PLACE_ERR_FLD 10

/******************************/
/* */
/* used by Edit Column form */
/* */
/******************************/

#define COLUMN_NUMBER 23
#define WIDTH_IN_CHARACTERS 24

#define ASCII_CK 15
#define INT_CK 16
#define FLOAT_CK 17

#define EDIT_OPT_CK 21
#define VERIFY_OPT_CK 20

#define UP_BUTTON 37
#define DOWN_BUTTON 38
#define EDIT_COL_ERR_FLD 10

#define ENABLE_HORZ_SCROLL 34
#define DISPLAY_HORZ_SCROLL 35
#define WRAP_TOG 36

#define LEFT_JUSTIFY_CK 44
#define CENTER_JUSTIFY_CK 45
#define RIGHT_JUSTIFY_CK 46

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

#define VERIFY_ERR_FLD 10

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

Form Place_multi_column_form = NULL;
Form Edit_column_form = NULL;
Form Column_mode_form = NULL;
Form Verify_column_form = NULL;

static Form Dummy_mcf_form = NULL;

#define MAX_COLUMNS 1000

static struct column_struct column_attr[MAX_COLUMNS];
static int column_number;
static int max_columns;
static int mcf = 0;
static int previous_column;
static int row_select_buttons_flag;

static void Show_column_info();
static void Validate_column_width();

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
extern int Next_in_sequence;
extern int Next_link;

extern int Edit_sequence_array[100];
extern int Edit_data_link_array[100];
extern int Edit_sequence_count;
extern int Edit_data_link_count;

extern char language[80];

/*************************************************************************/
/* */
/* kill_place_multi_col_field() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to PLACE_MULTI_COL_FIELD indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_place_multi_col_field(void)
{
  char t_str[256];

  if (Place_multi_column_form != NULL)
    FIf_erase (Place_multi_column_form);

  if (Edit_column_form != NULL)
    FIf_erase (Edit_column_form);

  if (Column_mode_form != NULL)
    FIf_erase (Column_mode_form);

  if (Verify_column_form != NULL)
    FIf_erase (Verify_column_form);

  if (Dummy_mcf_form != NULL)
  {
    FIg_delete (Dummy_mcf_form, mcf);
    mcf = 0;
    FIf_erase (Dummy_mcf_form);
  }

  if (Characteristics_form != NULL)
    Clear_characteristics_form();

  if (command_is_active == PLACE_MULTI_COL)
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


/*----------------------------------------------------------------------*/

static void Show_column_info(void)
{
  char t_str[256];
  int x;
  int num_rows;
  int dummy_int;

  FIg_erase (Edit_column_form, EDIT_COL_ERR_FLD);
  FIg_erase (Column_mode_form, EDIT_ERR_FLD);
  FIg_erase (Verify_column_form, VERIFY_ERR_FLD);

  sprintf (t_str, "%d", column_number);
  FIfld_set_text (Edit_column_form, COLUMN_NUMBER, 0, 0, t_str, 0);
  sprintf (t_str, "%d", column_attr[column_number].num_cols);
  FIfld_set_text (Edit_column_form, WIDTH_IN_CHARACTERS, 0, 0, t_str, 0);

  if (column_attr[column_number].field_type == FI_ALPHA)
  {
    FIg_set_state_off (Edit_column_form, INT_CK);
    FIg_set_state_off (Edit_column_form, FLOAT_CK);
    FIg_set_state_on (Edit_column_form, ASCII_CK);
  }

  if (column_attr[column_number].field_type == FI_INT)
  {
    FIg_set_state_off (Edit_column_form, ASCII_CK);
    FIg_set_state_off (Edit_column_form, FLOAT_CK);
    FIg_set_state_on (Edit_column_form, INT_CK);
  }

  if (column_attr[column_number].field_type == FI_DOUBLE)
  {
    FIg_set_state_off (Edit_column_form, ASCII_CK);
    FIg_set_state_off (Edit_column_form, INT_CK);
    FIg_set_state_on (Edit_column_form, FLOAT_CK);
  }

  /*******************************************************/
  /* */
  /* Now set up the horizontal scroll toggles as well as */
  /* the wrap mode flag. */
  /* */
  /*******************************************************/

  if (column_attr[column_number].horz_scroll_enable == 0)
  {
    FIg_set_state_on (Edit_column_form, ENABLE_HORZ_SCROLL);
    FIg_erase (Edit_column_form, DISPLAY_HORZ_SCROLL);
  }
  else
  {
    FIg_set_state_off (Edit_column_form, ENABLE_HORZ_SCROLL);
    FIg_display (Edit_column_form, DISPLAY_HORZ_SCROLL);
  }

  if (column_attr[column_number].horz_scroll_display == 1)
    FIg_set_state_on (Edit_column_form, DISPLAY_HORZ_SCROLL);
  else
    FIg_set_state_off (Edit_column_form, DISPLAY_HORZ_SCROLL);

  /********************************************/
  /* */
  /* Now set up justification of the column */
  /* */
  /********************************************/

  FIg_set_state_off (Edit_column_form, LEFT_JUSTIFY_CK);
  FIg_set_state_off (Edit_column_form, CENTER_JUSTIFY_CK);
  FIg_set_state_off (Edit_column_form, RIGHT_JUSTIFY_CK);

  if (column_attr[column_number].justification == FI_LEFT_JUSTIFIED)
    FIg_set_state_on (Edit_column_form, LEFT_JUSTIFY_CK);
  else if (column_attr[column_number].justification == FI_CENTER_JUSTIFIED)
    FIg_set_state_on (Edit_column_form, CENTER_JUSTIFY_CK);
  else
    FIg_set_state_on (Edit_column_form, RIGHT_JUSTIFY_CK);

  /*******************************************************/
  /* */
  /* Now set up the verification sub-form for the column */
  /* */
  /*******************************************************/

  if ((column_attr[column_number].field_type == FI_DOUBLE) ||
      (column_attr[column_number].field_type == FI_INT))
  {
    FIfld_set_text (Verify_column_form, FORMAT_FLD, 0, 0,
        column_attr[column_number].format, 0);

    if (column_attr[column_number].field_type == FI_INT)
    {
      sprintf (t_str, "%d", (int)column_attr[column_number].minimum_value);
      FIfld_set_text (Verify_column_form, MINIMUM_FLD, 0, 0, t_str, 0);

      sprintf (t_str, "%d", (int)column_attr[column_number].maximum_value);
      FIfld_set_text (Verify_column_form, MAXIMUM_FLD, 0, 0, t_str, 0);
    }
    else
    {
      sprintf (t_str, "%lE", column_attr[column_number].minimum_value);
      FIfld_set_text (Verify_column_form, MINIMUM_FLD, 0, 0, t_str, 0);

      sprintf (t_str, "%lE", column_attr[column_number].maximum_value);
      FIfld_set_text (Verify_column_form, MAXIMUM_FLD, 0, 0, t_str, 0);
    }

    FIg_display (Verify_column_form, MIN_TEXT);
    FIg_display (Verify_column_form, MAX_TEXT);
    FIg_display (Verify_column_form, MINIMUM_FLD);
    FIg_display (Verify_column_form, MAXIMUM_FLD);
    FIg_display (Verify_column_form, FORMAT_TEXT);
    FIg_display (Verify_column_form, FORMAT_FLD);
  }
  else
  {
    /*************************************************/
    /* */
    /* Put null strings in MAXIMUM_FLD, MINIMUM_FLD */
    /* */
    /*************************************************/

    t_str[0] = '\0';
    FIfld_set_text (Verify_column_form, MINIMUM_FLD, 0, 0, t_str, 0);
    FIfld_set_text (Verify_column_form, MAXIMUM_FLD, 0, 0, t_str, 0);

    FIg_erase (Verify_column_form, MIN_TEXT);
    FIg_erase (Verify_column_form, MAX_TEXT);
    FIg_erase (Verify_column_form, MINIMUM_FLD);
    FIg_erase (Verify_column_form, MAXIMUM_FLD);
    FIg_erase (Verify_column_form, FORMAT_TEXT);
    FIg_erase (Verify_column_form, FORMAT_FLD);
  }

  if ((gadget_attr.num_rows == 1) &&
      (gadget_attr.roll_through_flag == 0) &&
      ((gadget_attr.scroll_mode == NO_SCROLLING) ||
      (gadget_attr.scroll_mode == HORIZONTAL_SCROLL_ONLY)))
  {
    FIfld_get_default_text (Dummy_mcf_form, mcf, 0, column_number,
        255, (unsigned char *)t_str, &dummy_int);

    FIfld_set_text (Verify_column_form, DEFAULT_STR_FLD, 0, 0, t_str, 0);

    FIg_display (Verify_column_form, DEF_TEXT);
    FIg_display (Verify_column_form, DEFAULT_STR_FLD);

    FIg_erase (Verify_column_form, INITIAL_TEXT);
    FIg_erase (Verify_column_form, INITIAL_VALUES_FLD);

    /*********************************************************/
    /* */
    /* Need to beef this part up. Use FIfld_get_text() */
    /* to read the gadget's current text. This means that */
    /* a new multi-column field gadget must be created as */
    /* soon as the command begins, so that it will store */
    /* this value so that it can be obtained now. */
    /* */
    /* Also format the data if type is int or float. */
    /* */
    /*********************************************************/
  }
  else
  {
    if (previous_column >= 0)
    {
      FIfld_get_num_rows (Verify_column_form, INITIAL_VALUES_FLD,
          &num_rows);

      column_attr[previous_column].lines_default_text = num_rows;

      for (x = 0; x < num_rows; x++)
      {
        FIfld_get_text (Verify_column_form, INITIAL_VALUES_FLD,
            x, 0, 255,
            (unsigned char *)t_str, &dummy_int, &dummy_int);

        FIfld_set_text (Dummy_mcf_form, mcf, x,
            previous_column, t_str, 0);

        FIfld_get_text (Dummy_mcf_form, mcf,
            x, previous_column, 255,
            (unsigned char *)t_str, &dummy_int, &dummy_int);

        FIfld_set_text (Verify_column_form, INITIAL_VALUES_FLD,
            x, 0, "", 0);
      }
    }

    FIfld_set_num_rows (Verify_column_form, INITIAL_VALUES_FLD, 0);

    for (x = 0; x < column_attr[column_number].lines_default_text; x++)
    {
      FIfld_get_text (Dummy_mcf_form, mcf, x, column_number, 255,
          (unsigned char *)t_str, &dummy_int, &dummy_int);

      FIfld_set_text (Verify_column_form, INITIAL_VALUES_FLD,
          x, 0, t_str, 0);

      FIfld_get_text (Verify_column_form, INITIAL_VALUES_FLD, x,
          0, 255, (unsigned char *)t_str, &dummy_int, &dummy_int);
    }

    FIg_display (Verify_column_form, INITIAL_TEXT);
    FIg_display (Verify_column_form, INITIAL_VALUES_FLD);

    FIg_erase (Verify_column_form, DEF_TEXT);
    FIg_erase (Verify_column_form, DEFAULT_STR_FLD);

    /************************************************************/
    /* */
    /* Need to beef this up. Determine the number of lines */
    /* of default text which has been defined for this column. */
    /* Next read it all in and store it in the field. This */
    /* means that the multi-column field gadget must be */
    /* created as soon as the command is entered so that the */
    /* data will be available at this time. */
    /* */
    /************************************************************/
  }

  /*************************************************/
  /* */
  /* Now set up the Mode sub-form for the column */
  /* */
  /*************************************************/

  FIg_set_state_off (Column_mode_form, REVIEW_CK);
  FIg_set_state_off (Column_mode_form, SINGLE_SELECT_CK);
  FIg_set_state_off (Column_mode_form, MULTI_SELECT_CK);
  FIg_set_state_off (Column_mode_form, CHANGE_CK);
  FIg_set_state_off (Column_mode_form, INSERT_CK);

  if (column_attr[column_number].field_mode == FI_REVIEW)
  {
    FIg_set_state_on (Column_mode_form, REVIEW_CK);
    FIg_erase (Column_mode_form, REPLACE_TEXT_TOG);
    FIg_erase (Column_mode_form, NOTIFICATION_TOG);
    FIg_erase (Column_mode_form, ECHO_TOG);
  }
  else if (column_attr[column_number].field_mode == FI_SINGLE_SELECT)
  {
    FIg_set_state_on (Column_mode_form, SINGLE_SELECT_CK);
    FIg_erase (Column_mode_form, REPLACE_TEXT_TOG);
    FIg_erase (Column_mode_form, NOTIFICATION_TOG);
    FIg_erase (Column_mode_form, ECHO_TOG);
  }
  else if (column_attr[column_number].field_mode == FI_MULTI_SELECT)
  {
    FIg_set_state_on (Column_mode_form, MULTI_SELECT_CK);
    FIg_erase (Column_mode_form, REPLACE_TEXT_TOG);
    FIg_erase (Column_mode_form, NOTIFICATION_TOG);
    FIg_erase (Column_mode_form, ECHO_TOG);
  }
  else if (column_attr[column_number].field_mode == FI_APPEND)
  {
    FIg_set_state_on (Column_mode_form, CHANGE_CK);
    FIg_display (Column_mode_form, REPLACE_TEXT_TOG);
    FIg_display (Column_mode_form, NOTIFICATION_TOG);
    FIg_display (Column_mode_form, ECHO_TOG);
  }
  else if (column_attr[column_number].field_mode == FI_INSERT)
  {
    FIg_set_state_on (Column_mode_form, INSERT_CK);
    FIg_display (Column_mode_form, REPLACE_TEXT_TOG);
    FIg_display (Column_mode_form, NOTIFICATION_TOG);
    FIg_display (Column_mode_form, ECHO_TOG);
  }

  if (column_attr[column_number].replace_text_flag == 0)
    FIg_set_state_on (Column_mode_form, REPLACE_TEXT_TOG);
  else
    FIg_set_state_off (Column_mode_form, REPLACE_TEXT_TOG);

  if (column_attr[column_number].line_notification == 0)
    FIg_set_state_off (Column_mode_form, NOTIFICATION_TOG);
  else
    FIg_set_state_on (Column_mode_form, NOTIFICATION_TOG);

  if (column_attr[column_number].echo_flag == 0)
    FIg_set_state_on (Column_mode_form, ECHO_TOG);
  else
    FIg_set_state_off (Column_mode_form, ECHO_TOG);

  if (column_attr[column_number].required_flag == 1)
    FIg_set_state_on (Column_mode_form, REQUIRED_TOG);
  else
    FIg_set_state_off (Column_mode_form, REQUIRED_TOG);

  if (column_attr[column_number].right_to_left_flag == 1)
  {
    FIg_set_state_on (Column_mode_form, RIGHT_TO_LEFT_TOG);

    if (column_attr[column_number].reverse_input_flag == 1)
      FIg_set_state_off (Column_mode_form, REVERSE_INPUT_TOG);
    else
      FIg_set_state_on (Column_mode_form, REVERSE_INPUT_TOG);
    if (column_attr[column_number].reverse_output_flag == 1)
      FIg_set_state_off (Column_mode_form, REVERSE_OUTPUT_TOG);
    else
      FIg_set_state_on (Column_mode_form, REVERSE_OUTPUT_TOG);

    FIg_display (Column_mode_form, REVERSE_INPUT_TOG);
    FIg_display (Column_mode_form, REVERSE_OUTPUT_TOG);
  }
  else
  {
    FIg_set_state_off (Column_mode_form, RIGHT_TO_LEFT_TOG);
    FIg_erase (Column_mode_form, REVERSE_INPUT_TOG);
    FIg_erase (Column_mode_form, REVERSE_OUTPUT_TOG);
  }

  previous_column = column_number;

}

/*************************************************************************/
/* */
/* setup_new_multi_col_form() */
/* */
/* This function is called each time the operator wishes to place a */
/* new field on the work form. It will fill in default settings for */
/* the field. These will be displayed in the field definition form */
/* when the show_multi_col_field_info() function is called. */
/* */
/*************************************************************************/

static void setup_new_multi_col_form(void)
{
  int x;

  Set_new_gadget_defaults();

  column_number = 0;
  previous_column = -1; /* Don't save INITIAL_VALUES_FLD contents */
  /* when show_column_info() is called. */

  gadget_attr.num_rows = 5;
  gadget_attr.num_cols = 3;
  max_columns = MAX_COLUMNS;
  gadget_attr.visible_cols = 3;
  gadget_attr.poke_flag = 1;

  gadget_attr.vert_scroll_notify = 0;

  gadget_attr.scroll_mode = VERTICAL_SCROLL_ONLY;
  gadget_attr.display_scroll_flag = 1;
  row_select_buttons_flag = 1;
  FIg_set_state_off (Place_multi_column_form, ROW_SELECT_TOG); /* Poking */
  /* column */
  /**********************************************/ /* selects cell only */
  /* */
  /* Force this font for all new field gadgets */
  /* */
  /**********************************************/

  strcpy (gadget_attr.font_name, "mono821b");
  gadget_attr.bodysize = 15.0;

  for (x=0; x < MAX_COLUMNS; x++)
  {
    column_attr[x].lines_default_text = 0;

    column_attr[x].num_cols = 15;
    column_attr[x].field_mode = FI_INSERT;
    column_attr[x].field_type = FI_ALPHA;

    column_attr[x].replace_text_flag = 1;
    column_attr[x].line_notification = 0;
    column_attr[x].echo_flag = 1;

    column_attr[x].minimum_value = 0;
    column_attr[x].maximum_value = 0;

    column_attr[x].horz_scroll_enable = 1;
    column_attr[x].horz_scroll_display = 0;
    column_attr[x].wrap_flag = 0;
    column_attr[x].required_flag = 0;
    column_attr[x].right_to_left_flag = 0;
    column_attr[x].reverse_input_flag = 0;
    column_attr[x].reverse_output_flag = 0;
    column_attr[x].justification = FI_LEFT_JUSTIFIED;
    strcpy (column_attr[x].format, "%d");
  }

  /**************************************************/
  /* */
  /* I am using gadget_attr.display_format to store */
  /* the MCF scroll link data. 0 means no link. */
  /* */
  /**************************************************/

  gadget_attr.display_format = 0;

  gadget_attr.gadget_type = FI_MULTI_COL;
  Next_in_sequence = 0;
  Next_link = -1;
}

/*************************************************************************/
/* */
/* setup_old_multi_col_form() */
/* */
/* This function is called each time the operator wishes to edit an */
/* old field on the work form. It will fill in default settings for */
/* the field. These will be displayed in the field definition form */
/* when the show_multi_col_field_info() function is called. */
/* */
/*************************************************************************/

static void setup_old_multi_col_form(void)
{
  int row_count;
  int x, y;
  long temp_attr, temp_attr2;
  int height, width, line_spacing, font_type;
  char t_str[256];
  int xsize, ysize;
  Font font_id;
  float act_bodysize;
  int dummy_int;

  setup_standard_attr (old_gadget_label);

  FImcf_get_scroll_link (work_form, old_gadget_label,
      &gadget_attr.display_format);

  column_number = 0;
  previous_column = -1; /* Don't save INITIAL_VALUES_FLD contents */
  /* when show_column_info() is called. */

  _FI_find_font_id (gadget_attr.font_name, gadget_attr.bodysize,
      &font_id, &act_bodysize, FI_MULTI_COL, &font_type);

  _FI_calc_text (font_id, "M", 1, &height, &width, &line_spacing, font_type);

  FImcf_get_num_cols (work_form, old_gadget_label, &gadget_attr.num_cols);

  FImcf_get_num_vis_cols (work_form, old_gadget_label,
      &gadget_attr.visible_cols);

  FImcf_get_col_size (work_form, old_gadget_label, 0, &xsize, &ysize);
  gadget_attr.num_rows = ysize / line_spacing;

  max_columns = MAX_COLUMNS;
  gadget_attr.poke_flag = 0;

  FImcf_get_attr (work_form, old_gadget_label, &temp_attr);

  FIfld_get_attr (work_form, old_gadget_label, 0, &temp_attr2);

  if (temp_attr & FI_HORT_SCROLL)
    FIg_set_state_on (Place_multi_column_form, COLUMN_SCROLL_TOG);
  else
    FIg_set_state_off (Place_multi_column_form, COLUMN_SCROLL_TOG);

  if (temp_attr & FI_VERT_SCROLL)
  {
    gadget_attr.scroll_mode = VERTICAL_SCROLL_ONLY;
    FIg_display (Place_multi_column_form, DISPLAY_VERT_SCROLL);
  }
  else
  {
    gadget_attr.scroll_mode = NO_SCROLLING;
    FIg_erase (Place_multi_column_form, DISPLAY_VERT_SCROLL);
  }

  if (temp_attr & FI_DISPLAY_VSCROLL)
    gadget_attr.display_scroll_flag = 1;
  else
    gadget_attr.display_scroll_flag = 0;

  if (temp_attr & FI_NO_ROW_BUTTONS)
    row_select_buttons_flag = 0;
  else
    row_select_buttons_flag = 1;

  if (temp_attr & FI_ROW_SELECT)
    FIg_set_state_on (Place_multi_column_form, POKE_TO_SELECT_ROW_TOG);
  else
    FIg_set_state_off (Place_multi_column_form, POKE_TO_SELECT_ROW_TOG);

  for (x=0; x < MAX_COLUMNS; x++)
  {
    column_attr[x].lines_default_text = 0;

    column_attr[x].num_cols = 15;
    column_attr[x].field_mode = FI_INSERT;
    column_attr[x].field_type = FI_ALPHA;

    column_attr[x].replace_text_flag = 1;
    column_attr[x].line_notification = 0;
    column_attr[x].required_flag = 0;
    column_attr[x].right_to_left_flag = 0;
    column_attr[x].reverse_input_flag = 0;
    column_attr[x].reverse_output_flag = 0;
    column_attr[x].echo_flag = 1;

    column_attr[x].minimum_value = 0;
    column_attr[x].maximum_value = 0;

    column_attr[x].horz_scroll_enable = 1;
    column_attr[x].horz_scroll_display = 0;
    column_attr[x].wrap_flag = 0;
    column_attr[x].justification = FI_LEFT_JUSTIFIED;
  }

  for (x=0; x < gadget_attr.num_cols; x++)
  {
    FIfld_get_num_rows (work_form, old_gadget_label,
        &column_attr[x].lines_default_text);

    /* Figure out number of characters visible in the column */

    FImcf_get_col_size (work_form, old_gadget_label, x, &xsize, &ysize);
    column_attr[x].num_cols = xsize / width;

    FIfld_get_mode (work_form, old_gadget_label, x,
        &column_attr[x].field_mode);

    FIfld_get_type (work_form, old_gadget_label, x,
        &column_attr[x].field_type);

    FIfld_get_attr (work_form, old_gadget_label, x, &temp_attr);

    if (temp_attr & FI_CLEAR_ON_SELECTION)
      column_attr[x].replace_text_flag = 0;
    else
      column_attr[x].replace_text_flag = 1;

    if (temp_attr & FI_NOTIFY_BY_LINE)
      column_attr[x].line_notification = 1;
    else
      column_attr[x].line_notification = 0;

    if (temp_attr & FI_NO_ECHO)
      column_attr[x].echo_flag = 0;
    else
      column_attr[x].echo_flag = 1;

    if (temp_attr & FI_REQUIRED)
      column_attr[x].required_flag = 1;
    else
      column_attr[x].required_flag = 0;

    if (temp_attr & FI_RIGHT_TO_LEFT)
      column_attr[x].right_to_left_flag = 1;
    else
      column_attr[x].right_to_left_flag = 0;

    if (temp_attr & FI_REVERSE_INPUT)
      column_attr[x].reverse_input_flag = 1;
    else
      column_attr[x].reverse_input_flag = 0;

    if (temp_attr & FI_REVERSE_OUTPUT)
      column_attr[x].reverse_output_flag = 1;
    else
      column_attr[x].reverse_output_flag = 0;

    if (temp_attr & FI_HORT_SCROLL)
      column_attr[x].horz_scroll_enable = 1;
    else
      column_attr[x].horz_scroll_enable = 0;

    if (temp_attr & FI_DISPLAY_HSCROLL)
      column_attr[x].horz_scroll_display = 1;
    else
      column_attr[x].horz_scroll_display = 0;

    column_attr[x].minimum_value = 0;
    column_attr[x].maximum_value = 0;

    FImcf_get_justification (work_form, old_gadget_label, x,
        &(column_attr[x].justification));

    FImcf_get_low_value (work_form, old_gadget_label, x,
        &(column_attr[x].minimum_value));

    FImcf_get_high_value (work_form, old_gadget_label, x,
        &(column_attr[x].maximum_value));

    FIfld_get_format_string (work_form, old_gadget_label, x,
        (unsigned char *)column_attr[x].format);

    /*****************************************************/
    /* */
    /* Finally read in all default text for the column */
    /* placing it in the mcf gadget's columns. */
    /* */
    /*****************************************************/

    FIfld_get_num_rows (work_form, old_gadget_label, &row_count);

    if ((row_count == 1) && (gadget_attr.scroll_mode == NO_SCROLLING))
    {
      FIfld_get_text (work_form, old_gadget_label, 0, x, 255, 
		  (unsigned char *)t_str,
          &dummy_int, &dummy_int);

      FIfld_set_default_text (Dummy_mcf_form, mcf, 0, x, t_str, 0);
    }
    else
    {
      for (y = 0; y < row_count; y++)
      {
        FIfld_get_text (work_form, old_gadget_label, y, x, 255,
            (unsigned char *)t_str, &dummy_int, &dummy_int);

        FIfld_set_text (Dummy_mcf_form, mcf, y, x, t_str, 0);
      }
    }
  }

  gadget_attr.gadget_type = FI_MULTI_COL;
}

/*************************************************************************/
/* */
/* show_multi_col_forms_info() */
/* */
/* This function displays the information contained in the */
/* current_gadget struct into the both form's gadgets. */
/* */
/*************************************************************************/

static void show_multi_col_forms_info(void)
{
  char t_str[256];

  if (row_select_buttons_flag == 1)
    FIg_set_state_off (Place_multi_column_form, ROW_SELECT_TOG);
  else
    FIg_set_state_on (Place_multi_column_form, ROW_SELECT_TOG);

  sprintf (t_str, "%d", gadget_attr.num_rows);
  FIfld_set_text (Place_multi_column_form,
      NUMBER_OF_ROWS_FLD, 0, 0, t_str, 0);
  sprintf (t_str, "%d", gadget_attr.num_cols);
  FIfld_set_text (Place_multi_column_form,
      NUMBER_OF_COLS_FLD, 0, 0, t_str, 0);
  sprintf (t_str, "%d", gadget_attr.visible_cols);
  FIfld_set_text (Place_multi_column_form,
      VISIBLE_COLUMNS_FLD, 0, 0, t_str, 0);

  if (gadget_attr.scroll_mode == NO_SCROLLING)
  {
    FIg_set_state_on (Place_multi_column_form, ENABLE_VERT_SCROLL);
    FIg_erase (Place_multi_column_form, DISPLAY_VERT_SCROLL);
    FIg_erase (Place_multi_column_form, VERT_NOTIFY_TOG);
  }
  else
  {
    FIg_set_state_off (Place_multi_column_form, ENABLE_VERT_SCROLL);
    FIg_display (Place_multi_column_form, DISPLAY_VERT_SCROLL);
  }

  if (gadget_attr.display_scroll_flag == 1)
  {
    FIg_set_state_off (Place_multi_column_form, DISPLAY_VERT_SCROLL);
    FIg_display (Place_multi_column_form, VERT_NOTIFY_TOG);
  }
  else
  {
    FIg_set_state_on (Place_multi_column_form, DISPLAY_VERT_SCROLL);
    FIg_erase (Place_multi_column_form, VERT_NOTIFY_TOG);
  }

  if (gadget_attr.vert_scroll_notify == 1)
    FIg_set_state_on (Place_multi_column_form, VERT_NOTIFY_TOG);
  else
    FIg_set_state_off (Place_multi_column_form, VERT_NOTIFY_TOG);

  if (gadget_attr.poke_flag == 0)
  {
    sprintf (t_str, "%d", gadget_attr.x_pos);
    FIfld_set_text (Place_multi_column_form, X_POS_FLD, 0, 0, t_str, 0);

    sprintf (t_str, "%d", gadget_attr.y_pos);
    FIfld_set_text (Place_multi_column_form, Y_POS_FLD, 0, 0, t_str, 0);

    FIg_display (Place_multi_column_form, X_POS_TEXT);
    FIg_display (Place_multi_column_form, Y_POS_TEXT);
    FIg_display (Place_multi_column_form, X_POS_FLD);
    FIg_display (Place_multi_column_form, Y_POS_FLD);

    FIg_set_state_on (Place_multi_column_form, KEYIN_TOG);
  }
  else
  {
    FIg_set_state_off (Place_multi_column_form, KEYIN_TOG);
    FIg_erase (Place_multi_column_form, X_POS_TEXT);
    FIg_erase (Place_multi_column_form, Y_POS_TEXT);
    FIg_erase (Place_multi_column_form, X_POS_FLD);
    FIg_erase (Place_multi_column_form, Y_POS_FLD);
  }

  sprintf (t_str, "%d", gadget_attr.display_format);
  FIfld_set_text (Place_multi_column_form, HEADER_MCF_FLD, 0, 0, t_str, 0);

  Show_column_info ();
}

/*-------------------------------------------------------------------------*/

/*********************************************************************/
/* */
/* create_multi_column_gadget() */
/* */
/* This function creates a new multi column field gadget and */
/* places it at the position that was specified by the operator. */
/* */
/*********************************************************************/

static void create_multi_column_gadget(void)
{
  int x, y, temp_x, temp_y;
  int characteristics;
  Window window;	/* change from int to Window for ANSI */
  char t_str[256];
  int width, height, font_type;
  int state;
  int q, i;
  int line_spacing;
  int max_rows;
  int group_label;
  int single_line_mode, horz_flag, vert_flag, button_flag;
  int high_row, row_select_flag;
  Font font_id;
  float act_bodysize;
  int dummy_int;
  int status;

  /***********************************************************/
  /* */
  /* If the work form and the place field form intersect, */
  /* then send a window update message to the work_form */
  /* */
  /***********************************************************/

  Refresh_work_form();

  column_number = 0;
  Show_column_info();

  /*******************************************************************/
  /* */
  /* Determine the width of each character in the monospaced font */
  /* that the user has selected. */
  /* */
  /*******************************************************************/

  _FI_find_font_id (gadget_attr.font_name, gadget_attr.bodysize,
      &font_id, &act_bodysize, FI_MULTI_COL, &font_type);

  _FI_calc_text (font_id, "M", 1, &height, &width, &line_spacing, font_type);

  /****************************************************************/
  /* */
  /* Specify the position and size of the field, either through */
  /* keyin values, or through data point entries. */
  /* */
  /****************************************************************/

  gadget_attr.y_size = (gadget_attr.num_rows * line_spacing) + 4;
  gadget_attr.x_size = 10;

  for (x = 0; x < gadget_attr.visible_cols; x++)
  {
    gadget_attr.x_size += (column_attr[x].num_cols * width);

    gadget_attr.x_size += 7; /* space for dividing lines */
  }

  FIf_get_window (work_form, &window);

  if (gadget_attr.poke_flag == 1) /* Get datapt for field location */
  {
    UMSGetByNum (t_str, FB_P_POKTOPMUL, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    if (gadget_attr.num_rows == 1)
      single_line_mode = 1;
    else
      single_line_mode = 0;

    FIg_get_state (Place_multi_column_form, COLUMN_SCROLL_TOG, &x);

    if (x == 1)
      horz_flag = 1;
    else
      horz_flag = 0;

    if ((gadget_attr.scroll_mode == VERTICAL_SCROLL_ONLY) &&
        (gadget_attr.display_scroll_flag == 1))
      vert_flag = 1;
    else
      vert_flag = 0;

    FIg_get_state (Place_multi_column_form, ROW_SELECT_TOG, &x);
    if (x == 1)
      row_select_flag = 0;
    else
      row_select_flag = 1;

    button_flag = 0;
    for (x = 0; x < gadget_attr.num_cols; x++)
    {
      if ((column_attr[x].horz_scroll_enable == 1) &&
          (column_attr[x].horz_scroll_display == 1))
      {
        button_flag = 1;
      }
    }

    status = Move_MCF_box (window, &gadget_attr.x_pos,
        &gadget_attr.y_pos,
        gadget_attr.x_size,
        gadget_attr.y_size, 0, 0,
        single_line_mode,
        horz_flag, vert_flag, button_flag,
        row_select_flag);

    FIg_get_state (Place_multi_column_form, ROW_SELECT_TOG, &state);
    if (state == 1) /* No row buttons */
    {
      gadget_attr.x_pos -= 10;
      if (gadget_attr.x_pos < 0)
        gadget_attr.x_pos = 0;
    }

    if (status != 2) /* Operator wants to abort the place */
    {
      return;
    }
  }

  /**********************************************************************/
  /* */
  /* Now create a brand new multi-column field gadget to hold the info */
  /* */
  /**********************************************************************/

  temp_x = gadget_attr.x_size;
  temp_y = gadget_attr.y_size;
  gadget_attr.x_size += gadget_attr.x_pos;
  gadget_attr.y_size += gadget_attr.y_pos;

  if (command_is_active == EDIT_GADGET)
  {
    FIg_get_group_label (work_form, old_gadget_label, &group_label);
    FIg_erase (work_form, old_gadget_label);
    FIg_delete (work_form, old_gadget_label);
    old_gadget_label = -1;
  }
  else
    group_label = 0;

  Create_and_init_gadget (work_form, FI_MULTI_COL, gadget_attr.gadget_label);

  if (group_label != 0)
    FIg_add_to_group (work_form, gadget_attr.gadget_label, group_label);

  gadget_attr.x_size = temp_x;
  gadget_attr.y_size = temp_y;

  FImcf_set_num_cols (work_form, gadget_attr.gadget_label,
      gadget_attr.num_cols);

  for (x = 0; x < gadget_attr.num_cols; x++)
  {
    y = width * column_attr[x].num_cols;

    FImcf_set_col_size (work_form, gadget_attr.gadget_label, x,
        y, line_spacing * gadget_attr.num_rows);

    /* */
    FIfld_set_num_vis_chars (work_form, gadget_attr.gadget_label, x,
        column_attr[x].num_cols);
    /* */
  }

  /* */
  FIfld_set_num_vis_rows (work_form, gadget_attr.gadget_label,
      gadget_attr.num_rows);

  FImcf_set_num_vis_cols (work_form, gadget_attr.gadget_label,
      gadget_attr.visible_cols);
  /* */
  /****************************************************************/
  /* */
  /* Now for each column in the multi-column field, set its info */
  /* */
  /****************************************************************/

  for (q = 0; q < gadget_attr.num_cols; q++)
  {
    characteristics = 0;

    if (column_attr[q].horz_scroll_enable)
    {
      characteristics |= FI_HORT_SCROLL;
    }

    if (column_attr[q].horz_scroll_display)
    {
      characteristics |= FI_DISPLAY_HSCROLL;
    }

    if (gadget_attr.scroll_mode == VERTICAL_SCROLL_ONLY)
    {
      characteristics |= FI_VERT_SCROLL;
    }

    if (column_attr[q].replace_text_flag == 0)
      characteristics |= FI_CLEAR_ON_SELECTION;

    if (column_attr[q].line_notification == 1)
      characteristics |= FI_NOTIFY_BY_LINE;

    if (column_attr[q].echo_flag == 0)
      characteristics |= FI_NO_ECHO;

    if (column_attr[q].required_flag == 1)
      characteristics |= FI_REQUIRED;

    if (column_attr[q].right_to_left_flag == 1)
      characteristics |= FI_RIGHT_TO_LEFT;

    if (column_attr[q].reverse_input_flag == 1)
      characteristics |= FI_REVERSE_INPUT;

    if (column_attr[q].reverse_output_flag == 1)
      characteristics |= FI_REVERSE_OUTPUT;

    FIfld_set_attr (work_form, gadget_attr.gadget_label, q,
        characteristics);

    FIfld_set_mode (work_form, gadget_attr.gadget_label, q,
        column_attr[q].field_mode);

    FIfld_set_type (work_form, gadget_attr.gadget_label, q,
        column_attr[q].field_type);

    FImcf_set_justification (work_form, gadget_attr.gadget_label,
        q, column_attr[q].justification);

    FIfld_set_format_string (work_form, gadget_attr.gadget_label,
        q, column_attr[q].format);

    FImcf_set_low_value (work_form, gadget_attr.gadget_label,
        q, column_attr[q].minimum_value);

    FImcf_set_high_value (work_form, gadget_attr.gadget_label,
        q, column_attr[q].maximum_value);
  }

  /*********************************************************************/
  /* */
  /* Now set the characteristics for the MCF as whole. I had to wait */
  /* and do this after setting up all of the columns. This is because */
  /* when the horizontal scroll bar is created, it needs to check each */
  /* of the columns to see if any of them have their individual */
  /* column horizontal scroll bar displayed. If I called MCF_set_attr */
  /* before setting up the columns, it would not have any horizontal */
  /* scrolling flags set, so the Horizontal column scroll bar would */
  /* always cover up the Individual column horizontal scroll bars. */
  /* */
  /*********************************************************************/

  characteristics = 0;

  FIg_get_state (Place_multi_column_form, COLUMN_SCROLL_TOG, &x);

  if (x == 1)
  {
    characteristics |= FI_DISPLAY_HSCROLL;
    characteristics |= FI_HORT_SCROLL;
  }

  if (gadget_attr.scroll_mode != NO_SCROLLING)
  {
    characteristics |= FI_VERT_SCROLL;

    if (gadget_attr.display_scroll_flag)
      characteristics |= FI_DISPLAY_VSCROLL;
  }
  else
  {
    characteristics |= FI_DISABLE_VSCROLL;
  }

  if (row_select_buttons_flag == 0)
    characteristics |= FI_NO_ROW_BUTTONS;

  FIg_get_state (Place_multi_column_form, POKE_TO_SELECT_ROW_TOG, &x);
  if (x == 1)
    characteristics |= FI_ROW_SELECT;

  FImcf_set_attr (work_form, gadget_attr.gadget_label, characteristics);

  FIg_activate (work_form, gadget_attr.gadget_label);

  max_rows = 0;

  for (q = 0; q < gadget_attr.num_cols; q++)
  {
    if (column_attr[q].lines_default_text > max_rows)
      max_rows = column_attr[q].lines_default_text;
  }

  high_row = 0;
  for (q = 0; q < gadget_attr.num_cols; q++)
    if (column_attr[q].lines_default_text > high_row)
      high_row = column_attr[q].lines_default_text;

  for (q = 0; q < gadget_attr.num_cols; q++)
  {
    /************************************************/
    /* */
    /* Now fill in any default text for the field */
    /* */
    /************************************************/

    if ((gadget_attr.num_rows == 1) &&
        (gadget_attr.roll_through_flag == 0) &&
        ((gadget_attr.scroll_mode == NO_SCROLLING) ||
        (gadget_attr.scroll_mode == HORIZONTAL_SCROLL_ONLY)))
    {
      FIfld_get_default_text (Dummy_mcf_form, mcf, 0, q, 255,
          (unsigned char *)t_str, &dummy_int);

      FIfld_set_default_text (work_form, gadget_attr.gadget_label,
          0, q, t_str, 0);

      FIfld_set_text (work_form, gadget_attr.gadget_label,
          0, q, t_str, 0);
    }
    else /* transfer from current text to default text */
    {
      for (x = 0; x < column_attr[q].lines_default_text; x++)
      {
        FIfld_get_text (Dummy_mcf_form, mcf, x, q,
            255, (unsigned char *)t_str, &dummy_int, &dummy_int);

        FIfld_set_default_text (work_form,
            gadget_attr.gadget_label,
            x, q, t_str, 0);
      }

      if (column_attr[q].lines_default_text < high_row)
      {
        for (i = column_attr[q].lines_default_text; i < high_row; i++);
        {
          FIfld_set_default_text (work_form,
              gadget_attr.gadget_label,
              i, q, "", 0);
        }
      }
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

  if (gadget_attr.display == 1)
    FIg_display (work_form, gadget_attr.gadget_label);

  FImcf_set_scroll_link (work_form, gadget_attr.gadget_label,
      gadget_attr.display_format);

  /*
FIf_calculate_size (work_form);
*/
}

/*************************************************************************/
/* */
/* fi_column_mode_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the default */
/* settings for a new column, or alter the settings of an */
/* existing column. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_column_mode_form(int form_label,
                        int gadget_label,
                        double value,
                        Form form_ptr)
{
  FIg_erase (Column_mode_form, EDIT_ERR_FLD);

  switch (gadget_label)
  {
  case REQUIRED_TOG:

    column_attr[column_number].required_flag = (int)value;
    break;

  case RIGHT_TO_LEFT_TOG:
    column_attr[column_number].right_to_left_flag = (int)value;

    if ((int)value == 1)
    {
      if (column_attr[column_number].reverse_input_flag == 1)
        FIg_set_state_off (Column_mode_form, REVERSE_INPUT_TOG);
      else
        FIg_set_state_on (Column_mode_form, REVERSE_INPUT_TOG);
      if (column_attr[column_number].reverse_output_flag == 1)
        FIg_set_state_off (Column_mode_form, REVERSE_OUTPUT_TOG);
      else
        FIg_set_state_on (Column_mode_form, REVERSE_OUTPUT_TOG);
      FIg_display (Column_mode_form, REVERSE_INPUT_TOG);
      FIg_display (Column_mode_form, REVERSE_OUTPUT_TOG);
    }
    else
    {
      FIg_erase (Column_mode_form, REVERSE_INPUT_TOG);
      FIg_erase (Column_mode_form, REVERSE_OUTPUT_TOG);
    }
    break;

  case REVERSE_INPUT_TOG:
    if ((int)value == 0)
      column_attr[column_number].reverse_input_flag = 1;
    else
      column_attr[column_number].reverse_input_flag = 0;
    break;

  case REVERSE_OUTPUT_TOG:
    if ((int)value == 0)
      column_attr[column_number].reverse_output_flag = 1;
    else
      column_attr[column_number].reverse_output_flag = 0;
    break;

  case REVIEW_CK:

    FIg_erase (Column_mode_form, REPLACE_TEXT_TOG);
    FIg_erase (Column_mode_form, NOTIFICATION_TOG);
    FIg_erase (Column_mode_form, ECHO_TOG);
    column_attr[column_number].field_mode = FI_REVIEW;
    break;

  case SINGLE_SELECT_CK:

    FIg_erase (Column_mode_form, REPLACE_TEXT_TOG);
    FIg_erase (Column_mode_form, NOTIFICATION_TOG);
    FIg_erase (Column_mode_form, ECHO_TOG);
    column_attr[column_number].field_mode = FI_SINGLE_SELECT;
    break;

  case MULTI_SELECT_CK:

    FIg_erase (Column_mode_form, REPLACE_TEXT_TOG);
    FIg_erase (Column_mode_form, NOTIFICATION_TOG);
    FIg_erase (Column_mode_form, ECHO_TOG);
    column_attr[column_number].field_mode = FI_MULTI_SELECT;
    break;

  case CHANGE_CK:

    FIg_display (Column_mode_form, REPLACE_TEXT_TOG);
    FIg_display (Column_mode_form, NOTIFICATION_TOG);
    FIg_display (Column_mode_form, ECHO_TOG);
    column_attr[column_number].field_mode = FI_APPEND;
    break;

  case INSERT_CK:

    FIg_display (Column_mode_form, REPLACE_TEXT_TOG);
    FIg_display (Column_mode_form, NOTIFICATION_TOG);
    FIg_display (Column_mode_form, ECHO_TOG);
    column_attr[column_number].field_mode = FI_INSERT;
    break;

  case REPLACE_TEXT_TOG:

    if ((int)value == 0)
      column_attr[column_number].replace_text_flag = 1;
    else
      column_attr[column_number].replace_text_flag = 0;
    break;

  case NOTIFICATION_TOG:

    column_attr[column_number].line_notification = (int)value;
    break;

  case ECHO_TOG:

    if ((int)value == 0)
      column_attr[column_number].echo_flag = 1;
    else
      column_attr[column_number].echo_flag = 0;
    break;

  case FI_HELP:

    break;
  }
  return;
}

/*************************************************************************/
/* */
/* fi_place_multi_column_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the default */
/* settings for a new column, or alter the settings of an */
/* existing column. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_place_multi_column_form (int form_label,
                                int gadget_label,
                                double value,
                                Form form_ptr)
{
  char t_str[256];
  int i, x;
  int num_rows;
  int status;
  int gdt_type;
  int dummy_int;

  FIg_erase (Place_multi_column_form, PLACE_ERR_FLD);

  switch (gadget_label)
  {
  case ROW_SELECT_TOG:
    if ((int)value == 1)
      row_select_buttons_flag = 0;
    else
      row_select_buttons_flag = 1;
    break;

  case HEADER_MCF_FLD:
    FIfld_get_text (Place_multi_column_form, HEADER_MCF_FLD,
        0, 0, 255, (unsigned char *)t_str, &dummy_int, &dummy_int);
    i = atoi (t_str);
    status = FIg_get_type (work_form, i, &gdt_type);

    if ((status != FI_SUCCESS) || (gdt_type != FI_MULTI_COL))
    {
      UMSGetByNum (t_str, FB_E_INVHDRMCF, 0);
      FIfld_set_text (Place_multi_column_form, 10, 0, 0, t_str, 0);
      FIg_display (Place_multi_column_form, 10);
      sprintf (t_str, "%d", gadget_attr.display_format);
      FIfld_set_text (Place_multi_column_form, HEADER_MCF_FLD,
          0, 0, t_str, 0);
    }
    else
      gadget_attr.display_format = i;
    break;

  case ENABLE_VERT_SCROLL:

    if ((int)value) /* vertical scrolling disabled */
    {
      gadget_attr.scroll_mode = NO_SCROLLING;
      FIg_erase (Place_multi_column_form, DISPLAY_VERT_SCROLL);
      FIg_erase (Place_multi_column_form, VERT_NOTIFY_TOG);

      if (gadget_attr.num_rows == 1)
      {
        FIg_erase (Verify_column_form, INITIAL_TEXT);
        FIg_erase (Verify_column_form, INITIAL_VALUES_FLD);

        FIfld_get_default_text (Dummy_mcf_form, mcf, 0,
            column_number, 255, (unsigned char *)t_str, &dummy_int);
        FIfld_set_text (Verify_column_form, DEFAULT_STR_FLD,
            0, 0, t_str, 0);

        FIg_display (Verify_column_form, DEF_TEXT);
        FIg_display (Verify_column_form, DEFAULT_STR_FLD);
      }
    }
    else /* Vertical scrolling enabled */
    {
      gadget_attr.scroll_mode = VERTICAL_SCROLL_ONLY;
      FIg_display (Place_multi_column_form, DISPLAY_VERT_SCROLL);

      FIg_erase (Verify_column_form, DEF_TEXT);
      FIg_erase (Verify_column_form, DEFAULT_STR_FLD);

      FIg_display (Verify_column_form, INITIAL_TEXT);
      FIg_display (Verify_column_form, INITIAL_VALUES_FLD);

      if (gadget_attr.display_scroll_flag == 0)
        FIg_erase (Place_multi_column_form, VERT_NOTIFY_TOG);
      else
        FIg_display (Place_multi_column_form, VERT_NOTIFY_TOG);
    }
    break;

  case DISPLAY_VERT_SCROLL:

    if ((int)value)
    {
      gadget_attr.display_scroll_flag = 0;
      FIg_erase (Place_multi_column_form, VERT_NOTIFY_TOG);
    }
    else
    {
      gadget_attr.display_scroll_flag = 1;
      FIg_display (Place_multi_column_form, VERT_NOTIFY_TOG);
    }
    break;

  case VERT_NOTIFY_TOG:

    gadget_attr.vert_scroll_notify = (int)value;
    break;

  case COLUMN_SCROLL_TOG:

    if ((int)value == 1)
    {
      if (gadget_attr.num_cols == gadget_attr.visible_cols)
      {
        FIg_set_state_off (Place_multi_column_form, COLUMN_SCROLL_TOG);

        UMSGetByNum (t_str, FB_E_TOTCOLEXC, 0);
        print_error (Place_multi_column_form, PLACE_ERR_FLD, t_str);
      }
    }
    break;

  case KEYIN_TOG:

    if ((int)value == 0)
    {
      gadget_attr.poke_flag = 1;

      FIg_erase (Place_multi_column_form, X_POS_TEXT);
      FIg_erase (Place_multi_column_form, Y_POS_TEXT);
      FIg_erase (Place_multi_column_form, X_POS_FLD);
      FIg_erase (Place_multi_column_form, Y_POS_FLD);
    }
    else /* Switch to keyin mode */
    {
      gadget_attr.poke_flag = 0;

      FIg_display (Place_multi_column_form, X_POS_TEXT);
      FIg_display (Place_multi_column_form, Y_POS_TEXT);
      FIg_display (Place_multi_column_form, X_POS_FLD);
      FIg_display (Place_multi_column_form, Y_POS_FLD);
    }
    break;

  case NUMBER_OF_ROWS_FLD:

    FIfld_get_text (Place_multi_column_form, NUMBER_OF_ROWS_FLD,
        0, 0, 255, (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Place_multi_column_form,
        PLACE_ERR_FLD, &status);

    if (status)
      if (i > 0) /* Valid input */
      {
        if (i == 1)
        {
          gadget_attr.num_rows = 1;

          if (gadget_attr.scroll_mode == NO_SCROLLING)
          {
            FIg_erase (Verify_column_form, INITIAL_TEXT);
            FIg_erase (Verify_column_form, INITIAL_VALUES_FLD);

            FIfld_get_default_text (Dummy_mcf_form, mcf, 0,
                column_number,
                255, (unsigned char *)t_str, &dummy_int);

            FIfld_set_text (Verify_column_form, DEFAULT_STR_FLD,
                0, 0, t_str, 0);

            FIg_display (Verify_column_form, DEF_TEXT);
            FIg_display (Verify_column_form, DEFAULT_STR_FLD);
          }
        }
        else
        {
          gadget_attr.num_rows = i;

          FIg_erase (Verify_column_form, DEF_TEXT);
          FIg_erase (Verify_column_form, DEFAULT_STR_FLD);

          FIfld_get_num_rows (Dummy_mcf_form, mcf, &num_rows);

          for (x = 0; x < num_rows; x++)
          {
            FIfld_get_text (Dummy_mcf_form, mcf, x,
                column_number, 255,
                (unsigned char *)t_str, &dummy_int, &dummy_int);

            FIfld_set_text (Verify_column_form,
                INITIAL_VALUES_FLD, x, 0, t_str, 0);
          }

          FIg_display (Verify_column_form, INITIAL_TEXT);
          FIg_display (Verify_column_form, INITIAL_VALUES_FLD);
        }
      }
      else /* Invalid input */
      {
        UMSGetByNum (t_str, FB_E_ROWSGTZERO, 0);
        print_error (Place_multi_column_form, PLACE_ERR_FLD, t_str);
      }
    break;

  case NUMBER_OF_COLS_FLD:

    FIfld_get_text (Place_multi_column_form, NUMBER_OF_COLS_FLD,
        0, 0, 255, (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Place_multi_column_form,
        PLACE_ERR_FLD, &status);

    if (status)
      if (i <= 0) /* Valid input */
      {
        UMSGetByNum (t_str, FB_E_COLSGTZERO, 0);
        print_error (Place_multi_column_form, PLACE_ERR_FLD, t_str);
      }
      else if (i > MAX_COLUMNS)
      {
        UMSGetByNum (t_str, FB_E_MAX100COLS, 0);
        print_error (Place_multi_column_form, PLACE_ERR_FLD, t_str);
      }
      else
      {
        if (i > max_columns)
        {
          FImcf_set_num_cols (Dummy_mcf_form, mcf, i);
          max_columns = i;
        }

        if (column_number > i)
        {
          column_number = 0;
          Show_column_info();
        }
        gadget_attr.num_cols = i;

        if (i < gadget_attr.visible_cols)
        {
          gadget_attr.visible_cols = i;

          sprintf (t_str, "%d", i);
          FIfld_set_text (Place_multi_column_form,
              VISIBLE_COLUMNS_FLD, 0, 0, t_str, 0);
        }

        if (gadget_attr.visible_cols == gadget_attr.num_cols)
          FIg_set_state_off (Place_multi_column_form, COLUMN_SCROLL_TOG);
      }
    break;

  case VISIBLE_COLUMNS_FLD:

    FIfld_get_text (Place_multi_column_form, VISIBLE_COLUMNS_FLD,
        0, 0, 255, (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Place_multi_column_form,
        PLACE_ERR_FLD, &status);

    if (status)
      if (i < 0) /* Valid input */
      {
        UMSGetByNum (t_str, FB_E_COLSGTZERO, 0);
        print_error (Place_multi_column_form, PLACE_ERR_FLD, t_str);
      }
      else if (i > gadget_attr.num_cols)
      {
        UMSGetByNum (t_str, FB_E_VISCOLEXC, 0);
        print_error (Place_multi_column_form, PLACE_ERR_FLD, t_str);

        FIfld_set_value (Place_multi_column_form, VISIBLE_COLUMNS_FLD,
            0, 0, (double)gadget_attr.visible_cols, 0);
      }
      else
      {
        gadget_attr.visible_cols = i;
      }
    break;

  case X_POS_FLD:

    FIfld_get_text (Place_multi_column_form, X_POS_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Place_multi_column_form,
        PLACE_ERR_FLD, &status);

    if (status)
      if (i < 0)
      {
        UMSGetByNum (t_str, FB_E_XNOTNEG, 0);
        print_error (Place_multi_column_form, PLACE_ERR_FLD, t_str);
      }
      else
        gadget_attr.x_pos = i;
    break;

  case Y_POS_FLD:

    FIfld_get_text (Place_multi_column_form, Y_POS_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Place_multi_column_form,
        PLACE_ERR_FLD, &status);

    if (status)
      if (i < 0)
      {
        UMSGetByNum (t_str, FB_E_YNOTNEG, 0);
        print_error (Place_multi_column_form, PLACE_ERR_FLD, t_str);
      }
      else
        gadget_attr.y_pos = i;
    break;

  case FI_HELP:

    /* Help_topic ("Multi column field") */
    break;

  case FI_CANCEL:

    if (command_is_active == EDIT_GADGET)
    {
      if (edit_hilite_flag == 0)
        FIg_unhilite (work_form, old_gadget_label);

      if (edit_display_flag == 0)
        FIg_erase (work_form, old_gadget_label);
    }

    kill_place_multi_col_field();
    FIg_set_state_off (Place_multi_column_form, FI_CANCEL);
    break;

  case FI_ACCEPT:

    FIf_erase (Place_multi_column_form);
    FIf_erase (Edit_column_form);
    FIf_erase (Column_mode_form);
    FIf_erase (Verify_column_form);

    FIg_set_state_off (Edit_column_form, EDIT_OPT_CK);
    FIg_set_state_off (Edit_column_form, VERIFY_OPT_CK);

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

    create_multi_column_gadget();

    FIg_set_state_off (Place_multi_column_form, FI_ACCEPT);

    if (command_is_active == EDIT_GADGET)
      kill_place_multi_col_field();
    else /* Do command again */
    {
      FIf_display (Place_multi_column_form);
      FIf_display (Edit_column_form);

      FIf_get_next_label (work_form, &gadget_attr.gadget_label);

      if (Characteristics_form != NULL)
      {
        override_attr.gadget_label = gadget_attr.gadget_label;

        sprintf (t_str, "%d", override_attr.gadget_label);
        FIfld_set_text (Characteristics_form, LABEL_FLD,
            0, 0, t_str, 0);

        FIg_erase (Characteristics_form, 10);
      }

      UMSGetByNum (t_str, FB_P_FILLMULCOL, 0);
    }
    break;
  }
  return;
}

/*************************************************************************/
/* */
/* fi_verify_column_form() */
/* */
/* This function works inthe same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the default */
/* settings for a new column, or alter the settings of an */
/* existing column. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_verify_column_form(int form_label,
                          int gadget_label,
                          double value,
                          Form form_ptr)
{
  char t_str[256];
  int x, i;
  double f;
  char default_str[256];
  int num_rows;
  int dummy_int;
  int status;

  FIg_erase (Verify_column_form, VERIFY_ERR_FLD);

  switch (gadget_label)
  {
  case FORMAT_FLD:

    FIfld_get_text (Verify_column_form, FORMAT_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);
    strcpy (column_attr[column_number].format, t_str);
    break;

  case DEFAULT_STR_FLD:

    FIfld_get_text (Verify_column_form, DEFAULT_STR_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    if (column_attr[column_number].field_type == FI_ALPHA)
    {
      FIfld_set_default_text (Dummy_mcf_form, mcf, 0, column_number, t_str, 0);
    }

    if (column_attr[column_number].field_type == FI_INT)
    {
      i = validate_integer_field (t_str, Verify_column_form,
          VERIFY_ERR_FLD, &status);
      if (status)
        if (((i < (int)column_attr[column_number].minimum_value) ||
            (i > (int)column_attr[column_number].maximum_value)) &&
            (i != 0))
        {
          UMSGetByNum (t_str, FB_E_VALOUTLMT, 0);
          print_error (Verify_column_form, VERIFY_ERR_FLD, t_str);
        }
        else
          FIfld_set_default_text (Dummy_mcf_form, mcf, 0, column_number, t_str, 0);
    }

    if (column_attr[column_number].field_type == FI_DOUBLE)
    {
      f = validate_double_field (t_str, Verify_column_form,
          VERIFY_ERR_FLD, &status);
      if (status)
        if (((f < column_attr[column_number].minimum_value) ||
            (f > column_attr[column_number].maximum_value)) &&
            (f != 0))
        {
          UMSGetByNum (t_str, FB_E_VALOUTLMT, 0);
          print_error (Verify_column_form, VERIFY_ERR_FLD, t_str);
        }
        else
          FIfld_set_default_text (Dummy_mcf_form, mcf, 0, column_number, t_str, 0);
    }
    break;

  case MINIMUM_FLD:

    FIfld_get_text (Verify_column_form, MINIMUM_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    FIfld_get_text (Verify_column_form, DEFAULT_STR_FLD, 0, 0, 255,
        (unsigned char *)default_str, &dummy_int, &dummy_int);

    if (column_attr[column_number].field_type == FI_INT)
    {
      i = validate_integer_field (t_str, Verify_column_form,
          VERIFY_ERR_FLD, &status);
      if (status)
        if (i > (int)column_attr[column_number].maximum_value)
        {
          UMSGetByNum (t_str, FB_E_MINLEMAX, 0);
          print_error (Verify_column_form, VERIFY_ERR_FLD, t_str);
        }
        else
          column_attr[column_number].minimum_value = (double)i;
    }

    if (column_attr[column_number].field_type == FI_DOUBLE)
    {
      f = validate_double_field (t_str, Verify_column_form,
          VERIFY_ERR_FLD, &status);
      if (status)
        if (f > column_attr[column_number].maximum_value)
        {
          UMSGetByNum (t_str, FB_E_MINLEMAX, 0);
          print_error (Verify_column_form, VERIFY_ERR_FLD, t_str);
        }
        else
          column_attr[column_number].minimum_value = f;
    }
    break;

  case MAXIMUM_FLD:

    FIfld_get_text (Verify_column_form, MAXIMUM_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    FIfld_get_text (Verify_column_form, DEFAULT_STR_FLD, 0, 0, 255,
        (unsigned char *)default_str, &dummy_int, &dummy_int);

    if (column_attr[column_number].field_type == FI_INT)
    {
      i = validate_integer_field (t_str, Verify_column_form,
          VERIFY_ERR_FLD, &status);
      if (status)
        if (i < (int)column_attr[column_number].minimum_value)
        {
          UMSGetByNum (t_str, FB_E_MAXGEMIN, 0);
          print_error (Verify_column_form, VERIFY_ERR_FLD, t_str);
        }
        else
          column_attr[column_number].maximum_value = (double)i;
    }

    if (column_attr[column_number].field_type == FI_DOUBLE)
    {
      f = validate_double_field (t_str, Verify_column_form,
          VERIFY_ERR_FLD, &status);
      if (status)
        if (f < column_attr[column_number].minimum_value)
        {
          UMSGetByNum (t_str, FB_E_MAXGEMIN, 0);
          print_error (Verify_column_form, VERIFY_ERR_FLD, t_str);
        }
        else
          column_attr[column_number].maximum_value = f;
    }
    break;

  case INITIAL_VALUES_FLD:

    if ((int)value >= 0)
    {
      FIfld_get_num_rows (Verify_column_form, INITIAL_VALUES_FLD,
          &num_rows);

      for (x = 0; x < num_rows; x++)
      {
        FIfld_get_text (Verify_column_form, INITIAL_VALUES_FLD,
            x, 0, 255, (unsigned char *)t_str, &dummy_int, &dummy_int);

        FIfld_set_text (Dummy_mcf_form, mcf, x, column_number,
            t_str, 0);
      }
    }
    break;
  }
  return;
}

/*--------------------------------------------------------------------------*/

static void Validate_column_width(void)
{
  char t_str[256];
  int dummy_int;
  int i, status;

  FIfld_get_text (Edit_column_form, WIDTH_IN_CHARACTERS, 0, 0, 255,
      (unsigned char *)t_str, &dummy_int, &dummy_int);

  i = validate_integer_field (t_str, Edit_column_form,
      EDIT_COL_ERR_FLD, &status);
  if (status)
  {
    if (i < 1)
    {
      UMSGetByNum (t_str, FB_E_WIDGEONE, 0);
      print_error (Edit_column_form, EDIT_COL_ERR_FLD, t_str);
    }
    else
    {
      column_attr[column_number].num_cols = i;
    }
  }
}

/*************************************************************************/
/* */
/* fi_edit_column_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the default */
/* settings for a new multi-column field gadget, or alter the settings */
/* of an existing multi-column field gadget. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_edit_column_form (int form_label,
                         int gadget_label,
                         double value,
                         Form form_ptr)
{
  int i;
  char t_str[256];
  int dummy_int;
  int status;

  FIg_erase (Edit_column_form, EDIT_COL_ERR_FLD);

  switch (gadget_label)
  {
  case COLUMN_NUMBER:

    FIfld_get_text (Edit_column_form, COLUMN_NUMBER, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Edit_column_form,
        EDIT_COL_ERR_FLD, &status);
    if (status)
      if (i >= gadget_attr.num_cols)
      {
        UMSGetByNum (t_str, FB_E_NOTENGHCOL, 0);
        print_error (Edit_column_form, EDIT_COL_ERR_FLD, t_str);
      }
      else if (i < 0)
      {
        UMSGetByNum (t_str, FB_E_LOWCOLZERO, 0);
        print_error (Edit_column_form, EDIT_COL_ERR_FLD, t_str);
      }
      else
      {
        column_number = i;
        Show_column_info();
      }
    break;

  case UP_BUTTON:

    Validate_column_width();

    if (column_number < (gadget_attr.num_cols - 1))
    {
      column_number++;
      Show_column_info();
    }
    FIg_set_state_off (Edit_column_form, UP_BUTTON);
    break;

  case DOWN_BUTTON:

    Validate_column_width();

    if (column_number > 0)
    {
      column_number--;
      Show_column_info();
    }
    FIg_set_state_off (Edit_column_form, DOWN_BUTTON);
    break;

  case WIDTH_IN_CHARACTERS:

    Validate_column_width();
    break;

  case ASCII_CK:

    FIg_set_state_on (Edit_column_form, ASCII_CK);

    column_attr[column_number].field_type = FI_ALPHA;

    FIg_erase (Verify_column_form, MIN_TEXT);
    FIg_erase (Verify_column_form, MAX_TEXT);
    FIg_erase (Verify_column_form, MINIMUM_FLD);
    FIg_erase (Verify_column_form, MAXIMUM_FLD);
    FIg_erase (Verify_column_form, FORMAT_TEXT);
    FIg_erase (Verify_column_form, FORMAT_FLD);

    column_attr[column_number].minimum_value = 0.0;
    column_attr[column_number].maximum_value = 0.0;
    break;

  case INT_CK:

    FIg_set_state_on (Edit_column_form, INT_CK);

    column_attr[column_number].field_type = FI_INT;

    FIfld_set_text (Verify_column_form, FORMAT_FLD, 0, 0, "%d", 0);
    strcpy (column_attr[column_number].format, "%d");

    FIg_display (Verify_column_form, MIN_TEXT);
    FIg_display (Verify_column_form, MAX_TEXT);
    FIg_display (Verify_column_form, MINIMUM_FLD);
    FIg_display (Verify_column_form, MAXIMUM_FLD);
    FIg_display (Verify_column_form, FORMAT_TEXT);
    FIg_display (Verify_column_form, FORMAT_FLD);
    break;

  case FLOAT_CK:

    FIg_set_state_on (Edit_column_form, FLOAT_CK);

    column_attr[column_number].field_type = FI_DOUBLE;

    FIfld_set_text (Verify_column_form, FORMAT_FLD, 0, 0, "%lG", 0);
    strcpy (column_attr[column_number].format, "%lG");

    FIg_display (Verify_column_form, MIN_TEXT);
    FIg_display (Verify_column_form, MAX_TEXT);
    FIg_display (Verify_column_form, MINIMUM_FLD);
    FIg_display (Verify_column_form, MAXIMUM_FLD);
    FIg_display (Verify_column_form, FORMAT_TEXT);
    FIg_display (Verify_column_form, FORMAT_FLD);
    break;

  case ENABLE_HORZ_SCROLL:

    if ((int)value) /* Horizontal scrolling off */
    {
      column_attr[column_number].horz_scroll_enable = 0;
      column_attr[column_number].horz_scroll_display = 0;
      FIg_erase (Edit_column_form, DISPLAY_HORZ_SCROLL);
      FIg_set_state_off (Edit_column_form, DISPLAY_HORZ_SCROLL);
    }
    else
    {
      if (column_attr[column_number].justification != FI_LEFT_JUSTIFIED)
      {
        UMSGetByNum (t_str, FB_E_MSTBELEFT, 0);
        print_error (Edit_column_form, EDIT_COL_ERR_FLD, t_str);
        FIg_set_state_on (Edit_column_form, ENABLE_HORZ_SCROLL);
      }
      else
      {
        column_attr[column_number].horz_scroll_enable = 1;
        FIg_display (Edit_column_form, DISPLAY_HORZ_SCROLL);
      }
    }
    break;

  case DISPLAY_HORZ_SCROLL:

    if ((int)value) /* Don't display horizontal scroll bar */
      column_attr[column_number].horz_scroll_display = 1;
    else
      column_attr[column_number].horz_scroll_display = 0;
    break;

  case WRAP_TOG:

    if ((int)value) /* wants wrap mode */
    {
      if (column_attr[column_number].horz_scroll_enable)
      {
        UMSGetByNum (t_str, FB_E_NOWRPHRZSCRL, 0);
        print_error (Edit_column_form, EDIT_COL_ERR_FLD, t_str);
        FIg_set_state_off (Edit_column_form, WRAP_TOG);
      }
      else
        column_attr[column_number].wrap_flag = 1;
    }
    else
    {
      column_attr[column_number].wrap_flag = 0;
    }
    break;

  case LEFT_JUSTIFY_CK:

    column_attr[column_number].justification = FI_LEFT_JUSTIFIED;
    break;

  case RIGHT_JUSTIFY_CK:

    if (column_attr[column_number].horz_scroll_enable)
    {
      column_attr[column_number].justification = FI_LEFT_JUSTIFIED;
      UMSGetByNum (t_str, FB_E_MSTBELEFT, 0);
      print_error (Edit_column_form, EDIT_COL_ERR_FLD, t_str);
      FIg_set_state_off (Edit_column_form, RIGHT_JUSTIFY_CK);
      FIg_set_state_on (Edit_column_form, LEFT_JUSTIFY_CK);
    }
    else
      column_attr[column_number].justification = FI_RIGHT_JUSTIFIED;
    break;


  case CENTER_JUSTIFY_CK:

    if (column_attr[column_number].horz_scroll_enable)
    {
      column_attr[column_number].justification = FI_LEFT_JUSTIFIED;
      UMSGetByNum (t_str, FB_E_MSTBELEFT, 0);
      print_error (Edit_column_form, EDIT_COL_ERR_FLD, t_str);
      FIg_set_state_off (Edit_column_form, CENTER_JUSTIFY_CK);
      FIg_set_state_on (Edit_column_form, LEFT_JUSTIFY_CK);
    }
    else
      column_attr[column_number].justification = FI_CENTER_JUSTIFIED;
    break;

  case EDIT_OPT_CK:

    FIg_set_state_on (Edit_column_form, EDIT_OPT_CK);

    FIf_is_displayed (Verify_column_form, &status);

    if (status)
      FIf_erase (Verify_column_form);

    FIf_is_displayed (Column_mode_form, &status);

    if (!status)
      FIf_display (Column_mode_form);
    break;

  case VERIFY_OPT_CK:

    FIg_set_state_on (Edit_column_form, VERIFY_OPT_CK);

    FIf_is_displayed (Column_mode_form, &status);

    if (status)
      FIf_erase (Column_mode_form);

    FIf_is_displayed (Verify_column_form, &status);

    if (!status)
      FIf_display (Verify_column_form);
    break;

  case FI_HELP:

    /* Help_topic ("Field") */
    break;
  }
  return;
}

/* ARGSUSED */
void dummy_notification_routine (int form,
                                int label,
                                double value,
                                Form form_ptr)
{
  return;
}

/*************************************************************************/
/* */
/* execute_place_multi_col_field() */
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

void execute_place_multi_col_field(void)
{
  char t_str[256];
  int x;
  int status;
  int mask;

  if (work_form == NULL) /* No form defined */
  {
    strcpy (current_command_string, "None");
    command_is_active = 0;
    return;
  }

  UMSGetByNum (t_str, FB_I_PLCMULCOL, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENDEF, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Column_mode_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBEdFlOpt");
    status = FIf_new (998, t_str, (int (*)())fi_column_mode_form, &Column_mode_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
    FIf_set_location (Column_mode_form, 245, 120);
  }

  if (Verify_column_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBVrAsLsFl");
    status = FIf_new (997, t_str, (int (*)())fi_verify_column_form, &Verify_column_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
    FIf_set_location (Verify_column_form, 220, 120);
  }

  FIg_erase (Verify_column_form, 12);

  if (Place_multi_column_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlMlClFl");
    status = FIf_new (996, t_str, (int (*)())fi_place_multi_column_form,
        &Place_multi_column_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);

    FIf_set_location (Place_multi_column_form, 615, 120);
  }

  if (Edit_column_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBEdMlCl");
    status = FIf_new (995, t_str, (int (*)())fi_edit_column_form,
        &Edit_column_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);

    FIf_set_location (Edit_column_form, 615, 530);
  }

  FIf_set_location (Column_mode_form, 245, 120);
  FIf_set_location (Verify_column_form, 220, 120);

  /************************************/
  /* */
  /* Create multi-column field gadget */
  /* */
  /************************************/

  Set_new_gadget_defaults();

  gadget_attr.display = 0; /* Prevent display for now */

  gadget_attr.x_pos = 10;
  gadget_attr.y_pos = 10;
  gadget_attr.x_size = 300;
  gadget_attr.y_size = 150;
  strcpy (gadget_attr.font_name, "mono821");
  gadget_attr.bodysize = 15.0;

  mcf = 0;

  if (mcf == 0)
  {
    if (Dummy_mcf_form == NULL)
      FIf_new (111, "FBBckgnd", (int (*)())dummy_notification_routine, &Dummy_mcf_form);
    mcf = 1000;

    Create_and_init_gadget (Dummy_mcf_form, FI_MULTI_COL, mcf);

    mask = 0;
    mask |= FI_VERT_SCROLL;

    FImcf_set_attr (Dummy_mcf_form, mcf, mask);

    FImcf_set_num_cols (Dummy_mcf_form, mcf, 100);

    mask = 0;
    mask |= FI_HORT_SCROLL;
    mask |= FI_VERT_SCROLL;

    for (x = 0; x < 10; x++)
      FIfld_set_attr (Dummy_mcf_form, mcf, x, mask);

    for (x = 0; x < 3; x++)
      FImcf_set_col_size (Dummy_mcf_form, mcf, x, 100, 150);

    FIg_activate (Dummy_mcf_form, mcf);
  }

  setup_new_multi_col_form();

  show_multi_col_forms_info();

  FIf_display (Place_multi_column_form);

  FIf_display (Edit_column_form);

  FIf_get_next_label (work_form, &gadget_attr.gadget_label);

  if (Characteristics_form != NULL)
    Update_characteristics_form();

  UMSGetByNum (t_str, FB_P_FILLMULCOL, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}

/*---------------------------------------------------------------------------*/

void edit_multi_col_field_gadget(void)
{
  char t_str[256];
  int x;
  int status;
  int mask;

  if (work_form == NULL) /* No form defined */
  {
    strcpy (current_command_string, "None");
    command_is_active = 0;
    return;
  }

  UMSGetByNum (t_str, FB_I_EDTMULCOL, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENCUR, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Column_mode_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBEdFlOpt");
    status = FIf_new (998, t_str, (int (*)())fi_column_mode_form, &Column_mode_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
    FIf_set_location (Column_mode_form, 245, 120);
  }

  if (Verify_column_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBVrAsLsFl");
    status = FIf_new (997, t_str, (int (*)())fi_verify_column_form, &Verify_column_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
    FIf_set_location (Verify_column_form, 220, 120);
  }

  FIg_erase (Verify_column_form, 12);

  if (Place_multi_column_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBPlMlClFl");
    status = FIf_new (996, t_str, (int (*)())fi_place_multi_column_form,
        &Place_multi_column_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);

    FIf_set_location (Place_multi_column_form, 615, 120);
  }

  if (Edit_column_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBEdMlCl");
    status = FIf_new (995, t_str, (int (*)())fi_edit_column_form,
        &Edit_column_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);

    FIf_set_location (Edit_column_form, 615, 530);
  }

  FIf_set_location (Column_mode_form, 245, 120);
  FIf_set_location (Verify_column_form, 220, 120);

  /************************************/
  /* */
  /* Create multi-column field gadget */
  /* */
  /************************************/

  Set_new_gadget_defaults();

  gadget_attr.display = 0; /* Prevent display for now */

  gadget_attr.x_pos = 10;
  gadget_attr.y_pos = 10;
  gadget_attr.x_size = 300;
  gadget_attr.y_size = 150;
  strcpy (gadget_attr.font_name, "mono821");
  gadget_attr.bodysize = 15.0;

  mcf = 0;

  if (mcf == 0)
  {
    if (Dummy_mcf_form == NULL)
      FIf_new (111, "FBBckgnd", (int (*)())dummy_notification_routine, &Dummy_mcf_form);

    mcf = 1000;

    Create_and_init_gadget (Dummy_mcf_form, FI_MULTI_COL, mcf);

    mask = 0;
    mask |= FI_VERT_SCROLL;

    FImcf_set_attr (Dummy_mcf_form, mcf, mask);

    FImcf_set_num_cols (Dummy_mcf_form, mcf, 100);

    mask |= FI_HORT_SCROLL;

    for (x = 0; x < 10; x++)
      FIfld_set_attr (Dummy_mcf_form, mcf, x, mask);

    for (x = 0; x < 3; x++)
      FImcf_set_col_size (Dummy_mcf_form, mcf, x, 100, 150);

    FIg_activate (Dummy_mcf_form, mcf);
  }

  gadget_attr.gadget_label = old_gadget_label;

  setup_old_multi_col_form();

  show_multi_col_forms_info();

  FIf_display (Place_multi_column_form);

  FIf_display (Edit_column_form);

  if (Characteristics_form != NULL)
    Update_characteristics_form();

  UMSGetByNum (t_str, FB_P_FILLMULCOL, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}
