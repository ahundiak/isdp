/* $Id: VLmrkFdSbCv.I,v 1.3 2001/02/20 01:04:57 build Exp $  */
/*************************************************************************
 * I/LOFT
 *
 * File:        src/tools / VLevalFunk.I
 *
 * Description: Evaluation functions.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLmrkFdSbCv.I,v $
 *      Revision 1.3  2001/02/20 01:04:57  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.2  2001/01/16 20:56:20  ramarao
 *      *** empty log message ***
 *
# Revision 1.2  2000/04/21  21:44:22  pinnacle
# Replaced: loft/src/mrkLine/VLmrkFdSbCv.I for:  by rchennup for Service Pack
#
# Revision 1.2  2000/03/29  15:29:14  pinnacle
# Replaced VLmrkFdSbCv.I by jpulapar for TR179901229
#
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.2  1998/04/08  11:26:36  pinnacle
# Replaced: src/mrkLine/VLmrkFdSbCv.I for:  by smpathak for loft
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      04/08/98   smpathak     file header creation.
 *      04/08/98   smpathak     modiifed for TR179800819
 *      03/27/00   jpulapar     function VLFindSubCurveByCurve modified for
 *				TR179901229 - new function VLGetPtsOnCrv used
 *      04/21/00   jpulapar     no TR - VLGetPtsOnCrv modified  
 *****************************************************************************/
class implementation VLmrkLine;

//+*****************************************************************************
//
//	Implementation of curve functions for object mark of a Struct 
//	 plate/plate or plate/beam.
//
//===========================================================================***

#include <stdio.h>
#include "vlprototype.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "bserr.h"
#include "msdef.h"
#include "madef.h"
#include "ma.h"
#include "exmacros.h"
#include "grmacros.h"
#include "growner.h"
#include "asmacros.h"
#include "emssfintdef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
/********************************** DEBUG flags	******************************


#ifndef MARKERDEBUG

#define MARKERDEBUG	1 
#define vsDEBUG		1
#define vserrDEBUG	1

#endif

********************************** end DEBUG flags	***********************/

#include "vldbgmacros.h"
#include "vldbgmacros.h"
#include "vlmark.h"

#ifndef M_PI
#define M_PI    3.14159265358979323846
#endif

#define EPS 1e-5
#define MALCONTA 8

//   *********c	External Functions

#include "bscveval.h"
#include "bscvarrev0.h"
#include "bsnorvec.h"
#include "bsdistptpt.h"
#include "bssur_sur.h"
#include "bsmdistcvcv.h"
#include "bsmdstptcv.h" 
 
//	see VDS
get_extsurf_geom(
        struct GRid             *surf_ptr  ,                    /* I */
        struct GRmd_env         *surf_mod_env_ptr ,             /* I */
        IGRdouble               extent ,                        /* I */
        struct IGRbsp_surface   **ext_surf_geom_ptrptr ) ;      /* O */


//++********************c  External Methods



// from	GRgraphics	import GRgetname;

// External variables

extern	GRclassid
			OPP_GR3dlinestr_class_id,
			OPP_GR3dlineseg_class_id;


//+++++++++++++++++++++++++++ FindSubCurveByCurve ++++++++++++++++++++++++++***
//	Given a base curve and a reference curve (usually shorter), find 
//	a subcurve=linestring at least 50 units long, without the same start
//	and as close as possible to the reference curve, ie somewhere within
//	its "range" eg:
//		_________________	(ref curve)
//	-----------------------------	(base curve)
//						should give something like:
//		_________________	(ref)
//			---		(sub)
//						and NOT
//		_________________
//	---
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++*********************

#define NUMPTS 7	// max number of subcurve pts

int	VLFindSubCurveByCurve(
		struct GRid	* RefCurve  ,	//I: ref crv for sub crv
		struct GRid	* BaseCurve ,	//I: base crv to calc sub curve
               struct GRmd_env  * md_env    ,	//I: module of current file
	struct GRvg_construct	* vg_cnst   ,	//I:construction list
		struct GRid	* SubCurve  )	//O: the curve built
{

  struct IGRpolyline	SubCurveGeom;   	// geom struct of the sub curve

  struct IGRbsp_curve	* BaseCvGeom = NULL ,
			*  RefCvGeom = NULL ;

  IGRpoint	CurvePts[NUMPTS+1] ,		// pts of curve at set intervals
		SubCvPts[NUMPTS+1] ,		// pts to build sub curve
		*Start = NULL ,		// start of sub curve
		*Finish= NULL ,		// end of sub curve
		*BaseCvPts = NULL ,	// pts on curve use to build sub crv
		* RefCvPts = NULL ;	// pts on crv used as reference

