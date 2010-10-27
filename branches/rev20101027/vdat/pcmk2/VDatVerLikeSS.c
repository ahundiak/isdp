/* $Id: VDatVerLikeSS.c,v 1.3 2001/10/19 18:22:34 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk2/VDatVerLikeSS.c
 *
 * Description: Verify Like Snapshot
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatVerLikeSS.c,v $
 *      Revision 1.3  2001/10/19 18:22:34  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/22 18:45:51  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/22 14:41:13  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/19 16:03:29  ahundiak
 *      ah
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/20/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDlog.h"
#include "VDctx.h"
#include "VDrisc.h"

#include "VDss.h"
#include "VDat.h"
#include "VDat2Pcmk.h"

#include "time.h"

VDASSERT_FFN("vdat/pcmk2/VDatVerLikeSS.c");

/* -----------------------------------------------
 * Custome routine for bouncing current node
 * against snapshot node2
 *
 * Since we are basically comparing a piece against itself,
 * put a real tight tolerance on area
 */
static IGRint compareSnapshot(const void *v1, const void *v2)
{
  VDASSERT_FN("compareSnapshot");
  
  TGRid *node1ID = (TGRid *)v1;
  TGRid *node2ID = (TGRid *)v2;

  IGRchab buf1,buf2;
  IGRchab type;
  
  IGRint cmp;
  
  IGRdouble area1,area2;
  IGRdouble delta;
  IGRdouble tol = 1.0;
  
  // Start with the usual piece attributes
  cmp = VDat2ComparePieceAttributes(node1ID,node2ID);
  if (cmp) goto wrapup;
  
  // Now check the geom summary attributes
  cmp = VDat2CompareGeomAttributes(node1ID,node2ID);
  if (cmp) goto wrapup;
  
  // Do the usual plate or beam
  VDctxGetNodeTypeSuffix(node1ID,type);
  if (!strcmp(type,VDCTX_NODE_TYPE_PLATE)) {

    // Regular check
    cmp = VDat2ComparePlateAttributes(node1ID,node2ID);
    if (cmp) goto wrapup;

    // Recheck area
    VDctxGetTxtAtr(node1ID,VDCTX_ATR_SS_PLATE_AREA,buf1);
    VDctxGetTxtAtr(node2ID,VDCTX_ATR_SS_PLATE_AREA,buf2);
    area1 = atof(buf1);
    area2 = atof(buf2);
    delta = fabs(area1 - area2);
    if (delta > tol) {
      if (area1 < area2) cmp = -1;
      if (area1 > area2) cmp =  1;
      goto wrapup;
    }
      
    // They match
    cmp = 0;
    goto wrapup;
    
  }
  if (!strcmp(type,VDCTX_NODE_TYPE_BEAM)) {

    // Regular check
    cmp = VDat2CompareBeamAttributes(node1ID,node2ID);
    if (cmp) goto wrapup;

    // Recheck area
    VDctxGetTxtAtr(node1ID,VDCTX_ATR_SS_BEAM_AREA,buf1);
    VDctxGetTxtAtr(node2ID,VDCTX_ATR_SS_BEAM_AREA,buf2);
    area1 = atof(buf1);
    area2 = atof(buf2);
    delta = fabs(area1 - area2);
    if (delta > tol) {
      if (area1 < area2) cmp = -1;
      if (area1 > area2) cmp =  1;
      goto wrapup;
    }

    // They match
    cmp = 0;
    goto wrapup;
    
  }

  // Bad
  cmp = 0;
  VDASSERTW(0);
  
 wrapup:
  return cmp;
}

/* -----------------------------------------------
 * Have a group with the same piece marks but at least
 * one no longer matches,
 *
 * If a snapshot is available, find any pieces whose attributes
 * have actually changed and whack em
 *
 * What happens if they all have changed attributes?
 * They all get whacked but will then all be regrouped
 *
 * I suppose we could whack one at a time and recheck after each?
 */
IGRstat VDat2VerifyLikeSnapshotGroup(TVDat2PcmkInfoList *listPI, 
				     IGRint beg, 
				     IGRint num,
				     TVDctxNodeList *listSS)
{
  VDASSERT_FN("VDat2VerifyLikeSnapshotGroup");

  IGRstat retFlag = 0;
  IGRstat sts;
  
  IGRint end = beg + num;
  
  IGRint i,j;
  IGRint cmp;
  
  TVDat2PcmkInfo *info1;
  TVDat2PcmkInfo *info2;

  IGRchab pcmk;
  
  IGRint whackCnt = 0;
  
  TGRid *node1ID;
  TGRid *node2ID;
  
  // Arg check
  VDASSERTW(listPI);
  VDASSERTW((beg >= 0) && (end <= listPI->cnt));
  VDASSERTW(listSS);
  
  // If have no snapshot then give up
  if (listSS->cnt == 0) goto wrapup;
  
  // For debugging
  VDctxGetTxtAtr(&listPI->pcmkInfos[beg].nodeID,VDCTX_ATR_SS_PIECE_PCMK,pcmk);
  // if (!strcmp(pcmk,"10")) traceFlag = 1;
  
  // Regular tolerance
  VDat2SetCompareFlags(0,0,0);

  //Say hi
  if (traceFlag)  VDlogPrintFmt(VDLOG_INFO,0,">>> %s %s %d %d\n",
				fn,pcmk,beg,num);
  
  // Check each against it's snapshot
  for(i = beg; i < end; i++) {

    node1ID = &listPI->pcmkInfos[i].nodeID;
    node2ID = VDctxSearchNodeList(node1ID,listSS,VDctxCompareCompPath);

    if (node2ID) {
   
      // So the compare 
      VDat2SetCompareFlags(traceFlag,0,0);
      cmp = compareSnapshot(node1ID,node2ID);
      VDat2SetCompareFlags(0,0,0);
      if (cmp) {

	// Whack it
	if (traceFlag) VDlogPrintFmt(VDLOG_INFO,0,"Whacked %d\n",i);
	VDctxSetTxtAtr(node1ID,VDCTX_ATR_SS_PIECE_PCMK,"");
	whackCnt++;
      }
    }   
  }
  
  // If none were whacked then give up
  if (whackCnt == 0) goto wrapup;

  // If they were all whacked then that's ok
  if (whackCnt == num) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Carefully resort to move whacked numbers up
  VDat2SetCompareFlags(0,0,1);
  qsort(&listPI->pcmkInfos[beg],num,sizeof(TVDat2PcmkInfo),VDat2VerifyLikeCompare1);  
  VDat2SetCompareFlags(0,0,0);

  // And check the remainders
  sts = VDat2VerifyLikeProcessGroup(listPI,beg+whackCnt,num - whackCnt);
  if (sts == 0) goto wrapup;
  if (traceFlag) {  
    VDlogPrintFmt(VDLOG_INFO,0,"### The snapshot compare did the trick\n");
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) VDlogPrintFmt(VDLOG_INFO,0,"<<< %s\n",fn);
  VDat2SetCompareFlags(0,0,0);
  return retFlag;
}
