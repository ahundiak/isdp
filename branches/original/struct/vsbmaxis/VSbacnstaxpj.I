/* $Id: VSbacnstaxpj.I,v 1.3 2002/05/16 15:34:02 ramarao Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	vsbmaxis/VSbacnstaxpj.I
 *
 * Description:
 *	Routines to construct the beam axis graphics.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSbacnstaxpj.I,v $
 *	Revision 1.3  2002/05/16 15:34:02  ramarao
 *	Fixed a crash problem ( TR# 5262 ).
 *	
 *	Revision 1.2  2001/01/17 00:12:51  ramarao
 *	*** empty log message ***
 *	
# Revision 1.1  2000/11/25  18:01:10  pinnacle
# Created: struct/vsbmaxis/VSbacnstaxpj.I by jpulapar for Service Pack
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/01/22  14:18:34  pinnacle
# Replaced: vsbmaxis/VSbacnstaxpj.I for:  by azuurhou for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			i-struct
 *	01/22/98	adz		Test with alternative project 
 *					routine for the axis.
 *      11/25/00        Jayadev         TR179900742 - spans change
 ***************************************************************************/

/*
	I/STRUCT

VScnst_axis_project_onto_side
-----------------------------

  Given a curve, a side of plate ( surface ), and two limiting surfaces
  ( s_surface and e_surface ), this method returns an axis with
  its construction list ( cst ). The axis is the projection of the line
  normal to the surface. In case of many projections, the axis is the first
  result which :

	- intersects with the two limiting surfaces.
	- intersects just with one limiting surface.
	- or the first result if there are no intersections with
	  the two limiting surfaces.

  notes :
  -------
	If the limiting surfaces are planar they will be considered as
	infinite planes.

  The values of *msg are :
	  MSSUCC		if successful operation.
	  EMS_W_NoSolution	if no solution found.
	  EMS_E_NoDynamicMemory if no dynamic memory.
*/

class implementation VSbeamAxis ;

#include <stdlib.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsiomacros.h"
#include "vsdbgmacros.h"

from EMSsubbs	import EMproject_curve_along_surface_normals ;
from EMSsubbs	import EMproject_curve_onto_surface ;

from GRsubbc	import EMleast_squares_fit_curvee ;
/*----------------------------------------------------------------------------*/
long VSfitCurve( msg, curveId, curveEnv, cst, fitCv )

long			*msg ;
struct GRid		*curveId ;
struct GRmd_env 	*curveEnv ;
struct GRvg_construct	*cst ;
struct GRid		*fitCv ; {

	/*
	 * Reduce data and fit input line string.
	 * NOTE: returns EMS_I_InvalidCase if input curve is not a line string
	 * or if the input line string does not have a sufficient number of
	 * points, in these two cases `*fitCv' is set to `*curveId'.
	 */
	long			sts,
				max_indicator=-1 ;
	struct IGRbsp_curve	*cvGeom ;
	double			max_error,
				average_error ;
	IGRpoint		error_line[2] ;
	struct GRlc_info	info ;
	int			order,
				spans ;
	extern OMuword		OPP_GR3dlinestr_class_id,
				OPP_GRbcsubbc_class_id ;

#define ORDER 4

	vs$dotsInStsFld( dots = 1 ) ;

	fitCv->objid = NULL_OBJID ;

	/*
	 * We only want to reduce linestrings.
	 */
	if( !vs$is_ancestry_valid(	classid = OPP_GR3dlinestr_class_id,
					object	= curveId ) ) {

		/*
		 * Not a line string: return input curve.
		 */
		*fitCv	= *curveId ;
		*msg	= EMS_I_InvalidCase ;
		sts	= OM_S_SUCCESS ;
		goto wrapup ;
	}

	/*
	 * See if input line string is eligible for fit w/ data reduction.
	 */
	sts = om$send(	msg	= message GRvg.GRgenabsg(
							msg,
							&curveEnv->_MATRIX_TYPE,
							curveEnv->_MATRIX,
							(char **) &cvGeom ),
			senderid= curveId->objid,
			targetid= curveId->objid,
			targetos= curveId->osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgenabsg", wrapup ) ;

	vs$dotsInStsFld() ;

	if(    cvGeom->order == 2
	    && ! cvGeom->rational
	    && cvGeom->num_poles < ORDER ) {
		/*
		 * Nothing to fit: return input curve.
		 */
		*fitCv	= *curveId ;
		*msg	= EMS_I_InvalidCase ;
		sts	= OM_S_SUCCESS ;
		goto wrapup ;
	}

	order = cvGeom->num_poles < 4 ? ORDER : ORDER + 1 ;
	//spans = cvGeom->num_poles - 1; TR179900742
        spans = (cvGeom->num_poles/11) + 2;
	fitCv->osnum = cst->env_info->_MD_OS ;

	sts = om$construct(	classid = OPP_GRbcsubbc_class_id,
				osnum	= fitCv->osnum,
				p_objid = &fitCv->objid ) ;
	if( !( sts & 1 ) ) { *msg = EMS_E_OMerror ; goto wrapup ; }

	info.located_obj	= *curveId ;
	info.module_info	= *curveEnv ;

	vs$dotsInStsFld() ;

	sts = om$send(	msg	= message GRsubbc.EMleast_squares_fit_curvee(
							order,
		/* "Periodic" flag: unused here */	FALSE,
		/* "# of points": unused here	*/	0,
		/* "List of points": unused here*/	NULL,
		/* Input linestring		*/	&info,
		/* Beginning tangent (none)	*/	NULL,
		/* Ending    tangent (none)	*/	NULL,
		/* "# of spans" 		*/	spans,
		/* Reference curve (none)	*/	NULL,
							&average_error,
							&max_error,
							&max_indicator,
							error_line,
							cst ),
			senderid= fitCv->objid,
			targetid= fitCv->objid,
			targetos= fitCv->osnum ) ;
	*msg = *cst->msg ;
	__CheckRC( sts, *msg, "GRsubbc.EMreduced_fit_curve", wrapup ) ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			if( !IF_NULL_OBJID( fitCv->objid ) ) {
				vs$bulk_delete( grids	= fitCv,
						theEnv	= cst->env_info ) ;
				fitCv->objid = NULL_OBJID ;
			}
		}
		vs$dotsInStsFld( dots = clear ) ;

