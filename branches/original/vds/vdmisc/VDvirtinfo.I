/*
	I/VDS	Copy
*/
class implementation VDSroot ;

#include "exmacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
/*----------------------------------------------------------------------------*/
long VD_getVirtualInfo( msg, object, p_md_env, p_virtual )

long		*msg ;
struct GRid	*object,
		*p_virtual ;
struct GRmd_env	*p_md_env ; {

	long		sts ;
	struct GRid	virtual ;
	double		*mx ;
	short		*mxType ;

	if( !p_virtual	) p_virtual = &virtual ;
	if( p_md_env	) {
		mxType	= &p_md_env->_MATRIX_TYPE ;
		mx	= p_md_env->_MATRIX ;
	} else {
		mxType	= NULL ;
		mx	= NULL ;
	}

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
						msg, "", p_virtual, mxType, mx),
			targetid= object->objid,
			targetos= object->osnum,
			senderid= object->objid ) ;
	*msg = *msg ? MSSUCC : MSFAIL ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	if( p_md_env ) {
		p_md_env->md_id.osnum = p_virtual->osnum ;
		ex$get_modid(	mod_osnum	= p_md_env->md_id.osnum,
				mod_id		= &p_md_env->md_id.objid ) ;
	}

	wrapup :
		return sts ;

} /* VD_getVirtualInfo */
/*----------------------------------------------------------------------------*/

end implementation VDSroot ;
