/*
**	NAME:							appsig.c
**	AUTHORS:						David Michal
**	CREATION DATE:					1/92
**	ABSTRACT:
**		Contains signal handling initialization routine and the signal	
**		handling routine itself.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <errno.h>
#include <signal.h>

#if defined(__clipper__)
/* 
** CLIX needs these headers as well, prior to wait.h, to stop compiler
** warnings concerning wait3.
*/
#include <sys/types.h>
#include <sys/time.h>
#include <sys/resource.h>
#endif

#if defined(unix)
#include <sys/wait.h>
#endif
#include "app.h"


/*
**	FUNCTION PROTOTYPES
*/
#define appsig_c
#include "appsig.prt"
#include "appcli.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "comwrap.prt"
#include "sys.prt"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/
#if defined(unix)
static void (*user_sigcld_handler)();
#endif

/*
**	FUNCTIONS
*/

extern void RISapp_sighandle(
	int signo)
{
#if defined(unix)
#if defined(sun)
	int pid;
#else
	pid_t pid;
#endif
	int retry;
	int status;
	int exit_status;

	APP_DBG(("RISapp_sighandle(sig:%d)\n", signo));

	if (signo != SIGCLD)
	{
		return;
	}

	APP_DBG(("RISapp_sighandle: got SIGCLD\n"));

	if (RIS_net && RIS_net->protocol == SHMEM && RIS_net->id.shmem.pid > 0)
	{
		APP_DBG(("RISapp_sighandle: calling waitpid: pid:%d\n",
			RIS_net->id.shmem.pid));

		pid = waitpid(RIS_net->id.shmem.pid,&status,WNOHANG);
		for (retry=1;retry;)
		{
			retry = 0;
			switch(pid)
			{
				case -1:
					APP_DBG(("RISapp_sighandle: waitpid returned -1 errno:%d\n",
						errno));
					if (errno == EINTR)
					{
						APP_DBG(("RISapp_sighandle: waitpid was interupted\n"));
						retry = 1;
					}
					break;

				case 0:
					APP_DBG(("RISapp_sighandle: waitpid returned 0, client is still alive\n"));
					break;

				default:
					APP_DBG(("RISapp_sighandle: waitpid returned %d\n", pid));

					if (WIFSTOPPED(status))
					{
						APP_DBG(("RISapp_sighandle:client stopped by sig:%d\n",
							WSTOPSIG(status)));
						/* do nothing */
					}
					else if (WIFSIGNALED(status))
					{
						APP_DBG(("RISapp_sighandle: client died by sig:%d\n",
							WTERMSIG(status)));
						RISapp_cleanup_client();

						if (RIS_cnt >= 0)
						{
							RIScom_sigrelse(SIGCLD);
							LONGJMP(RIS_E_CLIENT_DIED);
						}
					}
					else if (WIFEXITED(status))
					{
						exit_status = WEXITSTATUS(status);
						APP_DBG(("RISapp_sighandle: client exited sts:%d\n",
							exit_status));

						if (exit_status != 0)
						{
							RISapp_cleanup_client();
							if (RIS_cnt >= 0)
							{
								RIScom_sigrelse(SIGCLD);
								LONGJMP(RIS_E_CLIENT_DIED);
							}
						}
					}
				break;
			}
		}							
	}

	if (user_sigcld_handler != SIG_DFL &&
		user_sigcld_handler != SIG_IGN)
	{
		APP_DBG(("RISapp_sighandle: calling user_sigcld_handler\n"));
		user_sigcld_handler(signo);
	}

	APP_DBG(("RISapp_sighandle: complete\n"));
#endif
}

/******************************************************************************/

/*
** Set up signals to be handled by the client.
*/

extern void RISapp_init_signal()
{
#if defined(unix)
	APP_DBG(("RISapp_init_signal()\n"));

	if ((user_sigcld_handler = RIScom_sigset(SIGCLD, RISapp_sighandle)) == SIG_ERR)
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	APP_DBG(("RISapp_init_signal:complete\n"));
#endif
}

/******************************************************************************/

/*
** restore signals.
*/

extern void RISapp_restore_signal()
{
#if defined(unix)
	void (*sts)();

	APP_DBG(("RISapp_restore_signal()\n"));

	if ((sts = RIScom_sigset(SIGCLD, user_sigcld_handler)) == SIG_ERR)
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	if (sts != RISapp_sighandle)
	{
		APP_DBG(("RISapp_restore_signal:sig handler for SIGCLD wasn't ours\n"));
		if (RIScom_sigset(SIGCLD, sts) == SIG_ERR)
		{
			LONGJMP(RIS_E_INTERNAL_ERROR);
		}
	}

	APP_DBG(("RISapp_restore_signal:complete\n"));
#endif
}

/******************************************************************************/
