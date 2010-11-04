/* $RCSfile: fscnvrt.c $$Revision: 1.2 $$Date: 1991/02/28 13:52:27 $ Copyright (c) 1990 Intergraph Corp. */

#include <memory.h>
#pragma dumpmacros
#include "../hfiles/FSTypes.h"
#include "../hfiles/FSBmap.h"
#include "../hfiles/FSDef.h"
#include "../hfiles/FSConvert.h"


static uInt8	solidBitArray[9] = { 0, 1, 3, 7, 15, 31, 63, 127, 255 };
static uInt8	singleBitArray[8] = { 1, 2, 4, 8, 16, 32, 64, 128 };

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSConvertRLE8 (source, dest, width, height)			*/
/*	  _FSConvertRLE16 (source, dest, width, height)			*/
/*									*/
/*	  uInt8		*source		- 8-bit RLE encoded bitmap	*/
/*	   or				  for _FSConvertRLE8		*/
/*	  Int16		*source		- 16-bit RLE encoded bitmap	*/
/*					  for _FSConvertRLE16		*/
/*									*/
/*	  BmapBitmap	*dest		- Intergraph bitmap		*/
/*	  int		width;		- width of bitmap		*/
/*	  int		height;		- height of bitmap		*/
/*									*/
/*	DESCRIPTION							*/
/*	  These routines convert from run-length encoded characters to	*/
/*	  Intergraph bitmap format.					*/
/*									*/
/*	RETURN VALUE							*/
/*	  None								*/
/*									*/
/************************************************************************/

int _FSConvertRLE8 (
    uInt8 *source,	/* Beginning of RLE data */
    BmapBitmap *dest,	/* Place to put the bitmap */
    int width,
    int height)		/* Size of bitmap (in pixels) */
{
    BmapBitmap	*place;
    uInt8	start, length, runs;
    int		i, j, size, bytesPerRow;

    bytesPerRow = (width + 7) >> 3;
    size = bytesPerRow * height;

    /* First, clear the bitmap */
    memset (dest, 0, size);

    /* Now OR in the RLE data */
    place = dest; 
    for (i = 0; i < height; i++)		/* Loop through rle rows */
    {
    	runs = *source++;		/* How many runs in this row? */
    	for (j = 0; j < runs; j++)	/* Loop through the runs in the row */
    	{
	    start = *source++;
	    length = *source++;
	    _FSPlaceRun ((Int16) start, (Int16) length, place);
	}
	place += bytesPerRow;	/* Move to next row in bitmap */
    }
}

int _FSConvertRLE16 (
    Int16 *source,	/* Where RLE data is */
    BmapBitmap *dest,	/* Where to put the bitmap */
    int width,
    int height)		/* Size of bitmap (in pixels) */
{
    Int16	start, length, runs;	/* From RLE data */
    int		i, j, size, bytesPerRow;

    bytesPerRow = (width + 7) >> 3;
    size = bytesPerRow * height;

    /* First, clear the bitmap */
    memset (dest, 0, size);

    /* Now OR in the RLE data */
    for (i = 0; i < height; i++)		/* Loop through rle rows */
    {
    	runs = *source++;		/* How many runs in this row? */
    	for (j = 0; j < runs; j++)	/* Loop through the runs in the row */
    	{
	    start = *source++;
	    length = *source++;
	    _FSPlaceRun (start, length, dest);	/* Fill in the bitmap */
	}
	dest += bytesPerRow;	/* Move to next row in bitmap */
    }
}



/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSUnconvertRLE8 (source, dest, width, height)		*/
/*	  _FSUnconvertRLE16 (source, dest, width, height)		*/
/*									*/
/*	  BmapBitmap	*source		- Intergraph bitmap		*/
/*									*/
/*	  uInt8		*dest		- 8-bit RLE encoded bitmap	*/
/*	   or				  for _FSUnconvertRLE8.		*/
/*	  Int16		*dest		- 16-bit RLE encoded bitmap	*/
/*					  for _FSUnconvertRLE16.	*/
/*									*/
/*	  int		width;		- width of bitmap		*/
/*	  int		height;		- height of bitmap		*/
/*									*/
/*	DESCRIPTION							*/
/*	  These routines convert an Intergraph bitmap to an RLE encoded	*/
/*	  bitmap.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  Size of the result, in bytes.					*/
/*									*/
/************************************************************************/

