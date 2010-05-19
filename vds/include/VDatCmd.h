/* $Id: VDatCmd.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDatCmd.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatCmd.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.3  1999/03/03  06:15:54  pinnacle
 * Replaced: include/VDatCmd.h for:  by vsrivast for vds
 *
 * Revision 1.2  1998/10/25  13:05:06  pinnacle
 * ah
 *
 * Revision 1.1  1998/10/11  13:51:42  pinnacle
 * ah
 *
 * Revision 1.2  1998/09/25  15:43:10  pinnacle
 * ah
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/10/97  ah      creation
 * 10/11/98  ah      Renamed from VDatFORMS.h to VDatCmd.h
 *                   Also merged in VDatFmLabels.h
 * 03/03/99	 vinit   Added a field to TVDatFrmList structure
 ***************************************************************************/

#ifndef VDatCmd_include
#define VDatCmd_include

#ifndef   VDahFrm_include
#include "VDahFrm.h"
#endif

// For hilites
#ifndef   dpdef_include
#include "dpdef.h"
#endif

#ifndef   dpmacros_include
#include "dpmacros.h"
#endif

// Usual c++ stuff
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif


// All  VDAT Forms
#define VDAT_FORM_ALL_L_MISC     71
#define VDAT_FORM_ALL_G_SET_NAME 51

#define VDAT_FORM_NAME_SET  "VDatSet.frm"
#define VDAT_FORM_NAME_TREE "VDatTree.frm"

#define VDAT_FORM_G_SETS        36
#define VDAT_FORM_G_STAGE_TYPES 14

#define VDAT_FORM_G_PLATES 16

#define VDAT_FORM_C_PIECES_NAME 0
#define VDAT_FORM_C_PIECES_GRID 1

#define VDAT_FORM_G_TREE   26
#define VDAT_FORM_C_TREE_ATTR  0
#define VDAT_FORM_C_TREE_EXP   1
#define VDAT_FORM_C_TREE_NAME  2
#define VDAT_FORM_C_TREE_GRID  3
#define VDAT_FORM_C_TREE_LEVEL 4

#define VDAT_FORM_B_TREE_CLEAR 37

#define VDAT_FORM_B_WORK 13
#define VDAT_FORM_G_WORK 38

#define VDAT_FORM_B_CREATE 39
#define VDAT_FORM_G_CREATE 40

#define VDAT_FORM_B_DELETE_STAGE 15

#define VDAT_FORM_B_MOVETO     20
#define VDAT_FORM_B_MOVETO_SET 21
#define VDAT_FORM_B_HILITE     45

#define VDAT_FORM_B_MOVE_UP    30
#define VDAT_FORM_B_MOVE_DOWN  26

#define VDAT_FORM_G_STATUS 10
#define VDAT_FORM_G_GRIDS  33

/* ----------------------------------------------------
 * Note: Must keep this in sync with structure
 * defined in COatMgr.u
 */

typedef struct {
  Form form,mgr,set,leaf,tree,stage,rep,attr,pcmk,rpt;
  int  gadget;
	int reset;
  VDclassid      classIDs[16];
  OM_S_CLASSLIST classList;
  
} TVDatFrmList;

