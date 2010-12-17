/***********************************

		fence_edit.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
*/

/*************************************/
/* */
/* This file contains functions for the "fence edit" command. */
/* */
/* Programmer: Mack Draper */
/* Date: Apr. 27, 1989 */
/* */
/*************************************/

#include <stdio.h>

#include <X11/Xlib.h>

#include "FI.h"
#include "FIdyn.h"
#include "NFBpriv.h"
#include "FB.h"
#include "FEI.h"

#include "XFIproto_pub.h"
#include "XFIproto_pri.h"
#include "XFBproto_pri.h"

/**********************************/
/* */
/* used by Characteristics_form */
/* */
/**********************************/

#define CHAR_FOREGROUND_CLR_BTN 47
#define CHAR_FOREGROUND2_CLR_BTN 48
#define CHAR_LINE_STYLE_BTN 27
#define CHAR_LINE_WEIGHT_BTN 26
#define CHAR_TEXT_FONT_BTN 46
#define CHAR_LINE_DEPTH_TOG 25

#define DISPLAYED_TOG 31
#define ENABLED_TOG 32
#define HILITE_TOG 23

#define DISPLAY_EDIT_TOG 12
#define ENABLE_EDIT_TOG 13
#define HILITE_EDIT_TOG 14
#define FONT_EDIT_TOG 15
#define FG2_EDIT_TOG 16
#define FG_EDIT_TOG 17
#define DEPTH_EDIT_TOG 18
#define WEIGHT_EDIT_TOG 19
#define STYLE_EDIT_TOG 20

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

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

Form Edit_form = NULL;
Form Font_options_form = NULL;

int Edit_font_typeface_flag;
int Edit_font_size_flag;
int Edit_font_style_flag;
int Edit_font_justification_flag;

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern Form work_form;
extern struct dpb_struct dpb;
extern struct dpb_struct temp_dpb;
extern int command_is_active;
extern char current_command_string[80];
extern char execute_dir[200];

extern Form Font_form;
extern Form Line_weight_form;
extern Form Line_style_form;
extern Form FG_color_form;
extern Form FG2_color_form;
extern Form Message_form;

extern struct gadget_struct override_attr;
extern int Total_gadgets;
extern struct seq_struct seq_list[1001];

extern int Two_vscreens_flag;
extern short line_style[8];

extern char language[80];

extern GC xfb_GC;
extern XGCValues GC_values;
extern int hilite_plane;
extern Display *display;

/*************************************************************************/
/* */
/* kill_fence_edit() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to FENCE_EDIT indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_fence_edit(void)
{
  int x;
  char t_str[256];

  command_is_active = 0;
  strcpy (current_command_string, "None");

  FIf_erase (Font_form);
  FIf_erase (Line_weight_form);
  FIf_erase (Line_style_form);
  FIf_erase (FG_color_form);
  FIf_erase (FG2_color_form);

  if (Edit_form != NULL)
    FIf_erase (Edit_form);

  for (x = 0; x < Total_gadgets; x++)
  {
    if (seq_list[x].hilite_flag == 0)
      FIg_unhilite (work_form, seq_list[x].gadget);
    if (seq_list[x].display_flag == 0)
      FIg_erase (work_form, seq_list[x].gadget);
  }

  FIfld_set_text (Message_form, 11, 0, 0, "", 0);
  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  UMSGetByNum (t_str, FB_P_SELCOM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (work_form != NULL) /* Form already displayed */
  {
    FIf_set_builder_mode_off ((struct FIform_obj *)work_form);
  }

  if (Font_options_form != NULL)
    FIf_erase (Font_options_form);
}

/*************************************************************************/
/* */
/* fi_font_options_form() */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_font_options_form (int form_label,
                          int gadget_label,
                          double value,
                          Form form_ptr)
{
#define EDIT_FONT_TYPEFACE_CK 12
#define EDIT_FONT_SIZE_CK 13
#define EDIT_FONT_STYLE_CK 14
#define EDIT_FONT_JUSTIFICATION_CK 15

  switch (gadget_label)
  {
  case EDIT_FONT_TYPEFACE_CK:

    Edit_font_typeface_flag = (int)value;
    break;

  case EDIT_FONT_SIZE_CK:

    Edit_font_size_flag = (int)value;
    break;

  case EDIT_FONT_STYLE_CK:

    Edit_font_style_flag = (int)value;
    break;

  case EDIT_FONT_JUSTIFICATION_CK:

    Edit_font_justification_flag = (int)value;
    break;
  }

  return;
}

