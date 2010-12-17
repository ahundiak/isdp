/* Do not alter this SPC information: $Revision: 1.2.29.1 $ */
/*
**	NAME:							mm.h
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					10/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/

#ifndef MM_H
#define MM_H
 
#ifdef GLOBAL_DEFINE
#define EXTERN
#define INIT(x)	= x
#else
#define EXTERN	extern
#define INIT(x)
#endif

/*
**	INCLUDES
*/
#include <stdio.h>
#if defined(__clipper__)
#include <unistd.h>
#endif
#if defined(WIN32) || defined(DOS)
#include <stdlib.h>
#endif

/*
**	DEFINES
*/

#define IF_FALSE		0
#define IF_TRUE			1
#define IF_UNKNOWN		2
#define IF_INVALID		3
#define ELIF_FALSE		4
#define ELIF_TRUE		5
#define ELIF_UNKNOWN	6
#define ELIF_INVALID	7
#define ELSE			8
#define ENDIF			9
#define INCLUDE			10
#define OTHER			11

#define UNK_TYPE	0
#define C_TYPE		1
#define RC_TYPE		2

#ifdef DEBUG
# define STRING(x) ((x)?(x):"NULL")
# define DBG(s)	printf s
#else
# define DBG(s)
#endif

#define	SKIP_WHITE_SPACE(ptr)		while(*(ptr) && isspace(*(ptr))) {(ptr)++;}
#define	SKIP_TO_WHITE_SPACE(ptr)	while(*(ptr) && !isspace(*(ptr))) {(ptr)++;}
#define MALLOC(type)				(type *)malloc(sizeof(type))
#define ERRHEADER(ln,fl)	fprintf(stderr,"\"%s\", line %d: ",fl,ln)
#define MATCH(s1, s2)	(!strncmp(s1, s2, sizeof(s2) - 1))
#define EXIT(mode)		close_output_file(mode); exit(mode);

#if defined(WIN32) || defined(DOS)
# define PATH_MAX  _MAX_PATH
#endif
#if defined(unix) && !defined(__clipper__)
# define PATH_MAX  255
#endif

#if defined(unix)
#define PATH_CHAR '/'
#endif
#if defined(WIN32) || defined(DOS)
#define PATH_CHAR '\\'
#endif

/*
**	TYPES
*/

/*
**	VARIABLES
*/

EXTERN char	*exe				INIT("mm");
EXTERN char src[PATH_MAX]		INIT(".");
EXTERN int	error_count			INIT(0);
EXTERN int	warnings			INIT(0);

#endif
