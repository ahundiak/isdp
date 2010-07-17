/* $Id: VSmopBeamCmd.I,v 1.1 2001/01/17 00:10:46 ramarao Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vscmdsup/VSmopBeamCmd.I
 *
 * Description: Modify Operator Command Object for Beams
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmopBeamCmd.I,v $
 *      Revision 1.1  2001/01/17 00:10:46  ramarao
 *      *** empty log message ***
 *
# Revision 1.2  2000/06/07  16:00:36  pinnacle
# Replaced: struct/vscmdsup/VSmopBeamCmd.I for:  by mdong for Service Pack
#
# Revision 1.1  2000/06/01  15:22:40  pinnacle
# Created: struct/vscmdsup/VSmopBeamCmd.I by mdong for Service Pack
#
 *
 * History:
 * MM/DD/YY  	AUTHOR  	DESCRIPTION
 * 05/03/00  	Ming      	Creation
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDvla2.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDfrm.h"

#include "v_miscmacros.h"
#include "dpmacros.h"

#include "nddef.h"
#include "ndmacros.h"

#include "VDppl1.h"
#include "VSmop.h"
#include "VSmopCmd.h"
#include "VSmopBeamCmd.h"

static TVSmopCmdInfo *cmdInfo;

#define theCommand "Modify Beam Operator"
#define InsertErrorMessagr "Insertion position for new beam is incorrect. Insertion rejected!"

from ACpretend    import ACgive_downscan;
from NDnode       import NDconnect;
from NDmacro      import ACreturn_foot;
from VSmodFeature import VSremoveOperator;
from GRgraphics   import GRaltconstruct;
from GRvg         import GRgetsymb;

extern struct GRid NULL_GRID;

extern VDclassid OPP_ACpretend_class_id;
extern VDclassid OPP_GR3dlineseg_class_id;


/* ----------------------------------------------------------
** Utility routine to get active piece/item/op
*/
IGRstat VSmopBeamCmd_GetPieceItemOp( IGRint 	     *row,
				     IGRint 	     *sel,
				     TVSmopPieceInfo **pieceInfo,
				     TVSmopItemInfo  **itemInfo,
				     TVSmopOpInfo    **opInfo )
{
  IGRstat retFlag = 0;
  IGRint  pos;
  TGRid   pieceID;
  TGRid   itemID;
  TGRid   opID;
  IGRchar macName[64];
  

  /*
  ** Get the selected row
  */
  *row = -1;
  VIfld_get_active_row( cmdInfo->form, VSMOP_FORM_L_BEAM_OPS, row, &pos );
  if( *row < 0 ) goto wrapup;

  /*
  ** Lookup piece id
  */
  vdfrm$GetText( form   = cmdInfo->form, 
                 gadget = VSMOP_FORM_L_BEAM_OPS, 
                 col    = VSMOP_FORM_L_BEAM_OPS_PIECE_ID,
                 row    = *row,
                 objID  = &pieceID );

  VSmopFindPieceInfoByID( &cmdInfo->pieceInfoVLA, &pieceID, pieceInfo );
  if( *pieceInfo == NULL ) goto wrapup;

  /*
  ** Lookup item id
  */
  vdfrm$GetText( form   = cmdInfo->form, 
                 gadget = VSMOP_FORM_L_BEAM_OPS, 
                 col    = VSMOP_FORM_L_BEAM_OPS_ITEM_ID,
                 row    = *row,
                 objID  = &itemID );

  VSmopFindItemInfoByID( &(*pieceInfo)->itemInfoVLA, &itemID, itemInfo );
  if (*itemInfo == NULL) goto wrapup;

  /*
  ** Lookup op id
  */
  vdfrm$GetText( form   = cmdInfo->form, 
                 gadget = VSMOP_FORM_L_BEAM_OPS, 
                 col    = VSMOP_FORM_L_BEAM_OPS_CUT_ID,
                 row    = *row,
                 objID  = &opID );

  /*
  ** Lookup op macro name
  */
  vdfrm$GetText( form   = cmdInfo->form,
                 gadget = VSMOP_FORM_L_BEAM_OPS,
                 col    = VSMOP_FORM_L_BEAM_OPS_MACRO,
                 row    = *row,
                 txt    = macName );
  if( *macName == 0 ) strcpy( macName, "MACRO MISSING" );

  VSmopFindOpInfoByID( &(*itemInfo)->opInfoVLA,
		       &opID,
		       macName,
		       opInfo,
		       NULL );
  if (*opInfo == NULL) goto wrapup;

  /*
  ** Was row selected
  */
  vdfrm$GetText( form   = cmdInfo->form, 
                 gadget = VSMOP_FORM_L_BEAM_OPS, 
                 row    = *row,
                 sel    =  sel );

  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ----------------------------------------------------------
** Utility routine to get active piece/item
*/
IGRstat VSmopBeamCmd_GetPieceItem( IGRint          *row,
				   IGRint 	   *sel,
			           TVSmopPieceInfo **pieceInfo,
			           TVSmopItemInfo  **itemInfo )
{
  IGRstat retFlag = 0;
  IGRint  pos;
  TGRid   pieceID;
  TGRid   itemID;


  /*
  ** Get the selected row
  */
  *row = -1;
  VIfld_get_active_row( cmdInfo->form, VSMOP_FORM_L_BEAM_ITEMS, row, &pos );
  if( *row < 0 ) goto wrapup;

  /*
  ** Lookup piece id
  */
  vdfrm$GetText( form   = cmdInfo->form, 
                 gadget = VSMOP_FORM_L_BEAM_ITEMS, 
                 col    = VSMOP_FORM_L_BEAM_ITEMS_PIECE_ID,
                 row    = *row,
                 objID  = &pieceID );

  VSmopFindPieceInfoByID( &cmdInfo->pieceInfoVLA, &pieceID, pieceInfo );
  if( *pieceInfo == NULL ) goto wrapup;

  /*
  ** Lookup item id
  */
  vdfrm$GetText( form   = cmdInfo->form, 
                 gadget = VSMOP_FORM_L_BEAM_ITEMS, 
                 col    = VSMOP_FORM_L_BEAM_ITEMS_ITEM_ID,
                 row    = *row,
                 objID  = &itemID );

  VSmopFindItemInfoByID( &(*pieceInfo)->itemInfoVLA, &itemID, itemInfo );
  if( *itemInfo == NULL ) goto wrapup;

  /*
  ** Was row selected
  */
  vdfrm$GetText( form   = cmdInfo->form, 
                 gadget = VSMOP_FORM_L_BEAM_ITEMS, 
                 row    = *row,
                 sel    =  sel );

  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ----------------------------------------------------------
** Have a new operator to add
*/
IGRstat VSmopBeamCmd_LocatedOpOne( TVSmopPieceInfo *pieceInfo,
			           TVSmopItemInfo  *itemInfo,
                                   TVSmopOpInfo    *a_opInfo )
{
  IGRstat 	 retFlag = 0;
  IGRstat 	 retStatus;
  TVSmopOpInfo   *opInfo;
  TVSmopItemInfo *itemInfo_tmp;
  TGRid		 parentID;
  IGRint	 row, rows, i, j, itemPosition;
  IGRchar	 macName[64];
  
  vdobj$Get( objID = &a_opInfo->macroID, objName = macName );
  if( *macName == 0 ) strcpy( macName, "MACRO MISSING" );

  /*
  ** Cycle through to find the position of current item
  */
  for( i = 0;
       VSmopItemInfoVLA_GetNth(&pieceInfo->itemInfoVLA,i,NULL,&itemInfo_tmp);
       i++ )
  {
    if( itemInfo_tmp->itemOE.obj_id.objid == itemInfo->itemOE.obj_id.objid &&
	itemInfo_tmp->itemOE.obj_id.osnum == itemInfo->itemOE.obj_id.osnum )
    {
      itemPosition = i;
      break;
    }
  }

  /*
  ** Make sure not already used. Might not be a valid test, might need pretends
  */
  for( i = itemPosition ;
       VSmopItemInfoVLA_GetNth(&pieceInfo->itemInfoVLA,i,NULL,&itemInfo_tmp);
       i++ )
  {
    retStatus = VSmopFindOpInfoByID( &itemInfo_tmp->opInfoVLA,
				     &a_opInfo->cutOE.obj_id,
				     macName,
				     &opInfo,
				     &row );
    if( retStatus )
    {
      if( i == itemPosition )
      {
        FIfld_get_num_rows( cmdInfo->form, VSMOP_FORM_L_BEAM_OPS, &rows );
        for( j = 0 ; j < rows ; j++ )
        {
          FImcf_set_select( cmdInfo->form,
                            VSMOP_FORM_L_BEAM_OPS,
                            j,
                            0 );
        }
        FImcf_set_select( cmdInfo->form,
                          VSMOP_FORM_L_BEAM_OPS,
                          row,
		          1 );
        FIfld_set_active_row( cmdInfo->form, VSMOP_FORM_L_BEAM_OPS, row, 0 );
      }
      else
      {
	FIg_set_text( cmdInfo->form,
		      VSMOP_FORM_F_BEAM_STATUS,
		      "Operator aleady existed in a parent." );
	UI_status( "Operator aleady existed in a parent." );
      }

      goto wrapup;
    }
  }
  
  /*
  ** Just a transfer, sourcing etc. already done
  */
  opInfo = a_opInfo;

  /*
  ** Add to list
  */
  opInfo->miscFlag    = 0;
  opInfo->statusFlag  = 0;
  opInfo->hilitedFlag = 0;

  retStatus = 
  VSmopOpInfoVLA_Append( &itemInfo->opInfoVLA,opInfo );
  if( !(retStatus) )
  {
    printf("Problem getting opInfo from vla\n");
    goto wrapup;
  }
  
  /*
  ** Update form
  */
  VSmopBeamCmd_FillOpListRow( pieceInfo, itemInfo, opInfo );
  
  /*
  ** Done
  */
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ----------------------------------------------------------
** Have a new operator to add
*/
IGRstat VSmopBeamCmd_LocatedOp( TGRobj_env *opOE )
{
  IGRstat 	   retFlag = 0;
  IGRstat	   sts;
  IGRint 	   row, sel = 0;
  TVSmopPieceInfo  *pieceInfo;
  TVSmopItemInfo   *itemInfo;
  TVSmopOpInfo     *opInfo;
  TVSmopOpInfoVLA  opInfoVLA;
  IGRint       	   i;
  
  
  /*
  ** Get the data
  */
  sts = VSmopBeamCmd_GetPieceItem( &row, &sel, &pieceInfo, &itemInfo );
  if( !(sts&1) ) goto wrapup;
  if( sel == 0 )   goto wrapup;

  /*
  ** Check for operators in macro
  */
  VSmopOpInfoVLA_Init( &opInfoVLA );
  
  VSmopGetOps( opOE,&opInfoVLA );
 
  for(i = 0; VSmopOpInfoVLA_GetNth( &opInfoVLA, i, NULL, &opInfo ); i++)
  {
    VSmopBeamCmd_LocatedOpOne( pieceInfo, itemInfo, opInfo );
  }
  VSmopOpInfoVLA_Free( &opInfoVLA );

  /*
  ** Done
  */
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/*
** --------------------------------------------------------------
** Free the memory for VLA lists cmdInfo
** --------------------------------------------------------------
*/
IGRstat VSmopBeamCmd_FreeVlaLists()
{
  IGRstat               retFlag;
  TVDvlax               *piece_vlax, *piece_vlaxx;
  TVDvlax               *item_vlax, *item_vlaxx;
  TVSmopPieceInfoVLA    *pieceInfoVLA;
  TVSmopItemInfoVLA     *itemInfoVLA;
  TVSmopOpInfoVLA       *opInfoVLA;
  IGRint                i, j;


  retFlag  = 0;

  /*
  ** Vla variable check
  */
  if( !(cmdInfo) )
  {
    retFlag = 1;
    goto wrapup;
  }

  pieceInfoVLA = &(cmdInfo->pieceInfoVLA);

  /*
  ** Free the first section of pieces
  */
  for( i = 0 ; i < pieceInfoVLA->vla.cnt ; i++ )
  {
    itemInfoVLA = &(pieceInfoVLA->data[i].itemInfoVLA);

    /*
    ** Free operators in the first section of items
    */
    for( j = 0 ; j < itemInfoVLA->vla.cnt ; j++ )
    {
      opInfoVLA = &(itemInfoVLA->data[j].opInfoVLA);
      VSmopOpInfoVLA_Free( opInfoVLA );
    }

    /*
    ** Free operators in any downstream items
    */
    item_vlax = (TVDvlax *)(itemInfoVLA->vla.next);
    while( item_vlax )
    {
      item_vlaxx = (TVDvlax *)item_vlax->next;
      for( j = 0 ; j < item_vlax->cnt ; j++ )
      {
        opInfoVLA = &(((TVSmopItemInfo *)item_vlax->data)[j].opInfoVLA);
        VSmopOpInfoVLA_Free( opInfoVLA );
      }
      item_vlax = item_vlaxx;
    }

    VSmopItemInfoVLA_Free( itemInfoVLA );
  }

  /*
  ** Free any downstream pieces
  */
  piece_vlax = (TVDvlax *)(pieceInfoVLA->vla.next);

  while( piece_vlax )
  {
    piece_vlaxx = (TVDvlax *)piece_vlax->next;
    for( i = 0 ; i < piece_vlax->cnt ; i++ )
    {
      itemInfoVLA = &(((TVSmopPieceInfo *)piece_vlax->data)[i].itemInfoVLA);

      /*
      ** Free operators in the first section of items
      */
      for( j = 0 ; j < itemInfoVLA->vla.cnt ; j++ )
      {
        opInfoVLA = &(itemInfoVLA->data[j].opInfoVLA);
        VSmopOpInfoVLA_Free( opInfoVLA );
      }

      /*
      ** Free operators in any downstream items
      */
      item_vlax = (TVDvlax *)itemInfoVLA->vla.next;
      while( item_vlax )
      {
        item_vlaxx = (TVDvlax *)item_vlax->next;
        for( j = 0 ; j < item_vlax->cnt ; j++ )
        {
          opInfoVLA = &(((TVSmopItemInfo *)item_vlax->data)[j].opInfoVLA);
          VSmopOpInfoVLA_Free( opInfoVLA );
        }
        item_vlax = item_vlaxx;
      }

      VSmopItemInfoVLA_Free( itemInfoVLA );
    }

    piece_vlax = piece_vlaxx;
  }

  VSmopPieceInfoVLA_Free( pieceInfoVLA );

  /*
  ** Init the part vla
  */
  VSmopPieceInfoVLA_Init( &cmdInfo->pieceInfoVLA );

  /*
  ** Done
  */
  retFlag = 1;


wrapup:
  return retFlag;
} /* VSmopBeamCmd_FreeVlaLists */


/*
** --------------------------------------------------------------
** Insert a brand new beam object of class BSbooBeam
** --------------------------------------------------------------
*/
IGRstat VSmopBeamCmd_FormNotifyInsertNewBeam()
{
  IGRstat	  retFlag;
  IGRstat	  sts;
  IGRlong	  msg;
  IGRint	  active_row, row, pos, sel;
  IGRchar	  className[128];
  TVSmopPieceInfo *pieceInfo;
  TVSmopItemInfo  *itemInfo;
  TGRobj_env	  parentOE[2];
  TGRobj_env	  DummyOpOE;
  TGRid		  parentID;
  IGRint	  parentCnt;
  struct GRmd_env cstEnv;
  TGRid		  pieceID;
  TGRid		  itemID;
  TGRobj_env	  newBeam;


  retFlag      = 0;
  row          = -1;
  active_row   = -1;
  pieceInfo    = NULL;
  itemInfo     = NULL;
  className[0] = '\0';

  /*
  ** Get the selected row
  */
  VIfld_get_active_row( cmdInfo->form,
			VSMOP_FORM_L_BEAM_ITEMS,
			&active_row,
			&pos );
  if( active_row < 0 ) goto wrapup;

  /*
  ** Check if it is the first row
  */
  if( (active_row == 0) )
  {
    FIg_set_text( cmdInfo->form, VSMOP_FORM_F_BEAM_STATUS, InsertErrorMessagr );
    goto wrapup;
  }

  row = active_row - 1;

  /*
  ** Lookup the class name in the row (active_row - 1)
  */
  vdfrm$GetText( form   = cmdInfo->form,
                 gadget = VSMOP_FORM_L_BEAM_ITEMS,
                 col    = VSMOP_FORM_L_BEAM_ITEMS_CLASS,
                 row    = row,
                 txt    = className );
  /*
  ** Check if the new beam is before a beam object of VSbooBeam
  */
  if( strcmp(className,"VSbooBeam") ) 
  {
    FIg_set_text( cmdInfo->form, VSMOP_FORM_F_BEAM_STATUS, InsertErrorMessagr );
    goto wrapup;
  }

  /*
  ** Lookup piece id in the row (active_row - 1).
  */
  vdfrm$GetText( form   = cmdInfo->form,
                 gadget = VSMOP_FORM_L_BEAM_ITEMS,
                 col    = VSMOP_FORM_L_BEAM_ITEMS_PIECE_ID,
                 row    = row,
                 objID  = &pieceID );

  VSmopFindPieceInfoByID( &cmdInfo->pieceInfoVLA, &pieceID, &pieceInfo );
  if( pieceInfo == NULL ) goto wrapup;

  /*
  ** Lookup item id in the row (active_row - 1).
  */
  vdfrm$GetText( form   = cmdInfo->form,
                 gadget = VSMOP_FORM_L_BEAM_ITEMS,
                 col    = VSMOP_FORM_L_BEAM_ITEMS_ITEM_ID,
                 row    = row,
                 objID  = &itemID );

  VSmopFindItemInfoByID( &pieceInfo->itemInfoVLA, &itemID, &itemInfo );
  if( itemInfo == NULL ) goto wrapup;

  /*
  ** Get the construct environment
  */
  cstEnv = itemInfo->itemOE.mod_env;

  FIg_reset( cmdInfo->form, VSMOP_FORM_F_BEAM_STATUS );

  /*
  ** Create a dummy operator
  */
  sts = VSmopBeamCmd_CreateDummyOp( &itemInfo->itemOE, &DummyOpOE );
  if( !(sts) ) 
  {
    FIg_set_text( cmdInfo->form,
                  VSMOP_FORM_F_BEAM_STATUS,
                  "New beam insertion failed!" );
    printf("Creating a dummy operator failed!\n");
    goto wrapup;
  }

  /*
  ** Get parent
  */
  vdobj$GetTemplate(objOE      = &itemInfo->itemOE,
                    nth        =  0,
                    templateOE = &parentOE[0]);

  parentOE[1] = DummyOpOE;

  /*
  ** Construct the new beam
  */
  sts = VSmopBeamConstructNewBeam( &cstEnv, parentOE, className, &newBeam );
  if( !(sts&1) ) 
  {
    FIg_set_text( cmdInfo->form,
		  VSMOP_FORM_F_STATUS,
		  "New beam insertion failed!" );
    printf("New beam construction failed!\n");
    goto wrapup;
  }

  /*
  ** Reconnect the new beam to its parent and get rid of the dummy operator.
  */
/*
  sts = VSmopBeamCmd_ReconnectToParent( &parentOE[0].obj_id, &newBeam );
  if( !(sts&1) )
  {
    FIg_set_text( cmdInfo->form,
                  VSMOP_FORM_F_BEAM_STATUS,
                  "New beam insertion failed!" );
    printf("Reconnection to parent failed!\n");
    goto wrapup;
  }
*/

  /*
  ** Make the new beam be the parent of an existing beam.
  */
  sts = VSmopBeamCmd_ChangeParent( &newBeam );
  if( !(sts&1) )
  {
    FIg_set_text( cmdInfo->form,
                  VSMOP_FORM_F_BEAM_STATUS,
                  "New beam insertion failed!" );
    printf("Changing parent for existing beam failed!\n");
    goto wrapup;
  }

  /*
  ** Insert the new beam into VLA and command form
  */
  sts = VSmopBeamCmd_InsertNewBeamIntoVlaAndForm( &newBeam );
  if( !(sts&1) )
  {
    FIg_set_text( cmdInfo->form,
                  VSMOP_FORM_F_BEAM_STATUS,
                  "New beam insertion failed!" );
    printf("New beam insertion into VLA and form failed!\n");
    goto wrapup;
  }

  /*
  ** Done
  */
  retFlag = 1;


wrapup:
  return retFlag;
} /* VSmopBeamCmd_FormNotifyInsertNewBeam */

/*
** --------------------------------------------------------------
** Rearrange the operator field in cmd form and operator info VLA
** --------------------------------------------------------------
*/
IGRstat VSmopBeamCmd_RearrangeFormAndVla()
{
  IGRstat		retFlag;
  IGRstat		sts;
  IGRlong		status;
  IGRint		row, pos, sel;
  IGRint		i, NumberOp, num_row;
  TVSmopPieceInfo	*pieceInfo;
  TVSmopItemInfo	*itemInfo;
  TVSmopOpInfo		*opInfo;
  IGRchar		buf[128], macName[64], preName[64];;


  NumberOp = 0;
  retFlag  = 0;
  num_row  = 0;

  /*
  ** Get the data
  */
  sts = VSmopBeamCmd_GetPieceItem( &row, &sel, &pieceInfo, &itemInfo );
  if( !(sts&1) ) goto wrapup;
  if( sel == 0 ) goto wrapup;

  /*
  ** Now get any remaining operators
  */
  FIfld_get_num_rows( cmdInfo->form, VSMOP_FORM_L_BEAM_OPS, &num_row );

  for( i = 0 ; i < num_row ; i++ )
  {
    vdfrm$GetText( form   = cmdInfo->form, 
                   gadget = VSMOP_FORM_L_BEAM_OPS, 
                   col    = VSMOP_FORM_L_BEAM_OPS_STATUS, 
                   row    = i,
                   txt    = buf );

    vdfrm$SetText( form   = cmdInfo->form,
                   gadget = VSMOP_FORM_L_BEAM_OPS,
                   col    = VSMOP_FORM_L_BEAM_OPS_STATUS,
                   row    = i,
                   txt    = "" );

    vdfrm$SetText( form   = cmdInfo->form,
                   gadget = VSMOP_FORM_L_BEAM_OPS,
                   col    = VSMOP_FORM_L_BEAM_OPS_MACRO,
                   row    = i,
                   txt    = "" );

    vdfrm$SetText( form   = cmdInfo->form,
                   gadget = VSMOP_FORM_L_BEAM_OPS,
                   col    = VSMOP_FORM_L_BEAM_OPS_CUT,
                   row    = i,
                   txt    = "" );
 
    vdfrm$SetText( form   = cmdInfo->form,
                   gadget = VSMOP_FORM_L_BEAM_OPS,
                   col    = VSMOP_FORM_L_BEAM_OPS_PIECE_ID,
                   row    = i,
                   txt    = "" );

    vdfrm$SetText( form   = cmdInfo->form,
                   gadget = VSMOP_FORM_L_BEAM_OPS,
                   col    = VSMOP_FORM_L_BEAM_OPS_ITEM_ID,
                   row    = i,
                   txt    = "" );

    vdfrm$SetText( form   = cmdInfo->form,
                   gadget = VSMOP_FORM_L_BEAM_OPS,
                   col    = VSMOP_FORM_L_BEAM_OPS_CUT_ID,
                   row    = i,
                   txt  = "" );

    if( *buf != 'X' )
    {
      VSmopOpInfoVLA_GetNth( &itemInfo->opInfoVLA, i, NULL, &opInfo );

      /*
      ** Show macro name
      */
      vdobj$Get( objID = &opInfo->macroID, objName = macName );
      if( *macName == 0 ) strcpy( macName, "MACRO MISSING" );

      /*
      ** Show downscan in macro column
      */
      preName[0] = '\0';
      status =
      om$send( msg      = message ACpretend.ACgive_downscan(preName),
               senderid = NULL_OBJID,
               targetid = opInfo->parentID.objid,
               targetos = opInfo->parentID.osnum );

      vdfrm$SetText( form   = cmdInfo->form,
                     gadget = VSMOP_FORM_L_BEAM_OPS,
                     col    = VSMOP_FORM_L_BEAM_OPS_STATUS,
                     row    = NumberOp,
                     txt    = " " );

      vdfrm$SetText( form   = cmdInfo->form,
                     gadget = VSMOP_FORM_L_BEAM_OPS,
                     col    = VSMOP_FORM_L_BEAM_OPS_MACRO,
                     row    = NumberOp,
                     txt    = macName );

      vdfrm$SetText( form   = cmdInfo->form,
                     gadget = VSMOP_FORM_L_BEAM_OPS,
                     col    = VSMOP_FORM_L_BEAM_OPS_CUT,
                     row    = NumberOp,
                     txt    = preName );
 
      vdfrm$SetText( form   = cmdInfo->form,
                     gadget = VSMOP_FORM_L_BEAM_OPS,
                     col    = VSMOP_FORM_L_BEAM_OPS_PIECE_ID,
                     row    = NumberOp,
                     objID  = &pieceInfo->pieceOE.obj_id );

      vdfrm$SetText( form   = cmdInfo->form,
                     gadget = VSMOP_FORM_L_BEAM_OPS,
                     col    = VSMOP_FORM_L_BEAM_OPS_ITEM_ID,
                     row    = NumberOp,
                     objID  = &itemInfo->itemOE.obj_id );

      vdfrm$SetText( form   = cmdInfo->form,
                     gadget = VSMOP_FORM_L_BEAM_OPS,
                     col    = VSMOP_FORM_L_BEAM_OPS_CUT_ID,
                     row    = NumberOp,
                     objID  = &opInfo->cutOE.obj_id );

      VSmopOpInfoVLA_OverwriteNth( &itemInfo->opInfoVLA,
				   &NumberOp,
				   NULL,
				   &opInfo );

      NumberOp++;
    }
  }

  if( NumberOp < num_row )
  {
    VSmopOpInfoVLA_RearrangeVla( &itemInfo->opInfoVLA, &NumberOp, &num_row );
    
    if( !(NumberOp) ) VSmopOpInfoVLA_Init( &itemInfo->opInfoVLA );

    FIfld_delete_rows( cmdInfo->form,
		       VSMOP_FORM_L_BEAM_OPS,
		       NumberOp,
		       (num_row-NumberOp) );
  }

  /*
  ** Done
  */
  retFlag = 1;


wrapup:
  return retFlag;
} /* VSmopBeamCmd_RearrangeFormAndVla */

/*
** --------------------------------------------------------------
** Insert the brand new beam into VLA and command form.
** --------------------------------------------------------------
*/
IGRstat VSmopBeamCmd_InsertNewBeamIntoVlaAndForm( TGRobj_env *newBeam )
{
  IGRstat	  retFlag;
  IGRstat	  sts;
  IGRint          row, sel;
  TVSmopPieceInfo *pieceInfo;
  TVSmopItemInfo  *itemInfo;


  retFlag   = 0;
  row       = -1;
  pieceInfo = NULL;
  itemInfo  = NULL;

  /*
  ** Get the data
  */
  sts = VSmopBeamCmd_GetPieceItem( &row, &sel, &pieceInfo, &itemInfo );
  if( !(sts&1) ) goto wrapup;
  if( sel == 0 ) goto wrapup;

  /*
  ** Fill in the item info
  */
  sts = VSmopFillBeamItemVLA( pieceInfo );
  if( !(sts&1) ) goto wrapup;

  sts = VSmopBeamCmd_FormNotifyPieceList();
  if( !(sts&1) ) goto wrapup;

  sts = VSmopBeamCmd_FormNotifyNthRowItemList( &row );
  if( !(sts&1) ) goto wrapup;

  /*
  ** Done
  */
  retFlag = 1;


wrapup:
  return retFlag;
} /* VSmopBeamCmd_InsertNewBeamIntoVlaAndForm */

/*
** --------------------------------------------------------------
** Make the new beam be a parent of an existing beam.
** --------------------------------------------------------------
*/
IGRstat VSmopBeamCmd_ChangeParent( TGRobj_env *newBeam )
{
  IGRstat	  retFlag;
  IGRstat	  sts;
  IGRint          active_row, row, pos, sel;
  TVSmopPieceInfo *pieceInfo;
  TVSmopItemInfo  *itemInfo;
  TGRid		  parentIDs[300];
  IGRint	  parentCnt;
  IGRint	  cn_type;
  TGRid           pieceID;
  TGRid           itemID;


  retFlag    = 0;
  row        = -1;
  active_row = -1;
  pieceInfo  = NULL;
  itemInfo   = NULL;
  parentCnt  = -1;

  /*
  ** Get the selected row
  */
  VIfld_get_active_row( cmdInfo->form,
			VSMOP_FORM_L_BEAM_ITEMS,
			&active_row,
			&pos );
  if( active_row < 0 ) goto wrapup;

  row = active_row - 1;

  /*
  ** Lookup piece id in the row (active_row - 1).
  */
  vdfrm$GetText( form   = cmdInfo->form,
                 gadget = VSMOP_FORM_L_BEAM_ITEMS,
                 col    = VSMOP_FORM_L_BEAM_ITEMS_PIECE_ID,
                 row    = row,
                 objID  = &pieceID );

  VSmopFindPieceInfoByID( &cmdInfo->pieceInfoVLA, &pieceID, &pieceInfo );
  if( pieceInfo == NULL ) goto wrapup;

  /*
  ** Lookup item id in the row (active_row - 1).
  */
  vdfrm$GetText( form   = cmdInfo->form,
                 gadget = VSMOP_FORM_L_BEAM_ITEMS,
                 col    = VSMOP_FORM_L_BEAM_ITEMS_ITEM_ID,
                 row    = row,
                 objID  = &itemID );

  VSmopFindItemInfoByID( &pieceInfo->itemInfoVLA, &itemID, &itemInfo );
  if( itemInfo == NULL ) goto wrapup;

  /*
  ** Get all parents
  */
  do
  {
    ++parentCnt;
    vdchn$Get2( objOE  = &itemInfo->itemOE,
                chnIDx = VDCHN_IDX_PARENT,
                nth    = parentCnt,
                outID  = &parentIDs[parentCnt] );
  }
  while( parentIDs[parentCnt].objid != NULL_OBJID );

  if( parentIDs[0].objid == NULL_OBJID)
  {
    UI_status("No first parent");
    FIg_set_text( cmdInfo->form, VSMOP_FORM_F_BEAM_STATUS, "No first parent" );
    goto wrapup;
  }

  /*
  ** Change to new parent
  */
  parentIDs[0].objid = newBeam->obj_id.objid;
  parentIDs[0].osnum = newBeam->obj_id.osnum;

  /*
  ** Reconnect
  */
  sts = om$send( msg      = message NDnode.NDconnect(parentCnt,
						     parentIDs,
						     NULL_GRID,
						     ND_FULL),
    		 senderid = NULL_OBJID,
    		 targetid = itemInfo->itemOE.obj_id.objid,
    		 targetos = itemInfo->itemOE.obj_id.osnum );
  if( !(sts&1) )
  {
    UI_status("Problem connecting parents");
    FIg_set_text( cmdInfo->form,
		  VSMOP_FORM_F_BEAM_STATUS,
		  "Problem connecting parents" );
    goto wrapup;
  }

  /*
  ** Recompute
  */
  cn_type = ND_COMP;
  nd$wait_batch( type       = GR_GEOM_POSTED,
    		 nb_obj     = 1,
    		 l_object   = &itemInfo->itemOE.obj_id,
   		 l_obj_info = &cn_type );
  nd$exec_batch();

  /*
  ** Done
  */
  retFlag = 1;


wrapup:
  return retFlag;
} /* VSmopBeamCmd_ChangeParent */

/*
** --------------------------------------------------------------
** Reset cmd form
** --------------------------------------------------------------
*/
IGRstat VSmopBeamCmd_ResetForm()
{
  IGRstat		retFlag;


  retFlag = 0;

  FIg_reset( cmdInfo->form, VSMOP_FORM_L_BEAM_PIECES );
  FIg_reset( cmdInfo->form, VSMOP_FORM_L_BEAM_ITEMS );
  FIg_reset( cmdInfo->form, VSMOP_FORM_L_BEAM_OPS );
  FIg_reset( cmdInfo->form, VSMOP_FORM_T_BEAM_PROTECT_X );
  FIg_reset( cmdInfo->form, VSMOP_FORM_B_BEAM_LOCATE_OPS );
  FIg_reset( cmdInfo->form, VSMOP_FORM_B_LOCATE_BEAM );
  FIg_reset( cmdInfo->form, VSMOP_FORM_T_DELETE_BEAM );
  FIg_reset( cmdInfo->form, VSMOP_FORM_F_BEAM_STATUS );
  /*
  FIg_reset( cmdInfo->form, VSMOP_FORM_B_INSERT_BEAM );
  */

  /*
  ** Done
  */
  retFlag = 1;


wrapup:
  return retFlag;
} /* VSmopBeamCmd_ResetForm */

/*
** --------------------------------------------------------------
** Check if the macro has the existing pieceID as its parent. If so,
** make the macro be the child of the parent of the existing pieceID
** --------------------------------------------------------------
*/
IGRstat VSmopBeamCmd_CheckOrModifyMacroParent( TVSmopOpInfo    *opInfo,
					       int	       *row )
{
  IGRstat	retFlag;
  IGRint	sts;
  IGRint	cn_type, i, j, itemRow, pos;
  TGRid		macroID, itemID, currentItemID;
  IGRint 	MacroParentCnt, MacroParentCntNew;
  TGRid  	MacroParentIDs[300], MacroParentIDsNew[300];
  TGRid  	ItemParentID;


  retFlag = 0;
  itemRow = -1;
  macroID.objid       = NULL_OBJID;
  currentItemID.objid = NULL_OBJID;
  ItemParentID.objid  = NULL_OBJID;
  for( i = 0 ; i < 300 ; i++ )
  {
    MacroParentIDs[i].objid    = NULL_OBJID;
    MacroParentIDsNew[i].objid = NULL_OBJID;
  }

  VIfld_get_active_row( cmdInfo->form,
			VSMOP_FORM_L_BEAM_ITEMS,
			&itemRow,
			&pos );
  if( itemRow < 0 ) goto wrapup;

  vdobj$GetPretendParent( pretendID = &opInfo->parentID,
                          parentID  = &macroID );

  /*
  ** Lookup the current item id
  */
  vdfrm$GetText( form   = cmdInfo->form,
                 gadget = VSMOP_FORM_L_BEAM_OPS,
                 col    = VSMOP_FORM_L_BEAM_OPS_ITEM_ID,
                 row    = *row,
                 objID  = &currentItemID );

  for( j = 0 ; j <= itemRow ; j++ )
  {
    itemID.objid = NULL_OBJID;

    /*
    ** Lookup item id
    */
    vdfrm$GetText( form   = cmdInfo->form,
                   gadget = VSMOP_FORM_L_BEAM_ITEMS,
                   col    = VSMOP_FORM_L_BEAM_ITEMS_ITEM_ID,
                   row    = j,
                   objID  = &itemID );
    if( itemID.objid == NULL_OBJID) goto wrapup;

    /*
    ** Check all the parents of macro
    */
    MacroParentCnt = -1;
    do
    {
      ++MacroParentCnt;
      vdchn$Get2( objID  = &macroID,
                  chnIDx = VDCHN_IDX_PARENT,
                  nth    = MacroParentCnt,
                  outID  = &MacroParentIDs[MacroParentCnt] );

      if( MacroParentIDs[MacroParentCnt].objid == itemID.objid &&
          MacroParentIDs[MacroParentCnt].osnum == itemID.osnum )
      {
        vdchn$Get2( objID  = &currentItemID,
                    chnIDx = VDCHN_IDX_PARENT,
                    nth    = 0,
                    outID  = &ItemParentID );
        if( ItemParentID.objid == NULL_OBJID )
        {
          UI_status( "No first parent" );
          goto wrapup;
        }

        MacroParentCntNew = -1;
        do
        {
          ++MacroParentCntNew;
          vdchn$Get2( objID  = &macroID,
                      chnIDx = VDCHN_IDX_PARENT,
                      nth    = MacroParentCntNew,
                      outID  = &MacroParentIDsNew[MacroParentCntNew] );
        }
        while( MacroParentIDsNew[MacroParentCntNew].objid != NULL_OBJID );

        /*
	** Change to new parent
  	*/
        MacroParentIDsNew[MacroParentCnt].objid = ItemParentID.objid;
        MacroParentIDsNew[MacroParentCnt].osnum = ItemParentID.osnum;

        /*
        ** Reconnect
        */
        sts =
        om$send( msg      = message NDnode.NDconnect(MacroParentCntNew,
                                                     MacroParentIDsNew,
                                                     NULL_GRID,
                                                     ND_FULL),
                 senderid = NULL_OBJID,
                 targetid = macroID.objid,
                 targetos = macroID.osnum );
        if( !(sts&1) )
        {
          UI_status("Problem connecting parents");
          FIg_set_text( cmdInfo->form,
                        VSMOP_FORM_F_BEAM_STATUS,
                        "Problem connecting parents" );
          goto wrapup;
        }

        /*
        ** Recompute
        */
        cn_type = ND_COMP;
        nd$wait_batch( type       = GR_GEOM_POSTED,
                       nb_obj     = 1,
                       l_object   = &macroID,
                       l_obj_info = &cn_type );
        nd$exec_batch();

	goto done;
      }
    }
    while( MacroParentIDs[MacroParentCnt].objid != NULL_OBJID );
  }

done:

  /*
  ** Done
  */
  retFlag = 1;


wrapup:
  return retFlag;
} /* VSmopBeamCmd_CheckOrModifyMacroParent */

/* ----------------------------------------------------------
** Run or accept button was pressed
*/
IGRstat VSmopBeamCmd_FormNotifyExecute()
{
  IGRstat 	  retFlag = 0;
  IGRstat	  sts;
  IGRint	  row, pos, sel;
  IGRint 	  i, flag;
  TVSmopPieceInfo *pieceInfo;
  TVSmopItemInfo  *itemInfo;
  TVSmopOpInfo    *opInfo;
  TGRid  	  itemID;
  IGRint 	  itemI;
  TGRobj_env 	  *ItemOE;
  TGRobj_env 	  *cutOE;
  TGRobj_env 	  operatorOE;
  TGRobj_env 	  DummyOpOE;
  TGRid  	  parentIDs[300];
  IGRint 	  parentCnt;
  IGRchar 	  buf[128];
  TGRid 	  parentID;
  IGRint 	  cn_type;
  IGRint	  num_row;
  IGRint	  delete_flag;
  IGRint	  operatorLeftFlag;


  delete_flag 	      = 0;
  operatorLeftFlag    = 0;
  parentID.objid      = NULL_OBJID;
  for( i = 0 ; i < 300 ; i++ )
  {
    parentIDs[i].objid         = NULL_OBJID;
  }

  FIg_set_text( cmdInfo->form,
                VSMOP_FORM_F_BEAM_STATUS,
                "" );
  /*
  ** Get the data
  */
  sts = VSmopBeamCmd_GetPieceItem( &row, &sel, &pieceInfo, &itemInfo );
  if( !(sts&1) ) goto wrapup;
  if( sel == 0 ) goto wrapup;

  /*
  ** Keep 1st parent
  */
  vdchn$Get2( objOE  = &itemInfo->itemOE,
              chnIDx = VDCHN_IDX_PARENT,
              nth    = 0,
              outID  = &parentIDs[0] );

  if( parentIDs[0].objid == NULL_OBJID )
  {
    UI_status( "No first parent" );
    goto wrapup;
  }
  parentCnt = 1;

  /*
  ** Now get any remaining operators
  */
  FIfld_get_num_rows( cmdInfo->form, VSMOP_FORM_L_BEAM_OPS, &num_row );

  for( i = 0 ; i < num_row ; i++ )
  {
    vdfrm$GetText( form   = cmdInfo->form, 
                   gadget = VSMOP_FORM_L_BEAM_OPS, 
                   col    = VSMOP_FORM_L_BEAM_OPS_STATUS, 
                   row    = i,
                   txt    = buf );

    if( buf[0] != 'X' )
    {
      operatorLeftFlag = 1;

      VSmopOpInfoVLA_GetNth( &itemInfo->opInfoVLA, i, NULL, &opInfo );

      /*
      ** Add to list
      */
      cutOE = &opInfo->cutOE;
      if( cutOE->obj_id.objid != NULL_OBJID )
      {
        VDahMakeSource( cutOE, &parentIDs[parentCnt] );
        if( parentIDs[parentCnt].objid == NULL_OBJID )
   	{
          UI_status("Problem sourcing parent");
          goto wrapup;
        }

        parentID = opInfo->parentID;
        if( parentID.objid == NULL_OBJID )
 	{
          UI_status("Problem getting source");
          printf("Problem getting source\n");
          goto wrapup;
        }

	VSmopBeamCmd_CheckOrModifyMacroParent( opInfo, &i );

        parentIDs[parentCnt] = parentID;
        parentCnt++;
      }

      continue;
    }

    delete_flag = 1;
  }

  /*
  ** Keep the first one if all operators are removed.
  */
  flag = 0;
  VIg_get_state( cmdInfo->form, VSMOP_FORM_T_DELETE_PLATE, &flag );

  if( !(operatorLeftFlag) && (num_row>0) && flag )
  {
    VSmopOpInfoVLA_GetNth( &itemInfo->opInfoVLA, 0 , NULL, &opInfo );

    /*
    ** Add to list
    */
    cutOE = &opInfo->cutOE;
    operatorOE = opInfo->cutOE;
    if( cutOE->obj_id.objid != NULL_OBJID )
    {
      VDahMakeSource( cutOE, &parentIDs[parentCnt] );

      if( parentIDs[parentCnt].objid == NULL_OBJID )
      {
        UI_status("Problem sourcing parent");
        goto wrapup;
      }

      parentID = opInfo->parentID;
      if( parentID.objid == NULL_OBJID )
      {
        UI_status("Problem getting source");
        printf("Problem getting source\n");
        goto wrapup;
      }

      parentIDs[parentCnt] = parentID;
      parentCnt++;
    }
  }

  if( delete_flag )
  {
    sts = VSmopBeamCmd_RearrangeFormAndVla();
    if( !(sts) ) goto wrapup;
  }

  if (parentCnt < 1)
  {
    UI_status("Less than 1 parents");
    goto wrapup;
  }

  /*
  ** Reconnect
  */
  sts =
  om$send( msg 	    = message NDnode.NDconnect(parentCnt,
					       parentIDs,
					       NULL_GRID,
					       ND_FULL),
    	   senderid = NULL_OBJID,
    	   targetid = itemInfo->itemOE.obj_id.objid,
    	   targetos = itemInfo->itemOE.obj_id.osnum );
  if( !(sts&1) )
  {
    UI_status("Problem connecting parents");
    goto wrapup;
  }

  /* Recompute */
  cn_type = ND_COMP;

  nd$wait_batch(
    type = GR_GEOM_POSTED,
    nb_obj     = 1,
    l_object   = & itemInfo->itemOE.obj_id,
    l_obj_info = &cn_type
  );
  nd$exec_batch();

  if( operatorLeftFlag && (num_row>0) && flag )
  {
    FIg_set_text( cmdInfo->form,
		  VSMOP_FORM_F_BEAM_STATUS,
		  "Remove all operators before deleting beam!" );
    goto wrapup;
  }

  if( !(operatorLeftFlag) && (num_row>0) && flag )
  {
    sts = VSmopBeamCmd_DeleteBeamWithOp( &operatorOE );
    if( !(sts) ) goto wrapup;
  }

  /*
  ** If no operator is associated to the beam, create a dummy one to 
  ** connect to the plate.  Then, delete the beam.
  */
  if( (num_row==0) && flag )
  {
    /*
    ** Create a dummy operator for beam deletion
    */
    ItemOE = &itemInfo->itemOE;
    sts = VSmopBeamCmd_CreateDummyOp( ItemOE, &DummyOpOE );
    if( !(sts) ) goto wrapup;

    /*
    ** Create a parent
    */
    parentCnt = 1; 
    VDahMakeSource( &DummyOpOE, &parentIDs[parentCnt] );
    if( parentIDs[parentCnt].objid == NULL_OBJID )
    {
      UI_status("Problem sourcing parent");
      goto wrapup;
    }
    parentCnt++;

    /*
    ** Reconnect to dummy operator
    */
    sts = om$send( msg      = message NDnode.NDconnect(parentCnt,
						       parentIDs,
						       NULL_GRID,
						       ND_FULL),
                   senderid = NULL_OBJID,
    		   targetid = itemInfo->itemOE.obj_id.objid,
    		   targetos = itemInfo->itemOE.obj_id.osnum );
    if( !(sts&1) )
    {
      UI_status( "Problem connecting parents" );
      goto wrapup;
    }

    /*
    ** Recompute
    */
    cn_type = ND_COMP;
    nd$wait_batch( type       = GR_GEOM_POSTED,
    		   nb_obj     = 1,
    		   l_object   = &itemInfo->itemOE.obj_id,
    		   l_obj_info = &cn_type );
    nd$exec_batch();

    /*
    ** Delete the plate with the dummy operator
    */
    sts = VSmopBeamCmd_DeleteBeamWithOp( &DummyOpOE );
    if( !(sts) ) goto wrapup;
  }

  // Done
  retFlag = 1;

wrapup:
  VSmopBeamCmd_FormNotifyItemList();
  return retFlag;
}

/* ----------------------------------------------------------
** Row in op list was pressed
*/
IGRstat VSmopBeamCmd_FormNotifyOpList()  
{
  IGRstat 	  retFlag = 0;
  IGRstat 	  sts;
  IGRint  	  flag;
  IGRchar 	  buf[128];
  IGRint  	  row, sel;
  TVSmopPieceInfo *pieceInfo;
  TVSmopItemInfo  *itemInfo;
  TVSmopOpInfo    *opInfo;
  enum GRdpmode   mode;

  /*
  ** Get the selected row
  */
  sts = VSmopBeamCmd_GetPieceItemOp(&row, &sel, &pieceInfo, &itemInfo, &opInfo);
  if( !(sts&1) ) goto wrapup;
  
  /*
  ** Maybe toggle the status field
  */
  VIg_get_state( cmdInfo->form, VSMOP_FORM_T_BEAM_PROTECT_X, &flag );
  if( flag )
  {
    vdfrm$GetText( form   = cmdInfo->form, 
		   gadget = VSMOP_FORM_L_BEAM_OPS,
		   col    = VSMOP_FORM_L_BEAM_OPS_STATUS,
		   row    = row,
		   txt    = buf );

    if( *buf == 'X' ) strcpy( buf," " );
    else              strcpy( buf,"X" );

    vdfrm$SetText( form   = cmdInfo->form, 
		   gadget = VSMOP_FORM_L_BEAM_OPS,
		   col    = VSMOP_FORM_L_BEAM_OPS_STATUS,
		   row    = row,
		   txt    = buf );
  }

  /*
  ** Backwards since beam is hilited
  */
  if( sel ) mode = GRhdo;
  else      mode = GRheo;

  if( opInfo->cutOE.obj_id.objid != NULL_OBJID )
  {
    vd_$bulk_display( dpmode = mode, objenvs = &opInfo->cutOE );
  }
  else 
  {
    struct GRid      modObj;
    struct GRmd_env  modEnv;
    long             status, msg;
    struct GRid	     macroID;

    vdobj$GetPretendParent( pretendID = &opInfo->parentID,
                            parentID  = &macroID );

    status =
    om$send( msg      = message NDmacro.ACreturn_foot(
                                            &msg,
                                            "",
                                            &modObj,
                                            &modEnv.md_env.matrix_type,
                                            modEnv.md_env.matrix),
	     senderid = NULL_OBJID,
             targetid = macroID.objid,
             targetos = macroID.osnum );

             if( status & msg & 1 )
             {
               modEnv._MD_OS = macroID.osnum;
               status = ex$get_modid( mod_osnum = modEnv._MD_OS,
                                      mod_id    = &modEnv._MD_ID );
               if( status )
               {
		 vd_$bulk_display( dpmode = mode,
				   grids  = &macroID,
				   theEnv = &modEnv );
               }
             }
  }
  
  /*
  ** Done
  */
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------------------
** Fill in one operator row
*/
IGRstat VSmopBeamCmd_FillOpListRow( TVSmopPieceInfo *pieceInfo,
			            TVSmopItemInfo  *itemInfo,
                                    TVSmopOpInfo    *opInfo )
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRchar buf[256];
  IGRchar macName[64];
  IGRchar preName[64];
  IGRint  row;


  /*
  ** Append to end
  */
  vdfrm$GetText( form   = cmdInfo->form,
		 gadget = VSMOP_FORM_L_BEAM_OPS,
		 rows   = &row );

  vdfrm$SetText( form   = cmdInfo->form,
		 gadget = VSMOP_FORM_L_BEAM_OPS,
		 col    = VSMOP_FORM_L_BEAM_OPS_STATUS,
		 row    = row,
		 txt    = " " );
  
  vdfrm$SetText( form   = cmdInfo->form,
		 gadget = VSMOP_FORM_L_BEAM_OPS,
		 col    = VSMOP_FORM_L_BEAM_OPS_PIECE_ID,
		 row    = row,
		 objID  = &pieceInfo->pieceOE.obj_id );

  vdfrm$SetText( form   = cmdInfo->form,
		 gadget = VSMOP_FORM_L_BEAM_OPS,
		 col    = VSMOP_FORM_L_BEAM_OPS_ITEM_ID,
		 row    = row,
		 objID  = &itemInfo->itemOE.obj_id );

  vdfrm$SetText( form   = cmdInfo->form,
		 gadget = VSMOP_FORM_L_BEAM_OPS,
		 col    = VSMOP_FORM_L_BEAM_OPS_CUT_ID,
		 row    = row,
		 objID  = &opInfo->cutOE.obj_id );

  /*
  ** Was parent a pretend???
  */
  sts = vdobj$IsAncestryValid( objID        = &opInfo->parentID,
			       superClassID = OPP_ACpretend_class_id );
  if( sts&1 )
  {
    /*
    ** Show downscan in macro column
    */
    *preName = 0;
    om$send( msg      = message ACpretend.ACgive_downscan(preName),
	     senderid = NULL_OBJID,
	     targetid = opInfo->parentID.objid,
	     targetos = opInfo->parentID.osnum );

    vdfrm$SetText( form   = cmdInfo->form,
		   gadget = VSMOP_FORM_L_BEAM_OPS,
		   col    = VSMOP_FORM_L_BEAM_OPS_CUT,
		   row    = row,
		   txt    = preName );

    /*
    ** Show macro name
    */
    vdobj$Get( objID = &opInfo->macroID, objName = macName );

    if( *macName == 0 ) strcpy( macName, "MACRO MISSING" );

    vdfrm$SetText( form   = cmdInfo->form,
		   gadget = VSMOP_FORM_L_BEAM_OPS,
		   col    = VSMOP_FORM_L_BEAM_OPS_MACRO,
		   row    = row,
		   txt    = macName );
    
  }
  else
  {
    /*
    ** Fill in cut info
    */
    vdobj$Get( objOE = &opInfo->cutOE, objName = buf );
    if( *buf == 0 ) vdobj$Get( objOE = &opInfo->cutOE, className = buf );
    if( *buf == 0 ) strcpy(buf,"MISSING");

    vdfrm$SetText( form   = cmdInfo->form,
		   gadget = VSMOP_FORM_L_BEAM_OPS,
		   col    = VSMOP_FORM_L_BEAM_OPS_CUT,
		   row    = row,
		   txt    = buf );
  }

  /*
  ** Done
  */
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ----------------------------------------------------------
** Row in item list was pressed
*/
IGRstat VSmopBeamCmd_FormNotifyItemList()
{
  IGRstat 	  retFlag = 0;
  IGRstat	  sts, msg;
  IGRint	  row, pos, sel;
  IGRint 	  i;
  TVSmopPieceInfo *pieceInfo;
  TVSmopItemInfo  *itemInfo;
  TVSmopOpInfo    *opInfo;
  TGRid 	  pieceID;
  TGRid  	  itemID;


  /*
  ** Get the selected item
  */
  sts = VSmopBeamCmd_GetPieceItem( &row, &sel, &pieceInfo, &itemInfo );
  if( !(sts&1) ) goto wrapup;
  
  /*
  ** Hilite graphics
  */
  dp$erase_hilite( msg = &msg );

  if( itemInfo->itemOE.obj_id.objid != NULL_OBJID )
  {
    if( sel )
    {
      /* -----------------------------------------------
      ** Fun with display modes 
      ** GRbdhd           Lite hilite
      ** GRbehd           Lite hilite
      ** GRhd    GRhdo    Lite hilite 
      ** GRhhd   GRhhdo   Very lite hilite
      ** GRhe    GRheo    No hilite
      ** GRbdhe  GRbdheo  No hilite
      ** GRbehe  GRbeheo  No hilute
      ** GRbd             No hilite
      ** GRbe             No hilite
      */
      vd_$bulk_display( dpmode = GRhdo, objenvs = &itemInfo->itemOE );
    }
  }

  /*
  ** Fill in the op list
  */
  vdfrm$SetText( form   = cmdInfo->form, 
                 gadget = VSMOP_FORM_L_BEAM_OPS, 
                 rows   = 0 );

  for( i = 0 ; 
      VSmopOpInfoVLA_GetNth(&itemInfo->opInfoVLA,i,NULL,&opInfo) ; 
      i++ )
  {
    VSmopBeamCmd_FillOpListRow( pieceInfo, itemInfo, opInfo );
  }


  /*
  ** Done
  */
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------------------------
** Fill row in piece tree
** Assumes it is a valid object
*/
IGRstat VSmopBeamCmd_FillItemListRow( TGRobj_env *pieceOE, TGRobj_env *itemOE )
{
  IGRstat retFlag = 0;
  IGRchar buf[40];
  IGRint  row;
  

  /*
  ** Append
  */
  vdfrm$GetText( form   = cmdInfo->form,
		 gadget = VSMOP_FORM_L_BEAM_ITEMS,
		 rows   = &row );
  
  vdobj$Get( objOE = itemOE, className = buf );
  
  vdfrm$SetText( form   = cmdInfo->form,
		 gadget = VSMOP_FORM_L_BEAM_ITEMS,
		 col    = VSMOP_FORM_L_BEAM_ITEMS_CLASS,
		 row    = row,
		 txt    = buf );

  vdfrm$SetText( form   = cmdInfo->form,
		 gadget = VSMOP_FORM_L_BEAM_ITEMS,
		 col    = VSMOP_FORM_L_BEAM_ITEMS_ITEM_ID,
		 row    = row,
		 objID  = &itemOE->obj_id );

  vdfrm$SetText( form   = cmdInfo->form,
		 gadget = VSMOP_FORM_L_BEAM_ITEMS,
		 col    = VSMOP_FORM_L_BEAM_ITEMS_PIECE_ID,
		 row    = row,
		 objID  = &pieceOE->obj_id );

  retFlag = 1;
  
  return retFlag;
}

/* ----------------------------------------------------------
** User picked a row in the list of pieces
*/
IGRstat VSmopBeamCmd_FormNotifyPieceList()
{
  IGRstat 	  retFlag = 0;
  IGRstat 	  sts;
  IGRint  	  row, pos, sel;
  IGRint  	  i;
  TGRid 	  pieceID;
  TVSmopPieceInfo *pieceInfo;
  TVSmopItemInfo  *itemInfo;
  IGRchar  	  buf[128];
  

  /*
  ** Get the selected row
  */
  row = -1;
  VIfld_get_active_row( cmdInfo->form, VSMOP_FORM_L_BEAM_PIECES, &row, &pos );
  if( row < 0 ) goto wrapup;
  
  /* 
  ** Lookup piece in vla
  */
  vdfrm$GetText( form   = cmdInfo->form, 
                 gadget = VSMOP_FORM_L_BEAM_PIECES,
                 col    = VSMOP_FORM_L_BEAM_PIECES_ID,
                 row    = row,
                 objID  = &pieceID );

  VSmopFindPieceInfoByID( &cmdInfo->pieceInfoVLA, &pieceID, &pieceInfo );
  if( pieceInfo == NULL ) goto wrapup;
  
  /*
  ** Fill the item columd
  */
  vdfrm$SetText( form   = cmdInfo->form, 
                 gadget = VSMOP_FORM_L_BEAM_ITEMS,
                 rows   = 0 );

  for( i = 0 ; 
       VSmopItemInfoVLA_GetNth(&pieceInfo->itemInfoVLA,i,NULL,&itemInfo) ;
       i++ )
  {
    VSmopBeamCmd_FillItemListRow( &pieceInfo->pieceOE, &itemInfo->itemOE );
  }
  
  /*
  ** Make the first item active
  */
  vdfrm$GetText( form   = cmdInfo->form,
		 gadget = VSMOP_FORM_L_BEAM_ITEMS,
		 col    = VSMOP_FORM_L_BEAM_ITEMS_CLASS,
		 row    = 0,
		 txt    = buf );

  vdfrm$SetText( form   = cmdInfo->form,
		 gadget = VSMOP_FORM_L_BEAM_ITEMS,
		 col    = VSMOP_FORM_L_BEAM_ITEMS_CLASS,
		 row    = 0,
		 txt    = buf,
		 sel    = 1 );
  
  /*
  ** Make it active
  */
  FIfld_set_active_row( cmdInfo->form, VSMOP_FORM_L_BEAM_ITEMS, 0, 0 );
  VSmopBeamCmd_FormNotifyItemList();
  
  /* 
  ** Done
  */
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ----------------------------------------------------------
** User located a beam or stiffener
*/
IGRstat VSmopBeamCmd_LocatedBeam( TGRobj_env *beamOE )
{
  IGRstat 	  retFlag = 0;
  TVSmopPieceInfo *pieceInfo;
  IGRint 	  cnt;
  IGRint  	  row, rows;
  TGRid   	  pieceID;
  IGRchar 	  pieceName[64];
  
  /*
  ** Arg check
  */
  if( (beamOE == NULL) || (beamOE->obj_id.objid == NULL_OBJID) ) goto wrapup;

  /*
  ** See if beam or stiffener is already in list
  */
  vdfrm$GetText( form   = cmdInfo->form,
		 gadget = VSMOP_FORM_L_BEAM_PIECES,
		 rows   = &rows );
  
  for( row = 0 ; row < rows ; row++ )
  {
    vdfrm$GetText( form   = cmdInfo->form,
		   gadget =  VSMOP_FORM_L_BEAM_PIECES,
		   col    =  VSMOP_FORM_L_BEAM_PIECES_ID,
		   row    = row,
		   objID  = &pieceID );
  
    if( (pieceID.objid == beamOE->obj_id.objid) &&
	(pieceID.osnum == beamOE->obj_id.osnum) )
    {
      /*
      ** Make it the active row
      */
      VSmopBeamCmd_FormNotifyNthRowPieceList( &row );

      /*
      ** Done
      */
      retFlag = 1;
      goto wrapup;
    }
  }
  
  /*
  ** Add beam to the list
  */
  VSmopPieceInfoVLA_GetAppend( &cmdInfo->pieceInfoVLA, &pieceInfo );
  if( pieceInfo == NULL )
  {
    printf("Problem getting pieceInfo Entry\n");
    goto wrapup;
  }
  pieceInfo->pieceOE = *beamOE;
      
  /*
  ** Fill in the item info 
  */
  VSmopFillBeamItemVLA( pieceInfo );
  
  /*
  ** Add beam to form list
  */
  vdobj$Get( objOE = beamOE, objName = pieceName );

  vdfrm$SetText( form   = cmdInfo->form,
		 gadget = VSMOP_FORM_L_BEAM_PIECES,
		 col    = VSMOP_FORM_L_BEAM_PIECES_NAME,
		 row    = rows,
		 txt    = pieceName,
		 sel    = 1 );

  vdfrm$SetText( form   = cmdInfo->form,
		 gadget = VSMOP_FORM_L_BEAM_PIECES,
		 col    = VSMOP_FORM_L_BEAM_PIECES_ID,
		 row    = rows,
		 objID  = &beamOE->obj_id );
  
  /*
  ** Make it active
  */
  FIfld_set_active_row( cmdInfo->form, VSMOP_FORM_L_BEAM_PIECES, rows, 0 );
  
  /*
  ** Poke it
  */
  VSmopBeamCmd_FormNotifyPieceList();
  
  /*
  ** Done
  */
  retFlag = 1;
wrapup:
  return retFlag;
}

/* ----------------------------------------------------------
** Form notification
*/
IGRstat VSmopBeamCmd_FormNotify()
{
  IGRstat retFlag;
  IGRint  state;
  IGRint  active_row, row, pos;
  IGRchar className[128];


  retFlag      = 0;
  row          = -1;
  active_row   = -1;
  className[0] = '\0';

  /*
  ** Get the selected row
  */
  VIfld_get_active_row( cmdInfo->form,
			VSMOP_FORM_L_BEAM_ITEMS,
			&active_row,
			&pos );

  if( active_row >= 0 )
  {
    /*
    ** Lookup the class name in the row
    */
    vdfrm$GetText( form   = cmdInfo->form,
                   gadget = VSMOP_FORM_L_BEAM_ITEMS,
                   col    = VSMOP_FORM_L_BEAM_ITEMS_CLASS,
                   row    = active_row,
                   txt    = className );
    /*
    ** Check if the beam is a beam object of VSbooBeam
    */
    if( strcmp(className,"VSbooBeam") )
    {
      VIg_set_state( cmdInfo->form, VSMOP_FORM_T_DELETE_BEAM, 0 );
      VIg_disable( cmdInfo->form, VSMOP_FORM_T_DELETE_BEAM );
    }
    else
      VIg_enable( cmdInfo->form, VSMOP_FORM_T_DELETE_BEAM );

    /*
    ** Lookup the class name in the row (active_row - 1)
    */
    className[0] = '\0';
    row = active_row - 1;
    if( row >= 0 )
    {
      vdfrm$GetText( form   = cmdInfo->form,
                     gadget = VSMOP_FORM_L_BEAM_ITEMS,
                     col    = VSMOP_FORM_L_BEAM_ITEMS_CLASS,
                     row    = row,
                     txt    = className );
      /*
      ** Check if this beam is before a beam object of VSbooBeam
      */
      /*
      if( strcmp(className,"VSbooBeam") )
        VIg_disable( cmdInfo->form, VSMOP_FORM_B_INSERT_BEAM );
      else
        VIg_enable( cmdInfo->form, VSMOP_FORM_B_INSERT_BEAM );
      */
    }
  }

  active_row   = -1;
  className[0] = '\0';

  /*
  ** Process gadget
  */
  switch( cmdInfo->gadget )
  {
    case VSMOP_FORM_L_BEAM_PIECES:
      VSmopBeamCmd_FormNotifyPieceList();
      break;

    case VSMOP_FORM_L_BEAM_ITEMS:
      VSmopBeamCmd_FormNotifyItemList();
      break;

    case VSMOP_FORM_L_BEAM_OPS:
      VSmopBeamCmd_FormNotifyOpList();
      break;

    case VSMOP_FORM_B_INSERT_BEAM:
      VSmopBeamCmd_FormNotifyInsertNewBeam();
      FIg_set_state( cmdInfo->form, VSMOP_FORM_B_INSERT_BEAM, 0 );
      break;

    case FI_CANCEL:
      break;

    case FI_RESET:
      VSmopBeamCmd_Delete();
      VSmopBeamCmd_ResetForm();
      VSmopBeamCmd_LocatingBeam();
      break;

    case FI_EXECUTE:
    case FI_ACCEPT:
      VSmopBeamCmd_FormNotifyExecute();
      break;
  }

  /*
  ** Get the selected row
  */
  active_row = -1;
  className[0] = '\0';
  VIfld_get_active_row( cmdInfo->form,
			VSMOP_FORM_L_BEAM_ITEMS,
			&active_row,
			&pos );

  if( active_row >= 0 )
  {
    if( (cmdInfo->gadget != FI_ACCEPT) && (cmdInfo->gadget != FI_CANCEL) )
    {
      /*
      ** Lookup the class name in the row
      */
      vdfrm$GetText( form   = cmdInfo->form,
                     gadget = VSMOP_FORM_L_BEAM_ITEMS,
                     col    = VSMOP_FORM_L_BEAM_ITEMS_CLASS,
                     row    = active_row,
                     txt    = className );
      /*
      ** Check if the beam is a object of VSbooBeam
      */
      if( strcmp(className,"VSbooBeam") )
      {
        VIg_set_state( cmdInfo->form, VSMOP_FORM_T_DELETE_BEAM, 0 );
        VIg_disable( cmdInfo->form, VSMOP_FORM_T_DELETE_BEAM );
      }
      else
        VIg_enable( cmdInfo->form, VSMOP_FORM_T_DELETE_BEAM );

      /*
      ** Lookup the class name in the row (active_row - 1)
      */
      className[0] = '\0';
      row = active_row - 1;
      if( row >= 0 )
      {
        vdfrm$GetText( form   = cmdInfo->form,
                       gadget = VSMOP_FORM_L_BEAM_ITEMS,
                       col    = VSMOP_FORM_L_BEAM_ITEMS_CLASS,
                       row    = row,
                       txt    = className );
        /*
        ** Check if the new beam is before a object of VsbooBeam
        */
	/*
        if( strcmp(className,"VSbooBeam") )
          VIg_disable( cmdInfo->form, VSMOP_FORM_B_INSERT_BEAM );
        else
          VIg_enable( cmdInfo->form, VSMOP_FORM_B_INSERT_BEAM );
	*/
      }
    }
  }
  
  // Done
  retFlag = 1;
  return retFlag;
}

/* ---------------------------------------------------------
** Used to disable most of the form when loacting graphics
*/
IGRstat VSmopBeamCmd_SetFormState( IGRint state )
{
//  Form form = cmdInfo->form;
    Form form;

  form = cmdInfo->form;


  /*
  ** Might get called during init process
  */
  if( form == NULL ) goto wrapup;
  
  if( state )
  {
    VIg_enable( form, VSMOP_FORM_L_BEAM_PIECES );
    VIg_enable( form, VSMOP_FORM_L_BEAM_ITEMS );
    VIg_enable( form, VSMOP_FORM_L_BEAM_OPS );
    VIg_enable( form, VSMOP_FORM_T_BEAM_PROTECT_X );
    VIg_enable( form, VSMOP_FORM_B_BEAM_LOCATE_OPS );
    VIg_enable( form, VSMOP_FORM_B_LOCATE_BEAM );
    VIg_enable( form, VSMOP_FORM_T_DELETE_BEAM );
    /*
    VIg_enable( form, VSMOP_FORM_B_INSERT_BEAM );
    */
    VIg_enable( form, 1 );
    VIg_enable( form, 2 );
    VIg_enable( form, 3 );
  }
  else {

    VIg_disable( form, VSMOP_FORM_L_BEAM_PIECES );
    VIg_disable( form, VSMOP_FORM_L_BEAM_ITEMS );
    VIg_disable( form, VSMOP_FORM_L_BEAM_OPS );
    VIg_disable( form, VSMOP_FORM_T_BEAM_PROTECT_X );
    VIg_disable( form, VSMOP_FORM_B_BEAM_LOCATE_OPS );
    VIg_disable( form, VSMOP_FORM_B_LOCATE_BEAM );
    VIg_disable( form, VSMOP_FORM_T_DELETE_BEAM );
    /*
    VIg_disable( form, VSMOP_FORM_B_INSERT_BEAM );
    */

    VIg_disable( form, 1 );
    VIg_disable( form, 2 );
    VIg_disable( form, 3 );
  }

wrapup:
  return 1;
}

/* 
** ----------------------------------------------------------
** Select the Nth row in the list of pieces
** ----------------------------------------------------------
*/
IGRstat VSmopBeamCmd_FormNotifyNthRowItemList( IGRint *nthRow )
{
  IGRstat 	  retFlag = 0;
  IGRint 	  row;

  
  retFlag = 0;
  if( nthRow == NULL ) goto wrapup;
  row = *nthRow;
  if( row < 0 ) goto wrapup;

  FIfld_set_select( cmdInfo->form,
		    VSMOP_FORM_L_BEAM_ITEMS,
		    row,
		    0,
		    1 );
  FIfld_set_active_row( cmdInfo->form, VSMOP_FORM_L_BEAM_ITEMS, row, 0 );
 
  VSmopBeamCmd_FormNotifyItemList();
  
  /*
  ** Done
  */
  retFlag = 1;
  
wrapup:
  return retFlag;
} /* VSmopBeamCmd_FormNotifyNthRowItemList */

/* 
** ----------------------------------------------------------
** Select the Nth row in the list of pieces
** ----------------------------------------------------------
*/
IGRstat VSmopBeamCmd_FormNotifyNthRowPieceList( IGRint *nthRow )
{
  IGRstat 	  retFlag = 0;
  IGRint 	  row;

  
  retFlag = 0;
  if( nthRow == NULL ) goto wrapup;
  row = *nthRow;
  if( row < 0 ) goto wrapup;

  FIfld_set_select( cmdInfo->form,
		    VSMOP_FORM_L_BEAM_PIECES,
		    row,
		    0,
		    1 );
  FIfld_set_active_row( cmdInfo->form, VSMOP_FORM_L_BEAM_PIECES, row, 0 );
 
  VSmopBeamCmd_FormNotifyPieceList();
  
  /*
  ** Done
  */
  retFlag = 1;
  
wrapup:
  return retFlag;
} /* VSmopBeamCmd_FormNotifyNthRowPieceList */

/* 
** ----------------------------------------------------------------------
** Delete the actual beam selected if no operators is associated with it.
** Clear the command form for the beam.
** ---------------------------------------------------------------------
*/
IGRstat VSmopBeamCmd_DeleteBeamWithOp( TGRobj_env *cutOE )
{
  IGRstat	     retFlag;
  IGRint	     i, j, row, pos, sel, rows, item_rows;
  TGRid		     pieceID;
  TGRid		     itemID;
  TVSmopPieceInfo    *pieceInfo;
  TVSmopItemInfo     *itemInfoNew;
  TVSmopItemInfo     *itemInfo;
  TVSmopPieceInfoVLA *pieceInfoVLA;
  TVSmopItemInfoVLA  *itemInfoVLA;
  IGRint	     NumberPiece;
  IGRint	     matchRow;
  IGRchar            className[128];
  IGRchar            pieceName[128];
  

  retFlag = 0;
  NumberPiece = 0;
  matchRow = -1;
  className[0] = '\0';

  /*
  ** Get the selected row
  */
  row = -1;
  VIfld_get_active_row( cmdInfo->form, VSMOP_FORM_L_BEAM_ITEMS, &row, &pos );
  if( row < 0 ) goto wrapup;

  /*
  ** Lookup the class name in the row
  */
  vdfrm$GetText( form   = cmdInfo->form,
                 gadget = VSMOP_FORM_L_BEAM_ITEMS,
                 col    = VSMOP_FORM_L_BEAM_ITEMS_CLASS,
                 row    = row,
                 txt    = className );

  FIfld_get_num_rows( cmdInfo->form, VSMOP_FORM_L_BEAM_PIECES, &rows );
  FIfld_get_num_rows( cmdInfo->form, VSMOP_FORM_L_BEAM_ITEMS, &item_rows );

  /*
  ** Lookup piece in vla
  */
  vdfrm$GetText( form   = cmdInfo->form,
                 gadget = VSMOP_FORM_L_BEAM_ITEMS,
                 col    = VSMOP_FORM_L_BEAM_ITEMS_PIECE_ID,
                 row    = row,
                 objID  = &pieceID );

  /*
  ** Lookup item in vla
  */
  vdfrm$GetText( form   = cmdInfo->form,
                 gadget = VSMOP_FORM_L_BEAM_ITEMS,
                 col    = VSMOP_FORM_L_BEAM_ITEMS_ITEM_ID,
                 row    = row,
                 objID  = &itemID );

  /*
  ** Go through the piece VLA to find the matching plate
  */
  pieceInfoVLA = &(cmdInfo->pieceInfoVLA);

  /*
  ** Check if there is a matching in piece VLA
  */
  for( i = 0 ; i < rows ; i++ )
  {
    VSmopPieceInfoVLA_GetNth( pieceInfoVLA, i, NULL, &pieceInfo );

    itemInfoVLA = &pieceInfo->itemInfoVLA; 

    if( (pieceID.objid == pieceInfo->pieceOE.obj_id.objid) &&
	(pieceID.osnum == pieceInfo->pieceOE.obj_id.osnum) )
    {
      for( j = 0 ; j < item_rows ; j++ )
      {
	VSmopItemInfoVLA_GetNth( itemInfoVLA, j , NULL, &itemInfo );

	if( (itemID.objid == itemInfo->itemOE.obj_id.objid) &&
            (itemID.osnum == itemInfo->itemOE.obj_id.osnum) )
	{
          matchRow = j;
          VSmopBeamCmd_RealDeleteBeam( &itemID, cutOE );
          VSmopItemInfoVLA_FreeNth( itemInfoVLA, j );
          continue;
	}

        VSmopItemInfoVLA_OverwriteNth( itemInfoVLA,
                                       &NumberPiece,
                                       NULL,
                                       &itemInfo,
				       &itemInfoNew );
        VSmopItemInfoVLA_ResetDataP( itemInfoNew );
        NumberPiece++;
      }

      break;
    }

    if( i == rows-1 ) goto wrapup;
  }

  if( NumberPiece < item_rows )
    VSmopItemInfoVLA_RearrangeVla( itemInfoVLA, &NumberPiece, &item_rows );

  if( matchRow >= 0 )
    VSmopBeamCmd_ClearNthItemInfoOnForm( &matchRow );

  /*
  ** Check the beam deleted is in first row
  */
  if( row == 0 )
  {
    /*
    ** Lookup item in vla
    */
    vdfrm$GetText( form   = cmdInfo->form,
                   gadget = VSMOP_FORM_L_BEAM_ITEMS,
                   col    = VSMOP_FORM_L_BEAM_ITEMS_ITEM_ID,
                   row    = 0,
                   objID  = &itemID );

    FIfld_get_num_rows( cmdInfo->form, VSMOP_FORM_L_BEAM_ITEMS, &item_rows );

    /*
    ** Set the piece ID of all items to the first item ID
    */
    for( i = 0 ; i < item_rows ; i++ )
    {
      vdfrm$SetText( form   = cmdInfo->form,
                     gadget = VSMOP_FORM_L_BEAM_ITEMS,
                     col    = VSMOP_FORM_L_BEAM_ITEMS_PIECE_ID,
                     row    = i,
                     objID  = &itemID );
    }

    row = -1;
    VIfld_get_active_row( cmdInfo->form, VSMOP_FORM_L_BEAM_PIECES, &row, &pos );
    if( row < 0 ) goto wrapup;

    vdfrm$SetText( form   = cmdInfo->form,
                   gadget = VSMOP_FORM_L_BEAM_PIECES,
                   col    = VSMOP_FORM_L_BEAM_PIECES_ID,
                   row    = row,
                   objID  = &itemID );

    /*
    ** Look up the piece Info
    */
    pieceInfo = NULL;
    VSmopFindPieceInfoByID( pieceInfoVLA, &pieceID, &pieceInfo );
    if( pieceInfo == NULL ) goto wrapup;

    /*
    ** Look up the item Info
    */
    itemInfo = NULL;
    VSmopFindItemInfoByID( &pieceInfo->itemInfoVLA, &itemID, &itemInfo );
    if( itemInfo == NULL ) goto wrapup;

    /*
    ** Change the piece info into the first item info
    */
    pieceInfo->pieceOE = itemInfo->itemOE;

    /*
    ** Get the pieceName
    */
    vdobj$Get( objOE = &itemInfo->itemOE, objName = pieceName );
 
    vdfrm$SetText( form   = cmdInfo->form,
                   gadget = VSMOP_FORM_L_BEAM_PIECES,
                   col    = VSMOP_FORM_L_BEAM_PIECES_NAME,
                   row    = row,
                   txt    = pieceName,
                   sel    = 1 );
  }

  /*
  ** Done
  */
  retFlag = 1;
  
wrapup:
  return retFlag;
} /* VSmopBeamCmd_DeleteBeamWithOp */

/* 
** -------------------------------------------------------
** Delete the item in the command form.
** -------------------------------------------------------
*/
IGRstat VSmopBeamCmd_ClearNthItemInfoOnForm( IGRint *NthPiece )
{
  IGRstat	     retFlag;
  IGRint	     i, rows, row, pos;
  

  retFlag = 0;

  FIfld_delete_rows( cmdInfo->form,
                     VSMOP_FORM_L_BEAM_ITEMS,
                     *NthPiece,
                     1 );
  
  rows = 0;
  FIfld_get_num_rows( cmdInfo->form, VSMOP_FORM_L_BEAM_OPS, &rows );
  if( rows > 0 )
  {
    FIfld_delete_rows( cmdInfo->form,
                       VSMOP_FORM_L_BEAM_OPS,
                       0,
                       rows );
  }
  
  /*
  ** Get the selected row
  */
  row = -1;
  VIfld_get_active_row( cmdInfo->form, VSMOP_FORM_L_BEAM_PIECES, &row, &pos );
  if( row < 0 ) goto wrapup;

  /*
  ** Fill up the fields for the piece
  */
  VSmopBeamCmd_FormNotifyNthRowPieceList( &row );

  /*
  ** Done
  */
  retFlag = 1;
  
wrapup:
  return retFlag;
} /* VSmopBeamCmd_ClearNthItemInfoOnForm */

/* 
** -------------------------------------------------------
** Delete the beam and related items in the command form.
** -------------------------------------------------------
*/
IGRstat VSmopBeamCmd_ClearNthPieceInfoOnForm( IGRint *NthPiece )
{
  IGRstat	     retFlag;
  IGRint	     i, rows, row, pos;
  

  retFlag = 0;

  /*
  ** Delete the piece rows
  */
  FIfld_delete_rows( cmdInfo->form,
                     VSMOP_FORM_L_BEAM_PIECES,
                     *NthPiece,
                     1 );

  rows = 0;
  FIfld_get_num_rows( cmdInfo->form, VSMOP_FORM_L_BEAM_ITEMS, &rows );
  if( rows > 0 )
  {
    FIfld_delete_rows( cmdInfo->form,
                       VSMOP_FORM_L_BEAM_ITEMS,
                       0,
                       rows );
  }
  
  rows = 0;
  FIfld_get_num_rows( cmdInfo->form, VSMOP_FORM_L_BEAM_OPS, &rows );
  if( rows > 0 )
  {
    FIfld_delete_rows( cmdInfo->form,
                       VSMOP_FORM_L_BEAM_OPS,
                       0,
                       rows );
  }
  
  /*
  ** Get the selected row
  */
  row = -1;
  VIfld_get_active_row( cmdInfo->form, VSMOP_FORM_L_BEAM_PIECES, &row, &pos );
  if( row < 0 ) goto wrapup;

  /*
  ** Fill up the fields for the piece
  */
  VSmopBeamCmd_FormNotifyNthRowPieceList( &row );

  /*
  ** Done
  */
  retFlag = 1;
  
wrapup:
  return retFlag;
} /* VSmopBeamCmd_ClearNthPieceInfoOnForm */

/* 
** -------------------------------------------------------
** Delete the last operator and beam.
** -------------------------------------------------------
*/
IGRstat VSmopBeamCmd_RealDeleteBeam( TGRid *itemID, TGRobj_env *cutOE )
{
  IGRstat	  retFlag;
  IGRlong	  status, msg;
  TGRid	 	  lastOp;
  IGRint	  AmDeleted;
  TGRmd_env	  myEnv;
  

  retFlag = 0;

  lastOp = cutOE->obj_id;
  myEnv  = cutOE->mod_env;
  
  status = 
  om$send( msg      = message VSmodFeature.VSremoveOperator(&msg,
                                                            &myEnv,
                                                            &lastOp,
                                                            &AmDeleted),
           targetid = itemID->objid,
           targetos = itemID->osnum,
           senderid = NULL_OBJID );
  if( !(status&msg&1) ) goto wrapup;

  /*
  ** Done
  */
  retFlag = 1;
  
wrapup:
  return retFlag;
} /* VSmopBeamCmd_RealDeleteBeam */

/*
** --------------------------------------------------------------
** Reconnect the brand new part to its parent.
** --------------------------------------------------------------
*/
IGRstat VSmopBeamCmd_ReconnectToParent( TGRid      *parentID,
                                        TGRobj_env *newPart )
{
  IGRstat retFlag;
  IGRstat sts;
  IGRint  parentCnt;
  IGRint  cn_type;


  retFlag = 0;

  /*
  ** Reconnect
  */
  parentCnt = 1;
  sts = om$send( msg      = message NDnode.NDconnect(parentCnt,
                                                     parentID,
                                                     NULL_GRID,
                                                     ND_FULL),
                 senderid = NULL_OBJID,
                 targetid = newPart->obj_id.objid,
                 targetos = newPart->obj_id.osnum );
  if( !(sts&1) )
  {
    UI_status("Problem connecting parents");
    goto wrapup;
  }

  /*
  ** Recompute
  */
  cn_type = ND_COMP;
  nd$wait_batch( type       = GR_GEOM_POSTED,
                 nb_obj     = 1,
                 l_object   = &newPart->obj_id,
                 l_obj_info = &cn_type );
  nd$exec_batch();

  /*
  ** Done
  */
  retFlag = 1;


wrapup:
  return retFlag;
} /* VSmopBeamCmd_ReconnectToParent */

/* ----------------------------------------------------------
** Usual low level routines
*/
IGRstat VSmopBeamCmd_Init( TVSmopCmdInfo *a_cmdInfo )
{
  IGRstat retFlag = 0;


  /* 
  ** Clear instance data
  */
  cmdInfo = a_cmdInfo;

  /*
  ** Init the plate vla
  */
  VSmopPieceInfoVLA_Init( &cmdInfo->pieceInfoVLA );

  /*
  ** Done
  */
  cmdInfo->initFlag = 1;
  retFlag = 1;

wrapup:
  return retFlag;
}
IGRstat VSmopBeamCmd_Sleep()
{
  return 1;
}
IGRstat VSmopBeamCmd_Wakeup()
{
  return 1;
}
IGRstat VSmopBeamCmd_Delete()
{
  IGRstat msg;


  /*
  ** Free the vla lists
  */
  VSmopBeamCmd_FreeVlaLists();

  dp$erase_hilite( msg = &msg );

  return 1;
}

/*
** ----------------------------------------------------------------------
** Create a dummy operator
** ---------------------------------------------------------------------
*/
IGRstat VSmopBeamCmd_CreateDummyOp( TGRobj_env *ItemOE,
                                    TGRobj_env *DummyOpOE )
{
  IGRstat               retFlag;
  IGRstat               sts;
  IGRint                status;
  struct IGRpolyline    line_def;
  struct GRvg_construct cnst_lis;
  IGRdouble             points[6];
  IGRlong               loc_msg;
  struct GRmd_env       *md_env;
  struct GRsymbology    symb;
  IGRlong               NumberOfBytes, BytesReceived;
  IGRshort              cur_level;
  TGRid                 line;


  retFlag    = 0;
  md_env     = &ItemOE->mod_env;
  line.objid = NULL_OBJID;

  /*
  ** Give the end points of a linestring
  */
  points[0] = points[1] = points[2] = points[4] = points[5] = 0.0;
  points[3] = 1.0;

  /*
  ** Get the symbology
  */
  status =
  om$send( msg      = message GRvg.GRgetsymb( &loc_msg, &symb ),
           senderid = NULL_OBJID,
           targetos = ItemOE->obj_id.osnum,
           targetid = ItemOE->obj_id.objid );
  if( !(status&loc_msg&1) ) goto wrapup;

  /*
  ** Get the active level
  */
  NumberOfBytes = sizeof( IGRshort );
  gr$get_active_level( msg     = &loc_msg,
                       sizbuf  = &NumberOfBytes,
                       buffer  = &cur_level,
                       nret    = &BytesReceived );
  if( !(loc_msg&1) ) goto wrapup;

  /*
  ** Construct the linestring
  */
  line_def.num_points = 2;
  line_def.points = points;
  cnst_lis.msg = &loc_msg;
  cnst_lis.env_info = md_env;
  cnst_lis.display = &symb.display_attr;
  cnst_lis.geometry = (char *) &line_def;
  cnst_lis.newflag = FALSE;
  cnst_lis.level = cur_level;
  cnst_lis.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
  cnst_lis.class_attr = NULL;
  cnst_lis.name = NULL;

  line.osnum = md_env->md_id.osnum;
  status = om$construct( classid = OPP_GR3dlineseg_class_id,
                         osnum = md_env->md_id.osnum,
                         p_objid = &line.objid,
                         msg = message GRgraphics.GRaltconstruct(&cnst_lis) );
  if( !(status&loc_msg&1) ) goto wrapup;

  DummyOpOE->obj_id = line;
  DummyOpOE->mod_env = *md_env;

  /*
  ** Done
  */
  retFlag = 1;


wrapup:
  return retFlag;
} /* VSmopBeamCmd_CreateDummyOp */

/* ------------------------------------------------
** Waiting to pick beam
** form processing will be disabled here
*/
IGRstat VSmopBeamCmd_LocatingBeam()
{
  TGRid   pplID;
  IGRint  pplRET;

  vdppl$Load( name = "VSmopBeam", pplID = &pplID );
  vdppl$Run( pplID = &pplID, name = "locateBeam", ret = &pplRET );
  vdppl$Delete( pplID = &pplID );

  return 1;
} /* VSmopBeamCmd_LocatingBeam */


end implementation Root;
