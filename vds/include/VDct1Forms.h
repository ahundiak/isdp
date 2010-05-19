/* $Id: VDct1Forms.h,v 1.2 2002/01/10 19:09:36 jdsauby Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDct1Forms.h
 *
 * Description: Froms and gadgets used for Tree Manager
 *
 *
 * Revision History:
 *      $Log: VDct1Forms.h,v $
 *      Revision 1.2  2002/01/10 19:09:36  jdsauby
 *      JTSMP CR 5679, added event gadgets to LIB and TREE forms.
 *
 *      Revision 1.1  2001/01/09 22:17:56  art
 *      ah
 *
 * Revision 1.10  2000/12/08  20:50:42  pinnacle
 * ah
 *
 * Revision 1.9  2000/12/08  15:32:34  pinnacle
 * ah
 *
 * Revision 1.8  2000/12/07  13:34:10  pinnacle
 * ah
 *
 * Revision 1.7  2000/11/16  20:18:22  pinnacle
 * pn
 *
 * Revision 1.6  2000/09/07  18:04:54  pinnacle
 * js
 *
 * Revision 1.5  2000/08/21  21:47:36  pinnacle
 * js
 *
 * Revision 1.4  2000/07/20  20:18:26  pinnacle
 * js
 *
 * Revision 1.3  2000/07/20  13:20:52  pinnacle
 * ah
 *
 * Revision 1.1  2000/07/18  19:31:34  pinnacle
 * ah
 *
 * Revision 1.1  2000/07/17  18:55:50  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/12/00  ah      Created
 * 12/06/00  ah      c friendly
 ***************************************************************************/
#ifndef VDct1Forms_include
#define VDct1Forms_include

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

// The Tree
#define VDCT_FORM_TREE_F_NAME         "VDct1Tree.F"
#define VDCT_FORM_TREE_G_SET_NAME      51
#define VDCT_FORM_TREE_G_TREE          26
#define VDCT_FORM_TREE_G_EVENT         16
#define VDCT_FORM_TREE_B_UNSELECT_ALL  12
#define VDCT_FORM_TREE_B_UNHILITE_ALL  13
#define VDCT_FORM_TREE_B_HILITE_SELECT 14
#define VDCT_FORM_TREE_G_DISPLAY       15
#define VDCT_FORM_TREE_T_WORK          22

// Attributes Form
#define VDCT_FORM_ATTR_F_NAME            "VDct1Attr.F"
#define VDCT_FORM_ATTR_L_ATTRS           12
#define VDCT_FORM_ATTR_L_ATTRS_PVT       160
#define VDCT_FORM_ATTR_L_ATTRS_COL_BASE   0
#define VDCT_FORM_ATTR_L_ATTRS_COL_TYPE   1
#define VDCT_FORM_ATTR_L_ATTRS_COL_VALUE  2
#define VDCT_FORM_ATTR_L_ATTRS_COL_NAME   3
#define VDCT_FORM_ATTR_G_DOIT            22
#define VDCT_FORM_ATTR_T_LOCKED_NODE     13
#define VDCT_FORM_ATTR_G_LOCKED_NODE     51
#define VDCT_FORM_ATTR_G_ACTIVE_NODE     14
#define VDAT_FORM_ATTR_L_VALUES          13
#define VDAT_FORM_ATTR_G_VALUES          19
#define VDCT_FORM_ATTR_T_UPDATE          16


  // Freeze (Status) Form
#define VDCT_FORM_FREE_F_NAME        "VDct1Free.F"
#define VDCT_FORM_FREE_G_DOIT        19
#define VDCT_FORM_FREE_G_DELETE_NODE 25
#define VDCT_FORM_FREE_G_FROZEN_NODE 14
#define VDCT_FORM_FREE_G_ACTIVE_NODE 13
#define VDCT_FORM_FREE_G_ACT_REV     18
#define VDCT_FORM_FREE_G_FRZ_REV     16
#define VDCT_FORM_FREE_C_MR          24
#define VDCT_FORM_FREE_G_MR_REV      21

// Tree Library Form
#define VDCT_FORM_LIB_F_NAME          "VDct1Lib.F"
#define VDCT_FORM_LIB_G_DISPLAY       15
#define VDCT_FORM_LIB_B_CLEAR         16
#define VDCT_FORM_LIB_B_COPY          18
#define VDCT_FORM_LIB_B_WRITE         19
#define VDCT_FORM_LIB_G_DOIT          21
#define VDCT_FORM_LIB_G_TREE          26
#define VDCT_FORM_LIB_G_EVENT         11
#define VDCT_FORM_LIB_G_SET_NAME      51

  // Tree manager form
#define VDCT_FORM_MGR_F_NAME     "VDct1Mgr.F"
#define VDCT_FORM_MGR_B_SETS     12
#define VDCT_FORM_MGR_B_LIBS     13
#define VDCT_FORM_MGR_B_TREES    15
#define VDCT_FORM_MGR_B_ATTRS    16
#define VDCT_FORM_MGR_B_REPS     17
#define VDCT_FORM_MGR_B_NODES    18
#define VDCT_FORM_MGR_B_POST     28
#define VDCT_FORM_MGR_B_PCMK     25
#define VDCT_FORM_MGR_B_FREE     27
#define VDCT_FORM_MGR_B_PART     29
#define VDCT_FORM_MGR_B_DBTBL    26
#define VDCT_FORM_MGR_B_HILITE   19
#define VDCT_FORM_MGR_B_UNHILITE 37

  // Node Form
