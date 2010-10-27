/* $Id: VDrrvBevel.c,v 1.2 2002/05/03 20:12:13 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcty/rrv/VDrrvBevel.c
 *
 * Description: Compare bevel Trees
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDrrvBevel.c,v $
 *      Revision 1.2  2002/05/03 20:12:13  ahundiak
 *      ah
 *
 *      Revision 1.1  2002/03/14 22:18:07  ylong
 *      Compare bevels, penetrations
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/10/02  ylong   Creation
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

#include "VDgeomc.h"
#include "VDval.h"

#include "VDrrvCmd.h"

VDASSERT_FFN("vdcty/rrv/VDrrvBevel.c");

/*---------------------------------------------------------------
 * Used to sort bevel xdoms based on bevel macro name and tag number
 */
static int compareBevelTypeCompTag(const void *void1, const void *void2)
{
  VDASSERT_FN("compareBevelTypeCompTag");

  IGRint	cmp;
  TGRid		*node1ID = (TGRid *) void1;
  TGRid		*node2ID = (TGRid *) void2;
  IGRchar	buf1[128];
  IGRchar	buf2[128];
  TVDtag	tag1, tag2;

  VDctxGetTxtAtr(node1ID,VDCTX_ATR_SS_BEVEL_MACRO_TYPE,buf1);
  VDctxGetTxtAtr(node2ID,VDCTX_ATR_SS_BEVEL_MACRO_TYPE,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) return cmp;

  VDctxGetCompTag(node1ID,&tag1);
  VDctxGetCompTag(node2ID,&tag2);
   
  return( tag1.num - tag2.num );
}

/* ---------------------------------------------------------------------
 * compare two bevel's plates and create diff under bevel diff node
 */
void VDrrvCompareTwoBevelParentNodes(TGRid *diffsID,
			             TGRid *node1ID,
			             TGRid *node2ID,
			             TGRid *diffID)
{
  VDASSERT_FN("VDrrvCompareTwoBevelParentNodes");

  struct 
  {
    IGRchab path;
    TVDtag  tag;
  } info1,info2;
  
  TGRid		parent1ID,parent2ID;
  IGRchar	buf[256];
  
  // Make sure have nodes
  VDASSERTW(diffID); diffID->objid = NULL_OBJID;
  VDASSERTW(node1ID && node1ID->objid != NULL_OBJID);
  VDASSERTW(node2ID && node2ID->objid != NULL_OBJID);
  VDASSERTW(diffsID && diffsID->objid != NULL_OBJID);

  // Get parent nodes to create diff under bevel diff
  VDctxGetTreeParent(node1ID,&parent1ID);
  VDctxGetTreeParent(node2ID,&parent2ID);
  VDASSERTW(parent1ID.objid != NULL_OBJID && parent2ID.objid != NULL_OBJID);

  // Get paths of bevel's plates 
  VDctxGetCompPath(node1ID,info1.path);
  VDctxGetCompPath(node2ID,info2.path);

  // ah - Take out the assert, confuses things
  // ss_om_bevel_plate nodes may be empty if you see assert here
  // VDASSERTW(*info1.path || *info2.path);
  if (*info1.path == 0) goto wrapup;
  if (*info2.path == 0) goto wrapup;

  //if bevel's plate is replaced 
  if(strcmp(info1.path,info2.path) ) {
    sprintf(buf,"Changed from <%s> to <%s>", info2.path,info1.path);
    VDrrvCreateSpecialDiff(&parent1ID,&parent2ID,diffsID,diffID);
    VDctxAppTxtAtr(diffID,"plate",buf);
  }

  //else if the tag of bevel's plate changed 
  else { 
    // Get the tags
    VDctxGetCompTag(node1ID,&info1.tag);
    VDctxGetCompTag(node2ID,&info2.tag);
    if (info1.tag.num != info2.tag.num) {
      VDrrvCreateSpecialDiff(&parent1ID,&parent2ID,diffsID,diffID);
      VDctxAppTxtAtr(diffID,"plate","tag number changed");
    }
    else {
      if (info1.tag.ver != info2.tag.ver) {
        VDrrvCreateSpecialDiff(&parent1ID,&parent2ID,diffsID,diffID);
        VDctxAppTxtAtr(diffID,"plate","version changed with same tag number");
      }
    }
  }

  // Done
 wrapup:
  return;
}

