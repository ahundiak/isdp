/***********************************

		exp_preview.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
	05-07-92	sml		added 2nd arg for FI_process_event, casted
						  func args for ANSI
*/

/*************************************/
/* */
/* This file contains functions for the "expanded preview" command. */
/* */
/* Programmer: Mack Draper */
/* Date: Apr. 14, 1989 */
/* */
/*************************************/

#include <sys/types.h>
#include <dirent.h>

#include <stdio.h>

#include <X11/Xlib.h>

#include "FI.h"
#include "FIdyn.h"
#include "NFBpriv.h"
#include "UMS.h"
#include "FB.h"

#include "XFIproto_pub.h"
#include "XFBproto_pri.h"


#define PREVIEW_FLD 34
#define SAVE_TOG 15

#define DIR_TEXT 13
#define FILE_TEXT 14
#define DIR_FLD 16
#define FILE_FLD 17

#define ERR_FLD 10

/*************************************/
/* */
/* Global variables for this Command */
/* */
/*************************************/

Form Preview_form = NULL;

static struct preview_struct
{
  int gadget;
  int group;
  int data_link;
  int next_in_seq;
  int display_flag;
  int label_flag;
} preview_list[1000];

int Total_groups;
int group_list[100];
int index_list[1000];
int sort_array[1000];

static int Save_preview_data;
static char Save_preview_dir[256];
static char Save_preview_file[256];

static void Determine_current_preview_gadgets();
static void Display_preview_form();
static void Draw_exp_preview_labels();
static void Refresh_list_text();
static void Sort_gadgets_by_group();
static void Write_preview_data_to_disk();

extern Display *display;

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern int Total_gadgets;

extern struct form_data form_attr;
extern Form work_form;
extern Form Message_form;
extern char dir[256];
extern int command_is_active;
extern char current_command_string[80];
extern char execute_dir[200];

extern char language[80];

/*************************************************************************/
/* */
/* kill_expanded_preview() */
/* */
/* This function will be called by either the executive or by a */
/* routine that is responsible for obtaining a data point from a form. */
/* If the routine is being called from the executive then three */
/* conditions must be met. First a new command has been activated by */
/* the operator pressing a menu button. Secondly command_is_active */
/* flag is set to EXP_PREVIEW indicating that this command is */
/* executing. Thirdly the command autokill flag is set. */
/* */
/* If the method is being called by a point generator routine, then */
/* the operator has elected to press the reset mouse button instead of */
/* selecting the point. */
/* */
/*************************************************************************/

void kill_expanded_preview(void)
{
  char t_str[256];

  command_is_active = 0;
  strcpy (current_command_string, "None");

  FIfld_set_text (Message_form, 11, 0, 0, "", 0);
  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  UMSGetByNum (t_str, FB_P_SELCOM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (Preview_form != NULL)
  {
    FIf_erase (Preview_form);
  }
}

/*--------------------------------------------------------------------*/

static void Determine_current_preview_gadgets(void)
{
  int form_xsize, form_ysize;
  int x, type, group;
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
      preview_list[Total_gadgets].gadget = gadget_array[x];

      FIg_get_group_label (work_form, preview_list[x].gadget, &group);

      preview_list[Total_gadgets].group = group;

      FIg_get_next_in_seq (work_form, preview_list[x].gadget,
          &preview_list[x].next_in_seq);

      FIg_get_pass_data (work_form, preview_list[x].gadget,
          &preview_list[x].data_link);

      FIg_get_attr (work_form, gadget_array[x], &attr);

      if (attr & FI_NOT_DISPLAYED)
      {
        preview_list[Total_gadgets].display_flag = 0;
      }
      else
      {
        preview_list[Total_gadgets].display_flag = 1;
      }

      preview_list[Total_gadgets].label_flag = 1;

      Total_gadgets++;
    }
  }
}

/*--------------------------------------------------------------------*/

