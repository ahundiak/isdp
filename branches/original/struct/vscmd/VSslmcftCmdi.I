/*
	I/STRUCT
*/
class implementation VSslmcftCmd ;

#include <string.h>
#include <stdlib.h>
#include "OMmacros.h"
#include "growner.h"
#include "grgsdef.h"
#include "grgsmacros.h"
#include "parametric.h"
#include "macro.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "vsglobalmsg.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"

from	GRgrset		import	GSobject_add ;
from	ACcpx		import	find_macro ;
from	ACcpx_defn	import	ACgive_feet_desc ;
from	NDmacro		import	ACreturn_foot ;
/*----------------------------------------------------------------------------*/
static int VSfindFeetOrSubFeet( msg, cpx, footName, size, count, list )

long		*msg ;
struct GRid	*cpx ;
char		*footName ;
int		size,
		*count ;
struct GRid	*list ; {

	long		sts ;
	struct GRid	macDef ;
	struct myfeet	*feetDesc ;
	int		total,
			j,
			feetCount ;

	*count = 0 ;

	sts = om$send(	msg	= message ACcpx.find_macro( &macDef ),
			senderid= cpx->objid,
			targetid= cpx->objid,
			targetos= cpx->osnum ) ;
	__CheckRC( sts, 1, "ACcpx.find_macro", wrapup ) ;

	sts = om$send(	msg	= message ACcpx_defn.ACgive_feet_desc(
							&feetCount, &feetDesc ),
			senderid= macDef.objid,
			targetid= macDef.objid,
			targetos= macDef.osnum ) ;
	__CheckRC( sts, 1, "ACcpx.ACgive_feet_desc", wrapup ) ;

