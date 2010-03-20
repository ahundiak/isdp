/***********************************

		exit_fb.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
*/

/********************************/
/* */
/* These functions are used to exit the form builder program. */
/* */
/* Programmer: Mack Draper */
/* */
/* Date: Nov. 1, 1988 */
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
extern char current_command_string[80];
extern int command_is_active;
extern int exit_flag;
extern char menu_locations[256];

extern Form save_form;

/*-----------------------------------------------------------------------*/

void execute_exit_fb(void)
{
  if (work_form != NULL)
  {
    execute_save_form();
  }
  else
  {
    command_is_active = 0;
    strcpy(current_command_string, "None");
    exit_flag = 1;

/*  fprintf(stderr, "in exit_fb, menu_locations is %s\n",menu_locations);*/
    MS_save_locations( menu_locations );
/*    exit(); dmb:04/07/93:Found prototype mis-match during SUNOS5 port */
    exit(0);
  }
}

/*-----------------------------------------------------------------------*/


void kill_exit_fb(void)
{
  char t_str[256];

  if (save_form != NULL)
    FIf_erase (save_form);

  UMSGetByNum (t_str, FB_P_SELCOM, 0);
  fprintf (stderr, "%s\n", t_str);

  command_is_active = 0;
  strcpy (current_command_string, "None");
}
