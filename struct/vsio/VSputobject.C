/*
	I/STRUCT
*/
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
/*----------------------------------------------------------------------------*/
int VSputObjectToQueue( msg, objid, osnum, env, position )

long		*msg ;
OM_S_OBJID	objid ;
OMuword		osnum ;
struct GRmd_env	*env ;
long		position ; {

	/*
	 * Build a fake event to put object id onto software input queue.
	 */
	struct GRevent	toPut ;
	long		size ;
	int		nbytes,
			resp ;

	size = sizeof toPut.event.button ;
	
	gr$get_last_point(	msg	= msg,
				sizbuf	= &size,
				buffer	= &toPut.event.button,
				nret	= &nbytes ) ;

	toPut.located_object[0].module_info = *env ;
	toPut.response	= EX_DATA ;

	toPut.event.button.x	= toPut.event.button.y
				= toPut.event.button.z = 0. ;

	toPut.num_id	= 1 ;
	toPut.num_val	= 0 ;
	toPut.subtype	= GRst_LOCATE;

	toPut.located_object[0].located_obj.objid = objid ; 
	toPut.located_object[0].located_obj.osnum = osnum;
	toPut.located_object[0].geom_parms.u = 0. ;
	toPut.located_object[0].geom_parms.v = 0. ;
	toPut.located_object[0].geom_parms.polygon_inx = 2 ;

	size = sizeof( struct GRevent ) - 2 * sizeof( long ) ;

	resp = EX_OBJID ;
	ex$putque(	msg	= msg,
			response= &resp,
			byte	= &size,
			buffer	= (char *) &toPut.event.button,
			pos	= position ) ;

	return *msg & 1 ;

} /* VSputObjectToQueue */
/*----------------------------------------------------------------------------*/


