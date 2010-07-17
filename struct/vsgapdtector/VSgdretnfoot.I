/*
	I/STRUCT
*/
class implementation VSgapDtector ;

#include <string.h>
#include "exmacros.h"
#include "madef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"

extern long	VSmakeUnitPretend __(( struct GRid * )) ;
/*----------------------------------------------------------------------------*/
method ACreturn_foot(	long		*rc ;
			char		*nameOfOutput ;
			struct GRid	*idOfOutput ;
			short		*mxType ;
			IGRmatrix	mx ) {

	long			msg,	/* Completion code		*/
				sts ;	/* OM return code		*/

	sts = om$send(	msg	= message VShelper.ACreturn_foot(
						rc, nameOfOutput,
						idOfOutput, mxType, mx ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;

	if( ( sts & 1 ) && *rc ) {

	  /*
	   * We want pretends corresponding to numeric outputs to print
	   * themselves nicely. Put identity matrix: it does not matter.
	   */
	   struct GRmd_env	env ;
	   struct ret_struct	rs ;

	   env._MATRIX_TYPE = MAIDMX ;
	   MAidmx( &msg, env._MATRIX ) ;
	   env._MD_OS = OM_Gw_current_OS ;

	   ex$get_modid(mod_osnum	= OM_Gw_current_OS,
			mod_id		= &env._MD_ID ) ;
	   sts = om$send(	msg	= message NDnode.NDgive_structure(
							&msg, &rs, &env ),
				targetid= idOfOutput->objid,
				targetos= idOfOutput->osnum ) ;

	   if( ( sts & 1 & msg ) && rs.type == double_type ) {
		VSmakeUnitPretend( idOfOutput ) ;
	   	*rc = TRUE ;	
	   } else *rc = FALSE ;
	}

	/*
	 * Must always return OM_S_SUCCESS !
	 */
	return OM_S_SUCCESS ;
	
} /* method ACreturn_foot */
/*----------------------------------------------------------------------------*/
 
end implementation VSgapDtector ;
