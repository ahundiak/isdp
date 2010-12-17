/* adcomp.h -- compiler specific info goes in here */
#if defined(WIN)
#define ad_malloc winmalloc
#define ad_free(a)   winfree((LPSTR) a)
#else
#define ad_malloc malloc
#define ad_free   free
#endif

#if defined(WIN) && defined(microsoftc)
#define ad_open   _lopen
#define ad_close  _lclose
#define ad_read   _lread
#define ad_lseek  _llseek
#else
#define ad_open   open
#define ad_close  close
#define ad_read   read
#define ad_lseek  lseek
#endif

#define SHTLN short

/* establish some of the compiler specifics */
/* OCTALONLY       -- compiler accepts only octal chars */
/* NOPROTOTYPES    -- compiler does not accept prototypes */
/* BIGENDIAN       -- compiler/computer supports bigendian ordering */
/* OLDCHDR         -- compiler supports only the old c header format */
/* QUADWORDALIGNED -- compiler/computer requires quadword alignment */
/* UNIXOS          -- unix compiler -- use unix-type paths (/) */
/* HIGHCAPACITY    -- increased AD3 limits in use */
/* EASYNULL        -- compiler does not require complex null cast (AD3) */

/* the opposite of each of those is the default.
   That is, compiler/computer accepts hex chars and prototypes, is little
   endian, supports new c headers, is not quad word aligned, is not unix,
   has low capacity, and requires complex NULL cast */

/* ifdef sun changed for SCO/SOLARIS port MVR 22 Dec 1993 */

#if (defined( OS_SUNOS ) || defined( OS_SOLARIS ) ||  defined(OS_SCO_UNIX ) )
#define OCTALONLY
#define OLDCHDR
#define BIGENDIAN
#define QUADWORDALIGNED
#define NOPROTOTYPES
#define UNIXOS
#define HIGHCAPACITY
#define EASYNULL
#define max(a,b)	(((a) > (b)) ? (a) : (b))
#define min(a,b)	(((a) < (b)) ? (a) : (b))
#define memmove(a,b,c) bcopy(b,a,c)
/* Not including mp.h for SCO port MVR 22 Dec 93 */
#ifndef OS_SCO_UNIX
#include "mp.h"
#endif
#endif

/*#ifdef hp*/
/* HP PORT - IGI - 10 Jun 94 */
#if defined(hp) || defined(OS_HPUX)
#define OLDCHDR
#define BIGENDIAN
#define QUADWORDALIGNED
#define NOPROTOTYPES
#define UNIXOS
#define HIGHCAPACITY
#define EASYNULL
#define max(a,b)	(((a) > (b)) ? (a) : (b))
#define min(a,b)	(((a) < (b)) ? (a) : (b))
#include <sys/types.h>
#include <sys/stat.h>
#endif

#ifdef OS_CLIX
  /* Added by SSRS - 17 Mar 94 */
#define max(a,b)	(((a) > (b)) ? (a) : (b))
#define min(a,b)	(((a) < (b)) ? (a) : (b))
#endif

#ifdef rs6000
#define BIGENDIAN
#define QUADWORDALIGNED
#define UNIXOS
#define HIGHCAPACITY
#define EASYNULL
#define max(a,b)	(((a) > (b)) ? (a) : (b))
#define min(a,b)	(((a) < (b)) ? (a) : (b))
#include <sys/types.h>
#include <sys/stat.h>
#endif

#ifdef dec
#define OCTALONLY
#define QUADWORDALIGNED
#define UNIXOS
#define HIGHCAPACITY
#define max(a,b)	(((a) > (b)) ? (a) : (b))
#define min(a,b)	(((a) < (b)) ? (a) : (b))
#include <sys/types.h>
#include <sys/stat.h>
#endif

#ifdef highc
#define HIGHCAPACITY
#endif

#ifdef watcomc
#define HIGHCAPACITY
#define EASYNULL
#endif

#ifdef bc286
#define HIGHCAPACITY
#endif

#ifdef zortechc
#define EASYNULL
#else                /* define for all BUT zortech */
#define PI	3.1415926535898
#endif

#ifndef NOPROTOTYPES
#define PROTOTYPES
#endif

#ifdef PROTOTYPES
#define _(a) a
#else
#define _(a) ()
#endif

/* establish whether or not we're using the _dos_ functions to access
   the files.  If DF is defined, we do; otherwise we use open, read, close */
/* microsoft, all the metawares, watcom, and borland c++ have the _dos_ fns */

#if defined(microsoftc) && !defined(WIN)
#define DF 1
#endif

#if defined(__TURBOC__)
#if (__BORLANDC__ >= 0X0400)
#define DF 1
#endif
#endif


#ifdef bc286
#define memccpy _fmemccpy
#define memchr  _fmemchr
#define memcmp  _fmemcmp
#define memcpy  _fmemcpy
#define memicmp _fmemicmp
#define memset  _fmemset
#define strcat  _fstrcat
#define strchr  _fstrchr
#define strcmp  _fstrcmp
#define strcpy  _fstrcpy
#define strcspn _fstrcspn
#define strdup  _fstrdup
#define stricmp _fstricmp
#define strlen  _fstrlen
#define strlwr  _fstrlwr
#define strncat _fstrncat
#define strncmp _fstrncmp
#define strncpy _fstrncpy
#define strnicmp _fstrnicmp
#define strnset _fstrnset
#define strpbrk _fstrpbrk
#define strrchr _fstrrchr
#define strrev  _fstrrev
#define strset  _fstrset
#define strspn  _fstrspn
#define strstr  _fstrstr
#define strtod  _fstrtod
#define strtok  _fstrtok
#define strupr  _fstrupr
#endif
#ifdef OS_UNIX
/* changed the path of include file temporarily -SSRS - 25/11/93 */
/*#include "../ad11/adfilex.h"*/
#include "./adfilex.h"
#else
#include "c:\p\ad11\adfilex.h"
#endif

#ifdef  STREAM_ACCESS
#define AD_FILE    FILE
#define ad_ftell   ftell
#define ad_fseek   fseek
#define ad_fread   fread
#define ad_getc    getc
#define ad_fgetc   fgetc
#define ad_fopen   fopen
#define ad_fclose  fclose
#define ad_setvbuf setvbuf
#define ad_fgets   fgets
#endif
