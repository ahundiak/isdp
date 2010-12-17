#ifndef FIimport_included
#define FIimport_included	1



/**********************************************************************/
/*** IMPORTANT NOTE !!!  IMPORTANT NOTE !!!  IMPORTANT NOTE !!!     ***/
/**********************************************************************/
/*** THIS FILE MUST BE INCLUDED FIRST IN EVERY XFI SOURCE CODE FILE ***/
/**********************************************************************/

/* These #defines, along with the init_arch.c file, make it        */
/* possible to use the same .o's for System V shared library and   */
/* archive libraries.  This keeps us from having to compile twice: */
/* once with all of the external symbols initialized to 0 for the  */
/* shared library, and one with all of the external symbols        */
/* initialized to their proper values for the archive. */
/*   As of 09/23/92, this is only needed for CLIPPERS.  We have to */
/* compile twice for shared objects on the SUN anyway, because of  */
/* the PIC switch.  MIPS (SGI) uses System V shared libraries, but */
/* we do not currently need shared libraries on MIPS platforms.    */


#include <stdio.h>
#include <ctype.h>
#include <errno.h>
#include <string.h>

/* dmb:09/23/92: We should probably extend the use of standard    */
/* include files here and get away from defining these ourselves. */

/* dmb:09/23/92: Begin original externs.  */

	/*** functions imported from libc.a:	***/
extern int	access();
extern int	atoi();
extern double	atof();
extern int	close();
extern int	fclose();

#if defined(mips)
extern FILE * fopen(const char *, const char *);
#else
extern FILE *	fopen();
#endif

#if defined(clipper)
extern int	fprintf __((FILE *, const char *, ...));
#elif defined(mips) || defined(sun) || defined(sparc) || defined(i386)
extern int	fprintf (FILE *, const char *, ...);
#elif (!defined(hpux))

#else
extern int	fprintf();
#endif

#if defined(clipper)
extern _MY_SIZE_T fread __((void *, size_t, size_t, FILE *));
#elif (defined(sun) || defined(sparc)) && !defined(SYSV)
extern int	fread();
#elif (defined(sun) || defined(sparc)) && defined(SYSV)
extern size_t fread(void *, size_t, size_t, FILE *);
#elif defined(mips)
extern size_t	fread();
#endif

#if defined(clipper)
extern int	fscanf __((FILE *, const char *, ...));
#elif defined(mips) || defined(sun) || defined(sparc) || defined(i386)
extern int	fscanf (FILE *, const char *, ...);
#elif (!defined(hpux))

#else
extern int	fscanf();
#endif

#if defined(i386)
extern   int            fseek(FILE *, long int, int);
#else
extern int	fseek();
#endif

#if defined(clipper)
extern _MY_SIZE_T  fwrite __((const void *, size_t, size_t, FILE *));
#elif (defined(sun) || defined(sparc)) && !defined(SYSV)
extern int	fwrite();
#elif (defined(sun) || defined(sparc)) && defined(SYSV)
extern size_t   fwrite(const void *, size_t, size_t, FILE *);
#elif defined(mips)
extern size_t	fwrite();
#endif

extern char *	getlogin();
extern void	longjmp();

#if defined(clipper)
extern void *memcpy(void *, const void *, size_t);
#elif defined(mips)
extern void *memcpy(void *, const void *, size_t);
#elif (defined(sun) || defined(sparc)) && !defined(SYSV)
extern char *	memcpy();
#elif (defined(sun) || defined(sparc)) && defined(SYSV)
extern void *memcpy(void *, const void *, size_t);
#endif

#if defined(clipper) || defined(mips)
extern void *memset(void *, int, size_t);
#elif (defined(sun) || defined(sparc)) && !defined(SYSV)
extern char *	memset();
#elif (defined(sun) || defined(sparc)) && defined(SYSV)
extern void *memset(void *, int, size_t);
#endif

#if defined(clipper)
extern int open  __((const char *, int, ...));
#elif defined(mips) || defined(i386)
extern int    open(const char *, int, ...);
#elif (defined(sun) || defined(sparc)) && !defined(SYSV)
extern int    open();
#elif (defined(sun) || defined(sparc)) && defined(SYSV)
extern int    open(const char *, int, ...);
#elif (!defined(hpux))

#else
extern int	open();
#endif

#if defined(clipper)
extern int         printf __((const char *, ...));
#elif defined(mips) || defined(sun) || defined(sparc) || defined(i386)
extern int         printf (const char *, ...);
#elif (!defined(hpux))

#else
extern int	printf();
#endif

extern int	read();
extern int	setjmp();


#if defined(clipper)
extern int         sprintf __((char *, const char *, ...));
#elif defined(mips) || defined(i386)
extern int         sprintf (char *, const char *, ...);
#elif (defined(sun) || defined(sparc)) && !defined(SYSV)
extern char *      sprintf (char *, const char *, ...);
#elif (defined(sun) || defined(sparc)) && defined(SYSV)
extern int         sprintf (char *, const char *, ...);
#elif (!defined(hpux))

