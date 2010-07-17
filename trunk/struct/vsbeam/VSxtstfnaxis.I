/* $Id: VSxtstfnaxis.I,v 1.1.1.1 2001/01/04 21:10:13 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsbeam/VSxtstfnaxis.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSxtstfnaxis.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:13  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.4  1998/01/21  19:35:18  pinnacle
# TR179702512
#
# Revision 1.3  1998/01/21  17:01:20  pinnacle
# TR179702512
#
# Revision 1.2  1997/09/29  14:51:26  pinnacle
# TR179700969
#
 *
 * History:
 *      MM/DD/YY AUTHOR	DESCRIPTIO
 *      09/26/97 ah     added header
 *      09/29/97 ah	TR179700969 Cardinal Point 
 *      01/21/98 ah     TR179702512 Web Alignment Problem
 ***************************************************************************/

class implementation VSstfBeam ;

#include "OMmacros.h"
#include "exmacros.h"
#include "bstypes.h"
#include "bserr.h"
#include "EMSmsgdef.h"
#include "vsbmaxisdef.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bscveval.h"
#include "bsnorvec.h"
#include "bsalloccv.h"
#include "bscvxttpt.h"
#include "bsfreecv.h"
#include "ASsupport.h"
#include "vsgetinpbynm.h"
#include "vsvecmxproto.h"

#include "vsbeamproto.h"

extern long VSdistGeomGeom() ;
extern long VSextendAxisToSurface() ;
extern long VSbeamGetState(struct GRid *beamId, int *state);

extern OMuword	OPP_GRbcsubbc_class_id,
		OPP_GRlineseg_class_id,
		OPP_GR3dlineseg_class_id,
		OPP_EMSplane_class_id ;

from GRcurve	import GRendpts ;
/*----------------------------------------------------------------------------*/
long VSextendAxisToSurface( msg, bmId, bmEnv, suppAxis, suppSurf,
				trimSurf, whichEnd,
				cst, extAxis )

long			*msg ;
struct GRobj_env	*suppAxis,
			*suppSurf,
			*trimSurf ;
