/* $Id: VSixcnstfeet.I,v 1.1.1.1 2001/01/04 21:10:55 cvs Exp $  */

/*************************************************************************
 * I/STRUCT
 *
 * File:	vsprofile / VSixcnstfeet.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSixcnstfeet.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:55  cvs
 *	Initial import to CVS
 *	
# Revision 1.3  1998/06/24  15:49:50  pinnacle
# tr179801135
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/02/16  09:29:20  pinnacle
# Replaced: vsprofile/VSixcnstfeet.I for:  by rchennup for struct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/16/98  Suresh  Project Cross-section ACconstruct_feet.
 * 05/27/98  ah      TR179801097 The intersect was returning errors even though
 *                   it was also returning valid curves,  ignore the errors
 * 06/24/98  ah      TR179801135 Naming mismatch,
 *************************************************************************/

class implementation VSintCrsSctn ;

#if 0
#define vsDEBUG 1
#define vserrDEBIG 1
#endif

#include <stdlib.h>
#include "exmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsicmpcvoff.h"
#include "EMSutlmacros.h"
#include "vspart.h"
#include "vsbeamdef.h"
#include "vssplitdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsbeammacros.h"
#include "vsdbgmacros.h"
#include "EMSmsgdef.h"
/*
 * Includes of function prototypes.
 */
#include "bsdistptpts.h"
#include "EMSsffmacros.h"
#include "vsexpvalue.h"
#include "vsgetchanobj.h"
#include "vsvirtualinf.h"
#include "vsvecmxproto.h"

extern OMuword		OPP_GRcompcurve_class_id ;
extern void		SortAndBuildCrv() ;

from VSpart		import		VSgetSupports ;
from VSfeature		import		VSforwardToSource ;
from GRcurve		import		GRendpts,
					GRrevparm ;
from GRcompcurve	import		EMmakecomp ;

from VSbeam		import		VSextractProfile;
/*----------------------------------------------------------------------------*/
static long VSrev1stCompIfNeedBe( msg, env, cmp0, cmp1 )