#else
extern int	sprintf();
#endif

#if defined(clipper)
extern int         sscanf __((const char *, const char *, ...));
#elif defined(mips) || defined(sun) || defined(sparc) || defined(i386)
extern int         sscanf (const char *, const char *, ...);
#elif (!defined(hpux))

#else
extern int	sscanf();
#endif

extern char *	strcat();
extern char *	strchr();
extern int	strcmp();
extern char *	strcpy();

#if defined(clipper)
extern size_t strlen __((const char *s));
#elif (defined(sun) || defined(sparc)) && !defined(SYSV)
extern int	strlen();
#elif (defined(sun) || defined(sparc)) && defined(SYSV)
extern size_t strlen(const char *);
#elif defined(mips)
extern size_t	strlen();
#endif

extern int	strncmp();
extern char *	strncpy();
extern char *	strrchr();
extern long	time();
extern int	tolower();
extern int	toupper();
extern int	uname();

	/*** functions imported from libm.a:	***/
extern double	atan2();
extern double	cos();
extern double	pow();
extern double	sin();
extern double	sqrt();

	/*** functions imported from lib[xc|d]malloc.a:	***/
extern char *	calloc();
extern void	free();
extern char *	malloc();
extern char *	realloc();

	/*** functions imported from libbsd.a:	***/
extern int	select();

extern char * getenv();    /* GMD 2/4/92 */

#if defined(mips)
    /*** dmb:09/23/92:Functions imported from libXFS.a:    ***/

extern int    FSNewFont();
#endif

#if (defined(sun) || defined(sparc)) && defined(SYSV)
extern char * cuserid();    /* sml:01-24-94 */
#endif

/******************************************/
/*** EXTERN's for the things below:	***/
/******************************************/

#if defined(clipper)
extern unsigned char	_ctype[];
#elif defined(mips)
extern char	_ctype[];
#elif defined(sun) || defined(sparc)
/* extern char	_ctype_[]; dmb:09/24/92: This causes problems on sun */
#endif
extern int     		errno;
extern FILE		_iob[];

/* dmb:09/23/92: End original externs.  */


/* dmb:09/23/92:Exp- Try this for Suns, too... Hold for later... */
/** dmb:09/18/92:New Location */
/* dmb:09/24/92:Exp - Add sun */
#if defined(clipper) || defined(mips) || defined(sun) || defined(sparc)
/* #if defined(clipper) || defined(mips) ** dmb:09/24/92: Original */

/******************************************************************/
/*** Only do this for the SYSTEM V versions of X/Forms		***/
/*** ( But the extern's will work okay for all versions. )	***/
/******************************************************************/

#define _ctype		(*libxfi__ctype)
#define _iob		(*libxfi__iob)
#define errno		(*libxfi_errno)

#define access		(*libxfi_access)
#define atoi 		(*libxfi_atoi)
#define atof 		(*libxfi_atof)
#define	close 		(*libxfi_close)
#define fclose 		(*libxfi_fclose)
#define fopen 		(*libxfi_fopen)
#define	fprintf 	(*libxfi_fprintf)
#define	fread 		(*libxfi_fread)
#define	fscanf 		(*libxfi_fscanf)
#define	fseek 		(*libxfi_fseek)
#define	fwrite 		(*libxfi_fwrite)
#define	getlogin 	(*libxfi_getlogin)
#define	longjmp 	(*libxfi_longjmp)
#define	memcpy 		(*libxfi_memcpy)
#define	memset 		(*libxfi_memset)
#define	open 		(*libxfi_open)
#define	printf 		(*libxfi_printf)
#define	read 		(*libxfi_read)

/* dmb:09/24/92:Exp for building new archive on Sun */
#if defined(clipper) || defined(mips)
#define	setjmp 		(*libxfi_setjmp)
#endif

#define	sscanf 		(*libxfi_sscanf)
#define	sprintf 	(*libxfi_sprintf)
#define strcat 		(*libxfi_strcat)
#define strchr 		(*libxfi_strchr)
#define strcmp 		(*libxfi_strcmp)
#define strcpy 		(*libxfi_strcpy)
#define strlen 		(*libxfi_strlen)
#define strncmp 	(*libxfi_strncmp)
#define strncpy 	(*libxfi_strncpy)
#define strrchr 	(*libxfi_strrchr)

/******************************************************************/
/*** Can't define this here, because of xbutton.time structure	***/
/*** used in some files; so just do the #define wherever the	***/
/*** time() function is used.					***/
/******************************************************************
#define	time 		(*libxfi_time)
*******************************************************************/

#define	tolower 	(*libxfi_tolower)
#define	toupper 	(*libxfi_toupper)
#if !defined(mips)
#define	uname 		(*libxfi_uname)
#endif

#define	atan2 		(*libxfi_atan2)
#define	cos 		(*libxfi_cos)
#define	pow 		(*libxfi_pow)
#define	sin 		(*libxfi_sin)
#define	sqrt 		(*libxfi_sqrt)

