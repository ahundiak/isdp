/* $Id: VLconFlatPi.I,v 1.2 2001/02/20 01:06:11 build Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:	rimbaud / VLconFlatPi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VLconFlatPi.I,v $
 *	Revision 1.2  2001/02/20 01:06:11  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:11:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.2  1998/01/16  14:31:54  pinnacle
# EMSmacros.h
#
# Revision 1.1  1997/05/08  14:05:56  pinnacle
# Loft 250
#
# Revision 1.5  1996/04/18  04:23:10  pinnacle
# Replaced: src/rimbaud/VLconFlatPi.I for:  by rchennup for loft
#
# Revision 1.4  1995/12/06  20:02:52  pinnacle
# Replaced: src/rimbaud/VLconFlatPi.I for:  by l240_int for loft
#
# Revision 1.3  1995/11/06  02:22:48  pinnacle
# Replaced: src/rimbaud/VLconFlatPi.I for:  by tlbriggs for loft
#
 *
 * History:
 *  MM/DD/YY  AUTHOR  DESCRIPTION
 *  01/16/98  ah      Changed EMSmacros.h to emsmacros.h
 *************************************************************************/
class implementation VLcoToAlCmd;




#include <stdio.h>
#include <math.h>
#include "vlprototype.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "EMSstruct.h"
#include "ma.h"
#include "maerr.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsvalues.h"
#include "msdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "grmacros.h"
#include "growner.h"
#include "nddef.h"
#include "macro.h"
#include "asmacros.h"
#include "asbox.h"
#include "graph.h"
#include "ndmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "griomacros.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "dpmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "vsdef.h"
#include "vsplatedef.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "vsbmaxisdef.h"
#include "EMSdef.h"
#include "EMSbnddef.h"
#include "EMSopt.h"
#include "EMSssprops.h"
#include "emsmacros.h"
#include "vlstructure.h"
#include "vlmsg.h"
#include "vlgrdef.h"
#include "vlgrmacros.h"
#include "vlunfold.h"


/************************** internal definitions************************/

#include "vlalma.h"
#define		FINDMARKS	0
#define		FINDPLATE	1
#define		FINDTEMPS	2

/************************** internal definitions************************/

/********************** for DEBUGGING*********************************

#ifndef CONVTOALDEBUG

#define CONVTOALDEBUG 1

#define vsDEBUG         1
#define vserrDEBUG      1

#endif

********************** end DEBUGGING*********************************/

#include "vldbgmacros.h"

/*c     External Functions ****/
/*c defined in include files */

#include	"vlPtools.h"
#include	"mazrotmx.h"
#include	"matrnmx.h"
#include	"bsmkvec.h"
#include	"bsnorvec.h"
#include	"bscrossp.h"
#include	"bsdotp.h"
#include	"bsdistptpt.h"
#include	"bssfevaln.h"
#include	"bsorthovec.h"
#include	"maptscent.h"

//c *************** External Methods ***********************/

from  EMSsurface	import	EMget_point_on_surface ;
from  GRgencs		import	GRconstruct ;
from  NDnode		import	NDmove_to_root;
from  NDmacro		import	ACreturn_foot ;
from  GRgraphics        import  GRdelete,
				GRxform ;
from	GRlinear	import	GRgetpolyline ;
from	EMSloopset	import	EMpt_location;
from	VLjunction	import	VLreturn_graphic ;

//c     Extern variables ***/

	extern GRclassid	OPP_ACpretend_class_id ,
				OPP_VLjunction_class_id ;

//c     Define the methods... 


/************** VLOrientScaleFlatPlate	********************

  method to find and place the orientation symbols of a flat (planar) plate
  and determine the scaling matrix to be applied to the plate wrt the number
  of attached stiffeners.

************************************************************/

