/* $Id: VSdrwplbotsd.I,v 1.5 2001/03/12 22:33:41 ramarao Exp $ */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:      vsdrawing/VSdrwplbotsd.I
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdrwplbotsd.I,v $
 *      Revision 1.5  2001/03/12 22:33:41  ramarao
 *      Added one more argument(GRvg_construct) to VSgetNeatPlEdges() function to send proper environment matrix.
 *
 *      Revision 1.4  2001/02/03 19:22:03  ramarao
 *      Fixed TR# 4591.
 *
 *      Revision 1.3  2001/01/31 17:23:36  ramarao
 *      Implemented CR# 4564.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      07/17/00        Rama Rao        Header Creation && Added Neat Contour
 * -------------------------------------------------------------------*/

class implementation VSplate ;

#include <stdio.h>
#include <stdlib.h>
#include "grdpbdef.h"
#include "grdpb.h"
#include "fontdef.h"
#include "font.h"
#include "EMSmsgdef.h"
#include "vsslcdef.h"
#include "vsslc.h"
#include "vsdrw.h"
#include "vsedgedef.h"
#include "vsedgemacros.h"
#include "vsplatedef.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define vsDEBUG		1
#define vserrDEBUG	1

/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"

extern void		VSsetGRids() ;
extern long		VSgetGraphicEdge() ;
extern long		EFproject_any_curve_on_planen() ;

/*----------------------------------------------------------------------------*/
long VSdrwPlateBottomSide( msg, inp, xData, outp )

