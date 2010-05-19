/* $Id: VDchkobjrep.I,v 1.1.1.1 2001/01/04 21:08:57 cvs Exp $  */

/* I/VDS
 *
 * File:	vdmisc/VDchkobjrep.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Reference:
 *	$Log: VDchkobjrep.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:57  cvs
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
# Revision 1.1  1995/04/03  15:46:30  pinnacle
# Created: ./vdmisc/VDchkobjrep.I by azuurhou r#
# rno
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	04/03/95	adz		creation date
 */
class implementation VDSroot ;

#include <stdio.h>
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "EMSmsgdef.h"
/*
 * Includes of function prototypes.
 */

extern OMuword		OPP_ACncpx_class_id ;
/*----------------------------------------------------------------------------*/
long VD_validateObjectRep( elmId, objRep, chkRep )

struct GRid		*elmId ;
VD_dspRep		*objRep ;
VD_dspRep		chkRep ;
{

	long		sts = FALSE  ;

	*objRep = 0 ;

	if( vd_$is_ancestry_valid(object = elmId,
				classid  = OPP_ACncpx_class_id )){

		sts =
		_VD_SEND_OBJN(	*elmId, ACncpx.ACget_NV_rep( objRep ));
		__CheckRC( sts, 1, "ACncpx.ACget_NV_rep" , wrapup );

		if( chkRep == *objRep )
			return TRUE ;
	}

	wrapup :
		return FALSE ;

} /* VD_validateObjectRep */
/*----------------------------------------------------------------------------*/
		
end implementation VDSroot ;
