/* $Id: VD_linesS.I,v 1.1.1.1 2001/01/04 21:08:55 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdloft/func/VD_linesS.I
 *
 * Description:
 *		Functions for calculating offset points and curves with
 *		respect to a curve lying across a surface.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VD_linesS.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:55  cvs
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
# Revision 1.2  1996/03/24  20:20:48  pinnacle
# Replaced: vdloft/func/VD_linesS.I for:  by v240_int for vds.240
#
# Revision 1.1  1996/03/24  19:37:12  pinnacle
# Created: ./vdloft/func/VD_linesS.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			adz		creation date
 ***************************************************************************/

class implementation EMSsubbs;

#include <stdio.h>
#include <string.h>

%safe
#include <math.h>
%endsafe

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
#include "v_dbgmacros.h"
#include "VDmem.h"

//c	External Functions ***

#include "bsmkvec.h"
#include "bsnorvec.h"
#include "maarcptan.h"
#include "bsdistptpt.h"
#include "bsdotp.h"
#include "bssfeval.h"
#include "bsmove_crs.h"
#include "bsprptsonsf.h"
#include "bssfevaln.h"
#include "bspjmptssf.h"
#include "bspl_cv_int.h"
#include "bspl_nor_tc.h"
#include "bseqdptscv.h"
#include "ma2pttobc.h"
#include "bsalloccv.h"
#include "bsfreecv.h"
#include "bsiarcln.h"
#include "bscveval.h"
#include "bsdirfitcv.h"
#include "bsptsdlcv.h"
#include "bseqspaces.h"

#ifndef M_PI
#define M_PI            3.14159265358979323846
#endif


			// this fn is in VDS to intersect 2 surfaces
extern int IntTwoSrf( 
	IGRboolean              TrimOption , // I   FALSE  if no trim
	IGRboolean              AppOption  , // I   FALSE  if no approximation
 const  struct GRlc_info  * const BaseSrf   , // I   First surface
 const	struct GRlc_info  * const PjSrf    , // I   Second Surface
	struct  GRvg_construct  *cst       , // I 
	IGRint                  *NbInt     , // O   Number of intersection
	struct GRid             *IntSol    , // O   Array of solutions
	IGRlong                 *msg       ), // O 

	GRdisplay_object();
 
extern  double	fabs( double );

//c  External Methods

				
from  GRcurve	import	GRendpts;
from  EMSgenbs	import	EMplace_skinning_surface;

// External variables

extern	GRclassid	OPP_GR3dcirarc_class_id,	// circular arc class
			OPP_EMSgenbs_class_id,		// skinning surface
			OPP_GRbcsubbc_class_id;		// bspline curve class

////////////////////////////////////////////////////////////////////////////////
//  Function to calculate a variable offset curve from another curve lying 
//  along a given surface.  A normal and tangent to the initial point of offset
//  curve are given, these are used to produce two end arcs for a skinning surf
//  whose intersection is the offset curve.  The radius of the two arcs forms 
//  offset gaps at the start and end of the new curve.
///////////////////////////////////////////////////////////////////////////////

IGRint VDdw_linesSrf (

		IGRlong		 *	 RetSts   ,	//O: status code
		struct GRlc_info * const BaseCurve,	//I:trace curve 
	const	struct GRlc_info * const BaseSurf,	//I:surf for new crv
	const	IGRdouble	 * const Gaps	,	//I:old to new crv dists
		IGRdouble	 	ZDir[6] ,	//normal to arc	(tang)
	struct GRvg_construct	* const	VgCnst  ,      // construction list
		struct GRid	*	OffsetCurve  )  // new curve at offsets

