
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

class implementation Root;

#include "OMminimum.h"
#include "igrtypedef.h"
#include "sys/types.h"
#include "sys/dirent.h"
#include <stdio.h>
#include <tools.h>
#include "FI.h"

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"

#include "msdef.h"

#include "igetypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"

#include "dp.h"
#include "dpdef.h"
#include "dpstruct.h"

#include "godef.h"
#include "gr.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "emsdattyp.h"
#include "emsinter.h"
#include "emsdef.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "EMSsfparms.h"
#include "EMSssprops.h"

#include "hplot_imp.h"
#include "HSplot.h"
#include "HSplot_def.h"
#include "DEso.h"
/*#include "DEglob.h"*/

#include "HSpr_hplot.h"

#define DEBUG			0
#define DEBUG_COUNT		0
#define CHECK_RETURN_CODES	1
#define INITIAL_SIZE 		10
#define	MAX_BOUNDS		1000

#define if_bad(status)	if(!((status)&1))

from EMSloopset		import EMget_loops, EMget_props;
from EMSloop		import EMrgpack;
from EMSboundary	import EMget_edges;
from EMSedge		import EMget_props, EMgetbcgeom;
from EMSsurface		import EMget_params;
from EMSsubbs		import EMget_props;
from DEso		import DEget;

from GRvg		import GRgetrang;
from GRvg		import GRgetsymb;
from GRvg		import GRgetprops;
from GRvg		import GRgeomprops;
from GRvg		import GRgetsize;
from GRvg		import GRgetgeom;

%safe
static int	ccount = 0;
%endsafe

/*---HPwrite_curve----------------------------------------------------------*/

/*
NAME
	HPwrite_curve
	
KEYWORDS
	shaded plotting
	
DESCRIPTION
	Get the geometry of a curve object, and its parameters and
	write into the shaded plotfile
	
PARAMETERS
	elem		:(IN) : objid, osnum of the curve object
	matrix_type	:(IN) : environment matrix type
	matrix		:(IN) : environment matrix
	object_env	:(IN) : object environment info
	info		:(IN) : shaded plotting global information
	
HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	void	HPwrite_curve( struct GRid *elem,
				  IGRshort *matrix_type,
				 IGRmatrix matrix,
			   struct GRmd_env *object_env,
			struct HSplot_info *info )
#else
	void	HPwrite_curve(  elem, 
				matrix_type,
				matrix, 
				object_env,
				info )

	struct GRid		*elem; 
	IGRshort		*matrix_type; 
	IGRmatrix		matrix;
	struct GRmd_env		*object_env;
	struct HSplot_info	*info;
#endif

	{
	IGRlong				msg;
	int				status;
	
	static int			bs_ptr_size = 0;
	static struct IGRbsp_curve	*bs_ptr = NULL;
	
	IGRboolean			world = TRUE;
	IGRint				style;
	IGRlong				object_size;
	GRrange				range;

	IGRint				i;
	IGRint				*p_types;
	IGRdouble			*p_parms;
	struct IGRdisplay		*p_attr;
	IGRint				p_count;


#	if DEBUG_COUNT
	if( ((++ccount) % 100) == 0 )
	fprintf( stderr, "curve #%1d\n", ccount );
#	endif

	/*
	 * the object is a B-spline curve.
	 */

#       if DEBUG
	fprintf( stderr, "object is a GRbspline\n");
#       endif

	status = om$send( msg = message GRvg.GRgetrang(
						&msg,
						matrix_type,
						matrix,
						&world, range),
		     senderid = elem->objid,
		     targetid = elem->objid,
		     targetos = elem->osnum );

	OM_ERRCHK( status, "failed to GRgetrang\n" );
	if_bad(status) goto wrap_up;

	info->symbology->display_attr.color = ((info->symbology->display_attr.color-1) % info->num_colors) + 1;

	status = HPwrite_symbology( (IGRint *)&info->file_id, &info->symbology->display_attr );
	if( status != OM_S_SUCCESS ) goto wrap_up;

	/* 
	 * allocate space for geometry and retrieve it.
	 */
	 
	status = om$send( msg = message GRvg.GRgetsize( 
						&msg, 
						matrix_type,
						matrix,
						&object_size ),
		     senderid = elem->objid,
		     targetid = elem->objid,
		     targetos = elem->osnum );
		
	OM_ERRCHK( status, "failed to GRgetsize\n" );
	if_bad( status & msg ) goto wrap_up;

