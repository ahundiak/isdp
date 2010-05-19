/* $Id: VD_OffCrv.I,v 1.1.1.1 2001/01/04 21:08:54 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdloft/func/VD_OffCrv.I
 *
 * Description:
 *		Functions for calculating offset points and curves with
 *		respect to a curve lying across a surface.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VD_OffCrv.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:54  cvs
 *	Initial import to CVS
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
# Revision 1.2  1996/03/24  20:22:32  pinnacle
# Replaced: vdloft/func/VD_OffCrv.I for:  by v240_int for vds.240
#
# Revision 1.1  1996/03/24  19:37:06  pinnacle
# Created: ./vdloft/func/VD_OffCrv.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 ***************************************************************************/

class implementation EMSsubbs;

#include <stdio.h>
#include <string.h>

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "bserr.h"
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "grmacros.h"
#include "dpmacros.h"
#include "growner.h"
#include "asmacros.h"
#include "graph.h"
#include "nddef.h"
#include "ndmacros.h"
#include "EMSstruct.h"
#include "EMSssprops.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "VDmem.h"
#include "v_dbgmacros.h"


#include "bscveval.h"
#include "bsnorvec.h"
#include "bscrossp.h"
#include "bsprncp_nor.h"
#include "bsmkvec.h"
#include "maarcptan.h"
#include "bsdistptpt.h"
#include "bsdotp.h"
#include "bssfeval.h"
#include "bssfevaln.h"

#include "bspjmptssf.h"
#include "bspl_cv_int.h"
#include "bspl_nor_tc.h"
#include "bseqdptscv.h"
#include "ma2pttobc.h"
#include "bsalloccv.h"
#include "bsdirfitcv.h"
#include "bsfreecv.h"
#include "bsiarcln.h"
#include "bslsqfitcv.h"

extern int	GRdisplay_object(),
		VDdw_SurfCrvsPt() ,
		VDdw_CurveAbsGrev() ;
	
extern  double	fabs( double );

/******************************************************************************/

extern	void	VDdw_CrvLimPts(		BSrc * ,		
					const struct IGRbsp_curve *,
					IGRpoint[2],
					struct IGRbsp_curve** ) ;

from  GRlinear  import	GRgetpolyline;
from  GRcurve	import	GRendpts;


extern	GRclassid	OPP_EMSsurface_class_id,	// surface
			OPP_EMSplane_class_id,		// plane
			OPP_GRbcsubbc_class_id,		// bspline curve class
			OPP_GR3dpoint_class_id ;

////////////////////////////////////////////////////////////////////////////////
//  Function to calculate a variable offset curve from another curve lying 
//  along a given surface.  A normal and tangent to the initial point of offset
//  curve are given, these are used to produce two end arcs for a skinning surf
//  whose intersection is the offset curve.  The radius of the two arcs forms 
//  offset gaps at the start and end of the new curve.
///////////////////////////////////////////////////////////////////////////////

IGRint VDdw_CrvOffSrf (
  IGRlong			* RetSts   ,	//O: status code
  const struct GRlc_info	* const BaseCurve,	//I:trace curve 
  const  struct GRlc_info	* const BaseSurf,	//I:surf for new crv
  const IGRdouble		* const Params ,	//I:old to new crv dists
							//and method properties
  const struct GRlc_info	* const Limits  ,	//I:2 limiting objects
  struct GRvg_construct		* const VgCnst  ,      //I: construction list
  struct GRid			* GeodesCurve  ) //O: new curve at offsets
{
  IGRint		RetC	=   OM_E_INVARG,//return code for this function
			i=0,jj = 0 ,
			NumNormals = 0 ;
  IGRlong		Size = 0 ;
  struct GRlc_info 	LimitCurve;	//I:trace curve 
  struct GRid 			// Input curve limited by Limits objs
 			TubeOffCrv ;	// offset curve from tube intersection
					// curves 
 BSrc			bsrc	= BSFAIL;	// BS's return code
 IGRpoint		PointOnSf ,		// point defining arc radius
			*AbsPts = NULL ;
 IGRdouble		*AbsGrev = NULL ,	// params at Greville abscissae
			*UVParams= NULL ;	// surf params at the above
 struct GRmd_env 	*MdEnv	= VgCnst->env_info ;	//temp ptr to active env
 struct	IGRbsp_curve	*BaseCrvBSP = NULL,	// in curve geometry
			*OffsCrvBSP = NULL ,    // intersn offset curve geometry
			*GeodesCrvBSP= NULL ,	// resulting curve
			*LimitCrvBSP = NULL ;   // the input crv with limits
 struct	IGRbsp_surface  *BaseSrfBSP = NULL ;	// in surf geometry
 IGRvector		YDir ;		//normal to surface, ie YDir of arc
 IGRdouble		ZDirs[6] ;		//normal to arc	(tang)