{
  IGRint		RetC	=   OM_E_INVARG,//return code for this function
			jj = 0 ;
  struct GRid 		MinArcId,		// minor arc objec
 			MajArcId,		// major arc object
 			skinId,			// the skinning surface
			Intersections[10];	// resulting surf intersection  
						// curves 
 BSrc			bsrc	= BSFAIL;	// BS's return code
 IGRpoint		ArcPoint ,		// point defining arc radius
 			CurveEndPts[2];		// start + end pts of trace crv
 IGRdouble		MinArcRad = Gaps[0],	// minor arc radius (first)
			MajArcRad = Gaps[1] ;	// major arc radius (second)
 double			BStab[38],	// poles of arc (to avoid malloc)
			Angle = M_PI;	// arc sweep Angle
 struct GRmd_env 	*MdEnv	= VgCnst->env_info ;	//temp ptr to active env
 IGRvector		StartYDir ,		// normals to surf at end pts of
			EndYDir ;		// curve, ie YDirs of Arcs
 struct	IGRbsp_curve	BSpArc;	// arc geometry
 struct	IGRbsp_surface  *BSSurfPtr = NULL ;	// arc geometry
 IGRboolean	RCbool	=	FALSE ; // boolean return code

  SetProc ( VDdw_lineSrf ); Begin

  if (  !RetSts || !BaseCurve || !BaseSurf || !Gaps || !ZDir ||
	!VgCnst || !OffsetCurve ) {
	__DBGpr_int( " Problem with arguments Sts", RetSts  );
	__DBGpr_int( " Problem with arguments BaCu", BaseCurve );
	__DBGpr_int( " Problem with arguments BaSf", BaseSurf  );
	__DBGpr_int( " Problem with arguments Gap", Gaps );
	__DBGpr_int( " Problem with arguments Z", ZDir );
	__DBGpr_int( " Problem with arguments Vg", VgCnst );
	__DBGpr_int( " Problem with arguments feet_list ", OffsetCurve );
	goto wrapup;
  }

  *RetSts		=	MSFAIL;
  skinId.objid		=	NULL_OBJID;
  MinArcId.objid	=	NULL_OBJID;
  MajArcId.objid	=	NULL_OBJID;


  __DBGpr_vec( "ZDir start", ZDir );
  __DBGpr_vec( "ZDir end", &ZDir[3] );

	// set space for bsp representation of an arc
  BSpArc.poles   = &BStab[0];
  BSpArc.knots   = &BStab[21];
  BSpArc.weights = &BSpArc.knots[10];

  RetC = om$send (msg = message GRcurve.GRendpts( RetSts ,
						&MdEnv->md_env.matrix_type,
						MdEnv->md_env.matrix ,
                                		CurveEndPts[0], 
						CurveEndPts[1] ),
			  senderid = NULL_OBJID,
			  targetid = BaseCurve->located_obj.objid,
			  targetos = BaseCurve->located_obj.osnum);

  __CheckRC(RetC,*RetSts,"VDdw_lineSrf: GRendpts for curve", wrapup);

  __DBGpr_vec( "curve 1st point", CurveEndPts[0] ) ;

  RetC = vd_$get_geometry( msg = RetSts ,
			  grobjId = &(BaseSurf->located_obj) ,
			  grobjEnv= &(BaseSurf->module_info) ,
			  geometry= &BSSurfPtr ) ;
  __CheckRC(RetC,*RetSts,"VDdw_lineSrf: surf geom", wrapup);

  {			// code for evaluating surface normals 
	IGRint	NumPts = 2 ,
		NumNors= 0 ,
		Optn = 4 ;
	IGRboolean AllOnSurf = FALSE ;
	IGRdouble	UVPars[2][2] ;
	IGRpoint	Point ;

	 BSprptsonsf(	NumPts ,
			CurveEndPts ,
			BSSurfPtr ,
			UVPars,
			&AllOnSurf,
			&bsrc) ;
	CheckRC( AllOnSurf, 1 ) ;
//	CheckBSRC( bsrc ) ;
	__DBGpr_dbl( "uv pars 0", UVPars[0][0] ) ;
	__DBGpr_dbl( "uv pars 1", UVPars[0][1] ) ;
	__DBGpr_dbl( "uv pars 1", UVPars[1][0] ) ;
	__DBGpr_dbl( "uv pars 1", UVPars[1][1] ) ;

	BSsfevaln(	BSSurfPtr,
			UVPars[0][0],
			UVPars[0][1],
			Optn,
			&NumNors,
			Point,
			&StartYDir,
			&bsrc	) ;

	__DBGpr_vec( "Start YDir ", StartYDir );
	__DBGpr_int( "Start NumNors", NumNors );
	__CheckBSRC( bsrc, "bssfevaln start Y", wrapup ) ;

	BSsfevaln(	BSSurfPtr,
			UVPars[1][0],
			UVPars[1][1],
			Optn,
			&NumNors,
			Point,
			&EndYDir,
			&bsrc	) ;

	__DBGpr_vec( "End YDir ", EndYDir );
	__DBGpr_int( "End NumNors", NumNors );
	__CheckBSRC( bsrc, "bssfevaln end Y", wrapup ) ;

  }

