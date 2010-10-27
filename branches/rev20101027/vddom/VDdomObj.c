/* $Id: VDdomObj.c,v 1.5 2001/03/11 18:35:11 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdxml/VDdomObj.c
 *
 * Description: Object Routines
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDdomObj.c,v $
 *      Revision 1.5  2001/03/11 18:35:11  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/02/26 15:50:45  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/02/09 22:29:25  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/14 16:33:39  art
 *      sp merge
 *
 *      Revision 1.1  2001/01/11 19:28:37  art
 *      sp merge
 *
 * Revision 1.1  2000/12/06  15:01:08  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/01/00  ah      Creation
 * 01/13/01  ah      sp17 merge
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDdom.h"

#include "VDassert.h"

VDASSERT_FFN("vds/vddom/VDdomObj.c");

/* -----------------------------------------------
 * Given the top node in a regular xml tree
 * Convert it to a set object
 */
IGRstat VDdomConvertToSetObj(TGRid *treeID)
{
  VDASSERT_FN("VDdomConvertToSetObj");
  IGRstat retFlag = 0;

  IGRint cnt;
  TGRid  childID;

  IGRchar name[64];
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg Check
  VDASSERTW(treeID);

  // There should be one and only one child
  VDdomGetObjChildCount(treeID,0,&cnt);
  VDASSERTW(cnt == 1);
  
  // Does it have a name?
  VDdomGetObjName(treeID,name);
  if (*name == 0) {
    
    // Pull it from the child object
    VDdomGetNthChildObj(treeID,0,&childID);
    VDdomGetObjName(&childID,name);
    VDASSERTW(*name);
    
    VDdomAppendAtr(treeID,"node_name",name);
  }
  
  // Convert it
  VDdomSetObjClassType(treeID,VDDOM_CLASS_TYPE_SET);
  retFlag = 1;
  
 wrapup:
  
  // Say Bi
  if (traceFlag) printf("<<< %s\n",fn);

  return retFlag;
}

/* -----------------------------------------------
 * Get the set object for a given node
 */
void VDdomGetSetObj(TGRid *nodeID, TGRid *setID)
{
  VDASSERT_FN("VDdomGetSetObj");
  
  TGRid  parentID;
  IGRint classType;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(setID); setID->objid = NULL_OBJID;

  // Might be the set already
  VDdomGetObjClassType(nodeID,&classType);
  switch(classType) {

    case VDDOM_CLASS_TYPE_SET:
      *setID = *nodeID;
      goto wrapup;

    case VDDOM_CLASS_TYPE_MGR:
      VDASSERTW(NULL);
  }
  
  /* ---------------------------------------------
   * Grab it's parent, none means that we don't
   * have a set object in the tree in which case
   * this routine should not have been called
   */
  VDdomGetParentObj(nodeID,&parentID);
  VDASSERTW(parentID.objid != NULL_OBJID);
  
  VDdomGetSetObj(&parentID,setID);
  
 wrapup:
  
  // Say Bi
  if (traceFlag) printf("<<< %s\n",fn);

  return;
}

/* -----------------------------------------------
 * Get the tree object for a given node
 * Handles the case where a set object is passed
 * Otherwise, recurses up
 */
void VDdomGetTreeObj(TGRid *nodeID, TGRid *treeID)
{
  VDASSERT_FN("VDdomGetTreeObj");
  
  IGRint classType;
  TGRid  parentID;

  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(treeID); treeID->objid = NULL_OBJID;

  // Is it a set
  VDdomGetObjClassType(nodeID,&classType);
  switch(classType) {

    case VDDOM_CLASS_TYPE_SET:
      VDdomGetNthChildObj(nodeID,0,treeID);
      goto wrapup;

    case VDDOM_CLASS_TYPE_MGR:
      VDASSERTW(NULL);
  }
  
  // Get the parent - no parent implies a regular unmanaged tree
  VDdomGetParentObj(nodeID,&parentID);
  if (parentID.objid == NULL_OBJID) {
    *treeID = *nodeID;
    goto wrapup;
  }

  /* ---------------------------------------------------
   * Could put in code to check parent's class type here
   * But Just Go Up
   */
  VDdomGetTreeObj(&parentID,treeID);
  
 wrapup:
  
  // Say Bi
  if (traceFlag) printf("<<< %s\n",fn);

  return;
}

