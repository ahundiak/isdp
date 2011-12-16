/* Do not alter this SPC information: $Revision: 1.2.29.1 $ */
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
#if defined(unix) || defined(vms) || defined(DOS) || 0
#define RISAPI 
#elif defined(WIN32)
#define RISAPI WINAPI
#else
#error With a message
#endif

/*
**	TYPES
*/

/*
**	VARIABLES
*/

#endif /* RIS_API_H */