		return sts ;

#undef ORDER

} /* VSfitCurve */
/*----------------------------------------------------------------------------*/
method VScnst_axis_project_onto_side( long			*msg ;
				      struct GRobj_env		*curve ;
				      struct GRobj_env		*side;
				      struct GRobj_env		*s_surface ;
				      struct GRobj_env		*e_surface ;
				      struct GRvg_construct	*cst ;
				      struct GRid		*axis ) {

	long			sts,
				nb_proj = 0 ;
	int			index	= 0 ;
	struct GRlc_info	curve_info,
				side_info ;
	IGRdouble		parm[2] ;
	IGRvector		vector ;
	OM_S_OBJID		*proj_obj = NULL ;

	/*
	 * Initialize struct curve_info and side_info for message
	 * EMSsubbs.EMproject_curve_along_surface_normals.
	 */
	curve_info.located_obj	= curve->obj_id ;
	curve_info.module_info	= curve->mod_env ;
	side_info.located_obj	= side->obj_id ;
	side_info.module_info	= side->mod_env ;

#define	SURFACE_NORMAL	1
	/*
	 * Project curve.
	 */
#ifdef	SURFACE_NORMAL
	sts = om$send(
		msg = message EMSsubbs.EMproject_curve_along_surface_normals(
							&curve_info,
							&side_info,
							cst,
							TRUE,
							TRUE,
							&nb_proj,
							&proj_obj,
							msg ),
			targetid = side->_objid,
			targetos = side->_osnum ) ;
#else

	parm[0] = 0.5 ; parm[1] = 0.5 ;

	sts =
	vs$get_normal(	msg	= msg,
			sfId	= &side->obj_id, 
			sfEnv	= &side->mod_env,
			parm	= parm,
			normal	= vector );

	sts = om$send(
		msg = message EMSsubbs.EMproject_curve_onto_surface(
							&curve_info,
							&side_info,
							cst,
							vector,
							TRUE,
							TRUE,
							&nb_proj,
							&proj_obj,
							msg ),
			targetid = side->_objid,
			targetos = side->_osnum ) ;
#endif
	if( nb_proj < 1 ) {
		axis->objid = NULL_OBJID ;
		if( *msg == MANOMEMORY ) {
			 *msg = EMS_E_NoDynamicMemory ;
			 sts = OM_E_NODYNMEM ;
		} else {
			/*
			 * No solution found.
			 */
			 *msg = EMS_W_NoSolution ;
			 sts = OM_W_ABORT ;
		}
		goto wrapup ;
	}

	/*
	 * Keep result which intersects with limiting surfaces.
	 */
	if( s_surface && e_surface && nb_proj > 1 ) {
		int		i ;
		struct GRid	*proj_grid = NULL ;

		proj_grid = _MALLOC( nb_proj, struct GRid ) ;

		/*
		 * If no memory allocated, keep first projection.
		 */
		if( proj_grid ) {

			for( i=0; i<nb_proj; i++ ) {
				proj_grid[i].objid = proj_obj[i] ;
				proj_grid[i].osnum = curve->_osnum ;
			}

			VSfindCurveIntersectingSurfaces( msg,
							 s_surface,
							 e_surface,
							 nb_proj,
							 proj_grid,
							 cst->env_info,
							 &index ) ;
		}

		_FREE( proj_grid ) ;
	}

	axis->objid = proj_obj[index] ;
	axis->osnum = cst->env_info->_MD_OS ;

	/*
	 * Delete other projections found.
	 */
	proj_obj[index] = NULL_OBJID ;

	vs$bulk_delete( count	= nb_proj,
			objids	= proj_obj,
			theEnv	= cst->env_info ) ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		 if( nb_proj ) _FREE( proj_obj ) ;
		 return sts ;

} /* method VScnst_axis_project_onto_side */
/*----------------------------------------------------------------------------*/

end implementation VSbeamAxis ;
