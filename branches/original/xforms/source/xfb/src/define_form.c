/***********************************

		define_form.c

***********************************/

/*
  History
	04-03-92	sml		ANSI-ized; casted func args
*/

/*************************************/
/* */
/* This file contains all of the functions pertaining to the */
/* "define form" command. */
/* */
/* Programmer: Mack Draper */
/* Date: Nov. 30, 1988 */
/* */
/*************************************/


#include <sys/types.h> /*** need these two for stat() call ***/
#include <sys/stat.h>
#include <dirent.h>

#include <stdio.h>

#include <X11/Xlib.h>

#include "FI.h"
#include "NFBpriv.h"
#include "UMS.h"
#include "FB.h"
#include "FEI.h"

#include "FIform.h" /* dmb:08/28/91 */

#include "XFIproto_pub.h"
#include "XFIproto_pri.h"
#include "XFBproto_pri.h"

/***********************************/
/* */
/* Gadget labels for define form */
/* */
/***********************************/

#define BEZEL_CK 22
#define LINE_CK 23
#define NOBORDER_CK 16
#define NAME_FLD 21
#define DESC_FLD 24
#define FORM_LIST 25
#define SAVE_TOG 19
#define DIR_FLD 39
#define SCR_CK 41
#define QUAD_CK 43
#define SPECIFY_CK 44
#define DRAW_CK 45
#define DEFAULT_SCR_CK 20
#define CURRENT_SCR_CK 40
#define SPECIFY_SCR_CK 14
#define SPECIFY_SCR_FLD 17
#define FIT_FORM_CK 53
#define RESIZE_FORM_CK 67
#define REVERT_FORM_CK 68
#define FORM_SCALING_CK 69
#define HT_TEXT 11
#define WD_TEXT 18
#define HT_FLD 13
#define WD_FLD 12
#define X_FLD 15
#define Y_FLD 34
#define SEQUENCE_FLD 51
#define ACCEPT_BTN 1
#define CANCEL_BTN 4
#define HELP_BTN 6
#define MSG_FLD 10

#define KEYIN_GROUP 78
#define BORDER_GROUP 53
#define SCREEN_GROUP 52

/* These are new for 1.2.0 --- GMD */

#define DISP_TOG 54
#define SYM_FILE_FLD 56
#define SYM_NBR_FLD 57


/*************************************/
/* */
/* Global variables for this Command */
/* ( referenced in other files ) */
/* */
/*************************************/

char dir[256];
Form define_form;
char ** descript_ptr;
int start_sequence_gadget;

/*********************************************/
/* */
/* Static Global variables for this Command */
/* ( can't be referenced outside this file ) */
/* */
/*********************************************/

static char temp_string[256];
static int Line_border_flag;

static void Verify_name_field();
static void add_pwd_to_sym_dir_list();
static void create_work_form();
static void init_define_form();
static void list_directory();
static void setup_new_define_form();
static void setup_old_define_form();
static void show_define_form_info();
static void update_define_form();

/************************************/
/* */
/* External variable declarations */
/* */
/************************************/

extern struct form_data form_attr;
extern Form work_form;
extern Form Message_form;
extern struct dpb_struct dpb;
extern int command_is_active;
extern char current_command_string[80];
extern char execute_dir[200];
extern int save_restore_flag;
extern int global_form_scaling_flag;

extern int vs_x_size;
extern int vs_y_size;
extern Form save_form;

extern char language[80];
extern int SYM_dir_count;
extern char SYM_search_directory[200][256];
extern int hilite_mask;
extern Display *display;
extern GC dyn_GC, text_GC;
extern XGCValues dyn_GC_values;

/***************************************************************************/
/* */
/* kill_define_form() */
/* */
/* This function is called by the executive when three conditions are */
/* met. First the a new command has been activated by the operator */
/* pressing a menu button. Secondly command_is_active flag is set to */
/* DEFINE_FORM indicating that this command is executing. Thirdly the */
/* command autokill flag is set. */
/* */
/* This command provides a graceful freeing up of any resources that */
/* might be tied up by the define form command. If the define form is */
/* still displayed, then it will be deleted. Also the message prompts */
/* will be cleared in preparation for the new command, whatever it is. */
/* */
/***************************************************************************/

void kill_define_form(void)
{
  if (define_form != NULL)
  {
    FIf_erase (define_form);
  }

  FIfld_set_text (Message_form, 11, 0, 0, "", 0);
  FIfld_set_text (Message_form, 44, 0, 0, "", 0);

  UMSGetByNum (temp_string, FB_P_SELCOM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, temp_string, 0);

  if (save_form != NULL)
  {
    FIf_erase (save_form);
  }

  command_is_active = 0;
  strcpy(current_command_string, "None");
}

/*------------------------------------------------------------------------*/

/*******************************************************************/
/* */
/* _is_a_form(file, directory) */
/* */
/* This function determines whether or not a specified file is */
/* a form. The function attempts to open the file. If it fails */
/* then a FALSE value will be returned to the caller. */
/* */
/* If the file exists the both the ascii version and binary */
/* form headers will be checked for. If the format is valid then */
/* a true value will be returned to the caller, otherwise a false */
/* value will be returned to the caller. */
/* */
/* The function expects two string values. The first is the */
/* name of the file that you wish to check. The second is the */
/* full path of the directory that the file is located in. If you */
/* wish to look in the current directory, then specify a null */
/* string for the directory. */
/* */
/*******************************************************************/

