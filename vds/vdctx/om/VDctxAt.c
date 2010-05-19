/* $Id: VDctxAt.c,v 1.10 2001/11/09 14:44:40 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdctx/c/VDctxCt1.c
 *
 * Description: Context Classes
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctxAt.c,v $
 *      Revision 1.10  2001/11/09 14:44:40  ahundiak
 *      ah
 *
 *      Revision 1.9  2001/09/18 14:01:28  ahundiak
 *      ah
 *
 *      Revision 1.8  2001/06/03 14:47:30  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/04/06 12:42:49  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/04/03 16:46:11  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/03/18 22:40:28  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/03/13 00:18:31  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/26 15:46:34  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/02/22 23:53:06  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/02/17 14:21:29  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/01/14 16:09:04  art
 *      sp merge
 *
 * Revision 1.1  2000/12/06  15:01:08  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/12/00  ah      Creation
 * 04/03/01  ah      Pass on attribute requests to ACgive_struct
 * 09/18/01  ah      Internal calls not initializing results
 * 11/08/01  ah      Changed double to text routine
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDctxPrivate.h"
#include "VDctx.h"
#include "VDat.h"
#include "VDss.h"

VDASSERT_FFN("vdctx/c/VDctxAt.c");

/* -----------------------------------------------
 * Copy VDatFld to VDfld structure
 */
static void cpAtFldToFld(TVDatFld *fldx, TVDfld *fld)
{
  IGRchar *value;
  IGRchar *p;
  
  // Xfer
  fld->type = fldx->type;
  strcpy(fld->name,fldx->name);

  value = fld->val.txt;
  
  switch(fldx->type) {

    case VDAT_FLD_TYPE_CHAR:
      strcpy(value,fldx->valueTxt);
      break;

    case VDAT_FLD_TYPE_DOUBLE:

      VDcnvDblToTxt(fldx->valueDbl,value);
      
      /* -----------------------------------------
       * This matches the routine in xml but 
       * really need a global double to string
       * routine.
       */
#if 0
      sprintf(value,"%f",fldx->valueDbl);
      for(p = value + strlen(value) - 1; (p >= value) && (*p == '0'); p--);
      if (p < value) strcpy(value,"0.0");
      else {
	if (*p == '.') strcpy(p,".0");
	else *(p+1) = 0;
      }
#endif
      break;

    case VDAT_FLD_TYPE_INT:
      sprintf(value,"%d",fldx->valueInt); 
      break;
  }

wrapup:
  return;
}

/* -----------------------------------------------
 * Text Attribute
 */