long			*msg ;
VSdrwInputData		*inp ;
VSdrwExecData		*xData ;
VSdrwGraphicGroup	*outp ; {

	/*
	 * This function extracts the projection of the plate's bottom side.
	 */

	long			sts ;		  /* OM completion code.      */
	int			i ;		  /* Loop index.	      */
	struct GRvg_construct	cst ;		  /* Construction list for    */
						  /* wireframe elements.      */
	struct GRid		botSd,		  /* Bottom side of plate.    */
				cvComp, 	  /* Composite curve of       */
						  /* contour.		      */
				pjCvComp,	  /* Projection of composite  */
						  /* curve of contour.	      */
				insGrEdge ;	  /* Graphic of inside edge.  */
	struct GRid		*insList = NULL,  /* List of inside edges of  */
						  /* bottom side.	      */
				*pjList = NULL,   /* List of projected curve. */
				*outList = NULL ; /* List of output curves.   */
	int			insCount,	  /* Count of inside edges of */
						  /* bottom side.	      */
				outCount ;	  /* Count of output curves.  */
	OMuword 		pjClassid ;	  /* Class of the projected   */
						  /* curve.		      */
	struct GRobj_env	inp_pl;		  /* Input Plate	      */

	SetProc( VSdrwPlateBottomSide ); Begin

	__DBGpr_obj( "Plate to draw", *(inp->elmId) ) ;

	outp->count = 0 ;
	outp->list  = NULL ;

	insGrEdge.objid = pjCvComp.objid = cvComp.objid = NULL_OBJID ;

	/*
	 * Construct construction list for wireframe elements.
	 */
	vs$fill_cnst_list( Msg		= msg,
			   Env_info	= inp->drwInfo.drwEnv,
			   Level	= xData->overrides.elmLevel,
			   Display	= &xData->overrides.elmDisplay,
			   Cnst_list	= cst ) ;

	inp_pl.obj_id  = *(inp->elmId);
	inp_pl.mod_env = *(inp->elmEnv);

	/*
	 * Create a composite curve of bottom side's contour.
	 */
	sts = VSgetNeatPlEdges( msg, &inp_pl, &cst, FALSE, NULL, NULL, &cvComp ) ;
	__CheckRC( sts, *msg, "VSgetNeatPlEdges", wrapup ) ;

	__DBGpr_obj( "Composite curve of contour", cvComp ) ;

	/*
	 * Project composite curve onto drawing plane.
	 */
	sts = EFproject_any_curve_on_planen( msg,
					     &cst,
					     &cvComp,
					     cst.env_info,
					     inp->drwInfo.drwPlane,
					     inp->drwInfo.viewVector,
					     &pjCvComp,
					     &pjClassid ) ;

	__CheckRC( sts, *msg, "EFproject_any_curve_on_planen", wrapup ) ;

	__DBGpr_obj( "Projection of contour", pjCvComp ) ;

        /*
         * Get bottom side of plate.
         */
        sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                                               msg,
                                                               VS_K_plBotSfPath,
                                                               &botSd,
                                                               NULL,
                                                               NULL ),
                       senderid = inp->elmId->objid,
                       targetid = inp->elmId->objid,
                       targetos = inp->elmId->osnum ) ;

        __CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

        __DBGpr_obj( "Bottom side of plate", botSd ) ;

	/*
	 * Get inside edges of bottom side.
	 */
	sts = vs$get_surface_edges( msg 	= msg,
				    sfId	= &botSd,
				    sfEnv	= inp->elmEnv,
				    edgeType	= VS_K_INSIDE_EDGES,
				    edCount	= &insCount,
				    edList	= &insList ) ;

	__CheckRC( sts, *msg, "vs$get_surface_edges", wrapup ) ;

	__DBGpr_int( "Count of inside edges", insCount ) ;

	sts = VSremovePenetrationHoles( msg, inp->elmId, inp->elmEnv,
					&insCount, insList );
        __CheckRC( sts, *msg, "VSremovePenetrationHoles", wrapup ) ;

	__DBGpr_int( "Count of inside edges after removing penetration holes", 
				insCount ) ;

	/*
	 * If we have inside edges, for each edges, get its graphic object
	 * and project it onto drawing plane.
	 */
	if( insCount ) {
		/*
		 * Construct a list of projected curves.
		 */
		if( !( pjList = _MALLOC( insCount, struct GRid ) ) )
			vs$mem_fail() ;
		VSsetGRids( cst.env_info->_MD_OS, insCount, pjList ) ;

		for( i=0; i<insCount; i++ ) {

			__DBGpr_obj( "Inside edge of bottom side", insList[i]);

			/*
			 * Get the graphic of inside edge.
			 */
			sts = vs$get_graphic_edge( msg	   = msg,
						   edId    = insList + i,
						   edEnv   = inp->elmEnv,
						   grEdge  = &insGrEdge ) ;

			__CheckRC( sts, *msg, "vs$get_graphic_edge", wrapup ) ;

			__DBGpr_obj( "Graphic of edge", insGrEdge ) ;

			/*
			 * Project the graphic of inside edge onto drawing
			 * plane.
			 */
			sts = EFproject_any_curve_on_planen(
							msg,
							&cst,
							&insGrEdge,
							inp->elmEnv,
							inp->drwInfo.drwPlane,
							inp->drwInfo.viewVector,
							pjList + i,
							&pjClassid ) ;

			__CheckRC( sts, *msg, "EFproject_any_curve_on_planen",
				   wrapup );

			/*
			 * This call  will set insGrEdge.objid to NULL_OBJID.
			 */
			vs$bulk_delete( grids = &insGrEdge,
					theEnv= inp->elmEnv ) ;

			__DBGpr_obj( "Projection of graphic of edge",
				     pjList[i] ) ;
		}

		/*
		 * Remove covering curves.
		 */
		sts = VSdrwRmCoveredCurves( msg,
					    cst.display->style,
					    cst.display->style,
					    insCount,
					    pjList,
					    cst.env_info,
					    &outCount,
					    &outList ) ;

		__CheckRC( sts, *msg, "VSdrwRmCoveredCurves", wrapup ) ;

		outCount++ ;

	} else {
		__DBGpr_com( "No inside edge" ) ;
		outCount = 1 ;
	}

	/*
	 * Compress output list.
	 */
	if( !( outp->list = _MALLOC( outCount, struct GRid ) ) )
			vs$mem_fail() ;

	(outp->list)[0] = pjCvComp ;

	for( i=0; i<outCount-1; i++ )
		(outp->list)[i+1] = outList[i] ;

	outp->count = outCount ;

	__DBGpr_objlist( "Output list", outp->count, outp->list ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( insGrEdge.objid != NULL_OBJID ) {
			/* insGrEdge has been constructed but we erred off
			 * before having a chance to delete it...
			 */
			vs$bulk_delete( grids = &insGrEdge,
					theEnv= inp->elmEnv ) ;
		}

		if( !(sts & 1 & *msg) ) {
			if( pjList )
				vs$bulk_delete( count  = insCount,
						grids  = pjList,
						theEnv = cst.env_info ) ;

			vs$bulk_delete( count  = 1,
					grids  = &pjCvComp,
					theEnv = cst.env_info ) ;
		}

		vs$bulk_delete( count  = 1,
				grids  = &cvComp,
				theEnv = cst.env_info ) ;

		_FREE( insList	 ) ;
		_FREE( pjList	 ) ;
		_FREE( outList	 ) ;

		End
		return sts ;

} /* VSdrwPlateBottomSide */
/*----------------------------------------------------------------------------*/
long VSdrwPlateContour( msg, inp, xData, option, outp )