  SetProc ( VDdw_CrvOffSrf ); Begin

  __CheckPtr( RetSts, " Problem with arguments Sts", wrapup  );
  __CheckPtr( BaseCurve, " Problem with arguments BaCu", wrapup );
  __CheckPtr( BaseSurf, " Problem with arguments BaSf", wrapup  );
  __CheckPtr( Params," Problem with arguments Params", wrapup);
  __CheckPtr( VgCnst, " Problem with arguments Vg", wrapup );
  __CheckPtr( GeodesCurve, " Problem with arguments geo crv", wrapup);


   GRabsg_del_by_objid( &(BaseCurve->located_obj.objid),
		     &(BaseCurve->located_obj.osnum) );

  RetC = om$send( msg = message GRvg.GRgetsize( 	
				RetSts ,
			(IGRshort*)&(BaseCurve->module_info.md_env.matrix_type),
			     	BaseCurve->module_info.md_env.matrix,
			     	&Size ),
		     senderid = NULL_OBJID ,
	  	     targetid = BaseCurve->located_obj.objid,
	  	     targetos = BaseCurve->located_obj.osnum );
  __CheckRC( RetC, *RetSts , "Get Size on Curve", wrapup ) ;

  BaseCrvBSP = (struct IGRbsp_curve *) om$malloc(size = Size);
  __CheckPtr(  BaseCrvBSP , "om malloc for curve struct", wrapup ) ;

  RetC = om$send( msg = message GRvg.GRgetgeom( 	
				RetSts ,
			(IGRshort*)&(BaseCurve->module_info.md_env.matrix_type),
			     	BaseCurve->module_info.md_env.matrix,
			     	(char *)BaseCrvBSP ),
		     senderid = NULL_OBJID ,
	  	     targetid = BaseCurve->located_obj.objid,
	  	     targetos = BaseCurve->located_obj.osnum );

  __CheckRC( RetC, *RetSts , "Get geom of Curve", wrapup ) ;

  // limit curve at geodesic distance by the 2 input objects
  RetC = VDdw_CrvLimitObjs(	RetSts ,
				BaseCrvBSP ,	//  GeodesCrvBSP ,
				Limits,
				&LimitCrvBSP ); 	// FinalCrvBSP  ) ;

  __CheckRC( RetC, *RetSts , "VDdw_CrvLimitsObjs", wrapup ) ;
  __CheckPtr( LimitCrvBSP, "VDdw_CrvLimitObjs ret ptr", wrapup ) ;

 *RetSts = MSFAIL ;
 RetC = OM_E_ABORT ;

  //c define ZDirs at the origin of plane containing arc 
  // for both start and end of the curve ie the tangents make the Z

  {
    IGRdouble Param = 0. ,		//curve at the start
		CvEval[6] ;		//pt + 1st derivative(tangent )


   	BScveval( LimitCrvBSP, Param, (IGRint)1, 
			(IGRpoint*)CvEval, &bsrc);
	__CheckBSRC( bsrc, "BScveval Failed at start point", wrapup );

	for(i=0;i<3;i=i+1) { ZDirs[i] = 1.0 * CvEval[i+3];
	}
	__DBGpr_vec( "ZDirs[0]", ZDirs) ;


	Param = 1.;
   	BScveval ( LimitCrvBSP, Param, (IGRint)1, (IGRpoint*)CvEval, &bsrc);
	__CheckBSRC( bsrc, "BScveval Failed at end point", wrapup );

	__DBGpr_vec( "CvEval end ", &CvEval[3] ) ;
	for(i=3;i<6;i=i+1) { ZDirs[i] = 1.0 * CvEval[i];
	}
	__DBGpr_vec( "ZDirs[1]", &ZDirs[3] ) ;


  }	// end Z dirs section


