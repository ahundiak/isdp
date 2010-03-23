




/*****************************************************************************
*                                                                            *
*  Copyright 1987, as an unpublished work by Bitstream Inc., Cambridge, MA   *
*                               Patent Pending                               *
*                                                                            *
*         These programs are the sole property of Bitstream Inc. and         *
*           contain its proprietary and confidential information.            *
*                                                                            *
*****************************************************************************/




/************************** S P L I T _ A R C S . C **************************

    Takes an arc specified by 2 endpoints and a bulge factor and returns a
    polygonal approximation to the arc by successive splitting

 ****************************************************************************/






#include "../hfiles/stdef.h"
#include "../hfiles/comp2_3.h"            /* data structures for compr'd font */
#include "../hfiles/mkbm.h"
#include "../hfiles/polyfill.h"
#include "../hfiles/math.h"



typedef  struct
    {
    float  x1;                 /* 2 endpoints */
    float  y1;
    float  x2;
    float  y2;
    }
    arc_data;


/*   ARC SPLITTING ALGORITHM:

  Let (X1, Y1)  and  (X2, Y2) be the endpoints. Let B be the bulge factor
  The sign of B determines which way the arc bends.

  The midpoint of the arc  (XM, YM) is calculated as
    XM = (X1 + X2) / 2  -  B * (Y2 - Y1) / 2
    YM = (Y1 + Y2) / 2  +  B * (X2 - X1) / 2

  The error, which is the distance from the midpoint of the chord between
  (X1, Y1) and (X2, Y2) and the midpoint of the arc, is simply the absolute
  value of  .5 * chord_length * bulge_factor

  The bulge factor for the newly split arcs, B(new), is
    B(new) = (sqrt(1 + B*B) - 1) / B
  Note that as B approaches 0, B(new) = .5 * B (approx), and the error will
  diminish by almost a factor of 4 each time.

  These steps can be repeated until the error is acceptably small.
*/

FUNCTION  bool  arc_to_vects (x1, y1, x2, y2,
                                bugfat, tolerance, vectr, split_count)
  fix31     x1, y1;         /* arc endpoint */
  fix31     x2, y2;         /* arc endpoint */
  fix31     bugfat;         /* unnormalized bulge factor */
  float     tolerance;      /* arc splitting tolerance in outline relative units */
  vector_data  **vectr;     /* pointer to vector storage area */
  fix31    *split_count;    /* number of vectors to create */

/* ARC_TO_VECTS
 *  INPUT PARAMETERS:  x1, y1, x2, y2 (in outline resolution units),
 *                     bugfat, tolerance
 *  OUTPUT PARAMETERS:  split_count = number of vectors required to draw arc
 *                        with a maximum error of < 'tolerance' pixels
 *                      vectr = pointer to storage allocation for 'split_count'
 *                        vectors (split_count + 1 points)
 *  Allocates memory for 'vectr' -- 'split_count' + 1 structures of type
 *    'vector_dat'. The calling program deallocates this memory.
 *  CALLED BY:  another module
 */
    DECLARE
    float       abvbul;         /* maximum deviation from chord line */
    fix31       iabvbul;        /*              at the center of arc */
    arc_data    arc;            /* 2 arc endpoints */
    float       bulge_factor;   /* normalized bulge factor */
    float       chord_length;   /* distance between arc endpoints */
    double      dx, dy;
    fix15       split_shift;    /* number of arc splittings */

    ufix8      *alloc();        /* allocate chunk of static memory */
    fix31       i_pow();        /* exponiator */
    bool        put_vectors();  /* calculate the arc splitting */

    BEGIN
    if (bugfat == 0)
        printf("\n*** BULGE FACTOR = 0 ***!\n");
    bulge_factor = (double)bugfat / TWO32;
    arc.x1 = x1;
    arc.y1 = y1;
    arc.x2 = x2;
    arc.y2 = y2;
    dx = arc.x2 - arc.x1;
    dy = arc.y2 - arc.y1;
    chord_length = sqrt(dx * dx + dy * dy);
    abvbul = ABS(chord_length * bulge_factor) / 2;
    /* Corrected bulge value  - add 6.25% (1/16) if bulge factor > .2189, */
    /* else add 1.56% (1/64)  */
    if (bulge_factor > .2189)
        abvbul *= 1.0625;
    else
        abvbul *= 1.015625;
    iabvbul = (fix31)(abvbul / tolerance);

    for (split_shift=0; iabvbul != 0;  iabvbul = iabvbul>>2, split_shift++);
    *split_count = i_pow ((fix31) 2, (fix31) split_shift);
   /* Allocate space for 2**n + 1 vectors */
    assert((*vectr = (vector_data *) alloc((ufix32)(*split_count + 1) *
                                            sizeof(vector_data))) != NULL);
    if (!put_vectors (&arc, bulge_factor, *vectr, *split_count, split_shift))
        {
        printf("\n*** Arc splitting failed!\n");
        return(FALSE);
        }
    return(TRUE);
    END

