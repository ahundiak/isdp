/*	Copyright (c) 1984 AT&T	*/
/*	Copyright (c) 1988,1989,1990 Intergraph Corporation	*/
/*	  All Rights Reserved  	*/

/*	THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF AT&T	*/
/*	AND INTERGRAPH CORPORATION		   	*/
/*	The copyright notice above does not evidence any   	*/
/*	actual or intended publication of such source code.	*/

#ident  "$Id$  Copyright (c) 1986,1987,1988,1989,1990 by Intergraph Corp."

#ifndef _CTYPE_H
#define _CTYPE_H

#if defined(__STDC__) || defined(__cplusplus)
#define __(p) p
#else
#define __(p) ()
#endif

#define	_U	01	/* Upper case */
#define	_L	02	/* Lower case */
#define	_N	04	/* Numeral (digit) */
#define	_S	010	/* Spacing character */
#define	_P	020	/* Punctuation */
#define	_C	040	/* Control character */
#define	_B	0100	/* Blank */
#define	_X	0200	/* heXadecimal digit */

#if defined(__cplusplus)
extern "C" {
#endif

/* functional representation of macros */
extern int isalnum __((int));
extern int isalpha __((int));
extern int iscntrl __((int));
extern int isdigit __((int));
extern int isgraph __((int));
extern int islower __((int));
extern int isprint __((int));
extern int ispunct __((int));
extern int isspace __((int));
extern int isupper __((int));
extern int isxdigit __((int));  

/* ansi needs these without underbar, similar to _toupper and _tolower */
extern int tolower __((int));
extern int toupper __((int));   

#if (!defined(__STDC__) && !defined(__cplusplus)) || defined(_INGR_EXTENSIONS)

/*   Ingr extensions to ANSI C:                                              */
/*   These identifiers "pollute" ANSI name space, and are not included in    */
/*   strict ANSI compiles.  They are visible by default during K&R and       */
/*   mixed mode compilations, but are not visible during ANSI compilations   */
/*   unless the identifier _INGR_EXTENSIONS is defined.                      */

extern unsigned char	_ctype[];
extern int		isascii __((int));
extern int		toascii __((int));
extern int		_toupper __((int));
extern int		_tolower __((int));
#endif /* end of Ingr extensions */

/*
 * _BUILTIN_ declarations are used as a mechanism to flag candidates for
 * in-line code generation to compilers. If a compiler supports in-line
 * code generation, then it can recognize the _BUILITIN_<name> construct
 * and generate in-line code for that macro call.
 */

#define	_BUILTIN_isalpha(c)	((_ctype + 1)[c] & (_U | _L))
#define isalpha(c) 		_BUILTIN_isalpha(c)

#define	_BUILTIN_isupper(c)	((_ctype + 1)[c] & _U)
#define isupper(c) 		_BUILTIN_isupper(c)

#define	_BUILTIN_islower(c)	((_ctype + 1)[c] & _L)
#define islower(c) 		_BUILTIN_islower(c)

#define	_BUILTIN_isdigit(c)	((_ctype + 1)[c] & _N)
#define isdigit(c) 		_BUILTIN_isdigit(c)

#define	_BUILTIN_isxdigit(c)	((_ctype + 1)[c] & _X)
#define isxdigit(c) 		_BUILTIN_isxdigit(c)

#define	_BUILTIN_isalnum(c)	((_ctype + 1)[c] & (_U | _L | _N))
#define isalnum(c) 		_BUILTIN_isalnum(c)

#define	_BUILTIN_isspace(c)	((_ctype + 1)[c] & _S)
#define isspace(c)  		_BUILTIN_isspace(c)

#define	_BUILTIN_ispunct(c)	((_ctype + 1)[c] & _P)
#define ispunct(c)  		_BUILTIN_ispunct(c)

#define	_BUILTIN_isprint(c)	((_ctype + 1)[c] & (_P | _U | _L | _N | _B))
#define isprint(c) 		_BUILTIN_isprint(c)

#define	_BUILTIN_isgraph(c)	((_ctype + 1)[c] & (_P | _U | _L | _N))
#define isgraph(c) 		_BUILTIN_isgraph(c)

#define	_BUILTIN_iscntrl(c)	((_ctype + 1)[c] & _C)
#define iscntrl(c)		_BUILTIN_iscntrl(c)

#define	_BUILTIN_isascii(c)	(!((c) & ~0177))
#define isascii(c)  		_BUILTIN_isascii(c)

#define	_BUILTIN_toupper(c)     ((_ctype + 258)[c])
#define _toupper(c)  		_BUILTIN_toupper(c)

#define	_BUILTIN_tolower(c)	((_ctype + 258)[c])
#define _tolower(c)  		_BUILTIN_tolower(c)

#define	_BUILTIN_toascii(c)	((c) & 0177)
#define toascii(c)  		_BUILTIN_toascii(c)

#if defined(__cplusplus)
}
#endif

#endif  /* _CTYPE_H  */

/* Steve Lanham added this to make isdigit() work in XFB */
extern unsigned char	_ctype[];
