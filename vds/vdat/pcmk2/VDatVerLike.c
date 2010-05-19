/* $Id: VDatVerLike.c,v 1.7 2001/11/16 14:29:25 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk2/VDatVerStd.C
 *
 * Description: Like Verification Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatVerLike.c,v $
 *      Revision 1.7  2001/11/16 14:29:25  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/10/19 18:22:34  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/09/14 21:53:15  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/09/14 21:20:45  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/09/07 19:18:08  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/08/14 18:59:14  ahundiak
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
 * 08/10/01  ah      TR5502 not_like parts getting like numbers during verify
 * 09/07/01  ah      And now it was skipping some like parts during verify
 * 09/14/01  ah      And an unitiialized flag variable
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

VDASSERT_FFN("vdat/pcmk2/VDatVerLike.c");

/* -----------------------------------------------
 * Return the number of items the nth one actually matches
 * in the group counting itself as 1
 *
 * 06 July 2001
 * Had a logic bug, in some cases the nth item might match all
 * the other items but that set of items did not itself form a group
 * Needed another round of checking
 *
 * This does not necessarly get the biggest group, to do that would
 * really require checking every possible combination which could easily
 * take a very long time.  But is does make sure that any group found
 * is a valid one
 *
 * Really need to return the list of items in the group itself
 * Which it now does
 */
static IGRint getGroupMatchCnt(TVDat2PcmkInfoList *listPI, 
			       IGRint nth, IGRint beg, IGRint num, IGRint *flags)
{
  VDASSERT_FN("getGroupMatchCnt");
  
  IGRint end = beg + num;
  IGRint cnt = 0;
  IGRint cmp;
  IGRint i,j;
  
  TVDat2PcmkInfo *info1;
  TVDat2PcmkInfo *info2;
  TVDat2PcmkInfo *info3;

  IGRint  flag;
  
  // Init
  for(j = 0; j < num; j++) {
    flags[j] = 0;
  }
  
  // One being matched
  info1 = &listPI->pcmkInfos[nth];
  
  // Need to check every one against every one
  for(i = beg; i < end; i++) {

    // Always matches itself
    if (i == nth) cnt++;
    else {
      
      // Get the infos
      info2 = &listPI->pcmkInfos[i];

      // Check the attributes
      cmp = VDat2VerifyLikeCompare1(info1,info2);
      if (cmp == 0) {
	cmp = VDat2CompareGeometry(info1,info2);
      }
      if (cmp == 0) {

	// Check against any other possible group members
	flag = 1;
	for(j = beg; (j < i) && (flag == 1); j++) {
	  if (flags[j - beg]) {
	    info3 = &listPI->pcmkInfos[j];
	    cmp = VDat2VerifyLikeCompare1(info3,info2);
	    if (cmp == 0) {
	      cmp = VDat2CompareGeometry(info3,info2);
	    }
	    if (cmp) flag = 0;
	  }
	}
	if (flag) {
	  cnt++;
	  flags[i - beg] = 1;
	}
      }
    }
  }
  
  // Done
  flags[nth - beg] = 1;
  
 wrapup:
  //printf("<<< %s %d %d %d\n",fn,beg,nth,cnt);
  return cnt;
}

/* -----------------------------------------------
 * At this point we know the group is no longer valid
 * And there was no history snapshot or else
 * it was not able to resolve which pieces to keep
 *
 * So just find which piece mark the majority matches
 * and keep it.
 *
 * Don't get clever, just bounce everything against
 * everything and see what happens
 */
