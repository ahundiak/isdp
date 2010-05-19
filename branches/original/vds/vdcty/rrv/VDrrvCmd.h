/* $Id: VDrrvCmd.h,v 1.19 2002/06/07 20:14:48 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDrrvCmd.h
 *
 * Description: Review Revisions Command
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDrrvCmd.h,v $
 *      Revision 1.19  2002/06/07 20:14:48  ahundiak
 *      ah
 *
 *      Revision 1.18  2002/06/04 14:04:25  ahundiak
 *      ah
 *
 *      Revision 1.17  2002/05/17 15:22:33  ahundiak
 *      ah
 *
 *      Revision 1.16  2002/05/10 19:34:03  ahundiak
 *      ah
 *
 *      Revision 1.15  2002/05/06 20:52:51  ahundiak
 *      ah
 *
 *      Revision 1.14  2002/05/01 19:59:24  ahundiak
 *      ah
 *
 *      Revision 1.13  2002/02/28 21:41:33  ahundiak
 *      ah
 *
 *      Revision 1.12  2002/01/08 20:30:29  ahundiak
 *      ah
 *
 *      Revision 1.11  2001/11/01 22:20:01  ylong
 *      Add Navigate and Event functionalities
 *
 *      Revision 1.10  2001/03/29 19:36:46  jdsauby
 *      Incorporation of Purpose Info
 *
 *      Revision 1.9  2001/03/19 22:06:18  jdsauby
 *      Added pdm_info and purp_info attributes to tree, moved post to create form
 *
 *      Revision 1.8  2001/03/16 19:05:34  jdsauby
 *      Modified to suit for Posting, File and Database Operations
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/15/01  ah      Creation
 ***************************************************************************/

#ifndef VDrrvCmd_include
#define VDrrvCmd_include

#ifndef   VDtag_include
#include "VDtag.h"
#endif

#ifndef   VDfrmc_include
#include "VDfrmc.h"
#endif

#ifndef   VDpdm_include
#include "VDpdm.h"
#endif

#ifndef   VDtest_include
#include "VDtest.h"
#endif

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/* -----------------------------------------------
 * Turn all command tracing on or off
 */
#define VDRRV_TRACE 1

// Need to put these in VDfrmc.h
#define VDfrmShowg(form,gadget) VIg_display(form,gadget)
#define VDfrmHideg(form,gadget) VIg_erase  (form,gadget)

/* -----------------------------------------------
 * Create Snap Shot
 */
#define VDRRV_FORM_CREATE_NAME    "VDrrvCreate.F"
#define VDRRV_FORM_CREATE_NAMEX   "VDrrvCreatex.F"
#define VDRRV_FORM_CREATE_NUM      125

#define VDRRV_FORM_CREATE_G_UNIT    14
#define VDRRV_FORM_CREATE_G_ZONE    29
#define VDRRV_FORM_CREATE_G_SYSTEM  30
#define VDRRV_FORM_CREATE_G_PURPOSE 22
#define VDRRV_FORM_CREATE_G_FILE    15
#define VDRRV_FORM_CREATE_G_STAT    18

#define VDRRV_FORM_CREATE_B_CREATE  16
#define VDRRV_FORM_CREATE_B_RVW_LOG 17
#define VDRRV_FORM_CREATE_B_RVW_XML 20
//efine VDRRV_FORM_CREATE_B_POST    24
//efine VDRRV_FORM_CREATE_B_RVW_DOM 19
#define VDRRV_FORM_CREATE_B_OBJ_NAV 35
#define VDRRV_FORM_CREATE_B_OBJ_EVENT 36

#define VDRRV_FORM_CREATE_T_TRACE   21

#define VDRRV_FORM_CREATE_L_SCAN    27

extern void    VDtestCreateSnapshot       __((TVDtestTestInfo *testInfo));
extern IGRstat VDrrvCmdInitCreateSnapshot __((TVDtestTestInfo *testInfo, VDobjid pplObjid, VDosnum pplOsnum));

extern void    VDrrvCmdKillCreateSnapshot __(());
extern void    VDrrvCmdLoopCreateSnapshot __(());

extern IGRint  VDrrvCmdNotifyCreate    __((IGRint    f_label,
					   IGRint    gadget,
					   IGRdouble value,
					   Form      form));

extern IGRint VDrrvCmdGetCreateTraceFlag __(());

