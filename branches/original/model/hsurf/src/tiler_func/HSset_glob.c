
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/

/*
 * This file contains all the routines that set fields in the global
 * tiling_parms structure.
 */

#include <stdio.h>

#include "wl.h"

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dp.h"
#include "dpstruct.h"
#include "hstiler.h"
#include "hslight.h"
#include "hsmacdef.h"
#include "HStl_global.h"
#include "HStl_window.h"
#include "HStl_element.h"
#include "HSfem_spt.h"

#include "HSe2_mesher.h"
#include "hsdisplay.h"
#include "HSpr_tiler_f.h"



/*---HSdump_tiling_parms------------------------------------------------------*/

/*
NAME
    HSdump_tiling_parms
    
DESCRIPTION
    prints out the values of the tiling parameters.

GLOBALS USED
    tiling_parms
    
HISTORY
    08/29/90    C. M. Jablonski
        Created
*/

void    HSdump_tiling_parms(void)

    {
    fprintf (stderr, "GLOBAL TILING PARAMETERS:\n");
    fprintf (stderr, "  number of colors = %d\n", tiling_parms.number_colors);
    fprintf (stderr, "  number of shades = %d\n", tiling_parms.number_shades);
    fprintf (stderr, "  direct shading flag = %d\n", tiling_parms.processing_mode & HS_PMODE_DIRECT);
    fprintf (stderr, "  apparent shades = %d\n", tiling_parms.apparent_shades);
    fprintf (stderr, "  base color = %d\n", tiling_parms.base_color);
    fprintf (stderr, "  IP32 flag = %d\n", tiling_parms.processing_mode & HS_PMODE_IP32);
    fprintf (stderr, "  use EDGE2 flag = %d\n", tiling_parms.processing_mode & HS_PMODE_USE_EDGE2);
    fprintf (stderr, "  translucency 1x1 flag = %d\n", tiling_parms.processing_mode & HS_PMODE_TRANS_1x1);
    fprintf (stderr, "  status flag = %d\n", tiling_parms.status);
    fprintf (stderr, "  show hidden flag = %d\n", tiling_parms.processing_mode & HS_PMODE_RHL_SHOW_HIDDEN);
    fprintf (stderr, "  feedback mode flag = %d\n", tiling_parms.processing_mode & HS_PMODE_FEEDBACK);
    fprintf (stderr, "  feedback full mode flag = %d\n", tiling_parms.processing_mode & HS_PMODE_FEEDBACK_FULL);
    fprintf (stderr, "  dexel mode flag = %d\n", tiling_parms.processing_mode & HS_PMODE_DEXEL);
    fprintf (stderr, "  rendering mode flag = %d\n", tiling_parms.processing_mode & HS_PMODE_RENDER_IMAGE);
    fprintf (stderr, "  clip mode flag = %d\n", tiling_parms.processing_mode & HS_PMODE_CLIP);
    fprintf (stderr, "  shaded plot mode flag = %d\n", tiling_parms.processing_mode & HS_PMODE_SHADED_PLOT);
    fprintf (stderr, "  maximum z = %lf\n", tiling_parms.maximum_z);
    }

/*---HSset_window_object_info-------------------------------------------------*/

/*
NAME
   HSset_window_object_info
   
DESCRIPTION
    put the window objid/osnum in the tiling_parms structure.  To be
    used in HSgetedges.I

PARAMETERS
    window: (IN): address of an object id structure containing the object id
                  and object space number of the active window
                      
GLOBALS USED
    tiling_parms
    
HISTORY
    ??/??/??    M. Lanier
        Created
*/
 
void    HSset_window_object_info( struct GRid *window )

    {
    tiling_parms.window_id = (unsigned int)window->objid;
    tiling_parms.window_os = (unsigned short)window->osnum;
    }


/*---HSset_hardware_type------------------------------------------------------*/

/*
NAME
    HSset_hardware_type
    
DESCRIPTION
    sets the hardware-dependent parameters,  which include 
    the ip32 flag and the color table base index.

PARAMETERS
    flag: (IN): IP32 or not flag
    
GLOBALS USED
    tiling_parms
    
HISTORY
    02/27/90    C. M. Jablonski
        Created
*/