  // so far so good, now get geometry of curve and allocate space for
  // greville abscissae etc

  RetC = vd_$get_geometry(	msg = RetSts ,
                   		grobjId = &(BaseSurf->located_obj) ,
				grobjEnv= &(BaseSurf->module_info) ,
				geometry= &BaseSrfBSP ) ;
  __CheckRC(RetC,*RetSts,"VDdw_OffCrvSrf: surf geom", wrapup);
  __CheckPtr( BaseSrfBSP, "BaseSrfBSP ptr", wrapup ) ;

  AbsPts = _MALLOC( LimitCrvBSP->num_poles , IGRpoint ) ;
  __CheckPtr( AbsPts, "AbsPts ptr", wrapup ) ;

  AbsGrev= _MALLOC( LimitCrvBSP->num_poles , IGRdouble) ;
  __CheckPtr( AbsGrev,"AbsGrevptr", wrapup ) ;

  // calculate the points at the Greville abscissae
  RetC = VDdw_CrvAbsPts( RetSts, LimitCrvBSP, &AbsPts ) ;
  __CheckRC(RetC,*RetSts,"VDdw_CrvAbsPts: ", wrapup);

  // calculate the Greville abscissae
  RetC = VDdw_CurveAbsGrev( RetSts, LimitCrvBSP, AbsGrev ) ;
  __CheckRC(RetC,*RetSts,"VDdw_CrvAbsGrev ", wrapup);

 *RetSts = MSFAIL ;
 RetC = OM_E_ABORT ;

	//project these points on the surface and find normal at the given param
 {
    IGRboolean AllOnSrf = FALSE ;

    UVParams = _MALLOC( LimitCrvBSP->num_poles *2 , IGRdouble ) ;
    __CheckPtr( UVParams,"UVParams", wrapup ) ;

    BSprptsonsf( LimitCrvBSP->num_poles ,
		AbsPts ,
		BaseSrfBSP ,
		 UVParams ,
		&AllOnSrf ,
		&bsrc ) ;
    __DBGpr_int( "All pts on surf", AllOnSrf ) ;
    __CheckBSRC( bsrc, "BSprptsonsf Failed ", wrapup );

		// normal at start gives Y dir of arc 
    BSsfevaln( BaseSrfBSP ,
		UVParams[0] ,
		UVParams[1] ,
		1,
		&NumNormals ,
		PointOnSf, 
		(IGRvector*)YDir ,
		&bsrc ) ;
    __CheckBSRC( bsrc, "BSsfevaln Failed ", wrapup );
    __DBGpr_int( "numb nors", NumNormals ) ;

   }		// end section to calculate the surf normals at the abscissae

	VgCnst->geometry   = (char *)LimitCrvBSP;

	LimitCurve.located_obj.objid = NULL_OBJID;
	LimitCurve.located_obj.osnum = MdEnv->md_id.osnum;
	LimitCurve.module_info	     = *MdEnv ;

	RetC = om$construct(     classid = OPP_GRbcsubbc_class_id ,
				osnum   =  LimitCurve.located_obj.osnum ,
				p_objid = & (LimitCurve.located_obj.objid) , 
				msg  = message GRgraphics.GRconstruct( VgCnst));

	__CheckRC(RetC,*(VgCnst->msg),"Place limit curve GRconstruct", wrapup );
	__DBGpr_obj( "Sland: limit curve",  LimitCurve.located_obj );

		// now calculate the general offset curve (given via intersectn)