static IGRstat getFldAtr(TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name, 
			 IGRint     privatE,
			 TVDfld    *fld)
{
  VDASSERT_FN("getFldAtr");
  IGRstat retFlag = 0;
  
  TVDatFld fldx;
  IGRchar *value;

  // Init
  memset(fld,0,sizeof(TVDfld));
  
  // Get it
  VDatFldGetAttrByName(nodeID, name, &fldx);
  if (*fldx.name == 0) goto wrapup;

  // Xfer
  cpAtFldToFld(&fldx,fld);
    
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Text Attribute
 *
 * Still not as completely implemented as it should be
 * No smart attribute processing though it does get
 * the computed attributes
 *
 * Need to bit the bullet and send it ACgive_struct
 * Merge and clean the code from the OM file
 */
static IGRstat getTxtAtr(TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name, 
			 IGRint     privatE,
			 IGRchar   *value)
{
  VDASSERT_FN("getTxtAtr");
  IGRstat retFlag = 0;

  TVDfld  fld;

  Tret_struct rs;
  
  // Init
  *value = 0;
  
  // Get it
  retFlag = getFldAtr(nodeID,env,name,privatE,&fld);
  if (retFlag) {
    strcpy(value,fld.val.txt);
    goto wrapup;
  }
  
  // Might be a computed attribute
  retFlag = VDatGetStruct(nodeID,name,&rs);  
  if (retFlag) {
    strcpy(value,rs.var.text_st.text_string);
    goto wrapup;
  }
  
wrapup:
  if (traceFlag) printf(">>> %s %s %s %s %d\n",ffn(),fn,name,value,retFlag);
  return retFlag;
}

/* -----------------------------------------------
 * Text Attribute
 */
static IGRstat setTxtAtr(TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name, 
			 IGRint     privatE,
			 IGRchar   *value)
{
  VDASSERT_FN("setTxtAtr");
  IGRstat retFlag = 1;

  TVDfld  fld;

  // Easy
  VDatFldSetTxt(&fld,name,value);
  VDatFldUpdAllAttrs(nodeID,&fld,1);
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Double Attribute
 */
static IGRstat getDblAtr(TGRid     *nodeID, 
			 TGRmd_env *env, 
			 IGRchar   *name, 
			 IGRint     privatE,
			 IGRdouble *value)
{
  VDASSERT_FN("getDblAtr");
  IGRstat retFlag = 0;
  
  TVDfld fld;
  
  // Init
  *value = 0.0;
  
  // Get it
  retFlag = getFldAtr(nodeID,env,name,privatE,&fld);
  if (retFlag) {
    *value = atof(fld.val.txt);
  }

wrapup:
  return retFlag;
}


/* -----------------------------------------------
 * Field attributes
 */
static void getFldAtrs(TGRid     *nodeID, 
		       TGRmd_env *env,  
		       IGRint     privatE,
		       IGRint    *cnt,
		       TVDfld    *flds)
{
  VDASSERT_FN("getFldAtr");
  
  TVDatFld fldsx[256];
  IGRint   i;
  
  // Init
  *cnt = 0;
  
  // Get Them
  VDatFldGetAllAttrs(nodeID,fldsx,cnt);
  
  // Convert
  for(i = 0; i < *cnt; i++) {
    cpAtFldToFld(&fldsx[i],&flds[i]);
  }
  
wrapup:
  return;
}
/* --------------------------------------------------
 * Component name and path
 */
static void getCompPath(TGRid *nodeID, IGRchar *path)
{ 
  *path = 0;
  getTxtAtr(nodeID,NULL,VDCTX_ATR_COMP_PATH,0,path);
  
  // Done
  return;
}

static void getCompName(TGRid *nodeID, IGRchar *name)
{ 
  IGRchab buf;
  IGRchar *p;

  *name = 0;
  getCompPath(nodeID,buf);  
  p = strrchr(buf,':');
  if (p) p++;
  else   p = buf;
  strcpy(name,p);
  
  // Done
  return;
}
static void getPieceMark(TGRid *nodeID, IGRchar *pcmk)
{ 
  *pcmk = 0;
  getTxtAtr(nodeID,NULL,VDCTX_ATR_AT_ST_PCMK,0,pcmk);
  
  // Done
  return;
}
static void setPieceMark(TGRid *nodeID, IGRchar *pcmk)
{ 
  
  setTxtAtr(nodeID,NULL,VDCTX_ATR_AT_ST_PCMK,0,pcmk);
  
  // Done
  return;
}


static void getNodeName(TGRid *nodeID, IGRchar *nodeName)
{
  *nodeName = 0;
  VDatGetNodeName(nodeID,nodeName);
  return;
}

/* -------------------------------------------------------
 * Enhance a bit such that sets and other misc objects return
 * a type
 */
static void getNodeType(TGRid *nodeID, IGRchar *nodeType)
{
  IGRint type;
  
  // Init
  *nodeType = 0;
  
  // Different objects handled
  VDatGetBaseType(nodeID,&type);

  switch(type) {

    case VDAT_CLASSI_SET:
      strcpy(nodeType,VDAT_CLASSN_SET);
      break;

    case VDAT_CLASSI_LEAFS:
      strcpy(nodeType,VDAT_CLASSN_LEAFS);
      break;
    case VDAT_CLASSI_PLATES:
      strcpy(nodeType,VDAT_CLASSN_PLATES);
      break;
    case VDAT_CLASSI_BEAMS:
      strcpy(nodeType,VDAT_CLASSN_BEAMS);
      break;
    case VDAT_CLASSI_OTHERS:
      strcpy(nodeType,VDAT_CLASSN_OTHERS);
      break;
    case VDAT_CLASSI_TREES:
      strcpy(nodeType,VDAT_CLASSN_TREES);
      break;
      
    default:

      // Standard way using rdb objects
      VDatGetNodeType(nodeID,nodeType);
  }
  
  return;
}

static IGRstat isNodeType(TGRid *nodeID, IGRchar *nodeType)
{
  IGRstat retFlag = 0;
  
  IGRchar nodeTypex[80];
  
  getNodeType(nodeID,nodeTypex);
  if (!strcmp(nodeType,nodeTypex)) retFlag = 1;
  
  return retFlag;
}

/* -----------------------------------------------
 * Base Information
 * Should a set return nodeType and nodeName?
 */
static IGRstat getBaseInfo(TGRid *nodeID, TVDctxBaseInfo *baseInfo)
{
  VDASSERT_FN("getBaseInfo");
  IGRstat retFlag = 0;

  memset(baseInfo,0,sizeof(TVDctxBaseInfo));
  
  VDatGetSetType(nodeID,baseInfo->setType);
  VDatGetSetName(nodeID,baseInfo->setName);

  getNodeType(nodeID,baseInfo->nodeType);
  getNodeName(nodeID,baseInfo->nodeName);
  
  // Done
  retFlag = 1;

wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Get the nth child
 * For VDat Trees, stop at the actual LEAF object
 * Do not go onto the model object
 *
 * May want to adjust this later
 *
 * VDatGetChildObject actually returns the ACpretend object so
 * if the model object is desired then do a GetModelObject
 */
static  IGRstat getNthTreeChild(TGRid *nodeID, IGRint nth, TGRid *childID)
{
  IGRint type;

  childID->objid = NULL_OBJID;
  
  VDatGetBaseType(nodeID,&type);

  if (type == VDAT_CLASSI_LEAF) return 0;
  
  return VDatGetChildObject(nodeID,nth,childID);
}

static  IGRstat getNthMgrChild(TGRid *nodeID, IGRint nth, TGRid *childID)
{
  TGRid setsID;
  TGRid  setID;
  TGRid treeID;

  // Init
  childID->objid = NULL_OBJID;

  // Grab the list of sets
  VDatGetSets(nodeID,&setsID);

  // Get the nth set
  VDatGetChildObject(&setsID,nth,&setID);
  if (setID.objid == NULL_OBJID) return 0;
  
  // Grab the tree from the set
  VDatGetTree(&setID,&treeID);
  if (treeID.objid == NULL_OBJID) return 0;

  *childID = treeID;
  return 1;
  
}

/* -----------------------------------------------
 * Get the parent
 */
static IGRstat getTreeParent(TGRid *nodeID, TGRid *parentID)
{
  parentID->objid = NULL_OBJID;
  return VDatGetParentNode(nodeID,parentID);
}

/* -----------------------------------------------
 * I think this will be ok, need to see why it's important
 * To get the manager's parent
 *
 * Probably should skip the SETS object
 * But really would like to skip the set object as well
 */
static  IGRstat getMgrParent(TGRid *nodeID, TGRid *parentID)
{
  parentID->objid = NULL_OBJID;
  return VDatGetParentObject(nodeID,0,parentID);
}

/* -----------------------------------------------
 * Get the tree object by recursing up
 */
static void getTree(TGRid *nodeID, TGRid *treeID)
{
  treeID->objid = NULL_OBJID;
  VDatGetTree(nodeID,treeID);
  return;
}

/* -----------------------------------------------
 * Not going to implement this guy
 * Try to remove all sets from the complete process
 */
#if 0
/* -----------------------------------------------
 * Get the set object by recursing up
 */
static void getSet(TGRid *nodeID, TGRid *setID)
{
  VDASSERT_FN("getSet");
  
  TGRid   treeID;
  IGRlong type;
  
  // Might be asking a set for a set
  VDclaGetTypeFlag(NULL,nodeID,NULL_OBJID,NULL_OSNUM,&type,NULL);
  if (type ==VDCT1_CLASS_TYPE_SET) {
    
    // Need to get the manager child
    *setID = *nodeID;
    goto wrapup;
    
  }

  // Get the tree
  getTree(nodeID,&treeID);
  VDASSERTW(treeID.objid != NULL_OBJID);
  
  // Get the manager parent
  getMgrParent(nodeID,setID);
  
  // Done
 wrapup:
  return;
}
#endif

/* ----------------------------------------------------------------------
 * Get the model attached to the node
 */ 
static void getModelObject(TGRid *nodeID, TGRobj_env *modelOE)
{
  VDASSERT_FN("getModelObject");

  modelOE->obj_id.objid = NULL_OBJID;
    
  VDatGetLeafObject(nodeID,modelOE);
  return;
  
}

/* -----------------------------------------------
 * Initializer
 */
IGRstat VDctxInitAtCP(TVDctxCP *baseCP, TVDctxCP *cp)
{
  VDASSERT_FN("VDctxInitAtCP");
  IGRstat retFlag = 0;

  // Arg check
  VDASSERTW(cp);

  // Copy Base
  memcpy(cp,baseCP,sizeof(TVDctxCP));
  cp->parentCP = baseCP;
  
  // Xfer overrode functions
  cp->setTxtAtr  = setTxtAtr;
  cp->getTxtAtr  = getTxtAtr;
  cp->getDblAtr  = getDblAtr;
  cp->getFldAtr  = getFldAtr;
  cp->getFldAtrs = getFldAtrs;

  cp->getBaseInfo   = getBaseInfo;
  cp->getNodeName   = getNodeName;
  cp->getNodeType   = getNodeType;
  cp->isNodeType    = isNodeType;

  cp->getNthTreeChild = getNthTreeChild;
  cp->getTreeParent   = getTreeParent;

  cp->getNthMgrChild  = getNthMgrChild;
  cp->getMgrParent    = getMgrParent;
  
  cp->getTree         = getTree;
  cp->getModelObject  = getModelObject;

  cp->getCompName  = getCompName;
  cp->getCompPath  = getCompPath;

  cp->getPieceMark = getPieceMark;
  cp->setPieceMark = setPieceMark;
  
#if 0
  cp->get = get;
#endif

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

