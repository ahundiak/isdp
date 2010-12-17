/***********************************

		change_pv.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
*/

/*************************************/
/* */
/* This file contains functions for the "change pv" and "edit field" */
/* commands. */
/* */
/* Programmer: Mack Draper */
/* Date: Jan. 3, 1989 */
/* */
/*************************************/

#include <stdio.h>

#include <X11/Xlib.h>

#include "FI.h"
#include "NFBpriv.h"
#include "UMS.h"
#include "FB.h"

#include "XFIproto_pub.h"
#include "XFBproto_pri.h"

/*********************************/
/* */
/* Gadget labels for pv forms */
/* */
/*********************************/

#define CANCEL 4
#define HELP 6
#define ACCEPT 1

/****************************/
/* */
/* used by Master_pv_form */
/* */
/****************************/

#define ACTIVE_FORM_FLD 47

#define FOREGROUND_CLR_BTN 16
#define BACKGROUND_CLR_BTN 17
#define FOREGROUND2_CLR_BTN 37
#define LINE_STYLE_BTN 21
#define LINE_WEIGHT_BTN 20
#define TEXT_FONT_BTN 32

#define GRID_DISPLAY_TOG 25
#define GRID_PATTERN_TOG 18

#define LINE_DEPTH_TOG 48
#define COMMAND_AUTOKILL_TOG 35

#define X_TEXT 26
#define X_FLD 23
#define X_PERCENT_TEXT 24
#define Y_TEXT 22
#define Y_FLD 15
#define Y_PERCENT_TEXT 19
#define BOUNDARY_TOG 14

/************************/
/* */
/* Used by Font_form */
/* */
/************************/

#define TYPEFACE_FLD 15
#define SIZE_FLD 16

#define SAMPLE_HEADER 23
#define SAMPLE_TEXT 24
#define TYPEFACE_LIST_FLD 22

#define NORMAL_CK 21
#define EMBOSSED_CK 25
#define INCISED_CK 26
#define SHADOWED_CK 14

#define LEFT_JUST_CK 28
#define CENTER_JUST_CK 27
#define RIGHT_JUST_CK 29

#define ERR_FLD 10

/***********************/
/* */
/* Used by Grid_form */
/* */
/***********************/

#define GRID_15_5_BTN 26
#define GRID_25_25_BTN 16
#define GRID_50_25_BTN 17
#define GRID_75_25_BTN 18
#define GRID_100_25_BTN 19
#define GRID_SPECIFY_BTN 20

#define GRID_ERR_FLD 10

#define MASTER_UNITS_SYM 12
#define MASTER_UNITS_FLD 14
#define SUB_UNITS_SYM 13
#define SUB_UNITS_FLD 15
#define MASTER_UNITS_TEXT 24
#define SUB_UNITS_TEXT 25

/*******************************/
/* */
/* Used by Line_weight_form */
/* */
/*******************************/

#define LINE_WEIGHT_SLIDER 12
#define LINE_WEIGHT_LINE 15

/*****************************/
/* */
/* Used by Line_style_form */
/* */
/*****************************/

#define SOLID_CK 30
#define DOTTED_CK 31
#define UNEVEN_DASH_CK 32
#define DASH_CK 33
#define DOT_DASH_CK 34
#define SHORT_DASH_CK 35
#define DOT_DOT_DASH_CK 36
#define LONG_SHORT_DASH_CK 37

/*************************/
/* */
/* Used by Color_forms */
/* */
/*************************/

#define COLOR_SLOT_0_BTN 27
#define COLOR_SLOT_1_BTN 28
#define COLOR_SLOT_2_BTN 29
#define COLOR_SLOT_3_BTN 30
#define COLOR_SLOT_4_BTN 31
#define COLOR_SLOT_5_BTN 32
#define COLOR_SLOT_6_BTN 33
#define COLOR_SLOT_7_BTN 34
#define COLOR_SLOT_8_BTN 35
#define COLOR_SLOT_9_BTN 36
#define COLOR_SLOT_10_BTN 37
#define COLOR_SLOT_11_BTN 38
#define COLOR_SLOT_12_BTN 39
#define COLOR_SLOT_13_BTN 40

#define COLOR_TEXT 41
#define COLOR_FLD 12

/**********************************/
/* */
/* Used by Characteristics form */
/* */
/**********************************/

#define CHAR_FOREGROUND_CLR_BTN 47
#define CHAR_FOREGROUND2_CLR_BTN 48
#define CHAR_LINE_STYLE_BTN 27
#define CHAR_LINE_WEIGHT_BTN 26
#define CHAR_TEXT_FONT_BTN 46

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

Form Master_pv_form;
Form Font_form;
Form Grid_form;
Form Line_weight_form;
Form Line_style_form;
Form FG_color_form;
Form BG_color_form;
Form FG2_color_form;

struct dpb_struct temp_dpb;
short line_style[8];
int temp_autokill_flag;

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern struct form_data form_attr;
extern Form work_form;
extern Form Characteristics_form;
extern Form Message_form;
extern struct dpb_struct dpb;
extern int command_is_active;
extern int autokill_mode;
extern char current_command_string[80];
extern struct gadget_struct gadget_attr;
extern char execute_dir[200];

extern Form Edit_form;
extern Form Font_options_form;
extern Form Master_field_form;

extern char language[80];
extern Display *display;
extern void Report_fatal_form_error();

/*************************************************************************/
/* */
/* kill_change_pv() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to CHANGE_PV indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_change_pv(void)
{
  char t_str[256];

  if (Master_pv_form != NULL)
    FIf_erase (Master_pv_form);

  if (Font_form != NULL)
    FIf_erase (Font_form);

  if (Grid_form != NULL)
    FIf_erase (Grid_form);

  if (Line_weight_form != NULL)
    FIf_erase (Line_weight_form);

  if (Line_style_form != NULL)
    FIf_erase (Line_style_form);

  if (FG_color_form != NULL)
    FIf_erase (FG_color_form);

  if (BG_color_form != NULL)
    FIf_erase (BG_color_form);

  if (FG2_color_form != NULL)
    FIf_erase (FG2_color_form);

  FIg_set_state_off (Master_pv_form, ACCEPT);
  FIg_set_state_off (Master_pv_form, CANCEL);

  command_is_active = 0;
  strcpy (current_command_string, "None");

  UMSGetByNum (t_str, FB_P_SELCOM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
  FIfld_set_text (Message_form, 11, 0, 0, "", 0);
}

/*************************************************************************/
/* */
/* setup_master_pv_form() */
/* */
/* This function is called each time the operator wishes to place a */
/* new field on the work form. It will fill in default settings for */
/* the presentation values form. */
/* */
/*************************************************************************/

