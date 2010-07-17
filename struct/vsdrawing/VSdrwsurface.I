/* $Id: VSdrwsurface.I,v 1.3 2001/03/10 17:55:22 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsdrawing/VSdrwsurface.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdrwsurface.I,v $
 *      Revision 1.3  2001/03/10 17:55:22  ramarao
 *      Added Header and proper return code in Declivity function.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      03/10/01        Rama Rao        Header Creation && Added Declivity fn.
 * -------------------------------------------------------------------*/

class implementation EMSsurface ;

#include <stdio.h>
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsdrwproto.h"

extern OMuword	OPP_GRpoint_class_id ;

extern void	VSsetGRids() ;
/*----------------------------------------------------------------------------*/
long VSdrwProjectSurfaceWithHiddenLines( msg, sfId, sfEnv, elmCount, elmList,
					 viewVector, drwPlane, dspHid, dspVis,
					 cst, count, list )

long			*msg ;
struct GRid		*sfId ;
struct GRmd_env 	*sfEnv ;
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
	 * This function projects a surface ( sfId, sfEnv ) onto a drawing
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
				wfCount,  /* Count of wireframes of surface   */
					  /* to project.		      */
				pjCount ; /* Count of projected wireframes.   */
	struct GRid		*wfList,  /* Wireframes of surface to project.*/
				*pjList ; /* List of projected wireframes.    */
	OMuword 		pjClassid;/* Classid of projected wireframe.  */

	SetProc( VSdrwProjectSurfaceWithHiddenLines ); Begin

	__DBGpr_obj( "Surface to project", *sfId ) ;

	*count = 0 ;
	*list  = NULL ;

	wfCount = pjCount = 0 ;
	wfList	= pjList  = NULL ;

	/*
	 * Get wireframes of surface to project.
	 */
	sts = VSdrwSfToWireFrame( msg,
				  sfId,
				  sfEnv,
				  cst,
				  &wfCount,
				  &wfList ) ;

	__CheckRC( sts, *msg, "VSdrwSfToWireFrame", wrapup ) ;

	__DBGpr_int( "Count of wireframes", wfCount ) ;

	/*
	 * Allocate memory for projected wireframes.
	 */
	if( !( pjList = _MALLOC( wfCount, struct GRid ) ) ) vs$mem_fail() ;

	VSsetGRids( cst->env_info->_MD_OS, wfCount, pjList ) ;

	/*
	 * For each wireframes, project it with hidden lines.
	 */
	for( i=0; i<wfCount; i++ ) {

		__DBGpr_obj( "Wireframe", wfList[i] ) ;

		sts = VSdrwProjectWireframeWithHiddenParts( msg,
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

		__CheckRC( sts, *msg, "VSdrwProjectWireframeWithHiddenParts",
			   wrapup ) ;

		__DBGpr_obj( "Projected wireframe", pjList[pjCount] ) ;
		__DBGpr_com( "Is a point ?" ) ;

		/*
		 * Do not take points.
		 */
		if( om$is_ancestry_valid( subclassid   = pjClassid,
					  superclassid = OPP_GRpoint_class_id )
						== OM_S_SUCCESS ) {

			__DBGpr_com( "\t-> Yes" ) ;

			vs$bulk_delete( grids  = pjList +pjCount,
					theEnv = cst->env_info ) ;

		} else {
			__DBGpr_com( "\t-> No" ) ;
			pjCount++ ;
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

	__DBGpr_objlist( "Drawing of surface", *count, *list ) ;

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

} /* VSdrwProjectSurfaceWithHiddenLines */
/*----------------------------------------------------------------------------*/

long VSdrwGetDeclivity( msg, inp, xData, declivityAngle )
long                    *msg ;
const VSdrwInputData    *inp ;
const VSdrwExecData     *xData ;
double                  *declivityAngle ; {

   IGRlong		sts;

   /*
    * Dummy Function. Need to be implemented at a later stage.
    */

   sts = *msg = MSSUCC;

   *declivityAngle = 0.0;

   return sts;
}

end implementation EMSsurface ;