/*************************************************************************/
/* */
/* fi_multi_edit_form() */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_multi_edit_form (int form_label,
                        int gadget_label,
                        double value,
                        Form form_ptr)
{
  int x, state;
  int attr;
  float font_bodysize;
  char font_typeface[200];
  int gdt_type, button_ok;
  int num_rows, num_cols;
  int height, width, line_spacing, xsize, ysize;

  FIg_erase (Edit_form, 10); /* Erase error field */

  switch (gadget_label)
  {
  case DISPLAY_EDIT_TOG:

    if ((int)value == 1)
      FIg_enable (Edit_form, DISPLAYED_TOG);
    else
    {
      FIg_disable (Edit_form, DISPLAYED_TOG);
    }
    break;

  case ENABLE_EDIT_TOG:

    if ((int)value == 1)
      FIg_enable (Edit_form, ENABLED_TOG);
    else
      FIg_disable (Edit_form, ENABLED_TOG);
    break;

  case HILITE_EDIT_TOG:

    if ((int)value == 1)
      FIg_enable (Edit_form, HILITE_TOG);
    else
      FIg_disable (Edit_form, HILITE_TOG);
    break;

  case FONT_EDIT_TOG:

    if ((int)value == 1)
      FIg_enable (Edit_form, CHAR_TEXT_FONT_BTN);
    else
    {
      FIf_erase (Font_form);
      FIf_erase (Font_options_form);
      FIg_disable (Edit_form, CHAR_TEXT_FONT_BTN);
    }
    break;

  case FG2_EDIT_TOG:

    if ((int)value == 1)
      FIg_enable (Edit_form, CHAR_FOREGROUND2_CLR_BTN);
    else
    {
      FIf_erase (FG2_color_form);
      FIg_disable (Edit_form, CHAR_FOREGROUND2_CLR_BTN);
    }
    break;

  case FG_EDIT_TOG:

    if ((int)value == 1)
      FIg_enable (Edit_form, CHAR_FOREGROUND_CLR_BTN);
    else
    {
      FIf_erase (FG_color_form);
      FIg_disable (Edit_form, CHAR_FOREGROUND_CLR_BTN);
    }
    break;

  case DEPTH_EDIT_TOG:

    if ((int)value == 1)
      FIg_enable (Edit_form, CHAR_LINE_DEPTH_TOG);
    else
      FIg_disable (Edit_form, CHAR_LINE_DEPTH_TOG);
    break;

  case WEIGHT_EDIT_TOG:

    if ((int)value == 1)
      FIg_enable (Edit_form, CHAR_LINE_WEIGHT_BTN);
    else
    {
      FIf_erase (Line_weight_form);
      FIg_disable (Edit_form, CHAR_LINE_WEIGHT_BTN);
    }
    break;

  case STYLE_EDIT_TOG:

    if ((int)value == 1)
      FIg_enable (Edit_form, CHAR_LINE_STYLE_BTN);
    else
    {
      FIf_erase (Line_style_form);
      FIg_disable (Edit_form, CHAR_LINE_STYLE_BTN);
    }
    break;

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
      override_attr.selectable = 1;
    else
      override_attr.selectable= 0;
    break;

  case HILITE_TOG:

    if ((int)value == 1)
      override_attr.hilite = 1;
    else
      override_attr.hilite = 0;
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
    {
      FIf_display (Font_form);
      FIf_display (Font_options_form);
    }
    else
    {
      FIf_erase (Font_options_form);
      FIf_erase (Font_form);
    }
    break;

  case FI_CANCEL:

    FIf_erase (Font_form);
    FIf_erase (Line_weight_form);
    FIf_erase (Line_style_form);
    FIf_erase (FG_color_form);
    FIf_erase (FG2_color_form);

    FIf_erase (Edit_form);
    FIg_set_state_off (Edit_form, FI_CANCEL);
    FIf_erase (Font_options_form);

    /*********************************************/
    /* */
    /* Need to restore the fenced area's gadgets */
    /* to be non-displayed or unhilighted if */
    /* necessary. */
    /* */
    /*********************************************/

    for (x = 0; x < Total_gadgets; x++)
    {
      if (seq_list[x].display_flag == 0)
        FIg_erase (work_form, seq_list[x].gadget);

      if (seq_list[x].hilite_flag == 0)
        FIg_unhilite (work_form, seq_list[x].gadget);
    }

    Total_gadgets = 0; /* To keep from refreshing the screen twice */

    kill_fence_edit();
    break;

  case FI_ACCEPT:

    if (Total_gadgets > 0)
    {
      for (x = 0; x < Total_gadgets; x++)
      {
        FIg_get_type (work_form, seq_list[x].gadget, &gdt_type);

        FIg_get_attr (work_form, seq_list[x].gadget, &attr);

        FIg_get_state (Edit_form, DISPLAY_EDIT_TOG, &state);

        if (state == 1)
        {
          FIg_get_state (Edit_form, DISPLAYED_TOG, &state);

          if (state == 0)
          {
            if (attr & FI_NOT_DISPLAYED)
              attr ^= FI_NOT_DISPLAYED;
          }
          else
            attr |= FI_NOT_DISPLAYED;

        }
        else
        {
          if (seq_list[x].display_flag == 1)
          {
            if (attr & FI_NOT_DISPLAYED)
              attr ^= FI_NOT_DISPLAYED;
          }
          else
            attr |= FI_NOT_DISPLAYED;
        }

        FIg_get_state (Edit_form, HILITE_EDIT_TOG, &state);

        if (state == 1)
        {
          FIg_get_state (Edit_form, HILITE_TOG, &state);

          if (state == 0)
          {
            if (attr & FI_HILITED)
              attr ^= FI_HILITED;
          }
          else
            attr |= FI_HILITED;
        }
        else
        {
          if (seq_list[x].hilite_flag == 0)
          {
            if (attr & FI_HILITED)
              attr ^= FI_HILITED;
          }
          else
            attr |= FI_HILITED;
        }

        FIg_get_state (Edit_form, ENABLE_EDIT_TOG, &state);

        if (state == 1)
        {
          FIg_get_state (Edit_form, ENABLED_TOG, &state);

          if (state == 0)
          {
            if (attr & FI_NOT_ENABLED)
              attr ^= FI_NOT_ENABLED;
          }
          else
            attr |= FI_NOT_ENABLED;
        }

        FIg_get_state (Edit_form, FG2_EDIT_TOG, &state);

        if (state == 1)
          FIg_set_on_color (work_form, seq_list[x].gadget,
              temp_dpb.on_color);

        FIg_get_state (Edit_form, FG_EDIT_TOG, &state);

        if (state == 1)
          FIg_set_off_color (work_form, seq_list[x].gadget,
              temp_dpb.off_color);

        FIg_get_state (Edit_form, DEPTH_EDIT_TOG, &state);

        if (state == 1)
          FIg_set_line_depth (work_form, seq_list[x].gadget,
              temp_dpb.line_depth);

        FIg_get_state (Edit_form, WEIGHT_EDIT_TOG, &state);

        if (state == 1)
          FIg_set_line_weight (work_form, seq_list[x].gadget,
              temp_dpb.line_weight);

        FIg_get_state (Edit_form, STYLE_EDIT_TOG, &state);

        if (state == 1)
          FIg_set_line_style (work_form, seq_list[x].gadget,
              temp_dpb.line_style);

        button_ok = 1;

        if ((gdt_type == FI_BUTTON) ||
            (gdt_type == FI_TOGGLE))
        {
          if ((attr & FI_TEXT_GADGET) == 0)
            button_ok = 0;
        }

        if (gdt_type == FI_SYM)
          button_ok = 0;

        FIg_get_state (Edit_form, FONT_EDIT_TOG, &state);

        if ((state == 1) &&
            (button_ok == 1))
        {
          if ((Edit_font_style_flag == 1) &&
              (gdt_type != FI_LINE) &&
              (gdt_type != FI_RECT))
          {
            FIg_set_text_style (work_form, seq_list[x].gadget,
                temp_dpb.text_style);
          }

          if (Edit_font_justification_flag == 1)
          {
            FIg_set_justification (work_form, seq_list[x].gadget,
                temp_dpb.text_justification);
          }

          FIg_get_font (work_form, seq_list[x].gadget,
              font_typeface, &font_bodysize);

          /****************************************************/
          /* */
          /* If the gadget is a field, and the field is only */
          /* one line deep, then the ysize of the field needs */
          /* to be adjusted to the ysize of the new font's */
          /* line_spacing. At this point a check is made to */
          /* see if the gadget is a field, and if so is it */
          /* only one line deep. The local variable */
          /* Single_line_field will be set to one to indicate */
          /* that this is the case. */
          /* */
          /****************************************************/

          if (gdt_type == FI_FIELD)
          {
            FIfld_get_num_vis_rows (work_form, seq_list[x].gadget,
                &num_rows);

            FIfld_get_num_vis_chars (work_form, seq_list[x].gadget,
                0, &num_cols);
          }

          if (Edit_font_typeface_flag == 1)
            strcpy (font_typeface, temp_dpb.font_name);

          if (Edit_font_size_flag == 1)
            font_bodysize = temp_dpb.bodysize;

          if (gdt_type == FI_FIELD)
          {
            Font font_id;
            int font_type;
            float  dummy_float;

            _FI_find_font_id (font_typeface, font_bodysize, &font_id,
                &dummy_float, FI_FIELD, &font_type);

            _FI_calc_text (font_id, "M", 1, &height, &width, &line_spacing, font_type);

            xsize = num_cols * width;
            ysize = num_rows * line_spacing;

            FIg_set_size (work_form, seq_list[x].gadget,
                xsize, ysize);
          }

          FIg_set_font (work_form, seq_list[x].gadget,
              font_typeface, font_bodysize);
        }

        /******************************************************************/
        /* */
        /* Have to treat SCROLL gadgets and MCF gadgets differently than */
        /* the rest. Trying to set_attr for those two gadgets has */
        /* no effect. */
        /* */
        /******************************************************************/

        if ((gdt_type == FI_SCROLL) ||
            (gdt_type == FI_MULTI_COL) ||
            (gdt_type == FI_FIELD))
        {
          if ((attr & FI_HILITED) == 0)
            FIg_unhilite (work_form, seq_list[x].gadget);

          if (attr & FI_NOT_DISPLAYED)
            FIg_erase (work_form, seq_list[x].gadget);

          if (attr & FI_NOT_ENABLED)
            FIg_disable (work_form, seq_list[x].gadget);
          else
            FIg_enable (work_form, seq_list[x].gadget);

          FIg_activate (work_form, seq_list[x].gadget);
        }
        else
          FIg_set_attr (work_form, seq_list[x].gadget, attr);

      }

      /* New 10/21/89 */

      _FI_g_verify_erase_color ((struct FIform_obj *)work_form, seq_list[x].gadget,
          FI_FORM_GROUP);
    }

    FIf_erase (Font_form);
    FIf_erase (Line_weight_form);
    FIf_erase (Line_style_form);
    FIf_erase (FG_color_form);
    FIf_erase (FG2_color_form);

    FIf_erase (Edit_form);
    FIg_set_state_off (Edit_form, FI_ACCEPT);
    FIf_erase (Font_options_form);

    Refresh_work_form();

    Total_gadgets = 0;

    if (command_is_active == FENCE_EDIT)
      execute_fence_edit();
    else
      execute_group_edit();

    break;
  }

  return;
}

