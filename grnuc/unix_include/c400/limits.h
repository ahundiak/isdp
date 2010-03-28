
/*	Copyright (c) 1984 AT&T	*/
/*	Copyright (c) 1988,1989,1990 Intergraph Corporation	*/
/*	  All Rights Reserved  	*/

/*	THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF AT&T	*/
/*	AND INTERGRAPH CORPORATION		   	*/
/*	The copyright notice above does not evidence any   	*/
/*	actual or intended publication of such source code.	*/

#ident  "$Id: limits.h,v 1.1.1.1 2001/12/17 22:40:15 hans Exp $ Copyright (c) 1986,1987,1988,1989,1990 by Intergraph Corp."

#ifndef _LIMITS_H
#define _LIMITS_H

/*
 * ANSI-C standard Section 2.2.4.2
 */
#define CHAR_BIT	8	/* # of bits in a "char" */
#define CHAR_MAX	127	/* max integer value of a char */
#define CHAR_MIN	(-128)	/* min integer value of a char */
#define INT_MAX		2147483647
#define INT_MIN 	(-2147483647-1)
#define LONG_MAX	2147483647
#define LONG_MIN 	(-2147483647L-1L)
#define MB_LEN_MAX	1	/* max number of bytes in a multibyte char */
#define SCHAR_MAX	127	/* max integer value of a signed char*/
#define SCHAR_MIN	(-128) 	/* min integer value of a signed char*/
#define SHRT_MAX	32767	/* max decimal value of a short */
#define SHRT_MIN	(-32768)/* min decimal value of a short */
#define UCHAR_MAX	255	/* max integer value of an unsignd char*/
#define UINT_MAX	4294967295
#define ULONG_MAX	4294967295
#define USHRT_MAX	65535	/*max dec value of an unsigned short*/

#if !defined(__STDC__)
#include	<unistd.h>
#include	<float.h>
#ifndef _HUGE_MACRO                     /*ansi also defines elsewhere */
#define _HUGE_MACRO
#define	HUGE_VAL	(1.79e+308*1.79e+308)
#endif  /* _HUGE_MACRO */
#ifndef _POSIX_SOURCE
#define NGROUPS_MAX	16	/* # of supplementary G-IDs per process */
#define TZNAME_MAX	3
#define	SYSPID_MAX	30000	/* max value for a process ID */
#ifndef TMP_MAX
#define	TMP_MAX		17576	/* # unique temp file names tmpnam() */
#endif
#define	LONG_BIT	32	/* # of bits in a "long" */
#endif   /*!_POSIX_SOURCE */
#endif   /*! __STDC__ */

#ifdef _POSIX_SOURCE
/*
 * POSIX 1003.1 section 2.9
 * 
 * The following symbolic constants are defined in <unistd.h>
 *
 *	ARG_MAX, CHILD_MAX, OPEN_MAX, LINK_MAX, MAX_CANON, MAX_INPUT,
 *	NAME_MAX, PATH_MAX, PIPE_BUF
 */

/* 
 * POSIX section 2.9.3
 * (this name violates ANSI-C name-space pollution rules)
 */
#define NGROUPS_MAX	16
#define TZNAME_MAX	3
#define SSIZE_MAX	32767

/*
 * POSIX 1003.1 section 2.9.2
 */
#define _POSIX_ARG_MAX		4096	/* the length of the arg. for exec */
#define _POSIX_CHILD_MAX  	6	/* # of simultan. proc. per user ID*/
#define _POSIX_LINK_MAX		8	/* value of a file's link count */
#define _POSIX_MAX_CANON	255	/* # of bytes in canonical input q */
#define _POSIX_MAX_INPUT	255	/* # of space avail. in tty input q */
#define _POSIX_NAME_MAX		14	/* # of bytes in a filename */
#define _POSIX_NGROUPS_MAX	0	/* # of supplementary group per proc */
#define _POSIX_OPEN_MAX		16	/* # of files one process can open */
#define _POSIX_PATH_MAX		255	/* # of bytes in the pathname */
#define _POSIX_PIPE_BUF		512	/* # of bytes writing to a pipe */
#define _POSIX_SSIZE_MAX	32767
#define _POSIX_STREAM_MAX	8
#define _POSIX_TZNAME_MAX	3
#endif /* _POSIX_SOURCE */

#endif  /* _LIMITS_H */

