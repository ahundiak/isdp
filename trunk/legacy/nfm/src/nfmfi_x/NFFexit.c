
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

void _NFFexit (status)
  long    status;
  {
    static  char *fname = "_NFFexit";

    NFFform_message (MAIN_LABEL, NFI_I_EXIT, NULL);

    _NFFdelete_forms ();
 
    if( NFFglobal.Help_initialized == TRUE )
    {
        _NFIdebug ((fname, "killing Help ...\n"));
        Help_kill ();
        _NFIdebug ((fname, "returned from Help_kill\n"));
    }

    _NFIdebug ((fname, "calling NFFlogout ...\n"));
    NFFlogout ();

#ifndef XWINDOWS
    _NFIdebug ((fname, "calling Exit_tools ...\n"));
    Exit_tools ();
    _NFIdebug ((fname, "returned from Exit_tools\n"));
#else
    XCloseDisplay( NFFglobal.display );
#endif

    _NFIdebug ((fname, "calling exit ...\n"));
    exit (status);
  }
