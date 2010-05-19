/* $Id: VDctyPlot.c,v 1.2 2001/02/17 14:24:12 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdctx/c/VDctyBase.c
 *
 * Description: Base Tree Class
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctyPlot.c,v $
 *      Revision 1.2  2001/02/17 14:24:12  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/01/14 16:00:47  art
 *      sp merge
 *
 * Revision 1.1  2000/12/06  15:01:08  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/12/00  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDos.h"
#include "VDobj2.h"

#include "VDctx.h"
#include "VDcty.h"

#include "VDct1Plot.h"
#include "VDct1Forms.h"

VDASSERT_FFN("vdcty/base/VDctyPlot.c");

#define MY_TREE VDCTY_CLASSN_PLOT_TREE

/* ------------------------------------------------------
 * Validates, and cleans attribute values
 */
static IGRstat validateAttrValue(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
				 IGRchar  *attrName,
				 IGRchar  *attrValue,
				 IGRchar  *attrValuex,
				 IGRchar  *msg)
{
  VDASSERT_FN("validateAttrValue");
  
  IGRstat retFlag = 0;
  IGRstat sts;
    
  // copy attrValue into attrValuex
  strcpy(attrValuex,attrValue);

  // upper case it
  if (strcmp(attrName,VDCT1_PLOT_ATTR_NAME_WINDOW)) strupr(attrValuex);

  // done
  retFlag = 1;
  
 wrapup:  
  return retFlag;
}

/* --------------------------------------------------------
 * Set user information at creation of node
 */
