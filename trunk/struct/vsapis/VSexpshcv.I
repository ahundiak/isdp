/* $Id: VSexpshcv.I,v 1.1.1.1 2001/01/04 21:10:08 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vsapis/VSexpshcv.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSexpshcv.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:08  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.1  1996/02/20  23:44:46  pinnacle
# Created: ./vsapis/VSexpshcv.I by azuurhou for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			ef		creation date
 *
 ***************************************************************************/

class implementation VSexpandedCv ;

#include <stdio.h>
#include "OMmacros.h"
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
#include "vsgetchildrn.h"
#include "vsvirtualinf.h"

from VSmergeShExp	import VSget_all_original_shell_exp,
			       VSget_shell_exp_parents ;

extern OMuword 		OPP_VSmergeShExp_class_id ;

/*----------------------------------------------------------------------------*/
static long VSgetMergedShExpChildren( msg, shellExp, mergedSh, withShExp )

long			*msg ;
struct GRobj_env	*shellExp,
			*mergedSh,
			*withShExp ; {

	/*
	 * This function returns the merged shell expansion 'mergedSh'
	 * generated with the given shell expansion 'shellExp'. It also
	 * returns the other shell expansion 'withShExp' used.
	 */

	long		sts ;

	mergedSh->_objid = withShExp->_objid = NULL_OBJID ;

	/*
	 * Find merged shell expansion children.
	 */
	sts = VSfindChildByType( &shellExp->_grid,
				 OPP_VSmergeShExp_class_id,
				 &mergedSh->_grid ) ;

	__CheckRC( sts, 1, "VSfindChildByType", wrapup ) ;

	/*
	 * Get shell expansion parents of the merged shell expansion.
	 */
	if( !IF_NULL_OBJID( mergedSh->_objid ) ) {
		struct GRobj_env	frShell,
					toShell ;

		sts = VSgetVirtualInfo( msg,
					&mergedSh->_grid,
					&mergedSh->mod_env,
					&mergedSh->_grid ) ;

		__CheckRC( sts, *msg, "VSgetVirtualInfo", wrapup ) ;

		sts = om$send( msg	=
				   message VSmergeShExp.VSget_shell_exp_parents(
							     msg,
							     &mergedSh->mod_env,
							     &frShell,
							     &toShell ),
			       senderid = NULL_OBJID,
			       targetid = mergedSh->_objid,
			       targetos = mergedSh->_osnum ) ;

		__CheckRC( sts, *msg, "VSmergeShExp.VSget_shell_exp_parents",
			   wrapup ) ;

		if( IF_EQ_GRID( shellExp->_grid, frShell._grid ) )
			*withShExp = toShell ;
		else
		if( IF_EQ_GRID( shellExp->_grid, toShell._grid ) )
			*withShExp = frShell ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		return sts ;

} /* VSgetMergedShExpChildren */
/*----------------------------------------------------------------------------*/
static int VSisObjectOnList( object, list, size, index )

struct GRobj_env	*object,
			list[] ;
int			size,
			*index ; {

	int	i ;

	*index = -1 ;

	for( i=0; i<size; i++ )
		if( IF_EQ_GRID( object->_grid, list[i]._grid ) ) {
			*index = i ;
			return TRUE ;
		}

	return FALSE ;

} /* VSisObjectOnList */
/*----------------------------------------------------------------------------*/
static long VSconstructMerge( msg,
			      cst,
			      xCurvId )

long 			*msg ; 
struct GRvg_construct 	*cst ;
struct GRid		*xCurvId ; {

	long			sts ;
	int			i,
				j,
				nbShellExp = 0,
				index1	   = 0,
				index2	   = 0 ;
	struct GRobj_env	mergeShExp,
				curve,
				*shellExp   = NULL,
				*expandedCv = NULL,
				parents[3],
				merShExpChild,
				withShExp ;
	struct VScnst_list	*attr ;

	SetProc( VSconstructMerge ) ; Begin

	attr = (struct VScnst_list *) cst->class_attr ;

	mergeShExp = attr->parent_list[0] ;
	curve	   = attr->parent_list[1] ;

	__DBGpr_obj( "Merged shell expansion", mergeShExp._grid ) ;

	/*
	 * Get all original shell expansions of the merged shell
	 * expansion.
	 */
	sts = om$send( msg	=
			      message VSmergeShExp.VSget_all_original_shell_exp(
							    msg,
							    &mergeShExp.mod_env,
							    &nbShellExp,
							    &shellExp ),
		       senderid = NULL_OBJID,
		       targetid = mergeShExp._objid,
		       targetos = mergeShExp._osnum ) ;

	__CheckRC( sts, *msg, "VSmergeShExp.VSget_all_original_shell_exp",
		   wrapup ) ;

	__DBGpr_int( "Count of original shell expansions", nbShellExp ) ;

	if( !( expandedCv = _MALLOC( nbShellExp, struct GRobj_env ) ) )
		vs$mem_fail() ;

	/*
	 * Construct an expanded curve on each original shell expansions.
	 */
	attr->parent_count = 2 ;
	attr->parent_list  = parents ;

	parents[1] = curve ;

	for( i=0; i<nbShellExp; i++ ) {
		parents[0] = shellExp[i] ;

		__DBGpr_obj( "Construct expanded curve with original shell exp",
			     shellExp[i]._grid ) ;

		expandedCv[i]._osnum = cst->env_info->md_id.osnum ;

		sts = om$construct( classname = "VSexpandedCv",
				    osnum     = expandedCv[i]._osnum,
				    p_objid   = &expandedCv[i]._objid,
				    msg       = message GRgraphics.GRconstruct( cst ) ) ;

		__CheckRC( sts, *msg, "GRgraphics.GRconstruct", wrapup ) ;

		if( sts & 1 & *msg ) {
			expandedCv[i].mod_env = *cst->env_info ;

			__DBGpr_obj( "Constructed expanded curve",
				     expandedCv[i]._grid ) ;
		} else {
			vs$bulk_delete( grids  = &expandedCv[i]._grid,
					theEnv = cst->env_info ) ;

			__DBGpr_com( "Expanded curve NOT constructed" ) ;
		}
	}

	/*
	 * Merge the above expanded curves two by two.
	 */
	attr->parent_list = parents ;

	do {
		for( i=0; i<nbShellExp; i++ ) {
			sts = VSgetMergedShExpChildren( msg,
							shellExp +i,
							&merShExpChild,
							&withShExp ) ;

			__CheckRC( sts, *msg, "VSgetMergedShExpChildren",
				   wrapup ) ;

			if( IF_NULL_OBJID( merShExpChild._objid ) ) continue ;

			if( VSisObjectOnList( &withShExp, shellExp, nbShellExp,
					      &index2 ) ) {
				index1 = i ;
				break ;
			}
		}

#ifdef vsDEBUG
		__DBGpr_com( "Merge expanded curve(s)" ) ;
		if( !IF_NULL_OBJID( expandedCv[index1]._objid ) )
			__DBGpr_obj( "\t", expandedCv[index1]._grid ) ;
		if( !IF_NULL_OBJID( expandedCv[index2]._objid ) )
			__DBGpr_obj( "\t", expandedCv[index2]._grid ) ;
#endif

		parents[0] = merShExpChild ;

		if( !IF_NULL_OBJID( expandedCv[index1]._objid ) &&
		    !IF_NULL_OBJID( expandedCv[index2]._objid ) ) {

			attr->parent_count = 3 ;

			parents[1] = expandedCv[index1] ;
			parents[2] = expandedCv[index2] ;

		} else {
			attr->parent_count = 2 ;

			if( !IF_NULL_OBJID( expandedCv[index1]._objid ) )
				parents[1] = expandedCv[index1] ;
			else
			if( !IF_NULL_OBJID( expandedCv[index2]._objid ) )
				parents[1] = expandedCv[index2] ;
			else
			attr->parent_count = 0 ;
		}

		if( attr->parent_count ) {

			xCurvId->osnum = cst->env_info->md_id.osnum ;

			sts = om$construct( classname = "VSmergeExpCv",
					    osnum     = xCurvId->osnum,
					    p_objid   = &xCurvId->objid,
					    msg       = message GRgraphics.GRconstruct( cst ) ) ;

			if( !( sts & 1 & *msg ) )
				vs$bulk_delete( grids  = xCurvId,
						theEnv = cst->env_info ) ;

			__CheckRC( sts, *msg, "GRgraphics.GRconstruct", wrapup ) ;

			__DBGpr_obj( "Constructed merged expanded curve",
				     *xCurvId ) ;

		} else {
			xCurvId->objid = NULL_OBJID ;

			__DBGpr_com( "Merged expanded curve NOT constructed" ) ;
		}

		for( i=0, j=0; i<nbShellExp; i++ ) {
			if( i == index1 || i == index2 ) continue ;

			shellExp[j]   = shellExp[i] ;
			expandedCv[j] = expandedCv[i] ;

			j++ ;
		}

		shellExp[j]	      = merShExpChild ;
		expandedCv[j]._grid   = *xCurvId ;
		expandedCv[j].mod_env = *cst->env_info ;

		nbShellExp = j + 1 ;

	} while( nbShellExp != 1 ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		_FREE( shellExp   ) ;
		_FREE( expandedCv ) ;

		End
		return sts ;

} /* VSconstructMerge */
/*----------------------------------------------------------------------------*/
long VSexpand_shell_curve( msg,
			   xPlanId,
			   sCurvId,
			   sCurvEnv,
			   xCurvId )

long			*msg ;
struct GRid		*xPlanId ;
struct GRid		*sCurvId ;
struct GRmd_env 	*sCurvEnv ;
struct GRid		*xCurvId ; {

	/*
	 * This function is interfaced by macro 'vs$expand_shell_curve'.
	 */

	long			sts ;
	int			isAMergedSh ;
	struct GRobj_env	parents[2] ;
	struct GRmd_env 	curEnv ;
	struct GRvg_construct	cst ;
	struct VScnst_list	attr ;

	SetProc( VSexpand_shell_curve ) ; Begin

	xCurvId->objid = NULL_OBJID ;

	__DBGpr_obj( "Shell expansion", *xPlanId ) ;
	__DBGpr_obj( "Curve to expand", *sCurvId ) ;

	/*
	 * Get current module environnement.
	 */
	sts = ex$get_cur_mod( osnum = &curEnv._MD_OS,
			      id    = &curEnv._MD_ID ) ;

	__CheckRC( sts, 1, "ex$get_cur_mod", wrapup ) ;

	curEnv._MATRIX_TYPE = MAIDMX ;
	MAidmx( msg, curEnv._MATRIX ) ;

	/*
	 * Fill construction list ( Display and Level come from first parent ).
	 */
	vs$fill_cnst_list( Cnst_list	= cst,
			   Msg		= msg,
			   Env_info	= &curEnv,
			   Display	= NULL,
			   Level	= 0,
			   Class_attr	= &attr ) ;

	attr.feature_att    = NULL ;
	attr.representation = AC_NO_REP ;
	attr.parent_count   = 2 ;
	attr.parent_list    = parents ;

	/*
	 * Expand curve.
	 */
	parents[0]._grid   = *xPlanId ;
	parents[0].mod_env = curEnv ;

	parents[1]._grid   = *sCurvId ;
	parents[1].mod_env = sCurvEnv ? *sCurvEnv : curEnv ;

	isAMergedSh = vs$is_ancestry_valid(
					 object  = &parents[0]._grid,
					 classid = OPP_VSmergeShExp_class_id ) ;

	if( isAMergedSh ) {
		__DBGpr_com( "It's a merged shell expansion" ) ;

		sts = VSconstructMerge( msg, &cst, xCurvId ) ;

		__CheckRC( sts, *msg, "VSconstructMerge", wrapup ) ;
	} else {
		__DBGpr_com( "Not a merged shell expansion" ) ;

		xCurvId->osnum = curEnv.md_id.osnum ;

		sts = om$construct( classname = "VSexpandedCv",
				    osnum     = xCurvId->osnum,
				    p_objid   = &xCurvId->objid,
				    msg       = message GRgraphics.GRconstruct( &cst ) ) ;

		__CheckRC( sts, *msg, "GRgraphics.GRconstruct", wrapup ) ;
	}

	__DBGpr_obj( "Constructed expanded curve", *xCurvId ) ;

	/*
	 * Display expanded curve.
	 */
	vs$bulk_display( grids	= xCurvId,
			 theEnv = &curEnv ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			if( xCurvId->objid != NULL_OBJID )
				vs$bulk_delete( grids  = xCurvId,
						theEnv = &curEnv ) ;
		}

		End
		return sts ;

} /* VSexpand_shell_curve */
/*----------------------------------------------------------------------------*/

end implementation VSexpandedCv ;
