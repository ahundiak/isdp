/*
	I/STRUCT
*/
class implementation VSsrcBeam ;

#include "OMerrordef.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "grdpbdef.h"		/* Constants for DPB		*/
#include "grdpbmacros.h"	/* Macros for DPB		*/
#include "vsdbgmacros.h"
#include "vsmiscmacros.h"
/*----------------------------------------------------------------------------*/
method VSsetOrientation(	long		*msg ;
				struct GRmd_env	*myEnv ;
				int		orientation ) {

	long			sts ;		/* OM completion code	*/

	/*
	 * Compute yourself but not children: we just add new outputs...
	 */
	if( myEnv ) {
		sts = om$send(	msg	= message NDnode.NDs_compute_node(
								msg, 0, myEnv ),
				targetid= my_id ) ;
	} else {
		sts = OM_S_SUCCESS ; *msg = MSSUCC ;
	}

	return sts ;

} /* method VSsetOrientation */
/*----------------------------------------------------------------------------*/
method VSgetOrientation(	long	*msg ;
				int	*orientation ) {

	*msg = MSSUCC ;
	*orientation = VS_K_NatOrient ;

	return OM_S_SUCCESS ;

} /* method VSgetOrientation */
/*----------------------------------------------------------------------------*/
method VShasOrientation( int OMmsgType ) {

	/*
	 * Say you are oriented for read operation, and for write operation only
	 * if you are not in an assembly.
	 */
	return om$send( msg	= message VSfeature.VSisOriginal(
							TRUE, OMmsgType ),
			targetid= my_id ) ;

} /* method VShasOrientation */
/*----------------------------------------------------------------------------*/

end implementation VSsrcBeam ;
