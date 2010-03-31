#ifdef X11
/*  HSbldphyctbl.c:  entry points for build_phys_tbl and color_comp.
 *
 *    build_phys_tbl:  given a physical table, the number of colors & shades,
 *      & the DAC size, this routine "builds" shades off the base colors.  In
 *      the colortable array, it is assumed that entry 0, colortable[0], is
 *      the 1st base color and that each base color is positioned 'num_shades'
 *      apart from each other.  This algorithm makes some attempt to adjust
 *      "equal step" colors so they will truly be distinct in the 4-bit DAC
 *      case.  This algorithm also uses color table calibration, & it makes
 *      use of the ambient light source intensity to determine the darkest
 *      shade.
 *
 *    HScolor_compensate:  returns a color-compensated intensity value, given
 *      an uncompensated intensity, or returns an uncompensated intensity
 *      value, given a color-compensated intensity.
 *
 *  Author:  D. H. Holmes				Date:  7/7/89
 */

#define	GAMMA 2.2
#define ONE 65535
#define D_ONE 65535.0
#define TRUE 1

#include <math.h>
#include <stdio.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"

#include "hsurf.h"
#include "hsmacdef.h"
#include "hsmacros.h"
#include "hslight.h"


extern Display *EXdisplay;
extern int EX_scr[];
struct vlt_slot
{
   unsigned long pixel;
   unsigned short red;
   unsigned short green;
   unsigned short blue;
   char flags;
   char pad;
};

/*
 * prototype files must be included afer all relevant structures are defined.
 */

#include "HSpr_co_func.h"


/*--------build_phys_tbl---------------------------------------------------*/

/* Given a color table with base colors already loaded into their          */
/*   appropriate locations, and given the number of colors, the number of  */
/*   shades, and the DAC size of the specific workstation in question,     */
/*   this routine generates a full shading table.  Color table calibration */
/*   and use of the ambient light source (to determine the darkest shade)  */
/*   are a part of the algorithm.                                          */

#if defined(__STDC__) || defined(__cplusplus)
	void X_build_phys_tbl( int num_colors,
			       int num_shades,
		   struct vlt_slot colortable[],
			       int  dac_size )
#else
	void X_build_phys_tbl(num_colors, num_shades, colortable, dac_size)

	int  num_colors,    /* the number of base colors */
	     num_shades;    /* the number of shades to build per base color */
	truct vlt_slot  colortable[];    /* array containing base colors when      */
                                    /*   routine is called, and containing a  */
                                    /*   full shade table upon return         */
	int  dac_size;    /* used to deal with 4-bit DAC case individually */
