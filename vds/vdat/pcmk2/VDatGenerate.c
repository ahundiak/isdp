/* $Id: VDatGenerate.c,v 1.5 2001/10/19 18:22:34 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk2/VDatGenerate.c
 *
 * Description: Form Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatGenerate.c,v $
 *      Revision 1.5  2001/10/19 18:22:34  ahundiak
 *      ah
 *
 *      Revision 1.4  2001/03/22 14:42:19  ahundiak
 *      ah
 *
 *      Revision 1.3  2001/03/19 16:03:29  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/03/18 23:46:09  ahundiak
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

VDASSERT_FFN("vdat/pcmk2/VDatGenerate.c");

/* -----------------------------------------------
 * Sort for the new piece mark list
 * Sort of screwy but it makes sense to production
 *
 * Beams
 *   Possible Like Beams
 *     Name *** Additional like attributes
 *
 *   Not-Like Beamss
 *     Name
 *
 * Plates
 *   Possible Like Plates
 *     Name *** Additional like attributes
 *
 *   Not-Like Plates
 *     Name
 *
 * All Standard pieces sorted on standard piece marks
 *  Name
 */
static IGRint sortList1(const void *v1, const void *v2)
{
  TVDat2PcmkInfo *info1 = (TVDat2PcmkInfo *)v1;
  TVDat2PcmkInfo *info2 = (TVDat2PcmkInfo *)v2;
  
  TGRid *node1ID;
  TGRid *node2ID;

  IGRchab buf1, buf2;
  IGRchab name1,name2;
  IGRchab type1,type2;
  IGRint  pcmk1,pcmk2;
  
  IGRint cmp;

  // Node oriented
  node1ID = &info1->nodeID;
  node2ID = &info2->nodeID;
  
  // Use name when all else fails
  VDctxGetCompName(node1ID,name1);
  VDctxGetCompName(node2ID,name2);
  
  // Standard pieces go last (need to get actual standard piece num, should be filled in)
  VDctxGetTxtAtr(node1ID,VDCTX_ATR_SS_PIECE_PCMK_KEY,buf1);
  VDctxGetTxtAtr(node2ID,VDCTX_ATR_SS_PIECE_PCMK_KEY,buf2);
  cmp = strcmp(buf1,buf2); if (cmp) goto wrapup;

  // Are they both standard?
  if (*buf1) {     
    cmp = strcmp(name1,name2);
    goto wrapup;
  }

  // Divide on plates and beams
  VDctxGetNodeTypeSuffix(node1ID,type1);
  VDctxGetNodeTypeSuffix(node2ID,type2);
  cmp = strcmp(type1,type2); if (cmp) goto wrapup;

  // Divide on like and not like
  VDctxGetTxtAtr(node1ID,VDCTX_ATR_SS_PIECE_NOT_LIKE,buf1);
  VDctxGetTxtAtr(node2ID,VDCTX_ATR_SS_PIECE_NOT_LIKE,buf2);
  cmp = strcmp(buf1,buf2); if (cmp) goto wrapup;
  if (*buf1 == 0) {
    cmp = strcmp(name1,name2); 
    goto wrapup;
  }
  
  // Common piece attributes
  cmp = VDat2ComparePieceAttributes(node1ID,node2ID);
  if (cmp) goto wrapup;
  
  // Branch for different types
  VDctxGetNodeTypeSuffix(node1ID,buf1);

  // Plates
  if (!strcmp(buf1,VDCTX_NODE_TYPE_PLATE)) {

    // Standard check
    cmp = VDat2ComparePlateAttributes(node1ID,node2ID);
    if (cmp) goto wrapup;
  
    // Done
    cmp = 0;
    goto wrapup;
  }
      
  // Beams
  if (!strcmp(buf1,VDCTX_NODE_TYPE_BEAM)) {

    // Standard check
    cmp = VDat2CompareBeamAttributes(node1ID,node2ID);
    if (cmp) goto wrapup;
  
    // Done
    cmp = 0;
    goto wrapup;
  }
  
  // Must match ???
  cmp = 0;
  
 wrapup:
  return cmp;
}