long		*msg ;
struct GRmd_env *env ;
struct GRid	*cmp0,
		*cmp1 ; {

	long		sts ;
	IGRpoint	start0,
			end0,
			start1,
			end1 ;
	double		d_start,
			d_end,
			len ;

	sts = om$send(	msg	= message GRcurve.GRendpts(
							msg,
							&env->_MATRIX_TYPE,
							env->_MATRIX,
							start0,
							end0 ),
			senderid= cmp0->objid,
			targetid= cmp0->objid,
			targetos= cmp0->osnum ) ;
	__CheckRC( sts, *msg, "GRcurve.GRendpts", wrapup ) ;

	sts = om$send(	msg	= message GRcurve.GRendpts(
							msg,
							&env->_MATRIX_TYPE,
							env->_MATRIX,
							start1,
							end1 ),
			senderid= cmp1->objid,
			targetid= cmp1->objid,
			targetos= cmp1->osnum ) ;
	__CheckRC( sts, *msg, "GRcurve.GRendpts", wrapup ) ;

	d_start = BSdistptpts( msg, start0, start1 ) ;
	len	= BSdistptpts( msg, start0, end1   ) ;
	if( len < d_start ) d_start = len ;

	d_end	= BSdistptpts( msg, end0  , start1 ) ;
	len	= BSdistptpts( msg, end0  , end1   ) ;
	if( len < d_end ) d_end = len ;

	if( d_start < d_end ) {
		__DBGpr_com( "Reversing parm. of component #0" ) ;
		sts = om$send(	msg	= message GRcurve.GRrevparm( msg, env ),
				senderid= cmp0->objid,
				targetid= cmp0->objid,
				targetos= cmp0->osnum ) ;
		__CheckRC( sts, *msg, "GRcurve.GRrevparm", wrapup ) ;
	}
	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* VSrev1stCompIfNeedBe */
/*----------------------------------------------------------------------------*/
long VSinterCompSurfWithSurf( msg, compSol, surface, cst, compCurve )

long			*msg ;
struct GRobj_env	*compSol,
			*surface ;
struct GRvg_construct	*cst ;
struct GRid		*compCurve ; {

	long			sts;
	int			i,
				cnt,
				count ;
	struct GRid		compSurf,
				*list,
				*intList ;
	struct GRlc_info	*membCvList,
				membSfInfo,
				sfInfo ;
	OM_S_CHANSELECT 	toCmps ;

	intList = list = NULL ; membCvList = NULL ; compCurve->objid = NULL_OBJID ;

	ems$make_chanselect( chan_label    = GRcmpowner_to_components,
			     chan_selector = &toCmps ) ;

	sts = VS_GetChanObjWithMalloc( &compSol->_grid, &toCmps,
					&count, &list ) ;
	compSurf = list[0] ;

	_FREE( list ) ; list = NULL ;

	sts = VS_GetChanObjWithMalloc( &compSurf, &toCmps, &count, &list ) ;

	if( !(	membCvList = _MALLOC( count, struct GRlc_info ) ) )
							vs$mem_fail() ;
	for( i = 0 ; i < count ; i++ ) {
		membCvList[i].located_obj.objid = NULL_OBJID ;
	}
	sfInfo.located_obj	= surface->_grid ;
	sfInfo.module_info	= surface->mod_env ;
	membSfInfo.module_info	= compSol->mod_env ;

	for( i = 0 ; i < count ; i++ ) {
#ifdef vsDEBUG
		ShowObj( list + i ) ;
#endif

		membSfInfo.located_obj	= list[i] ;
		cnt = 0 ;
		sts = EMintersect_two_element(	&membSfInfo,
						&sfInfo,
						TRUE,
						cst,
						&cnt,
						&intList,
						msg ) ;

		__DBGpr_int( "Count of intersections", cnt ) ;

		/* ------------------------------------------------------
		 * TR179801097 Avondales screwy surfaces sometimes return error
		 * codes even though the intersection takes place.  So just ignore the
		 * errors and use the curves.
		 */
		if( (sts & 1 & *msg) || 1 ) {
			if( cnt == 1 ) {
				membCvList[i].located_obj = intList[0] ;
				membCvList[i].module_info = *cst->env_info ;
				_FREE( intList ) ;
				//printf("Did the intersection\n");
				
			} else if( cnt == 0 ) {
				*msg = EMS_E_NoIntersection ;
				sts  = OM_W_ABORT ;
				goto wrapup ;
			} else {
				/*
				 * Too many results.
				 */
				vs$bulk_delete( grids	= intList,
						count	= cnt,
						theEnv	= cst->env_info ) ;
				*msg = EMS_E_NoSolution ;
				sts  = OM_W_ABORT ;
				_FREE( intList ) ;
				goto wrapup ;
			}
		} else {
			*msg = EMS_E_NoIntersection ;
			sts  = OM_W_ABORT ;
			goto wrapup ;
		}
		intList = NULL ;
	}
	
	sts = VSrev1stCompIfNeedBe( msg, cst->env_info,
				    &membCvList[0].located_obj,
				    &membCvList[1].located_obj ) ;
				    
        compCurve->osnum = cst->env_info->_MD_OS ;
	compCurve->objid = NULL_OBJID;
	/*
	 * TR179801135 I dont think we need this anymore
	 * Should have been removed before
        sts = om$construct(     classid = OPP_GRcompcurve_class_id,
                                osnum   = compCurve->osnum,
                                p_objid = &compCurve->objid ) ;
        if( !( sts & 1 ) ) vs$om_error( sts = sts ) ;
	*/

/* EF 12/23/94 : GRcompcurve.EMmakecomp fails if two adjacent curves don't
		 have the same end points. Thus, we use the function
		 SortAndBuildCrv() which do the same job but extend the curve
		 if needed.

	compCurve->osnum = cst->env_info->_MD_OS ;
	sts = om$construct(	classid = OPP_GRcompcurve_class_id,
				osnum	= compCurve->osnum,
				p_objid = &compCurve->objid ) ;
	if( !( sts & 1 ) ) vs$om_error( sts = sts ) ;

	sts = om$send(	msg	= message GRcompcurve.EMmakecomp(
								msg,
								cst->env_info,
								count,
								membCvList,
								&badCv ),
			senderid= compCurve->objid,
			targetid= compCurve->objid,
			targetos= compCurve->osnum ) ;
	__CheckRC( sts, *msg, "GRcompcurve.EMmakecomp", wrapup ) ;
*/
{
	struct GRobj_env	*Crvs = NULL ;
	struct GRid		*ConCrvs = NULL ;
	int			NumConCrvs ;

	if( !( Crvs = _MALLOC( count, struct GRobj_env ) ) ) vs$mem_fail() ;

	for( i=0; i<count; i++ ) {
		Crvs[i].obj_id	= membCvList[i].located_obj ;
		Crvs[i].mod_env = membCvList[i].module_info ;
	}

	SortAndBuildCrv( Crvs, count, 3, cst, &ConCrvs, &NumConCrvs, msg ) ;

	_FREE( Crvs ) ;
	//printf("Num cons curves %d\n",NumConCrvs);
	
	if( *msg == BSFAIL ) {
		__DBGpr_com( "SortAndBuildCrv FAILED" ) ;
		vs$error( msgval = EMS_E_BSerror ) ;
	} else {
		if( NumConCrvs != 1 ) {
			__DBGpr_com( "Too many composite curves !!!" ) ;
			vs$error() ;
		}
	}

	*compCurve = ConCrvs[0] ;

	_FREE( ConCrvs ) ;
}
/* End EF 12/23/94 */

	*msg = MSSUCC ;
	sts  = OM_S_SUCCESS ;

	wrapup :

	_FREE( list ) ;
	if( !( sts & 1 & *msg ) ) {
		if( membCvList ) {
			for( i = 0 ; i < count ; i++ ) {
				vs$bulk_delete(
					grids	= &membCvList[i].located_obj,
					theEnv	= &membCvList[i].module_info ) ;
			}
		}
		vs$bulk_delete( grids	= compCurve,
				theEnv	= cst->env_info ) ;
	}
	_FREE( membCvList ) ;

	return sts ;

} /* VSinterCompSurfWithSurf */
/*----------------------------------------------------------------------------*/
method ACconstruct_feet(long		*msg ;
			int		purpose,
					count ;
			struct GRid	list[] ;
			struct GRmd_env *myEnv ;
			int		*feetCount ;
			struct GRid	*feetList ) {

	long			sts ;	  /* OM return code		    */


#ifdef	NO_MORE_NEEDED
	struct GRobj_env	surface,  /* Graphic surface id and env.    */
				bigPlane, /* Big plane			    */
				*p_sf ;   /* Pnter to sf. to project to     */
	struct GRmd_env 	bmEnv ;   /* Module environment of beam     */
	struct GRid		bmId ;	  /* Id of parent beam		    */
	struct GRsymbology	mySymb ;  /* My symbology		    */
	struct GRvg_construct	cst ;	  /* Construction list		    */
	VSdspRep		bmRep ;   /* Beam's display rep.	    */
	struct GRobj_env	compSol ; /* Composite solid of source beam.*/
	struct GRid		compCurve;/* Composite curve ( intersection */
					  /* between above solid and parent */
					  /* surface.			    */

        VSsuppList              bmSupps ; /* Supports of beam           */
        int                     scnt ;    /* Count of supports (unused) */
	struct GRid             profile;  /* Profile generated by beam  */
        VSdspRep                myRep ;   /* My display representation  */

        IGRpoint                intPnt ;  /* Inters. point axis/surface */
	double			intParam ;/* Param. of intersection pnt.*/  
        struct IGRbsp_curve     *axisGeom;/* Geometry of beam's axis    */
	IGRvector		prjVec ;  /* Vector of projection */
	struct GRid		offsetCv ;
	struct GRid		*p_cv ;
	double			cvOffset;

/*
 * Indices of parents.
 */
#define BEAM	0
#define SURF	1
#define EXPR	2

#define bmSURF  0
#define bmAXIS  1

#endif


	SetProc( VSintCrsSctn_ACconstruct_feet ) ; Begin ;

	__DBGpr_me() ;

	sts = om$send( msg	= message VSprjCrsSctn.ACconstruct_feet(
						msg, purpose, count, list,
						myEnv, feetCount, feetList ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;


#ifdef	NO_MORE_NEEDED
	p_cv = NULL;
        axisGeom = NULL ;

	feetList[0].objid = bigPlane._objid = compCurve.objid = NULL_OBJID ;

	offsetCv.objid = profile.objid = NULL_OBJID ;

	/* Get beam.
	 * If this object is inside a macro, then list[BEAM] is a pretend, since
	 * we are sending VS-specific messages, we have to get the id of the
	 * beam pointed to by that pretend (pretends do not understand VS
	 * messages).
	 */
	VSgetVirtualInfo( msg, list + BEAM, &bmEnv, &bmId ) ;

#ifdef vsDEBUG
	ShowObj( &bmId ) ;
#endif

	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &bmRep ),
			targetid= bmId.objid,
			targetos= bmId.osnum ) ;
	__DBGpr_int( "Beam's rep", bmRep ) ;


	/*
	 * If beam is in 2D, we cannot generate the intersection at small costs
	 * so we use ancestor's class method for this case which will generate
	 * the projection of the profile on the input surface.
	 */



	if( bmRep & AC_2D_REP ) {
		__DBGpr_com( "Using ancestor's ACreturn_foot" ) ;
		return om$send( msg	= message VSprjCrsSctn.ACconstruct_feet(
						msg, purpose, count, list,
						myEnv, feetCount, feetList ),
				mode	= OM_e_wrt_message,
				targetid= my_id ) ;
	} else {
		sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &myRep ),
				targetid= my_id ) ;
		if( myRep != bmRep ) {
			om$send(msg	= message ACncpx.ACput_NV_rep( bmRep ),
				targetid= my_id ) ;
		}
	}

	/*
	 * Get graphics of parent surface.
	 */
	sts = om$send(	msg	= message NDnode.ASreturn_go(
							&surface._grid,
							&surface._matrix_type,
							surface._matrix ),
			targetid= list[SURF].objid,
			targetos= list[SURF].osnum ) ;
	__CheckRC( sts, 1, "NDnode.ASreturn_go", wrapup ) ;
	__DBGpr_obj( "Graphic surface", surface._grid ) ;

	surface._md_os = surface._osnum ;
	ex$get_modid(	mod_osnum	= surface._md_os,
			mod_id		= &surface._md_id ) ;

	/*
	 * Fill construction list.
	 */
	sts = om$send(	msg	= message GRvg.GRgetsymb( msg, &mySymb ),
			mode	= purpose & VS_K_InitialPlacement
					? OM_e_wrt_message
					: OM_e_wrt_object,
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;

	vs$fill_cnst_list(	Env_info	= myEnv,
				Display 	= &mySymb.display_attr,
				Level		= mySymb.level,
				Cnst_list	= cst ) ;


	/*
	 * If input surface is a plane make it big enough so intersection will
	 * work, use range of beam as input to make sure that plane will be
	 * extended so as to encompass axis and apply a scaling factor to
	 * ensure that beam's body will be in it too.
	 */
	if( vs$is_surface_planar(	surfId	= &surface._grid,
					surfEnv = &surface.mod_env,
					msg	= msg ) ) {
		GRrange box ;

		sts = VSbeamBox( msg, &bmId, &bmEnv, box ) ;
		__CheckRC( sts, *msg, "VSbeamBox", wrapup ) ;

		sts = vs$makeBiggerPlane(
					msg		= msg,
					inPlane 	= &surface,
					elementRng	= box,
					scale		= 10.,
					cst		= &cst,
					bigPlane	= &bigPlane._grid ) ;
		__CheckRC( sts, *msg, "vs$makeBiggerPlane", wrapup ) ;

		bigPlane.mod_env = *cst.env_info ;
		p_sf = &bigPlane ;
	} else	p_sf = &surface ;


        if( count == 2 ) {
                /*
                 * No curve offset.
                 */
                 cvOffset = 0 ;
        } else {
                sts = VSexpValue( list[EXPR].objid, list[EXPR].osnum,
                                  &cvOffset ) ;
                __CheckRC( sts, 1, "VSexpValue", wrapup ) ;
        }
        __DBGpr_dbl( "Curve offset", cvOffset ) ;



	if ( ( count == 3) && ( !( vs$is_surface_planar(
						surfId  = &surface._grid,
						surfEnv = &surface.mod_env,
						msg     = msg ) ) ) )
	{
        sts = om$send(  msg     = message VSpart.VSgetSupports(
                                                msg, &bmEnv, &scnt, bmSupps ),
                        targetid= bmId.objid,
                        targetos= bmId.osnum ) ;
        __CheckRC( sts, *msg, "VSpart.VSgetSupports", wrapup ) ;

        /*
         * Intersect surface and axis of beam, if no solution is found, take
         * end of beam which is closest to surface, if several solutions are
         * found, well take the first one.
         */

        vs$get_geometry(        msg     = msg,
                                grobjId = &bmSupps[bmAXIS]._grid,
                                grobjEnv= &bmSupps[bmAXIS].mod_env,
                                geometry= &axisGeom ) ;
        __CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;

       	sts = VSintersectCurveAndSurface( 	msg,
	               	                        &bmSupps[bmAXIS]._grid,
        	               	                &bmSupps[bmAXIS].mod_env,
                                                &p_sf->_grid,
                                                &p_sf->mod_env,
                                                FALSE,
	                                        intPnt,
        	                                &intParam ) ;

	        if( !( sts & 1 & *msg ) ) {
                /*
                 * No intersection.
                 */
			*msg = EMS_E_NoIntersection ;
			sts  = OM_W_ABORT ;
			goto wrapup;
		}
	       if( vs$is_curve_linear( msg = msg, curveGeom = axisGeom ) ) {

        	   BSmkvec(msg, prjVec, axisGeom->poles, axisGeom->poles + 3 ) ;

	        } 
		else {
                	double  eval[6] ;  /* Buffer for BScveval       */

	                BScveval(
        	                axisGeom,            /* IN  : curve geometry */
                	        intParam,            /* IN  : t of evaluation*/
                        	1,                   /* IN  : point+tangent  */
	                        (IGRpoint *) eval,   /* OUT : buffer         */
        	                msg ) ;
                	if( BSERROR( *msg ) ) { *msg = EMS_E_CurveError ; goto wrapup ; }
	                VSvccpy( prjVec, eval + 3 ) ;
	        }

        	BSnorvec( msg, prjVec ) ;
	        __DBGpr_vec( "Projection vector", prjVec ) ;

        sts = om$send(  msg     = message ACncpx.ACget_NV_rep( &myRep ),
                        targetid= my_id ) ;
        __DBGpr_int( "My rep", myRep ) ;


		sts = om$send(  msg     = message VSbeam.VSextractProfile(
                                                        msg,
                                                        &bmEnv,
                                                        &bmSupps[bmSURF],
                                                        &bmSupps[bmAXIS],
                                                        intParam,
                                                        &cst,
                                                        myRep,
                                                        &profile ),
        	                targetid= bmId.objid,
                	        targetos= bmId.osnum ) ;
	        __CheckRC( sts, *msg, "VSbeam.VSextractProfile", wrapup ) ;

		/*
	         * Now offset profile curve .
	         */
	if ( cvOffset !=0 )
	{
     	        sts = vs$offsetCurve(   msg     = msg,
                                        cvEnv   = myEnv,
                                        cvId    = &profile,
                                        offset  = cvOffset,
                                        normal  = NULL,
                                        cst     = &cst,
                                        offCvId = &offsetCv ) ;
                __CheckRC( sts, *msg, "cvOffset", wrapup ) ;

		if ( *msg != EMS_I_Fail ) 
			p_cv = &offsetCv ;
	}
	else {
		p_cv = &profile ;
	}
	
        /*
         * At last project (offset) profile onto input surface.
         */
        sts = vs$projectCompCurveOntoSurface( msg        = msg,
                                              compId     = p_cv,
                                              compEnv    = myEnv,
                                              vector     = prjVec,
                                              surfaceId  = &p_sf->_grid,
                                              surfaceEnv = &p_sf->mod_env,
                                              cst        = &cst,
                                              projection = feetList ) ;

        __CheckRC( sts, *msg, "vs$projectCompCurveOntoSurface", wrapup ) ;

        *feetCount = 1 ;
	
	vs$bulk_delete( grids = &profile,	theEnv = cst.env_info ) ;
	vs$bulk_delete( grids = &offsetCv,	theEnv = cst.env_info ) ;

	}

	else {

	/*
	 * Get solid component of source beam.
	 */
 	sts = om$send(	msg	= message VSfeature.VSforwardToSource(
						msg,
						OM_e_wrt_object,
						message NDmacro.ACreturn_foot(
						msg, VS_K_bmGrCmpName,
						&compSol._grid, NULL, NULL )),
			targetid= bmId.objid,
			targetos= bmId.osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

	compSol.mod_env = bmEnv ;
	/*
	 * Intersect solid components of source beam with parent surface.
	 * NOTE: we do not use `EMintersect_two_element' here since the
	 * composite curve it will give out will not have its components
	 * ordered in the same way as the solid components ( which is a
	 * composite surface ).
	 */

	sts = VSinterCompSurfWithSurf( msg, &compSol, p_sf, 
						&cst, &compCurve ) ;
	__CheckRC( sts, *msg, "VSinterCompSurfWithSurf", wrapup ) ;

	/*
	 * Now offset result if requested.
	 */
	if( count > 2 ) {
		struct IGRplane planeOfCv ;
		IGRvector	offsetVec ;
		IGRpoint	plPoint ;

		planeOfCv.point = plPoint ;
		planeOfCv.normal= offsetVec ;
		sts = om$send(	msg	= message GRvg.GRdetplane(
						msg,
						&cst.env_info->_MATRIX_TYPE,
						cst.env_info->_MATRIX,
						&planeOfCv ),
			targetid= compCurve.objid,
			targetos= compCurve.osnum ) ;
		/*
		 * if curve is not planar, the above will fail: 
		 * do not offset.
		 */
		__DBGpr_vec( "Offset vec", offsetVec ) ;
		__DBGpr_vec( "Pl point", plPoint ) ;
		if( sts & 1 & *msg ) {
			if( cvOffset != 0. ) {
				sts = vs$offsetCurve(	
						msg	= msg,
						cvEnv 	= myEnv,
						cvId  	= &compCurve,
						offset 	= cvOffset,
						normal 	= NULL,
						cst	= &cst,
						offCvId = &offsetCv ) ;
				__CheckRC( sts, *msg, "cvOffset", wrapup ) ;

				if( *msg != EMS_I_Fail ) {
					vs$bulk_delete( 
						grids	= &compCurve,
						theEnv	= myEnv ) ;
					compCurve = offsetCv ;
				} /* Else :
				   *
				   * Did not offset because value of
				   * `cvOffset' was bad.
				   */
				}
			}
			else {
				 __DBGpr_com( "Comp. curve not planar" ) ; 
			} 
			
	} /* End if count > 2 */

	*feetCount = 1 ;
	feetList[0]= compCurve ; 
	
	}

	__DBGpr_obj( "Intersection profile", feetList[0] ) ;

	/*
	 * Update object tag, don't check return code: will be
	 * OM_W_NOTTAGGED if object has no tag connection.
	 */
	om$change_tag_version() ;

	wrapup :
		/*
		 * Get rid of temporary objects.
		 */
		_FREE( axisGeom );

		vs$bulk_delete( objenvs = &bigPlane  ) ;

		if( !( sts & 1 & *msg ) ) {

			vs$bulk_delete( grids = &compCurve,
					theEnv= myEnv ) ;

			if( purpose & VS_K_InitialPlacement ) {
				if( *msg & 1 ) *msg = MSFAIL ;
				sts = OM_W_ABORT ;
			} else {
				if( *msg & 1 ) *msg = EMS_E_NoSolution ;
				sts = OM_S_SUCCESS ;
			}
		}

#endif

		End
		return sts ;

} /* method ACconstruct_feet */
/*----------------------------------------------------------------------------*/

end implementation VSintCrsSctn ;





