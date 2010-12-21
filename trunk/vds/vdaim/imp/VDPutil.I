/* $Id:*/

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdproot /
 *
 * Description:
 *
 * Dependencies:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *	10/3/95		MSM		creation
 *	8/20/96		MSM		Modification to GetFileId due to ship
 *					revisioning.
 *	9/19/96		MSM		IsPmeEnabled() implementation
 *	10/03/96	MSM		Fix TR# 179603132. Mark Delete Compartment.
 *	10/03/96	MSM		Wrote function to get file state.
 *  10/07/96    MRA     Added function to check if default PME
 *                      has been set in the current os.
 *   Aug 07 1998 SSR    Added new functions for SIR
 *                      VDPGetMdCxId, ConnectAIM, WhichAim.
 *   Sep 24 1998 SSR    CR # 179801396 Replacement of ROUTE equipments
 *   Oct 15 1998 SSR    Added VDPPutAimName VDPGetAimName. to get server
 * -------------------------------------------------------------------*/

class implementation VDPRoot ;


/*#define vaimDEBUG
#define vaimerrDEBUG*/


#include <stdio.h>
#include "string.h"

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exdef.h"
#include "exmacros.h"

#include "v_miscmacros.h"
#include "vadbgmacros.h"
#include "v_datamacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "PDUstr.h"

#include "VDPtrTbl.h"
#include "VDPdm2.h"
#include "msmacros.h"
#include "execmsg.h"

#include "VDPdef.h"

from VDPtrTbl 		import VDPAddtoTrTable;
from VDPenabObj		import VDPIsObjEnabled;
from ACrg_collect 	import ACget_named_attribute,
			       ACmod_list_attribute;

extern struct PDUrefresh        *refresh;

/*+fi
  Internal Function VDPPmeDelete()

  Abstract
	This functions does the necessary processing in order to 
	delete a PME enabled object.

  Algorithm

  Returns
        Successful Return               OM_S_SUCCESS.

 * 22 May 2003 - Art Hundiak
 *               Some reformating while testing
 *               Forced it to always return success
 *
-fi*/

IGRint VDPPmeDelete(IGRlong *msg, struct GRid Obj, IGRboolean is_comp)
{
  IGRlong    status = OM_S_SUCCESS;
  OMuword    curOs;
  IGRboolean flag=FALSE;
  struct     GRid EnabId, TrTblId;
  struct     VDPtrObjList TrRow;

  SetProc ( VDPPmeDelete ); Begin

  *msg = MSSUCC;

  /* Verify if the Object is from the current design file */
  ex$get_cur_mod( osnum = &curOs );
  if( curOs != Obj.osnum ) goto wrapup;

  /* --------------------------------------------
   * Call the new function here, otherwise a list
   * is always created if one does not exist
   */
  VDPaimGetEnabledItemListObject(curOs,0,&EnabId);
  if (EnabId.objid == NULL_OBJID) goto wrapup;

  /* Check if the Object is enabled */
  __DBGpr_obj ( "Object to be Deleted ", Obj );
  status =
        _VD_SEND_OBJN ( EnabId, VDPenabObj.VDPIsObjEnabled (
                                        msg, Obj.objid, &flag) );
  CheckRC ( status, *msg );
  __DBGpr_int("Object Enabled ?", flag );

  if ( flag == TRUE )	/* If enabled */
  {

    /* PME disable Object */
    status = VDPDisableObject( msg, Obj );
    CheckRC ( status, *msg );

    /* Get the Transaction List Id */
    status = VDPGetTrTblId( msg, &TrTblId );
    CheckRC ( status, *msg );
    __DBGpr_obj ( "Transacion List Id ", TrTblId );

    /* Fill the Structure with info */
    if( is_comp == TRUE ) TrRow.ActionCode = VDP_DEL_COMP;
    else                  TrRow.ActionCode = VDP_DELETE;

    TrRow.VDSobjid   = Obj.objid;
    TrRow.oldVDSobjid   = 0;
    TrRow.PMEobid[0] = '\0';

    status = _VD_SEND_OBJN (TrTblId,VDPtrTbl.VDPAddtoTrTable (msg, TrRow));
    __CheckRC( status, *msg, "VDPtrTbl.VDPAddtoTrTable", wrapup);
  }

wrapup:
  End
/* This is called from VDroot recompute
 * never want it to mess things up
 * with bad returns
	return status;
 */
  *msg = MSSUCC;
  return OM_S_SUCCESS;
}

/*+fi
  Internal Function VDPPmeUpdate()

  Abstract
	This functions does the necessary processing when a PME enabled
	object is updated.

  Algorithm

  Returns
        Successful Return               OM_S_SUCCESS.

-fi*/


