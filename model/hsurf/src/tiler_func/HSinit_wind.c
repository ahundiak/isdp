/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/

#include <stdio.h>
#include <stdlib.h>

#include "igrtypedef.h"

#include "wl.h"
#include "igecolor.h"
#include "igecolordef.h"

#include "hsmacdef.h"
#include "HStl_window.h"
#include "HStl_global.h"

#define DEBUG	0


#define	init_buffer_size	1000


/*---HSinitialize_buffers---------------------------------------------*/

/*
NAME
    HSinitialize_buffers

DESCRIPTION
    Initialize the Z and color buffers for windows with no
    hardware Zbuffer support.

PARAMETERS
    x_dits (IN) - the x size of the window in dits
    y_dits (IN) - the y size of the window in dits

GLOBALS USED
    active_window
    tiling_parms

FUNCTIONS CALLED
    HSget_region_update
    HSget_region_style
    HSget_region_original_style
    HSget_region_hardware_type
    HSget_region_xy_minmax
    HSget_region_window_dits
    WLcreate_image
    WLget_raster_data
    
HISTORY
    xx/xx/xx   Unknown
        Creation Date
        
    02/24/92   S.P. Rogers
        Added prologue comment and setting of "image_buffer_valid" field
*/

void	HSinitialize_buffers(void)

    {
    HSzbuf		*zb;
    HSzbuf		*tmp_zb;
    HScbuf		*cb;
    IGRboolean		region_update=FALSE;
    IGRboolean		shd_window = FALSE;
    IGRboolean		rhl_display = FALSE;
    IGRboolean		wire_window = FALSE;
    IGRboolean		hwzbuf = FALSE;
    IGRint		xlo = 0, ylo = 0, xhi, yhi, win_xdits, win_ydits;
    IGRint		style, original_style, type;
    register int	x, y;
    
    int				ret;

#   if defined (XGL)
    WLuint32	context_no;
#   endif


#    if DEBUG
         fprintf( stderr, "Initialize buffers\n" );
#    endif

    HSget_region_update( &region_update );
    if( region_update )
        {
        HSget_region_style( &style );
        HSget_region_original_style( &original_style );
        
        rhl_display = (style==HS_STYLE_RASTER) || (style==HS_STYLE_FILLED_RASTER);
        wire_window = (original_style == HS_STYLE_WIREFRAME);
        shd_window  = (original_style == HS_STYLE_SMOOTH) || (original_style==HS_STYLE_CONSTANT);

        HSget_region_hardware_type( &type );

        hwzbuf = ( type & HShardware_ZB_MASK ) ? 1 : 0;

        /*  initialize buffers need full size of buffer to do   */
        /*  correctly.  Will be to window if reusing or aw dits */
        /*  if maloced a virtual small window                   */
        
        HSget_region_xy_minmax( &xlo, &ylo, &xhi, &yhi );

        if( hwzbuf && rhl_display && !(shd_window||wire_window) )
            {
            HSget_region_window_dits( &win_xdits, &win_ydits );
            win_xdits += win_xdits % 2;
            win_ydits += win_ydits % 2;
            }
        else
            {
            win_xdits = active_window->x_dits;
            win_ydits = active_window->y_dits;
            }
        }


    /* if locked Zbuffer AAAAAANNNNNNDDDDD dexel mode, DON'T DO IT! CMJ  04/16/90 */
    
    if( (active_window->type & HShardware_ZB_MASK) && 
        (tiling_parms.processing_mode & HS_PMODE_DEXEL) )
        return;


    /* abort if buffers not allocated */

    if( !active_window->zbuf ) return;


    /*  Want to initialize the z buffer to 'tiling_parms.maximum_z' */
    /*  and the color buffer to 'HS_BACKGROUND_COLOR'               */
         
    if( region_update && !wire_window &&
        ((hwzbuf && rhl_display && !(shd_window||wire_window)) || (!hwzbuf)))
        {

        /* initialize part of the window if reusing a virtual zbuff*/

        zb = active_window->zbuf;
        zb += win_xdits * ylo;
        tmp_zb = zb + xlo;
        for( x=xlo; x<xhi+1; x++ ) *(tmp_zb++) = tiling_parms.maximum_z;
        tmp_zb = zb + win_xdits;
        tmp_zb += xlo;
        zb += xlo;

        for( y=ylo+1; y<yhi+1; y++ )
            {
            memcpy( tmp_zb, zb, sizeof( HSzbuf ) * active_window->x_dits );
            tmp_zb += win_xdits;
            }
        }
    else
        {

        /* initialize whole zbuffer */

        zb = active_window->zbuf;

        for( x=0; x<active_window->x_dits; x++ )
            *(zb++) = tiling_parms.maximum_z;
        
        for( y=1; y<active_window->y_dits; y++ )
            {
            memcpy( zb, active_window->zbuf, sizeof( HSzbuf ) * active_window->x_dits );
            zb += active_window->x_dits;
            }
        }
        


    /*  If the grid is off, then we want to initialize the color buffer */
    /*  to all background.  If the grid is on, use the data currently   */
    /*  on the screen to initialze the color buffer                     */

    if( (active_window->grid_on) && !(region_update) )
        {
        active_window->image.x = 0;
        active_window->image.y = 0;
        active_window->image.width = active_window->x_dits;
        active_window->image.height = active_window->y_dits;
        active_window->image.buffer = (char *)active_window->cbuf;
        
        ret = WLget_raster_data( active_window->win_no,
                                 active_window->context_no,
                                 &active_window->image );
        }
    else
        {
        WLuint16   pcolor;

#       if defined (XGL)

           /*  In XGL, we want to use the 8bit forms context to convert  */
           /*  logical color index to a physical one because the active  */
           /*  context is 24bit and would return a bad value  */

           WLuint32 context_no;

           CMget_exnuc_forms_context( active_window->vs_no, &context_no );
        
           IGEgetabsclrindx( context_no, 
                             (short)HS_BACKGROUND_COLOR, 
                             &pcolor );
#       else
           IGEgetabsclrindx( active_window->context_no, 
                             (short)HS_BACKGROUND_COLOR, 
                             &pcolor );
#       endif
        
        cb = active_window->cbuf;
	
        if( region_update && !wire_window &&
            ((hwzbuf && rhl_display && !shd_window) || (!hwzbuf)))
            {
            cb += ylo * win_xdits;
            cb += xlo;
            for( y=ylo; y<yhi+1; y++ )
                {
                memset( cb, pcolor, xhi - xlo + 1 );
                cb += win_xdits;
                }
            }
        else
            {
            memset( cb, pcolor, active_window->cbuf_size );
            }
        }

    active_window->image_buffer_valid = FALSE;

    }  /* HSinitialize_buffers */


