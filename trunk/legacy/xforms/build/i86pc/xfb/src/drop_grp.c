/***********************************

		drop_grp.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
	05-06-92	sml		changed local vars types for ANSI
*/

/*************************************/
/* */
/* This file contains functions for the "drop from group" command. */
/* */
/* Programmer: Mack Draper */
/* Date: Apr. 6, 1989 */
/* */
/*************************************/

#include <stdio.h>

#include "FI.h"
#include "FIdyn.h"
#include "NFBpriv.h"
#include "UMS.h"
#include "FB.h"

#include "XFIproto_pub.h"
#include "XFIproto_pri.h"
#include "XFBproto_pri.h"

#define LABEL_FLD 13
#define SELECT_TOG 14
#define PASS_ON_TOG 15

static void Drop_gadgets_from_group();

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

extern int Active_group;
extern int Pass_on_flag;

extern Form Group_form;

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern int Total_gadgets;

extern struct seq_struct seq_list[1001];

extern Form work_form;
extern Form Message_form;
extern int command_is_active;
extern char current_command_string[80];

/*************************************************************************/
/* */
/* kill_drop_from_group() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to DROP_GRP indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_drop_from_group(void)
{
  int x;
  char t_str[256];

  if (command_is_active == DROP_FROM_GROUP)
  {
     command_is_active = 0;
     strcpy (current_command_string, "None");

     FIfld_set_text (Message_form, 11, 0, 0, "", 0);
     FIfld_set_text (Message_form, 44, 0, 0, "", 0);
     UMSGetByNum (t_str, FB_P_SELCOM, 0);
     FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

     if (work_form != NULL) /* Form already displayed */
     {
        FIf_set_builder_mode_off ((struct FIform_obj *)work_form);
     }


     if (Total_gadgets > 0)
     {
        for (x = 0; x < Total_gadgets; x++)
        {
           if (seq_list[x].hilite_flag == 0)
              FIg_unhilite (work_form, seq_list[x].gadget);
           else
              FIg_hilite (work_form, seq_list[x].gadget);

           if (seq_list[x].display_flag == 0)
              FIg_erase (work_form, seq_list[x].gadget);
           else
              FIg_display (work_form, seq_list[x].gadget);
        }
        Redisplay (work_form);
     }

     if (Group_form != NULL)
        FIf_erase (Group_form);
  }
}

/*-------------------------------------------------------------------*/

static void Drop_gadgets_from_group(void)
{
  Window window;	/* change from int to Window for ANSI */
  int x, not_finished, mode;
  int grp_gadget, xsize, ysize, display_flag, hilite_flag, accept_x, accept_y;
  int current_group, status;
  int type;
  int gadget_index = 0;
  char t_str[256];

  not_finished = 1;
  FIf_get_window (work_form, &window);

  while (not_finished)
  {
    mode = 0; /* make operator enter data point */

    UMSGetByNum (t_str, FB_P_SELGDTDRP, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    status = Select_gadget (&grp_gadget, &xsize, &ysize, &display_flag,
        &hilite_flag, &accept_x, &accept_y, mode);

    FIfld_set_text (Message_form, 22, 0, 0, "", 0);
    FIfld_set_text (Message_form, 44, 0, 0, "", 0);

    if (status == 2) /* Success */
    {
      FIg_get_group_label (work_form, grp_gadget, &current_group);

      if (current_group == Active_group)
      {
        /*********************************************************/
        /* */
        /* That gadget belongs to the Active group, so remove it */
        /* from the active group. */
        /* */
        /*********************************************************/

        FIg_add_to_group (work_form, grp_gadget, 0);

        FIg_get_type (work_form, grp_gadget, &type);

        if (type == FI_BEZEL)
          _FI_bez_pop_to_bottom ((struct FIform_obj *)work_form, grp_gadget);

        for (x = 0; x < Total_gadgets; x++)
          if (seq_list[x].gadget == grp_gadget)
          {
            gadget_index = x;
            break;
          }

        if (seq_list[gadget_index].hilite_flag == 0)
          FIg_unhilite (work_form, seq_list[gadget_index].gadget);

        if (seq_list[gadget_index].display_flag == 0)
          FIg_erase (work_form, seq_list[gadget_index].gadget);
      }
      else
      {
        /*****************************************************/
        /* */
        /* The gadget does not belong to the Active group */
        /* so inform the operator and allow him to make */
        /* another selection. */
        /* */
        /*****************************************************/

        UMSGetByNum (t_str, FB_E_GDTMEMGRP, 0);
        FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);

        if (hilite_flag == 0)
          FIg_unhilite (work_form, grp_gadget);

        if (display_flag == 0)
          FIg_erase (work_form, grp_gadget);
      }
    }
    else
      not_finished = 0;
  }

  if (Total_gadgets > 0)
  {
    for (x = 0; x < Total_gadgets; x++)
    {
      FIg_unhilite (work_form, seq_list[x].gadget);

      if (seq_list[x].display_flag == 0)
        FIg_erase (work_form, seq_list[x].gadget);
      else
        FIg_display (work_form, seq_list[x].gadget);
    }
    Redisplay (work_form);
  }

  execute_drop_from_group();
}

/*--------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* execute_drop_from_group() */
/* */
/* This function is called by the executive command handler routine. */
/* It changes values contained in the message windows and sets the */
/* builder mode to on for the work_form. As a result the gadgets will */
/* no longer change their state when poked. They will simply call their */
/* gadget notification routine. */
/* */
/*************************************************************************/

void execute_drop_from_group(void)
{
  char t_str[256];
  int status;
  int grp_gadget;
  int not_finished;
  int xsize, ysize;
  Window window;		/* change from int to Window for ANSI */
  int display_flag, hilite_flag;
  int accept_x, accept_y, mode;


  if (work_form == NULL)
  {
    command_is_active = 0;
    strcpy (current_command_string, "None");
  }
  else
  {
    UMSGetByNum (t_str, FB_I_DRPFRMGRP, 0);
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

      FIfld_set_text (Message_form, 44, 0, 0, "", 0);
      FIfld_set_text (Message_form, 22, 0, 0, "", 0);

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
          {
            FIg_unhilite (work_form, grp_gadget);
          }

          if (display_flag == 0)
            FIg_erase (work_form, grp_gadget);
        }
        else
        {
          /*****************************************************/
          /* */
          /* The gadget belongs to a group, so first display */
          /* all gadgets that belong to the group in highlight */
          /* mode. Then call a routine which will allow him */
          /* to remove gadgets from the group. */
          /* */
          /*****************************************************/

          FIgrp_get_pass (work_form, Active_group, &Pass_on_flag);

          FIgrp_set_pass_on (work_form, Active_group);

          FIg_hilite (work_form, Active_group);

          FIg_display (work_form, Active_group);

          if (Pass_on_flag == 0)
            FIgrp_set_pass_off (work_form, Active_group);

          Drop_gadgets_from_group();
          return;
        }
      }
      else
        not_finished = 0;
    }

    kill_drop_from_group();
  }
}