int			whichEnd ;
struct GRmd_env		*bmEnv ;
struct GRvg_construct	*cst ;
struct GRid		*bmId,
			*extAxis ; {

	long		sts ;			/* OM return code	*/
	struct IGRbsp_curve
			*axisGeom,		/* Geometry of axis	*/
			*extnGeom ;		/* Geometry of extension*/
	struct IGRbsp_surface
			*trimGeom ;		/* Geometry of trim surf*/
	OMuword		extClassid ;		/* Cl. of extended axis	*/
	struct GRvg_construct
			extCst ;		/* Const. list of ext.	*/
	IGRmatrix	xCS ;			/* Profile CS		*/
	struct GRid	xDef ;			/* Profile definition	*/
	IGRpoint	rectPt[4],		/* Rectangle points	*/
			extPoint ;
	double		eval[6] ;
	int		i ;
	double		d,
			maxDist ;
	int			order,
				nPoles ;

	/*
	 * Init stuff.
	 */
	axisGeom = extnGeom = NULL ; trimGeom = NULL ;

	/*
	 * Compute coordinate system of profile at beam axis parameter
	 * `whichEnd'.
	 */
	sts = om$send(	msg	= message VSbeam.VSgetCrossSectionCS(
						msg,
						bmEnv,
						suppSurf,
						suppAxis,
						(double) whichEnd,
						&xDef,
						xCS ),
			senderid= bmId->objid,
			targetid= bmId->objid,
			targetos= bmId->osnum ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetCrossSectionCS", wrapup ) ;

	/*
	 * Evaluate co-ordinates of the four points of the rectangle surrounding
	 * the profile :
	 *	rectPt[0]		rectPt[3]
	 *		+---------------+
	 *		|		|
	 *		+-----+   +-----+
	 *		      |   |
	 *		      |   |
	 *		      |   |
	 *		+-----+   +-----+
	 *		|		|
	 *		+---------------+
	 *	rectPt[1]		rectPt[2]
	 *
	 * They are first evaluate at the location of the cached profile
	 * definition (at the origin in the xy-plane z=0), then mapped to
	 * the site.
	 */

/* TR179701294 */
// TR179700969
// TR179702512
  {	
    IGRboolean cardOpt = FALSE ;
    int        state ;

    VSbeamGetState(bmId,&state);

    if( state & VS_m_NdState ) cardOpt = TRUE ;

    sts = VScardpt_to_point(bmEnv, xDef, &cardOpt, VS_e_BOT_LEFT, rectPt[0] ) ;
    sts = VScardpt_to_point(bmEnv, xDef, &cardOpt, VS_e_BOT_RGHT, rectPt[1] ) ;
    sts = VScardpt_to_point(bmEnv, xDef, &cardOpt, VS_e_UPP_LEFT, rectPt[2] ) ;
    sts = VScardpt_to_point(bmEnv, xDef, &cardOpt, VS_e_UPP_RGHT, rectPt[3] ) ;
  }


	/*
	 * Map points to the end of the beam axis.
	 */
	for( i = 0 ; i < 4 ; i++ ) {
	        VSmxprodpt( xCS, rectPt[i], rectPt[i] ) ;
        }

	/*
	 * Get geometry of support axis and trimming surface.
	 */
	vs$get_geometry(	msg	= msg,
				grobjId	= &suppAxis->_grid,
				grobjEnv= &suppAxis->mod_env,
				geometry= &axisGeom ) ;
	__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;

	vs$get_geometry(	msg	= msg,
				grobjId	= &trimSurf->_grid,
				grobjEnv= &trimSurf->mod_env,
				geometry= &trimGeom ) ;
	__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;


	maxDist = -1 ;
	for( i = 0 ; i < 4 ; i++ ) {
		sts = VSdistGeomGeom( msg, 2, rectPt[i], trimGeom, &d ) ;
		__CheckRC( sts, *msg, "VSdistGeomGeom", wrapup ) ;
		if( d > maxDist ) maxDist = d ;
	}

	BScveval( axisGeom, (double) whichEnd, 1, (IGRpoint *) eval, msg ) ;
	if( BSERROR( *msg ) ) { *msg = EMS_E_BSerror ; goto wrapup ; }

	if( whichEnd == 0 ) VSnegvc( eval + 3, eval + 3 ) ;

	BSnorvec( msg, eval + 3 ) ;

	for( i = 0 ; i < 3 ; i++ ) {
		extPoint[i] = eval[0+i] + maxDist * eval[3+i] ;
	}

	/*
	 * See the header of `BScvxttpt' for the following memory allocation.
	 */
	if( axisGeom->order < 3 ) {
		order	= 3 ;
		nPoles	=  7
			 + axisGeom->num_poles
			 + (   ( axisGeom->num_poles - axisGeom->order + 2 )
			     * ( 3 - axisGeom->order ) ) ;
	} else if( axisGeom->order > 3 ) {
		order	= axisGeom->order ;
		nPoles	=   axisGeom->num_poles
			  + 7
			  + ( 6 * ( axisGeom->order - 3 ) ) ;
	} else /* axisGeom->order = 3 */ {
		order	= axisGeom->order ;
		nPoles	= axisGeom->num_poles + 7 - 1 ;
	}
	BSalloccv(	order,
			nPoles,
			TRUE,		/* Result will be rational	*/
			0,
			&extnGeom,
			msg ) ;
	if( BSERROR( *msg ) ) {
		*msg = EMS_E_NoDynamicMemory ; sts = OM_E_NODYNMEM ;
		goto wrapup ;
	}
	extnGeom->num_poles	= nPoles ;
	extnGeom->order		= order ;
	extnGeom->num_knots	= nPoles + order ;
	extnGeom->rational	= TRUE ;

	/*
	 * Note that the following call will fail for certain B-splines if
	 * the distance to extend with is too large.
	 */
	BScvxttpt( msg, axisGeom, eval + 0, extPoint, extnGeom ) ;
	if( BSERROR( *msg ) ) {
		*msg = EMS_E_BSerror ; sts = OM_W_ABORT ; goto wrapup ;
	}

	/*
	 * Construct a curve object with extended geometry.
	 */
	extClassid =    vs$is_curve_linear(	msg		= msg,
						curveGeom	= extnGeom )
		     	? OPP_GR3dlineseg_class_id
		     	: OPP_GRbcsubbc_class_id ;

	*msg = EMS_E_OMerror ;
	extAxis->osnum = cst->env_info->_MD_OS ;
	sts = om$construct(	classid	= extClassid,
				osnum	= extAxis->osnum,
				p_objid	= &extAxis->objid ) ;
	__CheckRC( sts, 1, "om$construct", wrapup ) ;

	vs$fill_cnst_list(	Msg		= msg,
				Env_info	= cst->env_info,
				Display		= cst->display,
				Level		= cst->level,
				Properties	= cst->properties,
				Geometry	= extnGeom,
				Cnst_list	= extCst ) ;

	sts = om$send(	msg	= message GRgraphics.GRconstruct( &extCst ),
			senderid= extAxis->objid,
			targetid= extAxis->objid,
			targetos= extAxis->osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRconstruct", wrapup ) ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		_FREE( axisGeom ) ; _FREE( trimGeom ) ;
		if( extnGeom ) {
			long rc ;
			BSfreecv( &rc, extnGeom ) ;
		}

	return sts ;

} /* VSextendAxisToSurface */
/*----------------------------------------------------------------------------*/
long VSextendStfnAxisBeyondLimitSfs( msg, stfnId, stfnEnv,
					  suppSurf, suppAxis,
					  cst,
					  extnAxis )
long			*msg ;
struct	GRid		*stfnId ;
struct GRmd_env		*stfnEnv ;
struct GRobj_env	*suppSurf,
			*suppAxis ;
struct GRvg_construct	*cst ;
struct GRid		*extnAxis ; {


	long			sts ;
	struct	GRobj_env	limSf0,
				limSf1,
				*sfNear0,
				*sfNear1 ;
	struct IGRbsp_surface	*limGeom0	= NULL ;
	double			d0,
				d1 ;
	IGRpoint		ep0,
				ep1 ;
	struct GRid		beamAxis,
				extAt0,
				extAt1 ;

	extnAxis->objid = NULL_OBJID ;
	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	ASget_as_owner( &suppAxis->_grid, &beamAxis ) ;
	if( IF_NULL_OBJID( beamAxis.objid ) ) goto wrapup ;

	sts = VSgetInputByName(	msg, &beamAxis, VS_K_baStartSurf,
				&limSf0._grid, &limSf0.mod_env ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	sts = VSgetInputByName(	msg, &beamAxis, VS_K_baEndSurf,
				&limSf1._grid, &limSf1.mod_env ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	vs$get_geometry(	msg	= msg,
				grobjId	= &limSf0._grid,
				grobjEnv= &limSf0.mod_env,
				geometry= &limGeom0 ) ;
	__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;

	sts = om$send(	msg	= message GRcurve.GRendpts(
						msg,
						&suppAxis->_matrix_type,
						suppAxis->_matrix,
						ep0,
						ep1 ),
			senderid= suppAxis->_objid,
			targetid= suppAxis->_objid,
			targetos= suppAxis->_osnum ) ;
	__CheckRC( sts, *msg, "GRcurve.GRendpts", wrapup ) ;

	sts = VSdistGeomGeom( msg, 2, ep0, limGeom0, &d0 ) ;
	__CheckRC( sts, *msg, "VSdistGeomGeom", wrapup ) ;

	sts = VSdistGeomGeom( msg, 2, ep1, limGeom0, &d1 ) ;
	__CheckRC( sts, *msg, "VSdistGeomGeom", wrapup ) ;

	if( d0 < d1 ) {	sfNear0 = &limSf0 ; sfNear1 = &limSf1 ;
	} else {	sfNear0 = &limSf1 ; sfNear1 = &limSf0 ; }

	sts = VSextendAxisToSurface(	msg,
					stfnId,
					stfnEnv,
					suppAxis,
					suppSurf,
					sfNear0,
					0,
					cst,
					&extAt0 ) ;
	if( sts & 1 & *msg ) {
		struct GRobj_env	toExtAgain ;

		toExtAgain._grid	= extAt0 ;
		toExtAgain.mod_env	= *cst->env_info ;
		sts = VSextendAxisToSurface(	msg,
						stfnId,
						stfnEnv,
						&toExtAgain,
						suppSurf,
						sfNear1,
						1,
						cst,
						&extAt1 ) ;
		if( sts & 1 & *msg ) {
			*extnAxis = extAt1 ;

			vs$bulk_delete(	grids	= &extAt0,
					theEnv	= cst->env_info ) ;
		} else {
			*extnAxis = extAt0 ;
		}
	}

	sts = OM_S_SUCCESS ;
	*msg= MSSUCC ;

	wrapup :
		_FREE( limGeom0 ) ;
		return sts ;

} /* VSextendStfnAxisBeyondLimitSfs */
/*----------------------------------------------------------------------------*/

end implementation VSstfBeam ;

