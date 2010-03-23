/* $RCSfile: fstypfc.h $$Revision: 1.1 $$Date: 1990/07/02 16:08:17 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef _TYPEFACE
#define _TYPEFACE	0


#include "FSTypes.h"


/***********************
 * Typeface structures *
 ***********************/

typedef struct
{
	Char8	blockId[2];
	uInt16	nrDataWds;
	uInt16	recSize;
	uInt16	nrRecs;
}	TFBlockHeader;

typedef struct
{
	Char8	outlFmtNr[8];
	Char8	srcFontId[4];
	Int16	srcFontVrsn;
	Char8	srcFontName[70];
	Char8	mfgDate[10];
	Char8	layoutName[70];
	Int16	layoutNumber;		/* character layout number	*/
	Char8	cpyrtNotice[74];
	uInt32	timeStamp;
	uInt16	reslPerEm;
	uInt16	flag1;
	uInt16	flag2;			/* see below			*/
	Int32	extentXMin;
	Int32	extentXMax;
	Int32	extentYMin;
	Int32	extentYMax;
	uInt32	offsKernPrs;
	uInt32	offsKernTrks;
	uInt32	offsLigTable;		/* offset to ligature table	*/
	uInt32	offsCharDir;
	uInt32	offsOutlData;
	uInt16	layoutSize;
	uInt16	wordSpaceWidth;
	uInt16	custNumber;
	Char8	custNotice[100];	/* Intergraph legal statement	*/
	uInt16	revNumber;
	Int32	userId;			/* Intergraph user id		*/
	Int32	userData;		/* Intergraph user data		*/
	Char8	reserved[110];		/* round out to 512 (packed)	*/
}	TFInfo;

/** Masks for flag1 **/
#define	FS_REPCOD	0x0001	/* bit 0: 1 -> repeat coding set	*/
#define	FS_X_EXTN	0x0002	/* bit 1: 1 -> character x-extents	*/
#define	FS_Y_EXTN	0x0004	/* bit 2: 1 -> character y-extents	*/
#define	FS_EXTPTS	0x0008	/* bit 3: 1 -> extreme point addition	*/
#define	FS_KERNPR	0x0010	/* bit 4: 1 -> kerning pair data	*/
#define	FS_KTRCK1	0x0020	/* bit 5: 1 -> kerning track 1		*/
#define	FS_KTRCK2	0x0040	/* bit 6: 1 -> kerning track 2		*/
#define	FS_KTRCK3	0x0080	/* bit 7: 1 -> kerning track 3		*/
#define	FS_PLDATA	0x0100	/* bit 8: 1 -> plaid data		*/
#define	FS_HIERAR	0x0200	/* bit 9: 1 -> hierarchy data		*/
#define	FS_CHARID	0x0400	/* bit 10: 1 -> char IDs		*/
#define	FS_NCVSMP	0x0800	/* bit 11: 1 -> no curve simplification	*/

/** Masks for flag2 **/
#define	FS_NOPOLYS	0x0001	/* bit 0: 1 -> no fillable polygons	*/
#define FS_KTRCK4	0x0002	/* bit 1: 1 -> kerning track 4		*/

typedef struct
{
	Char16	char1;		/* first character in kerning pair	*/
	Char16	char2;		/* second character in kerning pair	*/
	Int16	adjustment;	/* spacing adjustment			*/
}	TFKernPair;

typedef struct
{
	Int16	pointSize;	/* point size for these tracks	*/
	Int16	trackAdj[4];	/* kern tracks 1-4		*/
}	TFKernTrack;

typedef struct
{
	Char16	char1;	/* first character in ligature	*/
	Char16	char2;	/* second character in ligature	*/
	Char16	char3;	/* third character in ligature	*/
	Char16	lig;	/* ligature character		*/
}	TFLigature;

typedef struct
{
	uInt16	setWidth;
	uInt32	outlineOffs;
	Char16	charId;
}	TFCharInfo;

typedef uInt16	TFOutlines;


#endif
