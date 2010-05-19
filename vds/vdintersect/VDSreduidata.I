/* $Id: VDSreduidata.I,v 1.1.1.1 2001/01/04 21:08:52 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdintersect / VDSreduidata.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSreduidata.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:52  cvs
 *	Initial import to CVS
 *	
# Revision 1.3  2000/01/25  23:26:48  pinnacle
# Replaced: vdintersect/VDSreduidata.I for:  by impd252 for vds
#
# Revision 1.2  2000/01/24  15:20:18  pinnacle
# Replaced: vdintersect/VDSreduidata.I for:  by impd252 for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
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
 *      01/24/00        HF              Fix for TR 179900956
 *
 * -------------------------------------------------------------------*/


class implementation GRvg ;

/*
 * Jean-Luc Loschutz and Eric Faivre ( 30 Sep 1994 ).
 * This function VDSapplyDataReduction() is called after the EMS function
 * EMintersect_two_element() to reduice the number of poles of the
 * resulting curve(s).
 */

#include <stdio.h>
#include "OMmacros.h"
#include "OMerrordef.h"
#include "bserr.h"
#include "growner.h"
#include "godef.h"
#include "go.h"
#include "gr.h"
#include "igr.h"
#include "EMSmsgdef.h"
#include "msdef.h"

/*
 * Includes of function prototype.
 */
#include "bsdta_rducv.h"
#include "bsarclnparc.h"
#include "bsfreecv.h"

/*----------------------------------------------------------------------------*/
/*			     Debug Macros				      */
/*----------------------------------------------------------------------------*/

//#define DEBUG

#ifdef DEBUG
#	define __CheckRC( OMrc, GRrc, _message_, label ) \
	if( !( (OMrc) & 1 ) ) {\
		printf( "FILE %s, LINE %d, %s: \n",\
			__FILE__, __LINE__, (_message_) ) ;\
		om$report_error( sts = (OMrc) ) ;\
		goto label ;\
	} else if( !( (GRrc) & 1 ) ) {\
		printf( "FILE %s LINE %d: %s failed\n",\
			__FILE__, __LINE__, (_message_) ) ;\
		goto label ;\
	}
#else
#	define	__CheckRC( OMrc, GRrc, _message_, label )\
	if( !( (OMrc) & 1 & (GRrc) ) ) goto label
#endif

#ifdef DEBUG
#	define PR_COM( comment ) printf( "%s\n", (comment) )
#else
#	define PR_COM( comment )
#endif

#ifdef DEBUG
#	define PR_INT( comment, value ) printf( "%s : %d\n", (comment), (value) )
#else
#	define PR_INT( comment, value )
#endif

#ifdef DEBUG
#	define PR_DBL( comment, value ) printf( "%s : %g\n", (comment), (value) )
#else
#	define PR_DBL( comment, value )
#endif

#ifdef DEBUG
#	define PR_OBJ( comment, object ) printf( "%s : [%d,%d]\n", (comment), (object).osnum, (object).objid )
#else
#	define PR_OBJ( comment, object )
#endif

#define _MALLOC( nelem, type )	\
	(type *) malloc( (unsigned) ( (nelem) * sizeof( type ) ) )
#define _REALLOC( ptr, nelem, type ) \
	(type *) realloc( (ptr), (unsigned) ( (nelem) * sizeof( type ) ) )
#define _FREE( pointer ) if( (pointer) ) free( (char *) (pointer) )
#define _CHK_MEMORY( pointer, label ) if( !(pointer) ) { \
					 sts  = OM_E_NODYNMEM ; \
					 *msg = EMS_E_NoDynamicMemory ; \
					 goto label ; \
				      }

/*----------------------------------------------------------------------------*/
/*				Globals 				      */
/*----------------------------------------------------------------------------*/

/*
 * Process the data reduction if this flag is TRUE. Otherwise, do nothing.
 */
%safe
IGRboolean VDS_gK_DoDataReduction = TRUE ;
%endsafe