/* ---------------------------------------------
 * Returns the objects class (type)
 */
void VDdomGetObjClassName(TGRid *nodeID, IGRchar *className)
{
  VDASSERT_FN("VDdomGetObjClassName");
  
  TVDdomEle *nodeDD;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(className);
  *className = 0;
  
  // Get the instance
  VDdomGetObjInstance(nodeID, &nodeDD);
  VDASSERTW(nodeDD);
  
  // Simple copy
  strcpy(className,nodeDD->type);
  
  // Done
wrapup:
  
  // Say Bi
  if (traceFlag) printf("<<< %s\n",fn);

  return;
}

/* ---------------------------------------------
 * Returns the objects class (type)
 */
void VDdomGetObjClassType(TGRid *nodeID, IGRint *classType)
{
  VDASSERT_FN("VDdomGetObjClassName");
  
  TVDdomEle *nodeDD;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(classType);
  *classType = 0;
  
  // Get the instance
  VDdomGetObjInstance(nodeID, &nodeDD);
  VDASSERTW(nodeDD);
  
  // Simple copy
  *classType = nodeDD->classType;
  
  // Done
wrapup:
  
  // Say Bi
  if (traceFlag) printf("<<< %s\n",fn);

  return;
}

/* ---------------------------------------------
 * Returns the objects class (type)
 */
void VDdomSetObjClassType(TGRid *nodeID, IGRint classType)
{
  VDASSERT_FN("VDdomSetObjClassType");
  
  TVDdomEle *nodeDD;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Get the instance
  VDdomGetObjInstance(nodeID, &nodeDD);
  VDASSERTW(nodeDD);
  
  // Simple copy
  nodeDD->classType = classType;
  
  // Done
wrapup:
  
  // Say Bi
  if (traceFlag) printf("<<< %s\n",fn);

  return;
}

/* -----------------------------------------------
 * Returns the nth direct child
 */