#	if DEBUG
	fprintf( stderr, "object_size=%d\n", object_size);
#	endif
	
	if( bs_ptr == NULL )
		{
		bs_ptr_size = (object_size + 256) & 0x7fffff00;
		bs_ptr = (struct IGRbsp_curve *)malloc( bs_ptr_size );
		}
	else
		{
		if( object_size > bs_ptr_size )
			{
			free( bs_ptr );
			bs_ptr_size = (object_size + 256) & 0x7fffff00;
			bs_ptr = (struct IGRbsp_curve *)malloc( bs_ptr_size );
			}
		}
    
	status = om$send( msg = message GRvg.GRgetgeom (
					&msg,
					matrix_type,
					matrix,
					(IGRchar *)bs_ptr ),
		     senderid = elem->objid,
		     targetid = elem->objid,
		     targetos = elem->osnum );
       
	OM_ERRCHK( status, "failed to GRgetgeom\n" );    
	if_bad( status ) goto wrap_up;

	/* 
	 * write rendering mode and translucency
	 */
	
	status = HPwrite_rendering( (IGRint *)&info->file_id, elem->objid, elem->osnum, &style );
	if( status != OM_S_SUCCESS ) goto wrap_up;
	
	/*
	 * write a draw with range command header.
	 */
     
	status = HPwrite_draw_range( 
			(IGRint *)&info->file_id,
			NURB_CURVE,
			info->symbology->level,
			range );
	    
	if( status != OM_S_SUCCESS ) goto wrap_up;

	/*
	 *  check to see if this object has any soo's attached for
	 *  the display window
	 */

	if( (info->properties & DEHAS_OVERRIDE) && (DEsos) )
		{
		struct GRmd_env	master_env;
		IGRint		sizbuf, nret;
				
		sizbuf = sizeof( struct GRmd_env );
	
		gr$get_module_env(
			   msg = &msg,
			sizbuf = &sizbuf,
			buffer = &master_env,
			  nret = &nret );
		
		status = om$send( msg = message DEso.DEget( 
							&msg,
							&p_types,
							&p_parms,
							&p_count,
							&p_attr,
							&info->symbology->display_attr,
							elem->objid,
							info->window.objid,
							matrix_type,
							matrix,
							2, TRUE ),  /* manual SOs only */
			     senderid = NULL_OBJID,
			     targetid = DEsos[elem->osnum],
			     targetos = master_env.md_id.osnum );

                if ( !(1 & status & msg) )
                        {
                        p_count = 0;
                        }

		}
	else
		{
		p_count = 0;
		}
	
#	if DEBUG
	for( i=0, j=0; i<p_count; i++, j+=2 )
		{
		fprintf( stderr, "      Parms %d = %f - %f\n",
						i,
						p_parms[j], p_parms[j+1] );
					
		fprintf( stderr, "      Color  = %d\n", p_attr[i].color);
		fprintf( stderr, "      Style  = %d\n", p_attr[i].style);
		fprintf( stderr, "      Weight = %d\n", p_attr[i].weight);
		}
#	endif

	/* 
	 * write the curve data.
	 */
     
	status = HPwrite_curve_info( (IGRint *)&info->file_id, bs_ptr, 3, (p_count > 0) );
	if( status != OM_S_SUCCESS ) goto wrap_up;
		    
	if( p_count > 0 )
		{
		status = HPwrite_curve_soo( (IGRint *)&info->file_id, p_parms, p_attr, p_count, p_types );
		if( status != OM_S_SUCCESS ) goto wrap_up;
		
		for( i=0; i<p_count; i++ )
			HPwrite_line_style( (IGRint *)&info->file_id, p_attr[i].style );
		}

	info->con_flags |= HP_CONTROL_WRITTEN_TO_PLOTFILE;
	return;
		
wrap_up:

	info->con_flags |= HP_CONTROL_WRITE_TO_PLOTFILE_ERROR;
	return;
	}
	
end implementation Root;
