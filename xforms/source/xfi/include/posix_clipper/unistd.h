/*	Copyright (c) 1984 AT&T	*/
/*	Copyright (c) 1988 Intergraph Corporation	*/
/*	  All Rights Reserved  	*/

/*	THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF AT&T	*/
/*	AND INTERGRAPH CORPORATION		   	*/
/*	The copyright notice above does not evidence any   	*/
/*	actual or intended publication of such source code.	*/

#ident	"@(#)sys:$Id: unistd.h,v 1.1 1993/08/31 15:28:55 spcX Exp $"

#ifndef _UNISTD_H
#define _UNISTD_H

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
#define MAX_INPUT	256	/* # of bytes in a terminal input queue */
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
#define	_POSIX_VERSION		198808L

/* Execution-Time Symbolic Constants */
#define _POSIX_VDISABLE		036

#endif	/* _UNISTD_H */

/* Steve Lanham added the following */
#ifdef _POSIX_SOURCE
typedef int ssize_t;
#endif
