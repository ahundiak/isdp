class implementation VLmrkLine;

//+*****************************************************************************
//
//	Implementation of object defining the mark of a Struct 
//		   stiffener or plate on a plate. The result is usually a
//		   curve defining the side of the marking object which touches
//		   the corresponding plate along with an offset (malconta) which
//		   indicates the width of the marking object.  The main curve
//		   may be trimmed across boundaries and the offset is usually a
//		   short curve of a 100 units, a third of the way along the
//		   length of the marking object.
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
#include "msdef.h"
#include "madef.h"
#include "ma.h"
#include "exmacros.h"
#include "grmacros.h"
#include "dpmacros.h"
#include "growner.h"
#include "emssfintdef.h"
#include "EMSsffmacros.h"
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

#include "bscrossp.h"
#include "bscveval.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "maarcptan.h"
#include "bsdistptpt.h"
#include "bsdotp.h"


//********************c  External Methods


from  GRcurve	import	
			GRmidpoint ;

from  EMSgenbs	import	EMplace_skinning_surface;


// External variables

extern	GRclassid	OPP_EMSgenbs_class_id,
			OPP_GR3dlineseg_class_id,
			OPP_GR3dcirarc_class_id ;

//+****************************************************************************
//
//	Function given a list of curves create a series of half-tubes with 
//	radius = the distance between the curves.   !  no longer used
//
//+++++++++++++++++   VLCreateTubes	++++++++++++++++++++++++++++++++++++++


int VLCreateTubes( 

	IGRlong   *	CTMsg , 		// return code
	int		NumCurves ,
	struct GRid	  *	Curves  , 	// the curves to build tube
 struct GRmd_env	  *	md_env ,
 struct GRvg_construct*	vg_cnst ,
	IGRvector	DirVector ,		// dirn from main to offset
 struct GRid	  *     Tubes )		// the tube (skinning) surface

{

	IGRpoint		CurveStart[2] ,
				CurveEnd [2] ,
				PtAlongCurve[2] ,
					PointOnArc;

	IGRvector		xDir, yDir, zDir ;

	int			LastPoleInd	= 0 ,
				ii	   	= 0 ,
				sts		= OM_E_INVARG ,
				CurveNo		= 0 ;

		double			bstab[38],	/* poles of arc	      */
					angle = M_PI,	/* arc sweep angle    */
					startdist = 0., /*dis to star of curve*/
					enddist   = 0., /*dist to end of curve*/
					Gap = 0. ,
				*	OffsetCentre= NULL 	,
				*	Centre	= NULL ;

		struct	IGRbsp_curve	bsp_arc,	/* arc geometry	      */
					*CurveGeom ;

		struct GRlc_info	trcobj,		/* trace curve of skin*/
					crsobj;		/* curve defn of skin */

		IGRlong			num_trace = 1,
					num_cross = 1;

		IGRboolean		is_open	= TRUE,
					absolute_orien = TRUE,
					no_height_scale= FALSE,
					bool = FALSE ;

	struct GRid	arcId ,
			skinId ;

	BSrc		bsrc ;


	SetProc ( CreateTubes ) ; Begin 

	if (	! CTMsg || 		// return code
 		! Curves||   	// the plate to check
		! md_env||
		!vg_cnst||
		!DirVector||
 		! Tubes )		// pt on surf closest to midpt
				goto wrapup ;


	bsp_arc.poles   = &bstab[0];
	bsp_arc.knots   = &bstab[21];
	bsp_arc.weights = &bsp_arc.knots[10];

