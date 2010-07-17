/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/common.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: common.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:06  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1998/01/16  05:24:56  pinnacle
 * Created: vrrt/common.h by r250_int for route
 *
 *
 *
 * History:
 *	01/15/98	Onay	Integration date.
 *
 *************************************************************************/

#ifndef _COMMON_
#define _COMMON_

/* This header file is designed to be #included at the top of
any C program or module.  The macros #defined here have the objective
of making C code short, readable and consistent.  They have the
disadvantage of creating a provincial dialect of C. */

/* The following header files are all for the standard C library
and can be found in /usr/include.  Of the programs written so far that
use the Common library, these header files are the ones most
frequently needed; more may be added at any time.  #including them here 
increases compile time, but keeps you from having to figure out which ones 
you need for a particular program or module. */
/* See also the #includes toward the end of this header file. */

#include <unistd.h> 	/* Constants for access() routine */
#include <stdlib.h> 	/* Declarations of standard C library functions */
#include <sys/types.h>
#include <values.h> 	/* Hardware constraints on integers, doubles, etc */
#include <varargs.h> 	/* Variable argument lists */
#include <sys/time.h>	/* Functions to determine the current date and time */

#include <errno.h> 	/* Error messages generated by system calls */
extern int sys_nerr; 		/* Why aren't these declared in errno.h? */
extern char* sys_errlist[];

#include <malloc.h>	/* Dynamic memory allocation */
#include <setjmp.h> 	/* Non-local goto support - used in diag.c */

#include <stdio.h>	/* File input/output */
#include <sys/file.h> 	/* Constants for calls to file functions */
#include <sys/stat.h>
#include <utime.h>
extern int access();

#include <ctype.h>	/* Character types (digit, lower case, etc.) */
#include <memory.h>	/* Functions to manipulate byte arrays in memory */
#include <string.h>	/* Functions for null-terminated char arrays */

extern int atoi();
extern long atol();

#undef MAXFLOAT 	/* Keep values.h from conflicting with math.h */
#undef M_LN2
#undef M_PI
#undef M_SQRT2
#include <math.h>	/* Floating-point math functions */

/* The following values are useful for setting/comparing variables
and for checking the return value of various C functions. */

#ifndef TRUE
#define TRUE 1
#endif
#ifndef FALSE
#define FALSE 0
#endif
#define T TRUE
#define F FALSE
#ifndef OKAY
#define OKAY 0
#endif
#ifndef OK
#define OK OKAY
#endif
#ifndef ERROR
#define ERROR (-1)
#endif
#ifndef NULL
#define NULL 0
#endif

/* These typedefs make declarations simpler and allow you to 
declare several variables in one statement, e.g.

	funcp a, b, c;

instead of

	int (*a)(); int (*b)(); int (*c)();
*/

typedef int (*funcp)(); 	/* Pointer-to-function. */
typedef char* charp;		/* Pointer-to-character, i.e. string. */
typedef void* pointer; 		/* Generic pointer. */
typedef pointer (*pfuncp)(); 	/* Pointer to function returning a pointer. */

/* For unsigned versions of standard C types. */

#define UTYPE(type) typedef unsigned type self(u)type;

/* Minimum, maximum, absolute value, sign.
These work with any of C's numerical types. */

#define MIN(a,b) ((a) < (b) ? (a) : (b))
#define MAX(a,b) ((a) < (b) ? (b) : (a))
#define ABS(x) ((x) >= 0 ? (x) : -(x))
#define SIGN(x) ((x) < 0 ? -1 : 1)

#define MIN_(a,b) ((a) < (b) ? (a) : ((a) = (b)))
#define MAX_(a,b) ((a) < (b) ? ((a) = (b)) : (a))
#define ABS_(x) ((x) >= 0 ? (x) : ((x) = -(x)))


#define mod1(x,m) ((((x)-1)/(m))+1)
#define modceil(x,m) (mod1(x,m)*m)

/* KB is 1 kilobyte, 2^10.  MAXSTR is a reasonable character array size
for strings or input lines when memory is not at a premium. */

#define KB 1024
#define MAXSTR 256

/* These macros heavily alter the look of the C language. */

#define not !
#define null(pointer) 	((pointer)==NULL)
#define okay(value) 	((value)==OKAY)
#define error(value) 	((value)==ERROR)
#define noterror(value) (not(error(value)))

#define ifnot(condition) if (not(condition))
#define ifnull(pointer) if (null(pointer))
#define ifokay(value) if (okay(value))
#define iferror(value) if (error(value))
#define ifnoterror(value) ifnot (error(value))

#define until(condition) while (!(condition))
#define For(var,limit) for ((var) = 0; (var)<(limit); (var)++)

/* Operate on two boolean values simultaneously */

#define bits2(b0,b1) (((b0)!=0)|(((b1)!=0)<<1))
#define switch2(b0,b1) switch (bits2(b0,b1))
#define case2(b0,b1) case bits2(b0,b1)

/* These macros build on the standard C library string functions
and on functions defined in the Common module str.c. */

#define strequal(str1,str2) 	(strcmp(str1,str2)==0)
#define strnequal(str1,str2,n) 	(strncmp(str1,str2,n)==0)
#define memequal(s1,s2,n) 	(memcmp(s1,s2,n)==0)

#define strfirstc(str) 		(*(str)) 	/* Counterpart to strlastc(),
						   defined in str.c. */
#define strprefix strlprefix
#define strsuffix strlsuffix

/* Free one string, reassign another. */

