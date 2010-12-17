/*
**      NAME:                                                   netwrap.c
**      AUTHORS:                                                Jin Jing 
**      CREATION DATE:                                  6/92
**      ABSTRACT:
**      
**      REVISION HISTORY:
*/

#define NO_NET_DBG
 
/*
**      INCLUDES
*/
#include <stdarg.h>

#if defined(unix) || defined(WIN32) || defined(vms)
#include <errno.h>
#include <signal.h>
#endif

#if defined(DOS)
#include <errno.h>
#endif
#include "net.h"

/*
**      DEFINES
*/

/*
**      TYPES
*/

/*
**      FUNCTION PROTOTYPES
*/
#define netwrap_c
#include "netwrap.prt"
/*START_PRT_INCLUDE*/
#include "net_wrap.prt"
/*STOP_PRT_INCLUDE*/
#include "net_sys.prt"

/*
**      VARIABLES
*/

/*
**      FUNCTIONS
*/

/******************************************************************************/

#if defined(unix) || defined(WIN32)
extern int NET_chmod(
	char *path,
	int mode)
{
	int status;

	NET_DBG(("NET_chmod()\n"));
	do
	{
#if defined(sco) || defined(__Sol2__) || defined(Soli) || defined(__hpux__)
		if ((status = chmod(path,(mode_t)mode)) == -1)
#elif defined(__clipper__) || defined(sun)
		if ((status = chmod(path,mode)) == -1)
#elif defined(WIN32)
		if ((status = _chmod(path,mode)) == -1)
#else
ERROR - UNKNOWN PLATFORM !!!
#endif
		{
			NET_DBG(("NET_chmod: status:%d errno:%d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	NET_DBG(("NET_chmod: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(DOS) || defined(vms) || defined(WIN32)
extern int NET_sys_close(
	int fd)
{
	int status;

	NET_DBG(("NET_sys_close()\n"));
	do
	{
#if defined(unix) || defined(DOS) || defined(vms)
		if ((status = close(fd)) == -1)
#endif
#if defined(WIN32)
		if ((status = _close(fd)) == -1)
#endif
		{
			NET_DBG(("NET_sys_close: status:%d errno:%d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	NET_DBG(("NET_sys_close: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32)
/*
**      WARNING: no NET_DBG allowed because this function is used in NET_init()
**            before the output device is initialized.   
*/
extern int NET_dup(
	int fd)
{
	int status;

	do
	{
#if defined(unix) || defined(vms)
		status = dup(fd);
#endif
#if defined(WIN32)
		status = _dup(fd);
#endif
	}
	while (status == -1 && errno == EINTR);

	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32)
extern int NET_execl(
	char *path,
	char *argv0,
	char *argv1,
	char *argv2,
	char *argv3,
	char *argv4)
{
	int status;

	NET_DBG(("NET_execl()\n"));
	do
	{
#if defined(unix) || defined(vms)
		if ((status = execl(path,argv0,argv1,argv2,argv3,argv4)) == -1)
#endif
#if defined(WIN32)
		if ((status = _execl(path,argv0,argv1,argv2,argv3,argv4)) == -1)
#endif
		{
			NET_DBG(("NET_execl: status:%d errno:%d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	NET_DBG(("NET_execl: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32)
extern int NET_fclose(
	FILE *stream)
{
	int status;

	NET_DBG(("NET_fclose()\n"));
	do
	{
		if (errno == EINTR)
		{
			errno = 0;
		}
		if ((status = fclose(stream)) == EOF)
		{
			NET_DBG(("NET_fclose: status:<%s> errno:%d\n",status, errno));
		}
	}
	while (status == EOF && errno == EINTR);

	NET_DBG(("NET_fclose: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(DOS)
extern int NET_fcntl(
	int fd,
	int cmd,
	int arg)
{
	int status;

	NET_DBG(("NET_fcntl()\n"));
	do
	{
		if ((status = fcntl(fd, cmd, arg)) == -1)
		{
			NET_DBG(("NET_fcntl: status:%d errno:%d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	NET_DBG(("NET_fcntl: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32)
extern char *NET_fgets(
	char *st,
	int n,
	FILE *fd)
{
	char *status;

	NET_DBG(("NET_fgets()\n"));
	do
	{
		if (errno == EINTR)
		{
			errno = 0;
		}
		if ((status = fgets(st, n, fd)) == NULL)
		{
			NET_DBG(("NET_fgets: status:<%s> errno:%d\n",status, errno));
		}
	}
	while (status == NULL && errno == EINTR);

	NET_DBG(("NET_fgets: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32)
extern FILE *NET_fopen(
    char *fname,
	char *type)
{
	FILE *status;

	NET_DBG(("NET_fopen()\n"));
	do
	{
		if (errno == EINTR)
		{
			errno = 0;
		}
		if ((status = fopen(fname, type)) == NULL)
		{
			NET_DBG(("NET_fopen: status:<%s> errno:%d\n",status, errno));
		}
	}
	while (status == NULL && errno == EINTR);

	NET_DBG(("NET_fopen: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32)
extern int NET_getc(
	FILE *stream)
{
	int status;

	NET_DBG(("NET_getc()\n"));
	do
	{
		if (errno == EINTR)
		{
			errno = 0;
		}
		if ((status = getc(stream)) == EOF)
		{
			NET_DBG(("NET_getc: status:<%s> errno:%d\n",status, errno));
		}
	}
	while (status == EOF && errno == EINTR);

	NET_DBG(("NET_getc: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(__clipper__)
extern int NET_getmsg(
	int fd,
	struct strbuf *ctlptr,
	struct strbuf *dataptr,
	int *flags)
{
	int status;

	NET_DBG(("NET_getmsg()\n"));
	do
	{
		if ((status = getmsg(fd, ctlptr, dataptr, flags)) == -1)
		{
			NET_DBG(("NET_getmsg: status:%d errno:%d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	NET_DBG(("NET_getmsg: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) && !defined(sco)
extern int NET_ioctl(
	int fd,
	int req,
	...) 
{
	int status;
	va_list pvar;
	int pvar_int;

	va_start(pvar, req);
	pvar_int = va_arg(pvar, int);
	va_end(pvar);

	NET_DBG(("NET_ioctl()\n"));
	do
	{
		status = ioctl(fd, req, pvar_int);
		if (status == -1)
		{
			NET_DBG(("NET_ioctl: status:%d errno:%d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	NET_DBG(("NET_ioctl: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32)
extern int NET_open(
    char *path,
	int oflag,
    ...)
{
	int status;
	va_list pvar;
	int pvar_int;

	va_start(pvar, oflag);
	pvar_int = va_arg(pvar, int);
	va_end(pvar);

	NET_DBG(("NET_open()\n"));
	do
	{
#if defined(unix) || defined(vms)
		status = open(path, oflag, pvar_int);
#endif
#if defined(WIN32)
		status = _open(path, oflag, pvar_int);
#endif
		if (status == -1)
		{
			NET_DBG(("NET_open: status:%d errno:%d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	NET_DBG(("NET_open: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(__clipper__)
extern int NET_poll(
	struct pollfd fds[],
	unsigned long nfds,
	int timeout)
{
	int status;

	NET_DBG(("NET_poll()\n"));
	do
	{
		if ((status = poll(fds, nfds, timeout)) == -1)
		{
			NET_DBG(("NET_poll: status:%d errno:%d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	NET_DBG(("NET_poll: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(__clipper__)
extern int NET_putmsg(
	int fd,
	struct strbuf *ctlptr,
	struct strbuf *dataptr,
	int flags)
{
	int status;

	NET_DBG(("NET_putmsg()\n"));
	do
	{
		if ((status = putmsg(fd, ctlptr, dataptr, flags)) == -1)
		{
			NET_DBG(("NET_putmsg: status:%d errno:%d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	NET_DBG(("NET_putmsg: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32)
extern int NET_remove(
	char *path)
{
	int status;

	NET_DBG(("NET_remove()\n"));
	do
	{
		if ((status = remove(path)) == -1)
		{
			NET_DBG(("NET_remove: status:%d errno:%d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	NET_DBG(("NET_remove: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix)
extern int NET_sighold(
	int sig)
{
	int status;

	NET_DBG(("NET_sighold()\n"));
	do
	{
		if ((status = sighold(sig)) == -1)
		{
			NET_DBG(("NET_sighold: status:%d errno:%d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	NET_DBG(("NET_sighold: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix)
extern int NET_sigrelse(
	int sig)
{
	int status;

	NET_DBG(("NET_sigrelse()\n"));
	do
	{
		if ((status = sigrelse(sig)) == -1)
		{
			NET_DBG(("NET_sigrelse: status:%d errno:%d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	NET_DBG(("NET_sigrelse: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix)
extern void (*NET_sigset(
	int sig,
	void (*func)(int))
	)(int)
{
	void (*sig_handler)(int);

	NET_DBG(("NET_sigset()\n"));
	do
	{
#if defined(__hpux__)
		if ((sig_handler = (void (*)())sigset(sig, func)) == SIG_ERR)
#else
		if ((sig_handler = sigset(sig, func)) == SIG_ERR)
#endif
		{
			NET_DBG(("NET_sigset: sig_handler:0x%x errno:%d\n",
				sig_handler, errno));
		}
	}
	while (sig_handler == SIG_ERR && errno == EINTR);

	NET_DBG(("NET_sigset: complete\n"));
	return sig_handler;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32)
extern int NET_stat(
	char *path,
	struct stat *buffer)
{
	int status;

	NET_DBG(("NET_stat()\n"));
	do
	{
#if defined(unix) || defined(vms)
		if ((status = stat(path, buffer)) == -1)
#endif
#if defined(WIN32)
		if ((status = _stat(path, (struct _stat *)buffer)) == -1)
#endif
		{
			NET_DBG(("NET_stat: status:%d errno:%d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	NET_DBG(("NET_stat: complete\n"));
	return status;
}
#endif

/*****************************************************************************/

#if defined(unix) || defined(vms)
extern char *NET_tmpnam(
	char *st)
{
	char *status;

	NET_DBG(("NET_tmpnam()\n"));
	do
	{
		if (errno == EINTR)
		{
			errno = 0;
		}
		if ((status = tmpnam(st)) == NULL)
		{
			NET_DBG(("NET_tmpnam: status:<%s> errno:%d\n",status, errno));
		}
	}
	while (status == NULL && errno == EINTR);

	NET_DBG(("NET_tmpnam: complete\n"));
	return status;
}
#endif

#if defined(WIN32)
extern char *NET_tmpnam(
	char *st)
{
	int	 result;
	char path[MAX_PATH];

	NET_DBG(("NET_tmpnam()\n"));
	if (result = GetTempPath(MAX_PATH, path) == 0)
	{
		NET_DBG(("NET_tmpnam: GetTmpPath Error: %d\n", GetLastError()));
		return((char *)result);
	}
	NET_DBG(("NET_tmpnam: GetTmpPath: %s\n", path));
	if (result = GetTempFileName(path, "RIS", 0, st) == 0)
	{
		NET_DBG(("NET_tmpnam: GetTmpFileName Error: %d\n", GetLastError()));
		return((char *)result);
	}
	NET_DBG(("NET_tmpnam: GetTmpFileName: %s\n", st));
	NET_DBG(("NET_tmpnam: complete\n"));
	return((char *)result);
}
#endif

/******************************************************************************/
