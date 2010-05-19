/* $Id: VDatClass.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDatClass.h
 *
 * Description: Assembly tree classes
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatClass.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/10/11  13:51:42  pinnacle
 * ah
 *
 * Revision 1.2  1998/04/30  14:30:44  pinnacle
 * ah
 *
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/25/97  ah      creation
 * 04/30/98  ah      Had DYN_REC defined twice
 * 01/11/98  ah      Renamed VDatCLASS.h to VDatclass.h
 ***************************************************************************/

#ifndef VDatClass_include
#define VDatClass_include

/* Class types */
#define VDAT_CLASSN_BASE      "VDatBase"
#define VDAT_CLASSI_BASE       100

#define VDAT_CLASSN_FRM_MGR   "VDatFrmMgr"
#define VDAT_CLASSI_FRM_MGR    200

#define VDAT_CLASSN_NB        "VDatNB"
#define VDAT_CLASSI_NB         210

#define VDAT_CLASSN_PDM_MGR   "VDatPdmMgr"
#define VDAT_CLASSI_PDM_MGR    220

#define VDAT_CLASSN_SET_MGR   "VDatSetMgr"
#define VDAT_CLASSI_SET_MGR    300

#define VDAT_CLASSN_STAGES    "VDatStages"
#define VDAT_CLASSI_STAGES     310

#define VDAT_CLASSN_STAGE     "VDatStage"
#define VDAT_CLASSI_STAGE      311

#define VDAT_CLASSN_TABLES    "VDatTables"
#define VDAT_CLASSI_TABLES     320

#define VDAT_CLASSN_TABLE     "VDatTable"
#define VDAT_CLASSI_TABLE      321

#define VDAT_CLASSN_SETS      "VDatSets"
#define VDAT_CLASSI_SETS       330

#define VDAT_CLASSN_SET       "VDatSet"
#define VDAT_CLASSI_SET        331

#define VDAT_CLASSN_NODES     "VDatNodes"
#define VDAT_CLASSI_NODES      340

#define VDAT_CLASSN_NODE      "VDatNode"
#define VDAT_CLASSI_NODE       341

#define VDAT_CLASSN_TREES     "VDatTrees"
#define VDAT_CLASSI_TREES      350

#define VDAT_CLASSN_TREE      "VDatTree"
#define VDAT_CLASSI_TREE       351

#define VDAT_CLASSN_ROOT      "VDatRoot"
#define VDAT_CLASSI_ROOT       361

#define VDAT_CLASSN_LEAFS     "VDatLeafs"
#define VDAT_CLASSI_LEAFS      370

#define VDAT_CLASSN_LEAF      "VDatLeaf"
#define VDAT_CLASSI_LEAF       371

#define VDAT_CLASSN_PIECES    "VDatPieces"
#define VDAT_CLASSI_PIECES     380

#define VDAT_CLASSN_PLATES    "VDatPlates"
#define VDAT_CLASSI_PLATES     381

#define VDAT_CLASSN_BEAMS     "VDatBeams"
#define VDAT_CLASSI_BEAMS      382

#define VDAT_CLASSN_OTHERS    "VDatOthers"
#define VDAT_CLASSI_OTHERS     383

#define VDAT_CLASSN_RDB_CACHE "VDatRDBCache"
#define VDAT_CLASSI_RDB_CACHE  400

#define VDAT_CLASSN_RDB_TRAN  "VDatRDBTran"
#define VDAT_CLASSI_RDB_TRAN   401

#define VDAT_CLASSN_RDB_SETS  "VDatRDBSets"
#define VDAT_CLASSI_RDB_SETS   410

#define VDAT_CLASSN_RDB_SET   "VDatRDBSet"
#define VDAT_CLASSI_RDB_SET    411

#define VDAT_CLASSN_RDB_NODES "VDatRDBNodes"
#define VDAT_CLASSI_RDB_NODES  420

#define VDAT_CLASSN_RDB_NODE  "VDatRDBNode"
#define VDAT_CLASSI_RDB_NODE   421

#define VDAT_CLASSN_RDB_POSTS "VDatRDBPosts"
#define VDAT_CLASSI_RDB_POSTS  430

#define VDAT_CLASSN_RDB_POST  "VDatRDBPost"
#define VDAT_CLASSI_RDB_POST   431

#define VDAT_CLASSN_RDB_ATTRS "VDatRDBAttrs"
#define VDAT_CLASSI_RDB_ATTRS  440

#define VDAT_CLASSN_RDB_ATTR  "VDatRDBAttr"
#define VDAT_CLASSI_RDB_ATTR   441

#define VDAT_CLASSN_RDB_MACS  "VDatRDBMacs"
#define VDAT_CLASSI_RDB_MACS   450

#define VDAT_CLASSN_RDB_MAC   "VDatRDBMac"
#define VDAT_CLASSI_RDB_MAC    451

#define VDAT_CLASSN_DYN_MGR   "VDatDynMgr"
#define VDAT_CLASSI_DYN_MGR    500

#define VDAT_CLASSN_DYN_TBLS  "VDatDynTbls"
#define VDAT_CLASSI_DYN_TBLS   501

#define VDAT_CLASSN_DYN_TBL   "VDatDynTbl"
#define VDAT_CLASSI_DYN_TBL    502

#define VDAT_CLASSN_DYN_RECS  "VDatDynRecs"
#define VDAT_CLASSI_DYN_RECS   503

#define VDAT_CLASSN_DYN_REC   "VDatDynRec"
#define VDAT_CLASSI_DYN_REC    504

/* Channels */
#define VDAT_CHN_TO_PARENT   "NDchildren.children"
#define VDAT_CHN_TO_CHILDREN "NDfather.father"

#define VDAT_CHN_TO_LISTEN   "GRnotify.notification"
#define VDAT_CHN_TO_NOTIFY   "VDatBase.to_notify"

#endif