int _is_a_form (char *file,
                char *directory)
{
  FILE * fp;
  char name[16];
  char path[256];
  short version;
  struct stat stat_buf;
  extern int stat();

  if (strlen (directory))
  {
    strcpy (path, directory);
    strcat (path, "/");
    strcat (path, file);
  }
  else
  {
    strcpy (path, file);
  }

  /*** see if this file exists, and is a regular file, or a ***/
  /*** symbolic link ***/
  /* sml:05-13-92  removed reference to link (non-POSIX) and use S_ISREG
                   macro for consistency between clipper and sun */
  if ( !stat( path, &stat_buf ) &&
     S_ISREG(stat_buf.st_mode) )     /*( ( stat_buf.st_mode & S_IFREG ) ||*/
/*     ( stat_buf.st_mode & S_IFLNK ) ) )       */
  {
    /*** it could be a form file ***/
  }
  else
  {
    return ( FALSE );
  }

  if (( fp = fopen(path,"r")) == NULL )
  {
    return ( FALSE );
  }

  if (fread(name, 8, 1, fp) != 1)
  {
    fclose (fp);
    return (FALSE);
  }

  /*** Only accept binary format files for now. ***/

  if ( !strncmp ( name+2, "FIform", 6 ) )
  {
    if ( FI_read_short (fp, &version) != FI_SUCCESS )
    {
      fclose ( fp );
      return (FALSE);
    }

/* fprintf(stderr,"Version is %d\n",version); */

    if ( version >= 3 )
    {
      fclose ( fp );

      return ( TRUE );
    }
  }

  fclose (fp);

  return ( FALSE );
}

/*-------------------------------------------------------------------------*/

/**********************************************************************/
/* */
/* list_directory() */
/* */
/* This function is used to read the contents of a directory and */
/* then list all valid form files to the define form's multi-line */
/* FORM_LIST gadget. The directory to be searched is contained in */
/* the global variable dir. */
/* */
/**********************************************************************/

static void list_directory(void)
{
  struct dirent *dp;
  DIR *dirp;
  char form_filename[2000][16];
  char *sorted_filename[2000];
  char *temp_filename;
  int x, y, z;


  if ( (dirp = opendir ( (char *) dir)) == NULL )
  {
    UMSGetByNum (temp_string, FB_E_BADOPNDIR, 0);
    print_error (define_form, MSG_FLD, temp_string);
    FIfld_set_num_rows (define_form, FORM_LIST, 0);
    return;
  }
  else
  {
    UMSGetByNum (temp_string, FB_I_SCANFILE, 0);

    x = 0;
    while (( dp = readdir ( dirp )) != NULL )
    {
      if (( strcmp ( dp->d_name, ".." ) != 0 ) &&
          ( strcmp ( dp->d_name, "." ) != 0 ))
      {
        if ( _is_a_form ( dp->d_name, dir ) )
        {
          strcpy( form_filename[x], dp->d_name );
          sorted_filename[x] = form_filename[x];

          x++;
        }
      }
    }

    closedir ( dirp );

    if ( x ) /* There are forms in the directory */
    {
      FIfld_set_num_rows (define_form, FORM_LIST, 0);

      if (x == 1) /* Only one entry, so no need to sort */
      {
        FIfld_set_text(define_form, FORM_LIST, 0, 0,
            form_filename[0], 0);
      }
      else /* Need to sort the files into alphabetical order */
      { /* before placing them into the form. */

        for (y=0; y < x - 1; y++)
        {
          for (z=y+1; z < x; z++)
          {
            if ( strcmp (sorted_filename[y], sorted_filename[z]) > 0 )
            {
              temp_filename = sorted_filename[y];
              sorted_filename[y] = sorted_filename[z];
              sorted_filename[z] = temp_filename;
            }
          }
        }

        /* Now that they are sorted, place them into the form */

        FIg_erase (define_form, FORM_LIST);

        FIfld_set_num_rows (define_form, FORM_LIST, x);

        for (y = 0; y < x; y++)
        {
          FIfld_set_text(define_form, FORM_LIST, y, 0,
              sorted_filename[y], 0);
        }
      }

      FIfld_set_active_row (define_form, FORM_LIST, 0, 0);

      FIg_display (define_form, FORM_LIST);

      FIg_erase(define_form, MSG_FLD);
    }
    else
    {
      UMSGetByNum (temp_string, FB_E_NOIFORMS, 0);
      print_error (define_form, MSG_FLD, temp_string);

      FIfld_set_num_rows (define_form, FORM_LIST, 0);
    }
  }
}

/*-------------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* init_define_form() */
/* */
/* This function performs operations that need to be done as soon as */
/* the define form is displayed, but before the operator can interact */
/* with the define form. There are several hidden gadgets that need */
/* to be displayed, as well as setting up the default directory and */
/* form filelist. */
/* */
/*************************************************************************/

static void init_define_form(void)
{
  FIg_erase (define_form, SPECIFY_SCR_FLD);
  FIg_set_state_off (define_form, SPECIFY_SCR_CK);
  FIg_set_state_off (define_form, CURRENT_SCR_CK);
  FIg_set_state_on (define_form, DEFAULT_SCR_CK);

  if ( dir[0] == (char) NULL )
  {
    strcpy (dir, expand_shell_vars("."));
  }

  FIfld_set_text(define_form, DIR_FLD, 0, 0, (char *) dir, 0);

  list_directory();
}

/*-----------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* setup_new_define_form() */
/* */
/* This function is called each time the operator types in a */
/* non-existant filename, or the name of a file that is not a form */
/* definition file. It prepares the form_attr structure with default */
/* settings which will be displayed in the define form's fields when the */
/* show_define_form_info() function is called immediately after this */
/* function finishes. How is that for a run-on sentence? */
/* */
/*************************************************************************/

static void setup_new_define_form(void)
{
  strcpy(form_attr.new_form_name, form_attr.form_name);
  form_attr.form_name[0] = (char) NULL;

  /*
  FIfld_set_text (define_form, DESC_FLD, 0, 0, " ", 0);
  */

  FIfld_set_num_rows (define_form, DESC_FLD, 0);

  form_attr.screen_number = FI_DEFAULT_SCRN;
  form_attr.absolute_screen = 0;
  form_attr.symbol_number = 0;
  strcpy ( form_attr.symbol_file, "collapse.icon" );
  form_attr.win_x1 = 0;
  form_attr.win_y1 = 76;

  form_attr.x_size = (vs_x_size - 187) / 2;
  form_attr.y_size = (vs_y_size - 105) / 2;

  form_attr.win_x2 = form_attr.win_x1 + form_attr.x_size;
  form_attr.win_y2 = form_attr.win_y1 + form_attr.y_size;

  /*
  form_attr.win_x2 = 497;
  form_attr.win_y2 = 459;
  form_attr.x_size = 497;
  form_attr.y_size = 391;
  */

  form_attr.collapse = 0;
  form_attr.sr_flag = 0;
  form_attr.border_flag = 1;
  Line_border_flag = 0;

  form_attr.resize_flag = 1;
  form_attr.scaling_flag = 1;

  start_sequence_gadget = 0;
}