   RetC = VDdw_linesSrf( RetSts, &LimitCurve , BaseSurf , &Params[2],  ZDirs, 
			VgCnst,  &TubeOffCrv ) ;

   __CheckRC( RetC , *RetSts , "VDdw_linesSrf", wrapup ) ;

  if ( Params[0] < 1. )  {
	*GeodesCurve = TubeOffCrv  ;
	TubeOffCrv.objid = NULL_OBJID ;		// avoid delete
	__DBGpr_obj("Sland:placed final curve method=0", *GeodesCurve );
	goto wrapup ;		// GOTO WRAPUP don't need the rest
  }

  RetC = vd_$get_geometry(	msg	= RetSts ,
				grobjId = &(TubeOffCrv) ,
				grobjEnv= MdEnv ,
				geometry= &OffsCrvBSP ) ;
  __CheckRC(RetC,*RetSts,"VDdw_OffCrvSrf: surf geom", wrapup);
  __CheckPtr( OffsCrvBSP,"OffsCrvBSP", wrapup ) ;

	// for each abscissa of the input curve find the curve lying on the 
	// surface between the input curve and its offset then find a point
	// at a specific length along the intermediate curve.

  for (jj=0 ; jj<LimitCrvBSP->num_poles; jj++ ) {

    __DBGpr_dbl("grev abs ",AbsGrev[jj]);
    BSsfevaln( BaseSrfBSP ,
		UVParams[(jj*2)] ,
		UVParams[(jj*2)+1] ,
		1,
		&NumNormals ,
		PointOnSf , 
		(IGRvector*)YDir ,
		&bsrc ) ;
    __CheckBSRC( bsrc, "BSsfevaln Failed ", wrapup );
    __DBGpr_int( "numb nors", NumNormals ) ;
    __DBGpr_vec( "normal YDir ", YDir ) ;

		// get the geodesic point
	RetC = VDdw_SurfCrvsPt( RetSts ,
				BaseSrfBSP ,
				LimitCrvBSP ,
				OffsCrvBSP ,
				&AbsGrev[jj],
				(IGRvector*)YDir ,
				Params ,
				AbsPts[jj] ) ;
	__CheckRC( RetC , *RetSts , "VDdw_SurfCrvsPt", wrapup ) ;
	__DBGpr_vec("abs pt",AbsPts[jj]);

  }	// for each abscissa curve get point at distance

 // for(jj=0 ; jj<LimitCrvBSP->num_poles;jj++) __DBGpr_vec( "abs pt",AbsPts[jj]);
 {
   IGRboolean Periodic = FALSE ,                // is curve periodic
                EndL   = FALSE ,                // are end tangents given?
                EndR   = FALSE ;
   IGRvector    TanL ,			// dummy tangents
                TanR ;
	// num of poles in Curve according to bsdirfitcv
   IGRint       NumPoles= LimitCrvBSP->num_poles +4 -1 ; 

   BSalloccv(   (IGRshort)4     ,
                (IGRlong) ( NumPoles  )  ,
                (IGRshort) 0    ,
                (IGRshort) 0    ,
                &GeodesCrvBSP  ,
                &bsrc   );
   __CheckPtr( GeodesCrvBSP , "bsalloccv offsetcrvbsp", wrapup ) ;

	// fit the curve to the abscissae pts at geodesic distance 
   BSdirfitcv(  (IGRlong) LimitCrvBSP->num_poles  ,
                AbsPts ,
                (IGRshort) 4,
                EndL    ,
                EndR    ,
                Periodic ,
                TanL ,
                TanR ,
                GeodesCrvBSP ,
                &bsrc ) ;

  __DBGpr_int( "dirfbsrc", bsrc ) ;
  __DBGpr_vec( "dirfpole1", GeodesCrvBSP->poles ) ;
  __CheckBSRC( bsrc, "bsdirfitcv", wrapup ) ;

	// and finally place the curve object 

  VgCnst->geometry   = (char *)GeodesCrvBSP;

  GeodesCurve->objid = NULL_OBJID;
  GeodesCurve->osnum = MdEnv->md_id.osnum;

  RetC = om$construct(     classid = OPP_GRbcsubbc_class_id ,
                           osnum   = GeodesCurve->osnum,
                           p_objid = &GeodesCurve->objid );

  __CheckRC( RetC,1, "OMConstruct final curve", wrapup ) ;

  RetC = om$send(msg  = message GRgraphics.GRconstruct( VgCnst),
                          senderid = NULL_OBJID,
                        targetid = GeodesCurve->objid,
                        targetos = GeodesCurve->osnum  );

  __CheckRC(RetC,*(VgCnst->msg),"Place final curve GRconstruct", wrapup );
  __DBGpr_obj( "Sland: placed final curve", *GeodesCurve );

}  // end place final curve

wrapup:

#ifndef vsDEBUGNODEL
  {
	  IGRlong TmpSts ;

	  om$send( msg = message GRgraphics.GRdelete ( &TmpSts, MdEnv ),
			  senderid = NULL_OBJID,
			targetid = TubeOffCrv.objid,
			targetos =  TubeOffCrv.osnum       );

	  om$send( msg = message GRgraphics.GRdelete ( &TmpSts, MdEnv ),
			  senderid = NULL_OBJID,
			targetid = LimitCurve.located_obj.objid,
			targetos =  LimitCurve.located_obj.osnum       );
  }
#endif 

