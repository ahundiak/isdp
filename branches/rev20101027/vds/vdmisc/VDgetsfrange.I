/*
	I/VDS	Copy.
*/
class implementation OMindex ;

#include <stdio.h>
#include "OMerrordef.h"
#include "igetypedef.h"		/* IGE typedefs GR*		*/
#include "exmacros.h"
#include "msdef.h"
#include "EMSutlmacros.h"
#include "growner.h"
#include "v_miscmacros.h"
#include "v_geommacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "v_ocgrleaves.h"

from OMrtree	import	find_key ;
from GRgraphics import	GRgetrang ;
/*----------------------------------------------------------------------------*/
int VD_getSfRange( msg, object, objRange )

long		*msg ;
struct GRid	*object ;
GRrange		objRange ; {

	/*
	 * Gets the range of an object which is in the R-tree.
	 * Returns a range significantly smaller than that returned by
	 * GRgraphics.GRgetrang.
	 * This function interfaced by macro vd_$getSurfaceRange.
	 */

	long		sts ;
	int		ret ;		/* OM's Find_key return code	*/
	DB_3D_DBL_BOX	queryRng ;	/* Biggest range possible	*/
	OM_S_CHANSELECT	toR_Tree ;	/* Module-to-R-tree channel	*/
	OM_S_KEY_DESC	searchKey,	/* Where to look for range	*/
			objectKey ;	/* Found range for object	*/
	OM_S_OBJID	module ;	/* Object id of object's module	*/

	queryRng.xmin = queryRng.ymin = queryRng.zmin = -MAXDOUBLE ;
	queryRng.xmax = queryRng.ymax = queryRng.zmax =  MAXDOUBLE ;
 
	ems$make_chanselect( chan_label    = module_primary,
			     chan_selector = &toR_Tree ) ;
 
	/*
	 * Get object's module.
	 */
	ex$get_modid(	mod_osnum	= object->osnum,
			mod_id		= &module ) ;
	
	objectKey.type = searchKey.type = KEY_3D_DBL ;
	searchKey.key.p_3ddbl		= &queryRng ;
	objectKey.key.p_3ddbl		= (DB_3D_DBL_BOX *) objRange ;

	/*
	 * Query R-tree.
	 */
	sts = om$send(	msg		= message OMrtree.find_key(
								&searchKey,
								&object->objid, 
								&objectKey,
								0,
								&ret ),
			p_chanselect	= &toR_Tree,
			senderid	= module,
			targetos	= object->osnum ) ;
	if( !( 1 & sts ) || ret ) {
		*msg = EMS_E_OMerror ; goto wrapup ;
	} else	{
		sts	= OM_S_SUCCESS ;
		*msg	= MSSUCC ;
	}
	wrapup:
		return sts ;

} /* VD_getSfRange */
/*----------------------------------------------------------------------------*/
long VD_getRangeOfComposite( msg, object, objRange )

long		*msg ;
struct GRobj_env*object ;
GRrange		objRange ; {

	/*
	 * Gets the range of an object which is made of components which are in
	 * the R-tree (such as solids).
	 * This function interfaced by macro vd_$getRangeOfComposite.
	 */
	long			sts ;
	struct GRid		*cmpList ;
	int			cmpCount,
				i,
				SurfaceRangeFailed ;
	GRrange			cmpRange ;

	cmpList = NULL ;

	sts = VD_getLeavesOfOwnerCmpGraph(	msg,
						&object->_grid,
						&cmpCount,
						&cmpList ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	objRange[0] = objRange[1] = objRange[2] =  MAXDOUBLE ;
	objRange[3] = objRange[4] = objRange[5] = -MAXDOUBLE ;

	SurfaceRangeFailed = FALSE ;
	for( i = 0 ; i < cmpCount ; i++ ) {
		sts = vd_$getSurfaceRange(	msg	= msg,
						surface	= cmpList + i,
						range	= cmpRange ) ;
		if( !( sts & *msg & 1 ) ) {
			SurfaceRangeFailed = TRUE ;
			break ;
		}
		if( cmpRange[0] < objRange[0] ) objRange[0] = cmpRange[0] ;
		if( cmpRange[1] < objRange[1] ) objRange[1] = cmpRange[1] ;
		if( cmpRange[2] < objRange[2] ) objRange[2] = cmpRange[2] ;
		if( cmpRange[3] > objRange[3] ) objRange[3] = cmpRange[3] ;
		if( cmpRange[4] > objRange[4] ) objRange[4] = cmpRange[4] ;
		if( cmpRange[5] > objRange[5] ) objRange[5] = cmpRange[5] ;
	}
	if( SurfaceRangeFailed ) {
		IGRboolean world = TRUE ;

		sts = om$send(	msg	= message GRgraphics.GRgetrang(
							msg,
							&object->_matrix_type,
							object->_matrix,
							&world,
							objRange ),
				senderid= object->_objid,
				targetid= object->_objid,
				targetos= object->_osnum ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRgetrang", wrapup ) ;
	}
	*msg = MSSUCC ;

	wrapup :
		_FREE( cmpList ) ;
		return sts ;

} /* VD_getRangeOfComposite */
/*----------------------------------------------------------------------------*/

end implementation OMindex ;