method VLOrientScaleFlatPlate( 
	struct GRobj_env	*FlatPlate;		// the plate
	struct mise_a_plat      *dev;			// the plate's surface
	double			*ScaleMatrix ;		// the scaling matrix
	int			TypeOfExpansion;	//sort of scale to apply
	double			ExpansionInX,		// increase in x
				ExpansionInY;		// increase in y
	struct GRmd_env		*CurEnv;		// current mod env
	struct GRvg_construct   *VgCst 			// current graphic param
				)
{

struct GRid		PlateType,		// symbol for type of plate
						// ie P(ort) S(tarboard) etc
			PosnArrows,		// macro of arrows to say 
						// which way around is the plate
			MinRect,		// Rectangle around plate

			line[3],		// temp list of these edges
			GObj,			// result of return foot
			CS  ;			// coord system id

IGRint			surf_type	= 0 ,
			i		= 0,
			ii		= 0,
			sts		= OM_E_INVARG,
			nbline		= 0,
			CutIndex	= 0,
			contour		= 0;


double 			length	=	1.,
			dbl	=	0.,
			width	=	1.;

IGRchar			
          *		FeetNames[4] ;   //list of ptrs to names of orient macro

IGRlong			msg	=	MSFAIL;

IGRdouble		ScaledLength	= 0.,
			ScaledWidth	= 0.,
			XDist		= 0.,
			YDist		= 0.;

IGRpoint		BoxOrigin,	// origin for arrows' 2d box
		*	MinRectPts 	= NULL ;

IGRboolean      TempTooling     = me->tooling ,   // to override default value
                TempApprox      = me->circleapprox ;    // ditto

int                       NumEdges	= 0,
			  NumEdgeAtt	= 0 ;

struct EdgeMatch          *EdgeList	= NULL;

#define MAX_LINES 100
struct GRid	LnLst[MAX_LINES];


  SetProc( OrienScale ) ;  Begin 

  if ( ! FlatPlate || ! (dev) || ! ScaleMatrix ||
	!CurEnv || ! VgCst )	goto wrapup ;


	// code added by Ghassan J

  MinRect.osnum = me->Current.md_id.osnum;
  msg = VLgetCutMarkLns(dev,FlatPlate,VgCst,
			&NumEdges,&EdgeList,&MinRect,
                        &nbline,LnLst,&CutIndex,&contour,line,&surf_type,
                        &length,&width);

  __DBGpr_int( "nbline", nbline ) ;
  __DBGpr_int( "nb edges", NumEdges ) ;
  __DBGpr_int( "cut index", CutIndex ) ;
  __CheckRC( msg, 1, "VLgetCutMarkLns", wrapup ) ;

  MAidmx( &msg, ScaleMatrix ) ;
  CheckRC( msg, 1 ) ;

  if ( TypeOfExpansion ) {	// only call function if plate is to be expanded

	struct GRid LocCopiedObj ;		// for xform 

	IGRshort	ScaleMatType ;

	sts = VLcompute_expansion_factors (	FlatPlate,
						length,	width,
						ExpansionInX,	ExpansionInY ,
                                   		TypeOfExpansion,
						CurEnv,
                                   		ScaleMatrix,
						&ScaledLength,	&ScaledWidth );

	__CheckRC( sts, 1, "VLcompute_expansion_factors", wrapup ) ;
	__DBGpr_dbl( "Scaled Length ", ScaledLength ) ;
	__DBGpr_dbl( "Scaled Width", ScaledWidth ) ;
	__DBGpr_mat( "Scaling matrix", ScaleMatrix ) ;

        MAtypemx( &msg, ScaleMatrix , &ScaleMatType );
	CheckRC( sts, msg ) ;

	if ( ScaleMatType != MAIDMX  ) {

	   for ( i=0; i<nbline ; ++i ) {

                sts  = om$send ( msg      = message GRgraphics.GRxform (
                                                &msg,
                                                CurEnv ,
                                                &ScaleMatType ,
                                                ScaleMatrix ,
                                                &LocCopiedObj.objid ),
                                senderid = NULL_OBJID,
                                targetid = LnLst[i].objid,
                                targetos = LnLst[i].osnum );
		CheckRC( sts, msg ) ;

		if( LocCopiedObj.objid != LnLst[i].objid ) {
			if ( LocCopiedObj.objid != NULL_OBJID ) {
				LnLst[i].objid = LocCopiedObj.objid;
				LnLst[i].osnum = CurEnv->md_id.osnum;
			}

		}	// if new object is not the same as before xform

	   }	// for all the edges/lines found

	}	// if not the identity matrix 

  }	// if expand the plate

  else {
	ScaledLength = length ;		// no expansion of the plate
	ScaledWidth  = width  ;
  }

			// no cs so create one from the minimum rectangle

   if ( me->Coord.objid == NULL_OBJID ) {

	struct IGRlbsys	lbs ;			//structure for coord system
	struct GRcs_construct CSArgs ;		// coord system parameters
	IGRshort	Quatre		= 4 ;	// size of matrix
	IGRboolean	bool		= FALSE ;	// return for bs fns
	BSrc		bsrc		= BSFAIL ;	// message from bs fns

	IGRvector	XVec ,		// orientation vectors for matrix
			YVec ,		// y dir of surface
			ZVec ,		// normal to surface (from min rect)
			MinXVec ,	// orientation vectors for min rectangle
			MinYVec ;	// y dir of min rect 

	int		xIndex = 0,	// index in x dir of an offset value
			yIndex = 0 ,	// index in y dir of an offset value
			action = 1 ;

	struct IGRpolyline	PolyLine ;
	double		Sum = 0. ,	// direction and size of cs vector
			SumM= 0. ;	// direction and size of MinRect vector

	IGRdouble *	XPtr = XVec,	// ptr for swapping x & y should these
		  *	YPtr = YVec ,	// not correspond with the initial c.s.

		  *	MinXPtr = NULL ,     //x dir based on minR longest side
		  *	MinYPtr = NULL ;     //y dir based on minR shortst side

	IGRdouble * MatrixOrigin = NULL ;	// origin of the MinR based cs


		// initialise matrix to identity

	bool = MAidmx( &msg, lbs.matrix ) ;
	__CheckRC( bool, msg, "maidmx", wrapup ) ;

	/* the minimum rectangle is not always a rectangle, sometimes it's a
	parallelogram, this results in a misaligment between the surface and
	the min rectangle, so cannot use its plane for the xy plane of the coord
	system.  Instead get its normal and work out the two orthogonal vectors
	from this and then check their direction against the general direction
	of the edges of the minimum rectangle.
	*/

	bsrc= vs$get_normal(	msg = &msg,
				sfId = &(dev->surf_id.obj_id),
				sfEnv= &(dev->surf_id.mod_env),
				normal=ZVec );
	__CheckRC( bsrc, msg, "getnormal", wrapup );
	__DBGpr_vec( "Plate plane vs$get normal", ZVec );
			for( i=0 ; i<3; ++i ) ZVec[i] = - ZVec[i] ;
	__DBGpr_vec( "after reverse of struct plane normal ", ZVec );

		// set up initial c.s. based on normal to surface
  	msg = BSorthovec( &bsrc, ZVec, XVec ) ;
	bool = BScrossp( &bsrc, XVec, ZVec, YVec ) ;
	__CheckRC( bool, !bsrc, "BScrossp", wrapup ) ;
	__DBGpr_vec( "x dir", XVec ) ;
	__DBGpr_vec( "y dir", YVec ) ;
	__DBGpr_vec( "z dir", ZVec ) ;

		// get points from rectangle around plate's surface

        action = 0;    // return points

        sts = om$send(msg=message GRlinear.GRgetpolyline( &msg,
                                                        &(CurEnv->_MATRIX_TYPE),
                                                        CurEnv->_MATRIX,
                                                        &action,
                                                        &PolyLine ),
                        senderid = NULL_OBJID,
                        targetid = MinRect.objid,
                        targetos = MinRect.osnum);
         __CheckRC( sts, msg, "GRgetpolyline points", wrapup );
	__DBGpr_int( "num pts",  PolyLine.num_points ) ;

		// malloc space for the points of the minimum rectangle

	MinRectPts =	_MALLOC( PolyLine.num_points , IGRpoint );
	PolyLine.points = (IGRdouble *)MinRectPts ;
		

		// pole  0 to pole  1 defines x direction of coord system

        action = 1;    // return points

        sts = om$send(msg=message GRlinear.GRgetpolyline( &msg,
                                                        &(CurEnv->_MATRIX_TYPE),
                                                        CurEnv->_MATRIX,
                                                        &action,
                                                        &PolyLine ),
                        senderid = NULL_OBJID,
                        targetid = MinRect.objid,
                        targetos = MinRect.osnum);
         __CheckRC( sts, msg, "GRgetpolyline points", wrapup );

	MinXPtr = MinRectPts[1] ,  //x dir based on minR longest side
	MinYPtr = MinRectPts[3] ;  //y dir based on minR shortst side
	MatrixOrigin =(IGRdouble*)MinRectPts;// origin of cs & MinR are the same

	for ( i = 0; i<5; ++i ) __DBGpr_vec( "point on minR",  MinRectPts[i] ) ;

	__DBGpr_dbl( "0to1",BSdistptpt( &bsrc, MinRectPts[0], MinRectPts[1] ) );
	__DBGpr_dbl( "0to3",BSdistptpt( &bsrc, MinRectPts[0], MinRectPts[3] ) );

		// longest side of min rec is the x direction of c.s.
	if ( BSdistptpt( &bsrc, MinRectPts[0] ,  MinRectPts[1] ) <
		BSdistptpt( &bsrc, MinRectPts[0] ,  MinRectPts[3] ) ){
						MinXPtr=MinRectPts[3];
						MinYPtr=MinRectPts[1];
	}

		// pole  0 to pole1?3 defines x direction of coord system

	bool = BSmkvec(&bsrc, MinXVec, MinRectPts[0], MinXPtr ) ;
	__CheckRC( bool, !bsrc, "BSmkvec", wrapup ) ;
	bool = BSnorvec( &bsrc,  MinXVec ) ;
	__CheckRC( bool, !bsrc, "BSnorvec", wrapup ) ;

	__DBGpr_vec( "min x point", MinXPtr ) ;
	__DBGpr_vec( "min x dir", MinXVec ) ;

	__DBGpr_dbl( "minX.Y", BSdotp( &bsrc, MinXVec, YVec ) );
	__DBGpr_dbl( "minX.X", BSdotp( &bsrc, MinXVec, XVec )  );

		// if initial x&y aren't about the same as min Rect swap them 
	if ( fabs(BSdotp( &bsrc, MinXVec, YVec )) 
		> fabs( BSdotp( &bsrc, MinXVec, XVec ) ) ){
		XPtr = YVec ;
		YPtr = XVec ;
	}

	// if X is neg and Z +ve or the reverse, negate the X
	Sum = XPtr[0] + XPtr[1] + XPtr[2] ;
	SumM = ZVec[0] + ZVec[1] + ZVec[2] ;

	__DBGpr_dbl( "SumX", Sum ) ;
	__DBGpr_dbl( "SumZ", SumM ) ;

	if ( (Sum > 0. && SumM < 0.) || (Sum < 0. && SumM > 0. ) ) 
		for ( i=0 ; i<3 ; ++i ) XPtr[i] = - XPtr[i] ; 


		// get size and direction of the 2 X vectors to compare 
	Sum = XPtr[0] + XPtr[1] + XPtr[2] ;
	SumM = MinXVec[0] + MinXVec[1] + MinXVec[2] ;

	__DBGpr_dbl( "SumX", Sum ) ;
	__DBGpr_dbl( "SumXM", SumM ) ;

	// if X of min rec is not in the same general direction as the X of the 		plane, reverse the X of the plane

	if ( (Sum > 0. && SumM < 0.) || (Sum < 0. && SumM > 0. ) ) 
			MatrixOrigin = MinXPtr ;


		// pole  0 to pole  2 defines y direction of coord system

	bool = BSmkvec(&bsrc, MinYVec, MinRectPts[0], MinYPtr ) ;
	__CheckRC( bool, !bsrc, "BSmkvec", wrapup ) ;
	bool = BSnorvec( &bsrc,  MinYVec ) ;
	__CheckRC( bool, !bsrc, "BSnorvec", wrapup ) ;


	bool = BScrossp( &bsrc, ZVec, XPtr, YPtr/*MinYVec*/ ) ;
	__CheckRC( bool, !bsrc, "BScrossp", wrapup ) ;


	__DBGpr_vec( "crossed y dir", YPtr ) ;
	__DBGpr_vec( "miny dir", MinYVec ) ;

	Sum = YPtr[0] + YPtr[1] + YPtr[2] ;
	SumM = MinYVec[0] + MinYVec[1] + MinYVec[2] ;

	__DBGpr_dbl( "SumY", Sum ) ;
	__DBGpr_dbl( "SumYM", SumM ) ;

	// if Y of min rec is not in the same general direction as the Y of the 		plane, reverse the Y origin of the plane

	__DBGpr_vec( "y dir", YPtr ) ;
	if ( (Sum > 0. && SumM < 0.) || (Sum < 0. && SumM > 0.) )
		if ( MatrixOrigin == (IGRdouble*)MinRectPts )
			MatrixOrigin = MinYPtr ;
		else
			MatrixOrigin = (IGRdouble*) MinRectPts [2] ;

	__DBGpr_vec( "x dir", XPtr ) ;
	__DBGpr_vec( "y dir", YPtr ) ;
	__DBGpr_vec( "z dir", ZVec ) ;

            /*
             *  set up the local bounded system geometry for the
             *  coordinate system -- transpose the view rotation matrix, add
             *  in the origin, and give it a degenerate diagonal
             */

	MAtrnmx( &msg, &Quatre, lbs.matrix, lbs.matrix ) ;
	__CheckRC( 1, msg, "MAtrnmx", wrapup ) ;

		// sometimes matrnmx forgets this value
	lbs.matrix[15] = 1. ;

	for ( Quatre = 0 ; Quatre < 3 ; ++ Quatre ) {
		lbs.matrix[ 3 + (4 * Quatre) ]	= MatrixOrigin[Quatre] ;
		lbs.matrix[4*Quatre]		= XPtr[Quatre] ;
		lbs.matrix[1+(4*Quatre)]	= YPtr[Quatre] ;
		lbs.matrix[2+(4*Quatre)]	= ZVec[Quatre] ;
		lbs.diag_pt1[ Quatre ] 		= 0. ;
		lbs.diag_pt2[ Quatre ] 		= 0. ;
	}

	__DBGpr_mat( "lbs mat", lbs.matrix ) ;

		// get the origin point for the orientation arrows

        sts = VLretMaxOfVal(NumEdges,&EdgeList[0], CurEnv, &dbl, &msg);
        if (!(sts&msg&1)) dbl = 40.;
	sts = VLfindBoxOnSurf( &msg, dev, (IGRuint)1, lbs.matrix,
                               dbl+VL_ARROW_SIZE,dbl+VL_ARROW_SIZE, 
                               dbl,dbl,				// In
			       BoxOrigin, NULL ) ;	        // Out
	CheckRC( sts, msg ) ;

		// construct and place the coord system
 
        CS.osnum = me->Current.md_id.osnum;
        CS.objid = NULL_OBJID;
	CSArgs.type	= RECTANGULAR ;
	CSArgs.desc	= NULL ;
	CSArgs.flag	= 0;
	VgCst->geometry = (IGRchar*)&lbs ;
	VgCst->class_attr = (IGRchar*)&CSArgs ;


        sts = om$construct(
                                classname       = "GRgencs",
                                osnum           = CS.osnum,
                                p_objid         = &CS.objid,

				msg = message GRgencs.GRconstruct( VgCst ) ) ;

	VgCst->geometry	= NULL ;
	VgCst->class_attr = NULL ;

	__CheckRC( sts, *(VgCst->msg), "CS altconstr", wrapup ) ;
	__DBGpr_obj( "CS", CS ) ;

	VgCst->geometry = NULL ;


		// calculate the X&Y offset from the coordinate system origin


	if ( fabs( lbs.matrix[0]) > 0.001 )	xIndex = 0 ;
	else if ( fabs( lbs.matrix[4] ) > 0.001 )	xIndex = 1 ;
	else    				xIndex = 2 ;

	if ( fabs( lbs.matrix[1]) > 0.001 )	yIndex = 0 ;
	else if ( fabs( lbs.matrix[5] ) > 0.001 )	yIndex = 1 ;
	else    				yIndex = 2 ;

	__DBGpr_int( "xind", xIndex );
	__DBGpr_int( "yind", yIndex );

	for ( i = 0 ; i<3 ; ++i ) {
		XVec[i] = lbs.matrix[i*4] ;
		YVec[i] = lbs.matrix[(i*4)+1] ;

	}

	__DBGpr_vec( "xvec" , XVec );
	__DBGpr_vec( "yvec" , YVec );

	XDist = BoxOrigin[xIndex] - MatrixOrigin[xIndex];
	YDist = BoxOrigin[yIndex] - MatrixOrigin[yIndex];

	__DBGpr_dbl( "xoffset", XDist ) ;
	__DBGpr_dbl( "yoffset", YDist ) ;

	XDist *= XVec[xIndex] ;
	YDist *= YVec[yIndex] ;

	__DBGpr_dbl( "xoffset", XDist ) ;
	__DBGpr_dbl( "yoffset", YDist ) ;

		/* this coordinates system is now used to map all geometry to
		   its xy plane, so no longer require me->tmat **/

	me->Coord = CS ;

   }	// end if need to define the coordinate system
   else
	 CS =  me->Coord ;


  ii = 0 ;

  for ( i=0; i<nbline ; ++i ) {

__DBGpr_int( "line index", i ) ;
__DBGpr_obj( "Edgemac", EdgeList[i].EdgeMac ) ;
__DBGpr_obj( "LnLst", LnLst[i] ) ;
__DBGpr_int( "NULL_OBJID ", NULL_OBJID ) ;

	
	if ( i >= CutIndex && i < (CutIndex+NumEdges) ) {

	   me->tooling = 0 ;   // cut

		//see if edge attributes are attached to the edge

	   NumEdgeAtt = -1 ;		// just the attributes
	   sts = om$send( msg = message VLcoToAlCmd.GetAttribOfObj( 
							EdgeList[ii].EdgeMac,
                                                                &NumEdgeAtt ),
                       targetid = my_id );
	   CheckRC( sts, 1 );
	   __DBGpr_int( "nb edge attributes", NumEdgeAtt ) ;

	   ++ii ;

	}   // if edge to cut

	else {	// its a mark

	   __DBGpr_int( "this is a mark ", i ) ;

	  me->edgeAt.type[0] = 'M';
	  me->tooling = 1;        // regardless of general setting set to mark

	  if ( vs$is_ancestry_valid( object = &LnLst[i] ,
				classid = OPP_VLjunction_class_id ) ) {
	
      		// cludge due to VLgetCut no longer returning just graphics

		struct GRobj_env  JuncGraphic ;

		sts = om$send( msg = message VLjunction.VLreturn_graphic ( 
								&msg ,
								NULL ,
								&JuncGraphic ),
				targetid = LnLst[i].objid ,
				targetos = LnLst[i].osnum );
		__CheckRC( sts, msg, "return_graphic", next_object );

			// if no edge attribute pass VLjunctions to Strudel
		me->edgeAt.macOcId = LnLst[i] ;

		__DBGpr_obj( "set edge mac GLOBAL to", me->edgeAt.macOcId ) ;


		// set the object in graphic list to the graphic foot of junc

		LnLst[i] = JuncGraphic.obj_id ;
		__DBGpr_obj( "NEW LnLst", LnLst[i] ) ;

	   }	// if not graphic but VLjunction

	   else {	
		me->edgeAt.macOcId.objid = NULL_OBJID ;
	   }


  	} 	// else mark


		// convert edge or mark

	sts = om$send( msg = message VLcoToAlCmd.FindTypeThenConvert(
                                                                &LnLst[i] ,
                                                                FALSE ),
                       targetid   = my_id);

	CheckRC( sts, 1 );

next_object :
	__DBGpr_int( "next line index", i+1 ) ;

   }	// for all lines ( mark or edge )

		// GJ code, it should place the orientation and type symbol
		//   macros: see him about it
   msg = VLplace_symbols(	&dev->surf_id,surf_type,&CS,VgCst,
				XDist+47.,YDist+53.,XDist,YDist ,
				line,ScaledLength,ScaledWidth,
                        	&PlateType, &PosnArrows);
   __CheckRC( msg, 1, "VLplace_symbols", wrapup ) ;


   sts   = om$send( msg = message NDmacro.ACreturn_foot(
                                        &msg,
                                        "letter",
                                        &GObj,
                                        &(me->RefMatType),
                                        me->RefMatrix ),
                senderid     = NULL_OBJID,
                targetid     = PlateType.objid,
                targetos     = PlateType.osnum);

   __CheckRC( sts, msg, "could not find foot letter", wrapup  ) ;

  me->edgeAt.type[0] = 'M';
  me->edgeAt.angle1  = 0. ;
  me->edgeAt.angle2  = 0. ;
  me->tooling = 1 ;             /* override global value
				   same for circular approximation of curves
				   or linestrings in the symbol macros as these
				   small curves give problems to approx fn */
  me->circleapprox = FALSE ;

                // transfer the graphic part to rimbaud file

  sts = om$send( msg = message VLcoToAlCmd.FindTypeThenConvert(
                                                                &GObj ,
                                                                FALSE ),
                        targetid   = my_id);
  __CheckRC( sts, 1, "convert letter of Type", wrapup  ) ;

	// convert the graphic feet of the orientation macro

  FeetNames[0] = "arrow1" ; FeetNames[1] = "letter1" ;
  FeetNames[2] = "arrow2" ; FeetNames[3] = "letter2" ;

			// get and convert any of above named successors
  for ( i=0 ; i<4 ; ++ i ) {

        GObj.objid = NULL_OBJID ;
        sts   = om$send( msg = message NDmacro.ACreturn_foot(
                                        &msg,
                                        FeetNames[i] ,
                                        &GObj ,
                                        &(me->RefMatType),
                                        me->RefMatrix ),
                senderid     = NULL_OBJID,
                targetid     = PosnArrows.objid,
                targetos     = PosnArrows.osnum);

        CheckRC( sts, msg );

        if ( GObj.objid != NULL_OBJID ) {
                /* transfer the graphic part to rimbaud file */

                if ( me->RefMatType != MAIDMX ) {
                __DBGpr_mat( "foot matrix", me->RefMatrix ) ;
                }

                sts = om$send( msg = message VLcoToAlCmd.FindTypeThenConvert(
                                                                &GObj ,
                                                                FALSE ),
                                targetid   = my_id);

                CheckRC( sts, 1 );

        }
        else  break ;   /* as no more feet of this name */

  } // for orientation feet


wrapup:
				// 1st reset globals that may have been changed
        me->circleapprox = 	TempApprox ;
        me->tooling	=	TempTooling ;
	me->edgeAt.type[0] = 'R';
	me->edgeAt.angle1  = 0. ;
	me->edgeAt.angle2  = 0. ;

			// if matrix was set by a give foot, reset to id
	if ( me->RefMatType != MAIDMX ) {
                        MAidmx( &msg, me->RefMatrix ) ;
                        me->RefMatType = MAIDMX  ;
	}

	_FREE( MinRectPts ) ;

#ifndef vsDEBUG
{			// remove all surplus geometry
  int loc_sts = MSFAIL ;

	loc_sts = om$send( msg = message GRgraphics.GRdelete( &msg,
								&me->Current ),
				senderid = NULL_OBJID ,
				targetid = MinRect.objid,
				targetos = MinRect.osnum ) ;
	CheckRC( loc_sts, msg ) ;

/***********	CS used to map geometry to its xy plane *************
	loc_sts = om$send( msg = message GRgraphics.GRdelete( &msg,
								&me->Current ),
				senderid = NULL_OBJID ,
				targetid = CS.objid,
				targetos = CS.osnum ) ;
	CheckRC( loc_sts, msg ) ;
************************************************************************/

	loc_sts = om$send( msg = message GRgraphics.GRdelete( &msg,
								&me->Current ),
				senderid = NULL_OBJID ,
				targetid     = PlateType.objid,
				targetos     = PlateType.osnum);
	CheckRC( loc_sts, msg ) ;
	loc_sts = om$send( msg = message GRgraphics.GRdelete( &msg,
								&me->Current ),
				senderid = NULL_OBJID ,
				targetid     = PosnArrows.objid,
				targetos     = PosnArrows.osnum);
	CheckRC( loc_sts, msg ) ;

		// remove copied edges 
	for ( i = CutIndex ; i < (CutIndex+NumEdges); ++i ) {

	loc_sts = om$send( msg = message GRgraphics.GRdelete( &msg,
								&me->Current ),
				senderid = NULL_OBJID ,
				targetid     = LnLst[i].objid,
				targetos     = LnLst[i].osnum);
	CheckRC( loc_sts, msg ) ;
	}
}
#endif	

 if( EdgeList ) { om$dealloc( ptr = EdgeList );  EdgeList  = NULL; }


	End
	return sts;

}  // orient and scale the flat plate

