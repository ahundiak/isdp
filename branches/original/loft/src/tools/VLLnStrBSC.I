class implementation GRbcsubbc		;


#include "math.h"
#include <stdio.h>
#include "vlprototype.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "EMSstruct.h"
#include "maerr.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsvalues.h"
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "grmacros.h"
#include "growner.h"
#include "macro.h"
#include "dpmacros.h"
#include "EMSssprops.h"
#include "EMSdpb.h"

#include "bsmergarrcv.h" 
#include "bsxtractpar.h"
#include "bsfreecv.h"		/* 		BSfreecv();	   */
#include "bsalloccv.h"		/* extern void	BSalloccv(),	   */

extern double fabs __((double));

/************************** internal definitions************************/



/********************** for DEBUGGING*********************************

#ifndef CONVTOALDEBUG

#define vsDEBUG         1
#define vserrDEBUG      1

#endif

********************** end DEBUGGING*********************************/

#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vldbgmacros.h"

//c     External Functions ****
//c defined in include files *

//c *************** External Methods ***********************

//c from  GRbcsubbc		import	EMcurve_by_poles;

//c     Extern variables ***

//c  ***********   external vars.. ***




//===========================================================================* 
//	given a lineString as a data structure or object id, try to approximate
//	with a bspline of the active order, then break the curve at any cusps
//	( knuckles ) and process each subcurve.	*/
//===========================================================================* 

IGRint	LineStrToCurve (
	BSrc			* bsrc ,	// BS status code 
	struct GRlc_info  	* inLineString,	// IN:	lineString id or
	struct IGRbsp_curve	* inLSbyGeom,	// IN:	lineString by geom
	struct GRvg_construct	* VgCnst,	// construction list
	struct GRid		* OutCurve 	// OUT: curve from linestring
			)

