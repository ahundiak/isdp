/*	Copyright (c) 1984 AT&T	*/
/*	Copyright (c) 1988 Intergraph Corporation	*/
/*	  All Rights Reserved  	*/

/*	THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF AT&T	*/
/*	AND INTERGRAPH CORPORATION		   	*/
/*	The copyright notice above does not evidence any   	*/
/*	actual or intended publication of such source code.	*/

#ident	"@(#)sys:$Id: unistd.h,v 1.1.1.1 2001/12/17 22:40:15 hans Exp $"

#ifndef _UNISTD_H
#define _UNISTD_H

#if !defined(_STANDARDS_H)
#include <standards.h>
#endif

#if !defined(_SYS_TYPES_H)
#include <sys/types.h>
#endif

#ifndef NULL
#define	NULL	0
#endif

/* Symbolic constants for the "access" routine: */
#define	R_OK	4	/* Test for Read permission */
#define	W_OK	2	/* Test for Write permission */
#define	X_OK	1	/* Test for eXecute permission */
#define	F_OK	0	/* Test for existence of File */

#define F_ULOCK	0	/* Unlock a previously locked region */
#define F_LOCK	1	/* Lock a region for exclusive use */
#define F_TLOCK	2	/* Test and lock a region for exclusive use */
#define F_TEST	3	/* Test a region for other processes locks */


/* Symbolic constants for the "lseek" routine: */
#ifndef SEEK_SET
#define	SEEK_SET	0	/* Set file pointer to "offset" */
#endif 
#ifndef SEEK_CUR
#define	SEEK_CUR	1	/* Set file pointer to current plus "offset" */
#endif 
#ifndef SEEK_END
#define	SEEK_END	2	/* Set file pointer to EOF plus "offset" */
#endif 

#define STDIN_FILENO	0
#define STDOUT_FILENO	1
#define STDERR_FILENO	2

/* Path names: */
#define	GF_PATH	"/etc/group"	/* Path name of the "group" file */
#define	PF_PATH	"/etc/passwd"	/* Path name of the "passwd" file */

/* 	Index of Configurable System Variables */
#define _SC_ARG_MAX 	0	/* length of arg. for the exec func */
#define _SC_CHILD_MAX	1	/* # of processes per real user ID */
#define _SC_CLK_TCK	2	/* # of cloxk ticks per second */
#define _SC_NGROUPS_MAX	3	/* # of supplementary G-IDs per process */
#define _SC_OPEN_MAX	4	/* # of files one process can have open at one time */
#define _SC_JOB_CONTROL	5	/* job control */
#define _SC_SAVED_IDS	6	/* saved set-user-ID and set-group-ID */
#define _SC_VERSION	7	/* posix version */
#define _SC_STREAM_MAX	8
#define _SC_TZNAME_MAX	9

/* 	Index of Configurable Pathname Variables */
#define _PC_LINK_MAX	0	/* file's link count */
#define _PC_MAX_CANON	1	/* # of bytes in a terminal canonical input queue */
#define _PC_MAX_INPUT	2	/* # of bytes in a terminal input queue */
#define _PC_NAME_MAX	3	/* # of bytes in a file name */
#define _PC_PATH_MAX	4	/* # of bytes in a path name */
#define _PC_PIPE_BUF	5	/* # of bytes atomic in write to a pipe */
#define _PC_CHOWN_RESTRICTED	6	/* chown restrict to the effective G-ID or its supplementG-IDs */ 
#define _PC_NO_TRUNC	7	/* pathname components longer than [DIRSIZ]([NAME_MAX]) generate an error */
#define _PC_VDISABLE	8	/* terminal special characters can be disabled */

/*
 *  NOTE:
 *	To get the current value of the following variables, you should
 *	call sysconf(), pathconf(), or fpathconf() than include
 *	them directly.
 */

/* Run-Time evaluable */
#ifndef	CLK_TCK			/* ANSI-C defined it in time.h */
#if defined(__USE_POSIX)
#define CLK_TCK		(_sysconf(_SC_CLK_TCK))
#else 
#define CLK_TCK		60
#endif
#endif
/* Run-Time Invariant Values(possibly indeterminate) */ 
#if defined(__USE_POSIX)
#define	CHILD_MAX	(_sysconf(_SC_CHILD_MAX))
#define	OPEN_MAX	(_sysconf(_SC_OPEN_MAX))
#else
#define	CHILD_MAX	25
#define	OPEN_MAX	128
#endif

