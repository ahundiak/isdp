
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

/*  Apogee compliant */

#include "igrtypedef.h"
#include "igr.h"

#include "hsmath.h"
#include "HStl_window.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HSd_macramp.h"

#include "HSpr_display.h"

#define	FILL_UP( y )	{ }

/*---HSarea_fill_ifb--------------------------------------------------------*/

/*
NAME
        HSarea_fill_ifb
        
KEYWORDS
        RASTERIZER
        RAMPS
        IFB
        
DESCRIPTION
        Given1 a trapezoid, make per-scanline calls to the IFB function
        sh_zbufshadeline to complete the rasterization, and display
        the trapezoid
        
ARGUMENTS
        tile: (IN): trapezoid structure containing the trapezoid to
                    rasterize
        
HISTORY
        ??/??/??	M. Lanier
                Created
*/

void HSarea_fill_ifb (struct trapezoid * trap)

    {
    int rxa, rxb, dxa, dxb;

    int dxc;
    int dy;

    struct HSfixedpt rza, rzb, rzc;

    register int y;
    register int xleft, xright;

    MIN_MAX_TEST

    CALC_DXDY_DZDY

    for (y = trap->yb; y < trap->ya; y++)
        {
        INIT_Z_VARIABLES
        INIT_X_VARIABLES
        CALC_DZ_DX

        sh_zbufshadeline( active_window->hwin_no,
                          y,
                          xleft, xright,
                          rzc.active, 0,
                          rzc.d_whole * rzc.sign,
                          rzc.d_fract,
                          0, 0,
                          0xffffffff );

        MOVE_TO_NEXT_ROW
        }
    }
#else
void HSarea_fill_ifb (struct trapezoid * trap)
   {
   printf( "STUB: HSarea_fill_ifb\n" );
   }
#endif
