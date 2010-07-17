/*
	I/STRUCT
*/
class implementation VSrflBeam ;

#include <string.h>
#include "OMmacros.h"
#include "asmacros.h"
#include "DImacros.h"
#include "EMSmsgdef.h"
#include "vsrfldef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvirtualinf.h"
/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					countOfInputs ;
			struct GRid	listOfInputs[] ;
			struct GRmd_env *myEnv ;
			int		*countOfOutputs ;
			struct GRid	*listOfOutputs ) {

	long			sts ;		/* OM return code	*/
	struct GRobj_env	parentBeam ;	/* Parent beam		*/
	int			placement,	/* TRUE/FALSE		*/
				parentHere,	/* TRUE/FALSE		*/
				compute,	/* TRUE/FALSE		*/
				storeFace,	/* TRUE/FALSE		*/
				index ; 	/* For ACgive_structure */
	struct ret_struct	rs ;		/* For ACgive_structure */
	VSdspRep		myRep ; 	/* My display rep.	*/
	struct GRid		hiddenSupport,
				faceForAxis,
				myUsrAttr ;	/* My user attr.	*/

	SetProc( VSrflBeam_ACconstruct_feet ) ; Begin ; __DBGpr_me() ;

	storeFace = FALSE ;
	hiddenSupport.objid	= faceForAxis.objid	= listOfOutputs[0].objid
				= listOfOutputs[1].objid= listOfOutputs[2].objid
				= NULL_OBJID ;

	placement = purpose & VS_K_InitialPlacement ;

	/*
	 * This object may have 2 or 3 parents :
	 * #0	: parent beam which is in a reference file, actually it is not
	 *	  the beam itself but an ACpretendin.
	 * #1	: private attibutes in same file as this object.
	 * #2	: user attributes in same file as this object (optional).
	 *
	 * At placement we have countOfInputs=1 (we had private attributes and
	 * user attributes -if any- ) in this method.
	 * At recompute we have countOfInputs=2 or 3.
	 */
	if( !countOfInputs ) vs$inv_arg() ;

	/*
	 * Since parent #0 is an ACpretendin (in the same file as me) pointing
	 * to parent beam in the reference file, get the beam. If the
	 * reference file is not attached, the following call will fail.
	 */
	sts = VSgetVirtualInfo( msg, listOfInputs + 0,
				&parentBeam.mod_env, &parentBeam._grid ) ;
	if( !( sts & 1 & *msg ) ) {
		/*
		 * Reference file not attached: at placement, this is an error
		 * at recompute, do nothing.
		 */
		if( placement ) {
			 vs$inv_arg() ;
		} else {
			parentHere = FALSE ;
		}
	} else {
		parentHere = TRUE ;

		sts = om$send(	msg	= message VSrflBeam.VSimportData(
						msg, placement, &parentBeam ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSrflBeam.VSimportData", wrapup ) ;
	}

	om$send(msg	= message ACncpx.ACget_NV_rep( &myRep ),
		targetid= my_id ) ;

	/*
	 * We must have user attributes at this point even if our parent beam
	 * did not have any. They have been set in method `VSimportData'.
	 */
	sts = om$send(	msg	= message VSfeature.VSfindCollection(
					msg, VS_K_prUsrAttr, &myUsrAttr ),
			targetid= my_id ) ;
	if( !( sts & 1 & *msg ) || IF_NULL_OBJID( myUsrAttr.objid ) ) {
		*msg = MSFAIL ; goto wrapup ;
	}

	if( parentHere ) {
	  struct GRid	parentFoot ;
	  struct GRmd_env	footEnv ;
	  VSdspRep	parentRep ;

	  sts = om$send( msg	 = message ACncpx.ACget_NV_rep( &parentRep ),
			 targetid= parentBeam._objid,
			 targetos= parentBeam._osnum ) ;

	  if( parentRep == myRep ) {
	    /*
	     * Copy parent's foot.
	     */
	    sts = om$send( msg	= message NDmacro.ACreturn_foot(
				       msg, VS_K_bmGrCmpName, &parentFoot,
				       &footEnv._MATRIX_TYPE, footEnv._MATRIX ),
			   targetid= listOfInputs[0].objid,
			   targetos= listOfInputs[0].osnum ) ;
	    __CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	    footEnv._MD_ID = parentBeam._md_id ;
	    footEnv._MD_OS = parentBeam._md_os ;

	    sts = vs$grCopy(	msg	= msg,
				frEnv	= &footEnv,
				frObj	= &parentFoot,
				toEnv	= myEnv,
				toObj	= listOfOutputs + 0 ) ;
	    __CheckRC( sts, *msg, "vs$grCopy", wrapup ) ;

	    om$change_tag_version() ;

	    compute = FALSE ;

	  } else compute = TRUE ;

	  if( !( myRep & AC_3D_REP ) ) {
	    GRname	faceName ;

	    DIstmcpy( faceName, VS_K_bmGrCmpName, VS_K_bmBody, VS_K_nmFlgInfE,
		      NULL ) ;

	    sts = VScopyBeamFaceForSupport( msg, &parentBeam, myEnv,
						faceName, &hiddenSupport ) ;
	    __CheckRC( sts, *msg, "VScopyBeamFaceForSupport", wrapup ) ;

	    index = -1 ;
	    sts = om$send( msg	= message NDmacro.ACgive_structure(
						(int *) msg, &index,
						VS_K_rbFaceNameAttr, &rs,
						myEnv ),
			   targetid= myUsrAttr.objid,
			   targetos= myUsrAttr.osnum ) ;
	     __CheckRC( sts, *msg, "NDmacro.ACgive_structure", wrapup ) ;

	     strcpy( faceName, rs.var.text_st.text_string ) ;

	     sts = VScopyBeamFaceForSupport( msg, &parentBeam, myEnv,
						faceName, &faceForAxis ) ;
	     __CheckRC( sts, *msg, "VScopyBeamFaceForSupport", wrapup ) ;

	     storeFace	= TRUE ;
	  }
	} else {
	  if( !( myRep & AC_3D_REP ) ) {
	    struct GRobj_env sf ;		/* My support sf */

	    sts = om$send( msg	   = message VSbeam.VSgetSupportSf(
							      msg, myEnv, &sf ),
			   targetid= my_id ) ;
	    __CheckRC( sts, *msg, "VSbeam.VSgetSupportSf", wrapup ) ;

	    sts = vs$grCopy(	msg	= msg,
				frEnv	= &sf.mod_env,
				frObj	= &sf._grid,
				toEnv	= myEnv,
				toObj	= &hiddenSupport ) ;
	    __CheckRC( sts, *msg, "vs$grCopy", wrapup ) ;

	    storeFace = TRUE ;
	  }
	  compute = TRUE ;
	}

	if( compute ) {
	  struct GRid	computeList[4],
			assoc0, 	/* Assoc. on supp. #0	*/
			assoc1, 	/* Assoc. on supp. #1	*/
			myColl ;	/* My private attr.	*/
	  VSsuppList	supps ; 	/* My support		*/
	  int		cnt ;

	  /*
	   * Retrieve source on surface and axis, put on them in
	   * your method VSgetSupports.
	   */
	  sts = om$send( msg	 = message VSpart.VSgetSupports(
						    msg, myEnv, &cnt, supps ),
			 targetid= my_id ) ;
	  __CheckRC( sts, *msg, "VSpart.VSgetSupports", wrapup ) ;

	  sts = as$make_source( go_grid = supps[0]._grid,
				mod_env = &supps[0].mod_env,
				as_os	= OM_Gw_current_OS,
				as_grid = &assoc0 ) ;
	  __CheckRC( sts, 1, "as$make_source 0", wrapup ) ;

	  sts = as$make_source( go_grid = supps[1]._grid,
				mod_env = &supps[1].mod_env,
				as_os	= OM_Gw_current_OS,
				as_grid = &assoc1 ) ;
	  __CheckRC( sts, 1, "as$make_source 1", wrapup ) ;

	  sts = om$send( msg	 = message VSfeature.VSfindCollection(
						msg, VS_K_prPrvAttr, &myColl ),
			 targetid= my_id ) ;
	  __CheckRC( sts, *msg, "VSfeature.VSfindCollection", wrapup ) ;

	  cnt = 0 ;
	  computeList[cnt++] = assoc0 ;
	  computeList[cnt++] = assoc1 ;
	  computeList[cnt++] = myColl ;
	  computeList[cnt++] = myUsrAttr ;

	  sts = om$send( msg	 = message VSsrcBeam.ACconstruct_feet(
							msg,
							purpose,
							cnt,
							computeList,
							myEnv,
							countOfOutputs,
							listOfOutputs ),
			  mode	   = OM_e_wrt_message,
			  targetid = my_id ) ;
	  __CheckRC( sts, *msg, "VSsrcBeam.ACconstruct_feet", wrapup ) ;

	}

	if( storeFace ) {
	    listOfOutputs[1] = hiddenSupport ;
	    listOfOutputs[2] = faceForAxis ;
	}

	*countOfOutputs = 3 ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete( grids	= listOfOutputs,
					theEnv	= myEnv ) ;
			vs$bulk_delete( grids	= &hiddenSupport,
					theEnv	= myEnv ) ;
		}
		End
		return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSrflBeam ;