/*-----------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* setup_old_define_form() */
/* */
/* This function is called each time the operator types in a */
/* the name of a form file or selects a form from the form list multi- */
/* line field. It prepares the form_attr structure by loading in the */
/* existing settings from the form file. First a new form is built. */
/* Next a variety of FIf_get_XXX() calls are made to determine the */
/* form's current settings. These settings are stored in the form_attr */
/* structure. The settings will be used to alter the define form's */
/* fields when the show_define_form_info function is called immediately */
/* after this function concludes. */
/* */
/*************************************************************************/

static void setup_old_define_form(void)
{
  int status;
  int num_desc;
  int xx;
  long form_mask; /* Used to retrieve form attributes such as: */
                 /* save/restore window enabled */
                 /* form border enabled */
                 /* form collapse enable */

  add_pwd_to_sym_dir_list();

  strcpy(form_attr.new_form_name, form_attr.form_name);

  strcpy (temp_string, dir);
  strcat (temp_string, "/");
  strcat (temp_string, form_attr.form_name);

  status = FIf_new(F_work, temp_string, (int (*)())fi_work_form, &work_form);

  if (status != FI_SUCCESS)
  {
    form_attr.form_name[0] = (char) NULL;
    form_attr.new_form_name[0] = (char) NULL;

    UMSGetByNum (temp_string, FB_E_BADFRMT, "%d", status);
    print_error (define_form, MSG_FLD, temp_string);

    FIfld_set_text (define_form, NAME_FLD, 0, 0, "", 0);

    work_form = NULL;
    return;
  }

  /* Clear description field */
  FIfld_set_num_rows (define_form, DESC_FLD, 0);
  FIfld_set_text (define_form, DESC_FLD, 0, 0, " ", 0);

  /******************************************/
  /* Read existing form's description field */
  /******************************************/

  FIf_get_description ((struct FIform_obj *)work_form, &num_desc, &descript_ptr);

  for (xx = 0; xx < num_desc; xx++)
  {
    FIfld_set_text ( define_form, DESC_FLD, xx, 0,
        descript_ptr[xx], 0 );
  }

  /*
  FIfld_set_num_rows (define_form, DESC_FLD, num_desc);
  */

  FIf_get_location (work_form, &form_attr.win_x1, &form_attr.win_y1);

  FIf_get_size (work_form, &form_attr.x_size, &form_attr.y_size);

  FIf_get_color (work_form, &dpb.bgcolor);

  FIf_get_Xscreen (work_form, &form_attr.screen_number, 
                              &form_attr.absolute_screen);

/* dmb:09/13/91 
  _is_a_form (form_attr.form_name, dir);
*/

  FIf_get_collapse_symbol (work_form, form_attr.symbol_file,
      &form_attr.symbol_number);

  FIf_get_attr (work_form, &form_mask);

  if (form_mask & FI_SAVE_RESTORE)
  {
    form_attr.sr_flag = 1;
  }
  else
  {
    form_attr.sr_flag = 0;
  }

  if (form_mask & FI_NO_BEZEL)
    form_attr.border_flag = 0;
  else
    form_attr.border_flag = 1;

  if (form_mask & FI_LINE_BORDER)
    Line_border_flag = 1;
  else
    Line_border_flag = 0;

  if (form_mask & FI_DISPLAY_COLLAPSED)
    form_attr.collapse = 1;
  else
    form_attr.collapse = 0;

  /********************************************************************/
  /* */
  /* Here I need to check to see if the following modes are enabled */
  /* and set the form_attr values if they are: */
  /* */
  /* form resizing */
  /* scale form */
  /* */
  /********************************************************************/

  if (form_mask & FI_NOT_SCALABLE)
    form_attr.scaling_flag = 0;
  else
    form_attr.scaling_flag = 1;

  if (form_mask & FI_NOT_RESIZABLE)
    form_attr.resize_flag = 0;
  else
    form_attr.resize_flag = 1;

  FIf_get_start_seq (work_form, &start_sequence_gadget);

  FIf_delete (work_form);

  work_form = NULL;
}

/*-----------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* show_define_form_info() */
/* */
/* This function displays the information contained in the */
/* form_attr structure in the various corresponding define form fields. */
/* */
/*************************************************************************/

