/* $Id: VDatSet.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdat/cmd/VDatSet.I
 *
 * Description: Set creation form
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDatSet.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:42  cvs
 *      Initial import to CVS
 *
# Revision 1.3  1998/11/07  14:06:32  pinnacle
# ah
#
# Revision 1.2  1998/10/11  13:53:52  pinnacle
# ah
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/10/97  ah      creation
 *
 ***************************************************************************/
class implementation VDatBase;

#include "VDatCmd.h"

#define VDAT_FORM_SET_L_SETS      21
#define VDAT_FORM_SET_G_SET_TYPE  12
#define VDAT_FORM_SET_G_SET_DESC  16
#define VDAT_FORM_SET_G_PIECE_TBL 28
#define VDAT_FORM_SET_G_TREE_TBL  29

#define VDAT_FORM_SET_B_CREATE_SET 20
#define VDAT_FORM_SET_B_DELETE_SET 13
#define VDAT_FORM_SET_B_RENAME_SET 19

IGRstat VDatCMDSetDeleteSet (TVDatFrmList *fl);
IGRstat VDatCMDSetCreateSet (TVDatFrmList *fl);
IGRstat VDatCMDSetRenameSet (TVDatFrmList *fl);

IGRstat VDatCMDSetFillMisc  (Form form, IGRchar *rdbSetType);
IGRstat VDatCMDSetNotifyType(Form form);
IGRstat VDatCMDSetFillTypes (Form form, IGRint gadget);

IGRstat VDatCMDSetNotifyForm  (TVDatFrmList *fl);
IGRstat VDatCMDSetActivateForm(TVDatFrmList *fl);

IGRstat VDatCMDSetActivateSet (TVDatFrmList *fl);

/* ----------------------------------------
 * Initializes the form with a new active set
 */