#define VDCT_FORM_NODE_F_NAME            "VDct1Node.F"
#define VDCT_FORM_NODE_G_DOIT            19
#define VDCT_FORM_NODE_B_PARENT_NODE     14
#define VDCT_FORM_NODE_G_PARENT_NODE     12
#define VDCT_FORM_NODE_G_ACTIVE_NODE     13
#define VDCT_FORM_NODE_T_ACTIVE_NODE     15
#define VDCT_FORM_NODE_G_EDIT_NODE_TYPE  17
#define VDCT_FORM_NODE_G_EDIT_NODE_NAME  18

#define VDCT_FORM_PART_T_SEL1            16
#define VDCT_FORM_PART_T_SEL2            17
#define VDCT_FORM_PART_T_SEL3            18
#define VDCT_FORM_PART_T_PART            19
#define VDCT_FORM_PART_T_PARENT          20
#define VDCT_FORM_PART_G_DB              21
#define VDCT_FORM_PART_G_QTY             25
#define VDCT_FORM_PART_L_SEL1            13
#define VDCT_FORM_PART_L_SEL2            14
#define VDCT_FORM_PART_L_SEL3            15
#define VDCT_FORM_PART_L_COL_BASE         0
#define VDCT_FORM_PART_L_COL_TYPE         1
#define VDCT_FORM_PART_L_COL_VALUE        2
#define VDCT_FORM_PART_L_COL_NAME         3

  // OPS Attributes Form
#define VDCT_FORM_OPS_F_NAME            "VDct1Ops.F"
#define VDCT_FORM_OPS_G_PART_CAGE_NUM   12
#define VDCT_FORM_OPS_L_ATTRS           14
#define VDCT_FORM_OPS_L_ATTRS_NAME       0
#define VDCT_FORM_OPS_L_ATTRS_VALUE      1

  // New Tree (Set) Form
#define VDCT_FORM_SET_F_NAME        "VDct1Set.F"
#define VDCT_FORM_SET_G_TREE_NAME   51
#define VDCT_FORM_SET_G_TREE_TYPE   12
#define VDCT_FORM_SET_G_TREE_DESC   16
#define VDCT_FORM_SET_G_DOIT        13
#define VDCT_FORM_SET_G_TREE_ACTIVE 14

  // Database Table form
#define VDCT_FORM_DBTBL_F_NAME      "VDct1DbTbl.F"
#define VDCT_FORM_DBTBL_G_TABLES    13
#define VDCT_FORM_DBTBL_G_COLS      12
#define VDCT_FORM_DBTBL_G_DATA      14
#define VDCT_FORM_DBTBL_G_SCROLL_H  17
#define VDCT_FORM_DBTBL_G_GROUP     20

  // Status form
#define VDCT_FORM_FREE_F_NAME       "VDct1Free.F"
#define VDCT_FORM_FREE_G_NODE_ACTIVE 13
#define VDCT_FORM_FREE_G_REV_ACTIVE  18
#define VDCT_FORM_FREE_G_NODE_FROZEN 14
#define VDCT_FORM_FREE_G_REV_FROZEN  16
#define VDCT_FORM_FREE_G_MR_FROZEN   21
#define VDCT_FORM_FREE_G_NODE_DEL    25
#define VDCT_FORM_FREE_G_DOIT        19

/* ------------------------------------------------------
 * Expose the tree gadget form functions
 * Note: Use char* for form just to avoid bringing in
 * form stuff,
 */
extern IGRstat VDct1FormFillTree        __((IGRchar *form, IGRint gadget, TGRid *setID));
extern IGRstat VDct1FormNotifyTree      __((IGRchar *form, IGRint gadget, TGRid *nodeID));
extern IGRstat VDct1FormNotifyTreeName  __((IGRchar *form, IGRint gadget, IGRint row, TGRid *treeID));
extern IGRstat VDct1FormUpdateTreeRow   __((IGRchar *form, IGRint gadget, TGRid *rowID));
extern IGRstat VDct1FormDeleteTreeRowID __((IGRchar *form, IGRint gadget, TGRid *rowID));
extern IGRstat VDct1FormFindTreeRow     __((IGRchar *form, IGRint gadget, TGRid *workID, IGRint *rowFound));
extern IGRstat VDct1FormRefreshNodeName __((IGRchar *form, IGRint gadget, IGRint row, TGRid  *nodeID));
extern IGRstat VDct1FormUpdateVRTree    __((IGRchar *form, IGRint gadget));
extern IGRstat VDct1FormAppendTree      __((IGRchar *form, IGRint gadget, TGRid *setID));
  
  
/* ------------------------- */
#if defined(__cplusplus)
}
#endif

#endif

