/* $Id: VDctzStaging.c,v 1.2 2001/08/24 20:00:01 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdval/x2/VDctzAtr.c
 *
 * Description:	Meta interface to the staging tree
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDctzStaging.c,v $
 *      Revision 1.2  2001/08/24 20:00:01  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/06/22 15:12:54  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/06/03 15:02:59  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/29/01  ah      Creation
 ***************************************************************************/
#include "VDtypedefc.h"
#include "VDassert.h"
#include "VDlog.h"
#include "VDctx.h"
#include "VDctz.h"

VDASSERT_FFN("vdval/x2/VDctzStaging.c");

/* -----------------------------------------------
 * Returns the meta staging name for either an
 * an actual stage or a staged piece
 *
 * Does not validate the node to see if it really is
 * part of a staging tree, use the Is routines first
 * if there is any doubt
 */
void VDctzGetStagingName(TGRid *nodeID, IGRchar *stageName)
{
  VDASSERT_FN("VDctzGetStagingName");
  
  IGRchab type;
  IGRchar *p;
  
  // Arg check
  VDASSERTW(stageName); *stageName = 0;
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);
  
  // Start with the node type
  VDctxGetNodeType(nodeID,type);

  // Check spades tree
  if (!strcasecmp(type,"PDF_OBJ_TREE_NODE")) {

    VDctxGetTxtAtr(nodeID,"PDF_ATR_TREE_NODE_TYPE",type);
    VDctxGetTxtAtr(nodeID,"PDF_ATR_TREE_NODE_NAME",stageName);

    // Some of the SA types are broken up
    if (!strcasecmp(type,"SA")) {
      if ((*stageName >= 'A') && (*stageName <= 'Z')) *stageName = 0;
      if ((*stageName >= 'a') && (*stageName <= 'a')) *stageName = 0;
    }
    
    goto wrapup;
  }

  // node_name is used internally for many things
  VDctxGetTxtAtr(nodeID,"node_name",stageName);
  if (*stageName) goto wrapup;
  
  // Hack for comp_path
  VDctxGetTxtAtr(nodeID,"comp_path",type);
  if (*type) {
    p = strrchr(type,':');
    if (p) strcpy(stageName,p+1);
    else   strcpy(stageName,type);
    goto wrapup;
  }
  
  // Other wise it should respond to node name routine?
  //VDctxGetNodeName(nodeID,stageName);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Returns the meta staging type for either an
 * an actual stage or a staged piece
 *
 * Does not validate the node to see if it really is
 * part of a staging tree, use the Is routines first
 * if there is any doubt
 */
void VDctzGetStagingType(TGRid *nodeID, IGRchar *stageType)
{
  VDASSERT_FN("VDctzGetStagingType");
  
  IGRchab type;
  
  // Arg check
  VDASSERTW(stageType); *stageType = 0;
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);
  
  // Start with the node type
  VDctxGetNodeType(nodeID,type);

  // Check spades tree
  if (!strcasecmp(type,"PDF_OBJ_TREE_NODE")) {

    VDctxGetTxtAtr(nodeID,"PDF_ATR_TREE_NODE_TYPE",stageType);

    // Some of the SA types are broken up
    if (!strcasecmp(stageType,"SA")) {
      VDctxGetTxtAtr(nodeID,"PDF_ATR_TREE_NODE_NAME",type);
      if ((*type >= 'A') && (*type <= 'Z')) strcat(stageType,type);
      if ((*type >= 'a') && (*type <= 'z')) strcat(stageType,type);
    }
    
    goto wrapup;
  }
  
  // Check snapshot tree
  if (!strncasecmp(type,"ss_st_",6)) {
    strcpy(stageType,type+6);
    goto wrapup;
  }
  
  // Just the regular type
  strcpy(stageType,type);
  
 wrapup:

  // Just for grins, the meta names are all upper case
  if (stageType) strupr(stageType);
  
  return;
}

/* -----------------------------------------------
 * Returns true if meta stage type is a stage
 */
static IGRstat isStageTypeStage(IGRchar *stageType)
{
  if (!strcasecmp(stageType,"unit")) return 1;
  if (!strcasecmp(stageType,"sa"  )) return 1;
  if (!strcasecmp(stageType,"sae" )) return 1;
  if (!strcasecmp(stageType,"sab" )) return 1;
  if (!strcasecmp(stageType,"saf" )) return 1;
  if (!strcasecmp(stageType,"sam" )) return 1;
  if (!strcasecmp(stageType,"cpsu")) return 1;
  if (!strcasecmp(stageType,"psa" )) return 1;
  if (!strcasecmp(stageType,"psu" )) return 1;

  return 0;
}

/* -----------------------------------------------
 * Returns true if meta stage type is a staged piece
 */
static IGRstat isStageTypePiece(IGRchar *stageType)
{
  if (!strcasecmp(stageType,"pm"))    return 1;
  if (!strcasecmp(stageType,"plate")) return 1;
  if (!strcasecmp(stageType,"beam"))  return 1;
  
  return 0;
}

