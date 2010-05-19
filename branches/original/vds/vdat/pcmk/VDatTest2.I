/* $Id: VDatTest2.I,v 1.1 2001/01/11 20:54:46 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/set/VDatTest2.I
 *
 * Description: Piece name testing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatTest2.I,v $
 *      Revision 1.1  2001/01/11 20:54:46  art
 *      sp merge
 *
# Revision 1.1  2000/06/27  17:34:38  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/28/00  ah      Creation
 ***************************************************************************/

class implementation VDatBase;

#include "VDat.h"
#include "VDatPcmk.h"

#include "VDsa.h"
#include "VDmem.h"
#include "VDobj.h"

/* -----------------------------------------------
 * Sort two piece mark info items
 * Key on existing pcmk1
 */
IGRint VDatSortPcmkInfoTest2(const void *a_info1, const void *a_info2)
{
  IGRint sts;
  
  TVDatPcmkInfo *info1 = (TVDatPcmkInfo*)a_info1;
  TVDatPcmkInfo *info2 = (TVDatPcmkInfo*)a_info2;

  TVDatPcmkLeafInfo *leaf1 = info1->leaf;
  TVDatPcmkLeafInfo *leaf2 = info2->leaf;
  
  // First by piece mark
  //if (leaf1->pcmk1 < leaf2->pcmk1) return -1;
  //if (leaf1->pcmk1 > leaf2->pcmk1) return  1;
  
  // Then by type
  //if (leaf1->pieceType < leaf2->pieceType) return -1;
  //if (leaf1->pieceType > leaf2->pieceType) return  1;

  // Then by name
  sts = strcmp(leaf1->pieceName,leaf2->pieceName);
  if (sts) return sts;
  
  // The same???
  return 0;
}

/* -----------------------------------------------
 * Print 1 leaf
 */
IGRstat VDatTest2PrintPcmk(TVDatPcmkInfo *info)
{
  IGRstat retFlag = 0;

  TVDatPcmkLeafInfo *leaf = info->leaf;

  printf("%2d %6d %5d %s\n",
	 leaf->pieceOE.obj_id.osnum,
	 leaf->pieceOE.obj_id.objid,
	 leaf->pcmk1,
	 leaf->pieceName);

  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Looks for problems with piece names,
 * Looks for dup piece names
 */
IGRstat VDatTest21Pcmk(TVDatPcmkInfos *infos, IGRint i, TVDatPcmkInfo *info)
{
  IGRstat retFlag = 1;

  TVDatPcmkInfo *infox;  // Next info
  TVDatPcmkInfo *infoy;  // prev info

  IGRint skip;
  
  // First look for anomilies
  switch(*info->leaf->pieceName) {
  case  0:
  case ' ':
  case 'V':
    VDatTest2PrintPcmk(info);
    goto wrapup;
  }

  // Look for dups
  if ((i+1) >= infos->cnt) 
  {
    goto wrapup;
  }
  infox = &infos->infos[i+1];
  if (strcmp(info->leaf->pieceName,infox->leaf->pieceName)) {
    goto wrapup;
  }
  
  // Got a dup, look back to avoid printing twice
  skip = 0;
  if (i) {
    infoy = &infos->infos[i-1];
    if (!strcmp(info->leaf->pieceName,infoy->leaf->pieceName)) {
      skip = 1;
    }
  }
  if (!skip) VDatTest2PrintPcmk(info);
  VDatTest2PrintPcmk(infox);

  // Done
  retFlag = 1;
  
wrapup:
  return retFlag;
  
}

/* -----------------------------------------------
 * Test Type 2
 * Look for dup piece names
 */
IGRstat VDatTest2PcmksForNode(IGRint test, TGRid *nodeID)
{
  IGRstat retFlag = 0;
  
  TVDatPcmkInfos infos;
  TVDatPcmkInfo *info;
  
  IGRint i;
  
  // Trace memory
  VD_memOn();
  VD_memReset();

  // Init
  memset(&infos,0,sizeof(TVDatPcmkInfos));
  
  // Arg check
  if (nodeID == NULL) goto wrapup;
  
  // Get the infos
  VDatGetPcmkInfos(nodeID,&infos);
  if (infos.infos == NULL) {
    printf("Problem getting list of piece mark information\n");
    goto wrapup;
  }
  
  // Sort them
  qsort(infos.infos,infos.cnt,sizeof(TVDatPcmkInfo),VDatSortPcmkInfoTest2);
  
  // header
  printf("======== Test %d =========\n",test);
  printf("OS  OBJID  PCMK NAME\n");

  // For 20 just dump it all
  if (test == 20) {
    for(i = 0; i < infos.cnt; i++) {
      info = &infos.infos[i];
      VDatTest2PrintPcmk(info);
    }
  }
  
  // For 21, looking for anomilies
  if (test == 21) {
    for(i = 0; i < infos.cnt; i++) {
      info = &infos.infos[i];
      VDatTest21Pcmk(&infos,i,info);
    }
  }
    
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

end implementation VDatBase;





