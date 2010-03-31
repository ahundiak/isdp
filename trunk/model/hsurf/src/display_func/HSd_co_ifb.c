
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:36 $
$Locker:  $
*/

#if defined (ENV5)

#include "stdlib.h"

/*  This function is a ramp rasterizer  */
/*  It is not WL converted  */

/*  Apogee compliant		*/

#include "igrtypedef.h"
#include "igr.h"

#include "hsmath.h"
#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HSd_macramp.h"

#include "HSpr_display.h"

#define FILL_UP( y )	{ }

/*---HSconstant_shade_ifb--------------------------------------------------------*/

/*
NAME
   HSconstant_shade_ifb

KEYWORDS
   RASTERIZER
   RAMPS
   IFB

DESCRIPTION
   Given a trapezoid structure, make per-scanline calls to
   sh_zbufshadeline for constant shaded display

ARGUMENTS
   trap: (IN): trapezoid structure containing the trapezoid to
               rasterize

HISTORY
   ??/??/??   M. Lanier
      Created
*/

void HSconstant_shade_ifb (struct trapezoid * trap)

    {
    int rxa, rxb, dxa, dxb;
    int shade;

    int dxc;
    int dy;

    struct HSfixedpt rza, rzb, rzc;

    register int y;
    register int xleft, xright;

    MIN_MAX_TEST

    shade = ((trap->shade0 ^ 0xff) * tiling_parms.apparent_shades) << 8;

    CALC_DXDY_DZDY

    for (y = trap->yb; y < trap->ya; y++)
        {
        INIT_Z_VARIABLES
        INIT_X_VARIABLES

        CALC_DZ_DX

        sh_zbufshadeline (
                  active_window->win_no,
                  y,
                  xleft, xright,
                  rzc.active, 0,
                  rzc.d_whole * rzc.sign,
                  rzc.d_fract,
                  shade, 0,
                  y == trap->ya || y == trap->yb ? 0x7fffffff : 0x00000001);

        MOVE_TO_NEXT_ROW

        }
    }
#else
void HSconstant_shade_ifb (struct trapezoid * trap)
   {
   printf( "STUB: HSconstant_shade_ifb\n" );
   }
#endif