  IGRint	
		NumPts	= NUMPTS ,	// max number pts in sub curve(linestrg)
		NumSol	= 0 ,		// number of solns for curve - surface
		pt      = 0 ,		// counter for current pt on input curve
		i,
		sts	= OM_E_INVARG ;

  IGRdouble			// pts used to define sub curve from input curve
		CurvePars[10] ,		// param values of pts on main curve
		Dist 	 = 0. ,		// distance curve to surface
		CvPar    = 0.,		// param values of pts on main curve
		DistPtCv = 0. ,		// distance curve to surface
	      *	BaseCvParams =NULL,	// parameters of pts on curve 
	      *	 RefCvParams =NULL,	// params of pts on ref closest to base 
		ParDist  = 1. , // parmetric dist from nearest pt to end of crv
		ParIncr  = 0.11 , // parmetric incr from 1st pt to end of crv
		subCrvLen= 0.0;
  IGRdouble     arclen = 0.0,pars[2];
  IGRlong	msg	= MSFAIL ;
  IGRint        ret_type;
  BSrc		bsrc	= BSFAIL ;

  SetProc( FindSubCurve ) ;	Begin 

  if (	! BaseCurve	||
 	!  RefCurve	||
 	!md_env		||
 	!SubCurve	||
 	!vg_cnst	) goto wrapup ;

  SubCurve->objid = NULL_OBJID ;		// assume a fail

  __DBGpr_obj( "base curve in", *BaseCurve ) ;
  __DBGpr_obj( "Ref  curve in", * RefCurve ) ;

  sts = vs$get_geometry ( msg	  = &msg,
			  grobjId = RefCurve ,
			  grobjEnv= md_env ,
			  geometry= &RefCvGeom ) ;
  __CheckRC( sts, msg , "ref:get_geometry", wrapup ) ;

  sts = om$send (msg = message GRvg.GRgenabsg( &msg ,
							&md_env->_MATRIX_TYPE,
							md_env->_MATRIX, 
                                		(IGRchar**)	&BaseCvGeom ),
			  senderid = NULL_OBJID ,
                          targetid = BaseCurve->objid ,
                          targetos = BaseCurve->osnum );
  __CheckRC( sts, msg, "BaseCurve:GRgenabs", wrapup );

