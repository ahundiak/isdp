/* $Id: VSpxgivepath.I,v 1.1.1.1 2001/01/04 21:10:55 cvs Exp $  */

/*************************************************************************
 * I/STRUCT
 *
 * File:	vsprofile / VSpxgivepath.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSpxgivepath.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:55  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1998/06/24  15:49:50  pinnacle
# tr179801135
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/24/98  ah      TR179801135 Mapping mismatch for non-3D_REP reps
 *
 *************************************************************************/

class implementation VSprjCrsSctn ;

/*
#define vsDEBUG
*/
#include "DImacros.h"
#include "nddef.h"
#include "EMSutlmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsnameproto.h"
#include "vsvirtualinf.h"

from VSbeam import VSfaceIndexToName ;
/*----------------------------------------------------------------------------*/
method ACgive_path(	int		*succ ;
			struct GRid	*footId ;
			char		*footName ; ) {

	long			msg,		/* Completion code	*/
				sts ;		/* OM return code	*/
	struct GRid		compcv,		/* Foot composite curve	*/
				parent ;	/* My parent		*/
	int			count,		/* Count of parents	*/
				index ;		/* Of curve on composite*/
	GRname			cmpName ;	/* Name of component	*/
	VSdspRep		myRep ;		/* My display rep.	*/

	SetProc( VSprjCrsSctn_ACgive_path ) ; Begin ; __DBGpr_me() ;

	__DBGpr_obj( "Foot id", *footId ) ;

	/*
	 * Check if it is not a simple foot.
	 */
	sts = om$send(	msg	= message ACncpx.ACgive_path(
						succ, footId, footName ),
			targetid= my_id,
			mode	= OM_e_wrt_message ) ;
	__DBGpr_int( "Give-path", *succ ) ;

	if( ( sts & 1 ) && *succ ) goto wrapup ;

	/*
	 * Get composite curve foot.
	 */
	sts = om$send(	msg	= message NDmacro.ACreturn_foot(
						&msg, VS_K_pxPrjCurve,
						&compcv, NULL, NULL ),
			targetid= my_id ) ;
	if( !msg ) { *succ = FALSE ; goto wrapup ; }

	__DBGpr_obj( "Id of composite curve", compcv ) ;

	/*
	 * See if input object is a component of curve.
	 */
	{ OM_S_CHANSELECT toCmps ;
	  ems$make_chanselect( chan_label    = GRcmpowner_to_components,
	  		       chan_selector = &toCmps ) ;

	  sts = om$get_index(	osnum_c		= compcv.osnum,
				objid_c		= compcv.objid,
				p_chanselect	= &toCmps,
				objid		= footId->objid,
				osnum2		= footId->osnum,
				indexaddr	= (OMuint *) &index ) ;
	  if( !( sts & 1 ) ) { *succ = FALSE ; goto wrapup ; }
	}

	__DBGpr_int( "Index of input component", index ) ;

	/*
	 * Then it may be a component of my foot which is a composite
	 * curve. Get parent beam and ask it for its profile, then
	 * ask profile to translate.
	 */
	sts = om$send(	msg	= message NDnode.NDget_objects(	ND_ROOT,
								&parent,
								1,
								NULL,
								0,
								0,
								&count ),
			targetid= my_id ) ;
	if( !( sts & 1 ) ) { *succ = FALSE ; goto wrapup ; }

	__DBGpr_obj( "Parent beam", parent ) ;

	if( count ) {
		struct GRid	beam ;

		/*
		 * Parent may be a pretend, get virtual beam parent.
		 */
		sts = VSgetVirtualInfo( &msg, &parent, NULL, &beam ) ;
		if( !( sts & 1 & msg ) ) { *succ = FALSE ; goto wrapup ; }

		__DBGpr_obj( "Real parent beam", beam ) ;
	
		/* ----------------------------------------------
		 * TR179801135 It would help if we asked the beam for the rep
		 * and if once we found it, we used it
		 *
		 * Back to using myRep since the rep can be independent of
		 * the beam rep for profiles
		 */
		sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &myRep ),
				//		targetid= beam.objid,
				//		targetos= beam.osnum ) ;
				targetid= my_id ) ;

   		if ( (myRep & AC_ENV_REP) || (myRep & AC_2D_REP ) ) {

			sts = om$send(	msg = message VSbeam.VSfaceIndexToName(
						&msg, AC_3D_REP,index, cmpName),
					targetid= beam.objid,
					targetos= beam.osnum ) ;
		} else { 
			sts = om$send(  msg = message VSbeam.VSfaceIndexToName(
		        //                      &msg, AC_3D_REP,index, cmpName),
                                                &msg, myRep,    index, cmpName),
			  targetid= beam.objid,
			  targetos= beam.osnum ) ;
		}
		if( !( sts & 1 & msg ) ) { *succ = FALSE ;goto wrapup ; }
		
		__DBGpr_str( "Face name", cmpName ) ;
	} else {
		/*
		 * No parent: I have probably been moved to root.
		 * Make up a name.
		 */
		VSgenCmpName( index, cmpName ) ;
	}

	/*
	 * Now create a path-name.
	 */
	DIstmcpy( footName, VS_K_pxPrjCurve, cmpName, NULL ) ;
	__DBGpr_str( "Foot path", footName ) ;

	*succ	= TRUE ;
	sts	= OM_S_SUCCESS ;

	wrapup:
		End
		return sts ;
	
} /* method ACgive_path */
/*----------------------------------------------------------------------------*/
 
end implementation VSprjCrsSctn ;