static void keepBiggestGroup(TVDat2PcmkInfoList *listPI, IGRint beg, IGRint num, IGRint *changeCnt)
{
  VDASSERT_FN("keepBiggestGroup");
  
  IGRint end = beg + num;
  IGRint i,j,cnt,cmp;
  
  IGRint nthx,cntx;
  
  TVDat2PcmkInfo *info1;
  TVDat2PcmkInfo *info2;
  
  IGRint *flags = NULL;
  IGRint *flagx = NULL;
  
  IGRchab buf;
  
  // Init
  cntx = 0;
  nthx = beg;
  flags = calloc(num,sizeof(IGRint));
  flagx = calloc(num,sizeof(IGRint));
  
  // Cycle through
  for(i = beg; i < end; i++) {

    if (num > 9) {
      sprintf(buf,"Matching groups %d of %d, Count %d",i,end,num);
      UI_status(buf);
    }
    
    cnt = getGroupMatchCnt(listPI,i,beg,num,flags);
    if (cnt > cntx) {
      cntx = cnt;
      nthx = i;
      for(j = 0; j < num; j++) {
	flagx[j] = flags[j];
      }   
    }
  }
  // Whack any not flagged
  for(j = 0; j < num; j++) {
    if (flagx[j] == 0) {
      VDctxSetTxtAtr(&listPI->pcmkInfos[beg+j].nodeID,VDCTX_ATR_SS_PIECE_PCMK,"");
      if (changeCnt) *changeCnt = *changeCnt + 1;
    }
  }
#if 0  
  // Get the one to keep
  info1 = &listPI->pcmkInfos[nthx];
  
  // Whack the rest
  for(i = beg; i < end; i++) {
    if (i != nthx) {

      info2 = &listPI->pcmkInfos[i];

      cmp = VDat2VerifyLikeCompare1(info1,info2);
      if (cmp == 0) {
	cmp = VDat2CompareGeometry(info1,info2);
      }
      if (cmp) {
	VDctxSetTxtAtr(&listPI->pcmkInfos[i].nodeID,VDCTX_ATR_SS_PIECE_PCMK,"");
	if (changeCnt) *changeCnt = *changeCnt + 1;
	printf("Whacked a piece\n");
      } 
    }
  }
#endif

  // Done
 wrapup:
  if (flags) free(flags);
  if (flagx) free(flagx);
  return;
}

/* -----------------------------------------------
 * At this point, know we have num nodes starting
 * the nth position with the same piece mark
 *
 * Need to see if they are all still like or not
 *
 * returns 1 if they are all alike
 */
