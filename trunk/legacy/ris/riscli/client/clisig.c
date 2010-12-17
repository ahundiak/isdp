/*
**	NAME:							clisig.c
**	AUTHORS:						David Michal
**	CREATION DATE:					1/92
**	ABSTRACT:
**		Contains signal handling initialization routine and the signal	
**		handling routine itself.
**	
**	REVISION HISTORY:
**		02-15-93	Grace Oliver	These funtions are not used in NT
**									client.
*/
 
#if defined(unix) 

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
#include <sys/wait.h>
#include "client.h"

/*
**	FUNCTION PROTOTYPES
*/
#define clisig_c
#include "clisig.prt"
#include "cliterm.prt"
#include "comjmp.prt"
#include "comdebug.prt"
#include "comwrap.prt"
#include "netgnerc.prt"
#include "sys.prt"

/*
**	DEFINES
*/

#if defined(__Sol2__)
#define _NSIG _sys_nsig
#elif defined(Soli)
# define _NSIG 34
#elif defined(sun) || defined(sco)
#define _NSIG NSIG
#endif

#define OUT_FILE        "/usr/tmp/riscli.out"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

extern void RIScli_sighandle(
	int signo)
{
	int			pid;
	int			retry;
	int			status;
	int			exit_status;
	risschema	*schema;

CLI_DBG(("\nRIScli_sighandle sig = %d\n",signo));

	switch(signo)
	{
		case SIGCLD:

CLI_DBG(("got SIGCLD\n"));

			/* check local servers */

			for (schema=RIS_srvs;schema;schema=schema->next)
			{
				if (schema->net->protocol == SHMEM &&
					schema->net->id.shmem.pid > 0)
				{

CLI_DBG(("checking server schname = <%s> pid = %d\n", schema->schname,
	schema->net->id.shmem.pid));
#if defined (sco)
					pid = (int)waitpid((pid_t)schema->net->id.shmem.pid,&status,WNOHANG);
#else
					pid = waitpid(schema->net->id.shmem.pid,&status,WNOHANG);
#endif
					for (retry=1;retry;)
					{
						retry = 0;
						switch(pid)
						{
							case -1:
								CLI_DBG(("waitpid() returned -1 errno:%d\n",
									errno));
								if (errno == EINTR)
								{
									CLI_DBG(("waitpid() was interupted\n"));
									retry = 1;
								}
							break;
							case 0:
								CLI_DBG(("waitpid() returned 0, server is still alive\n"));
							break;
							default:
								CLI_DBG(("waitpid() returned %d\n", pid));
								/* this server may be dead */
								if (WIFEXITED(status))
								{
									exit_status = WEXITSTATUS(status);
									CLI_DBG(("server exited with sts %d\n",
										exit_status));

								/*
								** if we were trying to kill this server then
								** longjmp so the client won't hang
								*/

									if (RIS_killing_srv_pid == pid)
									{
										RIScom_sigrelse(SIGCLD);
										LONGJMP(RIS_E_SERVER_IS_DEAD);
									}
									else
									{
										if (exit_status != 0)
										{
											NET_invalidate_connection(
												schema->net);
										}
									}
								}
								if (WIFSIGNALED(status))
								{
									CLI_DBG(("server died by signal %d\n",
										WTERMSIG(status)));

								/*
								** if we were trying to kill this server then
								** longjmp so the client won't hang
								*/

									if (RIS_killing_srv_pid == pid)
									{
										RIScom_sigrelse(SIGCLD);
										LONGJMP(RIS_E_SERVER_IS_DEAD);
									}
									else
									{
										NET_invalidate_connection(schema->net);
									}
								}
								if (WIFSTOPPED(status))
								{
									CLI_DBG(("server stopped by signal %d\n",
										WSTOPSIG(status)));
								}
							break;
						}
					}							
				}
            }

			/* check deadbeat local servers */

			for (schema=RIS_deadbeat_srvs;schema;schema=schema->next)
			{

CLI_DBG(("checking deadbeat server schname = <%s> pid = %d\n", schema->schname,
	schema->net->id.shmem.pid));
#if defined (sco)
				pid = (int)waitpid((pid_t)schema->net->id.shmem.pid,&status,WNOHANG);
#else
				pid = waitpid(schema->net->id.shmem.pid,&status,WNOHANG);
#endif
				for (retry=1;retry;)
				{
					retry = 0;
					switch(pid)
					{
						case -1:
							CLI_DBG(("waitpid() returned -1 errno:%d\n",
								errno));
							if (errno == EINTR)
							{
								CLI_DBG(("waitpid() was interupted\n"));
								retry = 1;
							}
						break;
						case 0:
							CLI_DBG(("waitpid() returned 0, deadbeat server is still alive\n"));
						break;
						default:
							CLI_DBG(("waitpid() returned %d\n", pid));
							/* this server may be dead */
							if (WIFEXITED(status))
							{
								exit_status = WEXITSTATUS(status);
								CLI_DBG(("deadbeat server exited with sts %d\n",
									exit_status));

							/*
							** if we were trying to kill this server then
							** longjmp so the client won't hang
							*/

								if (RIS_killing_srv_pid == pid)
								{
									RIScom_sigrelse(SIGCLD);
									LONGJMP(RIS_E_SERVER_IS_DEAD);
								}
								else
								{
									if (exit_status != 0)
									{
										NET_invalidate_connection(
											schema->net);
									}
								}
							}
							if (WIFSIGNALED(status))
							{
								CLI_DBG(("deadbeat server died by signal %d\n",
									WTERMSIG(status)));

							/*
							** if we were trying to kill this server then
							** longjmp so the client won't hang
							*/

								if (RIS_killing_srv_pid == pid)
								{
									RIScom_sigrelse(SIGCLD);
									LONGJMP(RIS_E_SERVER_IS_DEAD);
								}
								else
								{
									NET_invalidate_connection(schema->net);
								}
							}
							if (WIFSTOPPED(status))
							{
								CLI_DBG(("deadbeat server stopped by signal %d\n",
									WSTOPSIG(status)));
							}
						break;
					}
				}
            }

		break;

		case SIGPIPE:

		/* do nothing here */

		break;

		case SIGUSR1:
			RIScom_initialize_debug();
		break;

		case SIGHUP:
		case SIGINT:
		case SIGQUIT:
		case SIGILL:
		case SIGABRT:
		case SIGEMT:
		case SIGFPE:
		case SIGBUS:
		case SIGSEGV:
		case SIGSYS:
		case SIGTERM:
		case SIGUSR2:
#if !defined(sun)
		case SIGPWR:
#endif
#ifdef sco
		case SIGWINCH:
		case 21 /* SIGPHONE */:
#endif
			RIScli_restore_signal();
			RIScli_terminate(-1);
		break;
		default:
			CLI_DBG(("unknown signal\n"));
		break;
	}
	CLI_DBG(("\nRIScli_sighandle returning\n"));
}