int _FSUnconvertRLE8 (BmapBitmap *source, uInt8 *dest, int width, int height)
{
    Int16 array[5000], *place;
    int bytesPerRow, i, j, count;
    uInt8 *start;

    start = dest;
    bytesPerRow = (width + 7) >> 3;
    for (i = 0; i < height; i++, source += bytesPerRow)
    {
	place = array;
	count = _FSFindRuns (source, width, place);
	if (*place >= 256)
	    return (-1);	/* too many runs for RLE8 */

	*dest++ = (uInt8) (*place); place++;	/* Clipper compiler bug */
	for (j = 0; j < count; j++)
	{
	    if ((*place >= 256) || (*(place + 1) >= 256))
		return (-1);	/* return error if too big for RLE8 */

	    *dest++ = (uInt8) (*place);	place++;
	    *dest++ = (uInt8) (*place);	place++;
	}
    }
    return (dest - start);	/* return size in bytes */
}

int _FSUnconvertRLE16 (BmapBitmap *source, Int16 *dest, int width, int height)
{
    int bytesPerRow, i, count;
    Int16 *start;

    start = dest;
    bytesPerRow = (width + 7) >> 3;
    for (i = 0; i < height; i++, source += bytesPerRow)
    {
	count = _FSFindRuns (source, width, dest);
	dest += (count * 2) + 1;
    }
    return ((dest - start) * sizeof (Int16));	/* return size in bytes */
}


/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSPlaceRun (start, length, place)				*/
/*									*/
/*	  Int16		start		- how many pixels over the run	*/
/*					  starts			*/
/*	  Int16		length		- how long the run is		*/
/*	  uInt8		*place		- starting byte of the row	*/
/*					  where the run goes		*/
/*									*/
/*	DESCRIPTION							*/
/*	  This routine helps translate from a run-length encoded	*/
/*	  bitmap to a real bitmap.  It places runs of 'length pixels	*/
/*	  at the 'start pixel location of the row whose first byte is	*/
/*	  'place.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  None								*/
/*									*/
/************************************************************************/

int _FSPlaceRun (Int16 start, Int16 length, uInt8 *place)
{
#pragma end_dumpmacros
    if (start > 7)		/* Move to first byte where something goes */
    {
	place += start >> 3;
	start = start % 8;
    }

    if (length + start > 8)	/* If it flows into the next byte */
    {
	*place++ |= (solidBitArray[8]) << start;
	length = length - 8 + start;
	start = 0;
    }
    else			/* If it fits right into this byte */
    {
	*place++ |= (solidBitArray[length]) << start;
	length = 0;
    }

    while (length > 0)		/* Still more pixels to place */
    {
	if (length > 7)		/* Just fill in the byte */
	{
	    *place++ = solidBitArray[8];
	    length -= 8;
	}
	else			/* Cut it off, just place length pixels */
	{
	    *place++ |= (solidBitArray[length]) << start;
	    length = 0;
	}
    }
}	    

/************************************************************************/
/*									*/
/*	SYNOPSIS							*/
/*	  _FSFindRuns (start, length, place)				*/
/*									*/
/*	  uInt8		*start		- first byt of the row		*/
/*	  int		length		- number of pixels in row	*/
/*	  Int16		*place		- place to put the run-length	*/
/*					  encoded data			*/
/*									*/
/*	DESCRIPTION							*/
/*	  This procedure translates a row of a bitmap into the RLE	*/
/*	  equivalent.  It returns the data as 16 bit integers.  The	*/
/*	  first word is the number of runs in the row.  Every two	*/
/*	  words after it describe a run.  The first word in the pair	*/
/*	  tells where the run starts, and the second tells how long	*/
/*	  the run is.							*/
/*									*/
/*	RETURN VALUE							*/
/*	  The number of runs in the row					*/
/*									*/
/************************************************************************/

int	_FSFindRuns (uInt8 *start, int length, Int16 *place)
{
    register uInt8	*bitPtr, *bitEnd;
    register int	i, in, run=0, data=0, count;
    register Int16	*countPtr;
    static uInt8	*bitEndPtr = &singleBitArray[8];

    countPtr = place++;
    count = 0;
    in = FALSE;
    bitPtr = singleBitArray;
    bitEnd = bitEndPtr;
    for (i = 0; i < length; i++)
    {
	if ((i & 7) == 0)
	    data = (int) *start++;

	if (((uInt8) data & *bitPtr) != 0)
	{
	    if (! in)
	    {
		*place++ = i;
		run = 1;
		count++;
		in = TRUE;
	    }
	    else
		run++;
	}
	else
	{
	    if (in)
	    {
		*place++ = (Int16) run;
		in = FALSE;
	    }
	}

	bitPtr++;
	if (bitPtr == bitEnd)
	    bitPtr = singleBitArray;
    }
    if (in)
	*place = run;

    *countPtr = (Int16) count;
    return (count);
}