	if(  NULL != BaseCrvBSP ){ om$dealloc(ptr =  BaseCrvBSP); }
	_FREE( AbsPts ) ;	_FREE( AbsGrev) ;
	_FREE( UVParams ) ;
	_FREE( BaseSrfBSP ) ;	_FREE( OffsCrvBSP ) ;
	_FREECV( &bsrc, GeodesCrvBSP ) ;
	_FREECV( &bsrc, LimitCrvBSP ) ;

	End
	return(RetC);

} // end VDdw_CrvOff


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// function to limit a bsp curve by two objects, these can be either 2 pts
// in which case the nearest pts on the input curve are used as the limit ;
// otherwise its the intersection of the surface object and the input curve
// or the plane of the object if its not a 3d surface.
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

IGRint  VDdw_CrvLimitObjs(
	IGRlong				* RetSts ,
	const struct IGRbsp_curve	* const InCurve ,
	const struct GRlc_info		* const LimitObjs ,
	struct IGRbsp_curve		** LimitCrvBSP ) 

{
   IGRint	ii = 0 ,		// counters
		jj = 0 ,
		RetC = OM_E_INVARG ;	// the return code of this function
   BSrc		bsrc = BSFAIL ;		// math's return code
   OMuword	LimitClass = 0 ;	// class of limiting objects
   struct IGRbsp_surface * LimitSrfPs[2];	// ptrs to limiting surfaces
   IGRpoint	* SfCvPoints[2],	// surface-curve intersection points
		LimitPoints[2] ;	// the points at the limits of the curve
   IGRdouble	* CvPars[2],		// parameters of curve at intersect
		* UPars[2],		// the same as above but for the surface
		* VPars[2]   ,
		* IntPts[2] ,               //PTR to intersect pts & 2nd crv
		* UParams[2],              //u params of the above points
		* AParams[2],              //start params for the above
		* BParams[2];              //end params for the above

  SetProc ( VDdw_CrvLimitObjs  ) ;  Begin 

  __CheckPtr( RetSts , "status ptr", wrapup ) ;
  __CheckPtr( InCurve , "InCurve ptr", wrapup ) ;
  __CheckPtr(LimitObjs , "limit Objs ptr", wrapup ) ;
  __CheckPtr(LimitCrvBSP, "limitCrv ptr", wrapup ) ;

  for ( ii=0; ii<2 ; ii++ ) {
		LimitSrfPs[ii] = NULL;
		SfCvPoints[ii] = NULL;
		CvPars[ii] = NULL;
		UPars[ii] = NULL;
		VPars[ii]    = NULL;
		IntPts[ii] = NULL ,             //PTR to intersect pts & 2nd crv
		UParams[ii]= NULL ,              //u params of the above points
		AParams[ii]= NULL ,              //start params for the above
		BParams[ii]= NULL ;              //end params for the above
  }

