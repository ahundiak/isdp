/* $Id: VLsmsCmd.h,v 1.3 2001/09/14 13:41:52 ahundiak Exp $  */

/***************************************************************************
 * I/LOFT
 *
 * File:        include/VLsmsCmd.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VLsmsCmd.h,v $
 * Revision 1.3  2001/09/14 13:41:52  ahundiak
 * ah
 *
 * Revision 1.2  2001/01/16 18:12:00  ramarao
 * *** empty log message ***
 *
 * Revision 1.3  2000/11/27  20:22:12  pinnacle
 * ah
 *
 * Revision 1.2  2000/05/04  13:06:20  pinnacle
 * ah
 *
 * Revision 1.1  2000/04/25  16:26:24  pinnacle
 * ah
 *
 * Revision 1.2  2000/03/31  14:56:58  pinnacle
 * Replaced: include/VLsmsCmd.h for:  by impd252 for loft
 *
 * Revision 1.1  2000/02/25  17:39:26  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/15/99  ah      Creation
 * 03/31/00  jvh	added support for beams
 *
 ***************************************************************************/
#ifndef VLsmsCmd_include
#define VLsmsCmd_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

typedef struct 
{
  IGRint qty;
  TGRobj_env unwrapOE;
} TVLsmsPlateItem;

typedef struct {
  Form  form;  // Not null impiles created
  int   dis;   // Is displayed
  int   act;   // Is active
  TGRid id;    // Main object
} TVLsmsForm;

typedef struct {
  TVLsmsForm ext;

  Form  form;
  int   gadget;
  int   enableWakeup;
  int   initedOK;
  TGRid cmdID;

  OM_S_CLASSLIST classList;

  TGRid setID;  // Active set id 
  TGRid setIDu; // UnDevelopable Plates
  TGRid setIDm; // Misc Plates
  
  TGRid pplID;

  TVLsmsFileInfo file;
  TVLsmsPlateItem *plateItems;
  IGRint           plateItemMax;
  
  TVLsmsPlateItem *beamItems;
  IGRint           beamItemMax;
  
  IGRint         writeTree;

  IGRchar unitReal[128];
  IGRchar unitTest[128];

  IGRchar spadesFileName[128];
  IGRchar timeStamp     [64];
  
  IGRchar hull[16];
  IGRchar fileStatus[16];
  IGRchar fileWhat[16];
  IGRint  preTranslate;
  IGRint  mapLabels;
  
} TVLsmsCmdInfo;

/* ----------------------------------------------------------
 * Form Interface
 */
#define VLSMS_FORM_NAME       "VLsmsCmd.F"
#define VLSMS_FORM_G_FILE_NAME 14
#define VLSMS_FORM_G_FILE_WHAT 20
#define VLSMS_FORM_G_FILE_HULL 21
#define VLSMS_FORM_G_FILE_STAT 24
#define VLSMS_FORM_B_FILE_SEND 22

#define VLSMS_FORM_G_SETS 15
#define VLSMS_FORM_G_TREE 16


#define VLEXT_FORM_NAME       "VLextract.F"
#define VLEXT_FORM_G_PRE  12
#define VLEXT_FORM_G_HULL 13
#define VLEXT_FORM_G_UNIT 14
#define VLEXT_FORM_G_MAP  24
#define VLEXT_FORM_G_TREE_STATUS 19

#define VLEXT_FORM_B_QUICK_SCAN 18
#define VLEXT_FORM_B_TREE_REV   20
#define VLEXT_FORM_B_EXTRACT    21
#define VLEXT_FORM_B_SEND       22

/* ----------------------------------------------------------
 * C++
 */
#if defined(__cplusplus)
extern "C" {
#endif

/* -------------------------------------------------------
 * Interface to Manager 
 */
extern IGRstat VLsmsCmdInit   __((TVLsmsCmdInfo *info));
extern IGRstat VLsmsCmdSleep  __((TVLsmsCmdInfo *info));
extern IGRstat VLsmsCmdWakeup __((TVLsmsCmdInfo *info));
extern IGRstat VLsmsCmdDelete __((TVLsmsCmdInfo *info));

extern IGRstat VLsmsCmdNotifyForm   __((TVLsmsCmdInfo *info));
extern IGRstat VLsmsCmdNotifyObject __((TVLsmsCmdInfo *info, TGRobj_env *objOE));

extern IGRstat VLsmsCmdClassList __((OM_S_CLASSLIST *classList));

extern IGRstat VLsmsCmdExtractTreeNode __((TVLsmsCmdInfo *info, TGRid *nodeID));
extern IGRstat VLsmsCmdExtractTree     __((TVLsmsCmdInfo *info));
extern IGRstat VLsmsCmdExtractSetup    __((TVLsmsCmdInfo *info));
extern IGRstat VLsmsCmdExtractShip     __((TVLsmsCmdInfo *info));


/* -------------------------------------------------------
 * VLsmsCmd.I 
 */
extern IGRstat VLsmsCmdWritePlates   __((TVLsmsCmdInfo *info));

extern IGRstat VLsmsCmdWriteTreeNode __((TVLsmsCmdInfo *info, TGRid *nodeID));
extern IGRstat VLsmsCmdWriteTree     __((TVLsmsCmdInfo *info));

extern IGRstat VLsmsCmdWriteSetup    __((TVLsmsCmdInfo *info));

extern IGRstat VLunwFindLeafForPcmk __((TGRid *parentID, 
					IGRint pcmk, 
					TGRid *leafID));

extern IGRstat VLunwGetUndevUnwrapForPlate __((TGRid *undevSetID, 
					       IGRint pcmk, 
					       TGRobj_env *unwrapOE));

extern IGRstat VLsmsAddNodeToItemList __((TVLsmsCmdInfo *info, TGRid *leafID));


/* -------------------------------------------------------
 * VLsmsCmd2.I 
 */
extern IGRstat VLsmsCmdGetSetToWrite __((IGRchar *setName, 
					 TGRid   *setID,
					 TGRid   *setIDu,
					 TGRid   *setIDm));

extern IGRstat VLsmsCmdWriteSet __((IGRchar *unitReal, 
				    IGRchar *unitTest, 
				    IGRint   writeTree, 
				    IGRint   writePlates,
				    IGRint   pre_translate));

extern IGRstat VLsmsCmdWriteUnwrap __((TGRobj_env *unwrapOE));

extern IGRstat VLsmsCmdInitForm __((Form form));
extern IGRstat VLsmsCmdPostTree __((Form form));

/* -------------------------------------------------------
 * VLsmsCmd3.I 
 */
extern IGRstat VLsmsCmdWriteSetUsingForm __((Form form, IGRint type));
extern IGRstat VLsmsCmdGetInfoFromForm   __((Form form, TVLsmsCmdInfo *info));

extern IGRstat VLsmsCmdWriteHeader       __((TVLsmsCmdInfo *info));

// -------------------------
#if defined(__cplusplus)
}
#endif

#endif











