/***********************************

		exec.c

***********************************/

/*
  History
	04-28-92	sml		already ANSI-ized
	05-22-92	sml		removed unused extern vars
*/

/* EXECUTIVE */
/* */
/* Only one command can be serviced at one time. If a command is */
/* being serviced, you must be asked if you wish to terminate the */
/* current active command before proceeding with the new one. If you */
/* cancel the new command, this presents a problem in restoring the */
/* menu to its former state. The best that can be done is to pop up */
/* the button that was just canceled. */
/* */

#include <stdio.h>

#include "X11/Xlib.h"

#include "FI.h"
#include "NFBpriv.h"
#include "UMS.h"
#include "FB.h"

#include "FEI.h"

#include "FIform.h" /* dmb:08/28/91 */

#include "XFIproto_pub.h"
#include "XFIproto_pri.h"
#include "XFBproto_pri.h"

#if !defined(licensing_off)
	 /* I/Lic_tool stuff -- JAJ:01/25/92 ***/
#include "api.h"
#endif

#define XLO 3
#define YLO 85
#define XHI 991
#define YHI 820

#define FORM 100
#define TYPEFACE_LIST_FLD 22


#define MAX_PLANES 8
#define COLORS 14
#define MAX_COLORS 2*COLORS

int plane_masks[MAX_PLANES], pixels[MAX_COLORS], hilite_mask = 0;

XColor color_table[MAX_COLORS]={
  { 0, 61166, 61166, 56797, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 34952, 34952, 34952, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 00000, 00000, 00000, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 65535, 65535, 00000, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 48059, 48059, 48059, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 21845, 21845, 21845, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 65535, 65535, 65535, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 65535, 00000, 00000, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 00000, 65535, 00000, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 00000, 00000, 65535, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 65535, 65535, 48059, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 56797, 00000, 00000, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 00000, 48059, 00000, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 00000, 00000, 52428, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 65535, 65535, 65535, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 65535, 65535, 65535, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 65535, 65535, 65535, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 65535, 65535, 65535, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 65535, 65535, 65535, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 65535, 65535, 65535, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 65535, 65535, 65535, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 65535, 65535, 65535, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 65535, 65535, 65535, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 65535, 65535, 65535, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 65535, 65535, 65535, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 65535, 65535, 65535, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 65535, 65535, 65535, DoRed | DoGreen | DoBlue, (char) NULL },
  { 0, 65535, 65535, 65535, DoRed | DoGreen | DoBlue, (char) NULL }
};

int Two_vscreens_flag;
int vs_x_size;
int vs_y_size;

char LOGKBD; /*** Japan ***/
extern int lkb_pid;
unsigned char key_buf[256];

int exit_flag = 0;

char execute_dir[256];
char menu_locations[256];
char in_menu_locations[256];

char Global_symbol_file[20];
char language[80];

/*** need these two for help system **** 11-14-89 ***/
int FB_help_initialized_flag = 0;
char FB_help_topic[128];

void turn_sync_off();
void turn_sync_on();

static char line[255];


int SYM_dir_count;
char SYM_search_directory[200][256];
char symbol_search_string[5000];

int global_form_scaling_flag;

Display *display;
GC xfb_GC, dyn_GC, text_GC;
XGCValues GC_values, dyn_GC_values;
unsigned long gcMask = GCFunction | GCLineWidth | GCForeground | GCBackground | GCSubwindowMode;
int hilite_plane;
Screen *screen;

int font_count;
Font Font_array[200];
Font label_text_font;

Form Message_form;
Form Command_form;


#if defined(i386) || defined(hp9000)
void FSExit(void)
{
}
#endif


/*-----------------------------------------------------------------------*/

/* ARGSUSED */
unsigned long FEI_translate_color(int screen,
                                  int color)
{
  return pixels[ color%COLORS ];
}

/*-----------------------------------------------------------------------*/

void turn_sync_on(void)
{
  XSynchronize( display, 1 );
  return;
}

/*-----------------------------------------------------------------------*/

void turn_sync_off(void)
{
  XSynchronize( display, 0 );
  return;
}

/*-----------------------------------------------------------------------*/

/* ARGSUSED */
int myhandler (Display *display,
               XErrorEvent *myerr)
{
  /* dmb:10/19/92:Added to track down major code = 56 */
  char x_msg[80];
  XGetErrorText(display, myerr->error_code, x_msg, 80);

  fprintf (stderr, "Error code = %s\n", x_msg);

  fprintf (stderr, "major code = %d\n", myerr->request_code);

  return (FI_SUCCESS);
}

