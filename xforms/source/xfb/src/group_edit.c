/***********************************

		group_edit.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
	05-07-92	sml		changed var type for ANSI
*/

/*************************************/
/* */
/* This file contains functions for the "group edit" command. */
/* */
/* Programmer: Mack Draper */
/* Date: May 1, 1989 */
/* */
/*************************************/

#include <stdio.h>

#include "FI.h"
#include "FIdyn.h"
#include "NFBpriv.h"
#include "UMS.h"
#include "FB.h"

#include "XFIproto_pub.h"
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

extern Form Edit_form;
extern Form Font_options_form;

extern int Edit_font_typeface_flag;
extern int Edit_font_size_flag;
extern int Edit_font_style_flag;
extern int Edit_font_justification_flag;

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern Form work_form;
extern int command_is_active;
extern char current_command_string[80];

extern Form Font_form;
extern Form Line_weight_form;
extern Form Line_style_form;
extern Form FG_color_form;
extern Form FG2_color_form;
extern Form Message_form;

extern int Total_gadgets;
extern struct seq_struct seq_list[1001];

extern int Active_group;
extern int Pass_on_flag;

/*************************************************************************/
/* */
/* kill_group_edit() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to GROUP_EDIT indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_group_edit(void)
{
  int x;
  char t_str[256];

  if (command_is_active == GROUP_EDIT)
  {
     command_is_active = 0;
     strcpy (current_command_string, "None");

     FIf_erase (Font_form);
     FIf_erase (Line_weight_form);
     FIf_erase (Line_style_form);
     FIf_erase (FG_color_form);
     FIf_erase (FG2_color_form);

     if (Edit_form != NULL)
     {
        FIf_erase (Edit_form);
     }

     if (Total_gadgets > 0)
     {
        for (x = 0; x < Total_gadgets; x++)
        {
           if (seq_list[x].hilite_flag == 0)
              FIg_unhilite (work_form, seq_list[x].gadget);
           if (seq_list[x].display_flag == 0)
              FIg_erase (work_form, seq_list[x].gadget);
        }
        Redisplay (work_form);
     }

     FIfld_set_text (Message_form, 11, 0, 0, "", 0);
     FIfld_set_text (Message_form, 22, 0, 0, "", 0);
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
}

/*************************************************************************/
/* */
/* execute_group_edit() */
/* */
/* This function is called by the executive command handler routine. */
/* It changes values contained in the message windows and sets the */
/* builder mode to on for the work_form. As a result the gadgets will */
/* no longer change their state when poked. They will simply call their */
/* gadget notification routine. */
/* */
/*************************************************************************/

void execute_group_edit(void)
{
  char t_str[256];
  int status;
  int not_finished;
  int xsize, ysize, xpos, ypos;
  Window window;		/* change from int to Window for ANSI */
  int display_flag, hilite_flag;
  int x, grp_gadget;
  int temp_group, Temp_total_gadgets;
  int mode, accept_x, accept_y;

  if (work_form == NULL)
  {
    kill_group_edit();
  }
  else
  {
    UMSGetByNum (t_str, FB_I_GRPEDT, 0);
    FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);

    Determine_current_gadgets();

    FIf_set_builder_mode_on ((struct FIform_obj *)work_form);

    not_finished = 1;
    FIf_get_window (work_form, &window);

    while (not_finished)
    {
      mode = 0; /* make operator enter data point */

      UMSGetByNum (t_str, FB_P_SELMEMGRP, 0);
      FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

      status = Select_gadget (&grp_gadget, &xsize, &ysize, &display_flag,
          &hilite_flag, &accept_x, &accept_y, mode);

      if (status == 2) /* Success */
      {
        FIg_get_group_label (work_form, grp_gadget, &Active_group);

        if (Active_group == 0)
        {
          /*********************************************************/
          /* */
          /* That gadget does not belong to a group, so allow the */
          /* operator to choose another gadget. */
          /* */
          /*********************************************************/

          UMSGetByNum (t_str, FB_E_NOTMEMGRP, 0);
          FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);

          if (hilite_flag == 0)
            FIg_unhilite (work_form, grp_gadget);

          if (display_flag == 0)
            FIg_erase (work_form, grp_gadget);
        }
        else
        {
          FIfld_set_text (Message_form, 22, 0, 0, "", 0);

          /*********************************************/
          /* */
          /* Re-sort the gadgets in the seq_list array */
          /* so that the gadgets from 0..n are all */
          /* members of the selected group. */
          /* */
          /*********************************************/

          Temp_total_gadgets = 0;

          for (x = 0; x < Total_gadgets; x++)
          {
            FIg_get_group_label (work_form, seq_list[x].gadget,
                &temp_group);

            if (temp_group == Active_group)
            {
              if (Temp_total_gadgets != x)
              {
                seq_list[Temp_total_gadgets].gadget =
                    seq_list[x].gadget;

                seq_list[Temp_total_gadgets].hilite_flag =
                    seq_list[x].hilite_flag;

                seq_list[Temp_total_gadgets].display_flag =
                    seq_list[x].display_flag;
              }
              Temp_total_gadgets++;
            }
          }

          Total_gadgets = Temp_total_gadgets;

          /*****************************************************/
          /* */
          /* The gadget belongs to a group, so first display */
          /* all gadgets that belong to the group in highlight */
          /* mode. Then allow the user to indicate whether */
          /* this is the group that he wanted to edit. */
          /* */
          /*****************************************************/

          FIgrp_get_pass (work_form, Active_group, &Pass_on_flag);

          FIgrp_set_pass_on (work_form, Active_group);

          FIg_hilite (work_form, Active_group);

          FIg_display (work_form, Active_group);

          if (Pass_on_flag == 0)
            FIgrp_set_pass_off (work_form, Active_group);

          UMSGetByNum (t_str, FB_P_ACCREJGRP, 0);
          FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

          status = Poke_plain_point (window, &xpos, &ypos);

          if (status == 2) /* success */
          {
            /***************************************/
            /* */
            /* User has accepted the group, so */
            /* call a common routine that will be */
            /* used by both fence edit and group */
            /* edit. */
            /* */
            /* It uses Total gadgets and seq_list[]*/
            /* to determine which gadgets are */
            /* being edited. */
            /* */
            /***************************************/

            Display_edit_forms();
            return;
          }
          else
          {
            for (x = 0; x < Total_gadgets; x++)
            {
              if (seq_list[x].hilite_flag == 0)
                FIg_unhilite (work_form, seq_list[x].gadget);
              if (seq_list[x].display_flag == 0)
                FIg_erase (work_form, seq_list[x].gadget);
            }
            Redisplay (work_form);

            Determine_current_gadgets();
          }
        }
      }
      else
        not_finished = 0;
    }
  }

  Total_gadgets = 0;
  kill_group_edit();
}