long			*msg ;
VSdrwInputData		*inp ;
VSdrwExecData		*xData ;
char			*option ;
VSdrwGraphicGroup	*outp ; {

	/*
	 * This function extracts the projection of the contour of the
	 * plate's bottom side.
	 */

	long			sts ;		  /* OM completion code.      */
	struct GRvg_construct	cst ;		  /* Construction list for    */
						  /* wireframe elements.      */
	struct GRid		botSd,		  /* Bottom side of plate.    */
				cvComp ;	  /* Composite curve of       */
						  /* contour.		      */
	struct GRobj_env	plate;	  	  /* Plate	              */
	OMuword 		pjClassid ;	  /* Class of the projected   */
						  /* curve.		      */

	SetProc( VSdrwPlateContour ); Begin

	__DBGpr_obj( "Plate to draw", *(inp->elmId) ) ;

	outp->count = 0 ;
	outp->list  = NULL ;

	cvComp.objid = NULL_OBJID ;

	plate.obj_id  = *(inp->elmId);
	plate.mod_env = *(inp->elmEnv);

	/*
	 * Construct construction list for wireframe elements.
	 */
	vs$fill_cnst_list( Msg		= msg,
			   Env_info	= inp->drwInfo.drwEnv,
			   Level	= xData->overrides.elmLevel,
			   Display	= &xData->overrides.elmDisplay,
			   Cnst_list	= cst ) ;

	VDstrlwr(option);

	if( strcmp( option, "neat" ) )
 	{
            sts = VSgetNeatPlEdges( msg, &plate, &cst, FALSE, NULL, 
				    NULL, &cvComp ) ;
            __CheckRC( sts, *msg, "VSgetNeatPlEdges", wrapup ) ;
	}
	else
	{
	   sts = VSgetNeatPlEdges( msg, &plate, &cst, TRUE, NULL, 
				   NULL, &cvComp );
	   __CheckRC( sts, *msg, "VSgetNeatPlEdges", wrapup ) ;  
	}
	__DBGpr_obj( "Composite curve of contour", cvComp ) ;
	
	/*
	 * Allocate memory for output curve.
	 */
	if( !( outp->list = _MALLOC( 1, struct GRid ) ) ) vs$mem_fail() ;

	/*
	 * Project composite curve onto drawing plane.
	 */
	sts = EFproject_any_curve_on_planen( msg,
					     &cst,
					     &cvComp,
					     cst.env_info,
					     inp->drwInfo.drwPlane,
					     inp->drwInfo.viewVector,
					     outp->list,
					     &pjClassid ) ;

	__CheckRC( sts, *msg, "EFproject_any_curve_on_planen", wrapup ) ;

	__DBGpr_obj( "Projection of contour", *(outp->list) ) ;

	outp->count = 1 ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !(sts & 1 & *msg) ) {
			if( outp->list ) {
				_FREE( outp->list ) ;
				outp->list  = NULL ;
				outp->count = 0 ;
			}
		}

		vs$bulk_delete( count  = 1,
				grids  = &cvComp,
				theEnv = cst.env_info ) ;

		End
		return sts ;

} /* VSdrwPlateContour */
/*----------------------------------------------------------------------------*/

end implementation VSplate ;