static void setup_master_pv_form(void)
{
  int x;
  char t_str[256];

  for (x = 27; x <= 40; x++)
  {
    FIg_set_off_color (FG_color_form, x, (x - 27));
    FIg_set_off_color (BG_color_form, x, (x - 27));
    FIg_set_off_color (FG2_color_form, x, (x - 27));

    FIg_set_on_color (FG_color_form, x, (x - 27));
    FIg_set_on_color (BG_color_form, x, (x - 27));
    FIg_set_on_color (FG2_color_form, x, (x - 27));
  }

  /*********************************************/
  /* */
  /* Set up boundary margin for form gadgets */
  /* */
  /*********************************************/

  if (dpb.expansion4 == 0) /* Boundaries turned off */
  {
    FIg_set_state_off (Master_pv_form, BOUNDARY_TOG);

    FIg_erase (Master_pv_form, X_TEXT);
    FIg_erase (Master_pv_form, X_FLD);
    FIg_erase (Master_pv_form, X_PERCENT_TEXT);
    FIg_erase (Master_pv_form, Y_TEXT);
    FIg_erase (Master_pv_form, Y_FLD);
    FIg_erase (Master_pv_form, Y_PERCENT_TEXT);
  }
  else
  {
    FIg_set_state_on (Master_pv_form, BOUNDARY_TOG);

    FIg_display (Master_pv_form, X_TEXT);
    FIg_display (Master_pv_form, X_FLD);
    FIg_display (Master_pv_form, X_PERCENT_TEXT);
    FIg_display (Master_pv_form, Y_TEXT);
    FIg_display (Master_pv_form, Y_FLD);
    FIg_display (Master_pv_form, Y_PERCENT_TEXT);
  }

  sprintf (t_str, "%d", dpb.expansion2); /* X boundary_factor */
  FIg_set_text (Master_pv_form, X_FLD, t_str);
  sprintf (t_str, "%d", dpb.expansion3); /* Y boundary_factor */
  FIg_set_text (Master_pv_form, Y_FLD, t_str);

  /*****************************************************************/
  /* */
  /* Set the color indexes of the foreground, background, and */
  /* foreground2 buttons on the master pv form. */
  /* */
  /*****************************************************************/

  FIg_set_off_color (Master_pv_form, FOREGROUND_CLR_BTN, dpb.off_color);
  FIg_set_on_color (Master_pv_form, FOREGROUND_CLR_BTN, dpb.off_color);

  if (dpb.bgcolor != 4)
  {
    FIg_set_off_color (Master_pv_form, BACKGROUND_CLR_BTN, dpb.bgcolor);
    FIg_set_on_color (Master_pv_form, BACKGROUND_CLR_BTN, dpb.bgcolor);
  }
  else
  {
    FIg_set_off_color (Master_pv_form, BACKGROUND_CLR_BTN, 1);
    FIg_set_on_color (Master_pv_form, BACKGROUND_CLR_BTN, 1);
  }

  FIg_set_off_color (Master_pv_form, FOREGROUND2_CLR_BTN, dpb.on_color);
  FIg_set_on_color (Master_pv_form, FOREGROUND2_CLR_BTN, dpb.on_color);

  if (autokill_mode == 1)
    FIg_set_state_on (Master_pv_form, COMMAND_AUTOKILL_TOG);
  else
    FIg_set_state_off (Master_pv_form, COMMAND_AUTOKILL_TOG);

  if (dpb.line_depth == FI_3D_LINE)
    FIg_set_state_on (Master_pv_form, LINE_DEPTH_TOG);
  else
    FIg_set_state_off (Master_pv_form, LINE_DEPTH_TOG);

  if (dpb.grid_flag == 1)
    FIg_set_state_on (Master_pv_form, GRID_DISPLAY_TOG);
  else
    FIg_set_state_off (Master_pv_form, GRID_DISPLAY_TOG);

  FIg_set_state_off (Master_pv_form, FOREGROUND_CLR_BTN);
  FIg_set_state_off (Master_pv_form, BACKGROUND_CLR_BTN);
  FIg_set_state_off (Master_pv_form, FOREGROUND2_CLR_BTN);
  FIg_set_state_off (Master_pv_form, LINE_STYLE_BTN);
  FIg_set_state_off (Master_pv_form, LINE_WEIGHT_BTN);
  FIg_set_state_off (Master_pv_form, TEXT_FONT_BTN);
  FIg_set_state_off (Master_pv_form, GRID_PATTERN_TOG);

  /**********************************************/
  /* */
  /* Set the active form fld if one is active */
  /* */
  /**********************************************/

  FIfld_set_text (Master_pv_form, ACTIVE_FORM_FLD, 0, 0,
      form_attr.new_form_name, 0);

  FIg_set_state_off (Grid_form, GRID_15_5_BTN);
  FIg_set_state_off (Grid_form, GRID_25_25_BTN);
  FIg_set_state_off (Grid_form, GRID_50_25_BTN);
  FIg_set_state_off (Grid_form, GRID_75_25_BTN);
  FIg_set_state_off (Grid_form, GRID_100_25_BTN);
  FIg_set_state_off (Grid_form, GRID_SPECIFY_BTN);

  FIg_erase (Grid_form, MASTER_UNITS_SYM);
  FIg_erase (Grid_form, MASTER_UNITS_FLD);
  FIg_erase (Grid_form, MASTER_UNITS_TEXT);
  FIg_erase (Grid_form, SUB_UNITS_SYM);
  FIg_erase (Grid_form, SUB_UNITS_FLD);
  FIg_erase (Grid_form, SUB_UNITS_TEXT);

  if ((dpb.grid_master_units == 15) &&
      (dpb.grid_sub_units == 5))
    FIg_set_state_on (Grid_form, GRID_15_5_BTN);
  else
    if ((dpb.grid_master_units == 25) &&
        (dpb.grid_sub_units == 25))
      FIg_set_state_on (Grid_form, GRID_25_25_BTN);
    else
      if ((dpb.grid_master_units == 50) &&
          (dpb.grid_sub_units == 25))
        FIg_set_state_on (Grid_form, GRID_50_25_BTN);
      else
        if ((dpb.grid_master_units == 75) &&
            (dpb.grid_sub_units == 25))
          FIg_set_state_on (Grid_form, GRID_75_25_BTN);
        else
          if ((dpb.grid_master_units == 100) &&
              (dpb.grid_sub_units == 25))
            FIg_set_state_on (Grid_form, GRID_100_25_BTN);
          else
          {
            FIg_set_state_on (Grid_form, GRID_SPECIFY_BTN);

            sprintf (t_str, "%d", dpb.grid_master_units);

            FIfld_set_text (Grid_form, MASTER_UNITS_FLD, 0, 0, t_str, 0);
            FIg_display (Grid_form, MASTER_UNITS_SYM);
            FIg_display (Grid_form, MASTER_UNITS_FLD);
            FIg_display (Grid_form, MASTER_UNITS_TEXT);

            sprintf (t_str, "%d", dpb.grid_sub_units);

            FIfld_set_text (Grid_form, SUB_UNITS_FLD, 0, 0, t_str, 0);
            FIg_display (Grid_form, SUB_UNITS_SYM);
            FIg_display (Grid_form, SUB_UNITS_FLD);
            FIg_display (Grid_form, SUB_UNITS_TEXT);
          }

  FIg_set_state_off (Line_style_form, 13);
  FIg_set_state_off (Line_style_form, 14);

  if (dpb.line_style == -1)
    FIg_set_state_on (Line_style_form, 13);
  else
    FIg_set_state_on (Line_style_form, 14);

  FIg_set_off_color (Font_form, SAMPLE_HEADER, dpb.off_color);
  FIg_set_on_color (Font_form, SAMPLE_HEADER, dpb.on_color);
  FIg_set_off_color (Font_form, SAMPLE_TEXT, dpb.off_color);
  FIg_set_on_color (Font_form, SAMPLE_TEXT, dpb.on_color);

  FIg_set_justification (Font_form, SAMPLE_HEADER, dpb.text_justification);
  FIg_set_justification (Font_form, SAMPLE_TEXT, dpb.text_justification);

  FIg_set_state_off (Font_form, NORMAL_CK);
  FIg_set_state_off (Font_form, EMBOSSED_CK);
  FIg_set_state_off (Font_form, INCISED_CK);
  FIg_set_state_off (Font_form, SHADOWED_CK);

  FIg_set_text_style (Font_form, SAMPLE_HEADER, dpb.text_style);
  FIg_set_text_style (Font_form, SAMPLE_TEXT, dpb.text_style);

  if (dpb.text_style == FI_NORMAL_TEXT)
  {
    FIg_set_state_on (Font_form, NORMAL_CK);
  }

  if (dpb.text_style == FI_EMBOSSED)
  {
    FIg_set_state_on (Font_form, EMBOSSED_CK);
  }

  if (dpb.text_style == FI_INCISED)
  {
    FIg_set_state_on (Font_form, INCISED_CK);
  }

  if (dpb.text_style == FI_SHADOWED)
  {
    FIg_set_state_on (Font_form, SHADOWED_CK);
  }

  FIg_set_state_off (Font_form, LEFT_JUST_CK);
  FIg_set_state_off (Font_form, CENTER_JUST_CK);
  FIg_set_state_off (Font_form, RIGHT_JUST_CK);

  if (dpb.text_justification == FI_LEFT_JUSTIFIED)
  {
    FIg_set_state_on (Font_form, LEFT_JUST_CK);
  }

  if (dpb.text_justification == FI_CENTER_JUSTIFIED)
  {
    FIg_set_state_on (Font_form, CENTER_JUST_CK);
  }

  if (dpb.text_justification == FI_RIGHT_JUSTIFIED)
  {
    FIg_set_state_on (Font_form, RIGHT_JUST_CK);
  }

  /**************************************************************/
  /* */
  /* Next, override the text title for each of the three color */
  /* selection forms. */
  /* */
  /**************************************************************/

  UMSGetByNum (t_str, FB_I_OFFCOLOR, 0);
  FIg_set_off_text (FG_color_form, COLOR_TEXT, t_str);
  UMSGetByNum (t_str, FB_I_BGCOLOR, 0);
  FIg_set_off_text (BG_color_form, COLOR_TEXT, t_str);
  UMSGetByNum (t_str, FB_I_ONCOLOR, 0);
  FIg_set_off_text (FG2_color_form, COLOR_TEXT, t_str);

  FIfld_set_text (Font_form, TYPEFACE_FLD, 0, 0, dpb.font_name, 0);

  sprintf (t_str, "%d", (int)dpb.bodysize);

  FIfld_set_text (Font_form, SIZE_FLD, 0, 0, t_str, 0);

  FIg_set_font (Font_form, SAMPLE_TEXT, dpb.font_name, dpb.bodysize);
  FIg_set_font (Font_form, SAMPLE_HEADER, dpb.font_name, dpb.bodysize);

  /*************************************************************/
  /* */
  /* Now set up the line weight form with current dpb values */
  /* */
  /*************************************************************/

  FIg_set_value (Line_weight_form, LINE_WEIGHT_SLIDER,
      (double)dpb.line_weight);

  FIg_set_line_weight (Line_weight_form, LINE_WEIGHT_LINE,
      dpb.line_weight);

  FIg_display (Line_weight_form, LINE_WEIGHT_LINE);
}

