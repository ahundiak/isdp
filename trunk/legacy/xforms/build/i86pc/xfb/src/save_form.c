/***********************************

		save_form.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
	05-07-92	sml		casted func args for ANSI
*/

/********************************/
/* */
/* These functions are used to save the current work_form. */
/* */
/* Programmer: Mack Draper */
/* */
/* Date: Nov. 1, 1988 */
/* */
/********************************/

#include <sys/types.h>
#include <dirent.h>

#include <stdio.h>

#include "X11/Xlib.h"

#include "FI.h"
#include "NFBpriv.h"
#include "UMS.h"
#include "FB.h"
#include "FImin.h"

#include "XFIproto_pub.h"
#include "XFBproto_pri.h"

#define HELP 6
#define CANCEL 4
#define ACCEPT 1

#define DIR_FLD 14
#define NAME_FLD 15

#define ASCII_TOG 19
#define ERASE_TOG 16
#define WRITE_TOG 13

#define NOTIFY_TOG 20
#define NOTIFY_DIR_TEXT 21
#define NOTIFY_FILE_TEXT 22
#define NOTIFY_DIR_FLD 23
#define NOTIFY_FILE_FLD 24

#define ERR_FLD 10

extern struct form_data form_attr;
extern Form work_form;
extern Form Message_form;
extern struct dpb_struct dpb;
extern char current_command_string[80];
extern int command_is_active;
extern char dir[256];
extern char execute_dir[200];
extern int save_restore_flag;
extern int exit_flag;

extern int Fence_delete_total_gadgets;
extern int Fence_delete_gdt_array;
extern int Group_delete_total_gadgets;

extern char language[80];
extern int start_sequence_gadget;

/* - - - - - - - - - - - - */

static int save_as_ascii = 0;
static int save_as_binary = 0;
static int erase_form = 1;

static char save_dir[256];
static char save_name[256];

static char notify_dir[256];
static char notify_file[256];

Form save_form = NULL;


/*-----------------------------------------------------------------------*/

