
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "WFF.h"

/*  Global WFF structure  */

struct WFFglobal_st WFFglobal;

/* kept getting undefined symbol due to NFMitem_ptr, so I had to make it
   global.  It is never used by this code. */ 

struct NFMitem_info *NFMitem_ptr;


long main (argc, argv)
  int	argc;
  char	*argv[];
  {
	/* int	event; */
	int	status;
	int	errflag = 0;
	char	usage[4096];
	char	message[512];

	static	char *fname = "WFFmain";

	/*  Local functions  */

	void	_WFFprocess_command_file ();

	/*  External functions  */

	void _WFFinit_usage ();
	void _WFFinit_global ();
	long _WFFsetup_signals ();
	long _WFFinit_graphics ();
	void _WFFprocess_data ();
	long _WFFinit_main ();
	long _WFFinit_menus ();
	void _WFFexit ();

	void _NFMprint_copyright ();

	/*  Forms Interface functions  */

	int FI_process_forms ();


/*  Initialize "usage" string  */

    _WFFinit_usage (argv[0], usage);
/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_HPUX) || defined(OS_INTELSOL)
    /* Function added for getting fonts on SCO/HP - SSRS 2 Feb 94 */
    FI_select_X_fonts_first();
#endif

/*  Initialize global structure  */

    _WFFinit_global ();

/*  Parse input arguments  */

    _WFFparse_input (argc, argv, &errflag);
    if (errflag)
    {
	fprintf (stderr, "\n%s\n", usage);
	exit (1);
    }

/*  Default environment to same as server (per Durwood 8/6/90)  */

    if ((strcmp (WFFglobal.environment, "")) == 0)
    {
	/*  This will work even if a server was not specified  */
	strncpy (WFFglobal.environment,
			WFFglobal.server, sizeof (WFFglobal.environment) - 1);
    }

/*  Print copyright information to stderr  */

    _NFMprint_copyright ("");

/*  Check for option combinations that don't make sense  */

    if (WFFglobal.playback_time == -1)
    {
	/*  Default playback time to 1/2 of a second  */
	WFFglobal.playback_time = 30;
    }
    else if ((strcmp (WFFglobal.playback_file, "")) == 0)
    {
	/*  Print a warning message  */
	fprintf (stderr, "%s: -T option is only for playback\n", argv[0]);
    }

    if ((WFFglobal.delay_time != -1) &&
	((strcmp (WFFglobal.playback_file, "")) == 0))
    {
	/*  Print a warning message  */
	fprintf (stderr, "%s: -D option is only for playback\n", argv[0]);
	/*  Do not delay  */
	WFFglobal.delay_time = -1;
    }

/*  Set up the signal handling functions  */

    _NFIdebug ((fname, "calling _WFFsetup_signals ...\n"));
    status = _WFFsetup_signals ();
    if( status != NFI_S_SUCCESS)
    {
	_NFIdebug ((fname, "_WFFsetup_signals = <0x%.8x>\n", status));
	if (UMSGetByNum (message, status, NULL) == UMS_S_SUCCESS)
  	    fprintf (stderr, "%s: %s\n", argv[0], message);
	else
	    fprintf (stderr,"%s: An error occurred setting up signal processor\n",argv[0]);
	exit (status);
    }

/*  Initialize the graphics environment  */

    _NFIdebug ((fname, "calling _WFFinit_graphics ...\n"));
    status = _WFFinit_graphics(argv[0]);
    if( status != NFI_S_SUCCESS)
    {
	_NFIdebug ((fname, "_WFFinit_graphics = <0x%.8x>\n", status));
	if (UMSGetByNum (message, status, NULL) == UMS_S_SUCCESS)
		fprintf (stderr, "%s: %s\n", argv[0], message);
	else
		fprintf (stderr,
				"%s: An error occurred initializing graphics environment\n",argv[0]);

	if( status == NFI_E_GRAPHICS )
	    exit(status);
	else
  	    _WFFexit (status);
    }