  for ( jj=0; jj<3; ++jj ) {
		ArcPoint[jj] = CurveEndPts[0][jj] + (MinArcRad * StartYDir[jj]);
  }
  __DBGpr_dbl( "Obj radius", MinArcRad );
  __DBGpr_vec( "Obj ArcPoint", ArcPoint );

			// get the bspline definition of the semi-circle
  RCbool = MAarcptangconstr(	&bsrc,
			  	CurveEndPts[0],	// arc center
			  	ArcPoint,	// arc radius in +xaxis
			  	&Angle, 	// arc sweep Angle
			  	ZDir,		// normal to arc
				&BSpArc );
  if ( MSSUCC != bsrc && !RCbool ) {
	__DBGpr_int( "Mrk: arcbsrc ret %d ", bsrc );
	__DBGpr_int( "Mrk: RCbool ", RCbool);
	goto wrapup;
  }

  // place the minor (1st) arc object

  VgCnst->geometry   = (char *)&BSpArc;

  MinArcId.objid = NULL_OBJID;
  MinArcId.osnum = MdEnv->md_id.osnum;

  RetC = om$construct(     classid = OPP_GR3dcirarc_class_id,
                           osnum   = MinArcId.osnum,
                           p_objid = &MinArcId.objid );

  __CheckRC( RetC,1, "OMConstruct arc", wrapup ) ;

  RetC = om$send(msg  = message GRgraphics.GRconstruct( VgCnst),
			  senderid = NULL_OBJID,
			targetid = MinArcId.objid,
			targetos = MinArcId.osnum  );

  __CheckRC(RetC,*(VgCnst->msg),"Place arc GRconstruct", wrapup );
  __DBGpr_obj( "Mrk: placed arc ", MinArcId );

  #ifdef vsDEBUGNODEL		// look at arc orientation
	RetC = gr$display_object(object_id	= &MinArcId,
				md_env		= MdEnv ,
				mode		= GRbd );
	CheckRC( RetC, 1 );
  #endif

  for ( jj=0; jj<3; ++jj ) {
	ArcPoint[jj] = CurveEndPts[1][jj] + (MajArcRad * EndYDir[jj]);
  }
  __DBGpr_dbl( "Obj radius", MajArcRad );
  __DBGpr_vec( "Obj ArcPoint", ArcPoint );

	// get the bspline definition of the semi-circle
  RCbool = MAarcptangconstr(	&bsrc,
				CurveEndPts[1],	// arc center
				ArcPoint,	// arc radius in +xaxis
				&Angle, 	// arc sweep Angle
				&ZDir[3],		// normal to arc
				&BSpArc );

  if ( MSSUCC != bsrc && !RCbool ) {
	__DBGpr_int( "Mrk: arcbsrc ret %d ", bsrc );
	__DBGpr_int( "Mrk: RCbool ", RCbool);
	goto wrapup;
  }

	// place the major (2nd) arc object
  VgCnst->geometry   = (char *)&BSpArc;

  MajArcId.objid = NULL_OBJID;
  MajArcId.osnum = MdEnv->md_id.osnum;

  RetC = om$construct(	classid = OPP_GR3dcirarc_class_id,
			osnum   = MajArcId.osnum,
			p_objid = &MajArcId.objid );
  __CheckRC( RetC, 1, "OMConstruct arc", wrapup ) ;

  RetC = om$send(msg  = message GRgraphics.GRconstruct(VgCnst),
			  senderid = NULL_OBJID,
			targetid = MajArcId.objid,
			targetos = MajArcId.osnum  );