	for ( ii = 0; ii<NumCurves ; ++ii ) {
		__DBGpr_obj( "curve ", Curves[ii] ) ;
		sts = om$send (msg = message GRcurve.GRgenabsg( CTMsg ,
						&(md_env->md_env.matrix_type) ,
						md_env->md_env.matrix ,
						(IGRchar**)&CurveGeom ),
			  senderid = NULL_OBJID,
			  targetid = Curves[ii].objid,
			  targetos = Curves[ii].osnum);

		__CheckRC( sts,*CTMsg, "VLCreTubes: GRgenabs for curve",wrapup);

		BScveval( CurveGeom , 0.1 , 0 , &PtAlongCurve[ii] , &bsrc ) ;
		__CheckBSRC( bsrc, "BScveval", wrapup ) ;
		
		CurveStart[ii][0] = CurveGeom->poles[0] ;
		CurveStart[ii][1] = CurveGeom->poles[1] ;
		CurveStart[ii][2] = CurveGeom->poles[2] ;

		LastPoleInd = (CurveGeom->num_poles * 3) - 3 ;
		__DBGpr_int( "last pole index", LastPoleInd ) ;

		CurveEnd  [ii][0] = CurveGeom->poles[LastPoleInd+0] ;
		CurveEnd  [ii][1] = CurveGeom->poles[LastPoleInd+1] ;
		CurveEnd  [ii][2] = CurveGeom->poles[LastPoleInd+2] ;

		__DBGpr_vec( "CurveSt ", CurveStart[ii] ) ;
		__DBGpr_vec( "CurveEnd", CurveEnd  [ii] ) ;

	}

        startdist = BSdistptpt( &bsrc, CurveStart[0], CurveStart[1] );
	__CheckBSRC( bsrc, "BSdistptpt", wrapup ) ;
	__DBGpr_dbl( "startdist", startdist );

        enddist	  = BSdistptpt( &bsrc, CurveStart[0], CurveEnd[1] );
	__CheckBSRC( bsrc, "BSdistptpt", wrapup ) ;
	__DBGpr_dbl( "end  dist", enddist );


	if ( startdist < enddist ) {
				OffsetCentre	= CurveStart[1]; 	
				Gap		= startdist;
			}
			else {
				OffsetCentre	= CurveEnd[1]; 	
				Gap		= enddist;
			}
		
	__DBGpr_vec( "Mrk: OffsetCentre ", OffsetCentre );


	*CTMsg = BSmkvec( &bsrc, xDir, OffsetCentre, CurveStart[0]  );
	__CheckBSRC( bsrc, "BSmkvec offset-start", wrapup ) ;

	bool = BSnorvec( &bsrc, xDir );
	__CheckBSRC( bsrc, "BSnorvec offset-start", wrapup ) ;
					 
	   	__DBGpr_vec( "xDir", xDir );

	DirVector[0] = - xDir[0];
	DirVector[1] = - xDir[1];
	DirVector[2] = - xDir[2];

	*CTMsg = BSmkvec( &bsrc, zDir, CurveStart[0], PtAlongCurve[0] );
	__CheckBSRC( bsrc, "BSmkvec start-pt along", wrapup ) ;
	bool = BSnorvec( &bsrc, zDir );
	__CheckBSRC( bsrc, "BSnorvec start-pt along", wrapup ) ;
					 
	__DBGpr_vec( "z direction", zDir );
	
	bool = BScrossp( &bsrc, zDir, xDir, yDir );
	__CheckBSRC( bsrc, "BScrossp z/x", wrapup ) ;

	__DBGpr_vec( "yDir", yDir );

#ifdef	vsDEBUG
		{
		 double dirn;
		 dirn = BSdotp( &bsrc, zDir, yDir );
		 if ( dirn > 0. || dirn < 0. ) {
		   __DBGpr_dbl( "z direction cross", dirn );
		 }
		 {
		   dirn = BSdotp( &bsrc, xDir, yDir );
		   __DBGpr_dbl( "x direction cross", dirn );
		 }
		}
#endif
			// if the orthogonal to xz isn't in the dirn as the
			// vector axis to crossSn, flip it, to have the arc on
			// the correct side of the axis.
			//


