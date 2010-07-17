/* $Id: VSmopCmd.h,v 1.2 2001/01/16 23:53:21 ramarao Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        include/VSmopCmd.h
 *
 * Description: Modify Operator Functions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmopCmd.h,v $
 *      Revision 1.2  2001/01/16 23:53:21  ramarao
 *      *** empty log message ***
 *
 * Revision 1.2  2000/06/08  18:09:52  pinnacle
 * Replaced: struct/include/VSmopCmd.h for:  by mdong for Service Pack
 *
 * Revision 1.1  2000/06/07  15:54:16  pinnacle
 * Created: struct/include/VSmopCmd.h by mdong for Service Pack
 *
 * Revision 1.4  1999/07/27  20:28:52  pinnacle
 * (No comment)
 *
 * Revision 1.3  1999/06/16  15:45:16  pinnacle
 * (No comment)
 *
 * Revision 1.2  1999/05/06  21:49:18  pinnacle
 * (No comment)
 *
 * Revision 1.1  1999/04/26  20:52:08  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/26/99  ah      Creation
 ***************************************************************************/

#ifndef VSmopCmd_include
#define VSmopCmd_include
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

typedef struct 
{
  Form   form;
  IGRint gadget;
  IGRint displayForm;
  
//TVSmopItemInfos *itemInfos;
  
  IGRint initFlag;
  IGRint  retFlag;

  TVSmopPieceInfoVLA pieceInfoVLA;

} TVSmopCmdInfo;

#define VSMOP_FORM_F_STATUS      10

#define VSMOP_FORM_L_PIECES      14
#define VSMOP_FORM_L_PIECES_NAME  0
#define VSMOP_FORM_L_PIECES_ID    1

#define VSMOP_FORM_L_ITEMS          11
#define VSMOP_FORM_L_ITEMS_CLASS     0
#define VSMOP_FORM_L_ITEMS_PIECE_ID  1
#define VSMOP_FORM_L_ITEMS_ITEM_ID   2

#define VSMOP_FORM_L_OPS         13
#define VSMOP_FORM_L_OPS_STATUS   0
#define VSMOP_FORM_L_OPS_MACRO    1
#define VSMOP_FORM_L_OPS_CUT      2
#define VSMOP_FORM_L_OPS_PIECE_ID 3
#define VSMOP_FORM_L_OPS_ITEM_ID  4
#define VSMOP_FORM_L_OPS_CUT_ID   5

#define VSMOP_FORM_T_PROTECT_X   12
#define VSMOP_FORM_B_LOCATE_OPS  15
#define VSMOP_FORM_B_LOCATE_PLATE 16
#define VSMOP_FORM_T_DELETE_PLATE 17
#define VSMOP_FORM_B_INSERT_PLATE 19

extern IGRstat VSmopCmd_FillPlateItemList __((TGRobj_env *plateOE));
extern IGRstat VSmopCmd_FormNotify        __(());
extern IGRstat VSmopCmd_FormNotifyPieceList __(());

extern IGRstat VSmopCmd_LocatedOp    __((TGRobj_env *opOE));
extern IGRstat VSmopCmd_LocatedPlate __((TGRobj_env *plateOE));

extern IGRstat VSmopCmd_Init   __((TVSmopCmdInfo *cmdInfo));
extern IGRstat VSmopCmd_Sleep  __(());
extern IGRstat VSmopCmd_Wakeup __(());
extern IGRstat VSmopCmd_Delete __(());
extern IGRstat VSmopCmd_FillOpListRow __((TVSmopPieceInfo *pieceInfo,
                               		  TVSmopItemInfo  *itemInfo,
                               		  TVSmopOpInfo    *opInfo));

extern IGRstat VSmopCmd_SetFormState __((IGRint state));

extern IGRstat VSmopCmd_FreeVlaLists __(());
extern IGRstat VSmopCmd_FormNotifyInsertNewPlate __(());
extern IGRstat VSmopCmd_RearrangeFormAndVla __(());
extern IGRstat VSmopCmd_ReconnectToParent __((TGRid      *parentID,
                                    	      TGRobj_env *newPlate));
extern IGRstat VSmopCmd_InsertNewPlateIntoVlaAndForm __((TGRobj_env *newPlate));
extern IGRstat VSmopCmd_ChangeParent __((TGRobj_env *newPlate));
extern IGRstat VSmopCmd_ResetForm __(());
extern IGRstat VSmopCmd_FormNotifyNthRowPieceList __((IGRint *nthRow));
extern IGRstat VSmopCmd_FormNotifyNthRowItemList __((IGRint *nthRow));
extern IGRstat VSmopCmd_DeletePlateWithOp __((TGRobj_env *cutOE));
extern IGRstat VSmopCmd_CreateDummyOp __((TGRobj_env *ItemOE,
                                	  TGRobj_env *DummyOpOE));
extern IGRstat VSmopCmd_ClearNthPieceInfoOnForm __((IGRint *NthPiece));
extern IGRstat VSmopCmd_ClearNthItemInfoOnForm __((IGRint *NthPiece));
extern IGRstat VSmopCmd_RealDeletePlate __((TGRid *itemID, TGRobj_env *cutOE));
extern IGRstat VSmopCmd_CheckOrModifyMacroParent __((TVSmopOpInfo    *opInfo,
						     int	     *row));

// -------------------------
#if defined(__cplusplus)
}
#endif












