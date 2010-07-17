/*
	I/STRUCT
*/
class implementation VSdataMgr ;

#include <stdio.h>
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "msdef.h"
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
long VSgetDataMgr( osnum, p_objid ) OMuword osnum ; OM_S_OBJID *p_objid ; {

	long sts ;

	if( ex$get_modid( mod_osnum = osnum, mod_id = p_objid ) ) {
		sts = ex$get_super(	mod_id		= *p_objid,
					mod_osnum	= osnum,
					super_name	= "STRUCTdataMgr",
					super_class	= "VSdataMgr",
					create		= TRUE,
					super_id	= p_objid ) ;
	} else {
		sts = OM_W_ABORT ;
	}
	if( !( sts & 1 ) ) *p_objid = NULL_OBJID ;

	return sts ;

} /* VSgetDataMgr */
/*----------------------------------------------------------------------------*/
long VSgetSharedData( msg, osnum, count, data, p_objid )

long		*msg ;
OMuword		osnum ;
int		count ;
VSdataDesc	data[] ;
OM_S_OBJID	*p_objid ; {

	long		sts ;		/* OM return code		*/
	OM_S_OBJID	dataMgr ;	/* Id of shared data manager	*/

	*msg = EMS_E_OMerror ;
	sts = vs$getDataMgr( osnum = osnum, p_objid = &dataMgr ) ;
	if( !( sts & 1 ) ) goto wrapup ;

	sts = om$send(	msg	= message VSdataMgr.VSgetCollection(
						msg, count, data, p_objid ),
			senderid= dataMgr,
			targetid= dataMgr,
			targetos= osnum ) ;
	__CheckRC( sts, *msg, "VSdataMgr.VSgetCollection", wrapup ) ;

	wrapup :
		return sts ;

} /* VSgetSharedData */
/*----------------------------------------------------------------------------*/

end implementation VSdataMgr ;
