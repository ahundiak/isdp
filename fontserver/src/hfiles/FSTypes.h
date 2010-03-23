/* $RCSfile: fstypes.h $$Revision: 1.1 $$Date: 1990/07/02 16:08:17 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef _TYPES
#define _TYPES	0


/**********************************
* Generic scalar type definitions *
**********************************/

typedef char		Int8;
typedef short		Int16;
typedef int		Int32,
			Int,
			Boolean;
typedef unsigned char	uInt8,
			Char8,
			Char;
typedef unsigned short	uInt16,
			Char16;
typedef unsigned int	uInt32,
			uInt;
typedef float		Real32;
typedef double		Real64,
			Real;


/*********************************
* Font specific type definitions *
*********************************/

typedef Int32	BmapId;		/* bitmap font id		*/
typedef Int32	OutlId;		/* outline font id		*/
typedef Int32	FontId;		/* bitmap or outline font id	*/
typedef Char16	CharId;		/* character id			*/
typedef Int32	CharMapId;	/* character mapping id		*/


#endif
