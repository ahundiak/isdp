#ifndef	_SYS_DIRENT_H
#define	_SYS_DIRENT_H

#ifdef __cplusplus
extern "C" {
#endif

/*	Copyright (c) 1984 AT&T	*/
/*	  All Rights Reserved  	*/

/*	THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF AT&T	*/
/*	The copyright notice above does not evidence any   	*/
/*	actual or intended publication of such source code.	*/

/*#ident	"@(#)kern-port:sys/dirent.h	10.5"*/
#ident	"$Revision: 1.1.1.1 $"

#include <sys/types.h>

/*
 * The following structure defines the file
 * system independent directory entry.
 *
 */

struct dirent {				/* data from readdir() */
	ino_t		d_ino;		/* inode number of entry */
	off_t		d_off;		/* offset of disk direntory entry */
	unsigned short	d_reclen;	/* length of this record */
	char		d_name[1];	/* name of file */
};

typedef struct  dirent  dirent_t;

#if !defined(_POSIX_SOURCE)
#if defined(_MODERN_C) && !defined(_KERNEL)
int getdents(int, struct dirent *, unsigned);
#else
extern int getdents( );
#endif

#if defined(_SGI_SOURCE)
#define	DIRENTBASESIZE \
	(((struct dirent *) 0)->d_name - (char *) 0)
#define	DIRENTSIZE(namelen) \
	((DIRENTBASESIZE + (namelen) + sizeof(off_t)) & ~(sizeof(off_t) - 1))
#endif /* _SGI_SOURCE */

#ifdef _KERNEL
#include <sys/ktypes.h>

/* Irix5 view of dirent structure. */
typedef struct irix5_dirent {		/* data from readdir() */
	app32_ulong_t	d_ino;		/* inode number of entry */
	irix5_off_t	d_off;		/* offset of disk direntory entry */
	unsigned short	d_reclen;	/* length of this record */
	char		d_name[1];	/* name of file */
} irix5_dirent_t;

#define	IRIX5_DIRENTBASESIZE \
	(((struct irix5_dirent *) 0)->d_name - (char *) 0)
#define	IRIX5_DIRENTSIZE(namelen) \
	((IRIX5_DIRENTBASESIZE + (namelen) + \
	sizeof(irix5_off_t)) & ~(sizeof(irix5_off_t) - 1))
#endif	/* _KERNEL */

#endif /* !defined(_POSIX_SOURCE) */

#ifdef __cplusplus
}
#endif

#endif	/* !_SYS_DIRENT_H */
