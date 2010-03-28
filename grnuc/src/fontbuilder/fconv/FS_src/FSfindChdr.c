/******************************************************************************

                             FILE:  FSfindChdir.c

                              FSfindChardir()


   This routine return a pointer to the the bitstream character directory
   structure if one exists.  The bitstream character id "bits_char" or the
   adobe logical character name "char_name" is passed to this routine. if a
   char_name is set to NULL, then the bits_char id is used for the search.
   if a NULL bitstream id is passed in bits_char, then char_name is used for
   the search. All bitstream character ids are greater than zero.

                        R E V I S I O N   H I S T O R Y 

	(0)	4-NOV-87 sew : creation
        (1)     5-AUG-88 sew : renamed FSgetChdirPtr

 *****************************************************************************/

/*
$Log: FSfindChdr.c,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:22  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:29:35  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:58:36  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:50:58  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:29:24  root
 * COMMENT : Corresponds to Rel201.3 in 2.0.1 RCS
 *
 * Revision 201.3  1992/07/13  20:41:56  tim
 * COMMENT : added Log variable
 *
*/


#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "FFdef.h"
#include "FFstructs.h"
#include "FFerrdef.h"



FSfindChardir( chdir_dat, end_chdir, chdir_ptr, bits_char, char_name )

        cft_chardir_rec *chdir_dat, *end_chdir, **chdir_ptr;
	unsigned short   bits_char;
                 short  *char_name;
{
/*
                 int     sts;
*/
        unsigned short   bits_id, UTmapCharName();
	cft_chardir_rec *lo, *hi, *mid;

   bits_id = bits_char;
   if ( (bits_char <= 0) && (char_name) ) {
      bits_id = TXmapCharName(char_name, ADOBE_CHARS, BITSTREAM_CHARS);
      if ( ! bits_id ) bits_id = bits_char;
      }

   if (bits_id == 0) {
      *chdir_ptr = NULL;
      return( 0 );
      }

   if (bits_id > 0) {
       lo    = mid = chdir_dat;
       hi    = end_chdir;
       mid  += (int)((hi - lo) / 2);
       while(((mid->char_id == 0) || (mid->char_id == -1)) && (mid < hi)) mid++;
       if (mid == hi) {
          mid  += (int)((hi - lo) / 2);
          while(((mid->char_id == 0) || (mid->char_id == -1))
              && (mid > lo)) mid--;
          if (mid == lo) {
             *chdir_ptr = NULL;
             return( WARN );
             }
          }

       while( lo < hi ) {

          if ( mid->char_id == bits_id ) break;
          
          if ( (mid->char_id > bits_id) && (mid != lo) && (mid != hi) ) {
              hi = mid;
     	      if ((int)(hi - lo) > 1) mid -= ((int)(hi - lo) / 2);
              if (mid->char_id == 0) {
                 while((mid->char_id == 0) && (mid < hi)) mid++;
                 if (mid == hi) {
     	            if ((int)(hi - lo) > 1) mid -= ((int)(hi - lo) / 2);
                    while((mid->char_id == 0) && (mid > lo)) mid--;
                    if (mid == lo)
                       break;
                    }
                 }
              }
            else if ( (mid->char_id < bits_id) && (mid != hi) && (mid != lo) ) {
       	      lo = mid;
       	      if ((int)(hi - lo) > 1) mid += ((int)(hi - lo) / 2);
              if (mid->char_id == 0) {
                 while((mid->char_id == 0) && (mid < hi)) mid++;
                 if (mid == hi) {
                    if ((int)(hi - lo) > 1) mid += ((int)(hi - lo) / 2);
                    while((mid->char_id == 0) && (mid > lo)) mid--;
                    if (mid == lo)
                       break;
                    }
                 }
       	      }
           else if ( (mid->char_id != bits_id) && (mid == lo) ) {
       	      lo++;
       	      mid++;
       	      }
            else if( (mid->char_id != bits_id) && (mid == hi) ) {
       	      hi--;
       	      mid--;
       	      }
          }
       }
       

   if (mid->char_id == bits_id) {
      *chdir_ptr = mid;
      return( FF_S_SUCCESS );
      }
    else {
      *chdir_ptr = NULL;
      return( WARN );
      }
 
}
