/* $Id: VD_CurvEv.I,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdloft/func/VD_CurvEv.I
 *
 * Description:
 *		Functions for calculating offset points and curves
 *		with respect to a curve lying across a surface.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VD_CurvEv.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:53  cvs
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
# Revision 1.2  1996/03/24  20:21:34  pinnacle
# Replaced: vdloft/func/VD_CurvEv.I for:  by v240_int for vds.240
#
# Revision 1.1  1996/03/24  19:31:08  pinnacle
# Created: ./vdloft/func/VD_CurvEv.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
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

#include "bsmkvec.h"
#include "bsnorvec.h"
#include "maarcptan.h"
#include "bsdistptpt.h"
#include "bsdotp.h"
#include "bssfeval.h"

#include "bsprptsonsf.h"
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
#include "bscveval.h"
#include "bslsqfitcv.h"
#include "bspartofcv.h"
#include "bsmdstptscv.h"


////////////////////////////////////////////////////////////////////////////////
//  Function to calculate the Greville abscissae for the input curve
///////////////////////////////////////////////////////////////////////////////

IGRint VDdw_CurveAbsGrev (
	IGRlong				* RetSts  ,	//O: status code
	const	struct IGRbsp_curve	* const InCurve ,//I: curve to work with
	IGRdouble			* AbsGrev )     //O: the asbcisses 
{

	IGRint		RetC	=   OM_E_INVARG,//return code for this function
			jj = 0 ,
			ii = 0 ,
			Degree = 0 ,
			iStart = 0 ,
			iEnd   = 0 ;

  SetProc ( VDdw_CurveAbsGrev ); Begin

  if (  !RetSts || !InCurve || !AbsGrev  ) {
	__DBGpr_int( " Problem with arguments Sts", RetSts  );
	__DBGpr_int( " Problem with arguments InC", InCurve );
	__DBGpr_int( " Problem with arguments Abs", AbsGrev );
	goto wrapup;
  }

  *RetSts = MSFAIL;
  Degree  =  InCurve->order - 1 ;

  for ( ii=0; ii<InCurve->num_poles ; ii++ ) {

	iStart = ii+1 ;
	iEnd   = iStart + Degree ;
	AbsGrev[ii] = 0. ;
	for ( jj=iStart; jj<iEnd ; jj++ ) AbsGrev[ii] += InCurve->knots[jj] ;
	AbsGrev[ii] /= (IGRdouble)Degree ;

	__DBGpr_dbl( "abs grev ", AbsGrev[ii] ) ;
  }

  *RetSts = RetC = OM_S_SUCCESS ;

wrapup:			// WRAPUP & CLEANUP HERE 

  End
  return 	RetC ;

}	// end VDdw_CurveAbsG

/////////////////////////////////////////////////////////////////////////////
//	fn to calculate the points on a curve a its Greville abcissae 
//////////////////////////////////////////////////////////////////////////////

IGRint VDdw_CrvAbsPts(
	IGRlong 		   *  RetSts,		//O: bsp status code
	const struct IGRbsp_curve  * const InCurve ,	//I:curve for params
	IGRpoint		   **	CurvePts )	//O:lis of points

{

   IGRint	ii	= 0	,	// integer counter 
		NumTans = 0	,	// only want pts on curve
		RetC	= OM_E_INVARG ; // this return code 
   IGRdouble	* AbsGrev= NULL	;	//list of params at Greville's abscissae
   BSrc		bsrc = BSFAIL ;

  SetProc ( VDdw_CrvAbsPts ); Begin

  if (  ! RetSts	||
	! InCurve 	||
	! CurvePts		 )  { goto wrapup ; }	// if bad argument exit 

  AbsGrev = _MALLOC( InCurve->num_poles, IGRdouble ) ;

  RetC =  VDdw_CurveAbsGrev (	RetSts  ,
				InCurve ,
				AbsGrev );

  __CheckRC( RetC, *RetSts, "VDdw_CurveAbsGrev", wrapup ) ;
  __CheckPtr( AbsGrev , "AbsGrev ", wrapup ) ;

  *CurvePts = _MALLOC( InCurve->num_poles , IGRpoint ) ;

  for ( ii = 0 ; ii<InCurve->num_poles ; ii++ ) {

	// evaluate curve pt at parameter 
	BScveval(	(struct IGRbsp_curve*)InCurve ,
			AbsGrev[ii] ,
			NumTans  ,
			(IGRpoint*)(*CurvePts)[ii] ,
			&bsrc ) ;

	__DBGpr_int( "bscvev bsrc", bsrc ) ;
	__DBGpr_vec( "bscvev Pt", (*CurvePts)[ii] ) ;
  }


wrapup:
	_FREE( AbsGrev ) ;
	End
	return	RetC ;

} //	VDdw_CrvsAbsPts


/////////////////////////////////////////////////////////////////////////////
//	fn to limit a curve by 2 points , the points on the curve closest to
//	the given points are used to product the subcurve.
//////////////////////////////////////////////////////////////////////////////

void VDdw_CrvLimPts(
		BSrc		   *    bsrc ,		//O: bsp status code
		struct IGRbsp_curve*	InCurve ,	//I:curve for params
		IGRpoint	   *	Points  ,	//I:limiting points
		struct IGRbsp_curve**	OutCurve )	//O:curve for params
{

   IGRdouble	PtsParams[2] ;		// paramters of pts on the curve
   IGRboolean	BoolRC = FALSE ;

  SetProc ( VDdw_CrvLimPts ); Begin

  // make sure the arguments are valid 

  __CheckPtr( bsrc   , "bsrc   ptr", wrapup ) ;

  *bsrc = BSINARG ;
  __CheckPtr( InCurve, "InCurve ptr", wrapup ) ;
  __CheckPtr( Points, "Points ptr", wrapup ) ;
  __CheckPtr( OutCurve, "OutCurve ptr", wrapup ) ;

  __DBGpr_vec( "first in point", Points[0] ) ;
  __DBGpr_vec( "second in point", Points[1] ) ;

 {			// 1st get the closest points 
    IGRpoint	PointsOnCurve[2] ;
    IGRboolean  AllOnCurve = FALSE ;
    IGRdouble	Dists[2] ;
    IGRint	NumPts	= 2 ;

    BSmdstptscv( NumPts ,
		Points ,
		InCurve,
		PtsParams,
		PointsOnCurve,
		Dists,
		&AllOnCurve ,
		bsrc ) ;
		
    __CheckBSRC( *bsrc, "points min dist crv BSmdstptscv", wrapup ) ;
    __DBGpr_vec( "first point", PointsOnCurve[0] ) ;
    __DBGpr_vec( "second point", PointsOnCurve[1] ) ;

 }  // end min dist pts section 

	// now alloc a new curve according to BSpartofcv

 BSalloccv(	InCurve->order ,
		InCurve->num_poles + (2*InCurve->order - 1) ,//couldbe otherway?
		InCurve->rational ,
		InCurve->num_boundaries ,
		OutCurve ,
		bsrc ) ;
 __CheckBSRC( *bsrc, "BSalloccv", wrapup ) ;
 __CheckPtr( *OutCurve , "OutCurve", wrapup ) ;

  __DBGpr_dbl( "first point par" , PtsParams[0] ) ;
  __DBGpr_dbl( "second point par", PtsParams[1] ) ;

		// find sub curve from pt 1 to pt 2 via their mid parameter
 BoolRC = BSpartofcv(	bsrc ,
			InCurve,
			PtsParams[0],
			(PtsParams[0]+PtsParams[1])/2. ,
			PtsParams[1],
			*OutCurve ) ;
 __CheckBSRC( *bsrc, "BSpartofcv", wrapup ) ;

wrapup :
	BoolRC = TRUE ;
	End

}	// end VDdw_CrvLimPts 

end implementation EMSsubbs;
