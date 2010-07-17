/* $Id: VSbmmassprop.I,v 1.2 2002/05/07 16:51:30 ramarao Exp $  */
/***************************************************************************
* I/STRUCT
*
* File: vsbeam/VSbmmassprop.I        
*
* Description:
* 	Mass property calculations for beams
*
* Dependencies:
*
* Revision History:
*      $Log: VSbmmassprop.I,v $
*      Revision 1.2  2002/05/07 16:51:30  ramarao
*      Fixed incorrect beam length problem.
*
*      Revision 1.1.1.1  2001/01/04 21:10:12  cvs
*      Initial import to CVS
*
# Revision 1.4  2000/03/02  18:34:12  pinnacle
# Added VSgetBeamSolidGraphics() function.
#
# Revision 1.3  2000/02/01  16:14:26  pinnacle
# (No comment)
#
*
* History:
*      MM/DD/YY    AUTHOR    DESCRIPTION
*      11/15/99    bkeesara  fix for TR179900460
*      01/24/2000  Jayadev   changes for TR179901004
*      03/02/00    RamaRao   Added VSgetBeamSolidGraphics() function.
***************************************************************************/

class implementation VSbeam ;
#include "bserr.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "EMSmsgdef.h"
#include "vsbeamdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsgeommacros.h"
#include "vsmeasmacros.h"
#include "vsdbgmacros.h"
#include "vsdpbmacros.h"
#include "vsRDBmacros.h"
/*
 * Includes of function prototypes.
 */
#include "bscveval.h"
#include "vsRDBproto.h"

extern void		VSmulSupportMx __((	struct GRmd_env*,
						int,
						struct GRobj_env* )) ;
extern long		VSgetSolidBeamLength	__((	long*,
							struct GRid*,
							struct GRmd_env*,
							IGRvector,
							double* )) ;

from GRcurve	import	GRtotlength ;

static IGRlong 	VSgetBeamSolidGraphics(	long            	*msg,
					struct GRobj_env 	*beam, 
					struct GRid		*solidBeam  )
{
	IGRint			chgRep = FALSE;
	IGRlong			sts;
	struct GRid 		segment ;   /* Beam segment         */
	VSdspRep		beamRep ;   /* Beam Representation  */

	sts = om$send(  msg      = message ACncpx.ACget_NV_rep( &beamRep ),
			senderid = NULL_OBJID,
			targetid = beam->_objid,
			targetos = beam->_osnum		);
	__CheckRC( sts, *msg, "ACncpx.ACget_NV_rep", wrapup ) ;

    	if( !(beamRep & VS_m_3dWFillet) ) {
              	sts = om$send(  msg     = message ACncpx.ACset_NV_rep(
                            			VS_m_3dWFillet,
                            			&beam->mod_env ),
			senderid = NULL_OBJID,
                        targetid = beam->_objid,
                        targetos = beam->_osnum         );
        	nd$exec_batch() ;
        	chgRep = TRUE ;
    	}

    	sts = om$send(  msg     = message NDmacro.ACreturn_foot(
                                                        msg,
                                                        VS_K_bmGrCmpName,
                            				&segment ,
                                                        NULL, NULL ),
			senderid = NULL_OBJID,
                        targetid = beam->_objid,
                        targetos = beam->_osnum         );
      	*msg = *msg ? MSSUCC : MSFAIL ;
    	__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

    	solidBeam->osnum = segment.osnum ;
    	sts = om$send(  msg     = message GRgraphics.GRcopy(
                                                        msg,
                                                        &beam->mod_env,
                                                        &beam->mod_env,
                                                        &solidBeam->objid ),
				senderid = NULL_OBJID,
                                targetid = segment.objid,
                                targetos = segment.osnum ) ;
    	__CheckRC( sts, *msg, "GRgraphics.GRcopy", wrapup ) ;

    	if( chgRep ) {
        	sts = om$send(  msg     = message ACncpx.ACset_NV_rep(
                        				beamRep ,
                        				&beam->mod_env ),
			senderid = NULL_OBJID,
                        targetid = beam->_objid,
                        targetos = beam->_osnum         );
        	nd$exec_batch() ;
    	}

wrapup:
	return sts;
}

