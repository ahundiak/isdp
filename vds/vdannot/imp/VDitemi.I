/* $Id: VDitemi.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $ */

/* I/VDS
 *
 * File:        vdannot/VDitemi.I
 *
 * Description:
 *
 *      Implementation of methods for VDitem
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDitemi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
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
# Revision 1.4  1995/08/18  22:54:12  pinnacle
# Replaced: vdannot/imp/VDitem*I for:  by jwfrosch for vds.240
#
# Revision 1.3  1995/07/25  22:47:14  pinnacle
# Replaced: vdannot/imp/* for:  by jwfrosch for vds.240
#
# Revision 1.2  1995/07/13  14:36:38  pinnacle
# Replaced: vdannot/imp/VDitemi.I for:  by jwfrosch for vds.240
#
 *
 * History:
 *
 *      12/07/94       R.Manem     Creation Date
 *      6/15/95        tlb         Modified for new VDitem instance variables
 */

class implementation VDitem;

#include "go.h"
#include "msdef.h"
#include "AS_status.h"
#include "v_miscmacros.h"

#define VD_DEBUG

#include "VDdebug.h"

from    VDitemSet	import	VDgetSetInfo;

/*------------------------------------------------------------------------*/

method VDgetItemInfo
(
  IGRlong          *msg;
  IGRchar         **ItemNum;
  IGRchar         **tblName
)
{
  IGRint		len = 0;
  IGRlong		rc;
  IGRint		status = OM_S_SUCCESS;
  OM_S_CHANSELECT	bom_chan;

  __enterMethod ( name = "VDgetItemInfo" );

  *msg = MSSUCC;

  if( ItemNum )
  {
    *ItemNum = NULL;
    len = om$dimension_of( varray = me->ItemNum );

    __printf ( "om$dimension_of( varray = me->ItemNum ) = %d", len );

    if ( len )
    {
      __printf ( "me->ItemNum = <%s>", me->ItemNum );

      *ItemNum = _MALLOC ( len, IGRchar );
      if( !*ItemNum )
      {
	printf("\nERROR : Dynamic allocation\n");
	__exit_error_Method ( name = "VDgetItemInfo" );
	return OM_E_NODYNMEM;
      }
      strcpy( *ItemNum, me->ItemNum );
    }
  }

  if (tblName)
  {
    /* call corresponding VDitemSet object */
    status = om$make_chanselect( channame	= "VDitem.to_bomset",
				 p_chanselect	= &bom_chan );
    as$status();
    if ( ! (status & 1) )
    {
      __print_goto ( "wrapup" );
      goto wrapup;
    }

    status = _VD_SEND_CHAN (bom_chan, VDitemSet.VDgetSetInfo ( &rc, tblName) );

    as$status();
    as$status(sts = rc)
  }

wrapup:

  __exitMethod ( name = "VDgetItemInfo" );

  return status;
}

/*------------------------------------------------------------------------*/

method VDputItemInfo
(
  IGRlong         *msg;
  IGRchar         *ItemNum
)
{
  IGRint	len = 0;
  IGRlong	status = OM_S_SUCCESS;

  __enterMethod ( name = "VDputItemInfo" );

  *msg = MSSUCC;

  if( ItemNum )
  {
    len = strlen( ItemNum ) + 1;
    status = om$vla_set_dimension (	varray = me->ItemNum,
					size   = len );
    as$status();
    strcpy( me->ItemNum, ItemNum );
  }
  else
  {
    *(me->ItemNum) = '\0';
  }

  __exitMethod ( name = "VDputItemInfo" );

  return OM_S_SUCCESS;
}

end implementation VDitem;