  __CheckRC(RetC, *(VgCnst->msg),"Place arc GRconstruct", wrapup );
  __DBGpr_obj( "Mrk: placed arc ", MajArcId );

  #ifdef vsDEBUGNODEL		// look at arc orientation
	RetC = gr$display_object(object_id	= &MajArcId,
				md_env		= MdEnv ,
				mode		= GRbd );
	CheckRC( RetC, 1 );
  #endif

  {	// open code to call skinning surface 

      struct GRlc_info	ArcsObjs[2];	// arcs defining skinnning form

      IGRboolean	SurfIsOpen = TRUE,	//result should alway be open
			AbsOrient  = FALSE ,	//don't force the skin to 
						//follow the input geometry
			NoHeightScale= FALSE;   //not relevant 
					
      IGRlong		NumTrace = 1,		// No of trace curves
			NumCross = 2;		// No of cross section curves

	VgCnst->geometry 	=	NULL;
	skinId.objid		=	NULL_OBJID;
	skinId.osnum 		= 	MdEnv->md_id.osnum;

	ArcsObjs[0].located_obj	= 	MinArcId;
	ArcsObjs[0].module_info	= 	*MdEnv ;
	ArcsObjs[1].located_obj	= 	MajArcId;
	ArcsObjs[1].module_info	= 	*MdEnv ;

	BaseCurve->geom_parms.polygon_inx = FALSE;

        RetC = om$construct(	classid = OPP_EMSgenbs_class_id,
                                osnum   = skinId.osnum,
                                p_objid = &skinId.objid );
        __CheckRC( RetC, 1, "OMConstruct skinning surface", wrapup ) ;

	RetC = om$send(msg  = message EMSgenbs.EMplace_skinning_surface(
								RetSts ,
								VgCnst,
								NumTrace,
								BaseCurve ,
								NumCross,
								ArcsObjs,
								SurfIsOpen,
								NULL,
								AbsOrient,
								NoHeightScale,
								NULL,
								NULL ),
			senderid = NULL_OBJID,
			targetid = skinId.objid,
			targetos = skinId.osnum  );

        __CheckRC( RetC, *RetSts, "Place skinning surface", wrapup ) ;
	__DBGpr_obj( "Mrk: placed skinning surface", skinId );

   }	// close code for call to skinning surface

   {	// code for intersecting skin surface with incoming base surface

     IGRboolean	TrimReq	=	TRUE;	// Are the curves trimmed
     struct GRlc_info	SkinSurf ;		// lc struct of skin surface

     IGRint		NumInters = 0;		// number of inters curves

     SkinSurf.located_obj  = skinId ;
     SkinSurf.module_info  = *MdEnv ;

				// intersect base surface and my skinned surf
     RetC = IntTwoSrf(  TrimReq ,
                        FALSE ,		// option not used 
                        BaseSurf ,
                        &SkinSurf,
                        VgCnst   ,
                        &NumInters ,
                        Intersections ,
                        RetSts ) ;

     __CheckRC( RetC, *RetSts,  "VDdw_IntTwoSrf", wrapup ) ;
     __DBGpr_int( "numb intersections ", NumInters );

  }	// end intersection of surfaces code

  __DBGpr_obj( "first intersection ", Intersections[0] );

	// got an intersection curve, so show it
	// NOTE  only expect ONE output curve in this version

   *OffsetCurve = Intersections[0] ;
   
#ifdef	vsDEBUGNODEL
   RetC = gr$display_object(	object_id	= OffsetCurve  ,
				md_env		= MdEnv	,
				mode		= GRbd 	);
   __CheckRC( RetC, 1, "curve display", wrapup  );
#endif

wrapup:			// WRAPUP & CLEANUP HERE 

  _FREE( BSSurfPtr ) ;


#ifndef vsDEBUGNODEL
  {
	IGRlong TmpSts ;

        om$send( msg = message GRgraphics.GRdelete ( &TmpSts, MdEnv ),
                senderid = NULL_OBJID,
                targetid = MinArcId.objid,
               targetos =  MinArcId.osnum 	);
	
        om$send( msg = message GRgraphics.GRdelete ( &TmpSts, MdEnv ),
                senderid = NULL_OBJID,
                targetid = MajArcId.objid,
               targetos =  MajArcId.osnum 	);

        om$send( msg = message GRgraphics.GRdelete ( &TmpSts, MdEnv ),
                senderid = NULL_OBJID,
                targetid = skinId.objid,
               targetos =  skinId.osnum 	);
  }
#endif 

