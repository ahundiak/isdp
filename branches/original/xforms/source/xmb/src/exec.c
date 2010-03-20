/* exec.c */

#include <stdio.h>

#include <X11/Xlib.h>

#include "FI.h"
#include "UMS.h"

#include "FEI.h"
#include "XMB.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"
#include "XMBproto_pri.h"

#if !defined(licensing_off)
	 /* I/Lic_tool stuff -- JAJ:01/25/92 ***/
#include "api.h"
#endif

extern void exit();

int 	vs_x_size;
int 	vs_y_size;

int 	exit_flag = 0;

char     execute_dir[256];
char     menu_locations[256];

char     Global_symbol_file[20];
char     language[80];

	/*** need these two for help system **** 11-14-89 ***/
int	FB_help_initialized_flag = 0;
char	FB_help_topic[128];

extern APP_process_command();
/* extern fi_message_form(); */

int         SYM_dir_count;
char        line[255];
char        SYM_search_directory[100][300];

Display	*display;
Screen *screen;

Form Message_form;
Form Menubar_form;

char symbol_search_string[5000];
char dir[256];


/* Gadget and Palette arrays    GMD 7/15/91   */

int gadget_list [255][100];
char palette_name [255][20];
int palette_level [255];
int gadget_count [255];
int palette_count;
int group_list [255];


#if defined(i386) || defined(hp9000)
void FSExit(void)
{
}
#endif

/*-----------------------------------------------------------------*/

/* ARGSUSED */
void fi_menubar_form (int    form_label,
                     int    gadget_label,
                     double value,
                     Form   form)
{
  char t_str[300];

   FIg_get_command (Menubar_form, gadget_label, t_str);

   APP_process_command (1, t_str);
}


/**********************************************************************/
/** These functions don't seem to be called anywhere -- JAJ:01/26/92 **/
/**********************************************************************
Create_symbol_search_string (char symbol_search_string[5000])
{
int x;

    strcpy (symbol_search_string, execute_dir);
    strcat (symbol_search_string, "/config/");
    strcat (symbol_search_string, language);
    strcat (symbol_search_string, "/icons");
    strcat (symbol_search_string, ":.");

   for (x = 0; x < SYM_dir_count; x++)
   {
      strcat (symbol_search_string, ":");
      strcat (symbol_search_string, &(SYM_search_directory[x][0]));
   }
}

void turn_sync_on(void)
{
  XSynchronize( display, 1 );
}

void turn_sync_off(void)
{
  XSynchronize( display, 0 );
}
**********************************************************************/

/*----------------------------------------------------------------*/

/* ARGSUSED */
int myhandler (Display *display,
               XErrorEvent *myerr)
{
  fprintf (stderr, "major code = %d\n", myerr->request_code);
  return (FI_SUCCESS);
}

/*----------------------------------------------------------------*/

static void Syntax_err (char *pn,
                        char *arg)
{
   fprintf ( stderr, "%s: bad argument <%s>\n", pn, arg);
}



static void Usage (char *prog_name)
{
   fprintf ( stderr, "Usage:  %s [options]\n", prog_name);
   fprintf ( stderr, "Options:\n");
   fprintf ( stderr, "-d display.  node:display.screen\n");
   fprintf ( stderr, "-p specify symbol file search path\n");
   fprintf ( stderr, "-? help. Print this message.\n");
}

/*------------------------------------------------------------------*/

#if !defined(licensing_off)
/* I/Lic_tool stuff -- JAJ:01/25/92 ***/
API_HANDLE_SHUTDOWN ()
#endif

