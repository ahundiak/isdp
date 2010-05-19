/* $Id: VDReprSrfi.I,v 1.1.1.1 2001/01/04 21:08:53 cvs Exp $ */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdloft/cmd/VDReprSrfi.I
 *
 * Description:  Repairs a surface if poles are closer than a chord height
 *		 tolerance.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDReprSrfi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:08:53  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1998/01/29  20:11:40  pinnacle
# TR_179702387: converted file from Loft to VDS
#
 *
 * History:
 *  MM/DD/YY  AUTHOR  DESCRIPTION
 *  01/23/98  ejm     TR:179702387, converted file from Loft to VDS
 ***************************************************************************/

class implementation VDRepSrfCmd;


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
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "EMSssprops.h"
#include "VDmem.h"


 /********************** start DEBUGGING*********************************

#define vdsDEBUG         1
#define vdserrDEBUG      1

 ********************** end DEBUGGING*********************************/

#include "v_dbgmacros.h"

//c	External Functions 
//c defined in include files 

#include "bsallocsf.h"
#include "vdrepsrf.h"   /* VDScleanupCv */

//c  External Methods 

from GRgraphics import	GRconstruct ;

#define UDIR	0
#define BOTHDONE 2
#define VDIR	1


/* -------------------------------------------------------------------------- */

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

 long   		msg,
			NumberOfBytes,
			BytesReceived;
 long                   VDcnst_msg;
 struct  IGRdisplay     VDact_disp;
 short                  VDact_level;
 struct  GRmd_env       VDmoduleInfo;

 SetProc ( RepairSurf ) ;	Begin



 UCurve.weights = UCurve.knots = UCurve.poles = NULL ;

		//no argument, so leave
 if ( !TheSurf || TheSurf->_objid == NULL_OBJID ) goto wrapup;			

 loc_env	= me->ModuleInfo;

 __DBGpr_obj( "the surf", TheSurf->obj_id );
 lsts = vd_$get_geometry( msg	 = &lmsg,
			grobjId  = &(TheSurf->obj_id),
			grobjEnv = &(TheSurf->mod_env),
			geometry = &SurfGeom ) ;
 __CheckRC( lsts, lmsg, "Surface get geometry", wrapup );


 __DBGpr_int( "surf u_order", SurfGeom->u_order ) ;
 __DBGpr_int( "surf v_order", SurfGeom->v_order ) ;
 __DBGpr_int( "surf u_num_poles", SurfGeom->u_num_poles) ;
 __DBGpr_int( "surf v_num_poles", SurfGeom->v_num_poles ) ;
 __DBGpr_int( "surf num_boundaries ", SurfGeom->num_boundaries ) ;
 __DBGpr_int( "surf rational", SurfGeom->rational ) ;

 MaxPoles = SurfGeom->u_num_poles * SurfGeom->v_num_poles * 3 ;

 __DBGpr_int ( "max poles is ", MaxPoles ) ;

 //for ( Pole=0; Pole<MaxPoles ; Pole+=3 )
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

 NewSurfGeom->u_num_knots = SurfGeom->u_num_knots ;
 for ( i=0; i<SurfGeom->u_num_knots; ++i )
		NewSurfGeom->u_knots[i] =	SurfGeom->u_knots[i] ; 

 NewSurfGeom->v_num_knots = SurfGeom->v_num_knots ;
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

 UCurve.order		= Order ;
 UCurve.num_poles	= NumPoles ;
 UCurve.num_knots	= NumKnots ;
 UCurve.rational  	= SurfGeom->rational;
 UCurve.num_boundaries 	= SurfGeom->num_boundaries;

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
		PoleStart += PoleJump ){

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
    PoleJump 	    = 3 ; // SurfGeom->v_num_poles * 3 ;
    PoleIncr 	    = 3 ;
    Offset   	    = NumPolesInOppDir * 3 ;

    UCurve.order     = SurfGeom->v_order;
    UCurve.num_poles = SurfGeom->v_num_poles;
    UCurve.num_knots = SurfGeom->v_num_knots;

    for ( i=0; i<SurfGeom->v_num_knots; ++i )
	UCurve.knots[i] = SurfGeom->v_knots[i] ;

    __DBGpr_vec( "1st 3 knots", UCurve. knots );
    __DBGpr_vec( "2nd 3 knots", (UCurve. knots)+3 );

 }  // for each direction (DIR) of surface

 if ( !SurfaceChange )  {
	__DBGpr_com( "SURFACE NOT CHANGED IN V" ) ;
	WorkingSurfPtr	= NewSurfGeom ;
	OldSurfPtr	= SurfGeom	;
 }
 else{
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

   status = om$get_classid( p_classid =  &ObjectsClass ,
                               osnum  = TheSurf->_osnum ,
                               objid  = TheSurf->_objid ) ;
   __CheckRC( status, 1, " OMgetclassid Surf", wrapup ) ;

   VDcnst_msg = MSFAIL;

   NumberOfBytes = sizeof( VDmoduleInfo );
   status =
   gr$get_module_env( msg    = &msg,
                      sizbuf = &NumberOfBytes,
                      buffer = &VDmoduleInfo,
                      nret   = &BytesReceived);
   __CheckRC( status, msg, "gr$get_module_env", wrapup ) ;

   ASget_active_symb( &VDact_level, &VDact_disp );

   /* Fill construction list */
   vd_$fill_cnst_list ( Cnst_list  = vg_cnst,
                        Msg        = &VDcnst_msg,
                        Env_info   = &VDmoduleInfo,
                        Level      = VDact_level,
                        Display    = &VDact_disp,
                        Geometry   = (char *) WorkingSurfPtr );

   NewSurfObj.osnum = VDmoduleInfo.md_id.osnum ;


   status = om$construct(	classid = ObjectsClass ,
				osnum   = NewSurfObj.osnum ,
                                p_objid = &NewSurfObj.objid ) ;  

   __DBGpr_obj( "made a surf", NewSurfObj ) ;

#ifdef	vdsDEBUG
        VD_dumpSurface( vg_cnst.geometry );
#endif

   status = om$send(msg = message GRgraphics.GRconstruct( &vg_cnst),
                targetid = NewSurfObj.objid ,
                targetos = NewSurfObj.osnum ) ;
   __CheckRC( status, *(vg_cnst.msg) , "Construct Surf", wrapup ) ;

   status = gr$display_object( object_id = &NewSurfObj ,
                               md_env    = vg_cnst.env_info ,
                               mode      = GRbd ) ;
   __CheckRC( status, 1, "display result", wrapup ) ;

 } /* if ( SurfaceChange || UChange ) */
 else {
   status = om$send(msg = message VDRepSrfCmd.status( "Surface not changed" ),
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
    
}

end implementation VDRepSrfCmd;
