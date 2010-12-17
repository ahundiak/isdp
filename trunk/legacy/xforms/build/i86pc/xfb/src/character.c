/***********************************

		character.c

***********************************/

/*
  History
	04-28-92	sml		ANSI-ized; changed local var types
*/

/********************************/
/* */
/* These functions display the characteristics form if it is not */
/* currently displayed. If no place or edit command is active, then all */
/* the gadgets on the form will be erased, and the form will */
/* be collapsed. */
/* */
/* Programmer: Mack Draper */
/* */
/* Date: Feb. 24, 1989 */
/* */
/********************************/

#include <stdio.h>

#include "X11/Xlib.h"

#include "FI.h"
#include "NFBpriv.h"
#include "UMS.h"
#include "FB.h"

#include "FIform.h" /* dmb:08/28/91 */

#include "XFIproto_pub.h"
#include "XFBproto_pri.h"

/**********************************/
/* */
/* used by Characteristics_form */
/* */
/**********************************/

#define CHAR_TEXT_FONT_TEXT 13

#define CHAR_FOREGROUND_CLR_BTN 47
#define CHAR_FOREGROUND2_CLR_BTN 48
#define CHAR_LINE_STYLE_BTN 27
#define CHAR_LINE_WEIGHT_BTN 26
#define CHAR_TEXT_FONT_BTN 46
#define CHAR_LINE_DEPTH_TOG 25

#define DISPLAYED_TOG 31
#define ENABLED_TOG 32
#define HILITE_TOG 23
#define DITHER_TOG 18
#define INITIAL_BTN 39
#define COMPLETION_BTN 40
#define LABEL_FLD 41

#define COMMAND_TYPE_TOG 35
#define CMD_STRING_TEXT 20
#define CMD_KEY_TEXT 21
#define COMMAND_FLD 15
#define HELP_FLD 16

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

#define ERR_FLD 20

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

extern Form work_form;
extern int command_is_active;
extern struct gadget_struct gadget_attr;
extern char execute_dir[200];
extern struct dpb_struct temp_dpb;
extern Form Font_form;
extern Form Line_weight_form;
extern Form Line_style_form;
extern Form FG_color_form;
extern Form FG2_color_form;
extern Form Message_form;
extern short line_style[8];

extern int edit_hilite_flag;
extern int edit_display_flag;

extern char language[80];
extern int vs_y_size;

/**********************/
/* */
/* Global variables */
/* */
/**********************/

Form Characteristics_form = NULL;
struct gadget_struct override_attr;

/*------------------------------------------------------------------------*/

void Clear_characteristics_form(void)
{
  int xx;

  FIg_erase (Characteristics_form, 10); /* Error field */
  FIg_erase (Characteristics_form, 13); /* Text Font Sample */

  FIfld_set_text (Characteristics_form, COMMAND_FLD, 0, 0, "", 0);
  FIfld_set_text (Characteristics_form, HELP_FLD, 0, 0, "", 0);

  for (xx = 13; xx < 121; xx++)
  {
    FIg_disable (Characteristics_form, xx);
  }

  FIf_erase (Font_form);
  FIf_erase (FG_color_form);
  FIf_erase (FG2_color_form);
  FIf_erase (Line_weight_form);
  FIf_erase (Line_style_form);

  FIg_set_state_off (Characteristics_form, CHAR_FOREGROUND_CLR_BTN);
  FIg_set_state_off (Characteristics_form, CHAR_FOREGROUND2_CLR_BTN);
  FIg_set_state_off (Characteristics_form, CHAR_LINE_STYLE_BTN);
  FIg_set_state_off (Characteristics_form, CHAR_LINE_WEIGHT_BTN);
  FIg_set_state_off (Characteristics_form, CHAR_TEXT_FONT_BTN);

  for (xx = 27; xx <= 40; xx++)
  {
    FIg_set_state_off (FG_color_form, xx);
    FIg_set_state_off (FG2_color_form, xx);
  }
}

/*------------------------------------------------------------------------*/