main (int argc,
      char ** argv)
{
    char        temp_string[256];
    char        t_str[2000];

    extern	char	*optarg;

#if defined(i386) || defined(hp9000)
    int getopt();
#else
    char	getopt();
#endif

    int         bad_arguments;
    int         status, i;
    char      * ch;

    char display_name[200];
    char sym_path[2000];

    extern int command_is_active;

    extern char * strrchr();
    extern char * IIwhence();

    char progname[14];

    sym_path[0] = '\0';
    Global_symbol_file[0] = '\0';

    strcpy ( language, "english" );

    SYM_dir_count = 0;


    /**********************************************************/
    /*   First locate the parent directory of the executable. */
    /*   This will be used to locate xmb files such as        */
    /*   forms, menus and symbols.                            */
    /**********************************************************/

    strcpy ( execute_dir, IIwhence ( argv[0], NULL ) );
	/*** strip off the "/bin/xmb" from the end ***/
    ch = strrchr ( execute_dir, '/' );
/*  *ch = NULL; */
   strncpy(progname,ch + 1,14);
   *ch = (char) NULL; /* orig */
    ch = strrchr ( execute_dir, '/' );
   *ch = (char) NULL;

    /*************************************/
    /* Read in options from command line */
    /*************************************/

    strcpy (dir, expand_shell_vars("."));

    bad_arguments = 0;  /* Arguments assumed OK */

    display_name[0] = '\0';    /* NULL string */

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
       case 'd':
                strcpy ( display_name, argv[i]);
                break;

       case 'p':
                strcpy ( sym_path, argv[i]);
                break;

       case '?':
                strcpy ( display_name, argv[i]);
                Usage (progname);
                exit (0);
/*                break; */

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

/*
    XSynchronize( display, 1 );
*/

    XSetErrorHandler (myhandler);

    screen = DefaultScreenOfDisplay (display);

    vs_x_size = XWidthOfScreen (screen);
    vs_y_size = XHeightOfScreen (screen);


    /***********************************/
    /*  Setup symbol file search path  */
    /***********************************/

/* dmb:04/14/93:Why did we do this? */
/*  FI_set_symbol_path ("."); dmb:04/14/93:Original */
/*  FI_append_symbol_path ("."); dmb:04/14/93:Experimental */

  /* dmb:04/13/93:Added for CR#249202403 */
    {
#ifdef USING_THIS
   /* dmb:04/13/93:Begin Added for testing */
      char tmp_sym_path[256] = {(char) NULL};
      char ingr_root[256] = {(char) NULL};

      char cur_sym_path[256] = {NULL};
      int cur_sym_path_length = 0;
    
      FI_get_symbol_path (cur_sym_path);
      fprintf(stdout,"Current sym_path is %s\n",cur_sym_path);

      FI_get_symbol_path_length (&cur_sym_path_length);
      fprintf(stdout,"Current sym_path is %d\n",cur_sym_path_length);

   /* dmb:04/13/93:End Added for testing */
#endif


/*     strcpy(tmp_sym_path,FI_get_ingr_root(ingr_root));dmb:04/14/93:Exp */
/*     strcat(tmp_sym_path,"/lib/xformsrt:/usr/lib/xformsrt");dmb:04/14/93:Exp */
/*      FI_append_symbol_path (tmp_sym_path); dmb:04/14/93:Exp */

#ifdef USING_THIS

  /* dmb:04/13/93:Begin Added for testing FI_append_symbol_path. */
  /* FI_append_symbol_path appears broke because it appends additional */
  /* '/'s to the directories.  We fixed this once, and broke some app! */

    FI_get_symbol_path (cur_sym_path);
    fprintf(stdout,"Current sym_path is now %s\n",cur_sym_path);

    FI_get_symbol_path_length (&cur_sym_path_length);
    fprintf(stdout,"Current sym_path is now %d\n",cur_sym_path_length);

/*     strcpy(tmp_sym_path,FI_get_ingr_root(ingr_root));dmb:04/14/93:Exp */
/*     strcat(tmp_sym_path,"/lib/xformsrt:/usr/lib/xformsrt");dmb:04/14/93:Exp */
/*      FI_append_symbol_path (tmp_sym_path); dmb:04/14/93:Exp */

    FI_get_symbol_path (cur_sym_path);
    fprintf(stdout,"Current sym_path is now %s\n",cur_sym_path);

    FI_get_symbol_path_length (&cur_sym_path_length);
    fprintf(stdout,"Current sym_path is now %d\n",cur_sym_path_length);

  /* dmb:04/13/93:End Added for testing */
#endif

  }
  /* dmb:04/13/93:End Added for CR#249202403 */

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

    if (strlen (sym_path) != 0)  /* operator assigned sym search path */
    {
    int index, len;

       strcpy (t_str, ":");
       strcat (t_str, sym_path);
       FI_append_symbol_path (t_str);

       index = 0;
       len = strlen (sym_path);

       while (index < len)
       {
          i = index;
          while ((sym_path[i] != ':') && (i < (len - 1)))
             i++;

          strcpy (t_str, &(sym_path[index]));
          if (t_str[i - index] == ':')
             t_str[i - index] = '\0';

          strcpy (&(SYM_search_directory[SYM_dir_count][0]), t_str);
          SYM_dir_count++;

          index = i + 1;
       }

    }

    /******************************/
    /*   Setup form search Path   */
    /******************************/

    strcpy (temp_string, ".:");
    strcat (temp_string, execute_dir);
    strcat (temp_string, "/config/");
    strcat (temp_string, language);
    strcat (temp_string, "/forms");

    FI_set_form_path (temp_string);

    /*************************************************/
    /* Set up message subsystem for desired language */
    /*************************************************/

    strcpy (temp_string, execute_dir);
    strcat (temp_string, "/config/");
    strcat (temp_string, language);
    strcat (temp_string, "/messages/XMB.msg");

    status = UMSInitMsg (temp_string, UMS_INDEX | UMS_MESSAGE);

    if (status != UMS_S_SUCCESS)
    {
       fprintf (stderr, "Cannot load message file: %s\n", temp_string);
    }

   	/* Create menubar for my application */

      strcpy (t_str, execute_dir);
      strcat (t_str, "/config/");
      strcat (t_str, language);
      strcat (t_str, "/forms/MB_BAR_MENU");

      status = FIf_new (102, t_str, (int (*)())fi_menubar_form, &Menubar_form);

      if (status != 0)
         Report_fatal_form_error (status, t_str);

      FIf_set_location (Menubar_form, 0, 0);
      FIf_display (Menubar_form);

    FI_modify_env (FI_PROCESS_DATA, APP_process_command);

    command_is_active = 0;

      strcpy (t_str, execute_dir);
      strcat (t_str, "/config/");
      strcat (t_str, language);
      strcat (t_str, "/forms/MBMessage");

      status = FIf_new (102, t_str, (int (*)())fi_message_form, &Message_form);

      if ( status != FI_SUCCESS )
         Report_fatal_form_error (status, t_str);

      FIf_set_location (Message_form, 0, vs_y_size - 85);
      FIf_display (Message_form);

    UMSGetByNum (t_str, MB_I_MNUBLDR, 0);
    FIfld_set_text (Message_form, 11, 0, 0, t_str, 0);
    UMSGetByNum (t_str, MB_P_SELCOM, 0);
    FIfld_set_text (Message_form, 33, 0, 0, t_str, 0);

    FI_process_forms();

    FSExit();

    exit ( 0 );
}