  sts = OM_E_ABORT ;		// return this for maths errors
/*************** commented for TR179901229 *********************************
  // closest pts on each curve
  BSmdistcvcv(		BaseCvGeom	,
			RefCvGeom	,
			&NumSol		,
			&BaseCvParams	,
			&RefCvParams	,
			&BaseCvPts	,
			&RefCvPts	,
			&Dist		,
			&bsrc ) ;
  __CheckBSRC( bsrc, "BSmdistcvsf failed", wrapup ) ;
  if ( !NumSol || ! RefCvParams )	{  sts = OM_E_ABORT ;	goto wrapup; } 

  __DBGpr_int( "number of solutions is ", NumSol ) ;
  __DBGpr_dbl( "BaseCvParams is ", BaseCvParams[0] ) ;
  __DBGpr_dbl( "RefCvParams is ", RefCvParams[0] ) ;
  __DBGpr_dbl( "distance to nearest pt on surf is ", Dist ) ;

	// if curve doesn't cross the surface, get out 

  __DBGpr_dbl( "1st curve param ",  RefCvParams[0] ) ;

	// parametric dist is difference from end of crv to nearest pt
	// see if curve and ref directions are opposed


  if ( RefCvParams[0] > 0.9 ) 
	ParDist = 0.01 - RefCvParams[0] ;
  else		
	ParDist = 0.99 -  RefCvParams[0] ;

	// increment is parmetric distance divided by max no of pts req.
  ParIncr =  ParDist / (NumPts + 1) ;
      // set the param values for list of pts on the input curve
  for (	pt=1, CurvePars[0]= ( RefCvParams[0]+ParIncr) ;
	pt< NumPts  ;
	++pt ){
	CurvePars[pt] = CurvePars[pt-1] + ParIncr ;
  	__DBGpr_dbl( "CurvePars", CurvePars[pt] ) ;
  }

  //BScvarrev0( &bsrc,  RefCvGeom, CurvePars, NumPts, (IGRdouble*)CurvePts ) ;
  //__CheckBSRC( bsrc, "BScvarrev0", wrapup ) ;


		    //find list of pts at param dist ParIncr starting at nearest
  for ( pt=0; pt<NumPts ; ++pt ) {
        BScveval( RefCvGeom, CurvePars[pt], 0, &(CurvePts[pt]), &bsrc );
        __CheckBSRC( bsrc, "BScveval", wrapup ) ;
	__DBGpr_dbl( "Curve par ", CurvePars[pt] ) ;
	__DBGpr_vec( "CurvePt ", CurvePts[pt] ) ;
  }
    // go thru list of pts on ref curve until we have series of pts at least
    // 50 units along on the base curve as close as possible to the ref.

  pt = 1 ;
  Start = CurvePts ;
  Finish= CurvePts ;
  // shortest distance between pt on ref and base
  	BSmdstptcv(	BaseCvGeom,
			*Start ,
			&CvPar ,
			SubCvPts[0],
			&DistPtCv ,
			&bsrc ) ;
	__CheckBSRC( bsrc, "first BSmdstptcv failed", wrapup ) ;
		
  do {			// always have at least 2 pts		

	Finish += pt ;

	__DBGpr_vec( "base Pt ", *Start );
	__DBGpr_vec( "next Pt ", *Finish );
	__DBGpr_dbl( "dist", BSdistptpt( &bsrc, *Start, *Finish ) ) ;
  	BSmdstptcv(	BaseCvGeom,
			*Finish ,
			&CvPar ,
			SubCvPts[pt],
			&DistPtCv ,
			&bsrc ) ;

	++pt ;   	// next pt	

  } while ( (BSdistptpt( &bsrc, *Start, *Finish )< 50.) && (pt < NumPts ) ) ;
***************** commented for TR179901229 **********************************/
  // check the length of the sub curve w.r.t refCurve - TR179901229 begins
/*
  for(i=0;i<3;i++) subCrvLen += (SubCvPts[(pt-1)][i] - SubCvPts[0][i])*(SubCvPts[(pt-1)][i] - SubCvPts[0][i]);  
*/
/**************** added for TR179901229 **************************************/
  pars[0] = 0.0;
  pars[1] = 1.0;
  BSarclength(&bsrc,RefCvGeom,&pars[0],&pars[1],&arclen);
  if ( bsrc != BSSUCC ) goto wrapup;
  __DBGpr_dbl( "Reference curve length", arclen );
  __DBGpr_dbl( "Sub Curve length", subCrvLen );
  ret_type = VLGetPtsOnCrv(BaseCvGeom,arclen,SubCvPts,&pt);
  if(!(ret_type&1)){
	__DBGpr_com( "VLGetPtsOnCrv failed" );
	sts = OM_E_ABORT;
	goto wrapup;
  }
/**************** added for TR179901229 **************************************/

 SubCurve->osnum = md_env->md_id.osnum;
 sts = om$construct(     classid = OPP_GR3dlineseg_class_id,
                                osnum   = SubCurve->osnum,
                                p_objid = &SubCurve->objid );

        __CheckRC( sts, 1, "Mrk: OMConstruct SubCurve", wrapup ) ;


 __DBGpr_vec( "sub curve stPt ",  SubCvPts[0] );
 __DBGpr_vec( "sub curve nextPt ",  SubCvPts[1] );

 SubCurveGeom.num_points	=	pt  ;
 SubCurveGeom.points		= (IGRdouble*)SubCvPts ;
 vg_cnst->geometry		= (char*)&SubCurveGeom;

 sts = om$send(msg = message GRgraphics.GRaltconstruct( vg_cnst),
		senderid = NULL_OBJID ,
		targetid = SubCurve->objid,
		targetos = SubCurve->osnum  );

 __CheckRC( sts,*vg_cnst->msg,"Mrk: SubCurve GRaltconstruct",wrapup);
 __DBGpr_obj( "Mrk: placed subCurve ", *SubCurve );


wrapup :

		_FREE(	BaseCvParams ) ;
		_FREE(	RefCvParams ) ;
		_FREE(	BaseCvPts ) ;
		_FREE(	RefCvPts ) ;
		_FREE(  RefCvGeom ) ;