static void show_define_form_info(void)
{
  int ii;
  char temp_string2[256];
  char t_str[256];

  FIg_set_state (define_form, SAVE_TOG, form_attr.sr_flag);

  FIg_set_state (define_form, DISP_TOG, form_attr.collapse);

  FIg_set_state_off (define_form, BORDER_GROUP);

  if (Line_border_flag == 1)
  {
    FIg_set_state_on (define_form, LINE_CK);
  }
  else
  {
    if (form_attr.border_flag == 1)
      FIg_set_state_on (define_form, BEZEL_CK);
    else
      FIg_set_state_on (define_form, NOBORDER_CK);
  }

  FIg_set_state (define_form, RESIZE_FORM_CK, form_attr.resize_flag);

  FIg_set_state (define_form, FORM_SCALING_CK, form_attr.scaling_flag);

  FIg_set_state_off (define_form, QUAD_CK);
  FIg_set_state_off (define_form, SCR_CK);
  FIg_set_state_off (define_form, DRAW_CK);
  FIg_set_state_off (define_form, SPECIFY_CK);

  if ((form_attr.y_size == ((vs_y_size - 105) / 2)) &&
      (form_attr.x_size == ((vs_x_size - 187) / 2)))
  {
    FIg_set_state_on (define_form, QUAD_CK);
  }
  else if ((form_attr.y_size == (vs_y_size - 105)) &&
      (form_attr.x_size == (vs_x_size - 187)))
  {
    FIg_set_state_on (define_form, SCR_CK);
  }
  else
  {
    FIg_set_state_on (define_form, SPECIFY_CK);
  }

  form_attr.draw_flag = 0;

  ii = form_attr.y_size;
  sprintf (temp_string2, "%d", ii);
  FIfld_set_text(define_form, HT_FLD, 0, 0, temp_string2, 0);

  ii = form_attr.x_size;
  sprintf (temp_string2, "%d", ii);
  FIfld_set_text(define_form, WD_FLD, 0, 0, temp_string2, 0);

  FIg_set_state_off (define_form, SCREEN_GROUP);

  if ( form_attr.screen_number == FI_DEFAULT_SCRN )
  {
    FIg_set_state_off (define_form, SPECIFY_SCR_CK);
    FIg_erase (define_form, SPECIFY_SCR_FLD);
    FIg_set_state_off (define_form, CURRENT_SCR_CK);
    FIg_set_state_on (define_form, DEFAULT_SCR_CK);
  }
  else if (form_attr.screen_number == FI_CURRENT_SCRN)
  {
    FIg_set_state_off (define_form, SPECIFY_SCR_CK);
    FIg_erase (define_form, SPECIFY_SCR_FLD);
    FIg_set_state_off (define_form, DEFAULT_SCR_CK);
    FIg_set_state_on (define_form, CURRENT_SCR_CK);
  }
  else
  {
    FIg_set_state_off (define_form, DEFAULT_SCR_CK);
    FIg_set_state_off (define_form, CURRENT_SCR_CK);
    FIg_set_state_on (define_form, SPECIFY_SCR_CK);
    sprintf (t_str, "%d", form_attr.absolute_screen);
    FIg_set_text (define_form, SPECIFY_SCR_FLD, t_str);
    FIg_display (define_form, SPECIFY_SCR_FLD);
  }

  if (form_attr.symbol_file[0] == 0) /* Null string */
  {
    FIfld_set_text(define_form, SYM_FILE_FLD, 0, 0,
        "collapse.icon", 0);

    FIfld_set_text(define_form, SYM_NBR_FLD, 0, 0, "0", 0);
  }
  else
  {
    FIfld_set_text(define_form, SYM_FILE_FLD, 0, 0,
        form_attr.symbol_file, 0);

    sprintf(temp_string2, "%d", form_attr.symbol_number);
    FIfld_set_text(define_form, SYM_NBR_FLD, 0, 0, temp_string2, 0);
  }

  sprintf(temp_string2, "%d", form_attr.y_size);

  FIfld_set_text (define_form, HT_FLD, 0, 0, temp_string2, 0);

  sprintf(temp_string2, "%d", form_attr.x_size);

  FIfld_set_text (define_form, WD_FLD, 0, 0, temp_string2, 0);

  sprintf (temp_string2, "%d", form_attr.win_x1);

  FIfld_set_text (define_form, X_FLD, 0, 0, temp_string2, 0);

  sprintf (temp_string2, "%d", form_attr.win_y1);

  FIfld_set_text (define_form, Y_FLD, 0, 0, temp_string2, 0);

  FIg_display (define_form, KEYIN_GROUP);

  if (start_sequence_gadget != 0)
  {
    sprintf (temp_string2, "%d", start_sequence_gadget);
    FIfld_set_text (define_form, SEQUENCE_FLD, 0, 0, temp_string2, 0);
  }
  else
  {
    FIfld_set_text (define_form, SEQUENCE_FLD, 0, 0, "", 0);
  }
}


/*********************************************************************/
/* */
/* create_work_form() */
/* */
/* This function creates the form that the operator wishes to */
/* define/modify. At the present time only one form can be worked */
/* on at a time. This may be expanded in the future. */
/* */
/*********************************************************************/

static void create_work_form(void)
{
  int xx;
  int length;
  int dummy_int;
  int existing_rows;
  long form_mask;
  int num_desc;
  long mask;
  long and_mask;
  char temp_str[3000];

  /******************************/
  /* */
  /* Create the new work form */
  /* */
  /******************************/

  if (form_attr.form_name[0] != (char) NULL)
  {
    strcpy (temp_string, dir);
    strcat (temp_string, "/");
    strcat (temp_string, form_attr.form_name);
  }
  else /* New form */
  {
    temp_string[0] = (char) NULL;
  }

  FIf_new (F_work, temp_string, (int (*)())fi_work_form, &work_form);

  FIf_set_window_event_routine (work_form, (int (*)())window_event_grid_check);

  if (!hilite_mask)
  {
    int color, (*my_translate_color)();
    unsigned long foreground;

    FIf_get_color( work_form, &color );

    FI_get_env (FI_TRANSLATE_COLOR, &my_translate_color);

    /* GMD 12/17/91  Change highlight color to green to fix disappearing
                     text bug in move command.                             */

    foreground = (*my_translate_color)( 0, FI_GREEN )
        ^(*my_translate_color)( 0, color );
    XSetForeground (display, dyn_GC, foreground);
  }

  /************************************/
  /* */
  /* While in the builder, all form manipulation icons will be */
  /* activated. When the form is saved, the icon settings from */
  /* the define form will be enforced.*/
  /* */
  /************************************/

  FIf_get_attr (work_form, &mask);
  and_mask = 65535;

  if (global_form_scaling_flag == 0)
  {
    mask |= FI_NOT_SCALABLE;
  }
  else
  {
    and_mask ^= FI_NOT_SCALABLE;
  }

  and_mask ^= FI_NOT_RESIZABLE; /* Allow resizing */
  mask &= and_mask;
  FIf_set_attr (work_form, mask);

  /***********************************************************************/
  /*                                                                     */
  /* Override default settings with those obtained from the define form. */
  /*                                                                     */
  /***********************************************************************/

  FIf_set_Xscreen (work_form, FI_DEFAULT_SCRN, 0);   /* Always display forms */
                                                     /* on the default scrn  */
                                                     /* while in XFB.        */

  FIf_set_location (work_form, form_attr.win_x1, form_attr.win_y1);

  FIf_set_size (work_form, form_attr.x_size, form_attr.y_size);

  FIf_set_orig_size (work_form, form_attr.x_size - 1, 
      form_attr.y_size - 1);

  FIf_set_color (work_form, dpb.bgcolor);

  FIf_set_collapse_symbol (work_form, form_attr.symbol_file,
      form_attr.symbol_number);

  form_mask = 0;

  if (form_attr.sr_flag)
    save_restore_flag = 1;
  else
    save_restore_flag = 0;

  if (form_attr.border_flag == 0)
    form_mask |= FI_NO_BEZEL;

  if (Line_border_flag == 1)
    form_mask |= FI_LINE_BORDER;

  if (form_attr.collapse)
    form_mask |= FI_DISPLAY_COLLAPSED;

  FIf_set_attr (work_form, form_mask);

  FIf_get_attr (work_form, &mask);
  and_mask = 65535;

  if (global_form_scaling_flag == 0)
  {
    mask |= FI_NOT_SCALABLE;
  }
  else
  {
    and_mask ^= FI_NOT_SCALABLE;
  }

  and_mask ^= FI_NOT_RESIZABLE; /* Allow resizing */
  mask &= and_mask;
  FIf_set_attr (work_form, mask);

  /***************************************************/
  /* */
  /* Override the strings in the description field */
  /* */
  /***************************************************/

  FIf_get_description ((struct FIform_obj *)work_form, &existing_rows, &descript_ptr);

  FIfld_get_num_rows(define_form, DESC_FLD, &num_desc);

  if (existing_rows > 0) /* old form */
  {
    for (xx = 0; xx < existing_rows; xx++)
    {
      if (*(descript_ptr[xx]))
      {
        _FI_free ( (void *) descript_ptr[xx] ); /* dmb:08/29/92:Exp cast */
        descript_ptr[xx] = 0;
      }
    }

    descript_ptr = (char **)realloc (descript_ptr, num_desc * 4);
  }
  else /* new form */
  {
    descript_ptr = (char **)calloc (num_desc, 4);
  }

  for (xx = 0; xx < num_desc; xx++)
  {
    FIfld_get_text_length(define_form, DESC_FLD, xx, 0, &length);

    FIfld_get_text (define_form, DESC_FLD, xx, 0, length,
        (unsigned char *)temp_str, &dummy_int, &dummy_int);

    descript_ptr[xx] = calloc (length + 1, sizeof(char));

    if (temp_str[0] != 0)
      strcpy (descript_ptr[xx], temp_str);
  }

  FIf_erase (define_form);

  FIf_set_description((struct FIform_obj *)work_form, num_desc, descript_ptr);

  FIf_set_start_seq (work_form, start_sequence_gadget);

  /****************************/
  /* */
  /* Finally display the form */
  /* */
  /****************************/

  FIf_display(work_form);

  /******************/
  /* See "grid.c" */
  if (dpb.grid_flag)
    display_grid_on_work_form();
  /******************/
}