void Update_characteristics_form(void)
{
  int gdt_type, x;
  char t_str[256], n_str[10];

  /* change from int to Window for ANSI */
  Window window;
  extern int Two_vscreens_flag;
  int row, pos;

  FIf_get_window (Characteristics_form, &window);

  /*
Inq_win_collapse_org (window, &x, &y);

FIf_set_collapse_location (Characteristics_form, x, y);
*/
  FIg_enable (Characteristics_form, 23);
  FIg_enable (Characteristics_form, 31);
  FIg_enable (Characteristics_form, 32);
  FIg_enable (Characteristics_form, 41);
  FIg_enable (Characteristics_form, 43);
  FIg_enable (Characteristics_form, 13);

  /* Re-orient Characteristics forms so that they are based relative */
  /* to the screen height, rather than a fixed location.             */
  /*     GMD 1/29/92                                                 */

  FIf_set_location (Line_style_form, 583, vs_y_size - 621);
  FIf_set_location (Line_weight_form, 399, vs_y_size - 528);
  FIf_set_location (FG_color_form, 200, vs_y_size - 525);
  FIf_set_location (FG2_color_form, 0, vs_y_size - 525);
  FIf_set_location (Font_form, 400, vs_y_size - 698);

  override_attr.display = gadget_attr.display;
  override_attr.selectable = gadget_attr.selectable;
  override_attr.hilite = gadget_attr.hilite;
  override_attr.initial_notify = gadget_attr.initial_notify;
  override_attr.complete_notify = gadget_attr.complete_notify;
  override_attr.gadget_label = gadget_attr.gadget_label;
  override_attr.help = gadget_attr.help;
  override_attr.cmd_string = gadget_attr.cmd_string;
  override_attr.cmd_key = gadget_attr.cmd_key;
  override_attr.text_gadget = gadget_attr.text_gadget;
  override_attr.dither = gadget_attr.dither;
  strcpy (override_attr.command_string, gadget_attr.command_string);
  strcpy (override_attr.help_topic, gadget_attr.help_topic);

  temp_dpb.off_color = gadget_attr.off_color;
  temp_dpb.on_color = gadget_attr.on_color;
  temp_dpb.line_style = gadget_attr.line_style;
  temp_dpb.line_weight = gadget_attr.line_weight;
  temp_dpb.bodysize = gadget_attr.bodysize;
  strcpy (temp_dpb.font_name, gadget_attr.font_name);

  FIg_erase (Characteristics_form, CHAR_TEXT_FONT_TEXT);

  if (override_attr.text_gadget == 1)
  {
    strcpy (t_str, gadget_attr.font_name);
    if ((int)gadget_attr.bodysize != 0)
    {
      strcat (t_str, ".");
      sprintf (n_str, "%2d", (int)gadget_attr.bodysize);
      strcat (t_str, n_str);
    }

    FIg_set_text (Characteristics_form, CHAR_TEXT_FONT_TEXT, t_str);

    FIg_set_font (Characteristics_form, CHAR_TEXT_FONT_TEXT,
        gadget_attr.font_name,
        gadget_attr.bodysize);

    FIg_display (Characteristics_form, CHAR_TEXT_FONT_TEXT);
  }

  temp_dpb.line_depth = gadget_attr.line_depth;
  temp_dpb.text_style = gadget_attr.text_style;
  temp_dpb.text_justification = gadget_attr.text_justification;

  if (override_attr.display == 1)
    FIg_set_state_off (Characteristics_form, DISPLAYED_TOG);
  else
    FIg_set_state_on (Characteristics_form, DISPLAYED_TOG);

  if (override_attr.selectable == 1)
  {
    FIg_set_state_off (Characteristics_form, ENABLED_TOG);
    FIg_disable (Characteristics_form, DITHER_TOG);
  }
  else
  {
    FIg_set_state_on (Characteristics_form, ENABLED_TOG);
    FIg_enable (Characteristics_form, DITHER_TOG);
  }

  if (override_attr.hilite == 0)
    FIg_set_state_off (Characteristics_form, HILITE_TOG);
  else
    FIg_set_state_on (Characteristics_form, HILITE_TOG);

  if (override_attr.dither == 0)
    FIg_set_state_off (Characteristics_form, DITHER_TOG);
  else
    FIg_set_state_on (Characteristics_form, DITHER_TOG);

  if (override_attr.initial_notify == 1)
    FIg_set_state_on (Characteristics_form, INITIAL_BTN);
  else
    FIg_set_state_off (Characteristics_form, INITIAL_BTN);

  if (override_attr.complete_notify == 1)
    FIg_set_state_on (Characteristics_form, COMPLETION_BTN);
  else
    FIg_set_state_off (Characteristics_form, COMPLETION_BTN);

  if (override_attr.cmd_string == 1)
  {
    FIg_set_state_on (Characteristics_form, COMMAND_TYPE_TOG);
    FIg_erase (Characteristics_form, CMD_KEY_TEXT);
    FIg_display (Characteristics_form, CMD_STRING_TEXT);
  }
  else
  {
    FIg_set_state_off (Characteristics_form, COMMAND_TYPE_TOG);
    FIg_erase (Characteristics_form, CMD_STRING_TEXT);
    FIg_display (Characteristics_form, CMD_KEY_TEXT);
  }

  FIfld_set_text (Characteristics_form, COMMAND_FLD, 0, 0,
      override_attr.command_string, 0);

  FIfld_set_text (Characteristics_form, HELP_FLD, 0, 0,
      override_attr.help_topic, 0);

  sprintf (t_str, "%d", override_attr.gadget_label);
  FIfld_set_text (Characteristics_form, LABEL_FLD, 0, 0, t_str, 0);

  for (x = 27; x <= 40; x++)
  {
    FIg_set_off_color (FG_color_form, x, (x - 27));
    FIg_set_off_color (FG2_color_form, x, (x - 27));

    FIg_set_on_color (FG_color_form, x, (x - 27));
    FIg_set_on_color (FG2_color_form, x, (x - 27));
  }

  FIg_set_state_on (FG_color_form, 27 + gadget_attr.off_color);
  FIg_set_state_on (FG2_color_form, 27 + gadget_attr.on_color);

  if (temp_dpb.line_depth == FI_3D_LINE)
    FIg_set_state_on (Characteristics_form, CHAR_LINE_DEPTH_TOG);
  else
    FIg_set_state_off (Characteristics_form, CHAR_LINE_DEPTH_TOG);

   /* GMD 2/4/92   Fix problem displaying current line style */

   for (x = 0; x < 8; x++)
    {
      FIg_set_state_off (Line_style_form, 30 + x);
    }

  for (x = 0; x < 8; x++)
    {
      if (line_style[x] == temp_dpb.line_style)
	{
	  FIg_set_state_on (Line_style_form, 30 + x);
	}
    }

  FIg_set_text_style (Font_form, SAMPLE_HEADER, temp_dpb.text_style);
  FIg_set_text_style (Font_form, SAMPLE_TEXT, temp_dpb.text_style);

  FIg_set_justification (Font_form, SAMPLE_HEADER,
      temp_dpb.text_justification);
  FIg_set_justification (Font_form, SAMPLE_TEXT,
      temp_dpb.text_justification);

  FIg_set_off_color (Font_form, SAMPLE_HEADER, temp_dpb.off_color);
  FIg_set_on_color (Font_form, SAMPLE_HEADER, temp_dpb.on_color);
  FIg_set_off_color (Font_form, SAMPLE_TEXT, temp_dpb.off_color);
  FIg_set_on_color (Font_form, SAMPLE_TEXT, temp_dpb.on_color);

  FIg_set_state_off (Font_form, NORMAL_CK);
  FIg_set_state_off (Font_form, EMBOSSED_CK);
  FIg_set_state_off (Font_form, INCISED_CK);
  FIg_set_state_off (Font_form, SHADOWED_CK);

  FIfld_get_active_row (Font_form, TYPEFACE_LIST_FLD, &row, &pos);
  FIfld_set_select (Font_form, TYPEFACE_LIST_FLD, row, 0, 0);

  if (temp_dpb.text_style == FI_NORMAL_TEXT)
  {
    FIg_set_state_on (Font_form, NORMAL_CK);
  }
  else if (temp_dpb.text_style == FI_EMBOSSED)
  {
    FIg_set_state_on (Font_form, EMBOSSED_CK);
  }
  else if (temp_dpb.text_style == FI_INCISED)
  {
    FIg_set_state_on (Font_form, INCISED_CK);
  }
  else if (temp_dpb.text_style == FI_SHADOWED)
  {
    FIg_set_state_on (Font_form, SHADOWED_CK);
  }

  FIg_set_state_off (Font_form, LEFT_JUST_CK);
  FIg_set_state_off (Font_form, CENTER_JUST_CK);
  FIg_set_state_off (Font_form, RIGHT_JUST_CK);

  if (temp_dpb.text_justification == FI_LEFT_JUSTIFIED)
  {
    FIg_set_state_on (Font_form, LEFT_JUST_CK);
  }
  else if (temp_dpb.text_justification == FI_CENTER_JUSTIFIED)
  {
    FIg_set_state_on (Font_form, CENTER_JUST_CK);
  }
  else if (temp_dpb.text_justification == FI_RIGHT_JUSTIFIED)
  {
    FIg_set_state_on (Font_form, RIGHT_JUST_CK);
  }

  /* No longer necessary to do this more than once
sort_font_names(); 6/12/90
*/

  if (override_attr.text_gadget == 1)
  {
    FIfld_set_text (Font_form, TYPEFACE_FLD, 0, 0,
        temp_dpb.font_name, 0);

    sprintf (t_str, "%d", (int)temp_dpb.bodysize);

    if ((int)temp_dpb.bodysize != 0)
      FIfld_set_text (Font_form, SIZE_FLD, 0, 0, t_str, 0);
    else
      FIfld_set_text (Font_form, SIZE_FLD, 0, 0, "", 0);

    FIg_set_font (Font_form, SAMPLE_TEXT, temp_dpb.font_name,
        temp_dpb.bodysize);

    FIg_set_font (Font_form, SAMPLE_HEADER, temp_dpb.font_name,
        temp_dpb.bodysize);
  }

  /*************************************************************/
  /* */
  /* Now set up the line weight form with current dpb values */
  /* */
  /*************************************************************/

  FIg_set_value (Line_weight_form, LINE_WEIGHT_SLIDER,
      (double)temp_dpb.line_weight);

  FIg_set_line_weight (Line_weight_form, LINE_WEIGHT_LINE,
      temp_dpb.line_weight);

  /*********************************************************************/
  /* */
  /* Enable Notification Box and Information on queue box if necessary */
  /* */
  /*********************************************************************/

  gdt_type = gadget_attr.gadget_type;

  if ((gdt_type == FI_BUTTON) ||
      (gdt_type == FI_CHECKLIST) ||
      (gdt_type == FI_TOGGLE) ||
      (gdt_type == FI_SLIDER) ||
      (gdt_type == FI_SYM) ||
      (gdt_type == FI_TEXT) ||
      (gdt_type == FI_DIAL) ||
      (gdt_type == FI_RECT) ||
      (gdt_type == FI_FIELD) ||
      (gdt_type == FI_MULTI_COL))
  {
    FIg_enable (Characteristics_form, 35);
    FIg_enable (Characteristics_form, 20);
    FIg_enable (Characteristics_form, 21);
    FIg_enable (Characteristics_form, 22);
    FIg_enable (Characteristics_form, 15);
    FIg_enable (Characteristics_form, 16);
    FIg_enable (Characteristics_form, 52);
    FIg_enable (Characteristics_form, 50);
    FIg_enable (Characteristics_form, 39);
    FIg_enable (Characteristics_form, 40);
  }

  /*************************************************************/
  /* */
  /* Now enable any dpb buttons that are needed by the gadget */
  /* */
  /*************************************************************/

  FIg_set_off_color (Characteristics_form, CHAR_FOREGROUND_CLR_BTN,
      temp_dpb.off_color);
  FIg_set_on_color (Characteristics_form, CHAR_FOREGROUND_CLR_BTN,
      temp_dpb.off_color);
  FIg_set_state_off (Characteristics_form, CHAR_FOREGROUND_CLR_BTN);

  if (gdt_type != FI_SCROLL)
  {
    FIg_enable (Characteristics_form, CHAR_FOREGROUND_CLR_BTN);
  }

  FIg_set_off_color (Characteristics_form, CHAR_FOREGROUND2_CLR_BTN,
      temp_dpb.on_color);
  FIg_set_on_color (Characteristics_form, CHAR_FOREGROUND2_CLR_BTN,
      temp_dpb.on_color);
  FIg_set_state_off (Characteristics_form, CHAR_FOREGROUND2_CLR_BTN);

  if ((gdt_type == FI_BUTTON) ||
      (gdt_type == FI_CHECKLIST) ||
      (gdt_type == FI_TEXT) ||
      (gdt_type == FI_TOGGLE) ||
      (gdt_type == FI_SLIDER) ||
      (gdt_type == FI_DIAL) ||
      (gdt_type == FI_FIELD) ||
      (gdt_type == FI_MULTI_COL))
  {
    FIg_set_state_off (Characteristics_form, CHAR_TEXT_FONT_BTN);
    FIg_enable (Characteristics_form, CHAR_TEXT_FONT_BTN);
  }

  if ((gdt_type == FI_BUTTON) ||
      (gdt_type == FI_TOGGLE) ||
      (gdt_type == FI_GAUGE) ||
      (gdt_type == FI_FIELD) ||
      (gdt_type == FI_TEXT) ||
      (gdt_type == FI_RECT) ||
      (gdt_type == FI_SLIDER) ||
      (gdt_type == FI_CHECKLIST) ||
      (gdt_type == FI_MULTI_COL))
  {
    FIg_set_state_off (Characteristics_form, CHAR_FOREGROUND2_CLR_BTN);
    FIg_enable (Characteristics_form, CHAR_FOREGROUND2_CLR_BTN);
  }

  if ((gdt_type == FI_LINE) ||
      (gdt_type == FI_RECT))
  {
    FIg_set_state_off (Characteristics_form, CHAR_LINE_STYLE_BTN);
    FIg_set_state_off (Characteristics_form, CHAR_LINE_WEIGHT_BTN);

    FIg_enable (Characteristics_form, CHAR_LINE_STYLE_BTN);
    FIg_enable (Characteristics_form, CHAR_LINE_WEIGHT_BTN);
    FIg_enable (Characteristics_form, CHAR_LINE_DEPTH_TOG);
  }

}