static IGRstat setNodeUserInfo(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
			       TVDctyUserInfo *info)
{
  VDASSERT_FN("setNodeUserInfo");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar windowName[1024];
  
  // plot tree needs the windowName
  // VDobjGetName(NULL,&info->windowID,windowName);
  
  VDctxSetTxtAtrID(cp,nodeID,VDCT1_PLOT_ATTR_NAME_WINDOW,windowName);

  if (traceFlag) printf("Window name '%s'\n",windowName);

  // done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Returns value for form gadget
 * Every time we get a new parent,
 * this will get called.
 */
static IGRstat getGadgetText(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
			     IGRchar  *formName,
			     IGRint    gadget,
			     IGRint    nth,
			     IGRchar  *txt)
{
  VDASSERT_FN("getGadgetText");

  IGRstat        retFlag = 0;
  TVDctxBaseInfo baseInfo;

  TVDctyTP *tpx;
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  // Need baseInfo
  VDctxGetBaseInfoCP(cp,nodeID,&baseInfo);

  // Node Form
  if (!strcmp(formName,VDCT_FORM_NODE_F_NAME)) {
    
    switch(gadget) {
    case VDCT_FORM_NODE_G_DOIT:
      
      retFlag = 1;
      
      switch(nth) {
	case 0: strcpy(txt,"1 Review  Node");       break;
	case 1: strcpy(txt,"2 Create  Node");       break;
	case 2: strcpy(txt,"3 Create  Sheet Node"); break;
	case 3: strcpy(txt,"D Delete  Node");       break;
	case 4: strcpy(txt,"R Rename  Node");       break;
	case 5: strcpy(txt,"M Move    Node");       break;
	default: retFlag = 0;
      }
      goto wrapup;
      
    }
  }
  
  // Try ancestor
  tpx = (VDctyGetTreeTypeTP(MY_TREE))->parentTP;
  if (tpx->getGadgetText) {  
    retFlag = tpx->getGadgetText(tpx,cp,nodeID,formName,gadget,nth,txt);
  }
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Sheet node name, just use typed in value
 */
static IGRstat getNodeNameForModelObject(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
					 TGRobj_env    *modelOE,
					 IGRchar       *nodeName)
{
  VDASSERT_FN("getNodeNameForModelObject");
  
  IGRstat retFlag = 0;

  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* --------------------------------------------------
 * get the node type for the model object,
 */ 
static IGRstat getNodeTypeForModelObject(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
				     TGRobj_env    *modelOE,
				     IGRchar       *nodeType)
{
  VDASSERT_FN("getNodeTypeForModelObject");
  
  IGRstat retFlag = 0;

  strcpy(nodeType,VDCT1_PLOT_NODE_TYPE_SHEET);
  
  retFlag = 1;
   
wrapup:  
  
  return retFlag;
}

/* -------------------------------------------------------
 * Can we add this object
 */
static IGRstat isModelObjectValid(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
				  TGRobj_env *modelOE)
{
  VDASSERT_FN("isModelObjectValid");
  
  IGRstat      retFlag = 0;
  IGRstat      sts;
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* --------------------------------------------------
 * Validate child type
 */
static IGRstat isChildTypeValid(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
				IGRchar  *parentType,
				IGRchar  *childType)
{
  VDASSERT_FN("isChildTypeValid");
  IGRstat retFlag = 0;
  
  // Say hi
  if (traceFlag) {
    printf(">>> %s %s %s %s\n",ffn(),fn,parentType,childType);
  }
  
  // OK By default
  retFlag = 1;
  
  // DRAWINGS can have DRAWING
  if(!strcmp( parentType,VDCT1_PLOT_NODE_TYPE_DRAWINGS)) {
    if(!strcmp(childType,VDCT1_PLOT_NODE_TYPE_DRAWING)) goto wrapup;
  }

  // DRAWING can have SHEET
  if(!strcmp( parentType,VDCT1_PLOT_NODE_TYPE_DRAWING)) {
    if(!strcmp(childType,VDCT1_PLOT_NODE_TYPE_SHEET)) goto wrapup;
  }
  
  // Not ok
  retFlag = 0;
  
wrapup:
  if (traceFlag) {
    printf(">>> %s %s %d\n",ffn(),fn,retFlag);
  }

  return retFlag;
}

#if 0
/* -------------------------------------------------
 * Create a node
 */
static IGRstat createNode(TVDct1JD *parentJD,
			  IGRchar  *nodeType, 
			  IGRchar  *nodeName,
			  TVDct1JD *nodeJD)
{
  VDASSERT_FN("createNode");
  IGRstat retFlag   = 0;

  TVDct1JD parentClassJD;
  
  TGRid *parentID = &parentJD->id;
  TGRid *nodeID   = &nodeJD->id;

  // Arg check
  VDASSERTW(parentJD && parentJD->cl && (parentJD->id.objid != NULL_OBJID));
  parentID = &parentJD->id;
  VDASSERTW(nodeJD);
  nodeID        = &nodeJD->id;
  nodeJD->cl    = parentJD->cl;
  nodeID->objid = NULL_OBJID;
  
  VDASSERTW(nodeType && *nodeType != 0);
  VDASSERTW(nodeName);
  
  // Say Hi
  if (traceFlag) {
    printf(">>> %s %s %s %s\n",ffn(),fn,nodeType,nodeName);
  }

  // Use root node create routine
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  _RTCJDB(&parentClassJD)->createNode(parentJD,nodeType,nodeName,nodeJD);
  VDASSERTW(nodeID->objid != NULL_OBJID);

  // Set nodeName
  VDjt1SetAttr(nodeJD,VDCT1_PLOT_ATTR_NAME_DRAWING_NUMBER,nodeName);
  VDjt1SetAttr(nodeJD,VDCT1_PLOT_ATTR_NAME_SHEET_NUMBER,  nodeName);
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %s %s %d\n",ffn(),fn,nodeType,nodeName,retFlag);
  }
  
  return retFlag;
}
#endif

/* -------------------------------------------------
 * Class filter
 */
static void getFilter(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID, 
		      OM_S_CLASSLIST *classList)
{
  VDASSERT_FN("getFilter");
  
  // Doit
  VDomGetClassIdForClassName("GRvg",&classList->p_classes[0]);
  classList->w_count = 1;
  
wrapup:
  return;
}

/* -------------------------------------------------
 * Individual stage info
 */
static IGRstat getNodeTypeInfo(TVDctyTP *tp,  
			       TVDctxCP *cp, 
			       TGRid    *nodeID,
			       IGRint    nth, 
			       IGRint   *cnt, 
			       TVDctyNodeTypeInfo *info)
{
  VDASSERT_FN("getNodeTypeInfo");
  
  IGRstat retFlag = 0;
  
  // Arg check
  if (cnt) *cnt = 2;  // Set this to total number of nodes

  // Just a switch
  retFlag = 1;
  switch(nth) {

  case 0:
    strcpy(info->type, VDCT1_PLOT_NODE_TYPE_SHEET);
    strcpy(info->desc, "SHEET");
    strcpy(info->level,"U00");
    strcpy(info->table,"");
    goto wrapup;

  case 1:
    strcpy(info->type, VDCT1_PLOT_NODE_TYPE_DRAWING);
    strcpy(info->desc, "DRAWING");
    strcpy(info->level,"S01");
    strcpy(info->table,"");
    goto wrapup;

#if 0
  case 2:
    strcpy(info->type, VDCT1_PLOT_NODE_TYPE_DRAWINGS);
    strcpy(info->desc, "PLOT DRAWINGS");
    strcpy(info->level,"002");
    strcpy(info->table,"");
    goto wrapup;
#endif
  }
  
  // No More
  retFlag = 0;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Nth attribute of a given node
 */
static IGRstat getNodeAttrName(TVDctyTP *tp,  
			       TVDctxCP *cp, 
			       TGRid    *nodeID,
			       IGRchar  *nodeType,
			       IGRint    nth,
			       IGRchar  *attrName)
{ 
  VDASSERT_FN("getNodeAttrName");
  IGRstat retFlag = 0;
  
  // Say hi
  // traceFlag = 1;
  if (traceFlag) {
    printf(">>> %s %s %s %2d\n",ffn(),fn,nodeType,nth);
  }
  retFlag = 1;
  
  // Drawing
  if (!strcmp(nodeType,VDCT1_PLOT_NODE_TYPE_DRAWING)) {
    
    switch(nth) {

    case  0: strcpy(attrName,VDCT1_PLOT_ATTR_NAME_CAGE_CODE);             goto wrapup;
    case  1: strcpy(attrName,VDCT1_PLOT_ATTR_NAME_DRAWING_NUMBER);        goto wrapup;
    case  2: strcpy(attrName,VDCT1_PLOT_ATTR_NAME_DRAWING_REV);           goto wrapup;
    case  3: strcpy(attrName,VDCT1_PLOT_ATTR_NAME_NAVSEA_DRAWING_NUMBER); goto wrapup;
    case  4: strcpy(attrName,VDCT1_PLOT_ATTR_NAME_DRAWING_TITLE);         goto wrapup;
    case  5: strcpy(attrName,VDCT1_PLOT_ATTR_NAME_DRAWING_TYPE);          goto wrapup;
    case  6: strcpy(attrName,VDCT1_PLOT_ATTR_NAME_DRAWING_DATE);          goto wrapup;
    case  7: strcpy(attrName,VDCT1_PLOT_ATTR_NAME_SHEET_SIZE);            goto wrapup;
    case  8: strcpy(attrName,VDCT1_PLOT_ATTR_NAME_TEAM);                  goto wrapup;
    case  9: strcpy(attrName,VDCT1_PLOT_ATTR_NAME_POSTING_DATE);          goto wrapup;
    case 10: strcpy(attrName,VDCT1_PLOT_ATTR_NAME_OBID );                 goto wrapup; 
    case 11: strcpy(attrName,VDCT1_PLOT_ATTR_NAME_AUTHORIZE_FOR);         goto wrapup;
    case 12: strcpy(attrName,VDCT1_PLOT_ATTR_NAME_PREVIOUS_REV);          goto wrapup; 
    }
  }

  if (!strcmp(nodeType,VDCT1_PLOT_NODE_TYPE_SHEET)) {
    
    switch(nth) {
      
    case  0: strcpy(attrName,VDCT1_PLOT_ATTR_NAME_SHEET_NUMBER);        goto wrapup;
    case  1: strcpy(attrName,VDCT1_PLOT_ATTR_NAME_SHEET_NAME);          goto wrapup;
    case  2: strcpy(attrName,VDCT1_PLOT_ATTR_NAME_SHEET_DESCRIPTION);   goto wrapup;
    case  3: strcpy(attrName,VDCT1_PLOT_ATTR_NAME_REGISTRATION_STATUS); goto wrapup;
    case  4: strcpy(attrName,VDCT1_PLOT_ATTR_NAME_REGISTRATION_DATE);   goto wrapup;
    case  5: strcpy(attrName,VDCT1_PLOT_ATTR_NAME_OBID);                goto wrapup;
    case  6: strcpy(attrName,VDCT1_PLOT_ATTR_NAME_WINDOW);              goto wrapup;
    case  7: strcpy(attrName,VDCT1_PLOT_ATTR_NAME_DRAWING_REV);         goto wrapup;
    }
  }
  
  // Not found
  retFlag = 0;
    
wrapup:
  if (traceFlag) {
    printf("<<< %s %s %s\n",ffn(),fn,attrName);
  }
  return retFlag;
}

/* -----------------------------------------------
 * Should not get here
 */
static void getNodeAttrInfo(TVDctyTP *tp,  
			    TVDctxCP *cp, 
			    TGRid    *nodeID, 
			    IGRchar  *name, 
			    TVDctyAttrInfo *info)
{
  VDASSERT_FN("getNodeAttrInfo");

  // Just compares
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_CAGE_CODE)) {
    VDctySetAttrInfo(name,5,"CAGE CODE","CAGE CODE",info);
    goto wrapup;
  }

  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_DRAWING_NUMBER)) {
    VDctySetAttrInfo(name,20,"DRAWING NUMBER","DRAWING NUMBER",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_DRAWING_REV)) {
    VDctySetAttrInfo(name,20,"DRAWING REV","DRAWING REVISION",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_NAVSEA_DRAWING_NUMBER)) {
    VDctySetAttrInfo(name,20,"NAVSEA DRAWING NUMBER","NAVSEA DRAWING NUMBER",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_DRAWING_TITLE)) {
    VDctySetAttrInfo(name,40,"DRAWING TITLE","DRAWING TITLE",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_DRAWING_TYPE)) {
    VDctySetAttrInfo(name,20,"DRAWING TYPE","DRAWING TYPE",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_DRAWING_DATE)) {
    VDctySetAttrInfo(name,20,"DRAWING DATE","DRAWING DATE",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_SHEET_SIZE)) {
    VDctySetAttrInfo(name,20,"SHEET SIZE","SHEET SIZE",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_TEAM)) {
    VDctySetAttrInfo(name,20,"TEAM","TEAM",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_POSTING_DATE)) {
    VDctySetAttrInfo(name,20,"POSTING DATE","POSTING DATE",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_OBID)) {
    VDctySetAttrInfo(name,40,"OBID","OBID",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_SHEET_NUMBER)) {
    VDctySetAttrInfo(name,20,"SHEET NUMBER","SHEET NUMBER",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_SHEET_NAME)) {
    VDctySetAttrInfo(name,20,"SHEET NAME","SHEET NAME",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_SHEET_DESCRIPTION)) {
    VDctySetAttrInfo(name,60,"SHEET DESCRIPTION","SHEET DESCRIPTION",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_REGISTRATION_STATUS)) {
    VDctySetAttrInfo(name,20,"REGISTRATION STATUS","REGISTRATION STATUS",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_REGISTRATION_DATE)) {
    VDctySetAttrInfo(name,20,"REGISTRATION DATE","REGISTRATION DATE",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_WINDOW)) {
    VDctySetAttrInfo(name,24,"WINDOW","WINDOW NAME",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_AUTHORIZE_FOR)) {
    VDctySetAttrInfo(name,30,"AUTHORIZE FOR","AUTHORIZE FOR",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_PREVIOUS_REV)) {
    VDctySetAttrInfo(name,20,"PREVIOUS REVISION","PREVIOUS REVISION",info);
    goto wrapup;
  }

  // Not found

 wrapup:
  return;
}

