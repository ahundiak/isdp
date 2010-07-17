class implementation VLRepSrfCmd;



#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include <stdio.h>
#include "EMSstruct.h"
#include "bserr.h"
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "grmacros.h"
#include "growner.h"
#include "ndmacros.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "EMSssprops.h"
#include "vlstructure.h"


 /********************** start DEBUGGING*********************************

#define vsDEBUG         1
#define vserrDEBUG      1

 ********************** end DEBUGGING*********************************/

#include "vldbgmacros.h"
#include "vldbgmacros.h"

//c	External Functions 
//c defined in include files 

#include "bsallocsf.h"
#include "bsalloccv.h"
#include "vlSrfRep.h"

//c  External Methods 

from GRgraphics import	GRconstruct ;
from GRvg 	import	GRpostabsg ;

#define UDIR	0
#define BOTHDONE 2
#define VDIR	1

method RepairSurface( struct GRobj_env * TheSurf )
{

  int		status = OM_E_INVARG, // message return codes
		i	 = 0,
		Dir	 = 0,
		MaxPoles = 0 ,
		PoleIncr = 0 ,
		PoleJump = 0 ,
		PoleStart= 0 ,
		Pole	   = 0 ;

 IGRshort	Order = 0 ;

 GRclassid	ObjectsClass ;

 struct GRid		NewSurfObj ;

 struct IGRbsp_surface  * NewSurfGeom		= NULL ,
			* SurfGeom		= NULL ,
			* WorkingSurfPtr	= NULL ,
			* OldSurfPtr		= NULL ;

 struct IGRbsp_curve	UCurve;

 struct GRmd_env	loc_env;

 struct GRvg_construct  vg_cnst;

 IGRlong		lmsg,	  // require int return, long for method!
			lsts ,
			Offset   = 0 ,
			NumKnots = 0 ,
			NumPoles = 0 ,
			NumPolesInOppDir = 0 ;

  IGRboolean		modifNeeded	= FALSE , 
			curveHasOverlaps= FALSE ,
			SurfaceChange   = FALSE ,
			UChange		= FALSE ;

 BSrc			bsrc ;

 SetProc ( RepairSurf ) ;	Begin

 UCurve.weights = UCurve.knots = UCurve.poles = NULL ;

		//no argument, so leave
 if ( !TheSurf || TheSurf->_objid == NULL_OBJID ) goto wrapup;			

 loc_env	= me->ModuleInfo;

 __DBGpr_obj( "the surf", TheSurf->obj_id );
 lsts = vs$get_geometry( msg	= &lmsg,
			grobjId = &(TheSurf->obj_id),
			grobjEnv= &(TheSurf->mod_env),
			geometry= &SurfGeom ) ;
 __CheckRC( lsts, lmsg, "Surface get geometry", wrapup );


 __DBGpr_int( "surf u_order", SurfGeom->u_order ) ;
 __DBGpr_int( "surf v_order", SurfGeom->v_order ) ;
 __DBGpr_int( "surf u_num_poles", SurfGeom->u_num_poles) ;
 __DBGpr_int( "surf v_num_poles", SurfGeom->v_num_poles ) ;
 __DBGpr_int( "surf num_boundaries ", SurfGeom->num_boundaries ) ;
 __DBGpr_int( "surf rational", SurfGeom->rational ) ;

 MaxPoles = SurfGeom->u_num_poles * SurfGeom->v_num_poles * 3 ;

 __DBGpr_int ( "max poles is ", MaxPoles ) ;

// for ( Pole=0; Pole<MaxPoles ; Pole+=3 )
//	__DBGpr_vec( "pole", (SurfGeom->poles)+Pole ) ;


 BSallocsf( SurfGeom->u_order,
	    SurfGeom->v_order,
	    SurfGeom->u_num_poles,
	    SurfGeom->v_num_poles,
	    SurfGeom->rational,
	    SurfGeom->num_boundaries,
	    &NewSurfGeom,
	    &bsrc );

 __CheckBSRC( bsrc, "BSallocsf", wrapup ) ;
 __CheckPtr( NewSurfGeom, "alloc new surf", wrapup ) ;

 __DBGpr_int( "surf u_num_knots", SurfGeom->u_num_knots) ;
 __DBGpr_int( "surf v_num_knots", SurfGeom->v_num_knots ) ;
 __DBGpr_int( "NewSurf num u knots", NewSurfGeom->u_num_knots ) ;
 __DBGpr_int( "NewSurf num v knots", NewSurfGeom->v_num_knots ) ;


 for ( i=0; i<SurfGeom->u_num_knots; ++i )
		NewSurfGeom->u_knots[i] =	SurfGeom->u_knots[i] ; 

 for ( i=0; i<SurfGeom->v_num_knots; ++i )
		NewSurfGeom->v_knots[i] =	SurfGeom->v_knots[i] ; 

		// say which is the original and which will be the new surface
 WorkingSurfPtr	= NewSurfGeom	;
 OldSurfPtr	= SurfGeom	;
		
 if ( SurfGeom->u_num_poles >= SurfGeom->v_num_poles ) {
	Order	= SurfGeom->u_order;
	NumPoles= SurfGeom->u_num_poles;
	NumKnots= SurfGeom->u_num_knots;
 }
 else {
	Order	= SurfGeom->v_order;
	NumPoles= SurfGeom->v_num_poles;
	NumKnots= SurfGeom->v_num_knots;
 }

 UCurve.order	= Order ;
 UCurve.num_poles= NumPoles ;
 UCurve.num_knots= NumKnots ;
 UCurve.rational  = SurfGeom->rational;
 UCurve.num_boundaries = SurfGeom->num_boundaries;

 __DBGpr_int( "UC num knots", UCurve. num_knots ) ;
 __DBGpr_int( "UC num poles", UCurve. num_poles ) ;
 __DBGpr_int( "UC order", UCurve. order ) ;

 UCurve.poles	= _MALLOC( (NumPoles*3) , IGRdouble ) ;

 if ( UCurve.rational )
		UCurve.weights  = _MALLOC( (NumPoles*3),IGRdouble );

 UCurve.knots	= _MALLOC( NumKnots, IGRdouble ) ;

		// start with u direction 

 for ( i=0; i<SurfGeom->u_num_knots; ++i )

	UCurve. knots[i] = SurfGeom->u_knots[i] ;

   __DBGpr_vec( "1st 3 knots", UCurve. knots );
   __DBGpr_vec( "2nd 3 knots", (UCurve. knots)+3 );



 MaxPoles = SurfGeom->u_num_poles * 3; //SurfGeom->v_num_poles * 3;

 __DBGpr_int ( "max poles is ", MaxPoles ) ;

 PoleJump = SurfGeom->u_num_poles * 3 ;	// no of doubles in u block

 NumPolesInOppDir = SurfGeom->v_num_poles ;  // no poles in opp direction

 PoleIncr = 3 ;

	// loop on pole manipulation for each direction of the surface
	// 1st pass = udir, 2nd = vdir

 for ( Dir = UDIR ;   Dir < BOTHDONE ;   Dir += VDIR ) {


	// start at begining of surf and work thru no of poles in this dir
    for ( PoleStart=0; PoleStart<  (PoleJump*NumPolesInOppDir) ; 
		PoleStart += PoleJump ) {

    __DBGpr_int( "PoleStart", PoleStart);	// index of 1st pole
    __DBGpr_int( "PoleJump ", PoleJump );	// no 
    __DBGpr_int( "PoleIncr ", PoleIncr );
    __DBGpr_int( "PoleOffset", Offset);

	// set curve equal to current list of poles in this direction
	// ie make an iso curve

    for ( i=0,Pole=PoleStart; Pole<(PoleStart+PoleJump+Offset) ; 
	  Pole+=((PoleIncr>Offset)?PoleIncr:Offset),++i ) {

	UCurve. poles[i]	= OldSurfPtr->poles[Pole] ;
	UCurve. poles[++i]	= OldSurfPtr->poles[Pole+1] ;
	UCurve. poles[++i]	= OldSurfPtr->poles[Pole+2] ;

	__DBGpr_vec( "upole", (UCurve. poles)+(i-2) ) ;

    }

	// call JLL's dirty work

    modifNeeded = TRUE ;
     VDScleanupCv( &UCurve, modifNeeded, &curveHasOverlaps, &lmsg ) ;
     __CheckRC( 1, lmsg, "cleanup curve", wrapup ) ;

    __DBGpr_int( "curveHasOverlaps", curveHasOverlaps ) ;
    __DBGpr_int( "modifNeeded", modifNeeded ) ;

	// if there was a need to change the surface note it

    SurfaceChange = ( curveHasOverlaps ) ? curveHasOverlaps : SurfaceChange ;

    curveHasOverlaps = FALSE ;

    __DBGpr_int( "SurfaceChange   ", SurfaceChange    ) ;

	// set the poles on the new surface 

    for ( i=0,Pole=PoleStart; 
		Pole<(PoleJump+PoleStart) ;
			Pole+=(PoleIncr+Offset) ,++i ) {

	WorkingSurfPtr->poles[Pole]   =	UCurve. poles[i]	; 
	WorkingSurfPtr->poles[Pole+1] =	UCurve. poles[++i]	; 
	WorkingSurfPtr->poles[Pole+2] =	UCurve. poles[++i]	; 
    }


   }	// for the poles in this direction

   if ( SurfaceChange && !Dir )  {
	__DBGpr_com( "SURFACE CHANGED IN U" ) ;
	WorkingSurfPtr 	  = SurfGeom	;
	OldSurfPtr	  = NewSurfGeom ;
	SurfaceChange 	  = FALSE ;
	UChange		  = TRUE ;
   }
   else if ( !SurfaceChange && !Dir )  
	__DBGpr_com( "SURFACE NOT CHANGED IN U" ) ;

   NumPolesInOppDir = SurfGeom->u_num_poles ;
   PoleJump = 3; // SurfGeom->v_num_poles * 3 ;
   PoleIncr = 3 ;
   Offset   = NumPolesInOppDir * 3 ;

   UCurve.order  = SurfGeom->v_order;
   UCurve.num_poles= SurfGeom->v_num_poles;
   UCurve.num_knots= SurfGeom->v_num_knots;

   for ( i=0; i<SurfGeom->v_num_knots; ++i )

	UCurve. knots[i] = SurfGeom->v_knots[i] ;

     __DBGpr_vec( "1st 3 knots", UCurve. knots );
     __DBGpr_vec( "2nd 3 knots", (UCurve. knots)+3 );

 }  // for each direction of surface



 if ( !SurfaceChange )  {
	__DBGpr_com( "SURFACE NOT CHANGED IN V" ) ;
	WorkingSurfPtr	= NewSurfGeom ;
	OldSurfPtr	= SurfGeom	;
 }
 else if ( SurfaceChange )  {
	__DBGpr_com( "SURFACE CHANGED IN V" ) ;
 }

 __DBGpr_int( "surf u_order", WorkingSurfPtr->u_order ) ;
 __DBGpr_int( "surf v_order", WorkingSurfPtr->v_order ) ;
 __DBGpr_int( "surf u_num_poles", WorkingSurfPtr->u_num_poles) ;
 __DBGpr_int( "surf v_num_poles", WorkingSurfPtr->v_num_poles ) ;
 __DBGpr_int( "surf u_num_knots", WorkingSurfPtr->u_num_knots) ;
 __DBGpr_int( "surf v_num_knots", WorkingSurfPtr->v_num_knots ) ;
 __DBGpr_int( "surf num_boundaries ", WorkingSurfPtr->num_boundaries ) ;
 __DBGpr_int( "surf rational", WorkingSurfPtr->rational ) ;

 //  for ( Pole=0; Pole<(MaxPoles*SurfGeom->v_num_poles) ; Pole+=3 ){
 // 	__DBGpr_vec( "Work pole", (WorkingSurfPtr->poles)+Pole ) ;
 //	__DBGpr_vec( "Old pole", (OldSurfPtr->poles)+Pole ) ;}

 __DBGpr_int( "SurfaceChange   ", SurfaceChange    ) ;


		// only build a new surface if it's been changed

 if ( SurfaceChange || UChange ) {


   status = om$get_classid(   p_classid =  &ObjectsClass ,
                                osnum  = TheSurf->_osnum ,
                                objid  = TheSurf->_objid ) ;
   __CheckRC( status, 1, " OMgetclassid Surf", wrapup ) ;

   VLinitCnst( &vg_cnst );

   NewSurfObj.osnum = vg_cnst.env_info->_MD_OS ;
   vg_cnst.level	= me->NewLevel ;
   vg_cnst.geometry = (char *) WorkingSurfPtr ;
   *(vg_cnst.msg)	= MSFAIL ;

   status = om$construct(	classid = ObjectsClass ,
				osnum   = NewSurfObj.osnum ,
                                p_objid = &NewSurfObj.objid ) ;  

   __DBGpr_obj( "made a surf", NewSurfObj ) ;

   status = om$send(msg = message GRgraphics.GRconstruct( &vg_cnst),
                targetid = NewSurfObj.objid ,
                targetos = NewSurfObj.osnum ) ;

   __CheckRC( status, *(vg_cnst.msg) , "Construct Surf", wrapup ) ;

   status = gr$display_object(        object_id = &NewSurfObj ,
                                        md_env    = vg_cnst.env_info ,
                                        mode      = GRbd )              ;
   __CheckRC( status, 1, "display result", wrapup ) ;

 }
 else {
   status = om$send(msg = message VLRepSrfCmd.status( "Surface not changed" ),
                targetid = my_id ) ;
 }

 status = OM_S_SUCCESS;


wrapup:			////////////// cleanup GOTO

	_FREE( SurfGeom ) ;
	_FREE( UCurve.poles ) ;
	_FREE( UCurve.knots ) ;
	_FREE( UCurve.weights ) ;
	_FREESF( &bsrc, NewSurfGeom ) ;


	End
	return status ;
    
}	// end repair surface

end implementation VLRepSrfCmd;