  for ( ii=0; ii<2 ; ii++ ) {

    RetC =  om$get_classid(	osnum = LimitObjs[ii].located_obj.osnum,
				objid = LimitObjs[ii].located_obj.objid,
			    p_classid = &LimitClass ) ;
    __CheckRC( RetC, 1, "get_classid", wrapup );

					// limit by non plane surface
      if(( om$is_ancestry_valid( superclassid = OPP_EMSsurface_class_id ,
				subclassid = LimitClass ) == OM_S_SUCCESS ) && 
      ( om$is_ancestry_valid( superclassid = OPP_EMSplane_class_id ,
				subclassid = LimitClass ) != OM_S_SUCCESS )) {

	IGRint		NumInt = 0 ;		// number of intersections
	IGRboolean	RetBool = FALSE ;	// boolean return code

	 RetC = vd_$get_geometry(
			msg	= RetSts ,
                        grobjId = &(LimitObjs[ii].located_obj) ,
			grobjEnv= &(LimitObjs[ii].module_info) ,
			geometry= &LimitSrfPs[ii]  ) ;
	 __CheckRC(RetC,*RetSts,"VDdw_OffCrvSrf: limit1 geom", wrapup);
	 __CheckPtr( LimitSrfPs[ii], "LimitObj ptr", wrapup ) ;

	*RetSts = MSFAIL ;
	RetC = OM_E_ABORT ;
	bsrc	= BSFAIL ;

    	RetBool = BScv_sf_int(	&bsrc,
				InCurve,
				LimitSrfPs[ii],
				&NumInt,
				&SfCvPoints[ii],
				&CvPars[ii],
				&UPars[ii],
				&VPars[ii]  ) ;
	__CheckBSRC( bsrc, "BScv_sf_int", wrapup ) ;
	__CheckPtr( SfCvPoints[ii] , "CvSf int points", wrapup ) ;

	for ( jj=0 ; jj<3 ; jj++ ) {
		LimitPoints[ii][jj] = (*SfCvPoints[ii])[jj] ;
	}
	__DBGpr_vec( "intersection point is", LimitPoints[ii] ) ;

   }	// case surface
					// limit by point 
   else  if( om$is_ancestry_valid( superclassid = OPP_GR3dpoint_class_id ,
				subclassid = LimitClass ) == OM_S_SUCCESS ) {

  IGRint		Action = 1 ;
  struct IGRpolyline	PolyLine ;
  IGRdouble		PLPoints[6] ;

	PolyLine.points = PLPoints ;

	RetC = om$send( msg = message GRlinear.GRgetpolyline( 	
				RetSts ,
		     (IGRshort*)&(LimitObjs[ii].module_info.md_env.matrix_type),
			     	LimitObjs[ii].module_info.md_env.matrix,
				&Action ,
			     	&PolyLine  ),
		     senderid = NULL_OBJID ,
	  	     targetid = LimitObjs[ii].located_obj.objid,
	  	     targetos = LimitObjs[ii].located_obj.osnum );

	__CheckRC( RetC, *RetSts , "Get poly of Point", wrapup ) ;
	__DBGpr_int( "num of points is", PolyLine.num_points ) ;
	__DBGpr_vec( "geom of point is", PLPoints ) ;

	for ( jj=0 ; jj<3 ; jj++ ) {
			LimitPoints[ii][jj] = ((PLPoints))[jj] ;
	}
	__DBGpr_vec( "geom of point is", LimitPoints[ii] ) ;

   }	// end if point

  else {			// use plane of planar element 
	struct IGRplane Plane ;
	IGRvector	Normal ;
	IGRpoint	Origin ;

	IGRint	NumInt	= 0	,
		NumSegs = 0 ;
	
	IGRboolean	RCbool = FALSE ;

	Plane.point  = Origin ;
	Plane.normal = Normal ;

	RetC = om$send( msg = message GRvg.GRdetplane( 	
				RetSts ,
		   (IGRshort*)&(LimitObjs[ii].module_info.md_env.matrix_type),
			     	LimitObjs[ii].module_info.md_env.matrix,
			     	&Plane ),
		     senderid = NULL_OBJID ,
	  	     targetid = LimitObjs[ii].located_obj.objid,
	  	     targetos = LimitObjs[ii].located_obj.osnum );

	__CheckRC( RetC, *RetSts , "Get plane of object", wrapup ) ;
	__DBGpr_vec( "origin point of planar element is", Origin ) ;


			// alloc space required by curve-plane intersection
	IntPts[ii]  = _MALLOC ( InCurve->num_poles * 3 , IGRdouble ) ;
	UParams[ii] = _MALLOC ( InCurve->num_poles  	, IGRdouble ) ;
	AParams[ii]= _MALLOC ( InCurve->num_poles  	, IGRdouble ) ;
	BParams[ii] = _MALLOC ( InCurve->num_poles  	, IGRdouble ) ;

	if ( !IntPts[ii] || !UParams[ii] || !AParams[ii] || !BParams[ii] ) {
		*RetSts = RetC = OM_E_NODYNMEM ;
		goto	wrapup ;
	}

	bsrc = BSFAIL ;
	RCbool = BSpl_cv_int(	&bsrc	,
	(struct IGRbsp_curve*)	InCurve ,
				Origin ,
				Normal	,
				&NumInt ,
				IntPts[ii] ,
				UParams[ii]  ,
				&NumSegs  ,
				AParams[ii]  ,
				BParams[ii]	 ) ;

	__DBGpr_vec( "Bspl_cv: intersec pt with plane", IntPts[ii] );
	__DBGpr_int( "num pl cv segs", NumSegs );
	__DBGpr_int( "num pts", NumInt );
	__DBGpr_dbl( "param at int", UParams[ii][0] );
	__CheckBSRC( bsrc, "BSpl_cv_int", wrapup ) ;

		// sometimes the itersection fails at the end points
	if ( 0 == ii && !NumInt ) {
	       for ( jj = 0 ; jj < 3 ; ++jj ) {
					IntPts[ii][jj]=InCurve->poles[jj] ;
		}
   		__DBGpr_vec( "NEW START intersec pt with plane", IntPts[ii] );
	}	
	else if ( 1 == ii && !NumInt ) {
		for ( jj = 0 ; jj < 3 ; ++jj ) {
						IntPts[ii][jj] = 
			InCurve->poles[((InCurve->num_poles-1)*3)+jj] ;
		}
   		__DBGpr_vec( "NEW END intersec pt with plane", IntPts[ii] );
	}	

	// assign intersection pt as limiting pt for curve

	for ( jj=0 ; jj<3 ; jj++ ) {
					LimitPoints[ii][jj] = IntPts[ii][jj] ;
	}
   }	// case planar object 
 }	// for each limiting object

 *LimitCrvBSP = NULL ;

 *RetSts = MSFAIL ;
 RetC = OM_E_ABORT ;

// give the 2 limiting points find the subcurve limited by these
 VDdw_CrvLimPts(	&bsrc ,           //O: bsp status code
		InCurve ,       //I:curve for params
		LimitPoints  ,       //I:limiting points
		LimitCrvBSP ) ;     //O:curve for params
 __CheckBSRC( bsrc, "VDdw_CrvLimPts", wrapup ) ;

 *RetSts = RetC = OM_S_SUCCESS ;

wrapup :

  for ( ii=0; ii<2 ; ii++ ) {
		_FREE( LimitSrfPs[ii] );
		_FREE( SfCvPoints[ii] );
		_FREE( CvPars[ii] );
		_FREE( UPars[ii] );
		_FREE( VPars[ii] );
		_FREE( IntPts[ii]  ) ;
		_FREE( 	UParams[ii]) ;
		_FREE( 	AParams[ii]) ;
		_FREE( 	BParams[ii]) ;
  }

  End 
  return ( RetC ) ;

}	// VDdw_CrvLimits


// =========================================================================

end implementation EMSsubbs;