/*************************************************************************/
/* */
/* fi_master_pv_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the presentation */
/* values settings for the form being edited. Most buttons when */
/* selected cause sub-forms to be displayed. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_master_pv_form (int form_label,
                       int gadget_label,
                       double value,
                       Form form_ptr)
{
  int i;
  char t_str[256];
  int status, dummy_int;

  FIg_erase (Master_pv_form, 10); /* dmb:09/12/91: IFORMS does this. */

  switch (gadget_label)
  {

  case FOREGROUND_CLR_BTN:

    if ((int)value == 1)
      FIf_display (FG_color_form);
    else
      FIf_erase (FG_color_form);
    break;

  case BACKGROUND_CLR_BTN:

    if ((int)value == 1)
      FIf_display (BG_color_form);
    else
      FIf_erase (BG_color_form);
    break;

  case FOREGROUND2_CLR_BTN:

    if ((int)value == 1)
      FIf_display (FG2_color_form);
    else
      FIf_erase (FG2_color_form);
    break;

  case LINE_STYLE_BTN:

    if ((int)value == 1)
      FIf_display (Line_style_form);
    else
      FIf_erase (Line_style_form);
    break;

  case LINE_WEIGHT_BTN:

    if ((int)value == 1)
      FIf_display (Line_weight_form);
    else
      FIf_erase (Line_weight_form);
    break;

  case TEXT_FONT_BTN:

    if ((int)value == 1)
      FIf_display (Font_form);
    else
      FIf_erase (Font_form);
    break;

  case GRID_DISPLAY_TOG:

    temp_dpb.grid_flag = (int)value;
    break;

  case GRID_PATTERN_TOG:

    if ((int)value == 1)
      FIf_display (Grid_form);
    else
      FIf_erase (Grid_form);
    break;

  case LINE_DEPTH_TOG:

    temp_dpb.line_depth = (int)value;
    break;

  case COMMAND_AUTOKILL_TOG:

    temp_autokill_flag = (int)value;
    break;

  case BOUNDARY_TOG:

    temp_dpb.expansion4 = (int)value;
    if ((int)value == 0)
    {
      FIg_set_state_off (Master_pv_form, BOUNDARY_TOG);

      FIg_erase (Master_pv_form, X_TEXT);
      FIg_erase (Master_pv_form, X_FLD);
      FIg_erase (Master_pv_form, X_PERCENT_TEXT);
      FIg_erase (Master_pv_form, Y_TEXT);
      FIg_erase (Master_pv_form, Y_FLD);
      FIg_erase (Master_pv_form, Y_PERCENT_TEXT);
    }
    else
    {
      FIg_set_state_on (Master_pv_form, BOUNDARY_TOG);

      FIg_display (Master_pv_form, X_TEXT);
      FIg_display (Master_pv_form, X_FLD);
      FIg_display (Master_pv_form, X_PERCENT_TEXT);
      FIg_display (Master_pv_form, Y_TEXT);
      FIg_display (Master_pv_form, Y_FLD);
      FIg_display (Master_pv_form, Y_PERCENT_TEXT);
    }
    break;

  case X_FLD:

    FIfld_get_text (Master_pv_form, X_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Master_pv_form, 10, &status);

    if (status)
      if ((i > 0) && (i < 100)) /* Valid input */
      {
        temp_dpb.expansion2 = i;
      }
      else
      {
        sprintf (t_str, "%d", temp_dpb.expansion2);
        FIg_set_text (Master_pv_form, X_FLD, t_str);
      }
    break;

  case Y_FLD:
    FIfld_get_text (Master_pv_form, Y_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Master_pv_form, 10, &status);

    if (status)
      if ((i > 0) && (i < 100)) /* Valid input */
      {
        temp_dpb.expansion3 = i;
      }
      else
      {
        sprintf (t_str, "%d", temp_dpb.expansion3);
        FIg_set_text (Master_pv_form, Y_FLD, t_str);
      }
    break;

  case HELP:

    break;

  case CANCEL:

    kill_change_pv();
    break;

  case ACCEPT:

    if (form_attr.new_form_name[0] != '\0')
    {
      FIf_set_color (work_form, temp_dpb.bgcolor);
      Redisplay (work_form);
    }

    dpb.bgcolor = temp_dpb.bgcolor;
    dpb.grid_flag = temp_dpb.grid_flag;
    dpb.grid_master_units = temp_dpb.grid_master_units;
    dpb.grid_sub_units = temp_dpb.grid_sub_units;
    dpb.off_color = temp_dpb.off_color;
    dpb.on_color = temp_dpb.on_color;
    dpb.line_style = temp_dpb.line_style;
    dpb.line_weight = temp_dpb.line_weight;
    dpb.bodysize = temp_dpb.bodysize;
    strcpy (dpb.font_name, temp_dpb.font_name);

    dpb.line_depth = temp_dpb.line_depth;
    dpb.text_style = temp_dpb.text_style;
    dpb.text_justification = temp_dpb.text_justification;

    dpb.expansion2 = temp_dpb.expansion2;
    dpb.expansion3 = temp_dpb.expansion3;
    dpb.expansion4 = temp_dpb.expansion4;

    autokill_mode = temp_autokill_flag;

    if (dpb.grid_flag == 1)
    {
      Redisplay (work_form);
      display_grid_on_work_form();
    }

    kill_change_pv();
    break;
  }

  return;
}