//**************************************************

/*		VLfindBoxOnSurf

	Function to find a 2D box on a (normally flat) surface and return the
	origin point(3D) of the box in XYZ space and if required, the 2D point
	in UV space parameters of the surface.  
	This algorithm is simply to get a know point on the surface, work out
	2 UV pts at a set distance in the X & Y dirs of a given coord sys matrix
	and set whether or not these pts lie on the surface or are external to
	it (ie are external to the surface's loopsets).  Note in this case it is
	the two orthogonal pts from the origin, NOT the opposite corner which
	are used to define the box and the box is aligned with the XY of the
	incoming 4x4 matrix NOT the UV of the surface (though these could be one
	and the same.  It should also be noted that a steeply curved surface may
	result in a box smaller or larger than 110 square units.
*/

IGRint	VLfindBoxOnSurf( Msg, Surf, AttemptNum, lbs, horz, vert,opp_horz,
                         opp_vert, PointOnSurf, EMParams )

	IGRlong	*	Msg ;		// I:0 internal return message code
 struct mise_a_plat *	Surf;		// I:  flat surface to find area on 
	IGRuint AttemptNum  ;		// I:  how many goes at point_on_surf
	IGRmatrix	lbs ;		// I:  orientation matrix for box
        double 		horz;
        double 		vert;
        double 		opp_horz;
        double 		opp_vert;
	IGRpoint	PointOnSurf;	// O:  point on surf defining box origin
