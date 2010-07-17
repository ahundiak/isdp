class implementation VLmrkLine;

//+*****************************************************************************
//
//	Implementation of object defining the mark of a Struct 
//		  this is a series of functions used by the mark object.
//		   
//===========================================================================***

#include <stdio.h>
#include "vlprototype.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "EMSstruct.h"
#include "bserr.h"
#include "bsparameters.h"
#include "msdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "exmacros.h"
#include "grmacros.h"
#include "dpmacros.h"
#include "growner.h"
#include "vsglobalmsg.h"
#include "vsplatedef.h"
#include "vsbmaxisdef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"

/********************************** DEBUG flags	***********************

#ifndef MARKERDEBUG

#define MARKERDEBUG	1 
#define vsDEBUG		1
#define vserrDEBUG	1

#endif

*********************************** end DEBUG flags	***********************/

#include "vldbgmacros.h"
#include "vldbgmacros.h"
#include "vlmark.h"

#ifndef M_PI
#define M_PI    3.14159265358979323846
#endif

#define EPS 1e-5
#define MALCONTA 8

//   *********c	External Functions

#include "bsmdistcvsf.h"
#include "bsdotp.h"
#include "bsalloccv.h"

extern  double	fabs( double );

//********************c  External Methods

from	GRbcsubbc	import	EMcurve_by_poles;

// from	GRgraphics	import GRgetname;

// External variables



int  VLalignDirns( controlVec, changeVec )
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++********
//	Internal function to check whether or not two vectors are in the same
//	direction with respect to their equivalent normalised axes  in a 
//	unit coordinate system.  If their directions are not both +ve or -ve
//	the second vector is reversed.
//
// *++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++********

IGRvector	controlVec,		// vector determining the default dirn
		changeVec;		//vector to change if not as the above
 // align directions of 2 vectors
{
  IGRboolean	isNeg[2],		// are the vectors neg or positive
		isX	=	FALSE,  // the vector in the x direction
		isY	=	FALSE,  // the vector in the y direction
		isZ	=	FALSE;  // the vector in the z direction

  IGRint	sts	=	OM_E_INVARG,
		ii	=	0;

  BSrc		bsrc	=	BSFAIL;

  IGRdouble	dotx	=	0.,
		doty	=	0.,
		dotz	=	0.,
		*pvec[2],		//pointers equivalent to the 2 vectors
		**ppvec = 	pvec;   //pointer for traversing this array

  IGRvector	xAxis, yAxis, zAxis;	//the axes of a normalised unit cd-sys


  if ( !controlVec || !changeVec ) goto wrapup;

  isNeg[0]	=	isNeg[1]	= FALSE;
  pvec[0] = controlVec;
  pvec[1] = changeVec;

  xAxis[0] = yAxis[1] = zAxis[2] = 1.;
  xAxis[1] = xAxis[2] = yAxis[0] = yAxis[2] = zAxis[0] = zAxis[1] = 0.;

  
    __DBGpr_int( " controlVec", controlVec );
    __DBGpr_int( " changeVec", changeVec);
    __DBGpr_int( " pvec ", pvec );
  for ( ii=0; ii<2; ++ii ) {

    __DBGpr_int( " ppvec ", *ppvec );
    __DBGpr_vec( " ppvec ", (*ppvec) );
    __DBGpr_vec( " xAxis ", xAxis );

    dotx = BSdotp( &bsrc, *ppvec, xAxis );
    __CheckBSRC( bsrc, "BSdotp x failed", wrapup ) ;
    __DBGpr_dbl( "dot with x", dotx );

   if ( dotx == 1. || dotx == -1. )   isX = TRUE;
   else {
    __DBGpr_vec( " yAxis ", yAxis );
     doty = BSdotp( &bsrc, *ppvec, yAxis );
     __CheckBSRC( bsrc, "BSdotp y failed", wrapup ) ;
     __DBGpr_dbl( "dot with y", doty );

     if ( doty == 1. || doty == -1. ) isY = TRUE;
     else {
    __DBGpr_vec( " yAxis ", yAxis );
       dotz = BSdotp( &bsrc, *ppvec, zAxis );
       __DBGpr_dbl( "dot with z", dotz );
       if ( dotz == 1. || dotz == -1. ) isZ = TRUE;
       else {
	  if ( fabs(dotx) > fabs(doty) )	isX = TRUE;
	  else				isY = TRUE;

	  if ( isX ) 
		if ( fabs(dotx) < fabs(dotz) ) {isX = FALSE; isZ = TRUE;}
	  else
		if ( fabs(doty) < fabs(dotz) ) {isY = FALSE; isZ = TRUE;}
			
       }   // else not aligned with z axis
     }  // else not aligned with y axis
   }  // else not aligned with x axis

   ppvec++;

      // if flag set, reset and see if vector is reverse of axis

   if ( isX ){	    isX = FALSE;  if ( dotx < 0. )	isNeg[ii] = TRUE;}
   else if ( isY ){ isY = FALSE;  if ( doty < 0. )	isNeg[ii] = TRUE;}
   else    	 {  isZ = FALSE;  if ( dotz < 0. )	isNeg[ii] = TRUE;}

    __DBGpr_int( "isNeg ", isNeg[ii] );
   
  } // for

  if ( isNeg[0] != isNeg[1] ) {
	
	changeVec[0] = - changeVec[0];
	changeVec[1] = - changeVec[1];
	changeVec[2] = - changeVec[2];
  }

  sts = OM_S_SUCCESS;

wrapup:
  return sts;

}  // align directions

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//+****************************************************************************
//
//	Function given a curve from an element, find which side of a plate
//	it is closest to.
//
//+++++++++++++++++   VLCheckSide	+++++++++++++++++++++++++++++++++++++++


