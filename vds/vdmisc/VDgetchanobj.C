/*
	I/VDS	Copy
*/
#include <stdio.h>
#include <stdlib.h>
#include "OMminimum.h"
#include "OMprimindex.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "v_getchanobj.h"
/*----------------------------------------------------------------------------*/
int VD_GetChanObjWithMalloc( target, chan, count, objects )

const struct GRid	*target ;
const OM_p_CHANSELECT	chan ;
int			*count ;
struct GRid		**objects ; {

	int			rc ;
	long			sts ;
	OM_p_OBJECT_LINKAGE	Objects ;

	Objects = NULL ; *objects = NULL ; *count = 0 ;

	rc = FALSE ;

	sts = om$get_channel_count(	objid		= target->objid,
					osnum		= target->osnum,
					p_chanselect	= chan,
					count		= (OMuint *) count ) ;

	if( !( sts & 1 ) ) {
		goto wrapup ;
	}

	if( *count ) {
		int i ;

		Objects	 = _MALLOC( *count, OM_S_OBJECT_LINKAGE ) ;
		*objects = _MALLOC( *count, struct GRid ) ;
		if( Objects && *objects ) {
			rc = om$get_channel_objects(
					objid		= target->objid,
					osnum		= target->osnum,
					p_chanselect	= chan,
					size		= *count,
					list		= Objects,
					count		= (OMuint *) count ) ;
			rc = rc & 1 ;
			for( i = 0 ; i < *count ; i++ ) {
				(*objects)[i].objid = Objects[i].S_objid ;
				(*objects)[i].osnum = Objects[i].osnum ;
			}
		}
	} else rc = TRUE ;


	wrapup :
		_FREE( Objects ) ;
		if( !rc ) if( *objects ) {
				free( *objects ) ;
				*objects = NULL ;
		}
		return rc ;

} /* VD_GetChanObjWithMalloc */
/*----------------------------------------------------------------------------*/
void VD_resetObjidList( count, list )

int		count ;
OM_S_OBJID	list[] ; {

	int i ;

	for( i = 0 ; i < count ; i++ ) {
		list[i]	= NULL_OBJID ;
	}

} /* VD_resetObjidList */
/*----------------------------------------------------------------------------*/
void VD_setGRids( osnum, count, list )

OMuword		osnum ;
int		count ;
struct GRid	list[] ; {

	int	i ;

	for( i = 0 ; i < count ; i++ ) {
		list[i].objid	= NULL_OBJID ;
		list[i].osnum	= osnum ;
	}

} /* VD_setGRids */
/*----------------------------------------------------------------------------*/

