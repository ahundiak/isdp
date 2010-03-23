/*****************************************************************************
*                                                                            *
*               Copyright 1988, Bitstream Inc., Cambridge, MA                *
*                            Patent No. 4,785,391                            *
*                                                                            *
*         These programs are the sole property of Bitstream Inc. and         *
*           contain its proprietary and confidential information.            *
*                                                                            *
*****************************************************************************/




/***************************************************************************

    This module contains the C source code for speed critical routines

 ***************************************************************************/


/****************************** S P E E D . C ******************************
 ********************* R E V I S I O N   H I S T O R Y *********************
                                         
September 26,1988   cdf     Created

/**************************************************************************/

#include "stdef.h"              /* Bitstream standard macros & definitions  */
#include "comp2_3.h"            /* data structures for compressed font */
#include "mkbm.h"               /* General definition for make_bmap */
#include "errchk.h"
#include <math.h>

extern  fix31   xx_mult;
extern  fix31   yy_mult;
extern  fix31   x_offset;
extern  fix31   y_offset;
extern  fix31   xy_mult;
extern  fix31   yx_mult;
extern  fix15   no_xx_transforms;
extern  fix15   no_xy_transforms;
extern  fix15   x_i;
extern  fix15   x_orus[];
extern  fix31   x_offset_tbl[];
extern  fix31   x_mult_tbl[];    /* Transformation multiplier */
extern  fix15   no_yx_transforms;   /* No transforms for computing y from x */
extern  fix15   no_yy_transforms;   /* No transforms for computing y from y */
extern  fix15   y_i;                /* Current index into y_orus table */
extern  fix15   y_orus[];        /* Original x coord list */
extern  fix15   y_pixels[];      /* Transformed x coord list */
extern  fix31   y_mult_tbl[];    /* Transformation multiplier */
extern  fix31   y_offset_tbl[];  /* Transformation offset */
extern boolean whitewrite;     /* TRUE if whitewriter bitmaps required */  
extern fix15   x_oru, y_oru;   /* Current position in ORU space */
extern fix15   x_spxl, y_spxl; /* Current position in pixel space (unrounded) */
extern fix15   y_pxl;          /* Current y position in pixel space (rounded) */
extern fix15   char_shift;     /* how many places to shift left or right depending on lpem */
extern fix15   scan_shift;     /* how many places to shift left or right depending on lpem */
extern fix15   char_round;     /* what to round a split integer number with depending on lpem */
extern fix31   scan_round;     /* what to round a split integer number with depending on lpem */
extern fix15   rules_shift;    /* number of bits that do_xy_trans in rules.c is supposed to shift by */
extern boolean x_scan_active;  /* TRUE if vertical sampling required */
extern fix15   frac_x_oru;     /* accumulator for fraction error of sub oru-s */
extern fix15   frac_y_oru;
extern fix15   bmap_xmin;      /* Min X intercept */
                               /*   sub-pixel units during first pass */
                               /*   converted to pixel units at end of first pass */
extern fix15   bmap_xmax;      /* Max X intercept */
                               /*   sub-pixel units during first pass */
                               /*   converted to pixel units at end of first pass */
extern fix15   bmap_ymin;      /* Min Y intercept in pixel units */
extern fix15   bmap_ymax;      /* Max Y intercept in pixel units */
extern boolean first_pass;     /* TRUE if first pass through outline */

FUNCTION  void  do_xy_trans (sub_x, sub_y, xtr, ytr, shift, o_shift)
fix15      sub_x, sub_y;       /* (x, y) input arguments */
fix15      *xtr, *ytr; /* output arguments */
fix15      shift,o_shift;
/*  Called by vector_to() to executes X and Y transformation functions.  
 */

    DECLARE
    fix15  i,x,y;
    fix31  xx_factor = 0,xy_factor = 0,yy_factor = 0,yx_factor = 0;
    fix31  x_offs,y_offs;

    BEGIN
    x = sub_x >> o_shift;
    y = sub_y >> o_shift;

    if (no_xx_transforms > 0)                    /* X is a function of X only (>0 zones)? */
        {
        if (x > x_orus[x_i])
            {
            while (++x_i < no_xx_transforms)
                {
                if (x <= x_orus[x_i])
                    {
                    xx_factor = x_mult_tbl[x_i];
                    x_offs = x_offset_tbl[x_i];
                    goto xx_factor_only;
                    }
                }
            xx_factor = x_mult_tbl[x_i];
            x_offs = x_offset_tbl[x_i];
            x_i--;
            goto xx_factor_only;
            }
        else
            {
            while (--x_i >= 0)
                {
                if (x >= x_orus[x_i])
                    {
                    x_i++;
                    xx_factor = x_mult_tbl[x_i];
                    x_offs = x_offset_tbl[x_i];
                    goto xx_factor_only;
                    }
                }
            xx_factor = x_mult_tbl[0];
            x_offs = x_offset_tbl[0];
            x_i = 0;
            goto xx_factor_only;
            }
        }

    if (no_xx_transforms == 0)                   /* X is a function of X only (no zones)? */
        {
        xx_factor = x_mult_tbl[0];
        x_offs = x_offset_tbl[0];
        goto xx_factor_only;
        }

    if (no_xy_transforms >= 0)                   /* X is a function of Y only? */
        {
        for (i = 0; i < no_xy_transforms; i++)
            {
            if (y <= x_orus[i])
                {
                xy_factor = x_mult_tbl[i];
                x_offs = x_offset_tbl[i];
                goto xx_and_xy_factors;
                }
            }
        xy_factor = x_mult_tbl[i];
        x_offs = x_offset_tbl[i];
        goto xx_and_xy_factors;
        }
