/***********************************

		delete_form.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
    05-06-92	sml		casted func args for ANSI
*/

/*************************************/
/* */
/* This file contains functions for the "delete form" command. */
/* */
/* Programmer: Mack Draper */
/* Date: May 5, 1989 */
/* */
/*************************************/

#include <sys/types.h>
#include <dirent.h>

#include <stdio.h>

#include "FI.h"
#include "FIdyn.h"
#include "NFBpriv.h"
#include "UMS.h"
#include "FB.h"

#include "XFIproto_pub.h"
#include "XFBproto_pri.h"

/*************************/
/* */
/* used by Delete form */
/* */
/*************************/

#define DIRECTORY_FLD 11
#define FORM_FLD 18
#define DESCRIPTION_FLD 19
#define FILELIST_FLD 20

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

static Form Delete_form = NULL;
static char Delete_directory[256];
static char Delete_file[256];

static void Setup_description_field();

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern Form work_form;
extern Form Message_form;
extern int command_is_active;
extern char current_command_string[80];
extern char execute_dir[200];
extern char dir[256];

extern char language[80];

/*************************************************************************/
/* */
/* kill_delete_form() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to DELETE_FORM indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_delete_form(void)
{
  char t_str[256];

  if (Delete_form != NULL)
    FIf_erase (Delete_form);

  command_is_active = 0;
  strcpy (current_command_string, "None");

  FIfld_set_text (Message_form, 11, 0, 0, "", 0);

  UMSGetByNum (t_str, FB_P_SELCOM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}

/*--------------------------------------------------------------------------*/

