/*
**      NAME:                                                   netpopen.c
**      AUTHORS:                                                Terry McIntyre
**      CREATION DATE:                                  9/91
**      ABSTRACT:
**              Does the same function as the system calls popen and pclose,
**              but uses vfork instead of fork.
**      
**      REVISION HISTORY:
**              9/10/91 sunil - Moved from ../common to network as this is the only
**                      place it is used.
*/
 
/*
**      INCLUDES
*/
#if defined (unix)
# include <signal.h>
# include <fcntl.h>
# include <errno.h>
#endif

# include "net.h"

/*
**      DEFINES
*/
#if defined (__clipper__) || defined (sun) || defined(sco)
# define _NFILE  128
#elif defined(__Sol2__) || defined(__hpux__) || defined(Soli)
# if defined(_NFILE)
#  undef _NFILE
# endif
# define _NFILE 128
#endif /* clipper, sun, sco, solaris, hpux */

#define        tst(a,b) (*mode == 'r'? (b) : (a))
#define        RDR     0
#define        WTR     1

#if defined(sun) || defined(__Sol2__) || defined(__hpux__) || defined(Soli)
# define _fdopen fdopen
# define _execl execl
# define _vfork vfork
# define _pipe pipe
# define _close close
# define _fcntl fcntl
# define _wait wait
#elif defined(sco) 
# define _fdopen fdopen
# define _execl execl
# define _vfork fork
# define _pipe pipe
# define _close close
# define _fcntl fcntl
# define _wait wait
#endif /* sun, sco, solaris or hpux */

/*
**      TYPES
*/

/*
**      FUNCTION PROTOTYPES
*/
#define netpopen_c
#if defined(unix) || defined(WIN32)
# include "net_sys.prt"
# include "netpopen.prt"
# include "net_wrap.prt"
#endif
#include "net_popn.prt"

/*
**      VARIABLES
*/
#if defined (unix)
static int popen_pid[_NFILE];
static char bin_shell[] = "/bin/sh" ;
static char shell[] = "sh";
static char shflg[] = "-c";
#endif


/*
**      FUNCTIONS
*/

/******************************************************************************/

extern FILE * NET_popen(
	char    *cmd,
	char    *mode)
{

#if defined(unix)
	int     p[2];
	register int *poptr;
	register int myside, yourside, pid;
#endif

	NET_DBG(("NET_popen(cmd:<%s> mode:<%s>)\n",
		cmd ? cmd : "NULL", mode ? mode : "NULL"));

#if defined(unix)
	if(_pipe(p) < 0)
		return(NULL);
	myside = tst(p[WTR], p[RDR]);
	yourside = tst(p[RDR], p[WTR]);
	if((pid = _vfork()) == 0) {
		/* myside and yourside reverse roles in child */
		int     stdio;

		/* close all pipes from other popen's */
		for (poptr = popen_pid; poptr < popen_pid+_NFILE; poptr++) {
			if(*poptr)
				_close(poptr - popen_pid);
		}
		stdio = tst(0, 1);
		(void) _close(myside);
		(void) _close(stdio);
		(void) _fcntl(yourside, F_DUPFD, stdio);
		(void) _close(yourside);
		(void) _execl(bin_shell, shell, shflg, cmd, (char *)0);
		_exit(1);
	}
	if(pid == -1)
		return(NULL);
	popen_pid[myside] = pid;
	(void) _close(yourside);
	return(_fdopen(myside, mode));
#endif
#if defined(vms)
	return(popen(cmd, mode));
#endif
#if defined (WIN32)
	return(_popen(cmd, mode));
#endif
}

/******************************************************************************/

extern int NET_pclose(
	FILE    *ptr)
{
#if defined(unix)
	register int f, r;
	int status;
	void (*hstat)(), (*istat)(), (*qstat)();
#endif

	NET_DBG(("NET_pclose(fp:0x%x)\n", ptr));

#if defined(unix)
	f = fileno(ptr);
	(void) fclose(ptr);
	istat = sigset(SIGINT, SIG_IGN);
	qstat = sigset(SIGQUIT, SIG_IGN);
	hstat = sigset(SIGHUP, SIG_IGN);

	/* while the child is not done and no error has occured wait in the loop*/

	while((r = _wait(&status)) != popen_pid[f] && (r != -1 || errno == EINTR))
		;
	if(r == -1)
		status = -1;
	(void) sigset(SIGINT, istat);
	(void) sigset(SIGQUIT, qstat);
	(void) sigset(SIGHUP, hstat);
	/* mark this pipe closed */
	popen_pid[f] = 0;

	NET_DBG(("NET_pclose:returning status:%d\n", status));
	return(status);
#endif
#if defined(vms)
	return(pclose(ptr));
#endif
#if defined (WIN32)
	return(_pclose(ptr));
#endif
}

/******************************************************************************/