#define STR_RENEW(str,newstr) ((str) && (diag0_free(str),1), (str) = (newstr))

/* Upper/lower case in strings.  Under HP-UX, tolower is a function and
_tolower is a macro.  Under SunOS, tolower is a macro and _tolower
does not exist.  (@@#$%?!)  The only portable solution seems to be to make
four new definitions and convert to their usage. */

#define toupper_macro(c)	((c)-'a'+'A')
#define tolower_macro(c)	((c)-'A'+'a')
/* tolower_func() and toupper_func() are defined in tolower.c,
declared in commonext.h */

/* strconvert() is defined in str.c */
#define strtolower(str) 	strconvert(str,tolower_func)
#define strtoupper(str) 	strconvert(str,toupper_func)

/* The following macro allows clean usage of the unbackc_info()
function defined in the Common module unbackc.c.  unbackc_info(str)
returns two pieces of information in one integer; unbackc(str) returns
just the actual character that an escape sequence converts to. */

#define unbackc(str) (lobyte(unbackc_info(str)))

/* When printing a string argument (e.g. a filename) in an error message,
make control characters visible to the user.  back_str(), defined in the
Common module backc.c, overwrites its buffer with each call.  Since we'll
sometimes need to print more than one of these in a single C statement,
keep a circular array for the strings it returns. */

#define NBACKBUF 2
#define BACK(strvar) (strvar) = strcpy(nextbackbuf(),back_str(strvar));

/* Printing a space or newline on the standard output is an action 
frequent enough to justify a very short macro.  (See also the functions 
spn() and nln(), defined in commonio.c.) */

#define SP putchar(' ')		
#define NL putchar('\n')	/* Remember the semicolon, e.g. "SP; NL;" */
#define fNL(file) fputc('\n',file)

/* Fill a string with spaces.  Optional null-termination. */

#define blank(buf,length,do0) \
	(memset(buf,' ',length), (do0) && (*((buf)+(length))='\0'), buf)

/* getarg() takes a string from an array of strings and reduces the
size of the array by 1, returning NULL when there are no more strings
in the array.  GETARG() is for processing command-line arguments
inside main().  To use it you must declare 

	main(argn,argv) int argn; char** argv; { ...
*/

#define getarg(argn,argv) \
	(--(argn), ++(argv), ((argn)+1)>0 ? *((argv)-1) : NULL)
#define ungetarg(argn,argv) \
	(++(argn), --(argv), (argn)>0 ? *(argv) : NULL)
#define GETARG() getarg(argn,argv)
#define UNGETARG() ungetarg(argn,argv)

/* The swap macro can be used with variables of any type.
A temporary variable of the same type must be available to
the calling function.  The xswap macro needs no temporary variable.
Its XOR trick is useful for integers, but questionable for pointers. */

#define swap(a,b,tmp)	((tmp) = (a), (a) = (b), (b) = (tmp))
#define xswap(a,b) 	((a) ^= (b), (b) ^= (a), (a) ^= (b))

/* These macros are for passing multiple arguments of arbitrary type
from one C function to another.  They impose a limit on the number of
arguments that can be passed and they may not work on all platforms.
The Unix varargs package (/usr/include/varargs.h) should be used instead
if possible. */

#define PASSARGS i0,i1,i2,i3,i4,i5,i6,i7,i8,i9,iA,iB,iC,iD,iE,iF
#define PASSDECL int PASSARGS;
#define MAX_PASSARGS_INTS 16
#define MAX_PASSARGS_BYTES ( MAX_PASSARGS_INTS * sizeof(int) )

/* Miscellaneous. */

#define lobyte(x) ((x)&0xFF)
#define hibyte(x) (((x)&0xFF00) >> 8)

#define for_bits_on(type,x,i,b) For (i,8*sizeof(type)) if (x & (b = 1<<i))

#define inrange(value,low,high) ((value) >= (low) && (value) <= (high))
#define range_contain(alo,ahi,blo,bhi) ((alo)<=(blo) && (bhi)<=(ahi))
#define range_overlap(alo,ahi,blo,bhi) ((alo)<=(bhi) && (blo)<=(ahi))

/* Macros for comparisons without magnitude, e.g. for insertion
into a linked list. */

#define CMP_GREATER 1
#define CMP_EQUAL 0
#define CMP_LESS (-1)

/* For interpreting file permissions */

#define FMODEBITS (4*3)
#define FTYPEBITS 4
/* How come the header file doesn't have these?  People must use them. */
#define S_IRALL (S_IRUSR|S_IRGRP|S_IROTH)
#define S_IWALL (S_IWUSR|S_IWGRP|S_IWOTH)
#define S_IXALL (S_IXUSR|S_IXGRP|S_IXOTH)
#define S_IRA 	        S_IRALL
#define S_IRWA 	(S_IRA |S_IWALL)
#define S_IRWXA (S_IRWA|S_IXALL)

/* The following header files are all for the Common library. */

#include "self.h" 	/* Macros for building up a C identifier in pieces. */
#include "diag.h"	/* For the diagnostics module. */
#include "cfunc.h" 	/* For functions corresponding to the character-type 
			    macros defined in /usr/include/ctype.h. */

#include "arrays.h"
#include "struct.h" 	/* Arrays.h and struct.h contain primitive macros
			    for object-oriented programming: allocation,
			    copying, deletion etc. of arrays and structures. */

/*
include "commonext.h" 	
*/
/* Declarations for other functions and variables
			    defined in the various Common modules. */

#endif