	for ( CurveNo=1; CurveNo < 2 ; ++CurveNo ) {

		 if ( CurveNo ){
		    yDir[0] = -yDir[0];yDir[1] = -yDir[1];yDir[2] = -yDir[2];
		 }

		__DBGpr_vec( "yDir ", yDir );

		for ( ii=0; ii<3; ++ii ) 
		     PointOnArc[ii] = OffsetCentre[ii] + (Gap * yDir[ii]);

		__DBGpr_vec( "Obj ArcPoint", PointOnArc );


		__DBGpr_dbl( "Arc radius", Gap );
			// get the bspline definition of the semi-circle

		bool = MAarcptangconstr(&bsrc, OffsetCentre ,
					PointOnArc, &angle, 
					zDir,  &bsp_arc );

		if ( bsrc != MSSUCC && !bool ) {
			__DBGpr_int( "Mrk: arcbsrc ret %d ", bsrc );
			__DBGpr_int( "Mrk: bool ", bool);
			goto wrapup;
		}

	        vg_cnst->geometry   = (char *)&bsp_arc;

		arcId.objid = NULL_OBJID;
		arcId.osnum = md_env->md_id.osnum;

		sts = om$construct(     classid = OPP_GR3dcirarc_class_id,
                                	osnum   = arcId.osnum,
                                	p_objid = &arcId.objid );

        	__CheckRC( sts, 1, "OMConstruct arc", wrapup ) ;

		sts = om$send(msg  = message GRgraphics.GRconstruct( vg_cnst),
			senderid = NULL_OBJID ,
			targetid = arcId.objid,
			targetos = arcId.osnum  );

        	__CheckRC( sts,*vg_cnst->msg, "Place arc GRconstruct", wrapup );
		__DBGpr_obj( "Mrk: placed arc ", arcId );

		vg_cnst->geometry 	=	NULL;
		skinId.objid		=	NULL_OBJID;
		skinId.osnum 		= 	md_env->md_id.osnum;

		crsobj.located_obj	= 	arcId;
		crsobj.module_info	= 	*md_env;
		trcobj.located_obj	= 	Curves[0];  // main=trace curve
		trcobj.module_info	= 	*md_env ; 
		trcobj.geom_parms.polygon_inx = FALSE;

        	sts = om$construct(     classid = OPP_EMSgenbs_class_id,
                                	osnum   = skinId.osnum,
                                	p_objid = &skinId.objid );

        	__CheckRC( sts, 1, "OMConstruct skinning surface", wrapup ) ;

		sts = om$send(msg  = message EMSgenbs.EMplace_skinning_surface(
								CTMsg,
								vg_cnst,
								num_trace,
								&trcobj,
								num_cross,
								&crsobj,
								is_open,
								NULL,
								absolute_orien,
								no_height_scale,
								NULL,
								NULL ),
			senderid = NULL_OBJID ,
			targetid = skinId.objid,
			targetos = skinId.osnum  );

        	__CheckRC( sts, *CTMsg, "Place skinning surface", wrapup ) ;
		__DBGpr_obj( "Mrk: placed skinning surface", skinId );

	Centre		= OffsetCentre ;
	Tubes[/*CurveNo*/0]	= skinId ;
		
    }	// for all input curves

wrapup:

	End

	return sts ; // OM_E_INVARG ; //sts ;

	// end VLCreateTubes
}