int VLCheckSide( 

	IGRlong   *	CSMsg, 		// return code
 struct GRobj_env *	plateObj, 	// the plate to check
 struct GRobj_env *	curveObj, 	// the curve to test 
	IGRint    *	StiffSide, 	// the side on which it is
	IGRpoint	PtOnSurf )	// pt on surf closest to surface


{

   int 			status	=	OM_E_INVARG,
			ii	=	0 ;		// counter

   char *		sidename[2] ;	   // the names of the plates 2 surfaces

   struct GRobj_env	PlateSideObj[2] ;	// the plates 2 surfaces

   struct IGRbsp_surface * BspSf = NULL;       // pointer to Bspline surface

   struct IGRbsp_curve	 * CurveGeom = NULL;       // pointer to Bspline curve

   IGRint		NumSol[2] ;		// no sols for pt on surf

   IGRdouble 		
		
			Dist[2],		// dist to pts found on surf
			*Params[2] ,		// parameters of pts on curve
			*UVParams[2] ;		// parameters of pts on surface

   IGRpoint		
			*CurvePts[2] ,		// pts on crv closest to surface
			*SurfPts[2] ;		// pts on surface closest to crv

   BSrc			bsrc  = BSFAIL ;	// maths function rc


   SetProc( VLCheckSide ) ;   Begin
	

	Params[0]=	UVParams[0] =
	Params[1]=	UVParams[1] = NULL ;
			
	CurvePts[0] =	SurfPts[0] =
	CurvePts[1] =	SurfPts[1] = NULL ;

   if ( ! CSMsg 	||
	!plateObj 	||
	!curveObj 	||
	! StiffSide 	||
	! PtOnSurf		) goto wrapup ;

   __DBGpr_obj( "input curve", curveObj->obj_id ) ;
   status = vs$get_geometry(	msg = CSMsg ,
				grobjId = &( curveObj->obj_id ) ,
				grobjEnv= &(curveObj->mod_env ) ,
				geometry= &CurveGeom ) ;
   __CheckRC( status, *CSMsg , "get curve geom", wrapup ) ;

   sidename[0]        = VS_K_plBotSfPath ;
   sidename[1]        = VS_K_plTopSfPath ;


   for ( ii = 0; ii < 2 ; ++ii ) {
	status = om$send( msg = message NDmacro.ACreturn_foot(
					 CSMsg,
					 sidename[ii],
					&PlateSideObj[ii].obj_id,
					&PlateSideObj[ii]._matrix_type,
					 PlateSideObj[ii]._matrix ),
		 senderid = NULL_OBJID,
		 targetid = plateObj->_objid,
		 targetos = plateObj->_osnum ) ;

        __CheckRC(status, *CSMsg, "Mark: Plate NDmacro.ACreturn_foot", wrapup) ;
	__DBGpr_obj( "CheckSide plateSide object",  PlateSideObj[ii].obj_id );

		// get each surface and compare the point's proximity

	status=om$send ( msg = message GRvg.GRgenabsg( CSMsg,
                                        &PlateSideObj[ii]._matrix_type,
                                         PlateSideObj[ii]._matrix,
                                        (IGRchar **) &BspSf ),
		 	 senderid = NULL_OBJID,
			 targetid = PlateSideObj[ii]. _objid,
			 targetos = PlateSideObj[ii]. _osnum);

	__CheckRC( status, *CSMsg, "PlRol findD: EMSsubbs.GRgenabsg", wrapup );

		// Use pt normal to surface command to find closest pt to
		// each surface and the distance to this point.

	Dist[ii]	=	10000.1 ;	// initialise to nonzero value

	status		=	OM_E_ABORT ;	// assume failure

	BSmdistcvsf(	CurveGeom ,
			BspSf ,
			&NumSol[ii] ,
			&Params[ii] ,
			&UVParams[ii] ,
			&CurvePts[ii] ,
			&SurfPts[ii] ,
			&Dist[ii] ,
			&bsrc ) ;

	__CheckBSRC( bsrc, "BSmdistcvsf failed", wrapup ) ;
	__DBGpr_dbl( "number of solutions is ", NumSol[ii] ) ;
	__DBGpr_dbl( "distance to nearest pt on surf is ", Dist[ii] ) ;

   }	// end find pt on each surf nearest to pt given

	// if top plate closer than the bottom set side to top
	
   if ( (Dist[1] < Dist[0]) && (Dist[1] < 50.) ){

	*StiffSide = VS_K_baOnTopOfPlate ;
	*CSMsg = OM_S_SUCCESS ;
	status = OM_S_SUCCESS ;
	if ( SurfPts[1]) {
		for ( ii=0 ; ii<3 ; ++ii )
			PtOnSurf [ii] = (*SurfPts[1])[ii] ;
	}
	__DBGpr_com( "nearest to top srf" ) ;
   }
   else	if ( Dist[0] < 50. ) {

	*StiffSide = VS_K_baOnBotOfPlate ;
	*CSMsg = OM_S_SUCCESS ;
	status = OM_S_SUCCESS ;
	if ( SurfPts[0] ) {
		for ( ii=0 ; ii<3 ; ++ii )
			PtOnSurf [ii] = (*SurfPts[0])[ii] ;
	}
	__DBGpr_com( "nearest to base srf" ) ;
   }
   else {
	__DBGpr_dbl( "failed with dist 0", Dist[0] ) ;

	*CSMsg = MSFAIL ;
	status    = OM_E_ABORT ;
   }

  wrapup:		// +++++++++++   CLEANUP AND GET OUT +++++++++++++

	_FREE( Params[0] ) ;	_FREE( UVParams[0] ) ;
	_FREE( Params[1] ) ;	_FREE( UVParams[1] ) ;
			
	_FREE( CurvePts[0] ) ;	_FREE( SurfPts[0] ) ;
	_FREE( CurvePts[1] ) ;	_FREE( SurfPts[1] ) ;

	_FREE( CurveGeom ) ;

	End

  return status ;


}	// end VLCheckSide


