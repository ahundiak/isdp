
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:36 $
$Locker:  $
*/

#if defined (ENV5)

#include "stdlib.h"

/*  This code makes calls to special IFB functions that  */
/*  display constant shaded trapezoids.  It uses ramps!!!  */

#include "igrtypedef.h"
#include "igr.h"

#include "hsmath.h"
#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"

#include "HSpr_display.h"


#define DEBUG	0


/*---HSzbuf_trap_ifb--------------------------------------------------------*/

/*
NAME
   HSzbuf_trap_ifb
   
KEYWORDS
   RASTERIZER
   RAMPS
   IFB
   
DESCRIPTION
   Given a trapezoid structure, , call the IFB function sh_trap
   to rasterize and display a constant shaded trapezoid
   
ARGUMENTS
   trap: (IN): trapezoid structure
   
HISTORY
   ??/??/??      M.Lanier
       Created
*/

void HSzbuf_trap_ifb( struct trapezoid *tile )

   {
   int			shade;
   int			dxa, dxb;
   struct HSfixedpt	rza, rzb;
   int			dx1, dx2, dy;

   if (tile->x0 < active_window->x_min) active_window->x_min = tile->x0;
   if (tile->x1 > active_window->x_max) active_window->x_max = tile->x1;
   if (tile->x2 < active_window->x_min) active_window->x_min = tile->x2;
   if (tile->x3 > active_window->x_max) active_window->x_max = tile->x3;

   if (tile->yb < active_window->y_min) active_window->y_min = tile->yb;
   if (tile->ya > active_window->y_max) active_window->y_max = tile->ya;

   if( element_parms.facet_type == AREA_FILL )
      shade = 0;
   else
      shade = ((tile->shade0 ^ 0xff) * tiling_parms.apparent_shades) >> 8;


   if( ( dy = tile->ya - tile->yb ) == 0 )
      {
      dxa = 0;
      dxb = 0;
		
      rza.sign = 1;
      rza.d_whole = 0;
      rza.d_fract = 0;
      }
   else
      {
      dxa = ( tile->x0 - tile->x2 ) / dy;
      dxb = ( tile->x1 - tile->x3 ) / dy;
		
      fixed_divide( (tile->z0 - tile->z2), 
                     dy, 
                     &rza.sign, 
                     &rza.d_whole, 
                     &rza.d_fract );
      }

   dx1 = (ROUND16(tile->x0)) - (ROUND16(tile->x1));
   dx2 = (ROUND16(tile->x2)) - (ROUND16(tile->x3));
	
   if( (dx1 + dx2) == 0 )
      {
      rzb.sign = 1;
      rzb.d_whole = 0;
      rzb.d_fract = 0;
      }
   else
      {
      if( (ABS(dx1)) >= (ABS(dx2)) )
         fixed_divide( (tile->z0 - tile->z1), 
                        dx1, 
                        &rzb.sign, 
                        &rzb.d_whole, 
                        &rzb.d_fract );
      else
         fixed_divide( (tile->z2 - tile->z3), 
                        dx2, 
                        &rzb.sign, 
                        &rzb.d_whole, 
                        &rzb.d_fract );
      }

#  if DEBUG
      {
      fprintf( stderr, "Call to sh_trap\n" );
      fprintf( stderr, "  w_no ---------- %d\n", active_window->win_no );
      fprintf( stderr, "  ylow ---------- %d\n", tile->yb );
      fprintf( stderr, "  yhigh --------- %d\n", tile->ya );
      fprintf( stderr, "  xleft_start --- %f\n", ((double)tile->x2) / 65536.0 );
      fprintf( stderr, "  xleft_end ----- %f\n", ((double)tile->x0) / 65536.0 );
      fprintf( stderr, "  xright_start -- %f\n", ((double)tile->x3) / 65536.0 );
      fprintf( stderr, "  xright_end ---- %f\n", ((double)tile->x1) / 65536.0 );
      fprintf( stderr, "  zstart_whole -- %d\n", tile->z2 );
      fprintf( stderr, "  zstart_fract -- %d\n", 0 );
      fprintf( stderr, "  xleft_delta --- %f\n", ((double)dxa) / 65536.0 );
      fprintf( stderr, "  xright_delta -- %f\n", ((double)dxb) / 65536.0 );
      fprintf( stderr, "  dzdy_whole ---- %d\n", rza.d_whole * rza.sign );
      fprintf( stderr, "  dzdy_fraction - %d\n", rza.d_fract );
      fprintf( stderr, "  dzdx_whole ---- %d\n", rzb.d_whole * rzb.sign );
      fprintf( stderr, "  dzdx_fraction - %d\n", rzb.d_fract );
      fprintf( stderr, "  shade --------- %d\n", shade );
      }
#  endif

   sh_trap(
         active_window->hwin_no,
         tile->yb,
         tile->ya,
         tile->x2,
         tile->x0,
         tile->x3,
         tile->x1,
         tile->z2,
         0,
         dxa,
         dxb,
         rza.d_whole * rza.sign,
         rza.d_fract,
         rzb.d_whole * rzb.sign,
         rzb.d_fract,
         shade );
   }

#else
void HSzbuf_trap_ifb( struct trapezoid *tile )
   {
   printf( "STUB: HSzbuf_trap_ifb\n" );
   }
#endif
