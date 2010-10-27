/* $Id: VDatAll.I,v 1.3 2001/03/16 17:04:08 ahundiak Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/cmd/VDatAll.I
 *
 * Description: Common command routines
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatAll.I,v $
 *      Revision 1.3  2001/03/16 17:04:08  ahundiak
 *      ah
 *
 *      Revision 1.2  2001/01/11 20:23:18  art
 *      sp merge
 *
# Revision 1.1  2000/06/27  16:37:32  pinnacle
# ah
#
# Revision 1.3  1998/10/11  13:53:52  pinnacle
# ah
#
# Revision 1.2  1998/09/25  15:44:20  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/10/97  ah      creation
 * 06/21/00  ah      Update status when set activation is complete
 * 03/14/01  ah      Added Piece Mark Ver 2
 ***************************************************************************/

class implementation VDatBase;

#include "VDatCmd.h"

/* ------------------------------------------------
 * Sees if set is in the active file
 */
IGRstat VDatIsSetInActiveOS(TGRid *setID)
{
  IGRstat retFlag = 0;
  TGRid   curID;
  
  ex$get_cur_mod(id = &curID.objid, osnum = &curID.osnum);
  
  if (setID->osnum == curID.osnum) {
    retFlag = 1;  
  }
  return retFlag;
}

/* ------------------------------------------------
 * Sees if set is a tree
 */
