/* $Id: VDctxComp.c,v 1.2 2002/06/04 14:04:46 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdctx/c/VDctxComp.c
 *
 * Description: Component oriented routines
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctxComp.c,v $
 *      Revision 1.2  2002/06/04 14:04:46  ahundiak
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
#include "VDctx.h"
#include "VDlog.h"

VDASSERT_FFN("vdctx/c/VDctxComp.c");

/* -----------------------------------------------
 * Compare two tags
 */
IGRint VDctxCompareCompTag(const void *void1, const void *void2)
{
  TGRid *node1ID = (TGRid *) void1;
  TGRid *node2ID = (TGRid *) void2;

  IGRchar buf1[128];
  IGRchar buf2[128];
  TVDtagInfo tagInfo1,tagInfo2;

  IGRint cmp;

  // Get info
  VDctxGetCompTagInfo(node1ID,&tagInfo1);
  VDctxGetCompTagInfo(node2ID,&tagInfo2);

  // Make sure they are in the same file
  cmp = strcmp(tagInfo1.path,tagInfo2.path);
  if (cmp) return cmp;

  // And the actual number
  if (tagInfo1.tag.num < tagInfo2.tag.num) return -1;
  if (tagInfo1.tag.num > tagInfo2.tag.num) return  1;

  return 0;

}

/* -----------------------------------------------
 * Compare two comp names
 */
IGRint VDctxCompareCompName(const void *void1, const void *void2)
{
  TGRid *node1ID = (TGRid *) void1;
  TGRid *node2ID = (TGRid *) void2;

  IGRchar buf1[128];
  IGRchar buf2[128];

  VDctxGetCompName(node1ID,buf1);
  VDctxGetCompName(node2ID,buf2);
    
  return strcmp(buf1,buf2);
}

/* -----------------------------------------------
 * Compare by node type them comp name
 * have plates and beams match regardless of their prefix
 */
IGRint VDctxCompareNodeTypeCompName(const void *void1, const void *void2)
{
  IGRint cmp;
  
  TGRid *node1ID = (TGRid *) void1;
  TGRid *node2ID = (TGRid *) void2;

  IGRchar buf1[128];
  IGRchar buf2[128];

  // First the type
  VDctxGetNodeTypeSuffix(node1ID,buf1);
  VDctxGetNodeTypeSuffix(node2ID,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) return cmp;

  // Then the name
  VDctxGetCompName(node1ID,buf1);
  VDctxGetCompName(node2ID,buf2);
  return strcmp(buf1,buf2);
}

/* -----------------------------------------------
 * Compare two comp paths
 */
IGRint VDctxCompareCompPath(const void *void1, const void *void2)
{
  TGRid *node1ID = (TGRid *) void1;
  TGRid *node2ID = (TGRid *) void2;

  IGRchar buf1[128];
  IGRchar buf2[128];

  VDctxGetCompPath(node1ID,buf1);
  VDctxGetCompPath(node2ID,buf2);    
  return strcmp(buf1,buf2);
}

/* -----------------------------------------------
 * Compare by node type them comp path
 * have plates and beams match regardless of their prefix
 */
IGRint VDctxCompareNodeTypeCompPath(const void *void1, const void *void2)
{
  IGRint cmp;
  
  TGRid *node1ID = (TGRid *) void1;
  TGRid *node2ID = (TGRid *) void2;

  IGRchar buf1[128];
  IGRchar buf2[128];

  // First the type
  VDctxGetNodeTypeSuffix(node1ID,buf1);
  VDctxGetNodeTypeSuffix(node2ID,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) return cmp;

  // Then the name
  VDctxGetCompPath(node1ID,buf1);
  VDctxGetCompPath(node2ID,buf2);    
  return strcmp(buf1,buf2);
}

/* -----------------------------------------------
 * Checking for duplicate names
 * Sorts on node name as a side effect
 */
void VDctxCheckForDupCompNames(IGRint  cnt, 
			       TGRid  *listIDs, 
			       IGRint *a_dupCnt)
{
  VDASSERT_FN("VDctxCheckForDupCompNames");

  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint  i;
  IGRint  dupCnt = 0;
  
  TGRid   nodeID1,nodeID2;
  
  IGRchar type[128];
  IGRchar name[128];
  IGRchar path[128];
  
  IGRchar msg[256];
  
  // Arg check
  if (a_dupCnt) *a_dupCnt = 0;
  if (cnt == 0) goto wrapup;
  VDASSERTW(listIDs);
  
  // Sort
  qsort(listIDs,cnt,sizeof(TGRid),VDctxCompareCompName);

  // Cycle through
  for(i = 1; i < cnt; i++) {

    // See if different
    nodeID1 = listIDs[i-1];
    nodeID2 = listIDs[i-0];
    
    sts = VDctxCompareCompName(&nodeID1,&nodeID2);
    if (sts == 0) {
      
      dupCnt++;

      // Report it
      if (dupCnt == 1) {
	VDlogPrintFmt(VDLOG_INFO,0,"***");
	VDlogPrintFmt(VDLOG_INFO,0,"Duplicate Comp Name(s) Found:");
      }
      
      VDctxGetCompName(&nodeID1,name);
      VDlogPrintFmt(VDLOG_INFO,0,"*** Duplicate Comp Name %s",name);
      
      VDctxGetNodeType(&nodeID1,type);
      VDctxGetCompPath(&nodeID1,path);
      VDlogPrintFmt(VDLOG_INFO,0,"    %02d,%-8d %-6s %s",
		     nodeID1.osnum,nodeID1.objid,type,path);

      VDctxGetNodeType(&nodeID2,type);
      VDctxGetCompPath(&nodeID2,path);
      VDlogPrintFmt(VDLOG_INFO,0,"    %02d,%-8d %-6s %s",
		     nodeID2.osnum,nodeID2.objid,type,path);
    }      
  }
  if (dupCnt) {
    VDlogPrintFmt(VDLOG_INFO,0,"Found %d duplicate(s).",dupCnt);
  }
  
 wrapup:
  if (a_dupCnt) *a_dupCnt = dupCnt;
  
  return;
}

