/* $Id: VDatVerLikeMisc.c,v 1.2 2001/10/19 18:22:34 ahundiak Exp $  */

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
 *      $Log: VDatVerLikeMisc.c,v $
 *      Revision 1.2  2001/10/19 18:22:34  ahundiak
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

VDASSERT_FFN("vdat/pcmk2/VDatVerLike.c");


/* -----------------------------------------------
 * Within a piece mark group, sort on all
 * the actual like part attributes
 */
IGRint VDat2VerifyLikeCompare1(const void *v1, const void *v2)
{
  VDASSERT_FN("VDat2VerifyLikeCompare1");
  
  TVDat2PcmkInfo *info1 = (TVDat2PcmkInfo *)v1;
  TVDat2PcmkInfo *info2 = (TVDat2PcmkInfo *)v2;
  
  TGRid *node1ID;
  TGRid *node2ID;

  IGRchab buf1, buf2;
  IGRchab name1,name2;
  IGRchab type1,type2;
  
  IGRint cmp;

  // Node oriented
  node1ID = &info1->nodeID;
  node2ID = &info2->nodeID;

  // Start with piece marks
  cmp = VDat2ComparePcmks(node1ID,node2ID);
  if (cmp) goto wrapup;
 
  // Divide on plates and beams
  VDctxGetNodeTypeSuffix(node1ID,type1);
  VDctxGetNodeTypeSuffix(node2ID,type2);
  cmp = strcmp(type1,type2); if (cmp) goto wrapup;

  // Common piece attributes
  cmp = VDat2ComparePieceAttributes(node1ID,node2ID);
  if (cmp) goto wrapup;
  
  // Plates
  if (!strcmp(type1,VDCTX_NODE_TYPE_PLATE)) {

    // Standard check
    cmp = VDat2ComparePlateAttributes(node1ID,node2ID);
    if (cmp) goto wrapup;

    // They match
    cmp = 0;
    goto wrapup;
  
  }
      
  // Beams
  if (!strcmp(type1,VDCTX_NODE_TYPE_BEAM)) {

    // Standard check
    cmp = VDat2CompareBeamAttributes(node1ID,node2ID);
    if (cmp) goto wrapup;

    // They match
    cmp = 0;
    goto wrapup;
    
  }

  // Big Problem
  cmp = 0;
  VDASSERTW(0);
  
 wrapup:
  return cmp;
}

/* -----------------------------------------------
 * Use this when testing to see if n item without
 * a piece mark might go into a group
 * The difference between this and Compare 1 is that
 * this guy does not check piece marks
 */
IGRint VDat2VerifyLikeCompare2(const void *v1, const void *v2)
{
  VDASSERT_FN("VDat2VerifyLikeCompare2");
  
  TVDat2PcmkInfo *info1 = (TVDat2PcmkInfo *)v1;
  TVDat2PcmkInfo *info2 = (TVDat2PcmkInfo *)v2;
  
  TGRid *node1ID;
  TGRid *node2ID;

  IGRchab buf1, buf2;
  IGRchab name1,name2;
  IGRchab type1,type2;
  
  IGRint cmp;

  // Node oriented
  node1ID = &info1->nodeID;
  node2ID = &info2->nodeID;

  // Divide on plates and beams
  VDctxGetNodeTypeSuffix(node1ID,type1);
  VDctxGetNodeTypeSuffix(node2ID,type2);
  cmp = strcmp(type1,type2); if (cmp) goto wrapup;

  // Common piece attributes
  cmp = VDat2ComparePieceAttributes(node1ID,node2ID);
  if (cmp) goto wrapup;
  
  // Plates
  if (!strcmp(type1,VDCTX_NODE_TYPE_PLATE)) {

    // Standard check
    cmp = VDat2ComparePlateAttributes(node1ID,node2ID);
    if (cmp) goto wrapup;

    // They match
    cmp = 0;
    goto wrapup;
  
  }
      
  // Beams
  if (!strcmp(type1,VDCTX_NODE_TYPE_BEAM)) {

    // Standard check
    cmp = VDat2CompareBeamAttributes(node1ID,node2ID);
    if (cmp) goto wrapup;

    // They match
    cmp = 0;
    goto wrapup;
    
  }

  // Big Problem
  cmp = 0;
  VDASSERTW(0);
  
 wrapup:
  return cmp;
}

/* -----------------------------------------------
 * Print one node for debugging
 */
void VDat2VerifyLikePrintNode(IGRint nth, IGRint group,TGRid *nodeID)
{
  VDASSERT_FN("VDat2VerifyLikePrintNode");
  
  IGRchab   buf;
  IGRchab   name;
  IGRchab   type;
  IGRchab   pcmk;
  IGRchab   family;
  IGRchab   part_num;
  IGRchab   material;
  IGRchab   grade;
  IGRchab   notLike;

  IGRchar   std[8];
  IGRdouble area;
 
  // Gather
  VDctxGetCompName(      nodeID,name);
  VDctxGetNodeTypeSuffix(nodeID,type);

  VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_FAMILY,  family);

  // Couple of very long ones (PCG stuff), just trunc em
  VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_PART_NUM,part_num);
  *(part_num + 15) = 0;
  
  VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_MATERIAL,material);

  // Couple of very long ones (PCG stuff), just trunc em
  VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_GRADE,grade);
  *(grade+8) = 0;
  
  VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_PCMK,pcmk);
  
  VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_PCMK_KEY,buf);
  if (*buf) strcpy(std,"STD");
  else      strcpy(std,"   ");
  VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PIECE_NOT_LIKE,notLike);

  VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_PLATE_AREA,buf);
  area = atof(buf);
  if (area < 1.0) {  
    VDctxGetTxtAtr(nodeID,VDCTX_ATR_SS_BEAM_AREA,buf);
    area = atof(buf);
  }
  
  // Print
#if 0
  VDlogPrintFmt(VDLOG_DEBUG,0,
		"%4d %4d %4s %-2s %-5s %-8s %-15s %-8s %-8s %10.0f %-32s",
		nth,group,pcmk,notLike,
		type,
		family,part_num,
		material,grade,
		area,
		name);
#endif

  VDlogPrintFmt(VDLOG_DEBUG,0,
		"%4d %4d %4s %-2s %-5s %-15s %-8s %10.0f %-32s",
		nth,group,pcmk,notLike,
		type,part_num,grade,area,
		name);
    
  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * Given a parts list, just print it out
 */
void VDat2VerifyLikePrintList(TVDat2PcmkInfoList *listPI)
{
  VDASSERT_FN("VDat2VerifyLikePrintList");
  
  IGRint i;

  TVDat2PcmkInfo *info1 = NULL;
  TVDat2PcmkInfo *info2 = NULL;
  
  IGRint group = 1;
  IGRint cmp;
  
  VDlogPrintFmt(VDLOG_DEBUG,0,"---------------------------------------\n");
  
  // Cycle through
  for(i = 0; i < listPI->cnt; i++) {

    // Next node
    info2 = &listPI->pcmkInfos[i];

    // See if in the same group as previous node
    if (info1) {
      cmp = VDat2VerifyLikeCompare1(info1,info2);
      if (cmp) group++;
    }
    
    // Print it
    VDat2VerifyLikePrintNode(i,group,&info2->nodeID);

    // Setup for next compare
    info1 = info2;
    
  }
  VDlogPrintFmt(VDLOG_DEBUG,0,"--- %d pieces\n",i);
  
  // Done
 wrapup:
  return;
}
