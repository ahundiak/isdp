/* $Id: VSplsfint.I,v 1.1.1.1 2001/01/04 21:10:40 cvs Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:	vsgeom/VSplsfint.I
 *
 * Description:
 *              This function interfaced by macro "vs$plane_surface_intersection".
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSplsfint.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:40  cvs
 *	Initial import to CVS
 *	
# Revision 1.3  1999/03/16  15:51:10  pinnacle
# tr179900265
#
# Revision 1.2  1998/08/13  14:44:12  pinnacle
# tr179801437
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/12/98  ah      TR179801437 Failing on some surfaces
 * 03/03/99  Manoj   TR179900265 EMSsurface.EMintplane() failing 
 * 		     on some surfaces. Changing tolerance makes it work.
 * 03/16/99  ah      TR179900265 Few tolerance tweaks
 ***************************************************************************/
class implementation EMSsubbs ;

#include <stdio.h>
#include <stdlib.h>
#include "growner.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "vsgeommacros.h"
#include "msdef.h"
#include "EMSmsgdef.h"
/*
 * Includes of function prototypes.
 */
#include "vsvecmxproto.h"

extern OMuword	OPP_GRgrgrp_class_id ;

/*
 * EF 09/30/94 Execute data reduction.
 */
extern long VDSapplyDataReduction() ;

from EMSplane	import EMplaneDef ;
from GRowner	import GRget_number_components,
		       GRget_components,
		       GRdrop ;
/*----------------------------------------------------------------------------*/
long VSplaneSurfaceIntersection( msg, planeObj, planeGeom, surface, cst,
				 nb_result, resultList )

long			*msg ;
struct GRobj_env	*planeObj ;
struct IGRplane 	*planeGeom ;
struct GRobj_env	*surface ;
struct GRvg_construct	*cst ;
int			*nb_result ;
struct GRid		**resultList ; {

	long			sts ;
	struct GRlc_info	surface_info ;
	struct GRid		*inters = NULL ;
	struct IGRplane 	plane_definition ;
	double			normalPlane[3],
				pointPlane[3] ;

	/*
	 * Initialize structure surface_info.
	 */
	surface_info.located_obj	= surface->obj_id ;
	surface_info.module_info	= surface->mod_env ;

	/*
	 * Retrieve normal and a point on plane if given plane is an object.
	 */
	plane_definition.normal = normalPlane ;
	plane_definition.point	= pointPlane ;

	if( planeObj ) {
		sts = om$send( msg	= message EMSplane.EMplaneDef(
							msg,
							&planeObj->_matrix_type,
							planeObj->_matrix,
							&plane_definition ),
			       senderid = planeObj->_objid,
			       targetid = planeObj->_objid,
			       targetos = planeObj->_osnum ) ;
		__CheckRC( sts, *msg, "EMSplane.EMplaneDef", wrapup ) ;
	} else {
		VSvccpy( normalPlane, planeGeom->normal ) ;
		VSvccpy( pointPlane,  planeGeom->point	) ;
	}

	/*
	 * Intersect plane and surface.
	 */
	sts = om$send( msg   = message EMSsurface.EMintplane( cst,
							      &plane_definition,
							      &surface_info,
							      nb_result,
							      &inters,
							      (int *) msg ),
		       senderid = surface->_objid,
		       targetid = surface->_objid,
		       targetos = surface->_osnum ) ;

	/* -----------------------------------------------------------------
	 * TR179900265 If it fails, bump up tolerance and try again
	 */
	if (*nb_result <= 0) {

	  IGRdouble baseTol;

	  gr$get_basis_tolerance(buffer = &baseTol);
	  baseTol *= 10.0;
	  gr$put_basis_tolerance(buffer = &baseTol);
	  baseTol /= 10.0;

	  sts = om$send(msg = message EMSsurface.
			EMintplane(cst,
				   &plane_definition,
				   &surface_info,
				   nb_result,
				   &inters,
				   (int *) msg ),
			senderid = surface->_objid,
			targetid = surface->_objid,
			targetos = surface->_osnum);
	  
	  gr$put_basis_tolerance(buffer = &baseTol);

	}
	  
	/* -----------------------------------------------------------------
	 * TR179801437
	 * Some change in ems 3.4 results in errors being returned
	 * even though an intersection was made.  Releated to the extended
	 * geometry nonsense.
	 *
	 * If we get results then use them and ignore errors/warnings
	 */
	if (*nb_result > 0) {
	   sts = OM_S_SUCCESS;
	  *msg = MSSUCC;
	}
	__CheckRC( sts, *msg, "EMSsurface.EMintplane", wrapup ) ;

	/*
	 * EF ( 09/30/94 ).
	 * Execute data reduction. ( Don't check about return code because
	 * the function returns something even if it fails ).
	 *
	 * TR179801437 Use local msg return code as it does fail in some
	 * cases relating to extended geometry
	 *
	 */
	if( planeObj ) {
	  struct GRlc_info plane_info ;
	  IGRlong msg1;
	  
	  plane_info.located_obj	= planeObj->obj_id ;
	  plane_info.module_info	= planeObj->mod_env ;

	  VDSapplyDataReduction( &msg1,
				 &surface_info,
				 &plane_info,
				 cst,
				 *nb_result,
				 inters ) ;
	}

	/*
	 * If the number of intersections is equal to one, perhaps there is just
	 * one intersection or many intersections stored in a graphic group. So
	 * retrieve all elements in the graphic group.
	 */
	if( *nb_result == 1 &&
	    vs$is_ancestry_valid( object = inters,
				  classid= OPP_GRgrgrp_class_id ) ) {

		int		nb_comp ;
		struct	GRid	gg_id ;

		gg_id = *inters ;
		/*
		 * Retrieve the number of components.
		 */
		sts = om$send( msg   = message GRowner.GRget_number_components(
								     msg,
								     &nb_comp ),
			       senderid = gg_id.objid,
			       targetid = gg_id.objid,
			       targetos = gg_id.osnum ) ;
		__CheckRC( sts, *msg, "GRgrgrp.GRget_number_components",wrapup);

		/*
		 * Retrieve all components.
		 */
		_FREE( inters ) ;
		inters = _MALLOC( nb_comp, struct GRid ) ;
		if( !inters ) {
			*msg = EMS_E_NoDynamicMemory ; goto wrapup ;
		}

		sts = om$send( msg   = message GRowner.GRget_components(
								  msg,
								  cst->env_info,
								  inters,
								  nb_comp,
								  nb_result,
								  0,
								  nb_comp ),
			       senderid = gg_id.objid,
			       targetid = gg_id.objid,
			       targetos = gg_id.osnum ) ;
		__CheckRC( sts, *msg, "GRowner.GRget_components",wrapup ) ;

		/*
		 * Delete graphic group.
		 */
		sts = om$send( msg	= message GRowner.GRdrop(
								msg,
								cst->env_info ),
			       senderid = gg_id.objid,
			       targetid = gg_id.objid,
			       targetos = gg_id.osnum ) ;
		__CheckRC( sts, *msg, "GRowner.GRdrop",wrapup ) ;

	} else {
		if( !*nb_result ) *msg = MSFAIL ;
	}

	wrapup :
		if( !( *msg & 1 & sts ) ) {
			*nb_result  = 0 ;
			*msg	    = EMS_W_NoSolution ;
			*resultList = NULL ;
			_FREE( inters ) ;
		} else	{
			*msg	    = MSSUCC ;
			*resultList = inters ;
		}

		return sts ;

} /* VSplaneSurfaceIntersection */
/*----------------------------------------------------------------------------*/

end implementation EMSsubbs ;