  End
  return 	RetC ;

}	// end VDdw_linesSrf

/////////////////////////////////////////////////////////////////////////////
//	Function which takes an input surface and two curves lying across it.
//	A given parameter value along the 1st curve is used to calculate a plane
//	normal to the 1st curve.  This plane is intersected with the 2nd curve
//	the result is used to produce a line between the 1st and 2nd curves.
//	Six equally spaced pts are found on the line, these are projected onto
//	the surface to produce a curve on the surface which lies between the
//	2 input curves.  The point at the input length along the new curve is
//	returned.
//	Each sub function call is enclosed so any specific variables are 
//	declared locally.  Only common vars & memory ptrs are global.
//////////////////////////////////////////////////////////////////////////////

IGRint VDdw_SurfCrvsPt(
	IGRlong 	     *  RetSts,		//O: bsp status code
  const struct IGRbsp_surface *	const BaseSurf    ,	//I:surf to find pt on
  const struct IGRbsp_curve*	const FirstCurve  ,	//I:1st curve on surf
  const struct IGRbsp_curve*	const SeconCurve  ,	//I:2nd curve on surf
  const IGRdouble	 *	const CurveParam ,	//I:Par of 1st crv to 
							//I:    start from
  const IGRvector	 *	const ProjVec	    ,	//I:dirn of pt onto surf
  const IGRdouble	 *	const Lengths ,		//I: length along surf 
	IGRpoint		Point    )	//O: pt at length along 
							// surface 

