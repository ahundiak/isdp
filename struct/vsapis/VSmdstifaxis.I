/* $Id: VSmdstifaxis.I,v 1.1.1.1 2001/01/04 21:10:10 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vsapis/VSmdstifaxis.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSmdstifaxis.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:10  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/04/20  15:59:50  pinnacle
# CR179800807
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.1  1996/02/20  23:45:14  pinnacle
# Created: ./vsapis/VSmdstifaxis.I by azuurhou for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			ef		creation date
 *	04/17/98  	suresh  	CR179800807 - added orientByCurve 
 *					extPastTrim and extToTrim options
 ***************************************************************************/

class implementation VSbeam ;

#include <stdio.h>
#include <string.h>
#include "madef.h"
#include "exmacros.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asmacros.h"
#include "vsbmaxisdef.h"
#include "vsstfnrdef.h"
#include "vsstfnrdef.h"
#include "vsqryrdbdef.h"
#include "vsRDBmacros.h"
#include "vsdatamacros.h"
#include "vsbeammacros.h"
#include "vsmiscmacros.h"
#include "vsAPImacros.h" // CR 179800807
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */

from VSbeamAxis		import VSputPlateSide ,
                                VSputExtendFlag,
                                VSputByCurve,
                                VSputExtend ;

from VSstfBeam		import VSputPlateSide ;

extern struct GRid	NULL_GRID ;

extern OMuword		OPP_VSstfBeam_class_id ;

