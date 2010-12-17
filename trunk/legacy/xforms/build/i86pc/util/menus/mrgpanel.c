#include <errno.h>
#include <stdio.h>

#include <X11/Xlib.h>


#include "FIdyn.h"
#include "MI.h"
#include "GMmenu.h"
#include "GMerror.h"

#include "GMproto_pri.h"
#include "XFIproto_pub.h"

#define  NUM_CMD_OPTS  1
#define  VERBOSE_OPT   0

Display *display;    /* dmb:06/30/91:Exp */
char *display_name = "";		/*02-08-93:sml:	use default display or 
								  what's in $DISPLAY */

int panelPalHeight = -1;	/* command line-specified panel height */
int panelPalWidth = -1;		/* command line-specified panel width */

/**************************************************************************

Doc:  main

Abstract:
  This program merges two or more panel menus into a single panel menu.

History:
  25-SEP-1989  tjz  Finally yielded to pressure and did it

**************************************************************************/

int  main(int  argc,
          char  *argv[])
{
  struct  GMPalette  *pal;
  int     sts, idx, mnuIdx, cmdOpts[NUM_CMD_OPTS];


  sts = GMPParseCmdLine( &mnuIdx, cmdOpts, argc, argv );
  if ( GM_ERROR( sts ) )
  {
    fprintf( stderr,
     "usage: %s [-v] [-p <palette name prefix>] [-h <panel height>] <merged panel> <panel 1> <panel 2> [<panel 3> ...]\n\nHeight and width must be integers\n",
      argv[0] );
    goto arg_exit;
  }

  for ( idx = mnuIdx + 1; idx < argc; idx++ )
  {
    if ( access( argv[idx], 4 ) < 0 )
    {
      perror( argv[idx] );
      sts = GM_F_MENU;
      goto arg_exit;
    }
  }

/* dmb:06/30/91:Simplest conversion to X */
  if ((display = XOpenDisplay (display_name)) == None)
  {
    fprintf (stderr,
      "%s: cannot connect to X server %s\n", XDisplayName (display_name));
    exit (-1);
  }

  FSEnter();

  FI_enter( display, DefaultColormap(display,DefaultScreen(display)), 32 );
/* dmb:06/30/91: end new part */

  idx = mnuIdx + 1;
  sts = GMMergePanels( &pal, &argv[idx], argc - idx, stderr );
  if ( GM_ERROR( sts ) )
    goto error_exit;

  if ( cmdOpts[VERBOSE_OPT] )
    sts = GMPrintDesc( argv[mnuIdx], PANEL_MENU, pal );

  sts = GMWriteMenu( argv[mnuIdx], PANEL_MENU, pal, stderr );
  if ( GM_ERROR( sts ) )
    goto error_exit;
  fprintf( stderr, "Completed %s\n", argv[mnuIdx] );

  XCloseDisplay (display);   /* dmb:06/30/91:Exp */
  exit( sts );

error_exit:
  XCloseDisplay (display);   /* dmb:06/30/91:Exp */

arg_exit:
  fprintf( stderr, "%s exited\n", argv[0] );
  exit( sts );
}

/**************************************************************************

Doc:  GMPParseCmdLine

Abstract:
  The GMPParseCmdLine function parses the command line.

Return Status:
  GM_S_SUCCESS  -  Success
  GM_F_USAGE    -  Invalid command usage

**************************************************************************/
/* int  *mnuIdx;    ** o - argv index for merged menu name  */
/* int  cmdOpts[];  ** o - Command line options    */
/* int  argc;       ** i - Number of command line arguments  */
/* char *argv[];    ** i - Command line arguments    */

int  GMPParseCmdLine (int  *mnuIdx,
                     int  cmdOpts[],
                     int  argc,
                     char *argv[])
{
  extern  int  opterr;
  int    i, c;

  *mnuIdx = 1;

  for ( i = 0; i < NUM_CMD_OPTS; i++ )
    cmdOpts[i] = 0;

  opterr = 0;    /* Handle invalid options here  */

	/*************************************************/
	/* sml:10-14-94:TR 249406896                     */
	/*  added -h and -w options for panel height     */
	/*  and width.                                   */
	/*************************************************/

  while ( ( c = getopt( argc, argv, "v" ) ) != -1 )
  {
    if ( c == 'v' )
    {
      cmdOpts[VERBOSE_OPT] = 1;
      (*mnuIdx)++;
    }
    else
      return( GM_F_USAGE );
  }

  if ( argc < *mnuIdx + 3 )  /* Need at least two more args  */
    return( GM_F_USAGE );

  return( GM_S_SUCCESS );
}
