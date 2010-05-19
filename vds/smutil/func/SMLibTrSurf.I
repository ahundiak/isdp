/* $Id: SMLibTrSurf.I,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/smutil/func / SMLibTrSurf.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMLibTrSurf.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:39  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/04/17  14:54:20  pinnacle
# Replaced: smframe/cmd/SMModNotif.I for:  by ksundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*

   File name :		SMLibTrSurf.I
   Revision date :	92/11/04

   Description :		
	"Trim composite surface by curve on surface"
	Library implementing the function SMTrSurfPassArg() needed
	by the command object SMCoTrSurf.u

   History :  NOT YET COMPLETED - WAITING FOR MORE SPEC'S 

 92/10/21	alc	Creation date

 */


class implementation Root ;

#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "griodef.h"
#include "godef.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "dp.h"
#include "OMmacros.h"
#include "grmacros.h"
#include "parametric.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "bserr.h"
#include "msdef.h"

/* Prototypes */
#include "bsrgbxint.h"
#include "bsdistptpts.h"
#include "VDmem.h"

from GRgraphics		import GRgetrang  ;
from GRowner		import GRget_number_components, GRget_components ;
from GRcurve		import GRmidpoint  ;
from EMSsurface		import GRptproject ;

extern GRclassid	OPP_EMSsurface_class_id  ;
extern GRclassid	OPP_EMScompsurf_class_id ;
extern GRclassid	OPP_EMSsubbs_class_id    ;
extern GRclassid	OPP_GRcompcurve_class_id ;
extern GRclassid	OPP_GRcurve_class_id     ;

/*
	---------------------------------------------------------
 */


IGRlong SMTrSurfPassArg(msg, surface, curve, track_point,
   track_parms, cst, options, map_options, imp_options,
   trimmed_surf)
IGRlong			*msg ;			/* O */ 
struct GRlc_info	*surface ;		/* I */ 
struct GRlc_info	*curve ; 		/* I */
IGRdouble		*track_point ;		/* I */
struct GRparms		*track_parms ; 		/* I */
struct GRvg_construct	*cst ; 			/* I */
IGRushort		options ; 		/* I */
IGRushort		map_options ; 		/* I */
IGRushort		imp_options ; 		/* I */
GRobjid			*trimmed_surf  ;	/* O */

/*
   Description :

	This function assumes that the composite curve is the result of
	an intersection between our located composite surface and another
	surface, so that the curve components of the composite curve
	are properly trimmed on each sub-surface of our composite curve.
	(...)
 */

