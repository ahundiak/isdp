/***********************************

		copy_form.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
	05-07-92	sml		changed local vars types for ANSI
*/

/*************************************/
/* */
/* This file contains functions for the "copy form" command. */
/* */
/* Programmer: Mack Draper */
/* Date: June 26, 1989 */
/* */
/*************************************/

#include <sys/types.h>
#include <dirent.h>

#include <stdio.h>
#include <fcntl.h>

#include "FI.h"
#include "FIdyn.h"
#include "NFBpriv.h"
#include "UMS.h"
#include "FB.h"

#include "XFIproto_pub.h"
#include "XFBproto_pri.h"

/*************************/
/* */
/* used by Copy form */
/* */
/*************************/

#define FROM_DIR_FLD 15
#define FROM_FORM_FLD 16
#define FROM_DESC_FLD 22
#define FROM_FORM_LIST_FLD 23

#define TO_DIR_FLD 17
#define TO_FORM_FLD 18
#define TO_DESC_FLD 24
#define TO_FORM_LIST_FLD 25

#define FI_MSG_FLD 10

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

static Form Copy_form = NULL;
static char From_directory[256];
static char From_file[200];
static char To_directory[256];
static char To_file[200];

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern int command_is_active;
extern char current_command_string[80];
extern char execute_dir[200];
extern char dir[256];

extern Form Test_form;
extern Form Message_form;

extern char language[80];

/*************************************************************************/
/* */
/* kill_copy_form() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to COPY_FORM indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_copy_form(void)
{
  char t_str[256];

  if (Copy_form != NULL)
    FIf_erase (Copy_form);

  command_is_active = 0;
  strcpy (current_command_string, "None");

  FIfld_set_text (Message_form, 11, 0, 0, "", 0);

  UMSGetByNum (t_str, FB_P_SELCOM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}

/*--------------------------------------------------------------------------*/

Setup_copy_description_field(void)
{
  extern char ** descript_ptr;
  int num_desc, x;
  Form Test_form;
  char t_str[2000], t_str2[2000];

  strcpy (t_str, From_directory);
  strcat (t_str, "/");
  strcat (t_str, From_file);

  FIf_new (1, t_str, (int (*)())fi_dummy_notify, &Test_form);

  /******************************************/
  /* */
  /* Read existing form's description field */
  /* */
  /******************************************/

  FIf_get_description ((struct FIform_obj *)Test_form, &num_desc, &descript_ptr);

  FIfld_set_num_rows (Copy_form, FROM_DESC_FLD, 0);
  FIfld_set_num_rows (Copy_form, TO_DESC_FLD, 0);

  for (x = 0; x < num_desc; x++)
  {
    strcpy (t_str, descript_ptr[x]);
    if (t_str[2] < 32)
      strcpy (t_str2, &(t_str[3]));
    else
      strcpy (t_str2, t_str);

    FIfld_set_text (Copy_form, FROM_DESC_FLD, x, 0, t_str2, 0);
  }

  FIf_delete (Test_form);
}

