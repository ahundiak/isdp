




/*****************************************************************************
*                                                                            *
*  Copyright 1987, as an unpublished work by Bitstream Inc., Cambridge, MA   *
*                               Patent Pending                               *
*                                                                            *
*         These programs are the sole property of Bitstream Inc. and         *
*           contain its proprietary and confidential information.            *
*                                                                            *
*****************************************************************************/




/****************************** B I T M A P . C ******************************

   Utility routines for setting or clearing bits in a bitmap.

 ****************************************************************************/


#include "../hfiles/stdef.h"              /* Bitstream standard macros  */



static  bit8  setmask[8] = { 0x80, 0x40, 0x20, 0x10, 0x8, 0x4, 0x2, 0x1 };
static  bit8  clrmask[8] = { 0x7F, 0xBF, 0xDF, 0xEF, 0xF7, 0xFB, 0xFD, 0xFE };
static  bit8  setmask_left[9] = { 0, 1, 3, 7, 0xF, 0x1F, 0x3F, 0x7F, 0xFF };
static  bit8  clrmask_left[9] = { 0xFF, 0x7F, 0x3F, 0x1F, 0xF, 7, 3, 1, 0 };
static  bit8  setmask_right[9] = { 0, 0x80, 0xC0, 0xE0, 0xF0,
                                   0xF8, 0xFC, 0xFE, 0xFF };
static  bit8  clrmask_right[9] = { 0xFF, 0xFE, 0xFC, 0xF8,
                                   0xF0, 0xE0, 0xC0, 0x80, 0 };


FUNCTION  void  set_1_bit (bitmap, scanline, bit, rwid)
  bit8     *bitmap;         /* pointer to bitmap memory */
  fix31     scanline;       /* scan line in bitmap (0 = top) */
  fix31     bit;            /* bit to be set, (0 = leftmost in line) */
  fix31     rwid;           /* raster width of bitmap */

/*  SET_1_BIT -- sets 1 bit in a bitmap
    Called from 'convert.c'     */

    DECLARE
    fix31   t;

    BEGIN
    t = scanline * rwid + bit;
    bitmap[t >> 3] |= setmask[t & 7];
    END




/*  FUNCTION  void  clr_1_bit (bitmap, scanline, bit, rwid)
/*    bit8     *bitmap;         /* pointer to bitmap memory */
/*    fix31     scanline;       /* scan line in bitmap (0 = top) */
/*    fix31     bit;            /* bit to be cleared, (0 = leftmost in line) */
/*    fix31     rwid;           /* raster width of bitmap */
/*  
/*      CLR_1_BIT -- clears 1 bit in a bitmap
/*      Called from 'convert.c'     */
/*  
/*      DECLARE
/*      fix31   t;
/*  
/*      BEGIN
/*      t = scanline * rwid + bit;
/*      bitmap[t >> 3] &= clrmask[t & 7];
/*      END                                                 */


FUNCTION  void  set_bits (bitmap, scanline, rwid, xbit1, xbit2)
  bit8     *bitmap;
  fix15     scanline;
  fix15     rwid;
  fix15     xbit1, xbit2;

/*  SET_BITS -- sets bits in one line in a bitmap 'rwid' bits wide
 *  Input arguments:
 *    scanline -- scan line in bitmap (0 = top)
 *    rwid -- raster width of bitmap
 *    xbit1, xbit2 -- first, last bits to be set
 *  Output argument:
 *    bitmap -- pointer to bitmap memory, is updated
 *  Called from 'convert.c'
 */
    DECLARE
    fix31   bit_count;
    fix31   byn;            /* p1 - # bits to set in 1st byte */
    fix31   ii;             /* p2 - # bytes to set  */
    fix31   p1, p2, p3;     /* p3 - # bits to set in last byte */
    fix31   t;

    BEGIN
    byn = (t = (ufix32)scanline * rwid + xbit1) >> 3;
    bit_count = xbit2 - xbit1 + 1;
    p1 = 8 - (t % 8);
    if (p1 > bit_count)     /* if bits to be set are contained within 1 byte */
        {
        bitmap[byn] |= (setmask_left[p1] & setmask_right[8 + bit_count - p1]);
        return;
        }
    p2 = (bit_count - p1) >> 3;
    p3 = bit_count - (p1 + (p2 << 3));
    bitmap[byn++] |= setmask_left[p1];
    for (ii=0; ii < p2;  ii++)
        bitmap[byn++] = 0xFF;
    bitmap[byn] |= setmask_right[p3];
    return;
    END
