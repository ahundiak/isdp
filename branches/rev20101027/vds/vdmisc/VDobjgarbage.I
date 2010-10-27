/*
	I/VDS	Copy
*/
class implementation NDnode ;

#include <stdlib.h>
#include "v_miscmacros.h"

struct VD_s_tmpObjList {
	struct GRmd_env		modEnv ;
	struct GRid		object ;
	struct VD_s_tmpObjList	*next ;
} ;
typedef struct VD_s_tmpObjList VD_tmpObjList ;

%safe
VD_tmpObjList	*VD_Gp_tmpObjList	= NULL ;
%endsafe
/*----------------------------------------------------------------------------*/
void VD_recordTmpObj( id, env ) struct GRid *id ; struct GRmd_env *env ; {

	VD_tmpObjList	*new = _MALLOC( 1, VD_tmpObjList ) ;

	if( new ) {
		new->object		= *id ;
		new->modEnv		= *env ;
		new->next		= VD_Gp_tmpObjList ;
		VD_Gp_tmpObjList	= new ;
	}

} /* VD_recordTmpObj */
/*----------------------------------------------------------------------------*/
void VD_discardTmpObjs() {

	VD_tmpObjList	*this	= VD_Gp_tmpObjList,
			*next ;

	while( this ) {
		om$send(msg	= message NDnode.NDsleep( &this->modEnv ),
			senderid= NULL_OBJID,
			targetid= this->object.objid,
			targetos= this->object.osnum ) ;
		next = this->next ;
		free( this ) ;
		this = next ;
	}
	VD_Gp_tmpObjList = NULL ;

} /* VD_discardTmpObjs */

/*----------------------------------------------------------------------------*/

end implementation NDnode ;