//	fn to enclose the rather long ems surf-surface fn which itself encloses
//	the ems fn to intersect two surfaces
//
int VLIntTwoSrfs(	IGRlong	*	ITSMsg , 
		struct GRobj_env *	BaseSurf,
		struct GRid      *	IntSectSurf,
		struct GRvg_construct *	vg_const ,
			IGRlong  *	NumInters ,
		struct GRid	  **	IntersObjs )

 {

		struct GRlc_info PlateLcInfo ,
				 StiffSideInfo [2] ;


   struct EMSdataselect EDS;

   struct GRid	IntersObj ;

   int	sts	= OM_E_INVARG ,
	ii	= 0 ,
	NumSrfs = 0 ,
	NumInter= 0 ;

   SetProc ( IntTwoSrfs  ) ; Begin 

   if ( !ITSMsg || !BaseSurf || !IntSectSurf || 
	!vg_const || !NumInters || !IntersObjs ) goto wrapup ;

   __DBGpr_int( "intersecting this many surfaces", *NumInters ) ;

   PlateLcInfo.located_obj	= 	BaseSurf->obj_id;
   PlateLcInfo.module_info	= 	BaseSurf->mod_env;

   NumSrfs = *NumInters ;

   IntersObj.osnum = vg_const->env_info->md_id.osnum ;

   for ( ii =0;	ii<NumSrfs ;	++ii ) {



		*ITSMsg = MSFAIL ;
		*(vg_const->msg) = OM_S_SUCCESS ;
		vg_const->geometry = NULL ;

		StiffSideInfo[ii].located_obj	= IntSectSurf[ii];
		StiffSideInfo[ii].module_info	= *(vg_const->env_info) ;


	EDS.data.object = &(IntSectSurf[ii]) ;
	EDS.datatype = EMSdata_object ;

	__DBGpr_obj( "Inters srf", IntSectSurf[ii] ) ;

    sts = ems$intersect_surfaces( msg	= ITSMsg ,
				surface1= &(BaseSurf->obj_id) ,
				surface1env = &(BaseSurf->mod_env) ,
				numsurfaces2= 1 ,
				surfaces2= &EDS   ,
				surfaces2env = &(vg_const->env_info->md_env ),
				inters_opts = EMS_SFINT_HANDLESTOP ,
				world_opts = EMSINT_OUTPUT_WORLD |
						EMSINT_WORLD_OBJECT ,
				param_opts = FALSE ,
				trim_opts  = 
				EMSINT_TRIM_OUTPUT		|
				EMSINT_TRIM_COPLANAR		|
				EMSINT_TRIM_PROCOVERLAP		|
				EMSINT_TRIM_HANDLESTOP		|
				EMSINT_TRIM_BDRYISAREA	,
				construction_args = vg_const ,
				inters_outputobj  = &(IntersObj.objid)  ,
				status_str = "Marking plate" ,
				num_inters = &NumInter  ) ;

    __CheckRC( sts, *ITSMsg, "ems intersect", wrapup ) ;
    CheckRC( 1, *(vg_const->msg) ) ;

	__DBGpr_int( "int surf returned no curves", NumInter ) ;
	__DBGpr_int( "int surf returned value", sts ) ;
	__DBGpr_obj( "intersection", IntersObj ) ;

		*NumInters += NumInter ;
		*IntersObjs[ii] = IntersObj ;

  }	//for all surfaces to intersect with base surface

	if ( NumInter ) 
		sts = OM_S_SUCCESS ;
	else
		sts = MSFAIL ;
wrapup:


	End

	return sts ;

} // VLIntTwoSurf


//	
//	given a curve and a direction,place a line starting at the midpt of this
//	curve going in the give dirn
//
int VLLineAtMidByVec(	IGRlong	*	LMVMsg , 
		struct GRid      *	TheCurve ,
		IGRvector		DirVector ,
		struct GRvg_construct *	vg_const ,
		struct GRid	  *	TheMidPtLine )

{			

   IGRpoint		MidPt,
			PerEndPts[2];

   struct IGRpolyline      PerpLineGeom ;   // geom of the perp. line

	struct GRparms GrParms;
   int	sts	=	OM_E_INVARG ,
			ii ;

   SetProc ( LineAtMidByVec ) ; Begin 

   if ( !LMVMsg || !TheCurve || ! DirVector || ! vg_const || ! TheMidPtLine )
		goto wrapup ;

	   GrParms.u = 0.5 ;		// mid section

	   sts = om$send (msg = message GRcurve.GRmidpoint( LMVMsg ,
					&(vg_const->env_info->_MATRIX_TYPE) ,
					vg_const->env_info->_MATRIX ,
							&GrParms ,
                                			MidPt ),
			  senderid = NULL_OBJID,
                          targetid = TheCurve->objid ,
                          targetos = TheCurve->osnum );
	   __CheckRC( sts, *LMVMsg ,"get midpt ", wrapup );
	   __DBGpr_vec( "full offset mid", MidPt ) ;

