/* $Id: VSdpb_func.I,v 1.1.1.1 2001/01/04 21:10:32 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsdpb/VSdpb_func.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSdpb_func.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:32  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1997/12/18  12:29:30  pinnacle
# Replaced: vsdpb/VSdpb_func.I for:  by svkadamb for struct
#
# Revision 1.2  1997/11/14  12:22:12  pinnacle
# Replaced: vsdpb/VSdpb_func.I for:  by svkadamb for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *                      suresh          modification
 ***************************************************************************/

/*
	I/STRUCT
*/
class implementation VSdpb ;

#include <stdio.h>
#include "OMmacros.h"
#include "msdef.h"		/* For MS...		*/
#include "igetypedef.h"
#include "igrtypedef.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "gr.h"
#include "vsdbgmacros.h"

%safe
struct GRid VS_GS_DpbId = { 0, (OM_S_OBJID) -1 } ;
%endsafe
/*----------------------------------------------------------------------------*/
int VSget_dpb( p_dpb_id, p_dpb_os )

OM_S_OBJID	*p_dpb_id ;
OMuword		*p_dpb_os ; {

	OM_S_OBJID	mod_id ;
	int		rc ;

	if( !IF_NULL_OBJID( VS_GS_DpbId.objid ) ) {
		*p_dpb_id = VS_GS_DpbId.objid ;
		*p_dpb_os = VS_GS_DpbId.osnum ;

		rc = TRUE ;
	} else if( ex$get_cur_mod(	id	= &mod_id,
					osnum	= p_dpb_os ) & 1 ) {
		rc = ex$get_super(	mod_id		= mod_id,
					mod_osnum	= *p_dpb_os,
					super_name	= "STRUCTdpb",
					super_class	= "VSdpb",
					create		= TRUE,
					super_id	= p_dpb_id ) ;
		if( rc & 1 ) {
			rc = TRUE ;
		} else {
			*p_dpb_id = VS_GS_DpbId.objid = NULL_OBJID ;
			rc = FALSE ;
		}
	} else {
		*p_dpb_id = NULL_OBJID ;
		rc = FALSE ;
	}
		
	return rc ;

} /* VSget_dpb */
/*----------------------------------------------------------------------------*/
int VSdpb_get( msg, type, var )

long		*msg	;	/* OUT : completion code	*/
enum VSdpb_parm	type	;	/* IN  : code of parameter	*/
char		*var	; {	/* OUT : buffer to fill		*/

	OM_S_OBJID	dpb_id ;
	OMuword		dpb_os ;

	*msg = MSFAIL ;
	if( VSget_dpb( &dpb_id, &dpb_os ) ) {
		/*
		 * The following message will set *msg to MSSUCC if it
		 * succeeds.
		 */
		om$send(	msg	= message VSdpb.get( msg, type, var ),
				senderid= dpb_id,
				targetid= dpb_id,
				targetos= dpb_os ) ;
	}
	return *msg & 1 ;

} /* VSdpb_get */
/*----------------------------------------------------------------------------*/
int VSdpb_put( msg, type, var )

long		*msg	;	/* OUT : completion code	*/
enum VSdpb_parm	type	;	/* IN  : code of parameter	*/
char		*var	; {	/* IN  : buffer to read from	*/

	OM_S_OBJID	dpb_id ;
	OMuword		dpb_os ;

	*msg = MSFAIL ;
	if( VSget_dpb( &dpb_id, &dpb_os ) ) {
		/*
		 * The following message will set *msg to MSSUCC if it
		 * succeeds.
		 */
		om$send(	msg	= message VSdpb.put( msg, type, var ),
				senderid= dpb_id,
				targetid= dpb_id,
				targetos= dpb_os ) ;
	}
	return *msg & 1 ;

} /* VSdpb_put */
/*----------------------------------------------------------------------------*/
long VSdpb_loaded_with_beam( loaded ) int *loaded ; {

	OM_S_OBJID	dpb_id ;
	OMuword		dpb_os ;

	if( VSget_dpb( &dpb_id, &dpb_os ) ) {
		/*
		 * The following message will set *msg to MSSUCC if it
		 * succeeds.
		 */
		om$send(	msg	= message VSdpb.have_beam_data( loaded),
				senderid= dpb_id,
				targetid= dpb_id,
				targetos= dpb_os ) ;
	} else *loaded = FALSE ;

	return TRUE ;

} /* VSdpb_loaded_with_beam */
/*----------------------------------------------------------------------------*/
long VSdpb_loaded_with_plate( loaded ) int *loaded ; {

	OM_S_OBJID	dpb_id ;
	OMuword		dpb_os ;
	
	if( VSget_dpb( &dpb_id, &dpb_os ) ) {
		/*
		 * The following message will set *msg to MSSUCC if it
		 * succeeds.
		 */
		om$send(	msg	= message VSdpb.have_plate_data( loaded),
				senderid= dpb_id,
				targetid= dpb_id,
				targetos= dpb_os ) ;
	} else *loaded = FALSE ;

	return TRUE ;

} /* VSdpb_loaded_with_plate */
/*----------------------------------------------------------------------------*/

end implementation VSdpb ;

