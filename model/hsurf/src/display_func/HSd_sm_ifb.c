
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

/*  Apogee compliant  */

#include "igrtypedef.h"
#include "igr.h"

#include "hsmath.h"
#include "HStl_global.h"
#include "HStl_window.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HSd_macramp.h"

#include "HSpr_display.h"


#define FILL_UP( y )	{ }

/*---HSsmooth_shade_ifb--------------------------------------------------------*/

/*
NAME
   HSsmooth_shade_ifb
   
KEYWORDS
   RASTERIZER
   RAMPS
   IFB
   
DESCRIPTION
   Given a trapezoid structure, make per-scanline calls to the
   IFB function sh_zbufshadeline, for smooth shaded, opaque
   display
   
ARGUMENTS
   trap: (IN): trapezoid structure
   
HISTORY
   ??/??/??      M. Lanier
      Created
*/

void HSsmooth_shade_ifb( struct trapezoid *trap )

    {
    int			rxa, rxb, dxa, dxb;
    int			rsa, rsb, dsa, dsb;
						
    int			dxc;		
    int			rsc, rsd, dsc;	
    int			dx, dy;		
						
    struct HSfixedpt	rza, rzb, rzc;	
						
    register int		y;		
    register int		xleft, xright;	

    MIN_MAX_TEST

    /*
     *  Scale the shade.  NOTE what should be done is divide by 255 and shift left 16.  
     *  The "<< 8" implies a division by 256 and shift by 16, which has a small error.  
     *  You could be as much as a shade off.
     */

    rsa = ( (trap->shade2 ^ 0xff) * tiling_parms.apparent_shades ) << 8;
    rsb = ( (trap->shade3 ^ 0xff) * tiling_parms.apparent_shades ) << 8;
    rsc = ( (trap->shade0 ^ 0xff) * tiling_parms.apparent_shades ) << 8;
    rsd = ( (trap->shade1 ^ 0xff) * tiling_parms.apparent_shades ) << 8;

    CALC_DXDY_DZDY_DSDY
	
    for( y=trap->yb; y < trap->ya; y++ )
        {
        INIT_SHADE_VARIABLES
        INIT_Z_VARIABLES
        INIT_X_VARIABLES

        CALC_DZ_DX
        CALC_DSHADE_DX
 
        sh_zbufshadeline( 
                active_window->hwin_no,
                y,
                xleft, xright,
                rzc.active, 0,
                rzc.d_whole * rzc.sign,
                rzc.d_fract,
                rsc, dsc, 
                y == trap->ya || y == trap->yb ? 0x7fffffff : 0x00000001 );
			
        MOVE_TO_NEXT_ROW_SHADING
	
        }
    }
#else
void HSsmooth_shade_ifb( struct trapezoid *trap )
   {
   printf( "STUB: HSsmooth_shade_ifb\n" );
   }
#endif
