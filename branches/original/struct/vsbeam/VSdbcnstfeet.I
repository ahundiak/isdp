/*
	I/STRUCT
*/
class implementation VSpntBeam ;

#include "bserr.h"
#include "exmacros.h"
#include "emssfintdef.h"
#include "emsbool.h"
#include "EMSmsgdef.h"
#include "vsplatedef.h"
#include "vsbeamdef.h"
#include "vssplitdef.h"
#include "vsiomacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bsmdistcvcv.h"
#include "GRfindcontex.h"
#include "vsintcvsf.h"
#include "vsvecmxproto.h"

from GRlinear	import	GRgetpolyline ;
from GRcurve	import	GRendpts ;

extern IGRboolean	ASbroadcast_in_progress ;
extern long		VSsplitCurveWithOneOrTwoPoints() ;
extern void		VSsetGRids() ;
extern OMuword		OPP_VSrflBeam_class_id ;

#omdef vs$splitCurveWithOneOrTwoPoints(
			msg, cvEnv, cvId, count, pntEnv, pntList, pntCoord, cst,
			subCv1, subCv2 )
	VSsplitCurveWithOneOrTwoPoints(
			(msg), (cvEnv), (cvId), (count), (pntEnv), (pntList),
			(pntCoord), (cst),
			(subCv1), (subCv2) )
