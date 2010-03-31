#include <stdio.h>
#include <stdlib.h>
#if defined (CLIX)
#include <EG.h>
#endif
#include "wl.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "hplot.h"
#include "gr.h"
#include "hstiler.h"
#include "hslight.h"
#include "HStl_window.h"
#include "HStl_global.h"
#include "HStl_element.h"
#include "HSfem_spt.h"
#include "HPglobal.h"
#include "HPtiming.h"
#include "HSplot_def.h"
#include "hsdisplay.h"
#include "HSd_fixedpt.h"
#include "HPpr_hplot_f.h"

/*-----------------------
 *  for
 *     HSfetch_plotting_xrange
 *     HSreset_plotting_xrange
 *     HSset_clip_mode
 */

#include "HSe2_mesher.h" 
#include "HSpr_tiler_f.h"

/*------------------------*/

static int	cliphi, cliplo;
	
/*---HPfini_zbuffering--------------------------------------------------*/

/*
NAME
	HPfini_zbuffering
	
KEYWORD
	HSplot
	banding
	question arguments
	
DESCRIPTION
	Collects all the curve from the remember buffers and sends them
	to the tiler for processing for band 1.  Then, if in multiband
	mode, collects the surfaces and curves from the remember buffer,
	performs range test, and sends those that are within range of
	the current band to the tiler for processing
	
PARAMETERS
	file_ptr   :(IN) :  File pointer to the input shaded plot file
	rle_width  :(OUT):  width in pixels of the output raster data (needed???)
	rle_length :(OUT):  length in pixels of the output raster data (needed???)
	
GLOBALS USED
	HPglobal
	tiling_parms
	HPband_info

FUNCTIONS CALLED
	ftell
	HPget_next_object_curv
	HPreset_banding
	HSset_clip_mode
	HSreset_plotting_xrange
	HPzbuffered_curve
	HSfetch_plotting_xrange
	HPremember_minmax
	HPget_next_object_surf
	HPzbuffered_surface
	HPfree_band_memory
	fseek
	
HISTORY
	??/??/??	M. Lanier
		Created
		
*/

#if defined(__STDC__) || defined(__cplusplus)
	int HPfini_zbuffering    (FILE *file_ptr, 
				   int *rle_width, 
				   int *rle_length )			   
#else
	int	HPfini_zbuffering( file_ptr, rle_width, rle_length )

	FILE	*file_ptr;
	int	*rle_width;
	int	*rle_length;