	End
	return sts ;

}  // find subcurve on a surface
// The idea is to break the curve into 80 parts (of parameter) and get a portion
// which is more than (.2 times length of the main marker) at the center
IGRint VLGetPtsOnCrv(struct IGRbsp_curve *crv,IGRdouble mrkLen,IGRpoint points[],IGRint *numpts)
{
  IGRint i,retFlag = FALSE;
  IGRint k;
  IGRdouble ii,jj;
  IGRpoint CurvePts[81],refpt,startpt,endpt;	
  IGRdouble	CurvePars[81],parVal = 0.0;
  BSrc		bsrc	= BSFAIL ;
  IGRdouble     curveLen = 0.0;
  // make a curve .2 times the length of main mark 
    BScvmidpt(crv,&parVal,refpt,&bsrc);
  __CheckBSRC( bsrc, "BScveval", wrapup ) ; 
  __DBGpr_vec( "RefPt ", refpt ) ;

  ii = parVal - 0.0125;
  jj = parVal + 0.0125;

  do{
        BScveval( crv, ii, 0, &startpt, &bsrc );
        __CheckBSRC( bsrc, "BScveval", wrapup ) ;
        BScveval( crv, jj, 0, &endpt, &bsrc );
        __CheckBSRC( bsrc, "BScveval", wrapup ) ;
        curveLen = BSdistptpt( &bsrc, startpt, endpt );
        __CheckBSRC( bsrc, "BSdistptpt", wrapup ) ;
 	if(curveLen>(0.2*mrkLen)) break;
	ii = ii - 0.0125; jj = jj + 0.0125;
  }while((ii>0.0) && (jj<1.0));
  if(curveLen<(0.2*mrkLen)) goto wrapup;  // ensure that everything went fine

  // fill the output
  *numpts = 2;	
	for(k=0;k<3;k++) points[0][k] = startpt[k];
	for(k=0;k<3;k++) points[1][k] = endpt[k];
#ifdef DEBUG
printf("\n returning points [%f,%f,%f]  and  [%f,%f,%f] \n", startpt[0],startpt[1],startpt[2],endpt[0],endpt[1],endpt[2]);
#endif
  // Done
  retFlag = TRUE;

wrapup:
return retFlag;
}

//++++++++++++++ 
//		method to intersection two surfaces iteratively by 1st extending
//		the second surface then using the BSsur_sur function to find
//		a list of intersection points.  This is mainly used to find a
//		reduced size intersection curve.
//	***************

int	VLInterTwoSurfIter (   struct GRobj_env *	FirstSurf ,  //I
				struct GRobj_env*	SeconSurf ,  //I
               struct GRmd_env  * md_env    ,   //I: module of current file
	struct GRvg_construct	* vg_cnst   ,   //I:construction list
				int *	NumInter  , //I:O
		struct	    GRid * 		InterSects  ) //I:O
{

 struct IGRbsp_surface	* PlateSrfGeom = NULL,	// first surf's geometry
			* StifSrfGeom = NULL;	// second surf's geometry

 struct IGRpolyline	InterCurveGeom;   // geom struct of the InterSect

 IGRdouble	extent = 1. ,
		ChrdhtTol = 0.1 , 
		CalcTol = 0.1 ,
		EndPts[6] ,
	*	LinePts = EndPts ;

 IGRpoint		**pts	= NULL ;

 BSpair		**par1 = NULL , 
		**par2 = NULL ; 


  IGRlong	msg	= MSFAIL ;

 BSrc		bsrc	= BSFAIL ;

 IGRint		sts	= OM_E_INVARG ,
		NumGrps = 0,
	*	NumPts  = NULL ,
		NumLinePts = 0 ,
		i = 0 ;

 SetProc( InterTwoSurf ) ;   Begin

 if ( ! FirstSurf || !SeconSurf || ! md_env || ! vg_cnst ||
	 				!NumInter || !InterSects ) goto wrapup ;

 InterSects->objid = NULL_OBJID ;

		__DBGpr_com( "extend the second surface " );

		sts = get_extsurf_geom( &(SeconSurf->obj_id) , 
				&(SeconSurf->mod_env), 
				extent,
				&StifSrfGeom );
		__CheckRC( sts, 1, "get_extsurf_geom", wrapup ) ;

	vs$get_geometry( msg    = &msg,
				grobjId = &FirstSurf->obj_id,
				grobjEnv= &FirstSurf->mod_env,
				geometry= &PlateSrfGeom );
	__CheckRC( 1, msg, "Mrk: first get_geom", wrapup );

		// find their intersection
	
		BSsur_sur(	&bsrc, PlateSrfGeom, StifSrfGeom, 
				&ChrdhtTol, &CalcTol,
				&NumGrps, &NumPts, &pts, &par1, &par2 );
		__CheckBSRC( bsrc, "BSsur_sur", wrapup ) ;