/*-----------------------------------------------------------------------*/

/* ARGSUSED */
void fi_background_form (int form_label,
                        int gadget_label,
                        double value,
                        Form form_ptr)
{
  /* Dummy routine needed to poke new form's boundaries */
  return;
}

/*---------------------------------------------------------------------------*/

static void Verify_name_field(void)
{
  int dummy_int;

  FIfld_get_text(define_form, NAME_FLD, 0, 0, 255,
      (unsigned char *)temp_string, &dummy_int, &dummy_int);

  if (strlen(temp_string) > 14)
  {
    UMSGetByNum (temp_string, FB_E_BADFRMNAME, 0);
    print_error (define_form, MSG_FLD, temp_string);

    FIfld_set_text(define_form, NAME_FLD, 0, 0, "", 0);
  }
  else
  {
    if (strcmp(temp_string, form_attr.form_name))
    {
      strcpy(form_attr.form_name, temp_string);

      if (form_attr.form_name[0] == (char) NULL)
        form_attr.new_form_name[0] = (char) NULL;

      update_define_form();
    }
  }
}

/*************************************************************************/
/* */
/* fi_define_form() */
/* */
/* This massive function works in the same manner as the form_input */
/* method did in the OM world. (Boo! Hiss!!!) */
/* */
/* There is quite a collection of gadgets, so rather than talking */
/* about them all up here I have incorporated comments with some of the */
/* more difficult or important gadgets that are being serviced by this */
/* routine. */
/* */
/* The naming convention for all of my gadget notification routines */
/* will start with "fi" for form input. */
/* */
/*************************************************************************/