/*************************************************************************/
/* */
/* fi_font_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the font used */
/* in newly created gadgets, or gadgets that are currently being */
/* edited. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_font_form (int form_label,
                  int gadget_label,
                  double value,
                  Form form_ptr)
{
  char t_str[256], n_str[256];
  int x, i;
  int dummy_int;
  int status;
  int num_rows;

  FIg_erase (Font_form, ERR_FLD);

  switch (gadget_label)
  {
  case TYPEFACE_LIST_FLD:

    FIfld_get_text (Font_form, TYPEFACE_LIST_FLD, (int)value, 0, 255,
         (unsigned char *)t_str, &dummy_int, &dummy_int);

    strcpy (temp_dpb.font_name, t_str);

    FIfld_set_text (Font_form, TYPEFACE_FLD, 0, 0, t_str, 0);

    FIg_erase (Font_form, SAMPLE_HEADER);
    FIg_erase (Font_form, SAMPLE_TEXT);

    FIg_set_font (Font_form, SAMPLE_HEADER, t_str, temp_dpb.bodysize);
    FIg_set_font (Font_form, SAMPLE_TEXT, t_str, temp_dpb.bodysize);

    FIg_display (Font_form, SAMPLE_HEADER);
    FIg_display (Font_form, SAMPLE_TEXT);
    break;

  case TYPEFACE_FLD:

    FIfld_get_num_rows (Font_form, TYPEFACE_LIST_FLD, &num_rows);
    for (x = 0; x < num_rows; x++)
       FIfld_set_select (Font_form, TYPEFACE_LIST_FLD, x, 0, 0);

    FIfld_get_text (Font_form, TYPEFACE_FLD, (int)value, 0, 255,
         (unsigned char *)t_str, &dummy_int, &dummy_int);

    strcpy (temp_dpb.font_name, t_str);

    FIg_erase (Font_form, SAMPLE_HEADER);
    FIg_erase (Font_form, SAMPLE_TEXT);

    FIg_set_font (Font_form, SAMPLE_HEADER, t_str, temp_dpb.bodysize);
    FIg_set_font (Font_form, SAMPLE_TEXT, t_str, temp_dpb.bodysize);

    FIg_display (Font_form, SAMPLE_HEADER);
    FIg_display (Font_form, SAMPLE_TEXT);
    break;

  case SIZE_FLD:
    FIfld_get_text (Font_form, SIZE_FLD, 0, 0, 255,
         (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Font_form, ERR_FLD, &status);

    if (status)
      if ((i <= 0) || (i > 300))
      {
        UMSGetByNum (t_str, FB_E_BADSIZE, 0);
        print_error (Font_form, ERR_FLD, t_str);
      }
      else
      {
        temp_dpb.bodysize = (float)i;

        FIg_erase (Font_form, SAMPLE_HEADER);
        FIg_erase (Font_form, SAMPLE_TEXT);

        FIg_set_font (Font_form, SAMPLE_HEADER, temp_dpb.font_name, 
                                                temp_dpb.bodysize);
        FIg_set_font (Font_form, SAMPLE_TEXT, temp_dpb.font_name,
                                              temp_dpb.bodysize);

        FIg_display (Font_form, SAMPLE_HEADER);
        FIg_display (Font_form, SAMPLE_TEXT);
      }
    break;

  case NORMAL_CK:

    temp_dpb.text_style = FI_NORMAL_TEXT;
    FIg_set_text_style (Font_form, SAMPLE_HEADER, FI_NORMAL_TEXT);
    FIg_set_text_style (Font_form, SAMPLE_TEXT, FI_NORMAL_TEXT);
    FIg_display (Font_form, SAMPLE_HEADER);
    FIg_display (Font_form, SAMPLE_TEXT);
    break;

  case EMBOSSED_CK:

    temp_dpb.text_style = FI_EMBOSSED;
    FIg_set_text_style (Font_form, SAMPLE_HEADER, FI_EMBOSSED);
    FIg_set_text_style (Font_form, SAMPLE_TEXT, FI_EMBOSSED);
    FIg_display (Font_form, SAMPLE_HEADER);
    FIg_display (Font_form, SAMPLE_TEXT);
    break;

  case INCISED_CK:

    temp_dpb.text_style = FI_INCISED;
    FIg_set_text_style (Font_form, SAMPLE_HEADER, FI_INCISED);
    FIg_set_text_style (Font_form, SAMPLE_TEXT, FI_INCISED);
    FIg_display (Font_form, SAMPLE_HEADER);
    FIg_display (Font_form, SAMPLE_TEXT);
    break;

  case SHADOWED_CK:

    temp_dpb.text_style = FI_SHADOWED;
    FIg_set_text_style (Font_form, SAMPLE_HEADER, FI_SHADOWED);
    FIg_set_text_style (Font_form, SAMPLE_TEXT, FI_SHADOWED);
    FIg_display (Font_form, SAMPLE_HEADER);
    FIg_display (Font_form, SAMPLE_TEXT);
    break;

  case LEFT_JUST_CK:

    temp_dpb.text_justification = FI_LEFT_JUSTIFIED;
    FIg_set_justification (Font_form, SAMPLE_HEADER, FI_LEFT_JUSTIFIED);
    FIg_set_justification (Font_form, SAMPLE_TEXT, FI_LEFT_JUSTIFIED);
    FIg_display (Font_form, SAMPLE_HEADER);
    FIg_display (Font_form, SAMPLE_TEXT);
    break;

  case CENTER_JUST_CK:

    temp_dpb.text_justification = FI_CENTER_JUSTIFIED;

    if (Master_field_form != NULL)
    {
      if ((gadget_attr.scroll_mode == HORIZONTAL_SCROLL_ONLY) ||
          (gadget_attr.scroll_mode == BOTH_DIRECTION_SCROLL))
      {
        temp_dpb.text_justification = FI_LEFT_JUSTIFIED;

        UMSGetByNum (t_str, FB_E_NOHORZSCRL, 0);
        print_error (Font_form, ERR_FLD, t_str);

        FIg_set_state_off (Font_form, CENTER_JUST_CK);
        FIg_set_state_on (Font_form, LEFT_JUST_CK);
      }
      else
      {
        FIg_set_justification (Font_form, SAMPLE_HEADER, FI_CENTER_JUSTIFIED);
        FIg_set_justification (Font_form, SAMPLE_TEXT, FI_CENTER_JUSTIFIED);
        FIg_display (Font_form, SAMPLE_HEADER);
        FIg_display (Font_form, SAMPLE_TEXT);
      }
    }
    else
    {
      FIg_set_justification (Font_form, SAMPLE_HEADER, FI_CENTER_JUSTIFIED);
      FIg_set_justification (Font_form, SAMPLE_TEXT, FI_CENTER_JUSTIFIED);
      FIg_display (Font_form, SAMPLE_HEADER);
      FIg_display (Font_form, SAMPLE_TEXT);
    }
    break;

  case RIGHT_JUST_CK:

    temp_dpb.text_justification = FI_RIGHT_JUSTIFIED;

    if (Master_field_form != NULL)
    {
      if ((gadget_attr.scroll_mode == HORIZONTAL_SCROLL_ONLY) ||
          (gadget_attr.scroll_mode == BOTH_DIRECTION_SCROLL))
      {
        temp_dpb.text_justification = FI_LEFT_JUSTIFIED;

        UMSGetByNum (t_str, FB_E_NOHORZSCRL, 0);
        print_error (Font_form, ERR_FLD, t_str);

        FIg_set_state_off (Font_form, RIGHT_JUST_CK);
        FIg_set_state_on (Font_form, LEFT_JUST_CK);
      }
      else
      {
        FIg_set_justification (Font_form, SAMPLE_HEADER, FI_RIGHT_JUSTIFIED);
        FIg_set_justification (Font_form, SAMPLE_TEXT, FI_RIGHT_JUSTIFIED);
        FIg_display (Font_form, SAMPLE_HEADER);
        FIg_display (Font_form, SAMPLE_TEXT);
      }
    }
    else
    {
      FIg_set_justification (Font_form, SAMPLE_HEADER, FI_RIGHT_JUSTIFIED);
      FIg_set_justification (Font_form, SAMPLE_TEXT, FI_RIGHT_JUSTIFIED);
      FIg_display (Font_form, SAMPLE_HEADER);
      FIg_display (Font_form, SAMPLE_TEXT);
    }
    break;

  case CANCEL:

    FIf_erase (Font_form);
    if (Font_options_form != NULL)
    {
      FIf_erase (Font_options_form);
    }

    if (command_is_active == CHANGE_PV)
    {
      temp_dpb.bodysize = dpb.bodysize;
      strcpy (temp_dpb.font_name, dpb.font_name);
    }
    else /* Edit or Place command */
    {
      temp_dpb.bodysize = gadget_attr.bodysize;
      strcpy (temp_dpb.font_name, gadget_attr.font_name);
    }

    FIg_set_state_off (Font_form, CANCEL);

    if (command_is_active == CHANGE_PV)
      FIg_set_state_off (Master_pv_form, TEXT_FONT_BTN);
    else if ((command_is_active == FENCE_EDIT) ||
        (command_is_active == GROUP_EDIT))
      FIg_set_state_off (Edit_form, CHAR_TEXT_FONT_BTN);
    else /* Edit or place command */
      FIg_set_state_off (Characteristics_form, CHAR_TEXT_FONT_BTN);
    break;

  case ACCEPT:

    FIf_erase (Font_form);
    if (Font_options_form != NULL)
      FIf_erase (Font_options_form);

    FIg_set_state_off (Font_form, ACCEPT);

    if (command_is_active == CHANGE_PV)
      FIg_set_state_off (Master_pv_form, TEXT_FONT_BTN);
    else if ((command_is_active == FENCE_EDIT) ||
        (command_is_active == GROUP_EDIT))
      FIg_set_state_off (Edit_form, CHAR_TEXT_FONT_BTN);
    else
    {
      FIg_erase (Characteristics_form, 13);

      strcpy (t_str, temp_dpb.font_name);
      strcat (t_str, ".");
      sprintf (n_str, "%2d", (int)temp_dpb.bodysize);
      strcat (t_str, n_str);

      FIg_set_text (Characteristics_form, 13, t_str);

      FIg_set_font (Characteristics_form, 13,
          temp_dpb.font_name,
          temp_dpb.bodysize);

      FIg_display (Characteristics_form, 13);
      FIg_set_state_off (Characteristics_form, CHAR_TEXT_FONT_BTN);
    }
    break;
  }

  return;
}

