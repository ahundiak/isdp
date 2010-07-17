/*
	I/STRUCT
*/
class implementation NDnode ;

#include <stdlib.h>
#include "vsmiscmacros.h"

struct VS_s_tmpObjList {
	struct GRmd_env		modEnv ;
	struct GRid		object ;
	struct VS_s_tmpObjList	*next ;
} ;
typedef struct VS_s_tmpObjList VStmpObjList ;

%safe
VStmpObjList	*VS_Gp_tmpObjList	= NULL ;
%endsafe
/*----------------------------------------------------------------------------*/
void VSrecordTmpObj( id, env ) struct GRid *id ; struct GRmd_env *env ; {

	VStmpObjList	*new = _MALLOC( 1, VStmpObjList ) ;

	if( new ) {
		new->object		= *id ;
		new->modEnv		= *env ;
		new->next		= VS_Gp_tmpObjList ;
		VS_Gp_tmpObjList	= new ;
	}

} /* VSrecordTmpObj */
/*----------------------------------------------------------------------------*/
void VSdiscardTmpObjs() {

	VStmpObjList	*this	= VS_Gp_tmpObjList,
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
	VS_Gp_tmpObjList = NULL ;

} /* VSdiscardTmpObjs */
/*----------------------------------------------------------------------------*/

end implementation NDnode ;