/* ARGSUSED */
void fi_define_form(int form_label,
                   int gadget_label,
                   double value,
                   Form form_ptr)
{
  Form background_form = NULL;
  int ii, jj;
  int num_flag;
  int sym_value;
  char sym_name[6];
  Window window;	/* change from int to Window for ANSI */
  int anchor_x, anchor_y;
  int x_lo, y_lo, x_hi, y_hi;
  int dummy_int;
  char t_str[256];
  int screen_number;
  int status;

  FIg_erase (define_form, MSG_FLD);

  switch ( form_label )
  {
  case F_define:
    switch ( gadget_label )
    {
    case DIR_FLD:

      /* Find out what the operator just typed in */

      FIfld_get_text(define_form, DIR_FLD, 0, 0, 255,
          (unsigned char *)temp_string, &dummy_int, &dummy_int);

      /* Expand the shell variables to full path and put back into field */

      strcpy(dir, expand_shell_vars(temp_string));

      FIfld_set_text(define_form, DIR_FLD, 0, 0, (char *) dir, 0);

      list_directory();

      break;

    case FORM_LIST:
      /* value contains the index of the item which was just selected */
      ii = (int)value;


      if (ii >= 0)
      {
        FIfld_get_text(define_form, FORM_LIST, ii, 0, 255,
            (unsigned char *)temp_string, &dummy_int, &dummy_int);

        strcpy ( form_attr.form_name, temp_string);

        FIfld_set_text(define_form, NAME_FLD, 0, 0, temp_string, 0);

        update_define_form();
      }
      break;

    case NAME_FLD:

      Verify_name_field();
      break;

    case DESC_FLD:

      FIfld_get_text(define_form, DESC_FLD, (int)value, 0, 255,
          (unsigned char *)temp_string, &dummy_int, &dummy_int);

      strcpy ( form_attr.desc[(int)value], temp_string );
      break;

    case SAVE_TOG:

      form_attr.sr_flag = (int)value;
      break;

    case DEFAULT_SCR_CK:

      form_attr.screen_number = FI_DEFAULT_SCRN;
      FIg_set_state_off (define_form, CURRENT_SCR_CK);
      FIg_set_state_off (define_form, SPECIFY_SCR_CK);
      FIg_erase (define_form, SPECIFY_SCR_FLD);
      break;

    case CURRENT_SCR_CK:

      form_attr.screen_number = FI_CURRENT_SCRN;
      FIg_set_state_off (define_form, DEFAULT_SCR_CK);
      FIg_set_state_off (define_form, SPECIFY_SCR_CK);
      FIg_erase (define_form, SPECIFY_SCR_FLD);
      break;

    case SPECIFY_SCR_CK:

      FIg_set_state_off (define_form, DEFAULT_SCR_CK);
      FIg_set_state_off (define_form, CURRENT_SCR_CK);
      FIg_display (define_form, SPECIFY_SCR_FLD);
      FIg_get_text (define_form, SPECIFY_SCR_FLD, t_str);
      form_attr.screen_number = FI_HARDCODED_SCRN;
      form_attr.absolute_screen = atoi (t_str);
      break;

    case SPECIFY_SCR_FLD:

      FIg_get_text (define_form, SPECIFY_SCR_FLD, t_str);
      screen_number = atoi (t_str);
      if ((screen_number > 7) || (screen_number < 0))
      {
        UMSGetByNum (temp_string, FB_E_BADSCRN, 0);

        print_error (define_form, MSG_FLD, temp_string);
      }
      else
      {
        form_attr.absolute_screen = screen_number;
      }
      break;

    case BEZEL_CK:

      form_attr.border_flag = 1;
      Line_border_flag = 0;
      break;

    case NOBORDER_CK:

      form_attr.border_flag = 0;
      Line_border_flag = 0;
      break;

    case LINE_CK:

      Line_border_flag = 1;
      form_attr.border_flag = 0;
      break;

    case RESIZE_FORM_CK:

      form_attr.resize_flag = (int)value;
      break;

    case FORM_SCALING_CK:

      form_attr.scaling_flag = (int)value;
      break;

    case SCR_CK:

      form_attr.draw_flag = 0;

      form_attr.x_size = vs_x_size - 187;
      form_attr.y_size = vs_y_size - 105;

      form_attr.win_x1 = 0;
      form_attr.win_y1 = 50;

      sprintf(temp_string, "%d", form_attr.x_size);
      FIfld_set_text (define_form, WD_FLD, 0, 0, temp_string, 0);

      sprintf(temp_string, "%d", form_attr.y_size);
      FIfld_set_text (define_form, HT_FLD, 0, 0, temp_string, 0);

      FIfld_set_text (define_form, X_FLD, 0, 0, "0", 0);
      FIfld_set_text (define_form, Y_FLD, 0, 0, "50", 0);
      break;

    case QUAD_CK:

      form_attr.draw_flag = 0;

      form_attr.win_x1 = 0;
      form_attr.win_y1 = 50;
      form_attr.x_size = (vs_x_size - 187) / 2;
      form_attr.y_size = (vs_y_size - 105) / 2;

      sprintf(temp_string, "%d", form_attr.x_size);
      FIfld_set_text (define_form, WD_FLD, 0, 0, temp_string, 0);

      sprintf(temp_string, "%d", form_attr.y_size);
      FIfld_set_text (define_form, HT_FLD, 0, 0, temp_string, 0);
      FIfld_set_text (define_form, X_FLD, 0, 0, "0", 0);
      FIfld_set_text (define_form, Y_FLD, 0, 0, "50", 0);
      break;

    case SPECIFY_CK:

      form_attr.draw_flag = 0;

      sprintf(temp_string, "%d", form_attr.x_size);
      FIfld_set_text (define_form, WD_FLD, 0, 0, temp_string, 0);

      sprintf(temp_string, "%d", form_attr.y_size);
      FIfld_set_text (define_form, HT_FLD, 0, 0, temp_string, 0);
      break;

    case DRAW_CK:

      form_attr.draw_flag = 1;

      FIfld_set_text(define_form, HT_FLD, 0, 0, " ", 0);

      FIfld_set_text(define_form, WD_FLD, 0, 0, " ", 0);

      FIfld_set_text(define_form, X_FLD, 0, 0, " ", 0);

      FIfld_set_text(define_form, Y_FLD, 0, 0, " ", 0);
      break;

    case HT_FLD:

      FIg_set_state_on (define_form, SPECIFY_CK);
      FIg_set_state_off (define_form, SCR_CK);
      FIg_set_state_off (define_form, DRAW_CK);
      FIg_set_state_off (define_form, QUAD_CK);

      FIfld_get_text(define_form, HT_FLD, (int)value, 0, 255,
          (unsigned char *)temp_string, &dummy_int, &dummy_int);

      ii = validate_integer_field (temp_string,
          define_form, MSG_FLD, &status);

      if (status)
      {
        if ( ii > 0 )
        {
          form_attr.win_y2 = ii + form_attr.win_y1;
          form_attr.y_size = ii;
        }
        else
        {
          UMSGetByNum (temp_string, FB_E_BADHT, 0);

          print_error (define_form, MSG_FLD, temp_string);
        }
      }
      break;

    case WD_FLD:

      FIg_set_state_on (define_form, SPECIFY_CK);
      FIg_set_state_off (define_form, SCR_CK);
      FIg_set_state_off (define_form, DRAW_CK);
      FIg_set_state_off (define_form, QUAD_CK);

      FIfld_get_text(define_form, WD_FLD, (int)value, 0, 255,
          (unsigned char *)temp_string, &dummy_int, &dummy_int);

      ii = validate_integer_field (temp_string,
          define_form, MSG_FLD, &status);

      if (status)
      {
        if ( ii > 0 )
        {
          form_attr.win_x2 = ii + form_attr.win_x1;
          form_attr.x_size = ii;
        }
        else
        {
          UMSGetByNum (temp_string, FB_E_BADWD, 0);
          print_error (define_form, MSG_FLD, temp_string);
        }
      }
      break;

    case X_FLD:

      FIfld_get_text(define_form, X_FLD, (int)value, 0, 255,
          (unsigned char *)temp_string, &dummy_int, &dummy_int);

      ii = validate_integer_field (temp_string,
          define_form, MSG_FLD, &status);

      if (status)
      {
        if (( ii >= 0 ) && (ii <= vs_x_size))
        {
          form_attr.win_x2 = ii + form_attr.x_size;
          form_attr.win_x1 = ii;
        }
        else
        {
          if (ii <= 0)
          {
            UMSGetByNum (temp_string, FB_E_FRMXNOTNEG, 0);
          }
          else
          {
            UMSGetByNum (temp_string, FB_E_FRMBADX, "%d",
                vs_x_size);
          }

          print_error (define_form, MSG_FLD, temp_string);
        }
      }
      break;

    case Y_FLD:

      FIfld_get_text(define_form, Y_FLD, (int)value, 0, 255,
          (unsigned char *)temp_string, &dummy_int, &dummy_int);

      ii = validate_integer_field (temp_string,
          define_form, MSG_FLD, &status);

      if (status)
      {
        if (( ii >= 0 ) && (ii <= vs_y_size))
        {
          form_attr.win_y2 = ii + form_attr.y_size;
          form_attr.win_y1 = ii;
        }
        else
        {
          if (ii <= 0)
            UMSGetByNum (temp_string, FB_E_FRMYNOTNEG, 0);
          else
            UMSGetByNum (temp_string, FB_E_FRMBADY, "%d",
                vs_y_size - 50);

          print_error (define_form, MSG_FLD, temp_string);
        }
      }
      break;

    case ACCEPT_BTN:

      FIg_set_state_off (define_form, ACCEPT_BTN);

      if ( form_attr.new_form_name[0] == '\0' )
      {
        UMSGetByNum (temp_string, FB_E_NONAME, 0);
        print_error (define_form, MSG_FLD, temp_string);
        return;
      }
      else
      {
        FIf_erase (define_form);

        if (form_attr.draw_flag)
        {
          int save_boundary_mode;

          save_boundary_mode = 0;

          if (background_form == NULL)
          {
            strcpy (temp_string, execute_dir);
            strcat (temp_string, "/config/");
            strcat (temp_string, language);
            strcat (temp_string, "/forms/FBBckgnd");

            status = FIf_new (250, temp_string,
                (int (*)())fi_background_form, &background_form);

            if (status != FI_SUCCESS)
              Report_fatal_form_error (status, temp_string);
          }

/*          FIf_set_size (background_form, vs_x_size, vs_y_size); XFB */
          FIf_set_size (background_form, vs_x_size, vs_y_size - 300);

          FIf_set_location (background_form, 0, 0);

          FIg_erase (background_form, 11);

          FIf_set_color (background_form, FI_BLACK);

          FIf_set_attr (background_form, FI_NO_BEZEL);

          FIf_display (background_form);

          UMSGetByNum (t_str, FB_P_POKFRMANC, 0);
          FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

          FIf_get_window (background_form, &window);

          status = Get_first_point (window,
              &anchor_x, &anchor_y, 0, 0, 0, 0);

          if (status == 2) /* Success */
          {
            UMSGetByNum (t_str, FB_I_ANCX, "%d%d",
                anchor_x, anchor_y);
            FIfld_set_text (Message_form, 22, 0, 0, t_str, 0);
            UMSGetByNum (t_str, FB_P_POKFRMSWG, 0);
            FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

            if (dpb.expansion4 == 1)
            {
              dpb.expansion4 = 0;
              save_boundary_mode = 1;
            }

            status = Get_second_point (window,
                anchor_x, anchor_y,
                &x_lo, &y_lo, &x_hi, &y_hi, 0, -1);

            FIfld_set_text (Message_form, 22, 0, 0, "", 0);

            dpb.expansion4 = save_boundary_mode;

            if (status == 2) /* Success */
            {
              form_attr.win_x1 = x_lo;
              form_attr.win_y1 = y_lo;
              form_attr.x_size = x_hi - x_lo;
              form_attr.y_size = y_hi - y_lo;
            }
            else /* Operator wants to kill this command */
            {
              FIf_erase (background_form);
              return;
            }
          }
          else /* Operator wants to kill this command */
          {
            FIf_erase (background_form);
            return;
          }
          FIf_erase (background_form);
        }

        /* All is ready, so let's create the new work_form !!! */

        UMSGetByNum (t_str, FB_I_DEFINE, 0);
        FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
        UMSGetByNum (t_str, FB_I_DISPWRKFRM, 0);
        FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

        create_work_form();

        FIfld_set_text (Message_form, 11, 0, 0, "", 0);
        FIfld_set_text (Message_form, 44, 0, 0, "", 0);
        UMSGetByNum (t_str, FB_P_SELCOM, 0);
        FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

        command_is_active = 0;
        strcpy(current_command_string, "None");

        add_pwd_to_sym_dir_list();

      }
      break;

    case HELP_BTN:

      /*
      Help_topic ( "Define" );
      */

      FIg_erase(define_form, MSG_FLD);
      break;

    case CANCEL_BTN:

      form_attr.new_form_name[0] = 0; /* Clear form name */
      form_attr.form_name[0] = 0; /* Clear form name */
      kill_define_form();
      FIg_set_state_off (define_form, FI_CANCEL);
      break;

      /* These gadgets are new for version 1.2 --- GMD */

    case SEQUENCE_FLD:

      FIfld_get_text(define_form, SEQUENCE_FLD, (int)value, 0, 255,
          (unsigned char *)temp_string, &dummy_int, &dummy_int);

      ii = validate_integer_field (temp_string,
          define_form, MSG_FLD, &status);

      if (status)
      {
        if (( ii > 10 ) && (ii < 1000))
        {
          start_sequence_gadget = ii;
        }
        else if (ii == 0)
        {
          start_sequence_gadget = -1;
        }
        else
        {
          UMSGetByNum (temp_string, FB_E_INVSEQGDT, 0);
          print_error (define_form, MSG_FLD, temp_string);
        }
      }
      break;

    case DISP_TOG:

      form_attr.collapse = (int)value;
      break;

    case SYM_NBR_FLD: /* Symbol ID */

      num_flag = 1;
      ii = 0;
      jj = 0;

      FIfld_get_text(define_form, SYM_NBR_FLD, 0, 0, 255,
          (unsigned char *)temp_string, &dummy_int, &dummy_int);

      if ((temp_string[0] == '\'') || (temp_string[0] == '\\'))
      {
        ii = 1;
        if (temp_string[1] == '\\')
        {
          ii = 2;
        }
      }
      while ((temp_string[ii] != (char) NULL) && num_flag)
      {
        if (temp_string[ii] != '\'')
        {
          if (isdigit (temp_string[ii]))
          {
            if (( temp_string[0] == '\'' ) &&
                ( temp_string[1] == '\\'))
            {
              sym_name[ii - 2] = temp_string[ii];
            }
            else if ( temp_string[0] == '\\' )
            {
              sym_name[ii - 1] = temp_string[ii];
            }
            else
            {
              sym_name[ii] = temp_string[ii];
            }
            jj++;
          }
          else
          {
            num_flag = 0;
          }
        }
        ii++;
      }
      if ( num_flag )
      {
        sym_name[jj] = (char) NULL;
        if (( temp_string[0] == '\'' ) ||
            ( temp_string[0] == '\\'))
        {
          sscanf (sym_name, "%o", &sym_value);
        }
        else
        {
          sscanf ((char *) temp_string, "%d", &sym_value);
        }

        if ((sym_value < 0) || (sym_value > 255))
        {
          UMSGetByNum (temp_string, FB_E_RANGE255, 0);
          print_error (define_form, MSG_FLD, temp_string);
        }
        else
        {
          form_attr.symbol_number = sym_value;
        }
      }
      else
      {
        UMSGetByNum (temp_string, FB_E_INVALIDSYM, 0);
        print_error (define_form, MSG_FLD, temp_string);
      }
      break;

    case SYM_FILE_FLD:

      FIfld_get_text(define_form, SYM_FILE_FLD, 0, 0,
          255, (unsigned char *)temp_string, &dummy_int, &dummy_int);

      strcpy (form_attr.symbol_file, temp_string);
      break;
    }
  }

  return;
}

