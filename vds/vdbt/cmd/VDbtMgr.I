/* $Id: VDbtMgr.I,v 1.1.1.1 2001/01/04 21:07:57 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdbt/cmd/VDbtMgr.I
 *
 * Description: Manager Form
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDbtMgr.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:57  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1998/04/05  13:34:26  pinnacle
# ah
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/04/98  ah      creation
 *
 ***************************************************************************/

class implementation VDbtBase;

#include "VDmaster.h"
#include "VDfrm.h"

#include "VDbtCmd.h"

#define VDBT_FORM_MGR_L_SETS 21

#define VDBT_FORM_MGR_B_SETS  12
#define VDBT_FORM_MGR_B_LEAFS 13
#define VDBT_FORM_MGR_B_TREES 15
#define VDBT_FORM_MGR_B_ATTRS 16
#define VDBT_FORM_MGR_B_REPS  17
#define VDBT_FORM_MGR_B_STAGE 18
#define VDBT_FORM_MGR_B_POST  23

#define VDBT_FORM_MGR_B_HILITE   19
#define VDBT_FORM_MGR_B_UNHILITE 37

#if 0
IGRstat VDatCMDMgrFillSets(Form form, IGRint gadget);
IGRstat VDatCMDMgrFillAll (Form form);

IGRstat VDatCMDMgrNotifySets(TVDatFrmList *fl);

IGRstat VDatCMDMgrAddSet(
  TVDatFrmList *fl,
  TGRid        *setID,
  IGRchar      *setName,
  IGRchar      *setType
);
IGRstat VDatCMDMgrDeleteSet(
  TVDatFrmList *fl,
  TGRid        *setID,
  IGRchar      *setName
);

IGRstat VDatCMDMgrHiLiteSet(TVDatFrmList *fl);

/* ----------------------------------------
 * New active set was picked
 */
IGRstat VDatCMDMgrActivateSet(TVDatFrmList *fl)
{
  Form  form = fl->mgr;
  TGRid setID;
  
  VDatCMDAllGetActiveSet(fl, &setID, NULL);

  if (VDatIsSetATree(&setID))  {
    VIg_enable(form,VDAT_FORM_MGR_B_TREES);
    VIg_enable(form,VDAT_FORM_MGR_B_STAGE);
  }
  else {
    VIg_disable(form,VDAT_FORM_MGR_B_TREES);
    VIg_disable(form,VDAT_FORM_MGR_B_STAGE);
  }

  return 1;
}

/* ----------------------------------------
 * Hilite active set
 */
IGRstat VDatCMDMgrHiLiteSet(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;
  TGRid   setID,leafsID;

  VDatCMDAllGetActiveSet(fl, &setID, NULL);
  if (setID.objid == NULL_OBJID) goto wrapup;

  // Get the leafs
  VDatGetLeafs(&setID,&leafsID);
  if (leafsID.objid == NULL_OBJID) goto wrapup;

  // Display them
  VDatDisplayNode(&leafsID,GRhhd);

  retFlag = 1;

wrapup:
  return retFlag;
}

/* --------------------------------------
 * Someone deleted a set
 */
#argsused
IGRstat VDatCMDMgrDeleteSet(
  TVDatFrmList *fl,
  TGRid        *a_setID,
  IGRchar      *a_setName
)
{
  IGRstat retFlag = 0;

  Form   form   = fl->mgr;
  IGRint gadget = VDAT_FORM_MGR_L_SETS;

  TGRid setID;
  
  // Refill list
  VDatCMDMgrFillSets(form, gadget);

  // No set active
  setID.objid = NULL_OBJID;
  setID.osnum = 0;
  VDatCMDAllSetActiveSet(fl, &setID);

  retFlag = 1;
  return retFlag;
}

/* --------------------------------------
 * Someone renamed a set
 */
