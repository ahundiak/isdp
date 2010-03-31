
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:38 $
$Locker:  $
*/

 
class implementation Root;
 
#define CHECK_RETURN_CODES 1

#define DEBUG_LOCATE 0

#include <stdio.h>
/*#include <unistd.h>*/
#include "FI.h"
#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "growner.h"
#include "bs.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "msdef.h"
#include "hsurferrpriv.h"
#include "HStl_element.h"
#include "hrstruct.h"
#include "hsmsg.h"
#include "igr.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "godef.h"
#include "go.h"
#include "HSplot.h"

#include "wl.h"
#include "HSpr_hplot.h"

/*-----------------------------------
 *  for function
 *     HSclassify_located_function
 */
 
#include "HSpr_lvhl.h"

/*-----------------------------------*/



static struct GRsymbology	symbology;
static IGRshort			properties;

from GRvg import GRgetsymb;
from GRvg import GRgetprops;


%safe
/*
 *  Prototype declaration for static functions
 */


#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* HPcollect.I */
static IGRint HPstub __((IGRshort object_os, 
	 	     IGRboolean is_symbol));

static void HPstub2 __((OM_S_OBJID text_id, 
			   OMuword text_os, 
			 IGRdouble *matrix, 
			  IGRshort matrix_type, 
		   struct GRmd_env *master_env));

#if defined(__cplusplus)
}
#endif


#undef __


%endsafe

static IGRint	HPstub(IGRshort object_os, 
		     IGRboolean is_symbol) { return(TRUE); }

static void HPstub2 (OM_S_OBJID text_id, 
		        OMuword text_os, 
		      IGRdouble *matrix, 
		       IGRshort matrix_type, 
		struct GRmd_env *master_env) {}
/*
extern void	HPwrite_surface();
extern void	HPwrite_curve();
*/

/*---- HPcollect_elements_to_plot -------------------------------------------*/

/*
NAME
	HPcollect_elements_to_plot
	
KEYWORDS
	shaded plotting
	collect and classify
	
DESCRIPTION
	Take each object id from the list of objects collected for
	the create shaded plot file command and send it to the classify
	function.
	
PARAMETERS
	info		:(IN) : shaded plotting global information
	co_grid		:(IN) :
	gschanset	:(IN) :
	master_layers	:(IN) :
	
GLOBALS USED
	-none-
	
FUNCTIONS CALLED 
	HSclassify_located_objects
	MSG_ERRCHK
	OM_ERRCHK
	gr$gsempty
	gr$gsget_objects
	gr$gsinqcount
	om$send
		GRvg.GRgetprops
		GRvg.GRgetsymb

HISTORY
	??/??/??	M. Lanier
		Created
*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRint	HPcollect_element_to_plot( struct HSplot_info *info,
						  struct GRid *co_grid,
					      OM_S_CHANSELECT *gschansel,
						       IGRint *master_layers )
#else
	IGRint	HPcollect_element_to_plot( 
				info,
				co_grid, 
				gschansel, 
				master_layers )

	struct HSplot_info	*info;
	struct GRid		*co_grid;
	OM_S_CHANSELECT		*gschansel;
	IGRint			*master_layers;
#endif

	{
	IGRlong          sts;
	IGRlong          msg;
	IGRint           num_ret;
	IGRint           i;
	IGRint           object_count;
	struct GRobj_env obj_info;
	IGRint		 status;
	struct GRid		fence_grid;

	fence_grid.objid = NULL_OBJID;
	fence_grid.osnum = 0;

	/* find out how many objects were located */

	sts = gr$gsinqcount( msg          = &msg,
	                     count        = &object_count,
	                     senderid     = co_grid->objid,
	                     senderos     = co_grid->osnum,
	                     p_chanselect = gschansel );

	OM_ERRCHK( sts, "HPcollect_elements_to_plot: gr$gsinqcount OM error" );
	MSG_ERRCHK( msg, "HPcollect_elements_to_plot: gr$gsinqcount failed" );
	
#	if DEBUG_LOCATE
	fprintf( stderr, "Objects on channel:  %d\n\n", object_count );
	fprintf( stderr, "The located objects are:\n\n" );
#	endif

	/* get each located object individually and classify it */

	status = OM_S_SUCCESS;
		
	for( i=0; i<object_count; i++ )
		{
		sts = gr$gsget_objects( 
				msg          = &msg,
				array        = &obj_info,
				size         = sizeof( struct GRobj_env ),
				count        = &num_ret,
				from_obj     = i,
				to_obj       = i,
				senderid     = co_grid->objid,
				senderos     = co_grid->osnum,
				p_chanselect = gschansel );

        	OM_ERRCHK( sts, "HPcollect_elements_to_plot: gr$gsget_objects OM error" );
    		MSG_ERRCHK( msg, "HPcollect_elements_to_plot: gr$gsget_objects failed" );

		if( (1 & msg & sts) )
			{
			if( obj_info.obj_id.objid != info->fence.objid || obj_info.obj_id.osnum != info->fence.osnum )
				{
				status = om$send( msg = message GRvg.GRgetsymb( &msg, &symbology ),
					     senderid = obj_info.obj_id.objid,
					     targetid = obj_info.obj_id.objid,
					     targetos = obj_info.obj_id.osnum );

				status = om$send( msg = message GRvg.GRgetprops( &msg, &properties ),
					     senderid = obj_info.obj_id.objid,
					     targetid = obj_info.obj_id.objid,
					     targetos = obj_info.obj_id.osnum );
		     
				info->properties = properties;
				info->symbology = &symbology;

				HSclassify_located_object(
						&obj_info.obj_id,
						&obj_info.mod_env,
						obj_info.mod_env.md_env.matrix,
						&obj_info.mod_env.md_env.matrix_type,
						&fence_grid,
						TRUE,
						HPstub,
						HPwrite_surface,
						HPwrite_curve,
						HPstub2,
						(IGRchar *)info,
						NULL );

				if( status == HS_E_PltFlWrtErr ) break;
				}
			}
		}

	/* empty the located object channel */
	
	gr$gsempty( msg          = &msg,
	            senderid     = co_grid->objid,
	            senderos     = co_grid->osnum,
	            p_chanselect = gschansel );
	            
	MSG_ERRCHK( msg, "HPcollect_elements_to_plot: gr$gsempty failed" );
	
	return( status );
	}

end implementation Root;