#define	ARG_MAX		12288	/* max length of arguments to exec */
#define	LINK_MAX	1000	/* max # of links to a single file */
#define MAX_CANON	256	/* # of bytes in a terminal canonical input queue */
#ifndef MAX_INPUT
#define MAX_INPUT	256	/* # of bytes in a terminal input queue */
#endif  /* MAX_INPUT */
#define	NAME_MAX	14	/* max # of characters in a file name */
#define	PATH_MAX	1023	/* max # of characters in a path name */
#if defined(__USE_POSIX)
#define PIPE_BUF 	_pathconf(".",_PC_PIPE_BUF)
#else
#define	PIPE_BUF	5120	/* max # bytes atomic in write to a pipe */
#endif
/* Compile-Time Symbolic Constants */
#define	_POSIX_JOB_CONTROL	1
#define	_POSIX_SAVED_IDS	1
#define	_POSIX_VERSION		199009L

/* Execution-Time Symbolic Constants */
#define _POSIX_VDISABLE		036

#if !defined(_SIZE_T)
#define _SIZE_T
typedef	unsigned int	size_t;
#endif

#if !defined(_SSIZE_T)
#define _SSIZE_T
typedef	int	ssize_t;
#endif



#if defined(__cplusplus)
extern "C" {
#endif
#if defined(_POSIX_SOURCE)
extern void _exit __((int));
extern int access __((const char *, int));
extern unsigned int alarm __((unsigned int));
extern int chdir __((const char *));
extern int chown __((const char *, uid_t, gid_t));
extern int close __((int));
extern char *ctermid __((char *));
extern int dup2 __((int, int));
extern int dup __((int));
extern int execl __((const char *, const char *, ...));
extern int execle __((const char *, const char *, ...));
extern int execlp __((const char *, const char *, ...));
extern int execv __((const char *, char *const []));
extern int execve __((const char *, char *const [], char *const []));
extern int execvp __((const char *, char *const []));
extern pid_t fork __((void));
extern long fpathconf __((int, int));
extern char *getcwd __((char *, size_t));
extern gid_t getegid __((void));
extern uid_t geteuid __((void));
extern gid_t getgid __((void));
extern int getgroups __((int, gid_t []));
extern char *getlogin __((void));
extern pid_t getpgrp __((void));
extern pid_t getpid __((void));
extern pid_t getppid __((void));
extern uid_t getuid __((void));
extern int isatty __((int));
extern int link __((const char *, const char *));
extern off_t lseek __((int, off_t, int));
extern long pathconf __((const char *, int));
extern int pause __((void));
extern int pipe __((int fildes[2]));
extern ssize_t read __((int, void *, size_t));
extern int rmdir __((const char *));
extern int setgid __((gid_t));
extern int setpgid __((pid_t, pid_t));
extern pid_t setsid __((void));
extern int setuid __((uid_t));
extern unsigned int sleep __((unsigned int));
extern long sysconf __((int));
extern pid_t tcgetpgrp __((int));
extern int tcsetpgrp __((int, pid_t));
extern char *ttyname __((int));
extern int unlink __((const char *));
extern ssize_t write __((int, const void *, size_t));
#endif  /* _POSIX_SOURCE */

#if defined(__cplusplus) || (defined(__STDC__) && defined(_INGR_EXTENSIONS))
extern int acct __((char *));
extern int chroot __((char *));
extern int ioctl __((int, int, ...));
extern int lockf __((int, int, long));
extern int nice __((int));
extern void profil __((char *, int, int, int));
extern int ptrace __((int, pid_t, int, int));
extern int readlink __((const char*, char*, int));
extern int setgroups __((int, const gid_t *));
extern int setpgrp __((void));
extern int stime __((const time_t *));
extern void sync __((void));
extern long ulimit __((int, long));
#endif /* __cplusplus || (STDC && INGR_EXTENSIONS) */

#if defined(__cplusplus)
}
#endif


#endif	/* _UNISTD_H */