struct EMparms	*	EMParams ;	// O:  NULL or uv params of surf point 

{

  IGRint ReturnCode	= OM_E_INVARG ,	// OM return code 
	 FoundPoint	= 0 ,		// if point on surface 
	 i		= 0 ,		// counter 
	 PtNum		= 0 ,		// counter 
	 check		= 0 ,		// check against infinite loops
	 NumLoopIds	= 0 ;

  IGRuint NumLoopSets	= 0 ;		// no of loops returned
  	 

OM_S_OBJECT_LINKAGE LoopSetLinks;       // ptr to list of loopset ids

GRobjid	*	LoopIds = NULL ;	// list of loop ids 
	

  IGRvector	XVec,			// X Vector of cs whose xy defines box 
		YVec ;			// Y Vector of cs defining the box
  IGRvector	XoppVec,               // other vectors to avoid problems
                                       // if there are offsets
                YoppVec,
                midVec,
                mid1Vec,
                mid2Vec,
                mid3Vec;

  IGRpoint	BoxEdgePts[9],		// the  pts 
		CornerOnSurf ;		// the 3D surface pt of the 2 abouve

  IGRdouble	Dist	= 0. ,		// dist from corner pt to surface
  		Box2D[20] ;		// the 2d(uv) orthog corners of the box

IGRboolean	Intersection = FALSE ;	// does box intersect an edge

struct EMSptloc_info 	PtLocInfo ;	// i/o for pt_location method
struct EMSpartolbasis 	ParTolBasis;	// i/o for pt_location method


