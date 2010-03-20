#include <sys/types.h>
#include <string.h>
#include <stdio.h>

#include <X11/Xlib.h>


#include "FIdyn.h"
#include "GMmenu.h"
#include "GMerror.h"

#include "GMproto_pri.h"
#include "XFIproto_pub.h"

#define  NUM_CMD_OPTS  1
#define  VERBOSE_OPT   0

Display *display;
char *display_name = "";		/*02-08-93:sml:	use default display or 
								  what's in $DISPLAY */
#if !defined(licensing_off)
	 /* I/Lic_tool stuff -- JAJ:01/25/92 ***/
#include "api.h"
#endif

#if !defined(licensing_off)
/* I/Lic_tool stuff -- JAJ:01/25/92 ***/
API_HANDLE_SHUTDOWN ()
#endif

int panelPalHeight = -1;	/* command line-specified panel height */
int panelPalWidth = -1;		/* command line-specified panel width */

/**************************************************************************

Doc:  main

Abstract:
  This program reads an ASCII outline describing a menu and writes
  the I/FORMS file(s) for the menu.

History:
  25-APR-1988  tjz  "Liberated" mk_mnu from UI people to
                    add command strings and help topics
  27-JUN-1988  tjz  Tweeked copy to do MENU_STRIPs
  20-AUG-1988  tjz  Created genmenu from mk_mnu and I/MB
  25-SEP-1989  tjz  Updated genmenu to I/FORMS menu system

**************************************************************************/

int  main(int  argc,
          char  *argv[])
{
  struct  GMPalette  *palList;
  FILE   *otlFp;
  int    sts, savsts, menuType, cmdOpts[NUM_CMD_OPTS];
  char   otlFile[GM_FILENAME_LEN], mnuFile[GM_FILENAME_LEN], palPrefix[16];


  sts = GMParseCmdLine( otlFile, mnuFile, palPrefix, cmdOpts, argc, argv );
  if ( GM_ERROR( sts ) )
  {
    fprintf( stderr,
      "usage : %s [-v] [-p <palette name prefix>] [-h <panel height>] [-w <panel width>] <outline> <menu file>\n\nHeight and width must be integers\n",
       argv[0] );
    goto error_exit;
  }

  if ( strcmp( otlFile, "-" ) == 0 )
    otlFp = stdin;
  else if ( ( otlFp = fopen( otlFile, "r" ) ) == NULL )
  {
    fprintf( stderr, "Error opening %s", otlFile );
    perror( " " );
    sts = GM_F_OUTLINE;
    goto error_exit;
  }

  savsts = GMGetMenuData( &menuType, &palList, palPrefix, otlFp, stderr );
  if ( otlFp != stdin )
    fclose( otlFp );

  if ( GM_ERROR( savsts ) )
  {
    sts = savsts;
    goto error_exit;
  }

  if ( cmdOpts[VERBOSE_OPT] )
    sts = GMPrintDesc( mnuFile, menuType, palList );


#if !defined(licensing_off)
  /* I/Lic_tool stuff -- JAJ:01/25/92 ***/
  API_GET_LICENSE ( "SN01252", "1992" )
#endif

/* dmb:06/30/91:Simplest conversion to X */
  if ((display = XOpenDisplay (display_name)) == None)
  {
    fprintf (stderr, 
      "%s: cannot connect to X server %s\n", XDisplayName (display_name));
    exit (-1);
  }

  FSEnter();

  FI_enter( display, DefaultColormap(display,DefaultScreen(display)), 32 );
/* end new part */

  sts = GMWriteMenu( mnuFile, menuType, palList, stderr );
  if ( GM_ERROR( sts ) )
  {
    XCloseDisplay (display);   /* dmb:06/30/91:Exp */
    goto error_exit;
  }
  fprintf( stderr, "Completed %s\n", mnuFile );

  XCloseDisplay (display);   /* dmb:06/30/91:Exp */
  exit( savsts );

error_exit:
  fprintf( stderr, "%s exited\n", argv[0] );
  exit( sts );
}

/**************************************************************************

Doc:  GMParseCmdLine

Abstract:
  The GMParseCmdLine function parses the command line.

Return Status:
  GM_S_SUCCESS  -  Success
  GM_F_USAGE    -  Invalid command usage

**************************************************************************/
/* char  *otlFile;    ** o - Input outline file name    */
/* char  *mnuFile;    ** o - Output menu file name    */
/* char  *palPrefix;  ** o - Optional prefix for palette names*/
/* int   cmdOpts[];   ** o - Command line options    */
/* int   argc;        ** i - Number of command line arguments  */
/* char  *argv[];     ** i - Command line arguments    */

int  GMParseCmdLine (char  *otlFile,
                     char  *mnuFile,
                     char  *palPrefix,
                     int   cmdOpts[],
                     int   argc,
                     char  *argv[])
{
  extern  int  opterr;
  extern  char  *optarg;
  int     i, c;

  if ( argc < 3 )
    return( GM_F_USAGE );

  strcpy( otlFile, argv[argc - 2] );
  strcpy( mnuFile, argv[argc - 1] );

  palPrefix[0] = '\0';

  for ( i = 0; i < NUM_CMD_OPTS; i++ )
    cmdOpts[i] = 0;

  opterr = 0;    /* Handle invalid options here  */

	/*************************************************/
	/* sml:10-14-94:TR 249406896                     */
	/*  added -h and -w options for panel height     */
	/*  and width.                                   */
	/*************************************************/

  while ( ( c = getopt( argc, argv, "vp:h:w:" ) ) != -1 )
  {
    switch ( c )
    {
    case 'p':
      strncpy( palPrefix, optarg, 14 );
      palPrefix[14] = '\0';
      break;
    case 'v':
      cmdOpts[VERBOSE_OPT] = 1;
      break;
	case 'h':
	  panelPalHeight = atoi(optarg);
	  break;
	case 'w':
	  panelPalWidth = atoi(optarg);
	  break;
    default:
      return( GM_F_USAGE );
    }
  }

  return( GM_S_SUCCESS );
}
