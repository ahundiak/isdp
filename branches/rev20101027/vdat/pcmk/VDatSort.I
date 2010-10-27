/* $Id: VDatSort.I,v 1.1 2001/01/11 20:54:46 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk/VDatSort.I
 *
 * Description: Various Sorting Routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatSort.I,v $
 *      Revision 1.1  2001/01/11 20:54:46  art
 *      sp merge
 *
# Revision 1.1  2000/11/27  19:35:18  pinnacle
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

  // Push notLikes down
  if ((leaf1->notLike == 1) && (leaf2->notLike == 0)) return  1;
  if ((leaf1->notLike == 0) && (leaf2->notLike == 1)) return -1;
  
  // Then by name
  sts = strcmp(leaf1->pieceName,leaf2->pieceName);
  if (sts) return sts;
  
  // The same???
  return 0;
}

end implementation VDatBase;
