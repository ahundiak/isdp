/* $Id: VSxbxtndaxis.I,v 1.1.1.1 2001/01/04 21:10:13 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        vsbeam/VSxbxtndaxis.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSxbxtndaxis.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:13  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/04/09  07:48:18  pinnacle
# Replaced: vsbeam/VSxbxtndaxis.I for:  by svkadamb for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTIO
 *      04/09/98	suresh		modification. If the axis is already 
					extended then extension routines will 
					fail. In such a condition return the 
					support axis as the extended axis.
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSxtrBeam ;

#include <stdlib.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "bstypes.h"
#include "vsbeammacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "mabcrevpa.h"
#include "bscveval.h"
#include "bsdotp.h"
#include "bsfreecv.h"

extern long		VSext_axis_for_trimming_plane() ;

extern OMuword	OPP_GRbcsubbc_class_id,
		OPP_GRlineseg_class_id,
		OPP_GR3dlineseg_class_id,
		OPP_EMSplane_class_id ;
/*----------------------------------------------------------------------------*/
method VSextendAxis(	long			*msg ;
			struct GRobj_env	*trimSurf ;
			struct GRvg_construct	*cst ;
			struct GRid		*extAxis ) {

	long			sts ;		/* OM return code	*/
	struct GRobj_env	suppAxis ;	/* Support axis    	*/
	struct IGRbsp_curve	*axisGeom,	/* Geometry of axis	*/
				*extnGeom ;	/* Geometry of extension*/
	struct IGRbsp_surface	*trimGeom ;	/* Geometry of trim surf*/
	OMuword			extClassid ;	/* Cl. of extended axis	*/
	struct GRvg_construct
				extCst ;	/* Const. list of ext.	*/
	double			pm,
				eval1[6],	/* For BScveval		*/
				eval2[6] ;	/* For BScveval		*/
	struct GRobj_env	bigPlane ;

	/*
	 * Init stuff.
	 */
	axisGeom = extnGeom = NULL ; trimGeom = NULL ;
	bigPlane._objid = NULL_OBJID ;

	/*
	 * Get supporting axis. Use wrt message to get original axis.
	 */
	sts = om$send(	msg	= message VSmodBeam.VSgetSupportAxis(
					msg, cst->env_info, &suppAxis ),
			mode	= OM_e_wrt_message,
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSmodBeam.VSgetSupportAxis", wrapup ) ;

	/*
	 * If trimming surface is a plane, we consider it as infinite.
	 */
	if( vs$is_ancestry_valid(	object	= &trimSurf->_grid,
					classid	= OPP_EMSplane_class_id ) ) {
		struct GRid	plane ;
		sts = vs$makeBiggerPlane(	msg	= msg,
						inPlane	= trimSurf,
						element	= &suppAxis,
						scale	= 100,
						cst	= cst,
						bigPlane= &plane ) ;
		if( sts & 1 & *msg ) {
			bigPlane._grid	= plane ;
			bigPlane.mod_env= *cst->env_info ;
			trimSurf	= &bigPlane ;
		}
	}
	/*
	 * Get geometry of support axis and trimming surface.
	 */
	vs$get_geometry(	msg	= msg,
				grobjId	= &suppAxis._grid,
				grobjEnv= &suppAxis.mod_env,
				geometry= &axisGeom ) ;
	__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;

	vs$get_geometry(	msg	= msg,
				grobjId	= &trimSurf->_grid,
				grobjEnv= &trimSurf->mod_env,
				geometry= &trimGeom ) ;
	__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;

	{
	  struct GRobj_env suppSf ;

	  sts = om$send( msg      = message VSbeam.VSgetSupportSf(
						msg, cst->env_info, &suppSf ),
			 targetid = my_id ) ;
	  __CheckRC( sts, *msg, "VSbeam.VSgetSupportSf", wrapup ) ;

	  if(    vs$is_ancestry_valid(	object	= &suppSf._grid,
	    				classid	= OPP_EMSplane_class_id )
	      && vs$is_ancestry_valid(	object	= &trimSurf->_grid,
	    				classid	= OPP_EMSplane_class_id ) ) {

		/*
		 * Special case: use a more reliable (i.e. working more often)
		 * algorithm.
		 */
		struct GRid	 myGRid ;
		struct GRobj_env supports[2] ;

		myGRid.objid	= my_id ;
		myGRid.osnum	= OM_Gw_current_OS ;
		supports[0]	= suppSf ;
		supports[1]	= suppAxis ;
		sts = VSext_axis_for_trimming_plane(	msg,
							&myGRid,
							cst->env_info,
							supports,
							axisGeom,
							trimGeom,
							(double) me->extEnd,
				/*
				 * No extra length percentage for extension.
				 */
							0.,
				/* 
				 * Return the whole extended curve,
				 * not the extension portion:
				 */
							FALSE,
							&extnGeom ) ;
		/*
		 * If there is no extension then send back the support 
		 * axis object as the exntended axis
		 */
		// __CheckRC( sts, *msg, "VSext_axis_for_trimming_plane", wrapup ) ;
	  } else {
		/*
		 * Extend axis till it intersects trimming surface, if possible.
		 */
		vs$extend_curve_to_surface(	msg		= msg,
						curveGeom	= axisGeom,
						surfaceGeom	= trimGeom,
						whichEnd	= me->extEnd,
						p_curveGeom	= &extnGeom ) ;
		// if( !( 1 & *msg ) ) { sts = OM_W_ABORT ; goto wrapup ; }
		/*
		 * If there is no extension then send back the support 
		 * axis object as the exntended axis
		 */
	  }
	}
	if( !extnGeom ) { 
		struct GRid copy ;
		/*
		 * make a copy of the support axis object
		 */
		sts = vs$grCopy(        msg     = msg,
                                        frEnv   = &suppAxis.mod_env,
                                        frObj   = &suppAxis._grid,
                                        toEnv   = cst->env_info,
                                        toObj   = &copy ) ;
 
                __CheckRC( sts, *msg, "vs$grCopy", wrapup ) ;

		extAxis->osnum = cst->env_info->_MD_OS ;
		extAxis->objid = copy.objid  ;

		*msg 	= MSSUCC ;
		sts	= OM_S_SUCCESS ;
		goto wrapup  ;
	}

	/*
	 * Check that original axis and extended axis have the same orientation.
	 */
	pm = me->extEnd == 0 ? 1. : 0. ;
	BScveval( axisGeom, pm, 2, (IGRpoint *) eval1, msg ) ;
	BScveval( extnGeom, pm, 2, (IGRpoint *) eval2, msg ) ;

	if( BSdotp( msg, eval1 + 3, eval2 + 3 ) < 0 ) {
		MAbcrevparm( msg, extnGeom, extnGeom ) ;
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
			targetid= extAxis->objid,
			targetos= extAxis->osnum ) ;
	__CheckRC( sts, *msg, "GRgraphics.GRconstruct", wrapup ) ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		_FREE( axisGeom ) ; _FREE( trimGeom ) ;
		if( extnGeom ) { long rc ; BSfreecv( &rc, extnGeom ) ; }
		if( !IF_NULL_OBJID( bigPlane._objid ) ) {
			vs$bulk_delete(	objenvs = &bigPlane ) ;
		}

	return sts ;

} /* method VSextendAxis */
/*----------------------------------------------------------------------------*/

end implementation VSxtrBeam ;

