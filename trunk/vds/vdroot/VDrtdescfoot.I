/* $Id: VDrtdescfoot.I,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdroot/VDrtdescfoot.I
 *
 * Description:
 *	Sent by a pretend to this object, used to pretty-print an output in
 *	the "Directory Command" form.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDrtdescfoot.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:12  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1998/08/21  13:48:10  pinnacle
# tr179801490
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/10/23  21:45:18  pinnacle
# Created: vdroot/VDrtdescfoot.I by v250_int for vds
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/23/97	adz		creation date
 *	08/21/98	adz		tr179801490 Implemented function
 ***************************************************************************/
class implementation VDSroot ;

#include <stdio.h>
#include <string.h>
#include "UOMdef.h"
#include "griodef.h"
#include "v_dbgmacros.h"

/*----------------------------------------------------------------------------*/
method VDdescribeOutput( long *msg ; char *nameOfOutput, *description ) {

	long			sts ;
	int			ACrc,
				index = -1 ;
	char			value[UOM_K_MAX_LEN] ;
	struct ret_struct	rs ;
	struct GRid		myGRid ;
	struct GRmd_env		myEnv ;

	SetProc( VDSroot_VDdescribeOutput ); Begin

	myGRid.objid	= my_id ;
	myGRid.osnum	= OM_Gw_current_OS ;

	VD_getVirtualInfo( msg, &myGRid, &myEnv, NULL ) ;

	sts = om$send(	msg	= message ACcpx.ACgive_structure(
				    &ACrc, &index, nameOfOutput, &rs, &myEnv ),
			targetid= my_id ) ;
	if( !( sts & 1 & ACrc ) ) {
		strcpy( description, nameOfOutput ) ;
	} else {
		sprintf( value, " = %g", rs.var.root_pm_st.value ) ;
		strcat( description, value ) ;
	}

	*msg = MSSUCC ;
	__DBGpr_str(" Description ", description );

	End;
	return OM_S_SUCCESS ;

} /* method VDdescribeOutput */
/*----------------------------------------------------------------------------*/

end implementation VDSroot ;