xx_factor = xx_mult;
xy_factor = xy_mult;
x_offs = x_offset;
              
xx_and_xy_factors:

    xy_factor >>= o_shift;
    x_offs += (sub_y * xy_factor);

xx_factor_only:

    xx_factor >>= o_shift;
    x_offs += (sub_x * xx_factor);
    *xtr = x_offs >> shift; /* X is a function of X and Y. */

next: if (no_yy_transforms > 0)                  /* Y is a function of Y only (>0 zones)? */
        {
        if (y > y_orus[y_i])
            {
            while (++y_i < no_yy_transforms)
                {
                if (y <= y_orus[y_i])
                    {
                    yy_factor = y_mult_tbl[y_i];
                    y_offs = y_offset_tbl[y_i];
                    goto compute_yy_only;
                    }
                }
            yy_factor = y_mult_tbl[y_i];
            y_offs = y_offset_tbl[y_i];
            y_i--;
            goto compute_yy_only;
            }
        else
            {
            while (--y_i >= 0)
                {
                if (y >= y_orus[y_i])
                    {
                    y_i++;
                    yy_factor = y_mult_tbl[y_i];
                    y_offs = y_offset_tbl[y_i];
                    goto compute_yy_only;
                    }
                }
            yy_factor = y_mult_tbl[0];
            y_offs = y_offset_tbl[0];
            y_i = 0;
            goto compute_yy_only;
            }
        }

    if (no_yy_transforms == 0)                   /* Y is a function of Y only (no zones)? */
        {
        yy_factor = y_mult_tbl[0];
        y_offs = y_offset_tbl[0];
        goto compute_yy_only;
        }

    if (no_yx_transforms >= 0)                   /* Y is a function of X only? */
        {
        for (i = 0; i < no_yx_transforms; i++)
            {
            if (x <= y_orus[i])
                {
                yx_factor = y_mult_tbl[i];
                y_offs = y_offset_tbl[i];
                goto compute_yy_and_yx;
                }
            }
        yx_factor = y_mult_tbl[i];
        y_offs = y_offset_tbl[i];
        goto compute_yy_and_yx;
        }

    yx_factor = yx_mult;
    yy_factor = yy_mult;
    y_offs = y_offset;

compute_yy_and_yx:

    yx_factor >>= o_shift;
    y_offs += sub_x * yx_factor;

compute_yy_only:

    yy_factor >>= o_shift;
    y_offs += sub_y * yy_factor;
    *ytr = y_offs >> shift; /* Y is a function of X and Y. */
    return;

    END


FUNCTION draw_vector_to(x0, y0, x1, y1, icept_func)
fix15 x0;                /* X coordinate increment (orus) */
fix15 y0;                /* Y coordinate increment (orus) */
fix15 x1;
fix15 y1;
void (*icept_func)();
/*  Called by vector_to() to scan convert one vector from the current
 *  point to a new point with the specified incremental coorinates.
 */

    DECLARE
    fix15     how_many_y;      /* # of intercepts at y = n + 1/2  */
    fix15     yc, y_end;          /* yc current */
    fix31     xc, dx_dy;
    fix15     temp1;

    yc = (y0 + char_round) >> char_shift;    /* Y coord of start of vector in pixel space (pixels) */
    /* round off to get y_end */
    y_end = (y1 + char_round) >> char_shift; /* Update y_pxl to end of vector */ 

    how_many_y = y_end - yc; /* Vector crosses how many Y samples? */

    if (how_many_y == 0) return;       /* discard horizontal lines */

/* dx_dy is 32 bits. 16 bit integer, 16 bit fraction. It is the pixel slope */

    temp1 = x1 - x0;
    dx_dy = (((fix31)(temp1) << 16)/
            ((fix31)(y1 - y0))) << char_shift;

/* xc = (yc + .5 - y0) * dx_dy + x0  (in split integer arithmetic!) */
/* yc is integer and must be converted to subpixels. */
/* Then, .5 is added and y0 is subtracted. */
/* dx_dy has to be shifted to be the SUBpixel slope */
/* The result of the multiply has 16 bits of fractional subpixels */
/* so x0 must be shifted to match. The result is xc: */
/*                               16 bits integer, 16 bit fraction in subpixels */

    xc = (((yc << char_shift) + char_round - y0) * (dx_dy >> char_shift)) + ((fix31)x0 << 16);

    if (how_many_y < 0) /* vector up or down? */
        { /* vector DOWN */
        how_many_y += yc;
        xc -= dx_dy;
        while(--yc >= how_many_y)
            {
            temp1 = (xc + 0x8000L) >> 16;
            (*icept_func)(yc, temp1);
            xc -= dx_dy;
            }
        }
        else /* vector UP */
        {
        how_many_y += yc;
        while(yc != how_many_y)
            {
            temp1 = (xc + 0x8000L) >> 16;
            (*icept_func)(yc++, temp1);
            xc += dx_dy;
            }
        }

    END 