/*---HSinit_window_ROP-------------------------------------------------------*/

/*
NAME
    HSinit_window_ROP

DESCRIPTION
    Initialize a window for shading when there is no hardware
    support (i.e., Zbuffer, ASAP1).

PARAMETERS
    x_dits (IN) - the x size of the window in dits
    y_dits (IN) - the y size of the window in dits

GLOBALS USED
    active_window
    tiling_parms

FUNCTIONS CALLED
    HSinitialize_buffers 
    
HISTORY
    xx/xx/xx   Unknown
        Creation Date
    02/24/92   S.P. Rogers
        Added prologue comment
*/

void    HSinit_window_ROP( IGRint x_dits, IGRint y_dits )
    
    {
    
#   if DEBUG
    fprintf( stderr, "HSinit_window_rop\n" );
    fprintf( stderr, "   w_no ------------ %d\n", active_window->win_no );
    fprintf( stderr, "   org_x ----------- %d\n", active_window->org_x );
    fprintf( stderr, "   org_y ----------- %d\n", active_window->org_y );
    fprintf( stderr, "   x_dits ---------- %d\n", x_dits );
    fprintf( stderr, "   y_dits ---------- %d\n", y_dits );
#   endif


    active_window->x_dits = x_dits;
    active_window->y_dits = y_dits;
        
    if( active_window->x_dits & 1 ) active_window->x_dits++;
    if( active_window->y_dits & 1 ) active_window->y_dits++;

    active_window->x_min = active_window->x_dits << 16;
    active_window->y_min = active_window->y_dits;
    active_window->x_max = 0;
    active_window->y_max = 0;

    if ( active_window->using_ramps )
    {
       /*  supports ramp-rasterizers.  'us' stands for unsupported.    */
       /*  These define the display region for the unsupported zbuffer */
    
       active_window->x_min_us = active_window->x_dits << 16;
       active_window->y_min_us = active_window->y_dits;
       active_window->x_max_us = 0;
       active_window->y_max_us = 0;

       tiling_parms.apparent_shades = tiling_parms.processing_mode & HS_PMODE_DIRECT ?
           tiling_parms.number_shades :
           ( tiling_parms.number_shades - 1 ) * 16 + 1;
    }
    else
    {
    struct IGEcontext_info	IGEcontext_info;
    IGEload_context( active_window->context_no, &IGEcontext_info );
    tiling_parms.apparent_shades = ((IGEcontext_info.cube_size-1)*16)+1;
    }
        
    if( !(tiling_parms.processing_mode & (HS_PMODE_DEXEL | HS_PMODE_FEEDBACK)) )
       HSinitialize_buffers();

    }  /* HSinit_window_ROP */

#if defined( ENV5 )

/*---HSinit_window_IFB-------------------------------------------------------*/


