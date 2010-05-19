/*
	I/VDS	Copy
*/
class implementation VDSroot ;

#include "EMSmsgdef.h"
#include "v_iomacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "v_chgsymb.h"
#include "v_vecmxproto.h"

from GRlinear	import	GRgetpolyline ;
from GRcurve	import	GRsplit ;

extern OMuword OPP_GRcompcurve_class_id ;

/*----------------------------------------------------------------------------*/
static long VD_split( msg, env, cv, pm, pt, cnt, cvs )

long		*msg ;
struct GRmd_env	*env ;
OM_S_OBJID	cv ;
double		pm ;
IGRpoint	pt ;
int		*cnt ;
OM_S_OBJID	*cvs ; {

	/*
	 * I got tired of writing the whole message send.
	 */
	long			sts ;
	struct GRparms		splitPm ;
	short			count ;
	struct GRid		Cv ;

	splitPm.u		= pm ;
	splitPm.leaf_id.objid	= NULL_OBJID ;
	splitPm.leaf_id.objid	= 0 ;

	Cv.objid = cv ;
	Cv.osnum = env->_MD_OS ;
	if( vd_$is_ancestry_valid(object	= &Cv,
				 classid	= OPP_GRcompcurve_class_id ) ) {
				 	
		/* For composite curves we need the lead id */

		IGRpoint	prj ;
		sts = om$send( msg	= message GRgraphics.GRptproject(
							msg,
							&env->_MATRIX_TYPE,
							env->_MATRIX,
							pt,
							prj,
							&splitPm ),
				senderid= cv,
				targetid= cv,
				targetos= env->_MD_OS ) ;
							
	}
	sts = om$send(	msg	= message GRcurve.GRsplit(	msg,
								env,
								pt,
								&splitPm,
								cvs + 0,
								cvs + 1,
								&count ),
			senderid= cv,
			targetid= cv,
			targetos= env->_MD_OS ) ;
	*cnt = count ;

	return sts ;

} /* VD_split */
/*----------------------------------------------------------------------------*/
long VD_ptatpr( msg, env, cv, pm, pt )

long		*msg ;
struct GRmd_env	*env ;
OM_S_OBJID	cv ;
double		pm ;
IGRpoint	pt ; {

	long	sts ;

	sts = om$send(	msg	= message GRvg.EMptatpr(msg,
							&env->_MATRIX_TYPE,
							env->_MATRIX,
							&pm,
							1,
							pt ),
			senderid= cv,
			targetid= cv,
			targetos= env->_MD_OS ) ;
	return sts ;

} /* VD_ptatpr */
/*----------------------------------------------------------------------------*/
long VD_pratpt( msg, env, cv, pt, pm )

long		*msg ;
struct GRmd_env	*env ;
OM_S_OBJID	cv ;
IGRpoint	pt ;
double		*pm ; {

	long	sts ;
	int	count ;
	double	t[2] ;

	sts = om$send(	msg	= message GRvg.EMpratpt(msg,
							&env->_MATRIX_TYPE,
							env->_MATRIX,
							pt,
							t,
							&count ),
			senderid= cv,
			targetid= cv,
			targetos= env->_MD_OS ) ;
			
	if( !count ) {
		sts  = OM_E_ABORT ;
		*msg = EMS_W_NoSolution ;
	} else 	*pm = t[0] ;

	return sts ;

} /* VD_pratpt */
/*----------------------------------------------------------------------------*/
static long VD_splitAtXYZ( msg, env, cv, pt, cnt, cvs )

long		*msg ;
struct GRmd_env	*env ;
OM_S_OBJID	cv ;
IGRpoint	pt ;
int		*cnt ;
OM_S_OBJID	*cvs ; {

	long	sts ;
	double	pm ;

	sts = VD_pratpt( msg, env, cv, pt, &pm ) ;
	if( sts & 1 & *msg ) {
		sts = VD_split( msg, env, cv, pm, pt, cnt, cvs ) ;
	}
	return sts ;

} /* VD_splitAtXYZ */
/*----------------------------------------------------------------------------*/

end implementation VDSroot ;