void HSset_hardware_type( IGRboolean flag )


    {
    if( flag )
        tiling_parms.processing_mode |= HS_PMODE_IP32;
    else
        tiling_parms.processing_mode &= ~HS_PMODE_IP32;
        
    /* ramps start at the physical slot of logical color #1 */
    tiling_parms.base_color = HSlogical_color_to_physical_slot( 1, active_window->context_no );
    }
    

/*---HSset_transparency-------------------------------------------------------*/

/*
NAME
    HSset_transparency
    
DESCRIPTION
    sets the transparency type: TRUE = 1x1
    screen door, FALSE = 3x3 screen door.

PARAMETERS
    flag: (IN):  The 1x1 or 3x3 flag
    
GLOBALS USED
    tiling_parms
    
HISTORY
    02/27/90    C. M. Jablonski
        Created
*/

IGRint    HSset_transparency( IGRboolean flag )


    {
    if( flag )
        tiling_parms.processing_mode |= HS_PMODE_TRANS_1x1;
    else
        tiling_parms.processing_mode &= ~HS_PMODE_TRANS_1x1;
        
    return(0);
    }


/*---HSset_edge2_usage--------------------------------------------------------*/

/*
NAME
    HSset_edge2_usage

DESCRIPTION
    sets the edge2 usage flag.

PARAMTERS
    flag: (IN):  The use edge2 or not flag
    
GLOBALS USED
    tiling_parms
    
HISTORY
    06/13/90    C. M. Jablonski
        Created
*/

IGRint    HSset_edge2_usage( IGRboolean flag )


    {
    if( flag )
        tiling_parms.processing_mode |= HS_PMODE_USE_EDGE2;
    else
        tiling_parms.processing_mode &= ~HS_PMODE_USE_EDGE2;

    return(0);
    }

/*---HSset_feedback_mode------------------------------------------------------*/

/*
NAME
    HSset_feedback_mode
    
DESCRIPTION
    sets the feedback mode flag.

PARAMETERS
    flags: (IN): The feedback mode or not flag
    
GLOBALS USED
    tiling_parms
    
HISTORY
    02/27/90    C. M. Jablonski
        Created
*/

void HSset_feedback_mode( IGRboolean flag )

    {
    if( flag )
        tiling_parms.processing_mode |= HS_PMODE_FEEDBACK;
    else
        tiling_parms.processing_mode &= ~HS_PMODE_FEEDBACK;
    }


/*---HSset_feedback_full_mode-------------------------------------------------*/

/*
NAME
    HSset_feedback_full_mode
    
DESCRIPTION
    sets the feedback full status flag.

PARAMETERS
    flags: (IN): The feedback full or not flag
    
GLOBALS USED
    tiling_parms
    
HISTORY
    02/27/90    C. M. Jablonski
        Created
*/

void HSset_feedback_full_mode( IGRboolean flag )


    {
    if( flag )
        tiling_parms.processing_mode |= HS_PMODE_FEEDBACK_FULL;
    else
        tiling_parms.processing_mode &= ~HS_PMODE_FEEDBACK_FULL;
    }

/*---HSset_dexel_mode---------------------------------------------------------*/

/*
NAME
    HSset_dexel_mode
    
DESCRIPTION
    sets the dexel mode flag.

PARAMETERS
    flag: (IN): the dexel mode or not flag
    
GLOBALS USED
    tiling_parms
    
HISTORY
    02/27/90    C. M. Jablonski
        Created
*/

void HSset_dexel_mode( IGRboolean flag )

    {
    if( flag )
        tiling_parms.processing_mode |= HS_PMODE_DEXEL;
    else
        tiling_parms.processing_mode &= ~HS_PMODE_DEXEL;
    }


/*---HSset_rendering_mode-----------------------------------------------------*/

/*
NAME
    HSset_rendering_mode
    
DESCRIPTION
    sets the rendering mode flag.

PARAMETERS
    flags: (IN): the render image or not flag

GLOBALS USED
    tiling_parms
        
HISTORY
    02/27/90    C. M. Jablonski
        Created
 */

