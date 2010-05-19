/* $Id: VDvalPcmk.c,v 1.2 2001/08/24 20:00:49 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdval/x2/VDvalPcmk.c
 *
 * Description:	Piece Mark Validation
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDvalPcmk.c,v $
 *      Revision 1.2  2001/08/24 20:00:49  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/06/22 15:18:30  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 06/15/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDrisc.h"
#include "VDtest.h"
#include "VDctx.h"
#include "VDctz.h"
#include "VDval.h"

VDASSERT_FFN("vdval/x2/VDvalPcmk.c");


/* -----------------------------------------------
 * Add a node to the piece mark tree unless
 * the piece mark has already been added
 */
static void addPcmkNode(TGRid *nodeID, void *treeIDx, IGRint *stopWalk)
{
  VDASSERT_FN("addPcmkNode");

  TGRid  *treeID = treeIDx;
  TGRid   pcmkID;
  IGRint  i,pcmki;
  IGRchab pcmk;
  IGRchab pcmkx;
  IGRchab type;
  IGRchab name;
  
  // See if the node has a piece mark
  if (!VDctzIsStagingPiece(nodeID)) goto wrapup;

  // Save name and type for later
  VDctzGetStagingType(nodeID,type);
  VDctzGetStagingName(nodeID,name);
  
  // Get the piece mark
  VDctzGetPieceMark(nodeID,pcmk);  
  if (*pcmk == 0) {
    VDlogPrintFmt(VDLOG_ERROR,0,"\nTree node has no piece mark %s %s",type,name);
    goto wrapup;
  }

  // Just to be safe
  pcmki = atoi(pcmk);
  sprintf(pcmk,"%d",pcmki);
  
  // Look it up in the tree
  for(i = 0; VDctxGetNthTreeChild(treeID,i,&pcmkID); i++) {
    VDctzGetPieceMark(&pcmkID,pcmkx);
    if (!strcmp(pcmk,pcmkx)) goto wrapup;
  }
  
  // Need to create one
  VDctxCreateNode(treeID,"pcmk",NULL,&pcmkID);
  VDASSERTW(pcmkID.objid != NULL_OBJID);
  VDctxAppTxtAtr(&pcmkID,"pcmk",pcmk);
  VDctxAppTxtAtr(&pcmkID,"piece_type",type);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Process one plate against the pcmk tree
 */
static void processPcmkPlate(TGRid *plateID, void *treeIDx, IGRint *stopWalk)
{
  VDASSERT_FN("processPcmkPlate");

  TGRid  *treeID = treeIDx;
  TGRid   pcmkID;
  IGRint  i,pcmki;
  IGRchab pcmk;
  IGRchab pcmkx;
  IGRchab parent;
  IGRchab name;
  IGRint  cnti;
  IGRchab cnt;
  
  // Only want plates
  if (!VDctzIsPlate(plateID)) goto wrapup;
  
  VDctzGetStagingParentName(plateID,parent);
  VDctzGetPieceName(plateID,name);

  // Grab the piece mark
  VDctzGetPieceMark(plateID,pcmk);
  if (*pcmk == 0) {
    VDlogPrintFmt(VDLOG_ERROR,0,"\nPlate has no piece mark %s %s",
		  parent,name);
    goto wrapup;
  }

  // Just to be safe
  pcmki = atoi(pcmk);
  sprintf(pcmk,"%d",pcmki);
  
  // Look it up in the tree
  for(i = 0; VDctxGetNthTreeChild(treeID,i,&pcmkID); i++) {
    VDctxGetTxtAtr(&pcmkID,"pcmk",pcmkx);
    if (!strcmp(pcmk,pcmkx)) {
      VDctxGetTxtAtr(&pcmkID,"plate_cnt",cnt);
      cnti = atoi(cnt);
      if (cnti) {
	VDlogPrintFmt(VDLOG_ERROR,0,"\nPlate piece mark %s unwrapped more than once %s",
		      pcmk,parent,name);
      }
      cnti++;
      sprintf(cnt,"%d",cnti);
      VDctxAppTxtAtr(&pcmkID,"plate_cnt",cnt);
      goto wrapup;
    }
  }
  
  // Not in tree
  VDlogPrintFmt(VDLOG_ERROR,0,"\nPlate piece mark %s not in staging tree %s %s",
		pcmk,parent,name);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Want to make sure that every pcmk in the tree
 * has been unwrapped once (and only once)
 *
 * Use an intermediate tree for this
 */
void VDvalValidateStagingPieceMarks(TGRid *stagingID, TGRid *platesID)
{
  VDASSERT_FN("VDvalValidateStagingPieceMarks");
  
  TGRid   pcmkIDs;
  TGRid   pcmkID;
  IGRchab cnt;
  IGRchab type;
  IGRchab pcmk;
  IGRint  stopWalk = 0;
  IGRint  i,cnti;
  
  // Init
  pcmkIDs.objid = NULL_OBJID;
  
  // Arg check
  VDASSERTW(stagingID && stagingID->objid != NULL_OBJID);
  VDASSERTW(platesID  &&  platesID->objid != NULL_OBJID);
  
  // Make the working tree
  VDctxCreateXdomTree("pcmks",NULL,&pcmkIDs);
  VDASSERTW(pcmkIDs.objid != NULL_OBJID);
  
  // Walk through and fill it up with piece marks
  VDctxWalkNode(stagingID,1,addPcmkNode,&pcmkIDs,&stopWalk);

  // Bounce the plates against it
  VDctxWalkNode(platesID,1,processPcmkPlate,&pcmkIDs,&stopWalk);

  // Final check
  for(i = 0; VDctxGetNthTreeChild(&pcmkIDs,i,&pcmkID); i++) {

    // Only check plates
    VDctxGetTxtAtr(&pcmkID,"piece_type",type);
    if (!strcasecmp(type,"PLATE")) {
      
      // Need at least one unwrap
      VDctxGetTxtAtr(&pcmkID,"pcmk",pcmk);
      VDctxGetTxtAtr(&pcmkID,"plate_cnt",cnt);
      cnti = atoi(cnt);
      switch(cnti) {
	case 1: break;
	case 0:
	  VDlogPrintFmt(VDLOG_ERROR,0,"Piece mark %-4s was not unwrapped",pcmk);
	break;
	default:
	  VDlogPrintFmt(VDLOG_ERROR,0,"Piece mark %-4s was unwrapped %d times",pcmk,cnti);	  
      }
    }
  }
  
 wrapup:
  VDctxDeleteNode(&pcmkIDs);
}