/*************************************************************************/
/* */
/* Display_edit_forms() */
/* */
/*************************************************************************/

void Display_edit_forms(void)
{
  char t_str[256];
  int x;
  int status;

  Edit_font_typeface_flag = 0;
  Edit_font_size_flag = 0;
  Edit_font_style_flag = 0;
  Edit_font_justification_flag = 0;

  if (Font_options_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBEdFntOp");
    status = FIf_new (107, t_str, (int (*)())fi_font_options_form, &Font_options_form);
    if (status != 0)
      Report_fatal_form_error (status, t_str);
  }

  if (Edit_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBEdGrpFnc");
    status = FIf_new (107, t_str, (int (*)())fi_multi_edit_form, &Edit_form);
    if (status != 0)
      Report_fatal_form_error (status, t_str);
  }

  FIg_erase (Edit_form, 10);
  FIg_erase (Font_options_form, 10);

  FIg_set_state_off (Edit_form, CHAR_FOREGROUND_CLR_BTN);
  FIg_disable (Edit_form, CHAR_FOREGROUND_CLR_BTN);
  FIg_set_state_off (Edit_form, CHAR_FOREGROUND2_CLR_BTN);
  FIg_disable (Edit_form, CHAR_FOREGROUND2_CLR_BTN);
  FIg_set_state_off (Edit_form, CHAR_LINE_STYLE_BTN);
  FIg_disable (Edit_form, CHAR_LINE_STYLE_BTN);
  FIg_set_state_off (Edit_form, CHAR_LINE_WEIGHT_BTN);
  FIg_disable (Edit_form, CHAR_LINE_WEIGHT_BTN);
  FIg_set_state_off (Edit_form, CHAR_TEXT_FONT_BTN);
  FIg_disable (Edit_form, CHAR_TEXT_FONT_BTN);
  FIg_set_state_off (Edit_form, CHAR_LINE_DEPTH_TOG);
  FIg_disable (Edit_form, CHAR_LINE_DEPTH_TOG);

  FIg_set_state_off (Edit_form, DISPLAYED_TOG);
  FIg_disable (Edit_form, DISPLAYED_TOG);
  FIg_set_state_off (Edit_form, ENABLED_TOG);
  FIg_disable (Edit_form, ENABLED_TOG);
  FIg_set_state_off (Edit_form, HILITE_TOG);
  FIg_disable (Edit_form, HILITE_TOG);

  for (x = 12; x < 21; x++)
    FIg_set_state_off (Edit_form, x); /* Edit/Don't Edit toggles */

  for (x = 12; x < 16; x++)
    FIg_set_state_off (Font_options_form, x); /* Font option cklist items */

  FIf_display (Edit_form);

  UMSGetByNum (t_str, FB_P_FILLEDTFRMS, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  FIf_set_location (FG2_color_form, 0, 386);
  FIf_set_location (FG_color_form, 200, 386);
  FIf_set_location (Font_form, 400, 212);
  FIf_set_location (Font_options_form, 400, 107);
  FIf_set_location (Line_style_form, 762, 290);
  FIf_set_location (Line_weight_form, 0, 100);

  /************************************************************/
  /* */
  /* Now setup all default values and store them in the forms */
  /* */
  /************************************************************/

  temp_dpb.off_color = dpb.off_color;
  temp_dpb.on_color = dpb.on_color;
  temp_dpb.line_style = dpb.line_style;
  temp_dpb.line_weight = dpb.line_weight;
  temp_dpb.bodysize = dpb.bodysize;
  strcpy (temp_dpb.font_name, dpb.font_name);

  temp_dpb.line_depth = dpb.line_depth;
  temp_dpb.text_style = dpb.text_style;
  temp_dpb.text_justification = dpb.text_justification;

  if (Two_vscreens_flag == 0)
  {
    for (x = 27; x <= 40; x++)
    {
      FIg_set_off_color (FG_color_form, x, (x - 27));
      FIg_set_off_color (FG2_color_form, x, (x - 27));

      FIg_set_on_color (FG_color_form, x, (x - 27));
      FIg_set_on_color (FG2_color_form, x, (x - 27));
    }
  }
  else
  {
    for (x = 35; x <= 40; x++)
    {
      FIg_erase (FG_color_form, x);
      FIg_erase (FG2_color_form, x);
    }

    FIg_set_off_color (FG_color_form, 27, FI_BLACK);
    FIg_set_off_color (FG2_color_form, 27, FI_BLACK);

    FIg_set_on_color (FG_color_form, 27, FI_BLACK);
    FIg_set_on_color (FG2_color_form, 27, FI_BLACK);

    FIg_set_off_color (FG_color_form, 28, FI_WHITE);
    FIg_set_off_color (FG2_color_form, 28, FI_WHITE);

    FIg_set_on_color (FG_color_form, 28, FI_WHITE);
    FIg_set_on_color (FG2_color_form, 28, FI_WHITE);

    FIg_set_off_color (FG_color_form, 29, FI_RED);
    FIg_set_off_color (FG2_color_form, 29, FI_RED);

    FIg_set_on_color (FG_color_form, 29, FI_RED);
    FIg_set_on_color (FG2_color_form, 29, FI_RED);

    FIg_set_off_color (FG_color_form, 30, FI_YELLOW);
    FIg_set_off_color (FG2_color_form, 30, FI_YELLOW);

    FIg_set_on_color (FG_color_form, 30, FI_YELLOW);
    FIg_set_on_color (FG2_color_form, 30, FI_YELLOW);

    FIg_set_off_color (FG_color_form, 31, FI_BLUE);
    FIg_set_off_color (FG2_color_form, 31, FI_BLUE);

    FIg_set_on_color (FG_color_form, 31, FI_BLUE);
    FIg_set_on_color (FG2_color_form, 31, FI_BLUE);

    FIg_set_off_color (FG_color_form, 32, FI_LT_GREY);
    FIg_set_off_color (FG2_color_form, 32, FI_LT_GREY);

    FIg_set_on_color (FG_color_form, 32, FI_LT_GREY);
    FIg_set_on_color (FG2_color_form, 32, FI_LT_GREY);

    FIg_set_off_color (FG_color_form, 33, FI_DK_GREY);
    FIg_set_off_color (FG2_color_form, 33, FI_DK_GREY);

    FIg_set_on_color (FG_color_form, 33, FI_DK_GREY);
    FIg_set_on_color (FG2_color_form, 33, FI_DK_GREY);

    FIg_set_off_color (FG_color_form, 34, FI_GREEN);
    FIg_set_off_color (FG2_color_form, 34, FI_GREEN);

    FIg_set_on_color (FG_color_form, 34, FI_GREEN);
    FIg_set_on_color (FG2_color_form, 34, FI_GREEN);
  }

  if (Two_vscreens_flag == 0)
  {
    FIg_set_state_on (FG_color_form, 27 + temp_dpb.off_color);

    FIg_set_state_on (FG2_color_form, 27 + temp_dpb.on_color);
  }
  else
  {
    if (temp_dpb.off_color == FI_BLACK)
      FIg_set_state_on (FG_color_form, 27);

    if ((temp_dpb.off_color == FI_OFF_WHITE) ||
        (temp_dpb.off_color == FI_WHITE))
      FIg_set_state_on (FG_color_form, 28);

    if ((temp_dpb.off_color == FI_RED) ||
        (temp_dpb.off_color == FI_DK_RED))
      FIg_set_state_on (FG_color_form, 29);

    if ((temp_dpb.off_color == FI_YELLOW) ||
        (temp_dpb.off_color == FI_LT_YELLOW))
      FIg_set_state_on (FG_color_form, 30);

    if ((temp_dpb.off_color == FI_BLUE) ||
        (temp_dpb.off_color == FI_DK_BLUE))
      FIg_set_state_on (FG_color_form, 31);

    if (temp_dpb.off_color == FI_LT_GREY)
      FIg_set_state_on (FG_color_form, 32);

    if ((temp_dpb.off_color == FI_MED_GREY) ||
        (temp_dpb.off_color == FI_DK_GREY))
      FIg_set_state_on (FG_color_form, 33);

    if ((temp_dpb.off_color == FI_GREEN) ||
        (temp_dpb.off_color == FI_DK_GREEN))
      FIg_set_state_on (FG_color_form, 34);

    if (temp_dpb.on_color == FI_BLACK)
      FIg_set_state_on (FG2_color_form, 27);

    if ((temp_dpb.on_color == FI_OFF_WHITE) ||
        (temp_dpb.on_color == FI_WHITE))
      FIg_set_state_on (FG2_color_form, 28);

    if ((temp_dpb.on_color == FI_RED) ||
        (temp_dpb.on_color == FI_DK_RED))
      FIg_set_state_on (FG2_color_form, 29);

    if ((temp_dpb.on_color == FI_YELLOW) ||
        (temp_dpb.on_color == FI_LT_YELLOW))
      FIg_set_state_on (FG2_color_form, 30);

    if ((temp_dpb.on_color == FI_BLUE) ||
        (temp_dpb.on_color == FI_DK_BLUE))
      FIg_set_state_on (FG2_color_form, 31);

    if (temp_dpb.on_color == FI_LT_GREY)
      FIg_set_state_on (FG2_color_form, 32);

    if ((temp_dpb.on_color == FI_MED_GREY) ||
        (temp_dpb.on_color == FI_DK_GREY))
      FIg_set_state_on (FG2_color_form, 33);

    if ((temp_dpb.on_color == FI_GREEN) ||
        (temp_dpb.on_color == FI_DK_GREEN))
      FIg_set_state_on (FG2_color_form, 34);
  }

  if (temp_dpb.line_depth == FI_3D_LINE)
    FIg_set_state_on (Edit_form, CHAR_LINE_DEPTH_TOG);
  else
    FIg_set_state_off (Edit_form, CHAR_LINE_DEPTH_TOG);

  for (x = 0; x < 8; x++)
    FIg_set_state_off (Line_style_form, 30 + x);

  for (x = 0; x < 8; x++)
    if (line_style[x] == temp_dpb.line_style)
      FIg_set_state_on (Line_style_form, 30 + x);

  FIg_set_state_off (Font_form, NORMAL_CK);
  FIg_set_state_off (Font_form, EMBOSSED_CK);
  FIg_set_state_off (Font_form, INCISED_CK);

  if (temp_dpb.text_style == FI_NORMAL_TEXT)
    FIg_set_state_on (Font_form, NORMAL_CK);

  if (temp_dpb.text_style == FI_EMBOSSED)
    FIg_set_state_on (Font_form, EMBOSSED_CK);

  if (temp_dpb.text_style == FI_INCISED)
    FIg_set_state_on (Font_form, INCISED_CK);

  FIg_set_state_off (Font_form, LEFT_JUST_CK);
  FIg_set_state_off (Font_form, CENTER_JUST_CK);
  FIg_set_state_off (Font_form, RIGHT_JUST_CK);

  if (temp_dpb.text_justification == FI_LEFT_JUSTIFIED)
    FIg_set_state_on (Font_form, LEFT_JUST_CK);

  if (temp_dpb.text_justification == FI_CENTER_JUSTIFIED)
    FIg_set_state_on (Font_form, CENTER_JUST_CK);

  if (temp_dpb.text_justification == FI_RIGHT_JUSTIFIED)
    FIg_set_state_on (Font_form, RIGHT_JUST_CK);

  /*
sort_font_names();
*/

  FIfld_set_text (Font_form, TYPEFACE_FLD, 0, 0, temp_dpb.font_name, 0);

  sprintf (t_str, "%d", (int)temp_dpb.bodysize);

  FIfld_set_text (Font_form, SIZE_FLD, 0, 0, t_str, 0);

  FIg_set_font (Font_form, SAMPLE_TEXT, temp_dpb.font_name,
      temp_dpb.bodysize);
  FIg_set_font (Font_form, SAMPLE_HEADER, temp_dpb.font_name,
      temp_dpb.bodysize);

  /*************************************************************/
  /* */
  /* Now set up the line weight form with current dpb values */
  /* */
  /*************************************************************/

  FIg_set_value (Line_weight_form, LINE_WEIGHT_SLIDER,
      (double)temp_dpb.line_weight);

  FIg_set_line_weight (Line_weight_form, LINE_WEIGHT_LINE,
      temp_dpb.line_weight);

  /*************************************************************/
  /* */
  /* Now enable any dpb buttons that are needed by the gadget */
  /* */
  /*************************************************************/

  FIg_set_off_color (Edit_form, CHAR_FOREGROUND_CLR_BTN,
      temp_dpb.off_color);
  FIg_set_on_color (Edit_form, CHAR_FOREGROUND_CLR_BTN,
      temp_dpb.off_color);

  FIg_set_off_color (Edit_form, CHAR_FOREGROUND2_CLR_BTN,
      temp_dpb.on_color);
  FIg_set_on_color (Edit_form, CHAR_FOREGROUND2_CLR_BTN,
      temp_dpb.on_color);
}

/*************************************************************************/
/* */
/* execute_fence_edit() */
/* */
/* This function is called by the executive command handler routine. */
/* It changes values contained in the message windows and sets the */
/* builder mode to on for the work_form. As a result the gadgets will */
/* no longer change their state when poked. They will simply call their */
/* gadget notification routine. */
/* */
/*************************************************************************/

void execute_fence_edit(void)
{
  char t_str[256];
  int status;
  int not_finished;
  int xpos, ypos;
  int attr;
  Window window;
  int xlo, ylo, xhi, yhi;
  int gadget_array[1000];
  int x;
  int fgcolor, bgcolor;
  int (*my_translate_color)();
  int save_boundary_mode;

  save_boundary_mode = 0;

  FIf_get_color (work_form, &bgcolor);
  FI_get_env (FI_TRANSLATE_COLOR, &my_translate_color);
  bgcolor = (*my_translate_color)( 0, bgcolor );
  fgcolor = (*my_translate_color)( 0, FI_WHITE );

  if (work_form == NULL)
  {
    kill_fence_edit();
  }
  else
  {
    UMSGetByNum (t_str, FB_I_FCEEDT, 0);
    FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);

    FIf_set_builder_mode_on ((struct FIform_obj *)work_form);

    not_finished = 1;
    FIf_get_window (work_form, &window);

    while (not_finished)
    {
      UMSGetByNum (t_str, FB_P_POKANCPNT, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

      status = Get_first_point (window, &xpos, &ypos, 0, 0, 0, 0);

      if (status == 2)
      {
        UMSGetByNum (t_str, FB_P_SELFCEAREA, 0);
        FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

        if (dpb.expansion4 == 1)
        {
          dpb.expansion4 = 0;
          save_boundary_mode = 1;
        }

        status = Get_second_point (window, xpos, ypos,
            &xlo, &ylo, &xhi, &yhi, 0, -1);
        dpb.expansion4 = save_boundary_mode;

        if (status == 2)
        {
          FIf_gadgets_inside_area (work_form, xlo, ylo, xhi, yhi,
              &Total_gadgets, gadget_array);

          if (Total_gadgets > 0)
          {
            for (x = 0; x < Total_gadgets; x++)
            {
              seq_list[x].gadget = gadget_array[x];

              FIg_get_attr (work_form, gadget_array[x], &attr);

              if (attr & FI_NOT_DISPLAYED)
                seq_list[x].display_flag = 0;
              else
                seq_list[x].display_flag = 1;

              if (attr & FI_HILITED)
                seq_list[x].hilite_flag = 1;
              else
                seq_list[x].hilite_flag = 0;
            }

            for (x = 0; x < Total_gadgets; x++)
            {
              FIg_display (work_form, gadget_array[x]);
              FIg_hilite (work_form, gadget_array[x]);
            }

            XSetForeground (display, xfb_GC, fgcolor);
            XDrawLine (display, window, xfb_GC, xlo, ylo, xlo, yhi);
            XDrawLine (display, window, xfb_GC, xlo, yhi, xhi, yhi);
            XDrawLine (display, window, xfb_GC, xhi, yhi, xhi, ylo);
            XDrawLine (display, window, xfb_GC, xhi, ylo, xlo, ylo);
            XFlush (display);

            UMSGetByNum (t_str, FB_P_ACCREJFCE, 0);
            FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

            status = Poke_plain_point (window, &xpos, &ypos);

            if (status == 2)
            {
              /***************************************/
              /* */
              /* User has accepted fenced area, so */
              /* call a common routine that will be */
              /* used by both fence edit and group */
              /* edit. */
              /* */
              /* It uses Total gadgets and seq_list[]*/
              /* to determine which gadgets are */
              /* being edited. */
              /* */
              /***************************************/

              FIfld_set_text (Message_form, 33, 0, 0,
                  "Generating edit forms", 0);
              Display_edit_forms();
              XSetForeground (display, xfb_GC, bgcolor);
              XDrawLine (display, window, xfb_GC, xlo, ylo, xlo, yhi);
              XDrawLine (display, window, xfb_GC, xlo, yhi, xhi, yhi);
              XDrawLine (display, window, xfb_GC, xhi, yhi, xhi, ylo);
              XDrawLine (display, window, xfb_GC, xhi, ylo, xlo, ylo);
              XFlush (display);
              return;
            }
            else
            {
              for (x = 0; x < Total_gadgets; x++)
              {
                if (seq_list[x].hilite_flag == 0)
                {
                  FIg_unhilite (work_form, gadget_array[x]);
                }

                if (seq_list[x].display_flag == 0)
                {
                  FIg_erase (work_form, gadget_array[x]);
                }
              }
              XSetForeground (display, xfb_GC, bgcolor);
              XDrawLine (display, window, xfb_GC, xlo, ylo, xlo, yhi);
              XDrawLine (display, window, xfb_GC, xlo, yhi, xhi, yhi);
              XDrawLine (display, window, xfb_GC, xhi, yhi, xhi, ylo);
              XDrawLine (display, window, xfb_GC, xhi, ylo, xlo, ylo);
              XFlush (display);
            }
          }
        }
        else
        {
          /* Do nothing, loop back around */
        }
      }
      else
      {
        kill_fence_edit();
        return;
      }
    }
  }

}
