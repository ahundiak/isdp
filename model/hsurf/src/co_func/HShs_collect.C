  
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:35 $
$Locker:  $
*/

#define CHECK_RETURN_CODES 1


#define DEBUG_LOCATE	0

#include <stdio.h>

#include "wl.h"

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"

#include "msdef.h"
#include "msmacros.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"

#include "gr.h"
#include "growner.h"

#include "bs.h"

#include "grgs.h"
#include "grgsmacros.h"

#include "hsurferrpriv.h"
#include "HStl_global.h"

#include "hsurf.h"
#include "HSlvhl.h"
#include "hskyoptypes.h"
#include "hsanimate.h"
#include "HSrle.h"
#include "HSsara.h"

#include "HSpr_co_func.h"


/*
 *  Prototype declaration for static functions
 */


#if defined (__) 
#undef __
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* HShs_collect.C */
static IGRint HShs_always_TRUE __((void));
static void HShs_stub __((void));


#if defined(__cplusplus)
}
#endif


#undef __


/*
extern int	HSprocess_soos_on_solid();
extern int	HSprocess_soos_on_curve();
*/

static IGRint	HShs_always_TRUE() { return( TRUE ); }
static void	HShs_stub() {}

/*---HScollect_hidden_symbology_overrides-------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRboolean HScollect_hidden_symbology_overrides( struct GRid *co_grid,
							 struct GRid *window,
						     OM_S_CHANSELECT *gschansel,
							      IGRint mode,
							   IGRdouble *rotation )
#else
	IGRboolean HScollect_hidden_symbology_overrides( 
			co_grid, 
			window, 
			gschansel, 
			mode,
			rotation )

	struct GRid	*co_grid;
	struct GRid	*window;
	OM_S_CHANSELECT	*gschansel;
	IGRint		mode;
	IGRdouble	*rotation;
#endif

/*
NAME
	HScollect_hidden_symbology_overrides

DESCRIPTION
	Collect and sort all of the elements specified by the user and 
	process the automatic symbology overrides on them.  The objects
	should be in a graphics set that is connected to a channel declared in a
	command object.  This is the channel that is passed in to this function.

PARAMETERS
	co_grid (IN) - the GRid of the command object whose channel has the graphics set
	window (IN) - the GRid of the window that the SOs are to be removed from
	gschansel (IN) - the channel selector for the graphics set channel
	mode (IN) - flag indicating whether to delete or dump(debug) SOs
	rotation (IN) - the rotation matrix for the window

GLOBALS USED
	none

RETURN VALUES
	TRUE

HISTORY
	05/15/87    S.P. Rogers
	   Creation Date
	05/17/91    Mike Lanier
	   Copied and modified for Convert/Delete Hidden Symbology
*/

	{
	IGRlong			sts;
	IGRlong			msg;
	IGRint			num_ret;
	IGRint			i;
	IGRint			object_count;
	struct GRid		fence_grid;
	struct GRobj_env	obj_info;
	IGRboolean		stat;

	fence_grid.objid = NULL_OBJID;
	fence_grid.osnum = 0;
	
	gr$gsget_fence( msg = &msg, 
		   fence_id = &fence_grid );

	/* 
	 * find out how many objects were located 
	 */
	 
	sts = gr$gsinqcount( msg = &msg,
			   count = &object_count,
			senderid = co_grid->objid,
			senderos = co_grid->osnum,
		    p_chanselect = gschansel );

	OM_ERRCHK( sts, "HScollect_hidden_symbology_overrides: gr$gsinqcount OM error" );
	MSG_ERRCHK( msg, "HScollect_hidden_symbology_overrides: gr$gsinqcount failed" );

#	if DEBUG_LOCATE
		fprintf( stderr, "Objects on channel:  %d\n\n", object_count );
		fprintf( stderr, "The located objects are:\n\n" );
#	endif

	/* 
	 * get each located object individually and classify it 
	 */

	stat = TRUE;
	
	HSinit_delete_detail_display( window, mode, rotation );
	
	for( i=0; i<object_count; i++ )
		{
		sts = gr$gsget_objects( msg = &msg,
				      array = &obj_info,
				       size = sizeof( struct GRobj_env ),
				      count = &num_ret,
				   from_obj = i,
				     to_obj = i,
				   senderid = co_grid->objid,
				   senderos = co_grid->osnum,
			       p_chanselect = gschansel );

		OM_ERRCHK( sts, "HScollect_hidden_symbology_overrides: gr$gsget_objects OM error" );
		MSG_ERRCHK( msg, "HScollect_hidden_symbology_overrides: gr$gsget_objects failed" );

		if( (1 & msg & sts) )
			{
			
			/*
			 *  save the module environment information for the surface
			 */
			 
			memcpy( &HSlvhl.md_env, &obj_info.mod_env, sizeof( struct GRmd_env ) );
			
			HSclassify_located_object( 
				&obj_info.obj_id, 
				&obj_info.mod_env.md_id, 
				obj_info.mod_env.md_env.matrix,
				&obj_info.mod_env.md_env.matrix_type,
				&fence_grid,
				FALSE,
				HShs_always_TRUE,
				HSprocess_soos_on_solid,
				HSprocess_soos_on_curve,
				HShs_stub,
				NULL,
				NULL );
			}
		}
	
	/* 
	 * empty the located object channel
	 */
	 
	gr$gsempty( msg = &msg,
	       senderid = co_grid->objid,
	       senderos = co_grid->osnum,
	   p_chanselect = gschansel );

	MSG_ERRCHK( msg, "HScollect_hidden_symbology_overrides: gr$gsempty failed" );

	return( stat );
	}