	total = 0 ;
	for( j = 0 ; j < feetCount ; j++ ) {

		if( total >= size ) break ;

		if( VSmatchRE( footName, feetDesc[j].name ) ) {
			/*
			 * Found one !
			 */
			sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							feetDesc[j].name,
							list + total,
							NULL,
							NULL ),
					senderid= cpx->objid,
					targetid= cpx->objid,
					targetos= cpx->osnum ) ;
			__CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup );

			total++ ;
		} else {
			/*
			 * Is foot a macro itself ?
			 */
			int		subCnt ;
			struct GRid	nestedCpx ;

			if( !( feetDesc[j].prop & macro_generic ) ) continue ;

			sts = om$send(	msg	= message NDmacro.ACreturn_foot(
							msg,
							feetDesc[j].name,
							&nestedCpx,
							NULL,
							NULL ),
					senderid= cpx->objid,
					targetid= cpx->objid,
					targetos= cpx->osnum ) ;

			if( !IF_NULL_OBJID( nestedCpx.objid ) ) {
				sts = VSfindFeetOrSubFeet(
							msg,
							&nestedCpx,
							footName,
							size - total,
							&subCnt,
							list + total ) ;
				__CheckRC( sts, *msg, "VSfindFeetOrSubFeet", wrapup ) ;

				total += subCnt ;
			}
		}
	}

	*count = total ;

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* VSfindFeetOrSubFeet */
/*----------------------------------------------------------------------------*/
method checkRegExp( long *msg ) {

	GRname	RE ;

	strcpy( me->regExp, me->event1.event.keyin ) ;
	*msg = VScheckRE( me->regExp, RE ) ? MSSUCC : MSFAIL ;

	return OM_S_SUCCESS ;

} /* method checkRegExp */
/*----------------------------------------------------------------------------*/
method displaySet( enum GRdpmode dpMode ) {

	vs$bulk_display(	grids	= &me->constructedObject,
				theEnv	= &me->ModuleInfo,
				dpmode	= dpMode ) ;
	return OM_S_SUCCESS ;

} /* method displaySet */
/*----------------------------------------------------------------------------*/
method putSetOntoQ() {

	long	msg ;

	/*
	 * Put set onto queue.
	 */
	VSputObjectToQueue(	&msg,
				me->constructedObject.objid,
				me->constructedObject.osnum,
				&me->ModuleInfo,
				FRONT ) ;
	return OM_S_SUCCESS ;


} /* method putSetOntoQ */
/*----------------------------------------------------------------------------*/
method dissolveSet() {

	long	msg ;

	gr$gsdissolve(	msg		= &msg,
			object_id	= &me->constructedObject ) ;

	return OM_S_SUCCESS ;

} /* method dissolveSet */
/*----------------------------------------------------------------------------*/
method operation( long *msg ) {

	long			sts ;
	struct GRobj_env	*elements ;
#define LIST_SIZE		200
	struct GRid		list[LIST_SIZE] ;
	int			i,
				j,
				card,
				count,
				nbValidCpxes,
				properties,
				allOK = FALSE ;
	struct GRid		element0 ;

	me->constructedObject.objid = NULL_OBJID ;

	/*
	 * Allocate memory for all located macro occurrences.
	 */
	card = me->oprndCount ;

	if( !card ) { *msg = VS_K_ACT_SUCCESS ; return OM_S_SUCCESS ; }
	if( !( elements = _MALLOC( card, struct GRobj_env ) ) ) {
		sts = OM_E_NODYNMEM ; goto wrapup ;
	}

	sts = om$send(	msg	= message VSlocateCmd.getLocObjs(
							msg, card, elements ),
			targetid= my_id ) ;
	__CheckRC( sts, *msg, "VSlocateCmd.VSgetLocObjs", wrapup ) ;

 	sts = gr$gsinit( msg		= msg,
			 flag		= 2,        
			 p_objid	= &me->constructedObject.objid,
			 osnum		= me->ModuleInfo._MD_OS ) ;
	__CheckRC( sts, *msg, "gr$gsinit", wrapup ) ;

	me->constructedObject.osnum = me->ModuleInfo._MD_OS ;

	/*
	 * Retain macro ocurrences with feet bearing `me->regExp'.
	 */
	properties	= LC_DP_ONLY | LC_LC_ONLY | LC_RW ;
	nbValidCpxes	= 0 ;

	for( i = 0 ; i < card ; i++ ) {

		VSfindFeetOrSubFeet(	msg,
					&elements[i]._grid,
					me->regExp,
					LIST_SIZE,
					&count,
					list ) ;

		for( j = 0 ; j < count ; j++ ) {
			if( i == 0 && j == 0 ) {
				element0 = list[j] ;
			}
			sts = om$send(	msg	= message GRgrset.GSobject_add(
							msg,
							list + j,
							&elements[i].mod_env,
							&properties,
							NULL,
							NULL ),
				       targetid= me->constructedObject.objid,
				       targetos= me->constructedObject.osnum ) ;
			__CheckRC( sts, *msg, "GRgrset.GSobject_add", wrapup ) ;

			nbValidCpxes++ ;
		}
	}

	allOK = TRUE ;
	if( !nbValidCpxes ) {
		ex$message(	msgnumb	= VS_gI_NoMcWFtFnd,
				type	= "%s",
				var	= `me->regExp` ) ;
		gr$gsdissolve(	msg		= msg,
				object_id	= &me->constructedObject ) ;
		me->ret = VS_K_NO_FENCE ;
	} else {
		if( nbValidCpxes == 1 ) {
			gr$gsdissolve(
				msg		= msg,
				object_id	= &me->constructedObject ) ;
			me->constructedObject = element0 ;
		}
		ex$message(	msgnumb	= VS_gI_NbMcWFtFnd,
				type	= "%d%s",
				var	= `nbValidCpxes,me->regExp` ) ;
		me->ret = VS_K_ACT_SUCCESS ;
	}
	wrapup :
		_FREE( elements ) ;
		if( !allOK ) me->ret = VS_K_RESTART_CMD ;
		return OM_S_SUCCESS ;

} /* method operation */
/*----------------------------------------------------------------------------*/

end implementation VSslmcftCmd ;