//	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//		Give an object and an array, return the object's short name
//		ie the first one found without the full dir name .
//	+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

int VLGetShortName ( 	
	struct GRobj_env *	TheObject ,
	struct GRmd_env  *	MdEnv ,
	IGRchar		 *	ItsName
		)
{

   IGRchar  PathMax[DI_PATH_MAX] ;

   DIint	distatus = MSFAIL;

   int sts	= OM_E_INVARG ;

   long	ret	= MSFAIL ;

   GRclassid	ObjClass ;

	SetProc( GetShortName ) ;	Begin

   if ( ! TheObject || !ItsName || !MdEnv )	goto wrapup ;

   ItsName[0] = 0 ;
   PathMax[0] = 0 ;

   __DBGpr_obj( "Asked to find name of", TheObject->obj_id ) ;

    sts = VLGetObjAndClass(&ret,
			    TheObject ,
			    MdEnv  ,
			   &ObjClass ) ;
    __CheckRC( sts, ret, "Get obj and class", wrapup ) ;
    __DBGpr_obj( "Got object id ",  TheObject->obj_id );

   sts = om$send( msg = message GRgraphics.GRgetname(  &ret,
                                                       PathMax   ),
              senderid = NULL_OBJID,
              targetid = TheObject->_objid,
              targetos = TheObject->_osnum ) ;
   __CheckRC( sts, ret, "GRgetname", wrapup );

   __DBGpr_str( "full stiff name ", PathMax   ) ;

     if ( PathMax[0] ) {
	distatus = di$split (	pathname = PathMax ,
				name 	 = ItsName );
	__CheckRC( distatus, 1, "displit", wrapup );

	__DBGpr_str( "object's name ", ItsName ) ;
     }
     else 
	ItsName [0] = 0;


wrapup :
	End
	return sts ;

}				// end fn to get object's short name

