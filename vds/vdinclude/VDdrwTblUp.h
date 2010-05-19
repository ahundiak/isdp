/* $Id: VDdrwTblUp.h,v 1.9 2002/03/30 16:54:21 ylong Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDdrwTblUp.h
 *
 * Description: Update drawing and table
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDdrwTblUp.h,v $
 *      Revision 1.9  2002/03/30 16:54:21  ylong
 *      *** empty log message ***
 *
 *      Revision 1.8  2002/02/14 22:55:21  ylong
 *      *** empty log message ***
 *
 *      Revision 1.7  2001/11/20 20:09:29  ylong
 *      *** empty log message ***
 *
 *      Revision 1.6  2001/11/15 20:59:31  ylong
 *      *** empty log message ***
 *
 *      Revision 1.5  2001/11/14 17:10:04  ylong
 *      CR5779
 *
 *      Revision 1.4  2001/11/09 21:12:42  ylong
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/03/02 14:13:36  ylong
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/02/22 22:37:05  ylong
 *      Modified function prototype
 *
 *      Revision 1.1  2001/01/10 16:41:14  art
 *      sp merge
 *
 * Revision 1.4  2000/09/25  18:54:08  pinnacle
 * ylong
 *
 * Revision 1.3  2000/09/12  14:49:26  pinnacle
 * changed prompt
 *
 * Revision 1.2  2000/08/23  18:15:48  pinnacle
 * ylong
 *
 * Revision 1.1  2000/08/07  18:29:26  pinnacle
 * ylong
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/06/00  ylong   Created for Update Drawing and Table command
 * 01/10/01  ah      sp merge
 ***************************************************************************/
#ifndef VDdrwTblUp_include
#define VDdrwTblUp_include 1

#include "v_drwprocess.h"

// C stuff
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

/*
 * Define form gadgets for VDdrwTblUpAs.frm
 */
#define VDTBL_FORM_G_FIND   18
#define VDTBL_FORM_G_TREE   26

/*
 * Define form gadgets and text for VDdrwTblUp.frm
 */
#define UPDATE_DRW_TBL_COMMAND	"Update Table and Drawing"
#define FORM_TITLE_DRW		"Update Drawing"
#define FORM_TITLE_TBL		"Update Table"
#define FORM_TITLE		11
#define SELECT_BY		13
#define APPEND_CHK		14
#define APPEND_TXT		23
#define ITEMNO_TXT		37
#define ITEMNO_FLD		38
#define TBL_OPT_GRP		51
#define STAGE_TXT		15
#define STAGE_FLD		16
#define STAGE_NAME_TXT		17
#define STAGE_NAME_FLD		18
#define	SETS_TXT		19
#define	SETS_FLD		12
#define	PRINT_BTN		22
#define	REPORT_FLD		24
#define	OUTPUT_FILE_FLD		26
#define	SHOW_TREE_BTN		27
#define	ASSIGN_BTN		28
#define	REVIEW_BTN		29
#define	PROCESS_BTN		30
#define	SORT_PCMK_BTN		31
#define	SORT_PATH_BTN		32
#define	SORT_TYPE_BTN		33
#define	SORT_STATUS_BTN		34
#define	FIT_OBJECT_BTN		35
#define INDEX_FLD		42
#define ITEMNO_OPT_FLD		47

#define	REPORT_PCMK_COL		0
#define	REPORT_PATH_COL		1
#define	REPORT_OBJ_TYPE_COL	2
#define	REPORT_STATUS_COL	3
#define	REPORT_OBJID_COL	4

typedef struct {
	TGRid		*nodeIDs;	// node array
	IGRchar		path[128];	// node path
	IGRint		index;		// selected
	IGRint		nodeCnt;	// number of nodes
} TVDstageList;

typedef struct {
	IGRchar		*index;
	IGRint		indLen;
	IGRint		indCnt;
} TVDindList;