#endif

	{
	long			file_marker=0.0;
	int			status, more;
	int			xmin, xmax;
	int			count, object_type;
	struct HPbanding_info	*object;

	/*
	 *  Reset the banding buffers and collect all the curve, sending
	 *  them to the curve tiler form processing.
	 */
	 	
	HPreset_banding();
	more = 1;
	while( more )
		{
		more = HPget_next_object_curv( 
				file_ptr,
				&HPglobal.active_color,
				&HPglobal.translucency,
				&object_type,
				&HPglobal.rendering_mode,
				&HPglobal.tiling_tolerance,
				&HPglobal.line_width,
				&HPglobal.line_style,
				&xmin, &xmax,
				&count,
                         &HPglobal.objid,
                         &HPglobal.osnum,
				&object );

		/*
		 *  If the curve is really an edge, mark its type in
		 *  the processing mode mask
		 */
		 
		if( object_type == NURB_EDGE || object_type == oldNURB_EDGE )
			tiling_parms.processing_mode |=  HS_PMODE_EDGE_OBJECT;
		else
			tiling_parms.processing_mode &= ~HS_PMODE_EDGE_OBJECT;

		/*
		 *  HPget_next_object_curv will return a 1 until it returns
		 *  the last curve.
		 */
		 
		if( more != 2 )
			{
				
			/*
			 *  Turn clipping on and reset the xrange.  This is
			 *  a min/max in the tiler that collects the transformed
			 *  x range of the curve.
			 */
			 
			HSset_clip_mode( TRUE );
			HSreset_plotting_xrange();
		
			/*
			 *  process the curve
			 */
			 
			status = HPzbuffered_curve( 
					file_ptr, 
					count,
                                        object_type );
			
			/*
			 *  Get the x range from the tiler and added it to the
			 *  curves banding information.
			 */
			 	
			HSfetch_plotting_xrange( &xmin, &xmax );
			HPremember_minmax( object, xmin, xmax );
								
			if( status ) goto wrapup;
			}
		else
			{
			more = 0;
			}
		}

	/*
	 *  Write the first band's data to the output file.
	 */
	 
	HPfini_band();

	file_marker = ftell( file_ptr );	

	/*
	 *  Process the rest of the bands
	 */
	 
	while( HPglobal.band_count++ < HPglobal.total_bands )
		{
		
		/*
		 *  Initialize the next band
		 */
		 
		HPinit_band();
		HPreset_banding();

		/*
		 *  Get the x range of this band
		 */
		 
 		cliphi = (int)(HPband_info.clip_range[3]);
		cliplo = (int)(HPband_info.clip_range[0]);
		
		/*
		 *  Get the surfaces and process
		 */
		 
		more = 1;		
		while( more )
			{
			more = HPget_next_object_surf( 
					file_ptr,
					&HPglobal.active_color,
					&HPglobal.translucency,
					&HPglobal.trans_grid,
					&HPglobal.rendering_mode,
					&HPglobal.tiling_tolerance,
					&HPglobal.line_width,
					&HPglobal.line_style,
					&xmin, &xmax,
					&count,
                                        &HPglobal.objid,
                                        &HPglobal.osnum );
			
			if( more == 2 )
				{
				more = 0;
				}
			else
				{
					
				/*
				 *  Only process the curve if it range is in
				 *  the current band
				 */
				 
				if( (xmin >= cliplo && xmin <= cliphi) ||
				    (xmax >= cliplo && xmax <= cliphi) ||
				    (xmin <  cliplo && xmax  > cliphi) )
					{
					HSset_clip_mode( TRUE );
					status = HPzbuffered_surface(
							file_ptr,
							NULL,
							count );

					if( status ) goto wrapup;
					}
				}
			}

		/*
		 *  Get the curves and process
		 */
		 		
		more = 1;
		while( more )
			{
			more = HPget_next_object_curv( 
					file_ptr,
					&HPglobal.active_color,
					&HPglobal.translucency,
					&object_type,
					&HPglobal.rendering_mode,
					&HPglobal.tiling_tolerance,
					&HPglobal.line_width,
					&HPglobal.line_style,
					&xmin, &xmax,
					&count,
                                        &HPglobal.objid,
                                        &HPglobal.osnum,
					&object );


			if( object_type == NURB_EDGE || object_type == NURB_EDGE )
				tiling_parms.processing_mode |=  HS_PMODE_EDGE_OBJECT;
			else
				tiling_parms.processing_mode &= ~HS_PMODE_EDGE_OBJECT;
			
			if( more == 2 )
				{
				more = 0;
				}
			else
				{
					
				/*
				 *  Only process those that are in the band
				 */
				 
				if( (xmin >= cliplo && xmin <= cliphi) ||
				    (xmax >= cliplo && xmax <= cliphi) ||
				    (xmin <  cliplo && xmax  > cliphi) )
					{
					HSset_clip_mode( TRUE );

					status = HPzbuffered_curve(
							file_ptr,
							count,
                                                        object_type );

					if( status ) goto wrapup;
					}
				}
			}

		/*
		 *  Write the next bands info into the output file
		 */
		 
		HPfini_band();
		}

	status = HP_I_Success;

wrapup:
	fseek( file_ptr, file_marker, 0 );
					
	HPfree_band_memory();

	*rle_length = HPglobal.xdits;
	*rle_width  = HPglobal.ydits - HPglobal.total_bands;

	return( status );
	}