void    HSinit_window_IFB( IGRint x_dits, IGRint y_dits )
    
/*
NAME
    HSinit_window_IFB

DESCRIPTION
    Initialize a window for shading on an IFB machine
    when there is a hardware or locked Zbuffer.

PARAMETERS
    x_dits (IN) - the x size of the window in dits
    y_dits (IN) - the y size of the window in dits

GLOBALS USED
    active_window
    tiling_parms

HISTORY
    xx/xx/xx   Unknown
       Creation Date
    02/24/92   S.P. Rogers
       Added prologue comment
*/

    {
    
#   if DEBUG
    fprintf( stderr, "HSinit_window_ifb\n" );
    fprintf( stderr, "   win_no ---------- %d\n", active_window->win_no );
    fprintf( stderr, "   org_x ----------- %d\n", active_window->org_x );
    fprintf( stderr, "   org_y ----------- %d\n", active_window->org_y );
    fprintf( stderr, "   x_dits ---------- %d\n", x_dits );
    fprintf( stderr, "   y_dits ---------- %d\n", y_dits );
#   endif
    
    /*
     *  Initialize the z-buffer and dither mode
     */

    sh_set_zbuf( 
        active_window->hwin_no,
        0, 0,
        x_dits, y_dits,
        (unsigned long)tiling_parms.maximum_z );
        
    sh_set_dither_mode(
        active_window->hwin_no,
        (tiling_parms.processing_mode & HS_PMODE_DIRECT) ? 0 : 1 );
        
    /*
     *  Calculate the number of apparent shades based on the dither
     *  or direct flag and the number of colors and shades.
     */

    tiling_parms.apparent_shades = (tiling_parms.processing_mode & HS_PMODE_DIRECT) ?
        tiling_parms.number_shades :
        ( tiling_parms.number_shades - 1 ) * 16 + 1;
    
    /*
     *  Load the window extents in the local data structure and 
     *  init the min/max for raster hidden lines.
     */
     
    active_window->x_dits = x_dits;
    active_window->y_dits = y_dits;
        
    active_window->x_min_rl = active_window->x_dits << 16;
    active_window->y_min_rl = active_window->y_dits;
    active_window->x_max_rl = 0;
    active_window->y_max_rl = 0;

    }  /* HSinit_window_IFB */
    

/*---HSinit_window_FPE-------------------------------------------------------*/

/*
NAME
    HSinit_window_FPE

DESCRIPTION
    Initialize a window for shading on an IFB machine
    when there is a floating point engine present

PARAMETERS
    x_dits (IN) - the x size of the window in dits
    y_dits (IN) - the y size of the window in dits

GLOBALS USED
    active_window
    tiling_parms

HISTORY
    xx/xx/xx   Unknown
       Creation Date
    02/24/92   S.P. Rogers
       Added prologue comment
*/

void    HSinit_window_FPE( IGRint x_dits, IGRint y_dits )
    
    {
#   if DEBUG
    fprintf( stderr, "HSinit_window_fpe\n" );
    fprintf( stderr, "   win_no ---------- %d\n", active_window->win_no );
    fprintf( stderr, "   org_x ----------- %d\n", active_window->org_x );
    fprintf( stderr, "   org_y ----------- %d\n", active_window->org_y );
    fprintf( stderr, "   x_dits ---------- %d\n", x_dits );
    fprintf( stderr, "   y_dits ---------- %d\n", y_dits );
#   endif
    
    /*
     *  Initialize the z-buffer and dither mode
     */

    /*
     *  Load the window extents in the local data structure and 
     *  init the min/max for raster hidden lines.
     */
     
    /*
     *  Calculate the number of apparent shades based on the dither
     *  or direct flag and the number of colors and shades.
     */

    tiling_parms.apparent_shades = (tiling_parms.processing_mode & HS_PMODE_DIRECT) ?
        tiling_parms.number_shades :
        ( tiling_parms.number_shades - 1 ) * 16 + 1;
    
    sh_set_dither_mode( active_window->hwin_no,
        (tiling_parms.processing_mode & HS_PMODE_DIRECT) ? 0 : 1 );
        
    GPEnableZbuffer( active_window->gpipe_id, 1 ); 
    GPInitZbuffer( active_window->gpipe_id, 0x7FFFFFFF );
        
    active_window->x_dits = x_dits;
    active_window->y_dits = y_dits;
        
    active_window->x_min_rl = active_window->x_dits << 16;
    active_window->y_min_rl = active_window->y_dits;
    active_window->x_max_rl = 0;
    active_window->y_max_rl = 0;

    }  /* HSinit_window_FPE */


/*---HSinit_window_EG--------------------------------------------------------*/

void    HSinit_window_EG( IGRint x_dits, IGRint y_dits )
    
