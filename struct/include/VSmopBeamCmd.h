/* $Id: VSmopBeamCmd.h,v 1.1 2001/01/16 23:53:52 ramarao Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        include/VSmopBeamCmd.h
 *
 * Description: Modify Operator Functions for Beams
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmopBeamCmd.h,v $
 *      Revision 1.1  2001/01/16 23:53:52  ramarao
 *      *** empty log message ***
 *
 * Revision 1.2  2000/06/07  16:00:10  pinnacle
 * Replaced: struct/include/VSmopBeamCmd.h for:  by mdong for Service Pack
 *
 * Revision 1.1  2000/06/01  15:44:52  pinnacle
 * Created: struct/include/VSmopBeamCmd.h by mdong for Service Pack
 *
 *
 * History:
 * MM/DD/YY  	AUTHOR  	DESCRIPTION
 * 05/05/00     Ming      	Creation
 ***************************************************************************/

#ifndef VSmopBeamCmd_include
#define VSmopBeamCmd_include
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* ----------------------------------------------------------
 * C++
 */
#if defined(__cplusplus)
extern "C" {
#endif

#define VSMOP_FORM_F_BEAM_STATUS      		10

#define VSMOP_FORM_L_BEAM_PIECES      		14
#define VSMOP_FORM_L_BEAM_PIECES_NAME  		0
#define VSMOP_FORM_L_BEAM_PIECES_ID    		1

#define VSMOP_FORM_L_BEAM_ITEMS           	11
#define VSMOP_FORM_L_BEAM_ITEMS_CLASS     	0
#define VSMOP_FORM_L_BEAM_ITEMS_PIECE_ID  	1
#define VSMOP_FORM_L_BEAM_ITEMS_ITEM_ID   	2

#define VSMOP_FORM_L_BEAM_OPS         		13
#define VSMOP_FORM_L_BEAM_OPS_STATUS   		0
#define VSMOP_FORM_L_BEAM_OPS_MACRO    		1
#define VSMOP_FORM_L_BEAM_OPS_CUT      		2
#define VSMOP_FORM_L_BEAM_OPS_PIECE_ID 		3
#define VSMOP_FORM_L_BEAM_OPS_ITEM_ID  		4
#define VSMOP_FORM_L_BEAM_OPS_CUT_ID   		5

#define VSMOP_FORM_T_BEAM_PROTECT_X   		12
#define VSMOP_FORM_B_BEAM_LOCATE_OPS  		15
#define VSMOP_FORM_B_LOCATE_BEAM 		16
#define VSMOP_FORM_T_DELETE_BEAM 		17
#define VSMOP_FORM_B_INSERT_BEAM 		19


extern IGRstat VSmopBeamCmd_GetPieceItemOp __((IGRint          *row,
                                     	       IGRint          *sel,
                                     	       TVSmopPieceInfo **pieceInfo,
                                     	       TVSmopItemInfo  **itemInfo,
                                     	       TVSmopOpInfo    **opInfo));

extern IGRstat VSmopBeamCmd_GetPieceItem __((IGRint          *row,
                                     	     IGRint          *sel,
                                     	     TVSmopPieceInfo **pieceInfo,
                                     	     TVSmopItemInfo  **itemInfo));

extern IGRstat VSmopBeamCmd_LocatedOpOne __((TVSmopPieceInfo *pieceInfo,
                                   	     TVSmopItemInfo  *itemInfo,
                                   	     TVSmopOpInfo    *a_opInfo));

extern IGRstat VSmopBeamCmd_LocatedOp    __((TGRobj_env *opOE));

extern IGRstat VSmopBeamCmd_FormNotifyInsertNewBeam __(());

extern IGRstat VSmopBeamCmd_RearrangeFormAndVla __(());

extern IGRstat VSmopBeamCmd_InsertNewBeamIntoVlaAndForm 
						__((TGRobj_env *newBeam));

extern IGRstat VSmopBeamCmd_ChangeParent __((TGRobj_env *newPlate));

extern IGRstat VSmopBeamCmd_ResetForm __(());

extern IGRstat VSmopBeamCmd_CheckOrModifyMacroParent
						 __((TVSmopOpInfo    *opInfo,
						     int	     *row));

extern IGRstat VSmopBeamCmd_FormNotifyExecute __(());

extern IGRstat VSmopBeamCmd_FormNotifyOpList __(());

extern IGRstat VSmopBeamCmd_FillOpListRow __((TVSmopPieceInfo *pieceInfo,
                               		      TVSmopItemInfo  *itemInfo,
                               		      TVSmopOpInfo    *opInfo));

extern IGRstat VSmopBeamCmd_FormNotifyItemList __(());

extern IGRstat VSmopBeamCmd_FillItemListRow __((TGRobj_env *pieceOE,
						TGRobj_env *itemOE));

extern IGRstat VSmopBeamCmd_FormNotifyPieceList __(());

extern IGRstat VSmopBeamCmd_LocatedBeam __((TGRobj_env *beamOE));

extern IGRstat VSmopBeamCmd_FormNotify        __(());

extern IGRstat VSmopBeamCmd_SetFormState __((IGRint state));

extern IGRstat VSmopBeamCmd_FormNotifyNthRowItemList __((IGRint *nthRow));

extern IGRstat VSmopBeamCmd_FormNotifyNthRowPieceList __((IGRint *nthRow));

extern IGRstat VSmopBeamCmd_DeleteBeamWithOp __((TGRobj_env *cutOE));

extern IGRstat VSmopBeamCmd_ClearNthItemInfoOnForm __((IGRint *NthPiece));

extern IGRstat VSmopBeamCmd_ClearNthPieceInfoOnForm __((IGRint *NthPiece));

extern IGRstat VSmopBeamCmd_RealDeleteBeam __((TGRid *itemID,
					       TGRobj_env *cutOE));

extern IGRstat VSmopBeamCmd_Init   __((TVSmopCmdInfo *cmdInfo));

extern IGRstat VSmopBeamCmd_Sleep  __(());

extern IGRstat VSmopBeamCmd_Wakeup __(());

extern IGRstat VSmopBeamCmd_Delete __(());

extern IGRstat VSmopBeamCmd_CreateDummyOp __((TGRobj_env *ItemOE,
                                              TGRobj_env *DummyOpOE));

extern IGRstat VSmopBeamCmd_FreeVlaLists __(());

extern IGRstat VSmopBeamCmd_LocatingBeam __(());

extern IGRstat VSmopBeamCmd_ReconnectToParent __((TGRid      *parentID,
                                                  TGRobj_env *newPart));

// -------------------------
#if defined(__cplusplus)
}
#endif
