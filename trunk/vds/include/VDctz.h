/* $Id: VDctz.h,v 1.2 2001/06/22 15:00:37 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/include/VDctz.h
 *
 * Description: Meta tree routines
 *
 * Dependencies: 
 *
 * Revision History:
 *      $Log: VDctz.h,v $
 *      Revision 1.2  2001/06/22 15:00:37  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/06/03 14:40:53  ahundiak
 *      ah
 *
 *      Revision 1.1  2001/05/24 18:35:35  ahundiak
 *      ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 05/23/01  ah      Created
 ***************************************************************************/

#ifndef VDctz_include
#define VDctz_include

#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ----------------------------------------------
 * The basic idea is that these names are the same across
 * all tree types
 */
#define VDCTZ_ATR_NODE_TYPE "node_type"
#define VDCTZ_ATR_NODE_NAME "node_name"
#define VDCTZ_ATR_PCMK      "pcmk"
#define VDCTZ_ATR_PLATEN    "platen"

#define VDCTZ_OBJ_STAGING_TREE_NODE "staging_tree_node"

extern void VDctzGetTxtAtr __((TGRid *nodeID, IGRchar *name, IGRchar *value));

extern void    VDctzGetNodeType __((TGRid *nodeID, IGRchar *type));  
extern IGRstat VDctzIsNodeType  __((TGRid *nodeID, IGRchar *type));
  
extern void VDctzGetStagingType   __((TGRid *nodeID, IGRchar *stageType));
extern void VDctzGetStagingName   __((TGRid *nodeID, IGRchar *stageName));
extern void VDctzGetStagingPlaten __((TGRid *nodeID, IGRchar *platen));
  
extern IGRstat VDctzIsStagingStage        __((TGRid *nodeID));
extern IGRstat VDctzIsStagingPiece        __((TGRid *nodeID));
extern IGRstat VDctzIsStagingStageOrPiece __((TGRid *nodeID));

extern void VDctzGetPieceMark __((TGRid *nodeID, IGRchar *pcmk));
extern void VDctzGetPieceName __((TGRid *nodeID, IGRchar *name));

extern void VDctzGetStagingParentName __((TGRid *nodeID, IGRchar *name));  
  
extern IGRstat VDctzIsPlate __((TGRid *nodeID));
  

/* ----------------------------------------------
 * Cleanup
 */
#if defined(__cplusplus)
}
#endif

#endif