	for ( ii=0; ii<3; ++ii ) PerEndPts[0][ii] = MidPt[ii] ;

	__DBGpr_vec( "new curve start ", PerEndPts[0] ) ;

		// need to go 50 units in main to offset direction

	PerEndPts[1][0] = PerEndPts[0][0] + (DirVector[0]*50.) ;
	PerEndPts[1][1] = PerEndPts[0][1] + (DirVector[1]*50.) ;
	PerEndPts[1][2] = PerEndPts[0][2] + (DirVector[2]*50.) ;

	__DBGpr_vec( "perp start",PerEndPts[0]  ) ;
	__DBGpr_vec( "perp end ", PerEndPts[1] ) ;
	__DBGpr_vec( "perp dir ", DirVector ) ;

	TheMidPtLine->osnum = vg_const->env_info->md_id.osnum ;

	sts = om$construct(     classid = OPP_GR3dlineseg_class_id,
                                osnum   = TheMidPtLine->osnum ,
                                p_objid = &(TheMidPtLine->objid) ) ;

        __CheckRC( sts, 1, "Mrk: OMConstruct PerpLine", wrapup ) ;

	PerpLineGeom.num_points		=	2;
	PerpLineGeom.points		= (IGRdouble*)PerEndPts ; 
	vg_const->geometry		= (char*)&PerpLineGeom;
	*(vg_const->msg)		= OM_S_SUCCESS ;

	sts = om$send(msg = message GRgraphics.GRaltconstruct( vg_const),
			  senderid = NULL_OBJID,
		targetid = TheMidPtLine->objid ,
		targetos = TheMidPtLine->osnum ) ;

       __CheckRC( sts,*(vg_const->msg), "Mrk: altConstruct PerCurve", wrapup ) ;

wrapup :

	End
	return sts ;

}	// end closure for vector from full to offset mark

//
//	given two curves, build a surface along the first which is perpendicular
//	to the dirn between the curves at a height of 3* the + and 3* the -
//	distance between the curves.
//
int VLCreateFlatSkin( 

	IGRlong   *	CTMsg , 		// return code
	struct GRid	Curves[2]  , 	// the curves to build skin surface
 struct GRmd_env	  *	md_env ,
 struct GRvg_construct*	vg_const ,
	IGRvector	DirVector ,		// dirn from main to offset
 struct GRid	  *     FlatSkin )		// the (skinning) surface

{

 IGRpoint		CurveStart[2] ,
 			CurveEnd [2] ,
 			PtAlongCurve[2] ,
 			 LineEnds [2];

 IGRvector		xDir, yDir, zDir ;

 int			LastPoleInd	= 0 ,
 			ii	   	= 0 ,
 			sts		= OM_E_INVARG ,
 			CurveNo		= 0 ;

 double
 			startdist = 0., //dis to star of curve*/
 			enddist   = 0., //dist to end of curve*/
 			Gap = 0. ,
 		*	OffsetStart= NULL 	;

  struct IGRbsp_curve	  *CurveGeom ;		// geom of input curves 
  struct IGRpolyline      PerpLineGeom ;   // geom of the perp. line


  struct GRlc_info	trcobj,		// trace curve of skin*/
			  crsobj;		// curve defn of skin */

  IGRlong			num_trace = 1,
 				num_cross = 1;

  IGRboolean		is_open	= TRUE,
  			absolute_orien = TRUE,
 				no_height_scale= FALSE,
 				bool = FALSE ;

 struct GRid	LineId ,
 		skinId ;

 BSrc		bsrc ;


 SetProc ( FlatSkin ) ; Begin 

 if (	! CTMsg || 		// return code
  	! Curves||   	// the plate to check
 	! md_env||
 	!vg_const||
 	!DirVector  )           goto wrapup ;

 LineId.objid = NULL_OBJID;

