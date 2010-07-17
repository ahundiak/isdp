/* $Id: VSmop.h,v 1.2 2001/01/16 23:53:19 ramarao Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        include/VSmop.h
 *
 * Description: Modify Operator Functions
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmop.h,v $
 *      Revision 1.2  2001/01/16 23:53:19  ramarao
 *      *** empty log message ***
 *
 * Revision 1.2  2000/06/01  15:44:28  pinnacle
 * Replaced: struct/include/VSmop.h for:  by mdong for Service Pack
 *
 * Revision 1.1  2000/05/15  20:02:28  pinnacle
 * initial revision
 *
 * Revision 1.4  1999/07/27  20:28:22  pinnacle
 * (No comment)
 *
 * Revision 1.3  1999/06/16  15:44:06  pinnacle
 * (No comment)
 *
 * Revision 1.2  1999/05/06  21:49:34  pinnacle
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

#ifndef VSmop_include
#define VSmop_include
#endif

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#ifndef   VDvla2_include
#include "VDvla2.h"
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

/* ----------------------------------------------------
 * Op Info Stuff
 */
typedef struct
{
  TGRobj_env cutOE;
  TGRid      parentID;
  TGRid      macroID;
  IGRint     miscFlag;
  IGRint     statusFlag;
  IGRint     hilitedFlag;
} TVSmopOpInfo;

#define VSMOP_VLA_OP_INFO_MAX 5
#define VSMOP_VLA_OP_INFO_ADD 5

typedef struct {
  TVDvla vla;
  TVSmopOpInfo data[VSMOP_VLA_OP_INFO_MAX];
} TVSmopOpInfoVLA;

extern IGRstat VSmopOpInfoVLA_Init   __((TVSmopOpInfoVLA *vla));
extern IGRstat VSmopOpInfoVLA_Free   __((TVSmopOpInfoVLA *vla));
extern IGRstat VSmopOpInfoVLA_Empty  __((TVSmopOpInfoVLA *vla));

extern IGRstat VSmopOpInfoVLA_Append __((TVSmopOpInfoVLA *vla, 
                                         TVSmopOpInfo    *data));

extern IGRstat VSmopOpInfoVLA_GetAppend __((TVSmopOpInfoVLA *vla, 
					    TVSmopOpInfo   **data));

extern IGRstat VSmopOpInfoVLA_GetCnt __((TVSmopOpInfoVLA *vla, 
                                           IGRint        *cnt));

extern IGRstat VSmopOpInfoVLA_GetNth __((TVSmopOpInfoVLA *vla, 
                                         IGRint           nth, 
                                         TVSmopOpInfo    *data, 
                                         TVSmopOpInfo   **dataP));

extern IGRstat VSmopOpInfoVLA_RearrangeVla __((TVSmopOpInfoVLA *vla, 
					       IGRint	       *numOp,
					       IGRint          *totalNumOp));

extern IGRstat VSmopOpInfoVLA_OverwriteNth __((TVSmopOpInfoVLA *vla, 
					       IGRint	       *nth,
					       TVSmopOpInfo    *data,
					       TVSmopOpInfo   **dataP));

extern IGRstat VSmopConstructNewPlate __(( TGRmd_env  *cstEnv,
                                	   TGRobj_env *parentOE,
					   IGRchar    *className,
                                	   TGRobj_env *constructedObject ));


/* ----------------------------------------------------
 * Holds item information
 */
typedef struct {
  TGRobj_env       itemOE;
  TGRobj_env       subOE;
  TGRobj_env       graphicOE;
  VDclassid        classID;
  IGRint           miscFlag;
  IGRint           statusFlag;
  IGRint           hilitedFlag;
  TVSmopOpInfoVLA  opInfoVLA;
} TVSmopItemInfo;

#define VSMOP_VLA_ITEM_INFO_MAX 5
#define VSMOP_VLA_ITEM_INFO_ADD 5

typedef struct {
  TVDvla vla;
  TVSmopItemInfo data[VSMOP_VLA_ITEM_INFO_MAX];
} TVSmopItemInfoVLA;

extern IGRstat VSmopItemInfoVLA_Init   __((TVSmopItemInfoVLA *vla));
extern IGRstat VSmopItemInfoVLA_Free   __((TVSmopItemInfoVLA *vla));
extern IGRstat VSmopItemInfoVLA_Empty  __((TVSmopItemInfoVLA *vla));

extern IGRstat VSmopItemInfoVLA_Append __((TVSmopItemInfoVLA *vla, 
                                           TVSmopItemInfo    *data));

extern IGRstat VSmopItemInfoVLA_GetAppend __((TVSmopItemInfoVLA *vla, 
					      TVSmopItemInfo   **data));

extern IGRstat VSmopItemInfoVLA_GetCnt __((TVSmopItemInfoVLA *vla, 
                                           IGRint            *cnt));

