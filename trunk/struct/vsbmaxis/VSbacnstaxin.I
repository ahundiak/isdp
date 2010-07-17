/*
	I/STRUCT

  Given a surface, a side of plate ( surface ) and two limiting surfaces
  ( s_surface and e_surface ), this method returns an axis with its
  construction list ( cst ). The axis is the intersection between the surface
  and the side. In case of many intersections, the axis is the first result
  which :

	- intersects with the two surfaces limit.
	- intersects just with one surface limit.
	- or the first result if there is no intersection with
	  the two limiting surfaces.

  Notes :
  -------
	If the surface is planar it will be considered as an infinite plane.

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
#include "vsdbgmacros.h"
#include "vsgeommacros.h"
/*
 * Includes of function prototypes.
 */
#include "EMSsffmacros.h"

extern long	VSfitCurve() ;
extern long	VSfindCurveIntersectingSurfaces() ;
extern long	VSremoveAllCuspsOnCurve() ;
/*----------------------------------------------------------------------------*/
method VScnst_axis_int_surf_and_side( long			*msg ;
				      struct GRobj_env		*surface ;
				      struct GRobj_env		*side ;
				      struct GRobj_env		*s_surface ;
				      struct GRobj_env		*e_surface ;
				      struct GRvg_construct	*cst ;
				      struct GRid		*axis ) {

	long			sts ;
	int			nb_inter = 0 ;
	int			is_planar,
				index = 0 ;
	struct GRid		*inter_obj = NULL ;

	/*
	 * See if surface is planar.
	 */
	is_planar = vs$is_surface_planar( msg	 = msg,
					  surfId = &surface->obj_id,
					  surfEnv= &surface->mod_env ) ;

	if( !( *msg & 1 ) ) {
		CheckRC( 1, *msg ) ; sts  = OM_W_ABORT ; goto wrapup ;
	}

	if( is_planar ) {
		sts = vs$plane_surface_intersection( msg	= msg,
						     planeObj	= surface,
						     surface	= side,
						     cst	= cst,
						     nb_result	= &nb_inter,
						     resultList = &inter_obj ) ;

	} else {
		struct GRlc_info	surface_info ;
		struct GRlc_info	side_info ;

		/*
		 * Initialize struct surface_info and side_info for function
		 * EMintersect_two_element.
		 */
		surface_info.located_obj	= surface->obj_id ;
		surface_info.module_info	= surface->mod_env ;
		side_info.located_obj		= side->obj_id ;
		side_info.module_info		= side->mod_env ;

		/*
		 * Intersect side and surface.
		 */
		sts = EMintersect_two_element(	&surface_info,
						&side_info,
						TRUE,
						cst,
						&nb_inter,
						&inter_obj,
						msg ) ;
	}

	if( nb_inter < 1 ) {
		axis->objid = NULL_OBJID ;
		if( *msg == EMS_E_NoDynamicMemory ) {
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
	 * Keep the result which intersects with limiting surfaces.
	 */
	if( s_surface && e_surface && nb_inter > 1 ) {

		VSfindCurveIntersectingSurfaces( msg,
						 s_surface,
						 e_surface,
						 nb_inter,
						 inter_obj,
						 cst->env_info,
						 &index ) ;
	}

	*axis = inter_obj[index] ;

	/*
	 * Delete other intersections found.
	 */
	inter_obj[index].objid = NULL_OBJID ;

	vs$bulk_delete( count	= nb_inter,
			grids	= inter_obj,
			theEnv	= cst->env_info ) ;

	/*
	 * EF ( 01/05/94 )
	 * Remove cusp points on axis.
	 */
	sts = VSremoveAllCuspsOnCurve( msg, cst->env_info, axis ) ;

	__CheckRC( sts, *msg, "VSremoveAllCuspsOnCurve", wrapup ) ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		 if( nb_inter ) _FREE( inter_obj ) ;
		 return sts ;

} /* method VScnst_axis_int_surf_and_side */
/*----------------------------------------------------------------------------*/

end implementation VSbeamAxis ;
