/*
	I/STRUCT
*/
class implementation VSgapDtector ;

#include "EMSmsgdef.h"
#include "DImacros.h"
#include "vspart.h"
#include "vssectiondef.h"
#include "vsbeamdef.h"
#include "vsstfnrdef.h"
#include "vsplatedef.h"
#include "vsglobals.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsvecmxproto.h"
#include "vsvirtualinf.h"

extern long VSdetectGapBeyondTolBtwSfs __((
					long			*msg,
					const struct GRid	*sf1Id,
					const struct GRmd_env	*sf1Env,
					const struct GRid	*sf2Id,
					const struct GRmd_env	*sf2Env,
					double			gap,
					struct GRvg_construct	*cst,
					int			maxMarkers,
					struct GRid		markers[],
					int			*count,
					double			*maxGap )) ;

from expression	import NDgive_value ;
from VSstfBeam	import VSgetPlateSide ;
/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					countOfInputs ;
			struct GRid	listOfInputs[] ;
			struct GRmd_env	*myEnv ;
			int		*countOfOutputs ;
			struct GRid 	*listOfOutputs ) {

	long			sts ;		/* OM return code	*/
#define STFN	0
#define MAXGAP	1
	double			maxAdmGap ;	/* Max. admissible gap	*/
	struct GRobj_env	parents[2] ;	/* Virtual parents	*/
	struct GRid		faceId ;	/* Face of parent stif.	*/

	/*
	 * Real parents may be ACpretends: get virtual ones.
	 */
	{
	  int i ;
	  for( i = 0 ; i < 2 ; i++ ) {
	     sts = VSgetVirtualInfo(	msg,
					listOfInputs + i,
					&parents[i].mod_env,
					&parents[i]._grid ) ;
	     __CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;
	  }
	}

	sts = om$send(	msg	= message expression.NDgive_value( &maxAdmGap ),
			targetid= parents[MAXGAP]._objid,
			targetos= parents[MAXGAP]._osnum ) ;
	__CheckRC( sts, 1, "NDnode.NDgive_value", wrapup ) ;

	/*
	 * Get supports of stiffener. Since parents beam can be in a ref file F1
	 * and its support surface in a ref file F2, we have to multiply
	 * the matrices:
	 *		+- F2 ----------------------+
	 *              |      support surface      |
	 *              +---------------------------+\
	 *                                             m
	 *              +- F1 ----------------------+/
	 *              |         stiffener         |
	 *              +---------------------------+\
	 *                                             m
	 *              +---------------------------+/
	 *              |        gap detector       |
	 *              +---------------------------+
	 *
	 */
	{
	  int			side ;
	  const char*		sideName ;
	  struct GRid		plate ;
	  struct GRid		plSdId ;
	  struct GRmd_env	plSdEnv ;

	  sts = om$send( msg	= message VSstfBeam.VSgetPlateSide( msg, &side),
			targetid= parents[STFN]._objid,
			targetos= parents[STFN]._osnum ) ;
	  __CheckRC( sts, *msg, "VSstfBeam.VSgetPlateSide", wrapup ) ;

	  switch( side ) {
		default 		 :
		case VS_K_stOnTopOfPlate :
			sideName = VS_K_plTopSfPathABS ; break ;
		case VS_K_stOnBotOfPlate :
			sideName = VS_K_plBotSfPathABS ; break ;
	  }
	  sts = om$send( msg	= message ACcpx.ACfind_temp_obj(
					(int*) msg, VS_K_stSuppPlate, &plate ),
			targetid= parents[STFN]._objid,
			targetos= parents[STFN]._osnum ) ;
	  __CheckRC( sts, *msg, "ACcpx.ACfind_temp_obj", wrapup ) ;

	  sts = om$send( msg	= message NDmacro.ACreturn_foot(
				   	msg, (char*) sideName, &plSdId,
				   	&plSdEnv._MATRIX_TYPE, plSdEnv._MATRIX),
			targetid= plate.objid,
			targetos= plate.osnum ) ;
	  __CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	  plSdEnv._MD_OS = plSdId.osnum ;
	  plSdEnv._MD_ID = NULL_OBJID ;

	  VSmulmx( parents[STFN]._matrix, myEnv->_MATRIX, parents[STFN]._matrix,
		   &parents[STFN]._matrix_type ) ;
	  VSmulmx( plSdEnv._MATRIX, parents[STFN]._matrix, plSdEnv._MATRIX,
		   &plSdEnv._MATRIX_TYPE ) ;

	  {
	    GRname face ;
	    DIstmcpy( face, VS_K_bmGrCmpName, VS_K_bmBody, VS_K_nmFlgInfE, NULL );

	    sts = om$send(msg     = message NDmacro.ACreturn_foot(
  					      msg, face, &faceId, NULL, NULL ),
			  targetid= parents[STFN]._objid,
			  targetos= parents[STFN]._osnum ) ;
	  }

	  /*
	   * If the stiffener is in 2D then the face queried for above does not
	   * exist, therefore the gap cannot be evaluated. In this case, do
	   * not err but be dormant, i.e. without graphic manifestation.
	   */
	  if( !( sts & 1 & *msg ) ) {
	      me->maxAdmissibleGap	= maxAdmGap ;
	      *countOfOutputs		= 0 ;
	  } else {

	    struct GRvg_construct	cst ;	/* Construction list	*/
	    struct GRsymbology		mySymb ;/* My symbology		*/
	    int				wrtMsg ;

	    /*
	     * If no components (dormant) then I have to get the symbology
	     * from myself, not my components.
	     */
	    if( !( purpose & VS_K_InitialPlacement ) ) {
	      int nbOutputs ;
	      sts = om$send( msg      = message GRowner.GRget_number_components(
	    						      msg, &nbOutputs ),
	    		     targetid = my_id ) ;
	      __CheckRC( sts, *msg, "GRowner.GRget_number_components", wrapup );
	      wrtMsg = nbOutputs == 0 ;
	    } else {
	      wrtMsg = TRUE ;
	    }

	    sts = om$send(msg     = message GRvg.GRgetsymb( msg, &mySymb ),
	 		  mode    = wrtMsg ? OM_e_wrt_message : OM_e_wrt_object,
			  targetid= my_id ) ;
	    __CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;

	    vs$fill_cnst_list(	Env_info	= myEnv,
				Display		= &mySymb.display_attr,
				Level		= mySymb.level,
				Cnst_list	= cst ) ;

	    {
	      int		count ;
	      struct GRid	markers[VS_K_gdMaxOutputs] ;
	      double		maxGapObserved ;
	      sts = VSdetectGapBeyondTolBtwSfs(	msg,
						&faceId,
						&parents[STFN].mod_env,
						&plSdId,
						&plSdEnv,
						maxAdmGap,
						&cst,
						VS_K_gdMaxOutputs,
						markers,
						&count,
						&maxGapObserved ) ;
	      __CheckRC( sts, *msg, "VSdetectGapBeyondTolBtwSfs", wrapup ) ;

	      me->maxAdmissibleGap	= maxAdmGap ;
	      me->excessGap		= maxGapObserved - maxAdmGap ;

	      *countOfOutputs = count ;
	      if( count ) {
		      memcpy( listOfOutputs, markers,
		      	      count * sizeof( struct GRid ) ) ;
	      }
	    }
          }
	}

	/*
	 * Update object tag, don't check return code: will be
	 * OM_W_NOTTAGGED if object has no tag connection.
	 */
	om$change_tag_version() ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {

			if( purpose & VS_K_InitialPlacement ) {
				if( *msg & 1 ) *msg = MSFAIL ;
				sts = OM_W_ABORT ;
			} else {
				if( *msg & 1 ) *msg = EMS_E_NoSolution ;
	    			sts = OM_S_SUCCESS ;
	    		}
		}

		return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSgapDtector ;
