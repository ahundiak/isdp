#ifndef __STDIO_H__
#define __STDIO_H__
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
/*	Copyright (c) 1988 AT&T	*/
/*	  All Rights Reserved  	*/

/*	THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF AT&T	*/
/*	The copyright notice above does not evidence any   	*/
/*	actual or intended publication of such source code.	*/

/*
* User-visible pieces of the ANSI C standard I/O package.
*/

#if defined(_LANGUAGE_C) || defined(_LANGUAGE_C_PLUS_PLUS)

#if !defined(_SIZE_T) && !defined(_SIZE_T_)
#define _SIZE_T
#if (_MIPS_SZLONG == 32)
typedef unsigned int 	size_t;
#endif
#if (_MIPS_SZLONG == 64)
typedef unsigned long 	size_t;
#endif
#endif 

typedef long	fpos_t;

#endif /* defined(_LANGUAGE_C) || defined(_LANGUAGE_C_PLUS_PLUS) */

#ifndef NULL
#define NULL		0
#endif 


#define BUFSIZ	4096
#define _NFILE	100	/* initial number of streams */
#define _SBFSIZ	8	/* compatibility with shared libs */

#if defined(_LANGUAGE_C) || defined(_LANGUAGE_C_PLUS_PLUS)
#define _IOFBF		0000	/* full buffered */
#define _IOLBF		0100	/* line buffered */
#define _IONBF		0004	/* not buffered */
#define _IOEOF		0020	/* EOF reached on read */
#define _IOERR		0040	/* I/O error from system */

#define _IOREAD		0001	/* currently reading */
#define _IOWRT		0002	/* currently writing */
#define _IORW		0200	/* opened for reading and writing */
#define _IOMYBUF	0010	/* stdio malloc()'d buffer */
#endif /* defined(_LANGUAGE_C) || defined(_LANGUAGE_C_PLUS_PLUS) */

#if defined(_LANGUAGE_FORTRAN)
#define _IOFBF		'0000'x	/* full buffered */
#define _IOLBF		'0040'x	/* line buffered */
#define _IONBF		'0004'x	/* not buffered */
#define _IOEOF		'0010'x	/* EOF reached on read */
#define _IOERR		'0020'x	/* I/O error from system */
#define _IOREAD		'0001'x	/* currently reading */
#define _IOWRT		'0002'x	/* currently writing */
#define _IORW		'0080'x	/* opened for reading and writing */
#define _IOMYBUF	'0008'x	/* stdio malloc()'d buffer */
#endif	/* defined(_LANGUAGE_FORTRAN) */

#if defined(_LANGUAGE_C) || defined(_LANGUAGE_C_PLUS_PLUS)

#ifndef EOF
#   define EOF	(-1)
#endif

#define FOPEN_MAX	_NFILE
#define FILENAME_MAX    1024	/* max # of characters in a path name */

#ifndef SEEK_SET
#define SEEK_SET	0
#define SEEK_CUR	1
#define SEEK_END	2
#endif 	/* SEEK_SET */
#define TMP_MAX		17576	/* 26 * 26 * 26 */

#if defined(_SVR4_SOURCE) || defined(_POSIX_SOURCE) || defined(_XOPEN_SOURCE)
#define L_ctermid	9
#define L_cuserid	9
#endif

#if (defined(_SVR4_SOURCE) && !defined(_POSIX_SOURCE)) || defined(_XOPEN_SOURCE)
#define P_tmpdir	"/var/tmp/"
#endif

#define L_tmpnam	25	/* (sizeof(P_tmpdir) + 15) */

#define stdin	(&__iob[0])	
#define stdout	(&__iob[1])	
#define stderr	(&__iob[2])	

typedef struct	/* needs to be binary-compatible with old versions */
#if defined(_SGI_SOURCE) && !defined(_POSIX_SOURCE) && !defined(_XOPEN_SOURCE) || defined(_LANGUAGE_C_PLUS_PLUS)
/*
 * The __file_s struct tag is for backwards compat ONLY - it shouldn't be
 * used in any new headers. We would have liked to not use it in C++ since
 * it will change the name mangling of FILE *, but since it has already
 * gone out that way, we must stick to it. The safest thing is to *always*
 * define it for C++ (since a function that takes a FILE * as an argument
 * will have this tag in its mangled name).
 */
