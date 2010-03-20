/***********************************

		create_grp.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
   05-07-92    sml     changed local vars types for ANSI
*/

/*************************************/
/* */
/* This file contains functions for the "create group" command. */
/* */
/* Programmer: Mack Draper */
/* Date: Apr. 5, 1989 */
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

#define LABEL_FLD 13
#define SELECT_TOG 14
#define PASS_ON_TOG 15

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

int Active_group;
int Single_select_flag;
int Pass_on_flag;

Form Group_form = NULL;

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
extern char execute_dir[200];

extern char language[80];
extern Display *display;

static void Add_gadgets_to_group();
static void Display_group_form();

/*************************************************************************/
/* */
/* kill_create_group() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to CREATE_GRP indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_create_group(void)
{
  int x;
  char t_str[256];

  if (command_is_active == CREATE_GROUP)
  {
     command_is_active = 0;
     strcpy (current_command_string, "None");

     FIfld_set_text (Message_form, 11, 0, 0, "", 0);
     FIfld_set_text (Message_form, 44, 0, 0, "", 0);

     UMSGetByNum (t_str, FB_P_SELCOM, 0);
     FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

     if (work_form )
        FIf_set_builder_mode_off ((struct FIform_obj *)work_form);

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

     if (Total_gadgets > 0)
     {
        Redisplay (work_form);
     }

     if (Group_form != NULL)
        FIf_erase (Group_form);
  }
}

/*-------------------------------------------------------------------*/