/*
NAME
    HSinit_window_EG

DESCRIPTION
    Initialize a window for shading on an EdgeII machine
    when the EG library will be used to access the 
    hardware Zbuffer and true color capabilities.

PARAMETERS
    x_dits (IN) - the x size of the window in dits
    y_dits (IN) - the y size of the window in dits

GLOBALS USED
    active_window
    tiling_parms

HISTORY
    xx/xx/xx   Unknown
       Creation Date
    02/24/92   S.P. Rogers
       Added prologue comment
*/

    {
    
    /*
     *  Calculate the number of apparent shades based on the dither
     *  or direct flag and the number of colors and shades.
     */

    {
    struct IGEcontext_info	IGEcontext_info;
    IGEload_context( active_window->context_no, &IGEcontext_info );
    tiling_parms.apparent_shades = ((IGEcontext_info.cube_size-1)*16)+1;
    }
    /*
    tiling_parms.apparent_shades = (tiling_parms.processing_mode & HS_PMODE_DIRECT) ?
        tiling_parms.number_shades :
        ( tiling_parms.number_shades - 1 ) * 16 + 1;
    */
    /*
     *  Load the window extents in the local data structure and 
     *  init the min/max for raster hidden lines.
     */
     
    active_window->x_dits = x_dits;
    active_window->y_dits = y_dits;
        
    active_window->x_min_rl = active_window->x_dits << 16;
    active_window->y_min_rl = active_window->y_dits;
    active_window->x_max_rl = 0;
    active_window->y_max_rl = 0;
    }  /* HSinit_window_EG */
#endif


#if defined( OPENGL )

void    HSinit_window_OPENGL(
   IGRint x_dits,
   IGRint y_dits )
    
/*
NAME
    HSinit_window_OPENGL

DESCRIPTION
    Initialize a window for shading using OPENGL

PARAMETERS
    x_dits (IN) - the x size of the window in dits
    y_dits (IN) - the y size of the window in dits

GLOBALS USED
    active_window
    tiling_parms

HISTORY
    xx/xx/xx   Unknown
       Creation Date
    02/24/92   S.P. Rogers
       Added prologue comment
*/

    {
    
    /*
     *  Calculate the number of apparent shades based on the dither
     *  or direct flag and the number of colors and shades.
     */

    {
    struct IGEcontext_info	IGEcontext_info;
    IGEload_context( active_window->context_no, &IGEcontext_info );
    tiling_parms.apparent_shades = ((IGEcontext_info.cube_size-1)*16)+1;
    }
    /*
    tiling_parms.apparent_shades = (tiling_parms.processing_mode & HS_PMODE_DIRECT) ?
        tiling_parms.number_shades :
        ( tiling_parms.number_shades - 1 ) * 16 + 1;
    */
    /*
     *  Load the window extents in the local data structure and 
     *  init the min/max for raster hidden lines.
     */
     
    active_window->x_dits = x_dits;
    active_window->y_dits = y_dits;
        
    active_window->x_min_rl = active_window->x_dits << 16;
    active_window->y_min_rl = active_window->y_dits;
    active_window->x_max_rl = 0;
    active_window->y_max_rl = 0;
    }  /* HSinit_window_OPENGL */
#endif

#if defined( XGL )

void    HSinit_window_XGL(
   IGRint x_dits,
   IGRint y_dits )
    
/*
NAME
    HSinit_window_XGL

DESCRIPTION
    Initialize a window for shading using XGL

PARAMETERS
    x_dits (IN) - the x size of the window in dits
    y_dits (IN) - the y size of the window in dits

GLOBALS USED
    active_window
    tiling_parms

HISTORY
    xx/xx/xx   Unknown
       Creation Date
    02/24/92   S.P. Rogers
       Added prologue comment
*/

    {
    
    /*
     *  Calculate the number of apparent shades based on the dither
     *  or direct flag and the number of colors and shades.
     */

    {
    struct IGEcontext_info	IGEcontext_info;
    IGEload_context( active_window->context_no, &IGEcontext_info );
    tiling_parms.apparent_shades = ((IGEcontext_info.cube_size-1)*16)+1;
    }
    /*
    tiling_parms.apparent_shades = (tiling_parms.processing_mode & HS_PMODE_DIRECT) ?
        tiling_parms.number_shades :
        ( tiling_parms.number_shades - 1 ) * 16 + 1;
    */
    /*
     *  Load the window extents in the local data structure and 
     *  init the min/max for raster hidden lines.
     */
     
    active_window->x_dits = x_dits;
    active_window->y_dits = y_dits;
        
    active_window->x_min_rl = active_window->x_dits << 16;
    active_window->y_min_rl = active_window->y_dits;
    active_window->x_max_rl = 0;
    active_window->y_max_rl = 0;
    }  /* HSinit_window_XGL */
#endif


