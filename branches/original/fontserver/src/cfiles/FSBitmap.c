/* $RCSfile: fsbitmap.c $$Revision: 1.1 $$Date: 1990/07/02 16:06:31 $ Copyright (c) 1990 Intergraph Corp. */


/*****************************************************************************
*                                                                            *
*  Copyright 1987, as an unpublished work by Bitstream Inc., Cambridge, MA   *
*                               Patent Pending                               *
*                                                                            *
*         These programs are the sole property of Bitstream Inc. and         *
*           contain its proprietary and confidential information.            *
*                                                                            *
*	Modified extensively by Intergraph Corp., Huntsville, AL	     *
*									     *
*****************************************************************************/


/****************************** B I T M A P . C ******************************

   Utility routines for setting or clearing bits in a bitmap.

 ****************************************************************************/


#include "../hfiles/import.h"
#include "../hfiles/FSDef.h"
#include "../hfiles/FSTypes.h"
#include "../hfiles/FSBmap.h"



static BmapBitmap setMask[8] = { 0x1, 0x2, 0x04, 0x8, 0x10, 0x20, 0x40, 0x80 };
static BmapBitmap setMaskLeft[9] = { 0, 0x80, 0xC0, 0xE0, 0xF0,
				     0xF8, 0xFC, 0xFE, 0xFF };
static BmapBitmap setMaskRight[9] = { 0, 0x1, 0x3, 0x7, 0xF,
				      0x1F, 0x3F, 0x7F, 0xFF };


void  _FSSet1Bit (bitmap, scanLine, bit, rWid)
BmapBitmap	*bitmap;	/* pointer to bitmap memory */
Int32		scanLine;	/* scan line in bitmap (0 = top) */
Int32		bit;		/* bit to be set, (0 = leftmost in line) */
Int32		rWid;		/* raster width of bitmap */

/*  _FSSet1Bit -- sets 1 bit in a bitmap */
{
    BmapBitmap *scan;

    scan = bitmap + scanLine * ((rWid + 7) >> 3);
    scan[bit >> 3] |= setMask[bit & 7];
}



void  _FSSetBits (bitmap, scanLine, rWid, startBit, bitCount)
BmapBitmap	*bitmap;
int		scanLine;
int		rWid;
int		startBit;
int		bitCount;

/*  _FSSetBits -- sets bits in one line in a bitmap 'rWid' bits wide
 *  Input arguments:
 *	scanLine -- scan line in bitmap (0 = top)
 *	rWid -- raster width of bitmap
 *	startBit -- first bit to be set
 *	bitCount -- how many bits to set
 *  Output argument:
 *	bitmap -- pointer to bitmap memory, is updated
 */
{
    register int	fullByte = 0xFF;
    register BmapBitmap	*scanPtr, *scanEnd;
    int			p1;		/* # bits to set in 1st byte */
    int			p2;		/* # bytes to set */
    int			p3;		/* # bits to set in last byte */
    BmapBitmap		*scan;

    scan = bitmap + scanLine * ((rWid + 7) >> 3);	/* ptr to scanLine */
    scanPtr = &scan[startBit >> 3];
    p1 = 8 - (startBit & 7);
    if (p1 >= bitCount)	/* if bits to be set are contained within 1 byte */
    {
	*scanPtr |= (setMaskLeft[p1] & setMaskRight[8 + bitCount - p1]);
    }
    else
    {
	p2 = (bitCount - p1) >> 3;
	p3 = bitCount - (p1 + (p2 << 3));
	*scanPtr++ |= setMaskLeft[p1];

	scanEnd = &scanPtr[p2];
	for (; scanPtr < scanEnd;  scanPtr++)
	    *scanPtr = (BmapBitmap) fullByte;

	*scanPtr |= setMaskRight[p3];
    }
}
