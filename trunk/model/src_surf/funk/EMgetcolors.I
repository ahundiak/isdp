/* ###################   APOGEE COMPILED   ################## */
class implementation Root;

#include "EMS.h"
#include <stdio.h>
#include "wl.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdef.h"
#include "igewindef.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "igecolmacros.h"
#include "msdef.h"
#include "emsdef.h"
#include "emserr.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bstagsorti.h"

#define RESERVE_BITS    0x3fffffff
#define MAXVALUE 65535

%safe
static int pp_rgb_to_hsv();
%endsafe

/*
Abstract
    This function returns the number of active colors and their indexes
    sorted from low to high intensity. Blue being the lowest, then green,
    and then red the highest.


Arguments
    IGRint EMget_colors(msg, num_of_colors, color)

    IGRlong  *msg            return code.

    IGRint   *num_of_colors  output the number of active colors.

    IGRint   **color         output an array of color indexes sorted from
                             low to high intensity.


Notes

Files
    EMgetcolors.I


History
    dhm    12/28/88    creation date.
    pp     09/28/89    Modified the code to sort colors based on hue.
    pp     02/14/89    If the number of colors > 12 then we just choose
                       the first twelve colors.
    NP     08/27/92    Modified for ANSI compliance.
    Sudha  07/06/93    Modified for BSprototypes ansification
*/

IGRint EMget_colors(msg, num_of_colors, color)
IGRlong  *msg;
IGRint   *num_of_colors;
IGRint   **color;

{
  IGRlong     msg_loc;
  IGRshort    i, j, num_colors;
  IGRint      *rgb;
  IGRdouble   r,g,b,h,s,v;
  struct IGEvlt rgb_value;
  IGRboolean  sts;

  *msg = MSSUCC;
  rgb = NULL;

  /*
   * Get the color table of the screen.
   */

  ige$get_num_active_colors(num_colors = &num_colors);

  if (num_colors > 12) num_colors = 12;

  *num_of_colors = (IGRint) num_colors;

  /*
   * Allocate memory.
   */

  rgb = (IGRint *) om$malloc(size = num_colors * sizeof(IGRint) );
  EMerr_hndlr(!rgb, *msg, MSNOMEM, ret_end);

  *color = (IGRint *) om$malloc(size = num_colors * sizeof(IGRint) );
  EMerr_hndlr(!(*color), *msg, MSNOMEM, ret_end);

  /*
   * Get the red, green, blue gun intensities of the colors.
   */

  for (i = 1; i <= num_colors; i++)
  {
    ige$get_rgb_value(log_color = i,
                      flags = 0,
                      rgb_value = &rgb_value);

    
    r = rgb_value.red;
    g = rgb_value.green;
    b = rgb_value.blue;
    pp_rgb_to_hsv(r,g,b,&h,&s,&v);
    rgb[i-1] = h;

/*
    rgb[i-1] = rgb_value & RESERVE_BITS;
*/
  }
  /*
   * Sort the intensities and return the color numbers sorted from
   * low to high intensities.
   */

  BStagsorti(num_of_colors, rgb, *color, &msg_loc);
  EMerr_hndlr(msg_loc != BSSUCC, *msg, MSFAIL, ret_end);

  /*
   * The color indexes start at 1, not 0.  Therefore, I need to
   * add 1 to each index BStagsorti returned. The above sorting has been done
   * so that the color with the lowest is first. We need to reverse this to
   * enable color with the highest hue be the first color.
   */

  for (i=0;i<num_colors;i++)
   rgb[i] = color[0][i] + 1;

  for (i = 0,j=num_colors-1; i < num_colors; i++,j--)
     color[0][i] = rgb[j];
  
ret_end:
    if (rgb)
     om$dealloc(ptr = rgb);
    return(OM_S_SUCCESS);
}

static int pp_rgb_to_hsv(r,g,b,hue,sat,value)
IGRdouble r,g,b;
IGRdouble *hue, *sat, *value;
/* 
 * This function transforms RGB point to HSV point.
 */
{
  IGRdouble max,min,rc,gc,bc;
  IGRlong msg_loc, zerotol;

  max = 0;
  min = 0;

  BSEXTRACTPAR(&msg_loc,BSTOLCLOSETOZERO,zerotol);

  r = r/MAXVALUE;
  g = g/MAXVALUE;
  b = b/MAXVALUE;

  if (r > max) max = r;
  if (g > max) max = g;
  if (b > max) max = b;
  if (r < min) min = r;
  if (g < min) min = g;
  if (b < min) min = b;

  *value = max;

  if ((max - 0.0) > zerotol)
   *sat = (max - min)/max;
  else
   *sat = 0;
  
  if ((*sat - 0) < zerotol)
    *hue = -1;
  else
  {
   rc = (max - r)/(max - min);
   gc = (max - g)/(max - min);
   bc = (max - b)/(max - min);

   if (r == max)  *hue = bc - gc;
   else if (g == max) *hue = 2 + rc - bc;
   else if (b == max) *hue = 4 + gc - rc;

   (*hue) *= 60;

   if (*hue < 0) (*hue) = (*hue) + 360;
  } 
 return;
 }
end implementation Root;
