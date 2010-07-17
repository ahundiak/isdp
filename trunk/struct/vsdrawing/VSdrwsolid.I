/*
	I/STRUCT
*/
class implementation EMSsolid ;

#include <stdio.h>
#include "bserr.h"
#include "bsparameters.h"
#include "msdef.h"
#include "emseligible.h"
#ifndef EMSconstruct_include
#	include "EMSconstruct.h"
#endif
#include "EMSmsgdef.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vspratpt.h"
#include "vsdrwproto.h"
#include "vsvecmxproto.h"
#include "vsvisedproto.h"

/*
 * Defines for drawing type of a wireframe.
 */
#define VS_K_DRW_TYPE_COVER	0	/* Wireframe covered by other	      */
					/* wireframes.			      */
#define VS_K_DRW_TYPE_HIDDEN	1	/* Wireframe hidden by owner solid.   */
#define VS_K_DRW_TYPE_VISIBLE	2	/* Wireframe visible.		      */

extern OMuword	OPP_GRpoint_class_id ;

extern long	EFproject_any_curve_on_planen() ;
extern void	VSsetGRids() ;
/*----------------------------------------------------------------------------*/
long VSdrwProjectWireframeWithHiddenParts( msg, wfId, wfEnv, nbSolSurf,
					   solSurfObj, cst, dspVis, dspHid,
					   drwPlane, viewVector, pjCv,
					   pjClassid )

long			*msg ;
struct GRid		*wfId ;
struct GRmd_env 	*wfEnv ;
int			nbSolSurf ;
struct GRobj_env	*solSurfObj ;
struct GRvg_construct	*cst ;
struct IGRdisplay	*dspVis,
			*dspHid ;
