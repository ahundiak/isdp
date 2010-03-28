/* $RCSfile: fstypes.h $$Revision: 1.1 $$Date: 1990/07/02 16:08:17 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef _TYPES
#define _TYPES	0
#include <sys/types.h>

/**********************************
* Generic scalar type definitions *
**********************************/

typedef char		Int8;
typedef short		Int16;
typedef int		Int;
typedef int		Boolean;
typedef int32_t         Int32;
typedef uchar_t 	uInt8;
typedef uchar_t 	Char8;
typedef uchar_t 	Char;
typedef uint16_t	uInt16;
typedef uint16_t	Char16;
typedef uint_t      	uInt;
typedef uint32_t        uInt32;
typedef float		Real32;
typedef double		Real64;
typedef double		Real;


/*********************************
* Font specific type definitions *
*********************************/

typedef Int32	BmapId;		/* bitmap font id		*/
typedef Int32	OutlId;		/* outline font id		*/
typedef Int32	FontId;		/* bitmap or outline font id	*/
typedef Char16	CharId;		/* character id			*/
typedef Int32	CharMapId;	/* character mapping id		*/


#endif
