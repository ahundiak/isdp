/* $Id: VDatInfo.I,v 1.2 2001/01/11 20:54:46 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk/VDatInfo.I
 *
 * Description: Piece Mark Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatInfo.I,v $
 *      Revision 1.2  2001/01/11 20:54:46  art
 *      sp merge
 *
# Revision 1.2  2000/11/27  19:22:20  pinnacle
# ah
#
# Revision 1.1  2000/06/27  17:34:38  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/28/00  ah      Creation
 ***************************************************************************/

class implementation Root;

#include "VDtypedef.h"
#include "VDatPcmk.h"

#include "VDsa.h"
#include "VDmem.h"
#include "VDobj.h"

#include "VDassert.h"

VDASSERT_FFN("vdat/pcmk/VDatInfo.I");

/* -----------------------------------------------
 * Pretty print single piece mark info
 */
IGRstat VDatPrintPcmkInfo(TVDatPcmkInfo *info)
{
  IGRstat retFlag = 0;

  TVDatPcmkLeafInfo *leaf;
  TVDatPcmkAttrInfo *attr;
  
  IGRchar buf[40];
  
  IGRchar t;
  
  // Arg check
  if (info == NULL) goto wrapup;
  leaf = info->leaf;
  attr = info->attr;
  if (leaf == NULL) goto wrapup;
  
  // Decide Type
  switch(leaf->pieceType) {
    case VDAT_PCMK_INFO_PIECE_TYPE_PLATE: t = 'P'; break;
    case VDAT_PCMK_INFO_PIECE_TYPE_BEAM : t = 'B'; break;
    default: t = 'U';
  }
  
  // Some attribute stuff
  *buf = 0;
  if (attr) {

    switch(leaf->pieceType) {

      // Plate
      case VDAT_PCMK_INFO_PIECE_TYPE_PLATE:
	sprintf(buf,"%-12s %-10d",
		attr->grade,
		attr->type.plate.area);
	break;

      // Beam
      case VDAT_PCMK_INFO_PIECE_TYPE_BEAM:
	sprintf(buf,"%-12s %-10d",
		attr->part_num,
		attr->type.beam.length);
	break;
    }
  }
  
  // And print
  printf("%4d %4d %c %-24s %-20s\n",
	 leaf->pcmk1,
	 leaf->pcmk2,
	 t,
	 buf,
	 leaf->pieceName);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Pretty print set of piece marks
 */
IGRstat VDatPrintPcmkInfos(TVDatPcmkInfos *infos)
{
  IGRstat retFlag = 0;
  
  IGRint i;
  
  // Arg check
  if (infos == NULL) goto wrapup;

  // Say hi
  printf("-------------- PCMK INFO -----------------\n");
  
  // Cycle through
  for(i = 0; i < infos->cnt; i++) {
    VDatPrintPcmkInfo(&infos->infos[i]);
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Sets the notLike flag for standard pieces
 * and pieces not meeting like criteria
 */
IGRstat VDatGetPcmkNotLikeInfo(TVDatPcmkInfo *info)
{
  IGRstat retFlag = 0;
  
  IGRint i;

  TVDatPcmkLeafInfo *leaf;
  TVDatPcmkAttrInfo *attr;
  
  // Arg check
  if (info == NULL) goto wrapup;
  leaf = info->leaf; if (leaf == NULL) goto wrapup;
  attr = info->attr; if (attr == NULL) goto wrapup;
  
  // Filter standards
  if (leaf->pcmk1 >= VDAT_PCMK_STD_MIN) {
    leaf->notLike = 1;    
    retFlag = 1;
    // printf("Not like because it's standard\n");
    goto wrapup;
  }
  
  // Check other props
  if (attr == NULL) goto wrapup;
  switch(leaf->pieceType) {

    // Plate
    case VDAT_PCMK_INFO_PIECE_TYPE_PLATE:

      // Planar
      if (attr->type.plate.isPlanar == 0) {
	leaf->notLike = 1;
	retFlag = 1;
	// printf("Not like because it's not planar\n");
	goto wrapup;
      }
	
      // Area
      if (attr->type.plate.area > VDAT_PCMK_MAX_LIKE_PLATE_AREA) {
	leaf->notLike = 1;
	retFlag = 1;
	// printf("Not like because of plate area\n");
	goto wrapup;
      }
      
      break;

    // Beam
    case VDAT_PCMK_INFO_PIECE_TYPE_BEAM:

      break;
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Sets the notLike flag for standard pieces
 * and pieces not meeting like criteria
 */
IGRstat VDatGetPcmkNotLikeInfos(TVDatPcmkInfos *infos)
{
  IGRstat retFlag = 0;
  
  IGRint i;
  
  // Arg check
  if (infos == NULL) goto wrapup;
  
  // Cycle through
  for(i = 0; i < infos->cnt; i++) {
    if (IGEstop()) goto wrapup;
    VDatGetPcmkNotLikeInfo(&infos->infos[i]);
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Test the piece mark routines for a given tree
 * or for a et
 */
IGRstat VDatTest1PcmksForNode(IGRint test, TGRid *nodeID)
{
  IGRstat retFlag = 0;
  
  TVDatPcmkInfos infos;
  
  // Trace memory
  VD_memOn();
  VD_memReset();

  // Init
  memset(&infos,0,sizeof(TVDatPcmkInfos));
  
  // Arg check
  if (nodeID == NULL) goto wrapup;
  
  // Get the infos
  UI_status("Getting piece information ...");
  VDatGetPcmkInfos(nodeID,&infos);
  if (infos.infos == NULL) {
    printf("Problem getting list of piece mark information\n");
    goto wrapup;
  }

  // Fill in standard parts
  UI_status("Getting standard parts ...");
  VDatGetStandardPcmkInfos(&infos);

  // Fill in attributes
  UI_status("Filling in attributes ...");
  VDatGetPcmkAttrInfos(&infos);

  // Fill in notLike flag
  VDatGetPcmkNotLikeInfos(&infos);
  
  // Sort them
  qsort(infos.infos,infos.cnt,sizeof(TVDatPcmkInfo),VDatSortPcmkInfo2);
  
  // Print
  VDatPrintPcmkInfos(&infos);
  
  // Done
  retFlag = 1;
  
 wrapup:

  // Free the stuff
  VDatFreePcmkInfos(&infos);
  
  // Memory Check
  VD_memStatus();
  VD_memOff();

  return retFlag;
}

/* -----------------------------------------------
 * Test the piece mark routines for a given set
 */
IGRstat VDatTestPcmksForSetName(IGRint test, IGRchar *setName)
{
  IGRstat retFlag = 0;

  TGRid setID;
  TGRid treeID;

  // Arg check
  if (setName == NULL) goto wrapup;
  
  // Get the set
  VDatGetSetByTypeName("StagingTree",setName,&setID);
  if (setID.objid == NULL_OBJID) {
    printf("*** Unable to get set for %s\n",setName);
    goto wrapup;
  }
  
  // Get the tree
  VDatGetTree(&setID,&treeID);
  if (treeID.objid == NULL_OBJID) {
    printf("*** Unable to get tree for %s\n",setName);
    goto wrapup;
  }
  
  // Test It
  switch(test) {
  case 10: 
  case 11: 
  case 12: 
  case 13: 
    retFlag = VDatTest1PcmksForNode(test,&setID);  
    break;

  case 20:
  case 21:
  case 22:
  case 23:
    retFlag = VDatTest2PcmksForNode(test,&setID); 
    break;
  }
    
 wrapup:
  return retFlag;
}

end implementation Root;