typedef struct {

	Form		cmdFrm;
	Form		treeFrm;	// form pointer to VDdrwTblUp.frm
	Form		form;		// form pointer to VDdrwTblUp.frm
	IGRint		gadget;		// form gadget
	TGRobj_env	dtOE;		// located obj, drawing or table
	IGRint		obj_type;	// drawing or table ?
	IGRint		select_mod;	// drw: stage/object, tbl: stage/index
	IGRint		usrOpt;		// append new added object to table
					// and/or keep usr values in rows
	IGRchar		stage[128];	// stage from form
	IGRchar		sname[128];	// stage name
	TVDindList	indList;	// index list
	IGRchar		filename[128];	// update reprot file name
	IGRint		displayForm;	// 
	TGRid		setID;		// selected set
	TGRid		treeID;		// selected tree
	TGRid		rootID;		// selected root
	TVDstageList	nodeList;	// all nodes from selected tree/set

	struct PrcInfo	*curList;	// objects from drw model or tbl
	IGRint		curCnt;
	struct PrcInfo	*newList;	// objects from from tree/stage nodes
	IGRint		newCnt;
	struct PrcInfo	*outList;	// mergeList = oldList U newList 
	IGRint		outCnt;
	struct PrcInfo	*rvwList;	// review list for output 
	IGRint		rvwCnt;

} TVDdrwTblInfo ;


extern	IGRlong	VDdrwTblCMD_init	__((TVDdrwTblInfo *));
extern	IGRlong	VDdrwTblCMD_sleep	__((TVDdrwTblInfo *));
extern 	IGRlong	VDdrwTblCMD_wakeup	__((TVDdrwTblInfo *));
extern	IGRlong	VDdrwTblCMD_delete	__((TVDdrwTblInfo *));

extern	void	VDdrwTblCMD_disableForm	__((Form));
extern	void	VDdrwTblCMD_enableForm	__((Form));
extern	IGRlong	VDdrwTblCMD_initForm	__((TVDdrwTblInfo *));
extern	IGRlong	VDdrwTblCMD_setForm	__((TVDdrwTblInfo *));
extern	IGRlong VDdrwTblCMD_resetForm	__((TVDdrwTblInfo *));
extern	IGRlong VDdrwTblCMD_update	__((TVDdrwTblInfo *));
extern	IGRlong	VDdrwTblCMD_activateTrFrm	__((TVDdrwTblInfo *));
extern	IGRlong	VDdrwTblCMD_getLocatedInfo	__((TVDdrwTblInfo *));
extern	IGRlong VDdrwTblCMD_getClassList	__((OM_S_CLASSLIST *));
extern	IGRlong	VDdrwTblCMD_getNodeList		__((TGRid *, TGRid **, IGRint *));
extern	IGRlong	VDdrwTblCMD_getDrwObjs		__((TVDdrwTblInfo*));
extern	IGRlong	VDdrwTblCMD_getTblObjs		__((TVDdrwTblInfo*));
extern	IGRlong	VDdrwTblCMD_getNewList		__((TVDdrwTblInfo*));
extern	IGRlong	VDdrwTblCMD_fillSets		__((TVDdrwTblInfo*));
extern	IGRlong	VDdrwTblCMD_fillStageList	__((TVDdrwTblInfo*));
extern	IGRlong VDdrwTblCMD_fillNameList	__((TVDdrwTblInfo *));
extern	IGRlong VDdrwTblCMD_fillRootList	__((TVDdrwTblInfo *));
extern	IGRlong VDdrwTblCMD_reviewOut		__((TVDdrwTblInfo *));
extern	IGRstat	VDdrwTblCMD_notifyFrm		__((TVDdrwTblInfo *));
extern	IGRstat	VDdrwTblCMD_notifyTrFrm		__((TVDdrwTblInfo *));
extern	IGRlong VDdrwTblCMD_printOutput		__((TVDdrwTblInfo *));
extern	IGRlong VDdrwTblCMD_fillReport __((Form, IGRint, struct PrcInfo *, IGRint));
extern	IGRlong VDdrwTblCMD_sortList __((struct PrcInfo *, IGRint, IGRint));

// Cleanup
#if defined(__cplusplus)
}
#endif

#endif