/*-----------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* update_define_form() */
/* */
/* This function changes the values displayed in the define form */
/* whenever the form name field on the define form is altered. */
/* */
/*************************************************************************/

static void update_define_form(void)
{
  char directory[256];
  char path[512];
  FILE * fp;

  if (dir[0] == '.')
  {
    directory[0] = (char) NULL;
  }
  else
  {
    strcpy(directory, dir);
  }

/* fprintf(stderr,"In form_attr.form_name is :%s:\n", form_attr.form_name); */
  if (_is_a_form(form_attr.form_name, directory)) /* form exists */
  {
    setup_old_define_form();
  }
  else
  {
    if (strlen (directory))
    {
      strcpy (path, directory);
      strcat (path, "/");
      strcat (path, form_attr.form_name);
    }
    else
    {
      strcpy (path, form_attr.form_name);
    }

    if (( fp = fopen(path,"r")) != NULL )
    {
      form_attr.form_name[0] = (char) NULL;
      form_attr.new_form_name[0] = (char) NULL;
      fclose (fp);

      UMSGetByNum (temp_string, FB_E_NOTIFORMS, 0);
      print_error (define_form, MSG_FLD, temp_string);
      return;
    }

    setup_new_define_form();
  }

  show_define_form_info();
}

/*-----------------------------------------------------------------------*/

