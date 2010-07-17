/*
	I/STRUCT
*/
class implementation GRgraphics ;

#include <stdlib.h>
#include "msdef.h"
#include "exmacros.h"
#include "refdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "maidmx.h"
#include "GRgetctxsupe.h"
#include "vsfnditmary.h"

from OMObjSpace	import pass ;
from GRcontext	import GRgetinstance ;
/*----------------------------------------------------------------------------*/
long VSobjSpacePass( msg, classList, OMmsg, refAlso, mxType, mx )

long		*msg ;
OM_p_CLASSLIST	classList ;
OM_p_MESSAGE	OMmsg ;
int		refAlso ;
short		**mxType ;
double		**mx ; {

	long		sts ;		/* OM return code		*/
	OMuword		osoOs ;		/* OS of a design file		*/
	OM_S_OBJID	osoId ;		/* Id of Object Space above	*/
	short		*saveMxType = NULL ;
	double		*saveMx	    = NULL ;
	struct GRid	ctxId,		/* A context id 		*/	
			rfmgr ;		/* Id of ref. file mgr		*/
	OM_S_CHANSELECT rfmgrTOctx ;	/* Ref. file mgr -> context	*/
	struct GRmd_env	ctxEnv ;	/* Environment from context	*/
	int  		count,		/* ... of contexts		*/
			*files,		/* List of design osnums	*/
			i,		/* Loop-on-context index	*/
			j,		/* Index in array `files'	*/
			useMx ;		/* Use input matrix & type ?	*/
	short		flag ;		/* Context flags		*/

	*msg	= MSSUCC ;
	files	= NULL ;

	if( refAlso && mxType && mx ) {
		saveMxType	= *mxType ;
		saveMx		= *mx ;
		useMx		= TRUE ;
	} else	useMx		= FALSE ;

	/*
	 * Active design file.
	 */
	ex$get_cur_mod( osnum = &osoOs ) ;
	sts = om$osnum_to_oso_objid( osnum = osoOs, p_objid = &osoId ) ;
	__CheckRC( sts, 1, "om$osnum_to_oso_objid", wrapup ) ;

	sts = om$send(	msg	= message OMObjSpace.pass(	classList,
								OM_e_wrt_object,
								OMmsg ),
			senderid= NULL_OBJID,
			targetid= osoId,
			targetos= osoOs ) ;
	__CheckRC( sts, 1, "message OMObjSpace.pass", wrapup ) ;

	if( !refAlso ) goto wrapup ;

	/*
	 * Get the context Super.
	 */
	rfmgr.objid = NULL_OBJID ;
	sts = GRgetctxsuper( msg, &rfmgr ) ;
	__CheckRC( sts, *msg, "GRgetctxsuper", wrapup ) ;

	if( !rfmgr.objid ) {
		/*
		 * If no super, GRNUC return zero as object id with success !
		 * It would be too easy to return NULL_OBJID or just fail...
		 */
		goto wrapup ;
	}

	sts = om$make_chanselect(	
				channame	= "Super_rfmgr.to_context",
				p_chanselect	= &rfmgrTOctx ) ;
	__CheckRC( sts, 1, "om$make_chanselect", wrapup ) ;

	sts = om$get_channel_count(	osnum		= rfmgr.osnum,
					objid		= rfmgr.objid,
					p_chanselect	= &rfmgrTOctx,
					count		= (OMuint *) &count ) ;
	__CheckRC( sts, 1, "om$get_channel_count", wrapup ) ;

	if( !count ) goto wrapup ;

	files = _MALLOC( count, int ) ;

	/*
	 * Loop on contexts.
	 */
	for( i = j = 0 ; i < count ; ++i ) {

		sts = om$send(
			msg	= message GRcontext.GRgetinstance(
							msg,
							&ctxEnv._MATRIX_TYPE,
							ctxEnv._MATRIX,
							&osoOs,
							&flag,
							&ctxId ),
			senderid	= rfmgr.objid,
			targetos	= rfmgr.osnum,
			p_chanselect	= &rfmgrTOctx,
			to		= i,
			from		= i ) ;
		__CheckRC( sts, *msg, "GRcontext.GRgetinstance", wrapup ) ;

		if( osoOs == (OMuword) -1 ) continue ;

		if( useMx ) {
			/*
			 * Set matrix so message can use it.
			 */
			*mxType	= &ctxEnv._MATRIX_TYPE ;
			*mx	= ctxEnv._MATRIX ;
		} else {
			int index ;

			/*
			 * If matrix is not needed by message, there is no
			 * use sending the message twice.
			 */
			VSfind_item_in_array( osoOs, files, j, &index ) ;
			if( index != -1 ) {
				continue ;
			}
		}
		files[j++] = osoOs ;

		sts = om$osnum_to_oso_objid( osnum = osoOs, p_objid = &osoId ) ;
		__CheckRC( sts, 1, "om$osnum_to_oso_objid", wrapup ) ;

		sts = om$send(	msg	= message OMObjSpace.pass(
								classList,
								OM_e_wrt_object,
								OMmsg ),
				senderid= NULL_OBJID,
				targetid= osoId,
				targetos= osoOs ) ;
		__CheckRC( sts, 1, "message OMObjSpace.pass", wrapup ) ;
	}
	wrapup :

	if( useMx ) {
		*mxType	= saveMxType ;
		*mx	= saveMx ;
	}
	_FREE( files ) ;

	return sts ;

} /* VSobjSpacePass */
/*----------------------------------------------------------------------------*/
long VSobjSpacePassLocDsp( msg, classList, locDsp, refAlso )

long		*msg ;
OM_p_CLASSLIST	classList ;
int		locDsp ;
int		refAlso ; {

	long		chgpropsRC ;
	short		action,
			props ;

	action	= locDsp ? 1 : 0 ;
	props	= GRIS_LOCATABLE | GRIS_DISPLAYABLE ;

	return VSobjSpacePass(	msg,
				classList,
				message GRgraphics.GRchgprops(	&chgpropsRC,
								&action,
								&props ),
				refAlso,
				(short  **) NULL,
				(double **) NULL ) ;
							
} /* VSobjSpacePassLocDsp */
/*----------------------------------------------------------------------------*/
long VSobjSpacePassDisplay( msg, classList, dpMode, refAlso )

long		*msg ;
OM_p_CLASSLIST	classList ;
enum GRdpmode	dpMode ;
int		refAlso ; {

	long		displayRC ;
	struct GRid	modGRid ;
	short		idMxType,
			*mxType ;
	IGRmatrix	idMx ;
	double		*mx ;

	MAidmx( msg, idMx ) ; idMxType = MAIDMX ;

	mx = idMx ; mxType = &idMxType ;

	ex$get_cur_mod( id = &modGRid.objid, osnum = &modGRid.osnum ) ;

	return VSobjSpacePass(	msg,
				classList,
				message GRgraphics.GRdisplay(	&displayRC,
								mxType,
								mx,
								&dpMode,
								&modGRid ),
				refAlso,
				&mxType,
				&mx ) ;

} /* VSobjSpacePassDisplay */
/*----------------------------------------------------------------------------*/

end implementation GRgraphics ;