#endif

  {
    int  c,    /* color counter */
         color,    /* vlt slot index */
         i,    /* vlt slot index */
         num_steps,    /* count of number of 4-bit DAC steps */
         val;    /* temporary storage for intensity value */
    double  num_shd_minus_1,    /* num_shades - 1 */
            base_r, base_g, base_b,    /* base color intensities */
            range_r, range_g, range_b,    /* range of color intensities */
            step_r, step_g, step_b,    /* color intensity steps */
            rval, gval, bval,    /* color intensity values */
            amb_intens;    /* averaged ambient light color intensities */
    struct HS_light_source  ambient;
    int msg, calib_flag;

    if (num_shades < 2) return;

    num_shd_minus_1 = (double)(num_shades - 1);

    /* get color calibration flag */
    GRsetinqcolcal( &msg, 0, &calib_flag );
/*The following line is set purely for the purpose of testing . The line is to be 
removed if GRsetinqcolcal is implemented in X */


#ifdef X11
    calib_flag=1;
#endif
    hs$get_global_lights( ambient_light = &ambient );
    amb_intens = (double)(ambient.red + ambient.green + ambient.blue) / (3.0 * 255.0);

    for( c=1, color=0; c<=num_colors; c++, color += num_shades )
      {    /* for each base color: */
        base_r = ((double)(colortable[color].red)) / 65535.0;    /* get    */
        base_g = ((double)(colortable[color].green)) / 65535.0;  /*  base  */
        base_b = ((double)(colortable[color].blue)) / 65535.0;   /*  color */

        range_r = base_r - (amb_intens * base_r);    /* calculate range of   */
        range_g = base_g - (amb_intens * base_g);    /*   brightest shade to */
        range_b = base_b - (amb_intens * base_b);    /*   darkest shade      */

        step_r = range_r / num_shd_minus_1;    /* calculate step */
        step_g = range_g / num_shd_minus_1;
        step_b = range_b / num_shd_minus_1;

        rval = base_r - step_r;    /* calculate 1st shade after base color */
        gval = base_g - step_g;
        bval = base_b - step_b;

        for (i = (color + 1);  i < (color + num_shades); i++)
          {    /* for each shade after the base color: */
            colortable[i].red = (int)((rval * 65535.0) + 0.5);
            colortable[i].green = (int)((gval * 65535.0) + 0.5);
            colortable[i].blue = (int)((bval * 65535.0) + 0.5);
	    colortable[i].flags = DoRed | DoGreen| DoBlue;

            rval = rval - step_r;    /* calculate next shade */
            gval = gval - step_g;
            bval = bval - step_b;
          }
        if (dac_size < 8)    /* assumes DAC size is 4 */
          {
           if ( calib_flag )    /* compensate the color intensities */
              {
                for (i = (color + 1);  i < (color + num_shades); i++)
                  {    /* for each shade after the base color: */
                    colortable[i].red =
                        HScolor_compensate(colortable[i].red, 0);
                    colortable[i].green =
                        HScolor_compensate(colortable[i].green, 0);
                    colortable[i].blue =
                        HScolor_compensate(colortable[i].blue, 0);
                  }
              }
            num_steps = (int)(range_r * 16.0);
            if ((num_steps + 1) >= num_shades)    /* if have enough */
              {    /* shades, convert to 4-bit values & adjust downward     */
                colortable[color].red = colortable[color].red >> 12;

                for (i = (color + 1);  i < (color + num_shades); i++)
                  {    /* for each shade of red after the base color: */
                    colortable[i].red = colortable[i].red >> 12;
                    if (colortable[i-1].red <= colortable[i].red)
                        colortable[i].red = colortable[i-1].red - 1;
                  }
                for (i = color;  i < (color + num_shades); i++)
                  {    /* convert back to 16-bit value */
                    val = colortable[i].red;
                    colortable[i].red = (val << 12) + (val << 8) +
                                          (val << 4) + val;
                  }
              }
            num_steps = (int)(range_g * 16.0);
            if ((num_steps + 1) >= num_shades)    /* if have enough */
              {    /* shades, convert to 4-bit values & adjust downward     */
                colortable[color].green = colortable[color].green >> 12;

                for (i = (color + 1);  i < (color + num_shades); i++)
                  {    /* for each shade of green after the base color: */
                    colortable[i].green = colortable[i].green >> 12;
                    if (colortable[i-1].green <= colortable[i].green)
                        colortable[i].green = colortable[i-1].green - 1;
                  }
                for (i = color;  i < (color + num_shades); i++)
                  {    /* convert back to 16-bit value */
                    val = colortable[i].green;
                    colortable[i].green = (val << 12) + (val << 8) +
                                            (val << 4) + val;
                  }
              }
            num_steps = (int)(range_b * 16.0);
            if ((num_steps + 1) >= num_shades)    /* if have enough */
              {    /* shades, convert to 4-bit values & adjust downward     */
                colortable[color].blue = colortable[color].blue >> 12;

                for (i = (color + 1);  i < (color + num_shades); i++)
                  {    /* for each shade of blue after the base color: */
                    colortable[i].blue = colortable[i].blue >> 12;
                    if (colortable[i-1].blue <= colortable[i].blue)
                        colortable[i].blue = colortable[i-1].blue - 1;
                  }
                for (i = color;  i < (color + num_shades); i++)
                  {    /* convert back to 16-bit value */
                    val = colortable[i].blue;
                    colortable[i].blue = (val << 12) + (val << 8) +
                                           (val << 4) + val;
                  }
              }
              if ( calib_flag )  /* convert back to uncompensated values */
              {
                for (i = (color + 1);  i < (color + num_shades); i++)
                  {    /* for each shade after the base color: */
                    colortable[i].red =
                        HScolor_compensate(colortable[i].red, 1);
                    colortable[i].green =
                        HScolor_compensate(colortable[i].green, 1);
                    colortable[i].blue =
                        HScolor_compensate(colortable[i].blue, 1);
                  }
              }
          }
      }
  }
#endif