{
   IGRboolean	RCbool	= FALSE ;	// boolean return code 
   IGRint	ii	= 0	,	// integer counter 
		RetC	= OM_E_INVARG ; // this return code 
   BSrc		bsrc = BSFAIL ;		// math return code
   IGRpoint	Origin		,		// origin of plane on 1st curve
		*RetPts = NULL	,		// PTR to pts found on surface
		EqDstPts[6] ;	// PTR to set of equidist points
   IGRdouble	* IntPts = NULL	,		//PTR to intersect pts & 2nd crv
		* UParams = NULL ,		//u params of the above points
		* AParams = NULL ,		//start params for the above
		* BParams = NULL ,		//end params for the above
		* RetPars = NULL ;		//Parameters of proj points on
						// the surface
   IGRvector	Normal		;		// normal of the plane
   struct IGRbsp_curve *	BSCurve = NULL ; //line between the 2 curves
						// then the curve between them.

  SetProc ( VDdw_SurfCrvPt ); Begin

  if ( !   RetSts	||
	!BaseSurf	||
	!FirstCurve  	||
	!SeconCurve  	||
	!CurveParam	||
	!ProjVec	||
	!Lengths	||
	!Point		 )  { goto wrapup ; }	// if bad argument exit 

 *RetSts = MSFAIL ;

 {		// code for bs plane normal to curve

   IGRboolean Finite = FALSE ;		//infinite plane
   IGRdouble	Scale =	1.0	;	// scale for plane
   struct IGRbsp_surface  BspSurf ;	// dummy surface

   BSpl_nor_tc(  &bsrc,
  (struct IGRbsp_curve*)FirstCurve ,
	(IGRdouble*)	CurveParam ,
			&Finite , 
			&Scale ,
			Origin ,
			Normal ,
			&BspSurf ) ;

   __DBGpr_vec( "Origin Pt of plane", Origin );
   __DBGpr_vec( "Normal of plane", Normal );
   __CheckBSRC( bsrc, "bspl_nor_tc ", wrapup ) ;

 }	// end section bs plane nor to crv
  
 {	// section plane crv intersection

   IGRint	NumInt	= 0	,
		NumSegs = 0 ;

   IntPts  = _MALLOC ( SeconCurve->num_poles * 3 , IGRdouble ) ;
   UParams = _MALLOC ( SeconCurve->num_poles  	, IGRdouble ) ;
   AParams = _MALLOC ( SeconCurve->num_poles  	, IGRdouble ) ;
   BParams = _MALLOC ( SeconCurve->num_poles  	, IGRdouble ) ;

   if ( !IntPts || !UParams || !AParams || !BParams ) {
	*RetSts = RetC = OM_E_NODYNMEM ;
	goto	wrapup ;
   }

   bsrc = BSFAIL ;
   RCbool = BSpl_cv_int(	&bsrc	,
	  (struct IGRbsp_curve*)SeconCurve ,
				Origin ,
				Normal	,
				&NumInt ,
				IntPts ,
				UParams  ,
				&NumSegs  ,
				AParams  ,
				BParams	 ) ;

   __DBGpr_vec( "Bspl_cv: intersec pt with plane", IntPts );
   __DBGpr_int( "num pl cv segs", NumSegs );
   __DBGpr_int( "num pts", NumInt );
   __DBGpr_dbl( "param at int", UParams[0] );
   __CheckBSRC( bsrc, "BSpl_cv_int", wrapup ) ;

	// sometimes the itersection fails at the end points
   if ( 0.000001 >= *CurveParam && !NumInt ) {
	for ( ii = 0 ; ii < 3 ; ++ii ) { IntPts[ii] = SeconCurve->poles[ii] ;
	}
   	__DBGpr_vec( "NEW START intersec pt with plane", IntPts );
   }	//end if param is about 0.

   else if ( 0.999999 <= *CurveParam && !NumInt ) {
	for ( ii = 0 ; ii < 3 ; ++ii ) {
	  IntPts[ii] = 
		SeconCurve->poles[((SeconCurve->num_poles-1)*3)+ii] ;
	}
   	__DBGpr_vec( "NEW END intersec pt with plane", IntPts );
   }	//end else param is about 1.

 }	// end section for plane crv intersection


  {	// calculate equidistant points

	IGRint		NumSpaces = 5 ;

	RCbool =  BSeqspaces( &bsrc , Origin , IntPts , &NumSpaces, EqDstPts ) ;
	__CheckBSRC( bsrc, "bseqspaces", wrapup ) ;

#ifdef vsDEBUG
	for ( ii = 0 ; ii < 6 ; ++ii ) {
		__DBGpr_vec( "next eq point", EqDstPts[ii] ) ;
	}
#endif
 }	// end section to find equidistant points

 {	// section to project equi pts on input surface

   IGRboolean	BiDirectional	= TRUE  ,	// is vector infinite?
		HadToAl		= FALSE ;	// proj pts alloc by function

   IGRint	GivenMem	= 0 ,		// no of pts passed to fn
		NumRet[6]	;		// num of pts and their params

   const IGRint	NumPrPts	= 6 ,		// num of pts projected on surf
		NumVecs		= 1 ;		// num of vectors of proj

   IGRdouble    URange[2] ,			// range on surface to look in U
		VRange[2] ;			//  in V


   URange[0] = VRange[0] = 0. ;			// the whole surface
   URange[1] = VRange[1] = 1. ;

   bsrc = BSFAIL ;

   __DBGpr_vec( "projecting along vec", *ProjVec ) ;

   BSpjmptssf(	(struct IGRbsp_surface*)BaseSurf ,
		NumPrPts  ,
		EqDstPts 	,
		NumVecs ,
		(IGRvector*)ProjVec ,
		URange  ,
		VRange  ,
		BiDirectional ,
		GivenMem	,
		NULL  	,	//ProjPts
		NULL  	,	//UVPars
		&HadToAl ,
		NumRet ,
		&RetPts ,
		&RetPars,
		&bsrc    ) ;

  __DBGpr_int( "num int pt1 ", NumRet[0] ) ;
  __DBGpr_int( "had to alloc ", HadToAl ) ;
  __CheckBSRC( bsrc ,"bsrc  bspjmptssf", wrapup  ) ;

  if ( !RetPts ) 	{ *RetSts = MSFAIL ;  goto wrapup; }

#ifdef vsDEBUG
  else
   for ( ii = 0 ; ii < 6 ; ++ii ) {
	__DBGpr_vec( "next proj point", RetPts[ii] ) ;
   }
#endif 


 }		// END section to project equi pts 


 {		// section to find curve along surface from curve 1 to curve 2

   IGRboolean Periodic = FALSE ,		// is curve periodic
		EndL   = FALSE ,		// are end tangents given?
		EndR   = FALSE ;

   IGRvector	TanL ,
		TanR ;

   BSalloccv(	(IGRshort)4	,
		(IGRlong) ( 6 + 4 -1 )	,	//num pts + ord - 1
		(IGRshort) 0	,
		(IGRshort) 0	,
		&BSCurve	,
		&bsrc 	);
  __CheckBSRC( bsrc ,"bsrc  bsalloc", wrapup  ) ;
  __CheckPtr ( BSCurve,"BSCurve bsalloc", wrapup  ) ;
		
   BSdirfitcv(  (IGRlong) 6 , 
		RetPts ,
		(IGRshort) 4,
		EndL	,
		EndR	,
		Periodic ,
		TanL ,
		TanR ,
		BSCurve ,
		&bsrc ) ;

  __DBGpr_int( "dirf bsrc", bsrc ) ;
  __DBGpr_vec( "dir pole1", BSCurve->poles ) ;
  __CheckBSRC( bsrc, "bsdirfitcv", wrapup ) ;

}	// end section to find curve along surf

#ifdef vsDEBUGNODEL

{		// debug section to draw curve

struct GRvg_construct	VgCnst  ;      // construction list
struct GRid	CurveId ;

  VDdw_initCnst( &VgCnst ) ;

  VgCnst.geometry   = (char *)BSCurve;

  CurveId.objid = NULL_OBJID;
  CurveId.osnum = VgCnst.env_info->md_id.osnum;

  RetC = om$construct(     classid = OPP_GRbcsubbc_class_id,
                                	osnum   = CurveId.osnum,
                                	p_objid = &CurveId.objid );

  __CheckRC( RetC, 1, "OMConstruct arc", wrapup ) ;

  RetC = om$send(msg  = message GRgraphics.GRconstruct(&VgCnst),
			  senderid = NULL_OBJID,
			targetid = CurveId.objid,
			targetos = CurveId.osnum  );

  __CheckRC(RetC, *(VgCnst.msg),"Place GRconstruct", wrapup );
  __DBGpr_obj( "placed crv ", CurveId );

}	// end of debug section to draw curve

#endif

 {	// final section to find at input length along curve on surface

  const IGRdouble StartPar = 0.0 ,
		  EndPar   = 1.0 ;

  IGRdouble	  OffsetLength = 0.0 ;
		  
  IGRint	TheLaw = Lengths[1] ;

  __DBGpr_int( "law is ", TheLaw ) ;

  POapplaw2val( TheLaw, Lengths[2], Lengths[3], 
		StartPar, EndPar, *CurveParam, &OffsetLength, &bsrc ) ;

  __CheckBSRC( bsrc, "POapplaw", wrapup ) ;
  __DBGpr_dbl( "offset according to law", OffsetLength ) ;

  if ( OffsetLength < 0. ) 	{ OffsetLength *= -1 ;	}

	// get pt parameter at arc length
  BSptsdlcv( 	&bsrc ,
		BSCurve  ,
		(IGRdouble*)&StartPar ,
		RetPts[5] ,
		&OffsetLength ,
		Point ) ;

  __DBGpr_int( "dist pt bsrc", bsrc ) ;
  __DBGpr_vec( "Pt at dist", Point ) ;
  __CheckBSRC( bsrc, "bsptsdlcv", wrapup ) ;

 }	// END final section to find pt at input length

 *RetSts = RetC = OM_S_SUCCESS ;

wrapup:

	_FREE( RetPts ) ;
	_FREE( IntPts ) ;
	_FREE( RetPars ) ;
	_FREE( UParams ) ;
	_FREE( AParams ) ;
	_FREE( BParams ) ;
	_FREECV( &bsrc, BSCurve ) ;
   
	End
	return	RetC ;

} //	VDdw_SurfCrvsPts


///////////////////////////////////////////////////////////////////////////////

end implementation EMSsubbs;