 for ( ii = 0; ii<2 ; ++ii ) {
 	__DBGpr_obj( "curve ", Curves[ii] ) ;
 	sts = om$send (msg = message GRcurve.GRgenabsg( CTMsg ,
						&(md_env->md_env.matrix_type) ,
						md_env->md_env.matrix ,
						(IGRchar**)&CurveGeom ),
	 	  senderid = NULL_OBJID,
	 	  targetid = Curves[ii].objid,
	 	  targetos = Curves[ii].osnum);

	 __CheckRC( sts,*CTMsg, "VLCreFlatSkin: GRgenabs for curve",wrapup);

	 BScveval( CurveGeom , 0.1 , 0 , &PtAlongCurve[ii] , &bsrc ) ;
		
	 CurveStart[ii][0] = CurveGeom->poles[0] ;
	 CurveStart[ii][1] = CurveGeom->poles[1] ;
	 CurveStart[ii][2] = CurveGeom->poles[2] ;

	 LastPoleInd = (CurveGeom->num_poles * 3) - 3 ;
	 __DBGpr_int( "last pole index", LastPoleInd ) ;

	 CurveEnd  [ii][0] = CurveGeom->poles[LastPoleInd+0] ;
	 CurveEnd  [ii][1] = CurveGeom->poles[LastPoleInd+1] ;
	 CurveEnd  [ii][2] = CurveGeom->poles[LastPoleInd+2] ;

		__DBGpr_vec( "CurveSt ", CurveStart[ii] ) ;
		__DBGpr_vec( "CurveEnd", CurveEnd  [ii] ) ;

	}

        startdist = BSdistptpt( &bsrc, CurveStart[0], CurveStart[1] );
	__DBGpr_dbl( "startdist", startdist );
        enddist	  = BSdistptpt( &bsrc, CurveStart[0], CurveEnd[1] );
	__DBGpr_dbl( "end  dist", enddist );


	if ( startdist < enddist ) {
	 		OffsetStart	= CurveStart[1]; 	
	 		Gap		= startdist;
	  }
	  else {
	 		OffsetStart	= CurveEnd[1]; 	
	 		Gap		= enddist;
	  }
		
	__DBGpr_vec( "Mrk: OffsetStart ", OffsetStart );
		__DBGpr_dbl( "Gap between lines", Gap );

	Gap = 1000. ;
	__DBGpr_dbl( "OVERRIDING: Gap between lines", Gap );


	*CTMsg = BSmkvec( &bsrc, xDir, OffsetStart, CurveStart[0]  );
	__CheckBSRC( bsrc, "FlatSkin:BSmkvec of-cs", wrapup ) ;
	bool = BSnorvec( &bsrc, xDir );
	__CheckBSRC( bsrc, "FlatSkin:BSnorvec", wrapup ) ;
					 
	   	__DBGpr_vec( "xDir", xDir );

	DirVector[0] = - xDir[0];
	DirVector[1] = - xDir[1];
	DirVector[2] = - xDir[2];
	if( !FlatSkin ) 
	{
	   sts = OM_S_SUCCESS;
	   goto wrapup;
	}

		// use initial curve dirn to approx Z

	*CTMsg = BSmkvec( &bsrc, zDir, CurveStart[0], PtAlongCurve[0] );
	__CheckBSRC( bsrc, "FlatSkin:BSmkvec cs-pta", wrapup ) ;
	bool = BSnorvec( &bsrc, zDir );
	__CheckBSRC( bsrc, "FlatSkin:BSnrovec cs-pta", wrapup ) ;
					 
	__DBGpr_vec( "z direction", zDir );

		// Y is the cross product 

	bool = BScrossp( &bsrc, zDir, xDir, yDir );
	__CheckBSRC( bsrc, "FlatSkin:BScrossp z/x", wrapup ) ;

					 
	__DBGpr_vec( "yDir", yDir );


#ifdef	vsDEBUG
		{
		 double dirn;
		 dirn = BSdotp( &bsrc, zDir, yDir );
		 if ( dirn > 0. || dirn < 0. ) {
		   __DBGpr_dbl( "z direction cross", dirn );
		 }
		 {
		   dirn = BSdotp( &bsrc, xDir, yDir );
		   __DBGpr_dbl( "x direction cross", dirn );
		 }
		}
#endif
			//Build the vertical (cross section) line 
			// and the 1st curve is used as the trace


