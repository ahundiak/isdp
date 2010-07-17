/*
	I/STRUCT
*/
class implementation VSrflBeam ;

#include <string.h>
#include "vsrfldef.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "vsmkgrobjtmp.h"
/*----------------------------------------------------------------------------*/
method VSgetSupportSf(	long			*msg ;
			struct GRmd_env 	*myEnv ;
			struct GRobj_env	*sf ) {

	long		sts ;			/* OM return code	*/
	int		usingHiddenSrf = FALSE ;
	VSdspRep	myRep ; 		/* My display rep.	*/
	GRname		faceName ;		/* Name of one face	*/
	struct GRid	faceId ;

	sf->_objid = NULL_OBJID ;

	/*
	 * If we are in the course of changing representation, say from 3D
	 * to 2D, our rep. has been changed to 2D but we still have our foot
	 * in 3D, since the ACreturn_foot of beams depends upon the representa-
	 * tion, it will fail if rep. and foot do not match. We temporarily
	 * trick the beam into believing it is in 3D, should it be in another
	 * representation.
	 */
	om$send( msg	 = message ACncpx.ACget_NV_rep( &myRep ),
		 targetid= my_id ) ;

	if( !( myRep & AC_3D_REP ) ) {
		om$send( msg	 = message ACncpx.ACput_NV_rep( AC_3D_REP ),
			 targetid= my_id ) ;
	}

	/*
	 * Retrieve name of face to use to regenerate the axis, this info
	 * is stored in the collection of user attributes; we can access it
	 * directly via NDmacro.ACgive_structure sent to ourself.
	 */
	{ int			index = -1 ;
	  struct ret_struct	rs ;

	  sts = om$send( msg	 = message NDmacro.ACgive_structure(
					     (int *) msg, &index,
					     VS_K_rbFaceNameAttr, &rs, myEnv ),
			 targetid= my_id ) ;
	  __CheckRC( sts, *msg, "NDmacro.ACgive_structure", wrapup ) ;

	  strcpy( faceName, rs.var.text_st.text_string ) ;
	}

	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
					msg, faceName, &faceId, NULL, NULL ),
			targetid= my_id ) ;

	/*
	 * Restore rep. before testing any return code that might cause an
	 * exit from this method, leaving beam in the wrong rep. !
	 */
	om$send( msg	 = message ACncpx.ACput_NV_rep( myRep ),
		 targetid= my_id ) ;

	if( !( sts & 1 & *msg ) ) {
	  sts = om$send( msg	= message NDmacro.ACreturn_foot(
				 msg, VS_K_rbSuppSrf, &faceId, NULL, NULL ),
			targetid= my_id ) ;
	  __CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;
	  usingHiddenSrf = TRUE ;
	}

	sts = vs$grCopy(	msg	= msg,
				frEnv	= myEnv,
				frObj	= &faceId,
				toEnv	= myEnv,
				toObj	= &sf->_grid ) ;
	__CheckRC( sts, *msg, "vs$grCopy", wrapup ) ;

	if( ! usingHiddenSrf ) {
		/*
		 * This surface must have its orientation reversed, hence we
		 * reverse it anew to match that of the original support.
		 */
		sts = vs$reverse_sf_orientation(
					msg		= msg,
					surfaceId	= &sf->_grid,
					ignRevFlag	= TRUE ) ;
		__CheckRC( sts, *msg, "vs$reverse_sf_orientation", wrapup ) ;
	}

	sf->mod_env.md_id	= myEnv->md_id ;
	sf->_matrix_type	= MAIDMX ;
	MAidmx( msg, sf->_matrix ) ;

	sts = VSmakeGraphicObjectTemporary( msg, &sf->_grid, TRUE ) ;

	wrapup :
		return sts ;

} /* method VSgetSupportSf */
/*----------------------------------------------------------------------------*/
method VSgetSupportAxis(	long			*msg ;
				struct GRmd_env 	*myEnv ;
				struct GRobj_env	*axis ) {

	long			sts ;		/* OM return code	*/
	struct GRobj_env	sf ;
	IGRvector		delta ;

	axis->_objid = NULL_OBJID ;

	{ struct GRid moi ;
	  moi.objid = my_id ;
	  moi.osnum = OM_Gw_current_OS ;
	  sts = VSgetVectorFrColl( msg,
				   &moi,
				   VS_K_rbDxAttr,
				   VS_K_rbDyAttr,
				   VS_K_rbDzAttr,
				   delta ) ;
	  __CheckRC( sts, *msg, "VSgetVectorFrColl", wrapup ) ;
	}

	sts = om$send( msg	= message VSbeam.VSgetSupportSf(
							      msg, myEnv, &sf ),
		       targetid = my_id ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetSupportSf", wrapup ) ;

	{ struct GRvg_construct cst ;
	  struct GRid		moi ;

	  moi.osnum = OM_Gw_current_OS ;
	  moi.objid = my_id ;

	  vs$fill_cnst_list( Msg = msg, Env_info = myEnv, Cnst_list = cst ) ;

	  sts = VSregenerateBeamAxis( msg, &sf._grid, myEnv, &moi, &cst, delta,
				      &axis->_grid ) ;
	  __CheckRC( sts, *msg, "VSregenerateBeamAxis", wrapup ) ;
	}

	axis->mod_env.md_id	= myEnv->md_id ;
	axis->_matrix_type	= MAIDMX ;
	MAidmx( msg, axis->_matrix ) ;

	sts = VSmakeGraphicObjectTemporary( msg, &axis->_grid, TRUE ) ;

	wrapup :
		return sts ;

} /* method VSgetSupportAxis */
/*----------------------------------------------------------------------------*/

end implementation VSrflBeam ;