void HSset_rendering_mode( IGRboolean flag )

    {
    if( flag )
        tiling_parms.processing_mode |= HS_PMODE_RENDER_IMAGE;
    else
        tiling_parms.processing_mode &= ~HS_PMODE_RENDER_IMAGE;

    }

/*---HSset_processing_mode-----------------------------------------------------*/

/*
NAME
    HSset_processing_mode
    
DESCRIPTION
    Sets the active processing mode flag in the tiling parameters structure
    
PARMETERS
    flag: (IN): The new processing mode
    
GLOBALS USED
    tiling_parms
    
HISTORY
    ??/??/??    M. Lanier
        Created
*/

void HSset_processing_mode( unsigned int flag )

    {
    /* clear out the old processing mode */

    tiling_parms.processing_mode &= ~HS_PMODE_PROC_MODES;    
    tiling_parms.processing_mode |= flag;
    }


/*---HSset_clip_mode----------------------------------------------------------*/

/*
NAME
    HSset_clip_mode
    
DESCRIPTION
    sets the clip mode flag.  TRUE = clip facets,  FALSE = do not clip facets.

PARAMETERS
    flag: (IN): The clip mode on/off flag
    
GLOBALS USED
    tiling_parms
    
HISTORY
    02/27/90    C. M. Jablonski
        Created
*/

void HSset_clip_mode( IGRboolean flag )

    {
    if( flag )
        tiling_parms.processing_mode |= HS_PMODE_CLIP;
    else
        tiling_parms.processing_mode &= ~HS_PMODE_CLIP;
    }


/*---HSset_hidden_line_display_mode----------------------------------------------------------*/

/*
NAME
    HSset_hidden_line_display_mode
    
DESCRIPTION
    sets the hidden_line_display mode flag.  TRUE = display 
    hidden lines, FALSE = do not display hidden lines.

PARAMETERS
    flag: (IN): The hidden line display mode on/off flag
    
GLOBALS USED
    tiling_parms
    
HISTORY
    02/27/90    C. M. Jablonski
        Created
*/

void HSset_hidden_line_display_mode( IGRboolean flag )

    {
    if( flag )
        tiling_parms.processing_mode |= HS_PMODE_DISPLAY_HIDDEN_LINES;
    else
        tiling_parms.processing_mode &= ~HS_PMODE_DISPLAY_HIDDEN_LINES;
    }


/*---HSset_shaded_plot_mode---------------------------------------------------*/

/*
NAME
    HSset_shaded_plot_mode
    
DESCRIPTION
    sets the shaded plotting mode flag.

PARAMETERS
    flag: (IN): The shaded plotting on/off flag
    
GLOBALS USED
    tiling_parms
    
HISTORY
    02/27/90    C. M. Jablonski
        Created
*/

void HSset_shaded_plot_mode( IGRboolean flag )

    {
    if( flag )
        tiling_parms.processing_mode |= HS_PMODE_SHADED_PLOT;
    else
        tiling_parms.processing_mode &= ~HS_PMODE_SHADED_PLOT;        
    }


/*---HSset_maximum_z----------------------------------------------------------*/

/*
NAME
    HSset_maximum_z
    
DESCRIPTION
    sets the maximum z value.  This is the maximum  value that 
    can be represented in the z-buffer.

PARAMETERS
    value: (IN): The new max z value
    
GLOBALS USED
    tiling_parms
    
HISTORY
    02/27/90    C. M. Jablonski
        Created
*/

void HSset_maximum_z( IGRdouble value )

    {
    tiling_parms.maximum_z = value;
    }


/*---HSset_status-------------------------------------------------------------*/

/*
NAME
    HSset_status
    
DESCRIPTION
    sets the status flag.

PARAMETERS
    flag: (IN): The new status flag
    
GLOBALS USED
    tiling_parms
    
HISTORY
    02/27/90    C. M. Jablonski
        Created
*/

void HSset_status( IGRint flag )

    {
    tiling_parms.status = flag;
    }


/*---HSset_paint_offset----------------------------------------------------------*/