#argsused
IGRstat VDatCMDMgrRenameSet(
  TVDatFrmList *fl,
  TGRid        *a_setID,
  IGRchar      *a_setName
)
{
  IGRstat retFlag = 0;

  Form   form   = fl->mgr;
  IGRint gadget = VDAT_FORM_MGR_L_SETS;
  
  // Refill list
  VDatCMDMgrFillSets(form, gadget);

  // Make it active forcing forms to refresh themselvse
  VDatCMDAllSetActiveSet(fl, a_setID);

  retFlag = 1;
  return retFlag;
}

/* --------------------------------------
 * Someone created a set
 */
IGRstat VDatCMDMgrAddSet(
  TVDatFrmList *fl,
  TGRid        *setID,
  IGRchar      *setName,
  IGRchar      *setType
)
{
  IGRstat retFlag = 0;
  IGRint  row;
  Form    form = fl->mgr;
  IGRint  gadget = VDAT_FORM_MGR_L_SETS;

  IGRchar  refName[1024];
  IGRchar *pnt;

  // Insert at end
  row = -1;
  VIfld_get_num_rows(form,gadget,&row);
  if (row < 0) goto wrapup;

  // OS Name
  strcpy(refName,OM_GA_OSDs[setID->osnum]->name);
  pnt = strrchr(refName,'/');
  if (pnt) strcpy(refName,pnt+1);

  VDahFrmSetTextRC(form,gadget,row,0,refName);
  VDahFrmSetTextRC(form,gadget,row,1,setName);
  VDahFrmSetTextRC(form,gadget,row,2,setType);
  VDahFrmSetGRid  (form,gadget,row,3,setID);

  // Want row to be selected and displayed
  VIfld_set_select(form,gadget,row,0,1);
  VIfld_set_select(form,gadget,row,1,1);
  VIfld_set_select(form,gadget,row,2,1);
  VDatFormShowRow (form,gadget,row);

  // Tell the rest of world about it
  VDatCMDAllSetActiveSet(fl,setID);

  retFlag = 1;
wrapup:
  return retFlag;
}

/* --------------------------------------
 * User poked a set in the list
 */
IGRstat VDatCMDMgrNotifySets(TVDatFrmList *fl)
{
  IGRstat retFlag = 0;

  Form    form   = fl->mgr;
  IGRint  gadget = VDAT_FORM_MGR_L_SETS;

  IGRint  row,pos;

  TGRid   setID;

  // Get active row
  row = -1;
  VIfld_get_active_row(form,gadget,&row,&pos);
  if (row < 0) goto wrapup;

  // Get the set
  VDahFrmGetGRid(form,gadget,row,3,&setID);  
  if (setID.objid == NULL_OBJID) goto wrapup;
  
  VDatCMDAllSetActiveSet(fl,&setID);

  retFlag = 1;

wrapup:
  if (retFlag == 1) {
    VIfld_set_select(form,gadget,row,0,1);
    VIfld_set_select(form,gadget,row,1,1);
    VIfld_set_select(form,gadget,row,2,1);
  }
  else {
    VIfld_set_select(form,gadget,row,0,0);
    VIfld_set_select(form,gadget,row,1,0);
    VIfld_set_select(form,gadget,row,2,0);
    VIg_set_text(form,10,"Bad Set Selected");
  }

  return retFlag;
}

/* ----------------------------------------
 * Fill in one file of sets
 */
