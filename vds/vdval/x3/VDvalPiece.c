/* $Id: VDvalPiece.c,v 1.4 2001/10/16 15:10:40 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdval/x3/VDvalPiece.c
 *
 * Description:	Piece handling routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalPiece.c,v $
 *      Revision 1.4  2001/10/16 15:10:40  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/08/24 20:00:55  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/08/06 01:40:02  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/07/23 16:32:40  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/20/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDtest.h"
#include "VDgeomc.h"
#include "VDctx.h"
#include "VDval.h"
#include "VDvalLike.h"
#include "VDss.h"
#include "stdarg.h"
#include "glib.h"

VDASSERT_FFN("VDvalPiece.c");

/* -----------------------------------------------
 * Wrap a few common attrributes
 */
static void getKey(TGRid *nodeID, IGRchar *key)
{
  VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_PCMK_KEY,key);
  return;
}
static void getTranInfo(TGRid *nodeID, TVDvalSrfTranInfo **info)
{
  VDctxGetBinAtr(nodeID,"tran_info2",(void**)info);
  return;
}

/* -----------------------------------------------
 * Returns 1 if the node is a standard piece
 * based on the key value
 */
static IGRint hasStdPcmkKey(TGRid *nodeID)
{
  IGRchab key;

  // printf("--- hasStdPcmkKey %d\n",nodeID->objid);
  
  getKey(nodeID,key);
  if (*key == 0) return 0;

  return 1;
}

/* -----------------------------------------------
 * Group by key then area
 */
static IGRint compareKeyArea(const void *p1, const void *p2)
{
  VDASSERT_FN("compareKeyArea");
  
  IGRint cmp = 0;
  
  TGRid *node1ID = (TGRid*)p1;
  TGRid *node2ID = (TGRid*)p2;
  
  IGRchab buf1;
  IGRchab buf2;

  TVDvalSrfTranInfo *info1;
  TVDvalSrfTranInfo *info2;
  
  // First the key
  getKey(node1ID,buf1);
  getKey(node2ID,buf2);
  cmp = strcmp(buf1,buf2);
  if (cmp) goto wrapup;

  // Then the area
  getTranInfo(node1ID,&info1);
  getTranInfo(node2ID,&info2);
  VDASSERTW(info1 && info2);
  
  if (info1->contour.area < info2->contour.area) return -1;
  if (info1->contour.area > info2->contour.area) return  1;
  cmp = 0;
  
 wrapup:
  return cmp;
}

/* -----------------------------------------------
 * Little debug routine
 */
static void printNode(TGRid *nodeID)
{
  IGRchab buf;

  VDctxGetTxtAtr(nodeID,"comp_path",buf);
  printf("%s\n",buf);
  VDctxGetTxtAtr(nodeID,"comp_tagx",buf);
  printf("%s\n",buf);
  VDctxGetTxtAtr(nodeID,"symbology",buf);
  printf("%s\n",buf);
}

/* -----------------------------------------------
 * Returns if the two nodes are identical 
 * standard pieces
 */
