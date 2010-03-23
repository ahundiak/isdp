/* $RCSfile: fsfont.h $$Revision: 1.1 $$Date: 1990/07/02 16:08:07 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef _FONT
#define _FONT	0


#include "FSTypes.h"
#include "FS.h"


/*  Font structures that are identical for all fonts:	*/
/*	FontInfo	FontKernPair	FontLigature	*/

typedef struct
{
	Char8		typeface[15];	/* typeface file name		*/
	Real64		bodySize;	/* bodysize of font		*/
	Real64		resFactor;	/* apparent resolution factor	*/
	Real64		aspect;		/* aspect ratio of font		*/
	Real64		rotation;	/* rotation angle of font	*/
	Real64		slant;		/* slant angle of font		*/
	Char8		charMap[15];	/* character mapping file name	*/
	Int32		flags;		/* FontSpec flags		*/
	Real64		ascent;		/* ascent value			*/
	Real64		descent;	/* descent value		*/
	Real64		minExtent;	/* min exten value		*/
	Real64		maxExtent;	/* max extent value		*/
	Real64		track[4];	/* kerning tracks (1-4)		*/
	Real64		rotationSin;	/* sine of rotation angle	*/
	Real64		rotationCos;	/* cosine of rotation angle	*/
	Int16		drawDir;	/* draw direction (below)	*/
	CharId		missingChar;	/* missing character id		*/
	Int32		fontFlags;	/* miscellaneous flags (below)	*/
}	FontInfo;

/** Constants for the drawDir field **/
#define FS_LEFT_TO_RIGHT	0
#define FS_RIGHT_TO_LEFT	1
#define FS_TOP_TO_BOTTOM	2
#define FS_BOTTOM_TO_TOP	3

/** Masks for the fontFlags field **/
#define FS_SIXTEEN_BIT_FONT	0x1	/* if font was created using	*/
					/*  a 16-bit character mapping	*/
#define FS_FILLABLE_FONT	0x2	/* if this outline font is made	*/
					/*  up of closed polygons	*/

typedef struct
{
	CharId	char1;	/* first character in kerning pair	*/
	CharId	char2;	/* second character in kerning pair	*/
	Real64	kern;	/* spacing adjustment			*/
}	FontKernPair;

typedef struct
{
	CharId	char1;	/* first character in ligature	*/
	CharId	char2;	/* second character in ligature	*/
	CharId	char3;	/* third character in ligature	*/
	CharId	lig;	/* ligature character		*/
}	FontLigature;


/* Font structures that are not identical for all fonts, but exist in	*/
/* all fonts in one form or another (hence, these can only be used to	*/
/* declare a pointer or handle, so their definitions are arbitrary):	*/
/*	FontHeader	FontCharInfo					*/

#define	FontHeader	char
#define	FontCharInfo	char


#endif