/*  Set the flag to call FI_process_forms ()  */

    WFFglobal.call_process_forms = TRUE;

/*  Try to login to I/NFM  */

    _NFIdebug ((fname, "calling _WFFprocess_data for login ...\n"));
    _WFFprocess_data (0, WFF_M_LOGIN_TO_ENVIRONMENT);
    if (WFFglobal.cmd_status != NFI_S_SUCCESS)
    {
	_NFIdebug ((fname, "WFFconnect = <0x%.8x>\n", status));
	if (UMSGetByNum	(message, status, "%s", WFFglobal.server) == UMS_S_SUCCESS)
        {
  	    /*  Put the error message on stderr  */

  	    fprintf (stderr, "%s: %s\n", argv[0], message);
        }
	else
        {
 	    fprintf (stderr, "%s: A fatal error occurred while attempting\n",
				argv[0]);
       	    if ((strcmp (WFFglobal.server, "")) != 0)
 	    {
		fprintf (stderr,"%-*.*s  to login to I/NFM server \"%s\".\n",
		strlen (argv[0]), strlen (argv[0]), "", WFFglobal.server);
 	    }
	    else
 	    {
		fprintf (stderr, "%-*.*s  to login to an I/NFM server.\n",
				strlen (argv[0]), strlen (argv[0]), "");
	    }
		fprintf (stderr, "%-*.*s  status = 0x%.8x.\n\n", strlen (argv[0]),strlen (argv[0]), "", status);
        }
        _WFFexit (status);
    }

/*  Display the main form  */

    _NFIdebug ((fname, "calling _WFFinit_main ...\n"));
    status = _WFFinit_main ();
    if( status != NFI_S_SUCCESS)
    {
	_NFIdebug ((fname, "_WFFinit_main = <0x%.8x>\n", status));
	if (UMSGetByNum (message, status, NULL) == UMS_S_SUCCESS)
	    fprintf (stderr, "%s: %s\n", argv[0], message);
	else
	    fprintf (stderr,"%s: An error occurred initializing graphics environment\n",argv[0]);
	_WFFexit (status);
    }

/*  Load and display the product menus  */

    _NFIdebug ((fname, "calling _WFFinit_menus ...\n"));
    status = _WFFinit_menus ();
    if( status != NFI_S_SUCCESS)
    {
	_NFIdebug ((fname, "_WFFinit_menus = <0x%.8x>\n", status));
	if (UMSGetByNum (message, status, NULL) == UMS_S_SUCCESS)
  	    fprintf (stderr, "%s: %s\n", argv[0], message);
	else
	    fprintf (stderr,"%s: An error occurred loading I/NFM graphic menus\n",argv[0]);
	_WFFexit (status);
    }

/*  If there is a command file, process it  */

    _WFFprocess_command_file ();

/*  Set the flag to NOT call FI_process_forms () in the future  */

    WFFglobal.call_process_forms = FALSE;

/*  Delay the requested amount of time  */

    if (WFFglobal.delay_time != -1)
    {
	fprintf (stderr, "Beginning playback delay (%d seconds) ...\n",
		WFFglobal.delay_time);
	fflush (stderr);
	sleep (WFFglobal.delay_time);
	fprintf (stderr, "Beginning playback session ...\n");
	fflush (stderr);
    }

#ifdef XWINDOWS
    _WFF_process_x_forms();
#else
    _WFF_process_environv_forms ();
#endif

    _WFFexit (0);
  }


void _WFFprocess_command_file ()
{
	char	command_string[128];
	FILE	*infile, *fopen ();

        void    _WFFprocess_data ();

    if ((infile = fopen (WFF_COMMAND_FILE, "r")) == NULL)
    {
	/*  There is no command file, just return  */
	return;
    }

    while (_WFFfgets (command_string, sizeof (command_string), infile))
    {
	/*  Call _WFFprocess_data () just as if the
	    user pressed a button on one of the menus  */
	_WFFprocess_data (0, command_string);
    }

    fclose (infile);

    return;
}