  BSrc		bsrc 	=	BSFAIL ;

  if ( ! Msg || !Surf || !lbs || !PointOnSurf )  goto wrapup ;

  // if ( ! AttemptNum ) AttemptNum = 1 ;

	// get the loopsets of the surface and number of internal loops
  ReturnCode = VLGetSurfLoops( &(Surf->surf_id.obj_id),
				&LoopSetLinks ,
				&NumLoopSets ,
				&LoopIds ,
				&NumLoopIds	);
  __CheckRC( ReturnCode, 1 , "VLGetSurfLoops", wrapup ) ;
  __DBGpr_int( "Found this many internal loops", NumLoopSets ) ;

	// if none or 1 just get 1st (normally mid) pt of surface 
  if ( NumLoopSets < 2 ){
	ReturnCode = om$send( msg = message EMSsurface.EMget_point_on_surface(
							Msg,
						       &(Surf->surf_id.mod_env),
							AttemptNum , 
							(IGRint)1 ,  
							(IGRdouble*)PointOnSurf,
							EMParams ) ,
			senderid     = NULL_OBJID,
			targetid     = Surf->surf_id._objid,
			targetos     = Surf->surf_id._osnum );
	__CheckRC( ReturnCode, *Msg, "get point on surface", wrapup ) ;
	__DBGpr_vec( "point on surface", PointOnSurf ) ;

	goto wrapup ;		// only the outside loop so point should be good
   }

