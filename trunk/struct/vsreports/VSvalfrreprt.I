/*
	I/STRUCT
*/
class implementation VScpx ;

#include <ctype.h>
#include <string.h>
#include "OMmacros.h"
#include "vsmiscmacros.h"
/*----------------------------------------------------------------------------*/
void VSgetItemValueForReport( object, attribute, buffer )

struct GRobj_env	*object ;
char			*attribute,
			*buffer ; {

	long			sts ;
	int			index = -1,
				rc ;
	struct ret_struct	rs ;

	*buffer = '\0' ;
	sts = om$send(	msg	= message ACdb_info.ACgive_db_structure(
						&rc,
						&index,
						attribute,
						&rs,
						&object->mod_env ),
			senderid= object->_objid,
			targetid= object->_objid,
			targetos= object->_osnum ) ;

	if( !( ( sts & 1 & rc ) && ( rs.type & parameter_generic ) ) ) {
		*buffer = '?' ;
		strcpy( buffer + 1, attribute ) ;
	} else {
		if( rs.type == text_type ) {
			strcpy( buffer, rs.var.text_st.text_string ) ;
		} else {
			long	msg ;

			sts = om$send(	msg	= message VScpx.VSdescribeOutput(
							&msg,
							attribute,
							buffer ),
					senderid= object->_objid,
					targetid= object->_objid,
					targetos= object->_osnum ) ;

			if( sts & 1 & msg ) {
				char	*p ;
				if( p = strchr( buffer, '=' ) ) {
					char *q ;
					p += 2 ;
					if( q = strchr( p, '(' ) ) {
						p = q + 1 ;
						OM_BLOCK_MOVE(	p,
								buffer,
								1 + strlen( p ) ) ;
						if( p = strrchr( buffer, ')' ) ) {
							*p = '\0' ;
						}
					} else {
						OM_BLOCK_MOVE(	p,
								buffer,
								1 + strlen( p ) ) ;
					}
				}

			} else {
				sprintf( buffer, "%g", rs.var.root_pm_st.value ) ;
			}
		}
	}

} /* VSgetItemValueForReport */
/*----------------------------------------------------------------------------*/

end implementation VScpx ;

