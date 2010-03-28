class implementation COcctform;

/*
 *   Filename:   COcct_hls.I   
 *   Programmer:   C. M. Jablonski
 *   Creation Date:   January 1989
 *
 *   This file contains the actions that translate between RGB and HLS values:
 *
 *   (intensity)   - determines a color value from the given hue
 *
 *   (rgb_to_hls)   - translates RGB into HLS values
 *
 *   (rgb_from_hls)   - translates HLS into RGB values
 *
 *   History:
 *        scw 06/23/92  Added static ANSI C prototypes
 */


#include <stdio.h>
#include "dpgraphics.h"
#include "cct.h"

%safe
/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static double intensity __((double n1, double n2, double hue));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe

#define MAX( x, y )   (x > y) ? (x) : (y)
#define MIN( x, y )   (y > x) ? (x) : (y)


/*----- intensity ------------------------------------------------------------*/
static double intensity( 
   double   n1,
   double   n2,
   double   hue )

/*
ABSTRACT
   Intensity determines a color value from the given hue.

PARAMETERS
   n1 (in):      value 0.0 to 2.0
   n2 (in):      value 0.0 to 2.0
   hue (in):      hue range 0.0 to 360

RETURN VALUES
   an intensity value of a gun between 0.0 and 255.0

HISTORY:   01/11/88  Created.         C. M. Jablonski
*/

{
   if (hue < 0.0)
   {
      hue += 360.0;
   }
   else if (hue > 360.0)
   {
      hue -= 360.0;
   }

   if (hue < 60.0)
   {
      return( n1 + (((n2 - n1) * hue) / 60.0) );
   }
   else if (hue < 180.0)
   {
      return( n2 );
   }
   else if (hue < 240.0)
   {
      return( n1 + (((n2 - n1) * (240.0 - hue)) / 60.0) );
   }
   else
   {
      return( n1 );
   }
}

/*----- rgb_to_hls -----------------------------------------------------------*/
void rgb_to_hls ( 
   double   red,
   double   green,
   double   blue,
   double   *hue,
   double   *luminance,
   double   *saturation )

/*
ABSTRACT:
   rgb_to_hls updates the active HLS values by recalculating
   from the active RGB values.
   The values of hue, luminance, and saturation are not changed
   in the case of luminance = 1.0 or 0.0 or any case when 
   sat = 0.0 since this removes information.  Therefore the 
   paramaters should be initialized to be valid or check for the
   above cases.
PARAMETERS
   red (in):      value range 0.0 to 1.0
   green (in):      value range 0.0 to 1.0
   blue (in):      value range 0.0 to 1.0
   hue (out):      value range 0.0 to 359.99
   luminance (out):   value range 0.0 to 1.0
   saturation (out):   value range 0.0 to 1.0

HISTORY:   01/11/88  Created.         C. M. Jablonski

*/

{
double   max, min, max1, min1, rc, gc, bc;

   max1 = MAX( red, green );
   max = MAX( max1, blue );

   min1 = MIN( red, green );
   min = MIN( min1, blue );

   /* calculate luminance */
   *luminance = (max + min) / (2.0);

   /* calculate saturation */
   if ((*luminance > 0.0) && (*luminance < 1.0))
   {
      /* only calculate hue and sat if luminance is not an extreme. */
      /* otherwise it forces the hue and sat to 0 and loses the hue */
      /* and sat data to draw cross hairs and fill values.          */
      if (max == min)
      {
         /* red = green = blue : achromatic case */
         *saturation = 0.0;
      }
      else
      {
         if (*luminance <= 0.5)
         {
            *saturation = (max - min) / (max + min);
         }
         else
         {
            *saturation = (max - min) / (2.0 - max - min);
         }
   
         /* calculate hue */
         rc = (max - red) / (max - min);
         gc = (max - green) / (max - min);
         bc = (max - blue) / (max - min);
   
         if (max == red)
         {
            *hue = bc - gc;
         }
         else if (max == green)
         {
            *hue = 2.0 + rc - bc;
         }
         else
         {
            *hue = 4.0 + gc - rc;
         }
   
         *hue *= 60.0;
         if (*hue < 0.0) *hue += 360.0;
      }
   }

}

/*----- rgb_from_hls -----------------------------------------------------------*/
void rgb_from_hls ( 
   double   *red,
   double   *green,
   double   *blue,
   double   hue, 
   double   luminance,
   double   saturation )

/*
ABSTRACT:
   rgb_from_hls updates the active RGB values by recalculating
   from the active HLS values.

PARAMETERS
   red (out):      value range 0.0 to 1.0
   green (out):      value range 0.0 to 1.0
   blue (out):      value range 0.0 to 1.0
   hue (in):      value range 0.0 to 359.99
   luminance (in):      value range 0.0 to 1.0
   saturation (in):   value range 0.0 to 1.0

HISTORY:   01/11/88  Created.         C. M. Jablonski
*/

{
double   m1, m2;

   if (luminance <= 0.5)
   {
      m2 = luminance * (saturation + 1.0);
   }
   else
   {
      m2 = luminance + saturation - (luminance * saturation);
   }

   m1 = (2.0 * luminance) - m2;

   if (saturation == 0.0)
   {
      /* achromatic case */
      *red = *green = *blue = luminance;
   }
   else
   {
      /* chromatic case */
      *red = intensity( m1, m2, hue + 120.0 );
      *green = intensity( m1, m2, hue );
      *blue = intensity( m1, m2, hue - 120.0 );
   }

}

end implementation COcctform;