/*************************************************************************/
/* */
/* fi_grid_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the grid */
/* pattern used on the work form. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_grid_form (int form_label,
                  int gadget_label,
                  double value,
                  Form form_ptr)
{
  int i, status;
  char t_str[256];
  int z;
  int dummy_int;

  FIg_erase (Grid_form, GRID_ERR_FLD);

  switch (gadget_label)
  {
  case GRID_15_5_BTN:

    FIg_erase (Grid_form, MASTER_UNITS_SYM);
    FIg_erase (Grid_form, MASTER_UNITS_FLD);
    FIg_erase (Grid_form, SUB_UNITS_SYM);
    FIg_erase (Grid_form, SUB_UNITS_FLD);
    FIg_erase (Grid_form, MASTER_UNITS_TEXT);
    FIg_erase (Grid_form, SUB_UNITS_TEXT);

    temp_dpb.grid_master_units = 15;
    temp_dpb.grid_sub_units = 5;
    break;

  case GRID_25_25_BTN:

    FIg_erase (Grid_form, MASTER_UNITS_SYM);
    FIg_erase (Grid_form, MASTER_UNITS_FLD);
    FIg_erase (Grid_form, SUB_UNITS_SYM);
    FIg_erase (Grid_form, SUB_UNITS_FLD);
    FIg_erase (Grid_form, MASTER_UNITS_TEXT);
    FIg_erase (Grid_form, SUB_UNITS_TEXT);

    temp_dpb.grid_master_units = 25;
    temp_dpb.grid_sub_units = 25;
    break;

  case GRID_50_25_BTN:

    FIg_erase (Grid_form, MASTER_UNITS_SYM);
    FIg_erase (Grid_form, MASTER_UNITS_FLD);
    FIg_erase (Grid_form, SUB_UNITS_SYM);
    FIg_erase (Grid_form, SUB_UNITS_FLD);
    FIg_erase (Grid_form, MASTER_UNITS_TEXT);
    FIg_erase (Grid_form, SUB_UNITS_TEXT);

    temp_dpb.grid_master_units = 50;
    temp_dpb.grid_sub_units = 25;
    break;

  case GRID_75_25_BTN:

    FIg_erase (Grid_form, MASTER_UNITS_SYM);
    FIg_erase (Grid_form, MASTER_UNITS_FLD);
    FIg_erase (Grid_form, SUB_UNITS_SYM);
    FIg_erase (Grid_form, SUB_UNITS_FLD);
    FIg_erase (Grid_form, MASTER_UNITS_TEXT);
    FIg_erase (Grid_form, SUB_UNITS_TEXT);

    temp_dpb.grid_master_units = 75;
    temp_dpb.grid_sub_units = 25;
    break;

  case GRID_100_25_BTN:

    FIg_erase (Grid_form, MASTER_UNITS_SYM);
    FIg_erase (Grid_form, MASTER_UNITS_FLD);
    FIg_erase (Grid_form, SUB_UNITS_SYM);
    FIg_erase (Grid_form, SUB_UNITS_FLD);
    FIg_erase (Grid_form, MASTER_UNITS_TEXT);
    FIg_erase (Grid_form, SUB_UNITS_TEXT);

    temp_dpb.grid_master_units = 100;
    temp_dpb.grid_sub_units = 25;
    break;

  case GRID_SPECIFY_BTN:

    FIg_display (Grid_form, MASTER_UNITS_SYM);
    FIg_display (Grid_form, MASTER_UNITS_FLD);
    FIg_display (Grid_form, SUB_UNITS_SYM);
    FIg_display (Grid_form, SUB_UNITS_FLD);
    FIg_display (Grid_form, MASTER_UNITS_TEXT);
    FIg_display (Grid_form, SUB_UNITS_TEXT);
    break;

  case MASTER_UNITS_FLD:

    FIfld_get_text (Grid_form, MASTER_UNITS_FLD, 0, 0, 255,
         (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Grid_form, GRID_ERR_FLD, &status);

    if (status)
      if (i < temp_dpb.grid_sub_units)
      {
        UMSGetByNum (t_str, FB_E_LTSUBUNITS, 0);
        print_error (Grid_form, GRID_ERR_FLD, t_str);
      }
      else if ((i % temp_dpb.grid_sub_units) != 0)
      {
        UMSGetByNum (t_str, FB_E_MULSUBUNITS, 0);
        print_error (Grid_form, GRID_ERR_FLD, t_str);
      }
      else
        temp_dpb.grid_master_units = i;
    break;

  case SUB_UNITS_FLD:

    FIfld_get_text (Grid_form, SUB_UNITS_FLD, 0, 0, 255,
         (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, Grid_form, GRID_ERR_FLD, &status);

    if (status)
      if (i < 5)
      {
        UMSGetByNum (t_str, FB_E_SUBGTFIVE, 0);
        print_error (Grid_form, GRID_ERR_FLD, t_str);
      }
      else
      {
        z = temp_dpb.grid_master_units / temp_dpb.grid_sub_units;

        temp_dpb.grid_master_units = i * z;

        sprintf (t_str, "%d", temp_dpb.grid_master_units);

        FIfld_set_text (Grid_form, MASTER_UNITS_FLD, 0, 0, t_str, 0);
        temp_dpb.grid_sub_units = i;
      }
    break;

  case CANCEL:

    FIf_erase (Grid_form);

    temp_dpb.grid_master_units = dpb.grid_master_units;
    temp_dpb.grid_sub_units = dpb.grid_sub_units;

    FIg_set_state_off (Grid_form, CANCEL);
    FIg_set_state_off (Master_pv_form, GRID_PATTERN_TOG);
    break;

  case ACCEPT:

    FIf_erase (Grid_form);

    FIg_set_state_off (Grid_form, ACCEPT);
    FIg_set_state_off (Master_pv_form, GRID_PATTERN_TOG);
    break;
  }

  return;
}

/*************************************************************************/
/* */
/* fi_line_weight_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the thickness */
/* of the newly created or edited lines or rectangles. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_line_weight_form (int form_label,
                         int gadget_label,
                         double value,
                         Form form_ptr)
{

  switch (gadget_label)
  {
  case LINE_WEIGHT_SLIDER:

    temp_dpb.line_weight = (int)value;

    FIg_erase (Line_weight_form, LINE_WEIGHT_LINE);
    FIg_set_line_weight (Line_weight_form, LINE_WEIGHT_LINE, (int)value);
    FIg_display (Line_weight_form, LINE_WEIGHT_LINE);
    break;

  case CANCEL:

    FIf_erase (Line_weight_form);

    if (command_is_active == CHANGE_PV)
      temp_dpb.line_weight = dpb.line_weight;
    else
      temp_dpb.line_weight = gadget_attr.line_weight;

    FIg_set_state_off (Line_weight_form, CANCEL);

    if (command_is_active == CHANGE_PV)
      FIg_set_state_off (Master_pv_form, LINE_WEIGHT_BTN);
    else if ((command_is_active == FENCE_EDIT) ||
        (command_is_active == GROUP_EDIT))
      FIg_set_state_off (Edit_form, CHAR_LINE_WEIGHT_BTN);
    else /* Edit or place command */
      FIg_set_state_off (Characteristics_form, CHAR_LINE_WEIGHT_BTN);
    break;

  case ACCEPT:

    FIf_erase (Line_weight_form);

    FIg_set_state_off (Line_weight_form, ACCEPT);

    if (command_is_active == CHANGE_PV)
      FIg_set_state_off (Master_pv_form, LINE_WEIGHT_BTN);
    else if ((command_is_active == FENCE_EDIT) ||
        (command_is_active == GROUP_EDIT))
      FIg_set_state_off (Edit_form, CHAR_LINE_WEIGHT_BTN);
    else /* Edit or place command */
      FIg_set_state_off (Characteristics_form, CHAR_LINE_WEIGHT_BTN);
    break;
  }

  return;
}