{

	IGRint		ii,			// incremental integer
			RetC  = OM_E_INVARG,
			NumCusps = 0,
		*	Cusps	  = NULL;	// list of cusp indexes

	IGRuchar	buffer;			// for EMSdpb functions

	IGRboolean	PolesAligned = FALSE,
			u_periodic;

	IGRlong 	u_order = 0, // was short
			NumPoles = 0,
			LStat	= MSFAIL;

	IGRdouble	tol	= 1.0;	// current chord height tolerance

	IGRpoint      *	Poles	=	NULL;	// list of poles for curve

struct	IGRbsp_curve  *	CrvByPolesBSP = NULL,	// geom of curve to find Cusps
		      * MergedCrv     = NULL,
		      **SubCrvs=	NULL;	// a sub curve between Cusps

 struct GRid 		CrvByPoles;		//used approximate linestring

 struct GRmd_env        *MdEnv  = VgCnst->env_info ;    //temp ptr to active env


 SetProc( VLLineStrToCurve );	Begin


 if ( !inLineString && !inLSbyGeom ) goto wrapup;

 __CheckPtr ( bsrc , "input bsrc", wrapup ) ;
 __CheckPtr ( VgCnst, "VgCnst", wrapup ) ;
 __CheckPtr ( OutCurve, "OutCurve", wrapup ) ;

			// get default properties for output curve
 RetC= EMdpb_get(
			&LStat,
			EMSdpb_u_order,
			&buffer);
 __CheckRC(RetC, LStat, "EMSdpb_props:u_order", wrapup);

 u_order = buffer;

 RetC= EMdpb_get(
			&LStat,
			EMSdpb_props,
			&buffer);
 __CheckRC(RetC, LStat, "EMSdpb_props:u_period",wrapup);

 if ((buffer & EMDPB_U_PERIODIC) && (u_order > 2))
			u_periodic = TRUE;
 else
			u_periodic = FALSE;


			// 1st use linestring points for curve by poles

 CrvByPoles.osnum = MdEnv->md_id.osnum;
 CrvByPoles.objid = NULL_OBJID;

 RetC= om$construct(
                                classname       = "GRbcsubbc",
                                osnum           = CrvByPoles.osnum,
                                p_objid         = &CrvByPoles.objid ) ;

 __DBGpr_obj( "ConGeom constructed curv ", CrvByPoles );
 __CheckRC(RetC, 1, "OMconstruct curv", wrapup ) ;

 if ( inLSbyGeom ) {

		if (inLSbyGeom->rational) {
			__DBGpr_com( "Rational lineString?" );
			RetC =	BSunwght_p(
					bsrc,
					inLSbyGeom->poles,
					inLSbyGeom->weights,
					&inLSbyGeom->num_poles,
					inLSbyGeom->poles);
			__CheckBSRC( *bsrc, "BSunwght_p", wrapup ) ;
		} // if (inLSbyGeom->rational)

		NumPoles = inLSbyGeom->num_poles;
		Poles   = (IGRpoint *) inLSbyGeom->poles;
 } // if by geometry


 VgCnst->geometry	= NULL;

 RetC = om$send(msg = message GRbcsubbc.EMcurve_by_poles(
								u_order,
								u_periodic,
								NumPoles,
								Poles,
								inLineString ,
								VgCnst ),
			senderid = NULL_OBJID,
                       targetid = CrvByPoles.objid,
                       targetos = CrvByPoles.osnum);
 __CheckRC( RetC, *(VgCnst->msg) , "EMcurve_by_poles:", wrapup );

 RetC = vs$get_geometry(       msg = &LStat ,
			  grobjId = &(CrvByPoles) ,
			grobjEnv= (MdEnv) ,
			geometry= &CrvByPolesBSP ) ;
 __CheckRC(RetC,LStat,"VLOffCrvSrf: surf geom", wrapup);
 __CheckPtr( CrvByPolesBSP, "CrvByPolesBSP ptr", wrapup ) ;


 BSxtractpar( bsrc, BSTOLCHRDHT, &tol );
 __CheckBSRC( *bsrc, "bsxtractpar", wrapup ) ;
 tol *= tol;
  __DBGpr_dbl("tolerance ",tol );

 POcvFndCusps(CrvByPolesBSP, tol, &NumCusps, &Cusps, &PolesAligned, bsrc);

 __DBGpr_int( "Cusps gave ", NumCusps  );

 if ( *bsrc != BSSUCC || PolesAligned || !Cusps ) {

		__DBGpr_int( "FndCusps failed", inLSbyGeom );
		__DBGpr_int( "PolesAligned", PolesAligned );
		__DBGpr_int( "retBS", *bsrc );
		__DBGpr_int( "Cusps", Cusps );

		*OutCurve	 = CrvByPoles ;
		CrvByPoles.objid = NULL_OBJID ;

 }
 else { 		// found the Cusps
		
	SubCrvs = 	_MALLOC( NumCusps+1 , struct IGRbsp_curve * )  ;
	__DBGpr_int( "num poles", CrvByPolesBSP->num_poles ) ;

	  for ( ii=0; ii<=NumCusps ; ++ii ) {

		__DBGpr_int( "found Cusp at", Cusps[ii] );
		__DBGpr_dbl( "next cusp", Cusps[ii+1] );

		SubCrvs[ii] = NULL ;
		BSalloccv( CrvByPolesBSP->order, CrvByPolesBSP->num_poles, //IN
			   CrvByPolesBSP->rational,
			   CrvByPolesBSP->num_boundaries,
			   &SubCrvs[ii], bsrc );		 //OUT

		__CheckBSRC( *bsrc, "bssalloccv", wrapup ) ;
		__CheckPtr( SubCrvs[ii], "subcrv[ii]", wrapup ) ;

		POcvFrmPoles( CrvByPolesBSP, (IGRshort) 1, (Cusps[ii]),
					(Cusps[ii+1]), SubCrvs[ii], bsrc );
		__CheckBSRC( *bsrc , "POcvFrmPoles", wrapup ) ;


	 }	// for Cusps


	  if (NumCusps > 0) {
	  	BSmergarrcv( NumCusps+1, SubCrvs , &MergedCrv, bsrc);
	  	__CheckBSRC( *bsrc, "bsmergarrcv", wrapup ) ;
	  	__CheckPtr ( MergedCrv, "bsmergarrcv ptr", wrapup ) ;
	  }
	  else	MergedCrv = SubCrvs[0];

	  VgCnst->geometry	= (char*)MergedCrv ;
	  OutCurve->osnum	= MdEnv->md_id.osnum ;
	  RetC= om$construct(
                                classname= "GRbcsubbc",
                                osnum    = OutCurve->osnum ,
                                p_objid  = &(OutCurve->objid) ,
			msg	 = message GRgraphics.GRconstruct( VgCnst) ) ;
	  __CheckRC( RetC, *(VgCnst->msg), "construct final crv", wrapup ) ;

	  __DBGpr_obj( "ConGeom constructed curv ", *OutCurve );

 } // else found Cusps


 RetC = OM_S_SUCCESS;

wrapup:

	_FREE( CrvByPolesBSP ) ;
	_FREE( Cusps );

	if ( SubCrvs ) {
	  for ( ii=0; ii<=NumCusps ; ++ii )
		_FREECV( bsrc, SubCrvs[ii]);

	  _FREE( SubCrvs ) ;
	}
	  _FREECV( bsrc ,  MergedCrv ) ;


#ifndef vsDEBUG
	if ( CrvByPoles.objid != NULL_OBJID ) {
	   NumCusps = om$send(msg = message GRgraphics.GRdelete(	&LStat,
								MdEnv ),
			senderid = NULL_OBJID,
			targetid = CrvByPoles.objid,
			targetos = CrvByPoles.osnum );
	    CheckRC( NumCusps, LStat );
	}
#endif

	End
	return ( RetC );

}	// end fn  LineStrToCurve



end implementation GRbcsubbc	;
