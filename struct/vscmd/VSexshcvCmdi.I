/* $Id: VSexshcvCmdi.I,v 1.1.1.1 2001/01/04 21:10:23 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vscmd/VSexshcvCmdi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSexshcvCmdi.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:23  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/10/07  14:07:02  pinnacle
# EMSmacros.h to emsmacros.h
#
 *
 * History:
 *      MM/DD/YY  AUTHOR  DESCRIPTIO
 *      09/26/97  ah      added header
 *      09/30/97  ah      TR179701791 Don't allocate 0 bytes
 *	10/07/97  ah	  EMSmacros.h renamed to emsmacros.h
 *
 ***************************************************************************/

class implementation VSexshcvCmd ;

#include <stdio.h>
#include "OMmacros.h"

/*
#include "EMSmacros.h"
*/
#include "emsmacros.h"

#include "acrepdef.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "growner.h"
#include "vsdef.h"
#include "vs.h"
#include "vscmddef.h"
#include "vscmdmacros.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes of function prototypes.
 */
#include "vsgetchildrn.h"
#include "vsvirtualinf.h"

from VSmergeShExp	import VSget_all_original_shell_exp,
			       VSget_shell_exp_parents ;

extern OMuword OPP_VSmergeShExp_class_id ;

/*----------------------------------------------------------------------------*/
long VSgetMergedShExpChildren( msg, shellExp, mergedSh, withShExp )

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
method operation( long *msg ) {

	long			sts ;
	int			i,
				isAMergedSh ;
	struct GRobj_env	parents[2],
				*locObj = NULL ;
	struct GRvg_construct	cst ;
	struct VScnst_list	attr ;

	/*
	 * Get located objects.
	 */
	if( !( locObj = _MALLOC( me->oprtrCount + 1, struct GRobj_env ) ) )
		vs$mem_fail() ;

	sts = om$send( msg	= message VSlocateCmd.getLocObjs(
							     msg,
							     me->oprtrCount + 1,
							     locObj ),
		       targetid = my_id ) ;
	__CheckRC( sts, *msg, "VSlocateCmd.getLocObjs", wrapup ) ;

	/*
	 * Fill construction list ( Display and Level come from first parent ).
	 */
	vs$fill_cnst_list( Cnst_list	= cst,
			   Msg		= msg,
			   Env_info	= &me->cstEnv,
			   Display	= NULL,
			   Level	= 0,
			   Class_attr	= &attr ) ;

	attr.feature_att    = NULL ;
	attr.representation = AC_NO_REP ;

	/*
	 * Expand curve(s).
	 */
	parents[0] = locObj[0] ;

	isAMergedSh = vs$is_ancestry_valid(
					 object  = &parents[0]._grid,
					 classid = OPP_VSmergeShExp_class_id ) ;

	for( i=0; i<me->oprtrCount; i++ ) {
		parents[1] = locObj[i+1] ;

		attr.parent_count = 2 ;
		attr.parent_list  = parents ;

		if( isAMergedSh ) {
			om$send( msg	  = message VSexshcvCmd.construct_merge(
									 msg,
									 &cst ),
				 targetid = my_id ) ;
		} else {
			strcpy( me->const_class, "VSexpandedCv" ) ;
			om$send( msg	  = message VSpartopCmd.construct(
									 msg,
									 &cst ),
				 targetid = my_id ) ;
		}
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		*msg = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;
		_FREE( locObj ) ;

		return sts ;

} /* method operation */
/*----------------------------------------------------------------------------*/
method construct_merge( long *msg ; struct GRvg_construct *cst ) {

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

	SetProc( VSexshcvCmd_construct_merge ) ; Begin

	attr = (struct VScnst_list *) cst->class_attr ;

	mergeShExp = attr->parent_list[0] ;
	curve	   = attr->parent_list[1] ;

	__DBGpr_obj( "Merged shell expansion located", mergeShExp._grid ) ;
	__DBGpr_obj( "Curve located",		       curve._grid	) ;

	/*
	 * Get all original shell expansions of the located merged shell
	 * expansion.
	 */
	sts = om$send( msg	=
			      message VSmergeShExp.VSget_all_original_shell_exp(
							    msg,
							    &mergeShExp.mod_env,
							    &nbShellExp,
							    &shellExp ),
		       targetid = mergeShExp._objid,
		       targetos = mergeShExp._osnum ) ;

	__CheckRC( sts, *msg, "VSmergeShExp.VSget_all_original_shell_exp",
		   wrapup ) ;

	__DBGpr_int( "Count of original shell expansions", nbShellExp ) ;

	if( !( expandedCv = _MALLOC( nbShellExp + 1, struct GRobj_env ) ) )
		vs$mem_fail() ;

	/*
	 * Construct an expanded curve on each original shell expansions.
	 */
	strcpy( me->const_class, "VSexpandedCv" ) ;

	attr->parent_count = 2 ;
	attr->parent_list  = parents ;

	parents[1] = curve ;

	for( i=0; i<nbShellExp; i++ ) {
		parents[0] = shellExp[i] ;

		__DBGpr_obj( "Construct expanded curve with original shell exp",
			     shellExp[i]._grid ) ;

		sts = om$send( msg	= message VSpartopCmd.construct( msg,
									 cst ),
			       targetid = my_id ) ;

		if( sts & 1 & *msg ) {
			expandedCv[i]._grid   = me->constructedObject ;
			expandedCv[i].mod_env = me->cstEnv ;

			__DBGpr_obj( "Constructed expanded curve",
				     expandedCv[i]._grid ) ;
		} else {
			expandedCv[i]._objid = NULL_OBJID ;

			__DBGpr_com( "Expanded curve NOT constructed" ) ;
		}
	}

	/*
	 * Merge the above expanded curves two by two.
	 */
	strcpy( me->const_class, "VSmergeExpCv" ) ;

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
			sts = om$send( msg	=
					   message VSpartopCmd.construct( msg,
									  cst ),
				       targetid = my_id ) ;

			__CheckRC( sts, *msg, "VSpartopCmd.construct", wrapup );

			__DBGpr_obj( "Constructed merged expanded curve",
				     me->constructedObject ) ;

		} else {
			me->constructedObject.objid = NULL_OBJID ;

			__DBGpr_com( "Merged expanded curve NOT constructed" ) ;
		}

		for( i=0, j=0; i<nbShellExp; i++ ) {
			if( i == index1 || i == index2 ) continue ;

			shellExp[j]   = shellExp[i] ;
			expandedCv[j] = expandedCv[i] ;

			j++ ;
		}

		shellExp[j]	      = merShExpChild ;
		expandedCv[j]._grid   = me->constructedObject ;
		expandedCv[j].mod_env = me->cstEnv ;

		nbShellExp = j + 1 ;

	} while( nbShellExp != 1 ) ;

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		*msg = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;

		_FREE( shellExp   ) ;
		_FREE( expandedCv ) ;

		End
		return sts ;

} /* method construct_merge */
/*----------------------------------------------------------------------------*/

end implementation VSexshcvCmd ;
