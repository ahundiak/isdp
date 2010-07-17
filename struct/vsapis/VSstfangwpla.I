/* $Id: VSstfangwpla.I,v 1.1.1.1 2001/01/04 21:10:10 cvs Exp $  */

/******************************************************************************
* I/STRUCT
*
* File:        vsapis/VSstfangwpla.I
*
* Description:
*
* Dependencies:
*
* Revision History:
*      $Log: VSstfangwpla.I,v $
*      Revision 1.1.1.1  2001/01/04 21:10:10  cvs
*      Initial import to CVS
*
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/11/25  11:26:12  pinnacle
# Created: vsapis/VSstfangwpla.I by manoj for struct
#
*
* History:
*      25/11/97        AUTHOR          DESCRIPTION
*                      Manoj           "VSangleBetStfAndPlate" calculates
*				       angle between a stiffner and its 
*                                      plate at a specified point.
*                                      Caution : It will have problem 
*                                      with stiffener, which has no 
*                                      vertical component in its profile
*				       (cross-section).
******************************************************************************/
/*
	I/STRUCT
*/

class implementation VSstfBeam;

#include <string.h>
#include <limits.h>
#include <math.h>
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"

#include "ex.h"
#include "exmacros.h"
#include "EMSmsgdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "griodef.h"
#include "go.h"
#include "godef.h"
#include "igr.h"
#include "grio.h"

#include "grmacros.h" 
#include "gr.h"
#include "asmacros.h"
#include "grmacros.h"
#include "dpstruct.h"
#include "growner.h"
#include "igrdp.h"
#include "igrdef.h"

#include "igrtypedef.h"
#include "msmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "vsplatedef.h"
#include "vsplacmacros.h"
#include "vssectiondef.h"
#include "vsmiscmacros.h"
#include "vsmodmacros.h"
#include "vsdbgmacros.h"
#include "vsdef.h"
#include "vsdpb.h"
#include "vsgeommacros.h"
#include "vsglobalmsg.h"
#include "vsintcvsf.h"
/*
 *  include of prototypes
 */
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bscveval.h"
#include "maang2vc.h"
#include "values.h"

extern OMuword	OPP_EMSsubbs_class_id;
extern OMuword	OPP_VSstfBeam_class_id;

from 	GRcurve		import GRendpts;
from	VSxscurve	import VStransUsrNmToCmp ;
from	VScompcurve     import VSgetMapping;
from    VScompcurve     import VStransUsrIxToCmp ;
from    VSxscurve	import VStransCmpToUsrNm ;

/*********************************************************************/
/* Purpose: VSgetVerticalSegment() detects a vertical component among 
 *          the components of a curve.    
 *
 */