/*************************************************************************/
/* */
/* fi_line_style_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the pattern */
/* of lines or rectangles. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_line_style_form (int form_label,
                        int gadget_label,
                        double value,
                        Form form_ptr)
{

  switch (gadget_label)
  {
  case CANCEL:

    FIf_erase (Line_style_form);

    if ((command_is_active == CHANGE_PV) ||
        (command_is_active == FENCE_EDIT) ||
        (command_is_active == GROUP_EDIT))
      temp_dpb.line_weight = dpb.line_weight;
    else
      temp_dpb.line_weight = gadget_attr.line_weight;

    FIg_set_state_off (Line_style_form, CANCEL);

    if (command_is_active == CHANGE_PV)
      FIg_set_state_off (Master_pv_form, LINE_STYLE_BTN);
    else if ((command_is_active == FENCE_EDIT) ||
        (command_is_active == GROUP_EDIT))
      FIg_set_state_off (Edit_form, CHAR_LINE_STYLE_BTN);
    else
      FIg_set_state_off (Characteristics_form, CHAR_LINE_STYLE_BTN);
    break;

  case ACCEPT:

    FIf_erase (Line_style_form);

    FIg_set_state_off (Line_style_form, ACCEPT);

    if (command_is_active == CHANGE_PV)
      FIg_set_state_off (Master_pv_form, LINE_STYLE_BTN);
    else if ((command_is_active == FENCE_EDIT) ||
        (command_is_active == GROUP_EDIT))
      FIg_set_state_off (Edit_form, CHAR_LINE_STYLE_BTN);
    else
      FIg_set_state_off (Characteristics_form, CHAR_LINE_STYLE_BTN);
    break;

  case 30:
    temp_dpb.line_style = line_style[0];
    break;

  case 31:
    temp_dpb.line_style = line_style[1];
    break;

  case 32:
    temp_dpb.line_style = line_style[2];
    break;

  case 33:
    temp_dpb.line_style = line_style[3];
    break;

  case 34:
    temp_dpb.line_style = line_style[4];
    break;

  case 35:
    temp_dpb.line_style = line_style[5];
    break;

  case 36:
    temp_dpb.line_style = line_style[6];
    break;

  case 37:
    temp_dpb.line_style = line_style[7];
    break;
  }

  return;
}

/*************************************************************************/
/* */
/* fi_fg_color_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the foreground */
/* color on the work form. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_fg_color_form (int form_label,
                      int gadget_label,
                      double value,
                      Form form_ptr)
{
  int i, x;
  char t_str[256];
  int dummy_int;
  int status;

  FIg_erase (FG_color_form, 10);

  switch (gadget_label)
  {
  case HELP:

    break;

  case CANCEL:

    FIf_erase (FG_color_form);

    FIg_set_off_color (Font_form, SAMPLE_HEADER, dpb.off_color);
    FIg_set_off_color (Font_form, SAMPLE_TEXT, dpb.off_color);
    FIg_display (Font_form, SAMPLE_HEADER);
    FIg_display (Font_form, SAMPLE_TEXT);

    if (command_is_active == CHANGE_PV)
    {
      temp_dpb.off_color = dpb.off_color;
      FIg_set_off_color (Master_pv_form, FOREGROUND_CLR_BTN, dpb.off_color);
      FIg_set_on_color (Master_pv_form, FOREGROUND_CLR_BTN, dpb.off_color);
    }
    else
    {
      if ((command_is_active == FENCE_EDIT) ||
          (command_is_active == GROUP_EDIT))
      {
        temp_dpb.off_color = FI_BLACK;
        FIg_set_off_color (Edit_form, CHAR_FOREGROUND_CLR_BTN,
            FI_BLACK);
        FIg_set_on_color (Edit_form, CHAR_FOREGROUND_CLR_BTN,
            FI_BLACK);
      }
      else /* Edit or place command */
      {
        temp_dpb.off_color = gadget_attr.off_color;
        FIg_set_off_color (Characteristics_form, CHAR_FOREGROUND_CLR_BTN,
            gadget_attr.off_color);
        FIg_set_on_color (Characteristics_form, CHAR_FOREGROUND_CLR_BTN,
            gadget_attr.off_color);
      }
    }

    FIg_set_state_off (FG_color_form, CANCEL);

    if (command_is_active == CHANGE_PV)
      FIg_set_state_off (Master_pv_form, FOREGROUND_CLR_BTN);
    else if ((command_is_active == FENCE_EDIT) ||
        (command_is_active == GROUP_EDIT))
      FIg_set_state_off (Edit_form, CHAR_FOREGROUND_CLR_BTN);
    else
      FIg_set_state_off (Characteristics_form, CHAR_FOREGROUND_CLR_BTN);
    break;

  case ACCEPT:

    FIf_erase (FG_color_form);

    FIg_set_state_off (FG_color_form, ACCEPT);

    if (command_is_active == CHANGE_PV)
      FIg_set_state_off (Master_pv_form, FOREGROUND_CLR_BTN);
    else if ((command_is_active == FENCE_EDIT) ||
        (command_is_active == GROUP_EDIT))
      FIg_set_state_off (Edit_form, CHAR_FOREGROUND_CLR_BTN);
    else /* Edit or placement command */
      FIg_set_state_off (Characteristics_form, CHAR_FOREGROUND_CLR_BTN);
    break;

  case COLOR_FLD:

    FIfld_get_text (FG_color_form, COLOR_FLD, 0, 0, 255,
         (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, FG_color_form, 10, &status);

    if (status)
    {
      if (i < 16)
      {
        if (temp_dpb.off_color >= 16)
          sprintf (t_str, "%d", temp_dpb.off_color);
        else
          t_str[0] = 0;

        FIfld_set_text (FG_color_form, 12, 0, 0, t_str, 0);
      }
      else
      {
        temp_dpb.off_color = i;

        FIg_set_off_color (Font_form, SAMPLE_HEADER, i);
        FIg_set_off_color (Font_form, SAMPLE_TEXT, i);
        FIg_display (Font_form, SAMPLE_HEADER);
        FIg_display (Font_form, SAMPLE_TEXT);

        /* turn off any buttons that are selected */

        for (x = 27; x < 42; x++)
          FIg_set_state_off (FG_color_form, x);

        if (command_is_active == CHANGE_PV)
        {
          FIg_set_off_color (Master_pv_form, FOREGROUND_CLR_BTN,
              temp_dpb.off_color);
          FIg_set_on_color (Master_pv_form, FOREGROUND_CLR_BTN,
              temp_dpb.off_color);
          FIg_display (Master_pv_form, FOREGROUND_CLR_BTN);
        }
        else
        {
          if ((command_is_active == FENCE_EDIT) ||
              (command_is_active == GROUP_EDIT))
          {
            FIg_set_off_color (Edit_form, CHAR_FOREGROUND_CLR_BTN,
                temp_dpb.off_color);
            FIg_set_on_color (Edit_form, CHAR_FOREGROUND_CLR_BTN,
                temp_dpb.off_color);
            FIg_display (Edit_form, CHAR_FOREGROUND_CLR_BTN);
          }
          else
          {
            FIg_set_off_color (Characteristics_form, CHAR_FOREGROUND_CLR_BTN,
                temp_dpb.off_color);
            FIg_set_on_color (Characteristics_form, CHAR_FOREGROUND_CLR_BTN,
                temp_dpb.off_color);
            FIg_display (Characteristics_form, CHAR_FOREGROUND_CLR_BTN);
          }
        }
      }
    }
    else
    {
      /* Invalid integer */
      if (temp_dpb.off_color >= 16)
        sprintf (t_str, "%d", temp_dpb.off_color);
      else
        t_str[0] = 0;

      FIfld_set_text (FG_color_form, 12, 0, 0, t_str, 0);
    }
    break;

  default:

    FIfld_set_text (FG_color_form, 12, 0, 0, "", 0);

    temp_dpb.off_color = gadget_label - 27;

    FIg_set_off_color (Font_form, SAMPLE_HEADER, temp_dpb.off_color);
    FIg_set_off_color (Font_form, SAMPLE_TEXT, temp_dpb.off_color);
    FIg_display (Font_form, SAMPLE_HEADER);
    FIg_display (Font_form, SAMPLE_TEXT);

    if (command_is_active == CHANGE_PV)
    {
      FIg_set_off_color (Master_pv_form, FOREGROUND_CLR_BTN,
          temp_dpb.off_color);
      FIg_set_on_color (Master_pv_form, FOREGROUND_CLR_BTN,
          temp_dpb.off_color);
      FIg_display (Master_pv_form, FOREGROUND_CLR_BTN);
    }
    else
    {
      if ((command_is_active == FENCE_EDIT) ||
          (command_is_active == GROUP_EDIT))
      {
        FIg_set_off_color (Edit_form, CHAR_FOREGROUND_CLR_BTN,
            temp_dpb.off_color);
        FIg_set_on_color (Edit_form, CHAR_FOREGROUND_CLR_BTN,
            temp_dpb.off_color);
        FIg_display (Edit_form, CHAR_FOREGROUND_CLR_BTN);
      }
      else
      {
        FIg_set_off_color (Characteristics_form, CHAR_FOREGROUND_CLR_BTN,
            temp_dpb.off_color);
        FIg_set_on_color (Characteristics_form, CHAR_FOREGROUND_CLR_BTN,
            temp_dpb.off_color);
        FIg_display (Characteristics_form, CHAR_FOREGROUND_CLR_BTN);
      }
    }
    break;
  }

  return;
}