/*
NAME
    HSset_paint_offset
    
DESCRIPTION
    Loaded the display region x/y offset from the window origin
    into the global tiling parameters structure
    
PARAMETERS
    x: (IN):  The display region x offset from the window origin
    y: (IN):  The display region y offset from the window origin
    
GLOBALS USED
    tiling_parms
    
HISTORY
    ??/??/??    M. Lanier
        Created
*/

void    HSset_paint_offset( IGRint x, IGRint y )

    {
    tiling_parms.x_offset = x;
    tiling_parms.y_offset = y;
    }

/*---HSset_region_update----------------------------------------------------------*/

/*
NAME
    HSset_region_update
    
DESCRIPTION
    Load the region display on/off flag into the global tiling
    parameters structure
    
PARAMETERS
    flag: (IN): The region display on/off flag
    
GLOBALS USED
    tiling_parms
    
HISTORY
    ??/??/??    M. Lanier
        Created
*/

void    HSset_region_update( IGRboolean update )

    {
    tiling_parms.region_update = update;
    }
    
/*---HSget_region_update--------------------------------------------------------*/

/*
NAME
    HSget_region_update
    
DESCRIPTION
    Gets the region display on/off flag from the global tiling
    parameters structure and returns it to the caller
    
PARAMETERS
    update: (OUT):  The current state of the region display flag
    
GLOBALS USED
    tiling_parms
    
HISTORY
    ??/??/??    J. Underwood
        Created
*/

void    HSget_region_update( IGRboolean *update )

    {
    *update = tiling_parms.region_update;
    }
    
/*---HSset_region_style------------------------------------------------------*/

/*
NAME
    HSset_region_style
    
DESCRIPTION
    Load the shading style for the region, into the global tiling
    parameters structure
    
PARAMETERS
    style: (IN):  The shading style for the region
    
GLOBALS USED
    tiling_parms
    
HISTORY
    ??/??/??     J. Underwood
        Created
*/

void    HSset_region_style( IGRint style )

    {
    tiling_parms.region_style = style;
    }
    
/*---HSset_region_original_style------------------------------------------*/

/*
NAME
    HSset_region_original_style
    
DESCRIPTION
    Sets the original shading style for the region
    
KEYWORDS
    region update
    shading style
    
PARAMETERS
    original_style: (IN): The original shading style
    
GLOBALS USED
    tiling_parms
    
HISTORY
    ??/??/??    J. Underwood
        Created
*/

void    HSset_region_original_style( IGRint original_style )

    {
    tiling_parms.region_original_style = original_style;
    }
    
/*---HSget_region_original_style-------------------------------------------*/

/*
NAME
    HSget_region_original_style
    
DESCRIPTION
    Returns to the caller, the display region's original shading style
    
KEYWORDS
    region update
    shading style
    
PARAMETERS
    original_style: (OUT): The original shading style for the region
    
GLOBALS USED
    tiling_parms
    
HISTORY
    ??/??/??    J. Underwood
        Created
*/

void    HSget_region_original_style( IGRint *original_style )

    {
    *original_style = tiling_parms.region_original_style;
    }

/*---HSget_region_style----------------------------------------------------*/

/*
NAME
    HSget_region_style
    
DESCRIPTION
    Return to the caller, the display region's shading style
    
KEYWORDS
    shading_style
    region update
    
PARAMETERS
    style: (OUT): The display region's shading style
    
GLOBALS USED
    tiling_parms
    
HISTORY
    ??/??/??    J. Underwood
        Created
        
*/
    
void    HSget_region_style( IGRint *style )

    {
    *style = tiling_parms.region_style;
    }
    
/*---HSset_region_xy_minmax----------------------------------------------*/

/*
NAME
    HSset_region_xy_minmax
    
DESCRIPTION
    Sets the range box of the display region

KEYWORDS
    region update
    
PARAMETERS
    xmin, ymin: (IN):  The x/y coordinate, with respect to the window
                       origin, of the upper left corner of the display
                       region
    xmax, ymax: (IN):  The x/y coordinate, with respect to the window
                       origin, of the lower right corner of the display
                       region

GLOBALS USED
    tiling_parms
    
HISTORY
    ??/??/??    J. Underwood
        Created
    
*/

