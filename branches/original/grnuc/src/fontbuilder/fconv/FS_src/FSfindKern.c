/******************************************************************************

                             FILE:  FSKernPr.c

                              FSfindKernPair()


   This routine returns a pointer to the the bitstream kernpair record
   structure if one exists.  The character ids "char_id1 and char_id2", and
   the number of kern pair records are passed to this routine.
   All bitstream and Publisher character ids are greater than zero.

                        R E V I S I O N   H I S T O R Y 

	(0)	26-JAN-88 sew : creation
	(0)	05-AUG-88 sew : changed name to FSgetKernPair

 *****************************************************************************/

/*
$Log: FSfindKern.c,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:23  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:29:36  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:58:37  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:51:01  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:29:27  root
 * COMMENT : Corresponds to Rel201.3 in 2.0.1 RCS
 *
 * Revision 201.3  1992/07/13  20:41:58  tim
 * COMMENT : added Log variable
 *
*/


#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "FFstructs.h"

FSfindKernPair( knpr_dat, num_pairs, char_id1, char_id2, knpr_ptr )

        cft_kern_pair_rec *knpr_dat, **knpr_ptr;
	unsigned short     num_pairs, char_id1, char_id2;
{
	cft_kern_pair_rec *lo, *hi, *mid, *prev;

    lo    = hi = mid = knpr_dat;
    hi   += (int)num_pairs - 1;
    mid  += (int)((hi - lo) / 2);
    prev  = mid;
    if (prev > lo) prev--;
    while((mid->char1 == prev->char1) && (prev != lo)) {
    	mid--;
    	prev--;
        }

    if ((prev == lo) && (lo->char1 == mid->char1)) mid--;
    
    while( (lo < hi) && (mid->char1 != char_id1) ) {

       if ( mid->char1 == char_id1 ) break;
          
       if ( (mid->char1 > char_id1) && (mid != lo) && (mid != hi) ) {
           hi = mid;
	   if ((int)(hi - lo) > 1)
	      mid -= ((int)(hi - lo) / 2);
           }
         else if ( (mid->char1 < char_id1) && (mid != hi) && (mid != lo) ) {
       	   lo = mid;
       	   if ((int)(hi - lo) > 1)
       	      mid += ((int)(hi - lo) / 2);
       	   }
        else if ( (mid->char1 != char_id1) && (mid == lo) ) {
       	  lo++;
          mid++;
      	  }
        else if( (mid->char1 != char_id1) && (mid == hi) ) {
       	  hi--;
          mid--;
      	  }
       }
       
   prev = mid;
   if (prev > lo) prev--;
   while((mid->char1 == prev->char1) && (mid != lo)) {
      mid--;
      prev--;
      }
      
   while( (mid->char2 != char_id2) && (mid->char1 == char_id1) && (mid != hi))
      mid++;

   if ((mid->char1 == char_id1) && (mid->char2 == char_id2)) {
      *knpr_ptr = mid;
      return( (int)mid->adjustment );
      }
    else {
      *knpr_ptr = NULL;
      return( 0 );
      }
}