IGRboolean	VLLineStrToCurve (
	struct GRid *		inLineString	,
	struct IGRbsp_curve   *	inLSbyGeom	,
	struct GRvg_construct *	VgCnst		,
	struct IGRbsp_curve **	OutCurveGeom	) 

{

	BSrc		retbs = BSFAIL;
	IGRint		ii,			// incremental integer
			ret0  = OM_E_INVARG,
			num_cusps = 0,

		*	cusps	  = NULL;	// list of cusp indexes

	IGRuchar	buffer; // for EMSdpb functions
	IGRboolean	polesAligned = FALSE,
			u_periodic,
			BoolRC		= FALSE ;

	IGRlong 	u_order = 0, // was short
			n_poles = 0,
			l_ret	= MSFAIL;

	IGRdouble	tol	= 1.0;	// current chord height tolerance

	IGRpoint      *	poles	=	NULL;	// list of poles for curve
struct GRlc_info	lineString,		// linestring to create curve
		      *	LSptr	=	NULL;	// linestring ptr to above

struct	IGRbsp_curve  *	TmpCurveGeom	= NULL;	// geom of curve to find cusps
		     
 struct GRid 		CurveObj;		//used approximate linestring

	SetProc( LineStrToCurve );	Begin

	CurveObj.objid	=	NULL_OBJID;

	if ( !inLineString && !inLSbyGeom ) goto wrapup;

	ret0= EMdpb_get(
			&l_ret,
			EMSdpb_props,
			&buffer);
	__CheckRC(ret0, l_ret, "EMSdpb_props:u_period",wrapup);

	if ((buffer & EMDPB_U_PERIODIC) && (u_order > 2))
			u_periodic = TRUE;
	else
			u_periodic = FALSE;

	CurveObj.osnum = VgCnst->env_info->md_id.osnum;
	CurveObj.objid = NULL_OBJID;

        ret0= om$construct(
                                classname       = "GRbcsubbc",
                                osnum           = CurveObj.osnum,
                                p_objid         = &CurveObj.objid ) ;

        __DBGpr_obj( "ConGeom constructed CurveObj ", CurveObj );
        __CheckRC(ret0, 1, "OMconstruct CurveObj", wrapup ) ;

