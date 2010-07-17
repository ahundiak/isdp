/*
	I/STRUCT
*/
class implementation VSfeature ;

#include "nddef.h"
/*----------------------------------------------------------------------------*/
method NDcopy(	long		*msg ;
		int		cp_type ;
                struct GRmd_env	*fr_env,
                		*to_env ;
		struct GRid	*newobjid ) {

	long	sts ;	/* OM return code	*/

	newobjid->objid = NULL_OBJID ;

	sts = om$send(	mode     = OM_e_wrt_message,
			msg      = message ACncpx.NDcopy(	msg,
								cp_type,
								fr_env,
								to_env,
								newobjid ),
			targetid = my_id ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

/*
 * This flag (DROP_MODE_ONLY) also present in VSfebcmmacro.I
 * (method VSfeature.ACbecome_macro).
 */
#ifdef DROP_MODE_ONLY
	if( cp_type & ND_FROM_MACRO ) {
		/*
		 * Also if I was copied out of a macro definition, I must
		 * set copy's representation to AC_NO_REP, so when copy
		 * recomputes, it will know that it must either take the
		 * active representation if source and its parent's if consumed.
		 * The send is wrt message since ACput_NV_rep is overridden by
		 * comsumed objects which bubble it up.
		 */
		sts = om$send(	msg	= message ACncpx.ACput_NV_rep(
								AC_NO_REP ),
				mode	= OM_e_wrt_message,
				targetid= newobjid->objid,
				targetos= newobjid->osnum ) ;
	}
#endif
	wrapup :
		return sts ;

} /* method NDcopy */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
