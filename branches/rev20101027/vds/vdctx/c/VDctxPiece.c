/* $Id: VDctxPiece.c,v 1.5 2002/02/19 17:19:10 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdctx/c/VDctxPiece.c
 *
 * Description: Common Piece oriented Routines
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctxPiece.c,v $
 *      Revision 1.5  2002/02/19 17:19:10  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/04/06 12:43:21  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/03/18 22:40:17  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/16 16:50:51  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/13 00:17:58  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/12/01  ah      Creation
 ***************************************************************************/

#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDctxPrivate.h"
#include "VDctx.h"
#include "VDtest.h"

VDASSERT_FFN("VDctxPiece.c");

/* -----------------------------------------------
 * Add plates and beams to the list
 * If data->max is 0 then effectivily get only the count 
 */
void VDctxWalkProcessGetPieces(TGRid *nodeID, void *datax, IGRint *stopWalk)
{
  TVDctxNodeList *data = datax;
  IGRchab nodeType;

  IGRchar *p;
  
  VDctxGetNodeTypeSuffix(nodeID,nodeType);
  
  if (strcmp(nodeType,"beam")  &&
      strcmp(nodeType,"plate") &&
      strcmp(nodeType,"piece") &&
      strcmp(nodeType,"PM")    &&
      strcmp(nodeType,"pm"))   goto wrapup;

  // Save it
  if (data->cnt < data->max) {
    data->listIDs[data->cnt] = *nodeID;
  }
  data->cnt++;

 wrapup:  
  return;
}

/* ---------------------------------------------------
 * Grab a list of pieces from the node
 * Sort on suffix node type and comp_path
 */
void VDctxGetListPieces(TGRid *treeID, TVDctxNodeList *nodeList)
{
  VDASSERT_FN("VDctxGetListPieces");

  IGRint stopWalk = 0;
  IGRint cnt;
  
  // Arg check
  VDASSERTW(nodeList);
  VDctxInitNodeList(nodeList);  
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);
  
  // Walk for the count
  VDctxWalkNode(treeID,1,VDctxWalkProcessGetPieces,nodeList,&stopWalk);
  cnt = nodeList->cnt;
  nodeList->cnt = 0;
  if (cnt == 0) goto wrapup;
  
  // Allocate
  nodeList->listIDs = calloc(cnt,nodeList->size);
  VDASSERTW(nodeList->listIDs);
  nodeList->max = cnt;
  
  // Walk for the nodes
  VDctxWalkNode(treeID,1,VDctxWalkProcessGetPieces,nodeList,&stopWalk);
  VDASSERTW(nodeList->cnt == nodeList->max);

  // Sort em
  VDctxSortNodeList(nodeList,VDctxCompareNodeTypeCompPath);
  
  //qsort(nodeList->listIDs,nodeList->cnt,nodeList->size,VDctxCompareNodeTypeCompPath);
  
  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Get tag information
 */
void VDctxGetCompTag(TGRid *nodeID, TVDtag *tag)
{
  VDASSERT_FN("VDctxGetCompTag");

  IGRchab buf;
  IGRchar *p;
  
  // Arg check
  VDASSERTW(tag);
  memset(tag,0,sizeof(TVDtag));
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);

  VDctxGetTxtAtr(nodeID,"comp_tagx",buf);
  if (*buf == 0) goto wrapup;

  // : Terminates
  p = strrchr(buf,':');
  if (p == NULL) goto wrapup;
  *p = 0;

  // Rev is last
  p = strrchr(buf,':');
  if (p == NULL) goto wrapup;
  tag->ver = atoi(p+1);

  // Num is second to last
  *p = 0;
  p = strrchr(buf,':');
  if (p == NULL) goto wrapup;
  tag->num = atoi(p+1);
  
  // Done

 wrapup:
  return;
}

/* -----------------------------------------------
 * Get full tag information
 */
void VDctxGetCompTagInfo(TGRid *nodeID, TVDtagInfo *tagInfo)
{
  VDASSERT_FN("VDctxGetCompTag");

  IGRchab buf;
  IGRchar *p;
  
  // Arg check
  VDASSERTW(tagInfo);
  memset(tagInfo,0,sizeof(TVDtagInfo));
  tagInfo->id.objid = NULL_OBJID;
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);

  // Make sure have one
  VDctxGetTxtAtr(nodeID,"comp_tagx",buf);
  if (*buf == 0) goto wrapup;

  // : Terminates
  p = strrchr(buf,':');
  if (p == NULL) goto wrapup;
  *p = 0;

  // Rev is last
  p = strrchr(buf,':');
  if (p == NULL) goto wrapup;
  tagInfo->tag.ver = atoi(p+1);

  // Num is second to last
  *p = 0;
  p = strrchr(buf,':');
  if (p == NULL) goto wrapup;
  tagInfo->tag.num = atoi(p+1);

  // objid -s next
  *p = 0;
  p = strrchr(buf,':');
  if (p == NULL) goto wrapup;
  tagInfo->id.objid = atoi(p+1);

  // File name
  *p = 0;
  p = strrchr(buf,':');
  if (p == NULL) goto wrapup;
  strcpy(tagInfo->path,p+1);
  
  // Convert to os
  VDosGetFileNameOS(tagInfo->path,&tagInfo->id.osnum);
  if (tagInfo->id.osnum == NULL_OSNUM) tagInfo->id.objid = NULL_OBJID;
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Get the production piece mark
 *
 * This is where start to stray into confusing territoty
 * A VDatLeaf has an attribute called pcmk
 * The snapshot stuff uses attributes called piece_pcmk
 * The actual model object needs to kick off a smart attribute
 *
 * But I guess the standard deployment strategy will work
 */
void VDctxGetPieceMark(TGRid *nodeID, IGRchar *pcmk)
{
  VDASSERT_FN("VDctxGetPieceMark");

  TVDctxCP *cp;
  
  // Arg checks
  VDASSERTW(pcmk); *pcmk = 0;
  
  // Get the class pointer
  cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->getPieceMark);

  // Doit
  cp->getPieceMark(nodeID,pcmk);
  
  // Done
wrapup:
  return;
}
void VDctxSetPieceMark(TGRid *nodeID, IGRchar *pcmk)
{
  VDASSERT_FN("VDctxSetPieceMark");

  TVDctxCP *cp;
  
  // Arg checks
  VDASSERTW(pcmk);
  
  // Get the class pointer
  cp = VDctxGetNodeCP(nodeID);
  VDASSERTW(cp && cp->setPieceMark);

  // Doit
  cp->setPieceMark(nodeID,pcmk);
  
  // Done
wrapup:
  return;
}

