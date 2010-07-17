/*
	I/STRUCT
 History
    10/25/95	tlb		EMS 3.2: change cs.h to grcoordsys.h
*/
class implementation VSfeature ;

#include "csdef.h"
#include "grcoordsys.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

extern OMuword OPP_GRgencs_class_id ;
/*----------------------------------------------------------------------------*/
long VSconstructCS( msg, matrix, cst, CSid )

long			*msg ;
IGRmatrix		matrix ;
struct GRvg_construct	*cst ;
struct GRid		*CSid ; {

	long			sts ;
	int			i ;
	struct IGRlbsys		geometry ;
	struct GRcs_construct	args ;
	char			*saveAttr,
				*saveGeom ;

	CSid->objid = NULL_OBJID ;

	saveAttr = cst->class_attr ;
	saveGeom = cst->geometry ;

	args.desc	= NULL ;
	args.flag	= CS_CONNECT_TO_MGR | CS_NO_MAKE_ACTIVE ;

	for( i = 0 ; i < 16 ; i++ ) {
		geometry.matrix[i]= matrix[i] ;
	}
	for( i = 0 ; i < 3 ; i++ ) {
		geometry.diag_pt1[i] = geometry.diag_pt2[i] = 0 ;
	}

	cst->geometry	= (char *) &geometry ;
	cst->class_attr	= (char *) &args ;

	sts = om$construct(	classid	= OPP_GRgencs_class_id,
				osnum	= cst->env_info->_MD_OS,
				p_objid	= &CSid->objid ) ;
	if( !( sts & 1 ) ) {
		*msg = EMS_E_OMerror ; goto wrapup ;
	}
	CSid->osnum = cst->env_info->_MD_OS ;

	sts = om$send(	msg	= message GRgraphics.GRconstruct( cst ),
			senderid= CSid->objid,
			targetid= CSid->objid,
			targetos= CSid->osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRconstruct( CS )", wrapup ) ;

	wrapup :
		cst->class_attr	= saveAttr ;
		cst->geometry	= saveGeom ;

		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete( grids = CSid, theEnv = cst->env_info ) ;
			CSid->objid = NULL_OBJID ;
		}
		return sts ;

} /* VSconstructCS */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
