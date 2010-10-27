/* $Id $ */

/* I/VDS
 *
 * File:        vdannot/imp/VDitemMgri.I
 *
 * Description:
 *
 *      VDitemMgr implementation - 
 *		methods:  VDconnectItmObjs, VDcleanUp
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDitemMgri.I,v $
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
# Revision 1.3  1995/08/18  22:54:12  pinnacle
# Replaced: vdannot/imp/VDitem*I for:  by jwfrosch for vds.240
#
# Revision 1.2  1995/07/25  22:47:14  pinnacle
# Replaced: vdannot/imp/* for:  by jwfrosch for vds.240
#
# Revision 1.1  1995/07/13  14:38:12  pinnacle
# Created: vdannot/imp/VDitemMgri.I by jwfrosch for vds.240
#
 *
 * History:
 *
 *	6/15/95		tlb	Creation from VDmgrCleanUp.I, VDmgrConItm.I
 */

class implementation VDitemMgr;

#include <stdio.h>
#include "OMmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "string.h"
#include "go.h"
#include "msdef.h"
#include "asbox.h"
#include "AS_status.h"
#include "v_miscmacros.h"

#define VD_DEBUG

#include "VDdebug.h"

from	GRconnector	import	GRdisconn,
				GRflexconn;
from	VDitemSet	import	VDgetSetInfo,
				VDputSetInfo,
				VDisEmpty;

extern GRclassid	OPP_VDitemSet_class_id;

/*------------------------------------------------------------------------*/

method VDcleanUp( IGRlong *msg )
{
  IGRint		i, count = 0;
  IGRboolean		isEmpty;
  struct GRid		ownerId, *SetLst = NULL;

  IGRlong		status = OM_S_SUCCESS;

  __enterMethod ( name = "VDcleanUp" );

    *msg = MSSUCC;

    /*
     * get the VDitemSets from the components channel
     */

    ownerId.objid = my_id;
    ownerId.osnum = OM_Gw_current_OS;

    status = VDGetGridsFromChan_of_Class ( msg, ownerId, &AS_to_comp, OPP_VDitemSet_class_id, &count, &SetLst );

    if( !count )
        goto wrapup;

    __printf("VDitemMgr.VDcleanUp : channel count = %d", count );
      
    /*
     * if any of the VDitemSet's is empty, disconnect and delete it
     */

    for( i = 0 ; i < count ; i++ )
    {
        status = om$send( msg	= message VDitemSet.VDisEmpty( msg, &isEmpty ),
			  targetid	= SetLst[i].objid,
			  targetos	= SetLst[i].osnum );
        as$status();

        if( isEmpty )
        {

	  __printf("VDcleanUp : <%d,%d> is being deleted", `SetLst[i].objid, SetLst[i].osnum` );

            status = om$send( msg	= message GRconnector.GRdisconn( msg, &ownerId ),
			      targetid	= SetLst[i].objid,
			      targetos	= SetLst[i].osnum );
            as$status();

            status = om$send( msg	= message Root.delete( 0 ),
			      targetid	= SetLst[i].objid,
			      targetos	= SetLst[i].osnum );
            as$status();
        }
    }
     
wrapup :

    _FREE ( SetLst );

  __exitMethod ( name = "VDcleanUp" );

    return status;
}

/*------------------------------------------------------------------------*/