static void Add_gadgets_to_group(void)
{
  int x, not_finished, mode;
  int grp_gadget, xsize, ysize, display_flag, hilite_flag, accept_x, accept_y;
  int current_group, xpos, ypos, status;
  int type;
  char t_str[256];

  Window window;

  not_finished = 1;
  FIf_get_window (work_form, &window);

  while (not_finished)
  {
    mode = 0; /* make operator enter data point */

    UMSGetByNum (t_str, FB_P_SELADDGRP, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    status = Select_gadget (&grp_gadget, &xsize, &ysize, &display_flag,
        &hilite_flag, &accept_x, &accept_y, mode);

    if (status == 2) /* Success */
    {
      status = FIg_get_group_label (work_form, grp_gadget, &current_group);

      if (current_group == 0)
      {
        /*********************************************************/
        /* */
        /* That gadget does not belong to a group, so add it to */
        /* the active group. */
        /* */
        /*********************************************************/

        FIg_add_to_group (work_form, grp_gadget, Active_group);

        FIg_get_type (work_form, grp_gadget, &type);

        /*
if (type == FI_BEZEL)
_FI_bez_pop_to_bottom (work_form, grp_gadget);
*/
      }
      else
      {
        /*****************************************************/
        /* */
        /* The gadget belongs to a group, so prompt the */
        /* operator to insure that he wants to transfer it */
        /* from the group it is in now to the new group. */
        /* */
        /*****************************************************/

        UMSGetByNum (t_str, FB_E_GDTMEMGRP, 0);
        FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);
        UMSGetByNum (t_str, FB_P_TRANSREJ, 0);
        FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

        status = Poke_plain_point (window, &xpos, &ypos);

        FIfld_set_text (Message_form, 22, 0, 0, "", 0);

        if (status == 1) /* Do not transfer gadget to Active_group */
        {
          if (hilite_flag == 0)
            FIg_unhilite (work_form, grp_gadget);

          if (display_flag == 0)
            FIg_erase (work_form, grp_gadget);
        }
        else
        {
          FIg_add_to_group (work_form, grp_gadget, Active_group);

          FIg_get_type (work_form, grp_gadget, &type);

          /*
if (type == FI_BEZEL)
_FI_bez_pop_to_bottom (work_form, grp_gadget);
*/
        }
      }
    }
    else
      not_finished = 0;
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

  execute_create_group();
}

/*--------------------------------------------------------------------*/

void Determine_current_gadgets(void)
{
  int form_xsize, form_ysize;
  int x, type;
  int attr;
  int num_gadgets, gadget_array[1000];

  Total_gadgets = 0;

  FIf_get_size (work_form, &form_xsize, &form_ysize);

  FIf_gadgets_inside_area (work_form, 0, 0, form_xsize, form_ysize,
      &num_gadgets, gadget_array);

  for (x = 0; x < num_gadgets; x++)
  {
    FIg_get_type (work_form, gadget_array[x], &type);

    if (type != FI_GROUP)
    {
      seq_list[Total_gadgets].gadget = gadget_array[x];

      FIg_get_attr (work_form, gadget_array[x], &attr);

      if (attr & FI_NOT_DISPLAYED)
        seq_list[Total_gadgets].display_flag = 0;
      else
        seq_list[Total_gadgets].display_flag = 1;

      if (attr & FI_HILITED)
        seq_list[Total_gadgets].hilite_flag = 1;
      else
        seq_list[Total_gadgets].hilite_flag = 0;

      Total_gadgets++;
    }
  }
}

/*--------------------------------------------------------------------*/

/* ARGSUSED */
void fi_group_form (int form_label,
                   int gadget_label,
                   double value,
                   Form form_ptr)
{
  int x, i, label_is_ok;
  char t_str[256];
  int group;
  int dummy_int;
  int status;

  FIg_erase (Group_form, 10);

  switch (gadget_label)
  {
  case SELECT_TOG:

    if ((int)value == 0)
    {
      FIgrp_set_single_select_on (work_form, Active_group);
      Single_select_flag = 1;
    }
    else
    {
      FIgrp_set_single_select_off (work_form, Active_group);
      Single_select_flag = 0;
    }
    break;

  case PASS_ON_TOG:

    if ((int)value == 0)
    {
      FIgrp_set_pass_on (work_form, Active_group);
      Pass_on_flag = 1;
    }
    else
    {
      status = FIgrp_set_pass_off (work_form, Active_group);
      Pass_on_flag = 0;
    }
    break;

  case LABEL_FLD:

    FIfld_get_text (Group_form, LABEL_FLD, 0, 0, 255, 
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
      print_error (Group_form, 10, t_str);

      sprintf (t_str, "%d", Active_group);
      FIfld_set_text (Group_form, LABEL_FLD, 0, 0, t_str, 0);
    }
    else if (i > 999)
    {
      UMSGetByNum (t_str, FB_E_LABLT1000, 0);
      print_error (Group_form, 10, t_str);

      sprintf (t_str, "%d", Active_group);
      FIfld_set_text (Group_form, LABEL_FLD, 0, 0, t_str, 0);
    }
    else if (i < 11)
    {
      UMSGetByNum (t_str, FB_E_LABGT10, 0);
      print_error (Group_form, 10, t_str);

      sprintf (t_str, "%d", Active_group);
      FIfld_set_text (Group_form, LABEL_FLD, 0, 0, t_str, 0);
    }
    else
    {
      FIg_new (work_form, FI_GROUP, i);

      for (x = 0; x < Total_gadgets; x++)
      {
        FIg_get_group_label (work_form, seq_list[x].gadget, &group);

        if (group == Active_group)
          FIg_add_to_group (work_form, seq_list[x].gadget, i);
      }

      if (Single_select_flag == 1)
        FIgrp_set_single_select_on (work_form, i);
      else
        FIgrp_set_single_select_off (work_form, i);

      if (Pass_on_flag == 1)
        FIgrp_set_pass_on (work_form, i);
      else
        FIgrp_set_pass_off (work_form, i);

      FIg_delete (work_form, Active_group);
      Active_group = i;
    }
    break;

  case FI_ACCEPT:

    FIf_erase (Group_form);
    FIg_set_state_off (Group_form, FI_ACCEPT);

    Refresh_work_form();

    Add_gadgets_to_group();
    break;
  }

  return;
}

/*--------------------------------------------------------------------*/

static void Display_group_form(void)
{
  char t_str[256];
  int status;

  if (Group_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBCrEdGrp");
    status = FIf_new (532, t_str, (int (*)())fi_group_form, &Group_form);

    if (status != 0)
      Report_fatal_form_error (status, t_str);
  }

  FIg_erase (Group_form, 10); /* Error field */

  sprintf (t_str, "%d", Active_group);
  FIfld_set_text (Group_form, LABEL_FLD, 0, 0, t_str, 0);

  if (Single_select_flag == 1)
    FIg_set_state_off (Group_form, SELECT_TOG);
  else
    FIg_set_state_on (Group_form, SELECT_TOG);

  if (Pass_on_flag == 1)
    FIg_set_state_off (Group_form, PASS_ON_TOG);
  else
    FIg_set_state_on (Group_form, PASS_ON_TOG);

  FIf_display (Group_form);

  UMSGetByNum (t_str, FB_P_FILLGRP, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}


/*************************************************************************/
/* */
/* execute_create_group() */
/* */
/* This function is called by the executive command handler routine. */
/* It changes values contained in the message windows and sets the */
/* builder mode to on for the work_form. As a result the gadgets will */
/* no longer change their state when poked. They will simply call their */
/* gadget notification routine. */
/* */
/*************************************************************************/

void execute_create_group(void)
{
  char t_str[256];
  int status;
  int grp_gadget;
  int not_finished;
  int xsize, ysize, xpos, ypos;
  int display_flag, hilite_flag;
  int accept_x, accept_y, mode;
  Window window;

  if (work_form == NULL)
  {
    command_is_active = 0;
    strcpy (current_command_string, "None");
  }
  else
  {
    UMSGetByNum (t_str, FB_I_EDTGRP, 0);
    FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
    FIfld_set_text (Message_form, 33, 0, 0, "", 0);

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
        status = FIg_get_group_label (work_form, grp_gadget, &Active_group);

        if (Active_group == 0)
        {
          /*********************************************************/
          /* */
          /* That gadget does not belong to a group, so allow the */
          /* operator to create a new group to hold it. */
          /* */
          /*********************************************************/

          UMSGetByNum (t_str, FB_E_NOTMEMGRP, 0);
          FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);
          UMSGetByNum (t_str, FB_P_CREATREJ, 0);
          FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

          status = Poke_plain_point (window, &xpos, &ypos);

          FIfld_set_text (Message_form, 22, 0, 0, "", 0);
          FIfld_set_text (Message_form, 44, 0, 0, "", 0);

          if (status == 1) /* Do not create new group */
          {
            if (hilite_flag == 0)
              FIg_unhilite (work_form, grp_gadget);

            if (display_flag == 0)
              FIg_erase (work_form, grp_gadget);
          }
          else
          {
            /* Grab the next label to use as the Active_group */
            /* and create the group. */

            FIf_get_next_label (work_form, &Active_group);

            FIg_new (work_form, FI_GROUP, Active_group);

            FIg_add_to_group (work_form, grp_gadget, Active_group);

            Pass_on_flag = 1;
            FIgrp_set_pass_on (work_form, Active_group);

            Single_select_flag = 1;
            FIgrp_set_single_select_on (work_form, Active_group);

            Display_group_form();

            return;
          }
        }
        else
        {
          /*****************************************************/
          /* */
          /* The gadget belongs to a group, so first display */
          /* all gadgets that belong to the group in highlight */
          /* mode. Then display a form which will allow the */
          /* operator to set single select, and pass-on flags */
          /* for the group. This form will also allow the */
          /* user to modify the group's label if he wishes to */
          /* do so. */
          /* */
          /*****************************************************/

          FIgrp_get_single_select (work_form, Active_group,
              &Single_select_flag);

          FIgrp_get_pass (work_form, Active_group, &Pass_on_flag);

          FIgrp_set_pass_on (work_form, Active_group);

          FIg_hilite (work_form, Active_group);

          FIg_display (work_form, Active_group);

          if (Pass_on_flag == 0)
            FIgrp_set_pass_off (work_form, Active_group);

          Display_group_form();

          return;
        }
      }
      else
        not_finished = 0;
    }

    kill_create_group();
  }
}