/*------------------------------------------------------------------------*/

/* ARGSUSED */
void fi_characteristics_form (int form_label,
                             int gadget_label,
                             double value,
                             Form form_ptr)
{
  char t_str[256];
  int i, label_is_ok, status;
  int state;
  int dummy_int;

  FIg_erase (Characteristics_form, 10); /* Erase error field */

  switch (gadget_label)
  {
  case DISPLAYED_TOG:

    if ((int)value == 0)
    {
      override_attr.display = 1;
    }
    else
    {
      override_attr.display = 0;
    }
    break;

  case ENABLED_TOG:

    if ((int)value == 0)
    {
      override_attr.selectable = 1;
      FIg_disable (Characteristics_form, DITHER_TOG);
    }
    else
    {
      override_attr.selectable = 0;
      FIg_enable (Characteristics_form, DITHER_TOG);
    }
    break;

  case HILITE_TOG:

    if ((int)value == 1)
      override_attr.hilite = 1;
    else
      override_attr.hilite = 0;
    break;

  case DITHER_TOG:

    if ((int)value == 1)
      override_attr.dither = 1;
    else
      override_attr.dither = 0;
    break;

  case INITIAL_BTN:

    if ((int)value == 1)
      override_attr.initial_notify = 1;
    else
      override_attr.initial_notify = 0;
    break;

  case COMPLETION_BTN:

    if ((int)value == 1)
      override_attr.complete_notify = 1;
    else
      override_attr.complete_notify = 0;
    break;

  case COMMAND_TYPE_TOG:

    if ((int)value == 0)
    {
      override_attr.cmd_key = 1;
      override_attr.cmd_string = 0;
      FIg_erase (Characteristics_form, CMD_STRING_TEXT);
      FIg_display (Characteristics_form, CMD_KEY_TEXT);
    }
    else
    {
      override_attr.cmd_string = 1;
      override_attr.cmd_key = 0;
      FIg_erase (Characteristics_form, CMD_KEY_TEXT);
      FIg_display (Characteristics_form, CMD_STRING_TEXT);
    }
    break;

  case COMMAND_FLD:

    FIfld_get_text (Characteristics_form, COMMAND_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    strcpy (override_attr.command_string, t_str);
    if (strlen (t_str) != 0)
    {
      FIg_get_state (Characteristics_form, COMMAND_TYPE_TOG, &state);
      if (state == 0)
      {
        override_attr.cmd_key = 1;
        override_attr.cmd_string = 0;
      }
      else
      {
        override_attr.cmd_key = 0;
        override_attr.cmd_string = 1;
      }
    }
    break;

  case HELP_FLD:

    FIfld_get_text (Characteristics_form, HELP_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    strcpy (override_attr.help_topic, t_str);

    if (t_str[0] != '\0') /* NULL string */
      override_attr.help = 1;
    else
      override_attr.help = 0;
    break;

  case LABEL_FLD:

    FIfld_get_text (Characteristics_form, LABEL_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    i = atoi(t_str);

    label_is_ok = 1;

    status = FIg_get_location (work_form, i, &dummy_int, &dummy_int);

    if (status == FI_SUCCESS)
      label_is_ok = 0;

    status = FIgrp_get_pass (work_form, i, &dummy_int);

    if (status == FI_SUCCESS)
      label_is_ok = 0;

    if (label_is_ok == 0)
    {
      UMSGetByNum (t_str, FB_E_LABELINUSE, "%d", i);
      print_error (Characteristics_form, 10, t_str);

      sprintf (t_str, "%d", override_attr.gadget_label);
      FIfld_set_text (Characteristics_form, LABEL_FLD, 0, 0, t_str, 0);
    }
    else if (i > 999)
    {
      UMSGetByNum (t_str, FB_E_LABLT1000, 0);
      print_error (Characteristics_form, 10, t_str);

      sprintf (t_str, "%d", override_attr.gadget_label);
      FIfld_set_text (Characteristics_form, LABEL_FLD, 0, 0, t_str, 0);
    }
    else if (i < 11)
    {
      UMSGetByNum (t_str, FB_E_LABGT10, 0);
      print_error (Characteristics_form, 10, t_str);

      sprintf (t_str, "%d", override_attr.gadget_label);
      FIfld_set_text (Characteristics_form, LABEL_FLD, 0, 0, t_str, 0);
    }
    else
      override_attr.gadget_label = i;
    break;

  case FI_CANCEL:

    FIf_erase (Font_form);
    FIf_erase (Line_weight_form);
    FIf_erase (Line_style_form);
    FIf_erase (FG_color_form);
    FIf_erase (FG2_color_form);

    FIf_erase (Characteristics_form);
    FIg_set_state_off (Characteristics_form, FI_CANCEL);
    break;

  case CHAR_LINE_DEPTH_TOG:

    if ((int)value == 1)
      temp_dpb.line_depth = FI_3D_LINE;
    else
      temp_dpb.line_depth = FI_2D_LINE;
    break;

  case CHAR_FOREGROUND_CLR_BTN:

    if ((int)value == 1)
      FIf_display (FG_color_form);
    else
      FIf_erase (FG_color_form);
    break;

  case CHAR_FOREGROUND2_CLR_BTN:

    if ((int)value == 1)
      FIf_display (FG2_color_form);
    else
      FIf_erase (FG2_color_form);
    break;

  case CHAR_LINE_STYLE_BTN:

    if ((int)value == 1)
      FIf_display (Line_style_form);
    else
      FIf_erase (Line_style_form);
    break;

  case CHAR_LINE_WEIGHT_BTN:

    if ((int)value == 1)
      FIf_display (Line_weight_form);
    else
      FIf_erase (Line_weight_form);
    break;

  case CHAR_TEXT_FONT_BTN:

    if ((int)value == 1)
      FIf_display (Font_form);
    else
      FIf_erase (Font_form);
    break;
  }
  return;
}

/*------------------------------------------------------------------------*/

void execute_display_characteristics_form(void)
{
  char t_str[256];
  int status;
  int state;

  if (Characteristics_form != NULL)
  {
    FIf_is_displayed (Characteristics_form, &state);
    if (state == 1)
      return;
  }

/* dmb:10/05/91
  UMSGetByNum (t_str, FB_I_DISPCHAR, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
*/
  FIfld_set_text (Message_form, 33, 0, 0, "", 0);

  line_style[0] = -1; /* 0xFFFF */
  line_style[1] = -30584; /* 0x8888 */
  line_style[2] = -3172; /* 0xF39C */
  line_style[3] = -772; /* 0xFCFC */
  line_style[4] = -120; /* 0xFF88 */
  line_style[5] = -13108; /* 0xCCCC */
  line_style[6] = -1912; /* 0xF888 */
  line_style[7] = -100; /* 0xFF9C */

  if (Font_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBSlFnt");

    status = FIf_new (102, t_str, (int (*)())fi_font_form, &Font_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
    FIf_set_location (Font_form, 665, 460);
  }

  /* This will load in the fonts as well as sorting them. */
  /* This only needs to be done once.  GMD 6/12/90 */
  sort_font_names();

  if (Line_weight_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBSlLnWt");

    status = FIf_new (104, t_str, (int (*)())fi_line_weight_form, &Line_weight_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);

    /* dmb:09/12/91:IFORMS does this */
    FIg_set_continuous_routine ( Line_weight_form, LINE_WEIGHT_SLIDER,
        (int (*)())fi_line_weight_form );

    FIf_set_location (Line_weight_form, 360, 500);
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
    FIf_set_location (Line_style_form, 625, 57);
  }

  if (FG_color_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBSlClr");
    status = FIf_new (106, t_str, (int (*)())fi_fg_color_form, &FG_color_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  if (FG2_color_form == NULL)
  {
    status = FIf_new (108, t_str, (int (*)())fi_fg2_color_form, &FG2_color_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);

    FIg_set_off_text (FG2_color_form, COLOR_TEXT, "On Color");
  }

  if (Characteristics_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBEdGdCh");

    status = FIf_new (100, t_str, (int (*)())fi_characteristics_form,
        &Characteristics_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);

    /* FIf_display (Characteristics_form); dmb:08/28/91:Test probe */

    FIf_set_collapse_location (Characteristics_form, 865, 760);
  }

  FIg_erase (Characteristics_form, CMD_STRING_TEXT);
  FIg_display (Characteristics_form, CMD_KEY_TEXT);

  switch (command_is_active)
  {
  case PLACE_BUTTON:
  case PLACE_FIELD:
  case PLACE_CHECKLIST:
  case PLACE_TEXT:
  case PLACE_SYMBOL:
  case PLACE_TOGGLE:
  case PLACE_SLIDER:
  case PLACE_DIAL:
  case PLACE_RECTANGLE:
  case PLACE_LINE:
  case PLACE_PALETTE:
  case PLACE_BEZEL:
  case PLACE_MULTI_COL:
  case EDIT_GADGET:

    Update_characteristics_form();
    break;

  default:

    Clear_characteristics_form();
    break;
  }

  /****************************************/
  /* Now display the characteristics form */
  /****************************************/

  if (command_is_active != 0)
    FIf_display (Characteristics_form);

  UMSGetByNum (t_str, FB_P_SELCOM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
  FIfld_set_text (Message_form, 11, 0, 0, "", 0);
}

/*------------------------------------------------------------------------*/

void replace_attr_with_overrides(void)
{
  gadget_attr.display = override_attr.display;
  gadget_attr.selectable = override_attr.selectable;
  gadget_attr.hilite = override_attr.hilite;
  gadget_attr.dither = override_attr.dither;
  gadget_attr.initial_notify = override_attr.initial_notify;
  gadget_attr.complete_notify = override_attr.complete_notify;
  gadget_attr.gadget_label = override_attr.gadget_label;
  gadget_attr.help = override_attr.help;
  gadget_attr.cmd_string = override_attr.cmd_string;
  gadget_attr.cmd_key = override_attr.cmd_key;
  strcpy (gadget_attr.command_string, override_attr.command_string);
  strcpy (gadget_attr.help_topic, override_attr.help_topic);

  gadget_attr.off_color = temp_dpb.off_color;
  gadget_attr.on_color = temp_dpb.on_color;
  gadget_attr.line_style = temp_dpb.line_style;
  gadget_attr.line_weight = temp_dpb.line_weight;
  gadget_attr.bodysize = temp_dpb.bodysize;
  strcpy (gadget_attr.font_name, temp_dpb.font_name);

  gadget_attr.line_depth = temp_dpb.line_depth;
  gadget_attr.text_style = temp_dpb.text_style;
  gadget_attr.text_justification = temp_dpb.text_justification;
}