#endomdef
/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					countOfInputs ;
			struct GRid	listOfInputs[] ;
			struct GRmd_env	*myEnv ;
			int		*countOfOutputs ;
			struct GRid	*listOfOutputs ) {

	long		sts ;		/* OM return code		*/
	struct GRobj_env
			operand,	/* ... of this operation	*/
			oprIds[2] ;	/* Splitting operators		*/
	struct GRprops	optrType ;	/* Type of operator(s)		*/
	struct IGRpolyline
			poly ;
	int		action = 1 ;
	IGRpoint	point,
			splPnts[2] ;	/* Co-ordinates of points	*/
	struct GRvg_construct 
			cst ;		/* ... of resulting boolean	*/
	unsigned	myMask ;	/* My mask of sub-beams		*/
	int		i,		/* Loop index			*/
			nbPnts,		/* Count of parent operators	*/
			maxSubBeams ;	/* Max. # of sub-beams		*/
	struct GRid	parentOutput ;	/* My parent beam's output	*/
	struct GRobj_env
			suppAxis ;	/* My support axis    		*/
	IGRboolean	saveBroadcast ;
	struct GRsymbology
			mySymb ;
	struct IGRbsp_curve *geom0 = NULL,
                            *geom1 = NULL ;

	if( !countOfInputs ) { *msg = MSINARG ; return OM_W_ABORT ; }

	nbPnts = countOfInputs == 3 ? 2 : 1 ;

	saveBroadcast		= ASbroadcast_in_progress ;
	ASbroadcast_in_progress	= TRUE ;

	VSsetGRids( myEnv->_MD_OS, 2, listOfOutputs ) ;

	/*
	 * The operand is the parent I consume.
	 */
	operand._grid = listOfInputs[VS_K_ConsumedIx] ;

	/*
	 * Fill construction list.
	 */
	sts = om$send(	msg	= message GRvg.GRgetsymb( msg, &mySymb ),
			mode	= purpose & VS_K_InitialPlacement
					? OM_e_wrt_message
					: OM_e_wrt_object,
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;

	vs$fill_cnst_list(	Msg		= msg,
				Env_info	= myEnv,
				Display		= &mySymb.display_attr,
				Level		= mySymb.level,
				Cnst_list	= cst ) ;

	/*
	 * Consume parent and get rid of graphics immediately (we don't need
	 * them !). The following call will set `operand.mod_env'.
	 */
	sts = vs$consume(	msg	= msg,
				objId	= &operand._grid,
				ftEnv	= myEnv,
				objEnv	= &operand.mod_env,
				nbfeet	= 1,
				feet	= &parentOutput ) ;
	__CheckRC( sts, *msg, "vs$consume", wrapup ) ;

	vs$bulk_delete(	count = 1, theEnv = myEnv, grids = &parentOutput ) ;

	/*
	 * Get axis.
	 */
	sts = om$send(msg     = message VSbeam.VSgetSupportAxis(
						        msg, myEnv, &suppAxis ),
	              targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetSupportAxis", wrapup ) ;

	/*
	 * We either have one or two parents for splitting, each of them being
	 * either a point or a plane. In case we have got a plane we compute
	 * its intersection with the axis of the beam.
	 */
	sts = om$send(	msg	= message VScpx.VSget_graphic_input(
					msg, nbPnts, listOfInputs + 1, oprIds ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VScpx.VSget_graphic_input", wrapup ) ;

	/*
	 * Get co-ordinates of points to split with.
	 */
	poly.num_points	= 1 ;

	for( i = 0 ; i < nbPnts ; i++ ) {

	  sts = om$send( msg      = message GRvg.GRgeomprops(
					msg, &oprIds[i]._matrix_type,
					oprIds[i]._matrix, &optrType ),
			 targetid = oprIds[i]._objid,
			 targetos = oprIds[i]._osnum ) ;
	  __CheckRC( sts, *msg, "GRvg.GRgeomprops", wrapup ) ;

	  if( GRSURFACE == optrType.type && GRSS == optrType.subtype ) {
	    /*
	     * This is a sub-surface.
	     */
	    double	pm ;
	    sts = VSintersectCurveAndSurface( msg,
					      &suppAxis._grid,
					      &suppAxis.mod_env,
					      &oprIds[i]._grid,
					      &oprIds[i].mod_env,
					      TRUE,
				 	      splPnts[i],
	 				      &pm ) ;
            __CheckRC( sts, *msg, "VSintersectCrAndSf", wrapup ) ;

	  } else if(    GRCURVE == optrType.type 
	             && GRLN    == optrType.subtype
		     && optrType.phy_closed ) {
			/*
			 * This is a point. Wouldn't you know ?
			 */
	    struct GRparms	prjParms ;

	    poly.points = point ;

	    sts = om$send( msg     = message GRlinear.GRgetpolyline(
					msg, &oprIds[i]._matrix_type,
					oprIds[i]._matrix, &action, &poly ),
			   targetid= oprIds[i]._objid,
			   targetos= oprIds[i]._osnum ) ;
	    __CheckRC( sts, *msg, "GRlinear.GRgetpolyline", wrapup);

	    sts = om$send( msg	= message GRgraphics.GRptproject(
					msg, &suppAxis._matrix_type,
					suppAxis._matrix, point,
					splPnts[i], &prjParms ),
			   targetid= suppAxis._objid,
			   targetos= suppAxis._osnum ) ;
	    __CheckRC( sts, *msg, "GRgraphics.GRptproject", wrapup);

	  } else if( GRCURVE == optrType.type ) {

	    /* Split is done with a curve: find the intersection with the
	     * axis of the beam, using Assoc's ASinpt object which
	     * contains an extensive curve-curve intersection logic.
	     */
	    struct GRvg_construct ptCst = cst ;
	    struct GRas 	  attr ;
	    struct GRid		  parents[2],
	  		          contexts[2] ;
	    IGRpoint	          snapPt ;
	    struct GRid	          intPt ;
	    struct ret_struct     rs ;
	    extern OMuword        OPP_ASintpt_class_id ;

	    ptCst.class_attr = (char*) &attr ;
	    attr.num_parents = 2 ;
            attr.parents     = parents ;
            attr.context     = contexts ;

            attr.go_attr = NULL;
            attr.as_attr = (char*) snapPt ;

	    parents[0] = suppAxis._grid ; contexts[0].objid = NULL_OBJID ;
	    GRfindcontext( msg, &suppAxis._matrix_type, suppAxis._matrix,
                                 &suppAxis._osnum, contexts + 0 ) ;
            parents[1] = oprIds[i]._grid ; contexts[1].objid = NULL_OBJID ;
            GRfindcontext( msg, &oprIds[i]._matrix_type, oprIds[i]._matrix,
                                 &oprIds[i]._osnum, contexts + 1 ) ;

            /* We need a snap point to differentiate multiple solutions: let us
             * take the point on the beam axis at a minimun distance from the
             * parent curve.
             */
            {
              int		num ;
              double            dist ;
	      double		*par1	= NULL,
	                        *par2	= NULL ;
	      IGRpoint	        *pt1	= NULL,
				*pt2	= NULL ;

              vs$get_geometry( msg      = msg,
                               grobjId	= &suppAxis._grid,
			       grobjEnv = &suppAxis.mod_env,
			       geometry = &geom0 ) ;
              __CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

              vs$get_geometry( msg      = msg,
                               grobjId	= &oprIds[i]._grid,
			       grobjEnv = &oprIds[i].mod_env,
			       geometry = &geom1 ) ;
              __CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

	      BSmdistcvcv( geom0, geom1, &num, &par1, &par2, &pt1, &pt2, &dist,
			   msg ) ;
	      if( BSOKAY( *msg ) ) VSvccpy( snapPt, pt1[0] ) ;
	      else               snapPt[0] = snapPt[1] = snapPt[2] = 0 ;
	      _FREE( par1 ) ; _FREE( pt1 ) ; _FREE( geom0 ) ;
	      _FREE( par2 ) ; _FREE( pt2 ) ; _FREE( geom1 ) ;
	    }

	    intPt.osnum = ptCst.env_info->_MD_OS ;
	    sts = om$construct( osnum   = intPt.osnum,
                                classid = OPP_ASintpt_class_id,
                                p_objid = &intPt.objid,
                                msg     = message GRgraphics.GRconstruct( &ptCst));
            __CheckRC( sts, *msg, "om$construct( ASintpt )", wrapup ) ;

            sts = om$send( msg     = message NDnode.NDgive_structure(
                                                     msg, &rs, ptCst.env_info ),
                           targetid= intPt.objid,
                           targetos= intPt.osnum ) ;
            __CheckRC( sts, *msg, "message NDnode.NDgive_structure", wrapup ) ;

            VSvccpy( splPnts[i], rs.var.point_st.pt ) ;
            om$send( msg    = message GRgraphics.GRdelete( msg, ptCst.env_info),
                     targetid= intPt.objid,
                     targetos= intPt.osnum ) ;
	  }
	}

	/*
	 * Split axis with points.
	 */
	sts = vs$splitCurveWithOneOrTwoPoints(	msg	= msg,
						cvEnv	= &suppAxis.mod_env,
						cvId	= &suppAxis._grid,
						count	= nbPnts,
						pntEnv	= NULL,
						pntList	= NULL,
						pntCoord= splPnts,
						cst	= &cst,
						subCv1	= listOfOutputs + 0,
						subCv2	= listOfOutputs + 1 ) ;
	__CheckRC( sts, *msg, "vs$splitCurveWithOneOrTwoPoints", wrapup ) ;

	*countOfOutputs = 2 ;

	if( purpose & VS_K_InitialPlacement ) {
/* RM if OK
		if( *countOfOutputs == 1 ) {
			if( IF_NULL_OBJID( listOfOutputs[0].objid ) ) {
			  listOfOutputs[0].objid = listOfOutputs[1].objid ;
			  listOfOutputs[1].objid = NULL_OBJID ;
			}
			sts = om$send(	msg	= message VSdivFeature.VSsetSubMask(
							msg, VS_K_SET_BITS, 1 ),
					targetid= my_id ) ;
		}
END RM if OK */
	} else {
		/*
		 * Sub-beams may have been deleted purposedly by user: do not
		 * put them back.
		 */
		sts = om$send(	msg	= message VSdivFeature.VSgetSubMask(
					msg, &myMask, &i, &maxSubBeams ),
				targetid= my_id ) ;
		__CheckRC( sts, *msg, "VSdivFeature.VSgetSubMask", wrapup ) ;

		for( i = 0 ; i < maxSubBeams ; i++ ) {
			if( myMask & ( 1 << i ) ) {
				/* Keeping it: no op */
			} else {

				vs$bulk_delete(	count 	= 1,
						grids	= listOfOutputs + i,
						theEnv	= myEnv ) ;
			}
		}
	}
	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	wrapup :

	vs$dotsInStsFld( dots = clear ) ;
	 _FREE( geom0 ) ; _FREE( geom1 ) ;

	if( !( sts & 1 & *msg ) ) {
		/* Cleanup */
		vs$bulk_delete(	count	= *countOfOutputs,
				grids	= listOfOutputs,
				theEnv	= myEnv ) ;
	    	/*
	    	 * Placement : failure. Compute : degraded state.
	    	 */
	    	if( purpose & VS_K_InitialPlacement ) {
	    		/*
	    		 * Unconsuming parent.
	    		 */
			long rc ; VSdspRep myRep ;

			om$send(msg	= message ACncpx.ACget_NV_rep( &myRep ),
				targetid= my_id ) ;
	    		vs$unconsume(	msg	= &rc,
	    				object	= &operand._grid,
	    				mod_env	= &operand.mod_env,
	    				rep	= myRep,
	    				compute	= TRUE ) ;
	    		if( *msg & 1 ) *msg = MSFAIL ;
	    		sts = OM_W_ABORT ;
	    	} else {
	    		if( *msg & 1 ) *msg = EMS_E_NoSolution ;
	    		sts = OM_S_SUCCESS ;
	    	}
	} else {
		/*
		 * Update beam tag, don't check return code: will be
		 * OM_W_NOTTAGGED if object has no tag connection.
		 */
		om$change_tag_version() ;
	}

	ASbroadcast_in_progress	= saveBroadcast ;

	return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSpntBeam ;