IGRstat VDatCMDMgrFillSet(Form form, IGRint gadget, IGRint *row, VDosnum osnum)
{
  IGRstat retFlag = 0;

  TGRid  mgrID;

  TGRid setsID;
  TGRid  setID;

  TGRid rdbSetID;

  IGRchar setName[128];
  IGRchar setType[128];
  IGRchar *pnt;

  IGRchar refName[DI_PATH_MAX];

  IGRint  i;

  // OS Name
  strcpy(refName,OM_GA_OSDs[osnum]->name);
  pnt = strrchr(refName,'/');
  if (pnt) strcpy(refName,pnt+1);

  // For active, do ?

  // Get the manager
  vdat$GetSetMgr(osnum = osnum, mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) goto wrapup;

  // Get the sets
  VDatGetSets(&mgrID,&setsID);
  if (setsID.objid == NULL_OBJID) goto wrapup;

  // Cycle Through
  for(i = 0; VDatGetChildObject(&setsID,i,&setID); i++) {

    // Show name for now
    VDahFrmSetTextRC(form,gadget,*row,0,refName);

    // Show name for now
    *setName = 0;
    VDatGetBaseName(&setID,setName);
    VDahFrmSetTextRC(form,gadget,*row,1,setName);

    // Get the set type
    VDatRDBGetSet  (&setID,&rdbSetID);
    VDatGetBaseName(&rdbSetID,setType);
    VDahFrmSetTextRC(form,gadget,*row,2,setType);

    // Store the id
    VDahFrmSetGRid(form,gadget,*row,3,&setID);
    
    // Next Row
    *row = *row + 1;
  }

  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* ----------------------------------------
 * Fill in list of sets
 */
IGRstat VDatCMDMgrFillSets(Form form, IGRint gadget)
{
  IGRstat retFlag = 0;

  IGRint row;

  IGRint    refI;
  TGRmd_env refENV;
  TVDvlaENV refEnvVLA;

  // Clear Field
  VIfld_set_num_rows(form,gadget,0);
  row = 0;

  // Get list of files
  VDvlaENV_Construct(&refEnvVLA);
  VDahRefGetRefList (&refEnvVLA);

  for(refI = 0; VDvlaENV_GetAt(&refEnvVLA,&refENV,refI); refI++) {

    VDatCMDMgrFillSet(form, gadget, &row, refENV.md_id.osnum);

  }

  retFlag = 1;

//wrapup:
  VDvlaENV_Delete(&refEnvVLA);
  return retFlag;
}

/* ----------------------------------------------------
 * Fill everything on manager form
 */
IGRstat VDatCMDMgrFillAll(Form form)
{
  IGRstat retFlag = 0;

  if (form == NULL) goto wrapup;

  VDatCMDMgrFillSets(form,VDAT_FORM_MGR_L_SETS);

  retFlag = 1;
wrapup:
  return retFlag;
}

/* ------------------------------------------------------
 * Wrapper to convert fence into vla
 * later may want to handle mod env better
 */
IGRstat VDahGetFenceVLA(TGRobj_env *objOE, TVDvlaOE *objVLA)
{
  IGRstat retFlag = 0;
  IGRint  cnt = 0;
  IGRint  i;
  TGRobj_env *listOE = NULL;

  as$start_fence(
    set     = &objOE->obj_id,
    set_env = &objOE->mod_env,
    nb_obj  = &cnt,
    p_obj_env = &listOE
  );
  for(i = 0; i < cnt; i++) {
    VDvlaOE_Append(objVLA,&listOE[i]);
  }
  ASend_fence(); // Frees listOE

  retFlag = 1;
  return retFlag;
}
#endif

/* -----------------------------------------------------
 * An object was selected
 */
IGRstat VDbtCMD_MgrNotifyObject(TVDbtCMD_Info *info, TGRobj_env *setOE)
{
  IGRstat  retFlag = 0;
  TVDvlaOE setVLA;

  // Get the objects
  VDvlaOE_Construct(&setVLA);
  VDahGetFenceVLA(setOE, &setVLA);

  // Send them onwards
  // VDatCMDLeafNotifyObject(fl,&setVLA);

  retFlag = 1;
//wrapup:
  VDvlaOE_Delete(&setVLA);
  return retFlag;
}

/* -------------------------------------------
 * The notification routine, called by the ppl
 */
#argsused
IGRstat VDbtCMD_MgrNotifyForm(TVDbtCMD_Info *info)
{
  IGRstat retFlag = 0;
  IGRstat msg;

  // Arg Check
  if (info == NULL) {
    printf("Form notification reached with NULL Data\n");
    goto wrapup;
  }

  // Form has all global data
  if (info->form == NULL) {
    printf("NULL Form Pointer\n");
    goto wrapup;
  }

  // See which form caused message
  if (info->form == info->set.form) { 
    //retFlag = VDatCMDSetNotifyForm(info);
    goto wrapup;
  }
  if (info->form == info->leaf.form) { 
    //retFlag = VDatCMDLeafNotifyForm(info);
    goto wrapup;
  }
  if (info->form == info->tree.form) { 
    //retFlag = VDatCMDTreeNotifyForm(info);
    goto wrapup;
  }
  if (info->form == info->attr.form) { 
    //retFlag = VDatCMDAttrNotifyForm(info);
    goto wrapup;
  }
  if (info->form == info->stage.form) { 
    //retFlag = VDatCMDStageNotifyForm(info);
    goto wrapup;
  }

  // Should be the manager itself
  if (info->form != info->mgr.form) goto wrapup;
  
  switch(info->gadget) {

  case VDBT_FORM_MGR_B_POST:     
    //retFlag = VDatPOSTAll();
    break;

  case VDBT_FORM_MGR_B_UNHILITE:
    dp$erase_hilite(msg = &msg);
    retFlag = 1;
    break;

  case VDBT_FORM_MGR_B_HILITE:
    //VDatCMDMgrHiLiteSet(fl);
    break;

  case VDBT_FORM_MGR_L_SETS:
    //retFlag = VDatCMDMgrNotifySets(fl);
    break;

  case FI_CANCEL:
    retFlag = FI_CANCEL;  // Will bubble up and shutdown command
    break;

  case VDBT_FORM_MGR_B_SETS:
    //retFlag = VDatCMDSetActivateForm(fl);
    break;

  case VDBT_FORM_MGR_B_LEAFS:
    //retFlag = VDatCMDLeafActivateForm(fl);
    break;

  case VDBT_FORM_MGR_B_TREES:
    //retFlag = VDatCMDTreeActivateForm(fl);
    break;

  case VDBT_FORM_MGR_B_ATTRS:
    //retFlag = VDatCMDAttrActivateForm(fl);
    break;

  case VDBT_FORM_MGR_B_STAGE: 
    //retFlag = VDatCMDStageActivateForm(fl);
    break;

  case VDBT_FORM_MGR_B_REPS:
    retFlag = 1;
    break;

  default:
    goto wrapup;
  }

wrapup:
  return retFlag;
}

/* --------------------------------------
 * Called by ppl to start everything up
 * info has been cleard
 * forms have been created
 */
IGRstar VDbtCMD_MgrInit(TVDbtCMD_Info *info)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  //TGRid mgrID;
  //TGRid setID;

  /* Need to be logged in */
  sts = VDsaVerifyLogin();
  if (!(sts & 1)) {
    UI_status("Please log into PDM first.");
    goto wrapup;
  }

  /* List of locate classes */
  sts = VDbtCMD_MgrClassList(&info->classList);
  if (!(sts & 1)) {
    UI_status("Problem getting locatable classes");
    goto wrapup;
  }

  /* Set the objid's to null
   */
  info->mgr.id.objid   = NULL_OBJID;
  info->set.id.objid   = NULL_OBJID;
  info->leaf.id.objid  = NULL_OBJID;
  info->tree.id.objid  = NULL_OBJID;
  info->attr.id.objid  = NULL_OBJID;
  info->stage.id.objid = NULL_OBJID;

  // Position from file
  vdfrm$LoadFormPosition(form = info->mgr.form);
  vdfrm$LoadFormPosition(form = info->set.form);
  vdfrm$LoadFormPosition(form = info->leaf.form);
  vdfrm$LoadFormPosition(form = info->tree.form);
  vdfrm$LoadFormPosition(form = info->attr.form);
  vdfrm$LoadFormPosition(form = info->stage.form);
  vdfrm$LoadFormPosition(form = info->mgr.form);

  // Display manager
  vdfrm$DisplayForm(form = info->mgr.form, flag = &info->mgr.dis);
  info->mgr.act = 1;

#if 0
  // Make sure have a manager or create one
  vdat$GetSetMgr(mgrID = &mgrID);
  if (mgrID.objid == NULL_OBJID) {
    vdat$CreateSetMgr(mgrID = &mgrID);
  }
  if (mgrID.objid == NULL_OBJID) {
    goto wrapup;
  }

  // No default active set yet 
  setID.objid = NULL_OBJID;
  setID.osnum = 0;
  VDatCMDAllSetActiveSet(fl,&setID);

  /* Fill Everyting */
  VDatCMDMgrFillAll(fl->mgr);
#endif

  /* Erase any existing highlites */
  sts = dp$erase_hilite(msg = &msg);

  /* Done */
  UI_status("Set Manager Ready");
  retFlag = 1;

  info->initedOK = 1;

wrapup:
  return retFlag;
}