IGRstat VDat2VerifyLikeProcessGroup(TVDat2PcmkInfoList *listPI, 
				    IGRint beg, IGRint num)
{
  VDASSERT_FN("VDat2VerifyLikeProcessGroup");

  IGRstat retFlag = 0;
  
  IGRint end = beg + num;
  
  IGRint i,j;
  IGRint cmp;
  
  TVDat2PcmkInfo *info1;
  TVDat2PcmkInfo *info2;

  IGRchab pcmk;
  
  // Arg check
  VDASSERTW(listPI);
  VDASSERTW((beg >= 0) && (end <= listPI->cnt));

  // For debugging
  VDctxGetTxtAtr(&listPI->pcmkInfos[beg].nodeID,VDCTX_ATR_SS_PIECE_PCMK,pcmk);
  
  // Verbose
  VDat2SetCompareFlags(1,0,0);

  //Say hi
  if (traceFlag)  VDlogPrintFmt(VDLOG_INFO,0,">>> %s %s %d %d\n",
				fn,pcmk,beg,num);
  
  // Need to check every one against every one
  for(i = beg; i < end; i++) {
    for(j = i+1; j < end; j++) {

      // Get the infos
      info1 = &listPI->pcmkInfos[i];
      info2 = &listPI->pcmkInfos[j];

      // Check the attributes
      cmp = VDat2VerifyLikeCompare1(info1,info2);
      if (cmp) goto wrapup;
      
      // Check the geometry
      cmp = VDat2CompareGeometry(info1,info2);
      if (cmp) goto wrapup;
      
    }
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  if (traceFlag) VDlogPrintFmt(VDLOG_INFO,0,"<<< %s\n",fn);
  VDat2SetCompareFlags(0,0,0);

  if (retFlag == 0) {
    // printf("Initial group verify failed for %s %d\n",pcmk,num);
  }
  
  return retFlag;
}

/* -----------------------------------------------
 * Count how many nodes have the same piece mark
 * Always return at least 1
 */
static IGRint getNumInPcmkGroup(TVDat2PcmkInfoList *listPI, IGRint nth)
{
  VDASSERT_FN("getNumInPcmkGroup");
  
  IGRint  i;
  IGRint  num = 1;
  IGRchab pcmk1,pcmk2;
  
  // Grab the current piece mark
  VDctxGetTxtAtr(&listPI->pcmkInfos[nth].nodeID,VDCTX_ATR_SS_PIECE_PCMK,pcmk1);

  // Cycle through
  for(i = nth + 1; i < listPI->cnt; i++) {
    VDctxGetTxtAtr(&listPI->pcmkInfos[i].nodeID,VDCTX_ATR_SS_PIECE_PCMK,pcmk2);
    if (strcmp(pcmk1,pcmk2)) goto wrapup;
    num++;
  }
  
  // Done
 wrapup:
  return num;
}

/* -----------------------------------------------
 * Trying to find a home for i in a like group
 * Know that i match j
 * See if i matches the rest of the pieces in group j
 */
static IGRstat checkLikeGroup(TVDat2PcmkInfoList *listPI, IGRint i, IGRint j)
{
  VDASSERT_FN("checkLikeGroup");

  IGRstat retFlag = 0;
  
  TVDat2PcmkInfo *infoi;
  TVDat2PcmkInfo *infoj;
  TVDat2PcmkInfo *infok;

  IGRchab pcmkj;
  IGRchab pcmkk;
  
  IGRint k;
  IGRint cmp;
  
  // Setup
  infoi = &listPI->pcmkInfos[i];
  infoj = &listPI->pcmkInfos[j];

  VDctxGetTxtAtr(&infoj->nodeID,VDCTX_ATR_SS_PIECE_PCMK,pcmkj);
  
  // Cycle through
  for(k = 0; k < listPI->cnt; k++) {

    infok =  &listPI->pcmkInfos[k];
    VDctxGetTxtAtr(&infok->nodeID,VDCTX_ATR_SS_PIECE_PCMK,pcmkk);
    if (!strcmp(pcmkj,pcmkk)) {

      // Check the attributes
      cmp = VDat2VerifyLikeCompare2(infoi,infok);
      if (cmp) goto wrapup;
      
      // Check the geometry
      cmp = VDat2CompareGeometry(infoi,infok);
      if (cmp) goto wrapup;
    }
  }
  
  // Its ok
  retFlag = 1;

 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * See if any piece with empty pcmks fit into a group
 * Do a bubble search just to prevent head turning
 */
static void addEmptyPcmks(TVDat2PcmkInfoList *listPI, IGRint *nextPcmk, IGRint *changeCnt)
{
  VDASSERT_FN("addEmptyPcmks");

  IGRstat sts;
  
  IGRint  i,j;
  IGRint  cmp;
  
  IGRchab pcmk;

  TVDat2PcmkInfo *info1;
  TVDat2PcmkInfo *info2;

  IGRchar notLike1[32];
  IGRchar notLike2[32];
  
  IGRint pcmkWasSet;

  // Say hi
  //traceFlag = 1;
  if (traceFlag) printf(">>> %s\n",fn);
  
  // Cycle until no more empty marks
  for(i = 0; i < listPI->cnt; i++) {
    info1 = &listPI->pcmkInfos[i];
    VDctxGetTxtAtr(&info1->nodeID,VDCTX_ATR_SS_PIECE_PCMK,pcmk);

    // All ordered so stop when we get a piece mark
    if (*pcmk) goto wrapup;
    pcmkWasSet = 0;

    // Legacy data may have some notLike parts slipping in here
    VDctxGetTxtAtr(&info1->nodeID,VDCTX_ATR_SS_PIECE_NOT_LIKE,notLike1);

    if (traceFlag) printf("Index %d, notLike %s\n",i,notLike1);
    
    if (*notLike1 != '1') {

      
      // Search em all
      for(j = 0; j < listPI->cnt; j++) {

	// Except for itself
	if (i != j) {
	
	  info2 = &listPI->pcmkInfos[j];
	  VDctxGetTxtAtr(&info2->nodeID,VDCTX_ATR_SS_PIECE_PCMK,pcmk);
	  VDctxGetTxtAtr(&info2->nodeID,VDCTX_ATR_SS_PIECE_NOT_LIKE,notLike2);
	  if ((*pcmk) && (*notLike2 != '1')) {

	    // Check the attributes
	    cmp = VDat2VerifyLikeCompare2(info1,info2);
	    if (cmp == 0) cmp = VDat2CompareGeometry(info1,info2);
	    if (cmp == 0) {
	    
	      // Found 1 match, need to check rest of the group
	      sts = checkLikeGroup(listPI,i,j);
	      if (sts == 1) {
	      
		// Add it
		VDctxSetTxtAtr(&info1->nodeID,VDCTX_ATR_SS_PIECE_PCMK,pcmk);
		if (changeCnt) *changeCnt = *changeCnt + 1;
		j = listPI->cnt;
		pcmkWasSet = 1;
	      }
	    }
	  }
	}
      }
    }
    // Might need to add new piece mark
    if (pcmkWasSet == 0) {
      sprintf(pcmk,"%d",*nextPcmk);
      VDctxSetTxtAtr(&info1->nodeID,VDCTX_ATR_SS_PIECE_PCMK,pcmk);
      if (changeCnt) *changeCnt = *changeCnt + 1;
      *nextPcmk = *nextPcmk + 1;
    }  
  }
  
  // Done
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * At this point, have a list of possible like parts along
 * with all their surface information sorted on piece marks
 *
 * The goal is to see which groups of like parts are no longer
 * valid groups and then to select which pieces to reset to
 * make them valid with minimal impact
 */
void VDat2VerifyLikes(TVDat2PcmkInfoList *listPI,
		      TGRid  *ssID,
		      IGRint *nextPcmk,
		      IGRint *a_changeCnt)
{
  VDASSERT_FN("VDat2VerifyNotLikes");

  IGRstat sts;
  
  IGRint i,num;
  IGRint changeCnt  = 0;
  IGRint changeCntx = 0;
  IGRint flag;
  IGRint begNotZero = 0;
  
  TGRid *nodeID;

  IGRchab buf;

  TVDctxNodeList listSS;
  
  // Say hi
  //traceFlag = 1;
  if (traceFlag) printf(">>> VDat2VerifyLikes\n");
  
  // Init
  VDctxInitNodeList(&listSS);

  // Arg check
  VDASSERTW(listPI);
  if (listPI->cnt == 0) goto wrapup;
  VDASSERTW(ssID);
  
  // Start by reordering with the like part attributes
  VDat2SetCompareFlags(0,0,1);
  qsort(listPI->pcmkInfos,listPI->cnt,listPI->size,VDat2VerifyLikeCompare1);
  VDat2SetCompareFlags(0,0,0);
  
  // Cycle through
  VDlogPrintFmt(VDLOG_INFO,0,"Verifying possible like parts...");

  // Skip any pcmk 0 at the Beginning of the list
  begNotZero = listPI->cnt;
  flag = 1;
  for(i = 0; (i < listPI->cnt) && (flag); i++) {
    VDctxGetTxtAtr(&listPI->pcmkInfos[i].nodeID,VDCTX_ATR_SS_PIECE_PCMK,buf);
    if (traceFlag) printf("pcmk %d '%s'\n",i,buf);    
    if (atoi(buf) > 0) {
      flag = 0;
      begNotZero = i;
    }
  }
  if (traceFlag) printf("begNotZero %d, listPI->cnt %d\n",begNotZero,listPI->cnt);
  
  // See if they were all cleared
  if (begNotZero >= listPI->cnt) goto wrapup;

  // Check each group to see if they are all like still
  for(i = begNotZero; i < listPI->cnt; i += num) {

    // Allow Interrupts
    if (IGEstop()) {
      VDlogPrintFmt(VDLOG_ERROR,0,"Verifying stopped by user");
      goto wrapup;
    }

    // Status
    VDlogPrintFmt(VDLOG_STAT,0,"Verifying piece mark %d of %d",i+1,listPI->cnt);

    // See what the pcmk group size is
    num = getNumInPcmkGroup(listPI,i);

    // Process the group
    sts = VDat2VerifyLikeProcessGroup(listPI,i,num);

    // Did they all pass???
    if (sts == 0) {

      // First try to resolve with snapshot

      // No need to make this list unless actually have something to try
      if ((listSS.cnt == 0) && (ssID->objid != NULL_OBJID)) {
	VDctxGetListPieces(ssID,&listSS);
	VDctxSortNodeList (&listSS,VDctxCompareCompPath);
      }
      sts = VDat2VerifyLikeSnapshotGroup(listPI,i,num,&listSS);
      if (sts == 0) {
	
	/* -----------------------------------------
	 * Give up and just keep the biggest group
	 * Don't count these changes, they get reassigned later
	 * Majority rules
	 */
	/* The snapshot group may have whacked a few pieces
	 * that it knew changed.  Need to skip over these
	 */
	flag = 1;
	while(flag) {
	  if ((i >= listPI->cnt) || (num == 0)) flag = 0;
	  else {
	    VDctxGetTxtAtr(&listPI->pcmkInfos[i].nodeID,VDCTX_ATR_SS_PIECE_PCMK,buf);
	    if (*buf) flag = 0;
	    else {
	      i++;
	      num--;
	    }
	  }
	}
	    
	// Do the rest
	if (num) keepBiggestGroup(listPI,i,num,&changeCntx);
      }
    }
  }

  // Useful to stop here and see what got whacked
  // VDat2VerifyLikePrintList(listPI);
  
  // Sort again to put any whacked marks at the top
  VDat2SetCompareFlags(0,0,1);
  qsort(listPI->pcmkInfos,listPI->cnt,listPI->size,VDat2VerifyLikeCompare1);
  VDat2SetCompareFlags(0,0,0);

  // Now go through and see if any of the empty pcmks can
  // Be added to a group
  if (traceFlag) printf("About to call addEmptyPcmks\n");
  addEmptyPcmks(listPI,nextPcmk,&changeCnt);
  
  // Update master counter
  if (a_changeCnt) *a_changeCnt = *a_changeCnt + changeCnt;
  
  // Done
  VDlogPrintFmt(VDLOG_INFO,0,"Verified possible like parts, change count %d",changeCnt);

  // VDat2VerifyLikePrintList(listPI);
  
 wrapup:
  VDctxFreeNodeList(&listSS);
  return;
}