long VSgetVerticalSegment( msg,  curve, segName)   
long         		*msg;   /* O : error status */
struct GRobj_env  	*curve; /* I : profile of the cross-section the stf */
GRname    		segName;/* O : name of vertical compnenet of profile*/  
{
	int     i, size,  *usrIndices = NULL ;
	struct GRid cmpId;
	IGRpoint stPnt, endPnt;
	long sts;

	/* Get the usrindices and size */
  	sts = om$send(  msg     = message VScompcurve.VSgetMapping(
                                                msg,
                                                &size,
                                                &usrIndices ),
                        senderid = curve->_objid,
                        targetid = curve->_objid,
                        targetos = curve->_osnum ) ;
        __CheckRC( sts, *msg, "VScompcurve.VSgetMapping", wrapup );
	
	/*
	 * For each component of profile(curve at cross-section 
	 */
        for(i = 0; i < size ; i ++ ) {
		
		/*
		 * Get component Id from usr indices 
		 */
                sts = om$send(  msg = message VScompcurve.VStransUsrIxToCmp (
                                                        msg,
                                                        usrIndices[i],
                                                        NULL,
                                                        &cmpId),
                                senderid = curve->_objid,
                                targetid = curve->_objid,
                                targetos = curve->_osnum ) ;
                __CheckRC( sts, *msg, "VScompcurve.VStransUsrIxToCmp", wrapup );

	       /* 
		* Given the component Id and environment of profile 
		* get the end points of the component. 
	        */ 
                sts = om$send(  msg     = message GRcurve.GRendpts(
                                                msg,
                                                &curve->mod_env.md_env.matrix_type,
						curve->mod_env.md_env.matrix,
                                                stPnt,
                                                endPnt ),
                                senderid = cmpId.objid,
                                targetid = cmpId.objid,
                                targetos = cmpId.osnum );
                __CheckRC(sts, *msg, "GRcurve.GRendpts", wrapup );

		if ( stPnt[0] == endPnt[0] ){
                	sts = om$send(  msg  = message VSxscurve.VStransCmpToUsrNm(
							msg, 
							0, 
							&cmpId, 
							segName  ), 
                        		senderid = curve->_objid,
                        		targetid = curve->_objid,
                        		targetos = curve->_osnum ) ;
			__CheckRC(sts, *msg, "VSxscurve.VStransCmpToUsrNm", wrapup );

			break; /* Because the aim was to identify 
			        * ANY vertical compinent.
				*/
		}
	}
	
	wrapup:
		_FREE( usrIndices );
		return sts;

}/* long VSgetVerticalSegment( )*/   
/*----------------------------------------------------------------------------*/
long VSangleBetStfAndPlate( msg, stf, param, surface, angle )
long 		    *msg ;  /* O : return code				*/
struct GRobj_env    stf ;   /* I : stiffener object			*/
double              *param ;/* I : parameter on the stiffener axis.	*/
			    /* 	   NULL if surface/plane is used	*/
struct GRobj_env    surface;/* I : Used only if param is not input.	*/
			    /*     Intersection between curve  and 	*/
			    /*     surface gives the point at which we	*/
			    /*     have to find angle.			*/ 
