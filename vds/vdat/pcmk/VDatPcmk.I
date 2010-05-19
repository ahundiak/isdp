/* $Id: VDatPcmk.I,v 1.2 2001/01/11 20:54:46 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/set/VDatPcmk.I
 *
 * Description: Piece Mark Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatPcmk.I,v $
 *      Revision 1.2  2001/01/11 20:54:46  art
 *      sp merge
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:42  cvs
 *      Initial import to CVS
 *
# Revision 1.1  2000/03/31  17:12:18  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/28/00  ah      Creation
 * 01/11/01  ah      sp merge, Not . .m file???
 ***************************************************************************/

class implementation VDatBase;

#include "VDat.h"
#include "VDatPcmk.h"

#include "VDsa.h"
#include "VDmem.h"
#include "VDobj.h"

/* -----------------------------------------------
 * Fill in leaf information
 */
IGRstat VDatGetPcmkLeafInfo(TGRid *leafID, TVDatPcmkLeafInfo *leaf)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  
  IGRchar pcmk[40];
  
  TGRobj_env pieceOE;
  
  // Arg check
  if (leaf   == NULL)   goto wrapup;
  if (leafID == NULL) goto wrapup;
  
  // Init
  memset(leaf,0,sizeof(TVDatPcmkLeafInfo));
  leaf->leafID = *leafID;
  leaf->pieceOE.obj_id.objid = NULL_OBJID;
  
  // Get the existing piece mark
  vdsa$GetStruct(objID = leafID,
		 name  = VDAT_ATTR_PCMK,
		 txt   =  pcmk);
  if (*pcmk) leaf->pcmk1 = atoi(pcmk);
  
  // Get the piece object
  VDatGetLeafObject(leafID,&pieceOE);
  if (pieceOE.obj_id.objid == NULL_OBJID) goto wrapup;
  leaf->pieceOE = pieceOE;
  
  // Get the piece name
  vdobj$Get(objOE = &pieceOE, objName = leaf->pieceName);
  
  // Adjust the type
  sts = vdobj$IsAncestryValid(objOE = &pieceOE, superClassName = "VSplate");
  if (sts & 1) leaf->pieceType = VDAT_PCMK_INFO_PIECE_TYPE_PLATE;
  else {  
    sts = vdobj$IsAncestryValid(objOE = &pieceOE, superClassName = "VSbeam");
    if (sts & 1) leaf->pieceType = VDAT_PCMK_INFO_PIECE_TYPE_BEAM;
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
  
}

/* -----------------------------------------------
 * Recursive routine for filling in piece mark info
 */
IGRstat VDatGetPcmkLeafInfos(TGRid          *nodeID,
			     TVDatPcmkInfos *infos)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRuint i;
  TGRid   childID;
  
  // Arg check
  if (infos == NULL) goto wrapup;

  // Make sure have room for more
  if (infos->cnt >= infos->max) goto wrapup;

  // Process leafs
  sts = VDatIsLeaf(nodeID);
  if (sts & 1) {
    VDatGetPcmkLeafInfo(nodeID,infos->infos[infos->cnt].leaf);
    infos->cnt++;
    retFlag = 1;
    goto wrapup;
  }
  // Cycle through kids
  for(i = 0; VDatGetChildObject(nodeID,i,&childID); i++) {
    VDatGetPcmkLeafInfos(&childID,infos);
  }

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}
    
/* -----------------------------------------------
 * Return a list of pcmk information in the tree
 * Might extend to set later
 */