IGRint VDPPmeUpdate(IGRlong    *msg, 
		    struct GRid	OldObj, 
		    struct GRid NewObj)
{
  IGRlong    status = OM_S_SUCCESS;
  OMuword    curOs;
  IGRboolean flag=FALSE;
  struct     GRid         EnabId, TrTblId;
  struct     VDPtrObjList TrRow;

  SetProc ( VDPPmeUpdate ); Begin

  __DBGpr_obj( "Old Object Id ", OldObj );
  __DBGpr_obj( "New Object Id ", NewObj );

  if( NewObj.objid == NULL_OBJID) NewObj.objid = OldObj.objid;

  /* Verify if the Object is from the current design file */
  ex$get_cur_mod( osnum = &curOs );
  if(curOs != OldObj.osnum || curOs != NewObj.osnum) goto wrapup;

  /* Get the Enabled List */
  /* --------------------------------------------
   * Call the new function here, otherwise a list
   * is always created if one does not exist
   */
  VDPaimGetEnabledItemListObject(curOs,0,&EnabId);
  if (EnabId.objid == NULL_OBJID) goto wrapup;

  /* Check if the Object is enabled */
  status =
    _VD_SEND_OBJN ( EnabId, VDPenabObj.VDPIsObjEnabled (
                                        msg, NewObj.objid, &flag) );
  CheckRC ( status, *msg );

  if (flag != TRUE) goto wrapup;

  /* Get the Transaction List Id */
  status = VDPGetTrTblId( msg, &TrTblId );
  __DBGpr_obj( "Trans List Id ", TrTblId );
  CheckRC ( status, *msg );

  /* --------------------------------------------
   * Fill the Structure with info 
   * If the Object is the same as the new Object then the object's
   * are being modified.
   * Else the object is being replaced. 
   */
  if( OldObj.objid == NewObj.objid )
  {
    TrRow.ActionCode = VDP_MODIFY;

    TrRow.VDSobjid    = OldObj.objid;
    TrRow.oldVDSobjid = NewObj.objid;
    TrRow.PMEobid[0]  = '\0';

    __DBGpr_int( " VDPutil:TrRow.ActionCode ", TrRow.ActionCode );
    status = _VD_SEND_OBJN ( TrTblId, VDPtrTbl.VDPAddtoTrTable (msg,TrRow));
    __CheckRC( status, *msg, "VDPtrTbl.VDPAddtoTrTable", wrapup);
  
   }  // end modify case
   else
   {
     /* -----------------------------------------
      * This looks pretty screwed up
      * Leave it alone for now
      */
     //TrRow.ActionCode = VDP_REPLACE;
     TrRow.ActionCode = VDP_CREATE;

     status = _VD_SEND_OBJN(EnabId, VDPenabObj.VDPIsObjEnabled (
                                        msg, OldObj.objid, &flag) );
     CheckRC ( status, *msg );
     __DBGpr_obj( " object in picture ", OldObj );
     __DBGpr_int( " enable flag ", flag );
     VDPPmeEnable ( msg, OldObj, NULL );

   }  // end replace case

wrapup:
  End
  /* Always succede to prevent messing up recomputes */
  *msg = MSSUCC;
  return OM_S_SUCCESS;

}

/*+fi
  Internal Function VDPPmeEnable()

  Abstract
	This functions does the necessary processing in order to 
	enable a PME enabled object.

  Algorithm

  Returns
        Successful Return               OM_S_SUCCESS.

-fi*/

IGRint	VDPPmeEnable( IGRlong	*msg, struct GRid Obj, IGRchar	*PMobid )
{
	IGRlong			status = OM_S_SUCCESS;
	OMuword			curOs;
	IGRboolean		flag=TRUE;
	struct	GRid		EnabId, TrTblId;
	struct	VDPtrObjList	TrRow;

	SetProc ( VDPPmeEnable ); Begin

        /* Initialize */
        memset(&TrRow,0,sizeof(struct VDPtrObjList));

	/* Verify if the Object is from the current design file */
        ex$get_cur_mod( osnum = &curOs );
        if( curOs != Obj.osnum )
                goto wrapup;

	/* Get the Enabled List */

	EnabId.objid = NULL_OBJID;
        status = VDPGetEnabledListId( msg, curOs, &EnabId );
	__DBGpr_obj ( "Enabled List Id ", EnabId );
	if( PMobid )
	__DBGpr_str ( "PMObid ", PMobid );

	/* Check if the Object is enabled */
        status =
        _VD_SEND_OBJN ( EnabId, VDPenabObj.VDPIsObjEnabled (
                                        msg, Obj.objid, &flag) );
        CheckRC ( status, *msg );
	__DBGpr_int("Object Enabled ?", flag );

	if ( flag == FALSE )	/* If not enabled */
	{
		/* PME enable Object */

		status = VDPEnableObject( msg, Obj );
		CheckRC ( status, *msg );

		/* Get the Transaction List Id */

		status = VDPGetTrTblId( msg, &TrTblId );
		CheckRC ( status, *msg );
		__DBGpr_obj ( "Transacion List Id ", TrTblId );

		/* Fill the Structure with info */

		if( !PMobid || PMobid[0] == 0 )
		    TrRow.ActionCode = VDP_CREATE;
		else 
		    TrRow.ActionCode = VDP_FRPLLST;

		__DBGpr_com(" After Action Code ");

		TrRow.VDSobjid   = Obj.objid;
		TrRow.oldVDSobjid = 0;

		if (PMobid)
			strcpy(TrRow.PMEobid, PMobid) ;

		status =
		_VD_SEND_OBJN ( TrTblId, VDPtrTbl.VDPAddtoTrTable (
						msg, TrRow ) );
		__CheckRC( status, *msg, "VDPtrTbl.VDPAddtoTrTable", wrapup);
	}

wrapup:
	End
	return status;
}