method  VDconnectItmObjs
(
  IGRlong       *msg;
  char		*TblName;
  IGRint         nbObjs;
  struct GRid   *itmObjs
)
{
  IGRint		 i, j, count = 0, found_itemSet = 0, idx = -1;
  IGRchar		*curTblName = NULL;
  IGRlong		 status = OM_S_SUCCESS, flag = 1, index	= OM_K_MAXINT;
  struct GRid		 MgrId, new_setId,
			*SetLst = NULL;
  OM_S_CHANSELECT	 to_chan, from_chan;

  __enterMethod ( name = "VDconnectItmObjs" );

  __printf ( "nbObjs = %d, TblName = <%s>", `nbObjs, TblName` );

  for ( i=0; i < nbObjs; i++ )
  {
    __printf ( "itmObjs[%d] = [%d,%d]", `itmObjs[i].osnum, itmObjs[i].objid` );
  }
    
    *msg = MSSUCC;
    MgrId.objid = my_id;
    MgrId.osnum = OM_Gw_current_OS;

    /*
     * Form the channels
     */
    status = om$make_chanselect( channame	= "VDitem.to_bomset",
				 p_chanselect	= &from_chan );
    as$status( action = GOTO_VALUE, value = wrapup );

    status = om$make_chanselect( channame	= "VDitemSet.to_items",
				 p_chanselect	= &to_chan );
    as$status( action = GOTO_VALUE, value = wrapup );

RETRY:

    /*
     * get the VDitemSets from the components channel of the VDitemMgr
     */

    status = VDGetGridsFromChan_of_Class ( msg, MgrId, &AS_to_comp, OPP_VDitemSet_class_id, &count, &SetLst );

    __printf("VDitemMgr.VDconnectItmObjs : count = %d", count );

    for( i = 0 ; i < count ; i++ )
    {
	_FREE ( curTblName );

	status = om$send( msg       = message VDitemSet.VDgetSetInfo( msg, &curTblName),
			  targetid  = SetLst[i].objid,
			  targetos  = SetLst[i].osnum );
	as$status();

	/*
	 * Check if the VDitemSet already exists 
	 * If not, it has to be created ....
	 */
	if( ! strcmp( TblName, curTblName ) )
	{
	    found_itemSet = TRUE;
	    idx = i;
	    break;
	}
    }

    /*
     * Construct a new VDitemSet, if necessary (because it does not yet exist)
     */

    if ( ! count || ! found_itemSet )
    {
	new_setId.objid = NULL_OBJID;
	status =
	om$construct (	classid       = OPP_VDitemSet_class_id,
			p_objid       = &new_setId.objid );
	as$status( action = GOTO_VALUE, value = wrapup );

	if ( new_setId.objid == NULL_OBJID ) goto wrapup;
	new_setId.osnum = OM_Gw_current_OS;

	__printf ( "new_setId[%d] = [%d,%d]", `new_setId.osnum, new_setId.objid` );

	/*
	 * Connect the object to the manager.
	 */

	status =
	_VD_SEND_OBJN(	new_setId,
			GRconnector.GRflexconn( msg, &flag, &MgrId, &index, &index ));
	as$status( action = GOTO_VALUE, value = wrapup );

	status = om$send( msg       = message VDitemSet.VDputSetInfo( msg,
							TblName),
			  targetid  = new_setId.objid,
			  targetos  = new_setId.osnum );
	as$status( action = GOTO_VALUE, value = wrapup );

	_FREE ( SetLst );

	goto RETRY;
    }

    /*
     * Connect the objects
     */
    for( i = 0 ; i < nbObjs ; i++ )
    {
	/*
	 * If NULL_OBJID, continue
	 */
	if( itmObjs[i].objid == NULL_OBJID )
	    continue;

	/*
	 * Find correct VDitemSet
	 */
	for( j = 0 ; j < count ; j++ )
	{
	    _FREE ( curTblName );

	    status = om$send( msg       = message VDitemSet.VDgetSetInfo( msg,
								&curTblName),
			      targetid  = SetLst[j].objid,
			      targetos  = SetLst[j].osnum );
	    as$status();

	    /*
	     * Check if this is the required VDitemSet
	     */
	    if( ! strcmp( TblName, curTblName ) )
	    {
		/* connect the object */
		status = om$send( msg		= message Root.connect( 
							to_chan, 0,
							itmObjs[i].objid,
							itmObjs[i].osnum,
							from_chan, 0 ),
			      	  targetid  	= SetLst[j].objid,
			      	  targetos  	= SetLst[j].osnum );
		as$status();
		break;
	    }    
	}
    }

wrapup :

    _FREE ( curTblName );
    _FREE ( SetLst );

  __exitMethod ( name = "VDconnectItmObjs" );

    return status;
}

end implementation VDitemMgr;
