/* $RCSfile: FSXBmap.h,v $$Revision: 1.1 $$Date: 1994/11/21 16:06:33 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef _BMAP
#define _BMAP	0


#include "FSTypes.h"
#include "FSFont.h"


/*************************
* Bitmap font structures *
*************************/

typedef struct
{
	Char8	magic[4];	/* magic number; "FSBF"			*/
	Char8	fmtVersn[4];	/* format version; "V2.1"		*/
	Char8	tfId[4];	/* typeface id				*/
	Char8	tfName[70];	/* typeface description			*/
	Char8	tfFile[128];	/* typeface file name			*/
	Int16	tfRev;		/* typeface revision number		*/
	Int16	layoutNumber;	/* layout number			*/
	Char8	mfgDate[10];	/* manufacturing date			*/
	Int32	timeStamp;	/* time stamp				*/
	Char8	copyrt[34];	/* copyright notice			*/
	Int32	startGenSec;	/* file offset to general info section	*/
	Int32	bytesGenSec;	/* number of bytes in info section	*/
	Int32	startKernSec;	/* file offset to kern pair section	*/
	Int32	bytesKernRec;	/* number of bytes in kern pair record	*/
	Int32	nbrKernRec;	/* number of kern pair records		*/
	Int32	startLigSec;	/* file offset to ligature section	*/
	Int32	bytesLigRec;	/* number of bytes in ligature record	*/
	Int32	nbrLigRec;	/* number of ligature records		*/
	Int32	startDirSec;	/* file offset to char dir section	*/
	Int32	bytesDirRec;	/* number of bytes in char dir record	*/
	Int32	nbrDirRec;	/* number of char dir records		*/
	Int32	startMapSec;	/* file offset to bitmap section	*/
	Int32	bytesMapSec;	/* number of bytes in bitmap section	*/
	Char8	reserved[32];	/* reserved for future use		*/
}	BmapHeader;

/** These structures are the same for all fonts **/
#define	BmapInfo	FontInfo
#define	BmapKernPair	FontKernPair
#define	BmapLigature	FontLigature

typedef struct
{
	CharId	charId;		/* character id				*/
	Real64	setWid;		/* set width				*/
	Int16	hOff;		/* horiz. offset of bmap from baseline	*/
	Int16	vOff;		/* vert. offset of bitmap from baseline	*/
	uInt16	rWid;		/* width of bitmap			*/
	uInt16	rHgt;		/* height of bitmap			*/
	uInt32	sMap;		/* offset to bitmap in bitmap section	*/
	uInt32	nMap;		/* size of bitmap, in bytes		*/
	Int16	flags;		/* flags (below)			*/
}	BmapCharInfo;

/** Masks for the flags field **/
#define FS_REAL_BITMAP		0x1
#define FS_RUNLENGTH_8		0x0
#define FS_RUNLENGTH_16		0x2
#define FS_BITMAP_TYPE		0x3

/** For compatilibity with old name **/
#define FS_USED_FLAG_BITS	FS_BITMAP_TYPE

typedef uInt8	BmapBitmap;


#endif
