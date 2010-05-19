/* $Id: VDdom.h,v 1.8 2001/10/19 18:29:47 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDdom.h
 *
 * Description: Document Object Manager prototypes
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDdom.h,v $
 *      Revision 1.8  2001/10/19 18:29:47  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/03/11 18:33:11  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/03/09 15:02:22  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/02/26 15:45:32  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/02/22 23:00:44  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/17 14:06:12  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/14 16:11:38  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/10 15:33:42  art
 *      ah
 *
 * Revision 1.4  2000/12/08  15:58:54  pinnacle
 * ah
 *
 * Revision 1.3  2000/12/06  14:44:04  pinnacle
 * ah
 *
 * Revision 1.2  2000/12/01  13:53:04  pinnacle
 * ah
 *
 * Revision 1.1  2000/08/05  16:26:40  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/01/00  ah      Created
 * 01/12/01  ah      sp17 merge, lots of little changes
 * 10/18/01  ah      Obsolete, added deliberate error to flag is it gets included
 ***************************************************************************/

#ifndef VDdom_include
#define VDdom_include

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

/* ----------------------------------------------
 * Keep these in sync with the xml stuff until
 * all the old xml code is converted
 *
 * Use void pointers because both structures 
 * point to each other and I can't figure out
 * how to keep the compilier from complaining
 */

An Error !

#define VDDOM_TAG_TYPE_LEN   40
#define VDDOM_ATR_VALUE_LEN 128

typedef IGRchar TVDdomTagType [VDDOM_TAG_TYPE_LEN];
typedef IGRchar TVDdomAtrValue[VDDOM_ATR_VALUE_LEN];

typedef struct 
{
  void *parent;  /* Parent Element */
  void *next;    /* Next Attribute */
  TVDdomTagType   type;
  TVDdomAtrValue  value;
} TVDdomAtr;

typedef struct 
{
  void *parent;
  void *children;
  void *sibling;
  
  TVDdomAtr    *atrs;
  TVDdomTagType type;

  TGRid eleID;

  IGRint classType;
  
} TVDdomEle;

#define VDDOM_CLASS_TYPE_NONE 0
#define VDDOM_CLASS_TYPE_MGR  1
#define VDDOM_CLASS_TYPE_SET  2

/* -------------------------------------------------------
 * Single object space info
 */
typedef unsigned short int DOM_S_OSNUM;
typedef unsigned long  int DOM_S_OBJID;

#ifndef VDtypedefc_include
#define NULL_OSNUM  ((DOM_S_OSNUM) -1)
#endif

typedef struct 
{
  IGRint       max;
  IGRint       cnt;
  IGRint       inc;
  DOM_S_OSNUM  osnum;

  TVDdomEle  **ele_list;
  TVDdomEle   *ele_free;

} TVDdomOSD;

/* ---------------------------------------------
 * Very private internal data, don't use
 */
typedef struct 
{
  IGRint      revFlag;
  
  DOM_S_OSNUM osnum_beg;
  DOM_S_OSNUM osnum_end;
  DOM_S_OSNUM osnum_act;
  IGRint      osnum_cnt;
  TVDdomOSD  *osd_list;

  TVDdomAtr *atr_list;
  IGRint     atr_cnt;

  TGRid  mgrID;
} TVDdomStaticData;

/* ---------------------------------------------
 * vddom/VDdomOM.c
 */

extern IGRstat     VDdomInitSystem     __((IGRint flag, DOM_S_OSNUM osnum_beg, IGRint osnum_cnt));

extern DOM_S_OSNUM VDdomGetActiveOsnum __((DOM_S_OSNUM *osnum));

extern IGRstat     VDdomGetObjInstance __((TGRid *nodeID, TVDdomEle **nodeDD));

extern IGRstat     VDdomGetOSD         __((DOM_S_OSNUM osnum, TVDdomOSD **osd));

extern IGRstat     VDdomIsOSValid      __((DOM_S_OSNUM osnum));
extern IGRstat     VDdomIsIDValid      __((DOM_S_OSNUM osnum, DOM_S_OBJID objid));
extern IGRstat     VDdomIsObjValid     __((TGRid *nodeID));

extern IGRstat     VDdomFreeTreeEle    __((TVDdomEle *treeDD));

extern IGRstat     VDdomFreeLists      __(());
extern IGRstat     VDdomFreeObjList    __(());

/* ---------------------------------------------
 * vddom/VDdomMisc.c
 */
extern IGRstat VDdomGetDoublesFromAttribute __((IGRchar   *value,
						IGRint     max, 
						IGRint    *cnt, 
						IGRdouble *doubles));

/* ---------------------------------------------
 * vddom/VDdomObj.c
 */
extern void    VDdomGetObjClassName __((TGRid *nodeID, IGRchar *className));
extern void    VDdomGetObjClassType __((TGRid *nodeID, IGRint  *classType));
extern void    VDdomSetObjClassType __((TGRid *nodeID, IGRint   classType));