IGRstat VDvalValidateTwoStdPieces(TGRid *node1ID, 
				  TGRid *node2ID, 
				  IGRdouble tol,
				  IGRint *errCnt)
{
  VDASSERT_FN("VDvalValidateTwoStdPieces");
  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRchab   key1,key2;
  IGRdouble delta;
  
  TGRobj_env parentOEs[2];
  TGRobj_env macOE;

  TVDvalSrfTranInfo *info1;
  TVDvalSrfTranInfo *info2;
  
  // Really should not be called unless key is set
  getKey(node1ID,key1);
  getKey(node2ID,key2);
  VDASSERTW(*key1 && *key2);
  
  getTranInfo(node1ID,&info1);
  getTranInfo(node2ID,&info2);
  VDASSERTW(info1 && info2);

  // Check the geometry
  sts = VDvalCompareNodeGeometry(node1ID,node2ID,tol,NULL);
  if (sts == 0) {
  
    // Report it
    delta = fabs(info1->contour.area - info2->contour.area);
    printf("----------------------------------------------------------\n");
    printf("*** Pieces failed geometry check, area difference of %.2f\n",delta);

    printNode(node1ID);    
    printf("KEY %s, AREA %.2f\n",key1,info1->contour.area);

    printNode(node2ID);    
    printf("KEY %s, AREA %.2f\n",key2,info2->contour.area);

    // Counter
    *errCnt = *errCnt + 1;

    // Place a macro
    VDctxGetModelObject(node1ID,&parentOEs[0]);
    VDctxGetModelObject(node2ID,&parentOEs[1]);  
    VDefpPlaceMacro("VDefp","crv_tran2",0,2,parentOEs,&macOE);

    goto wrapup;
  }
  
  // They match
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Starting with the nth element, return
 * number of elements in the same piece mark group
 */
static void getGroupCount(TVDctxNodeList *listSP, IGRint nth, IGRint *cnt)
{
  IGRchab key1,key2;
  IGRint  i;
  IGRint flag = 1;
  
  // Init
  *cnt = 0;
  if (nth >= listSP->cnt) goto wrapup;
  *cnt = 1;
  
  getKey(&listSP->listIDs[nth],key1);
  
  // Cycle though
  for(i = nth + 1; (flag) && (i < listSP->cnt); i++) {
    getKey(&listSP->listIDs[i],key2);
    if (!strcmp(key1,key2)) *cnt = *cnt + 1;
    else flag = 0;
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Starting at the nth element we have
 * cnt pieces with the same key sorted by area
 * check the biggest difference between areas
 */
static void processGroup2(TVDctxNodeList *listSP, IGRint nth, IGRint cnt, IGRdouble tol, IGRint *errCnt)
{
  TGRid *node1ID,*node2ID;
  
  // Ignore groups of 1
  if (cnt <= 1) goto wrapup;

  // Validate extremes
  VDvalValidateTwoStdPieces(&listSP->listIDs[nth],
			    &listSP->listIDs[nth + cnt - 1],
			    tol,
			    errCnt);
  
 wrapup:
  return;
}
/* -----------------------------------------------
 * Starting at the nth element we have
 * cnt pieces with the same key sorted by area
 * Validate each pair of pieces in the group
 */
static void processGroup0(TVDctxNodeList *listSP, IGRint nth, IGRint cnt, IGRdouble tol, IGRint *errCnt)
{
  TGRid *node1ID,*node2ID;
  
  IGRint i,j;
  
  // Ignore groups of 1
  if (cnt <= 1) goto wrapup;

  // Loop for each
  for(i = 0; i < cnt; i++) {
    node1ID = &listSP->listIDs[nth + i];
    
    // Loop again
    for(j = 0; j < cnt; j++) {
      node2ID = &listSP->listIDs[nth + j];

      // Validate
      VDvalValidateTwoStdPieces(node1ID,node2ID,tol,errCnt);
    }
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Check that all the standard pieces in the tree
 * are in fact standard
 */
void VDvalValidateStdPieces(TGRid    *treeID,
			    IGRint    flag,
			    IGRdouble tol,
			    IGRint   *errCnt)
{
  VDASSERT_FN("VDvalValidateStdPieces");

  TVDctxNodeList listSP;
  
  TGRid *nodeID,*node1ID,*node2ID;
  IGRint i,cnt;

  IGRchab key1,key2;
  
  TGRbsp_curve *crv;
  
  TVDvalSrfTranInfo *info;
  
  IGRchar buf[128];
  
  // Init
  VDctxInitNodeList(&listSP);
  
  // Say hi
  //traceFlag = 1;
  if (traceFlag) printf(">>> %s\n",fn);
  
  // Arg check
  VDASSERTW(errCnt); *errCnt = 0;
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);

  // Grab a list of standard pieces
  VDctxGetNodeListByFilter(treeID,hasStdPcmkKey,&listSP);
  if (listSP.cnt == 0) goto wrapup;

  if (traceFlag) printf("Located %d standard pieces\n",listSP.cnt);

  // Extract like info if necessary
  for(i = 0; i < listSP.cnt; i++) {
    nodeID = &listSP.listIDs[i];
    getTranInfo(nodeID,&info);
    if (info == NULL) {
      VDvalGenerateLikePartInfo(nodeID);
    }
  }
  
  // Sortem
  VDctxSortNodeList(&listSP,compareKeyArea);

  if (traceFlag) printf("Checking %d standard pieces\n",listSP.cnt);

  // Check by group
  for(i = 0; i < listSP.cnt; i += cnt)
  {
    getGroupCount(&listSP,i,&cnt);

    sprintf(buf,"Processing %d of %d, group cnt %d",i,listSP.cnt,cnt);
    UI_status(buf);
    
    switch(flag) {

      case 0:
	processGroup0(&listSP,i,cnt,tol,errCnt);
	break;

      case 2:
	processGroup2(&listSP,i,cnt,tol,errCnt);
	break;

    }
  }
  printf("### Total number of errors %d\n",*errCnt);

 wrapup:
  VDctxFreeNodeList(&listSP);
  if (traceFlag) printf("<<< %s\n",fn);
  return;
}
