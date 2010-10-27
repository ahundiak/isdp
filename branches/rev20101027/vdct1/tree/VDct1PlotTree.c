 /* $Id: VDct1PlotTree.c,v 1.1 2001/01/14 16:29:17 art Exp $  */
/***************************************************************************
 * I/VDS
 *
 * File:        vdct1/tree/VDct1PlotTree.I
 *
 * Description: Plot Tree Customization
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDct1PlotTree.c,v $
 *      Revision 1.1  2001/01/14 16:29:17  art
 *      sp merge
 *
 * Revision 1.6  2000/11/30  15:31:26  pinnacle
 * js
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/10/00  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
 
#include "VDos.h"
#include "VDobj2.h"

#include "VDct1.h"
#include "VDct1Tree.h"
#include "VDct1Tree2.h"
#include "VDct1Plot.h"
#include "VDct1Trace.h"
#include "VDct1Forms.h"

VDASSERT_FFN("vdct1/tree/VDct1PlotTree.C");

#define MY_TREE VDCT1_TREE_TYPE_PLOT_TREE

/* ------------------------------------------------------
 * Validates, and cleans attribute values
 */
static IGRstat validateAttrValue(TVDct1JD *nodeJD,
				 IGRchar  *attrName,
				 IGRchar  *attrValue,
				 IGRchar  *attrValuex,
				 IGRchar  *msg)
{
  VDASSERT_FN("validateAttrValue");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  VDASSERTW(nodeJD->cl != NULL);
  VDASSERTW(attrName);
  VDASSERTW(attrValue);
  VDASSERTW(attrValuex);
  VDASSERTW(msg);
  
  // copy attrValue into attrValuex
  strcpy(attrValuex,attrValue);

  // upper case it
  if (strcmp(attrName,VDCT1_PLOT_ATTR_NAME_WINDOW)) VDstrupr(attrValuex);

  // done
  retFlag = 1;
  
 wrapup:  
  return retFlag;
}

/* --------------------------------------------------------
 * Set user information at creation of node
 */
