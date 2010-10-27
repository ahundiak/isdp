/* $Id: VDatStd.c,v 1.10 2002/05/09 17:47:47 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk2/VDatStd.c
 *
 * Description: Standard Piece Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatStd.c,v $
 *      Revision 1.10  2002/05/09 17:47:47  ahundiak
 *      ah
 *
 *      Revision 1.9  2001/11/16 22:24:04  ahundiak
 *      ah
 *
 *      Revision 1.8  2001/11/16 14:29:25  ahundiak
 *      ah
 *
 *      Revision 1.7  2001/10/19 18:22:34  ahundiak
 *      ah
 *
 *      Revision 1.6  2001/04/09 16:19:08  paul_noel
 *      ah
 *
 *      Revision 1.5  2001/04/04 14:16:31  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/04/02 20:56:03  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/03/22 14:42:19  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/18 22:50:17  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/16 17:10:45  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/13/01  ah      Creation
 * 04/02/01  ah      Added VDatGetStdPcmkKey from pcmk/VDatStd.I
 *                   Moved Like functions to VDatLike.c
 * 04/03/01  ah      TR3297
 * 04/09/01  ah      Added VDmacGetFoot macro
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDlog.h"
#include "VDrisc.h"
#include "VDobj2.h"
#include "VDctx.h"
#include "VDss.h"
#include "VDat.h"
#include "VDat2Pcmk.h"

VDASSERT_FFN("vdat/pcmk2/VDatStd.c");

/* -----------------------------------------------
 * Replaced with VDvalGetStdPcmk1Key
&/
IGRstat VDatGetStdPcmkKey(TGRobj_env *pieceOE, IGRchar *key)
{
  VDASSERT_FN("VDatGetStdPcmkKey");
  VDASSERTW(0);
 wrapup:
  return;
}

/* -----------------------------------------------
 * Given a list of pieces, fill in the standard key
 * if one exists
 */
void VDat2SetStdPcmkKeys(TVDctxNodeList *listPM)
{
  VDASSERT_FN("VDat2SetStdPcmkKeys");
  
  IGRint i;
  TGRid     *nodeID;
  TGRobj_env modelOE;

  IGRchab buf;
  
  // Arg check
  VDASSERTW(listPM && listPM->listIDs);
  
  // Cycle through
  for(i = 0; i < listPM->cnt; i++) {

    // Status
    if (!(i % 10)) {
      VDlogPrintFmt(VDLOG_STAT,0,"Setting standard key for %d of %d",i+1,listPM->cnt);
    }

    nodeID = &listPM->listIDs[i];

    VDctxGetModelObject(nodeID,&modelOE);
    VDvalGetStdPcmk1Key(&modelOE,buf);
    if (*buf) {
      VDctxAppTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_PCMK_KEY,buf);
    }
  }
  VDlogPrintFmt(VDLOG_STAT,0,"Done setting standard keys");
  
  // Done
 wrapup:
  return;
}
#define NEXT_PCMK "ZNEXT_STD_PCMK"

/* -----------------------------------------------------------------
 * Given a key, lookup the actual piece mark
 * Create it if need be based on flag
 *
 * Add a cache call to it
 */
