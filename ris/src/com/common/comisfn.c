/* Do not alter this PINNACLE information: $Revision: 1.7.4.1 $ */
/*
**	NAME:							comisfn.c
**	AUTHORS:						Jin Jing
**	CREATION DATE:					7/92
**	ABSTRACT:
**	contains the functions that test byte types
**		
**	
**	REVISION HISTORY:
**              Removed calls to isbitset. Paula 8/94
**              Removed the functions:
**                  RIScom_isdbchar()
**                  RIScom_issgchar()
**                      These functions are no longer necessary due to unicode
**                      functionality. Paula 10/17/94
**              Added Unicode functions to utilities Melania 12/1/95 TR#439503878
**
*/
 
/*
**	INCLUDES
*/
// Need this for isascii stuff
#define __EXTENSIONS__

#include <ctype.h>
#include "riscom.h"

/******************************************************************************/

extern int RIScom_isspace(
	int c)
{
#if defined(WIN32)
        return (RIScom_uisspace((char *)&c)) ;
#else
	return(isspace(c));
#endif
}

/******************************************************************************/

extern int RIScom_isdigit(
	int c)
{
	return(isdigit(c));
}

/******************************************************************************/

extern int RIScom_isxdigit(
	int c)
{
	return(isxdigit(c));
}

/******************************************************************************/

extern int RIScom_islower(
	int c)
{
#if defined(WIN32)
        return (RIScom_uislower((char *)&c)) ;
#else
	return(islower(c));
#endif
}

/******************************************************************************/

extern int RIScom_isupper(
	int c)
{
#if defined(WIN32)
        return (RIScom_uisupper((char *)&c)) ;
#else
	return(isupper(c));
#endif
}

/******************************************************************************/

extern int RIScom_isalpha(
	int c)
{
	return(isalpha(c));
}

/******************************************************************************/

extern int RIScom_isalnum(
	int c)
{
	return(isalnum(c));
}

/******************************************************************************/

extern int RIScom_iscntrl(
	int c)
{
	return(iscntrl(c));
}

/******************************************************************************/

extern int RIScom_ispunct(
	int c)
{
	return(ispunct(c));
}

/******************************************************************************/

extern int RIScom_isprint(
	int c)
{
	return(isprint(c));
}

/******************************************************************************/

extern int RIScom_isgraph(
	int c)
{
	return(isgraph(c));
}

/******************************************************************************/

extern int RIScom_isascii(
	int c)
{
	return(isascii(c));
}

/******************************************************************************/

extern int RIScom_tolower(
	int c)
{
#if defined(WIN32)
        return (RIScom_utolower((char *)&c)) ;
#else
	return(_tolower(c));
#endif
}

/******************************************************************************/

extern int RIScom_toupper(
	int c)
{
#if defined(WIN32)
        return (RIScom_utoupper((char *)&c)) ;
#else
	return(_toupper(c));
#endif
}

/******************************************************************************/

extern int RIScom_toascii(
	int c)
{
	return(toascii(c));
}

/******************************************************************************/