static IGRstat setNodeUserInfo(TVDct1JD       *nodeJD,
			       TVDct1UserInfo *info)
{
  VDASSERT_FN("setNodeUserInfo");
  
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchar windowName[1024];

  VDASSERTW(nodeJD);
  VDASSERTW(info);
  
  // do it
  
  // plot tree needs the windowName
  VDobjGetName(NULL,&info->windowID,windowName);
  
  VDjt1SetAttr(nodeJD,VDCT1_PLOT_ATTR_NAME_WINDOW,windowName);
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
static IGRstat getGadgetText(TVDct1JD *nodeJD,
			     IGRchar  *formName,
			     IGRint    gadget,
			     IGRint    nth,
			     IGRchar  *txt)
{
   VDASSERT_FN("getGadgetText");

  IGRstat       retFlag = 0;
  TVDctBaseInfo baseInfo;
  TVDct1JD parentClassJD;
  
  // Arg check
  VDASSERTW(txt != NULL);
  *txt = 0;
  VDASSERTW(formName != NULL);
  
  if (traceFlag) {
    printf(">>> %s %s\n",ffn(),fn);
  }
  
  // Need baseInfo
  _RTCJDB(nodeJD)->getBaseInfo(nodeJD,&baseInfo);
  if (*baseInfo.nodeType == 0) goto wrapup;

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
  parentClassJD.cl = VDct1GetParentTreeClassForSetType(MY_TREE);
  retFlag = _RTCJDC(&parentClassJD)->getGadgetText(nodeJD,formName,gadget,nth,txt);
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Sheet node name, just use typed in value
 */
static IGRstat getNodeNameForModelObject(TVDct1JD      *nodeJD,
					 TGRobj_env    *modelOE,
					 TVDctNodeName  nodeName)
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
static IGRstat getTypeForModelObject(TVDct1JD      *parentNodeJD,
				     TGRobj_env    *modelOE,
				     TVDctNodeType nodeType)
{
  VDASSERT_FN("getTypeForModelObject");
  
  IGRstat retFlag = 0;

  strcpy(nodeType,VDCT1_PLOT_NODE_TYPE_SHEET);
  
  retFlag = 1;
   
wrapup:  
  
  return retFlag;
}

/* -------------------------------------------------------
 * Can we add this object
 */
static IGRstat isModelObjectValid(TVDct1JD   *nodeJD,
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
static IGRstat isChildTypeValid(TVDct1JD *parentJD,
				IGRchar  *childType)
{
  VDASSERT_FN("isChildTypeValid");
  IGRstat retFlag = 0;
  
  TVDctBaseInfo baseInfo;
  TVDctNodeType parentType;
  
  // Arg check
  VDASSERTW(parentJD && parentJD->cl && (parentJD->id.objid != NULL_OBJID));
  VDASSERTW(childType);

  // Need the parent info
  _RTCJDB(parentJD)->getBaseInfo(parentJD,&baseInfo);
  strcpy(parentType,baseInfo.nodeType);
  VDASSERTW(*parentType != 0);
  
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

/* -------------------------------------------------
 * Class filter
 */
static IGRstat getFilter(TVDct1JD *setJD, OM_S_CLASSLIST *classList)
{
  VDASSERT_FN("getFilter");
  
  IGRstat retFlag = 0;
  
  // Arg check
  VDASSERTW(setJD && setJD->cl);
  VDASSERTW(classList);
  
  // Doit
  VDomGetClassIdForClassName("GRvg",&classList->p_classes[0]);
  classList->w_count = 1;

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -------------------------------------------------
 * Individual stage info
 */
static IGRstat getNodeTypeInfo(TVDct1JD *nodeJD,
			       IGRint    nth, 
			       IGRint   *cnt, 
			       TVDctNodeTypeInfo *info)
{
  VDASSERT_FN("getNodeTypeInfo");
  
  IGRstat retFlag = 0;
  
  // Arg check
  if (cnt) *cnt = 2;  // Set this to total number of nodes

  VDASSERTW(nodeJD && nodeJD->cl);
  VDASSERTW(info);

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
  memset(info,0,sizeof(TVDctNodeTypeInfo));
  retFlag = 0;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Nth attribute of a given node
 */
static IGRstat getNodeAttrName(TVDct1JD *nodeJD,
			       IGRchar  *nodeType,
			       IGRint    nth,
			       IGRchar  *attrName)
{ 
  VDASSERT_FN("getNodeAttrName");
  IGRstat retFlag = 0;

  // Arg check
  VDASSERTW(attrName); *attrName = 0;
  VDASSERTW(nodeJD   && nodeJD->cl);
  VDASSERTW(nodeType && *nodeType);
  
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
    printf("<<< %s %s\n",ffn(),fn);
  }
  return retFlag;
}

/* --------------------------------------------------
 * For a given set wide attribute name, fill in the info
 */
static IGRstat getNodeAttrInfo(TVDct1JD *nodeJD,
			       IGRchar  *name, 
			       TVDctAttrInfo *info)
{ 
  VDASSERT_FN("getNodeAttrInfo");
  IGRstat retFlag = 0;
  
  // Arg check
  VDASSERTW(info); *info->name = 0;
  VDASSERTW(name);
  VDASSERTW(nodeJD && nodeJD->cl);
  
  // Just compares
  retFlag = 1;

  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_CAGE_CODE)) {
    VDctxSetAttrInfo(name,5,"CAGE CODE","CAGE CODE",info);
    goto wrapup;
  }

  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_DRAWING_NUMBER)) {
    VDctxSetAttrInfo(name,20,"DRAWING NUMBER","DRAWING NUMBER",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_DRAWING_REV)) {
    VDctxSetAttrInfo(name,20,"DRAWING REV","DRAWING REVISION",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_NAVSEA_DRAWING_NUMBER)) {
    VDctxSetAttrInfo(name,20,"NAVSEA DRAWING NUMBER","NAVSEA DRAWING NUMBER",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_DRAWING_TITLE)) {
    VDctxSetAttrInfo(name,40,"DRAWING TITLE","DRAWING TITLE",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_DRAWING_TYPE)) {
    VDctxSetAttrInfo(name,20,"DRAWING TYPE","DRAWING TYPE",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_DRAWING_DATE)) {
    VDctxSetAttrInfo(name,20,"DRAWING DATE","DRAWING DATE",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_SHEET_SIZE)) {
    VDctxSetAttrInfo(name,20,"SHEET SIZE","SHEET SIZE",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_TEAM)) {
    VDctxSetAttrInfo(name,20,"TEAM","TEAM",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_POSTING_DATE)) {
    VDctxSetAttrInfo(name,20,"POSTING DATE","POSTING DATE",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_OBID)) {
    VDctxSetAttrInfo(name,40,"OBID","OBID",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_SHEET_NUMBER)) {
    VDctxSetAttrInfo(name,20,"SHEET NUMBER","SHEET NUMBER",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_SHEET_NAME)) {
    VDctxSetAttrInfo(name,20,"SHEET NAME","SHEET NAME",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_SHEET_DESCRIPTION)) {
    VDctxSetAttrInfo(name,60,"SHEET DESCRIPTION","SHEET DESCRIPTION",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_REGISTRATION_STATUS)) {
    VDctxSetAttrInfo(name,20,"REGISTRATION STATUS","REGISTRATION STATUS",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_REGISTRATION_DATE)) {
    VDctxSetAttrInfo(name,20,"REGISTRATION DATE","REGISTRATION DATE",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_WINDOW)) {
    VDctxSetAttrInfo(name,24,"WINDOW","WINDOW NAME",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_AUTHORIZE_FOR)) {
    VDctxSetAttrInfo(name,30,"AUTHORIZE FOR","AUTHORIZE FOR",info);
    goto wrapup;
  }
  if (!strcmp(name,VDCT1_PLOT_ATTR_NAME_PREVIOUS_REV)) {
    VDctxSetAttrInfo(name,20,"PREVIOUS REVISION","PREVIOUS REVISION",info);
    goto wrapup;
  }

  // Not found
  retFlag = 0;
  
wrapup:
  if (retFlag == 0) {  
    if (info) memset(info,0,sizeof(TVDctAttrInfo));
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * Hello routine for testing
 */
static IGRstat hello(TVDct1JD *nodeJD)
{
  VDASSERT_FN("hello");

  printf("@@@ Hello from %s %s\n",ffn(),fn);

  return 1;
}

/* -----------------------------------------------
 * The only public routine
 * Used to init the various function pointers
 */
IGRstat VDct1InitPlotTreeClass(TVDct1RootTreeClass *rootCL, 
			       TVDct1PlotTreeClass *cl)
{
  VDASSERT_FN("VDct1InitPlotTreeClass");
  IGRstat retFlag = 0;

  // Tracing
  traceFlagx = traceFlag = VDct1TraceFlag(VDCT1_TRACE_TREE_PLOT);

  // Arg check
  VDASSERTW(rootCL);
  VDASSERTW(cl);
  
  // Clear
  memset(cl,0,sizeof(TVDct1PlotTreeClass));
  
  // Transfer
  VDct1CopyRootImps(rootCL,cl);
  
  // Class info
  strcpy(cl->base.className,VDCT1_CLASSN_PLOT_TREE);
  cl->base.classID        = VDCT1_CLASSI_PLOT_TREE;
 
  // Data
  strcpy(cl->base.info.type,VDCT1_TREE_TYPE_PLOT_TREE);
  strcpy(cl->base.info.rev, "000");
  strcpy(cl->base.info.desc,"Drawing Plot Tree");
  
  // Fill up pointers
  cl->base.hello            = hello;
  cl->base.getFilter        = getFilter;

  cl->base.getNodeTypeInfo  = getNodeTypeInfo;
  cl->base.getNodeAttrName  = getNodeAttrName;
  cl->base.getNodeAttrInfo  = getNodeAttrInfo;
  
  cl->base.createNode       = createNode;  
  cl->base.isChildTypeValid = isChildTypeValid;

  cl->base.isModelObjectValid        = isModelObjectValid;
  cl->base.getTypeForModelObject     = getTypeForModelObject;
  cl->base.getNodeNameForModelObject = getNodeNameForModelObject;

  cl->cmd.getGadgetText     = getGadgetText;
  cl->cmd.setNodeUserInfo   = setNodeUserInfo;
  cl->cmd.validateAttrValue = validateAttrValue;
  
  // Done
  retFlag = 1;

 wrapup:
  return retFlag;
}

