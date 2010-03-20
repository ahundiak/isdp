/***********************************

		delete_gdt.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
*/

/*************************************/
/* */
/* This file contains functions for the "delete gadget" command. */
/* */
/* Programmer: Mack Draper */
/* Date: Feb. 7, 1989 */
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
#include "XFBproto_pri.h"

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

#define SAVED_GADGET_LABEL -1000

int Delete_gdt_display_flag;
int Delete_gdt_label;
int Delete_gdt_sequence_label;
int Delete_gdt_data_link_label;
int Delete_gdt_group_label;

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern Form work_form;
extern Form Message_form;
extern int command_is_active;
extern char current_command_string[80];


/*************************************************************************/
/* */
/* kill_delete_gadget() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to MOVE_GADGET indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_delete_gadget(void)
{
  char t_str[256];

  if (command_is_active == DELETE_GADGET)
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
  }
}

/*************************************************************************/
/* */
/* execute_delete_gadget() */
/* */
/* This function is called by the executive command handler routine. */
/* It changes values contained in the message windows and sets the */
/* builder mode to on for the work_form. As a result the gadgets will */
/* no longer change their state when poked. They will simply call their */
/* gadget notification routine. */
/* */
/*************************************************************************/

void execute_delete_gadget(void)
{
  char t_str[256];
  int status;
  int delete_gadget;
  int undelete_gadget;
  int not_finished;
  int xsize, ysize;
  int type;
  int attr;
  Window window;		/* change from int to Window for ANSI */
  int display_flag, hilite_flag;
  int accept_x, accept_y, mode;

  if (work_form == NULL) /* No form defined */
  {
    kill_delete_gadget();
  }
  else
  {
    UMSGetByNum (t_str, FB_I_DELGDT, 0);
    FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
    UMSGetByNum (t_str, FB_P_SELGDT, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    FIf_set_builder_mode_on ((struct FIform_obj *)work_form);

    not_finished = 1;
    FIf_get_window (work_form, &window);

    mode = 0; /* Force operator to enter a data point */

    while (not_finished)
    {
      status = Select_gadget (&delete_gadget, &xsize, &ysize, &display_flag,
          &hilite_flag, &accept_x, &accept_y, mode);

      if (status == 2) /* Success */
      {
        status = FIg_get_type (work_form, SAVED_GADGET_LABEL, &type);

        if (status == FI_SUCCESS)
          FIg_delete (work_form, SAVED_GADGET_LABEL);

        status = FIg_get_type (work_form, delete_gadget, &type);

        if ((hilite_flag == 0) &&
            (type != FI_GROUP))
          FIg_unhilite (work_form, delete_gadget);

        if (type == FI_GROUP)
        {
          FIgrp_delete (work_form, delete_gadget);
        }
        else
        {
          int xpos, ypos, xsize, ysize;

          undelete_gadget = SAVED_GADGET_LABEL;

          FIg_get_next_in_seq (work_form, delete_gadget,
              &Delete_gdt_sequence_label);

          FIg_get_pass_data (work_form, delete_gadget,
              &Delete_gdt_data_link_label);

          FIg_get_group_label (work_form, delete_gadget,
              &Delete_gdt_group_label);


          status = FIg_copy (work_form, delete_gadget, &undelete_gadget, 0);

          Delete_gdt_display_flag = display_flag;
          Delete_gdt_label = delete_gadget;

          FIg_get_location (work_form, delete_gadget, &xpos, &ypos);
          FIg_get_size (work_form, delete_gadget, &xsize, &ysize);

          FIg_delete (work_form, delete_gadget);

          FIg_erase (work_form, SAVED_GADGET_LABEL);

          FIg_get_attr (work_form, SAVED_GADGET_LABEL, &attr);

          attr |= FI_NOT_DISPLAYED;

          FIg_set_default_attr ((struct FIform_obj *)work_form, SAVED_GADGET_LABEL, attr);

          if ((type != FI_FIELD) &&
              (type != FI_MULTI_COL))
          {
            FIf_paint_area (work_form, xpos, ypos,
                xpos + xsize, ypos + ysize);
          }
          else
            Redisplay (work_form);

          mode = 1;
        }
      }
      else
      {
        not_finished = 0;
      }
    }

    kill_delete_gadget();
  }
}
