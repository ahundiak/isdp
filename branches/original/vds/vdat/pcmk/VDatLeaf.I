/* $Id: VDatLeaf.I,v 1.2 2001/01/11 20:54:46 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/leaf/VDatLeaf.I
 *
 * Description: Piece Mark Leaf Processing
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatLeaf.I,v $
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
  IGRchar path[128];
  IGRchar *p;
  
  TGRobj_env pieceOE;
  
  // Arg check
  if (leaf   == NULL) goto wrapup;
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
  if (pieceOE.obj_id.objid == NULL_OBJID) {
    printf("*** Unable to get piece for leaf %d,%d\n",leafID->osnum,leafID->objid);
    goto wrapup;
  }
  
  // Check if consumed
  msg = 0;
  sts = om$send(msg = message NDmacro.ACtest_consumed(&msg),
		senderid = NULL_OBJID,
		targetid = pieceOE.obj_id.objid,
		targetos = pieceOE.obj_id.osnum);

  if (sts & msg & 1) {
    printf("*** Piece object is consumed\n");
    vdobj$Print(objOE = &pieceOE);
    vdobj$Print(objID = leafID);
    printf("---\n");
  }
  
  // Store It
  leaf->pieceOE = pieceOE;

  // Store the entire path
  *path = 0;
  om$send(msg = message GRgraphics.GRgetname(&msg,path),
	  senderid = NULL_OBJID,
	  targetid = pieceOE.obj_id.objid,
	  targetos = pieceOE.obj_id.osnum);

  // Drop any ref file info
  p = strstr(path,":ref:");
  if (p) strcpy(path,p+4);
  *(path+78) = 0;
  
  strcpy(leaf->piecePath,path);
  p = strrchr(leaf->piecePath,':');
  if (p) leaf->pieceName = p;
  else   leaf->pieceName = leaf->piecePath;
  
  // Get the piece name
#if 0
  vdsa$GetStruct(objOE = &pieceOE,
		 name  = "memb_name",
		 txt   = leaf->pieceName);
#endif
  
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
 * Supports nodes,sets or trees
 */
IGRstat VDatGetPcmkLeafInfos(TGRid          *nodeID,
			     TVDatPcmkInfos *infos)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  IGRuint i,j;

  TGRid   leafsID;
  TGRid   leafID;
  TGRid   listID;

  TGRid   childID;
  IGRint  type;
  
  // Arg check
  if (infos == NULL) goto wrapup;

  // Make sure have room for more
  if (infos->cnt >= infos->max) goto wrapup;

  // User stop
  if (IGEstop()) goto wrapup;
  
  // Support different node types
  VDatGetBaseType(nodeID,&type);
  switch(type) {

  case VDAT_CLASSI_LEAF:
    VDatGetPcmkLeafInfo(nodeID,infos->infos[infos->cnt].leaf);
    infos->cnt++;
    break;
    
  case VDAT_CLASSI_SET:

    // Get list of sets
    VDatGetLeafs(nodeID,&leafsID);
    if (leafsID.objid == NULL_OBJID) goto wrapup;

    // Cycle through
    for(i = 0; VDatGetChildObject(&leafsID,i,&listID); i++) {
      for(j = 0; VDatGetChildObject(&listID,j,&leafID); j++) {
	VDatGetPcmkLeafInfos(&leafID,infos);
      }
    }
    break;


  case VDAT_CLASSI_TREE: 
  case VDAT_CLASSI_NODE:

    // Recursive Loop
    for(i = 0; VDatGetChildObject(nodeID,i,&childID); i++) {
	VDatGetPcmkLeafInfos(&childID,infos);
    }
    break;
  }

  // Done
  retFlag = 1;
  
 wrapup:
  return retFlag;
}

end implementation VDatBase;