__file_s
#endif
{
#if (_MIPS_SZLONG == 32)
	int		_cnt;	/* number of available characters in buffer */
#endif
#if (_MIPS_SZLONG == 64)
	long		_cnt;	/* number of available characters in buffer */
#endif
	unsigned char	*_ptr;	/* next character from/to here in buffer */
	unsigned char	*_base;	/* the buffer */
#if (_MIPS_SZLONG == 32)
	unsigned char	_flag;	/* the state of the stream */
	unsigned char	_file;	/* UNIX System file descriptor */
#endif
#if (_MIPS_SZLONG == 64)
	unsigned int	_flag;	/* the state of the stream */
	unsigned int	_file;	/* UNIX System file descriptor */
#endif
} FILE;

extern FILE		__iob[_NFILE];	
extern FILE		*_lastbuf;
extern unsigned char 	**_bufendtab;
extern unsigned char	 _sibuf[], *_sobuf;

extern int	remove();
extern int	rename();
extern FILE	*tmpfile();
extern char	*tmpnam();
extern int	fclose();
extern int	fflush();
extern FILE	*fopen();
extern FILE	*freopen();
extern void	setbuf();
extern int	setvbuf();
/* PRINTFLIKE2 */
extern int	fprintf();
/* SCANFLIKE2 */
extern int	fscanf();
/* PRINTFLIKE1 */
extern int	printf();
/* SCANFLIKE1 */
extern int	scanf();
/* PRINTFLIKE2 */
extern int	sprintf();
/* SCANFLIKE2 */
extern int	sscanf();
extern int	vfprintf();
extern int	vprintf();
extern int	vsprintf();
extern int	fgetc();
extern char	*fgets();
extern int	fputc();
extern int	fputs();
extern int	getc();
extern int	getchar();
extern char	*gets();
extern int	putc();
extern int	putchar();
extern int	puts();
extern int	ungetc();
extern size_t	fread();
#pragma int_to_unsigned fread
extern size_t	fwrite();
#pragma int_to_unsigned fwrite
extern int	fgetpos();
extern int	fseek();
extern int	fsetpos();
extern long	ftell();
extern void	rewind();
extern void	clearerr();
extern int	feof();
extern int	ferror();
extern void	perror();

extern int	__filbuf();
extern int	__flsbuf();

#if defined(_SVR4_SOURCE) || defined(_POSIX_SOURCE) || defined(_XOPEN_SOURCE)
	/* POSIX additions */
extern FILE    *fdopen();
extern char    *ctermid();
extern int	fileno();
#endif

#if (defined(_SVR4_SOURCE) || defined(_XOPEN_SOURCE)) && !defined(_POSIX_SOURCE)
	/* SVR4/XOPEN? additions */
extern FILE    *popen();
extern int     pclose();
extern char    *cuserid();
extern char    *tempnam();
extern int     getw();
extern int     putw();
extern int	system(); /* ANSI/POSIX have this in stdlib.h */

#endif	/* defined(_SVR4_SOURCE) */

#if defined(_SGI_SOURCE) && !defined(_POSIX_SOURCE) && !defined(_XOPEN_SOURCE)
extern char	*mktemp();
extern int	mkstemp();
extern int	setbuffer();
extern int	setlinebuf();
#endif /* _SGI_SOURCE */

#if (defined(_SGI_SOURCE) && !defined(_POSIX_SOURCE) && !defined(_XOPEN_SOURCE)) || defined(_SGI_MP_SOURCE)
extern int	__semputc();
extern int	__semgetc();
extern int	__us_rsthread_stdio;
#endif