/* --------------------------------------
 * Called by ppl to shut things down
 * Not much to do anymore
 */
#argsused
IGRstar VDbtCMD_MgrDelete(TVDbtCMD_Info *info)
{
  IGRstat retFlag = 0;
  IGRstat msg;

  // Un hilite
  dp$erase_hilite(msg = &msg);

  // Stroe position in file
  vdfrm$SaveFormPosition(form = info->mgr.form);
  vdfrm$SaveFormPosition(form = info->set.form);
  vdfrm$SaveFormPosition(form = info->leaf.form);
  vdfrm$SaveFormPosition(form = info->tree.form);
  vdfrm$SaveFormPosition(form = info->attr.form);
  vdfrm$SaveFormPosition(form = info->stage.form);

  // Delete them
  vdfrm$DeleteForm(form = info->mgr.form);
  vdfrm$DeleteForm(form = info->set.form);
  vdfrm$DeleteForm(form = info->leaf.form);
  vdfrm$DeleteForm(form = info->tree.form);
  vdfrm$DeleteForm(form = info->attr.form);
  vdfrm$DeleteForm(form = info->stage.form);

  retFlag = 1;

  return retFlag;
}

#argsused
IGRstar VDbtCMD_MgrWakeup(TVDbtCMD_Info *info)
{
  IGRstat retFlag = 1;

  /* Ignore first one */
  if (info->enableWakeup == 0) goto wrapup;

  /* Wakup all active forms, need to deal with hilite later */
  if (info->mgr.act)   vdfrm$DisplayForm(form = info->mgr.form);
  if (info->set.act)   vdfrm$DisplayForm(form = info->set.form);
  if (info->leaf.act)  vdfrm$DisplayForm(form = info->leaf.form);
  if (info->tree.act)  vdfrm$DisplayForm(form = info->tree.form);
  if (info->attr.act)  vdfrm$DisplayForm(form = info->attr.form);
  if (info->stage.act) vdfrm$DisplayForm(form = info->stage.form);

  retFlag = 1;

wrapup:
  return retFlag;
}

#argsused
IGRstar VDbtCMD_MgrSleep(TVDbtCMD_Info *info)
{
  return 1;
}

static VDclassid classListIDs[8];

IGRstar VDbtCMD_MgrClassList(OM_S_CLASSLIST *classList)
{
  IGRstat retFlag = 0;
  int i = 0;

  classListIDs[i] = 0;
  om$get_classid( 
    classname = "VSplate",
    p_classid = &classListIDs[i]
  ) ;
  if (classListIDs[i] != 0) i++;

  classListIDs[i] = 0;
  om$get_classid( 
    classname = "VSbeam",
    p_classid = &classListIDs[i]
  ) ;
  if (classListIDs[i] != 0) i++;

  classListIDs[i] = 0;
  om$get_classid( 
    classname = "VDequipment",
    p_classid = &classListIDs[i]
  ) ;
  if (classListIDs[i] != 0) i++;

  classList->p_classes = classListIDs;
  classList->w_count   = i;
  classList->w_flags   = OM_CLST_subclass;

  retFlag = 1;

  return retFlag;
}

end implementation VDbtBase;




