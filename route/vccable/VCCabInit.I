/* $Id: VCCabInit.I,v 1.2 2001/02/20 01:08:32 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vccable / VCCabInit.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VCCabInit.I,v $
 *	Revision 1.2  2001/02/20 01:08:32  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:25  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1998/04/01  19:41:34  pinnacle
# Replaced: vccable/VCCabInit.I for:  by kddinov for route
#
# Revision 1.2  1998/03/16  00:57:38  pinnacle
# Replaced: vccable/VCCabInit.I for:  by kddinov for route
#
# Revision 1.1  1998/02/18  19:57:40  pinnacle
# Created: vccable/VCCabInit.I by kddinov for route
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	Feb/98		KDD	creation
 *
 *************************************************************************/

class implementation VCCable;

/*
#define vdsDEBUG        1
*/
 
#include "vrdbgmacros.h"

method VCInitInstance (IGRlong *msg)
{
  IGRlong 	status;

SetProc(VCCable_VCInitInstance ); Begin

  status = om$vla_set_dimension( varray = me->Offset,
                                 size   = 0 );

  me->OffsetType = 0; 				/* unknown data type */


End;
return (  om$send( msg      = message VCRoot.VCInitInstance (msg),
		   mode     = OM_e_wrt_message,
                   targetid = my_id )  );
}


end implementation VCCable;
