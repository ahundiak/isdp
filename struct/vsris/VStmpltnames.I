/*
	I/STRUCT
*/
class implementation ACcpx_defn ;

#include <stdio.h>
#include <limits.h>
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
#include "exmacros.h"
#include "gr.h"
#include "acdef.h"
#include "acmacros.h"
#include "macro.h"
#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
void VSgetMacDefFullName( macLib, macDefBaseName, macDefFullName )

char	*macLib,
	*macDefBaseName,
	*macDefFullName ; {

	OMuword		actModOs ;
	extern char	*ACdefault_constructs,
			*ACdefault_constructs_lib ;

	ex$get_cur_mod( osnum = &actModOs ) ;

	di$give_pathname(	osnum	= actModOs,
				pathname= macDefFullName ) ;

	DIstmcat(	macDefFullName,
			ACdefault_constructs_lib,
			macLib,
			ACdefault_constructs,
			macDefBaseName,
			NULL ) ;

} /* VSgetMacDefFullName */
/*----------------------------------------------------------------------------*/
long VSgetTemplateNames( msg, errStr, macLib, macDefName, size,
			 p_count, templates )

/*
 * This function is interfaced by macro vs$getTemplateNames.
 */
long	*msg ;
char	*errStr,
	*macLib,
	*macDefName,
	*templates[] ;
int	size,
	*p_count ; {

	long		sts ;
	struct GRid	macDefId ;
	struct stemp	*temp_desc ;	
	int		i ;
	char		macDefFullName[DI_PATH_MAX] ;

	if( errStr ) *errStr = '\0' ;

	sts = ac$construct_path(	mode = AC_ADD_PATH,
					name = macLib ) ;
	if( !( sts & 1 ) ) {
		*msg = MSFAIL ;
		if( errStr ) {
			ex$message(	msgnumb	= VS_gW_CantAttMacLib,
					type	= "%s",
					var	= `macLib`,
					buff	= errStr ) ;
		}
		goto wrapup ;
	}

	/*
	 * Get full name of macro definition to make sure we pick out the right
	 * one.
	 */
	VSgetMacDefFullName( macLib, macDefName, macDefFullName ) ;

	sts = ac$find_macro_defn(	action		= ACfind_no_load,
					macro_name	= macDefFullName,
					p_macro_defn_id	= &macDefId ) ;
	if( !( sts & 1 ) ) {

		*msg = MSFAIL ;
		if( errStr ) {
			ex$message(	msgnumb	= VS_gW_MacNotFound,
					type	= "%s%s",
					var	= `macDefName,macLib`,
					buff	= errStr ) ;
		}
		goto wrapup ;
	}

	sts = om$send(	msg	= message ACcpx_defn.ACgive_temp_desc(
							p_count, &temp_desc ),
			senderid= macDefId.objid,
			targetid= macDefId.objid,
			targetos= macDefId.osnum ) ;

	if( !( sts & 1 ) ) {

		*msg = MSFAIL ;
		if( errStr ) {
			ex$message(	msgnumb	= VS_gW_NoDataFrMac,
					type	= "%s",
					var	= `macDefName`,
					buff	= errStr ) ;
		}
		goto wrapup ;
	}

	if( *p_count <= size ) size = *p_count ;

	for( i = 0 ; i < size ; i++ ) {
		templates[i] = temp_desc[i].name ;
	}

	*msg = MSSUCC ;

	wrapup :
		if( !( *msg & 1 ) ) *p_count = 0 ;
		return *msg & 1 ;

} /* VSgetTemplateNames */
/*----------------------------------------------------------------------------*/

end implementation ACcpx_defn ;
