/* $Id: VDatVerStd.c,v 1.4 2001/11/16 14:29:25 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk2/VDatVerStd.C
 *
 * Description: Standard Piece Mark Verification Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatVerStd.c,v $
 *      Revision 1.4  2001/11/16 14:29:25  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/10/19 18:22:34  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/04/06 12:45:59  ahundiak
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

VDASSERT_FFN("vdat/pcmk2/VDatVerStd.c");

/* -----------------------------------------------
 * Verify a given possible standard piece mark
 */
void VDat2VerifyStdPcmk(TGRid *nodeID, IGRint isLoggedIn, IGRint *cnt)
{
  VDASSERT_FN("VDat2VerifyStdPcmk");

  IGRchab key;
  IGRchab pcmk;
  IGRchab std_pcmk;

  IGRint isStd;
  
  TGRobj_env modelOE;
  
  // Arg check
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);
  VDASSERTW(cnt);

  // Calc the key
  VDctxGetModelObject(nodeID,&modelOE);
  VDvalGetStdPcmk1Key(&modelOE,key);
  if (*key) {
    VDctxAppTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_PCMK_KEY,key);
  }
  
  // Get any existing piece mark
  VDctxGetPieceMark(nodeID,pcmk);  
  isStd = VDat2IsStdPcmk(pcmk,0);

  // No key set
  if (*key == 0) {

    // Make sure existing mark is not standard
    if (isStd == 0) goto wrapup;
	
    // Clear it
    VDctxSetPieceMark(nodeID,"");    
    *cnt = *cnt + 1;
    goto wrapup;
  }
  
  // If logged in, lookup the mark
  if (isLoggedIn) {

    // Get the pcmk
    VDat2GetStdPcmkForKey(1,key,std_pcmk);
    if (*std_pcmk == 0) {

      // Got big problems, leave things alone
      VDlogPrintFmt(VDLOG_ERROR,1,"Could not lookup standard piece mark key '%s'",key);
      *cnt = *cnt + 1;
      goto wrapup;
    }
    
    // See if they match
    if (!strcmp(pcmk,std_pcmk)) goto wrapup;
    
    // Need to update
    VDctxSetPieceMark(nodeID,std_pcmk);
    *cnt = *cnt + 1;
    goto wrapup;
  }
  
  // If not logged in, just make sure have a standard piece
  if (isStd) goto wrapup;
  
  // Set at 9999
  sprintf(std_pcmk,"%d",VDAT2_MAX_STD_PCMK);
  VDctxSetPieceMark(nodeID,std_pcmk);
  *cnt = *cnt + 1;
  
  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Given a list, verify the standard piece mark
 * assignments adding or deleting as
 * required
 */
void VDat2VerifyStdPcmks(TVDctxNodeList *listPM, IGRint *a_cnt)
{
  VDASSERT_FN("VDat2VerifyStdPcmks");

  IGRint i;
  IGRint cnt = 0;
  IGRint isLoggedIn;  
  TGRid *nodeID;
    
  // Arg check
  VDASSERTW(listPM);
  if (listPM->cnt == 0) goto wrapup;
  
  // See if logged in
  isLoggedIn = VDrisIsSchemaOpen();
  
  // Cycle through
  VDlogPrintFmt(VDLOG_INFO,0,"Verifying standard piece marks...");

  // Cycle through
  for(i = 0; i < listPM->cnt; i++) {

    // Allow Interrupts
    if (IGEstop()) {
      VDlogPrintFmt(VDLOG_ERROR,0,"Verification stopped by user");
      goto wrapup;
    }

    // Status
    if (!(i % 10)) {
      VDlogPrintFmt(VDLOG_STAT,0,"Verifying standard piece mark %d of %d",i+1,listPM->cnt);
    }

    // Grab some data
    nodeID = &listPM->listIDs[i];
    VDat2VerifyStdPcmk(nodeID,isLoggedIn,&cnt);    
  }

  // Update master counter
  if (a_cnt) *a_cnt = *a_cnt + cnt;
  
  // Done
  VDlogPrintFmt(VDLOG_INFO,0,"Verified standard piece marks, changed %d pieces",cnt);
  
 wrapup:
  return;
}