/* --------------------------------------------
 * Get the scan type flag
 * Returns:
 * VDRRV_CREATE_SCAN_FULL     for full scan
 * VDRRV_CREATE_SCAN_QUICK    for a quick scan
 * VDRRV_CREATE_SCAN_EXTENDED for an extended scan
 * **/
extern IGRint VDrrvCmdGetCreateQuickFlag __(());

extern IGRstat VDrrvCmdInitSnapshotFileOps __(());

extern IGRstat VDrrvCmdInitSnapshotDbOps __(());

extern IGRstat VDrrvPostXmlSnapshotFile __((IGRchar *xmlFile,
                                            IGRchar *msg));
/* -----------------------------------------------
 * Review Snap Shots
 */
#define VDRRV_FORM_REVIEW_NAME    "VDrrvDooms.F"
#define VDRRV_FORM_REVIEW_NUM      135

#define VDRRV_FORM_REVIEW_L_DOOMS      12
#define VDRRV_FORM_REVIEW_L_DOOMS_TYPE  0
#define VDRRV_FORM_REVIEW_L_DOOMS_NAME  1
#define VDRRV_FORM_REVIEW_L_DOOMS_TS    2
#define VDRRV_FORM_REVIEW_L_DOOMS_ID    3

#define VDRRV_FORM_REVIEW_G_FILES      13
#define VDRRV_FORM_REVIEW_B_LOAD_FILE  14
#define VDRRV_FORM_REVIEW_B_FILE_OPS   19
#define VDRRV_FORM_REVIEW_B_DB_OPS     20

#define VDRRV_FORM_REVIEW_B_COMPARE    16
#define VDRRV_FORM_REVIEW_B_DELETE     17
#define VDRRV_FORM_REVIEW_B_VIEW_XML   21
#define VDRRV_FORM_REVIEW_B_POST_XML   22

#define VDRRV_FORM_REVIEW_G_STAT       15
#define VDRRV_FORM_REVIEW_G_SHOW       23

#define VDRRV_FORM_REVIEW_L_DIFFS         18
#define VDRRV_FORM_REVIEW_L_DIFFS_NUM      0      
#define VDRRV_FORM_REVIEW_L_DIFFS_TYPE     1   
#define VDRRV_FORM_REVIEW_L_DIFFS_DESC     2   
#define VDRRV_FORM_REVIEW_L_DIFFS_DIFF_ID  3 
#define VDRRV_FORM_REVIEW_L_DIFFS_NODE_ID  4 

extern void    VDtestReviewSnapshot       __((TVDtestTestInfo *testInfo));
extern IGRstat VDrrvCmdInitReviewSnapshot __((TVDtestTestInfo *testInfo));

extern void    VDrrvCmdKillReviewSnapshot __(());
extern void    VDrrvCmdLoopReviewSnapshot __(());

extern IGRint  VDrrvCmdReviewNotify    __((IGRint    f_label,
					   IGRint    gadget,
					   IGRdouble value,
					   Form      form));

extern void VDrrvCmdFillDoomList __((Form form, IGRint gadget));

/* -----------------------------------------------
 * File Operations form
 * **/
#define VDRRV_FORM_FILE_OPS_NAME    "VDrrvFile.F"
#define VDRRV_FORM_FILE_OPS_NUM     145

#define VDRRV_FORM_FILE_OPS_L_DOOMS      12
#define VDRRV_FORM_FILE_OPS_L_DOOMS_TYPE  0
#define VDRRV_FORM_FILE_OPS_L_DOOMS_NAME  1
#define VDRRV_FORM_FILE_OPS_L_DOOMS_TS    2

#define VDRRV_FORM_FILE_OPS_G_PATH       14
#define VDRRV_FORM_FILE_OPS_STATUS       15

#define VDRRV_FORM_FILE_OPS_B_LOAD       16
#define VDRRV_FORM_FILE_OPS_B_VIEW       17

extern void VDrrvCmdKillSnapshotFileOps __(());

extern void VDrrvCmdLoopSnapshotFileOps __(());

extern void VDrrvLoadFromFile __((IGRchar *name));

/* -----------------------------------------------
 * Database Operations form
 * **/
#define VDRRV_FORM_DB_OPS_NAME    "VDrrvDbOps.F"
#define VDRRV_FORM_DB_OPS_NUM     155

#define VDRRV_FORM_DB_OPS_L_DOOMS      12
#define VDRRV_FORM_DB_OPS_L_DOOMS_HULL  0
#define VDRRV_FORM_DB_OPS_L_DOOMS_TYPE  1
#define VDRRV_FORM_DB_OPS_L_DOOMS_NAME  2
#define VDRRV_FORM_DB_OPS_L_DOOMS_TS    3