void    HSset_region_xy_minmax( IGRint xmin,
                                IGRint ymin,
                                IGRint xmax,
                                IGRint ymax )

    {
    tiling_parms.dr_xmin = xmin;
    tiling_parms.dr_xmax = xmax;
    tiling_parms.dr_ymin = ymin;
    tiling_parms.dr_ymax = ymax;
    }

/*---HSget_region_xy_minmax-------------------------------------*/

/*
NAME
    Hget_region_xy_minmax
    
DESCRIPTION
    Gets the range box of the display region

KEYWORDS
    region update
    
PARAMETERS
    xmin, ymin: (OUT):  The x/y coordinate, with respect to the window
                        origin, of the upper left corner of the display
                        region
    xmax, ymax: (OUT):  The x/y coordinate, with respect to the window
                        origin, of the lower right corner of the display
                        region

GLOBALS USED
    tiling_parms
    
HISTORY
    ??/??/??    J. Underwood
        Created
    
*/

void    HSget_region_xy_minmax( IGRint *xmin,
                                IGRint *ymin,
                                IGRint *xmax,
                                IGRint *ymax )

    {
    *xmin = tiling_parms.dr_xmin;
    *xmax = tiling_parms.dr_xmax;
    *ymin = tiling_parms.dr_ymin;
    *ymax = tiling_parms.dr_ymax;
    }
    
/*---HSset_region_window_dits----------------------------------------*/

/*
NAME
    Hset_region_window_dits
    
DESCRIPTION
    Sets the extents of the display region

KEYWORDS
    region update
    
PARAMETERS
    xdits: (IN): The x extents of the display region
    ydits: (IN): The y extents of the display region

GLOBALS USED
    tiling_parms
    
HISTORY
    ??/??/??    J. Underwood
        Created
    
*/

void  HSset_region_window_dits( IGRint x_dits, IGRint y_dits )

    {
       tiling_parms.window_x_dits=x_dits;
       tiling_parms.window_y_dits=y_dits;
     }

/*---HSget_region_window_dits-----------------------------------------*/

/*
NAME
    Hget_region_window_dits
    
DESCRIPTION
    Gets the extents of the display region

KEYWORDS
    region update
    
PARAMETERS
    xdits: (OUT): The x extents of the display region
    ydits: (OUT): The y extents of the display region

GLOBALS USED
    tiling_parms
    
HISTORY
    ??/??/??    J. Underwood
        Created
    
*/

void  HSget_region_window_dits( IGRint *x_dits, IGRint *y_dits )

    {
    *x_dits=tiling_parms.window_x_dits;
    *y_dits=tiling_parms.window_y_dits;
    }

/*---HSget_region_hardware_type---------------------------------------*/

/*
NAME
    HSget_region_hardware_type
    
DESCRIPTION
    Get the display region's hardware type
    
KEYWORDS
    region update
    
PARAMETERS
    type: (OUT): The display region's hardware type
    
GLOBALS USED
    tiling_parms
    
HISTORY
    ??/??/??    J. Underwood
        Created
        
*/

void HSget_region_hardware_type( IGRint *type )

    {
    *type=tiling_parms.hardware_type;
    }

/*---HSset_region_Hardware_type----------------------------------------*/

/*
NAME
    HSset_region_hardware_type
    
DESCRIPTION
    Set the display region's hardware type
    
KEYWORDS
    region update
    
PARAMETERS
    type: (IN): The display region's hardware type
    
GLOBALS USED
    tiling_parms
    
HISTORY
    ??/??/??    J. Underwood
        Created
        
*/

void HSset_region_hardware_type( IGRint type )

    {
    tiling_parms.hardware_type=type;
    }
    
/*---HSset_ambient_light_intensities------------------------------------------*/

/*
NAME
    HSset_ambient_light_intensities
    
DESCRIPTIONS
    Set the red, green, blue and average intensities of the ambient 
    light.
    
ARGUMENTS
    ambient_light:  light structure containing the ambient intensities
    
GLOBALS USED
    tiling_parms: global tiler information
    
HISTORY
    6/1/93        M. Lanier
        Created
*/

