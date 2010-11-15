/*
**	NAME:							cliterm.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					12/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <signal.h>
#include "client.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define cliterm_c
#include "cliterm.prt"
#include "netgnerc.prt"
#include "usrinit.prt"
#include "usrkill.prt"
#include "comdebug.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIScli_terminate(
	int sts)
{
	net_finish_s	app_finish;

	CLI_DBG(("RIScli_terminate(sts:%d)\n", sts));

	RISusr_terminate_transact(!sts);
	RISusr_kill_all_srvs();

	NET_close(RIS_app_net);

	if (RIS_app_read)
	{
		NET_free((char *)RIS_app_read);
		RIS_app_read = 0;
	}
	if (RIS_app_write)
	{
		NET_free((char *)RIS_app_write);
		RIS_app_write = 0;
	}

	app_finish.memory_mode = DEALLOCATE;
	NET_finish(RIS_app_net, &app_finish);

	/*
	**	exit
	*/
	CLI_DBG(("risclient: exiting\n"));
/*  On Solaris/Intel 2.4 when the client was exited the signal handlers
was getting called with signal 14.  Which caused a looping condition
in the signal handler and the client never terminated.  Since we
are about to exit anyway, the signal handler is reset to the default.
Ashley 3/20/95
*/
#if defined(Soli)
sigset(SIGALRM, SIG_DFL);
#endif
	exit (sts);
}

/******************************************************************************/
