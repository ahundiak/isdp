/* $RCSfile: FSTypes.h,v $$Revision: 1.1 $$Date: 1994/11/21 16:06:29 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef _TYPES
#define _TYPES	0

/* ===============================================================
 * The Boolean typedef caused problems somewhere in Vds
 * X11 defines it as a char
 * and Vds was complaining about it
 *
 * But up to Grnuc ar least, int seems to work fine
 * int was the original definition so setting it back for now
 */

/**********************************
* Generic scalar type definitions *
**********************************/

typedef char		Int8;
typedef short		Int16;
typedef int		Int32,
			Int;

typedef char            Booleanx; // Was an int

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
