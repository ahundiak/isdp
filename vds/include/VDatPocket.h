/* $Id: VDatPocket.h,v 1.7 2001/10/29 20:09:42 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDatPocket.h
 *
 * Description:	Assembly Tree Pocket Command
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatPocket.h,v $
 *      Revision 1.7  2001/10/29 20:09:42  ylong
 *      CR5709
 *
 *      Revision 1.6  2001/05/25 17:02:06  ylong
 *      *** empty log message ***
 *
 *      Revision 1.5  2001/02/23 14:27:20  ylong
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/02/09 18:26:13  ylong
 *      Add prototypes for VDct1TreeF.I
 *
 *      Revision 1.1  2001/01/09 22:03:39  art
 *      ah
 *
 * Revision 1.2  2000/05/24  15:56:12  pinnacle
 * ah
 *
 * Revision 1.1  2000/04/10  19:05:02  pinnacle
 * ah
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/04/00  ah      Creation
 * 05/24/00  ah      Send viewOE when getting marking lines
 * 01/09/01  ah      sp merge
 ***************************************************************************/
#ifndef VDatPocket_include
#define VDatPocket_include

#ifndef   VDtypedef_include
#include "VDtypedef.h"
#endif

#ifndef   VDfrm_include
#include "VDfrm.h"
#endif

#ifndef   DPvd_include
#include "DPvd.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

struct VDatPKT_elem_buf {
        TGRid   *objIDs;
        IGRint  count;
        IGRint  bufSize;
};

/* ---------------------------------------------
 * Gadget controls
 */
#define VDAT_FORM_PKT_L_SETS   12

#define VDAT_FORM_PKT_G_SEARCH 18
#define VDAT_FORM_PKT_B_PICK   20

#define VDAT_FORM_PKT_G_TREE      26
#define VDAT_FORM_PKT_G_PICK_LIST 21

#define VDAT_FORM_PKT_G_SELECT_FROM	25
#define VDAT_FORM_PKT_G_SELECT_TO	27
#define VDAT_FORM_PKT_B_SELECT_FROM	19
#define VDAT_FORM_PKT_B_SELECT_TO	28
#define VDAT_FORM_PKT_B_MULTI_SELECT	29

#define VDAT_FORM_PKT_G_NOTICE    10
#define VDAT_FORM_PKT_G_MESSAGE    9

#define VDAT_FORM_PKT_T_TREE_OR_PICK_LIST 13
#define VDAT_FORM_PKT_T_MODEL_OR_NODE     22

#define	VDAT_FORM_PKT_G_SET_NAME	24
#define VDAT_FORM_PKT_B_SET_LOAD	30
#define VDAT_FORM_PKT_B_SET_SAVE	31
#define VDAT_FORM_PKT_B_SET_DELET	32
#define VDAT_FORM_PKT_G_HILIT_OPT	34
#define VDAT_FORM_PKT_B_SET_ADD		36
#define	VDAT_FORM_PKT_B_CLEAR_SEL	35


/* -----------------------------------------------
 * These were copied from loft/include/unfold.h
 * They allow the user to select which lines 
 * they want from the selected pieces
 */
#define UNFOLD_ATT_IDX_MARK	   0
#define UNFOLD_ATT_IDX_ROL	   1
#define UNFOLD_ATT_IDX_CTRL	   2
#define UNFOLD_ATT_IDX_TRACE	   3
#define UNFOLD_ATT_IDX_WATER	   4
#define UNFOLD_ATT_IDX_BUTT	   5
#define UNFOLD_ATT_IDX_SEAM	   6
#define UNFOLD_ATT_IDX_DISMIN      7
#define UNFOLD_ATT_IDX_FAR         8

#define UNFOLD_NB_OPT              9
#define UNFOLD_NB_OPTLINE          9

#define VDAT_PKT_OFFSET            2

/* ---------------------------------------------
 * Internal Protos
 */

// VDCSlAsCpi.I (also has the methods)
extern IGRstat VDatPKTNotifySets __((Form form));
extern IGRstat VDatPKTNotifyTree __((Form form));
extern IGRstat VDatPKTNotifyToggleTreeList __((Form form));
extern IGRstat VDatPKTNotifyMultiSelect __((Form form, IGRint gadget));
  
// VDatLines.I
extern IGRstat VDatPKTAddLinesToSaveSet __((TGRobj_env *viewOE,
					    TGRobj_env *modelOE, 
					    IGRint *pickList, 
					    TGRid  *grsetID));
  
// VDatSave.I
extern IGRstat VDatPKTAddToSaveSet __((TGRid *objID, TGRid *grsetID, TGRobj_env *objOE));

extern IGRstat VDatPKTFillSaveSet  __((Form        form, 
				       TGRid      *setID, 
				       TGRid      *grsetID, 
				       TGRobj_env *objOE));

extern IGRstat VDatPKTNotifyAccept __((Form form, TGRobj_env *objOE));

extern IGRstat VDatPKTCreateGRgrset   __((TGRobj_env *grsetOE));

extern IGRstat VDatPKTQueDataToCmdObj __((struct DPvd_actwin awin, 
					  TGRobj_env *grsetOE));

extern IGRstat VDatPKTSaveTreeNode    __((Form form));
  
