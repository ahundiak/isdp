
/* $Id: VScrshellexp.I,v 1.1.1.1 2001/01/04 21:10:08 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vsapis/VScrshellexp.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VScrshellexp.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:08  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.1  1996/02/20  23:44:42  pinnacle
# Created: ./vsapis/VScrshellexp.I by azuurhou for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			ef		creation date
 *
 ***************************************************************************/

class implementation VSshellExp ;

#include <stdio.h>
#include "madef.h"
#include "exmacros.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "VDSsymb_def.h"
#include "vscmdmacros.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "maidmx.h"

/*----------------------------------------------------------------------------*/
long VScreate_shell_expansion( msg,
			       shellId,
		               shellEnv,
	                       rPlanId,
                               rPlanEnv,       
                               sPlanId,
			       sPlanEnv,
			       ePlanId,
			       ePlanEnv,
			       xPlanId )

long			*msg ;
struct GRid		*shellId ;
struct GRmd_env 	*shellEnv ;
struct GRid		*rPlanId ;
struct GRmd_env 	*rPlanEnv ;
struct GRid		*sPlanId ;
struct GRmd_env 	*sPlanEnv ;
struct GRid		*ePlanId ;
struct GRmd_env 	*ePlanEnv ;
struct GRid		*xPlanId ; {

	/*
	 * This function is interfaced by macro 'vs$create_shell_expansion'.
	 */

	long			sts ;
	struct GRobj_env	parents[3] ;
	struct GRmd_env 	curEnv ;
	struct GRvg_construct	cst ;
	struct VScnst_list	attr ;
	struct VDSsymb		symb ;
	short			level ;
	struct IGRdisplay	display ;

	SetProc( VScreate_shell_expansion ) ; Begin

	xPlanId->objid = NULL_OBJID ;

	__DBGpr_obj( "Shell", *shellId ) ;

#ifdef vsDEBUG
	if( rPlanId ) 
		__DBGpr_obj( "Reference plane", *rPlanId ) ;
	else
		__DBGpr_com( "NO reference plane" ) ;
	if( sPlanId ) 
		__DBGpr_obj( "Start plane", 	*sPlanId ) ;
	else
		__DBGpr_com( "NO start plane" 	  ) ;
	if( ePlanId ) 
		__DBGpr_obj( "End plane", 	*ePlanId ) ;
	else
		__DBGpr_com( "NO end plane" 	  ) ;
#endif

	/*
	 * See if we have sPlane and ePlane.
	 */
	if( sPlanId )
		if( !ePlanId ) vs$inv_arg() ;

 	if( ePlanId )
		if( !sPlanId ) vs$inv_arg() ;

	/*
	 * Get current module environnement.
	 */
	sts = ex$get_cur_mod( osnum = &curEnv._MD_OS,
			      id    = &curEnv._MD_ID ) ;

	__CheckRC( sts, 1, "ex$get_cur_mod", wrapup ) ;

	curEnv._MATRIX_TYPE = MAIDMX ;
	MAidmx( msg, curEnv._MATRIX ) ;

	/*
	 * Retrieve current symbology.
	 */
	sts = vs$cnstDefaults( msg	= msg,
			       symb_id	= curEnv.md_id,
			       symb	= &symb,
			       level	= &level,
			       display	= &display ) ;

	/*
	 * Fill construction list.
	 */
	vs$fill_cnst_list( Cnst_list	= cst,
			   Msg		= msg,
			   Env_info	= &curEnv,
			   Display	= &display,
			   Level	= level,
			   Class_attr	= &attr ) ;

	attr.parent_list  = parents ;
	attr.parent_count = 1 ;

	parents[0]._grid   = *shellId ;
	parents[0].mod_env = shellEnv ? *shellEnv : curEnv ;

	if( rPlanId ) {
		parents[1]._grid   = *rPlanId ;
		parents[1].mod_env = rPlanEnv ? *rPlanEnv : curEnv ;

		attr.parent_count++ ;
	}

	if( sPlanId ) {
		parents[attr.parent_count]._grid   = *sPlanId ;
		parents[attr.parent_count].mod_env = sPlanEnv ? *sPlanEnv : curEnv ;

		attr.parent_count++ ;

		parents[attr.parent_count]._grid   = *ePlanId ;
		parents[attr.parent_count].mod_env = ePlanEnv ? *ePlanEnv : curEnv ;

		attr.parent_count++ ;
	}
		
	attr.representation = AC_NO_REP ;
	attr.feature_att    = NULL ;

	/*
	 * Construct shell expansion.
	 */
	xPlanId->osnum = curEnv.md_id.osnum ;

	sts = om$construct( classname = "VSshellExp",
			    osnum     = xPlanId->osnum,
			    p_objid   = &xPlanId->objid,
			    msg       = message GRgraphics.GRconstruct( &cst ) ) ;

	__CheckRC( sts, *msg, "GRgraphics.GRconstruct", wrapup ) ;

	__DBGpr_obj( "Created shell expansion", *xPlanId ) ;

	/*
	 * Display shell expansion.
	 */
	vs$bulk_display( grids	= xPlanId,
			 theEnv = &curEnv ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			if( xPlanId->objid != NULL_OBJID )
				vs$bulk_delete( grids  = xPlanId,
						theEnv = &curEnv ) ;
		}

		End
		return sts ;

} /* VScreate_shell_expansion */
/*----------------------------------------------------------------------------*/

end implementation VSshellExp ;
