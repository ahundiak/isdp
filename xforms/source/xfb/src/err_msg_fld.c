/***********************************

		err_msg_fld.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
*/

/********************************/
/* */
/* These functions place the standard error message and prompt fields at */
/* the bottom of the form, and erases them. */
/* */
/* Programmer: Mack Draper */
/* */
/* Date: Feb. 2, 1989 */
/* */
/********************************/

#include <stdio.h>

#include "FI.h"
#include "NFBpriv.h"
#include "UMS.h"
#include "FB.h"

#include "XFIproto_pub.h"
#include "XFBproto_pri.h"

extern Form work_form;
extern Form Message_form;
extern struct gadget_struct gadget_attr;
extern char current_command_string[80];
extern int command_is_active;


/*----------------------------------------------------------------------*/

void execute_place_err_msg_flds(void)
{
  int xsize, ysize;
  char t_str[256];

  if (work_form == NULL)
  {
    command_is_active = 0;
    strcpy(current_command_string, "None");
  }
  else
  {
    UMSGetByNum (t_str, FB_I_PLAERRMSG, 0);
    FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
    FIfld_set_text (Message_form, 33, 0, 0, "", 0);

    FIg_erase (work_form, 9);
    FIg_erase (work_form, 10);
    FIg_delete (work_form, 9);
    FIg_delete (work_form, 10);

    FIf_get_size (work_form, &xsize, &ysize);

    Set_new_gadget_defaults();

    gadget_attr.display = 1;
    gadget_attr.selectable = 1;
    gadget_attr.hilite = 0;
    gadget_attr.initial_notify = 0;
    gadget_attr.complete_notify = 1;
    gadget_attr.help = 0;
    gadget_attr.cmd_string = 0;
    gadget_attr.cmd_key = 0;
    gadget_attr.text_gadget = 1;

    gadget_attr.x_pos = 15;
    gadget_attr.y_pos = ysize - 29;
    gadget_attr.x_size = xsize - 15;
    gadget_attr.y_size = ysize - 12;

    strcpy (gadget_attr.font_name, "mono821b");
    gadget_attr.bodysize = 15;

    Create_and_init_gadget (work_form, FI_FIELD, 10);

    FIfld_set_attr (work_form, 10, 0, FI_HORT_SCROLL);

    FIfld_set_mode (work_form, 10, 0, FI_REVIEW);
    FIfld_set_type (work_form, 10, 0, FI_ALPHA);

    FIg_activate (work_form, 10);
    FIg_display (work_form, 10);

    gadget_attr.x_pos = 15;
    gadget_attr.y_pos = ysize - 52;
    gadget_attr.x_size = xsize - 15;
    gadget_attr.y_size = ysize - 34;

    Create_and_init_gadget (work_form, FI_FIELD, 9);

    FIfld_set_attr (work_form, 9, 0, FI_HORT_SCROLL);

    FIfld_set_mode (work_form, 9, 0, FI_REVIEW);
    FIfld_set_type (work_form, 9, 0, FI_ALPHA);

    FIg_activate (work_form, 9);
    FIg_display (work_form, 9);

    FIf_calculate_size ((struct FIform_obj *)work_form);

    /* GMD 10/21/91   Fix for SUN crash problem */

    FIfld_set_format_string (work_form, 9, 0, "%d");
    FIfld_set_format_string (work_form, 10, 0, "%d");

    FIfld_set_text (Message_form, 11, 0, 0, "", 0);
    UMSGetByNum (t_str, FB_P_SELCOM, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    command_is_active = 0;
    strcpy(current_command_string, "None");
  }
}

/*------------------------------------------------------------------------*/

void kill_place_err_msg_flds(void)
{
}