// VDatSearch.I
extern IGRstat VDatPKTNotifySearch  __((Form form));
extern IGRstat VDatPKTNotifyPick    __((Form form));
extern IGRstat VDatPKTDisplayLocate __((Form form, TGRid *setID, TGRobj_env *objOE));
extern IGRstat VDatPKTLocateObject  __((Form form, TGRid *setID));
 
// VDatState.I 
extern IGRstat VDatPKTSaveState __((Form form));
extern IGRstat VDatPKTLoadState __((Form form));

extern IGRstat VDatPKTSetStateSavedNodeToggle __((IGRint  nodeToggle));
extern IGRstat VDatPKTGetStateSavedNodeToggle __((IGRint *nodeToggle));
  
extern IGRstat VDatPKTGetStateSavedSet  __((TGRid *setID));
extern IGRstat VDatPKTSetStateSavedSet  __((TGRid *setID));
extern IGRstat VDatPKTGetStateSavedNode __((TGRid *nodeID));
extern IGRstat VDatPKTSetStateSavedNode __((TGRid *nodeID));

extern IGRstat VDatPKTGetStatePickList     __((IGRint *pickList));
extern IGRstat VDatPKTFillInternalPickList __((Form form));
  

// for vdat/pocket/VDatTreeF.I 

extern IGRstat VDatPKTFormClearTree __((Form form, IGRint gadget));

extern IGRstat VDatPKTFormUpdateTreeRow __((	Form	form, 
						IGRint	gadget, 
						TGRid *rowID ));

extern IGRstat VDatPKTFormFindTreeRow __((Form	form, 
					IGRint	gadget, 
					TGRid	*workID, 
					IGRint *rowFound ));

extern IGRstat VDatPKTFormRefreshNodeName __((	Form form,
						IGRint  gadget,
						IGRint  row,
						TGRid  *nodeID ));

extern IGRstat VDatPKTFormFillTreeRow __((Form	form,
					IGRint  gadget,
					IGRint *row,
					IGRint  level,
					TGRid  *nodeID,
					IGRint  atrFlag,
					IGRint  expFlag ));

extern IGRstat VDatPKTFormFillTree __((	Form	form, 
					IGRint	gadget, 
					TGRid	*setID));

extern IGRstat VDatPKTFormExpandTreeAttrRow __((Form	form, 
						IGRint	gadget, 
						IGRint	row));

extern IGRstat VDatPKTFormSortRows __(( Form	form, 
					IGRint	gadget, 
					IGRint	level,
					IGRint  end_row,
					IGRint  nrow));

extern IGRstat VDatPKTFormExpandTreeRow __((	Form	form,
						IGRint	gadget, 
						IGRint row));

extern IGRstat VDatPKTFormContractTreeRow __((	Form	form, 
						IGRint	gadget, 
						IGRint	row));

extern IGRstat VDatPKTFormDeleteTreeRow	__((	Form	form, 
						IGRint	gadget, 
						IGRint	row));

extern IGRstat VDatPKTFormDeleteTreeRowID __((	Form	form, 
						IGRint	gadget, 
						TGRid	*rowID));

extern IGRstat VDatPKTFormNotifyTreeExp __((	Form	form,
						IGRint	gadget,
						IGRint	row,
						TGRid	*rootID ));

// VDct1TreeF.I

extern IGRstat VDct1PKTFormUpdateTreeRo 
		__(( Form form, IGRint gadget, TGRid *rowID));

extern IGRstat VDct1PKTFormFindTreeRow  
		__((Form form, IGRint gadget, TGRid *workID, IGRint *rowFound));

extern IGRstat VDct1PKTFormRefreshNodeName 
		__((Form form, IGRint gadget, IGRint row, TGRid *nodeID));

extern IGRstat VDct1PKTFormFillTree
		__((Form form, IGRint gadget, TGRid *setID));

extern IGRstat VDct1PKTScanTree 
		__((TGRid *setID));

extern IGRstat VDct1PKTFormAppendTree 
		__((Form form, IGRint gadget, TGRid *setID));

extern IGRstat VDct1PKTFormDisplayRecurse  
		__((Form form, IGRint gadget, TGRid *nodeID, IGRint *row));

extern IGRstat VDct1PKTFormExpandTree  
		__(( Form form, IGRint gadget, TGRid  *setID, TGRid  *nodeID));

extern IGRstat VDct1PKTFormDeleteTreeRowID 
		__((Form form, IGRint gadget, TGRid *rowID));

extern IGRstat VDct1PKTFormNotifyTree 
		__((Form form, IGRint gadget, TGRid *a_nodeID));

extern IGRstat VDct1PKTFormFillSetRow 
		__((Form form, IGRint gadget, TGRid *setID));

extern IGRstat VDct1PKTFormFillSets 
		__((Form form, IGRint gadget, IGRint clearGadget));

extern IGRstat VDct1PKTFormUpdateVRTree 
		__((Form form, IGRint gadget));

extern IGRstat VDct1PKTFormContractTreeRow
		__((Form form, IGRint gadget, IGRint row));

extern VDclassid OPP_VDatBase_class_id;
extern VDclassid OPP_VDct1Base_class_id;


/* ----------------------------------------------------
 * Clean up
 */
#if defined(__cplusplus)
}
#endif

#endif
