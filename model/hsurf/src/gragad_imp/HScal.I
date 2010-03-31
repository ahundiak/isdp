
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

class implementation HSgragad;


#include <stdio.h>

#include "wl.h"

#include "OMminimum.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "msdef.h"
#include "bserr.h"
#include "bsparameters.h"

#include "hskyoptypes.h"
#include "hsanimate.h"
#include "hstiler.h"
#include "hsmacdef.h"

#include "HSrle.h"
#include "HSsara.h"
#include "HSfem_spt.h"
#include "HStl_window.h"
#include "HStl_global.h"
#include "HStl_element.h"

/*--------------------------
 *  for functions
 *     HSget_region_hardware_type
 *     HSget_region_original_type
 *     HSget_region_style
 *     HSget_region_update
 *     HSget_region_xy_minmax
 */
 
#include "HSe2_mesher.h"
#include "hsdisplay.h"
#include "HSpr_tiler_f.h"

/*------------------------------*/


/*---DPcal------------------------------------------------------------------*/

method DPcal( IGRlong *msg )

/*
NAME
	HSgragad.DPcal

DESCRIPTION
	This method is overridden so the transformation matrices in the tiler
	can be updated whenever the matrices in the IGEgragad are changed.
	The main reason for this is to handle view-independent elements.  When
	the GRNUC display code encounters a view-independent element, it
	changes the matrices in the IGEgragad to handle it.  The only way to
	catch this during an update is to override this method.

PARAMETERS
	msg (OUT) - routine status

GLOBALS USED
	none

RETURN VALUES
	OM_S_SUCCESS - if successful

HISTORY
	xx/xx/xx    Unknown programmer
	   Creation Date
	01/14/91    S.P. Rogers
	   Added parameters to HSreset_transformation_matrix to support EdgeII and
	   added prologue documentation
	06/03/92    Joel D. Underwood
	   Fixed Display region for view independent text.  The matrices
	   translations display region did were lost when the new matrix 
	   of view independent text was inserted so I had to set back.  
*/
	
{
	IGRint			sts;
	IGRlong			bytes_returned;
	IGRboolean		region_update=FALSE;
	IGRint			xlo,ylo,xhi,yhi;
	IGRboolean		wire_display,rhl_display,wire_window,shd_window,hwzbuf;
	IGRint			orig_style,style,type;
	IGRdouble		post_rotation[4][4];
	struct var_list		var_list[2];
	IGRlong			msg1, error;
	IGRint			raster_offset=0;
	IGRshort		rect;
	IGRshort		front;
	IGRshort		back;

	sts = om$send(
		mode     = OM_e_wrt_message,
		msg      = message IGEgragad.DPcal( msg ),
		targetid = my_id );

	if( !(sts & 1) )
	{
		om$report_error(sts = sts);
		return( sts );
	}
			
	if ( ME.IGEgragad->gragad.flags & IS_PERSP )
	{
		/* can only get post rotation matrix from perspective views */
		var_list[0].var		   = POST_ROTATION;
		var_list[0].var_ptr	   = (IGRchar *) post_rotation;
		var_list[0].num_bytes	   = sizeof(IGRdouble)*16;
		var_list[0].bytes_returned = &bytes_returned;
		var_list[1].var		   = END_PARAM;

		dp$inq_set_gragad(
			msg		= &msg1, 
			which_error	= &error,
			var_list	= var_list,
			gragad_objid	= my_id,
			osnum		= OM_Gw_current_OS );
	}

	HSget_region_update(&region_update);
	if (region_update)
	{
		HSget_region_style( &style );
		HSget_region_original_style( &orig_style );
		wire_display=(style == HS_STYLE_WIREFRAME);
		rhl_display=(style==HS_STYLE_RASTER||
			style==HS_STYLE_FILLED_RASTER);
		wire_window=(orig_style == HS_STYLE_WIREFRAME);
		shd_window =(orig_style==HS_STYLE_SMOOTH)||
			(orig_style==HS_STYLE_CONSTANT);
		HSget_region_hardware_type( &type );
		hwzbuf=(type&HShardware_ZB_MASK)?1:0;
		HSget_region_xy_minmax(&xlo,&ylo,&xhi,&yhi);
		if ((hwzbuf&&rhl_display&&shd_window)||
		            (rhl_display&&wire_window))
		{
			/* when you are allocating a region size zbuffer and
			   are drawing a raster region, there will be 1 row
			   of pixels added all the way around the zb and cb.
			   (so comparisons of neighbors around the edge do 
			   not cause a memory fault).  To compensate for this
			   You have to make the region bigger by 4 bytes
			   and paint in 4 bytes (put line has to be 32 bit
			   alligned */
			raster_offset=3;
		} else  raster_offset=0;
		
		if ((!hwzbuf&&wire_window&&!wire_display)||
			(hwzbuf&&rhl_display&&(wire_window||shd_window)))
		{
			ME.IGEgragad->gragad.wld_to_viewport[0][3]-=
				(double) (xlo-raster_offset);
			ME.IGEgragad->gragad.wld_to_viewport[1][3]-=(double) ylo;
    			ME.IGEgragad->gragad.dit_clip_range[0]=0.0;
			ME.IGEgragad->gragad.dit_clip_range[1]=0.0;
			ME.IGEgragad->gragad.dit_clip_range[3]=
				(double) (xhi-xlo+raster_offset);
			ME.IGEgragad->gragad.dit_clip_range[4]=(double) (yhi-ylo);
		}
		if (wire_display)
		{
  			ME.IGEgragad->gragad.dit_clip_range[0]=(double) xlo;
			ME.IGEgragad->gragad.dit_clip_range[1]=(double) ylo;
			ME.IGEgragad->gragad.dit_clip_range[3]=(double) xhi;
			ME.IGEgragad->gragad.dit_clip_range[4]=(double) yhi;
		        rect = ME.IGEgragad->gragad.flags & CLIP;
		        front = ME.IGEgragad->gragad.flags & FRONT_CLIP;
		        back = ME.IGEgragad->gragad.flags & BACK_CLIP;
		        DPpush_clip(msg,rect,front,back,ME.IGEgragad->gragad.dit_clip_range,
				    ME.IGEgragad->gragad.gpipe_id);
		}
	}

	HSreset_transformation_matrix( 
		ME.IGEgragad->gragad.gpipe_id, 
		ME.IGEgragad->gragad.wld_to_view,
		ME.IGEgragad->gragad.wld_to_viewport,
		ME.IGEgragad->gragad.rotation, 
		post_rotation,
		ME.IGEgragad->gragad.vw_volume,
		ME.IGEgragad->gragad.eye_pt,
		ME.IGEgragad->gragad.vrp,
		ME.IGEgragad->gragad.vpn,
		ME.IGEgragad->gragad.vup,
		(me->max_x_dep - me->min_x_dep) + 1,
		(me->max_y_dep - me->min_y_dep) + 1 );

	return(sts);
}


end implementation HSgragad;