void	HSset_ambient_light_intensities( struct HS_light_source  *ambient_light )

    {
    IGRint	r, g, b, a;

    /*
     *  Compute the average by summing the three intensities and
     *  dividing by 3
     */
     
    r = (IGRint)ambient_light->red;
    g = (IGRint)ambient_light->green;
    b = (IGRint)ambient_light->blue;
    
    a = (r + g + b) / 3;

    /*
     *  Store the ambient light information in the tiling parms structure
     */
         
    tiling_parms.ambient[0] = ambient_light->red;
    tiling_parms.ambient[1] = ambient_light->green;
    tiling_parms.ambient[2] = ambient_light->blue;
    tiling_parms.ambient[3] = (unsigned short)a;
    }

/*---HSset_shade_config-------------------------------------------------------*/

IGRint    HSset_shade_config( IGRint pipe_no,
             unsigned long base_addr,
                IGRint num_colors,
                IGRint num_shades,
                IGRint dither )

/*
 * ABSTRACT:    HSset_shade_config sets the color table configuration parameters,
 *        which include num_colors, num_shades and dither mode.
 *
 * HISTORY:    02/27/90  Created            C. M. Jablonski
 */

    {
#if defined (ENV5)    	
    if( active_window->type & HShardware_LB_GPIPE )
        GPSetShadeTable( active_window->gpipe_id, num_shades, dither  );
#endif

    if( dither == HS_DITHER_DIRECT )
        tiling_parms.processing_mode |= HS_PMODE_DIRECT;
    else
        tiling_parms.processing_mode &= ~HS_PMODE_DIRECT;
 
    tiling_parms.number_colors = num_colors;
    tiling_parms.number_shades = num_shades;

    tiling_parms.apparent_shades = (tiling_parms.processing_mode & HS_PMODE_DIRECT) ?
        tiling_parms.number_shades :
        ( tiling_parms.number_shades - 1 ) * 16 + 1;
    return(0);
    }

/*---HSset_fem_ramp-------------------------------------------------------*/

IGRint    HSset_fem_ramp( IGRint num_shades_fem,
                          IGRint start_slot_fem )

/*
 * ABSTRACT:    HSset_fem_ramp sets the color table configuration parameters,
 *
 * HISTORY:    09/27/93  Created            Joel D. Underwood
 */

{
    tiling_parms.apparent_shades_fem = ( num_shades_fem - 1 ) * 16 + 1;
    tiling_parms.start_slot_fem = start_slot_fem;

    return(0);
}

/*---HSset_fem_ramp-------------------------------------------------------*/

/*---HSset_curve_type_to_curve------------------------------------------------------*/

/*
NAME
    HSset_curve_type
    
DESCRIPTION
    sets the type of curve that is to be output from low/med CVE or PDD.
    PDD will want the curve type to be set to horizon curve while CVE will
    want to have horizon edges/curves used if already there or will produce
    them if needed.

PARAMETERS
    flag: (IN): cuves or edges flag
    
GLOBALS USED
    tiling_parms
    
HISTORY
        Tim Fox
        Created: 06/20/94
*/

void HSset_curve_type_to_curve( IGRboolean flag )
    {
    if( flag )
        tiling_parms.processing_mode |= HS_PMODE_CREATE_HRZ_CVS;
    else
        tiling_parms.processing_mode &= ~HS_PMODE_CREATE_HRZ_CVS;
    }

/*---HSis_curve_type_equal_curve------------------------------------------------------*/

/*
NAME
    HSset_curve_type
    
DESCRIPTION
    returns the type of curve that is to be output from low/med CVE or PDD.
    PDD will want the curve type to be set to horizon curve while CVE will
    want to have horizon edges/curves used if already there or will produce
    them if needed.

PARAMETERS
    flag: (IN): cuves or edges flag
    
GLOBALS USED
    tiling_parms
    
HISTORY
        Tim Fox
        Created: 06/20/94
*/

int HSis_curve_type_equal_curve()
    {
    if( tiling_parms.processing_mode & HS_PMODE_CREATE_HRZ_CVS )
        return(1);
    else
        return(0);
    }