IGRstat VDatIsSetATree(TGRid *setID)
{
  IGRstat retFlag = 0;
  TGRid   rdbNodesID;
  TGRid   rdbNodeID;
  IGRint i;
  
  // Now see if tree exists
  VDatRDBGetNodes(setID,&rdbNodesID);
  if (rdbNodesID.objid == NULL_OBJID) goto wrapup;

  for(i = 0; VDatGetChildObject(&rdbNodesID,i,&rdbNodeID); i++);
  if (i > 1) retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Returns object's position on channel
 */
IGRstat VDatGetChildIndex(TGRid *mainID, TGRid *childID, IGRint *index)
{
  IGRstat retFlag = 0;
  IGRint  i;
  TGRid   childIDx;

  // Init
  *index = -1;

  // Find it
  for(i = 0; VDatGetChildObject(mainID,i,&childIDx); i++) {

    if ((childID->objid == childIDx.objid) &&
        (childID->osnum == childIDx.osnum)) {
      *index  = i;
      retFlag = 1;
      goto wrapup;
    }
  }
wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Moves object either up or down on a channel
 */
IGRstat VDatMoveChildObject(
  TGRid   *mainID,
  TGRid   *moveID,
  IGRint   dir
)
{
  IGRstat  retFlag = 0;
  IGRstat  sts;

  TVDvlaID objVLA;
  IGRint   i,j;
  TGRid    objID;

  // Init
  VDvlaID_Construct(&objVLA);

  // Arg check
  if ((mainID == NULL) || (mainID->objid == NULL_OBJID)) goto wrapup;
  if ((moveID == NULL) || (moveID->objid == NULL_OBJID)) goto wrapup;

  // Find the object in quest
  sts = VDatGetChildIndex(mainID,moveID,&i);
  if (sts != 1) goto wrapup;

  // Know position of the object on the channel
  if (dir == 0) i--;
  if (i < 0) goto wrapup; // Object is already first

  // Save the id's to move
  j = 0;
  for(; VDatGetChildObject(mainID,i,&objID); i++) {
    VDvlaID_Append(&objVLA,&objID);
    j++;
  }
  if (j == 1) goto wrapup;  // At end of channel already

  // Drop them off channel
  for(j = 0; VDvlaID_GetAt(&objVLA,&objID,j); j++) {
    VDatDelParent(&objID,mainID);
  }
  
  // Swap first two
  VDvlaID_GetAt(&objVLA,&objID,1);
  VDatAddParent(&objID,  mainID);
  VDvlaID_GetAt(&objVLA,&objID,0);
  VDatAddParent(&objID,  mainID);

  // Put rest back on
  for(j = 2; VDvlaID_GetAt(&objVLA,&objID,j); j++) {
    VDatAddParent(&objID,mainID);
  }
  
  retFlag = 1;

wrapup:
  VDvlaID_Delete(&objVLA);
  return retFlag;
}

/* ------------------------------------------------
 * Gets the active set if one is selected
 */
IGRstat VDatCMDAllGetActiveSet(
  TVDatFrmList *fl, 
  TGRid        *a_setID, 
  IGRchar      *a_setName)
{
  IGRstat retFlag = 0;
  TGRid   setID;

  // Init
  if (a_setID)    a_setID->objid = NULL_OBJID;
  if (a_setName) *a_setName = 0;

  // Arg check
  if ((fl == NULL) || (fl->mgr == NULL)) goto wrapup;

  // Get the id
  VDahFrmGetGRid(fl->mgr,VDAT_FORM_ALL_L_MISC,1,0,&setID);
  if (setID.objid == NULL_OBJID) goto wrapup;

  // Xfer
  if (a_setID) *a_setID = setID;
  
  // Get name of requested
  if (a_setName) {
    VDatGetBaseName(&setID,a_setName);
  }

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Gets the active leaf if have one
 */
IGRstat VDatCMDAllGetActiveLeaf(TVDatFrmList *fl, TGRid *leafID)
{
  IGRstat retFlag = 0;

  // Init
  leafID->objid = NULL_OBJID;

  // Arg check
  if ((fl == NULL) || (fl->mgr == NULL)) goto wrapup;

  // Get the id
  VDahFrmGetGRid(fl->mgr,VDAT_FORM_ALL_L_MISC,2,0,leafID);
  if (leafID->objid == NULL_OBJID) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Gets the active node if have one
 */
IGRstat VDatCMDAllGetActiveNode(TVDatFrmList *fl, TGRid *nodeID)
{
  IGRstat retFlag = 0;

  // Init
  nodeID->objid = NULL_OBJID;

  // Arg check
  if ((fl == NULL) || (fl->mgr == NULL)) goto wrapup;

  // Get the id
  VDahFrmGetGRid(fl->mgr,VDAT_FORM_ALL_L_MISC,3,0,nodeID);
  if (nodeID->objid == NULL_OBJID) goto wrapup;

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Stores the active set
 */
IGRstat VDatCMDAllSetActiveSet(TVDatFrmList *fl, TGRid *setID)
{
  IGRstat retFlag = 0;
  IGRint  msg;

  // Unhilite anything
  dp$erase_hilite(msg = &msg);

  // Arg check
  if ((fl == NULL) || (fl->mgr == NULL) || (setID == NULL)) goto wrapup;

  // Store in misc array
  VIfld_set_num_rows(fl->mgr,VDAT_FORM_ALL_L_MISC,1);
  VDahFrmSetGRid(fl->mgr,VDAT_FORM_ALL_L_MISC,1,0,setID);

  // Inform other forms (they call get active set)
  VDatCMDMgrActivateSet  (fl);
  VDatCMDSetActivateSet  (fl);
  VDatCMDLeafActivateSet (fl);
  VDatCMDTreeActivateSet (fl);
  VDatCMDAttrActivateSet (fl);
  VDatCMDPcmkActivateSet (fl);
  VDatCMDPcmk2ActivateSet(fl);
  VDatCMDStageActivateSet(fl);
  UI_status("Set Activated");
  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Stores the active leaf
 */
IGRstat VDatCMDAllSetActiveLeaf(TVDatFrmList *fl, TGRid *leafID)
{
  IGRstat retFlag = 0;

  // Arg check
  if ((fl == NULL) || (fl->mgr == NULL) || (leafID == NULL)) goto wrapup;

  // Store in misc array
  VIfld_set_num_rows(fl->mgr,VDAT_FORM_ALL_L_MISC,4);
  VDahFrmSetGRid(fl->mgr,VDAT_FORM_ALL_L_MISC,2,0,leafID);

  // Inform other forms (they call get active leaf)
  VDatCMDAttrActivateLeaf(fl);

  //VDatCMDSetActivateSet  (fl);
  //VDatCMDLeafActivateSet (fl);
  //VDatCMDTreeActivateSet (fl);
  //VDatCMDStageActivateSet(fl);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ------------------------------------------------
 * Stores the active node
 */
IGRstat VDatCMDAllSetActiveNode(TVDatFrmList *fl, TGRid *nodeID)
{
  IGRstat retFlag = 0;

  // Arg check
  if ((fl == NULL) || (fl->mgr == NULL) || (nodeID == NULL)) goto wrapup;

  // Store in misc array
  VIfld_set_num_rows(fl->mgr,VDAT_FORM_ALL_L_MISC,4);
  VDahFrmSetGRid(fl->mgr,VDAT_FORM_ALL_L_MISC,3,0,nodeID);

  // Inform other forms
  VDatCMDAttrActivateNode (fl);
  VDatCMDTreeActivateNode (fl);
  VDatCMDStageActivateNode(fl);

  //VDatCMDSetActivateSet  (fl);
  //VDatCMDLeafActivateSet (fl);


  retFlag = 1;

wrapup:
  return retFlag;
}

end implementation VDatBase;


