/*************************************************************************/
/* */
/* execute_define_form() */
/* */
/* This function is called by the executive command handler routine. */
/* It initializes the define form then displays the define form, then */
/* exits. After that point, the fi_define_form gadget notification */
/* routine will be in control. That is to say, every time the operator */
/* alters a gadget on the define form the fi_define_form() function will */
/* be invoked. */
/* */
/*************************************************************************/

void execute_define_form(void)
{
  int status;

  if (work_form != NULL) /* Form already displayed */
  {
    execute_save_form();
  }
  else
  {
    form_attr.new_form_name[0] = (char) NULL; /* Blank this item */

    UMSGetByNum (temp_string, FB_I_DEFINE, 0);
    FIfld_set_text (Message_form, 11, 0, 0, temp_string, 0);
    UMSGetByNum (temp_string, FB_I_DEFFRM, 0);
    FIfld_set_text (Message_form, 33, 0, 0, temp_string, 0);

    if (define_form == NULL)
    {
      strcpy (temp_string, execute_dir);
      strcat (temp_string, "/config/");
      strcat (temp_string, language);
      strcat (temp_string, "/forms/FBDfinFrm");

      status = FIf_new (F_define, temp_string, (int (*)())fi_define_form, 
          &define_form);
      if (status != FI_SUCCESS)
        Report_fatal_form_error (status, temp_string);
    }

    /* Now display the default define form */

    FIg_erase (define_form, 10); /* Error field */

    FIfld_set_text (define_form, NAME_FLD, 0, 0, "", 0);

    init_define_form(); /* List forms in global dir */

    setup_new_define_form(); /* Sets up blank define form */

    show_define_form_info(); /* Places values into gadgets */

    FIf_display (define_form);

    /********************************************/
    /* */
    /* Need to set Help topic to "Define" here */
    /* */
    /********************************************/

    UMSGetByNum (temp_string, FB_I_DEFINE, 0);
    FIfld_set_text (Message_form, 11, 0, 0, temp_string, 0);
    UMSGetByNum (temp_string, FB_P_FILLDEFFRM, 0);
    FIfld_set_text (Message_form, 33, 0, 0, temp_string, 0);
  }
}



static void add_pwd_to_sym_dir_list(void)
{
  int xx;
  char sym_path_found;

  /*************** JAJ:07/17/90 ****************************/
  /****** look in $PWD for symbols, by default ************/
  /*********************************************************/

  sym_path_found = 0;

  strcpy ( temp_string, expand_shell_vars ( "$PWD" ) );

  if (strlen (temp_string) > 0)
  {
    xx = strlen (temp_string);
    if (temp_string[xx-1] == '/')
      temp_string[xx-1] = (char) NULL;

    for (xx = 0; xx < SYM_dir_count; xx++)
    {
      if (! strcmp(temp_string, &SYM_search_directory[xx][0]) )
      {
        sym_path_found = 1;
        break;
      }
    }
  }

  if ( (sym_path_found == 0) && /* Wasn't in the list, so add it */
  (strlen (temp_string) > 0) )
  {
    strcpy (&SYM_search_directory[SYM_dir_count][0], temp_string);
    SYM_dir_count++;
  }
}