		// get X & Y direction of the coordinate system
                // get also other directions
   for ( i=0 ; i<3 ; ++i ) { 
	XVec[i] = lbs[i*4] ;
        XoppVec[i] = - XVec[i];
	YVec[i] = lbs[1+(i*4)] ;
        YoppVec[i] = - YVec[i];
        midVec[i]  = (XVec[i] + YVec[i])/2.;
        mid1Vec[i] = (XVec[i] + YoppVec[i])/2.;
        mid2Vec[i] = (XoppVec[i] + YoppVec[i])/2.;
        mid3Vec[i] = (XoppVec[i] + YVec[i])/2.;
	XVec[i] *= horz ;
        XoppVec[i] *= opp_horz;
	YVec[i] *= vert ;
        YoppVec[i] *= opp_vert;
   }
   BSnorvec( &bsrc,  midVec ) ; BSnorvec( &bsrc,  mid1Vec ) ;
   BSnorvec( &bsrc,  mid2Vec ) ; BSnorvec( &bsrc,  mid3Vec ) ;
   for ( i=0 ; i<3 ; ++i ) { 
        midVec[i] *= (vert+horz)/2.;
        mid1Vec[i] *= (opp_vert+horz)/2.;
        mid2Vec[i] *= (opp_vert+opp_horz)/2.;
        mid3Vec[i] *= (vert+opp_horz)/2.;
   }
   __DBGpr_vec( "160 in XVec", XVec ) ;
   __DBGpr_vec( "160 in YVec", YVec ) ;