IGRstat VDatGetPcmkInfoList(TGRid          *treeID,  
			    TVDatPcmkInfos *infos)
{
  IGRstat retFlag = 0;
  IGRint  cnt = 0;
  IGRint  i;
  
  // Arg check
  if (infos   == NULL) goto wrapup;
  if (treeID  == NULL) goto wrapup;
  
  // Init
  memset(infos,0,sizeof(TVDatPcmkInfos));
  
  // Count em
  VDatGetNumLeafs(treeID,&cnt);
  if (cnt <= 0) goto wrapup;
  infos->max = cnt;
  
  // Pointer list
  infos->infos = _CALLOC(cnt,TVDatPcmkInfo);
  if (infos->infos == NULL) {
    printf("*** Problem allocating list of piece marks\n");
    goto wrapup;
  }
  
  // Leaf list
  infos->leafs = _CALLOC(cnt,TVDatPcmkLeafInfo);
  if (infos->leafs == NULL) {
    printf("*** Problem allocating list of leaf piece marks\n");
    _FREE(infos->infos);
    infos->infos = NULL;
    infos->max = 0;
    goto wrapup;
  }
 
  // Attach leafs to main list
  for(i = 0; i < cnt; i++) {
    infos->infos[i].leaf = &infos->leafs[i];
  }
  
  // Recursive loop to fill in information
  VDatGetPcmkLeafInfos(treeID,infos);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Sort two piece mark info items
 * Key on existing pcmk1
 */
IGRint VDatSortPcmkInfo1(const void *a_info1, const void *a_info2)
{
  IGRint sts;
  
  TVDatPcmkInfo *info1 = (TVDatPcmkInfo*)a_info1;
  TVDatPcmkInfo *info2 = (TVDatPcmkInfo*)a_info2;

  TVDatPcmkLeafInfo *leaf1 = info1->leaf;
  TVDatPcmkLeafInfo *leaf2 = info2->leaf;
  
  // First by piece mark
  if (leaf1->pcmk1 < leaf2->pcmk1) return -1;
  if (leaf1->pcmk1 > leaf2->pcmk1) return  1;
  
  // Then by type
  if (leaf1->pieceType < leaf2->pieceType) return -1;
  if (leaf1->pieceType > leaf2->pieceType) return  1;

  // Then by name
  sts = strcmp(leaf1->pieceName,leaf2->pieceName);
  if (sts) return sts;
  
  // The same???
  return 0;
}

/* -----------------------------------------------
 * Sort two piece mark info items
 * Key on new pcmk2
 */
IGRint VDatSortPcmkInfo2(const void *a_info1, const void *a_info2)
{
  IGRint sts;
  
  TVDatPcmkInfo *info1 = (TVDatPcmkInfo*)a_info1;
  TVDatPcmkInfo *info2 = (TVDatPcmkInfo*)a_info2;

  TVDatPcmkLeafInfo *leaf1 = info1->leaf;
  TVDatPcmkLeafInfo *leaf2 = info2->leaf;
  
  // First by piece mark
  if (leaf1->pcmk2 < leaf2->pcmk2) return -1;
  if (leaf1->pcmk2 > leaf2->pcmk2) return  1;
  
  // Then by type
  if (leaf1->pieceType < leaf2->pieceType) return -1;
  if (leaf1->pieceType > leaf2->pieceType) return  1;

  // Then by name
  sts = strcmp(leaf1->pieceName,leaf2->pieceName);
  if (sts) return sts;
  
  // The same???
  return 0;
}

/* -----------------------------------------------
 * Pretty print set of piece marks
 */
IGRstat VDatPrintPcmkInfoList(TVDatPcmkInfos *infos)
{
  IGRstat retFlag = 0;

  TVDatPcmkInfo     *info;
  TVDatPcmkLeafInfo *leaf;
  
  IGRint i;
  IGRchar t;
  
  // Arg check
  if (infos == NULL) goto wrapup;

  // Say hi
  printf("-------------- PCMK INFO -----------------\n");
  
  // Cycle through
  for(i = 0; i < infos->cnt; i++) {

    info = &infos->infos[i];
    leaf = info->leaf;
    
    switch(leaf->pieceType) {
      case VDAT_PCMK_INFO_PIECE_TYPE_PLATE: t = 'P'; break;
      case VDAT_PCMK_INFO_PIECE_TYPE_BEAM : t = 'B'; break;
      default: t = 'U';
    }
          
    printf("%4d %4d %4d %c %-20s\n",
	   i,
	   leaf->pcmk1,
	   leaf->pcmk2,
	   t,
	   leaf->pieceName);
    
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Sets one standard piece mark info
 */
IGRstat VDatSetStandardPcmkInfo(TVDatPcmkInfo *info)
{
  IGRstat retFlag = 0;
  IGRchar std_pcmk[40];
  TVDatPcmkLeafInfo *leaf;
  
  // Arg check
  if (info == NULL) goto wrapup;
  leaf = info->leaf;
  
  vdsa$GetStruct(objOE = &leaf->pieceOE,
		 name  = "SA_PPL:pcmk:std_pcmk",
		 txt   =  std_pcmk);

  // This means it's a standard but not logged into the database
  if (!strcmp(std_pcmk,"STANDARD")) {
    leaf->pcmk2 = leaf->pcmk1;
    if (leaf->pcmk2 < VDAT_STD_PCMK_MIN) leaf->pcmk2 = VDAT_STD_PCMK_UNK;

    //printf("Standard %s\n",info->pieceName);
    
    retFlag = 1;
    goto wrapup;
  }

  // If it's not a standard, leave blank
  if (!strcmp(std_pcmk,"NOT STANDARD")) {
    
    // Just leave at zero
    retFlag = 1;
    goto wrapup;
  }
  
  // Got it
  leaf->pcmk2 = atoi(std_pcmk);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Pass through the list of piece marks and determine
 * which pieces are standard
 */
IGRstat VDatSetStandardPcmkInfos(TVDatPcmkInfos *infos)
{
  IGRstat retFlag = 0;
  IGRint  i;
  
  // Arg check
  if (infos == NULL) goto wrapup;
  
  // Loop through
  for(i = 0; i < infos->cnt; i++) {
    VDatSetStandardPcmkInfo(&infos->infos[i]);
  }
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Free the internal data for an infos struct
 */
IGRstat VDatFreePcmkInfos(TVDatPcmkInfos *infos)
{
  IGRstat retFlag = 0;
  
  // Arg check
  if (infos == NULL) goto wrapup;
  
  // Free the pointers
  _FREE(infos->attrs);
  _FREE(infos->leafs);
  _FREE(infos->infos);

  // Reset
  memset(infos,0,sizeof(TVDatPcmkInfos));
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Test the piece mark routines for a given tree
 */
IGRstat VDatTestPcmksForTree(TGRid *treeID)
{
  IGRstat retFlag = 0;
  
  TVDatPcmkInfos infos;
  
  // Trace memory
  VD_memOn();
  VD_memReset();

  // Init
  memset(&infos,0,sizeof(TVDatPcmkInfos));
  
  // Arg check
  if (treeID == NULL) goto wrapup;
  
  // Get the infos
  VDatGetPcmkInfoList(treeID,&infos);
  if (infos.infos == NULL) {
    printf("Problem getting list of piece mark information\n");
    goto wrapup;
  }

  // Fill in standard parts
  VDatSetStandardPcmkInfos(&infos);
  
  // Sort them
  qsort(infos.infos,infos.cnt,sizeof(TVDatPcmkInfo),VDatSortPcmkInfo2);
  
  // Print
  VDatPrintPcmkInfoList(&infos);
  
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
IGRstat VDatTestPcmksForSetName(IGRchar *setName)
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
  retFlag = VDatTestPcmksForTree(&treeID);
  
 wrapup:
  return retFlag;
}

end implementation VDatBase;





