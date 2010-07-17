/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method GRcopy(	long		*msg ;
		struct GRmd_env	*frEnv,
				*toEnv ;
		OM_S_OBJID	*copy ) {

	long		sts ;
	unsigned long	myType ;

	sts = om$send(	msg	= message VSfeature.VSgetResultType(
								msg, &myType ),
			targetid= my_id ) ;
	
	myType = VS_OP_TYPE( myType ) ;

	if(    ( ( myType & VS_m_SUB_generic ) == VS_m_SUB_generic )
	    || ( myType & VS_m_MOD_generic ) ) {
		/*
		 * We do not want the copy command to copy modified or sub-
		 * feature since it breaks the consume mechanism, we return a
		 * `root' copy: not very usefull for the "Copy" command but
		 * perfectly OK for the consume mechanism (NDmacro.ACconsume
		 * sends us a GRcopy message).
		 */
		struct GRid	cpy ;

		sts = om$send(	msg	= message NDnode.NDcopy_to_root(
						msg, 0, frEnv, toEnv, &cpy ),
				targetid= my_id ) ;
		*copy = cpy.objid ;
	} else {
		/*
		 * This is a pure (original) source feature: we can use our
		 * ancestor's GRcopy.
		 */
		sts = om$send(	msg	= message ACncpx.GRcopy(
						msg, frEnv, toEnv, copy ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
	}

	return sts ;

} /* method GRcopy */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