IGRstat VDdomGetNthChildObj(TGRid *nodeID, IGRint nth, TGRid *childID)
{
  VDASSERT_FN("VDdomGetNthChildObject");
  IGRstat retFlag = 0;

  TVDdomEle *parentDD;
  TVDdomEle *childDD;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(childID);
  childID->objid = NULL_OBJID;
  VDASSERTW(nth >= 0);

  // Parent
  VDdomGetObjInstance(nodeID, &parentDD);
  VDASSERTW(parentDD);

  // Cycle through
  for(childDD = parentDD->children; childDD; childDD = childDD->sibling) {
    if (nth == 0) {
      *childID = childDD->eleID;
      retFlag = 1;
      goto wrapup;
    }
    nth--;
  }
  
 wrapup:
  
  // Say Bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* -----------------------------------------------
 * Returns the number of direct or indirect children
 */
IGRstat VDdomGetObjChildCount(TGRid *nodeID, IGRint flag, IGRint *cnt)
{
  VDASSERT_FN("VDdomGetObjChildCount");
  
  IGRstat retFlag = 0;
  IGRint i;

  TVDdomEle *parentDD;
  TVDdomEle *childDD;

  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(cnt);
  *cnt = 0;
  
  // Parent
  VDdomGetObjInstance(nodeID, &parentDD);
  VDASSERTW(parentDD);

  // Cycle through
  for(childDD = parentDD->children; childDD; childDD = childDD->sibling) {
    *cnt = *cnt + 1;    
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  
  // Say Bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* ---------------------------------------------
 * Get the parent of an object if one exists
 */
IGRstat VDdomGetObjParent(TGRid *childID, TGRid *parentID)
{
  VDASSERT_FN("VDdomGetObjParent");
  IGRstat retFlag = 0;
  
  TVDdomEle *childDD;
  TVDdomEle *parentDD;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(parentID);
  parentID->objid = NULL_OBJID;
  
  // Get the child
  VDdomGetObjInstance(childID,&childDD);
  if (childDD == NULL) goto wrapup;
  
  // Have a parent
  parentDD = childDD->parent;
  if (parentDD == NULL) goto wrapup;
  
  // Done
  *parentID = parentDD->eleID;
  retFlag = 1;
  
wrapup:
  
  // Say Bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* ---------------------------------------------
 * Print a single node
 */
void  VDdomPrintObj(TGRid *nodeID,
		    FILE  *file,
		    IGRint atrs,
		    IGRint kids,
		    IGRint indent)
{
  VDASSERT_FN("VDdomPrintNodeObj");
  IGRint  i;
  
  IGRchar className[40];
  TGRid   childID;
  
  TVDdomAtr *nodeAD;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(nodeID);
  if (nodeID->objid == NULL_OBJID) goto wrapup;
  if (file == NULL) file = stdout;

  // Get the class
  VDdomGetObjClassName(nodeID,className);
  VDASSERTW(*className);
  
  // Put it out
  for(i = 0; i < indent; i++) fputc(' ',file); indent++;
  fprintf(file,"DOM %d,%d %s\n",nodeID->osnum,nodeID->objid,className);

  // Do the attributes
  if (atrs) {  
    VDdomGetFirstAtr(nodeID,&nodeAD);
    while(nodeAD) {
      for(i = 0; i < indent; i++) fputc(' ',file);
      fprintf(file,"ATR %s = %s\n",nodeAD->type,nodeAD->value);
      nodeAD = VDdomGetNextAtr(nodeAD);
    }
  }
  
  // Do the kids
  if (kids) {  
    for(i = 0; VDdomGetNthChildObj(nodeID,i,&childID); i++) {
      VDdomPrintObj(&childID,file,atrs,kids,indent);  
    }
  }
  
  // Done
wrapup:
  
  // Say Bi
  if (traceFlag) printf("<<< %s\n",fn);

  return;
}

/* ---------------------------------------------
 * Just a wrapper to make dumping a tree easier
 */
void VDdomPrintTree(TGRid *treeID, FILE *file)
{
  if (file == NULL) file = stdout; 
  VDdomPrintObj(treeID,file,1,1,0);
}

/* -----------------------------------------------
 * node_type interface
 */
IGRstat VDdomGetObjType(TGRid *nodeID, IGRchar *type)
{
  VDASSERT_FN("VDdomGetObjType");
  
  IGRstat retFlag = 0;
  
  IGRchar className[40];
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(type);
  *type = 0;

  // Get the class name
  VDdomGetObjClassName(nodeID,className);
  if (*className == 0) goto wrapup;
  
  // Done
  strcpy(type,className);
  retFlag = 1;
    
 wrapup:
  
  // Say Bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* -----------------------------------------------
 * node_name interface
 */
IGRstat VDdomGetObjName(TGRid *nodeID, IGRchar *name)
{
  VDASSERT_FN("VDdomGetObjName");
  
  IGRstat retFlag = 0;

  TVDdomAtr *nameAD;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(name);
  *name = 0;

  // See if have a node name
  VDdomGetAtrByType(nodeID,"node_name",&nameAD);
  if (nameAD == NULL) {
    VDdomGetAtrByType(nodeID,"set_name",&nameAD);
  }
  if (nameAD == NULL) {
    VDdomGetAtrByType(nodeID,"pcmk",&nameAD);
  }
  if (nameAD == NULL) goto wrapup;
  
  // Got it
  strcpy(name,nameAD->value);
  retFlag = 1;
    
 wrapup:
  
  // Say Bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* -----------------------------------------------
 * Returns a display description for the element
 */
IGRstat VDdomGetObjDesc(TGRid *nodeID, IGRchar *desc)
{
  VDASSERT_FN("VDdomGetObjDesc");
  
  IGRstat retFlag = 0;

  TVDdomAtr *nameAD;
  
  IGRchar className[40];
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(desc);
  *desc = 0;

  // Get the class name
  VDdomGetObjClassName(nodeID,className);
  if (*className == 0) {
    strcpy(desc,"INVALID");
    goto wrapup;
  }
  retFlag = 1;
  
  // See if have a node name
  VDdomGetAtrByType(nodeID,"node_name",&nameAD);
  if (nameAD) {
    sprintf(desc,"%s %s",className,nameAD->value);
    goto wrapup;
  }
  
  // Just the tag
  strcpy(desc,className);
  
 wrapup:
  
  // Say Bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* -------------------------------------------------------
 * Create an element
 */
IGRstat VDdomCreateObj(TGRid *parentID, IGRchar *type, TGRid *a_newID)
{
  VDASSERT_FN("VDdomCreateObj");
  IGRstat retFlag = 0;

  TGRid      newID;
  TVDdomEle *newDD;
  TVDdomEle *childDD;
  TVDdomEle *parentDD;
  
  TVDdomOSD *osd;

  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(a_newID);
  a_newID->objid = NULL_OBJID;
  VDASSERTW(type && *type);
  VDASSERTW(parentID);
  
  // get the osd
  VDdomGetOSD(parentID->osnum, &osd);
  VDASSERTW(osd);
  
  // Get the object id
  newID.osnum = parentID->osnum;
  VDdomGetNextObjid(newID.osnum, &newID.objid);
  VDASSERTW(newID.objid != NULL_OBJID);
  
  // Know it's valid so just get instance pointer
  newDD = osd->ele_list[newID.objid];
  VDASSERTW(newDD);
  
  // Set the type
  strcpy(newDD->type,type);
  
  // Set the parent if have one
  VDdomGetObjInstance(parentID, &parentDD);
  if (parentDD) {
    newDD->parent = parentDD;
    if (parentDD->children == NULL) parentDD->children = newDD;
    else {
      for(childDD = parentDD->children; childDD->sibling; childDD = childDD->sibling);
      childDD->sibling = newDD;
    }
  }
  else newDD->parent = NULL;
  
  // Done
  *a_newID = newID;
  retFlag = 1;
  
wrapup:
  
  // Say Bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* -----------------------------------------------
 * Append new child to the parent
 */
IGRstat VDdomAppendChildObj(TGRid *parentID, TGRid *childID)
{
  VDASSERT_FN("VDdomAppendChildObj");
  IGRstat retFlag = 0;
  
  TVDdomEle *parentDD,*childDD,*nextDD;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Need the pointers
  VDdomGetObjInstance(parentID,&parentDD); VDASSERTW(parentDD);
  VDdomGetObjInstance( childID, &childDD); VDASSERTW( childDD);

  // Adjust pointers
  childDD->parent = parentDD;
  if (parentDD->children == NULL) parentDD->children = childDD;
  else {
    for(nextDD = parentDD->children; nextDD->sibling; nextDD = nextDD->sibling);
    nextDD->sibling = childDD;
  }

  // Done
  retFlag = 1;

 wrapup:
  
  // Say Bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* -----------------------------------------------
 * Private interface with no arg checking
 * Recursive search for first occurance of a particular element type
 */
static domGetObjByClassName(TGRid *nodeID, IGRchar *className, TGRid *foundID)
{
  VDASSERT_FN("domFindElementByType");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid childID;

  IGRchar classNamex[40];
  
#if 0
  // Does current element match?
  VDdomGetObjClassName(nodeID,classNamex);

  if (!strcmp(classNamex,className)) {
    
    // Got it
    *foundID = nodeID;
    retFlag = 1;
    goto wrapup;
  }
  
  // Cycle through kids
  childEle = rootEle->children;
  while(childEle) {

    // Recurse
    sts = domFindElementByType(childEle,eleType,foundEle);
    if (sts & 1) {

      // Got it
      retFlag = 1;
      goto wrapup;
    }
    childEle = childEle->sibling;
  }
#endif  
  // Done (no match)
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Public interface with arg checking
 * Recursive search for first occurance of a particular element type
 */
IGRstat VDdomGetObjByClassName(TGRid *nodeID, IGRchar *className, TGRid *foundID)
{
  VDASSERT_FN("VDdomGetObjByClassName");
  IGRstat retFlag = 0;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(foundID);
  foundID->objid = NULL_OBJID;
  VDASSERTW(className && *className);
  VDASSERTW(nodeID);

  // Call private
  retFlag = domGetObjByClassName(nodeID,className,foundID);
    
 wrapup:
  
  // Say Bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}

/* -----------------------------------------------
 * Public interface for freeing tree nodes
 * A NULL_OBJID will fail silently to make the calling
 * apps job easier
 */
IGRstat VDdomFreeTreeObj(TGRid *treeID)
{
  VDASSERT_FN("VDdomFreeTreeObj");
  
  IGRstat retFlag = 1;

  TVDdomEle *treeDD;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  if (treeID == NULL)              goto wrapup;
  if (treeID->objid == NULL_OBJID) goto wrapup;
  
  // Get the function pointer
  VDdomGetObjInstance(treeID, &treeDD);
  if (treeDD == NULL) goto wrapup;

  retFlag = VDdomFreeTreeEle(treeDD);
  
 wrapup:
  
  // Say Bi
  if (traceFlag) printf("<<< %s %d\n",fn,retFlag);

  return retFlag;
}