	if ( inLSbyGeom ) {
		if (inLSbyGeom->rational) {
			__DBGpr_com( "Rational lineString?" );
			ret0 =	BSunwght_p(
					&retbs,
					inLSbyGeom->poles,
					inLSbyGeom->weights,
					&inLSbyGeom->num_poles,
					inLSbyGeom->poles);
				__CheckBSRC( retbs, "BSunwght_p", wrapup );
		} // if (inLSbyGeom->rational)
		n_poles = inLSbyGeom->num_poles;
		poles   = (IGRpoint *) inLSbyGeom->poles;
	}

	else {		// by object
		lineString.located_obj	= *inLineString;
		lineString.module_info	= *VgCnst->env_info ,
		LSptr			= &lineString;
	}

	VgCnst->geometry	= NULL;
	*(VgCnst->msg)		= OM_S_SUCCESS ;
	u_order			= 3 ;
	ret0 = om$send(msg = message GRbcsubbc.EMcurve_by_poles(
								u_order,
								u_periodic,
								n_poles,
								poles,
								LSptr,
								VgCnst ),
			senderid = NULL_OBJID,
                       targetid = CurveObj.objid,
                       targetos = CurveObj.osnum);
	__CheckRC( ret0, *(VgCnst->msg) , "EMcurve_by_poles:", wrapup );

	__DBGpr_obj( "input CurveObje", CurveObj ) ;
	ret0 = vs$get_geometry(	msg = VgCnst->msg ,
				grobjId = &( CurveObj ) ,
				grobjEnv= (VgCnst->env_info ) ,
				geometry= &TmpCurveGeom) ;
	__CheckRC( ret0, *(VgCnst->msg), "get CurveObje geom", wrapup ) ;

     	BSxtractpar(&retbs, BSTOLCHRDHT, &tol );
	__CheckBSRC( retbs, "BSxtractpar", wrapup );
	tol *= tol;
  	__DBGpr_dbl("tolerance ",tol );

	POcvFndCusps(TmpCurveGeom, tol, 
			&num_cusps, &cusps, &polesAligned, &retbs );

	__DBGpr_int( "cusps gave ", num_cusps  );
	__DBGpr_int( "polesAligned", polesAligned );
	__DBGpr_int( "retBS", retbs );
	__DBGpr_int( "cusps", cusps );

	if ( retbs != BSSUCC || polesAligned || !cusps ) {

		__DBGpr_int( "FndCusps failed", inLSbyGeom );
		goto wrapup ;

	}
	else { 		// found the cusps

		__DBGpr_int( "found cusps", inLSbyGeom );

		BSalloccv( TmpCurveGeom->order, TmpCurveGeom->num_poles, //IN
			   TmpCurveGeom->rational,
			   TmpCurveGeom->num_boundaries,
			   	OutCurveGeom, &retbs );		 //OUT

		__CheckBSRC( retbs, "BSalloccv" , wrapup );

		__DBGpr_int( "after BSalloc", retbs );

		for ( ii=0; ii<=num_cusps ; ++ii ) {

		    POcvFrmPoles( TmpCurveGeom, (IGRshort) 1, (cusps[ii]),
					(cusps[ii+1]), *OutCurveGeom, &retbs );
			__CheckBSRC( retbs, "POcvFrmPoles" , wrapup );

			__DBGpr_int( "after POcvFrmPoles", retbs );

		}	// for cusps

	} // else found cusps

	ret0 = OM_S_SUCCESS;

wrapup:

		//RETURNED if ( *OutCurveGeom ) BSfreecv(&retbs, *OutCurveGeom);
	_FREE( TmpCurveGeom ) ;
	_FREE( cusps );

#ifndef vsDEBUG
	if ( CurveObj.objid != NULL_OBJID ) {
	   retbs = om$send(msg = message GRgraphics.GRdelete(	&l_ret,
							(VgCnst->env_info ) ),
			senderid = NULL_OBJID,
			targetid = CurveObj.objid,
			targetos = CurveObj.osnum );
	    CheckRC( 1, l_ret );
	}
#endif

	End
	return ( BoolRC );

}

end implementation VLmrkLine;

//----------------------------------------------------------------------------