/*----------------------------------------------------------------------------*/
method VSgetMassProperties(	long		*msg ;
				struct GRmd_env *myEnv ;
				VSintegral	*mp ) {

	long		sts ;		/* OM return code		*/
/*	int		toggle ;	 Mass props. toggle		*/
	struct GRid	segment ;	/* My solid segment		*/
	VSdspRep	myRep ; 	/* My display representation	*/
	double		density ;	/* Density of beam's material	*/
	VSpartAttr	attr ;		/* To get material+grade	*/
	char            errString[128];
	/*
	 * Zero out unused dimensions (height and width).
	 */
         /*TR179900460 Segment.objid is initialized to nullobjid */
	segment.objid = NULL_OBJID;
	mp->dims[1] = mp->dims[2] = 0 ;

	/*
	 * Force exact computation of mass properties if compute-toggle is ON.
	 */
/*
	* Commented for CR 179528562
	  Keeping the code in case if we want to revert it one day

	vs$get_massp_toggle(	msg	= msg,
				p_toggle= &toggle ) ;
	if( toggle ) {
*/
		/*
		 * Precise (and slow) computation of the mass properties (if
		 * I am in 3d ).
		 * What kind of display am I in ?
		 */
		sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &myRep ),
				targetid= my_id ) ;
		__CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;
/*	} else { */
		/*
		 * We'll have a fast approximated computation of the mass
		 * properties.
		 */