extern IGRstat VDdomConvertToSetObj __((TGRid *treeID));

extern void    VDdomPrintObj  __((TGRid *nodeID, FILE *file, IGRint atrs, IGRint kids, IGRint indent));
extern void    VDdomPrintTree __((TGRid *treeID, FILE *file));

extern IGRstat VDdomCreateObj __((TGRid *parentID, IGRchar *type, TGRid *newID));

extern IGRstat VDdomGetObjParent __((TGRid *childID, TGRid *parentID));

#define VDdomGetParentObj(childID,parentID) VDdomGetObjParent(childID,parentID)

extern IGRstat VDdomGetObjDesc   __((TGRid *nodeID, IGRchar *desc));

extern IGRstat VDdomGetNthChildObj    __((TGRid *nodeID, IGRint nth,  TGRid  *childID));
extern IGRstat VDdomGetObjChildCount  __((TGRid *nodeID, IGRint flag, IGRint *cnt));

extern IGRstat VDdomAppendChildObj    __((TGRid *parentID, TGRid *childID));

extern IGRstat VDdomGetObjByClassName __((TGRid *nodeID, IGRchar *className, TGRid *foundID));

extern IGRstat VDdomFreeTreeObj       __((TGRid *nodeID));

extern void    VDdomGetSetObj  __((TGRid *nodeID, TGRid *setID));
extern void    VDdomGetTreeObj __((TGRid *nodeID, TGRid *treeID));

// Node name and type interface
extern IGRstat VDdomGetObjName  __((TGRid *nodeID, IGRchar *name));
extern IGRstat VDdomGetObjType  __((TGRid *nodeID, IGRchar *type));

/* ---------------------------------------------
 * vddom/VDdomAtr.c
 */
extern IGRstat VDdomAppendAtr __((TGRid   *nodeID, 
				  IGRchar *type, 
				  IGRchar *value));

extern IGRstat VDdomSetTxtAtr __((TGRid   *nodeID, 
				  IGRint   createFlag, 
				  IGRchar *type, 
				  IGRchar *value));

extern IGRstat VDdomCreateAtr __((IGRchar    *type, 
				  IGRchar    *value, 
				  TVDdomAtr **atrAD));

extern IGRstat VDdomFreeAtrList __(());
extern  void   VDdomFreeAtr     __((TVDdomAtr *atrAD));

extern IGRstat    VDdomGetFirstAtr  __((TGRid *nodeID,                TVDdomAtr **nodeAD));
extern IGRstat    VDdomGetNthAtr    __((TGRid *nodeID, IGRint   nth,  TVDdomAtr **nodeAD));
extern IGRstat    VDdomGetAtrByType __((TGRid *nodeID, IGRchar *type, TVDdomAtr **nodeAD));

#define VDdomGetAtrByName(nodeID,name,nodeAD) VDdomGetAtrByType(nodeID,name,nodeAD)

extern IGRstat    VDdomGetAtrCount  __((TGRid *nodeID, IGRint  *cnt));

extern TVDdomAtr *VDdomGetNextAtr  __((TVDdomAtr *nodeAD));

// Private
extern TVDdomAtr *VDdomGetFreeAtrList __(());
extern void       VDdomSetFreeAtrList __((TVDdomAtr *atr_list));
extern IGRint     VDdomGetFreeAtrCnt  __(());
extern void       VDdomSetFreeAtrCnt  __((IGRint atr_cnt));
extern void       VDdomIncFreeAtrCnt  __(());


/* ---------------------------------------------
 * vddom/VDdomMgr.c
 */
extern void VDdomGetMgr __((VDosnum osnum, IGRint flag, TGRid *mgrID));

/* ---------------------------------------------
 * vddom/VDdomXml.c
 */
extern IGRstat VDdomCreateTreeFromXmlFile __((IGRchar *fileName, TGRid *treeID));

/* ---------------------------------------------
 * vddom/VDdomCreate.c
 */
extern void VDdomCreateTree __((VDosnum osnum,    IGRchar *treeType, IGRchar *treeName, TGRid *treeID));
extern void VDdomCreateNode __((TGRid  *parentID, IGRchar *nodeType, IGRchar *nodeName, TGRid *nodeID));
extern void VDdomCreateFind __((TGRid  *findID));

/* ---------------------------------------------
 * vddom/VDdomTreeF.c
 */
#ifndef FI_H_INCLUDED
#include "FI.h"
#endif

extern IGRstat VDdomFormFillTree   __((Form form, IGRint gadget, TGRid *treeID));
extern IGRstat VDdomFormNotifyTree __((Form form, IGRint gadget, TGRid *nodeID));

/* ------------------------- */
#if defined(__cplusplus)
}
#endif

#endif