#if (defined(_SGI_SOURCE) && !defined(_POSIX_SOURCE) && !defined(_XOPEN_SOURCE)) || defined(_SGI_REENTRANT_FUNCTIONS)
char *ctermid_r();
void flockfile();
int ftrylockfile();
void funlockfile();
int getc_unlocked();
int putc_unlocked();
int getchar_unlocked();
int putchar_unlocked();
#endif

#ifndef _LINT

#if (defined(_SGI_SOURCE) && !defined(_POSIX_SOURCE) && !defined(_XOPEN_SOURCE)) || defined(_SGI_MP_SOURCE)
/* NOTE:
 * The stdio macros have been modified so that they are by default 
 * multi-thread  safe.
 * For speed we have a single global that determines whether
 * threading is required.
 * There are 2 other versions of the macros:
 *	macro_locked - always use locked version
 * 	macro_unlocked - use unlocked version - these should be used
 *		with the flock/funlock-file functions
 */

/* Default versions of the macros */
#define getc(p)		getc_locked(p)
#define putc(x, p)	putc_locked((x), p)
#define getchar()	getc_locked(stdin)
#define putchar(x)	putc_locked((x), stdout)
#undef clearerr
/* the following 3 are atomic and require no locking */
#define feof(p)		feof_unlocked(p)
#define ferror(p)	ferror_unlocked(p)
#define fileno(p)	fileno_unlocked(p)

/* Explicit locked (thread-safe) versions */
#define getc_locked(p)	   	(__us_rsthread_stdio ? __semgetc(p) : \
			(--(p)->_cnt < 0 ? __filbuf(p) : (int)*(p)->_ptr++))
#define putc_locked(x, p)     	(__us_rsthread_stdio ? __semputc(x,p) : \
			(--(p)->_cnt < 0 ? __flsbuf((x), (p)) \
					  : (int)(*(p)->_ptr++ = (x))))
#define getchar_locked()	getc_locked(stdin)
#define putchar_locked(x)	putc_locked((x), stdout)
#define clearerr_locked(p)	clearerr(p)
#define feof_locked(p)		feof_unlocked(p)
#define ferror_locked(p)	ferror_unlocked(p)
#define fileno_locked(p)	fileno_unlocked(p)

/* Explicit unlocked (thread-unsafe) versions */
#define getc_unlocked(p)	(--(p)->_cnt < 0 ? __filbuf(p) : (int)*(p)->_ptr++)
#define putc_unlocked(x, p)	(--(p)->_cnt < 0 ? __flsbuf((x), (p)) \
				: (int)(*(p)->_ptr++ = (x)))
#define getchar_unlocked()	getc_unlocked(stdin)
#define putchar_unlocked(x)	putc_unlocked((x), stdout)
#define clearerr_unlocked(p)	((void)((p)->_flag &= ~(_IOERR | _IOEOF)))
#define feof_unlocked(p)	(((int)(p)->_flag) & _IOEOF)
#define ferror_unlocked(p)	(((int)(p)->_flag) & _IOERR)
#define fileno_unlocked(p)	(p)->_file

#else

/*
 * Std ANSI - thread-unsafe
 */

#define getc(p)		(--(p)->_cnt < 0 ? __filbuf(p) : (int)*(p)->_ptr++)
#define putc(x, p)	(--(p)->_cnt < 0 ? __flsbuf((x), (p)) \
				: (int)(*(p)->_ptr++ = (x)))
#define getchar()	getc(stdin)
#define putchar(x)	putc((x), stdout)
#define clearerr(p)	((void)((p)->_flag &= ~(_IOERR | _IOEOF)))
#define feof(p)		(((int)(p)->_flag) & _IOEOF)
#define ferror(p)	(((int)(p)->_flag) & _IOERR)
#if defined(_SVR4_SOURCE) || defined(_POSIX_SOURCE) || defined(_XOPEN_SOURCE)
#define fileno(p)	(p)->_file
#endif

#endif /* _SGI_MP_SOURCE */

#endif /* !_LINT */

#endif /* defined(_LANGUAGE_C) || defined(_LANGUAGE_C_PLUS_PLUS) */

#ifdef __cplusplus
}
#endif
#endif /* !__STDIO_H__ */
