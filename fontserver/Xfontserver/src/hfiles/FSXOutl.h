/* $RCSfile: fsxoutl.h $$Revision: 1.1 $$Date: 1994/12/27 18:45:10 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef _OUTL
#define _OUTL	0


#include "FSTypes.h"
#include "FSFont.h"


/**************************
* Outline font structures *
**************************/

typedef struct
{
	Char8	magic[4];	/* magic number; "FSOF"			*/
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
	Int32	startPSizeSec;	/* file offset to poly sizes section	*/
	Int32	bytesPSizeRec;	/* number of bytes in poly size record	*/
	Int32	nbrPSizeRec;	/* number of poly size records		*/
	Int32	startVertSec;	/* file offset to vertex section	*/
	Int32	bytesVertRec;	/* number of bytes in vertex record	*/
	Int32	nbrVertRec;	/* number of vertex records		*/
	Char8	reserved[32];	/* reserved for future use		*/
}	OutlHeader;

/** These structures are the same for all fonts **/
#define	OutlInfo	FontInfo
#define	OutlKernPair	FontKernPair
#define	OutlLigature	FontLigature

typedef struct
{
	CharId	charId;		/* character id				*/
	Real64	setWid;		/* set width				*/
	Real64	xMin;		/* minimum x value			*/
	Real64	yMin;		/* minimum y value			*/
	Real64	xMax;		/* maximum x value			*/
	Real64	yMax;		/* maximum y value			*/
	uInt32	sPSize;		/* poly size offset in poly size sect.	*/
	uInt16	nPSize;		/* how many polygon sizes		*/
	uInt32	sVert;		/* vertex offset in vertex section	*/
 	uInt16	nVert;		/* how many vertices			*/
	Int16	flags;		/* flags				*/
}	OutlCharInfo;

typedef	Int32	OutlPolySize;

typedef struct
{
	Real64	x, y;
}	OutlVertex;

typedef struct
{
	Real64	x, y, z;
}	Outl3DVertex;


#endif
