/* $RCSfile: types.h,v $$Revision: 1.8 $$Date: 89/08/03 13:12:47 $ Copyright (c) 1988 Intergraph Corp. */

#ifndef SYS_TYPES_H
#define SYS_TYPES_H
/*	Copyright (c) 1984 AT&T 				*/
/*	THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF AT&T	*/
/*	The copyright notice above does not evidence any   	*/
/*	actual or intended publication of such source code.	*/

/*#ident	"@(#)kern-port:sys/types.h	10.6	@(#)types.h	1.5 (Fairchild) 8/14/87"*/

typedef	struct { int r[1]; } *	physadr;
typedef	long		daddr_t;	/* <disk address> type */
typedef	char *		caddr_t;	/* ?<core address> type */
typedef	unsigned char	unchar;
typedef	unsigned short	ushort;
typedef	unsigned int	uint;
typedef	unsigned long	ulong;
typedef	ushort		ino_t;		/* <inode> type */
typedef	short		cnt_t;		/* ?<count> type */

#ifndef _TIME_T_LONG
#define _TIME_T_LONG
typedef	long		time_t;		/* <time> type; in seconds */
#endif

typedef	int		label_t[44];
typedef	short		dev_t;		/* <old device number> type */
typedef	long		off_t;		/* ?<offset> type */
typedef	long		paddr_t;	/* <physical address> type */
typedef	int		key_t;		/* IPC key type */
typedef	unsigned char	use_t;		/* use count for swap.  */
typedef	short		sysid_t;
typedef	short		index_t;
typedef	short		lock_t;		/* lock work for busy wait */

#ifndef _SIZE_T_INT
#define _SIZE_T_INT
typedef	unsigned int	size_t;		/* len param for string funcs */
#endif

typedef	ushort		mode_t;		/* file mode */
typedef	short		nlink_t;	/* link counts */
typedef	short		pid_t;		/* process ID */

#ifndef _CLOCK_T_LONG
#define _CLOCK_T_LONG
typedef	long		clock_t;	/* time in clock ticks */
#endif

/* These typedefs and defines are used for BSD compatibility */

typedef unsigned char   u_char;
typedef unsigned short  u_short;
typedef unsigned int    u_int;
typedef unsigned long   u_long;
typedef	u_short	uid_t;
typedef	u_short	gid_t;
typedef	struct	_quad { long val[2]; } quad;
typedef	long	swblk_t;

#define NBBY 8

/*
 *	The following is added for BSD compatability.
 */
#define FD_SETSIZE	256
#define NFDBITS (sizeof(long) * NBBY)      /* bits per mask */
#ifndef howmany
#define howmany(x, y)	(((x)+((y)-1))/(y))
#endif

typedef struct fd_set {
	long fds_bits[howmany(FD_SETSIZE, NFDBITS)];
} fd_set;

#define FD_SET(n, p)	((p)->fds_bits[(n)/NFDBITS] |= (1 << ((n) % NFDBITS)))
#define FD_CLR(n, p)	((p)->fds_bits[(n)/NFDBITS] &= ~(1 << ((n) % NFDBITS)))
#define FD_ISSET(n, p)	((p)->fds_bits[(n)/NFDBITS] & (1 << ((n) % NFDBITS)))
#define FD_ZERO(p)	bzero((char *)(p), sizeof(*(p)))


#endif
