/*
 * Name
 *        stopsign
 *
 * Description
 *        This program displays a stop sign, which allows the user to send
 *        signal SIGUSR1 to the specified process.  The process may
 *        interpret the signal to stop some lengthy operation, such as a
 *        display.  The program also interprets signals SIGUSR1 and
 *        SIGUSR2 to change the colors of the sign.  This allows the
 *        controlling process to indicate to the user when an operation
 *        may be "stopped."
 *
 * Notes
 *        By default, the code will compile for EnvironV tools.  The
 *        symbol RUN_X may be defined to compile an X Window System
 *        version.
 *
 *        The X Window System version looks best if it is passed the color
 *        map id of the specified process as a command line argument.
 *
 * History
 *        created long, long ago
 *
 *        mrm     09/01/91    add color changing feature
 *        mrm     10/23/91    rewrote to use I/FORMS
 *        mrm     10/30/91    added color map command line arg
 *        mrm     02/19/91    changed signal() to sigset() to handle rapid
 *                            signal catching
 *        mrm     02/20/92    added translate_color() for ROP machines
 *        mrm     02/27/92    zero out standard_st structure lest garbage
 *                            mislead FORMS into using unintended data fields
 *        mrm     09/08/92    set collapse icon
 *        elp     01/08/93    port to NT.  This will probably become a thread
 *                            under NT but for now port as a seperate process.
 *                            I don't think a seperate process will work under
 *                            NT because you can't send a signal to another
 *                            process.
 *        mrm     05/18/93    added signal handler to move to active screen
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>

#if defined( ENV5 )
#include <tools.h>
#include <FEI.h>
#include <FI.h>
#include <FIdyn.h>
#elif defined(X11)
#include "FI.h"
#include "FIdyn.h"
#elif defined( NT )
#include <windows.h>
#ifndef SIGUSR1
#define SIGUSR1 16
#endif
#ifndef SIGUSR2
#define SIGUSR2 17
#endif
#endif
#include "dpgraphics.h"

/* flags for setting window system icons */
#define	DISABLE	0
#define	ENABLE  1

/* symbol file indices in GRfrm.sym */
#define STOP_SIGN_INDEX         203
#define STOP_OUTLINE_INDEX      215

/* form definitions and labels */
#define FORM_LABEL      666
#define STOP_SIGN_LABEL 100
#define OUTLINE_LABEL   101
#ifdef X11
#define FORM_X_ORIGIN   0
#define FORM_Y_ORIGIN   65      /* allow for window manager decoration */
#define FORM_X_SIZE     45
#define FORM_Y_SIZE     40
#define XLO             2
#define YLO             4
#else
#define FORM_X_ORIGIN   0
#define FORM_Y_ORIGIN   55
#define FORM_X_SIZE     48
#define FORM_Y_SIZE     45
#define XLO             4
#define YLO             6
#endif

/* exit codes */
#define INVALID_ARG             1       /* invalid command line argument */
#define CANT_CREATE_FORM        2       /* failed to create a form */
#define BAD_DISPLAY             3       /* failed to open X display */

/* global variables */
long ppid;
Form form;
#ifdef X11
Display *display;
#endif

/* forward reference */
void activate_sign(), deactivate_sign() , dummy1();
#ifdef ENV5
void move_to_active_screen();
#endif

/*
#define	DEBUG	1
*/

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Name
 *        usage
 *
 * Description
 *        Routine to print an error message containing command line syntax
 */

