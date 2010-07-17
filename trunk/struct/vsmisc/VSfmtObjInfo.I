/*
	I/STRUCT
*/
class implementation VSfeature ;

#include <stdio.h>
#include <string.h>
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "exmacros.h"
#include "msmacros.h"
#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
long VSformatObjInfo( msg, osnum, objid, objtype, info )

long			*msg ;
OMuword			osnum ;
OM_S_OBJID		objid ;
long			objtype ;
struct GRobj_info 	*info ; {

	long		sts,
			rMsg ;			/* Rep. message number	*/
	int		nchars,			/* Space to print type	*/
			inAlen ;		/* Length of "inA"	*/
	VSdspRep	repCode ;		/* Representation	*/
	unsigned long	res ;			/* Operation result	*/
	char		typ[MS_MAX_MSG_LENGTH],	/* Object type		*/
			rep[MS_MAX_MSG_LENGTH],	/* Representation name	*/
			inA[MS_MAX_MSG_LENGTH]; /* In-macro message buf.*/
	OMuword		actModOs ;		/* Osnum of active mod.	*/

	ex$get_cur_mod( osnum = &actModOs ) ;
	*typ = '\0' ;
        *rep = '\0' ;
        *inA = '\0' ;

	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &repCode ),
			senderid= objid,
			targetid= objid,
			targetos= osnum ) ;
	__CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;

	sts = om$send(	msg	= message VSfeature.VSgetResultType( msg, &res),
			senderid= objid,
			targetid= objid,
			targetos= osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetResultType", wrapup ) ;
	
	repCode &= ~AC_SUB_REP ;

	switch( repCode ) {
		case AC_2D_REP		: rMsg = VS_gI_Internal_2d ; break ;
		case AC_ENV_REP		: rMsg = VS_gI_Envelope	   ; break ;
		case AC_3D_REP		: rMsg = VS_gI_Internal_3d ; break ;
		default			:
			/*
			 * Should not get here.
			 */
			 		  rMsg = MS_NO_MSG ; break ;
	}
	if( rMsg != MS_NO_MSG ) {
		ex$message(	msgnumb	= rMsg,
				buff	= rep ) ;
	} else {
		*rep = '\0' ;
	}

	ex$message(	msgnumb	= objtype,
			buff	= typ ) ;

	if( res & VS_m_IN_ASSEMBLY ) {
		/*
		 * Object is a macro occurrence or a macro definition.
		 */
		ex$message( msgnumb = VS_gI_InAsbly, buff = inA ) ;
		inAlen = strlen( inA ) ;
	} else if( osnum != actModOs ) {
		inAlen = strlen( strcpy( inA, " [R]" ) ) ;
	} else	inAlen = 0 ;

	nchars = sizeof( info->type ) 	- 1		/* space	*/
					- 3 		/* rep		*/
					- 1		/* space	*/
					- inAlen ;

	if( inAlen ) {
		sprintf( info->type, "%.*s %-3.3s%s", nchars, typ, rep, inA ) ;
	} else {
		sprintf( info->type, "%.*s %-3.3s", nchars, typ, rep ) ;
	}
	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;
 
	wrapup :
		return sts ;

} /* VSformatObjInfo */
/*----------------------------------------------------------------------------*/
long VSformatCpxInfo( msg, osnum, objid, objtype, info )

long			*msg ;
OMuword			osnum ;
OM_S_OBJID		objid ;
long			objtype ;
struct GRobj_info 	*info ; {

	long		sts,
			rMsg ;			/* Rep. message number	*/
	int		nchars,			/* Space to print type	*/
			inRlen ;		/* Length of "inR"	*/
	VSdspRep	repCode ;		/* Representation	*/
	char		typ[MS_MAX_MSG_LENGTH],	/* Object type		*/
			rep[MS_MAX_MSG_LENGTH],	/* Representation name	*/
			inR[MS_MAX_MSG_LENGTH] ;/* In-macro message buf.*/
	OMuword		actModOs ;		/* Osnum of active mod.	*/

	ex$get_cur_mod( osnum = &actModOs ) ;

	if( osnum != actModOs ) {
		inRlen = strlen( strcpy( inR, " [R]" ) ) ;
	} else	inRlen = 0 ;

	sts = om$send(	msg	= message ACncpx.ACget_NV_rep( &repCode ),
			senderid= objid,
			targetid= objid,
			targetos= osnum ) ;
	__CheckRC( sts, 1, "ACncpx.ACget_NV_rep", wrapup ) ;

	repCode &= ~AC_SUB_REP ;
	switch( repCode ) {
		case AC_2D_REP		: rMsg = VS_gI_Internal_2d ; break ;
		case AC_ENV_REP		: rMsg = VS_gI_Envelope	   ; break ;
		case AC_3D_REP		: rMsg = VS_gI_Internal_3d ; break ;
		default			: rMsg = MS_NO_MSG	   ; break ;
	}
	ex$message(	msgnumb	= objtype,
			buff	= typ ) ;

	if( rMsg != MS_NO_MSG ) {
		ex$message(	msgnumb	= rMsg,
				buff	= rep ) ;

		nchars = sizeof( info->type ) 	- 1		/* space     */
						- 3 		/* rep	     */
						- inRlen
						- 1 ;		/* space     */

		if( inRlen ) {
			sprintf( info->type, "%.*s %-3.3s %s",
					     nchars, typ, rep, inR ) ;
		} else {
			sprintf( info->type, "%.*s %-3.3s",
					     nchars, typ, rep ) ;
		}
	} else {
		nchars = sizeof( info->type ) 	- 1		/* space     */
						- inRlen ;

		if( inRlen ) {
			sprintf( info->type, "%.*s %s", nchars, typ, inR ) ;
		} else {
			sprintf( info->type, "%.*s", nchars, typ ) ;
		}
	}
	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;
 
	wrapup :
		return sts ;

	
} /* VSformatCpxInfo */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