/* -----------------------------------------------
 * Returns true if node is in a staging tree
 */
IGRstat VDctzIsStagingStage(TGRid *nodeID)
{
  VDASSERT_FN("VDctzIsStagingStage");
  IGRstat retFlag = 0;
  
  IGRchab stageType;
  
  // Arg check
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);

  // Get the meta node
  VDctzGetStagingType(nodeID,stageType);
  
  // Test
  retFlag = isStageTypeStage(stageType);
  
 wrapup:
  return retFlag;
}
/* -----------------------------------------------
 * Returns true if node is a staged piece
 */
IGRstat VDctzIsStagingPiece(TGRid *nodeID)
{
  VDASSERT_FN("VDctzIsStagingPiece");
  IGRstat retFlag = 0;
  
  IGRchab stageType;
  
  // Arg check
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);

  // Get the meta node
  VDctzGetStagingType(nodeID,stageType);
  
  // Test
  retFlag = isStageTypePiece(stageType);
  
 wrapup:
  return retFlag;
}
/* -----------------------------------------------
 * Returns true if node is in a staging tree or
 * is a staged piece
 */
IGRstat VDctzIsStagingStageOrPiece(TGRid *nodeID)
{
  VDASSERT_FN("VDctzIsStagingStageOrPiece");
  IGRstat retFlag = 0;
  
  IGRchab stageType;
  
  // Arg check
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);

  // Get the meta node
  VDctzGetStagingType(nodeID,stageType);
  
  // Test
  retFlag = isStageTypeStage(stageType);
  if (retFlag == 0) {
    retFlag = isStageTypePiece(stageType);
  }
  
 wrapup:
  return retFlag;
}

/* -----------------------------------------------
 * Gets the platen attribute
 */
void VDctzGetStagingPlaten(TGRid *nodeID, IGRchar *platen) 
{
  VDASSERT_FN("VDctzGetStagingPlaten");
  
  // Arg check
  VDASSERTW(platen); *platen = 0;
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);
  
  // Kee it simple
  VDctxGetTxtAtr(nodeID,"u_platen",platen);
  if (*platen) goto wrapup;
  
  VDctxGetTxtAtr(nodeID,"PDF_ATR_TREE_NODE_PLATEN",platen);
  if (*platen) goto wrapup;

 wrapup:
  return;
}

/* -----------------------------------------------
 * Returns the piece mark if one exists
 * add this here for now until things get sorted out
 */
void VDctzGetPieceMark(TGRid *nodeID, IGRchar *pcmk)
{
  VDASSERT_FN("VDctzGetPieceMark");

  IGRchab buf;
  
  // Arg check
  VDASSERTW(pcmk); *pcmk = 0;
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);

  VDctxGetTxtAtr(nodeID,"pcmk",pcmk);
  if (*pcmk) goto wrapup;

  VDctxGetTxtAtr(nodeID,"PCMK",pcmk);
  if (*pcmk) goto wrapup;

  VDctxGetTxtAtr(nodeID,"PDF_ATR_TREE_NODE_PCMK",pcmk);
  if (*pcmk) goto wrapup;

  VDctxGetNodeType(nodeID,buf);
  printf("%s failed for %s %d\n",fn,buf,nodeID->osnum);
  
 wrapup:
  return;
}

/* -----------------------------------------------
 * Might be getting too specific her but see what happens
 */
void VDctzGetPieceName(TGRid *nodeID, IGRchar *name)
{
  VDASSERT_FN("VDctzGetPieceName");

  // Arg check
  VDASSERTW(name); *name = 0;
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);

  VDctxGetTxtAtr(nodeID,"PDF_ATR_TREE_NODE_NAME",name);
  if (*name) goto wrapup;

 wrapup:
  return;
}

/* -----------------------------------------------
 * Might be getting too specific here but see what happens
 */
void VDctzGetStagingParentName(TGRid *nodeID, IGRchar *name)
{
  VDASSERT_FN("VDctzStagingParentName");

  // Arg check
  VDASSERTW(name); *name = 0;
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);

  VDctxGetTxtAtr(nodeID,"PDF_ATR_TREE_NODE_PARENT",name);
  if (*name) goto wrapup;

 wrapup:
  return;
}

/* -----------------------------------------------
 * Is it some sort of plate
 * Not part of a staging tree
 */
IGRstat VDctzIsPlate(TGRid *nodeID)
{
  VDASSERT_FN("VDctzIsPlate");
  IGRstat retFlag = 1;
  
  IGRchab type;

  // Arg check
  VDASSERTW(nodeID && nodeID->objid != NULL_OBJID);
  
  // Checks
  VDctxGetNodeType(nodeID,type);
  if (!strcasecmp(type,"PDF_OBJ_PLATE")) goto wrapup;
  
  // Nope
  retFlag = 0;
  
 wrapup:
  return retFlag;
}

  
