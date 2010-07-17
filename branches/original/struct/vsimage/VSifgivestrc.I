/*
	I/STRUCT
*/
class implementation VSimgFeature ;

#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method	ACgive_structure(	int			*ok,
							*notUsed ;
				char			*attrName ;
				struct ret_struct	*attrVal ;
				struct GRmd_env		*myEnv ) {

	long	sts ;

	sts = om$send(	msg	= message VSfeature.ACgive_structure(
						ok, notUsed, attrName, attrVal,
						myEnv ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	if( !( sts & 1 & *ok ) ) {
	  /*
	   * Ask model then.
	   */
	  struct GRid		modelId ;
	  struct GRmd_env	modelEnv ;
	  sts = om$send(msg	= message VSimgFeature.VSgetModel(
							&modelId, &modelEnv ),
			targetid= my_id ) ;
	  __CheckRC( sts, 1, "VSimgFeature.VSgetModel", wrapup ) ;

	  sts = om$send(msg	= message NDmacro.ACgive_structure(
						ok, notUsed, attrName, attrVal,
						&modelEnv ),
			targetid= modelId.objid,
			targetos= modelId.osnum ) ;
	}
	
	wrapup :
		return sts ;

} /* method ACgive_structure */
/*----------------------------------------------------------------------------*/

end implementation VSimgFeature ;