/* -----------------------------------------------
 * Set type information
 */
static void getSetTypeInfo(TVDctyTP *tp, TVDctxCP *cp, TGRid *nodeID,
			    TVDctySetTypeInfo *info)
{
  VDASSERT_FN("getSetTypeInfo");

  info->flag = 1;
  info->nth  = VDCTY_CLASSI_PLOT_TREE;
  strcpy(info->type,VDCTY_CLASSN_PLOT_TREE);
  strcpy(info->rev, "000");
  strcpy(info->desc,"Plotting Tree");
  
wrapup:
  return;
}

/* -----------------------------------------------
 * Link the base methods
 */
IGRstat VDctyInitPlotTP(TVDctyTP *tpb, TVDctyTP *tp)
{
  VDASSERT_FN("VDctyInitBaseTP");
  IGRstat retFlag = 0;

  // Arg check
  VDASSERTW(tp);

  // Copy Base
  memcpy(tp,tpb,sizeof(TVDctyTP));
  tp->parentTP = tpb;
  
  // Xfer functions
  tp->getSetTypeInfo    = getSetTypeInfo;
  tp->getNodeTypeInfo   = getNodeTypeInfo;
  tp->getNodeAttrInfo   = getNodeAttrInfo;
  tp->getNodeAttrName   = getNodeAttrName;
  tp->validateAttrValue = validateAttrValue;
  tp->setNodeUserInfo   = setNodeUserInfo;
  tp->getGadgetText     = getGadgetText;
  tp->isChildTypeValid  = isChildTypeValid;
  tp->getFilter         = getFilter;

  tp->getNodeNameForModelObject = getNodeNameForModelObject;
  tp->getNodeTypeForModelObject = getNodeTypeForModelObject;
  tp->isModelObjectValid        = isModelObjectValid;
    
  
  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}




