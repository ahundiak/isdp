/*
	I/STRUCT

	Bulk display of graphic objects.
*/
class implementation GRgraphics ;

#include <stdio.h>
#include "OMmacros.h"
#include "exmacros.h"
#include "msdef.h"
#include "growner.h"
#include "vsmiscmacros.h"
/*----------------------------------------------------------------------------*/
long VSbulkDisplayByGRids( theEnv, dpmode, count, GRidList )

struct GRmd_env		*theEnv ;
enum GRdpmode		dpmode ;
int			count ;
struct GRid		GRidList[] ; {

	long		msg ;		/* Completion code		*/
	int		i ;		/* Loop-on-graphics index	*/
	struct GRid	actMod ;

	ex$get_cur_mod( id = &actMod.objid, osnum = &actMod.osnum ) ;

	for( i = 0 ; i < count ; i++ ) {
		if( !IF_NULL_OBJID( GRidList[i].objid ) ) {

			om$send(msg	= message GRgraphics.GRdisplay(
							&msg,
							&theEnv->_MATRIX_TYPE,
							theEnv->_MATRIX,
							&dpmode,
							&actMod ),
				senderid= GRidList[i].objid,
				targetid= GRidList[i].objid,
				targetos= GRidList[i].osnum ) ;
		}
	}
	return 1 ;

} /* VSbulkDisplayByGRids */
/*----------------------------------------------------------------------------*/
long VSbulkDisplayByGRobj_envs( dpmode, count, GRobj_envList )

enum GRdpmode		dpmode ;
int			count ;
struct GRobj_env	GRobj_envList[] ; {

	long		msg ;		/* Completion code		*/
	int		i ;		/* Loop-on-graphics index	*/
	struct GRid	actMod ;

	ex$get_cur_mod( id = &actMod.objid, osnum = &actMod.osnum ) ;

	for( i = 0 ; i < count ; i++ ) {
		if( !IF_NULL_OBJID( GRobj_envList[i]._objid ) ) {

			om$send(msg	= message GRgraphics.GRdisplay(
					&msg,
					&GRobj_envList[i]._matrix_type,
					GRobj_envList[i]._matrix,
					&dpmode,
					&actMod ),
				senderid= GRobj_envList[i]._objid,
				targetid= GRobj_envList[i]._objid,
				targetos= GRobj_envList[i]._osnum ) ;
		}
	}

	return 1 ;

} /* VSbulkDisplayByGRobj_envs */
/*----------------------------------------------------------------------------*/
long VSbulkDisplayByObjid( theEnv, dpmode, count, objidList )

struct GRmd_env		*theEnv ;
enum GRdpmode		dpmode ;
int			count ;
OM_S_OBJID		objidList[] ; {

	long		msg ;		/* Completion code		*/
	int		i ;		/* Loop-on-graphics index	*/
	OMuword		theOS ;
	struct GRid	actMod ;

	ex$get_cur_mod( id = &actMod.objid, osnum = &actMod.osnum ) ;

	theOS = theEnv->_MD_OS ;

	for( i = 0 ; i < count ; i++ ) {
		if( !IF_NULL_OBJID( objidList[i] ) ) {

			om$send(msg	= message GRgraphics.GRdisplay(
							&msg,
							&theEnv->_MATRIX_TYPE,
							theEnv->_MATRIX,
							&dpmode,
							&actMod ),
				senderid= objidList[i],
				targetid= objidList[i],
				targetos= theOS ) ;
		}
	}

	return 1 ;

} /* VSbulkDisplayByObjids */
/*----------------------------------------------------------------------------*/

end implementation GRgraphics ;
