/* $Id: VSpxretnfoot.I,v 1.1.1.1 2001/01/04 21:10:55 cvs Exp $  */

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
 *	$Log: VSpxretnfoot.I,v $
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
#include <string.h>
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "nddef.h"
#include "EMSutlmacros.h"
#include "vsattr.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsnameproto.h"
#include "vsvirtualinf.h"

extern char		DIR_G_car_dir ;

from VSbeam	import VSfaceNameToIndex ;
/*----------------------------------------------------------------------------*/
method ACreturn_foot(	long		*rc ;
			char		*footName ;
			struct GRid	*footId ;
			short		*mxType ;
			IGRmatrix	mx ) {

	long		msg,		/* Completion code		*/
			sts ;		/* OM return code		*/
	GRname		crvName,	/* Name of foot curve		*/
			cmpName ;	/* Logical name of component	*/
	struct GRid	compcv,		/* Foot composite curve		*/
			parent ;	/* My parent			*/
	int		count,		/* Count of parents		*/
			index ;		/* Of curve on composite	*/
	VSdspRep	myRep ;		/* My display rep.		*/

	SetProc( VSprjCrsSctn_ACreturn_foot ) ; Begin ; __DBGpr_me() ;

	__DBGpr_str( "Want foot", footName ) ;

	footId->objid = NULL_OBJID ;

	/*
	 * Try as is... if does not contain ':', since if it does
	 * ACncpx.ACreturn_foot will think it's nested stuff and will split
	 * the path, then trying to send an ACreturn_foot message to
	 * a GRcompcurve ...
	 */
	if( strchr( footName, DIR_G_car_dir ) == NULL ) {
		sts = om$send(	msg	= message ACncpx.ACreturn_foot(
					rc, footName, footId, mxType, mx ),
				targetid= my_id,
				mode	= OM_e_wrt_message ) ;

		if( ( sts & 1 ) && *rc ) goto wrapup ;
	}

	/*
	 * Else must be a logical name for a component curve of my composite
	 * curve foot.
	 */
	di$split(	pathname	= footName,
			dirname		= crvName,
			name		= cmpName ) ;
	__DBGpr_str( "Component name", cmpName ) ;

	/*
	 * Get foot.
	 */
	sts = om$send(	msg	= message ACncpx.ACreturn_foot(
					rc, crvName, &compcv, mxType, mx ),
			targetid= my_id ) ;
	if( !( sts & 1 ) || !*rc ) goto wrapup ;

	sts = om$send(	msg	= message NDnode.NDget_objects(	ND_ROOT,
								&parent,
								1,
								NULL,
								0,
								0,
								&count ),
			targetid= my_id ) ;
	if( !( sts & 1 ) ) { *rc = FALSE ; goto wrapup ; }
	__DBGpr_obj( "Parent beam", parent ) ;

	if( count ) {
		struct GRid	beam ;

		/*
		 * Parent may be a pretend, get virtual beam parent.
		 */
		sts = VSgetVirtualInfo( &msg, &parent, NULL, &beam ) ;
		if( !( sts & 1 & msg ) ) { *rc = FALSE ; goto wrapup ; }

		/* ----------------------------------------------
		 * TR179801135 It would help if we asked the beam for the rep
		 * Unlike the give_path code, myRep was being used to map
		 * just did not have the right rep
		 *
		 * Latest requirment is to have myRep be independent of the beam rep
		 * so back to asking myself for a rep and using it
		 */
		sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &myRep ),
				//		targetid= beam.objid,
				//		targetos= beam.osnum ) ;
				targetid= my_id ) ;

		if ( (myRep & AC_ENV_REP) || (myRep & AC_2D_REP ) ) {
			sts = om$send( msg = message VSbeam.VSfaceNameToIndex(
						&msg,AC_3D_REP,cmpName, &index),
					targetid= beam.objid,
					targetos= beam.osnum ) ;
		} else {
	
			sts = om$send( msg = message VSbeam.VSfaceNameToIndex(
                                                &msg, myRep, cmpName, &index ),
                                        targetid= beam.objid,
                                        targetos= beam.osnum ) ;
		}
		if( !( sts & 1 & msg ) ) { *rc = FALSE ; goto wrapup ; }
	} else {
		/*
		 * No parent: I have probably been moved to root. Maybe the
		 * component name was generated after I have been moved to
		 * root in which case its name is in the form "$<n>".
		 */
		if( !VSreadGenericName( cmpName, &index ) ) {
			*rc = FALSE ; goto wrapup ;
		}
	}

	/*
	 * Now get id from index.
	 */
	{ OM_S_CHANSELECT toCmps ;
	  ems$make_chanselect( chan_label    = GRcmpowner_to_components,
	  		       chan_selector = &toCmps ) ;

	  sts = om$get_objid_at_index(	osnum		= compcv.osnum,
					objid		= compcv.objid,
					p_chanselect	= &toCmps,
					index		= index,
					objidaddr	= &footId->objid,
					osnumaddr	= &footId->osnum ) ;
	  if( !( sts & 1 ) ) { *rc = FALSE ; goto wrapup ; }
	}

	__DBGpr_obj( "Foot found", *footId ) ;

	wrapup :
		__DBGpr_int( "rc", *rc ) ;
		End
		/*
		 * Must return OM_S_SUCCESS !
		 */
		return OM_S_SUCCESS ;
	
} /* method ACreturn_foot */
/*----------------------------------------------------------------------------*/
 
end implementation VSprjCrsSctn ;