extern IGRstat VSmopItemInfoVLA_GetNth __((TVSmopItemInfoVLA *vla, 
                                           IGRint              nth, 
                                           TVSmopItemInfo    *data, 
                                           TVSmopItemInfo   **dataP));


/* ----------------------------------------------------
 * Holds piece information
 */

typedef struct {
  TGRobj_env        pieceOE;
  TVSmopItemInfoVLA itemInfoVLA;
} TVSmopPieceInfo;

#define VSMOP_VLA_PIECE_INFO_MAX  1
#define VSMOP_VLA_PIECE_INFO_ADD 10

typedef struct {
  TVDvla vla;
  TVSmopPieceInfo data[VSMOP_VLA_PIECE_INFO_MAX];
} TVSmopPieceInfoVLA;

extern IGRstat VSmopPieceInfoVLA_Init   __((TVSmopPieceInfoVLA *vla));
extern IGRstat VSmopPieceInfoVLA_Free   __((TVSmopPieceInfoVLA *vla));
extern IGRstat VSmopPieceInfoVLA_Empty  __((TVSmopPieceInfoVLA *vla));

extern IGRstat VSmopPieceInfoVLA_Append __((TVSmopPieceInfoVLA *vla, 
                                            TVSmopPieceInfo    *data));

extern IGRstat VSmopPieceInfoVLA_GetAppend __((TVSmopPieceInfoVLA *vla, 
                                               TVSmopPieceInfo   **data));

extern IGRstat VSmopPieceInfoVLA_GetCnt __((TVSmopPieceInfoVLA *vla, 
                                            IGRint             *cnt));

extern IGRstat VSmopPieceInfoVLA_GetNth __((TVSmopPieceInfoVLA *vla, 
                                            IGRint              nth, 
                                            TVSmopPieceInfo    *data, 
                                            TVSmopPieceInfo   **dataP));

extern IGRstat VSmopPieceInfoVLA_ResetDataP __((TVSmopPieceInfo *dataP));

extern IGRstat VSmopItemInfoVLA_ResetDataP __((TVSmopItemInfo *dataP));

extern IGRstat VSmopItemInfoVLA_RearrangeVla __((TVSmopItemInfoVLA *vla, 
						 IGRint	           *numOp,
						 IGRint            *totalNumOp));

extern IGRstat VSmopPieceInfoVLA_RearrangeVla __((TVSmopPieceInfoVLA *vla, 
						  IGRint	     *numOp,
						  IGRint             *totalNumOp));

extern IGRstat VSmopItemInfoVLA_OverwriteNth __((TVSmopItemInfoVLA  *vla, 
						 IGRint	      	    *nth,
						 TVSmopItemInfo     *data,
						 TVSmopItemInfo    **dataP,
						 TVSmopItemInfo    **dataPNew));

extern IGRstat VSmopPieceInfoVLA_OverwriteNth __((TVSmopPieceInfoVLA  *vla, 
						  IGRint	      *nth,
						  TVSmopPieceInfo     *data,
						  TVSmopPieceInfo    **dataP,
						  TVSmopPieceInfo    **dataPNew));

extern IGRstat VSmopPieceInfoVLA_FreeNth      __((TVSmopPieceInfoVLA *pieceVLA, 
						  IGRint nth ));

extern IGRstat VSmopItemInfoVLA_FreeNth       __((TVSmopItemInfoVLA *itemVLA, 
						  IGRint nth ));

/* --------------------------------------------------------------
 * Implemented in VSmopPlate.I
 */
extern IGRstat VSmopGetOps            __((TGRobj_env      *opOE, 
					  TVSmopOpInfoVLA *opInfoVLA));

extern IGRstat VSmopFillOpInfo        __((TVSmopItemInfo *itemInfo, 
					  IGRint nth));

extern IGRstat VSmopFillOpInfoVLA     __((TVSmopItemInfo *itemInfo));

extern IGRstat VSmopFindOpInfoByID    __((TVSmopOpInfoVLA *infoVLA,
					  TGRid           *infoID,
					  IGRchar	  *opMacName,
					  TVSmopOpInfo    **info,
					  IGRint          *NthRow));

extern IGRstat VSmopMatchOpInfoBymacroID __((TVSmopOpInfoVLA *infoVLA,
					     TGRid           *macroID));

extern IGRstat VSmopFindItemInfoByID  __((TVSmopItemInfoVLA *infoVLA,
					  TGRid             *infoID,
					  TVSmopItemInfo   **info));

extern IGRstat VSmopFindPieceInfoByID __((TVSmopPieceInfoVLA *infoVLA,
					  TGRid              *infoID,
					  TVSmopPieceInfo   **info));

extern IGRstat VSmopFillPlateItemInfo __((TVSmopItemInfoVLA *itemInfoVLA,
					  TGRobj_env        *pieceOE));

extern IGRstat VSmopFillPlateItemVLA  __((TVSmopPieceInfo *plateInfo));


// -------------------------
#if defined(__cplusplus)
}
#endif