/*+fi
  Internal Function VDPGetPlacementContext()

  Abstract
        This function returns the placement context defined for the current file

  Algorithm

  Returns
        Successful Return               OM_S_SUCCESS.

-fi*/


IGRint  VDPGetPlacementContext( IGRlong  *msg, IGRchar  *PlacementCtx, IGRchar *ContextId )
{
    IGRlong             status = OM_S_SUCCESS;
    struct GRid         CollId;
    OMuword             curOs;
    IGRchar             DirName[DI_PATH_MAX];
    IGRchar             CollName[DI_PATH_MAX];
    struct ACrg_coll    coll;

    SetProc( VDPGetPlacementContext ); Begin

    ex$get_cur_mod( osnum = &curOs );

    /* get directory path name */
    status = di$give_pathname(  osnum           = curOs,
                                pathname        = DirName );
    CheckRC( status, 1 );
    __DBGpr_str( "Path name", DirName );

    sprintf( CollName,"%s%s%s", DirName, PME_GLOBAL_DIR, PME_REQ_DATA );
    __DBGpr_str( "Collector name", CollName );

    CollId.objid = NULL_OBJID;

    status = VDgetVdCollId ( msg, CollName, TRUE, FALSE, &CollId );
    CheckRC( status, *msg );
    if (!(status & *msg & 1) || CollId.objid == NULL_OBJID )
    {
        UI_status("Placement Context not Selected");
        return OM_E_ABORT;
    }
    strcpy( coll.name, VDP_PLCTX_NAME );
    status =
    _VD_SEND_OBJN( CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
    __DBGpr_str( "VDP_PLCTX_NAME", coll.desc.value.att_txt );

    strcpy( PlacementCtx, coll.desc.value.att_txt );

    strcpy( coll.name, VDP_PLCTX_ID );
    status =
    _VD_SEND_OBJN( CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
    __DBGpr_str( "VDP_PLCTX_ID", coll.desc.value.att_txt );

    strcpy( ContextId, coll.desc.value.att_txt );
    End
    return OM_S_SUCCESS;
}

/*+fi
  Internal Function VDPGetFileId()

  Abstract
        This function returns the PME file id for the file defined by osnum.

  Algorithm

  Returns
        Successful Return               OM_S_SUCCESS.

-fi*/



IGRint  VDPGetFileId( IGRlong  *msg, OMuword curOs, IGRchar  *FileId )
{
    IGRlong             status = OM_S_SUCCESS;
    struct GRid         CollId;
    IGRchar             DirName[DI_PATH_MAX], CollName[DI_PATH_MAX];
    IGRchar		OldFileId[VDPOBID_LEN],
    			NshipId[VDPOBID_LEN],
    			NShipName[VDPDESC_LEN],
    			NbwtCtxId[VDPOBID_LEN],
    			NplCtxId[VDPOBID_LEN];
    struct ACrg_coll    coll, coll1[5];
    static  IGRboolean	first = TRUE;
    OMuword		current_os;
    IGRint		fileState=0;
    IGRchar		errmsg[256];

    SetProc( VDPGetFileId ); Begin

    /* get directory path name */
    status = di$give_pathname(  osnum           = curOs,
                                pathname        = DirName );
    CheckRC( status, 1 );
    __DBGpr_str( "Path name", DirName );

    sprintf( CollName,"%s%s%s", DirName, PME_GLOBAL_DIR, PME_REQ_DATA );
    __DBGpr_str( "Collector name", CollName );

    CollId.objid = NULL_OBJID;

    status = VDgetVdCollId ( msg, CollName, TRUE, FALSE, &CollId );
    CheckRC( status, *msg );
    if (!(status & *msg & 1) || CollId.objid == NULL_OBJID )
    {
        UI_status("PME Required Data not set");
        return OM_E_ABORT;
    }
    __DBGpr_obj ( "Collector Id ", CollId );

    strcpy( coll.name, VDP_FILEID );
    status =
    _VD_SEND_OBJN( CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
    __DBGpr_str( "VDP_FILEID", coll.desc.value.att_txt );

    strcpy( OldFileId, coll.desc.value.att_txt );

    /* For now set the FileId the same as old file Id */

    __DBGpr_int( "First", first );

    ex$get_cur_mod( osnum = &current_os );
    
    /* First time query the database if the current file is revised */
    if ( first && current_os == curOs )
    {
	/* Is File revised */
	status = VDPIsFileRevised( msg, OldFileId, refresh->act_catalog, refresh->act_partid, refresh->act_revision, &fileState, FileId, NshipId, NbwtCtxId, NplCtxId, NShipName );

	if( !(status&1) )
	    goto wrapup;

/*	__CheckRC( status, *msg,"VDPIsFileRevised", wrapup ); */

	if (fileState == VDP_FILE_ACTIVE )
	    strcpy(FileId, OldFileId );
	else if (fileState == VDP_FILE_FROZEN )
	{
	/* If FILE_FROZEN pop up a box to the user asking him to revise the file
	   in PME 
	 */
            UI_status( "File is Frozen in PME; Should be revised" );
	}
	else if (fileState == VDP_PARENT_FILE_HAS_SUCCESSOR )
	{
	    strcpy(errmsg,"The parent design file already has a successor. Parent file cannot have multiple successors. ");
	    ex$message( msgnumb = EX_F_Var1, type = "%s", var=errmsg );
	}
	else if (fileState == VDP_FILE_REVISED )
	{
	}
	else if (fileState == VDP_UPDATE_FILEDATA )
	{

	/* Update PME with new catalog, part, rev */

/* Now we are not sending this message. Because the data is already updated
   in PME. 10/22/96
	    status = VDPUpdateFileId( msg, FileId, refresh->act_catalog, 
					refresh->act_partid, 
					refresh->act_revision, NShipName );
	    __CheckRC( status, *msg, "VDPUpdateFileId", wrapup );
	    __DBGpr_str( "File Id :", FileId );
*/

	/* If FILE_REVISED update the Default data with new file_id, ship_id,
	   bwt_id, plctx_id.  */

	    strcpy( coll1[0].name, VDP_FILEID );
	    coll1[0].desc.type = AC_ATTRIB_TEXT;
	    strcpy( coll1[0].desc.value.att_txt, FileId );

	    strcpy( coll1[1].name, VDP_SHIPID );
	    coll1[1].desc.type = AC_ATTRIB_TEXT;
	    strcpy( coll1[1].desc.value.att_txt, NshipId );

	    strcpy( coll1[2].name, VDP_PLCTX_ID );
	    coll1[2].desc.type = AC_ATTRIB_TEXT;
	    strcpy( coll1[2].desc.value.att_txt, NplCtxId );

	    strcpy( coll1[3].name, VDP_BDGCTX_ID );
	    coll1[3].desc.type = AC_ATTRIB_TEXT;
	    strcpy( coll1[3].desc.value.att_txt, NbwtCtxId );

	    strcpy( coll1[4].name, VDP_SHIPNAME );
	    coll1[4].desc.type = AC_ATTRIB_TEXT;
	    strcpy( coll1[4].desc.value.att_txt, NShipName );

	    status =
	    _VD_SEND_OBJN( CollId, ACrg_collect.ACmod_list_attribute(
							msg,
							5,
							coll1 ) );
	    CheckRC( status, *msg );
	    fileState = VDP_FILE_ACTIVE;

	}
	first = FALSE;
    }
    else
	strcpy( FileId, coll.desc.value.att_txt );
	

wrapup:
    End
    return status;
}

/*+fi
  Internal Function VDPGetBudgetCtxAndESWBS()

  Abstract
        This functions returns the budget weight context and ESWBS for the
 	current file.

  Algorithm

  Returns
        Successful Return               OM_S_SUCCESS.

-fi*/


IGRint  VDPGetBudgetCtxAndESWBS( IGRlong  *msg, IGRchar  *BdgCtx, IGRchar *ContextId, IGRchar  *ESWBS )
{
    IGRlong             status = OM_S_SUCCESS;
    struct GRid         CollId;
    OMuword             curOs;
    IGRchar             DirName[DI_PATH_MAX];
    IGRchar             CollName[DI_PATH_MAX];
    struct ACrg_coll    coll;

    SetProc( VDPGetBudgetCtxAndESWBS ); Begin

    ex$get_cur_mod( osnum = &curOs );

    /* get directory path name */
    status = di$give_pathname(  osnum           = curOs,
                                pathname        = DirName );
    CheckRC( status, 1 );
    __DBGpr_str( "Path name", DirName );

    sprintf( CollName,"%s%s%s", DirName, PME_GLOBAL_DIR, PME_REQ_DATA );
    __DBGpr_str( "Collector name", CollName );

    CollId.objid = NULL_OBJID;

    status = VDgetVdCollId ( msg, CollName, TRUE, FALSE, &CollId );
    CheckRC( status, *msg );
    if (!(status & *msg & 1) || CollId.objid == NULL_OBJID )
    {
        UI_status("BUDGET Context not Selected");
        return OM_E_ABORT;
    }
    strcpy( coll.name, VDP_BDGCTX_NAME );
    status =
    _VD_SEND_OBJN( CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
    __DBGpr_str( "VDP_BDGCTX_NAME", coll.desc.value.att_txt );

    strcpy( BdgCtx, coll.desc.value.att_txt );

    strcpy( coll.name, VDP_BDGCTX_ID );
    status =
    _VD_SEND_OBJN( CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
    __DBGpr_str( "VDP_BDGCTX_ID", coll.desc.value.att_txt );

    strcpy( ContextId, coll.desc.value.att_txt );

    strcpy( coll.name, VDP_ESWBS );
    status =
    _VD_SEND_OBJN( CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
    __DBGpr_str( "VDP_ESWBS", coll.desc.value.att_txt );

    strcpy( ESWBS, coll.desc.value.att_txt );
    End
    return OM_S_SUCCESS;
}

/*+fi
  Internal Function VDPCleanupfromanyCrash()

  Abstract
        This functions cleans up the DM2 database of any reserved items that 
	don't exist in the current file. This could have been caused due to 
 	items being reserved and then a crash might have occurred.

  Algorithm

  Returns
        Successful Return               OM_S_SUCCESS.

-fi*/

IGRint	VDPCleanupfromanyCrash( IGRlong		*msg )
{
    IGRlong             status = OM_S_SUCCESS;
    OMuword		curOs;
    IGRchar		FileId[VDPOBID_LEN];

    SetProc( VDPGetBudgetCtxAndESWBS ); Begin

    *msg = MSSUCC;

    /* Get the current osnum */
    ex$get_cur_mod( osnum = &curOs );

    /* Get the current file id */
    status = VDPGetFileId( msg, curOs, FileId );

    /* Get all the items that have been reserved in DM2 but not posted */

    /* Verify if these items are enabled in the design file */

    /* See if the items that are not enabled, are in translog and deleted */

    /* Send the list of items to be unplaced in DM2 */

    End
    return OM_S_SUCCESS;
}

/*+fi
  Internal Function VDPGetShipData()

  Abstract
	This function retrieves the Ship Id, Ship Name and Ship Desc
  from the collector.

  Algorithm

  Returns
        Successful Return               OM_S_SUCCESS.

-fi*/

IGRint  VDPGetShipData( IGRlong  *msg, struct VDPShipDesc  *ShipDesc )
{
    IGRlong             status = OM_S_SUCCESS;
    struct GRid         CollId;
    OMuword             curOs;
    IGRchar             DirName[DI_PATH_MAX];
    IGRchar             CollName[DI_PATH_MAX];
    struct ACrg_coll    coll;

    SetProc( VDPGetShipData ); Begin

    ex$get_cur_mod( osnum = &curOs );

    /* get directory path name */
    status = di$give_pathname(  osnum           = curOs,
                                pathname        = DirName );
    CheckRC( status, 1 );
    __DBGpr_str( "Path name", DirName );

    sprintf( CollName,"%s%s%s", DirName, PME_GLOBAL_DIR, PME_REQ_DATA );
    __DBGpr_str( "Collector name", CollName );

    CollId.objid = NULL_OBJID;

    status = VDgetVdCollId ( msg, CollName, TRUE, FALSE, &CollId );
    CheckRC( status, *msg );
    if (!(status & *msg & 1) || CollId.objid == NULL_OBJID )
    {
        UI_status("Default data not Set");
        return OM_E_ABORT;
    }
    strcpy( coll.name, VDP_SHIPNAME );
    status =
    _VD_SEND_OBJN( CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
    __DBGpr_str( "VDP_SHIPNAME", coll.desc.value.att_txt );

    strcpy( ShipDesc->ShipName, coll.desc.value.att_txt );

    strcpy( coll.name, VDP_SHIPDESC );
    status =
    _VD_SEND_OBJN( CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
    __DBGpr_str( "VDP_SHIPDESC", coll.desc.value.att_txt );
    strcpy( ShipDesc->ShipDesc, coll.desc.value.att_txt );

    strcpy( coll.name, VDP_SHIPID );
    status =
    _VD_SEND_OBJN( CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
    __DBGpr_str( "VDP_SHIPID", coll.desc.value.att_txt );
    strcpy( ShipDesc->ShipId, coll.desc.value.att_txt );

    End
    return OM_S_SUCCESS;

}

IGRint	VDPisObjPmeEnabled( IGRlong *msg, struct GRid Obj, IGRboolean *flag )
{ 
    IGRlong                 status = OM_S_SUCCESS;
    OMuword                 curOs;
    struct  GRid            EnabId; 

    SetProc( VDPisObjPmeEnabled ); Begin

    /* Verify if the Object is from the current design file */
    ex$get_cur_mod( osnum = &curOs );

    /* Get the Enabled List */

    EnabId.objid = NULL_OBJID;
    status = VDPGetEnabledListId( msg, curOs, &EnabId );
    __DBGpr_obj ( "Enabled List Id ", EnabId );

    /* Check if the Object is enabled */
    __DBGpr_obj ( "Object ", Obj );
    *flag = FALSE;
    status =
    _VD_SEND_OBJN ( EnabId, VDPenabObj.VDPIsObjEnabled (
			msg, Obj.objid, flag) );
    CheckRC ( status, *msg );
    __DBGpr_int("Object Enabled ?", *flag );

    End
    return OM_S_SUCCESS;
}
IGRint  VDPGetFileState( IGRlong  *msg, OMuword curOs, IGRint  *fileState )
{
    IGRlong             status = OM_S_SUCCESS;
    struct GRid         CollId;
    IGRchar             DirName[DI_PATH_MAX], CollName[DI_PATH_MAX];
    IGRchar		OldFileId[VDPOBID_LEN],
    			FileId[VDPOBID_LEN],
    			NshipId[VDPOBID_LEN],
    			NShipName[VDPDESC_LEN],
    			NbwtCtxId[VDPOBID_LEN],
    			NplCtxId[VDPOBID_LEN];
    struct ACrg_coll    coll, coll1[5];
    OMuword		current_os;
    IGRchar		errmsg[256];

    SetProc( VDPGetFileState ); Begin

    *fileState = 0;
    /* get directory path name */
    status = di$give_pathname(  osnum           = curOs,
                                pathname        = DirName );
    CheckRC( status, 1 );
    __DBGpr_str( "Path name", DirName );

    sprintf( CollName,"%s%s%s", DirName, PME_GLOBAL_DIR, PME_REQ_DATA );
    __DBGpr_str( "Collector name", CollName );

    CollId.objid = NULL_OBJID;

    status = VDgetVdCollId ( msg, CollName, TRUE, FALSE, &CollId );
    CheckRC( status, *msg );
    if (!(status & *msg & 1) || CollId.objid == NULL_OBJID )
    {
        UI_status("PME Required Data not set");
        return OM_E_ABORT;
    }
    __DBGpr_obj ( "Collector Id ", CollId );

    strcpy( coll.name, VDP_FILEID );
    status =
    _VD_SEND_OBJN( CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
    __DBGpr_str( "VDP_FILEID", coll.desc.value.att_txt );

    strcpy( OldFileId, coll.desc.value.att_txt );

    ex$get_cur_mod( osnum = &current_os );
    
    /* First time query the database if the current file is revised */
    /* Is File revised */
    status = VDPIsFileRevised( msg, OldFileId, refresh->act_catalog, refresh->act_partid, refresh->act_revision, fileState, FileId, NshipId, NbwtCtxId, NplCtxId, NShipName );

/*
    __DBGpr_str( "ShipName ", NShipName );
    __DBGpr_str( "FileId ", FileId );
    __DBGpr_str( "BWT CTX ", NbwtCtxId );
    __DBGpr_str( "plCtx ", NplCtxId );
    __DBGpr_str( "ShipId ", NshipId );
*/
    if (! (status & 1))
	goto wrapup;

    __CheckRC( status, *msg, "VDPIsFileRevised", wrapup );

    __DBGpr_int( "FileState", *fileState );
    if (*fileState == VDP_FILE_ACTIVE )
	strcpy(FileId, OldFileId );
    else if (*fileState == VDP_FILE_FROZEN )
    {
	/* If FILE_FROZEN pop up a box to the user asking him to revise the file
	   in PME 
	 */
            UI_status( "File is Frozen in PME; Should be revised" );
	    return OM_S_SUCCESS;
    }
    else if (*fileState == VDP_PARENT_FILE_HAS_SUCCESSOR )
    {
        strcpy(errmsg,"The parent design file already has a successor. Parent file cannot have multiple successors. ");
        ex$message( msgnumb = EX_F_Var1, type = "%s", var=errmsg );
	return OM_E_ABORT;
    }
    else if (*fileState == VDP_FILE_REVISED )
    {
    }
    else if (*fileState == VDP_UPDATE_FILEDATA )
    {
	/* Update PME with new catalog, part, rev */
/*
	status = VDPUpdateFileId( msg, FileId, refresh->act_catalog, 
					refresh->act_partid, 
					refresh->act_revision, NShipName );
	__CheckRC( status, *msg, "VDPUpdateFileId", wrapup );
	__DBGpr_int ("msg ", *msg );
	__DBGpr_int ("status ", status );

	if(*msg == MSFAIL)
	{
	    *msg = MSSUCC; 
			  
	    __DBGpr_com(" Update msg returned MSFAIL" );
	    return OM_S_SUCCESS;
	}
*/
	__DBGpr_str( "File Id :", FileId );

	/* If FILE_REVISED update the Default data with new file_id, ship_id,
	   bwt_id, plctx_id.  */

	strcpy( coll1[0].name, VDP_FILEID );
	coll1[0].desc.type = AC_ATTRIB_TEXT;
	strcpy( coll1[0].desc.value.att_txt, FileId );

	strcpy( coll1[1].name, VDP_SHIPID );
	coll1[1].desc.type = AC_ATTRIB_TEXT;
	strcpy( coll1[1].desc.value.att_txt, NshipId );

	strcpy( coll1[2].name, VDP_PLCTX_ID );
	coll1[2].desc.type = AC_ATTRIB_TEXT;
	strcpy( coll1[2].desc.value.att_txt, NplCtxId );

	strcpy( coll1[3].name, VDP_BDGCTX_ID );
	coll1[3].desc.type = AC_ATTRIB_TEXT;
	strcpy( coll1[3].desc.value.att_txt, NbwtCtxId );

	strcpy( coll1[4].name, VDP_SHIPNAME );
	coll1[4].desc.type = AC_ATTRIB_TEXT;
	strcpy( coll1[4].desc.value.att_txt, NShipName );

	status =
	_VD_SEND_OBJN( CollId, ACrg_collect.ACmod_list_attribute(
							msg,
							5,
							coll1 ) );
	CheckRC( status, *msg );
	*fileState = VDP_FILE_ACTIVE;
    }

wrapup:
    End
    return status;
}

/*+fi
  Internal function VDPIsPmeDataSet

  Abstract
  This function checks if default PME data has been set for the current
  object space( design file ).

  Algorithm

  Return Value
    Returns TRUE        - if default PME data is already set.
    Returns FALSE       - if default PME data is not set.
    Returns an errror   - if an error was encountered during processing.
               value
-fi*/

VDPIsPmeDataSet( IGRlong *msg )
{
   IGRboolean          ReqExist=FALSE;
   OMuword             curOs;
   IGRchar             DirName[DI_PATH_MAX],
                       ReqName[DI_PATH_MAX];
   IGRlong             status = OM_S_SUCCESS;
   struct GRid         Buf;

   *msg = MSSUCC;

   ex$get_cur_mod( osnum = &curOs );

   /* get directory path name */
   status = di$give_pathname( osnum           = curOs,
                              pathname        = DirName );
   CheckRC( status, 1 );

   sprintf( ReqName,"%s%s%s", DirName, PME_GLOBAL_DIR, PME_REQ_DATA );

   status =
   di$translate( objname = ReqName,
                 p_objid = &Buf.objid,
                 p_osnum = &Buf.osnum );

   if( status == DIR_S_SUCCESS )
    ReqExist = TRUE;
   else
    ReqExist = FALSE;

   if( ReqExist == TRUE )
    return TRUE;

   return FALSE;
}

IGRint  VDPGetMdCxId( IGRlong  *msg, OMuword curOs, IGRchar  *MdCxId )
{
   IGRchar             DirName[DI_PATH_MAX], CollName[DI_PATH_MAX];
   struct GRid         CollId;
   IGRlong             status = OM_S_SUCCESS;
   struct ACrg_coll    coll;

    SetProc( VDPGetMdCxId ); Begin

    /* get directory path name */
    status = di$give_pathname(  osnum           = curOs,
                                pathname        = DirName );
    CheckRC( status, 1 );
    __DBGpr_str( "Path name", DirName );

    sprintf( CollName,"%s%s%s", DirName, SIR_GLOBAL_DIR, SIR_REQ_DATA );
    __DBGpr_str( "Collector name", CollName );

    CollId.objid = NULL_OBJID;

    status = VDgetVdCollId ( msg, CollName, TRUE, FALSE, &CollId );
    CheckRC( status, *msg );
    if (!(status & *msg & 1) || CollId.objid == NULL_OBJID )
    {
        UI_status("SIR Required Data not set");
        return OM_E_ABORT;
    }
    __DBGpr_obj ( "Collector Id ", CollId );


    strcpy( coll.name, SIR_MODCX_ID );
    status =
    _VD_SEND_OBJN( CollId, ACrg_collect.ACget_named_attribute( msg, &coll ));
    __DBGpr_str( "SIR_MODCX_ID", coll.desc.value.att_txt );

    strcpy( MdCxId, coll.desc.value.att_txt );


wrapup:
    End
    return status;

}

IGRint VDPGetBinItemFromCollector(IGRlong *msg, OMuword curOs, char *item, int *results)
{
  IGRlong	status = OM_S_SUCCESS;
  IGRchar	DirName[DI_PATH_MAX], CollName[DI_PATH_MAX];
  struct GRid   DirId, CollId;
  struct ACrg_coll     coll;

  SetProc(VDPGetItemFromCollector); Begin

  __DBGpr_com("Inside AIMGetItemFromCollector");

   /* get directory path name */
  di$give_pathname(osnum = curOs, pathname = DirName ); 
  __DBGpr_str( "Path name", DirName );

  sprintf( CollName,"%s%s%s", DirName, SIR_GLOBAL_DIR, SIR_REQ_DATA );
  __DBGpr_str( "Collector name", CollName );

  CollId.objid = NULL_OBJID;

  status = VDgetVdCollId ( msg, CollName, TRUE, FALSE, &CollId );
  CheckRC( status, *msg );

  if (!(status & *msg & 1) || (CollId.objid == NULL_OBJID ) )
  {
	UI_status("SIR Required Data not set");
	return OM_E_ABORT;
  }
  __DBGpr_obj( " Collector Id ", CollId );

  __DBGpr_str( "item = ", item ); 
  strcpy( coll.name, item );
  __DBGpr_str( "coll.name = ", coll.name ); 

/*
  __DBGpr_int( "exp = ", exp ); 
  if ( exp == 2 )
  {
  	__DBGpr_com( "setting type"); 
	coll.desc.type= AC_ATTRIB_DOUBLE;	
  	__DBGpr_com( "after setting type"); 
  }
*/

  status = _VD_SEND_OBJN( CollId, ACrg_collect.ACget_named_attribute( msg, &coll )); 

//  if ( exp == 2)
//  {
  	__DBGpr_int( "Collector Item:", coll.desc.value.att_exp ); 
	*results = coll.desc.value.att_exp;
  	__DBGpr_int( "results:", *results ); 
//  }


  wrapup:
	End
	return status;
}



IGRint VDPGetAsciiItemFromCollector(IGRlong *msg, OMuword curOs, char *item, char *results)
{
  IGRlong	status = OM_S_SUCCESS;
  IGRchar	DirName[DI_PATH_MAX], CollName[DI_PATH_MAX];
  struct GRid   DirId, CollId;
  struct ACrg_coll     coll;

  SetProc(VDPGetItemFromCollector); Begin

  __DBGpr_com("Inside AIMGetItemFromCollector");

   /* get directory path name */
  di$give_pathname(osnum = curOs, pathname = DirName ); 
  __DBGpr_str( "Path name", DirName );

  sprintf( CollName,"%s%s%s", DirName, SIR_GLOBAL_DIR, SIR_REQ_DATA );
  __DBGpr_str( "Collector name", CollName );

  CollId.objid = NULL_OBJID;

  status = VDgetVdCollId ( msg, CollName, TRUE, FALSE, &CollId );
  CheckRC( status, *msg );

  if (!(status & *msg & 1) || (CollId.objid == NULL_OBJID ) )
  {
	UI_status("SIR Required Data not set");
	return OM_E_ABORT;
  }
  __DBGpr_obj( " Collector Id ", CollId );

  __DBGpr_str( "item = ", item ); 
  strcpy( coll.name, item );
  __DBGpr_str( "coll.name = ", coll.name ); 

  status = _VD_SEND_OBJN( CollId, ACrg_collect.ACget_named_attribute( msg, &coll )); 

  __DBGpr_str( "Collector Item:", coll.desc.value.att_txt ); 
  strcpy(results, coll.desc.value.att_txt );
  __DBGpr_str( "results:", results ); 
  
  wrapup:
	End
	return status;
}
end implementation VDPRoot;
