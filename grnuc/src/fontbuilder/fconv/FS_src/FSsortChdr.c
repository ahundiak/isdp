/******************************************************************************

                            FILE:  FSsort_chr.c

                               FSsort_chdirs()

    These functions sorts bitstream character directories for binary searches.

                        R E V I S I O N   H I S T O R Y 

	(0)	14-MAR-88 sew : creation

 *****************************************************************************/

/*
$Log: FSsortChdr.c,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:26  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:29:40  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:58:40  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:51:13  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:29:36  root
 * COMMENT : Corresponds to Rel201.3 in 2.0.1 RCS
 *
 * Revision 201.3  1992/07/13  20:42:07  tim
 * COMMENT : added Log variable
 *
*/

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "FFdef.h"
#include "FFstructs.h"
#include "FFerrdef.h"

void FSsortCharDirs(beg_chdir, num_chars)

	cft_chardir_rec *beg_chdir;
        unsigned short   num_chars;
{
               int              count, ii, jj, kk, ss, ww;
	       cft_chardir_rec  temp;
        static int aa[] = { 9, 5, 3, 3, 1 };

   count = (int)num_chars;
   for(ww = 0; ww < 5; ww++ ) {
      kk = aa[ww];
      ss = -kk;
      for ( ii = kk; ii <= count; ++ii) {
         temp.set_width    = beg_chdir[ii].set_width;
         temp.outline_offs = beg_chdir[ii].outline_offs;
         temp.char_id      = beg_chdir[ii].char_id;
         jj = ii - kk;
         if ( ss == 0 ) {
            ss = -kk;
            ss++;
            beg_chdir[ss].set_width    = temp.set_width;
            beg_chdir[ss].outline_offs = temp.outline_offs;
            beg_chdir[ss].char_id      = temp.char_id;
            }

         while(  (temp.char_id < beg_chdir[jj].char_id)
              && (jj >= 0)
              && (jj <= (count + 1)) ) {
            beg_chdir[jj + kk].set_width    = beg_chdir[jj].set_width;
            beg_chdir[jj + kk].outline_offs = beg_chdir[jj].outline_offs;
            beg_chdir[jj + kk].char_id      = beg_chdir[jj].char_id;
            jj = jj - kk;
            }
            
         beg_chdir[jj + kk].set_width    = temp.set_width;
         beg_chdir[jj + kk].outline_offs = temp.outline_offs;
         beg_chdir[jj + kk].char_id      = temp.char_id;
         }
      } 
}