static void Sort_gadgets_by_group(void)
{
  int x, y, test_passed, g, temp;

  /* First determine how many groups are set up on the form */

  Total_groups = 1;
  group_list[0] = 0; /* Forms group */

  for (x = 0; x < Total_gadgets; x++)
  {
    g = preview_list[x].group;

    test_passed = 1;

    for (y = 0; y < Total_groups; y++)
    {
      if (group_list[y] == g)
      {
        test_passed = 0;
        y = Total_groups;
      }
    }

    if (test_passed)
    {
      group_list[Total_groups] = g;
      Total_groups++;
    }
  }

  /* Sort the groups into ascending order */

  for (x = 0; x < Total_groups - 1; x++)
  {
    for (y = x + 1; y < Total_groups; y++)
    {
      if (group_list[y] < group_list[x])
      {
        temp = group_list[x];
        group_list[x] = group_list[y];
        group_list[y] = temp;
      }
    }
  }
}

/*--------------------------------------------------------------------*/

static void Draw_exp_preview_labels(void)
{
  int x; 
  int attr;
  XEvent event;

  if (forms_intersect (Preview_form, work_form))
  {
    XMaskEvent (display, ExposureMask, &event); /* wait for event */
    FI_process_event (&event, 0); /* add 2nd arg for ANSI */

    while (XCheckMaskEvent (display, ExposureMask, &event))
    {
      FI_process_event (&event, 0); /* add 2nd arg for ANSI */
    }
  }


  for (x = 0; x < Total_gadgets; x++)
  {
    FIg_get_attr (work_form, preview_list[x].gadget, &attr);

    if (preview_list[x].display_flag == 1)
    {
      if (attr & FI_NOT_DISPLAYED)
      {
        FIg_display (work_form, preview_list[x].gadget);
      }
    }
    else
    {
      if (!(attr & FI_NOT_DISPLAYED))
      {
        FIg_erase (work_form, preview_list[x].gadget);
      }
    }
  }

  while (XCheckMaskEvent (display, ExposureMask, &event))
  {
    FI_process_event (&event, 0); /* add 2nd arg for ANSI */
  }

  for (x = 0; x < Total_gadgets; x++)
  {
    if (preview_list[x].label_flag == 1)
    {
      FIg_draw_a_label (preview_list[x].gadget);
    }
  }
}

/*--------------------------------------------------------------------*/

static void Write_preview_data_to_disk(void)
{
  FILE *preview_file;
  char line_of_text[256], t_str[256];
  char temp_file[300];
  int x, y;
  int dummy_int;

  FIfld_get_text (Preview_form, DIR_FLD, 0, 0, 255,
      (unsigned char *)Save_preview_dir, &dummy_int, &dummy_int);

  FIfld_get_text (Preview_form, FILE_FLD, 0, 0, 255,
      (unsigned char *)Save_preview_file, &dummy_int, &dummy_int);

  strcpy (temp_file, Save_preview_dir);
  strcat (temp_file, "/");
  strcat (temp_file, Save_preview_file);

  preview_file = fopen (temp_file, "w");

  if (preview_file == NULL)
  {
    char error_string[1000];

    UMSGetByNum (error_string, FB_E_UNBCREFIL, "%s", temp_file);
    Report_nonfatal_error (error_string);
  }
  else
  {

    /****************************************/
    /* */
    /* First print heading for preview file */
    /* */
    /****************************************/

    fprintf (preview_file, "\n\n\n");
    fprintf (preview_file,
     "--------------------------------------------------------------\n\n");
    fprintf (preview_file,
        " Expanded Preview Dump File\n\n\n");
    fprintf (preview_file,
        " Gadget Group Gadget X Y Display Seq Data\n");
    fprintf (preview_file,
        " Number Number Type Pos Pos Gadget To Link\n");
    fprintf (preview_file,
       "--------------------------------------------------------------\n");
    fprintf (preview_file, "\n\n");

    for (x = 0; x < Total_gadgets; x++)
    {
      line_of_text[0] = 0;

      for (y = 0; y < 8; y++)
      {
        FIfld_get_text (Preview_form, PREVIEW_FLD, x, y, 255, 
			(unsigned char *)t_str,
            &dummy_int, &dummy_int);

        if (strlen(t_str) > 8)
        {
          t_str[7] = 0;
        }
        if (y < 6)
        {
          strcat (line_of_text, t_str);
        }
        else
        {
          strcat (line_of_text, " ");
          strcat (line_of_text, t_str);
        }

        strcat (line_of_text, "\t");
      }
      fprintf (preview_file, "%s\n", line_of_text);
    }

    fclose (preview_file);
  }
}

