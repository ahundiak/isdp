/* $Id: VDdrwelembuf.I,v 1.1.1.1 2001/01/04 21:08:37 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddraw/drw/VDdrwelembuf.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwelembuf.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:37  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1995/08/23  20:07:08  pinnacle
# Created: vddraw/drw/VDdrwelembuf.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08/22/95	adz		creation date
 *
 ***************************************************************************/
class implementation VDSroot ;

#include "OMmacros.h"
#include "vd_ve.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

/*----------------------------------------------------------------------------*/
void VD_veInitElemBuf( buf )
struct  VDve_elem_buf	*buf ;
{
	if( buf ){
		buf->count	= 0 ;
		buf->buf_siz	= 0 ;
		buf->obj_info_p	= NULL ;
	}
}
/*----------------------------------------------------------------------------*/
void VD_veFreeElemBuf( buf )
struct  VDve_elem_buf	*buf ;
{
	if( buf ){
		_FREE( buf->obj_info_p );
		VD_veInitElemBuf( buf );
	}
}
/*----------------------------------------------------------------------------*/
void VD_veDelElemBuf( buf )
struct  VDve_elem_buf	*buf ;
{
	if( buf ){
		/*
		 * Delete the objects.
		 */
		vd_$bulk_delete(count	= buf->count,
				objenvs	= buf->obj_info_p );
		VD_veFreeElemBuf( buf );
	}
}
/*----------------------------------------------------------------------------*/

end implementation VDSroot ;