#define	calloc 		(*libxfi_calloc)
#define	free 		(*libxfi_free)
#define	malloc 		(*libxfi_malloc)
#define	realloc 	(*libxfi_realloc)

#define	select 		(*libxfi_select)
#define getenv		(*libxfi_getenv)

#if (defined(sun) || defined(sparc)) && defined(SYSV)
#define cuserid		(*libxfi_cuserid)
#endif

/* dmb:09/23/92: Begin repeat of externs. These will be #defined to */
/*               their libxfi_ names */

	/*** functions imported from libc.a:	***/
extern int	access();
extern int	atoi();
extern double	atof();
extern int	close();
extern int	fclose();
#if defined(mips)
extern FILE * fopen(const char *, const char *);
#else
extern FILE *	fopen();
#endif

#if defined(clipper)
extern int	fprintf __((FILE *, const char *, ...));
#elif defined(mips) || defined(sun) || defined(sparc)
extern int	fprintf (FILE *, const char *, ...);
#else
extern int	fprintf();
#endif

#if defined(clipper)
extern _MY_SIZE_T fread __((void *, size_t, size_t, FILE *));
#elif defined(sun) || defined(sparc)
extern int	fread();
#elif defined(mips)
extern size_t	fread();
#endif

#if defined(clipper)
extern int	fscanf __((FILE *, const char *, ...));
#elif defined(mips) || defined(sun) || defined(sparc)
extern int	fscanf (FILE *, const char *, ...);
#else
extern int	fscanf();
#endif

extern int	fseek();

#if defined(clipper)
extern _MY_SIZE_T  fwrite __((const void *, size_t, size_t, FILE *));
#elif defined(sun) || defined(sparc)
extern int	fwrite();
#elif defined(mips)
extern size_t	fwrite();
#endif

extern char *	getlogin();
extern void	longjmp();
#if defined(clipper)
extern void *memcpy(void *, const void *, size_t);
#elif defined(mips)
extern void *memcpy(void *, const void *, size_t);
#else
extern char *	memcpy();
#endif

#if defined(clipper) || defined(mips)
extern void *memset(void *, int, size_t);
#else
extern char *	memset();
#endif

#if defined(clipper)
extern int open  __((const char *, int, ...));
#elif defined(mips)
extern int    open(const char *, int, ...);
#elif (defined(sun) || defined(sparc)) && !defined(SYSV)
extern int    open();
#elif (defined(sun) || defined(sparc)) && defined(SYSV)
extern int    open(const char *, int, ...);
#else
extern int	open();
#endif

#if defined(clipper)
extern int         printf __((const char *, ...));
#elif defined(mips)
extern int         printf (const char *, ...);
#else
extern int	printf();
#endif

extern int	read();

#if defined(clipper) || defined(mips)
/* dmb:09/24/92:Exp */
extern int	setjmp();
#endif

#if defined(clipper)
extern int         sprintf __((char *, const char *, ...));
#elif defined(mips)
extern int         sprintf (char *, const char *, ...);
#elif defined(sun) || defined(sparc)
extern char *      sprintf (char *, const char *, ...);
#else
extern int	sprintf();
#endif

#if defined(clipper)
extern int         sscanf __((const char *, const char *, ...));
#elif defined(mips) || defined(sun) || defined(sparc)
extern int         sscanf (const char *, const char *, ...);
#else
extern int	sscanf();
#endif

extern char *	strcat();
extern char *	strchr();
extern int	strcmp();
extern char *	strcpy();

#if defined(clipper)
extern size_t strlen __((const char *s));
#elif defined(sun) || defined(sparc)
extern int	strlen();
#elif defined(mips)
extern size_t	strlen();
#endif

extern int	strncmp();
extern char *	strncpy();
extern char *	strrchr();
extern long	time();
extern int	tolower();
extern int	toupper();
extern int	uname();

	/*** functions imported from libm.a:	***/
extern double	atan2();
extern double	cos();
extern double	pow();
extern double	sin();
extern double	sqrt();

	/*** functions imported from lib[xc|d]malloc.a:	***/
extern char *	calloc();
extern void	free();
extern char *	malloc();
extern char *	realloc();

	/*** functions imported from libbsd.a:	***/
extern int	select();

extern char * getenv();    /* GMD 2/4/92 */


#if defined(mips)
    /*** functions imported from libXFS.a:    ***/

extern int    FSNewFont();
#endif

#if (defined(sun) || defined(sparc)) && defined(SYSV)
extern char * cuserid();    /* sml:01-24-94 */
#endif

/******************************************/
/*** EXTERN's for the things above:	***/
/******************************************/

#if defined(clipper)
extern unsigned char	_ctype[];
#elif defined(mips) || defined(sun) || defined(sparc)
extern char	_ctype[];
#endif
extern int     		errno;
extern FILE		_iob[];

/* dmb:09/23/92: End repeat externs.  */

#endif	/*** defined(clipper) || defined(mips) || defined(sun) || defined(sparc) ***/

#endif /* FIimport_included */