/******************************************************************************/

/*
** Set up signals to be handled by the client.
*/

extern void RIScli_init_signal()
{
	int sig;

CLI_DBG(("\nRIScli_init_signal\n"));

	for (sig=1;sig < _NSIG;sig++)
	{
		switch(sig)
		{

/* handle these signals */

			case SIGHUP:
			case SIGINT:
			case SIGQUIT:
			case SIGILL:
			case SIGABRT:
			case SIGEMT:
			case SIGFPE:
			case SIGBUS:
			case SIGSEGV:
			case SIGSYS:
			case SIGPIPE:
			case SIGTERM:
			case SIGUSR1:
			case SIGUSR2:
#if !defined(sun)
			case SIGPWR:
#endif
			case SIGCLD:
				if (RIScom_sigset(sig,RIScli_sighandle) == SIG_ERR)
				{
					LONGJMP(RIS_E_INTERNAL_ERROR);
				}
			break;

			/*
			** leave these signals alone
			*/

			case SIGTRAP:
			case SIGKILL:
			case SIGALRM:
#if !defined(sco)
			case SIGURG:
			case SIGIO:
#endif
#if defined(__clipper__) || defined(sco)
			case SIGPOLL:
#endif 
			case SIGSTOP:
			case SIGTSTP:
			case SIGTTIN:
			case SIGTTOU:
			case SIGCONT:
#if defined(sun) 
			case SIGXCPU:
			case SIGXFSZ:
			case SIGWINCH:
			case SIGLOST:
#endif
#if defined (__Sol2__) || defined(Soli)
			case SIGXCPU:
			case SIGXFSZ:
			case SIGWAITING:
			case SIGLWP:
			case SIGWINCH:
#if defined (__Sol2__)
			case SIGFREEZE:
			case SIGTHAW:
			case _SIGRTMIN:
			/*
			** KLUDGE for Solaris, there are no 
			** macros for signals from 37 thru 42.
			*/

			case 37:
			case 38:
			case 39:
			case 40:
			case 41:
			case 42:
			case _SIGRTMAX:
			/* Fix to TR# 439600069 -kmreddy */
			/* The _NSIG value in V2.5 is 45 */
			case 44:

#endif /* Solaris SPARC only */
#endif
#if defined (__hpux__)
                        case SIGWINCH:
                        case SIGLOST:
                        case 31:
                        case 32:
#endif

#ifdef sco
			case SIGWINCH:
			case 21 /* SIGPHONE */:
#endif
#ifdef SIGVTALRM
			case SIGVTALRM:
			case SIGPROF:
#endif
			break;
			default:
				LONGJMP(RIS_E_INTERNAL_ERROR);
			break;
		}
	}
}

