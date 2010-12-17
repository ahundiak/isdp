/***********************************

		save_pv.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
	05-07-92	sml		casted func args for ANSI
*/

/********************************/
/* */
/* These functions save the current presentation values to a form. */
/* */
/* Programmer: Mack Draper */
/* */
/* Date: Mar. 13, 1989 */
/* */
/********************************/

#include <sys/types.h>
#include <dirent.h>

#include <stdio.h>

#include "FI.h"
#include "NFBpriv.h"
#include "UMS.h"
#include "FB.h"

#include "XFIproto_pub.h"
#include "XFBproto_pri.h"


#define HELP 6
#define CANCEL 4
#define ACCEPT 1

#define DIR_FLD 13
#define NAME_FLD 15

#define ERR_FLD 10

extern struct dpb_struct dpb;
extern char current_command_string[80];
extern int command_is_active;
extern char execute_dir[200];
extern Form Message_form;

extern char language[80];

static Form Save_pv_form = NULL;
static char save_pv_dir[256];
static char save_pv_name[256];


/*-----------------------------------------------------------------------*/

void kill_save_pv(void)
{
  char t_str[256];

  if (Save_pv_form != NULL)
    FIf_erase (Save_pv_form);

  FIfld_set_text (Message_form, 11, 0, 0, "", 0);

  UMSGetByNum (t_str, FB_P_SELCOM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  command_is_active = 0;
  strcpy (current_command_string, "None");
}

/*------------------------------------------------------------------------*/
/*************************************************************************/
/* */
/* fi_save_pv_form() */
/* */
/* This massive function works in the same manner as the form_input */
/* method did in the OM world. (Boo! Hiss!!!) */
/* */
/* The naming convention for all of my gadget notification routines */
/* will start with "fi" for form input. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_save_pv_form (int form_label,
                     int gadget_label,
                     double value,
                     Form form_ptr)
{
  char t_str[256];
  int status;
  char filepath[256];
  DIR *dirp;
  char temp_dir[256];
  FILE *save_pv_file;
  int dummy_int;

  FIg_erase (Save_pv_form, ERR_FLD);

  switch (gadget_label)
  {
  case HELP:
    break;

  case CANCEL:

    kill_save_pv();
    FIg_set_state_off (Save_pv_form, FI_CANCEL);
    break;

  case ACCEPT:

    strcpy (filepath, save_pv_dir);
    strcat (filepath, "/");
    strcat (filepath, save_pv_name);

    save_pv_file = fopen (filepath, "w");

    fwrite (&dpb, sizeof (dpb), 1, save_pv_file);

    fclose (save_pv_file);

    kill_save_pv();
    FIg_set_state_off (Save_pv_form, FI_ACCEPT);
    break;

  case DIR_FLD:

    /* Find out what the operator just typed in */

    status = FIfld_get_text (Save_pv_form, DIR_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    /* Expand the shell variables to full path and put back into field */

    strcpy (temp_dir, expand_shell_vars(t_str));

    dirp = opendir ( temp_dir );
    if ( dirp == NULL )
    {
      UMSGetByNum (t_str, FB_E_BADOPNDIR, 0);
      print_error (Save_pv_form, ERR_FLD, t_str);
    }
    else
    {
      FIfld_set_text (Save_pv_form, DIR_FLD, 0, 0, temp_dir, 0);
      strcpy (save_pv_dir, temp_dir);
      closedir (dirp);
    }
    break;

  case NAME_FLD:

    status = FIfld_get_text (Save_pv_form, NAME_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    if ((strlen (t_str) > 14) ||
        (strlen (t_str) == 0))
    {
      UMSGetByNum (t_str, FB_E_BADFRMNAME, 0);

      FIfld_set_text (Save_pv_form, ERR_FLD, 0, 0, t_str, 0);

      FIg_display (Save_pv_form, ERR_FLD);

      FIfld_set_text (Save_pv_form, NAME_FLD, 0, 0, "", 0);
      break;
    }
    else
      strcpy (save_pv_name, t_str);

    break;
  }

  return;
}

/*************************************************************************/

void execute_save_pv(void)
{
  int status;
  char t_str[256];

  UMSGetByNum (t_str, FB_I_SVEPRESVAR, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  FIfld_set_text (Message_form, 33, 0, 0, "", 0);

  if (Save_pv_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBSvPrVr");
    status = FIf_new (100, t_str, (int (*)())fi_save_pv_form, &Save_pv_form);

    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  FIfld_set_text (Save_pv_form, DIR_FLD, 0, 0, "", 0);
  FIfld_set_text (Save_pv_form, NAME_FLD, 0, 0, "", 0);
  FIg_erase (Save_pv_form, 10);

  FIf_display (Save_pv_form);

  /********************************************/
  /* */
  /* Need to set Help topic to "Save" here */
  /* */
  /********************************************/

  UMSGetByNum (t_str, FB_P_FILLSVPV, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}
