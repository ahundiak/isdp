/* $Id: VDatVerNot.c,v 1.7 2002/05/03 15:22:23 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk2/VDatVerStd.C
 *
 * Description: Not like Verification Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatVerNot.c,v $
 *      Revision 1.7  2002/05/03 15:22:23  ahundiak
 *      ah
 *
 *      Revision 1.6  2002/05/03 13:41:37  ahundiak
 *      ah
 *
 *      Revision 1.5  2001/10/19 18:22:34  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/09/07 19:18:08  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/04/06 12:45:59  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/22 21:46:00  ahundiak
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

VDASSERT_FFN("vdat/pcmk2/VDatVerNot.c");

/* -----------------------------------------------
 * See if a node is not like
 */
IGRstat VDat2IsNotLike(TGRid *nodeID)
{
  VDASSERT_FN("VDat2IsNotLike");

  IGRstat isNotLike = 1;
  
  IGRchab buf;
  IGRchab type;
  
  IGRdouble height,area;

  // printf(">>> %s\n",fn);
  
  // Arg check
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);
  
  // Standard pieces are NotLike
  VDctxGetPieceMark(nodeID,buf);
  if (VDat2IsStdPcmk(buf,0)) goto wrapup;

  // Pieces with keys are NotLike
  VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_PCMK_KEY,buf);
  if (*buf) goto wrapup;
  
  // Really don't want to calc key but will if need to

  // Plate or beam
  VDctxGetNodeTypeSuffix(nodeID,type);

  // Plates
  if (!strcmp(type,VDCTX_NODE_TYPE_PLATE)) {
    
    // Must be planar
    VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PLATE_IS_PLANAR,buf);
    if (*buf != '1') goto wrapup;

    // Check the min area
    VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PLATE_AREA,buf);
    area = atof(buf);
    if (area > VDAT2_PCMK_MAX_LIKE_PLATE_AREA) goto wrapup;

    // Plates with any sort of bevels are not like
    VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PLATE_BEVELS,buf);
    if (*buf == '1') {
      // printf("### Like plate with a bevel\n");
      goto wrapup;
    }

    // Might be like
    isNotLike = 0;
    goto wrapup;    
  }  

  // Beams
  if (!strcmp(type,VDCTX_NODE_TYPE_BEAM)) {

    /* -------------------------------------------
     * Imposing this restriction will cause some of the
     * pcmk1 assigned likes to fail
     * Turn back on and research later to see why
     *
     * Maybe webs really are planar
     * Or maybe it's ok
     */
    // Must be planar
    VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_BEAM_IS_PLANAR,buf);
    // if (*buf != '1') goto set_it;

    // Height restriction
    VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_BEAM_HEIGHT,buf);
    height = atof(buf);
    if (height > VDAT2_PCMK_MAX_LIKE_BEAM_HEIGHT) goto wrapup;

    // Might be like
    isNotLike = 0;
    goto wrapup;
  }

  // Oh Oh
  VDASSERTW(0);
  
  // Done
 wrapup:
  return isNotLike;
}

/* -----------------------------------------------
 * Verify a given not like part
 */
static void VDat2VerifyNotLike(TVDctxNodeList *listPM, IGRint nth, TGRid *nodeID, IGRint *changeCnt)
{
  VDASSERT_FN("VDat2VerifyNotLike");

  IGRchab buf;
  IGRchab pcmk;
  IGRchab pcmkx;
  IGRchab type;
  
  IGRint stopFlag;
  IGRint probFlag;
  IGRint i;
  
  // Arg check
  VDASSERTW(listPM);
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);
  
  // Dont care about standard pieces
  VDctxGetPieceMark(nodeID,pcmk);

  // Not sure about this, they may or may not be around
  // if (VDat2IsStdPcmk(pcmk,0)) goto wrapup;

  // Only care about notLike parts
  if (VDat2IsNotLike(nodeID) == 0) goto wrapup;
  
  // Flag for future use
  VDctxAppTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_NOT_LIKE,"1");

  /* One possible complication is that a previously like part
   * may now be a not like part, if so need to reset it's
   * piece mark
   *
   * Kind of a pain here but just work through it
   */
  /* If it has no piece mark then don't worry at all */
  if (*pcmk == 0) goto wrapup;
  
  // Look backwards
  probFlag = 0;
  stopFlag = 1;
  for(i = nth - 1; (i >= 0) && (stopFlag); i--) {

    // Get the previous mark
    VDctxGetPieceMark(&listPM->listIDs[i],pcmkx);

    // Maybe previous one was wacked
    if (*pcmkx) {
      if (!strcmp(pcmk,pcmkx)) probFlag = 1;
      stopFlag = 0;
    }
  }
  // Also look ahead on, need not worry about them being cleared
  i = nth + 1;
  if (i < listPM->cnt) {
    VDctxGetPieceMark(&listPM->listIDs[i],pcmkx);
    if (!strcmp(pcmk,pcmkx)) probFlag = 1;
  }

  // Have a not like part which is in a like part set
  if (probFlag) {

    // Reset the piece mark
    VDctxSetPieceMark(nodeID,"");
    *changeCnt = *changeCnt + 1;

    // Show a message
    VDlogPrintFmt(VDLOG_ERROR,1,"*** ----------------------------------------");
    VDlogPrintFmt(VDLOG_ERROR,1,"*** compareLikeNodesError %s","No longer Like");

    VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_COMP_PATH,buf);
    VDlogPrintFmt(VDLOG_ERROR,1,"1   %s",buf);
 
    VDlogPrintFmt(VDLOG_ERROR,1,"1   %s",pcmk);

    VDctxGetTxtAtr(nodeID,"piece_stage",buf);
    VDlogPrintFmt(VDLOG_ERROR,1,"1   %s",buf);
 
    VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_COMP_TAG,buf);
    VDlogPrintFmt(VDLOG_ERROR,1,"1   %s",buf);
    
    goto wrapup;
  }
  
  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Given a list, set the not like flags and see
 * about any problems that may result
 * List is sorted by piece mark
 */
void VDat2VerifyNotLikes(TVDctxNodeList *listPM, IGRint *a_changeCnt)
{
  VDASSERT_FN("VDat2VerifyNotLikes");

  IGRint i;
  IGRint changeCnt = 0;
  TGRid *nodeID;
    
  // Arg check
  VDASSERTW(listPM);
  if (listPM->cnt == 0) goto wrapup;
  
  // Cycle through
  VDlogPrintFmt(VDLOG_INFO,0,"Verifying not likes...");

  // Cycle through
  for(i = 0; i < listPM->cnt; i++) {

    // Allow Interrupts
    if (IGEstop()) {
      VDlogPrintFmt(VDLOG_ERROR,0,"Verification stopped by user");
      goto wrapup;
    }

    // Status
    if (!(i % 10)) {
      VDlogPrintFmt(VDLOG_STAT,0,"Verifying not like part %d of %d",i+1,listPM->cnt);
    }

    // Grab some data
    nodeID = &listPM->listIDs[i];
    VDat2VerifyNotLike(listPM,i,nodeID,&changeCnt);    
  }

  // Update master counter
  // Dont save, they get counted later when new mark is assigned
  //if (a_changeCnt) *a_changeCnt = *a_changeCnt + cnt;
  
  // Done
  VDlogPrintFmt(VDLOG_INFO,0,"Verified not like parts, changed %d pieces",changeCnt);
  
 wrapup:
  return;
}