struct IGRplane 	*drwPlane ;
IGRvector		viewVector ;
struct GRid		*pjCv ;
OMuword 		*pjClassid ; {

	/*
	 * This function projects the input wireframe ( wfId, wfEnv ) with
	 * hidden parts calculated with set of solids / surfaces ( nbSolSurf,
	 * solSurfObj ). It output the projected wireframe ( pjCv ) and its
	 * class id ( pjClassid ).
	 */

	long		sts ;	     /* OM completion code.		      */
	int		nb_part ;    /* Number of hidden parts. 	      */
	double		*part_pt_s,  /* Start points of hidden parts.	      */
			*part_pt_e,  /* End points of hidden parts.	      */
			*part_pm_s,  /* Parameters of start points.	      */
			*part_pm_e ; /* Parameters of end points.	      */

	pjCv->objid = NULL_OBJID ;
	*pjClassid  = OM_K_NOTUSING_CLASSID ;

	nb_part   = 0 ;
	part_pt_s = part_pt_e = part_pm_s = part_pm_e = NULL ;

	/*
	 * Find hidden parts of wireframe.
	 */
	sts = VSveFindHiddenPartsOfCurveWithSolSurfs( msg,
						      wfId,
						      wfEnv,
						      nbSolSurf,
						      solSurfObj,
						      viewVector,
						      &nb_part,
						      &part_pt_s,
						      &part_pt_e,
						      &part_pm_s,
						      &part_pm_e ) ;

	__CheckRC( sts, *msg, "VSveFindHiddenPartsOfCurveWithSolSurfs",
		   wrapup ) ;

	/*
	 * Project wireframe onto drawing plane along view vector with its
	 * hidden parts.
	 */
	sts = VSdrwProjectCurveWithHiddenParts( msg,
						wfId,
						wfEnv,
						nb_part,
						part_pt_s,
						part_pt_e,
						part_pm_s,
						part_pm_e,
						cst,
						dspVis,
						dspHid,
						drwPlane,
						viewVector,
						pjCv,
						pjClassid ) ;

	__CheckRC( sts, *msg, "VSdrwProjectCurveWithHiddenParts", wrapup ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		_FREE( part_pt_s ) ;
		_FREE( part_pt_e ) ;
		_FREE( part_pm_s ) ;
		_FREE( part_pm_e ) ;

		return sts ;

} /* VSdrwProjectWireframeWithHiddenParts */
/*----------------------------------------------------------------------------*/
static long VSdrwSolidToWireFrame( msg, solId, solEnv, cst, wfCount, wfList )

long			*msg ;
struct GRid		*solId ;
struct GRmd_env 	*solEnv ;
struct GRvg_construct	*cst ;
int			*wfCount ;
struct GRid		*wfList[] ; {

	/*
	 * This function returns the wireframes of a solid.
	 */

	long			sts,	   /* OM return code.		      */
				buf_size ; /* For EMmake_wire_frame.	      */
	struct GRvg_construct	locCst ;   /* Construction list (local).      */
	struct EMScurveinfo	solInfo ;  /* I/O of EMmake_wire_frame.       */
	unsigned short		options ;  /* Options of EMmake_wire_frame.   */

	SetProc( VSdrwSolidToWireFrame ); Begin

	__DBGpr_obj( "Solid", *solId ) ;

	*wfCount = 0 ;
	*wfList  = NULL ;

	/*
	 * Construct local construction list.
	 */
	vs$fill_cnst_list( Msg		= msg,
			   Env_info	= cst->env_info,
			   Display	= cst->display,
			   Level	= cst->level,
			   Cnst_list	= locCst ) ;

	/*
	 * Initialise data for EMmake_wire_frame.
	 */
	buf_size			= 0 ;
	solInfo.messg_linestr		= NULL ;
	solInfo.messg_gencrv		= NULL ;
	solInfo.construct_list		= &locCst ;
	solInfo.linestr.objid		= NULL_OBJID ;
	solInfo.gencrv.objid		= NULL_OBJID ;
	solInfo.linestr_counter 	= 0 ;
	solInfo.gencrv_counter		= 0 ;
	solInfo.curves			= wfList ;
	solInfo.buf_size		= &buf_size ;
	solInfo.num_curves		= (long *) wfCount ;

	options = EMSeligible_NonSeamEdge	|
		  EMSeligible_NonDegenerateEdge |
		  EMSeligible_UseMsc ;

	/*
	 * Make wireframes of input solid.
	 */
	sts = om$send( msg	= message EMSsolid.EMmake_wire_frame( msg,
								      solEnv,
								      &solInfo,
								      options ),
		       senderid = solId->objid,
		       targetid = solId->objid,
		       targetos = solId->osnum ) ;

	__CheckRC( sts, *msg, "EMSsolid.EMmake_wire_frame", wrapup ) ;

	__DBGpr_objlist( "Wireframes", *wfCount, *wfList ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			_FREE( *wfList ) ;
			*wfList  = NULL ;
			*wfCount = 0 ;
		}

		End
		return sts ;

} /* VSdrwSolidToWireFrame */
/*----------------------------------------------------------------------------*/
static long VSdrwGetDrawingTypeOfWireframe( msg, solId, solEnv, wfId, wfEnv,
					    viewVector, drwType )

long		*msg ;
struct GRid	*solId ;
struct GRmd_env *solEnv ;
struct GRid	*wfId ;
struct GRmd_env *wfEnv ;
IGRvector	viewVector ;
int		*drwType ; {

	/*
	 * Given a solid ( solId, solEnv ) and its wireframe ( wfId, wfEnv ),
	 * this function returns the drawing type of the wireframe ( drwType )
	 * with respect to the solid :
	 *
	 * - VS_K_DRW_TYPE_COVER	: Wireframe covered by other wireframes
	 *				  ( don't project it ).
	 * - VS_K_DRW_TYPE_HIDDEN	: Wireframe hidden by solid
	 *				  ( Project total hiiden ).
	 * - VS_K_DRW_TYPE_VISIBLE	: Wireframe visible
	 *				  ( Project with hidden parts ).
	 */

	long		sts ;	    /* OM completion code.		      */
	unsigned long	pLocation,  /* Location of test point ( compute with  */
				    /* view vector ) with respect to solid.   */
			oLocation ; /* Location of test point ( compute with  */
				    /* the oposite of view vector ) with      */
				    /* respect to solid.		      */
	IGRpoint	midPt,      /* Middle point of wireframe.	      */
			pTestPt,    /* Test point compute with view vector.   */
			oTestPt ;   /* Test point compute with the oposite of */
				    /* view vector.			      */
	double		minDst ;    /* Minimum distance of system.	      */
	struct GRprops	properties ;/* Geometry properties of wireframe.      */

	*drwType = VS_K_DRW_TYPE_COVER ;

	/*
	 * See if wireframe is closed, planar and its normal is orthogonal to
	 * view vector. In this case, the wireframe is visible.
	 */
	sts = om$send( msg	= message GRvg.GRgeomprops(
							   msg,
							   &wfEnv->_MATRIX_TYPE,
							   wfEnv->_MATRIX,
							   &properties ),
		       senderid = wfId->objid,
		       targetid = wfId->objid,
		       targetos = wfId->osnum ) ;

	__CheckRC( sts, *msg, "GRvg.GRgeomprops", wrapup ) ;

	if( properties.phy_closed &&
	    properties.planar	  ) {
		IGRpoint	point ;
		IGRvector	normal ;
		struct IGRplane plane ;

		__DBGpr_com( "Wireframe is closed and planar" ) ;

		plane.normal = normal ;
		plane.point  = point ;

		sts = om$send( msg	= message GRvg.GRdetplane(
							   msg,
							   &wfEnv->_MATRIX_TYPE,
							   wfEnv->_MATRIX,
							   &plane ),
			       senderid = wfId->objid,
			       targetid = wfId->objid,
			       targetos = wfId->osnum ) ;

		__CheckRC( sts, *msg, "GRvg.GRdetplane", wrapup ) ;

		if( VSorthoVectors( normal, viewVector ) ) {
			*drwType = VS_K_DRW_TYPE_VISIBLE ;

			sts  = OM_S_SUCCESS ;
			*msg = MSSUCC ;

			goto wrapup ;
		}
	}

	/*
	 * Find middle point of wireframe.
	 */
	sts = VSptatpr( msg, wfEnv, wfId->objid, 0.5, midPt ) ;

	__CheckRC( sts, *msg, "VSptatpr", wrapup ) ;

	__DBGpr_vec( "Middle point", midPt ) ;

	/*
	 * Find minimum distance of system.
	 */
	BSEXTRACTPAR( msg, BSTOLLENVEC, minDst ) ;
	minDst *= 100. ;

	/*
	 * Find test points.
	 */
	pTestPt[0] = midPt[0] + minDst * viewVector[0] ;
	pTestPt[1] = midPt[1] + minDst * viewVector[1] ;
	pTestPt[2] = midPt[2] + minDst * viewVector[2] ;

	oTestPt[0] = midPt[0] - minDst * viewVector[0] ;
	oTestPt[1] = midPt[1] - minDst * viewVector[1] ;
	oTestPt[2] = midPt[2] - minDst * viewVector[2] ;

	/*
	 * Find location of test points with respect to solid.
	 */
	sts = om$send( msg	= message EMSsolid.EMpoint_locate( msg,
								   solEnv,
								   0,
								   pTestPt,
								   NULL,
								   &pLocation ),
		       senderid = solId->objid,
		       targetid = solId->objid,
		       targetos = solId->osnum ) ;

	__CheckRC( sts, *msg, "EMSsolid.EMpoint_locate", wrapup ) ;

#ifdef vsDEBUG
	switch( pLocation ) {
		case EMS_S_OUTSOLID : __DBGpr_com( "+ : OUT"	 ) ; break ;
		case EMS_S_INSOLID  : __DBGpr_com( "+ : IN"	 ) ; break ;
		case EMS_S_ONSOLID  : __DBGpr_com( "+ : ON"	 ) ; break ;
		case EMS_S_UNKNOWN  : __DBGpr_com( "+ : UNKNOWN" ) ; break ;
		default 	    : __DBGpr_com( "+ : ERROR"	 ) ;
	}
#endif

	sts = om$send( msg	= message EMSsolid.EMpoint_locate( msg,
								   solEnv,
								   0,
								   oTestPt,
								   NULL,
								   &oLocation ),
		       senderid = solId->objid,
		       targetid = solId->objid,
		       targetos = solId->osnum ) ;

	__CheckRC( sts, *msg, "EMSsolid.EMpoint_locate", wrapup ) ;

#ifdef vsDEBUG
	switch( oLocation ) {
		case EMS_S_OUTSOLID : __DBGpr_com( "- : OUT"	 ) ; break ;
		case EMS_S_INSOLID  : __DBGpr_com( "- : IN"	 ) ; break ;
		case EMS_S_ONSOLID  : __DBGpr_com( "- : ON"	 ) ; break ;
		case EMS_S_UNKNOWN  : __DBGpr_com( "- : UNKNOWN" ) ; break ;
		default 	    : __DBGpr_com( "- : ERROR"	 ) ;
	}
#endif

	/*
	 * Search drawing type of wireframe.
	 *
	 *	-----------------------------------------
	 *	|  o\p	|  IN	|  OUT	|  ON	| UNKN	|
	 *	-----------------------------------------
	 *	|  IN	| cover |visible| cover | cover |
	 *	-----------------------------------------
	 *	|  OUT	| hidden|visible| cover | cover |
	 *	-----------------------------------------
	 *	|  ON	| cover |visible|visible| cover |
	 *	-----------------------------------------
	 *	|  UNKN | cover | cover | cover | cover |
	 *	-----------------------------------------
	 */
	if( ( pLocation == EMS_S_OUTSOLID	&&
	      oLocation != EMS_S_UNKNOWN)	||
	    ( pLocation == EMS_S_ONSOLID	&&
	      oLocation == EMS_S_ONSOLID )	)
		*drwType = VS_K_DRW_TYPE_VISIBLE ;

	if( pLocation == EMS_S_INSOLID		&&
	    oLocation == EMS_S_OUTSOLID )
		*drwType = VS_K_DRW_TYPE_HIDDEN ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		return sts ;

} /* VSdrwGetDrawingTypeOfWireframe */
/*----------------------------------------------------------------------------*/
long VSdrwProjectSolidWithHiddenLines( msg, solId, solEnv, elmCount, elmList,
				       viewVector, drwPlane, dspHid, dspVis,
				       cst, count, list )

long			*msg ;
struct GRid		*solId ;
struct GRmd_env 	*solEnv ;
int			elmCount ;
struct GRobj_env	elmList[] ;
IGRvector		viewVector ;
struct IGRplane 	*drwPlane ;
struct IGRdisplay	*dspHid,
			*dspVis ;
struct GRvg_construct	*cst ;
int			*count ;
struct GRid		*list[] ; {

	/*
	 * This function projects a solid ( solId, solEnv ) onto a drawing
	 * plane ( drwPlane ) along a view vector ( viewVector ) with hidden
	 * lines calculated with respect to a set of solids / surfaces
	 * ( elmCount, elmList ). 'dspHid' and 'dspVis' are respectly the
	 * hidden and visible display of output curves ( count, list ).
	 * 'cst' is the construction list for output curves.
	 *
	 * Note :
	 * ======
	 *	'*list' is allocated and must be freed by the caller with
	 *	'free( *list )'.
	 */

	long			sts ;	  /* OM completion code.	      */
	int			i,	  /* Loop index.		      */
				drwType,  /* Drawing type of wireframe.       */
				wfCount,  /* Count of wireframes of solid to  */
					  /* project.			      */
				pjCount ; /* Count of projected wireframes.   */
	struct GRid		*wfList,  /* Wireframes of solid to project.  */
				*pjList ; /* List of projected wireframes.    */
	OMuword 		pjClassid;/* Classid of projected wireframe.  */

	SetProc( VSdrwProjectSolidWithHiddenLines ); Begin

	__DBGpr_obj( "Solid to project", *solId ) ;

	*count = 0 ;
	*list  = NULL ;

	wfCount = pjCount = 0 ;
	wfList	= pjList  = NULL ;

	/*
	 * Get wireframes of solid to project.
	 */
	sts = VSdrwSolidToWireFrame( msg,
				     solId,
				     solEnv,
				     cst,
				     &wfCount,
				     &wfList ) ;

	__CheckRC( sts, *msg, "VSdrwSolidToWireFrame", wrapup ) ;

	__DBGpr_int( "Count of wireframes", wfCount ) ;

	/*
	 * Allocate memory for projected wireframes.
	 */
	if( !( pjList = _MALLOC( wfCount, struct GRid ) ) ) vs$mem_fail() ;

	VSsetGRids( cst->env_info->_MD_OS, wfCount, pjList ) ;

	/*
	 * For each wireframes, project it or not according to its drawing
	 * type.
	 */
	for( i=0; i<wfCount; i++ ) {

		__DBGpr_obj( "Wireframe", wfList[i] ) ;

		/*
		 * Get drawing type of wireframe.
		 */
		sts = VSdrwGetDrawingTypeOfWireframe( msg,
						      solId,
						      solEnv,
						      wfList +i,
						      cst->env_info,
						      viewVector,
						      &drwType ) ;

		__CheckRC( sts, *msg, "VSdrwGetDrawingTypeOfWireframe",
			   wrapup ) ;

		switch( drwType ) {
		case VS_K_DRW_TYPE_HIDDEN	:
			__DBGpr_com( "\tProject total hidden" ) ;

			/*
			 * Project wireframe onto drawing plane with hidden
			 * symbology.
			 */
			cst->display = dspHid ;
			sts = EFproject_any_curve_on_planen( msg,
							     cst,
							     wfList + i,
							     cst->env_info,
							     drwPlane,
							     viewVector,
							     pjList +pjCount,
							     &pjClassid ) ;

			__CheckRC( sts, *msg, "EFproject_any_curve_on_planen",
				   wrapup ) ;

			goto ADD_TO_LIST ;

		case VS_K_DRW_TYPE_VISIBLE	:
			__DBGpr_com( "\tProject with hidden parts" ) ;

			/*
			 * Project wireframe onto drawing plane with hidden
			 * parts.
			 */
			sts = VSdrwProjectWireframeWithHiddenParts(
								msg,
								wfList +i,
								cst->env_info,
								elmCount,
								elmList,
								cst,
								dspVis,
								dspHid,
								drwPlane,
								viewVector,
								pjList +pjCount,
								&pjClassid ) ;

			__CheckRC( sts, *msg,
				   "VSdrwProjectWireframeWithHiddenParts",
				   wrapup ) ;

		ADD_TO_LIST :
			__DBGpr_obj( "Projected wireframe", pjList[pjCount] ) ;
			__DBGpr_com( "Is a point ?" ) ;

			/*
			 * Do not take points.
			 */
			if( om$is_ancestry_valid(
					   subclassid	= pjClassid,
					   superclassid = OPP_GRpoint_class_id )
						  == OM_S_SUCCESS ) {

				__DBGpr_com( "\t-> Yes" ) ;

				vs$bulk_delete( grids  = pjList +pjCount,
						theEnv = cst->env_info ) ;

			} else {
				__DBGpr_com( "\t-> No" ) ;
				pjCount++ ;
			}
			break ;

		case VS_K_DRW_TYPE_COVER	:
			__DBGpr_com( "\tDon't project wireframe" ) ;
			break ;
		}
	}

	/*
	 * Remove projected curve which are covered by other projected curve.
	 */
	sts = VSdrwRmCoveredCurves( msg,
				    dspHid->style,
				    dspVis->style,
				    pjCount,
				    pjList,
				    cst->env_info,
				    count,
				    list ) ;

	__CheckRC( sts, *msg, "VSdrwRmCoveredCurves", wrapup ) ;

	__DBGpr_objlist( "Drawing of solid", *count, *list ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete( count  = pjCount,
					grids  = pjList,
					theEnv = cst->env_info ) ;

			_FREE( *list ) ;
			*list  = NULL ;
			*count = 0 ;
		}

		vs$bulk_delete( count  = wfCount,
				grids  = wfList,
				theEnv = cst->env_info ) ;

		_FREE( wfList ) ;
		_FREE( pjList ) ;

		End
		return sts ;

} /* VSdrwProjectSolidWithHiddenLines */
/*----------------------------------------------------------------------------*/

end implementation EMSsolid ;
