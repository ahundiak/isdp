/*
	I/STRUCT
*/
class implementation VSimgFeature ;

#include <string.h>
#include "msmacros.h"
#include "exmacros.h"
#include "UOMdef.h"
#include "UOM.h"
#include "vsglobalmsg.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsioproto.h"
#include "vsstrngproto.h"
/*----------------------------------------------------------------------------*/
method GRgetobjinfo(	long			*msg ;
			struct GRobj_info	*info ) {

	long		sts,
			VSrc ;
	struct GRid	mdl ;
	unsigned long	type ;
	OMuword		actModOs ;

	*info->type = '\0' ;

	sts = om$send(	msg	= message VSimgFeature.VSgetModel( &mdl, NULL ),
			targetid= my_id ) ;
	if( !( sts & 1 ) ) goto wrapup ;

	sts = om$send(	msg	= message VSfeature.VSgetResultType(
								msg, &type ),
			targetid= mdl.objid,
			targetos= mdl.osnum ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	if( type & VS_m_IMG_generic ) {
		/*
		 * Model is also an image: get its object information.
		 */
		sts = om$send(	msg	= OPPmargs,
				targetid= mdl.objid,
				targetos= mdl.osnum ) ;
	} else {
		/*
		 * Model is the original (a real structural element), get its
		 * type.
		 */
		VSobjDef	objDf ;
		char		otype[MS_MAX_MSG_LENGTH] ;
		int		len,
				max,
				wasTruncated ;

		sts = om$send(	msg 	= message VSfeature.VSforwardToOriginal(
						&VSrc,
						OM_e_wrt_object,
						message VScpx.VSgetObjDef(
								msg, &objDf ) ),
				targetid= mdl.objid,
				targetos= mdl.osnum ) ;
		if( !( sts & VSrc & *msg & 1 ) ) goto wrapup ; 

		ex$message(	msgnumb	= objDf.info,
				buff	= otype ) ;

		ex$get_cur_mod( osnum = &actModOs ) ;
		if( actModOs != mdl.osnum ) {
			strcat( otype, " [R]" ) ;
		}
		strcpy( info->type, VSmsgkey2string( VS_gI_ImageOf ) ) ;
		strcat( info->type, " " ) ;
		len = strlen( info->type ) ;
		max = sizeof info->type ;

		VSstrncpy( info->type + len, otype, max - len, &wasTruncated ) ;
	}
	wrapup :
		/*
		 * Success no matter what ...
		 */
		*msg = MSSUCC ;
		return OM_S_SUCCESS ;

} /* method GRgetobjinfo */
/*----------------------------------------------------------------------------*/

end implementation VSimgFeature ;