/******************************************************************************/

/*
** Restore default signal handling
*/

extern void RIScli_restore_signal()
{
	int sig;

CLI_DBG(("\nRIScli_restore_signal\n"));

	for (sig=1;sig < _NSIG;sig++)
	{
		switch(sig)
		{

/* these signals were handled*/

			case SIGHUP:
			case SIGINT:
			case SIGQUIT:
			case SIGILL:
			case SIGABRT:
			case SIGEMT:
			case SIGFPE:
			case SIGBUS:
			case SIGSEGV:
			case SIGSYS:
			case SIGPIPE:
			case SIGTERM:
			case SIGUSR1:
			case SIGUSR2:
#if !defined(sun)
			case SIGPWR:
#endif
			case SIGCLD:
				RIScom_sigset(sig,SIG_DFL);
			break;

			/*
			** leaves these signals alone
			*/

			case SIGTRAP:
			case SIGKILL:
			case SIGALRM:
#if defined (__hpux__)
			case SIGWINCH:
			case SIGLOST:
			case 31:
			case 32:
#endif
#if !defined(sco)
			case SIGURG:
			case SIGIO:
#endif
#if defined(__clipper__) || defined(sco)
			case SIGPOLL:
#endif 
			case SIGSTOP:
			case SIGTSTP:
			case SIGTTIN:
			case SIGTTOU:
			case SIGCONT:
#if defined(sun)
			case SIGXCPU:
			case SIGXFSZ:
			case SIGWINCH:
			case SIGLOST:
#endif
#if defined (__Sol2__) || defined(Soli)
			case SIGLWP:
			case SIGWAITING:
			case SIGXCPU:
			case SIGXFSZ:
			case SIGWINCH:
#if defined(__Sol2__)
			case SIGFREEZE:
			case SIGTHAW:
			case _SIGRTMIN:
			/*
			** KLUDGE for Solaris, there are no 
			** macros for signals from 37 thru 42.
			*/

			case 37:
			case 38:
			case 39:
			case 40:
			case 41:
			case 42:
			case _SIGRTMAX:
			/* Fix to TR# 439600069 -kmreddy */
			/* The _NSIG value in V2.5 is 45 */
			case 44:
#endif /* Solaris SPARC only */
#endif
#ifdef SIGVTALRM
			case SIGVTALRM:
			case SIGPROF:
#endif
#ifdef sco
			case SIGWINCH:
			case 21 /* SIGPHONE */:
#endif
			break;
			default:
				CLI_DBG(("unknown signal\n"));
			break;
		}
	}
}

#endif
/******************************************************************************/
