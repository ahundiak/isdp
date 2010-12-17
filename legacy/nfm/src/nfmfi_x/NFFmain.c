
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"

struct NFFglobal_st NFFglobal;

/*  This is a temporary kludge to link  */

MEMptr NFMmessage_buffer = NULL;

main (argc, argv)
  int   argc;
  char  *argv[];
  {
    auto   char  s[256];
    auto   char  usage[4096];
    auto   long  status;
    static char  *fname = "NFFmain";

    /*  Initialize "usage" string  */
    _NFFinit_usage (argv[0], usage);

    /*  Initialize global structure  */

/* HP-PORT IGI 25 Aug 94 */
/* Intel Solaris Port - CN 31/5/95 */

#if defined(OS_SCO_UNIX) || defined(OS_HPUX) || defined(OS_INTELSOL)   
    FI_select_X_fonts_first();
#endif
    _NFFinit_global ();

    /*  Parse input arguments  */

    if (_NFFparse_input (argc, argv))
      {
        fprintf (stderr, "\n%s\n", usage);
        exit (NFI_E_FAILURE);
      }

    /*  Default environment to same as server  */

    if ((strcmp (NFFglobal.environment, "")) == 0)
      {
        /*  This will work even if a server was not specified  */

        strncpy (NFFglobal.environment,
            NFFglobal.server, sizeof (NFFglobal.environment) - 1);
      }

    /*  Print copyright information to stderr  */

    _NFMprint_copyright ("");

    /*  Check for option combinations that don't make sense  */

    if (NFFglobal.playback_time == -1)
      {
        /*  Default playback time to 1/2 of a second  */

        NFFglobal.playback_time = 30;
      }
    else if ((strcmp (NFFglobal.playback_file, "")) == 0)
      {
        /*  Print a warning message  */

        fprintf (stderr, "%s: -T option is only for playback\n", argv[0]);
      }

    if ((NFFglobal.delay_time != -1) &&
        ((strcmp (NFFglobal.playback_file, "")) == 0))
      {
        /*  Print a warning message  */

        fprintf (stderr, "%s: -D option is only for playback\n", argv[0]);

        /*  Do not delay  */

        NFFglobal.delay_time = -1;
      }

    /*  The ERR subsystem might not have been initialized yet, so we
        can't use ERRget_message(); ERR subsystem is initialized in
        _NFFsetup_config() and we cannot call that until we call
        FI_enter() because of the forms/menus paths; So, we'll
        just make a best guess about the error and use fprintf() - Glenn  */

    if ((status = _NFFinit_graphics ()) != NFI_S_SUCCESS)
      {
        /*  If we're running under X, we couldn't open the display  */

        if (status == NFI_E_GRAPHICS)
          {
#ifdef XWINDOWS
            fprintf (stderr, "%s: Unable to open X display\n", argv[0]);
#else
            fprintf (stderr,
                "%s: Could not initialize graphics environment\n", argv[0]);
#endif
          }
        else
          {
            /*  Some other type of error occurred  */

            fprintf (stderr,
                "%s: Could not initialize graphics environment\n", argv[0]);
          }

        exit (status);
      }

    /*  Set up the signal handling functions  */

    _NFFsetup_signals ();

    /*  Connect (if necessary), and login  */

    if ((status = NFFlogin ()) != NFI_S_SUCCESS)
      {
        ERRget_message (s);
        fprintf (stderr, "%s\n", s);
        _NFFexit (status);
      }

#ifdef XWINDOWS
    _NFF_process_x_forms();
#else
    _NFF_process_environv_forms ();
#endif

    if (NFFglobal.status != NFI_S_SUCCESS)
      {
        ERRget_message (s);
        fprintf (stderr, "%s\n", s);
        _NFFexit (status);
      }

    if ((status = NFFinit_main_form ()) != NFI_S_SUCCESS)
      {
        ERRget_message (s);
        fprintf (stderr, "%s\n", s);
        _NFFexit (status);
      }


    _NFFinit_menus ();

    /*  Post-login processing  */

    NFFpost_login (TRUE);

#ifdef XWINDOWS
    _NFF_process_x_forms();
#else
    _NFF_process_environv_forms ();
#endif

    exit (NFI_S_SUCCESS);
  }
/*
dump_ERRstruct ()
  {
    extern struct _ERRstruct _ERRstruct;

    printf ("NFIstatus  = 0x%.8x\n", _ERRstruct.NFIstatus);
    printf ("NFMRstatus = 0x%.8x\n", _ERRstruct.NFMRstatus);
    printf ("NETCstatus = 0x%.8x\n", _ERRstruct.NETCstatus);
    printf ("NETSstatus = 0x%.8x\n", _ERRstruct.NETSstatus);
    printf ("NFMSstatus = 0x%.8x\n", _ERRstruct.NFMSstatus);
    printf ("NFMstatus  = 0x%.8x\n", _ERRstruct.NFMstatus);
    printf ("SQLstatus  = 0x%.8x\n", _ERRstruct.SQLstatus);
    printf ("MEMstatus  = 0x%.8x\n", _ERRstruct.MEMstatus);
    printf ("UTIstatus  = 0x%.8x\n", _ERRstruct.UTIstatus);
  }
*/