double              *angle; /* O : angle bet the stiffener and the plate*/
{			    /*     surface on which stiffener is placed */

	GRname		segName; /* Name of a vertical compnents of 
				  * profile ( at param of stiffner )    */
	IGRpoint 	intPnt,  /* point on the stiffner axis at param */                              startPt, 	/* Start point of xs component 	*/
                        endPt ;  	/* End point of xs component 	*/
        IGRvector 	nmOfSurf; 	/* Surface normal direction	*/
        IGRvector       vecStf;	        /* Direction of stiffner        */	
	VSdspRep	stfRep ;        /* My stiffener representation  */
        int 		nbRoots , 	/* root count of stiffener 	*/
			numParam, 	/* number of parameters... 	*/
			mySide;         /* side of the stiffener object */
        char 		*sideName; 	/* side name of the plate	*/
	double		pm ;		/* param at intersection	*/
        long 		sts ;
	BSrc		rc;		/* return code for bsfunc...	*/
	struct GRid 	parents[2],	/* parents of the stiffener	*/
			xsId,           /* id of the cross-section      */
			xDef,           /* Id of profile def            */
			cmpId,          /*                              */ 
			plate;          /* grid os support plate of the 
					 * stiffener                    */
	struct GRvg_construct   cst;	/* Construction list...		*/
        struct GRsymbology      mySymb ;/* My stiffener symbology	*/

	struct IGRbsp_curve *cvGeom = NULL;

        struct GRobj_env axis,
                         plateSf, 
			 stfAxis,
			 curve;

	double 		*sfParam = NULL;

	*msg = MSFAIL;
	xsId.objid = NULL_OBJID ;

        intPnt[0] = intPnt[1] = intPnt[2] = 0. ;

	/* 
	 * number of root count of stiffener object
	 */

        nbRoots = 0; 	

	sts = om$send( msg = message  NDnode.NDget_objects(
						ND_ROOT,
						parents,
                                                2,
                                                NULL,
						VS_K_ConsumedIx,
						1,
						&nbRoots ) ,
			senderid = stf._objid,
			targetid = stf._objid,
			targetos = stf._osnum ) ;
	__CheckRC( sts, 1, "NDmacro.NDget_objects", wrapup ) ;

	/*
	 * Validate  the parents for the given stiffener.
	 * Need to get the plate from the beam support in case
	 * of twisted stiffeners.
	 */
	plate 		= parents[0];
	axis._grid 	= parents[1];

	/*
	 * Now find which side we are on.
         */
	 sts = om$send(  msg     = message VSstfBeam.VSgetPlateSide(
						msg, 
						&mySide ),
			senderid = stf._objid,			
			targetid = stf._objid,
			targetos = stf._osnum );
	__CheckRC( sts, *msg,"VSstfBeam.VSgetPlateSide", wrapup ) ;

	switch( mySide ) {

		default                  :
		case VS_K_stOnTopOfPlate :
			sideName = VS_K_plTopSfPathABS ; break ;
		case VS_K_stOnBotOfPlate :
			sideName = VS_K_plBotSfPathABS ; break ;
	}

	/*
	 * get the plate surface from the name  of the surface
	 */
	sts = om$send( msg	= message NDmacro.ACreturn_foot(
						msg,
						sideName,
						&plateSf._grid,
						&plateSf._matrix_type,
						plateSf._matrix ),
			senderid= plate.objid,
			targetid= plate.objid,
			targetos= plate.osnum ) ;
	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

     	/*
         * Get the Beam Axis ( graphical object which has the same
         * environment of the VSbeamAxis )
         */
        sts = om$send ( msg =  message VSbeam.VSgetSupportAxis(
                                                        msg,
                                                        &stf.mod_env,
                                                        &stfAxis ),
                                senderid = stf._objid,
                                targetid = stf._objid,
                                targetos = stf._osnum );
	__CheckRC( sts, *msg, "VSbeam.VSgetSupportAxis", wrapup );

	/*
	 * Get the point at which angle has to calulated.
	 */
	if ( *param != -1 ){
		/*
		 * call a function to get x, y, z from param.
		 */
		sts =vs$get_geometry(	msg	= msg,
					grobjId	= &stfAxis._grid,
					grobjEnv= &stfAxis.mod_env,
					geometry= &cvGeom ) ;
		__CheckRC( 1, *msg, "vs$get_geometry", wrapup ) ;
		BScveval( cvGeom, *param, 0, (IGRpoint *)intPnt, msg ) ;

	} else {
		__DBGpr_com("VSintersectCurveAndSurface called");
		__DBGpr_obj("stfAxis._grid ",stfAxis._grid);
		__DBGpr_obj("surface._grid ",surface._grid);
		__DBGpr_obj("plateSf._grid ",surface._grid);
		sts = VSintersectCurveAndSurface( 	msg ,
						&stfAxis._grid ,
						&stfAxis.mod_env ,
						&surface._grid ,
						&surface.mod_env ,
						TRUE ,
						intPnt ,
						&pm ) ;
						 
                if( *msg == EMS_W_NoSolution){
			ex$message(msgname = " No intersection found between curve and plane ");
			}
		__CheckRC( sts, *msg, "VSintersectCurveAndSurface", wrapup ) ;
		*param = pm ;
	}
            
	sfParam = (double *)malloc(2*sizeof(double));

	sts = om$send(  msg     = message GRvg.EMpratpt (
						msg,
						&plateSf._matrix_type,
						plateSf._matrix ,
						intPnt,
						sfParam,
						&numParam ),
			senderid= plateSf._objid,
			targetid= plateSf._objid,
			targetos= plateSf._osnum ) ;
	__CheckRC( sts, *msg, "GRvg.EMpratpt", wrapup ) ;


        sts = vs$get_normal( msg        = msg,
                             sfId       = &plateSf._grid,
                             sfEnv      = &plateSf.mod_env,
                             parm      	= sfParam,
                             normal     = nmOfSurf ) ;
	__CheckRC( sts, *msg, "vs$get_normal", wrapup ) ;

	sts = om$send(  msg     = message ACncpx.ACget_NV_rep( &stfRep ),
                        senderid= stf._objid,
                        targetid= stf._objid,
			targetos= stf._osnum ) ;

	sts = om$send(  msg     = message GRvg.GRgetsymb( msg, &mySymb ),
                        senderid= stf._objid,
			targetid= stf._objid,
			targetos= stf._osnum ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetsymb", wrapup ) ;

        vs$fill_cnst_list(      Env_info        = &stf.mod_env,
				Display         = &mySymb.display_attr,
				Level           = mySymb.level,
				Cnst_list       = cst ) ;

	sts = om$send(  msg = message VSbeam.VSextractProfile(
						msg,
						&stf.mod_env,
						NULL,
						NULL,
						*param,
						&cst,
						AC_3D_REP,
						&xsId ),
			senderid= NULL_OBJID,
			targetid= stf._objid,
			targetos= stf._osnum );
	__CheckRC( sts, *msg, "VSbeam.VSextractProfile", wrapup ) ;

	
	/*
         * Find reference section and copy/map it to site.
         */
        sts = om$send(  msg     = message VSbeam.VSgetProfileDef( msg, &xDef ),
                        senderid= stf._objid  ,
                        targetid= stf._objid,
                        targetos= stf._osnum);

        __CheckRC( sts, *msg, "VSbeam.VSgetProfileDef", wrapup ) ;

 
	sts = VSextractCachedSection( msg, &xDef, AC_3D_REP, &curve );
	__CheckRC( sts, *msg, "VSextractCachedSection", wrapup ) ;


	sts = VSgetVerticalSegment( msg, &curve, segName) ; 
	__CheckRC( sts, *msg, "VSgetVerticalSegment", wrapup ) ;

	sts = om$send( msg = message VSxscurve.VStransUsrNmToCmp(
						msg,
						segName,
						NULL,
                                		&cmpId ),
			senderid= NULL_OBJID,
			targetid= xsId.objid,
			targetos= xsId.osnum );
	__CheckRC( sts, *msg, "VSxscurve.VStransUsrNmToCmp", wrapup ) ;	

	/*
	 * Evaluate the start and end points of the component
	 * and generate a vector from start to end. This vector will
	 * be used for evaluting the angle.
	 */ 
	sts = om$send(  msg     = message GRcurve.GRendpts(
					msg,
                                        &cst.env_info->md_env.matrix_type,
                                        cst.env_info->md_env.matrix,
                                        startPt,
                                        endPt),
                        senderid= NULL_OBJID,
                        targetid= cmpId.objid,
                        targetos= cmpId.osnum );
        __CheckRC( sts, *msg, "GRcurve.GRendpts", wrapup ) ;

        BSmkvec (&rc, vecStf, startPt, endPt ) ;
		

	/*
	 * Normalise the stiffener vector
	 */
	BSnorvec( &rc, vecStf );

	/* 
	 * Find the angle from nmOfSurf to vecStf in anticlockwise 
	 * direction ( Hence always +ve but may range from 0 to just 
	 * lessthan  2*PI ).
	 */
	MAang2vc(&rc, nmOfSurf, vecStf, angle ) ;

	/* 
	 * The angle is limited to PI/2 on either side of the 
	 * normal to the plate in a plane that is a plane defined 
	 * by the cross-section of the beam at the given paratmeter 
	 * value. 
	 */
	if (*angle > 0.5*M_PI && *angle < 1.5*M_PI ){
		*angle = *angle - M_PI;
	} else 
	if ( *angle >= 1.5*M_PI && *angle <= 2*M_PI ){
		*angle = *angle - 2*M_PI;
	}
		*angle = (*angle)*180/M_PI;

 
  wrapup:
	if ( sfParam )free( sfParam );
	_FREE( cvGeom );
	/*
	 * Make sure the cross section xsId is deleted.
	 */
	if( xsId.objid != NULL_OBJID ) {
		sts = om$send( msg = message GRgraphics.GRdelete(
							msg,
							&stf.mod_env ),
			       senderid  = xsId.objid,
			       targetid  = xsId.objid,
			       targetos  = xsId.osnum );
	}
	return sts;

} /* VSangleBetStfAndPlate  */
/*----------------------------------------------------------------------------*/
end implementation VSstfBeam;