/*----------------------------------------------------------------------------*/
/*				Externals				      */
/*----------------------------------------------------------------------------*/
extern OMuword OPP_GRgrgrp_class_id ;
extern OMuword OPP_GRcurve_class_id ;
extern OMuword OPP_GRcompcurve_class_id ;
extern OMuword OPP_GRbspline_class_id ;

from GRowner import	GRget_number_components,
			GRget_components ;

/*----------------------------------------------------------------------------*/
static int VDSisAncestryValid( element, superclassid )

struct GRid	*element ;
OMuword 	superclassid ; {

	long		sts ;
	OMuword 	subclassid ;
	int		isSub = FALSE ;

	sts = om$get_classid( objid	 = element->objid,
			      osnum	 = element->osnum,
			      p_classid  = &subclassid ) ;

	if( sts & 1 ) {
		if( om$is_ancestry_valid( superclassid = superclassid,
					  subclassid   = subclassid ) ==
								  OM_S_SUCCESS )
			isSub = TRUE ;
	}

	return isSub ;

} /* VDSisAncestryValid */
/*----------------------------------------------------------------------------*/
static long VDSapplyDataReductionOnBS( msg, cst, bsSol )

long			*msg ;		/* O : Return code.		      */
struct GRvg_construct	*cst ;		/* I : Construction list of bspline.  */
struct GRid		*bsSol ; {	/* I/O : Bspline intesection.	      */

	long			sts,
				bsRC ;
	struct IGRbsp_curve	*bs_geom = NULL,
				*reduice_geom = NULL ;
	int			tanl,
				tanr ;
	IGRvector		tangentl,
				tangentr ;
	IGRboolean		option ;
	IGRdouble		maxerr,
				avgerr,
				par,
				apar ;
	IGRpoint		pt,
				apt ;
	struct GRpost_info	post_info ;
	GRobjid 		newobjid ;

	/*
	 * See if bspline is order < 4.
	 */
	sts = om$send( msg	= message GRvg.GRgenabsg(
					     msg,
					     &cst->env_info->md_env.matrix_type,
					     cst->env_info->md_env.matrix,
					     (IGRchar **) &bs_geom ),
		       senderid = NULL_OBJID,
		       targetid = bsSol->objid,
		       targetos = bsSol->osnum ) ;

	__CheckRC( sts, *msg, "GRvg.GRgenabsg", wrapup ) ;

	if( bs_geom->order < 4 ) {
		PR_COM( "\t\t\tBS is not order 4" ) ;
		*msg = MSSUCC ;
		sts  = OM_S_SUCCESS ;
		goto wrapup ;
	}

	/*
	 * Do data reduction.
	 */
	tanl   = 1 ;
	tanr   = 1 ;
	option = TRUE ;

        // HF: 01/24/00 Fix for TR 179900956
        BSarclnparc( &bsRC, bs_geom );
	if( BSERROR( bsRC ) ) {
		PR_COM( "ERROR : Cannot arc-length parameterize using BSarclnparc" ) ;
		*msg = EMS_E_BSerror ;
		sts  = OM_W_ABORT ;
		goto wrapup ;
	}

	BSdta_rducv( bs_geom,
		     tanl,
		     tanr,
		     tangentl,
		     tangentr,
		     option,
		     &maxerr,
		     &avgerr,
		     &par,
		     pt,
		     &apar,
		     apt,
		     &reduice_geom,
		     &bsRC ) ;

	if( BSERROR( bsRC ) ) {
		PR_COM( "ERROR : Cannot reduice using BSdta_rducv" ) ;
		*msg = EMS_E_BSerror ;
		sts  = OM_W_ABORT ;
		goto wrapup ;
	}

	post_info.construct_flag = FALSE ;

	sts = om$send( msg	= message GRvg.GRpostabsg(
						       msg,
						       cst->env_info,
						       &post_info,
						       (IGRchar *) reduice_geom,
						       &newobjid ),
		       senderid = NULL_OBJID,
		       targetid = bsSol->objid,
		       targetos = bsSol->osnum ) ;

	__CheckRC( sts, *msg, "GRvg.GRpostabsg", wrapup ) ;

