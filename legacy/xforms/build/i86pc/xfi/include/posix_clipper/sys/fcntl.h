/* $RCSfile: fcntl.h,v $$Revision: 1.1 $$Date: 1993/08/31 15:29:04 $ Copyright (c) 1991 Intergraph Corporation */

#ifndef SYS_FCNTL_H
#define SYS_FCNTL_H

/*
 *	Copyright (c) 1988, 1989, 1990, 1991, Intergraph Corporation.
 *	All Rights Reserved.
 *
 *	THIS IS UNPUBLISHED, PROPIETARY, AND CONFIDENTIAL SOURCE
 *	SOFTWARE OF INTERGRAPH.  Use, duplication, and disclosure
 *	is prohibited, except under the terms and conditions of the
 *	applicable software license agreement.
 */

/*
 *	Copyright (c) 1984 AT&T
 *	All Rights Reserved
 *
 *	THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF AT&T
 *	The copyright notice above does not evidence any
 *	actual or intended publication of such source code.
 */

/*#ident	"@(#)kern-port:sys/fcntl.h	10.3	@(#)fcntl.h	1.5 (Intergraph) 5/7/88"*/

/* Flag values accessible to open(2) and fcntl(2) */
/*  (The first three can only be set by open) */
#define	O_RDONLY 0
#define	O_WRONLY 1
#define	O_RDWR	 2
#define O_ACCMODE 3	/* POSIX mask for file access modes */
#define	O_NDELAY 04	/* Non-blocking I/O */
#define	O_APPEND 010	/* append (writes guaranteed at the end) */
#define O_SYNC	 020	/* synchronous write option */
#define O_NONBLOCK 0100	/* POSIX non-block I/O */

/* Flag values accessible only to open(2) */
#define	O_CREAT	00400	/* open with file create (uses third open arg)*/
#define	O_TRUNC	01000	/* open with truncation */
#define	O_EXCL	02000	/* exclusive open */
#define O_NOCTTY 04000	/* POSIX no controlling tty on open */

/* fcntl(2) requests */
#define	F_DUPFD		0	/* Duplicate fildes */
#define	F_GETFD		1	/* Get fildes flags */
#define	F_SETFD		2	/* Set fildes flags */
#define	F_GETFL		3	/* Get file flags */
#define	F_SETFL		4	/* Set file flags */
#define	F_GETLK		5	/* Get file lock */
#define	F_SETLK		6	/* Set file lock */
#define	F_SETLKW	7	/* Set file lock and wait */
#define F_CHKFL		8	/* Check legality of file flag changes */
#define	F_ALLOCSP	10	/* reserved */
#define	F_FREESP	11	/* reserved */
#define FD_CLOEXEC	1	/* POSIX close on exec */

/*
 * Added F_[SG]ETOWN for sockets.  Start at 127 and work back
 * until we meet AT&T's numbers.
 */
#define F_SETOWN	126	/* used for sockets */
#define F_GETOWN	127	/* used for sockets */

/* file segment locking set data type - information passed to system by user */
struct flock {
	short	l_type;
	short	l_whence;
	long	l_start;
	long	l_len;		/* len = 0 means until end of file */
        short   l_sysid;
        short   l_pid;
};

/* file segment locking types */
	/* Read lock */
#define	F_RDLCK	01
	/* Write lock */
#define	F_WRLCK	02
	/* Remove lock(s) */
#define	F_UNLCK	03

#endif