/*--------------------------------------------------------------------*/

static void Refresh_list_text(void)
{
  int field_lines, x, y, z, sort_count, temp;
  char t_str[256], t_str2[256];
  int type, xpos, ypos;


  /****************************************************/
  /* */
  /* Now load up the multi-column field with entries. */
  /* A group at a time find all the gadgets that */
  /* belong to that group, sort them into ascending */
  /* order, and then fill in the preview form for */
  /* each of the gadgets. */
  /* */
  /****************************************************/

  field_lines = 0;

  for (x = 0; x < Total_groups; x++)
  {
    sort_count = 0;

    for (y = 0; y < Total_gadgets; y++)
    {
      if (preview_list[y].group == group_list[x])
      {
        sort_array[sort_count] = y;
        sort_count++;
      }
    }

    for (y = 0; y < sort_count - 1; y++)
    {
      for (z = y + 1; z < sort_count; z++)
      {
        if (preview_list[sort_array[y]].gadget >
            preview_list[sort_array[z]].gadget)
        {
          temp = sort_array[y];
          sort_array[y] = sort_array[z];
          sort_array[z] = temp;
        }
      }
    }

    for (y = 0; y < sort_count; y++)
    {
      index_list[field_lines] = sort_array[y];

      sprintf (t_str, "%4d", preview_list[sort_array[y]].gadget);

      FIfld_set_text (Preview_form, PREVIEW_FLD, field_lines, 0, t_str, 0);

      sprintf (t_str, "%4d", preview_list[sort_array[y]].group);

      FIfld_set_text (Preview_form, PREVIEW_FLD, field_lines, 1, t_str, 0);

      FIg_get_type (work_form, preview_list[sort_array[y]].gadget, &type);

      switch(type)
      {
      case FI_SLIDER:
        strcpy (t_str, "SLIDER");
        break;

      case FI_TOGGLE:
        strcpy (t_str, "TOGGLE");
        break;

      case FI_FIELD:
        strcpy (t_str, "FIELD");
        break;

      case FI_CHECKLIST:
        strcpy (t_str, "CKLIST");
        break;

      case FI_DIAL:
        strcpy (t_str, " DIAL");
        break;

      case FI_TEXT:
        strcpy (t_str, " TEXT");
        break;

      case FI_BUTTON:
        strcpy (t_str, "BUTTON");
        break;

      case FI_LINE:
        strcpy (t_str, " LINE");
        break;

      case FI_RECT:
        strcpy (t_str, " RECT");
        break;

      case FI_SYM:
        strcpy (t_str, "SYMBOL");
        break;

      case FI_SCROLL:
        strcpy (t_str, "SCROLL");
        break;

      case FI_MULTI_COL:
        strcpy (t_str, "MCFIELD");
        break;

      case FI_BEZEL:
        strcpy (t_str, "BEZEL");
        break;

      case FI_GAUGE:
        strcpy (t_str, "GAUGE");
        break;
      }

      FIfld_set_text (Preview_form, PREVIEW_FLD, field_lines, 2, t_str, 0);

      FIg_get_location (work_form, preview_list[sort_array[y]].gadget,
          &xpos, &ypos);

      sprintf (t_str, "%4d", xpos);

      FIfld_set_text (Preview_form, PREVIEW_FLD, field_lines, 3, t_str, 0);

      sprintf (t_str, "%4d", ypos);

      FIfld_set_text (Preview_form, PREVIEW_FLD, field_lines, 4, t_str, 0);

      if (preview_list[sort_array[y]].display_flag == 1)
      {
        UMSGetByNum (t_str2, FB_I_YES, 0);
      }
      else
      {
        UMSGetByNum (t_str2, FB_I_NO, 0);
      }

      strcpy (t_str, "   ");
      strcat (t_str, t_str2);
      FIfld_set_text (Preview_form, PREVIEW_FLD, field_lines, 5, t_str, 1);

      sprintf (t_str, "%4d", preview_list[sort_array[y]].next_in_seq);

      if (preview_list[sort_array[y]].next_in_seq == 0)
      {
        UMSGetByNum (t_str, FB_I_NONE, 0);
      }

      FIfld_set_text (Preview_form, PREVIEW_FLD, field_lines, 6, t_str, 0);

      sprintf (t_str, "%4d", preview_list[sort_array[y]].data_link);

      if (preview_list[sort_array[y]].data_link == -1)
      {
        UMSGetByNum (t_str, FB_I_NONE, 0);
      }

      FIfld_set_text (Preview_form, PREVIEW_FLD, field_lines, 7, t_str, 0);

      if (preview_list[sort_array[y]].label_flag == 1)
      {
        UMSGetByNum (t_str2, FB_I_YES, 0);
      }
      else
      {
        UMSGetByNum (t_str2, FB_I_NO, 0);
      }

      strcpy (t_str, "  ");
      strcat (t_str, t_str2);
      FIfld_set_text (Preview_form, PREVIEW_FLD, field_lines, 8, t_str, 1);

      field_lines++;
    }
  }
}

