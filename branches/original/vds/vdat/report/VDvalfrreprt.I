/* $Id: VDvalfrreprt.I,v 1.1.1.1 2001/01/04 21:07:43 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdat/reports/VDvalfrreprt.I
 *
 * Description:
 *	This file contains a routine to support the reporting process.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDvalfrreprt.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/12/31  13:47:44  pinnacle
# Moved from vdastree
#
# Revision 1.1  1997/11/04  17:43:10  pinnacle
# Created: vdastree/report/VDvalfrreprt.I by v250_int for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/23/97	adz		creation date
 *	12/30/97	ah		moved to vdat
 ***************************************************************************/

class implementation VDSroot ;

#include <ctype.h>
#include <string.h>
#include "OMmacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
/*----------------------------------------------------------------------------*/

void VD_getItemValueForReport( object, attribute, buffer )

struct GRobj_env	*object ;
char			*attribute,
			*buffer ; {

	long			sts ;
	int			index = -1,
				rc ;
	struct ret_struct	rs ;

	SetProc( VD_getItemValueForReport ); Begin 

	__DBGpr_obj(" Object ", object->_grid );
	__DBGpr_str(" Attr   ", attribute );

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

			sts =
			om$send(msg	= message VDSroot.VDdescribeOutput(
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

	__DBGpr_str(" buffer ", buffer );

	End

} /* VD_getItemValueForReport */
/*----------------------------------------------------------------------------*/

end implementation VDSroot ;