void List_directory_contents (Form form,
                              int gadget,
                              char *directory_name)
{
  int x;
  struct dirent *dp;
  DIR *dirp;
  int status;

  /* New for 1.2.0 --- GMD */

  char form_filename[1000][16];
  char temp_filename[16];
  int y, z;
  char t_str[256];

  dirp = opendir ( directory_name );
  if ( dirp == NULL )
  {
    UMSGetByNum (t_str, FB_E_BADOPNDIR, 0);
    print_error (form, FI_MSG_FIELD, t_str);
    FIfld_set_num_rows (form, gadget, 0);
    return;
  }
  else
  {
    UMSGetByNum (t_str, FB_I_SCANFILE, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    x = 0;
    while (( dp = readdir ( dirp )) != NULL )
    {
      if (( strcmp ( dp->d_name, ".." ) != 0 ) &&
          ( strcmp ( dp->d_name, "." ) != 0 ))
      {
        if ( _is_a_form ( dp->d_name, directory_name ) )
        {
          strcpy(&(form_filename[x][0]),dp->d_name);
          x++;
        }
      }
    }

    if ( x ) /* There are forms in the directory */
    {
      FIfld_set_num_rows (form, gadget, 0);

      if (x == 1) /* Only one entry, so no need to sort */
      {
        strcpy(t_str, &(form_filename[0][0]));

        status = FIfld_set_text(form, gadget, 0, 0,
            t_str, 0);
      }
      else /* Need to sort the files into alphabetical order */
      { /* before placing them into the form. */

        for (y=0; y < x - 1; y++)
        {
          for (z=y+1; z < x; z++)
          {
            if (strcmp (&(form_filename[y][0]),
                &(form_filename[z][0])) > 0)
            {
              strcpy(temp_filename, &(form_filename[y][0]));
              strcpy(&(form_filename[y][0]),&(form_filename[z][0]));
              strcpy(&(form_filename[z][0]),temp_filename);
            }
          }
        }

        /* Now that they are sorted, place them into the form */

        FIg_erase (form, gadget);

        for (y = 0; y < x; y++)
        {
          strcpy(t_str, &(form_filename[y][0]));

          status = FIfld_set_text(form, gadget, y, 0, t_str, 0);
        }
      }
      status = FIfld_set_num_rows (form, gadget, x);

      status = FIfld_set_active_row (form, gadget, 0, 0);

      FIg_display (form, gadget);

      status = FIg_erase(form, FI_MSG_FIELD);
    }
    else
    {
      UMSGetByNum (t_str, FB_E_NOIFORMS, 0);
      print_error (form, FI_MSG_FIELD, t_str);

      FIfld_set_num_rows (form, gadget, 0);
    }

    closedir ( dirp );
  }
  return;
}

/*-------------------------------------------------------------------------*/

/* ARGSUSED */
void fi_dummy_notify (int form_label,
                     int gadget_label,
                     double value,
                     Form form_ptr)
{
  return;
}

/*--------------------------------------------------------------------------*/

static void Setup_description_field(void)
{
  extern char ** descript_ptr;
  int num_desc, x;
  Form Test_form;
  char t_str[2000], t_str2[2000];
  int status;

  strcpy (t_str, Delete_directory);
  strcat (t_str, "/");
  strcat (t_str, Delete_file);

  FIf_new (1, t_str, (int (*)())fi_dummy_notify, &Test_form);

  /******************************************/
  /* */
  /* Read existing form's description field */
  /* */
  /******************************************/

  status = FIf_get_description ((struct FIform_obj *)Test_form, &num_desc, &descript_ptr);

  FIfld_set_num_rows (Delete_form, DESCRIPTION_FLD, 0);

  for (x = 0; x < num_desc; x++)
  {
    strcpy (t_str, descript_ptr[x]);
    if (t_str[2] < 32)
      strcpy (t_str2, &(t_str[3]));
    else
      strcpy (t_str2, t_str);

    FIfld_set_text (Delete_form, DESCRIPTION_FLD, x, 0,
        t_str2, 0);
  }

  FIf_delete (Test_form);
}

/*--------------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* fi_delete_form() */
/* */
/* This function works in the same manner as the form_input method */
/* did in the OM world. (Boo! Hiss!!!) */
/* */
/* This form is used to allow the operator to delete a form. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_delete_form (int form_label,
                    int gadget_label,
                    double value,
                    Form form_ptr)
{
  int i;
  int status;
  int dummy_int;
  char t_str[256];

  FIg_erase (Delete_form, FI_MSG_FIELD);

  switch (gadget_label)
  {
  case DIRECTORY_FLD:

    /* Find out what the operator just typed in */

    FIfld_get_text(Delete_form, DIRECTORY_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    /* Expand the shell variables to full path and put back into field */

    strcpy (Delete_directory, expand_shell_vars(t_str));

    FIfld_set_text (Delete_form, DIRECTORY_FLD,
        0, 0, Delete_directory, 0);

    List_directory_contents (Delete_form, FILELIST_FLD,
        Delete_directory);
    break;

  case FORM_FLD:

    FIfld_get_text(Delete_form, FORM_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    if (strlen(t_str) > 14)
    {
      UMSGetByNum (t_str, FB_E_BADFRMNAME, 0);
      print_error (Delete_form, FI_MSG_FIELD, t_str);

      FIfld_set_text(Delete_form, FORM_FLD, 0, 0,
          "", 0);
      Delete_file[0] = 0;
    }
    else
    {
      if (_is_a_form (t_str, Delete_directory))
      {
        strcpy (Delete_file, t_str);
        Setup_description_field();
      }
      else
      {
        UMSGetByNum (t_str, FB_E_INVDFORM, 0);
        print_error (Delete_form, FI_MSG_FIELD, t_str);
        Delete_file[0] = 0;
        FIfld_set_text(Delete_form, FORM_FLD, 0, 0,
            "", 0);
      }
    }
    break;

  case FILELIST_FLD:

    i = (int)value;

    if (i >= 0)
    {
      FIfld_get_text (Delete_form, FILELIST_FLD, i, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

      strcpy ( Delete_file, t_str);

      FIfld_set_text (Delete_form, FORM_FLD, 0, 0, t_str, 0);

      Setup_description_field();
    }
    break;

  case FI_HELP:

    /* Help_topic ("Text") */
    FIg_set_state_off (Delete_form, FI_HELP);
    break;

  case FI_CANCEL:

    kill_delete_form();
    FIg_set_state_off (Delete_form, FI_CANCEL);
    break;

  case FI_ACCEPT:

    if (Delete_file[0] == 0)
    {
      UMSGetByNum (t_str, FB_E_MSTSPCFIL, 0);
      print_error (Delete_form, FI_MSG_FIELD, t_str);
    }
    else
    {
      strcpy (t_str, Delete_directory);
      strcat (t_str, "/");
      strcat (t_str, Delete_file);

      status = unlink (t_str);

      if (status != 0)
      {
        UMSGetByNum (t_str, FB_E_CANNOTDEL, 0);
        print_error (Delete_form, FI_MSG_FIELD, t_str);
      }
      else
      {
        Delete_file[0] = 0;
        FIfld_set_text(Delete_form, FORM_FLD, 0, 0, "", 0);

        List_directory_contents (Delete_form, FILELIST_FLD,
            Delete_directory);
      }
    }
    FIg_set_state_off (Delete_form, FI_ACCEPT);

    break;
  }

  return;
}

/*************************************************************************/
/* */
/* execute_delete_form() */
/* */
/* This function is called in one of two ways. The first is to be */
/* called by the executive command handler routine. The second is to */
/* be called after text has been successfully placed. */
/* */
/* It displays the Delete form then exits. After that point */
/* the fi_delete_form() gadget notification routine will be in */
/* control. That is to say, every time the operator alters a gadget on */
/* the Delete form, the fi_delete_form() function will be invoked. */
/* */
/*************************************************************************/

void execute_delete_form(void)
{
  char t_str[256];
  int status;


  UMSGetByNum (t_str, FB_E_DELFRM, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_I_SEARDIR, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Delete_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBDelFrm");
    status = FIf_new (199, t_str, (int (*)())fi_delete_form, &Delete_form);
    if (status != 0)
      Report_fatal_form_error (status, t_str);
  }

  FIg_erase (Delete_form, 10); /* error field */

  if ( dir[0] == (char) NULL )
  {
    strcpy (dir, ".");
    strcpy (t_str, expand_shell_vars(dir));
    strcpy (dir, t_str);
  }

  List_directory_contents (Delete_form, FILELIST_FLD, dir);
  FIfld_set_text (Delete_form, DIRECTORY_FLD, 0, 0, dir, 0);
  FIfld_set_text (Delete_form, FORM_FLD, 0, 0, "", 0);
  FIfld_set_num_rows (Delete_form, DESCRIPTION_FLD, 0);

  strcpy (Delete_directory, dir);
  strcpy (Delete_file, "");

  FIf_display (Delete_form);

  UMSGetByNum (t_str, FB_P_FILLDEL, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}