	// try to find one 2D box that does not intersection with a loop

   do {
	++check ;		// to stop infinite loops

	ReturnCode = om$send( msg = message EMSsurface.EMget_point_on_surface(
							Msg,
						       &(Surf->surf_id.mod_env),
							AttemptNum , 
							(IGRint)1 ,  
							(IGRdouble*)PointOnSurf,
							EMParams ) ,
			senderid     = NULL_OBJID,
			targetid     = Surf->surf_id._objid,
			targetos     = Surf->surf_id._osnum );
	__CheckRC( ReturnCode, *Msg, "get point on surface", wrapup ) ;
	__DBGpr_vec( "point on surface", PointOnSurf ) ;

        AttemptNum += 2 ;    // try to get well-spaced points

		// make sure we have surface geometry 
	if ( !Surf->surface ) { ReturnCode = OM_E_INVARG ; goto wrapup ; }

		// find several pts in several directions
                // of the box (orientation arrows)
	for( i=0; i<3; ++i ) {
		BoxEdgePts[0][i]	= PointOnSurf[i] + XVec[i];
		BoxEdgePts[1][i]	= PointOnSurf[i] + YVec[i];
		BoxEdgePts[2][i]	= PointOnSurf[i] + midVec[i];
		BoxEdgePts[3][i]	= PointOnSurf[i] + YoppVec[i];
		BoxEdgePts[4][i]	= PointOnSurf[i] + XoppVec[i];
		BoxEdgePts[5][i]	= PointOnSurf[i] + mid1Vec[i];
		BoxEdgePts[6][i]	= PointOnSurf[i] + mid2Vec[i]; 
		BoxEdgePts[7][i]	= PointOnSurf[i] + mid3Vec[i];
	}
	__DBGpr_vec( "Box X Corner", BoxEdgePts[0] ) ;
	__DBGpr_vec( "Box Y Corner", BoxEdgePts[1] ) ;
	__DBGpr_vec( "Box Mid Corner", BoxEdgePts[2] ) ;
	__DBGpr_vec( "Box Yopp Corner", BoxEdgePts[3] ) ;
	__DBGpr_vec( "Box Xopp Corner", BoxEdgePts[4] ) ;
	__DBGpr_vec( "Box Mid1 Corner", BoxEdgePts[5] ) ;
	__DBGpr_vec( "Box Mid2 Corner", BoxEdgePts[6] ) ;
	__DBGpr_vec( "Box Mid3 Corner", BoxEdgePts[7] ) ;

	for ( PtNum = 0; PtNum < 8 ; ++PtNum ) {

           if (PtNum >= 3 && !opp_horz && !opp_vert) {
	     Intersection = FALSE ;
             break;
           }
           
	   BSptnorsf( Surf->surface, BoxEdgePts+PtNum , &FoundPoint ,
		   &Box2D[0+(PtNum*2)], &Box2D[1+(PtNum*2)] ,
		   CornerOnSurf , &Dist , &bsrc ) ;
	   CheckRC( 1, !bsrc ) ;
	   __DBGpr_vec( "surf says Box Opposite Corner", CornerOnSurf ) ;

			// if point outside surf try another origin
	   if ( !FoundPoint ) { Intersection = TRUE ;break ;}

	   __DBGpr_vec( "surf says Box corner", &Box2D[2*PtNum] ) ;

	   PtLocInfo.options	= EMS_PTLOC_ACTLOOP ;
	   ParTolBasis.mattyp	= &Surf->surf_id.mod_env._MATRIX_TYPE ;
	   ParTolBasis.mat	= Surf->surf_id.mod_env._MATRIX;

		//for each loopset set see whether point lies in an area
		// fixed at one for the moment 
	   	// for ( i = 0 ; i<NumLoopSets ; ++i ) {

	     ParTolBasis.is_valid	= FALSE ;
	     ReturnCode = om$send( msg = message EMSloopset.EMpt_location( Msg ,
							 &Box2D[PtNum*2],
							 &PtLocInfo,
							 &ParTolBasis ),
			senderid     = NULL_OBJID,
			targetid     = LoopSetLinks.S_objid ,
			targetos     = LoopSetLinks.osnum );
	     __CheckRC( ReturnCode, *Msg, "Find point location", wrapup ) ;

		// if this point is outside start again
	     if ( PtLocInfo.location != EMS_L_INAREA ) break ;


	//	only one loopset   }	//	for all the loopsets found

	if ( PtLocInfo.location != EMS_L_INAREA ){   // pt outside, try again!
		__DBGpr_int( "box loopset intersection", PtLocInfo.location ) ;
		Intersection = TRUE;
		break ;
	}
	else if (PtNum == 7) {	// all points are inside so it can exit
		__DBGpr_int( "no intersection", PtLocInfo.location ) ;
		Intersection = FALSE ;
	}

    } // for

   } while( Intersection && (check < 10) ) ;

		// if the check has cut in and the box still intersects, abort

   if ( check >= 10 && Intersection ) ReturnCode = OM_E_ABORT ;

   // to avoid that a corner of an arrow be in a hole
   PointOnSurf[0] += 10*lbs[0] + 10*lbs[1];
   PointOnSurf[1] += 10*lbs[4] + 10*lbs[5];

wrapup:

	if ( LoopIds ) om$dealloc( ptr = LoopIds ) ;

	return ReturnCode ;

}  // end VLfindBoxOnSurf 

end implementation VLcoToAlCmd;
