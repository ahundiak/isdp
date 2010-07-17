/* $Id: VSplstifaxis.I,v 1.1.1.1 2001/01/04 21:10:10 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vsapis/VSplstifaxis.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSplstifaxis.I,v $
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
# Revision 1.2  1996/05/16  19:56:48  pinnacle
# Replaced: vsapis/VSplstifaxis.I for:  by svkadamb for struct
#
# Revision 1.1  1996/02/20  23:45:44  pinnacle
# Created: ./vsapis/VSplstifaxis.I by azuurhou for struct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 *           ef	     Creation date
 * 02/28/98  ah      CR179800807 Added beam axis internal options
 *    "      ah      Copied pototype from vsAPImacros.h
 * 04/17/98  suresh  CR179800807 - added orientByCurve and extToTrim options
 ***************************************************************************/

class implementation VSbeam ;

#include <stdio.h>
#include <string.h>
#include "nddef.h"
#include "madef.h"
#include "exmacros.h"
#include "ACcheckin.h"
#include "msdef.h"
#include "VDSsymb_def.h"
#include "vsdpb.h"
#include "vsstfnr.h"
#include "vsbeam.h"
#include "vsbmaxisdef.h"
#include "vsstfnrdef.h"
#include "vsplatedef.h"
#include "vsRDBmacros.h"
#include "vscmdmacros.h"
#include "vsbeammacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "vsAPImacros.h" // CR179800807

/*
 * Includes of function prototypes.
 */
#include "maidmx.h"

from VSbeamAxis import VSputByCurve ;

/*----------------------------------------------------------------------------*/
long VSplace_stiffener_axis(	long			*msg,
				struct GRid		inputId[4],
				struct GRmd_env 	inputEnv[4],
				int			transtable,
				struct IGRdisplay	*display,
				short			level,
				int			topOfPlate,
				int			orientToCurve,
				int			extToTrim[2],
				struct GRid		*axisId )
{

	/*
	 * This function is interfaced by macro vs$place_stiffener_axis().
	 */

	long			sts ;
	struct GRmd_env 	curEnv ;
	struct GRvg_construct	cstargs ;
	struct VScnst_list	vsargs ;
	struct GRobj_env	parents[4] ;
	char			loc_directory[DI_PATH_MAX] ;
	short			loc_level ;
	struct IGRdisplay	loc_display ;
	struct VDSsymb		symb ;
	int			plateSide ;
	OMbyte			flagAttr ;

	SetProc( VSplace_stiffener_axis ) ; Begin

	axisId->objid = NULL_OBJID ;
	flagAttr = 0;

	/*
	 * Get current module environnement.
	 */
	sts = ex$get_cur_mod( osnum = &curEnv._MD_OS,
			      id    = &curEnv._MD_ID ) ;

	__CheckRC( sts, 1, "ex$get_cur_mod", wrapup ) ;

	curEnv._MATRIX_TYPE = MAIDMX ;
	MAidmx( msg, curEnv._MATRIX ) ;
	/*
	 * If we want to use the transTable, retrieve informations to construct the
	 * stiffener axis.
	 */
	if( transtable ) {
		sts = vs$getBmOrPlCstDefaults( msg	   = msg,
					       symb_id	   = curEnv.md_id,
					       symb	   = &symb,
					       memberClass = 0,
					       matchKey    = "stiffener",
					       matchId	   = inputId +0,
					       path	   = loc_directory,
					       level	   = &loc_level,
					       display	   = &loc_display ) ;

		__CheckRC( sts, *msg, "vs$getBmOrPlCstDefaults", wrapup ) ;

	} else {
		loc_level   = level ;
		loc_display = *display ;
	}

	/*
	 * Fill construction list.
	 */
	vs$fill_cnst_list( Env_info	= &curEnv,
			   Display	= &loc_display,
			   Level	= loc_level,
			   Name 	= '\0',
			   Class_attr	= &vsargs,
			   Cnst_list	= cstargs,
			   Msg		= msg ) ;

	vsargs.representation = AC_NO_REP ;

	/* Special Features Bits */
	if( topOfPlate )
		plateSide = VS_K_baOnTopOfPlate ;
	else
		plateSide = VS_K_baOnBotOfPlate ;

	// vsargs.feature_att = (char *) &plateSide ;
	flagAttr |= plateSide ;

	// CR179800807

	if (orientToCurve) { 
		flagAttr |= VS_K_baByCurve ;
	}

	if (extToTrim) {
		if( extToTrim[0] ) flagAttr |=  VS_K_baExtend0 ;
		if( extToTrim[1] ) flagAttr |=  VS_K_baExtend1 ;
	}

	vsargs.feature_att = (char *) &flagAttr ;
	
	/*
	 * Add parents to construction list.
	 */
	vsargs.parent_count	= 2 ;
	vsargs.parent_list	= parents ;

	parents[0]._grid	= inputId[0] ;
	parents[0].mod_env	= inputEnv[0] ;

	parents[1]._grid	= inputId[1] ;
	parents[1].mod_env	= inputEnv[1] ;

	if( inputId[2].objid != NULL_OBJID	&&
	    inputId[3].objid != NULL_OBJID	) {
		vsargs.parent_count	= 4 ;

		parents[2]._grid	= inputId[2] ;
		parents[2].mod_env	= inputEnv[2] ;

		parents[3]._grid	= inputId[3] ;
		parents[3].mod_env	= inputEnv[3] ;
	}

	__DBGpr_int( "Count of parents",	vsargs.parent_count ) ;
	__DBGpr_obj( "Parent #0 (plate)",	parents[0]._grid    ) ;
	__DBGpr_obj( "Parent #1 (direction)",	parents[1]._grid    ) ;
#ifdef vsDEBUG
	if( vsargs.parent_count == 4 ) {
	__DBGpr_obj( "Parent #2 (start surf)",	parents[2]._grid    ) ;
	__DBGpr_obj( "Parent #3 (end surf)",	parents[3]._grid    ) ;
	}
#endif

	/*
	 * Construct axis.
	 */
	axisId->osnum = curEnv._MD_OS ;

	sts = om$construct( classname = "VSbeamAxis",
			    osnum     = axisId->osnum,
			    p_objid   = &axisId->objid,
			    msg       =
				  message GRgraphics.GRconstruct( &cstargs ) ) ;
	__CheckRC( sts, *msg, "om$construct", wrapup ) ;

	__DBGpr_obj( "Constructed axis", *axisId ) ;

	/*
	 * Change state of axis, so if stiffener was deleted, the axis will be
	 * deleted when session ends.
	 */
	sts = om$send( msg	= message NDnode.NDchg_state( ND_DEL_NO_CH,
							      ND_DEL_NO_CH ),
		       senderid = NULL_OBJID,
		       targetid = axisId->objid,
		       targetos = axisId->osnum ) ;

	__CheckRC( sts, 1, "NDnode.NDchg_state", wrapup ) ;

	/*
	 * Display stiffener axis.
	 */
	vs$bulk_display( grids	= axisId,
			 theEnv = &curEnv ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) && axisId->objid != NULL_OBJID )
			vs$bulk_delete( grids  = axisId,
					theEnv = &curEnv ) ;
		End
		return sts ;
} /* VSplace_stiffener_axis */
/*----------------------------------------------------------------------------*/
end implementation VSbeam ;
