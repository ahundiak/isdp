/* $RCSfile: fsmkfnt.h $$Revision: 1.1 $$Date: 1990/07/02 16:08:12 $ Copyright (c) 1990 Intergraph Corp. */

#ifndef	_MAKEFONT
#define	_MAKEFONT	0


#include "FSTypes.h"
#include "FSTFCache.h"
#include "FSFontCach.h"


/*****  DEFINITIONS *****/

/* constants */
#define	TWO32	4.294967296E+09	/* 2^32 , bulge factor normalization */
#define	PI	3.1415926536	/* pi */
#define	PTPERINCH 72.2892	/* nbr points per inch, exactly! */
#define	DCHRCT	64		/* max nbr of subcharacters in compound char */

/* Em-square dimensions in high-precision relative units (baseline is at 0) */
#define	EM_TOTAL	8640	/* size of em-square */
#define	EM_LEFT		0	/* left edge of em-square */
#define	EM_RIGHT	8640	/* right edge of em-square */
#define	EM_TOP		6597	/* top edge of em-square */
#define	EM_BOT		-2043	/* bottom edge of em-square */


/* Plaid data constants */
#define	X_DIMENSION		0
#define	Y_DIMENSION		1
#define	MAX_ZONES_PER_DIM	64
#define	MAX_ZONES_PER_COMP_DIM	100

#define	MAX_CACHE_ZONES	1000


#define	MASK_P_FLAG	0x8000	/* Mask to extract parent flag from flags word */
#define	MASK_L_FLAG	0x4000	/* Mask to extract level flag from flags word */
#define	MASK_C_FLAG	0x2000	/* Mask to extract continue flag from flags word */
#define	MASK_FN_FLAG	0x1800	/* Mask to extract function field from flags word */
#define	FN_ONE_ITEM	0x0800	/* Value of function field representing one item */
#define	MASK_MIN	0x00ff	/* Mask to extract minimum field from flags word */


typedef struct
{
    Boolean	flag;		/* T: use subset of char map	*/
    CharId	*list;		/* list of char ids		*/
    Int		count;		/* how many char ids in list	*/
} SubsetList;


typedef struct
{
    Int16	left;
    Int16	right;
    Int16	top;
    Int16	bottom;
}   LRTB;


typedef struct
{
    TFStruct	*compf;		/* compressed outline font */
    FontNode	**fontNode;	/* the font node */
    Int16	chOff;		/* char offset number */
    CharId	charId;		/* character id */
    Real	linesPerEm;
    Real	resFactor;	/* apparent resolution factor */
    Real	pointSizeX;
    Real	pointSizeY;
    Real	resHor;		/* horizontal resolution */
    Real	resVer;		/* vertical resolution */
    Real	rotAngle;
    Real	oblAngle;
    LRTB	clip;		/* clip to char extents */
    LRTB	squeeze;	/* squeeze to char extents */
    Boolean	scanX;		/* T: do scan conv. in 2 dimensions */
    Int32	bslOffX;	/* left s.b.offset in x-scan conversion lists */
    Int32	bslOffY;	/* baseline offset in y-scan conversion lists */
    Boolean	outlFlag;	/* T: making an outline font */
    Boolean	thicken;	/* T: thicken font by one pixel */
    Boolean	noPolys;	/* T: no fillable polygons exist */
    Boolean	outl3D;		/* T: create 3D outlines */
    Boolean	allBitmaps;	/* T: all chars are bitmaps */
    Boolean	allRLE;		/* T: all chars are RLE */
    Boolean	intWidths;	/* T: round all set widths */
	/* These 3 items are passed to the rules.c module */
    Boolean	swFixed;	/* T: set width constrained */
    Boolean	bogusMode;	/* T: ignore plaid data */
    Real	xHtAdj;		/* x-height adj factor (always 1.0) */
}   CompCharDesc;		/* character attributes for scan conversion */


#endif