FUNCTION  static  bool  put_vectors (arc, bulge_factor, vectr,
                                            split_count, split_shift)
  arc_data     *arc;            /* arc endpoints */
  float         bulge_factor;
/*  float         chord_length; */
  vector_data  *vectr;          /* pointer to array of vector structures */
  fix31         split_count;    /* number of vectors created */
  fix15         split_shift;    /* nbr of splittings = log2(split_count)  */

/* PUT_VECTORS
 *   INPUT PARAMETERS:  arc, bulge_factor, split_count, split_shift
 *   OUTPUT PARAMETERS: vectr - a group of 2**N + 1 points
 *   X-Y coordinates are stored in an array of structures
 *     vectr[0], ... , vectr[split_count]
 *   CALLED BY:  ARC_TO_VECTS
 */

    DECLARE
    float       bufa[20];       /* bulge factors */
/*     float       chle[20]; */
    fix31       ii;
    fix15       n1, n2, n3;
    fix31       stack[20];
    fix15       stack_ptr;

    BEGIN
    bufa[0] = bulge_factor;
/*    chle[0] = chord_length; */
    for (ii=0; ii<=split_shift; ii++)   /* bulge factors are precomputed */
        {
        bufa[ii+1] = (sqrt((double)(1. + bufa[ii] * bufa[ii])) - 1.) / bufa[ii];
/*         chle[ii+1] = sqrt((double)(1. + bufa[ii] * bufa[ii])) * chle[ii] / 2.; */
        }
/*printf("\n");*/
/*for (ii=0; ii<split_shift; ii++)*/
/* printf("%2d. bulge factor, chord length = %.6f  %.3f\n", ii, bufa[ii], chle[ii]);*/
    vectr[0].xx = arc->x1;
    vectr[0].yy = arc->y1;
    vectr[0].level = 0;
    vectr[split_count].xx = arc->x2;
    vectr[split_count].yy = arc->y2;
    vectr[split_count].level = 0;
    if (split_count == 1)  return(TRUE);

    /* This section computes 'split_count' vectors */
    /* split_count must be a power of 2 for this algorithm to work */
    stack_ptr = 2;
    stack[0] = 0;
    stack[1] = split_count;
    while(stack_ptr >= 2)
        {
        if ((ii = stack[stack_ptr - 1]) % 2  ==  0)
            {
            stack[stack_ptr - 1] = stack[stack_ptr - 2];
            stack[stack_ptr - 2] = ii;
            stack[stack_ptr] =
                    (stack[stack_ptr - 1] + stack[stack_ptr - 2]) / 2;
            stack_ptr++;
            }
        else
            {
            stack_ptr -= 2;
            if (stack_ptr < 2)
                break;

            stack[stack_ptr] =
                   (stack[stack_ptr - 1] + stack[stack_ptr - 2]) / 2;
            stack_ptr++;
            }

        n1 = stack[stack_ptr - 2];      /* Find midpoint */
        n2 = stack[stack_ptr - 1];
        n3 = stack[stack_ptr - 3];
      /* '.level' tells which bulge factor to use */
        vectr[n2].level = MAX (vectr[n1].level, vectr[n3].level) + 1;
        vectr[n2].xx = .5 * (vectr[n1].xx + vectr[n3].xx -
                       bufa[vectr[n2].level - 1] * (vectr[n3].yy - vectr[n1].yy) );
        vectr[n2].yy = .5 * (vectr[n1].yy + vectr[n3].yy +
                       bufa[vectr[n2].level - 1] * (vectr[n3].xx - vectr[n1].xx) );
        }

    if (stack_ptr != 1  ||  stack[0] != split_count)
        {
        printf("Impossible state, stack has %d elements\n  ", stack_ptr);
        for (ii=0; ii<stack_ptr; ii++)
            printf("%6ld ", stack[ii]);
        printf("\n");
        return(FALSE);
        }
    return(TRUE);
    END