/*************************************************************************/
/* */
/* fi_bg_color_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the background */
/* color on the work form. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_bg_color_form (int form_label,
                      int gadget_label,
                      double value,
                      Form form_ptr)
{
  int i, x;
  char t_str[256];
  int dummy_int;
  int status;

  FIg_erase (BG_color_form, 10);

  switch (gadget_label)
  {
  case HELP:

    break;

  case CANCEL:

    FIf_erase (BG_color_form);

    temp_dpb.bgcolor = dpb.bgcolor;
    FIg_set_off_color (Master_pv_form, BACKGROUND_CLR_BTN, dpb.bgcolor);
    FIg_set_on_color (Master_pv_form, BACKGROUND_CLR_BTN, dpb.bgcolor);

    FIg_set_state_off (BG_color_form, CANCEL);
    FIg_set_state_off (Master_pv_form, BACKGROUND_CLR_BTN);
    break;

  case ACCEPT:

    FIf_erase (BG_color_form);

    FIg_set_state_off (BG_color_form, ACCEPT);
    FIg_set_state_off (Master_pv_form, BACKGROUND_CLR_BTN);
    break;

  case COLOR_FLD:

    FIfld_get_text (BG_color_form, COLOR_FLD, 0, 0, 255,
         (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, BG_color_form, 10, &status);

    if (status)
    {
      if (i < 16)
      {
        if (temp_dpb.bgcolor >= 16)
          sprintf (t_str, "%d", temp_dpb.bgcolor);
        else
          t_str[0] = 0;

        FIfld_set_text (BG_color_form, 12, 0, 0, t_str, 0);
      }
      else
      {
        temp_dpb.bgcolor = i;

        /* turn off any buttons that are selected */

        for (x = 27; x < 42; x++)
          FIg_set_state_off (BG_color_form, x);

        FIg_set_off_color (Master_pv_form, BACKGROUND_CLR_BTN,
            temp_dpb.bgcolor);
        FIg_set_on_color (Master_pv_form, BACKGROUND_CLR_BTN,
            temp_dpb.bgcolor);
        FIg_display (Master_pv_form, BACKGROUND_CLR_BTN);
      }
    }
    else
    {
      /* Invalid integer */
      if (temp_dpb.bgcolor >= 16)
        sprintf (t_str, "%d", temp_dpb.bgcolor);
      else
        t_str[0] = 0;

      FIfld_set_text (BG_color_form, 12, 0, 0, t_str, 0);
    }
    break;

  default:

    FIfld_set_text (BG_color_form, 12, 0, 0, "", 0);

    temp_dpb.bgcolor = gadget_label - 27;

    FIg_set_off_color (Master_pv_form, BACKGROUND_CLR_BTN,
        temp_dpb.bgcolor);
    FIg_set_on_color (Master_pv_form, BACKGROUND_CLR_BTN,
        temp_dpb.bgcolor);
    FIg_display (Master_pv_form, BACKGROUND_CLR_BTN);
    break;
  }

  return;
}