IGRstat VDatCMDSetActivateSet(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  IGRstat sts;

  TGRid   setID;
  Form    form = fl->set;

  IGRchar setName[128];
  IGRchar rdbSetType[128];

  // Ignore if the form is not active
  sts = VDatFormIsActive(form);
  if (sts != 1) goto wrapup;

  // get the active set
  VDatCMDAllGetActiveSet(fl,&setID,setName);
  if (setID.objid == NULL_OBJID) goto wrapup;

  VIg_set_text(form,VDAT_FORM_ALL_G_SET_NAME,setName);

  VDatRDBGetSetType (&setID,rdbSetType);
  VDatCMDSetFillMisc(form,  rdbSetType);

  // If the set is in a reference file, disable some gadgets
  if ((setID.objid == NULL_OBJID) || (VDatIsSetInActiveOS(&setID))) {    
    VIg_enable(form,VDAT_FORM_SET_B_CREATE_SET);
    VIg_enable(form,VDAT_FORM_SET_B_DELETE_SET);
    VIg_enable(form,VDAT_FORM_SET_B_RENAME_SET);
    VIg_enable(form,VDAT_FORM_SET_G_SET_TYPE);
  }
  else {
    VIg_disable(form,VDAT_FORM_SET_B_DELETE_SET);
    VIg_disable(form,VDAT_FORM_SET_B_RENAME_SET);
  }
  
  retFlag = 1;
wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Delete a set
 */
IGRstat VDatCMDSetDeleteSet(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;

  Form    form = fl->set;

  TGRid   setID;

  IGRchar setName [128];
  IGRchar setNameX[128];

  // Use global active set
  VDatCMDAllGetActiveSet(fl,&setID,setName);
  if (setID.objid == NULL_OBJID) goto wrapup;

  // Make sure only active set is meant to be deleted
  *setNameX = 0;
  VIg_get_text(form,VDAT_FORM_ALL_G_SET_NAME,setNameX);
  if (strcmp(setName,setNameX)) {
    VDatCMDStatus(form,"Set Name does not match active set");
    goto wrapup;
  }

  // Delete it
  VDatDeleteBase(&setID);

  // Tell the manager
  VDatCMDMgrDeleteSet(fl,&setID,setName);

  // Done
  VDatCMDStatus(form,"Set Deleted");

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Rename a set
 */
IGRstat VDatCMDSetRenameSet(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;

  Form    form = fl->set;

  TGRid   mgrID;
  TGRid   setID;
  TGRid   setIDx;
  TGRid   treeID;
  
  IGRchar setType [128];
  IGRchar setName [128];
  IGRchar setNameX[128];

  // Use global active set
  VDatCMDAllGetActiveSet(fl,&setID,setName);
  if (setID.objid == NULL_OBJID) goto wrapup;

  // Get the new name
  *setNameX = 0;
  VIg_get_text(form,VDAT_FORM_ALL_G_SET_NAME,setNameX);
  if (!strcmp(setName,setNameX)) {
    VIg_set_text(form,10,"Enter new set name first");
    goto wrapup;
  }

  // Get the manager
  vdat$GetSetMgr(mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) {
    VIg_set_text(form,10,"No Set Manager found");
    goto wrapup;
  }

  // Get the type
  VDatGetSetType(&setID,setType);
  
  // Make sure set does not already exist
  VDatGetSetByName(&mgrID,setType,setNameX,&setIDx);
  if (setIDx.objid != NULL_OBJID) {
    VIg_set_text(form,10,"Set already exists");
    goto wrapup;
  }

  // Rename
  VDatSetBaseName(&setID,setNameX);

  // If it is a tree then rename the top node as well
  VDatGetTree(&setID,&treeID);
  if (treeID.objid != NULL_OBJID) {
    VDatSetNodeName(&treeID,setNameX);
  }

  // Tell the manager
  VDatCMDMgrRenameSet(fl,&setID,setNameX);

  // Update lists

  VIg_set_text(form,10,"Set Renamed");

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Create a set
 */
IGRstat VDatCMDSetCreateSet(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;

  Form    form = fl->set;

  TGRid   mgrID;
  TGRid   setID,treeID;

  IGRchar setName[128];
  IGRchar setType[128];

  TGRid   rdbSetID;

  TGRid   rdbNodesID,rdbNodeID;
  IGRint  i;

  // Get the name
  *setName = 0;
  VIg_get_text(form,VDAT_FORM_ALL_G_SET_NAME,setName);
  if (*setName == 0) {
    VIg_set_text(form,10,"Set Name must be filled in");
    goto wrapup;
  }

  // Get the manager
  vdat$GetSetMgr(mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) {
    VIg_set_text(form,10,"No Set Manager found");
    goto wrapup;
  }

  // Get the type of set
  *setType = 0;
  VIg_get_text(form,VDAT_FORM_SET_G_SET_TYPE,setType);
  VDatRDBGetSetByType(&mgrID,setType,&rdbSetID);
  if (rdbSetID.objid == NULL_OBJID) {
    VIg_set_text(form,10,"Invalid set type");
    goto wrapup;
  }

  // Make sure set does not already exist   
  VDatGetSetByName(&mgrID,setType,setName,&setID);
  if (setID.objid != NULL_OBJID) {
    VIg_set_text(form,10,"Set already exists");
    goto wrapup;
  }

  // Create it
  VDatCreateSet(&mgrID,&rdbSetID,setName,&setID);
  if (setID.objid == NULL_OBJID) {
    VIg_set_text(form,10,"Set Creation Failed");
    goto wrapup;
  }

  // Update List
  VIg_set_text(form,10,"Set Created");

  // Now see if tree exists
  VDatRDBGetNodes(&rdbSetID,&rdbNodesID);
  if (rdbNodesID.objid == NULL_OBJID) goto wrapup;

  for(i = 0; VDatGetChildObject(&rdbNodesID,i,&rdbNodeID); i++);
  if (i <= 1) {
    goto set_created;
  }
  i--;
  VDatGetChildObject(&rdbNodesID,i,&rdbNodeID);
  VDatCreateTree(&setID,&rdbNodeID,setName,&treeID);

  if (treeID.objid == NULL_OBJID) {
    VIg_set_text(form,10,"Tree Creation Failed");
    goto wrapup;
  }
  VIg_set_text(form,10,"Set/Tree Created");

set_created:

  // Tell the manager, a new set was added
  VDatCMDMgrAddSet(fl,&setID,setName,setType);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Fills in misc fields
 */
IGRstat VDatCMDSetFillMisc(Form form, IGRchar *setType)
{
  IGRstat retFlag = 0;

#if 0
  TGRid mgrID;
  TGRid           rdbSetID;
  TVDatRDBSetInfo rdbSetINFO;

  TGRid rdbNodesID;
  TGRid rdbNodeID;

  IGRchar tblName[128];
#endif

  IGRchar setTypeDesc     [128];
  IGRchar setTypeTreeTable[128];
  IGRchar setTypeLeafTable[128];

  // Init
  VIg_set_text(form,VDAT_FORM_SET_G_SET_DESC, "");
  VIg_set_text(form,VDAT_FORM_SET_G_PIECE_TBL,"");
  VIg_set_text(form,VDAT_FORM_SET_G_TREE_TBL, "");

  vdat$GetSetTypeInfo(setType          = setType,
                      setTypeDesc      = setTypeDesc,
                      setTypeTreeTable = setTypeTreeTable,
                      setTypeLeafTable = setTypeLeafTable);

  if (*setTypeTreeTable == 0) strcpy(setTypeTreeTable,"Not a tree");

  VIg_set_text(form,VDAT_FORM_SET_G_SET_TYPE, setType);
  VIg_set_text(form,VDAT_FORM_SET_G_SET_DESC, setTypeDesc);
  VIg_set_text(form,VDAT_FORM_SET_G_PIECE_TBL,setTypeLeafTable);
  VIg_set_text(form,VDAT_FORM_SET_G_TREE_TBL, setTypeTreeTable);

  retFlag = 1;

//wrapup:
  return retFlag;
}
#if 0
  // Set desc
  vdat$GetSetMgr(mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) goto wrapup;

  VDatRDBGetSetByType(&mgrID,rdbSetType,&rdbSetID);
  if (rdbSetID.objid == NULL_OBJID) goto wrapup;

  VDatRDBGetSetInfo(&rdbSetID,&rdbSetINFO);
  VIg_set_text(form,VDAT_FORM_SET_G_SET_TYPE,rdbSetINFO.setType);
  VIg_set_text(form,VDAT_FORM_SET_G_SET_DESC,rdbSetINFO.setDesc);
  VIg_set_text(form,10,                      rdbSetINFO.setDesc);

  VDatRDBGetNodes(&rdbSetID,&rdbNodesID);
  if (rdbNodesID.objid == NULL_OBJID) goto wrapup;

  VDatGetChildObject(&rdbNodesID,0,&rdbNodeID);
  if (rdbNodeID.objid == NULL_OBJID) goto wrapup;

  VDatRDBGetTableName(&rdbNodeID,tblName);
  VIg_set_text(form,VDAT_FORM_SET_G_PIECE_TBL,tblName);

  VDatGetChildObject(&rdbNodesID,1,&rdbNodeID);
  if (rdbNodeID.objid == NULL_OBJID) {
    strcpy(tblName,"Not a Tree");
  }
  else {
    VDatRDBGetTableName(&rdbNodeID,tblName);
  }
  VIg_set_text(form,VDAT_FORM_SET_G_TREE_TBL,tblName);

  retFlag = 1;

wrapup:
  return retFlag;
}
#endif

/* --------------------------------------
 * User changed set type
 */
IGRstat VDatCMDSetNotifyType(Form form)
{
  IGRstat retFlag = 0;
  IGRchar rdbSetType[128];

  VIg_get_text(form,VDAT_FORM_SET_G_SET_TYPE,rdbSetType);

  VDatCMDSetFillMisc(form,rdbSetType);

  retFlag = 1;

  return retFlag;
}

/* --------------------------------------------------
 * Fills in list of available set types
 */
IGRstat VDatCMDSetFillTypes(Form form, IGRint gadget)
{
  IGRstat retFlag = 0;
  IGRint  i;

  IGRchar setType[64];

#if 0
  TGRid   mgrID;
  TGRid   rdbSetsID;
  TGRid   rdbSetID;
  IGRchar rdbSetType[128];
#endif

  // Init
  // FIg_set_text(form,gadget,"");
  VIfld_set_list_num_rows(form,gadget,0,0);

#if 0  
  vdat$GetSetMgr(mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) goto wrapup;

  VDatRDBGetSets(&mgrID,&rdbSetsID);
  if (rdbSetsID.objid == NULL_OBJID) goto wrapup;

  // Cycle Through
  for(i = 0; VDatGetChildObject(&rdbSetsID,i,&rdbSetID); i++) {

    VDatGetBaseName(&rdbSetID,rdbSetType);
    VIfld_set_list_text(form,gadget,i,0,rdbSetType,0);
  }
#endif

  for(i = 0; 
      vdat$GetSetTypeInfo(setTypeInd = i, setTypeO = setType); 
      i++) {
    VIfld_set_list_text(form,gadget,i,0,setType,0);
  }  
  retFlag = 1;

//wrapup:
  return retFlag;
}

/* -------------------------------------------
 * The notification routine, called by the ppl
 */
#argsused
IGRstat VDatCMDSetNotifyForm(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  Form    form;
  IGRint  gadget;

  // Form has all global data
  form   = fl->form;
  gadget = fl->gadget;

  switch(gadget) {

  case VDAT_FORM_SET_G_SET_TYPE: {
    VDatCMDSetNotifyType(form);
    retFlag = 1;
    goto wrapup;
  }

  case VDAT_FORM_SET_B_CREATE_SET: {
    VDatCMDSetCreateSet(fl);
    retFlag = 1;
    goto wrapup;
  }

  case VDAT_FORM_SET_B_DELETE_SET: {
    VDatCMDSetDeleteSet(fl);
    retFlag = 1;
    goto wrapup;
  }  

  case VDAT_FORM_SET_B_RENAME_SET: {
    VDatCMDSetRenameSet(fl);
    retFlag = 1;
    goto wrapup;
  }

  case FI_RESET: {
    retFlag = 1;
    goto wrapup;
  }

  case FI_CANCEL: {
    VIf_erase(form);
    VDatFormSetActive(form,0);
    retFlag = 1;
    goto wrapup;
  }
  }

wrapup:
  return retFlag;
}

/* --------------------------------------
 * Called when user pushes an open button
 */
IGRstat VDatCMDSetActivateForm(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  IGRstat sts;
  Form    form;

  // Arg check
  if ((fl == NULL) || (fl->set == NULL)) goto wrapup;
  form = fl->set;

  // Ignore if already active for now
  sts = VDatFormIsActive(form);
  if (sts == 1) {
    retFlag = 1;
    goto wrapup;
  }

  // Just display
  VIf_display(form);
  VDatFormSetActive(form,1);
  VDatCMDSetFillTypes(form,VDAT_FORM_SET_G_SET_TYPE);

  // Fills in active set info
  VDatCMDSetActivateSet(fl);

  retFlag = 1;

wrapup:
  return retFlag;
}

end implementation VDatBase;





