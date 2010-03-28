/******************************************************************************

                             File: FSsortKern.c   

                               FSsortKernTbl()

                        R E V I S I O N    H I S T O R Y

	(0) 27-MAY-1987 sew : Creation
        (1)  2-OCT-1987 sew : converted routine to sort compressed file format.

   ---------------------------------------------------------------------------

   FSsortKernTbl( knpr_dat, num_pairs )

	cft_kern_pair_rec *knpr_dat;   beginning of the kern pair buffer
        unsigned short     num_pairs;  number of kern pairs in buffer

   This routine makes sure that all kern pairs are sorted by primary ID and 
   secondary ID.  Some bitstream files were delivered unsorted.  This routine
   is needed so that a binary search can be performed.


   return status:

     0 - kern pairs were already sorted.
     1 - kern pairs were sorted.

******************************************************************************/

/*
$Log: FSsortKern.c,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:27  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:29:41  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:58:41  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:51:16  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:29:39  root
 * COMMENT : Corresponds to Rel201.3 in 2.0.1 RCS
 *
 * Revision 201.3  1992/07/13  20:42:08  tim
 * COMMENT : added Log variable
 *
*/

#include "FFstructs.h"

void FSsortKernTbl( knpr_dat, num_pairs )

	cft_kern_pair_rec *knpr_dat;  /* beginning of the kern pair buffer  */
        unsigned short     num_pairs; /* number of kern pairs in buffer     */

{

	cft_kern_pair_rec *lo_pair,   /**hi_pair,*/ *next_pair, *end_pair;
        void               FSquicksort_pairs();

   lo_pair  = next_pair = knpr_dat;
   end_pair = knpr_dat + (int)num_pairs - 1;
   next_pair++;

   FSquicksort_pairs(knpr_dat, end_pair, 0);

   lo_pair = next_pair = knpr_dat;
   while (lo_pair <= end_pair) {
      for ( ;(lo_pair->char1 == next_pair->char1)&&(next_pair < end_pair);)
           next_pair++;

      if (next_pair->char1 != lo_pair->char1) next_pair--;
      if ((lo_pair < next_pair) && (lo_pair < end_pair)) {
          FSquicksort_pairs(lo_pair, next_pair, 1);
          next_pair++;
          }
        else {
          lo_pair++;
          next_pair = lo_pair;
          }

      lo_pair = next_pair;
      }
}




void FSquicksort_pairs(beg_pair, end_pair, index)

	cft_kern_pair_rec  *beg_pair, *end_pair;
        int                index;

{
	cft_kern_pair_rec *lo_pair, *hi_pair, temp_pair;
        int                mid_val, count;
        void               FSquicksort_pairs();

   for (   lo_pair = beg_pair, count = 0, mid_val = 0;
           lo_pair < end_pair;
           lo_pair++, count++) {
      if ( index == 0 )
          mid_val = mid_val + (int)lo_pair->char1;
        else
          mid_val = mid_val + (int)lo_pair->char2;
      }

   mid_val  = mid_val / count;
   lo_pair  = beg_pair;

   hi_pair  = end_pair;
   do {
      if ( index == 0 )
          while ((lo_pair->char1 < mid_val) && (lo_pair < end_pair))
             lo_pair++;
        else
          while ((lo_pair->char2 < mid_val) && (lo_pair < end_pair))
             lo_pair++;

      if ( index == 0 )
          while ((mid_val < hi_pair->char1) && (hi_pair > beg_pair))
             hi_pair--;
        else
          while ((mid_val < hi_pair->char2) && (hi_pair > beg_pair))
             hi_pair--;

      if (lo_pair < hi_pair) {
          temp_pair.char1      = lo_pair->char1;
          temp_pair.char2      = lo_pair->char2;
          temp_pair.adjustment = lo_pair->adjustment;
          lo_pair->char1       = hi_pair->char1;
          lo_pair->char2       = hi_pair->char2;
          lo_pair->adjustment  = hi_pair->adjustment;
          hi_pair->char1       = temp_pair.char1;
          hi_pair->char2       = temp_pair.char2;
          hi_pair->adjustment  = temp_pair.adjustment;
          lo_pair++;
          hi_pair--;
          }
        else if (lo_pair == hi_pair) lo_pair++;

      } while (lo_pair <= hi_pair);

   if (beg_pair < hi_pair)  FSquicksort_pairs(beg_pair, hi_pair, index);
   if (lo_pair  < end_pair) FSquicksort_pairs(lo_pair, end_pair, index);
}