/*----------------------------------------------------------------------------*/
long VSmodify_stiffener_axis( long 		*msg,
			      struct GRid	*axisId,
			      struct GRid	*plateId,
			      struct GRmd_env	*plateEnv,
			      struct GRid	*directionId,
			      struct GRmd_env	*directionEnv,
			      struct GRid	*startSurfId,
			      struct GRmd_env	*startSurfEnv,
			      struct GRid	*endSurfId,
			      struct GRmd_env	*endSurfEnv,
			      int		*topOfPlate,
			      int		extPastTrim,
			      int		orientToCurve,
			      int		extToTrim[2] )
{
	/*
	 * This function is interfaced by macro 'vs$modify_stiffener_axis'.
	 */

	long			sts ;
	int			mode,
				cn_type = ND_COMP ;
	struct GRid		parents[4],
				stiffenerId ;
	int			count ;

	SetProc( VSmodify_stiffener_axis ) ; Begin

	__DBGpr_obj( "Stiffener axis to modify", *axisId ) ;
	/*
	 * See if input are valid.
	 */
#ifdef vsDEBUG 
	if( plateId )  printf(" Plate Exists \n");
	if( directionId )  printf(" directionId Exists \n");
	if( startSurfId )  printf(" startSurfId Exists \n");
	if( endSurfId )  printf(" endSurfId Exists \n");
#endif

	if( !plateId 		&& 
	    !directionId 	&& 
	    !startSurfId 	&& 
	    !endSurfId 		&& 
	    !topOfPlate 	)
		vs$inv_arg() ;

	if( (plateId && !plateEnv)		||
	    (directionId && !directionEnv)	)
		vs$inv_arg();

	if( (startSurfId && startSurfId->objid != NULL_OBJID && !startSurfEnv) ||
	    (endSurfId && endSurfId->objid != NULL_OBJID && !endSurfEnv)       )
	    	vs$inv_arg();

	/*
	 * If we change the plate parent or the side of plate, retrieve
	 * stiffener children.
	 */
	if( plateId || topOfPlate ) {
		sts = VSfindChildByType( axisId, OPP_VSstfBeam_class_id, &stiffenerId );

		__CheckRC( sts, 1, "VSfindChildByType", wrapup ) ;

		__DBGpr_obj( "Stiffener of stiffener axis", stiffenerId ) ;
	}

	/*
	 * Modify the side if wanted.
	 */
	if( topOfPlate ) {
		__DBGpr_int( "Chamge side of plate (1:top, 0:bottom)", 
		             *topOfPlate ) ;

		sts = om$send( msg	= message VSbeamAxis.VSputPlateSide( 
			msg,
			*topOfPlate ? VS_K_baOnTopOfPlate : VS_K_baOnBotOfPlate ),
			       senderid = NULL_OBJID,
			       targetid = axisId->objid,
			       targetos = axisId->osnum ) ;

		__CheckRC( sts, *msg, "VSbeamAxis.VSputPlateSide", wrapup ) ;

		sts = om$send( msg	= message VSstfBeam.VSputPlateSide( 
			msg,
			*topOfPlate ? VS_K_stOnTopOfPlate : VS_K_stOnBotOfPlate ),
			       senderid = NULL_OBJID,
			       targetid = stiffenerId.objid,
			       targetos = stiffenerId.osnum ) ;

		__CheckRC( sts, *msg, "VSstfBeam.VSputPlateSide", wrapup ) ;
	}
        // CR179800807
	// printf(" check 1 \n");
	sts = om$send( msg = message VSbeamAxis.VSputExtendFlag( msg,
                                                                extPastTrim ),
                                senderid = NULL_OBJID,
                                targetid = axisId->objid,
                                targetos = axisId->osnum );
	__CheckRC( sts, *msg, "VSbeamAxis.VSputExtendFlag", wrapup ) ;
	// printf(" check 1 \n");

	sts = om$send( msg = message VSbeamAxis.VSputByCurve( msg,
                                                              orientToCurve ),
                                senderid = NULL_OBJID,
                                targetid = axisId->objid,
                                targetos = axisId->osnum );
       __CheckRC( sts, *msg, "VSbeamAxis.VSputByCurve", wrapup ) ;
	// printf(" check 1 \n");
	if( extToTrim ) {
	// printf(" check 2 \n");
		sts = om$send( msg = message VSbeamAxis.VSputExtend( 
						             msg,
                                                             extToTrim[0],
                                                             extToTrim[1] ),
                                senderid = NULL_OBJID,
                                targetid = axisId->objid,
                                targetos = axisId->osnum );
		__CheckRC( sts, *msg, "VSbeamAxis.VSputExtend", wrapup ) ;
       }

	/*
	 * Modify parents if wanted.
	 */
	if( plateId	||
	    directionId	||
	    startSurfId ||
	    endSurfId   ) {
	    	/*
		 * Get actual parents.
		 */
	    	count = 4 ;

	    	sts = om$send( msg	= message NDnode.NDget_objects( ND_ROOT,
									parents,
									count,
									NULL,
									0,
									OM_K_MAXINT,
									&count ),
			       senderid = NULL_OBJID,
			       targetid = axisId->objid,
			       targetos = axisId->osnum ) ;

		__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

		if( count != 2 && count != 4 )
			vs$error();

		/*
		 * Rebuild list of parents with the new wanted.
		 */
		__DBGpr_int( "Count of actual parents",	 	count 		) ;
		__DBGpr_obj( "ACTUAL Plate parent",		parents[0]	) ;
		__DBGpr_obj( "ACTUAL Direction parent",		parents[1]	) ;
#ifdef vsDEBUG
		if( count == 4 ) {
		__DBGpr_obj( "ACTUAL Start surface parent",	parents[2]	) ;
		__DBGpr_obj( "ACTUAL End surface parent",	parents[3]	) ;
		}
#endif

		if( plateId )
			parents[0] = *plateId;

		if( directionId ) {
			sts = as$make_source( go_grid	= *directionId,
					      mod_env	= directionEnv,
					      as_grid   = parents +1 );

			__CheckRC( sts, 1, "as$make_source", wrapup ) ;
		}

		if( startSurfId && startSurfId->objid != NULL_OBJID ) {
			sts = as$make_source( go_grid	= *startSurfId,
					      mod_env	= startSurfEnv,
					      as_grid   = parents +2 );

			__CheckRC( sts, 1, "as$make_source", wrapup ) ;
		}

		if( endSurfId && endSurfId->objid != NULL_OBJID ) {
			sts = as$make_source( go_grid	= *endSurfId,
					      mod_env	= endSurfEnv,
					      as_grid   = parents +3 );

			__CheckRC( sts, 1, "as$make_source", wrapup ) ;
		}

		if( startSurfId && endSurfId )
			count = 4;

		if( startSurfId && startSurfId->objid == NULL_OBJID &&
		    endSurfId && endSurfId->objid == NULL_OBJID     )
		    	count = 2;

		__DBGpr_int( "Count of new parents",	 	count 		) ;
		__DBGpr_obj( "NEW Plate parent",		parents[0]	) ;
		__DBGpr_obj( "NEW Direction parent",		parents[1]	) ;
#ifdef vsDEBUG
		if( count == 4 ) {
		__DBGpr_obj( "NEW Start surface parent",	parents[2]	) ;
		__DBGpr_obj( "NEW End surface parent",		parents[3]	) ;
		}
#endif

		/*
		 * Disconnect all parents and connect new parents.
		 */
		sts = om$send( msg	= message NDnode.NDdisconnect( 0,
								       NULL ),
			       senderid = NULL_OBJID,
			       targetid = axisId->objid,
			       targetos = axisId->osnum ) ;

		__CheckRC( sts, 1, "NDnode.NDdisconnect", wrapup ) ;

		sts = om$send( msg	= message NDnode.NDconnect( count,
								    parents,
								    NULL_GRID,
								    ND_FULL ),
			       senderid = NULL_OBJID,
			       targetid = axisId->objid,
			       targetos = axisId->osnum ) ;

		__CheckRC( sts, 1, "NDnode.NDconnect", wrapup ) ;
	}

	/*
	 * If the parent plate was changed, we must also change the parent plate of
	 * the stiffener which is on this stiffener axis.
	 */
	if( plateId ) {
		count = 1;

	    	sts = om$send( msg	= message NDnode.NDget_objects( ND_ROOT,
									parents,
									count,
									NULL,
									0,
									0,
									&count ),
			       senderid = NULL_OBJID,
			       targetid = stiffenerId.objid,
			       targetos = stiffenerId.osnum ) ;

		__CheckRC( sts, 1, "NDnode.NDget_objects", wrapup ) ;

		__DBGpr_obj( "Actual parent plate of stiffener", parents[0] ) ;
		__DBGpr_obj( "New parent plate of stiffener",	 *plateId   ) ;

		sts = om$send( msg	= message NDnode.NDchange_connect( 1,
									   &parents[0],
									   plateId ),
			       senderid = NULL_OBJID,
			       targetid = stiffenerId.objid,
			       targetos = stiffenerId.osnum ) ;

		__CheckRC( sts, 1, "NDnode.NDchange_connect", wrapup ) ;
	}


	/*
	 * Recompute stiffener axis.
	 */
	nd$wait_batch(	type		= GR_GEOM_POSTED,
			l_object	= axisId,
			l_obj_info	= &cn_type,
			nb_obj		= 1 ) ;

	nd$mod_batch( request	 = ND_GET,
		      p_ret_mode = &mode ) ;

	if( mode != ND_DEFER ) nd$exec_batch() ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		End
		return sts ;

} /* VSmodify_stiffener_axis */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
