#include <stdio.h>
#include <stdlib.h>

#include "igrtypedef.h"
#include "igr.h"
#include "exsysdep.h"
#include "HStl_window.h"
#include "hplot.h"
#include "HPdef.h"
#include "HPmacros.h"
#include "HPglobal.h"
#include "hpmsg.h"

/*------------------------------
 *  for function
 *     HSconv_double
 *     HSconv_int
 *     HSconv_short
 */

#include "HSrle.h"
#include "hsanimate.h"
#include "HSpr_rle_uti.h"

/*------------------------------*/

static struct HPsoo_info *soo_buffer = NULL;
static int soo_buffer_size = 0;

/*---HPread_curve_soo-------------------------------------------------------_*/

/*
NAME
    HPread_curve_soo
        
KEYWORDS
    HSplot
    overrides
        
DESCRIPTION
    read the curve overrides from the shaded plot file
        
PARAMETERS
    file_ptr    :(IN) :  File pointer for the shaded plotfile
    num_soos    :(OUT):  Number of overrides read for the curve
    soos        :(OUT):  Array of overrides read for the curve

FUNCTIONS CALLED
    fread
    HSconv_int (Sun only)
    HSconv_double (Sun only)
    HSconv_short (Sun only)
    free
    malloc
                
HISTORY
    ??/??/??    M. Lanier
        Created
*/

IGRint HPread_curve_soo( FILE *file_ptr,
                       IGRint *num_soos,
            struct HPsoo_info **soos )

   {
   IGRlong                status;
   IGRint                 i, new_soo;
   static HPsimple_union  simple;


   status = fread( &i,
                   sizeof(IGRint),
                   1,
                   file_ptr );

#  ifdef BIG_ENDIAN
   HSconv_int (&i, 1);
#  endif

   /*
    *  save the value in num_soos.  if 0 then we are reading pre 3.0
    *  soos, else reading 3.0+ soos
    */
    
   new_soo = *num_soos;
   
   *num_soos = i;

   if( *num_soos > soo_buffer_size )
      {
      if( soo_buffer != NULL )
          free (soo_buffer);

      soo_buffer = (struct HPsoo_info *)malloc( sizeof(struct HPsoo_info) * *num_soos );

      soo_buffer_size = *num_soos;
      }

   *soos = soo_buffer;

   for( i=0; i<(*num_soos); i++ )
      {

      /* get the u parameters that are the endpoints of the soo */

      status = fread (&simple.f64,
                      sizeof(simple.f64),
                      1,
                      file_ptr );

#     ifdef BIG_ENDIAN
      HSconv_double( &simple.f64, 1 );
#     endif

      soo_buffer[i].parms[0] = simple.f64;

      status = fread( &simple.f64,
                      sizeof(simple.f64),
                      1,
                      file_ptr );

#     ifdef BIG_ENDIAN
      HSconv_double( &simple.f64, 1 );
#     endif

      soo_buffer[i].parms[1] = simple.f64;

      /* get the color, style and weight of the soo */

      status = fread( &simple.u16,
                      sizeof(simple.u16),
                      1,
                      file_ptr );

#     ifdef BIG_ENDIAN
      HSconv_short( (short *)(&simple.u16), 1 );
#     endif

      soo_buffer[i].color = simple.u16;

      status = fread (&simple.u8,
                      sizeof (simple.u8),
                      1,
                      file_ptr);

      soo_buffer[i].style = simple.u8;

      status = fread (&simple.u8,
                      sizeof (simple.u8),
                      1,
                      file_ptr);

      soo_buffer[i].weight = simple.u8;

      if( new_soo == 1 )
         {
         status = fread (&simple.u16,
                         sizeof (simple.u16),
                         1,
                         file_ptr);

#        ifdef BIG_ENDIAN
         HSconv_short( (short *)(&simple.u16), 1 );
#        endif

         soo_buffer[i].type = (unsigned short)simple.u16;
         }
      else
         {
         soo_buffer[i].type = 0;
         }
      }

   return HSplot_success;
   }