{
IGRlong		SMmsg, stat ;
OMuword		surf_cl, curve_cl ;
GRrange		curve_rg, surf_rg, dummy_rg ;
IGRboolean 	world, rg_flag ;
IGRdouble	dummy_diam, curve_diam ;
IGRint		num_curves, count_curves, num_surf ;
struct GRid	*curves_obj ;
IGRpoint	midpoint, aux_point ;
struct GRparms	dummy_parms, aux_parms ;
IGRint		i_curve ;
BSrc		bsrc ;

GRobjid		*curves_array ; /* Input list for the trimming op */
GRobjid		*surf_array   ; /* Input list for the trimming op */

extern IGRlong EFmap_compcv_compsf() ;

*msg = MSFAIL ;
curves_obj = NULL ; curves_array = NULL ; surf_array = NULL ;

stat = om$get_classid(osnum	= surface->located_obj.osnum,
		objid		= surface->located_obj.objid,
		p_classid	= &surf_cl) ; 
as$status(sts = stat) ; if (! (stat & 1)) goto wrapup ;

if (om$is_ancestry_valid(superclassid 	= OPP_EMSsurface_class_id,
			subclassid	= surf_cl) != OM_S_SUCCESS){
	#ifdef DEBUG
	printf("First located object is not a surface \n") ;
	#endif
	stat = OM_E_ABORT ; goto wrapup ;
	}

stat = om$get_classid(osnum	= curve->located_obj.osnum,
		objid		= curve->located_obj.objid,
		p_classid	= &curve_cl) ;
as$status(sts = stat) ; if (! (stat & 1)) goto wrapup ;

if (om$is_ancestry_valid(superclassid 	= OPP_GRcurve_class_id,
			subclassid	= curve_cl) != OM_S_SUCCESS){
	#ifdef DEBUG
	printf("Second located object is not a curve \n") ;
	#endif
	stat = OM_E_ABORT ; goto wrapup ;
	}

/*
	Test if the range of the curve is within the range of the surface
 */

world = TRUE ;
stat = om$send(msg = message GRgraphics.GRgetrang(&SMmsg,
			&surface->module_info.md_env.matrix_type,
			surface->module_info.md_env.matrix,
			&world,
			surf_rg),
		senderid = NULL_OBJID,
		targetid = surface->located_obj.objid,
	 	targetos = surface->located_obj.osnum) ;
as$status(sts = stat) ; if (! (stat & 1)) goto wrapup ;
if (! (SMmsg & 1)) {
	stat = OM_E_ABORT ; as$status(sts = stat) ; goto wrapup ;
	}
stat = om$send(msg = message GRgraphics.GRgetrang(&SMmsg,
			&curve->module_info.md_env.matrix_type,
			curve->module_info.md_env.matrix,
			&world,
			curve_rg),
		senderid = NULL_OBJID,
		targetid = curve->located_obj.objid,
	 	targetos = curve->located_obj.osnum) ;
as$status(sts = stat) ; if (! (stat & 1)) goto wrapup ;
if (! (SMmsg & 1)) {
	stat = OM_E_ABORT ; as$status(sts = stat) ; goto wrapup ;
	}

/* Intersect range boxes */
BSrgbxint(&surf_rg[0], &surf_rg[3], &curve_rg[0], &curve_rg[3],
	&rg_flag, &dummy_rg[0], &dummy_rg[3], &bsrc) ;
if (bsrc != BSSUCC) { /* useless */
	stat = OM_E_ABORT ; as$status(sts = stat) ; goto wrapup ;
	}

/* Compute square distance of curve_rg and dummy_rg boxes */
curve_diam = BSdistptpts(&bsrc, &curve_rg[0], &curve_rg[3]) ;
if (bsrc != BSSUCC) {
	stat = OM_E_ABORT ; as$status(sts = stat) ; goto wrapup ;
	}
dummy_diam = BSdistptpts(&bsrc, &dummy_rg[0], &dummy_rg[3]) ;
if (bsrc != BSSUCC) {
	stat = OM_E_ABORT ; as$status(sts = stat) ; goto wrapup ;
	}

if ( ! rg_flag || dummy_diam != curve_diam ) {
	#ifdef DEBUG
	printf("Curve is outside the range of the given surface \n") ;
	#endif
	stat = OM_E_ABORT ; as$status(sts = stat) ; goto wrapup ;
	}


/* 
	Get number of curve components
 */

if (om$is_ancestry_valid(superclassid 	= OPP_GRcompcurve_class_id,
			subclassid	= curve_cl) != OM_S_SUCCESS){
	#ifdef DEBUG
	printf("Located curve is not a composite one \n") ;
	#endif

	num_curves = 1 ;
	curves_obj = 
	    _MALLOC(num_curves,struct GRid);
	curves_array = 
	   _MALLOC(num_curves,GRobjid) ;
	surf_array   = 
	    _MALLOC(num_curves,GRobjid) ;
	if (curves_obj == NULL || curves_array == NULL || surf_array == NULL) {
		stat = OM_E_ABORT ; 
		as$status(sts = stat) ;
		goto wrapup ;
		}

	curves_obj[0] = curve->located_obj ;
	}

else {
	stat = om$send(msg = message GRowner.GRget_number_components(
			&SMmsg,
			&num_curves),
		senderid = NULL_OBJID,
		targetid = curve->located_obj.objid,
	 	targetos = curve->located_obj.osnum) ;
	as$status(sts = stat) ; if (! (stat & 1)) goto wrapup ;
	if (! (SMmsg & 1)) {
		stat = OM_E_ABORT ; as$status(sts = stat) ; goto wrapup ;
		}

	curves_obj = 
	   _MALLOC(num_curves,struct GRid);
	curves_array = 
	    _MALLOC(num_curves,GRobjid) ;
	surf_array   = 
	     _MALLOC(num_curves,GRobjid) ;
	if (curves_obj == NULL || curves_array == NULL || surf_array == NULL) {
		stat = OM_E_ABORT ; 
		as$status(sts = stat) ;
		goto wrapup ;
		}


	stat = om$send(msg = message GRowner.GRget_components(
			&SMmsg,
			&curve->module_info,
			curves_obj,
			num_curves,
			&count_curves,
			0,
			OM_K_MAXINT),
		senderid = NULL_OBJID,
		targetid = curve->located_obj.objid,
	 	targetos = curve->located_obj.osnum) ;
	as$status(sts = stat) ; if (! (stat & 1)) goto wrapup ;
	if (! (SMmsg & 1)) {
		stat = OM_E_ABORT ; as$status(sts = stat) ; goto wrapup ;
		}
	if (count_curves != num_curves) {
		#ifdef DEBUG
		printf("Error in getting curve components \n") ;
		#endif
		stat = OM_E_ABORT ; as$status(sts = stat) ; goto wrapup ;
		}
	}

/*
	Get number of number of surface components 
 */

if (om$is_ancestry_valid(superclassid 	= OPP_EMScompsurf_class_id,
			subclassid	= surf_cl) != OM_S_SUCCESS){
	#ifdef DEBUG
	printf("Located surface is not a composite one \n") ;
	#endif

	num_surf = 1 ;
	/* ... */
	}

else {
	stat = om$send(msg = message GRowner.GRget_number_components(
			&SMmsg,
			&num_surf),
		senderid = NULL_OBJID,
		targetid = surface->located_obj.objid,
	 	targetos = surface->located_obj.osnum) ;
	as$status(sts = stat) ; if (! (stat & 1)) goto wrapup ;
	if (! (stat & SMmsg & 1)) {
		stat = OM_E_ABORT ; as$status(sts = stat) ; goto wrapup ;
		}
	/* ... */
	}


/*
	Find relationship between curves and surfaces components :
	for each curve component, project its middle point to the composite
	surface, to get the leaf_id (i.e. id of the surface component on which
	the curve component lays)

	1) Simple surface case
	2) Composite surface (general case)
 */

if (num_surf == 1) {

	printf("Simple case \n") ;

	for (i_curve = 0 ; i_curve < num_curves ; i_curve ++) {
		curves_array[i_curve] = curves_obj[i_curve].objid  ;
		surf_array[i_curve]   =	surface->located_obj.objid ;
		}

	stat = EFmap_compcv_compsf(
			&SMmsg,
			&surface->located_obj,
			&surface->module_info,
			&curve->located_obj,
			&curve->module_info,
			num_curves,
			curves_array,
			surf_array,
			track_point,
			track_parms->leaf_id.objid,
			cst,
			options,
			map_options,
			imp_options,
			trimmed_surf) ; /* Output */
	as$status(sts = stat) ;

	}


else {

	#ifdef DEBUG
	printf("Located surface is a composite one \n") ;
	#endif

	/*
		For each curve component of the located composite curve, 
		find the sub-surface on which it lays.
	 */

	for (i_curve = 0 ; i_curve < num_curves ; i_curve++) {

		/* Get mid point */
		stat = om$send(msg = message GRcurve.GRmidpoint(
				&SMmsg,
                                &cst->env_info->md_env.matrix_type,
                                cst->env_info->md_env.matrix,
				&dummy_parms,
				midpoint),
			senderid = NULL_OBJID,
			targetid = curves_obj[i_curve].objid,
	 		targetos = curves_obj[i_curve].osnum) ;
		as$status(sts = stat) ;
		if (! (stat & SMmsg & 1)) {
			stat = OM_E_ABORT ; as$status(sts = stat) ; 
			goto wrapup ;
			}

		/* Project mid point on composite surface */
      		stat = om$send(msg   = message EMSsurface.GRptproject(
                                &SMmsg,
                                &cst->env_info->md_env.matrix_type,
                                cst->env_info->md_env.matrix,
                                midpoint,	/* I */
                                aux_point,	/* O */
                                &aux_parms),	/* O */
		senderid = NULL_OBJID,
                targetid = surface->located_obj.objid,
                targetos = surface->located_obj.osnum) ; 
		as$status(sts = stat) ;
		if (! (stat & SMmsg & 1)) {
			stat = OM_E_ABORT ; as$status(sts = stat) ; 
			goto wrapup ;
			}

		curves_array[i_curve] = curves_obj[i_curve].objid ;
		surf_array[i_curve]   = aux_parms.leaf_id.objid ;
		} /* for i_curve */

	/*
		Perform the trimming.
	 */

	printf("Just before calling EFmap_compcv_compsf() \n") ;

	stat = EFmap_compcv_compsf(
			&SMmsg,
			&surface->located_obj,
			&surface->module_info,
			&curve->located_obj,
			&curve->module_info,
			num_curves,
			curves_array,
			surf_array,
			track_point,
			track_parms->leaf_id.objid,
			cst,
			options,
			map_options,
			imp_options,
			trimmed_surf) ; /* Output */
	as$status(sts = stat) ;

	/* ... */




	} /* composite surface */


printf("A bientot") ;
stat = OM_S_SUCCESS ; /* so far */


wrapup:
	if (curves_obj   != NULL) _FREE(curves_obj)   ;
	if (curves_array != NULL) _FREE(curves_array) ;
	if (surf_array   != NULL) _FREE(surf_array)   ;
	

	printf("Coucou \n") ;
	return stat ;
} /* SMTrSurfPassArg() */


/*
	---------------------------------------------------------
 */


end implementation Root ;

