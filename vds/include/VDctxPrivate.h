/* $Id: VDctxPrivate.h,v 1.6 2001/10/19 18:29:46 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDctxPrivate.h
 *
 * Description: Private access to low level functions
 *              Include this file before include VDctx.h
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctxPrivate.h,v $
 *      Revision 1.6  2001/10/19 18:29:46  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/10/18 15:31:47  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/08/24 19:58:34  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/05/02 14:51:47  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/04/06 12:46:26  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/13 00:15:48  ahundiak
 *      ah
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/12/01  ah      Created
 * 04/05/01  ah      added getPieceMark,getPieceType
 * 10/18/01  ah      removed cDom and Dom interfaces
 ***************************************************************************/

#ifndef VDctxPrivate_include
#define VDctxPrivate_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#ifndef   VDtypedefc_include
#include "VDtypedefc.h"
#endif

#ifndef   VDxml_include
#include "VDxml.h"
#endif

#ifndef   VDfld_include
#include "VDfld.h"
#endif

#ifndef   dp_include
#include  "dp.h"
#endif

/* ----------------------------------------------------------
 * C++
 */
#if defined(__cplusplus)
extern "C" {
#endif

/* ---------------------------------------------
 * Available classes
 */
#define VDCTX_CP_BASE 0
//#define VDCTX_CP_DOM  1
#define VDCTX_CP_CT1  2
#define VDCTX_CP_AT   3
#define VDCTX_CP_OM   4
// #define VDCTX_CP_CDOM 5
#define VDCTX_CP_XDOM 6

/* ---------------------------------------------
 * Base information about a node
 * Need to duplicate from VDctx for the function pointers
 * Be sure and keep these in sync
 */
#define VDCTX_MAX_NAME_LEN    32
#define VDCTX_MAX_TYPE_LEN    16
#define VDCTX_MAX_TYPE_REV_LEN 4

typedef struct
{
  IGRchar setType   [VDCTX_MAX_TYPE_LEN];
  IGRchar setTypeRev[VDCTX_MAX_TYPE_REV_LEN];
  IGRchar setName   [VDCTX_MAX_NAME_LEN];

  IGRchar treeType[VDCTX_MAX_TYPE_LEN];
  IGRchar treeTRev[VDCTX_MAX_TYPE_REV_LEN];
  IGRchar treeName[VDCTX_MAX_NAME_LEN];
  IGRchar nodeType[VDCTX_MAX_TYPE_LEN];
  IGRchar nodeName[VDCTX_MAX_NAME_LEN];
  IGRchar baseName[50];
} TVDctxBaseInfo;
 
/* ---------------------------------------------
 * Main class pointer structure
 */
typedef struct TVDctxCP
{ 
  struct TVDctxCP *parentCP;

  // Base information
  IGRstat (*getBaseInfo)(TGRid *nodeID, TVDctxBaseInfo *baseInfo);
  IGRstat (*setBaseInfo)(TGRid *nodeID, TVDctxBaseInfo *baseInfo);

  // Attributes
  IGRstat (*getBinAtr)(TGRid *nodeID, TGRmd_env *env, 
		       IGRchar *name, IGRint flag, void **binData);

  IGRstat (*getTxtAtr)(TGRid *nodeID, TGRmd_env *env, 
		       IGRchar *name, IGRint flag, IGRchar *value);

  IGRstat (*getTxtAtrPtr)(TGRid *nodeID, TGRmd_env *env, 
			  IGRchar *name, IGRint flag, IGRchar **value);

  IGRstat (*setTxtAtr)(TGRid *nodeID, TGRmd_env *env,
		       IGRchar *name, IGRint flag, IGRchar *value);

  IGRstat (*setBinAtr)(TGRid *nodeID, TGRmd_env *env,
		       IGRchar *name, IGRint flag, 
		       void *binData, void (*binFree)(void *data));

  IGRstat (*getDblAtr)(TGRid *nodeID, TGRmd_env *env, 
		       IGRchar *name, IGRint flag, IGRdouble *value);

  IGRstat (*getFldAtr)(TGRid *nodeID, TGRmd_env *env, 
		       IGRchar *name, IGRint flag, TVDfld *fld);

  void   (*getFldAtrs)(TGRid *nodeID, TGRmd_env *env, 
		       IGRint flag, IGRint *cnt, TVDfld *flds);

  void (*deleteNode)(TGRid *nodeID);
  void (*createNode)(TGRid *parentID, IGRchar *type, IGRchar *name, TGRid *nodeID);

  void (*saveTreeToXmlBuf) (TGRid *treeID, IGRchar **buf);
  void (*saveTreeToXmlFile)(TGRid *treeID, IGRchar  *fileName);

  void (*printLog)(TGRid *nodeID, IGRint type, IGRint stdOutFlag);
  
  // Connections
  IGRstat (*getNthTreeChild)(TGRid *nodeID, IGRint nth, TGRid *childID);
  IGRstat (*getTreeParent)  (TGRid *nodeID, TGRid *parentID);

  IGRstat (*getNthMgrChild)(TGRid *nodeID, IGRint nth, TGRid *childID);
  IGRstat (*getMgrParent)  (TGRid *nodeID, TGRid *parentID);

  void (*getTree) (TGRid *nodeID, TGRid *treeID);
  void (*getSet)  (TGRid *nodeID, TGRid *setID);

  // Model stuff
  void (*getModelObject)(TGRid *nodeID, TGRobj_env *modelOE);

  // Helper functions
  void (*computeDate)(struct TVDctxCP *cp, TGRid *nodeID, IGRchar *name);
  void (*displayNode)(struct TVDctxCP *cp, TGRid *nodeID, enum GRdpmode mode, IGRint flag);

  // Piece oriented functions
  void    (*getPieceType) (TGRid *nodeID, IGRchar *pieceType);

  void    (*getPieceMark) (TGRid *nodeID, IGRchar *pieceMark);
  void    (*setPieceMark) (TGRid *nodeID, IGRchar *pieceMark);

  void    (*getPieceStage)(TGRid *nodeID, IGRchar *pieceStage);

  // Node functions
  void    (*getNodeType)(TGRid *nodeID, IGRchar *nodeType);
  void    (*getNodeName)(TGRid *nodeID, IGRchar *nodeName);
  IGRstat ( *isNodeType)(TGRid *nodeID, IGRchar *nodeType);

  void    (*getCompName)(TGRid *nodeID, IGRchar *compName);
  void    (*getCompPath)(TGRid *nodeID, IGRchar *compPath);
  
} TVDctxCP;

/* ---------------------------------------------
 * For global direct access to class pointers
 */
extern TVDctxCP *VDctxGetBaseCP __(());
//extern TVDctxCP *VDctxGetDomCP  __(());
extern TVDctxCP *VDctxGetCt1CP  __(());
extern TVDctxCP *VDctxGetAtCP   __(());
extern TVDctxCP *VDctxGetOmCP   __(());
// extern TVDctxCP *VDctxGetCdomCP __(());
extern TVDctxCP *VDctxGetXdomCP __(());

/* ---------------------------------------------
/* Various initialization routines 
 */
extern IGRstat VDctxInitBaseCP __((TVDctxCP *baseCP));
// extern IGRstat VDctxInitDomCP  __((TVDctxCP *baseCP, TVDctxCP *cp));
extern IGRstat VDctxInitCt1CP  __((TVDctxCP *baseCP, TVDctxCP *cp));
extern IGRstat VDctxInitAtCP   __((TVDctxCP *baseCP, TVDctxCP *cp));
extern IGRstat VDctxInitOmCP   __((TVDctxCP *baseCP, TVDctxCP *cp));
// extern IGRstat VDctxInitCdomCP __((TVDctxCP *baseCP, TVDctxCP *cp));
extern IGRstat VDctxInitXdomCP __((TVDctxCP *baseCP, TVDctxCP *cp));

/* ------------------------- */
#if defined(__cplusplus)
}
#endif

#endif