/*--------------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* fi_copy_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to copy a form. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_copy_form (int form_label,
                  int gadget_label,
                  double value,
                  Form form_ptr)
{
  int i;
  int status;
  char t_str[256], t2_str[256];
  Form Test_form;
  int dummy_int;

  FIg_erase (Copy_form, FI_MSG_FIELD);

  switch (gadget_label)
  {
  case FROM_DIR_FLD:

    /* Find out what the operator just typed in */

    FIfld_get_text (Copy_form, FROM_DIR_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    /* Expand the shell variables to full path and put back into field */

    strcpy (From_directory, expand_shell_vars(t_str));

    FIfld_set_text (Copy_form, FROM_DIR_FLD,
        0, 0, From_directory, 0);

    List_directory_contents (Copy_form,
        FROM_FORM_LIST_FLD, From_directory);
    break;

  case TO_DIR_FLD:

    /* Find out what the operator just typed in */

    FIfld_get_text (Copy_form, TO_DIR_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    /* Expand the shell variables to full path and put back into field */

    strcpy (To_directory, expand_shell_vars(t_str));

    FIfld_set_text (Copy_form, TO_DIR_FLD,
        0, 0, To_directory, 0);

    List_directory_contents (Copy_form, TO_FORM_LIST_FLD,
        To_directory);
    break;

  case FROM_FORM_FLD:

    FIfld_get_text (Copy_form, FROM_FORM_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    if (strlen(t_str) > 14)
    {
      UMSGetByNum (t_str, FB_E_BADFRMNAME, 0);
      print_error (Copy_form, FI_MSG_FIELD, t_str);

      FIfld_set_text(Copy_form, FROM_FORM_FLD, 0, 0,
          "", 0);
      From_file[0] = 0;
    }
    else
    {
      if (_is_a_form (t_str, From_directory))
      {
        strcpy (From_file, t_str);
        Setup_copy_description_field();
      }
      else
      {
        UMSGetByNum (t_str, FB_E_INVDFORM, 0);
        print_error (Copy_form, FI_MSG_FIELD, t_str);
        From_file[0] = 0;
        FIfld_set_text(Copy_form, FROM_FORM_FLD, 0, 0,
            "", 0);
      }
    }
    break;

  case TO_FORM_FLD:

    FIfld_get_text (Copy_form, TO_FORM_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    if (strlen(t_str) > 14)
    {
      UMSGetByNum (t_str, FB_E_BADFRMNAME, 0);
      print_error (Copy_form, FI_MSG_FIELD, t_str);

      FIfld_set_text(Copy_form, TO_FORM_FLD, 0, 0,
          "", 0);
      To_file[0] = 0;
    }
    else
    {
      strcpy (To_file, t_str);
    }
    break;

  case FROM_FORM_LIST_FLD:

    i = (int)value;

    if (i >= 0)
    {
      FIfld_get_text (Copy_form, FROM_FORM_LIST_FLD, i, 0, 255,
          (unsigned char *)t_str, &dummy_int, &dummy_int);

      strcpy ( From_file, t_str);

      FIfld_set_text (Copy_form, FROM_FORM_FLD, 0, 0,
          t_str, 0);

      Setup_copy_description_field();
    }
    break;

  case TO_FORM_LIST_FLD:

    i = (int)value;

    if (i >= 0)
    {
      FIfld_get_text (Copy_form, TO_FORM_LIST_FLD, i, 0, 255,
          (unsigned char *)t_str, &dummy_int, &dummy_int);

      strcpy ( To_file, t_str);

      FIfld_set_text (Copy_form, TO_FORM_FLD, 0, 0, t_str, 0);
    }
    break;

  case FI_HELP:

    /* Help_topic ("Text") */
    FIg_set_state_off (Copy_form, FI_HELP);
    break;

  case FI_CANCEL:

    kill_copy_form();
    FIg_set_state_off (Copy_form, FI_CANCEL);
    break;

  case FI_ACCEPT:

    if (From_file[0] == 0)
    {
      UMSGetByNum (t_str, FB_E_MSTSPSRC, 0);
      print_error (Copy_form, FI_MSG_FIELD, t_str);
    }
    else if (To_file[0] == 0)
    {
      UMSGetByNum (t_str, FB_E_MSTSPDEST, 0);
      print_error (Copy_form, FI_MSG_FIELD, t_str);
    }
    else
    {
      strcpy (t_str, From_directory);
      strcat (t_str, "/");
      strcat (t_str, From_file);

      strcpy (t2_str, To_directory);
      strcat (t2_str, "/");
      strcat (t2_str, To_file);

      FIf_new (1, t_str, (int (*)())fi_dummy_notify, &Test_form);

      status = FIf_save (Test_form, t2_str);

      if (status != FI_SUCCESS)
      {
        UMSGetByNum (t_str, FB_E_BADDIRFRCP, 0);
        print_error (Copy_form, FI_MSG_FIELD, t_str);
      }

      FIf_delete (Test_form);

      FIfld_get_text (Copy_form, FROM_DIR_FLD, 0, 0, 255,
          (unsigned char *)t_str, &dummy_int, &dummy_int);

      List_directory_contents (Copy_form, FROM_FORM_LIST_FLD,
          From_directory);

      FIfld_get_text (Copy_form, TO_DIR_FLD, 0, 0, 255,
          (unsigned char *)t_str, &dummy_int, &dummy_int);

      List_directory_contents (Copy_form, TO_FORM_LIST_FLD,
          To_directory);
    }
    FIg_set_state_off (Copy_form, FI_ACCEPT);

    break;
  }

  return;
}

/*************************************************************************/
/* */
/* execute_copy_form() */
/* */
/* This function is called in one of two ways. The first is to be */
/* called by the executive command handler routine. The second is to */
/* be called after text has been successfully placed. */
/* */
/* It displays the Delete form then exits. After that point */
/* the fi_delete_form() gadget notification routine will be in */
/* control. That is, every time the operator alters a gadget on */
/* the Delete form, the fi_delete_form() function will be invoked. */
/* */
/*************************************************************************/

void execute_copy_form(void)
{
  char t_str[256];
  int status;
  extern void Report_fatal_form_error();

  UMSGetByNum (t_str, FB_I_CPYFRM, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_SEARDIR, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Copy_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBCpyFrm");
    status = FIf_new (199, t_str, (int (*)())fi_copy_form, &Copy_form);
    if (status != FI_SUCCESS)
      Report_fatal_form_error (status, t_str);
  }

  FIg_erase (Copy_form, 10);

  if ( dir[0] == (char) NULL )
  {
    strcpy (dir, expand_shell_vars("."));
  }

  List_directory_contents (Copy_form, FROM_FORM_LIST_FLD, dir);
  FIfld_set_text (Copy_form, FROM_DIR_FLD, 0, 0, dir, 0);
  FIfld_set_text (Copy_form, FROM_FORM_FLD, 0, 0, "", 0);
  FIfld_set_num_rows (Copy_form, FROM_DESC_FLD, 0);

  List_directory_contents (Copy_form, TO_FORM_LIST_FLD, dir);
  FIfld_set_text (Copy_form, TO_DIR_FLD, 0, 0, dir, 0);
  FIfld_set_text (Copy_form, TO_FORM_FLD, 0, 0, "", 0);

  strcpy (From_directory, dir);
  strcpy (From_file, "");
  strcpy (To_directory, dir);
  strcpy (To_file, "");

  FIf_display (Copy_form);

  UMSGetByNum (t_str, FB_I_FILLCPY, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}
