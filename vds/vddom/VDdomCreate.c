/* $Id: VDdomCreate.c,v 1.3 2001/03/11 18:35:11 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vddom/VDdomTest.c
 *
 * Description: VDcxt Creation Routines
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDdomCreate.c,v $
 *      Revision 1.3  2001/03/11 18:35:11  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/02/26 15:50:45  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/02/22 22:44:50  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 02/22/01  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDdom.h"
#include "VDctx.h"

VDASSERT_FFN("vds/vddom/VDdomCreate.c");

/* -------------------------------------------------
 * Just create someting for searching process
 */
void VDdomCreateFind(TGRid *a_findID)
{
  VDASSERT_FN("VDdomCreateFind");

  TGRid findID;
  TGRid parentID;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  VDASSERTW(a_findID); a_findID->objid = NULL_OBJID;

  VDdomGetActiveOsnum(&parentID.osnum);
  parentID.objid = NULL_OBJID;

  VDdomCreateObj(&parentID,"FIND",&findID);
  VDASSERTW(findID.objid != NULL_OBJID);
  
  *a_findID = findID;
  
 wrapup:

  // Say Bi
  if (traceFlag) printf("<<< %s\n",fn);

  return;
}

/* -------------------------------------------------
 * Got to start somewhere
 */
void VDdomCreateTree(VDosnum osnum, IGRchar *treeType, IGRchar *treeName, TGRid *a_treeID)
{
  VDASSERT_FN("VDdomCreateTree");
  
  TGRid parentID;
  TGRid treeID;
  
  IGRchab buf;

  TVDctxBaseInfo baseInfo;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(a_treeID); a_treeID->objid = NULL_OBJID;
  VDASSERTW(treeName && *treeName);
  VDASSERTW(treeType && *treeType);

  // Set the os
  if (osnum != NULL_OSNUM) parentID.osnum = osnum;
  else                     VDdomGetActiveOsnum(&parentID.osnum);
  VDASSERTW(parentID.osnum != NULL_OSNUM);
  parentID.objid = NULL_OBJID;
  
  // Create it
  VDdomCreateObj(&parentID,treeType,&treeID);
  VDASSERTW(treeID.objid != NULL_OBJID);

  // Fill up the baseInfo structure
  memset(&baseInfo,0,sizeof(TVDctxBaseInfo));
  strcpy( baseInfo.setType, treeType);
  strcpy( baseInfo.setName, treeName);
  strcpy( baseInfo.nodeType,treeType);
  strcpy( baseInfo.nodeName,treeName);
  VDctxSetBaseInfo(&treeID,&baseInfo);
    
  // Done
  *a_treeID = treeID;
  
 wrapup:

  // Say Bi
  if (traceFlag) printf("<<< %s\n",fn);

  return;
}

/* -------------------------------------------------
 * Create a node
 * Use base information from the parent
 */
void VDdomCreateNode(TGRid *parentID, IGRchar *nodeType, IGRchar *nodeName, TGRid *a_nodeID)
{
  VDASSERT_FN("VDdomCreateNode");

  TGRid   nodeID;

  TVDctxBaseInfo baseInfo;
  
  // Say Hi
  traceFlag = VDdomGetTraceFlag();
  if (traceFlag) printf(">>> %s\n",fn);

  // Arg check
  VDASSERTW(a_nodeID);  a_nodeID->objid  = NULL_OBJID;
  VDASSERTW(parentID && parentID->objid != NULL_OBJID);
  VDASSERTW(nodeType && *nodeType);
  
  // Validate base information
  VDctxGetBaseInfo(parentID,&baseInfo);
  VDASSERTW(*baseInfo.treeType);
  strcpy(baseInfo.nodeType,nodeType);
  if (nodeName) strcpy(baseInfo.nodeName,nodeName);
  else          *baseInfo.nodeName = 0;
  
  // Create the node
  VDdomCreateObj(parentID,baseInfo.nodeType,&nodeID);
  VDASSERTW(nodeID.objid != NULL_OBJID);
  
  VDctxSetBaseInfo(&nodeID,&baseInfo);
  
  // Done
  *a_nodeID = nodeID;
  
 wrapup:

  // Say Bi
  if (traceFlag) printf("<<< %s\n",fn);

  return;
}