/*************************************************************************/
/* */
/* fi_fg2_color_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to change the secondary */
/* foreground color on the work form. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_fg2_color_form (int form_label,
                       int gadget_label,
                       double value,
                       Form form_ptr)
{
  int i, x;
  char t_str[256];
  int dummy_int;
  int status;

  FIg_erase (FG2_color_form, 10);

  switch (gadget_label)
  {
  case HELP:

    break;

  case CANCEL:

    FIf_erase (FG2_color_form);

    FIg_set_on_color (Font_form, SAMPLE_HEADER, dpb.on_color);
    FIg_set_on_color (Font_form, SAMPLE_TEXT, dpb.on_color);
    FIg_display (Font_form, SAMPLE_HEADER);
    FIg_display (Font_form, SAMPLE_TEXT);

    if (command_is_active == CHANGE_PV)
    {
      temp_dpb.on_color = dpb.on_color;
      FIg_set_off_color (Master_pv_form, FOREGROUND2_CLR_BTN, dpb.on_color);
      FIg_set_on_color (Master_pv_form, FOREGROUND2_CLR_BTN, dpb.on_color);
    }
    else if ((command_is_active == FENCE_EDIT) ||
        (command_is_active == GROUP_EDIT))
    {
      temp_dpb.on_color = FI_YELLOW;
      FIg_set_off_color (Edit_form, CHAR_FOREGROUND2_CLR_BTN,
          FI_YELLOW);
      FIg_set_on_color (Edit_form, CHAR_FOREGROUND2_CLR_BTN,
          FI_YELLOW);
    }
    else /* Edit or placement command */
    {
      temp_dpb.on_color = gadget_attr.on_color;
      FIg_set_off_color (Characteristics_form, CHAR_FOREGROUND2_CLR_BTN,
          gadget_attr.on_color);
      FIg_set_on_color (Characteristics_form, CHAR_FOREGROUND2_CLR_BTN,
          gadget_attr.on_color);
    }

    FIg_set_state_off (FG2_color_form, CANCEL);

    if (command_is_active == CHANGE_PV)
      FIg_set_state_off (Master_pv_form, FOREGROUND2_CLR_BTN);
    else if ((command_is_active == FENCE_EDIT) ||
        (command_is_active == GROUP_EDIT))
      FIg_set_state_off (Edit_form, CHAR_FOREGROUND2_CLR_BTN);
    else
      FIg_set_state_off (Characteristics_form, CHAR_FOREGROUND2_CLR_BTN);
    break;

  case ACCEPT:

    FIf_erase (FG2_color_form);

    FIg_set_state_off (FG2_color_form, ACCEPT);

    if (command_is_active == CHANGE_PV)
      FIg_set_state_off (Master_pv_form, FOREGROUND2_CLR_BTN);
    else if ((command_is_active == FENCE_EDIT) ||
        (command_is_active == GROUP_EDIT))
      FIg_set_state_off (Edit_form, CHAR_FOREGROUND2_CLR_BTN);
    else
      FIg_set_state_off (Characteristics_form, CHAR_FOREGROUND2_CLR_BTN);
    break;

  case COLOR_FLD:

    FIfld_get_text (FG2_color_form, COLOR_FLD, 0, 0, 255,
         (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = validate_integer_field (t_str, FG2_color_form, 10, &status);

    if (status)
    {
      if (i < 16)
      {
        if (temp_dpb.on_color >= 16)
          sprintf (t_str, "%d", temp_dpb.on_color);
        else
          t_str[0] = 0;

        FIfld_set_text (FG2_color_form, 12, 0, 0, t_str, 0);
      }
      else
      {
        temp_dpb.on_color = i;

        FIg_set_on_color (Font_form, SAMPLE_HEADER, i);
        FIg_set_on_color (Font_form, SAMPLE_TEXT, i);
        FIg_display (Font_form, SAMPLE_HEADER);
        FIg_display (Font_form, SAMPLE_TEXT);

        /* turn off any buttons that are selected */

        for (x = 27; x < 42; x++)
          FIg_set_state_off (FG2_color_form, x);

        if (command_is_active == CHANGE_PV)
        {
          FIg_set_off_color (Master_pv_form, FOREGROUND2_CLR_BTN,
              temp_dpb.on_color);
          FIg_set_on_color (Master_pv_form, FOREGROUND2_CLR_BTN,
              temp_dpb.on_color);
          FIg_display (Master_pv_form, FOREGROUND2_CLR_BTN);
        }
        else
        {
          if ((command_is_active == FENCE_EDIT) ||
              (command_is_active == GROUP_EDIT))
          {
            FIg_set_off_color (Edit_form, CHAR_FOREGROUND2_CLR_BTN,
                temp_dpb.on_color);
            FIg_set_on_color (Edit_form, CHAR_FOREGROUND2_CLR_BTN,
                temp_dpb.on_color);
            FIg_display (Edit_form, CHAR_FOREGROUND2_CLR_BTN);
          }
          else
          {
            FIg_set_off_color (Characteristics_form, CHAR_FOREGROUND2_CLR_BTN,
                temp_dpb.on_color);
            FIg_set_on_color (Characteristics_form, CHAR_FOREGROUND2_CLR_BTN,
                temp_dpb.on_color);
            FIg_display (Characteristics_form, CHAR_FOREGROUND2_CLR_BTN);
          }
        }
      }
    }
    else
    {
      /* Invalid integer */
      if (temp_dpb.on_color >= 16)
        sprintf (t_str, "%d", temp_dpb.on_color);
      else
        t_str[0] = 0;

      FIfld_set_text (FG2_color_form, 12, 0, 0, t_str, 0);
    }
    break;

  default:

    FIfld_set_text (FG2_color_form, 12, 0, 0, "", 0);

    temp_dpb.on_color = gadget_label - 27;

    FIg_set_on_color (Font_form, SAMPLE_HEADER, temp_dpb.on_color);
    FIg_set_on_color (Font_form, SAMPLE_TEXT, temp_dpb.on_color);
    FIg_display (Font_form, SAMPLE_HEADER);
    FIg_display (Font_form, SAMPLE_TEXT);

    if (command_is_active == CHANGE_PV)
    {
      FIg_set_off_color (Master_pv_form, FOREGROUND2_CLR_BTN,
          temp_dpb.on_color);
      FIg_set_on_color (Master_pv_form, FOREGROUND2_CLR_BTN,
          temp_dpb.on_color);
      FIg_display (Master_pv_form, FOREGROUND2_CLR_BTN);
    }
    else if ((command_is_active == FENCE_EDIT) ||
        (command_is_active == GROUP_EDIT))
    {
      FIg_set_off_color (Edit_form, CHAR_FOREGROUND2_CLR_BTN,
          temp_dpb.on_color);
      FIg_set_on_color (Edit_form, CHAR_FOREGROUND2_CLR_BTN,
          temp_dpb.on_color);
      FIg_display (Edit_form, CHAR_FOREGROUND2_CLR_BTN);
    }
    else
    {
      FIg_set_off_color (Characteristics_form, CHAR_FOREGROUND2_CLR_BTN,
          temp_dpb.on_color);
      FIg_set_on_color (Characteristics_form, CHAR_FOREGROUND2_CLR_BTN,
          temp_dpb.on_color);
      FIg_display (Characteristics_form, CHAR_FOREGROUND2_CLR_BTN);
    }
    break;
  }

  return;
}

/*************************************************************************/
/* */
/* execute_change_pv() */
/* */
/* This function is called by the executive command handler routine. */
/* */
/* It displays the Master_pv_form then exits. After that point */
/* the fi_master_pv_form() gadget notification routines will be in */
/* control. That is to say, every time the operator alters a gadget on */
/* one of these forms, the appropriate gadget notification routine will */
/* be invoked. */
/* */
/*************************************************************************/

void execute_change_pv(void)
{
  char t_str[256];
  int status;

  line_style[0] = -1; /* 0xFFFF */
  line_style[1] = -30584; /* 0x8888 */
  line_style[2] = -3172; /* 0xF39C */
  line_style[3] = -772; /* 0xFCFC */
  line_style[4] = -120; /* 0xFF88 */
  line_style[5] = -13108; /* 0xCCCC */
  line_style[6] = -1912; /* 0xF888 */
  line_style[7] = -100; /* 0xFF9C */

  UMSGetByNum (t_str, FB_I_CHPRESVAL, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_GENDEF, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Master_pv_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBSlPrVr");
    status = FIf_new (101, t_str, (int (*)())fi_master_pv_form, &Master_pv_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);

    FIf_set_location (Master_pv_form, 225, 120);
  }

  if (Font_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBSlFnt");
    status = FIf_new (102, t_str, (int (*)())fi_font_form, &Font_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  if (Grid_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBSlGrd");
    status = FIf_new (103, t_str, (int (*)())fi_grid_form, &Grid_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);

    FIf_set_location (Grid_form, 11, 400);
  }

  if (Line_weight_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBSlLnWt");
    status = FIf_new (104, t_str, (int (*)())fi_line_weight_form, &Line_weight_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  if (Line_style_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBSlLnSty");
    status = FIf_new (105, t_str, (int (*)())fi_line_style_form, &Line_style_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  strcpy (t_str, execute_dir);
  strcat (t_str, "/config/");
  strcat (t_str, language);
  strcat (t_str, "/forms/FBSlClr");

  if (FG_color_form == NULL)
  {
    status = FIf_new (106, t_str, (int (*)())fi_fg_color_form, &FG_color_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  if (BG_color_form == NULL)
  {
    status = FIf_new (107, t_str, (int (*)())fi_bg_color_form, &BG_color_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  if (FG2_color_form == NULL)
  {
    status = FIf_new (108, t_str, (int (*)())fi_fg2_color_form, &FG2_color_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  FIf_set_location (FG_color_form, 11, 120);
  FIf_set_location (BG_color_form, 20, 180);
  FIf_set_location (FG2_color_form, 30, 245);

  FIf_set_location (Font_form, 490, 120);
  FIf_set_location (Line_weight_form, 235, 600);
  FIf_set_location (Line_style_form, 840, 120);

  temp_dpb.bgcolor = dpb.bgcolor;
  temp_dpb.grid_flag = dpb.grid_flag;
  temp_dpb.grid_master_units = dpb.grid_master_units;
  temp_dpb.grid_sub_units = dpb.grid_sub_units;
  temp_dpb.off_color = dpb.off_color;
  temp_dpb.on_color = dpb.on_color;
  temp_dpb.line_style = dpb.line_style;
  temp_dpb.line_weight = dpb.line_weight;
  temp_dpb.bodysize = dpb.bodysize;
  strcpy (temp_dpb.font_name, dpb.font_name);

  temp_dpb.line_depth = dpb.line_depth;
  temp_dpb.text_style = dpb.text_style;
  temp_dpb.text_justification = dpb.text_justification;

  temp_dpb.expansion2 = dpb.expansion2;
  temp_dpb.expansion3 = dpb.expansion3;
  temp_dpb.expansion4 = dpb.expansion4;

  /* 
  sort_font_names();
*/
  temp_autokill_flag = autokill_mode;

  setup_master_pv_form();

  FIf_display (Master_pv_form);

  UMSGetByNum (t_str, FB_P_FILLPRES, 0);
  /* sml:04-29-92	put in gadget label (33) */
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

}