void kill_save_form(void)
{
  char t_str[256];

  if (save_form != NULL)
    FIf_erase (save_form);

  FIfld_set_text (Message_form, 11, 0, 0, "", 0);
  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  UMSGetByNum (t_str, FB_P_SELCOM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  command_is_active = 0;
  strcpy (current_command_string, "None");
}

/*------------------------------------------------------------------------*/
/*************************************************************************/
/* */
/* fi_save_form() */
/* */
/* This massive function works in the same manner as the form_input */
/* method did in the OM world. (Boo! Hiss!!!) */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_save_form (int form_label,
                  int gadget_label,
                  double value,
                  Form form_ptr)
{
  char t_str[256];
  int status, type;
  char filepath[256];
  long form_mask, and_mask;
  DIR *dirp;
  char temp_dir[256];
  int x, state;
  int dummy_int;
  struct FIform_obj * form = (struct FIform_obj *)work_form;

  FIg_erase (save_form, ERR_FLD);

  switch (gadget_label)
  {
  case HELP:
    break;

  case CANCEL:

    kill_save_form();
    FIg_set_state_off (save_form, FI_CANCEL);
    break;

  case ACCEPT:

    FIg_get_state (save_form, NOTIFY_TOG, &state);

    if (state == 1)
    {
      strcat (notify_dir, "/");
      strcat (notify_dir, notify_file);

      FIf_dump_process_code ((struct FIform_obj *)work_form, notify_dir);
    }

    /*************************************************************/
    /* */
    /* If any gadgets are being held in undelete buffers, now is */
    /* the time to get rid of them. */
    /* */
    /*************************************************************/

    status = FIg_get_type (work_form, -1000, &type);

    if (status == FI_SUCCESS)
      FIg_delete (work_form, -1000);

    /*************************************************************/
    /* */
    /* Now get rid of any lingering Fence undelete gadgets */
    /* */
    /*************************************************************/

    status = FIg_get_type (work_form, -2000, &type);

    if (status == FI_SUCCESS)
    {
      for (x = 0; x < Fence_delete_total_gadgets; x++)
      {
        FIg_delete (work_form, ((-2000) - x));
      }
    }

    /*************************************************************/
    /* */
    /* Now get rid of any lingering Group undelete gadgets */
    /* */
    /*************************************************************/

    status = FIg_get_type (work_form, -3000, &type);

    if (status == FI_SUCCESS)
    {
      FIg_delete (work_form, -4000);
      for (x = 0; x < Group_delete_total_gadgets; x++)
        FIg_delete (work_form, ((-3000) - x));
    }

    /************************************************/
    /* */
    /* Now start the business of saving the form */
    /* */
    /************************************************/

    if (command_is_active != SAVE_FORM)
    {
      form_attr.form_name[0] = 0;
      form_attr.new_form_name[0] = '\0';
    }

    FIf_get_size (work_form, &form_attr.x_size, &form_attr.y_size);

    FIf_set_orig_size (work_form, form_attr.x_size, form_attr.y_size);

    if (save_as_binary == 1)
    {
      and_mask = 65535;
      FIf_get_attr (work_form, &form_mask);

      if (form_attr.resize_flag == 1)
        and_mask ^= FI_NOT_RESIZABLE;
      else
        form_mask |= FI_NOT_RESIZABLE;

      if (form_attr.scaling_flag == 1)
        and_mask ^= FI_NOT_SCALABLE;
      else
        form_mask |= FI_NOT_SCALABLE;

      form_mask &= and_mask;
      FIf_set_attr (work_form, form_mask);

      strcpy (filepath, save_dir);
      strcat (filepath, "/");
      strcat (filepath, save_name);

      Determine_current_sequences(); /* Resolve any links that were */
      /* corrupted by gadgets being */
      /* deleted or renumbered. */

      Determine_current_data_links(); /* Do the same thing for the */
      /* data links. */

     if (form_attr.screen_number != FI_DEFAULT_SCRN)
     {
        FIf_erase (work_form);
        FIf_set_Xscreen (work_form, form_attr.screen_number,
                                    form_attr.absolute_screen);
     }

      /*********************************/
      /*                               */
      /* Cancel Grid Mode if it is set */
      /*                               */
      /*********************************/

    /* Don't need to do this    GMD 4/3/92   */
/*
      dpb.grid_flag = 0;
*/
      /* Fix GMD 2/12/91 */

      FIf_set_start_seq (work_form, start_sequence_gadget);

      if (save_restore_flag)
      {
         form->attr_mask |= FI_SAVE_RESTORE;
      }

      status = FIf_save (work_form, filepath);

      if (save_restore_flag)
      {
         form->attr_mask &= ~FI_SAVE_RESTORE;
      }

      if (form_attr.screen_number != FI_DEFAULT_SCRN)
      {
        FIf_set_Xscreen (work_form, FI_DEFAULT_SCRN, 0);
        FIf_display (work_form);
      }

      /* Insure that form is not scalable inside the builder. */
      /* This needs to be done in case the save form command was */
      /* used, since the form will remain in use after the command */
      /* completes. GMD 2/12/91 */

      FIf_get_attr (work_form, &form_mask);
      form_mask |= FI_NOT_SCALABLE; /* No scaling */
      form_mask |= FI_NOT_RESIZABLE;
      form_mask ^= FI_NOT_RESIZABLE; /* Allow resizing */

      FIf_set_attr (work_form, form_mask);

      if (status != FI_SUCCESS)
      {
        FIg_set_state_off (save_form, ACCEPT);
        UMSGetByNum (t_str, FB_E_STSOFSAV, "%d", status);
        print_error (save_form, ERR_FLD, t_str);
        return;
      }
    }

    if (erase_form == 1)
    {
      FIf_delete (work_form);

      work_form = NULL;
    }
    else if (command_is_active != SAVE_FORM)
    {
      FIf_set_notification_routine (work_form, (int (*)())fi_dummy_work_form);

      FIf_get_attr (work_form, &form_mask);
      form_mask |= FI_NOT_SCALABLE;
      form_mask |= FI_NOT_RESIZABLE;
      FIf_set_attr (work_form, form_mask);
      work_form = NULL;
    }

    if (command_is_active == EXIT_FB)
    {
      work_form = NULL;
      exit_flag = 1;
      command_is_active = 0;
      strcpy (current_command_string, "None");
      execute_exit_fb();
    }

    if (command_is_active == DEFINE_FORM)
    {
      FIf_erase (save_form);
      FIg_set_state_off (save_form, FI_ACCEPT);
      execute_define_form();
      return;
    }
    FIg_set_state_off (save_form, FI_ACCEPT);
    kill_save_form();
    break;

  case NOTIFY_TOG:

    if ((int)value == 0)
    {
      FIg_erase (save_form, NOTIFY_DIR_TEXT);
      FIg_erase (save_form, NOTIFY_FILE_TEXT);
      FIg_erase (save_form, NOTIFY_DIR_FLD);
      FIg_erase (save_form, NOTIFY_FILE_FLD);
    }
    else
    {
      FIg_display (save_form, NOTIFY_DIR_TEXT);
      FIg_display (save_form, NOTIFY_FILE_TEXT);
      FIg_display (save_form, NOTIFY_DIR_FLD);
      FIg_display (save_form, NOTIFY_FILE_FLD);
    }
    break;

  case ASCII_TOG:

    save_as_ascii = (int)value;
    print_error (save_form, ERR_FLD,
        "Ascii file not currently supported");
    FIg_set_state_off (save_form, ASCII_TOG);
    break;

  case ERASE_TOG:

    erase_form = (int)value;
    break;

  case WRITE_TOG:

    save_as_binary = (int)value;
    break;

  case DIR_FLD:

    /* Find out what the operator just typed in */

    FIfld_get_text (save_form, DIR_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    /* Expand the shell variables to full path and put back into field */

    strcpy (temp_dir, expand_shell_vars(t_str));

    dirp = opendir ( temp_dir );
    if ( dirp == NULL )
    {
      UMSGetByNum (t_str, FB_E_BADOPNDIR, 0);
      print_error (save_form, ERR_FLD, t_str);
    }
    else
    {
      FIfld_set_text (save_form, DIR_FLD, 0, 0, temp_dir, 0);
      strcpy (save_dir, temp_dir);
      closedir (dirp);
    }
    break;

  case NAME_FLD:

    FIfld_get_text(save_form, NAME_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    if ((strlen (t_str) > 14) || (strlen (t_str) == 0))
    {
      UMSGetByNum (t_str, FB_E_BADFRMNAME, 0);
      print_error (save_form, ERR_FLD, t_str);

      FIfld_set_text(save_form, ERR_FLD, 0, 0, t_str, 0);

      FIg_display(save_form, ERR_FLD);

      FIfld_set_text(save_form, NAME_FLD, 0, 0, "", 0);
      break;
    }
    else
      strcpy (save_name, t_str);

    break;

  case NOTIFY_DIR_FLD:

    /* Find out what the operator just typed in */

    FIfld_get_text (save_form, NOTIFY_DIR_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    /* Expand the shell variables to full path and put back into field */

    strcpy (temp_dir, expand_shell_vars(t_str));

    dirp = opendir ( temp_dir );
    if ( dirp == NULL )
    {
      UMSGetByNum (t_str, FB_E_BADOPNDIR, 0);
      print_error (save_form, ERR_FLD, t_str);
    }
    else
    {
      FIfld_set_text (save_form, NOTIFY_DIR_FLD, 0, 0, temp_dir, 0);
      strcpy (notify_dir, temp_dir);
      closedir (dirp);
    }
    break;

  case NOTIFY_FILE_FLD:

    FIfld_get_text(save_form, NOTIFY_FILE_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    if ((strlen (t_str) > 14) || (strlen (t_str) == 0))
    {
      UMSGetByNum (t_str, FB_E_DUMPNAME, 0);

      FIfld_set_text(save_form, ERR_FLD, 0, 0, t_str, 0);

      FIg_display(save_form, ERR_FLD);

      FIfld_set_text(save_form, NAME_FLD, 0, 0, "", 0);
      break;
    }
    else
      strcpy (notify_file, t_str);

    break;

  }

  return;
}

/*************************************************************************/

void execute_save_form(void)
{
  int status;
  char t_str[256];

  if (work_form == NULL)
  {
    kill_save_form();
  }
  else
  {
    UMSGetByNum (t_str, FB_I_SAVEFORM, 0);
    FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
    FIfld_set_text (Message_form, 33, 0, 0, "", 0);

    save_as_ascii = 0;
    save_as_binary = 1;
    erase_form = 1;

    if (save_form == NULL)
    {
      strcpy (t_str, execute_dir);
      strcat (t_str, "/config/");
      strcat (t_str, language);
      strcat (t_str, "/forms/FBExSvFrm");
      status = FIf_new (100, t_str, (int (*)())fi_save_form, &save_form);

      if (status != FI_SUCCESS)
        Report_fatal_form_error (status, t_str);
    }

    FIg_erase (save_form, 10); /* Error field */

    if (command_is_active == SAVE_FORM)
    {
      FIg_erase (save_form, ERASE_TOG);
      FIg_erase (save_form, WRITE_TOG);
      erase_form = 0;
    }
    else
    {
      FIg_display (save_form, ERASE_TOG);
      FIg_display (save_form, WRITE_TOG);
      FIg_set_state_on (save_form, ERASE_TOG);
      FIg_set_state_on (save_form, WRITE_TOG);
    }

    FIfld_set_text (save_form, DIR_FLD, 0, 0, dir, 0);

    FIfld_set_text (save_form, NAME_FLD, 0, 0, form_attr.new_form_name, 0);

    FIfld_set_text (save_form, NOTIFY_DIR_FLD, 0, 0, dir, 0);

    strcpy (notify_dir, dir);
    strcpy (notify_file, form_attr.new_form_name);
    if (strlen (notify_file) > 12)
      notify_file[12] = 0;
    strcat (notify_file, ".c");

    FIfld_set_text (save_form, NOTIFY_FILE_FLD, 0, 0, notify_file, 0);

    FIg_set_state_off (save_form, NOTIFY_TOG);
    FIg_erase (save_form, NOTIFY_DIR_TEXT);
    FIg_erase (save_form, NOTIFY_FILE_TEXT);
    FIg_erase (save_form, NOTIFY_DIR_FLD);
    FIg_erase (save_form, NOTIFY_FILE_FLD);

    /* Now display the save form */

    FIf_display (save_form);

    /********************************************/
    /* */
    /* Need to set Help topic to "Save" here */
    /* */
    /********************************************/

    UMSGetByNum (t_str, FB_P_FILLSVEFRM, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    strcpy (save_dir, dir);
    strcpy (save_name, form_attr.new_form_name);

  }
}
