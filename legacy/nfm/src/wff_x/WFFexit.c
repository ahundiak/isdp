#include "machine.h"
#include "WFF.h"

/*  Kludge to make a clean exit  */

extern long NETid;

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

void _WFFexit (status)
  int	status;
  {
    static	char *fname = "_WFFexit";

    _NFIdebug ((fname, "deleting menus ...\n"));
    MS_delete_menus ();
    _NFIdebug ((fname, "returned from MS_delete_menus\n"));

    if( WFFglobal.Help_initialized == TRUE )
    {
        _NFIdebug ((fname, "killing Help ...\n"));
        Help_kill ();
        _NFIdebug ((fname, "returned from Help_kill\n"));
    }

    if (WFFglobal.message_form != NULL)
    {
	_NFIdebug ((fname, "deleting message_form ...\n"));
	FIf_delete (WFFglobal.message_form);
	_NFIdebug ((fname, "returned from FIf_delete\n"));
    }

    if (WFFglobal.user_id != 0)
    {
 	_NFIdebug ((fname, "calling WFFlogout ...\n"));
	WFFlogout ();
	_NFIdebug ((fname, "returned from WFFlogout\n"));
    }

    _WFFmessage (NFI_I_EXIT, NULL);

    if (WFFglobal.current_form != NULL)
    {
	_NFIdebug ((fname, "deleting current_form ...\n"));
	FIf_delete (WFFglobal.current_form);
	WFFglobal.current_form = NULL;
	_NFIdebug ((fname, "returned from FIf_delete\n"));
    }

    if (WFFglobal.main_form != NULL)
    {
	_NFIdebug ((fname, "deleting main_form ...\n"));
	FIf_delete (WFFglobal.main_form);
	WFFglobal.main_form = NULL;
	_NFIdebug ((fname, "returned from FIf_delete\n"));
    }

    _WFFerase_message ();

#ifndef XWINDOWS
    _NFIdebug ((fname, "calling Exit_tools ...\n"));
    Exit_tools ();
    _NFIdebug ((fname, "returned from Exit_tools\n"));
#else
    _NFIdebug ((fname, "calling XCloseDisplay ...\n"));
    XCloseDisplay( WFFglobal.display );
#endif

    _NFIdebug ((fname, "calling exit ...\n"));
    exit (status);
  }
