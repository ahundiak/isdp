/* $Id: VDatInfo.c,v 1.4 2001/10/19 18:22:34 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk2/VDatInfo.c
 *
 * Description: Piece mark Info Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatInfo.c,v $
 *      Revision 1.4  2001/10/19 18:22:34  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/03/22 18:45:51  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/22 14:42:19  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/18 22:49:46  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/03/16 17:10:45  ahundiak
 *      *** empty log message ***
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/13/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"

#include "VDlog.h"
#include "VDctx.h"
#include "VDss.h"
#include "VDat.h"
#include "VDfrmc.h"

#include "VDat2Pcmk.h"

#include "time.h"

VDASSERT_FFN("vdat/pcmk2/VDatInfo.c");

/* -----------------------------------------------
 * Fill in the srfTranInfo 
 */
void VDat2FillSrfTranInfo(TVDat2PcmkInfo *info)
{
  VDASSERT_FN("VDat2FillSrfTranInfo");
  IGRstat sts;
  
  IGRint i;
  IGRint doit;
  
  TGRobj_env pieceOE;
  IGRchab    buf;

  // Arg check
  VDASSERTW(info && info->nodeID.objid != NULL_OBJID);
  
  // Init srfTran
  VDefpInitSrfTranInfo(&info->srfTranInfo);
  
  // Filter certain items
  doit = 1;

  // Skip standard pieces
  VDctxGetTxtAtr(&info->nodeID,VDCTX_ATR_SS_PIECE_PCMK_KEY,buf);
  if (*buf) {
    info->isStd = 1;
    doit = 0;
  }
  
  // Skip not like parts
  VDctxGetTxtAtr(&info->nodeID,VDCTX_ATR_SS_PIECE_NOT_LIKE,buf);
  if (*buf == '1') {
    info->isNotLike = 1;
    doit = 0;
  }
  
  // Done filtering
  if (doit == 0) goto wrapup;

  // Need the model object
  VDctxGetModelObject(&info->nodeID,&pieceOE);
  VDASSERTW(pieceOE.obj_id.objid != NULL_OBJID);

  // Fill
  sts = VDefpGetSrfTranInfo(&pieceOE,&info->srfTranInfo);
  VDASSERTW(sts == 1);

  // Add some attributes to the data
  VDctxAppDblAtr(&info->nodeID,VDCTX_ATR_SS_SRF_EDGE_LEN,  info->srfTranInfo.edgeLen);
  VDctxAppDblAtr(&info->nodeID,VDCTX_ATR_SS_SRF_CENTER_MIN,info->srfTranInfo.center_minor_distance);
  VDctxAppIntAtr(&info->nodeID,VDCTX_ATR_SS_SRF_CUTOUT_CNT,info->srfTranInfo.inner.cnt);
  VDctxAppDblAtr(&info->nodeID,VDCTX_ATR_SS_SRF_CUTOUT_DIS,info->srfTranInfo.cutout_distance);
  
  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Given a tree and a filled in list of node information
 * build and fill in the piece mark information list
 */
void VDat2FillPcmkInfoList(TGRid              *treeID, 
			   TVDctxNodeList     *listPM, 
			   TVDat2PcmkInfoList *listPI)
{
  VDASSERT_FN("VDat2FillPcmkInfoList");

  TVDat2PcmkInfo *info;
  
  IGRint i;

  time_t begTime;
  time_t endTime;
  
  // Arg check
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);
  VDASSERTW(listPM && listPM->cnt);
  VDASSERTW(listPI);
  
  // Init
  VDat2InitPcmkInfoList(listPI);
  time(&begTime);
  
  // Allocate room for infos
  listPI->pcmkInfos = calloc(listPM->cnt,listPI->size);
  VDASSERTW(listPI->pcmkInfos);
  listPI->cnt = listPI->max = listPM->cnt;
  
  // Xfer tree
  listPI->treeID = *treeID;

  // Say hi
  VDlogPrintFmt(VDLOG_INFO,0,"Getting surface info...");
  
  // Xfer nodes
  for(i = 0; i < listPM->cnt; i++) {

    // Get the info
    info = &listPI->pcmkInfos[i];

    // Status
    if (!(i % 10)) {
      VDlogPrintFmt(VDLOG_STAT,0,"Getting surface info %d of %d",i+1,listPM->cnt);
    }

    // Xfer node
    info->nodeID = listPM->listIDs[i];

    // Generate srfTranInfo
    VDat2FillSrfTranInfo(info);
  }
  
  // Done
  time(&endTime);
  VDlogPrintFmt(VDLOG_INFO,0,"Done getting surface info, Time %d",endTime - begTime);

 wrapup:
  return;
}

/* -----------------------------------------------
 * Initialize piece mark infolist structure
 */
void VDat2InitPcmkInfoList(TVDat2PcmkInfoList *listPI)
{
  VDASSERT_FN("VDat2InitPcmkInfoList");
  
  // Arg check
  VDASSERTW(listPI);
  
  // Clear
  memset(listPI,0,sizeof(TVDat2PcmkInfoList));
  
  // Flag
  listPI->treeID.objid = NULL_OBJID;
  listPI->size = sizeof(TVDat2PcmkInfo);
  
  // Done
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Frees piece mark infolist structure
 */
void VDat2FreePcmkInfoList(TVDat2PcmkInfoList *listPI)
{
  VDASSERT_FN("VDat2FreePcmkInfoList");
  
  IGRint i;

  TVDat2PcmkInfo *info;

  // Arg check
  VDASSERTW(listPI);

  // Cycle through
  for(i = 0; i < listPI->cnt; i++) {
    info = &listPI->pcmkInfos[i];
    VDefpFreeSrfTranInfo(&info->srfTranInfo);
  }
  
  // Get rid of the list
  if (listPI->pcmkInfos) free(listPI->pcmkInfos);
  
  // Reinit
  VDat2InitPcmkInfoList(listPI);
  
  // Done
  
 wrapup:
  return;
}
