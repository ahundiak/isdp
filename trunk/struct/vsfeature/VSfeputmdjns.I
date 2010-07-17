/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "EMSmsgdef.h"
#include "vsweld.h"
#include "vsjointdef.h"
#include "vsjoint.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"

extern OMuword	OPP_VSmodJoint_class_id ;
/*----------------------------------------------------------------------------*/
method VSputModJoints(	long		*msg ;
			struct GRmd_env	*myEnv ;
			int		count ;
			VSjointList	jList[] ) {

	long			sts ;		/* OM return code	*/
	int			i ;		/* Loop-on-joints index	*/
	struct GRid		modJoint ;	/* One modified joint	*/
	struct GRvg_construct	jCst ;		/* Cost. list for joints*/
	struct VScnst_list	vsargs ;	/* Parentage		*/
#define PARENTJN	0
#define FEATURE0	1
#define FEATURE1	2
#define MAX		3
	struct GRobj_env	parents[MAX] ;	/* Parents of mod. joint*/


	vs$fill_cnst_list(	Cnst_list	= jCst,
				Env_info	= myEnv,
				Msg		= msg,
				Display		= NULL,
				Level		= 0,
				Class_attr	= &vsargs ) ;

	vsargs.parent_list	= parents ;
	vsargs.parent_count	= MAX ;
	vsargs.feature_att	= 0 ;
	vsargs.representation	= 0 ;

	parents[FEATURE0]._objid	= my_id ;
	parents[FEATURE0]._osnum	= OM_Gw_current_OS ;
	parents[FEATURE0].mod_env	= *myEnv ;

	modJoint.osnum = jCst.env_info->_MD_OS ;
	modJoint.objid = NULL_OBJID ;

	for( i = 0 ; i < count ; i++ ) {
		sts = om$construct(	classid	= OPP_VSmodJoint_class_id,
					osnum	= modJoint.osnum,
					p_objid	= &modJoint.objid ) ;
		if( !( sts & 1 ) ) vs$om_error( sts = sts ) ;

		parents[PARENTJN] = jList[i].joint ;
		parents[FEATURE1] = jList[i].otherFeature ;
		/*
		 * If construction fails, joint will delete itself.
		 */
		sts = om$send(	msg	= message GRgraphics.GRconstruct(
									&jCst ),
				targetid= modJoint.objid,
				targetos= modJoint.osnum ) ;
		__CheckRC( sts, *msg, "GRgraphics.GRconstruct", wrapup ) ;

		vs$bulk_display( grids = &modJoint, theEnv = jCst.env_info ) ;

	}

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup	:
		return sts ;

} /* method VSputModJoints */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;