/*--------------------------------------------------------------------*/

/* ARGSUSED */
void fi_preview_form (int form_label,
                     int gadget_label,
                     double value,
                     Form form_ptr)
{
  int x, i;
  char t_str[256], t_str2[256];
  int row, column, pos;
  int selected;
  DIR *dirp;
  char temp_dir[256];
  int old_label, type;
  int dummy_int;
  int status;

  FIg_erase (Preview_form, 10);

  switch (gadget_label)
  {
  case PREVIEW_FLD:

    row = (int)value;
    if (row >= 0)
    {
      FIfld_get_select (Preview_form, PREVIEW_FLD, row, 5, &selected);

      column = 0;

      if (selected == 0)
      {
        if (preview_list[index_list[row]].display_flag == 0)
        {
          preview_list[index_list[row]].display_flag = 1;
          UMSGetByNum (t_str2, FB_I_YES, 0);
          strcpy (t_str, "   ");
          strcat (t_str, t_str2);
          FIfld_set_text (Preview_form, PREVIEW_FLD, row, 5, t_str, 1);
        }
        else
        {
          preview_list[index_list[row]].display_flag = 0;
          UMSGetByNum (t_str2, FB_I_NO, 0);
          strcpy (t_str, "   ");
          strcat (t_str, t_str2);
          FIfld_set_text (Preview_form, PREVIEW_FLD, row, 5, t_str, 1);
        }
      }

      FIfld_get_select (Preview_form, PREVIEW_FLD, row, 8, &selected);

      if (selected == 0)
      {
        if (preview_list[index_list[row]].label_flag == 0)
        {
          preview_list[index_list[row]].label_flag = 1;
          UMSGetByNum (t_str2, FB_I_YES, 0);
          strcpy (t_str, "  ");
          strcat (t_str, t_str2);
          FIfld_set_text (Preview_form, PREVIEW_FLD, row, 8, t_str, 1);
        }
        else
        {
          preview_list[index_list[row]].label_flag = 0;
          UMSGetByNum (t_str2, FB_I_NO, 0);
          strcpy (t_str, "  ");
          strcat (t_str, t_str2);
          FIfld_set_text (Preview_form, PREVIEW_FLD, row, 8, t_str, 1);
        }
      }

      FImcf_get_active_col (Preview_form, PREVIEW_FLD, &column, &pos);

      if (column == 0) /* gadget label */
      {
        FIfld_get_text (Preview_form, PREVIEW_FLD, row, 0, 255,
            (unsigned char *)t_str, &dummy_int, &pos);

        if (row >= Total_gadgets)
        {
          /* Just in case the field wasn't full */
          if (pos < 9)
          {
            pos--;
          }

          UMSGetByNum (t_str, FB_E_NONEWGDT, 0);
          print_error (Preview_form, 10, t_str);
          FIfld_set_active_row (Preview_form, PREVIEW_FLD,
              Total_gadgets - 2, pos - 1);
          return;
        }

        i = validate_integer_field (t_str, Preview_form,
            10, &status);

        old_label = preview_list[index_list[row]].gadget;
        sprintf (t_str, "%4d", old_label);

        if (status) /* Valid input */
        {
          if (i <= 10)
          {
            UMSGetByNum (t_str2, FB_E_LABGT10, 0);
            print_error (Preview_form, 10, t_str2);
            FIfld_set_text (Preview_form, PREVIEW_FLD, row, 0, t_str, 0);
          }
          else if (i >= 1000)
          {
            UMSGetByNum (t_str, FB_E_LABLT1000, 0);
            print_error (Preview_form, 10, t_str);
            FIfld_set_text (Preview_form, PREVIEW_FLD, row, 0, t_str, 0);
          }
          else
          {
            if (old_label != i) /* if value did not change, do nothing */
            {
              status = FIg_get_type (work_form, i, &type);

              if (status == FI_SUCCESS)
              {
                UMSGetByNum (t_str2, FB_E_LABELUSED, 0);
                print_error (Preview_form, 10, t_str2);
                FIfld_set_text (Preview_form, PREVIEW_FLD, row, 0,
                    t_str, 0);
              }
              else
              {
                FIg_copy (work_form, old_label, &i, 0);

                FIg_delete (work_form, old_label);

                FIg_add_to_group (work_form, i,
                    preview_list[index_list[row]].group);

                preview_list[index_list[row]].gadget = i;

                FIg_set_next_in_seq (work_form, i,
                    preview_list[index_list[row]].next_in_seq);

                FIg_set_pass_data (work_form, i,
                    preview_list[index_list[row]].data_link);

                /**************************************************/
                /* */
                /* Now all data links and sequences that used to */
                /* point to old_label need to be changed to point */
                /* to i. Also the preview_list.next_in_seq and */
                /* preview_list.data_link flags need to be */
                /* updated at the same time so they point to the */
                /* proper gadget. */
                /* */
                /**************************************************/

                for (x = 0; x < Total_gadgets; x++)
                {
                  if (preview_list[x].data_link == old_label)
                  {
                    preview_list[x].data_link = i;
                    FIg_set_pass_data (work_form,
                        preview_list[x].gadget, i);
                  }

                  if (preview_list[x].next_in_seq == old_label)
                  {
                    preview_list[x].next_in_seq = i;
                    FIg_set_next_in_seq (work_form,
                        preview_list[x].gadget, i);
                  }
                }

                /************************************************/
                /* */
                /* At this time the items in the list should be */
                /* regenerated, since many items in many rows */
                /* could have been affected. The row which is */
                /* currently being displayed as row 1 in the */
                /* window should continue to be shown in row 1 */
                /* of the window. The pos variable should */
                /* allow that to be implemented. */
                /* */
                /************************************************/

                Determine_current_preview_gadgets();

                Sort_gadgets_by_group();

                Refresh_list_text();
              }
            }
          }
        }
      }
    }

    break;

  case SAVE_TOG:

    if ((int)value == 0)
    {
      FIg_erase (Preview_form, DIR_TEXT);
      FIg_erase (Preview_form, FILE_TEXT);
      FIg_erase (Preview_form, DIR_FLD);
      FIg_erase (Preview_form, FILE_FLD);

      Save_preview_data = 0;
    }
    else
    {
      FIg_display (Preview_form, DIR_TEXT);
      FIg_display (Preview_form, FILE_TEXT);
      FIg_display (Preview_form, DIR_FLD);
      FIg_display (Preview_form, FILE_FLD);

      Save_preview_data = 1;
    }
    break;

  case DIR_FLD:

    /* Find out what the operator just typed in */

    FIfld_get_text (Preview_form, DIR_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    /* Expand the shell variables to full path and put back into field */

    strcpy (temp_dir, expand_shell_vars(t_str));

    dirp = opendir ( temp_dir );
    if ( dirp == NULL )
    {
      UMSGetByNum (t_str, FB_E_BADOPNDIR, 0);
      print_error (Preview_form, ERR_FLD, t_str);
    }
    else
    {
      FIfld_set_text (Preview_form, DIR_FLD, 0, 0, temp_dir, 0);
      strcpy (Save_preview_dir, temp_dir);
      closedir (dirp);
    }
    break;

  case FILE_FLD:

    FIfld_get_text (Preview_form, FILE_FLD, 0, 0, 255,
        (unsigned char *)t_str, &dummy_int, &dummy_int);

    if ((strlen (t_str) > 14) || (strlen (t_str) == 0))
    {

      UMSGetByNum (t_str, FB_E_BADFRMNAME, 0);

      FIfld_set_text (Preview_form, ERR_FLD, 0, 0, t_str, 0);

      FIg_display (Preview_form, ERR_FLD);

      FIfld_set_text (Preview_form, FILE_FLD, 0, 0, "", 0);
      break;
    }
    else
    {
      strcpy (Save_preview_file, t_str);
    }
    break;

  case FI_CANCEL:

    FIf_erase (Preview_form);
    FIg_set_state_off (Preview_form, FI_CANCEL);

    Refresh_work_form();

    kill_expanded_preview();
    break;

  case FI_ACCEPT:

    FIf_erase (Preview_form);
    FIg_set_state_off (Preview_form, FI_ACCEPT);

    Refresh_work_form();

    Draw_exp_preview_labels();

    if (Save_preview_data == 1)
    {
      Write_preview_data_to_disk();
    }

    kill_expanded_preview();
    break;
  }

  return;
}

/*--------------------------------------------------------------------*/

static void Display_preview_form(void)
{
  char t_str[256];
  int status;


  if (Preview_form == NULL)
  {
    strcpy (t_str, execute_dir);
    strcat (t_str, "/config/");
    strcat (t_str, language);
    strcat (t_str, "/forms/FBDsExPrv");
    status = FIf_new (532, t_str, (int (*)())fi_preview_form, &Preview_form);

    if (status != FI_SUCCESS)
    {
      Report_fatal_form_error (status, t_str);
    }
  }

  FIg_erase (Preview_form, 10);

  /******************************************************************/
  /* */
  /* Restrict the number of entries to be equal to the variable */
  /* Total_gadgets. This way the operator will not be able to */
  /* enter extra lines of text in column zero and screw things up. */
  /* */
  /******************************************************************/

  FIfld_set_max_num_rows (Preview_form, PREVIEW_FLD, Total_gadgets);

  FIfld_set_num_rows (Preview_form, PREVIEW_FLD, Total_gadgets);

  /***********************/
  /* */
  /* set up PREVIEW_FORM */
  /* */
  /***********************/

  Refresh_list_text();

  /***********************************************************/
  /* */
  /* Finally set up the save directory and filename fields */
  /* */
  /***********************************************************/

  strcpy (Save_preview_dir, dir);
  strcpy (Save_preview_file, form_attr.new_form_name);
  if (strlen (Save_preview_file) > 12)
  {
    Save_preview_file[10] = 0;
  }
  strcat (Save_preview_file, ".dmp");

  FIg_set_state (Preview_form, SAVE_TOG, 0);

  FIfld_set_text (Preview_form, DIR_FLD, 0, 0, Save_preview_dir, 0);
  FIfld_set_text (Preview_form, FILE_FLD, 0, 0, Save_preview_file, 0);
  FIg_erase (Preview_form, DIR_TEXT);
  FIg_erase (Preview_form, FILE_TEXT);
  FIg_erase (Preview_form, DIR_FLD);
  FIg_erase (Preview_form, FILE_FLD);

  FIf_display (Preview_form);

  UMSGetByNum (t_str, FB_P_FILLEXPPRV, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);
}

/*--------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* execute_expanded_preview() */
/* */
/* This function is called by the executive command handler routine. */
/* It changes values contained in the message windows and sets the */
/* builder mode to on for the work_form. As a result the gadgets will */
/* no longer change their state when poked. They will simply call their */
/* gadget notification routine. */
/* */
/*************************************************************************/

void execute_expanded_preview(void)
{
  char t_str[256];

  if (work_form == NULL)
  {
    command_is_active = 0;
    strcpy (current_command_string, "None");
  }
  else
  {
    UMSGetByNum (t_str, FB_I_EXPPRV, 0);
    FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);

    Determine_current_preview_gadgets();

    Sort_gadgets_by_group();

    Display_preview_form();

    Save_preview_data = 0;
  }
}