	*msg = MSSUCC ;
	sts  = OM_S_SUCCESS ;

	wrapup :
		if( reduice_geom ) BSfreecv( &bsRC, reduice_geom ) ;

		return sts ;

} /* VDSapplyDataReductionOnBS */
/*----------------------------------------------------------------------------*/
long VDSapplyDataReductionOnCv( msg, Obj1, Obj2, cst, cvSol )

IGRlong 		*msg ;		/* O : Return code.		      */
struct GRlc_info	*Obj1,		/* I : First object to intersect.     */
			*Obj2 ; 	/* I : Second object to intersect.    */
struct GRvg_construct	*cst ;		/* I : Construction list of curve.    */
struct GRid		*cvSol ; {	/* I/O : Curve intesection.	      */

	long			sts ;
	int			i,
				nbCv = 0 ;
	struct GRid		*curves = NULL ;
	IGRboolean		alloced = TRUE ;

	/*
	 * If we don't want the data reduction do nothing.
	 */
	if( !VDS_gK_DoDataReduction ) {
		PR_COM( "Don't process DATA REDUCTION" ) ;
		*msg = MSSUCC ;
		sts  = OM_S_SUCCESS ;
		goto wrapup ;
	}

	/*
	 * If we have a composite curve, get its components and apply data
	 * reduction on it. Otherwise, apply data reduction on the given
	 * curve.
	 */
	if( VDSisAncestryValid( cvSol,
				OPP_GRcompcurve_class_id ) ) {
		sts = om$send( msg	=
					message GRowner.GRget_number_components(
									msg,
									&nbCv ),
			       senderid = NULL_OBJID,
			       targetid = cvSol->objid,
			       targetos = cvSol->osnum ) ;

		__CheckRC( sts, *msg, "GRowner.GRget_number_components",
			   wrapup ) ;

		curves = _MALLOC( nbCv, struct GRid ) ;
		_CHK_MEMORY( curves, wrapup ) ;
		alloced = TRUE ;

		sts = om$send( msg	= message GRowner.GRget_components(
								  msg,
								  cst->env_info,
								  curves,
								  nbCv,
								  &nbCv,
								  0,
								  OM_K_MAXINT ),
			       senderid = NULL_OBJID,
			       targetid = cvSol->objid,
			       targetos = cvSol->osnum ) ;

		__CheckRC( sts, *msg, "GRowner.GRget_components", wrapup ) ;
	} else {
		nbCv	= 1 ;
		curves	= cvSol ;
		alloced = FALSE ;
	}

	/*
	 * Apply data reduction only if we have a bspline.
	 */
	PR_INT( "\tNumber of curves", nbCv ) ;

	for( i=0; i<nbCv; i++ ) {
		PR_OBJ( "\tcurve", curves[i] ) ;

		if( VDSisAncestryValid( curves +i,
					OPP_GRbspline_class_id ) ) {
			PR_COM( "\t\t-> do DATA REDUCTION" ) ;

			sts = VDSapplyDataReductionOnBS( msg,
							 cst,
							 curves +i ) ;

			__CheckRC( sts, *msg, "VDSapplyDataReductionOnBS",
				   wrapup ) ;
		} else {
			PR_COM( "\t\t-> do NOTHING" ) ;
		}
	}

	*msg = MSSUCC ;
	sts  = OM_S_SUCCESS ;

	wrapup :
		if( alloced ) _FREE( curves ) ;

		return sts ;

} /* VDSapplyDataReductionOnCv */
/*----------------------------------------------------------------------------*/
long VDSapplyDataReduction( msg, Obj1, Obj2, cst, numInter, ElemSol )

IGRlong 		*msg ;		/* O : Return code.		      */
struct GRlc_info	*Obj1,		/* I : First object to intersect.     */
			*Obj2 ; 	/* I : Second object to intersect.    */
struct GRvg_construct	*cst ;		/* I : Construction list of result.   */
IGRint			numInter ;	/* I : Number of intersections.       */
struct GRid		*ElemSol ; {	/* I/O : Resulted intesections.       */

