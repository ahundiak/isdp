#ifndef __STRING_H__
#define __STRING_H__
#ifdef __cplusplus
extern "C" {
#endif
#ident "$Revision: 1.1.1.1 $"
/*
*
* Copyright 1992, Silicon Graphics, Inc.
* All Rights Reserved.
*
* This is UNPUBLISHED PROPRIETARY SOURCE CODE of Silicon Graphics, Inc.;
* the contents of this file may not be disclosed to third parties, copied or
* duplicated in any form, in whole or in part, without the prior written
* permission of Silicon Graphics, Inc.
*
* RESTRICTED RIGHTS LEGEND:
* Use, duplication or disclosure by the Government is subject to restrictions
* as set forth in subdivision (c)(1)(ii) of the Rights in Technical Data
* and Computer Software clause at DFARS 252.227-7013, and/or in similar or
* successor clauses in the FAR, DOD or NASA FAR Supplement. Unpublished -
* rights reserved under the Copyright Laws of the United States.
*/
/*	Copyright (c) 1990, 1991 UNIX System Laboratories, Inc.	*/
/*	Copyright (c) 1988 AT&T	*/
/*	  All Rights Reserved  	*/

/*	THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF     	*/
/*	UNIX System Laboratories, Inc.                     	*/
/*	The copyright notice above does not evidence any   	*/
/*	actual or intended publication of such source code.	*/


#if !defined(_SIZE_T) && !defined(_SIZE_T_)
#define _SIZE_T
#if (_MIPS_SZLONG == 32)
typedef unsigned int	size_t;
#endif
#if (_MIPS_SZLONG == 64)
typedef unsigned long	size_t;
#endif
#endif

#ifndef NULL
#define NULL	0
#endif

extern void *memcpy();
extern void *memmove();
extern char *strcpy();

extern char *strncpy();

extern char *strcat();
extern char *strncat();

extern int memcmp();
extern int strcmp();
extern int strcoll();
extern int strncmp();
extern size_t strxfrm();

extern void *memchr();
extern char *strchr();
extern size_t strcspn();
#pragma int_to_unsigned strcspn
extern char *strpbrk();
extern char *strrchr();
extern size_t strspn();
#pragma int_to_unsigned strspn
extern char *strstr();
extern char *strtok(char *, const char *);

extern void *memset();
extern char *strerror();
extern size_t strlen();
#pragma int_to_unsigned strlen

#if defined(_SVR4_SOURCE) || defined(_POSIX_SOURCE) || defined(_XOPEN_SOURCE)

extern void *memccpy();
#endif

#if defined(_SVR4_SOURCE) && !defined(_POSIX_SOURCE) && !defined(_XOPEN_SOURCE)

extern char *strdup();
extern int ffs();

#endif

#if defined(_SVR4_SOURCE) && !defined(_POSIX_SOURCE) && !defined(_XOPEN_SOURCE)

/* Case-insensitive comparision routines from 4.3BSD.  */
extern int	strcasecmp();
extern int	strncasecmp();

#endif 

#if (defined(_SGI_SOURCE) && !defined(_POSIX_SOURCE) && !defined(_XOPEN_SOURCE)) || defined(_SGI_REENTRANT_FUNCTIONS)
extern char *strtok_r();
#endif

#ifdef __INLINE_INTRINSICS
/* The functions made intrinsic here can be activated by the driver
** passing -D__INLINE_INTRINSICS to cfe.
*/
#pragma intrinsic (strcpy) /* Only effective if second arg is string const */
#endif

#ifdef __cplusplus
}
#endif
#endif /* !__STRING_H__ */
