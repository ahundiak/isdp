/*
	I/VDS	Copy

	Bulk deletion of graphic objects.
*/
class implementation GRgraphics ;

#include <stdio.h>
#include "OMmacros.h"
#include "msdef.h"
#include "growner.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
/*----------------------------------------------------------------------------*/
long VD_bulkDeleteByGRids( theEnv, count, GRidList )

const struct GRmd_env	*theEnv ;
int			count ;
struct GRid		GRidList[] ; {

	long		sts,		/* OM return code		*/
			msg ;		/* Completion code		*/
	int		i ;		/* Loop-on-graphics index	*/

	for( i = 0 ; i < count ; i++ ) {
		if( !IF_NULL_OBJID( GRidList[i].objid ) ) {
			sts = om$send(	msg	= message GRgraphics.GRdelete(
						&msg,
						( struct GRmd_env*) theEnv ),
					senderid= GRidList[i].objid,
					targetid= GRidList[i].objid,
					targetos= GRidList[i].osnum ) ;
			if( !( sts & 1 & msg ) ) {
				om$send(msg	= message Root.delete( 0 ),
					senderid= GRidList[i].objid,
					targetid= GRidList[i].objid,
					targetos= GRidList[i].osnum ) ;
			}
			GRidList[i].objid = NULL_OBJID ;
		}
	}
	return TRUE ;

} /* VD_bulkDeleteByGRids */
/*----------------------------------------------------------------------------*/
long VD_bulkDeleteByGRobj_envs( count, GRobj_envList )

int			count ;
struct GRobj_env	GRobj_envList[] ; {

	long		sts,		/* OM return code		*/
			msg ;		/* Completion code		*/
	int		i ;		/* Loop-on-graphics index	*/

	for( i = 0 ; i < count ; i++ ) {
		if( !IF_NULL_OBJID( GRobj_envList[i]._objid ) ) {

			sts = om$send(	msg	= message GRgraphics.GRdelete(
						&msg,
						&GRobj_envList[i].mod_env ),
					senderid= GRobj_envList[i]._objid,
					targetid= GRobj_envList[i]._objid,
					targetos= GRobj_envList[i]._osnum ) ;
			if( !( sts & 1 & msg ) ) {
				om$send(msg	= message Root.delete( 0 ),
					senderid= GRobj_envList[i]._objid,
					targetid= GRobj_envList[i]._objid,
					targetos= GRobj_envList[i]._osnum ) ;
			}
			GRobj_envList[i]._objid = NULL_OBJID ;
		}
	}
	return TRUE ;

} /* VD_bulkDeleteByGRobj_envs */
/*----------------------------------------------------------------------------*/
long VD_bulkDeleteByObjid( theEnv, count, objidList )

const struct GRmd_env	*theEnv ;
int			count ;
OM_S_OBJID		objidList[] ; {

	long		sts,		/* OM return code		*/
			msg ;		/* Completion code		*/
	int		i ;		/* Loop-on-graphics index	*/
	OMuword		theOS ;

	theOS = theEnv->_MD_OS ;

	for( i = 0 ; i < count ; i++ ) {
		if( !IF_NULL_OBJID( objidList[i] ) ) {

			sts = om$send(	msg	= message GRgraphics.GRdelete(
						&msg,
						(struct GRmd_env*) theEnv ),
					senderid= objidList[i],
					targetid= objidList[i],
					targetos= theOS ) ;
			if( !( sts & 1 & msg ) ) {
				om$send(msg	= message Root.delete( 0 ),
					senderid= objidList[i],
					targetid= objidList[i],
					targetos= theOS ) ;
			}
			objidList[i] = NULL_OBJID ;
		}
	}
	return TRUE ;

} /* VD_bulkDeleteByObjids */
/*----------------------------------------------------------------------------*/

end implementation GRgraphics ;