/*		myRep = AC_2D_REP ;
	} */

	attr.Iwant = VS_m_MatType | VS_m_MatGrade ;
	sts = om$send(	msg	= message GRvg.GRgetattr( msg, (char *) &attr ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "GRvg.GRgetattr", wrapup ) ;

	/*
	 * The following call will fail if user has not logged into PDM, if so
	 * set density to 1.
	 */
	vs$extract_density_from_RDB(	msg	= msg,
					errStr  = errString,
					material= attr.info.material,
					grade	= attr.info.grade,
					density = &density ) ;
	if( !( *msg & 1 ) ) density = 1 ; 

	/*
	 * Commented for CR 179600634
	 */
/*
	switch( myRep & ~AC_SUB_REP ) 

	struct GRid	moi ;

	default 		: 
	case AC_2D_REP		:
		moi.objid = my_id ;
		moi.osnum = OM_Gw_current_OS ;

		sts = VS2dBeamMassProps( msg, &moi, myEnv, mp ) ;
		mp->mass = density * mp->volume ;
		break ;

	case AC_3D_REP		:
	case AC_ENV_REP 	:
		sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							VS_K_bmGrCmpName,
							&segment,
							NULL, NULL ),
				targetid= my_id ) ;
		*msg = *msg ? MSSUCC : MSFAIL ;
		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;
*/
	/*
	 * Get the solid beam in filleted/Detailed representation for
	 * tha actual calculations of the beam mass properties
	 */
	 __DBGpr_com("VSgetSolidBeam for VSbeam called");
	sts = om$send( msg =    message VSbeam.VSgetSolidBeam (
	                                        msg,
	                                        myEnv,
	                                        &segment ),
	                targetid = my_id );
	if( segment.objid == NULL_OBJID || !(sts&1&(*msg)) )
	{
	   struct GRobj_env	beam;

	   __DBGpr_com("VSgetSolidBeam FAILED, now VSgetBeamSolidGraphics");	
	   beam._objid  = my_id;
	   beam._osnum  = OM_Gw_current_OS;
	   beam.mod_env = *myEnv;
	   sts = VSgetBeamSolidGraphics( msg, &beam, &segment );
	   __CheckRC( sts, *msg, "VSgetBeamSolidGraphics", wrapup ) ;
	}
	__DBGpr_obj(" Beam Solid graphics ID ", segment );
        /* TR179900460 Check for segment.objid to null_objid
     	   if null got to wrapup */
	if(segment.objid == NULL_OBJID){
	    __DBGpr_com("Cannot calculate mass property for this beam");
	    goto wrapup;
	}

	vs$get_mass_props(	msg	= msg,
				surfEnv = myEnv,
				surfId	= &segment,
				density = density,
				area	= &mp->area,
				centroid= mp->centroid,
				volume	= &mp->volume,
				mass	= &mp->mass,
				moment	= mp->MofI.array ) ;
	__CheckRC( sts, *msg, "vs$get_mass_props", wrapup ) ;

        sts = om$send( msg      = message GRgraphics.GRdelete (
                                                        msg,
                                                        myEnv ),
                        targetid = segment.objid,
                        targetos = segment.osnum );


	/*
	 * Compute beam length.
	 */
	sts = om$send(	msg	= message VSbeam.VSgetBeamLength(
					msg, myEnv, &mp->dims[0] ),
			targetid= my_id ) ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
	return sts ;

} /* method VSgetMassProperties */
/*----------------------------------------------------------------------------*/
method VSgetBeamLength( long *msg ; struct GRmd_env *myEnv ; double *length ) {

	long		 sts ;		/* OM return code.		*/
	struct GRobj_env axis  ;	/* My support axis.		*/
	VSdspRep	 myRep ; 	/* My display representation.	*/

	struct IGRbsp_curve	*axGeom ;

	axGeom = NULL ;

	/*
	 * Get my display representation.
	 */
	sts = om$send( msg	= message ACncpx.ACget_NV_rep( &myRep ),
		       targetid = my_id ) ;
	__CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;

	/*
	 * Get my support axis.
	 */
	sts = om$send( msg	= message VSbeam.VSgetSupportAxis(
							msg, myEnv, &axis ),
		       targetid = my_id ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetSupportAxis", wrapup ) ;

	VSmulSupportMx( myEnv, 1, &axis ) ;

        sts = om$send( msg      = message GRcurve.GRtotlength(
                                          msg,
                                          &axis._matrix_type,
                                          axis._matrix,
                                          length ),
                       targetid = axis._objid,
                       targetos = axis._osnum ) ;
        __CheckRC( sts, *msg, "GRcurve.GRtotlength", wrapup ) ;

	/*
	 * Commented the following code, since it is returning incorrect
	 * lengths is many cases. - RamaRao 05/07/02
	 */

#if 0

	/*
	 * If I am in 2d representation, my length is the one of my support
	 * axis. Otherwise, my length is the one of my solid.
	 */
	switch( myRep & ~AC_SUB_REP ) {

	double			tanAt05[6] ;
	struct GRid		mySolid ;

	case AC_3D_REP		:
	case AC_ENV_REP 	:
		/*
		 * Get tangent of my axis at 0.5
		 */
		sts = vs$get_geometry( msg	= msg,
				       grobjId	= &axis._grid,
				       grobjEnv = &axis.mod_env,
				       geometry = &axGeom ) ;
		__CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

		BScveval( axGeom, 0.5, 1, (IGRpoint *) tanAt05, msg ) ;


		if( BSERROR( *msg ) ) vs$error( msgval = EMS_E_BSerror ) ;

		/*
		 * Get my solid.
		 */
		sts = om$send( msg	= message NDmacro.ACreturn_foot(
							       msg,
							       VS_K_bmGrCmpName,
							       &mySolid,
							       NULL,
							       NULL ),
			       targetid = my_id ) ;
		__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup ) ;

		/*
		 * Compute length of my solid.
		 */
		sts = VSgetSolidBeamLength(	msg,
						&mySolid,
						myEnv,
						tanAt05 + 3,
						length ) ;
		__CheckRC( sts, *msg, "VSgetSolidBeamLength", wrapup ) ;

		if( (*length) > 0.0 ) break ;

        default                 : /* Unknown rep, use AC_2D_REP */
        case AC_2D_REP          :
                sts = om$send( msg      = message GRcurve.GRtotlength(
                                                       msg,
                                                       &axis._matrix_type,
                                                       axis._matrix,
                                                       length ),
                               targetid = axis._objid,
                               targetos = axis._osnum ) ;
                __CheckRC( sts, *msg, "GRcurve.GRtotlength", wrapup ) ;

                break ;
	}
#endif

	wrapup :
		_FREE( axGeom ) ;
		if( !( sts & 1 & *msg ) ) {
			*length = 0 ;
			*msg	= MSSUCC ;
		}
		return OM_S_SUCCESS ;

} /* method VSgetBeamLength */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
