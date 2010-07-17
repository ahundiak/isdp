/*
	I/STRUCT
*/
class implementation VSfeature ;

#include <limits.h>
#include "EMSmsgdef.h"
#include "vsweld.h"
#include "vsjointdef.h"
#include "vsjoint.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"

extern OMuword	OPP_VSdivJoint_class_id,
		OPP_VSsubJoint_class_id ;

from VSdivFeature	import	VSget_sub_features ;
/*----------------------------------------------------------------------------*/
method VSputDivJoints(	long		*msg ;
			struct GRmd_env	*myEnv ;
			char		*dir ;
			int		count ;
			VSjointList	jList[] ) {

	long			sts ;		/* OM return code	*/
	int			i,		/* Loop-on-joints index	*/
				subCnt ;	/* Count of sub-joints	*/
	struct GRid		divJoint,	/* One divided joint	*/
				subJoints[VS_K_MAX_SUBS] ;
						/* Sub-joints of above	*/
	struct GRvg_construct	jCst ;		/* Cost. list for joints*/
	struct VScnst_list	vsargs ;	/* Parentage		*/
	VSdivArgs		dvargs ;
	VSpartAttr		part ;
	VSjointAttr		attr ;

#define PARENTJN	0
#define MAX		1
	struct GRobj_env	parents[MAX] ;	/* Parents of div. joint*/
	VSsubJointInfo		jnInfo ;	/* Info for sub-joints
						    to get more parents	*/

	vs$fill_cnst_list(	Cnst_list	= jCst,
				Env_info	= myEnv,
				Msg		= msg,
				Display		= NULL,
				Level		= 0,
				Class_attr	= &vsargs ) ;

	vsargs.parent_list	= parents ;
	vsargs.parent_count	= MAX ;
	vsargs.representation	= AC_NO_REP ;
	vsargs.feature_att	= (char *) &dvargs ;
	dvargs.subFeatureAttr	= (char *) &part ;
	dvargs.subFeatureClassid= OPP_VSsubJoint_class_id ;

	/*
	 * The following info will contain.
	 * - Myself (divided feature) so divided joint can get my sub-features
	 * and put each of them as a parent of a sub-joint.
	 * - The other feature, ie. that between which and each of the
	 * sub-features a sub-joint must be put.
	 */
	dvargs.divInfo		= (void *) &jnInfo ;

	jnInfo.divFeature._objid	= my_id ;
	jnInfo.divFeature._osnum	= OM_Gw_current_OS ;
	jnInfo.divFeature.mod_env	= *myEnv ;
	jnInfo.dir			= dir ;

	divJoint.osnum = jCst.env_info->_MD_OS ;
	divJoint.objid = NULL_OBJID ;

	part.Iwant	= VS_m_All ;
	part.specific	= (void *) &attr ;

	for( i = 0 ; i < count ; i++ ) {
		/*
		 * Give sub-joints the attributes of parent joint.
		 */
		sts = om$send(	msg	= message GRvg.GRgetattr(
							msg, (char *) &part ),
				targetid= jList[i].joint._objid,
				targetos= jList[i].joint._osnum ) ;
		__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

		sts = om$construct(	classid	= OPP_VSdivJoint_class_id,
					osnum	= divJoint.osnum,
					p_objid	= &divJoint.objid ) ;
		if( !( sts & 1 ) ) vs$om_error( sts = sts ) ;

		parents[PARENTJN]	= jList[i].joint ;
		jnInfo.otherFeature	= jList[i].otherFeature ;

		/*
		 * If construction fails, joint will delete itself, in this
		 * case continue because we may have encountered an invalid case
		 * such as the following :
		 *
		 * +-------------+      +-------------+      +-------------+  
		 * |1            |      |2            |      |2            |
		 * |             | -A-> +--j23--------+ -B-> +-------------+ 
		 * |             |      |3            |      |4            |
		 * |             |      |             |      +-------------+ 
		 * |             |      |             |      |5            | 
		 * +-------------+      +-------------+      +-------------+
		 *
		 * Splitting plates with placement of joints, when we arrive
		 * at B and 3 has been split into 4 and 5, we are trying
		 * to replace j23 by joints joining 4 and 5 to 2. Trying to
		 * joint 5 and 2 will obviously fail, so we must go on to
		 * establish j42.
		 */
		sts = om$send(	msg	= message GRgraphics.GRconstruct(
									&jCst ),
				targetid= divJoint.objid,
				targetos= divJoint.osnum ) ;
		if( !( sts & 1 & *msg ) ) {
			/*
			 * Well, go on anyway, baby !
			 */
			continue ;
		}

		sts = om$send(	msg	= message VSdivFeature.VSget_sub_features(
							msg, &subCnt, subJoints ),
				targetid= divJoint.objid,
				targetos= divJoint.osnum ) ;

		vs$bulk_display(	grids	= subJoints,
					count	= subCnt,
					theEnv	= jCst.env_info ) ;

	}

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup	:
		return sts ;

} /* method VSputDivJoints */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;


