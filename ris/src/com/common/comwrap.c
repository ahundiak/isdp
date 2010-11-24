/* Do not alter this SPC information: $Revision: 1.4.28.1 $ */
/*
**      NAME:                                                   comwrap.c
**      AUTHORS:                                                Jin Jing 
**      CREATION DATE:                                  6/92
**      ABSTRACT:
**      
**      REVISION HISTORY:
**          Feb. 94, Added function RIScom_execvp() - Sanju.
**  
**          11/94:  RIScom_fopen core dumps with a null file pointer.
**                  Fixed.  Pat/Paula
*/

#define NO_COM_DBG

#define __EXTENSIONS__

#include <errno.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <pwd.h>
#include <unistd.h>
#include <signal.h>

#include "risdebug.h"
#include "riscom.h"

/******************************************************************************/

#if defined(unix) || defined(WIN32) || defined(DOS) || defined(vms)
extern int RIScom_access(
	char *path,
	int access_mode)
{
	int status;

	COM_DBG(("RIScom_access(path: <%s> access_mode: %d)\n",path,access_mode));
	do
	{
#if defined(WIN32) || defined(DOS)
		if ((status = _access(path,access_mode)) == -1)
#endif
#if defined(unix) || defined(vms)
		if ((status = access(path,access_mode)) == -1)
#endif
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	COM_DBG(("RIScom_access: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(WIN32)
extern int RIScom_chmod(
	char *path,
	int mode)
{
	int status;

	COM_DBG(("RIScom_chmod(path: <%s> mode: 0x%x)\n",path,mode));
	do
	{
#if defined(unix) && !defined(sco)
		if ((status = chmod(path,mode)) == -1)
#elif defined(sco)
		if ((status = chmod(path,(mode_t)mode)) == -1)
#elif defined(WIN32)
		if ((status = _chmod(path,mode)) == -1)
#else
	!!! ERROR - NO CODE !!!
#endif
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	COM_DBG(("RIScom_chmod: complete\n"));
	return status;
}
#endif

#if defined(unix)
extern int RIScom_chown(
	char *path,
	int owner,
	int group)
{
	int status;

	COM_DBG(("RIScom_chown(path: <%s> owner: <%d> group: <%d>\n",
		  path,owner, group));
	do
	{
		if ((status = chown(path, (uid_t)owner, (gid_t)group)) == -1)
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	COM_DBG(("RIScom_chown: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32)
extern int RIScom_close(
	int fd)
{
	int status;

	COM_DBG(("RIScom_close(fd: %d)\n",fd));
	do
	{

#if defined(unix) || defined(vms)
		if ((status = close(fd)) == -1)
#endif
#if defined(WIN32)
		if ((status = _close(fd)) == -1)
#endif
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	COM_DBG(("RIScom_close: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32)
extern int RIScom_creat(
	char *path,
	int mode)
{
	int status;

	COM_DBG(("RIScom_creat(path: <%s> mode: 0x%x)\n",path,mode));
	do
	{
#if defined(unix) && !defined(sco) || defined(vms)
		if ((status = creat(path, mode)) == -1)
#elif defined(sco)
		if ((status = creat(path, (mode_t)mode)) == -1)
#elif defined(WIN32)
		if ((status = _creat(path, mode)) == -1)
#else
	!!! ERROR - NO CODE !!!
#endif
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	COM_DBG(("RIScom_creat: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32)
extern int RIScom_execv(
	char *path,
	char *argv[])
{
	int status;

	COM_DBG(("RIScom_execv(path: <%s> argv: 0x%x)\n",path,argv));
	do
	{
#if defined(unix) || defined(vms)
		if ((status = execv(path, argv)) == -1)
#elif defined(WIN32)
		if ((status = _execv(path, argv)) == -1)
#else
	!!! ERROR - NO CODE !!!
#endif
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	COM_DBG(("RIScom_execv: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32)
extern int RIScom_execve(
	char *path,
	char *argv[],
	char *envp[])
{
	int status;

	COM_DBG(("RIScom_execve(path: <%s> argv: 0x%x envp: 0x%x)\n",
		path, argv, envp));
	do
	{
#if defined(unix) || defined(vms)
		if ((status = execve(path, argv, envp)) == -1)
#endif
#if defined(WIN32)
		if ((status = _execve(path, argv, envp)) == -1)
#endif
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	COM_DBG(("RIScom_execve: complete\n"));
	return status;
}
#endif
/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32)
extern int RIScom_execvp(
	char *file,
	char *argv[])
{
	int status;

	COM_DBG(("RIScom_execvp(file: <%s> argv: 0x%x \n",
		path, argv));
	do
	{
#if defined(unix) || defined(vms)
		if ((status = execvp(file, argv)) == -1)
#endif
#if defined(WIN32)
		if ((status = _execvp(file, argv)) == -1)
#endif
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	COM_DBG(("RIScom_execvp: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32) || defined(DOS)
extern int RIScom_fclose(
	FILE *stream)
{
	int status = 0;

	COM_DBG(("RIScom_fclose(stream: %d)\n", stream));
	if ( stream )
	{
            do
    	    {
		errno = -1;
		if ((status = fclose(stream)) == EOF)
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	   
  	    }
 	    while (status == EOF && errno == EINTR);
        }
	COM_DBG(("RIScom_fclose: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32) || defined(DOS)
extern char *RIScom_fgets(
	char *st,
	int n,
	FILE *fd)
{
	char *status;

	COM_DBG(("RIScom_fgets(st: <%s> n %d fd 0x%x)\n", st, n, fd));
	do
	{
		errno = -1;
		if ((status = fgets(st, n, fd)) == NULL)
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == NULL && errno == EINTR);

	COM_DBG(("RIScom_fgets: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32) || defined(DOS)
extern FILE *RIScom_fopen(
    char *fname,
	char *type)
{
	FILE *status;

	COM_DBG(("RIScom_fopen(fname: <%s> type: <%s>)\n", fname, type));
	do
	{
		errno = -1;
		if ((status = fopen(fname, type)) == NULL)
		{
			COM_DBG(("status = <%s> errno = %d\n",status, errno));
		}
	}
	while (status == NULL && errno == EINTR);

	COM_DBG(("RIScom_fopen: complete\n"));
	return status;
}
#endif

/******************************************************************************/


#if defined(unix) || defined(vms) || defined(WIN32) || defined(DOS)
extern int RIScom_fputc(
	int c,
	FILE *fd)
{
	int status;

	COM_DBG(("RIScom_fputc(c: %d fd 0x%x)\n", c, fd));
	do
	{
		errno = -1;
		if ((status = fputc(c, fd)) == EOF)
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == EOF && errno == EINTR);

	COM_DBG(("RIScom_fputc: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32) || defined(DOS)
extern int RIScom_fputs(
	char *st,
	FILE *fd)
{
	int status;

	COM_DBG(("RIScom_fputs(st: <%s> fd 0x%x)\n", st, fd));
	do
	{
		errno = -1;
		if ((status = fputs(st, fd)) == EOF)
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == EOF && errno == EINTR);

	COM_DBG(("RIScom_fputs: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32) || defined(DOS)
extern int RIScom_fread(
	char *ptr,
	int size,
	int nitems,
	FILE *stream)
{
	int status;

	COM_DBG(("RIScom_fread: size=<%d> nitems=<%d>\n", size, nitems));
	do
	{
		errno = -1;
		if ((status = fread(ptr, size, nitems, stream)) == 0)
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == 0 && errno == EINTR);

	COM_DBG(("RIScom_fread: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32)
/*
**  WARNING: no COM_DBG allowed because this function is used in SRVmain()
**            before the output device is initialized.
*/
extern FILE *RIScom_freopen(
    char *fname,
	char *type,
	FILE *stream)
{
	FILE *status;

	do
	{
		errno = -1;
		status = freopen(fname, type, stream);
	}
	while (status == NULL && errno == EINTR);

	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32) || defined(DOS)
extern int RIScom_fwrite(
	char *ptr,
	int size,
	int nitems,
	FILE *stream)
{
	int status;

	COM_DBG(("RIScom_fwrite(ptr: <%s> size: 0x%x nitems: %d stream: %d)\n", 
		ptr, size, nitems, stream));
	do
	{
		errno = -1;
		if ((status = fwrite(ptr, size, nitems, stream)) == 0)
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == 0 && errno == EINTR);

	COM_DBG(("RIScom_fwrite: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32)
extern int RIScom_getc(
	FILE *stream)
{
	int status;

	COM_DBG(("RIScom_getc(stream: %d)\n", stream));
	do
	{
		errno = -1;
		if ((status = getc(stream)) == EOF)
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == EOF && errno == EINTR);

	COM_DBG(("RIScom_getc: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32)
extern int RIScom_getchar(
	void)
{
	int status;

	COM_DBG(("RIScom_getchar()\n"));
	do
	{
		errno = -1;
		if ((status = getchar()) == EOF)
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == EOF && errno == EINTR);

	COM_DBG(("RIScom_getchar: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix)
extern struct passwd *RIScom_getpwuid(
	uid_t uid)
{
	struct passwd *status;

	COM_DBG(("RIScom_getpwuid(uid: 0x%x)\n", uid));
	do
	{
		errno = -1;
		if ((status = getpwuid(uid)) == NULL)
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == NULL && errno == EINTR);

	COM_DBG(("RIScom_getpwuid: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix)
extern struct passwd *RIScom_getpwnam(
	char *name)
{
	struct passwd *status;

	COM_DBG(("RIScom_getpwnam(name: <%s>)\n", name));
	do
	{
		errno = -1;
		if ((status = getpwnam(name)) == NULL)
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == NULL && errno == EINTR);

	COM_DBG(("RIScom_getpwnam: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32)
extern char *RIScom_gets(
	char *st)
{
	char *status;

	COM_DBG(("RIScom_gets(st: <%s>)\n", st));
	do
	{
		errno = -1;
		if ((status = gets(st)) == NULL)
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == NULL && errno == EINTR);

	COM_DBG(("RIScom_gets: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(__clipper__) || defined(__hpux__)
extern struct utmp *RIScom_getutent()
{
	struct utmp *status;

	COM_DBG(("RIScom_getutent()\n"));
	do
	{
		errno = -1;
		if ((status = getutent()) == NULL)
		{
			COM_DBG(("status = 0x%x errno = %d\n",status, errno));
		}
	}
	while (status == NULL && errno == EINTR);

	COM_DBG(("RIScom_getutent: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) && !defined(sco)
extern int RIScom_ioctl(
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

	COM_DBG(("RIScom_ioctl(fd: %d req: %d pvar_int: %d)\n",fd, req, pvar_int));
	do
	{
		status = ioctl(fd, req, pvar_int);
		if (status == -1)
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	COM_DBG(("RIScom_ioctl: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) && !defined(sco) || defined(vms) || defined(WIN32)
extern int RIScom_isatty(
	int fd)
{
	int status;

	COM_DBG(("RIScom_isatty(fd: %d)\n", fd));
	do
	{
		errno = -1;
		if ((status = isatty(fd)) == 0)
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == 0 && errno == EINTR);

	COM_DBG(("RIScom_isatty: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) && !defined(sco) || defined(vms) || defined(WIN32)
extern int RIScom_putc(
	int c,
	FILE *fd)
{
	int status;

	COM_DBG(("RIScom_putc(c: %d fd 0x%x)\n", c, fd));
	do
	{
		errno = -1;
		if ((status = putc(c, fd)) == EOF)
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == EOF && errno == EINTR);

	COM_DBG(("RIScom_putc: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) && !defined(sco) || defined(vms) || defined(WIN32) || defined(DOS)
extern int RIScom_putchar(
	int c)
{
	int status;

	COM_DBG(("RIScom_putchar(c %d)\n", c));
	do
	{
		errno = -1;
		if ((status = putchar(c)) == EOF)
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == EOF && errno == EINTR);

	COM_DBG(("RIScom_putchar: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) && !defined(sco) || defined(vms) || defined(WIN32) || defined(DOS)
extern int RIScom_puts(
	char *st)
{
	int status;

	COM_DBG(("RIScom_puts(st: <%s>)\n", st));
	do
	{
		errno = -1;
		if ((status = puts(st)) == EOF)
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == EOF && errno == EINTR);

	COM_DBG(("RIScom_puts: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32)
extern int RIScom_write(
	int fd,
	char *buf,
	unsigned n)
{
	int status;

	COM_DBG(("RIScom_write(fd: %d buf: 0x%x nbytes: %d)\n",fd, buf, n));
	do
	{
#if defined(unix) || defined(vms)
		if ((status = write(fd, buf, n)) == -1)
#elif defined(WIN32)
		if ((status = _write(fd, buf, n)) == -1)
#else
	!!! ERROR - NO CODE !!!
#endif
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	COM_DBG(("RIScom_write: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32)
extern int RIScom_read(
	int fd,
	char *buf,
	unsigned n)
{
	int status;

	COM_DBG(("RIScom_read(fd: %d buf: 0x%x nbytes: %d)\n",fd, buf, n));
	do
	{
#if defined(unix) || defined(vms)
		if ((status = read(fd, buf, n)) == -1)
#endif
#if defined(WIN32)
		if ((status = _read(fd, buf, n)) == -1)
#endif
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	COM_DBG(("RIScom_read: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32) || defined(DOS)
extern int RIScom_remove(
	char *path)
{
	int status;

	COM_DBG(("RIScom_remove(path: <%s>)\n", path));
	do
	{
		if ((status = remove(path)) == -1)
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	COM_DBG(("RIScom_remove: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix)
extern int RIScom_sighold(
	int sig)
{
	int status;

	COM_DBG(("RIScom_sighold(sig: %d)\n",sig));
	do
	{
		if ((status = sighold(sig)) == -1)
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	COM_DBG(("RIScom_sighold: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix)
extern int RIScom_sigrelse(
	int sig)
{
	int status;

	COM_DBG(("RIScom_sigrelse(sig: %d)\n",sig));
	do
	{
		if ((status = sigrelse(sig)) == -1)
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	COM_DBG(("RIScom_sigrelse: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix)
extern void (*RIScom_sigset(
	int sig,
	void (*func)(int))
	)(int)
{
	void (*sig_handler)(int);

	COM_DBG(("RIScom_sigset(sig: %d func: 0x%x)\n",sig, func));
	do
	{
		if ((sig_handler = sigset(sig, func)) == SIG_ERR)
		{
			COM_DBG(("sig_handler = 0x%x errno = %d\n",sig_handler, errno));
		}
	}
	while (sig_handler == SIG_ERR && errno == EINTR);

	COM_DBG(("RIScom_sigset: complete\n"));
	return sig_handler;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32) || defined(DOS)
extern int RIScom_stat(
	char *path,
#if defined(WIN32)
	struct _stat *buffer)
#else
	struct stat *buffer)
#endif
{
	int status;

	COM_DBG(("RIScom_stat(path: <%s> buf: 0x%x)\n", path, buffer));
	do
	{
#if defined(unix) || defined(vms) || defined(DOS)
		if ((status = stat(path, buffer)) == -1)
#elif defined(WIN32)
		if ((status = _stat(path, buffer)) == -1)
#else
	!!! ERROR - NO CODE !!!
#endif
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == -1 && errno == EINTR);

	COM_DBG(("RIScom_stat: complete\n"));
	return status;
}
#endif

/******************************************************************************/

#if defined(unix) || defined(vms) || defined(WIN32)
extern int RIScom_system(
	char *st)
{
	int status;

	COM_DBG(("RIScom_system(st: <%s>)\n", st));
	do
	{
		errno = -1;
		if ((status = system(st)) < 0)
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status < 0 && errno == EINTR);

	COM_DBG(("RIScom_system: complete\n"));
	return status;
}
#endif

/*****************************************************************************/

#if defined(unix) || defined(vms)
extern char *RIScom_tmpnam(
	char *st)
{
	char *status;

	COM_DBG(("RIScom_tmpnam(st: <%s>)\n", st));
	do
	{
		errno = -1;
		if ((status = tmpnam(st)) == NULL)
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == NULL && errno == EINTR);

	COM_DBG(("RIScom_tmpnam: tmpnam <%s> complete\n"));
	return status;
}

#elif defined(WIN32)
extern int RIScom_tmpnam(
	char *st)
{
	int	 result;
	char path[MAX_PATH];

	COM_DBG(("RIScom_tmpnam()\n"));
	if ((result = GetTempPath(MAX_PATH, path)) == 0)
	{
		COM_DBG(("RIScom_tmpnam: GetTmpPath Error: %d\n", GetLastError()));
		return(result);
	}
	COM_DBG(("RIScom_tmpnam: GetTmpPath: %s\n", path));
	if ((result = GetTempFileName(path, "RIS", 0, st)) == 0)
	{
		COM_DBG(("RIScom_tmpnam: GetTmpFileName Error: %d\n", GetLastError()));
		return(result);
	}
	COM_DBG(("RIScom_tmpnam: GetTmpFileName: %s\n", st));
	COM_DBG(("RIScom_tmpnam: complete\n"));
	return(result);
}

#elif defined(DOS)
	/*
	** If TMP environment variable is not set then put file in current
    ** directory.  tmpnam returns a filename similar to "\t0000000.tmp"
	** so just remove the 1st character and use that name when no TMP.
	*/
extern char *RIScom_tmpnam(
	char *st)
{
    char    *tmpvar, *status, tmpnm[16];

	COM_DBG(("RIScom_tmpnam(st: <%s>)\n", st));

    tmpvar = getenv("TMP");
    status = tmpnam(tmpnm);
	if (status  == NULL)
	{
		COM_DBG(("RIScom_tmpnam: tmpnam's status = %d\n",status));
		COM_DBG(("RIScom_tmpnam: complete\n"));
		return status;
	}
    if (tmpvar)
    {
      sprintf(st, "%s%s", tmpvar, tmpnm);
      COM_DBG(("RIScom_tmpnam: filename when using TMP: %s\n", st));
    }
    else
    {
	  strcpy(st, tmpnm+1);
      COM_DBG(("RIScom_tmpnam: filename when no TMP: %s\n", st));
    }
	COM_DBG(("RIScom_tmpnam: complete\n"));
	return status;
}

#else
ERROR -- NO CODE
#endif

/******************************************************************************/

#if defined(unix) && !defined(sco) || defined(vms) || defined(WIN32)
extern int RIScom_ungetc(
	int c,
	FILE *stream)
{
	int status;

	COM_DBG(("RIScom_ungetc(c: %d stream: %d)\n", c, stream));
	do
	{
		errno = -1;
		if ((status = ungetc(c, stream)) == EOF)
		{
			COM_DBG(("status = %d errno = %d\n",status, errno));
		}
	}
	while (status == EOF && errno == EINTR);

	COM_DBG(("RIScom_ungetc: complete\n"));
	return status;
}
#endif

#if defined(unix) || defined(vms) || defined(WIN32) || defined(DOS)
extern int RIScom_unlink(
    char *fname)
{
	int status;

	COM_DBG(("RIScom_unlink: fname <%s>\n", fname));
#ifndef vms
	do
	{
		errno = -1;
#if defined(unix)
		if ((status = unlink(fname)))
#endif
#if defined(WIN32) || defined(DOS)
		if ((status = _unlink(fname)))
#endif
		{
			COM_DBG(("status = <%s> errno = %d\n",status, errno));
		}
	}
	while (status && errno == EINTR);

#endif /* non vms */
	COM_DBG(("RIScom_unlink: complete\n"));
	return status;
}
#endif

/*****************************************************************************/