void VDat2GetStdPcmkForKey(IGRint createFlag, IGRchar *key, IGRchar *pcmk)
{
  VDASSERT_FN("VDat2GetStdPcmkForKey");

  IGRint pcmkx;

  IGRchab sql;
  IGRchab buf;

  TGRid recordIDs;
  TGRid recordID;

  TVDrisInfo ris;

  // Init
  VDrisInitInfo(&ris);

  // Arg check
  VDASSERTW(pcmk); *pcmk = 0;
  VDASSERTW(key && *key);

  // Say hi
  if (traceFlag) printf(">>> %s %d '%s'\n",fn,createFlag,key);  
 
  // Make sure logged in
  if (VDrisIsSchemaOpen() == 0) goto wrapup;

  // Look it up
  snprintf(sql,sizeof(sql),
          "Select pcmk from std_pcmk where std_key = '%s';",key);
  VDrisDomQueryCache(VDRIS_CACHE_VDS,sql,&recordIDs);
  VDctxGetNthTreeChild(&recordIDs,0,&recordID);
  if (recordID.objid != NULL_OBJID) {

    // Pull out the attribute
    VDctxGetTxtAtr(&recordID,"pcmk",buf);
    VDASSERTW(*buf);

    // Little bit of paranoi never hur
    pcmkx = atoi(buf);
    sprintf(pcmk,"%d",pcmkx);
    goto wrapup;
  }
  // Done if flag is not set
  if (createFlag == 0) goto wrapup;
    
  // Need the next number
  sprintf(ris.sql,"Select pcmk from std_pcmk where std_key = '%s';",NEXT_PCMK);
  VDrisQuery(&ris,NULL);

  // Check it
  if (ris.rows > 0) {

    // Update it
    pcmkx = atoi(ris.buf[0]);
    sprintf(sql,
	    "Update std_pcmk set pcmk = %d where std_key = '%s';",
	    pcmkx + 1,NEXT_PCMK);
    VDrisExecute(sql);
  }
  else {
    // First one
    pcmkx = VDAT2_MIN_STD_PCMK;
    sprintf(ris.sql,
	    "Insert into std_pcmk values ('%s',%d);",
	    NEXT_PCMK,pcmkx+1);
    VDrisExecute(sql);
  }
  VDrisFreeInfo(&ris);
  
  // Add new pcmk
  sprintf(sql,
	  "Insert into std_pcmk values ('%s',%d);",
	  key,pcmkx);
  VDrisExecute(sql);
  sprintf(pcmk,"%d",pcmkx);
  
  // Fool the cache here
  VDctxCreateNode(&recordIDs,"record",NULL,&recordID);
  VDctxAppTxtAtr (&recordID, "pcmk",pcmk);

  // Done
  
wrapup:
  
  // Just to be safe
  VDrisFreeInfo(&ris);
  
  // Say Bi
  if (traceFlag) printf("<<< %s\n",fn);

  return;
}

/* -----------------------------------------------
 * Little routine to test for being standard
 */
IGRstat VDat2IsStdPcmk(IGRchar *pcmkc, IGRint pcmki)
{
  // Allow either input
  if (pcmkc && *pcmkc) pcmki = atoi(pcmkc);
  
  if ((pcmki >= VDAT2_MIN_STD_PCMK) && (pcmki <= VDAT2_MAX_STD_PCMK)){
    return 1;
  }
  return 0;
}

/* -----------------------------------------------
 * For each piece with a standard key, fill in the
 * actual piece mark
 *
 * The std piece mark key must have already been set
 *
 * Count how many were changed to allow updating list
 * if necessary
 *
 * Might still need some kind of check to see if
 * items with std piece marks but no key need to be flagged
 */
void VDat2SetStdPcmks(TVDctxNodeList *listPM, IGRint *changeCnt)
{
  VDASSERT_FN("VDat2SetStdPcmks");
  
  IGRint i;
  TGRid     *nodeID;
  TGRobj_env modelOE;

  IGRchab key;
  IGRchab pcmk1;
  IGRchab pcmk2;
  
  // Arg check
  VDASSERTW(listPM && listPM->listIDs);
  VDASSERTW(changeCnt);
  
  // No use if not logged in
  if (VDrisIsSchemaOpen() == 0) goto wrapup;

  // Say Hi
  VDlogPrintFmt(VDLOG_INFO,0,"Setting standard piece marks...");
  
  // Cycle through
  for(i = 0; i < listPM->cnt; i++) {

    // Status
    if (!(i % 10)) {
      VDlogPrintFmt(VDLOG_STAT,0,"Setting standard piece marks for %d of %d",i+1,listPM->cnt);
    }

    // Get the key
    nodeID = &listPM->listIDs[i];
    VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_PCMK_KEY,key);
    if (*key) {

      // Look it up
      VDat2GetStdPcmkForKey(1,key,pcmk1);
      if (*pcmk1) {
	VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_PCMK,pcmk2);
	if (strcmp(pcmk1,pcmk2)) {	  
	  VDctxAppTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_PCMK,pcmk1);
	  // VDlogPrintFmt(VDLOG_INFO,0,"Updated std pcmk from '%s' to '%s'",pcmk2,pcmk1);
	  *changeCnt = *changeCnt + 1;
	}
      }
      else VDlogPrintFmt(VDLOG_ERROR,0,"*** No STD PCMK For key '%s'",key);
    }
    else {
      // Just make sure not already set
      VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_PCMK,pcmk2);
      if (VDat2IsStdPcmk(pcmk2,0)) {

	// Reset it
	VDctxAppTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_PCMK,"");
	*changeCnt = *changeCnt + 1;
	// VDlogPrintFmt(VDLOG_INFO,0,"Piece '%s' is no longer standard",pcmk2);
      }  
    }
  }
  VDlogPrintFmt(VDLOG_INFO,0,"Done setting standard piece marks, changed %d",*changeCnt);
  
  // Done
 wrapup:
  return;
}
  