	for ( CurveNo=0; CurveNo < 1 ; ++CurveNo ) {

		__DBGpr_vec( "yDir ", yDir );

	  for ( ii=0; ii<3; ++ii ) {
	       LineEnds[0] [ii] =  CurveStart[0][ii] + (3*(Gap * yDir[ii]));
	       LineEnds[1] [ii] =  CurveStart[0][ii] - (3*(Gap * yDir[ii]));
	  }

		__DBGpr_vec( "Obj 1st Line Point", LineEnds[0]  );
		__DBGpr_vec( "Obj 2nd Line Point", LineEnds[1]  );


		__DBGpr_dbl( "Gap between lines", Gap );

		LineId.objid = NULL_OBJID;
		LineId.osnum = md_env->md_id.osnum;


		PerpLineGeom.num_points		=	2;
		PerpLineGeom.points		= (IGRdouble*)LineEnds  ; 
		vg_const->geometry		= (char*)&PerpLineGeom;
		*(vg_const->msg)		= OM_S_SUCCESS ;

	sts = om$construct(     classid = OPP_GR3dlineseg_class_id,
				osnum   = LineId.osnum,
				p_objid = &LineId.objid  );
       __CheckRC( sts,1, "Mrk: altConstruct PerCurve", wrapup ) ;

	sts = om$send( msg  = message GRgraphics .GRaltconstruct( vg_const) ,
			  senderid = NULL_OBJID,
			targetid = LineId.objid ,
			targetos = LineId.osnum );
       __CheckRC( sts,*(vg_const->msg), "Mrk: FlatSkin altConstruct ", wrapup );

	__DBGpr_obj( "Mrk: placed arc ", LineId );

		vg_const->geometry 	=	NULL;
		skinId.objid		=	NULL_OBJID;
		skinId.osnum 		= 	md_env->md_id.osnum;

		crsobj.located_obj	= 	LineId;
		crsobj.module_info	= 	*md_env;
		trcobj.located_obj	= 	Curves[CurveNo];//main=trace crv
		trcobj.module_info	= 	*md_env ; 
		trcobj.geom_parms.polygon_inx = FALSE;

        	sts = om$construct(     classid = OPP_EMSgenbs_class_id,
                                	osnum   = skinId.osnum,
                                	p_objid = &skinId.objid );

        	__CheckRC( sts, 1, "OMConstruct skinning surface", wrapup ) ;

		sts = om$send(msg  = message EMSgenbs.EMplace_skinning_surface(
								CTMsg,
								vg_const,
								num_trace,
								&trcobj,
								num_cross,
								&crsobj,
								is_open,
								NULL,
								absolute_orien,
								no_height_scale,
								NULL,
								NULL ),
			senderid = NULL_OBJID ,
			targetid = skinId.objid,
			targetos = skinId.osnum  );

        	__CheckRC( sts, *CTMsg, "Place skinning surface", wrapup ) ;
		__DBGpr_obj( "Mrk: placed skinning surface", skinId );

	*FlatSkin	= skinId ;
		
    }	// for all input curves

wrapup:

	if (   LineId   .objid != NULL_OBJID ) {
		int stat ;
		long msg ;
		__DBGpr_obj( "deleting line", LineId ) ;
		stat= om$send(msg  = message GRcurve.GRdelete( &msg,
								md_env ),
				senderid = NULL_OBJID ,
				targetid =   LineId   .objid,
				targetos =   LineId   .osnum  );
		CheckRC( stat, msg );
	}

	End

	return sts ; // OM_E_INVARG ; //sts ;

	
}	// end VLCreateFlatSkin



end implementation VLmrkLine;

//----------------------------------------------------------------------------