#define VDRRV_FORM_DB_OPS_G_UNIT       14
#define VDRRV_FORM_DB_OPS_G_HULL       18
#define VDRRV_FORM_DB_OPS_STATUS       15

#define VDRRV_FORM_DB_OPS_B_LOAD       16
#define VDRRV_FORM_DB_OPS_B_VIEW       17

extern void VDrrvCmdKillSnapshotDbOps __(());

extern void VDrrvCmdLoopSnapshotDbOps __(());


/* -----------------------------------------------
 * VDrrvScan.c
 */

extern IGRstat VDrrvGetPiecesFromOS __((VDosnum osnum, 
					IGRint *plateCnt, 
					IGRint *beamCnt, 
					TGRid **listIDs));


/* -----------------------------------------------
 * VDrrvTree.c
 */
extern void VDrrvAddDomStagingTreeNode __((TGRid          *domTreeID, 
					   TVDctxBaseInfo *domBaseInfo,
					   TVDctxNodeList *nodeList,
					   TGRid          *domFindID,
					   IGRint         *domNodeCnt,
					   TGRid          *stagingID));

extern void VDrrvAddDomStagingTree __((TGRid *treeID));


extern void VDrrvCreateDomTree __((IGRchar *treeType, 
				   IGRchar *treeName, 
				   TGRid   *treeID));


/* -----------------------------------------------
 * VDrrvUtil.c
 */
extern void VDrrvGetDefaultUnitModel __((IGRchar *unit, IGRchar *model));

extern IGRstat VDrrvGetDefaultCreateData __((TVDpdmPurposeInfo *p_info,
                                             IGRchar           *model));

extern IGRstat VDrrvFindPurposeInfo __((TVDpdmPurposeInfo *purposeInfo, VDosnum *osnum));

extern void VDrrvAutoSetPurposeInfo __(());

extern IGRstat VDrrvIsSetLinkedToOS __((TGRid *setID, VDosnum osnum));

/* -----------------------------------------------
 * Attribute routines VDrrvAttr.c
 * */
extern void VDrrvAddAttrsToDomTree __((TGRid  *treeID,
                                       VDosnum osnum));

extern IGRstat VDrrvPurposeAttrToInfo __((IGRchar           *attr,
                                          TVDpdmPurposeInfo *info));

extern IGRstat VDrrvPdmAttrToInfo __((IGRchar    *attr,
                                      TVDpdmInfo *info));

/* -------------------------------------------
 * Diff node processing VDrrvDiff.c
 */

extern void VDrrvCreateDiffNode __((TGRid   *diffsID, 
				    TGRid   *node1ID, 
				    TGRid   *node2ID,
				    IGRint   type,
				    IGRchar *comment,
				    TGRid   *a_diffID));

extern void VDrrvCreateSpecialDiff __((TGRid  *node1ID,
				       TGRid  *node2ID,
				       TGRid  *diffsID,
				       TGRid  *diffID));

typedef struct {
  TGRid *tree1ID;
  TGRid *tree2ID;
  TGRid *node1ID;  /* Newer item */
  TGRid *node2ID;  /* Older item */
  TGRid  diffIDs;  /* Master tree */
  TGRid  diffID;   /* Current diff node */
} TVDrrvDiffInfo;

extern void VDrrvInitDiffNode __((IGRint flag, TVDrrvDiffInfo *info));
extern void VDrrvInitDiffInfo __((TGRid *tree1ID, TGRid *tree2ID, TVDrrvDiffInfo *info));

extern IGRdouble fabs(IGRdouble dbl);

/* -------------------------------------------
 * VDrrvDooms.c
 */
extern void VDrrvCompareTwoPieceAttributes __((TGRid   *node1ID,
					       TGRid   *node2ID,
                                               IGRchar *name,
					       TGRid   *diffsID,
					       TGRid   *diffID));

extern void VDrrvCompareTwoPieceNodes __((TGRid *diffsID,
					  TGRid *node1ID,
					  TGRid *node2ID,
					  TGRid *diffID));

extern void VDrrvCompareTwoPieceTrees __((TGRid *tree1ID, 
					  TGRid *tree2ID, 
					  TGRid *diffsID));

