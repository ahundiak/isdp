/* $Id: VDatInfo2.I,v 1.1 2001/01/11 20:54:46 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/pcmk/VDatInfo2.I
 *
 * Description: Piece Mark Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatInfo2.I,v $
 *      Revision 1.1  2001/01/11 20:54:46  art
 *      sp merge
 *
# Revision 1.1  2000/11/27  19:35:18  pinnacle
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

VDASSERT_FFN("vdat/pcmk/VDatInfo2.I");

/* -----------------------------------------------
 * Getting really desperate here
 */
IGRstat VDatResetPcmkInfos(TVDatPcmkInfos *infos)
{
  VDASSERT_FN("VDatGetPcmkInfos");
  IGRstat retFlag = 0;

  VDASSERTW(infos);
  infos->cnt = 0;
  infos->max = 0;
  infos->infos = NULL;
  infos->leafs = NULL;
  infos->attrs = NULL;
  
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Return a list of pcmk information in the tree
 * Works with either set,tree or node
 */
IGRstat VDatGetPcmkInfos(TGRid          *nodeID,  
			 TVDatPcmkInfos *infos)
{
  VDASSERT_FN("VDatGetPcmkInfos");
  
  IGRstat retFlag = 0;
  IGRint  cnt = 0;
  IGRint  i;
  
  // Arg check
  VDASSERTW(infos);
  VDatResetPcmkInfos(infos);
  VDASSERTW(nodeID);
  
  // Count em
  VDatGetNumLeafs(nodeID,&cnt);
  if (cnt <= 0) goto wrapup;
  infos->max = cnt;
  
  // Pointer list
  infos->infos = calloc(cnt,sizeof(TVDatPcmkInfo));
  VDASSERTW(infos->infos);
  
  // Leaf list
  infos->leafs = calloc(cnt,sizeof(TVDatPcmkLeafInfo));
  VDASSERTW(infos->leafs);
   
  // Attach leafs to main list
  for(i = 0; i < cnt; i++) {
    infos->infos[i].leaf = &infos->leafs[i];
    infos->leafs[i].pieceName = infos->leafs[i].piecePath;
  }
  
  // Recursive loop to fill in information
  VDatGetPcmkLeafInfos(nodeID,infos);

  // Just a check
  VDASSERTW(infos->cnt == infos->max);
    
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
  
  IGRint i,j;

  // Arg check
  if (infos == NULL) goto wrapup;

  // Free any allocated geomotry information
  for(i = 0; i < infos->cnt; i++) {
    if (infos->infos[i].tran) VDefpFreeTranInfo(infos->infos[i].tran);
  }

  // Free the pointers
  if (infos->attrs) free(infos->attrs);
  if (infos->attrs) free(infos->leafs);
  if (infos->attrs) free(infos->infos);

  // Reset
  VDatResetPcmkInfos(infos);
  
  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}


end implementation Root;
