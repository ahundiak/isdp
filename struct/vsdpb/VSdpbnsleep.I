/* $Id: VSdpbnsleep.I,v 1.1.1.1 2001/01/04 21:10:32 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsdpb/VSdpbnsleep.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSdpbnsleep.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:32  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/11/14  13:34:34  pinnacle
# Created: vsdpb/VSdpbnsleep.I by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		creation 
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation VSdpbn ;

#include <stdio.h>
#include "OMerrordef.h"
#include "OMversion.h"
#include "exdef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "vsdbgmacros.h"

extern struct GRid	VS_GS_DpbnId ;
/*----------------------------------------------------------------------------*/
method sleep( int type ) {

	SetProc( VSdpbn_sleep ); Begin

	VS_GS_DpbnId.objid= NULL_OBJID ;

	End
	return OM_S_SUCCESS ;

} /* method sleep */
/*----------------------------------------------------------------------------*/

end implementation VSdpbn ;