/* ------------------------------------------------
 * Compare two attributes
 */
void VDrrvCompareTwoBevelAttributes (	TGRid  *node1ID,
					TGRid  *node2ID,
					TVDfld *fld1,
					IGRint  cnt2,
					TVDfld *fld2s,
					TGRid  *diffsID,
					TGRid  *diffID)
{
  VDASSERT_FN("VDrrvCompareTwoBevelAttributes");

  IGRint i;
  TVDfld *fld2 = NULL;

  IGRdouble dbl1,dbl2;
  IGRdouble del;
  
  IGRchar buf[256];

  IGRchab buf1,buf2;
  IGRchar *p;

  TGRid   plateID;
  IGRint  j;
  IGRchab pcmk;

  // Arg check
  VDASSERTW(node1ID && node1ID->objid != NULL_OBJID);
  VDASSERTW(node2ID && node2ID->objid != NULL_OBJID);
  VDASSERTW(fld1 && *fld1->name);

  // Certain ones get ignored
  if (!strcmp(fld1->name,VDCTX_ATR_SS_BASE_INFO)) goto wrapup;
  if (!strcmp(fld1->name,VDCTX_ATR_SS_COMP_PATH)) goto wrapup;
  if (!strcmp(fld1->name,VDCTX_ATR_SS_COMP_TAG))  goto wrapup;
  if (!strcmp(fld1->name,VDCTX_ATR_SS_SYMBOLOGY)) goto wrapup;

  // Find it in the list
  for(i = 0; (i < cnt2) && (fld2 == NULL); i++) {
    if (!strcmp(fld1->name,fld2s[i].name)) {
      fld2 = &fld2s[i];
    }
  }
  // Silently ignore attributes not in second set
  if (fld2 == NULL) goto wrapup;
  
  // Little hack to take care of some format differences
  strcpy(buf1,fld1->val.txt);
  p = strrchr(buf1,'.');
  if (p && !strcmp(p,".0")) *p = 0;
  strcpy(buf2,fld2->val.txt);
  p = strrchr(buf2,'.');
  if (p && !strcmp(p,".0")) *p = 0;
  
  // Generic processor
  if (strcmp(buf1,buf2)) {
  
    // If needed
    VDrrvCreateSpecialDiff(node1ID,node2ID,diffsID,diffID);

    sprintf(buf,"Changed from <%s> to <%s>",
	    fld2->val.txt,
	    fld1->val.txt);

    // Add piece marks from plate
    for(j = 0; VDctxGetNthTreeChild(node1ID,j,&plateID); j++) {
      VDctxGetTxtAtr(&plateID,"piece_mark",pcmk);
      if (*pcmk) {
        strcat(buf," pcmk=");
        strcat(buf,pcmk);
      }
    }
    strcat(buf,"\n");
    VDctxAppTxtAtr(diffID,fld1->name,buf);
  }
   
  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Compare the attributes of the two nodes
 */
void VDrrvCompareTwoBevelNodesAttributes(TGRid *diffsID,
				         TGRid *node1ID,
				         TGRid *node2ID,
				         TGRid *diffID)
{
  VDASSERT_FN("VDrrvCompareTwoBevelNodesAttributes");

  IGRint  cnt1,cnt2,i;
  TVDfld  flds1[64];
  TVDfld  flds2[64];

  // Arg check
  VDASSERTW(diffID);
  VDASSERTW(node1ID && node1ID->objid != NULL_OBJID);
  VDASSERTW(node2ID && node2ID->objid != NULL_OBJID);
  VDASSERTW(diffsID && diffsID->objid != NULL_OBJID);
  
  // Get the attributes
  VDctxGetFldAtrs(node1ID,&cnt1,flds1);
  VDctxGetFldAtrs(node2ID,&cnt2,flds2);

  // Bounce em
  for(i = 0; i < cnt1; i++) {
    VDrrvCompareTwoBevelAttributes(	node1ID,node2ID,
					&flds1[i],
					cnt2,flds2,
					diffsID,diffID);
  }

 wrapup:
  return;
}

/* -----------------------------------------------
 * Got two nodes from two different trees whose tag number
 * matches, do an in depth comparision
 */
void VDrrvCompareTwoBevelNodes( TGRid *diffsID,
				TGRid *node1ID,
				TGRid *node2ID,
				TGRid *diffID)
{
  VDASSERT_FN("VDrrvCompareTwoBevelNodes");

  struct 
  {
    IGRchab path;
    TVDtag  tag;
  } info1,info2;
  
  IGRint	i;
  IGRchab	path,buf;
  TGRid		*findID=NULL,*foundID=NULL;

  TVDctxNodeList l1,l2;
  
  // Init
  VDctxInitNodeList(&l1);
  VDctxInitNodeList(&l2);
  
  // Make sure have nodes
  VDASSERTW(diffID); diffID->objid = NULL_OBJID;
  VDASSERTW(node1ID && node1ID->objid != NULL_OBJID);
  VDASSERTW(node2ID && node2ID->objid != NULL_OBJID);
  VDASSERTW(diffsID && diffsID->objid != NULL_OBJID);

  // Just for grins, make sure comp_path matches
  VDctxGetCompPath(node1ID,info1.path);
  VDctxGetCompPath(node2ID,info2.path);
  VDASSERTW(*info1.path && *info2.path);
  
  // Get the tags
  VDctxGetCompTag(node1ID,&info1.tag);
  VDctxGetCompTag(node2ID,&info2.tag);
  if (info1.tag.num != info2.tag.num) {

    VDrrvCreateDiffNode(diffsID,node1ID,node2ID,3,"Tag number changed",diffID);
    VDASSERTW(diffID->objid != NULL_OBJID);
    
  }
  else {  
    if (info1.tag.ver != info2.tag.ver) {

      VDrrvCreateDiffNode(diffsID,node1ID,node2ID,4,"Same tag number, different version",diffID);      
      VDASSERTW(diffID->objid != NULL_OBJID);

    }
  }

  // Compare two bevels
  VDrrvCompareTwoBevelNodesAttributes(diffsID,node1ID,node2ID,diffID);

  // Check bevel's plates
  VDctxGetNodeListByType(node1ID,VDCTX_NODE_TYPE_SS_OM_BEVEL_PLATE,&l1);
  VDctxGetNodeListByType(node2ID,VDCTX_NODE_TYPE_SS_OM_BEVEL_PLATE,&l2);

  if (l1.cnt == 0) goto wrapup;
  if (l2.cnt == 0) goto wrapup;

  // Sort bevel's plates
  VDctxSortNodeList(&l1,VDctxCompareNodeTypeCompPath);
  VDctxSortNodeList(&l2,VDctxCompareNodeTypeCompPath);

  // Check for items in 1 but not in 2
  for(l1.i = 0; l1.i < l1.cnt; l1.i++) {

    findID  = &l1.listIDs[l1.i];
    foundID = VDctxSearchNodeList(findID,&l2,VDctxCompareNodeTypeCompPath);
    if (foundID == NULL) {
      VDrrvCreateSpecialDiff(node1ID,node2ID,diffsID,diffID);
      VDctxGetCompPath(findID,path);
      sprintf(buf, "<%s> is new", path);
      VDctxAppTxtAtr(diffID,"plate",buf);
    }
  }

  // Check for items in 2 but not in 1
  for(l2.i = 0; l2.i < l2.cnt; l2.i++) {

    findID  = &l2.listIDs[l2.i];
    foundID = VDctxSearchNodeList(findID,&l1,VDctxCompareNodeTypeCompPath);
    if (foundID == NULL) {
      VDrrvCreateSpecialDiff(node1ID,node2ID,diffsID,diffID);
      VDctxGetCompPath(findID,path);
      sprintf(buf, "<%s> is removed from bevel", path);
      VDctxAppTxtAtr(diffID,"plate",buf);
    }    
  }

  // Check for items in both
  for(l1.i = 0; l1.i < l1.cnt; l1.i++) {

    findID  = &l1.listIDs[l1.i];
    foundID = VDctxSearchNodeList(findID,&l2,VDctxCompareNodeTypeCompPath);
    if (foundID) {
      VDrrvCompareTwoBevelParentNodes(diffsID,findID,foundID,diffID);
    }
  }

  // Done
 wrapup:

  VDctxFreeNodeList(&l1);
  VDctxFreeNodeList(&l2);
  
  return;
}

/* -----------------------------------------------
 * Given two dom bevel trees, compare them
 * Make the assumption that tree1 is the newer tree?
 */
void VDrrvCompareTwoBevelTrees(TGRid *tree1ID, TGRid *tree2ID, TGRid *diffsID)
{
  VDASSERT_FN("VDrrvCompareTwoBevelTrees");

  IGRint stopWalk = 0;

  TGRid  *findID;
  TGRid *foundID;

  TGRid diffID;
  
  struct 
  {
    IGRint newCnt;
    IGRint delCnt;
    IGRint modCnt;
  } sum;
  
  TVDctxNodeList l1,l2;
  TVDctxBaseInfo baseInfo1,baseInfo2;
  
  // Init
  VDctxInitNodeList(&l1);
  VDctxInitNodeList(&l2);
  memset(&sum,0,sizeof(sum));
  
  // Arg check
  VDASSERTW(diffsID && diffsID->objid != NULL_OBJID);
  VDASSERTW(tree1ID && tree1ID->objid != NULL_OBJID);
  VDASSERTW(tree2ID && tree2ID->objid != NULL_OBJID);

  // For reporting
  VDctxGetBaseInfo(tree1ID,&baseInfo1);
  VDctxGetBaseInfo(tree2ID,&baseInfo2);
  VDASSERTW(baseInfo1.treeType);
  VDASSERTW(baseInfo1.treeType);
  
  // Grab the piecess
  VDctxGetNodeListByType(tree1ID,VDCTX_NODE_TYPE_SS_OM_BEVEL,&l1);
  VDctxGetNodeListByType(tree2ID,VDCTX_NODE_TYPE_SS_OM_BEVEL,&l2);
  
  // Ok if either has no pieces
  if (l1.cnt == 0) goto wrapup;
  if (l2.cnt == 0) goto wrapup;

  // Sort em
  VDctxSortNodeList(&l1,compareBevelTypeCompTag);
  VDctxSortNodeList(&l2,compareBevelTypeCompTag);
  
  // Report
  VDlogPrintFmt(VDLOG_INFO,traceFlag,
		"Compare Bevel Tree 1 %s %s, Count %4d",
		baseInfo1.treeType,baseInfo1.treeName,l1.cnt);

  VDlogPrintFmt(VDLOG_INFO,traceFlag,
		"        Bevel Tree 2 %s %s, Count %4d",
		baseInfo2.treeType,baseInfo2.treeName,l2.cnt);
  
  // Check for items in 1 but not in 2
  for(l1.i = 0; l1.i < l1.cnt; l1.i++) {

    findID  = &l1.listIDs[l1.i];
    foundID = VDctxSearchNodeList(findID,&l2,compareBevelTypeCompTag);
    if (foundID == NULL) {
      VDrrvCreateDiffNode(diffsID,findID,NULL,1,"New Bevel",&diffID); 
      //VDlogPrintObject(VDLOG_INFO,traceFlag,"New Piece ",NULL,findID);
      sum.newCnt++;
    }
  }

  // Check for items in 2 but not in 1
  for(l2.i = 0; l2.i < l2.cnt; l2.i++) {

    findID  = &l2.listIDs[l2.i];
    foundID = VDctxSearchNodeList(findID,&l1,compareBevelTypeCompTag);
    if (foundID == NULL) {
      VDrrvCreateDiffNode(diffsID,NULL,findID,2,"Deleted Bevel",&diffID);
      //VDlogPrintObject(VDLOG_INFO,traceFlag,"Deleted Piece ",NULL,findID);      
      sum.delCnt++;
    }    
  }

  // Check for items in both
  for(l1.i = 0; l1.i < l1.cnt; l1.i++) {

    findID  = &l1.listIDs[l1.i];
    foundID = VDctxSearchNodeList(findID,&l2,compareBevelTypeCompTag);
    if (foundID) {
      VDrrvCompareTwoBevelNodes(diffsID,findID,foundID,&diffID);
      if (diffID.objid != NULL_OBJID) sum.modCnt++;
    }
  }

  // Done
  VDlogPrintFmt(VDLOG_INFO,traceFlag,
	"Compare Summary, New Bevel %d, Deleted Bevel %d, 'Modified' Bevel %d",
	sum.newCnt,sum.delCnt,sum.modCnt);      
  
 wrapup:

  VDctxFreeNodeList(&l1);
  VDctxFreeNodeList(&l2);
  
  return;
}
