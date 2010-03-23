/* $RCSfile: fsx.h $$Revision: 1.1 $$Date: 1994/12/27 18:45:10 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef _FS
#define _FS	0


#include "FSTypes.h"
/*
#include <prof.h>
*/


/*********************************
* General Font Server structures *
*********************************/

typedef struct
{
    char	*typeface;	/* full or partial typeface file name	*/
    Real64	bodySize;	/* bodysize of font			*/
    Real64	resFactor;	/* apparent resolution factor		*/
    Real64	aspect;		/* aspect ratio of font			*/
    Real64	rotation;	/* rotation (ccw positive)		*/
    Real64	slant;		/* slant (ccw positive)			*/
    char	*charMap;	/* character mapping file name		*/
    Int32	flags;		/* flags (below)			*/
}   FontSpec;


/** Masks for flags field **/

/** General flags **/
#define	FS_NO_PLAID	0x00000001	/* don't use intelligence data	*/
#define	FS_OUTLINE	0x00000004	/* create an outline font	*/
#define	FS_NO_KERN	0x00000020	/* don't put kern pairs in font	*/
#define	FS_DEMAND	0x00000040	/* create chars only on demand	*/
#define	FS_SHARED	0x00000080	/* share font across processes	*/
#define	FS_INT_WIDTHS	0x00000100	/* all widths are rounded	*/
#define	FS_NO_LOAD 0x00000400	/* do not load glyphs on X display */
#define	FS_LOCAL 0x00000800	/* obtain font locally (don't use wire) */

/** Bitmap flags (FS_OUTLINE must not be set) **/
#define	FS_ALL_BITMAPS	0x00000002	/* all chars stored as bitmaps	*/
#define	FS_ALL_RLE	0x00000010	/* all chars stored as RLE	*/
#define	FS_THICKEN	0x00000008	/* thicken by one pixel		*/
#define	FS_NO_GLYPHS 0x00000200	/* do not send glyph data to client */

/** Outline flags (FS_OUTLINE must be set) **/
#define	FS_3D		0x00000010	/* valid only for outline fonts */

#define FS_NUM_FLAGS 13

/** For compatilibity with old names **/
#define	FS_NOPLAID	FS_NO_PLAID
#define	FS_NORLE	FS_ALL_BITMAPS
#define	FS_NOKERN	FS_NO_KERN


typedef struct
{
    CharId	start;
    Int16	count;
}   RangeSpec;


typedef struct
{
    CharId	charId;
    Char16	bsNbr;
}   CharMapSpec;

/** Flags for character mappings **/
#define	FS_SIXTEEN_BIT	0x1	/* sixteen bit character mapping	*/
#define	FS_ALL_CHARS	0x4	/* all characters in typeface		*/
#define FS_CHARMAP_ID	0x2	/* use specified char map id (obsolete)	*/


/*************************************************
* Error numbers returned by Font Server routines *
*************************************************/

#define	FS_NO_ERROR		0	/* no error			*/
#define	FS_ERROR		-1	/* general error		*/
#define	FS_INVALID_FONT		-2	/* invalid font id		*/
#define	FS_INVALID_CHAR		-3	/* invalid character id		*/
#define	FS_INVALID_CM_FILE	-4	/* invalid char map file	*/
#define	FS_CANT_ALLOC		-5	/* memory cannot be allocated	*/
#define	FS_CANT_MAKE_FONT	-6	/* error making font		*/
#define	FS_FILE_NOT_FOUND	-7	/* file not found		*/
#define	FS_FILE_NOT_WRITTEN	-8	/* file cannot be written	*/
#define	FS_INVALID_SYMBOL_FILE	-9	/* invalid Env V symbol file	*/
#define	FS_INVALID_TF_FILE	-10	/* invalid typeface file	*/
#define	FS_INVALID_FONT_FILE	-11	/* invalid FS font file		*/
#define	FS_INVALID_CHAR_MAP	-12	/* invalid character mapping	*/
#define	FS_DAEMON_ERROR		-13	/* daemon error			*/


/***********************************************
* Character bitmap & outline drawing functions *
***********************************************/
 
extern void _FSDrawBitmap ();		/* real bitmaps			*/
extern void _FSDrawRLE8();		/* bitmaps stored as 8-bit RLE	*/
extern void _FSDrawRLE16();		/* bitmaps stored as 16-bit RLE	*/
extern void _FSDrawOutline ();		/* outlines			*/
extern void _FSDrawOutline3D ();	/* 3D outlines			*/


#endif
