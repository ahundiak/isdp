/*
	I/STRUCT
*/ 
class implementation VSrflBeam ;

#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
/*----------------------------------------------------------------------------*/
long VScopyBeamFaceForSupport( msg, fromBeam, toEnv, faceName, face )

long			*msg ;
struct GRobj_env	*fromBeam ;
struct GRmd_env		*toEnv ;
GRname			faceName ;
struct GRid		*face ; {

	long			sts ;
	VSdspRep		rep ;
	struct GRid		parentFace ;
	int			forcedRep,
				forcedCompute ;
	struct GRmd_env		computeEnv ;
	short			action,
				props ;

	face->objid = NULL_OBJID ;
	forcedRep = forcedCompute = FALSE ;

	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &rep ),
			senderid= NULL_OBJID,
			targetid= fromBeam->_objid,
			targetos= fromBeam->_osnum ) ;
	__CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;

	if( !( rep & AC_3D_REP ) ) {
		sts = om$send(	msg	= message ACncpx.ACput_NV_rep( AC_3D_REP ),
				senderid= NULL_OBJID,
				targetid= fromBeam->_objid,
				targetos= fromBeam->_osnum ) ;
		__CheckRC( sts, 1, "ACncpx.ACput_NV_rep", wrapup ) ;
		forcedRep = TRUE ;

		computeEnv._MATRIX_TYPE = MAIDMX ;
		MAidmx( msg, computeEnv._MATRIX ) ;
		computeEnv._MD_ID = fromBeam->_md_id ;
		computeEnv._MD_OS = fromBeam->_md_os ;

		sts = om$send(	msg	= message NDnode.NDs_compute_node(
						msg, 0, &fromBeam->mod_env ),
				senderid= NULL_OBJID,
				targetid= fromBeam->_objid,
				targetos= fromBeam->_osnum ) ;
		__CheckRC( sts, *msg, "NDs_compute_node", wrapup ) ;

		forcedCompute = TRUE ;
	}

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(msg,
								faceName,
								&parentFace,
								NULL,
								NULL ),
			senderid= NULL_OBJID,
			targetid= fromBeam->_objid,
			targetos= fromBeam->_osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	sts = vs$grCopy(	msg	= msg,
				frEnv	= &fromBeam->mod_env,
				frObj	= &parentFace,
				toEnv	= toEnv,
				toObj	= face ) ;
	__CheckRC( sts, *msg, "vs$grCopy", wrapup ) ;

	/*
	 * This surface must have its orientation reversed, reverse it anew
	 * to match the of the original support surface.
	 */
	sts = vs$reverse_sf_orientation(msg		= msg,
					surfaceId	= face,
					ignRevFlag	= TRUE ) ;
	__CheckRC( sts, *msg, "vs$reverse_sf_orientation", wrapup ) ;

	/*
	 * Make it invisible.
	 */
	action	= 0 ;
	props	= GRIS_LOCATABLE | GRIS_DISPLAYABLE ;
	sts = om$send(	msg	= message GRgraphics.GRchgprops(msg,
								&action,
								&props ),
			senderid= face->objid,
			targetid= face->objid,
			targetos= face->osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRchgprops", wrapup ) ;

	wrapup :
		if( forcedRep ) {
			om$send(msg	= message ACncpx.ACput_NV_rep( rep ),
				senderid= NULL_OBJID,
				targetid= fromBeam->_objid,
				targetos= fromBeam->_osnum ) ;
		}
		if( forcedCompute ) {
			long	rc ;
			om$send(msg	= message NDnode.NDs_compute_node(
						&rc, 0, &fromBeam->mod_env ),
				senderid= NULL_OBJID,
				targetid= fromBeam->_objid,
				targetos= fromBeam->_osnum ) ;
		}

		return sts ;

} /* VScopyBeamFaceForSupport */
/*----------------------------------------------------------------------------*/

end implementation VSrflBeam ;