void usage(char * progname)
{
  fprintf(stderr, "Usage: %s ", progname);
#ifdef X11
  fprintf(stderr, "[-display display-name] [-color color-map-id] ");
#endif
  fprintf(stderr, "process-id symbol-file-path\n");
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Name
 *        usage
 *
 * Description
 *        Routine to refresh the stop sign.
 */

void refresh_sign()
{
  /*
    Don't use FIf_display; there is no predicting when X will
    actually decide to flush the display.  FIg_display is guaranteed
    to proceed immediately
  */
#ifdef ENV5
  /* HF: 02/21/2001 - Fix for TR# MP4704 */
  FIg_display(form, STOP_SIGN_LABEL);
  FIg_display(form, OUTLINE_LABEL);
#endif
#ifdef X11
  XFlush(display);            /* XForms kludge */
#endif
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Name
 *        usage
 *
 * Description
 *        Routine to set signal-catching routines
 */

void trap_signals()
{
#if defined( NT )
  signal(SIGUSR1, activate_sign);
  signal(SIGUSR2, deactivate_sign);
#else
  sigset(SIGUSR1, activate_sign);
  sigset(SIGUSR2, deactivate_sign);
#endif
#ifdef ENV5
  sigset(SIGPWR, move_to_active_screen);
#endif
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Name
 *        activate_sign
 *
 * Description
 *        Routine to activate the stop sign.
 */

/* ARGSUSED */
void activate_sign(int sig)
{
#if DEBUG
  fprintf(stderr,"  activate_sign: signal %d caught\n", sig);
#endif
  /* HF: 02/21/2001 - Fix for TR# MP4704 */
#ifdef ENV5
  FIg_set_color(form, STOP_SIGN_LABEL, FI_DK_GREY);
#else
  FIg_set_color(form, STOP_SIGN_LABEL, FI_RED);
#endif
  refresh_sign();
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Name
 *        deactivate_sign
 *
 * Description
 *        Routine to deactivate the stop sign
 */

/* ARGSUSED*/
void deactivate_sign(int sig)
{
#if DEBUG
  fprintf(stderr,"deactivate_sign: signal %d caught\n", sig);
#endif
  FIg_set_color(form, STOP_SIGN_LABEL, FI_DK_GREY);
  refresh_sign();
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Name
 *        move_to_active_screen
 *
 * Description
 *        Signal handler to move the stop sign to the active screen.  This
 *        signal is sent when a file is saved, so that when the menus move to
 *        the active screen (a questionable behavior necessitated by journaling
 *        madness), the stop sign will move as well.
 */

#ifdef ENV5
/* ARGSUSED */
void move_to_active_screen(int sig)
{
  int win, my_vs, active_vs;

  FIf_get_window(form, &win);
  Inq_win_vs(win, &my_vs);
  Inq_displayed_vs(&active_vs);
  if (my_vs != active_vs)
  {
    FIf_erase(form);
    Set_win_vs(win, active_vs);
    FIf_display(form);
  }
}
#endif

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Name
 *        form_notification
 *
 * Description
 *        form notification routine - any input will send SIGUSR1 to ppid.
 */

/* ARGSUSED */
int form_notification(int f_label, int g_label, double value, Form fp)
{
#if DEBUG
  fprintf(stderr,"Send SIGUSR1 to process %d\n", ppid);
#else
#if ! defined( NT )
  kill(ppid, SIGUSR1);
#endif
#endif
  deactivate_sign(SIGUSR2);
  return(FI_SUCCESS);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Name
 *        translate_colors
 *
 * Description
 *        Function to map colors for primitive machines (32Cs).
 */

#if defined( ENV5 )
/* ARGSUSED */
int translate_color(int vs, int color)
{
  /* map colors to safe locations in the EMS color table */
  switch (color)
  {
    case FI_LT_GREY:
    case FI_YELLOW:
    case FI_GREEN:
    case FI_LT_YELLOW:
      return(13);          /* light gray */

    case FI_MED_GREY:
    case FI_RED:
      return(14);          /* medium gray */

    case FI_WHITE:
    case FI_OFF_WHITE:
      return(15);          /* off white */

    case FI_BLACK:
    case FI_DK_GREY:
    case FI_BLUE:
    case FI_DK_RED:
    case FI_DK_GREEN:
    case FI_DK_BLUE:
    default:
      return(0);           /* dark color */
  }
}
#endif

void dummy1(int sig)
{
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * Name
 *        main / WinMain
 *
 * Description
 *        Entry point to program.
 */

#ifdef NT

int WINAPI WinMain( HINSTANCE hInst,
                    HINSTANCE hPrevInst,
                    LPSTR lpCmdLn,
                    int nShowCmd )

#else

main(int argc, char *argv[])

#endif
{
  char *c, *symbol_path = NULL;
  int sts, i = 1;
#if defined( X11 )
  char *display_name;
  int color_map = 0, color_map_size = 0;
#elif defined( ENV5 )
  int window_number;
  struct scr_info screen_info[MAX_SCREENS];
#endif
  struct standard_st gad;

#ifdef NT
  int argc = 0;
  char **argv = 0;

  /*
   *  Some function call will go here as soon as its defined but for now
   *  let's press on.  lpCmdLn has all command line arguments.
   */

  argv = (char **) malloc( 2 * sizeof( char * ) );
  argv[0] = (char *) strdup( "grstopproc" );
  argv[1] = 0;

  argc = 1;
#endif
  /* Trap these signals right in the begining so that even if
   * there is some delay( caused by X) in bringing up the stop sign,
   * they do not do any harm
   */

  sigset(SIGUSR1, dummy1);
  sigset(SIGUSR2, dummy1);

#ifdef X11
  /* check for the DISPLAY environment variable */
  if ((display_name = getenv("DISPLAY")) == NULL)
  {
    display_name = "unix:0.0";
  }

  /* check the command line args */
  for (i = 1; i < argc; i++)
  {
    c = argv[i];
    if (c[0] != '-')
      break;
    else
    {
      switch (c[1])
      {
        case 'c':
          color_map = atoi(argv[++i]);
          color_map_size = 32; /* just a guess */
          break;
        case 'd':
          display_name = argv[++i];
          break;
        default:
          usage(argv[0]);
          exit(INVALID_ARG);
      }
    }
  }
#endif

  /* get the parent process id and symbol path from the command line */
  if ((argc - i) == 2)
  {
    ppid = atoi(argv[i]);
    symbol_path = argv[i + 1];
  }
  else
  {
    usage(argv[0]);
    exit(INVALID_ARG);
  }

  /* activate the windowing system */
#if defined( X11 )
  if ((display = XOpenDisplay(display_name)) == NULL)
  {
    fprintf(stderr, "Cannot open display: %s\n", display_name);
    usage(argv[0]);
    exit(BAD_DISPLAY);
  }
#elif defined( ENV5 )
  Enter_tools_no_act();
#endif

  /* initialize the forms system */
#if defined( X11 )
  FSEnter(display, 0);
  FI_enter(display, color_map, color_map_size);
#elif defined( ENV5 )
  FI_enter();
#elif defined( NT )
  FI_enter( hInst );
#endif

  /* create a form */
  sts = FIf_new(FORM_LABEL, "", form_notification, &form);
  if (sts != FI_SUCCESS)
  {
    fprintf(stderr, "Failed to create stop sign form: %d\n", sts);
    exit(CANT_CREATE_FORM);
  }

#if defined( ENV5 )
  /* determine whether colors need special attention */
  Inq_screen_info(screen_info);
  for (i = 0; i < MAX_SCREENS; i++)
  {
    if (screen_info[i].vsi_screen_num == 0)
    {
      if (screen_info[i].vsi_flags & VSI_VIRTUAL_SCREEN)
      {
        if (screen_info[i].vsi_fixed_vlt_size == 0)
        {
          FI_modify_env(FI_TRANSLATE_COLOR, translate_color);
        }
        break;
      }
    }
  }
#endif

  /* adjust the form */
  FIf_set_location(form, FORM_X_ORIGIN, FORM_Y_ORIGIN);
  FIf_set_size(form, FORM_X_SIZE, FORM_Y_SIZE);

#if defined( X11 )
  FIf_set_attr(form, FI_NO_BEZEL);    /* window manager will decorate */
#elif defined( ENV5 )
  FIf_set_attr(form, FI_LINE_BORDER);
  FIf_set_window_level(form, FI_HIGH_PRIORITY);
#endif

  /* separate the symbol directory and filename */
#if defined( NT )
  if (c = strrchr(symbol_path, '\\')) *c++ = NULL;
#else
  if (c = strrchr(symbol_path, '/')) *c++ = NULL;
#endif
  FI_set_symbol_path(symbol_path);

  /* set the collapse symbol (the default one seems to bother mwm) */
  FIf_set_collapse_symbol(form, c, STOP_SIGN_INDEX);

  /* create the stop symbols */
  FIg_new(form, FI_SYM, STOP_SIGN_LABEL);
  memset((char*)&gad, 0, sizeof(struct standard_st));
  gad.xlo = XLO;
  gad.ylo = YLO;
  gad.attr_mask = 0;
  gad.fontname = c;
  gad.off_color = FI_DK_GREY;
  gad.symbol_index = STOP_SIGN_INDEX;
  FIg_set_standard_variables(form, STOP_SIGN_LABEL, &gad);
  FIg_new(form, FI_SYM, OUTLINE_LABEL);
  gad.off_color = FI_WHITE;
  gad.symbol_index = STOP_OUTLINE_INDEX;
  FIg_set_standard_variables(form, OUTLINE_LABEL, &gad);
  FIg_activate(form, STOP_SIGN_LABEL);
  FIg_activate(form, OUTLINE_LABEL);

  /* display the stop sign form */
  FIf_display(form);

#if defined( ENV5 )
  /* this code must follow FIf_display so that window_number will be valid */
  FIf_get_window(form, &window_number);
  Set_win_auto_act(window_number,DISABLE);
  Set_win_sys_icon(window_number, MODIFY_ICON_VALUE,ENABLE);
  Set_win_sys_icon(window_number, POPTOP_ICON_VALUE,ENABLE);
  Set_win_sys_icon(window_number, POPBTM_ICON_VALUE,ENABLE);
  Set_win_sys_icon(window_number, DELETE_ICON_VALUE,DISABLE);
  Set_win_sys_icon(window_number, COLPSE_ICON_VALUE,DISABLE);
  Set_win_sys_icon(window_number, REFRESH_ICON_VALUE,DISABLE);
  Set_win_vs_swap(window_number, ENABLE);
#endif

#if DEBUG
  fprintf(stderr,">>>>> In stopsign main() BEFORE trap_signals() & FI_process_forms()\n");
#endif

  /* set the signal handlers */
  trap_signals();

#if defined( ENV5 )
  /* set up input mask */
  Enable_events(BUTTON_EVENT | REFRESH_EVENT);
#endif

  /* wait for input */
  FI_process_forms();

#if DEBUG
  fprintf(stderr,"<<<<< In stopsign main() AFTER  FI_process_forms()\n");
#endif

  /* shut down */
#if defined( X11 )
  XCloseDisplay(display);
#elif defined( ENV5 )
  Exit_tools();
#endif

  exit(0);
}