/*-----------------------------------------------------------------------*/

static void Syntax_err (char *pn,
                        char *arg)
{
   fprintf ( stderr, "%s: bad argument <%s>\n", pn, arg);
}


static void Usage (char *progname)
{
  fprintf ( stderr, "Usage:  %s [options]\n", progname);
  fprintf ( stderr, "Options:\n");
  fprintf ( stderr, "-d node:display.screen\n");
  fprintf ( stderr, "-f form name\n");
  fprintf ( stderr, "-s startup_file\n");
  fprintf ( stderr, "-? help: print this message\n");
}



#if !defined(licensing_off)
/* I/Lic_tool stuff -- JAJ:01/25/92 ***/
API_HANDLE_SHUTDOWN ()
#endif


/*-----------------------------------------------------------------------*/
int main (int argc,
          char **argv)
{

  int status;
  int i, x, slash_count, slash_pos;

  char temp_string[256];
  char t_str[512];
  char path[256];
  char *ch;
  char startup_filename[256];
  char startup_formname[256];

  extern char *optarg;


  char error_string[1000];
  int bad_arguments;

  char font_name[2000];

  char *ptr;
  char display_name[200];
  float dummy_float;
  int dummy_int;
  char progname[15];


  extern unsigned char dir[256];
  extern struct dpb_struct dpb;
  extern int command_is_active;
  extern int global_crosshairs_flag;
  extern Form work_form;
  extern Form Master_pv_form;
  extern Form Font_form;
  extern Form Grid_form;
  extern Form Line_weight_form;
  extern Form Line_style_form;
  extern Form FG_color_form;
  extern Form BG_color_form;
  extern Form FG2_color_form;
  extern Form Characteristics_form;

  extern FILE *startup_file;
  extern char token[255];
  extern int token_type;
  extern int line_ptr;
  extern int end_of_file;
  extern int old_line_ptr;
  extern int save_restore_flag;
  extern struct form_data form_attr;

  extern char * strrchr();
  extern char * IIwhence();
  extern int label_font_id;

  extern char Save_preview_dir[200];
  extern char Save_preview_file[80];
/*	sml:05-22-92	not used
  extern Form MS_bar_menu;
  extern Form MS_panel_menu;
*/
  extern int start_sequence_gadget;
  
  strcpy (Global_symbol_file, "");
  strcpy (language, "english");

  SYM_dir_count = 0;

  global_crosshairs_flag = 1;
  global_form_scaling_flag = 0;
  Master_pv_form = NULL;
  Font_form = NULL;
  Grid_form = NULL;
  Line_weight_form = NULL;
  Line_style_form = NULL;
  FG_color_form = NULL;
  BG_color_form = NULL;
  FG2_color_form = NULL;

  FBprint_version();

  /**********************************************************/
  /* */
  /* First locate the parent directory of the executable. */
  /* This will be used to locate nfb files such as */
  /* forms, menus and symbols. */
  /* */
  /**********************************************************/

  slash_count = 0;

  strcpy ( execute_dir, IIwhence ( argv[0], NULL ) );
  /*** strip off the "/bin/xfb" from the end ***/
  ch = strrchr ( execute_dir, '/' );
/*  *ch = NULL; */
   strncpy(progname,ch + 1,14);
  *ch = (char)NULL; /* orig */
  ch = strrchr ( execute_dir, '/' );
  *ch = (char)NULL;

  /*************************************/
  /* */
  /* Read in options from command line */
  /* */
  /*************************************/

  dir[0] = (char) NULL;
  bad_arguments = 0; /* Arguments assumed OK */

  strcpy (startup_filename, execute_dir);
  strcat (startup_filename, "/config/xfb.startup");

  startup_formname[0] = 0; /* NULL string */
  display_name[0] = (char) NULL; /* NULL string */

  for (i = 1; i < argc; i++)
  {
    if (argv[i][0] != '-')
    {
      Syntax_err (progname, argv[i]);
      Usage (progname);
      exit (1);
    }

    switch (argv[i++][1])
    {
    case 's':
      strcpy ( startup_filename, argv[i]);
      break;

    case 'f':
      strcpy ( startup_formname, argv[i]);
      break;

    case 'd':
      strcpy ( display_name, argv[i]);
      break;

    case '?':
    case 'h':
      strcpy ( display_name, argv[i]);
      Usage (progname);
      exit (0);

    default:
      Syntax_err (progname, argv[i]);
      Usage (progname);
      bad_arguments = 1;
      exit (1);

    }
  }

#if !defined(licensing_off)
  /* I/Lic_tool stuff -- JAJ:01/25/92 ***/
  API_GET_LICENSE ( "SN01252", "1992" )
#endif

  if ((display = XOpenDisplay (display_name)) == None)
  {
    fprintf (stderr, "Cannot connect to X server %s\n", display_name);
    exit (-1);
  }

  FSEnter (display, 0);

/* dmb:02/18/93:Re-added for MIPS port */
/*  FI_enter (display, NULL, NULL);  dmb:10/21/92:Original */
  FI_enter (display, DefaultColormap(display,DefaultScreen(display)), 32);
  FEI_enter ();

  /*
XSynchronize( display, 1 );
*/

  XSetErrorHandler (myhandler);

  screen = DefaultScreenOfDisplay (display);

  vs_x_size = XWidthOfScreen (screen);
  vs_y_size = XHeightOfScreen (screen);

  xfb_GC = XCreateGC (display, RootWindowOfScreen (screen), 0, &GC_values);

  /*
  if (CreateDynamicColormap (display) )
    AdjustFormsColors();
  */

  dyn_GC_values.foreground = hilite_mask;
  dyn_GC_values.background = 0;
  dyn_GC_values.function = GXxor;
  dyn_GC_values.line_width = 1;
  dyn_GC_values.subwindow_mode = IncludeInferiors;
  dyn_GC = XCreateGC( display, RootWindowOfScreen (screen),
      gcMask, &dyn_GC_values );

  text_GC = XCreateGC (display, RootWindowOfScreen (screen), 
      gcMask, &dyn_GC_values);

  /************************/
  /* */
  /* Set up dpb structure */
  /* */
  /************************/

  dpb.bgcolor = FI_LT_GREY;
  strcpy(dpb.font_name, "swiss742b");
  dpb.bodysize = 15;
  dpb.off_color = FI_BLACK;
  dpb.on_color = FI_YELLOW;
  dpb.grid_flag = 0;
  dpb.grid_master_units = 15;
  dpb.grid_sub_units = 5;
  dpb.line_style = -1;
  dpb.line_weight = 1;

  dpb.line_depth = FI_2D_LINE;
  dpb.text_style = FI_NORMAL_TEXT;
  dpb.text_justification = FI_LEFT_JUSTIFIED;
  dpb.expansion1 = 0; /* Use 8 bit fonts */

  dpb.expansion4 = 0; /* Don't use boundaries by default */
  dpb.expansion2 = 15; /* Default X boundary percentage to 15 % */
  dpb.expansion3 = 10; /* Default Y boundary percentage to 10 % */

  /***********************************/
  /* */
  /* Setup symbol file search path */
  /* */
  /***********************************/

/* dmb:04/14/93:Why did we do this in the first place? */
/*  FI_set_symbol_path ("."); dmb:04/14/93:Original */

/*  FI_append_symbol_path ("."); dmb:04/14/93:Experimental */

  /* dmb:04/13/93:Added for CR#249202403 */
  {
    char tmp_sym_path[256] = {(char)NULL};
    char ingr_root[256] = {(char)NULL};

#ifdef USING_THIS
  /* dmb:04/13/93:Added for testing */
    char cur_sym_path[256] = {(char) NULL};
    int cur_sym_path_length = 0;
  /* dmb:04/13/93:End Added for testing */
#endif
    
  strcpy(tmp_sym_path,FI_get_ingr_root(ingr_root));
  strcat(tmp_sym_path,"/lib/xformsrt:/usr/lib/xformsrt");

/*  FI_append_symbol_path (tmp_sym_path); dmb:04/14/93:Experimental */

/* #define USING_THIS 1 */
#ifdef USING_THIS
  /* dmb:04/13/93:Begin Added for testing */

    FI_get_symbol_path (cur_sym_path);
    fprintf(stdout,"Current sym_path is %s\n",cur_sym_path);

    FI_get_symbol_path_length (&cur_sym_path_length);
    fprintf(stdout,"Current sym_path is %d\n",cur_sym_path_length);
  /* dmb:04/13/93:End Added for testing */
#endif
  }
  /* dmb:04/13/93:End Added for CR#249202403 */

  /**********************************************/
  /* */
  /* Read in parameters from the startup file */
  /* */
  /**********************************************/

  strcpy (path, startup_filename);

  startup_file = fopen (path, "r");
  if (startup_file == NULL)
  {
    sprintf (temp_string, "Could not find startup file %s\n", path);
    Report_fatal_error (temp_string);
  }

/*  fgets (line, 255, startup_file); */
  line_ptr = 0;
  old_line_ptr = 0;
  end_of_file = 0;

  LOGKBD = 0;

  while (!(end_of_file))
  {
    token_type = OTHER_TOKEN;

    while ((token_type != KEYWORD_TOKEN) &&
        (!(end_of_file)))
    {
      Get_token();
    }

    if (!(end_of_file))
    {
      if (strcmp (token, ":DPB:") == 0)
        process_dpb_keyword();
      else if (strcmp (token, ":LANGUAGE:") == 0)
        process_language_keyword();
      else if (strcmp (token, ":SYMPATH:") == 0)
        process_sympath_keyword();
      else if (strcmp (token, ":LOGKBD:") == 0)
        process_logical_keyboard_keyword();
      else
      {
        sprintf (temp_string,
            "Invalid keyword- %s found in startup file\n", token);
        Report_nonfatal_error (temp_string);
      }
    }
  }

  strcpy (temp_string, ":");
  strcat (temp_string, execute_dir);
  strcat (temp_string, "/config/");
  strcat (temp_string, language);
  strcat (temp_string, "/icons");

  FI_append_symbol_path (temp_string);

  strcpy (temp_string, execute_dir);
  strcat (temp_string, "/config/");
  strcat (temp_string, language);
  strcat (temp_string, "/icons");

  strcpy (&(SYM_search_directory[SYM_dir_count][0]), temp_string);
  SYM_dir_count++;

  /******************************/
  /* */
  /* Setup form search Path */
  /* */
  /******************************/

  strcpy (temp_string, execute_dir);
  strcat (temp_string, "/config/");
  strcat (temp_string, language);
  strcat (temp_string, "/forms:.");

  FI_set_form_path (temp_string);

  /*************************************************/
  /* */
  /* Set up message subsystem for desired language */
  /* */
  /*************************************************/

  strcpy (temp_string, execute_dir);
  strcat (temp_string, "/config/");
  strcat (temp_string, language);
  strcat (temp_string, "/messages/FB.msg");

  status = UMSInitMsg (temp_string, UMS_INDEX | UMS_MESSAGE);

  if (status != UMS_S_SUCCESS)
  {
    sprintf (error_string, "Cannot load message file: %s", temp_string);
    Report_fatal_error (error_string);
  }

  /* Call MEI_enter located in mei.c which handles setting up the */
  /* Menu Environment Interface. Inside MEI_enter it calls */
  /* MS_setup_functions with pointers to functions defined in mei.c */
  /* Inside mei.c there are functions that the Menu Subsystem will */
  /* call to get information about the environment. */

  /* Set up the location of the in_menu_locations file */

  /* dmb:08/06/91: Added $HOME override */
  if ( (ptr=(char *)getenv("HOME")) != NULL )
  {
    (void)strcpy(in_menu_locations,ptr);
    (void)strcpy(menu_locations,ptr);
  }
  else
  {
    fprintf (stderr, "Cannot find HOME environment variable.\n");
  }
/*  fprintf(stderr,"Home is %s\n",in_menu_locations); */

  strcat ( in_menu_locations, "/menu_locations");
  strcat ( menu_locations, "/menu_locations");

  /* if no access to $HOME/menu_locations */
  /* read $PROD_LOC/config/menu_locations. */
  if ( access ( in_menu_locations, 0 ) != 0 )
  {
    strcpy ( in_menu_locations, execute_dir );
    strcat ( in_menu_locations, "/config/menu_locations");
  }
  /* */


  MS_enter ();

  MS_set_startup_file ( in_menu_locations );

  /* Call MS_init_menus to create all the menus for my application */

  MS_init_menus ( );

  /* Call MS_display_menu to display all the menus */

  MS_display_menus ( );

  /**
FIf_set_location (MS_bar_menu, vs_x_size - 1184, 20);
FIf_set_location (MS_panel_menu, vs_x_size - 200, 20);
**/
  FI_modify_env (FI_PROCESS_DATA, APP_process_command);

  /*** Default help topic to be table of contents 11-14-89 ***/

  strcpy ( FB_help_topic, "TOC" );

  command_is_active = 0;

  strcpy (t_str, execute_dir);
  strcat (t_str, "/config/");
  strcat (t_str, language);
  strcat (t_str, "/forms/FBMessage");

  status = FIf_new (102, t_str, (int (*)())fi_message_form, &Message_form);

  if (status != FI_SUCCESS)
    Report_fatal_form_error (status, t_str);

  FIf_set_location (Message_form, 0, vs_y_size - 85);
  FIf_display (Message_form);

  execute_display_characteristics_form();

  FIf_collapse (Characteristics_form);
  /* FIf_set_collapse_location (Characteristics_form, 850, vs_y_size - 200); */

  FIf_set_collapse_location (Characteristics_form, 0, vs_y_size - 200);

     /* Adjust location down 100 pixels    GMD 1/27/92 */
  FIf_set_location (Characteristics_form, 0, vs_y_size - 255);
  FIf_display (Characteristics_form);

  UMSGetByNum (t_str, FB_I_FRMBLDR, 0);
  FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
  UMSGetByNum (t_str, FB_P_SELCOM, 0);
  FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

  if (startup_formname[0] != 0)
  {
    strcpy ( line, startup_formname );

    /**************************************/
    /* */
    /* First split off the directory and */
    /* form names from the complete */
    /* string. */
    /* */
    /**************************************/

    slash_pos = -1;

    for (x = strlen (line); x >= 0; x--)
    {
      if (line[x] == '/')
      {
        slash_pos = x;
        x = -1;
      }
    }

    if (slash_pos == -1)
    {
#if defined(hp9000)
      strcpy ((char *) dir, expand_shell_vars("."));
#else
      strcpy (dir, expand_shell_vars("."));
#endif
      strcpy (form_attr.form_name, line);
      strcpy (form_attr.new_form_name, line);
    }
    else
    {
      strcpy (form_attr.form_name, &(line[slash_pos+1]));
      strcpy (form_attr.new_form_name, &(line[slash_pos+1]));
      line [slash_pos] = 0;
#if defined(hp9000)
      strcpy ((char *) dir, expand_shell_vars(line));
#else
      strcpy (dir, expand_shell_vars(line));
#endif
    }

#if defined(hp9000)
    strcpy (line, (char *) dir);
#else
    strcpy (line, dir);
#endif
    strcat (line, "/");
    strcat (line, form_attr.form_name);

    status = FIf_new (222, line, (int (*)())fi_work_form, &work_form);

    if (status == FI_SUCCESS)
    {
	  long mask;

      /* Fix GMD 2/12/91: Moved 10/03/91 */
      FIf_get_start_seq (work_form, &start_sequence_gadget);

      /***************************************************/
      /* */
      /* Set dyn_GC color based on form background color */
      /* */
      /***************************************************/

      if (!hilite_mask)
      {
        int color, (*my_translate_color)();
        unsigned long foreground;

        FIf_get_color( work_form, &color );

        FI_get_env (FI_TRANSLATE_COLOR, &my_translate_color);

        /* GMD 12/19/91   Change dynamics color to Green because of bug
                          in moving text causing text to disappear.       */

        foreground = (*my_translate_color)( 0, FI_GREEN ) ^
            (*my_translate_color)( 0, color );
        XSetForeground( display, dyn_GC, foreground );
      }

      FIf_set_window_event_routine (work_form, (int (*)())window_event_grid_check);

	  /* sml:01-15-93	turn off SAVE/RESTORE attr for now */
	  FIf_get_attr(work_form, &mask);
	  if (mask & FI_SAVE_RESTORE)
	  {
		save_restore_flag = 1;
		mask ^= FI_SAVE_RESTORE;
	  }
	  else
	  {
		save_restore_flag = 0;
	  }
	  FIf_set_attr(work_form, mask);

      /****************************/
      /* */
      /* Finally display the form */
      /* */
      /****************************/

      status = FIf_display (work_form);

      /******************/
      if (dpb.grid_flag) /* */
        display_grid_on_work_form(); /* See "grid.c" */
      /* */
    } /******************/
    else
    {
      UMSGetByNum (error_string, FB_E_CNTLDFRM, "%s", line);

      Report_nonfatal_error (error_string);
      work_form = NULL;

#if defined(hp9000)
      strcpy ((char *) dir, expand_shell_vars("."));
#else
      strcpy (dir, expand_shell_vars("."));
#endif
      form_attr.form_name[0] = 0;
      form_attr.new_form_name[0] = 0;
    }
  }

  label_font_id = (int) NULL;

  strcpy (font_name, "swiss742b.12");

  _FI_find_font_id ("swiss742b", (float)12.0, &label_text_font,
      &dummy_float, FI_TEXT, &dummy_int);

  /* Loop and process events */

  FI_process_forms();

  FSExit();

  /* See execute_exit_fb for exit details */

  exit ( 0 );
}