extern void VDrrvCompareTwoTrees __((TGRid *tree1ID, 
				     TGRid *tree2ID, 
				     TGRid *diffsID));

/* -------------------------------------------
 * VDrrvEqp.c
 */
extern void VDrrvCompareTwoEqpNodes __((TVDrrvDiffInfo *info));
extern void VDrrvCompareTwoEqpTrees __((TVDrrvDiffInfo *info));

extern void VDrrvCompareTwoCsNodes __((TVDrrvDiffInfo *info,
                                       TGRid *node1ID,
                                       TGRid *node2ID));

extern void VDrrvAddEqps __((VDosnum osnum,TGRid *treeID));

/* -------------------------------------------
 * VDrrvComp.c
 */
extern void VDrrvCompareTwoCompTrees __((TVDrrvDiffInfo *info));
extern void VDrrvCompareTwoCompNodes __((TVDrrvDiffInfo *info));

extern void VDrrvAddComps __((VDosnum osnum,TGRid *treeID));

/* -------------------------------------------
 * VDrrvPen.c
 */
extern void VDrrvCompareTwoPcgTrees __((TVDrrvDiffInfo *info));
extern void VDrrvCompareTwoPenTrees __((TVDrrvDiffInfo *info));
extern void VDrrvCompareTwoPenNodes __((TVDrrvDiffInfo *info));

extern void VDrrvAddPens __((VDosnum osnum,TGRid *treeID));


/* -------------------------------------------------
 * Need a data structure to control file to process
 */
typedef struct 
{
  IGRchar purpose[32];
  IGRchar unit[8];
  IGRchar zone[8];
  IGRchar system[32];
  VDosnum osnum;
  IGRchar fileName[32];
  IGRint  useFlag;
  IGRint  doneFlag;
} TVDrrvPurposeInfo;

/* -------------------------------------------
 * VDrrvList.c
 */
#define VDRRV_FORM_LIST_NAME "VDrrvList.F"
#define VDRRV_FORM_LIST_NUM   165

#define VDRRV_FORM_G_FILE_LIST        37
#define VDRRV_FORM_G_FILE_HDR         38
#define VDRRV_FORM_G_FILE_LIST_OS      0
#define VDRRV_FORM_G_FILE_LIST_NAME    1
#define VDRRV_FORM_G_FILE_LIST_PURPOSE 2
#define VDRRV_FORM_G_FILE_LIST_UNIT    3
#define VDRRV_FORM_G_FILE_LIST_ZONE    4
#define VDRRV_FORM_G_FILE_LIST_SYSTEM  5
#define VDRRV_FORM_G_FILE_LIST_USE     6

extern void VDrrvCmdNotifyFileList  __((Form form, IGRint gadget));
extern void VDrrvCmdFillFileList    __((Form form, IGRint gadget, IGRint showFlag));
extern void VDrrvCmdFillFileListRow __((Form form, IGRint gadget, 
					IGRint *row, VDosnum osnum, IGRint showFlag));

extern IGRstat VDrrvCmdInitListSnapshot __((TVDtestTestInfo *testInfo));
extern void VDrrvCmdDefaultFileList  __((Form form, IGRint gadget));
extern void VDrrvCmdLoopListSnapshot __(());
extern void VDrrvCmdKillListSnapshot __(());

extern void VDrrvCmdGetInfoFromFileListRow __((Form   form, 
					       IGRint gadget, 
					       IGRint row,
					       TVDrrvPurposeInfo *info));

extern void VDrrvCmdGetListYesFiles __((Form   form, 
					IGRint gadget, 
					IGRint *cnt, 
					TVDrrvPurposeInfo **infos));

/* -------------------------------------------
 * VDrrvSnap.c
 */
extern void VDrrvCreateSnapshots __((TVDpdmPurposeInfo *curInfo, 
				     IGRint             infoCnt, 
				     TVDrrvPurposeInfo *infos,
				     TGRid             *treeID));

extern void VDrrvCreatePieceSnapshot __((VDosnum  osnum, 
					 TGRid   *treeID, 
					 IGRchar *stagedUnit));

/* -----------------------------------------------
 * VDrrvGet.c - Misc get routines
 */
extern void VDrrvGetListOM_Pieces __((TGRid *treeID, IGRint sortType, TVDctxNodeList *nodeList));
extern void VDrrvGetListST_Pieces __((TGRid *treeID, IGRint sortType, TVDctxNodeList *nodeList));


//Cleanup
#if defined(__cplusplus)
}
#endif

#endif