		if ( !NumPts || !pts ) {
			sts = OM_E_ABORT ;
			goto wrapup ;
		}
		else
			__DBGpr_int( "num groups", NumGrps );

	for ( i = 0 ; i< NumGrps ; ++i ) {
			__DBGpr_int( "no pts", NumPts[i] );
			__DBGpr_vec( "1st point", *(*pts)+i );
	}

			// if one of the two plates is not flat jump to a third
			// along the number of points and try and find the first
			// two points at least 100 units apart

	if ( *NumInter == MALCONTA   && NumPts[0] > 3 ) {
	   
					// one of the two is not flat
	   IGRpoint * Start  = NULL ,
		    * Finish = NULL ;

	   IGRdouble	Dist   = 0. ;

	   int	Third = 0,
		NumCurvePts = 0 ;

		*NumInter = 0 ;

		Third = (int) NumPts[0] / 3 ;
		__DBGpr_int( "Third", Third);
		if ( !Third ) { sts = OM_E_ABORT ;  goto wrapup ; }

		Start	= (*pts)+Third ;
		Finish	= (*pts)+Third ;
		NumCurvePts= 1 ;
		do { 
			++Finish ;
			++ NumCurvePts ;
			Dist = BSdistptpt( &bsrc, *Start, *Finish );
			__CheckBSRC( bsrc, "BSdistptpt", wrapup ) ;

		__DBGpr_vec( "Start point", *Start );
		__DBGpr_vec( "end point", *Finish );
			__DBGpr_dbl( "malc distance", Dist );
		}
		while ( NumCurvePts < (NumPts[0]-Third) && Dist < 100. ) ;

		NumLinePts	= NumCurvePts ;
		LinePts		= (IGRdouble*)Start ;

	}
	else if ( *NumInter == MALCONTA ) {
				// both are flat so just go 100 units along
	   IGRboolean bool = FALSE ;

		for ( i=0 ; i<3 ; ++i ) {
		   EndPts[i] = (**pts)[i] ;
		   EndPts[i+3] = (*((*pts)+1))[i] ;
		}
		__DBGpr_vec( "Flat start point", EndPts );
		__DBGpr_vec( "Flat end point", EndPts+3 );

		for ( i=0 ; i<3 ; ++i ) 
			EndPts[i+3] -= EndPts[i] ;
		
		__DBGpr_vec( "directional vector", EndPts+3 );

		sts  = OM_E_ABORT ;
		bool = BSnorvec( &bsrc, EndPts+3 );
		__CheckBSRC( bsrc, "BSnorvec", wrapup ) ;

		if ( !bool ) {
			sts  = OM_E_ABORT ;
			goto wrapup ;
		}

		for ( i=0 ; i<3 ; ++i ) {
			EndPts[i+3] *= 100. ;
			EndPts[i+3] += EndPts[i]  ;
		}

		LinePts		= EndPts ;
		NumLinePts	= 2 ;


        } // if both surfaces are flat
	else {
		NumLinePts	= NumPts[0] -1 ;
		LinePts		= (IGRdouble*)*pts;
	}

	InterSects->osnum = md_env->md_id.osnum;

		__DBGpr_vec( "Line start point", LinePts );
		__DBGpr_vec( "Line end point", LinePts+3 );

	sts = om$construct(     classid = OPP_GR3dlinestr_class_id,
                                osnum   = InterSects->osnum,
                                p_objid = &InterSects->objid );

        __CheckRC( sts, 1, "Mrk: OMConstruct SubCurve", wrapup ) ;

	InterCurveGeom.num_points	=	NumLinePts ;
	InterCurveGeom.points		=	LinePts;
	vg_cnst->geometry		= (char*)&InterCurveGeom;

	sts = om$send(msg = message GRgraphics.GRaltconstruct( vg_cnst),
			  senderid = NULL_OBJID ,
		targetid = InterSects->objid,
		targetos = InterSects->osnum  );

        __CheckRC( sts,*vg_cnst->msg,"Mrk: InterSect GRaltconstruct",wrapup);
	__DBGpr_obj( "Mrk: placed intersection line", *InterSects );
	*NumInter = 1 ;


wrapup:

	_FREE( PlateSrfGeom ) ;

	_FREESF( &bsrc, StifSrfGeom ) ;

 	_FREE( pts ) ;
 	_FREE( par1 ) ;
 	_FREE( par2 ) ;
	_FREE( NumPts ) ;

	End
	return sts ;

} // InterSect

//****************	end public messages		***********************
//----------------------------------------------------------------------------

end implementation VLmrkLine  ;