#if defined(__cplusplus)
extern "C" {
#endif

/* -----------------------------------------------
 * Generic Form routines
 */
extern IGRstat VDatFormShowRow        __((Form form, IGRint gadget, IGRint row));
extern IGRstat VDatFormHiLiteGadget   __((Form form, IGRint gadget, IGRint col, IGRint col1));
extern IGRstat VDatFormUnSelectGadget __((Form form, IGRint gadget, IGRint col, IGRint col1));

extern IGRstat VDatFormSetStatus __((Form form, IGRint  status));
extern IGRstat VDatFormGetStatus __((Form form, IGRint *status));

extern IGRstat VDatFormSetActive __((Form form, IGRint active));
extern IGRstat VDatFormIsActive  __((Form form));

extern IGRstat VDatCMDAllGetActiveSet  __((TVDatFrmList *fl, TGRid  *setID, IGRchar *setName));
extern IGRstat VDatCMDAllGetActiveLeaf __((TVDatFrmList *fl, TGRid *leafID));
extern IGRstat VDatCMDAllGetActiveNode __((TVDatFrmList *fl, TGRid *nodeID));

extern IGRstat VDatCMDAllSetActiveSet  __((TVDatFrmList *fl, TGRid  *setID));
extern IGRstat VDatCMDAllSetActiveLeaf __((TVDatFrmList *fl, TGRid *leafID));
extern IGRstat VDatCMDAllSetActiveNode __((TVDatFrmList *fl, TGRid *nodeID));

/* ------------------------
 * Activate Routines
 */
extern IGRstat VDatCMDSetActivateForm  __((TVDatFrmList *fl));
extern IGRstat VDatCMDLeafActivateForm __((TVDatFrmList *fl));
extern IGRstat VDatCMDTreeActivateForm __((TVDatFrmList *fl));
extern IGRstat VDatCMDPcmkActivateForm __((TVDatFrmList *fl));

/* -----------------------------------------------
 * Form routines
 */
extern IGRstat VDatFormSetMgrID  __((Form form, TGRid *objID));
extern IGRstat VDatFormGetMgrID  __((Form form, TGRid *objID));
extern IGRstat VDatFormSetSetsID __((Form form, TGRid *objID));
extern IGRstat VDatFormGetSetsID __((Form form, TGRid *objID));
extern IGRstat VDatFormSetSetID  __((Form form, TGRid *objID));
extern IGRstat VDatFormGetSetID  __((Form form, TGRid *objID));
extern IGRstat VDatFormSetTreeID __((Form form, TGRid *objID));
extern IGRstat VDatFormGetTreeID __((Form form, TGRid *objID));

extern IGRstat VDatFormFillEverything __((Form form));
extern IGRstat VDatFormSetIDs         __((Form form));

extern IGRstat VDatFormFillStages   __((Form form, IGRint gadget, TGRid *setID));
extern IGRstat VDatFormNotifyStages __((Form form, IGRint gadget));

extern IGRstat VDatFormFillPlates   __((Form form, IGRint gadget));
extern IGRstat VDatFormNotifyPlates __((Form form, IGRint gadget));

/* -----------------------------------------------
 * Tree Processing
 */

extern IGRstat VDatFormFindTreeRow __((
  Form   form, 
  IGRint gadget, 
  TGRid *workID, 
  IGRint *rowFound
));

extern IGRstat VDatFormFillTreeRow __((
  Form    form, 
  IGRint  gadget, 
  IGRint *row, 
  IGRint  level,
  TGRid  *nodeID,
  IGRint  atrFlag,
  IGRint  expFlag
));

extern IGRstat VDatFormFillTree __((Form form, IGRint gadget, TGRid *objID));

extern IGRstat VDatFormUpdateTreeRow __((Form form, IGRint gadget, TGRid *rowID));

extern IGRstat VDatFormExpandTreeAttrRow   __((Form form, IGRint gadget, IGRint row));
extern IGRstat VDatFormContractTreeAttrRow __((Form form, IGRint gadget, IGRint row));

extern IGRstat VDatFormExpandTreeRow   __((Form form, IGRint gadget, IGRint row));
extern IGRstat VDatFormContractTreeRow __((Form form, IGRint gadget, IGRint row));
extern IGRstat VDatFormDeleteTreeRow   __((Form form, IGRint gadget, IGRint row));

extern IGRstat VDatFormClearTree __((Form form, IGRint gadget));

extern IGRstat VDatFormNotifyTreeAttr __((
  Form   form, 
  IGRint gadget, 
  IGRint row, 
  TGRid *rootID
));

extern IGRstat VDatFormNotifyTreeExp __((
  Form   form, 
  IGRint gadget, 
  IGRint row, 
  TGRid *rootID
));

extern IGRstat VDatFormNotifyTreeName __((
  Form   form, 
  IGRint gadget, 
  IGRint row, 
  TGRid *rootID
));


extern IGRstat VDatFormNotifyTree __((
  Form   form, 
  IGRint gadget,
  TGRid *nodeID
));

/* -----------------------------------------------
 * 10/11/98 Merged in VDatFmLabels.h
 */

/* Label, 10, common to all forms, except VDTrSetFrm */

#define VDAT_FORM_G_STATUS 10



/* 
 * Form: DefModAssy.frm		"Define or Modify Assembly Tree" 
 *	 Labels, 1-75
 */ 

#define VDAT_FORM_NAME_DEF_MOD_ASSY "DefModAssy.frm"

#define VDAT_FORM_G_SETS        36
#define VDAT_FORM_G_STAGE_TYPES 14

#define VDAT_FORM_G_PLATES      16

#define VDAT_FORM_C_PIECES_NAME 0
#define VDAT_FORM_C_PIECES_GRID 1

#define VDAT_FORM_G_TREE        26      /* Used in VDCAsTrAtt.fm */
#define VDAT_FORM_C_TREE_ATTR   0
#define VDAT_FORM_C_TREE_EXP    1
#define VDAT_FORM_C_TREE_NAME   2
#define VDAT_FORM_C_TREE_GRID   3
#define VDAT_FORM_C_TREE_LEVEL  4

#define VDAT_FORM_B_WORK        13
#define VDAT_FORM_G_WORK        38

#define VDAT_FORM_B_CREATE      39
#define VDAT_FORM_G_CREATE      40

#define VDAT_FORM_B_MOVETO      20
#define VDAT_FORM_B_MOVETO_SET  21

#define VDAT_FORM_G_GRIDS       33


/* 
 * Form: VDCAsTrAtt.fm		"Define or Modify Assembly Attributes" 
 *	 Labels, 76-150
 */ 


#define VDAT_FORM_NAME_AS_TR_ATT  "VDCAsTrAtt.fm"

/*      VDAT_FORM_G_TREE         26   defined under DefModAssy.frm */
#define VDAT_FORM_F_UNIT	 79
#define VDAT_FORM_TG_ATTRIBUTE	 82
#define VDAT_FORM_B_DISPLAY	 93
#define VDAT_FORM_B_MODIFY 	 94
#define VDAT_FORM_B_COPY_ARROW   96
#define VDAT_FORM_B_COPY_ALL	 97
#define VDAT_FORM_B_COPY_SEL 	 98
#define VDAT_FORM_B_RESET        99
#define VDAT_FORM_B_PASTE        100
#define VDAT_FORM_F_NAME_VALU    104
#define VDAT_FORM_F_CHOICES      105
#define VDAT_FORM_B_CLEAR        106
#define VDAT_FORM_B_READ_FILE	 107 
#define VDAT_FORM_F_FILENAME     109
#define VDAT_FORM_B_SEARCH 	 110


/* 
 * Form: VDTrSetFrm		"Define or Modify Assembly Set" 
 *	 Labels, 151-200
 */ 


#define VDAT_FORM_NAME_TREE_SET "VDTrSetFrm"

#define	VDAT_MAXTEXT		80
#define	VDAT_FORM_B_TITASS	151
#define	VDAT_FORM_T_TITPRD	152
#define	VDAT_FORM_T_UNTNAME	153
#define	VDAT_FORM_F_UNTFLD	154
#define	VDAT_FORM_T_TBLNAME	155
#define	VDAT_FORM_F_TBLFLD	156
#define	VDAT_FORM_B_ADDBUTT	157
#define	VDAT_FORM_B_REMBUTT	158
#define	VDAT_FORM_B_DELBUTT	159


/* 
 * Form: VDGenReport		"Generate Components Report" 
 *	 Labels, 201-250
 */ 


#define VDAT_FORM_NAME_GEN_REPORT  "VDGenReport"

#define VDAT_FORM_T_FORM_TITLE  201
#define VDAT_FORM_F_DIR_FIELD	203
#define VDAT_FORM_F_FILE_FIELD	205
#define VDAT_FORM_F_FILT_FIELD  207
#define VDAT_FORM_F_REP_FIELD   209
#define VDAT_FORM_F_REPF_FIELD  211
#define VDAT_FORM_F_TITLE_FIELD 213


/* 
 * Form: SelAssyNod.frm		"Select Assembly Tree Components" 
 *	 Labels, 251-300
 */ 

/*      VDAT_FORM_G_TREE         26   defined under DefModAssy.frm */
#define VDAT_FORM_F_UNITS	253

#if defined(__cplusplus)
}
#endif

#endif









