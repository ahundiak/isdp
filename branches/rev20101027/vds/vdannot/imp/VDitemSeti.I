/* $Id: VDitemSeti.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $ */

/* I/VDS
 *
 * File:        vditem/VDitemSeti.I
 *
 * Description:
 *
 *      VDitemSet implementation - methods :
 *		VDgetSetInfo
 *		VDputSetInfo
 *		VDdisconDelItmObj
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDitemSeti.I,v $
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
# Revision 1.4  1995/08/23  17:46:50  pinnacle
# Replaced: vdannot/imp/VDitemSeti.I for:  by jwfrosch for vds.240
#
# Revision 1.3  1995/08/18  22:54:12  pinnacle
# Replaced: vdannot/imp/VDitem*I for:  by jwfrosch for vds.240
#
# Revision 1.2  1995/07/25  22:47:14  pinnacle
# Replaced: vdannot/imp/* for:  by jwfrosch for vds.240
#
# Revision 1.1  1995/07/13  14:38:48  pinnacle
# Created: vdannot/imp/VDitemSeti.I by jwfrosch for vds.240
#
 *
 * History:
 *
 *      6/15/95		tlb	
 */

class implementation VDitemSet;

#include <stdio.h>

#include "OMmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "string.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grdpbmacros.h"
#include "msdef.h"
#include "asbox.h"
#include "AS_status.h"
#include "v_miscmacros.h"

#define VD_DEBUG

#include "VDdebug.h"

from	VDitem		import	VDgetItemInfo;
from	NDnode		import	NDdisplay;

/*------------------------------------------------------------------------*/

method  VDgetSetInfo
(
  IGRlong	 *msg;
  IGRchar  	**tblName
)
{
  IGRint		size;

  __enterMethod ( name = "VDgetSetInfo" );

  *msg = MSSUCC;

  if( tblName )
  {
    *tblName = NULL;
    size = om$dimension_of( varray = me->tblName );
    *tblName = _MALLOC ( size, IGRchar );

    if( !*tblName )
    {
      printf("\nERROR : Dynamic allocation\n");
      __exit_error_Method ( name = "VDgetSetInfo" );
      return OM_E_NODYNMEM;
    }

    strcpy( *tblName, me->tblName );
  }

  __exitMethod ( name = "VDgetSetInfo" );

  return OM_S_SUCCESS;
}

/*------------------------------------------------------------------------*/

method  VDputSetInfo
(
  IGRlong  *msg;
  IGRchar  *tblName
)
{
  IGRint		size = 0;
  IGRlong		status = OM_S_SUCCESS;

  __enterMethod ( name = "VDputSetInfo" );

  *msg = MSSUCC;

  if( tblName )
  {
    size = strlen( tblName ) + 1;
    status = om$vla_set_dimension( varray	= me->tblName,
				   size		= size );
    as$status();
    if ( ! ( status & 1 ) ) { __print_goto ( "wrapup" ); goto wrapup; }

    strcpy( me->tblName, tblName );
  }

wrapup :

  __exitMethod ( name = "VDputSetInfo" );

  return status;
}

/*------------------------------------------------------------------------*/

method  VDisEmpty
(
  IGRlong 	*msg;
  IGRboolean  	*isEmpty
)
{
  int			count  = 0;
  IGRlong		status = OM_S_SUCCESS;
  OM_S_CHANSELECT	to_chan;

  __enterMethod ( name = "VDisEmpty" );

  *msg = MSSUCC;

  status = om$make_chanselect (	channame	= "VDitemSet.to_items",
				p_chanselect	= &to_chan );
  as$status( action = GOTO_VALUE, value = wrapup );

  status = om$get_channel_count (  objid        = my_id,
                                   p_chanselect = &to_chan,
                                   count        = (OMuint *) &count );
  as$status();

  *isEmpty = (count == 0);

wrapup:

  __exitMethod ( name = "VDisEmpty" );

  return status;
}

/*------------------------------------------------------------------------*/

method	VDdisconDelItmObj
(
  IGRlong	*msg;
  struct GRid	 itmObj
)
{
  IGRint		n, size;
  char			*ItemNum = NULL;
  IGRlong		status = OM_S_SUCCESS;

  struct GRmd_env	md_env;
  OM_S_CHANSELECT	to_chan, from_chan;

  __enterMethod ( name = "VDdisconDelItmObj" );

  *msg = MSSUCC;

  /* get the item number */

  status = om$send( msg           = message VDitem.VDgetItemInfo(
							msg,
							&ItemNum,
							NULL ),
                      targetid      = itmObj.objid,
                      targetos      = itmObj.osnum );

  _FREE ( ItemNum );

  as$status();
  if ( ! ( status & 1 ) )
  {
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  /* form the channels */

  status = om$make_chanselect ( channame       = "VDitem.to_bomset",
                                p_chanselect   = &to_chan );
  as$status( action = GOTO_VALUE, value = wrapup );

  status = om$make_chanselect ( channame       = "VDitemSet.to_items",
                                p_chanselect   = &from_chan );
  as$status( action = GOTO_VALUE, value = wrapup );


  /* disconnect the item object */
  status = om$send( msg	= message Root.disconnect( to_chan,
						   my_id,
						   OM_Gw_current_OS,
						   from_chan ),
		    targetid	= itmObj.objid,
		    targetos	= itmObj.osnum );

  as$status();
  if ( ! ( status & 1 ) )
  {
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  /* get current module environment */

  size = sizeof( struct GRmd_env );
  status = gr$get_module_env (	msg    = msg,
				sizbuf = &size,
				buffer = &md_env,
				nret   = &n );

  as$status( action = GOTO_VALUE, value = wrapup );

  md_env.md_id.osnum = itmObj.osnum;

  /* now erase the item number and delete it */

  status = om$send (	msg	 = message NDnode.NDdisplay( 0, GRbehe, &md_env ),
			targetid = itmObj.objid,
			targetos = itmObj.osnum );
  as$status();

  status = om$send (	msg	 = message GRgraphics.GRdelete( msg, &md_env ),
			targetid = itmObj.objid,
			targetos = itmObj.osnum );
  as$status();
		     
wrapup :

  __exitMethod ( name = "VDdisconDelItmObj" );

  return status;
}

end implementation VDitemSet;