/* -----------------------------------------------
 * Print one node for debugging
 */
static void printNode(IGRint nth, IGRint group,TGRid *nodeID)
{
  VDASSERT_FN("printNode");
  
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
static void printList(TVDat2PcmkInfoList *listPI)
{
  VDASSERT_FN("printList");
  
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
      cmp = sortList1(info1,info2);
      if (cmp) group++;
    }
    
    // Print it
    printNode(i,group,&info2->nodeID);

    // Setup for next compare
    info1 = info2;
    
  }
  VDlogPrintFmt(VDLOG_DEBUG,0,"--- %d pieces\n",i);
  
  // Done
 wrapup:
  return;
}

/* -----------------------------------------------
 * If a matches b and b matches c then we assume
 * that a matches c.  But assumptions can be bad
 * 
 * This routine is entered with b match c
 * Find all pieces with the same mark before b and
 * bounce against c
 */
static IGRstat validateGeometry2(TVDat2PcmkInfoList *listPI,
				 IGRint              b)
{
  VDASSERT_FN("validateGeometry2");

  IGRstat retFlag = 0;
  IGRstat sts;
  
  TGRid *nodeAID;
  TGRid *nodeBID;
  TGRid *nodeCID;

  IGRint a,c;
  IGRint cmp;
  
  IGRchab pcmkA,pcmkB;
  IGRchab buf1,buf2;
  
  IGRint flag = 0;
  
  // Setup the c data
  c = b + 1;
  VDASSERTW(c < listPI->cnt);
  nodeCID = &listPI->pcmkInfos[c].nodeID;
  
  // Setup the b data
  nodeBID = &listPI->pcmkInfos[b].nodeID;
  VDctxGetTxtAtr(nodeBID,VDCTX_ATR_SS_PIECE_PCMK,pcmkB);
  
  // Cycle through
  for(a = b - 1; a >= 0; a--) {
    
    // Check piece mark
    nodeAID = &listPI->pcmkInfos[a].nodeID;
    VDctxGetTxtAtr(nodeAID,VDCTX_ATR_SS_PIECE_PCMK,pcmkA);
    if (strcmp(pcmkA,pcmkB)) {
      retFlag = 1;
      goto wrapup;
    }

    // Debug certain items
    if (!strcmp(pcmkA,"XXX")) flag = 1;
    else                      flag = 0;
    if (flag) {
      VDlogPrintFmt(VDLOG_ERROR,0,"--------- %s %s --------------",ffn(),fn);
      VDctxGetCompPath(nodeAID,buf1);
      VDctxGetCompPath(nodeCID,buf2);
      VDlogPrintFmt(VDLOG_ERROR,0,"%-4s %s",pcmkA,buf1);
      VDlogPrintFmt(VDLOG_ERROR,0,"%-4s %s",pcmkB,buf2);
    }
    
    // Check attributes
    cmp = sortList1(&listPI->pcmkInfos[a],&listPI->pcmkInfos[c]);
    if (cmp) {
      if (flag) VDlogPrintFmt(VDLOG_ERROR,0,"   sortList1 failed");
      goto wrapup;
    }
    
    // Validate
    cmp = VDat2CompareGeometry(&listPI->pcmkInfos[a],
			       &listPI->pcmkInfos[c]);
    if (cmp) {
      if (flag) VDlogPrintFmt(VDLOG_ERROR,0,"    VDat2CompareGeometry failed");
      goto wrapup;
    }
    if (flag) VDlogPrintFmt(VDLOG_ERROR,0,"   Worked");
  }

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * A very simple minded routine for generating marks
 * If the pieces pass the geometry check then make them equal
 */
void generatePcmk1(TVDat2PcmkInfoList *listPI,
		   TVDat2PcmkInfo     *info1,
		   TVDat2PcmkInfo     *info2,
		   IGRint              nth,
		   IGRint             *mark)
{
  VDASSERT_FN("generatePcmk1");
  IGRstat sts;
  
  IGRchab buf1;
  IGRchab buf2;
  
  IGRint cmp;
  IGRint markx = *mark + 1;
  
  // Filter standard pieces
  VDctxGetTxtAtr(&info1->nodeID,VDCTX_ATR_SS_PIECE_PCMK_KEY,buf1);
  VDctxGetTxtAtr(&info2->nodeID,VDCTX_ATR_SS_PIECE_PCMK_KEY,buf2);
  if ((*buf1) || (*buf2)) {

    // This might be a good spot to get the actual standard piece mark
    return;;
  }

  // Filter out not likes
  VDctxGetTxtAtr(&info1->nodeID,VDCTX_ATR_SS_PIECE_NOT_LIKE,buf1);
  VDctxGetTxtAtr(&info2->nodeID,VDCTX_ATR_SS_PIECE_NOT_LIKE,buf2);
  if ((*buf1 == '1') || (*buf2 == '1')) goto wrapup;
  
  // Check attributes
  cmp = sortList1(info1,info2);
  if (cmp) goto wrapup;
  
  // Check geometry
  cmp = VDat2CompareGeometry(info1,info2);
  if (cmp) goto wrapup;
  
  // Last check to see if proposed addition matches all previous ones
  sts = validateGeometry2(listPI,nth-1);
  if (sts == 0) goto wrapup;
  
  // Keep the same mark
  markx--;

  // Done
 wrapup:
  VDctxAppIntAtr(&info2->nodeID,VDCTX_ATR_SS_PIECE_PCMK,markx);
  *mark = markx;
  return;
}

/* -----------------------------------------------
 * A very simple minded routine for generating marks
 * If the pieces pass the geometry check then make them equal
 */
void generatePcmks1(TVDat2PcmkInfoList *listPI, IGRint nextPcmk)
{
  VDASSERT_FN("generatePcmks1");
  
  IGRint h,i;

  TVDat2PcmkInfo *info1;
  TVDat2PcmkInfo *info2;

  IGRint cmp;

  time_t begTime,endTime;
  
  // Arg check
  VDASSERTW(listPI);
  if (listPI->cnt < 1) goto wrapup;
  
  // Bench mark
  time(&begTime);

  // Set the first one
  VDctxAppIntAtr(&listPI->pcmkInfos[0].nodeID,VDCTX_ATR_SS_PIECE_PCMK,nextPcmk);
  
  // Cycle through
  for(i = 1; i < listPI->cnt; i++) {

    // Allow Interrupts
    if (IGEstop()) {
      VDlogPrintFmt(VDLOG_ERROR,0,"Generating stopped by user");
      goto wrapup;
    }

    // Status
    if (!(i % 10)) {
      VDlogPrintFmt(VDLOG_STAT,0,"Generating piece marks %d of %d",i+1,listPI->cnt);
    }

    // The info
    h = i - 1;
    info1 = &listPI->pcmkInfos[h];
    info2 = &listPI->pcmkInfos[i];
    
    // Doit
    generatePcmk1(listPI,info1,info2,i,&nextPcmk);
    
  }
   
  // Done
  time(&endTime);
  VDlogPrintFmt(VDLOG_STAT,0,"Done generating, time %d",endTime - begTime);

 wrapup:
  return;
}

/* -----------------------------------------------
 * Generates a brand new set of piece marks
 * pcmkInfo's are filled in, srfTranInfo filled in for
 * all possible like parts
 */
void VDat2GeneratePcmks(TVDat2PcmkInfoList *listPI, IGRint nextPcmk)
{
  VDASSERT_FN("VDat2GeneratePcmks");
  
  IGRstat sts;
  
  IGRint errCnt = 0;

  // Arg check
  VDASSERTW(listPI);
  if (listPI->cnt == 0) goto wrapup;

  // No verbose messages when the compares fail
  // But do order plate areas exactly
  VDat2SetCompareFlags(0,0,1);
  qsort(listPI->pcmkInfos,listPI->cnt,listPI->size,sortList1);
  VDat2SetCompareFlags(0,0,0);
  
  // Simple Generation
  generatePcmks1(listPI, nextPcmk);
  
  // Print out
  printList(listPI);
  
  // Done
  VDlogPrintFmt(VDLOG_STAT,0,"Done generating, error count %d",errCnt);
  
 wrapup:
  return;
}
