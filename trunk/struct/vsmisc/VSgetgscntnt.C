/*
	I/STRUCT
*/
#include <stdio.h>
#include <stdlib.h>
#include "OMmacros.h"		/* IF_EQ_OBJID, IF_NULL_OBJID	*/
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vscmd.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
int VSget_gs_content( msg, gs, keepOSes, OScount, keepClasses, filter, args,
		      p_count, p_content, p_notCount, p_notKeep )

/*
 * This function is interfaced by macro vs$get_gs_content.
 */

long			*msg ;
struct GRid		*gs ;
OMuword			keepOSes[] ;
int			OScount,
			*p_count,
			*p_notCount,
			(*filter) __((	struct GRobj_env *object,
					VSfenceArgs	 *args )) ;
VSfenceArgs		*args ;
OM_S_CLASSLIST		keepClasses[] ;
struct GRobj_env	**p_content,
			**p_notKeep ; {

	struct GRid		clipPolygon ;	/* Id of clipping polygon    */
	int			total,		/* Total count of elements   */
				u,		/* Loop index on all elmts   */
				v,		/* Loop index on kept elmts  */
				w,		/* Loop index on elmts not   */
						/* keep.		     */
				OSchk,		/* Perform OS check if TRUE  */
				CLchk,		/* Class OS check if TRUE    */
				keepIt ;	/* If TRUE, retain object    */
	struct GRobj_env	*set = NULL ;	/* List of elements kept     */
	struct GRobj_env	*notSet = NULL ;/* List of elements not kept */
	OM_S_OBJID		elmObjid ;	/* Objid of one element	     */
	OMuword			elmOsnum ;	/* Osnum of one element	     */

	if( p_notCount ) *p_notCount = 0 ;
	if( p_notKeep  ) *p_notKeep  = NULL ;
	/*
	 * Retrieve clipping polygon if any.
	 */
	gr$gsget_fence(	msg = msg, fence_id = &clipPolygon ) ;
	if( !( *msg & 1 ) ) clipPolygon.objid = NULL_OBJID ;

	gr$gsinqcount(	msg		= msg,
			count		= &total,
			senderid	= gs->objid,
			object_id	= gs ) ;
	__CheckRC( 1, *msg, "gr$gsinqcount", wrapup ) ;

	if( !total ) { *msg = MSSUCC ; *p_count = 0 ; goto wrapup ; }

	set = _MALLOC( total, struct GRobj_env ) ;
	if( !set ) { *msg = EMS_E_NoDynamicMemory ; goto wrapup ; }

	if( p_notCount && p_notKeep ) {
		notSet = _MALLOC( total, struct GRobj_env ) ;
		if( !notSet ) { *msg = EMS_E_NoDynamicMemory ; goto wrapup ; }
	}

        gr$gsget_objects(	msg		= msg,
				array		= set,
				size		= total * sizeof *set,
				count		= &total,
				from_obj	= 0,
				to_obj  	= total - 1,
				senderid	= gs->objid,
				senderos	= gs->osnum,
				object_id	= gs ) ;
	__CheckRC( 1, *msg, "gr$gsget_objects", wrapup ) ;

	OSchk = keepOSes && OScount ;
	CLchk = keepClasses && keepClasses->w_count ;

	for( u = v = w = 0 ; u < total ; u++ ) {
		elmOsnum = set[u]._osnum ;
		elmObjid = set[u]._objid ;

		/*
		 * Do not retain clipping polygon.
		 */
		keepIt =    !IF_EQ_OBJID( elmObjid, clipPolygon.objid )
			 || elmOsnum != clipPolygon.osnum ;
		if( !keepIt ) continue ;
		
		/*
		 * Object space filter.
		 */
		if( keepIt && OSchk ) {
			keepIt = vs$is_osnum_in_list(
						osnum		= elmOsnum,
						spaceCount	= OScount,
						spaceList	= keepOSes ) ;
		}
		/*
		 * Class filter.
		 */
		if( keepIt && CLchk ) {
			keepIt = vs$is_object_of_classes(
						objid		= elmObjid,
						osnum		= elmOsnum,
						classList	= keepClasses );
		}
		/*
		 * User filter.
		 */
		if( keepIt && filter ) {
			keepIt = filter( set + u, args ) ;
		}

		if( keepIt ) {
			set[v++] = set[u] ;
		} else 	if( notSet ) { 
				notSet[w++] = set[u] ;
		}

	} /* for */

	*msg		= MSSUCC ;
	*p_count	= v ;
	*p_content	= set ;
	if( p_notCount ) *p_notCount	= w ;
	if( p_notKeep  ) *p_notKeep	= notSet ;


	wrapup :
		if( !( *msg & 1 ) ) { _FREE( set ) ; _FREE( notSet ) ; }
		return *msg & 1 ;
	
} /* VSget_gs_content */
/*----------------------------------------------------------------------------*/

