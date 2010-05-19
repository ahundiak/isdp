/* $Id: VDrrvDiff.c,v 1.4 2002/06/07 20:14:49 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcty/rrv/VDrrvDiff.c
 *
 * Description: Some Diff Utilities
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDrrvDiff.c,v $
 *      Revision 1.4  2002/06/07 20:14:49  ahundiak
 *      ah
 *
 *      Revision 1.3  2002/05/06 20:52:51  ahundiak
 *      ah
 *
 *      Revision 1.2  2002/05/02 15:58:09  ahundiak
 *      ah
 *
 *      Revision 1.1  2002/02/28 21:41:34  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/27/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDlog.h"
#include "VDxml.h"

#include "VDctx.h"
#include "VDss.h"

#include "VDdoom.h"
#include "VDtest.h"
#include "VDtag.h"

#include "VDrrvCmd.h"

VDASSERT_FFN("vdcty/rrv/VDrrvDiff.c");

/* ------------------------------------------------
 * If necessary, create a diff node
 * indicating that the tag number did not change
 * nor did the revision
 */
void VDrrvCreateSpecialDiff(TGRid  *node1ID,
			    TGRid  *node2ID,
			    TGRid  *diffsID,
			    TGRid  *diffID)
{
  VDASSERT_FN("VDrrvCreateSpecialDiff");
  
  if (diffID->objid != NULL_OBJID) goto wrapup;

  VDrrvCreateDiffNode(diffsID,node1ID,node2ID,5,
                      "Same tag number and revision but piece has changed",
                      diffID);
  VDASSERTW(diffID->objid != NULL_OBJID);

 wrapup:
  return;
}

/* -----------------------------------------------
 * Create a diff node
 */
void VDrrvCreateDiffNode(TGRid   *diffsID, 
			 TGRid   *node1ID, 
			 TGRid   *node2ID,
			 IGRint   type,
			 IGRchar *comment,
			 TGRid   *a_diffID)
{
  VDASSERT_FN("VDrrvCreateDiffNode");

  TGRid diffID;
  IGRchab buf;

  TVDctxBaseInfo baseInfo;
  
  // Init
  diffID.objid = NULL_OBJID;
  
  // Arg check
  if (a_diffID) a_diffID->objid = NULL_OBJID;
  VDASSERTW(diffsID && diffsID->objid != NULL_OBJID);
  
  // Create it
  VDctxCreateNode(diffsID,VDCTX_NODE_TYPE_SS_DIFF,"Cassie",&diffID);
  VDASSERTW(diffID.objid != NULL_OBJID);

  // The type of difference
  snprintf(buf,sizeof(buf),"%d",type);
  VDctxAppTxtAtr(&diffID,VDCTX_ATR_SS_DIFF_TYPE,buf);

  // Optional comment
  if (comment) strcpy(buf,comment);
  else         strcpy(buf,"no comment");
  VDctxAppTxtAtr(&diffID,VDCTX_ATR_SS_DIFF_COMMENT,buf);

  // First node
  if (node1ID && node1ID->objid != NULL_OBJID) {
    VDctxGetBaseInfo(node1ID,&baseInfo);
    snprintf(buf,sizeof(buf),"%d,%d %s %s",
	    node1ID->osnum,node1ID->objid,
	    baseInfo.nodeType,baseInfo.nodeName);    
  }
  else strcpy(buf,"NONE");
  VDctxAppTxtAtr(&diffID,VDCTX_ATR_SS_DIFF_NODE1,buf);
  
  // Second node
  if (node2ID && node2ID->objid != NULL_OBJID) {
    VDctxGetBaseInfo(node2ID,&baseInfo);
    snprintf(buf,sizeof(buf),"%d,%d %s %s",
	    node2ID->osnum,node2ID->objid,
	    baseInfo.nodeType,baseInfo.nodeName);
  }
  else strcpy(buf,"NONE");
  VDctxAppTxtAtr(&diffID,VDCTX_ATR_SS_DIFF_NODE2,buf);
  
 wrapup:
  if (a_diffID) *a_diffID = diffID;

  return;
}

/* ----------------------------------------------
 * Cleanup the diff node creation process a bit
 * Lot's of repeative code which can be consolidated
 * And a data structure to simplify things
 */
void VDrrvInitDiffNode(IGRint flag, TVDrrvDiffInfo *info)
{
  VDASSERT_FN("VDrrvInitDiffNode");

  TVDtag tag1,tag2;

  // Arg check
  VDASSERTW(info && info->diffIDs.objid != NULL_OBJID);

  // Always create
  if (flag == 0) info->diffID.objid = NULL_OBJID;

  // See if alredy created
  if (info->diffID.objid != NULL_OBJID) goto wrapup;

  // New node
  if (info->node1ID && !info->node2ID) {
    VDrrvCreateDiffNode(&info->diffIDs,
                         info->node1ID,
                         info->node2ID,
                         1,"New Item",
                        &info->diffID);
    goto wrapup;
  }
  // Deleted node
  if (info->node2ID && !info->node1ID) {
    VDrrvCreateDiffNode(&info->diffIDs,
                         info->node1ID,
                         info->node2ID,
                         2,"Deleted Item",
                        &info->diffID);
    goto wrapup;
  }

  // Make sure not messed up
  VDASSERTW(info->node1ID);
  VDASSERTW(info->node2ID);

  // Get the tags
  VDctxGetCompTag(info->node1ID,&tag1);
  VDctxGetCompTag(info->node2ID,&tag2);
  if (tag1.num != tag2.num) {
    VDrrvCreateDiffNode(&info->diffIDs,
                         info->node1ID,
                         info->node2ID,
                        3,"Tag number changed",
                        &info->diffID);
    goto wrapup;
  }
  if (tag1.ver != tag2.ver) {
    VDrrvCreateDiffNode(&info->diffIDs,
                         info->node1ID,
                         info->node2ID,
                        4,"Same tag number, different version",
                        &info->diffID);
 
    goto wrapup;
  }
  if (flag == 0) goto wrapup;

  VDrrvCreateDiffNode(&info->diffIDs,
                       info->node1ID,
                       info->node2ID,
                      5,"Same tag number and revision but item has changed",
                      &info->diffID);
 
wrapup:
  return;
}

/* ----------------------------------------------
 * For a smooth startup
 */
void VDrrvInitDiffInfo(TGRid *tree1ID, TGRid *tree2ID, TVDrrvDiffInfo *info)
{
  VDASSERT_FN("VDrrvInitDiffInfo");

  VDASSERTW(info);
  memset(info,0,sizeof(TVDrrvDiffInfo));

  // Save some stuff
  info->tree1ID = tree1ID;
  info->tree2ID = tree2ID;

  // Make the actual tree
  VDctxCreateXdomTree(VDCTX_TREE_TYPE_SS_DIFFS,"Rebecca",&info->diffIDs);
  VDASSERTW(info->diffIDs.objid != NULL_OBJID);

  // Just to be safe
  info->diffID.objid = NULL_OBJID;

wrapup:
  return;
}

