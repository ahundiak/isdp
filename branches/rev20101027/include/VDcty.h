/* $Id: VDcty.h,v 1.1 2001/01/14 16:11:38 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDcty.h
 *
 * Description: Generic tree objects
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDcty.h,v $
 *      Revision 1.1  2001/01/14 16:11:38  art
 *      sp merge
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/12/00  ah      Created
 ***************************************************************************/

#ifndef VDcty_include
#define VDcty_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#ifndef   VDfld_include
#include "VDfld.h"
#endif

/* ----------------------------------------------------------
 * C++
 */
#if defined(__cplusplus)
extern "C" {
#endif

/* ---------------------------------------------
 * Available trees
 */
#define VDCTY_CLASSN_BASE_TREE      "BaseTree"
#define VDCTY_CLASSI_BASE_TREE      0
#define VDCTY_CLASSN_PLOT_TREE      "PlotTree"
#define VDCTY_CLASSI_PLOT_TREE      1
#define VDCTY_CLASSN_PROD_TREE      "ProdTree"
#define VDCTY_CLASSI_PROD_TREE      2
#define VDCTY_CLASSN_STD_PARTS_TREE "StdParts"
#define VDCTY_CLASSI_STD_PARTS_TREE 3
#define VDCTY_CLASSN_STD_ASSYS_TREE "StdAssys"
#define VDCTY_CLASSI_STD_ASSYS_TREE 4
#define VDCTY_CLASSN_PAL_ASSYS_TREE "PalAssys"
#define VDCTY_CLASSI_PAL_ASSYS_TREE 5
#define VDCTY_CLASSN_ENG_TREE       "EngTree"
#define VDCTY_CLASSI_ENG_TREE       6
#define VDCTY_CLASSN_OUTFIT_TREE    "OutfitTree"
#define VDCTY_CLASSI_OUTFIT_TREE    7
#define VDCTY_CLASSN_ELEC2D_TREE    "Elec2dTree"
#define VDCTY_CLASSI_ELEC2D_TREE    8
#define VDCTY_CLASSN_ELEC3D_TREE    "Elec3dTree"
#define VDCTY_CLASSI_ELEC3D_TREE    9
#define VDCTY_CLASSN_STAGING_TREE   "StagingTree"
#define VDCTY_CLASSI_STAGING_TREE   10

/* ----------------------------------------------------------
 * Info about an attribute
 */
typedef struct 
{
  IGRchar  name[VDFLD_MAX_NAME];
  IGRint   type;
  IGRint   len;
  IGRchar  base[VDFLD_MAX_NAME];
  IGRchar  desc[VDFLD_MAX_TXT];
  IGRchar  defaultValue[72];  /* PPL Routine         */
  IGRchar  pickList   [256];  /* PPL Routine or list */
  IGRchar  validate    [72];  /* PPL Routine         */
} TVDctyAttrInfo;

/* ----------------------------------------------------------
 * Info about a node type
 */
typedef struct
{
  IGRchar type [16];
  IGRchar desc [34];
  IGRchar level[ 4];
  IGRchar table[20];
} TVDctyNodeTypeInfo;

/* ----------------------------------------------------------
 * Info about a set type
 */
typedef struct
{
  IGRchar type[16];
  IGRchar rev [ 4];
  IGRchar desc[34];
  IGRchar nodeTable[20];
  IGRchar leafTable[20];
  IGRint  nth;
  IGRint  flag;
} TVDctySetTypeInfo;

/* ----------------------------------------------------------
 * Somewhat specialized user information
 */
typedef struct 
{
  TGRobj_env   objOE;
  TGRid        windowID;
  TGRsymbology symb;
} TVDctyUserInfo;

/* ---------------------------------------------
 * Main class pointer structure
 */
typedef struct TVDctyTP
{
  struct TVDctyTP *parentTP;

  TGRid  schemaID;
  
  void    (*getSetTypeInfo)(struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
			    TVDctySetTypeInfo *info);

  IGRstat (*getNodeAttrName)(struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
			     IGRchar *nodeType, IGRint nth, IGRchar *attrName);
  
  void    (*getNodeAttrInfo)(struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, 
			   IGRchar *name, TVDctyAttrInfo *attrInfo);

  IGRstat (*getNodeTypeInfo)(struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
			     IGRint nth, IGRint *cnt, TVDctyNodeTypeInfo *info);

  IGRstat (*validateAttrValue)(struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
			       IGRchar  *attrName,
			       IGRchar  *attrValue,
			       IGRchar  *attrValuex,
			       IGRchar  *msg);

  IGRstat (*setNodeUserInfo)(struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
			     TVDctyUserInfo *info);

  IGRstat (*getGadgetText)(struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
			   IGRchar  *formName,
			   IGRint    gadget,
			   IGRint    nth,
			   IGRchar  *txt);

  IGRstat (*getNodeNameForModelObject)(struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
				       TGRobj_env    *modelOE,
				       IGRchar       *nodeName);

  IGRstat (*getNodeTypeForModelObject)(struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
				       TGRobj_env    *modelOE,
				       IGRchar       *nodeType);
  
  IGRstat (*isModelObjectValid)(struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
				TGRobj_env *modelOE);


  IGRstat (*isChildTypeValid)(struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
			      IGRchar  *parentType,
			      IGRchar  *childType);

  void (*getFilter)(struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, 
		    OM_S_CLASSLIST *classList);

  IGRstat (*getValidCommCode)(struct TVDctyTP *tp, TVDctxCP *cp, TGRid *parentID,
			      TVDctxBaseInfo *baseInfo,
			      IGRchar        *commCode);
  

  IGRstat (*isCommCodeValid)(struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, 
			     IGRchar *commCode);
  
  void (*getCommCode)(struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
		      IGRchar  *commCode);
  

  void (*getCageNum)(struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
		     IGRchar  *cageNum);

  void (*getHighestRev)(struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, IGRint *highestRev);

  void (*setStatus) (struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, IGRchar *value);
  void (*setAttrRev)(struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, IGRchar *value);
  
  void (*setAttrNodeCount)(struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, IGRchar *value);

  
  IGRstat (*computeNodeModel)(struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID);  
  IGRstat (*computeNode)     (struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID);  
  IGRstat (*isReviseOK)      (struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID);
  IGRstat (*isFreezeOK)      (struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID);
  
  void (*preExpandContractNode)(struct TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, IGRchar *op);
    
} TVDctyTP;

/* -----------------------------------------------
 * vdcty/base/VDctyMgr.c
 */
extern TVDctyTP *VDctyGetNthTP        __((IGRint nth));
extern TVDctyTP *VDctyGetTreeTypeTP   __((IGRchar  *treeType));
extern TVDctyTP *VDctyGetNodeTP       __((TVDctxCP *cp, TGRid *nodeID));
extern TVDctyTP *VDctyGetNthTP_ForApp __((IGRint app, IGRint nth));

/* -----------------------------------------------
 * Various init routines
 */
extern IGRstat VDctyInitBaseTP     __((TVDctyTP *tp));
extern IGRstat VDctyInitProdTP     __((TVDctyTP *tpb, TVDctyTP *tp));
extern IGRstat VDctyInitPlotTP     __((TVDctyTP *tpb, TVDctyTP *tp));
extern IGRstat VDctyInitStagingTP  __((TVDctyTP *tpb, TVDctyTP *tp));
extern IGRstat VDctyInitStdPartsTP __((TVDctyTP *tpb, TVDctyTP *tp));

extern IGRstat VDctyGetNodeAttrName __((TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
					IGRchar *nodeType, IGRint nth, IGRchar *attrName));

extern IGRstat VDctyGetNodeTypeInfo __((TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
					IGRint nth, IGRint *cnt, TVDctyNodeTypeInfo *info));

extern void    VDctyGetSetTypeInfo __((TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
				       TVDctySetTypeInfo *info));

extern void    VDctyGetNodeAttrInfo __((TVDctyTP *tp,  TVDctxCP *cp, TGRid *nodeID, 
					IGRchar *name, TVDctyAttrInfo *attrInfo));

extern IGRstat VDctyValidateAttrValue __((TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
					  IGRchar  *attrName,
					  IGRchar  *attrValue,
					  IGRchar  *attrValuex,
					  IGRchar  *msg));

extern   IGRstat VDctySetNodeUserInfo __((TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
					  TVDctyUserInfo *info));

extern   IGRstat VDctyGetGadgetText __((TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
					IGRchar  *formName,
					IGRint    gadget,
					IGRint    nth,
					IGRchar  *txt));

extern   IGRstat VDctyGetNodeNameForModelObject __((TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
						    TGRobj_env    *modelOE,
						    IGRchar       *nodeName));

extern   IGRstat VDctyGetNodeTypeForModelObject __((TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
						    TGRobj_env    *modelOE,
						    IGRchar       *nodeType));
  
extern   IGRstat VDctyIsModelObjectValid __((TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
					     TGRobj_env *modelOE));


extern   IGRstat VDctyIsChildTypeValid __((TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
					   IGRchar  *parentType,
					   IGRchar  *childType));

extern   void VDctyGetFilter __((TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, 
				 OM_S_CLASSLIST *classList));

extern IGRstat VDctyGetValidCommCode __((TVDctyTP *tp, TVDctxCP *cp, TGRid *parentID,
					 TVDctxBaseInfo *baseInfo,
					 IGRchar        *commCode));

extern IGRstat VDctyIsCommCodeValid  __((TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, 
					 IGRchar *commCode));

extern void VDctyGetCommCode __((TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, IGRchar *commCode));
extern void VDctyGetCageNum  __((TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, IGRchar *cageNum));

extern void VDctySetStatus        __((TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, IGRchar *value));
extern void VDctySetAttrNodeCount __((TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, IGRchar *value));
extern void VDctySetAttrRev       __((TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, IGRchar *value));

extern void VDctyGetHighestRev    __((TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, IGRint *highestRev));

extern IGRstat VDctyComputeNodeModel __((TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID));
extern IGRstat VDctyComputeNode      __((TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID));
extern IGRstat VDctyIsReviseOK       __((TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID));
extern IGRstat VDctyIsFreezeOK       __((TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID));

extern void VDctyPreExpandContractNode __((TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, IGRchar *op));

/* -----------------------------------------------
 * vdcty/base/VDctyMisc.c
 */
extern void VDctySetAttrInfo __((IGRchar *name,
				 IGRint   type,
				 IGRchar *base,
				 IGRchar *desc,
				 TVDctyAttrInfo *info));

extern IGRstat VDctyEngTreeGetAttrInfo __((IGRchar        *name, 
					   TVDctyAttrInfo *info));

/* ------------------------- */
#if defined(__cplusplus)
}
#endif

#endif