	long			sts ;
	struct GRid		*elemToReduice = NULL ;
	int			i,
				nbElemToReduice = 0,
				nbComponents ;

	/*
	 * If we don't want the data reduction or the number of intersection
	 * is < 1, do nothing.
	 */
	if( !VDS_gK_DoDataReduction || numInter < 1 ) {
		PR_COM( "Don't process DATA REDUCTION" ) ;
		*msg = MSSUCC ;
		sts  = OM_S_SUCCESS ;
		goto wrapup ;
	}

	PR_COM( "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" ) ;
	PR_COM( "	     Data Reduction		 " ) ;
	PR_COM( "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" ) ;
	PR_OBJ( "Intersected element #0", Obj1->located_obj ) ;
	PR_OBJ( "Intersected element #1", Obj2->located_obj ) ;

	/*
	 * Get all intersection elements to do the data reduction.
	 */
	for( i=0; i<numInter; i++ ) {
		if( VDSisAncestryValid( ElemSol +i,
					OPP_GRgrgrp_class_id ) ) {

			sts = om$send( msg	=
					message GRowner.GRget_number_components(
								msg,
								&nbComponents ),
				       senderid = NULL_OBJID,
				       targetid = ElemSol[i].objid,
				       targetos = ElemSol[i].osnum ) ;

			__CheckRC( sts, *msg, "GRowner.GRget_number_components",
				   wrapup ) ;

			if( !nbComponents ) continue ;

			if( nbElemToReduice ) {
				elemToReduice = _REALLOC( elemToReduice,
						 nbElemToReduice + nbComponents,
							  struct GRid ) ;
				_CHK_MEMORY( elemToReduice, wrapup ) ;
			} else {
				elemToReduice = _MALLOC( nbComponents,
							 struct GRid ) ;
				_CHK_MEMORY( elemToReduice, wrapup ) ;
			}

			sts = om$send( msg	=
					       message GRowner.GRget_components(
						 msg,
						 cst->env_info,
						 elemToReduice +nbElemToReduice,
						 nbComponents,
						 &nbComponents,
						 0,
						 OM_K_MAXINT ),
				       senderid = NULL_OBJID,
				       targetid = ElemSol[i].objid,
				       targetos = ElemSol[i].osnum ) ;

			__CheckRC( sts, *msg, "GRowner.GRget_components",
				   wrapup ) ;

			nbElemToReduice += nbComponents ;

		} else {
			if( nbElemToReduice ) {
				elemToReduice = _REALLOC( elemToReduice,
							  nbElemToReduice + 1,
							  struct GRid ) ;
				_CHK_MEMORY( elemToReduice, wrapup ) ;
			} else {
				elemToReduice = _MALLOC( 1,
							 struct GRid ) ;
				_CHK_MEMORY( elemToReduice, wrapup ) ;
			}

			elemToReduice[nbElemToReduice++] = ElemSol[i] ;
		}
	}

	/*
	 * Apply data reduction only on curve or on composite curve.
	 */
	PR_INT( "Number of elements", nbElemToReduice ) ;

	for( i=0; i<nbElemToReduice; i++ ) {
		PR_OBJ( "element", elemToReduice[i] ) ;

		if( VDSisAncestryValid( elemToReduice +i,
					OPP_GRcurve_class_id ) ) {
			PR_COM( "\t-> do DATA REDUCTION" ) ;

			sts = VDSapplyDataReductionOnCv( msg,
							 Obj1,
							 Obj2,
							 cst,
							 elemToReduice +i ) ;

			__CheckRC( sts, *msg, "VDSapplyDataReductionOnCv",
				   wrapup ) ;
		} else {
			PR_COM( "\t-> do NOTHING" ) ;
		}
	}

	*msg = MSSUCC ;
	sts  = OM_S_SUCCESS ;

	wrapup :
		_FREE( elemToReduice ) ;

		return sts ;

} /* VDSapplyDataReduction */
/*----------------------------------------------------------------------------*/

end implementation GRvg ;

