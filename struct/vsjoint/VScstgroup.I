/* $Id: VScstgroup.I,v 1.1.1.1 2001/01/04 21:10:43 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VScstgroup.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VScstgroup.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/01/06  22:14:24  pinnacle
# Placement Problems
#
 *
 * History:
 *  MM/DD/YY  AUTHOR  DESCRIPTION
 *  01/06/98  ah      Added header, prototypes
 ***************************************************************************/

/*
	I/STRUCT
*/
class implementation ACdiowner ;

#include "EMSutlmacros.h"
#include "vsjointdef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsbldrootcpx.h"
#include "vsgetchanobj.h"
#include "vsjntproto.h"

extern OMuword	OPP_ACdiowner_class_id ;
/*----------------------------------------------------------------------------*/
long VSconstructGroup( msg, cst, count, list, group )

long			*msg ;
struct GRvg_construct	*cst ;
int			count ;
struct GRid		list[],
			*group ; {

#define MAX	30

	long		sts ;
	int		i ;
	char		buffer[MAX][10],
			*names[30] ;
	struct GRid	cmps[MAX] ;

	__DBGpr_objlist( "Group member", count, list ) ;

	group->objid	= NULL_OBJID ;
	group->osnum	= cst->env_info->_MD_OS ;

	VSsetGRids( group->osnum, MAX, cmps ) ;

	for( i = 0 ; i < MAX ; i++ ) {
		sprintf( buffer[i], "jn%d", i ) ;
		names[i] = buffer[i] ;
	}
	if( count >= MAX ) count = MAX ;

	for( i = 0 ; i < count ; i++ ) {
		cmps[i] = list[i] ;
	}
	sts = VSbuildRootComplex(	msg,
					VS_K_jnJointGroup,
					MAX,
					cmps,
					names,
					cst->env_info,
					group->osnum,
					&group->objid ) ;
	__CheckRC( sts, *msg, "VSbuildRootComplex", wrapup ) ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			vs$bulk_delete(	grids	= group,
					theEnv	= cst->env_info ) ;
		}
		return sts ;

} /* VSconstructGroup */
/*----------------------------------------------------------------------------*/
long VSlinkGroup( msg, group, listener )

long		*msg ;
struct GRid	*group,
		*listener ; {

	long		sts ;
	struct GRid	*list = NULL ;
	int		i,
			count = 0 ;
	IGRboolean	tag_conn = FALSE ;
	int		listIndex ;
	OM_S_CHANSELECT	toCmps,
			notification ;

	__DBGpr_obj( "Listener", *listener ) ;
#ifdef vsDEBUG
	ShowObj( listener ) ; ShowObj( group ) ;
#endif
	ems$make_chanselect( chan_label    = GRnotify_notification,
			     chan_selector = &notification ) ; 
	ems$make_chanselect( chan_label    = GRcmpowner_to_components,
			     chan_selector = &toCmps ) ; 
	sts = VS_GetChanObjWithMalloc( group, &toCmps, &count, &list ) ;

	for( i = 0 ; i < count ; i++ ) {
		__DBGpr_obj( "Notifier", list[i] ) ;
		sts = om$send(	msg	= message GRnotify.GRntfyconn(
						msg, listener,
						&notification,
						&listIndex,
						&tag_conn,
						&list[i].osnum ),
				senderid= listener->objid,
				targetid= list[i].objid,
				targetos= list[i].osnum ) ;
		__CheckRC( sts, *msg, "GRnotify.GRntfyconn", wrapup ) ;
	}
	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		if( count ) _FREE( list ) ;
		return sts ;

} /* VSlinkGroup */
/*----------------------------------------------------------------------------*/

end implementation ACdiowner ;

