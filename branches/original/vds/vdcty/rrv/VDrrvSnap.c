/* $Id: VDrrvSnap.c,v 1.6 2002/06/07 20:14:49 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdcty/rrv/VDrrvSnap.c
 *
 * Description: File specific snapshot routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDrrvSnap.c,v $
 *      Revision 1.6  2002/06/07 20:14:49  ahundiak
 *      ah
 *
 *      Revision 1.5  2002/05/17 15:22:33  ahundiak
 *      ah
 *
 *      Revision 1.4  2002/05/10 21:00:19  ahundiak
 *      ah
 *
 *      Revision 1.3  2002/05/03 20:12:13  ahundiak
 *      ah
 *
 *      Revision 1.2  2002/03/04 20:55:26  ylong
 *      CR5068 and CR5286
 *
 *      Revision 1.1  2002/02/28 21:41:34  ahundiak
 *      ah
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/29/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDfrmc.h"
#include "VDtest.h"
#include "VDctx.h"
#include "VDdoom.h"
#include "VDss.h"
#include "VDat.h"

#include "VDrrvCmd.h"

#include "glib.h"

VDASSERT_FFN("vdcty/rrv/VDrrvSnap.c");

/* -----------------------------------------------
 * Filter staged piece
 */
static IGRstat filterStagedPiece(TGRobj_env *modelOE, IGRchar *stagedUnit)
{
  IGRstat retFlag = 0;
  
  TGRid leafID;
  IGRchab setName;
  
  // If no staged unit then accept
  if (stagedUnit == NULL) {
    retFlag = 1;
    goto wrapup;
  }
  
  // Find the staging tree leaf
  VDatGetObjectLeafForSetType(modelOE,"StagingTree",&leafID);
  if (leafID.objid == NULL_OBJID) goto wrapup;
  
  // Check the actual set
  VDatGetSetName(&leafID,setName);
  if (strcmp(setName,stagedUnit)) goto wrapup;
  
  // Accept it
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Create piece snapshot
 * if stagedUnit is passed then only snap those
 * pieces staged in the specified unit
 */
void VDrrvCreatePieceSnapshot(VDosnum  osnum, 
			      TGRid   *treeID, 
			      IGRchar *stagedUnit)
{
  VDASSERT_FN("VDrrvCreatePieceSnapshot");

  IGRstat sts;
  
  IGRint  pieceCnt,plateCnt,beamCnt;
  IGRint  dupCnt;
  
  IGRchab fileName;
  
  TGRid *listIDs = NULL;

  TGRid  beamsID;
  TGRid platesID;
  TGRid piecesID;

  IGRint i;
  IGRint errCnt  = 0;
  IGRint errCntx = 0;

  IGRint wantFlag       = VDrrvCmdGetCreateQuickFlag();
  IGRint pieceTraceFlag = VDrrvCmdGetCreateTraceFlag();

  TGRid  modelID,pieceID;
  TGRobj_env modelOE;
  
  // Arg check
  VDASSERTW(treeID && treeID->objid != NULL_OBJID);
  
  // Validate the os by getting the fileName
  VDosGetFileName(osnum,fileName);
  VDASSERTW(*fileName);
  
  // Get a list of the pieces
  VDobjGetPieces(osnum, &plateCnt, &beamCnt, &listIDs);
  pieceCnt = plateCnt + beamCnt;
  
  // Need to Handle no items found gracefully
  if (listIDs  == NULL) goto wrapup;
  if (pieceCnt == 0)    goto wrapup;
  
  // Look for dup comp names
  VDctxCheckForDupCompNames(pieceCnt,listIDs,&dupCnt);

  // Status
  VDlogPrintFmt(VDLOG_INFO,0,
		"File %s, Found %d plates, %d beams, %d total.",
		fileName,plateCnt,beamCnt,pieceCnt);
  
  // Make some nodes
  VDctxGetChildNodeByType(treeID,VDCTX_NODE_TYPE_SS_OM_PIECES,&piecesID);
  if (piecesID.objid == NULL_OBJID) {
    VDctxCreateNode(treeID,VDCTX_NODE_TYPE_SS_OM_PIECES,NULL,&piecesID);
  }
  VDctxGetChildNodeByType(&piecesID,VDCTX_NODE_TYPE_SS_OM_PLATES,&platesID);
  if (platesID.objid == NULL_OBJID) {
    VDctxCreateNode(&piecesID,VDCTX_NODE_TYPE_SS_OM_PLATES,NULL,&platesID);
  }
  VDctxGetChildNodeByType(&piecesID,VDCTX_NODE_TYPE_SS_OM_BEAMS,&beamsID);
  if (beamsID.objid == NULL_OBJID) {
    VDctxCreateNode(&piecesID,VDCTX_NODE_TYPE_SS_OM_BEAMS,NULL,&beamsID);
  }

  // Sort
  qsort(listIDs,pieceCnt,sizeof(TGRid),VDctxCompareNodeTypeCompPath);

  // Cycle through
  for(i = 0; i < pieceCnt; i++) {

    // Status
    if (!(i % 10)) {
      VDlogPrintFmt(VDLOG_STAT,0,"Processing %d of %d",i+1,pieceCnt);
    }
  
    // Create the actual node
    modelID = listIDs[i];
    VDctxGetModelObject(&modelID,&modelOE);

    // Filter
    sts = filterStagedPiece(&modelOE,stagedUnit);
    if (sts & 1) {
    
      // Log it if in verbose mode
      if (traceFlag || pieceTraceFlag) {
	VDlogPrintObject(VDLOG_INFO,1,"Processing ",&modelOE,NULL);
      }
      errCnt = 0;

      // Plate or beam
      sts = VDobjIsAncestryValid(&modelOE,NULL,OM_K_NOTUSING_CLASSID,"VSplate");
      if (sts) {
	VDvalConvertPieceToDom(&modelOE,&platesID,&pieceID,&errCnt,wantFlag);
      }
      sts = VDobjIsAncestryValid(&modelOE,NULL,OM_K_NOTUSING_CLASSID,"VSbeam");
      if (sts) {
	VDvalConvertPieceToDom(&modelOE,&beamsID,&pieceID,&errCnt,wantFlag);
      
      }
      errCntx += errCnt;
    }
  }
  VDlogPrintFmt(VDLOG_STAT,0,"");
  VDlogPrintFmt(VDLOG_INFO,0,"Done adding pieces, Error Count %d",errCntx);

 wrapup:
  g_free(listIDs);
  return;
}

/* -----------------------------------------------
 * Find any pen files and snapshot them
 */
static void processPenForUnit(TGRid *treeID, IGRint infoCnt, TVDrrvPurposeInfo *infos, IGRchar *unit)
{
  IGRint i;
  TVDrrvPurposeInfo *info;
  
  for(i = 0; i < infoCnt; i++) {
    info = &infos[i];
    if (!strcmp(info->purpose,"unit_pen") && 
	!strcmp(info->unit,unit) &&
	!info->doneFlag) {

      VDlogPrintFmt(VDLOG_INFO,0,"processPenForUnit %s",info->fileName);

      VDrrvAddDomPens(info->osnum,treeID);
      info->doneFlag = 1;
      goto wrapup;
    }
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Find any pcg files and snapshot them
 */
static void processPcgForUnit(TGRid *treeID, IGRint infoCnt, TVDrrvPurposeInfo *infos, IGRchar *unit)
{
  IGRint i;
  TVDrrvPurposeInfo *info;
  
  for(i = 0; i < infoCnt; i++) {
    info = &infos[i];
    if (!strcmp(info->purpose,"unit_pcg") && 
	!strcmp(info->unit,unit) &&
	!info->doneFlag) {

      VDlogPrintFmt(VDLOG_INFO,0,"processPcgForUnit %s",info->fileName);

      VDrrvAddDomPens(info->osnum,treeID);
      info->doneFlag = 1;
      goto wrapup;
    }
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Find the staging tree file for a given unit
 * and snapshot it
 */
static void processStagingForUnit(TGRid *treeID, IGRint infoCnt, TVDrrvPurposeInfo *infos, IGRchar *unit)
{
  IGRint i;
  TVDrrvPurposeInfo *info;
  
  for(i = 0; i < infoCnt; i++) {
    info = &infos[i];
    if (!strcmp(info->purpose,"unit_prod") && 
	!strcmp(info->unit,unit) &&
	!info->doneFlag) {
      VDlogPrintFmt(VDLOG_INFO,0,"processStagingForUnit %s",info->fileName);

      VDrrvAddDomStagingTree(treeID);
      VDrrvAddDomBevels(info->osnum,treeID);
      info->doneFlag = 1;
      goto wrapup;
    }
  }
  
 wrapup:
  return;
}


/* -----------------------------------------------
 * Find the unit_hull file for the given unit
 * and snapshot it
 */
static void processUnitHullForUnit(TGRid *treeID, IGRint infoCnt, TVDrrvPurposeInfo *infos, IGRchar *unit)
{
  IGRint i;
  TVDrrvPurposeInfo *info;
  
  for(i = 0; i < infoCnt; i++) {
    info = &infos[i];
    if (!strcmp(info->purpose,"unit_hull") && 
	!strcmp(info->unit,unit) &&
	!info->doneFlag) {
      VDlogPrintFmt(VDLOG_INFO,0,"processUnitHullForUnit %s",info->fileName);
      VDrrvCreatePieceSnapshot(info->osnum,treeID,NULL);
      info->doneFlag = 1;
      goto wrapup;
    }
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Process the staged pieces for any unit_hulls
 * except fot the passed unit
 */
static void processUnitHulls(TGRid *treeID, IGRint infoCnt, TVDrrvPurposeInfo *infos, IGRchar *unit)
{
  IGRint i;
  TVDrrvPurposeInfo *info;
  
  for(i = 0; i < infoCnt; i++) {
    info = &infos[i];
    if (!strcmp(info->purpose,"unit_hull") && 
	 strcmp(info->unit,unit) &&
	!info->doneFlag) {
      VDlogPrintFmt(VDLOG_INFO,0,"processUnitHulls %s",info->fileName);
      VDrrvCreatePieceSnapshot(info->osnum,treeID,unit);
      info->doneFlag = 1;
    }
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Process the staged pieces for files with no
 * purpose, do not set done flag for these
 */
static void processUnitNoPurpose(TGRid *treeID, IGRint infoCnt, TVDrrvPurposeInfo *infos, IGRchar *unit)
{
  IGRint i;
  TVDrrvPurposeInfo *info;
  
  for(i = 0; i < infoCnt; i++) {
    info = &infos[i];
    if ((*info->purpose == 0) && !info->doneFlag) {
      VDlogPrintFmt(VDLOG_INFO,0,"processUnitNoPurpose %s",info->fileName);
      VDrrvCreatePieceSnapshot(info->osnum,treeID,unit);
      VDrrvAddDomPens(info->osnum,treeID);
      info->doneFlag = 1;
    }
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Process a zone file, keep it simple for now
 */
static void processZone(TGRid *treeID, IGRint infoCnt, TVDrrvPurposeInfo *infos, IGRchar *zone)
{
  IGRint i;
  TVDrrvPurposeInfo *info;
  
  for(i = 0; i < infoCnt; i++) {
    info = &infos[i];
    if (!strncmp(info->purpose,"zone_",5) && !info->doneFlag) {
      VDlogPrintFmt(VDLOG_INFO,0,"processZone %s",info->fileName);
      VDrrvAddEqps (info->osnum,treeID);
      VDrrvAddComps(info->osnum,treeID);
      info->doneFlag = 1;
    }
  }
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Given the current file's purpose and a list
 * of files to process, generate the snapshot
 */
void VDrrvCreateSnapshots(TVDpdmPurposeInfo *curInfo, 
			  IGRint             infoCnt, 
			  TVDrrvPurposeInfo *infos,
			  TGRid             *treeID)
{
  VDASSERT_FN("VDrrvCreateSnapshots");

  IGRchab treeType,treeName;
  
  // Arg check
  VDASSERTW(treeID); treeID->objid = NULL_OBJID;
  VDASSERTW(curInfo && *curInfo->purpose);
  VDASSERTW(infoCnt && infos);
  
  // Tree type from purpose
  sprintf(treeType,"ss_%s",curInfo->purpose);
  
  // Tree name from unit or zone
  strcpy(treeName,curInfo->unit);
  if (*treeName == 0) strcpy(treeName,curInfo->zone);
  if (*treeName == 0) {
    VDlogPrintFmt(VDLOG_INFO,0,"Need either UNIT or ZONE to make a snapshot");
    goto wrapup;
  }
  // Create it
  VDlogPrintFmt(VDLOG_INFO,0,"Tree %s %s",treeType,treeName);
  VDrrvCreateDomTree(treeType,treeName,treeID);
  VDASSERTW(treeID->objid != NULL_OBJID);
  
  // If have a unit, take care of some of the files
  if (*curInfo->unit) {
    processUnitHullForUnit(treeID,infoCnt,infos,curInfo->unit);
    processUnitHulls      (treeID,infoCnt,infos,curInfo->unit);
    processUnitNoPurpose  (treeID,infoCnt,infos,curInfo->unit);
    processStagingForUnit (treeID,infoCnt,infos,curInfo->unit);
    processPenForUnit     (treeID,infoCnt,infos,curInfo->unit);
    processPcgForUnit     (treeID,infoCnt,infos,curInfo->unit);
  }

  // Zone files
  if (*curInfo->zone) {
    processZone(treeID,infoCnt,infos,curInfo->zone);
  }
  
 wrapup:
  return;
}


