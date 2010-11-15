/* Do not alter this SPC information: $Revision: 1.2.27.1 $ */
/*
**	NAME:							risapi.h
**	AUTHORS:						Hitesh R. Patel
**	CREATION DATE:					8/93
**	ABSTRACT:
**			Defines the macros function type
**	REVISION HISTORY:
*/
 
#ifndef RIS_API_H
#define RIS_API_H

/*
**	DEFINES
*/
#if defined(unix) || defined(DOS)
#define RISAPI 
#endif
#if defined(WIN32)
#include <windef.h>
#define RISAPI WINAPI
#endif

/*
**	TYPES
*/

/*
**	VARIABLES
*/

#endif /* RIS_API_H */
